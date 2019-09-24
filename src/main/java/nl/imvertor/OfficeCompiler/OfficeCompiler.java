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
import java.util.Vector;

import org.apache.log4j.Logger;
import org.springframework.util.StringUtils;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.FtpFolder;
import nl.imvertor.common.git.ResourcePusher;

public class OfficeCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(OfficeCompiler.class);
	
	public static final String STEP_NAME = "OfficeCompiler";
	public static final String VC_IDENTIFIER = "$Id: OfficeCompiler.java 7457 2016-03-05 08:43:43Z arjan $";
	
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
		String mm = configurator.getXParm("cli/metamodel");
		
		if (op.equals("html")) {
			runner.info(logger,"Creating documentation");
			Transformer transformer = new Transformer();
			
			boolean succeeds = true;
			
			// append codelists and reference lists to imvertor file when referenced and when required.
			succeeds = succeeds ? transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/WORK_LISTS_FILE", "properties/IMVERTOR_LISTS_XSLPATH","system/cur-imvertor-filepath") : false;
		
			// creates an XML modeldoc intermediate file which is the basis for output
			// each second, third... step is known as _2, _3 etc. in the parameter sequence as configured.
			// first step has no sequence number.
						
			/*
			succeeds = succeeds ? transformer.transformStep("properties/WORK_LISTS_FILE","properties/WORK_MODELDOC_FILE", "properties/IMVERTOR_METAMODEL_" + mm + "_MODELDOC_XSLPATH") : false;
			*/
			int i = 1;
			while (true) {
				String xslname = "IMVERTOR_METAMODEL_" + mm + "_MODELDOC_XSLPATH" + ((i == 1) ? "" : ("_" + i));
				String outname = "WORK_MODELDOC_FILE" + ((i == 1) ? "" : ("_" + i));
				if (configurator.getParm("properties", xslname, false) != null) {
					succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/" + outname, "properties/" + xslname, "system/cur-imvertor-filepath") : false ;
					i += 1;
				} else if (i == 0) {
					// first canonization is required: for each metamodel a primary canonization must be configured 
					runner.error(logger,"No such supported metamodel or invalid modeldoc configuration: " + mm);
					break;
				} else
					break;
			}
			
			// variants may be "office" or "respec"
			Vector<String> vr = Configurator.split(configurator.getXParm("cli/createofficevariant"),"\\s+");
			if (vr.contains("msword") || vr.contains("respec")) {
			
				String template = configurator.getXParm("cli/officename"); // e.g. resolved [project-name]-[application-name]-[phase]-[release]
				String fn = configurator.mergeParms(template);
			
				if (vr.contains("msword")) {
					succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/WORK_MSWORD_FILE", "properties/IMVERTOR_METAMODEL_" + mm + "_MODELDOC_MSWORD_XSLPATH") : false;
					if (succeeds) processDoc(fn,"msword.html","appinfo/msword-documentation-filename","properties/WORK_MSWORD_FILE");
					// copy along the msword template file (docm), if any
					String path = configurator.getXParm("system/configuration-owner-msword-folder",false);
					if (path != null) { 
						AnyFolder mswordFolder = new AnyFolder(path);
						if (mswordFolder.isDirectory()) 
							mswordFolder.copy(new AnyFolder(configurator.getXParm("system/work-cat-folder-path") + "/msword"));
					}
				}
				if (vr.contains("respec")) {
					succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/WORK_RESPEC_FILE", "properties/IMVERTOR_METAMODEL_" + mm + "_MODELDOC_RESPEC_XSLPATH") : false;
					if (succeeds) processDoc(fn,"respec.html","appinfo/respec-documentation-filename","properties/WORK_RESPEC_FILE");
				}
			} else {
				runner.error(logger,"No (valid) office variant specified: " + vr.toString());
				succeeds = false;
			}
			
		} else {
			runner.error(logger,"Transformation to Office format not implemented yet!");
		}
	}
	private String trim(String urlfrag) {
		return StringUtils.trimTrailingCharacter(StringUtils.trimLeadingCharacter(urlfrag,'/'),'/');
	}
	
	/*
	 * Copy the file from work to cat folder, and pass on to ftp/git when needed.
	 */
	private void processDoc(String documentname, String extension, String xparmOfficefile, String xparmWorkfile) throws Exception {
		configurator.setXParm(xparmOfficefile, documentname + "." + extension);
		
		AnyFile infoOfficeFile = new AnyFile(configurator.getXParm(xparmWorkfile));
		AnyFile officeFile = new AnyFile(configurator.getXParm("system/work-cat-folder-path") + "/" + documentname + "." + extension);
		infoOfficeFile.copyFile(officeFile);
		
		// see if this result should be sent on to FTP/GIT
		String target = configurator.getXParm("cli/passoffice",false);
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
		
		String gitemail     	        = configurator.getServerProperty("git.email"); // email address
		String gituser     	            = configurator.getServerProperty("git.user"); // user name
		String gitpass     	            = configurator.getServerProperty("git.pass"); // password
		String gitlocal     	        = configurator.getServerProperty("git.local"); // location of local git repositories 
			
		String giturl     	            = configurator.mergeParms(configurator.getXParm("cli/giturl")); //url of web page
		String gitpath     	            = configurator.mergeParms(configurator.getXParm("cli/gitpath")); //subpath to repos
		String gitcomment 				= configurator.mergeParms(configurator.getXParm("cli/gitcomment")); // comment to set on update
							
		runner.info(logger, "GIT Pushing as " + officeFile.getName());
		
		AnyFolder gitfolder = new AnyFolder(gitlocal + gitpath);
		
		// must remove this folder, as pushes and pulls will not work from OTAPs.
		if (gitfolder.isDirectory()) gitfolder.deleteDirectory();
		
		// create and prepare the GIT resource pusher
		ResourcePusher rp = new ResourcePusher();
		rp.prepare("https://github.com" + gitpath, gitfolder, gituser, gitpass, gitemail);
		
		// copy the files to the work folder
		catfolder.copy(new AnyFolder(gitfolder,"data"));
        
		// push with appropriate comment
		rp.push(gitcomment);
		
		configurator.setXParm("properties/giturl-resolved", giturl);
	}
}
