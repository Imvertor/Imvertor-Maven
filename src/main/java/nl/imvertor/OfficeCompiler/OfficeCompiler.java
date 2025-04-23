/*
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package nl.imvertor.OfficeCompiler;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import java.util.Vector;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.eclipse.jgit.transport.PushResult;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.FtpFolder;
import nl.imvertor.common.file.WordFile;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.ZipFile;
import nl.imvertor.common.git.ResourcePusher;
import nl.imvertor.common.xsl.extensions.ImvertorCalculateHashlabel;
import nl.imvertor.common.xsl.extensions.expath.ImvertorExpathWriteBinary;

public class OfficeCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(OfficeCompiler.class);
	
	public static final String STEP_NAME = "OfficeCompiler";
	public static final String VC_IDENTIFIER = "$Id: OfficeCompiler.java 7457 2016-03-05 08:43:43Z arjan $";
	
	private AnyFolder workFolder;
	private AnyFolder moduleFolder;
	
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		generateOfficeReport();
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    report();
		return runner.succeeds();

	}
	
	/**
	 * Generate a Pdf Report.
	 * This transforms the imvertor system code to some format that may be inserted into an Office doument environment, not defined yet.
	 * At least, for now, it is assumed to generate HTML.  
	 * 
	 * @throws Exception
	 */
	public void generateOfficeReport() throws Exception {
		String op = configurator.getXParm("cli/createoffice");
		String dr = configurator.getXParm("appinfo/docrules");
		
		if (op.equals("html")) {
			runner.info(logger,"Creating documentation");
			Transformer transformer = new Transformer();
			transformer.setExtensionFunction(new ImvertorCalculateHashlabel());
			transformer.setExtensionFunction(new ImvertorExpathWriteBinary());
				
			boolean succeeds = true;
			
			// append codelists and reference lists to imvertor file when referenced and when required.
			succeeds = succeeds ? transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/WORK_LISTS_FILE", "properties/IMVERTOR_LISTS_XSLPATH","system/cur-imvertor-filepath") : false;
		
			// creates an XML modeldoc intermediate file which is the basis for output
			// each second, third... step is known as _2, _3 etc. in the parameter sequence as configured.
			// first step has no sequence number.
						
			/*
			succeeds = succeeds ? transformer.transformStep("properties/WORK_LISTS_FILE","properties/WORK_MODELDOC_FILE", "properties/IMVERTOR_METAMODEL_" + dr + "_MODELDOC_XSLPATH") : false;
			*/
			int i = 1;
			String lastModeldocFile = "";
			while (true) {
				String xslname = "IMVERTOR_METAMODEL_" + dr + "_MODELDOC_XSLPATH" + ((i == 1) ? "" : ("_" + i));
				String outname = "WORK_MODELDOC_FILE" + ((i == 1) ? "" : ("_" + i));
				if (configurator.getParm("properties", xslname, false) != null) {
					lastModeldocFile = configurator.getXParm("properties/" + outname); // onthoud welk file als laatste in de reeks is gegenereerd
					succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/" + outname, "properties/" + xslname, "system/cur-imvertor-filepath") : false ;
					i += 1;
				} else if (i == 0) {
					// first canonization is required: for each metamodel a primary canonization must be configured 
					runner.error(logger,"No such supported docrules or invalid modeldoc configuration: " + dr);
					break;
				} else
					break;
			}
			
			Vector<String> vr = Configurator.split(configurator.getXParm("cli/createofficevariant"),"\\s+");
			if (vr.contains("msword") || vr.contains("respec") || vr.contains("documentor")) {
			
				String template = configurator.getXParm("cli/officename"); // e.g. resolved [project-name]-[application-name]-[phase]-[release]
				String fn = configurator.mergeParms(template);
			
				configurator.setXParm("system/officename-resolved", fn); // resolved, dus bijv. CM-Testmodel-1-20231114
				
				if (vr.contains("msword")) {
					succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/WORK_MSWORD_FILE", "properties/IMVERTOR_METAMODEL_" + dr + "_MODELDOC_MSWORD_XSLPATH") : false;
					if (succeeds) processDoc(fn,"msword.html","appinfo/msword-documentation-filename","properties/WORK_MSWORD_FILE","none");
					// copy along the msword template file (docm), if any, but do not pass to git/ftp
					String path = configurator.getXParm("system/configuration-owner-msword-folder",false);
					if (path != null) { 
						AnyFolder mswordFolder = new AnyFolder(path);
						if (mswordFolder.isDirectory()) 
							mswordFolder.copy(new AnyFolder(configurator.getXParm("system/work-cat-folder-path") + "/msword"));
					}
				}//msword
				if (vr.contains("respec") || vr.contains("documentor")) {
		
					// process catalog only, save as XHTML
					succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/WORK_RESPEC_FILE", "properties/IMVERTOR_MODELDOC_RESPEC_XSLPATH") : false;
					if (succeeds) processDoc(fn,"respec.catalog.xhtml","appinfo/catalog-documentation-filename","properties/WORK_RESPEC_FILE","none");
					
					// als documentor info beschikbaar is, dan uitpakken en omzetten naar xhtml met Pandoc
					String mdf = configurator.getXParm("cli/documentorfile",false);
					
					Boolean useDefault = false;
					if (mdf == null && vr.contains("documentor")) { 
						runner.warn(logger, "Documentor processing requested but no modeldoc folder passed. Using default model documentation.");
						mdf = configurator.getBaseFolder() + "/etc/respec/documentor";
						useDefault = true;
					}
				
					configurator.setXParm("documentor/use-default", useDefault ? "yes" : "no");
					
					if (succeeds && vr.contains("documentor")) {
						
						// Er is documentor input in de vorm van modeldocs meegeleverd.
						// Zo niet, val terug op default modeldoc.
						
						// Maak de workfolder en de module folder aan
						workFolder = new AnyFolder(configurator.getWorkFolder("documentor"));
						if (workFolder.isDirectory()) workFolder.deleteDirectory(); 
						workFolder.mkdir();
						configurator.setXParm("documentor/modeldoc-workfolder",workFolder.getCanonicalPath());
						
						moduleFolder = new AnyFolder(workFolder,"module");
						if (moduleFolder.isDirectory()) moduleFolder.deleteDirectory();
						moduleFolder.mkdir();
						configurator.setXParm("documentor/modeldoc-modulefolder",moduleFolder.getCanonicalPath());
						
						// check het type modeldoc. In development: folder, in productie: zipfile
						AnyFile docFile = new AnyFile(mdf);
						boolean isZip = docFile.getExtension().equals("zip");
						if (isZip) {
							runner.debug(logger,"CHAIN","Extracting documentor files");
							// alles uitpakken naar de workfolder
							ZipFile zipFile = new ZipFile(docFile);
							zipFile.decompress(workFolder);
						} else {
							runner.debug(logger,"CHAIN","Copying documentor files");
							// alles kopieren naar de workfolder
							(new AnyFolder(docFile)).copy(workFolder);
						}
						
						// maak een kopie van alle *relevante* files in de workfolder en verzamel deze in de modulefolder.
						String modelName = useDefault ? "default" : configurator.getXParm("appinfo/original-application-name");
						succeeds = succeeds ? copyFilesToModulefolder(workFolder + "/modeldoc/" + modelName, modelName, true, true) : false;
						succeeds = succeeds ? copyFilesToModulefolder(workFolder + "/sections", modelName, true, false) : false;
						
						// de files zijn uitgelezen en omgezet naar XHTML
						// nu de bestanden integreren, start bij het masterdoc, als dat er is -- masterdoc wordt bepaald bij het scannen van de files..
						String masterdocPath = configurator.getXParm("documentor/masterdoc-path",false);
						if (masterdocPath == null) { 
							runner.warn(logger, "Documentor processing requested but no modeldoc file \"" + modelName + "/" + modelName + ".docx\" found");
							succeeds = false;
						}
						// kopieer het masterdoc naar de imvertor workfolder
						if (succeeds) {
							(new AnyFile(masterdocPath)).copyFile(configurator.getXParm("properties/IMVERTOR_DOCUMENTOR_CORESCANNER_FILE"));
							succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/IMVERTOR_DOCUMENTOR_CORESCANNER_FILE", "properties/IMVERTOR_DOCUMENTOR_CORESCANNER_XSLPATH","system/cur-imvertor-filepath") : false;
							succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/IMVERTOR_DOCUMENTOR_COREMODES_FILE", "properties/IMVERTOR_DOCUMENTOR_COREMODES_XSLPATH","system/cur-imvertor-filepath") : false;
							succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/IMVERTOR_DOCUMENTOR_XHTMLTORESPEC_FILE", "properties/IMVERTOR_DOCUMENTOR_XHTMLTORESPEC_XSLPATH","system/cur-imvertor-filepath") : false;
						}
						if (succeeds) {
							
							// kopieer documentor configuratie naar de cat folder. Eerst de standaard "Imvertor" files, en daaroverheen de owner files.
							AnyFolder target = new AnyFolder(configurator.getWorkFolder() + "/app/cat/documentor");
							target.mkdirs();
							AnyFolder imvertorFolder = new AnyFolder(configurator.getBaseFolder(), "input/Imvertor/cfg/docrules/documentor"); // waaronder default.css en default.js
							imvertorFolder.copy(target);
							// kopieer documentor configuratie
							if (configurator.getXParm("documentor/image-zoomer").equals("pan-zoom-image") || configurator.getXParm("documentor/diagram-zoomer").equals("pan-zoom-image")) {
								AnyFolder leafletFolder = new AnyFolder(configurator.getBaseFolder(), "etc/respec/leaflet");
								leafletFolder.copyFolder(target);
							}
							AnyFolder ownerFolder = new AnyFolder(useDefault ? configurator.getBaseFolder() + "/input/Imvertor/cfg/docrules/documentor" : configurator.getInputFolder() + "/cfg/docrules/documentor");
							if (ownerFolder.isDirectory()) 
								ownerFolder.copy(target);
							else
								runner.warn(logger, "Documentor has not been configured for \""+ configurator.getXParm("cli/owner") +"\". Please contact your system administrator.");
							
							// kopieer de gecachte versie van de respec config javascript naar de js folder 
							AnyFolder cacheFolder = new AnyFolder(configurator.getBaseFolder() + "/etc/respec/cache/" + configurator.getXParm("documentor/respec-config")); 
							AnyFolder jsFolder = new AnyFolder(target + "/js");
							cacheFolder.copy(jsFolder);
						}
					}
					configurator.setXParm("system/cur-imvertor-filepath", lastModeldocFile);
					
					if (succeeds) {
						// we hebben nu het hele document in respec format, met daarin de catalogus. Plaats dit document als body van het Respec resultaat document.
						if (configurator.isTrue("cli","fullrespec", false)) {
							// process complete report
							transformer.setXslParm("catalog-only", "false");
							succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/WORK_RESPEC_FILE", "properties/IMVERTOR_METAMODEL_" + dr + "_MODELDOC_RESPEC_XSLPATH") : false;
							
							// als de fn is "index", vervang dan de extensie door (index.)html
							String fullExt = (fn.equals("index")) ? "html" : "respec.full.html";
							if (succeeds) processDoc(fn,fullExt,"appinfo/full-respec-documentation-filename","properties/WORK_RESPEC_FILE","none");
						}
						
						// process catalog only, save as HTML
						transformer.setXslParm("catalog-only", "true");
						succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/WORK_RESPEC_FILE", "properties/IMVERTOR_METAMODEL_" + dr + "_MODELDOC_RESPEC_XSLPATH") : false;
						if (succeeds) processDoc(fn,"respec.html","appinfo/respec-documentation-filename","properties/WORK_RESPEC_FILE",configurator.getXParm("cli/passoffice",false));
					}
					
				}//respec
			} else {
				runner.error(logger,"No (valid) office variant specified: " + vr.toString());
				succeeds = false;
			}
			
		} else {
			runner.error(logger,"Transformation to Office format not implemented yet!");
		}
	}
	private String trim(String urlfrag) {
		return StringUtils.removeEnd(StringUtils.removeStart(urlfrag,"/"),"/");
	}
	
	/*
	 * Copy the file from work to cat folder, and pass on to ftp/git when needed.
	 */
	private void processDoc(String documentname, String extension, String xparmOfficefile, String xparmWorkfile, String target) throws Exception {
		configurator.setXParm(xparmOfficefile, documentname + "." + extension);
		
		AnyFile infoOfficeFile = new AnyFile(configurator.getXParm(xparmWorkfile));
		AnyFile officeFile = new AnyFile(configurator.getXParm("system/work-cat-folder-path") + "/" + documentname + "." + extension);
		infoOfficeFile.copyFile(officeFile);
		
		// see if this result should be sent on to FTP/GIT
		
		if (target != null) 
			if (target.equals("ftp")) {
				passFTP(officeFile);
			} else if (target.equals("git")) {
				passGIThub(officeFile);
			} else if (target.equals("none")) {
				// ignore
			} else 
				runner.error(logger, "Not a known remote resource (passoffice): " + target);
	}
	
	private void passFTP(File officeFile) throws IOException, ConfiguratorException {
		String passftp              = trim(configurator.getXParm("cli/passftp"));
		String passpath 			= trim(configurator.getXParm("cli/passpath"));
		String passprotocol 		= configurator.getXParm("cli/passprotocol",false);
		String passuser 			= configurator.getXParm("cli/passuser");
		String passpass 			= configurator.getXParm("cli/passpass");
		
		String targetpath = "ftp://" + passftp + "/" + passpath;
		
		runner.info(logger, "Uploading to " + targetpath + "/" + officeFile.getName());
		
		FtpFolder ftpFolder = new FtpFolder();
		
		ftpFolder.server = passftp;
		ftpFolder.protocol = passprotocol;
		ftpFolder.username = passuser;
		ftpFolder.password = passpass;

		ftpFolder.connectTimeout = 120000;
		ftpFolder.controlKeepAliveTimeout = 180;
		ftpFolder.dataTimeout = 120000;

		try {
			ftpFolder.login();
			ftpFolder.upload(officeFile.getParentFile().getCanonicalPath(),passpath);
			ftpFolder.logout();
	    } catch (Exception e) {
	    	runner.warn(logger, e.getMessage());
			runner.warn(logger, "Cannot upload to " + targetpath);
		}

	}
	private void passGIThub(File officeFile) throws Exception {
		AnyFolder catfolder = new AnyFolder(officeFile.getParent());
		
		String gitcfg = configurator.mergeParms(configurator.getXParm("cli/gitcfg")); //name of the git configuration
		String postfix = "." + gitcfg;
		
		String gitemail     	        = configurator.getServerProperty("git.email" + postfix); // email address
		String gituser     	            = configurator.getServerProperty("git.user" + postfix); // user name
		String gitpass     	            = configurator.getServerProperty("git.pass" + postfix, false); // password
		String gittoken     	        = configurator.getServerProperty("git.token" + postfix); // personal access token
		String gitlocal     	        = configurator.getServerProperty("git.local" + postfix); // location of local git repositories 
			
		String giturl     	            = configurator.mergeParms(configurator.getXParm("cli/giturl")); //url of web page
		String gitpath     	            = configurator.mergeParms(configurator.getXParm("cli/gitpath")); //subpath to repos
		String gitcomment 				= configurator.mergeParms(configurator.getXParm("cli/gitcomment")); // comment to set on update
							
		runner.info(logger, "GIT Pushing as " + officeFile.getName());
		
		try {
			AnyFolder gitfolder = new AnyFolder(gitlocal + gitpath);
			
			// must remove this folder, as pushes and pulls will not work from OTAPs.
			//if (gitfolder.isDirectory()) gitfolder.deleteDirectory();
			
			// create and prepare the GIT resource pusher
			ResourcePusher rp = new ResourcePusher();
			rp.prepare("https://github.com" + gitpath, gitfolder, gituser, gitpass, gittoken, gitemail, true);
			
			// copy the files to the work folder
			catfolder.copy(new AnyFolder(gitfolder,"data"));
	        
			// push with appropriate comment
			Iterator<PushResult> result = rp.push(gitcomment).iterator();
			while (result.hasNext()) {
				String next = result.next().getMessages();
				if (next.matches(".*\\S.*")) logger.warn(next); else logger.info("Push succeeds");  
			}
			
			configurator.setXParm("properties/giturl-resolved", giturl);
		} catch (Exception e) {
			runner.error(logger, "Error pushing files to remote repository https://github.com" + gitpath + ": " + e.getMessage(),e);
		}
	}
	
	private boolean transformDocx(AnyFile mswordFile) throws Exception {
		WordFile infile = new WordFile(mswordFile);
		XmlFile outfile = new XmlFile(mswordFile.getCanonicalPath() + ".xhtml");
		
		runner.info(logger,"Processing " + infile.getName());

		Transformer transformer = new Transformer();
		
		boolean succeeds = true;
		
		succeeds = succeeds ? infile.correctCodeSpaces() : false;
		
		succeeds = succeeds? infile.toXhtmlFile(outfile) : false;
				
		configurator.getRunner().debug(logger,"DOCUMENTOR","File prepared okay? " + succeeds);
		
		if (succeeds) {
			// transformeer die XHTML naar iets bruikbaars, extraheer ook meteen respec properties
			transformer.setXslParm("msword-file-path", outfile.getCanonicalPath());
			transformer.setXslParm("msword-file-name", outfile.getNameNoExtension());
			configurator.setXParm("system/cur-imvertor-filepath", outfile.getCanonicalPath());
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/IMVERTOR_DOCUMENTOR_FILEPREPARE_FILE", "properties/IMVERTOR_DOCUMENTOR_FILEPREPARE_XSLPATH","system/cur-imvertor-filepath") : false;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/IMVERTOR_DOCUMENTOR_FILEFINALIZE_FILE", "properties/IMVERTOR_DOCUMENTOR_FILEFINALIZE_XSLPATH","system/cur-imvertor-filepath") : false;
			// vervang het file met de aangepaste XHTML file
			if (succeeds) (new AnyFile(configurator.getXParm("properties/IMVERTOR_DOCUMENTOR_FILEFINALIZE_FILE"))).copyFile(outfile);
		}
		return succeeds;
	}
	
	private boolean copyFilesToModulefolder(String workSubFolderPath, String modelName, boolean recurse, boolean mustExist) throws Exception {
		
		// workfolder is gemaakt; alle MsWord bestanden omzetten naar XHTML
		AnyFolder workSubFolder = new AnyFolder(workSubFolderPath);
		workSubFolderPath = workSubFolder.getCanonicalPath(); // forward slash correctie
		if (workSubFolder.isDirectory()) {
			// eerste slag: alle docx files transformeren naar standaard XHTML vorm.
			Iterator<String> it1 = workSubFolder.listFilesToVector(recurse).iterator();
			boolean succeeds = true;
			while (it1.hasNext()) {
				String path = it1.next();
				AnyFile f = new AnyFile(path);
				Boolean isMasterDoc = f.getParent().equals(workSubFolderPath) && f.getName().equals(modelName + ".docx");
				String fileUri = f.toURI().toString();
				// Kies de te verwerken bestanden: het moet een docx file zijn, het is de masterdoc of het is een lokaal subdocument. Sla alle msword werkbestanden over. 
				if (f.getExtension().equals("docx") && (isMasterDoc || StringUtils.contains(fileUri,"/sections/")) && !StringUtils.startsWith(f.getName(),"~"))
					succeeds = succeeds ? transformDocx(f) : false ;
			}
			// tweede slag: alles kopieren naar module folder
			Iterator<String> it2 = workSubFolder.listFilesToVector(recurse).iterator();
			while (it2.hasNext()) {
				AnyFile f = new AnyFile(it2.next());
				String fileName = f.getName();
				String fileUri = f.toURI().toString();
				
				// Kopieer de msword resultaten en de include files naar de module folder. 
				if (f.isFile()) {
					Boolean isWordFile = StringUtils.endsWith(fileName,".docx.xhtml");
					Boolean isIncludeFile = StringUtils.contains(fileUri,"/include/");
					if (isWordFile || isIncludeFile) {
						String filepath = (isWordFile) ? moduleFolder + "/" + fileName : configurator.getWorkFolder() + "/app/cat/inc/" + fileName;
						AnyFile moduleFile = new AnyFile(filepath);
						if (moduleFile.isFile()) {
							runner.error(logger, "Duplicate file name in documentor input: " + fileName);
							succeeds = false;
						} else 
							f.copyFile(moduleFile);
					}
				}
			}
	
			return succeeds;
		} else
			return !mustExist;
	}
	
}
