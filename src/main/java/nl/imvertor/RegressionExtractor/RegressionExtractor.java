/*
 * Copyright (C) 2019 Armatiek Solutions BV
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

package nl.imvertor.RegressionExtractor;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Vector;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import nl.armatiek.saxon.extensions.http.SendRequest;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.xsl.extensions.ImvertorCompareXML;
import nl.imvertor.common.xsl.extensions.ImvertorFileSpec;
import nl.imvertor.common.xsl.extensions.ImvertorMergeParms;
import nl.imvertor.common.xsl.extensions.ImvertorParameterFile;
import nl.imvertor.common.xsl.extensions.ImvertorStripAccents;
import nl.imvertor.common.xsl.extensions.ImvertorTrack;

public class RegressionExtractor  extends Step {

	protected static final Logger logger = Logger.getLogger(RegressionExtractor.class);
	
	public static final String STEP_NAME = "RegressionExtractor";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	public static Transformer transformer;
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
			
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Compiling Regression file");
		
		String url = (new File(configurator.getXParm("properties/COMPARE_GENERATED_XSLPATH"))).toURI().toURL().toString();
		configurator.addCatalogMap(
				"http://www.imvertor.org/imvertor/1.0/xslt/compare/compare-generated.xsl", 
				url);
		
		transformer = new Transformer(); // Transformer created on basis of current Configurator
		transformer.setExtensionFunction(new ImvertorCompareXML());
		transformer.setExtensionFunction(new ImvertorStripAccents());
		
		AnyFolder workFolder = new AnyFolder(configurator.getServerProperty("work.dir"));
		
		String identifier = configurator.getXParm("cli/identifier",false);
		String compareMethod = configurator.getXParm("cli/regressionmethod",false);
		       compareMethod = compareMethod == null ? "raw" : compareMethod;
				
		if (identifier == null) {
		    // Bulk test: in regression chain
			
			String r = Configurator.getInstance().getXParm("cli/regowner",false);
			String[] regOwners = StringUtils.split(r.replace(" ", ""),';');
			
			AnyFolder regfolder = new AnyFolder(configurator.getXParm("system/managedregtestfolder"));
			configurator.getRunner().info(logger,"Regression testing bulk mode: " + configurator.getXParm("system/managedregtestfolder"));
		    Iterator<File> owners = Arrays.asList(regfolder.listFiles()).iterator();
			while (owners.hasNext()) {
				AnyFile owner = new AnyFile(owners.next());
				String ownerName = owner.getParentFile().getName();
				if (regOwners.length == 0 || ArrayUtils.contains(regOwners, ownerName)) {
					Iterator<File> projects = Arrays.asList(owner.listFiles()).iterator();
					while (projects.hasNext()) {
						AnyFile project = new AnyFile(projects.next());
						Iterator<File> models = Arrays.asList(project.listFiles()).iterator();
						while (models.hasNext()) {
							AnyFile model = new AnyFile(models.next());
							Iterator<File> releases = Arrays.asList(model.listFiles()).iterator();
							while (releases.hasNext()) {
								AnyFile release = new AnyFile(releases.next());
								String subpath = project.getName() + "_" + model.getName() + "_" + release.getName(); // used as identifier
								
								AnyFolder refFolder = new AnyFolder(release,"ref");
								AnyFolder tstFolder = new AnyFolder(release,"tst");
								AnyFolder outFolder = new AnyFolder(release,"out");
								
								// Maak de test folder leeg en maak een workfolder
								tstFolder.deleteDirectory();
								
								AnyFolder wrkfolder = new AnyFolder(tstFolder,"work");
								wrkfolder.mkdirs();
								
								// kopieer alle files uit de workfolder, als die er is, naar de tst folder
								AnyFolder appFolder = new AnyFolder(workFolder,ownerName + "/app");
								appFolder.copy(wrkfolder);
								
								Integer diffsfound = test(configurator,refFolder,tstFolder,outFolder,subpath,compareMethod);
								if (diffsfound != 0) 
									logger.warn("Regression: " + (compareMethod.equals("raw") ? "some" : diffsfound) + " differences in " + tstFolder);
							}
						}
					}
				} 
			}
		} else if (identifier.equals("DEVELOPMENT")) {
			// Single test: in TranslateAndReport chain
			configurator.getRunner().info(logger,"Regression testing this model");
			String subpath = configurator.getXParm("cli/owner") + "/" + configurator.getXParm("appinfo/subpath");
			AnyFolder regFolder = new AnyFolder(configurator.getXParm("system/managedregtestfolder"));
			if (regFolder.isDirectory()) {
			    AnyFolder refFolder = new AnyFolder(regFolder,"ref/" + subpath);
			    AnyFolder tstFolder = new AnyFolder(regFolder,"tst/" + subpath);
				AnyFolder outFolder = new AnyFolder(regFolder,"out/" + subpath);
				// Maak de test folder leeg en maak een workfolder
				tstFolder.deleteDirectory(); 
				tstFolder.mkdirs();
				// copy the chain results to tst folder
				String jobID =  System.getProperty("job.id");
				AnyFolder appFolder = new AnyFolder(workFolder,jobID + "/app");
				AnyFolder tapFolder = new AnyFolder(tstFolder,"app");
				appFolder.copy(tapFolder);
				//  Run the test
				Integer diffsfound = testFileByFile(configurator,refFolder,tstFolder,outFolder,identifier,compareMethod);
				if (diffsfound != 0) 
					logger.warn("Regression: " + (compareMethod.equals("raw") ? "some" : diffsfound) + " differences in " + tstFolder);
			} else {
				logger.error("Managed regression folder not found: " + regFolder.getName());
			}
		} else {
			// Single test: in regression chain (identifier is usually the owner name)
			configurator.getRunner().info(logger,"Regression testing single model: " + configurator.getXParm("cli/tstfolder"));
		    AnyFolder refFolder = new AnyFolder(configurator.getXParm("cli/reffolder"));
			AnyFolder tstFolder = new AnyFolder(configurator.getXParm("cli/tstfolder"));
			AnyFolder outFolder = new AnyFolder(configurator.getXParm("cli/outfolder"));
			Integer diffsfound = test(configurator,refFolder,tstFolder,outFolder,identifier,compareMethod);
			if (diffsfound != 0) 
				logger.warn("Regression: " + (compareMethod.equals("raw") ? "some" : diffsfound) + " differences in " + tstFolder);
		}
			    
	    report();
		    
		return runner.succeeds();
		
	}
	
	/**
	 * Test the differences between ref and tst folders.
	 * Return the number of recorded differences.
	 * 
	 * @param configurator
	 * @param reffolder
	 * @param tstfolder
	 * @param outfolder
	 * @param identifier
	 * @return
	 * @throws Exception
	 */
	private Integer test(Configurator configurator, AnyFolder reffolder, AnyFolder tstfolder, AnyFolder outfolder, String identifier, String compareMethod) throws Exception {
		
		Integer diffsfound = 0;
		
		//1 serialize the tst folder
		XslFile xslFilterFile = new XslFile(configurator.getXslPath(configurator.getXParm("properties/REGRESSION_EXTRACT_XSLPATH")));
		
		runner.debug(logger,"CHAIN","Serializing test folder: " + tstfolder);
		tstfolder.serializeToXml(transformer,xslFilterFile,"test",true);
		
		//2 serialize the ref folder
		// determine the __content.xml locations in tst and ref
		XmlFile tstContentXML = new XmlFile(tstfolder,AnyFolder.SERIALIZED_CONTENT_XML_FILENAME);
		XmlFile refContentXML = new XmlFile(reffolder,AnyFolder.SERIALIZED_CONTENT_XML_FILENAME);
		XmlFile compareXML    = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_DIFF_FILE"));
		
		// normally the reference folder already holds the __content.xml file, but if not, recreate it here
		// when developing, always replace.
		if (!refContentXML.isFile() || configurator.getRunMode() == Configurator.RUN_MODE_DEVELOPMENT || configurator.isTrue("cli","rebuildref")) {
			runner.debug(logger,"CHAIN","Serializing reference folder; " + reffolder);
			reffolder.serializeToXml(transformer,xslFilterFile,"ctrl",true);
		}
		
		// now compare the two __content.xml files.
		
		if (compareMethod == null || compareMethod.equals("xmlunit")) {
			XslFile tempXsl = new XslFile(configurator.getXParm("properties/COMPARE_GENERATED_XSLPATH")); // ...Imvertor-OS-work\default\compare\generated.xsl
			XslFile compareXsl = new XslFile(configurator.getXParm("properties/COMPARE_GENERATOR_XSLPATH")); // ...RegressionExtractor\compare\xsl\compare.generator.xsl
			XmlFile listingXml = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_LISTING_FILE")); // ...Imvertor-OS-work\default\imvert\compare.2.listing.xml
			
			Boolean valid = true;
			
			transformer.setXslParm("ctrl-filepath", refContentXML.getCanonicalPath());
			transformer.setXslParm("test-filepath", tstContentXML.getCanonicalPath());
			transformer.setXslParm("diff-filepath", compareXML.getCanonicalPath());
			transformer.setXslParm("max-difference-reported", configurator.getXParm("cli/maxreport") == null ? "100" : configurator.getXParm("cli/maxreport"));
			
			//3 create includable stylesheet generated.xsl
			valid = valid && transformer.transform(refContentXML, tempXsl, compareXsl,null);
			
			//4 create listing, while including the generated.xsl
			XslFile listingXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_LISTING_XSLPATH"));
			valid = valid && transformer.transform(refContentXML,listingXml,listingXsl,null);
			// copy the listing to the outfolder. 
			AnyFile outfile = new AnyFile(outfolder,identifier + ".report.xml");
			listingXml.copyFile(outfile);
			
			diffsfound = Integer.parseInt(configurator.getXParm("application/differencesfound"));
		} else if (compareMethod.equals("raw")) {
			// compare contents
			diffsfound = refContentXML.compareContent(tstContentXML) ? 0 : 1;
			
		} else {
			// TODO comparemode is definitediff, roep definitediff aan
		}
	
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    return diffsfound;
	}
	/**
	 * Test the differences between ref and tst folders.
	 * Return the number of recorded differences.
	 * 
	 * @param configurator
	 * @param reffolder Folder holding the reference files
	 * @param tstfolder Folder holding the test files, i.e. to be compared to the reference files.
	 * @param outfolder Output of the comparison.
	 * @param identifier The identifier can be any string. When "DEVELOPMENT" this indicated regression test in development mode, i.e. on a single run.
	 * @return
	 * @throws Exception
	 */
	private Integer testFileByFile(Configurator configurator, AnyFolder reffolder, AnyFolder tstfolder, AnyFolder outfolder, String identifier, String compareMethod) throws Exception {
		
		//1 serialize the tst folder
		XslFile xslFilterFile = new XslFile(configurator.getXslPath(configurator.getXParm("properties/REGRESSION_EXTRACT_CANON_XSLPATH")));
		xslFilterFile.setExtensionFunction(new ImvertorFileSpec());
		xslFilterFile.setExtensionFunction(new ImvertorParameterFile());
		xslFilterFile.setExtensionFunction(new ImvertorMergeParms());
		xslFilterFile.setExtensionFunction(new ImvertorTrack());
		xslFilterFile.setExtensionFunction(new ImvertorStripAccents());
		xslFilterFile.setExtensionFunction(new SendRequest());
		
		xslFilterFile.setParm("dlogger-mode",configurator.getServerProperty("dlogger.mode"));
		xslFilterFile.setParm("dlogger-proxy-url",configurator.getServerProperty("dlogger.proxy.url"));
		xslFilterFile.setParm("dlogger-viewer-url",configurator.getServerProperty("dlogger.viewer.url"));
		xslFilterFile.setParm("dlogger-client-name",configurator.getServerProperty("dlogger.client.name"));
		
		// when developing, always replace the ref-canon.
		if (configurator.getRunMode() == Configurator.RUN_MODE_DEVELOPMENT || configurator.isTrue("cli","rebuildref")) {
			canonizeFolder(reffolder,xslFilterFile,false);
		}
		Integer diffsfound = canonizeFolder(tstfolder,xslFilterFile,true);
		
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    return diffsfound;
	}
	
	/**
	 * Create a folder based on the folder passed which holds all files in canonized form.
	 * 
	 * @param folder Folder to canonize
	 * @param xslFilterFile File that transforms the contents of the XML file such taht it is canonized: removing all non-essential info from the file.
	 * @param compare True when comparison with corresponding tst folder is required.
	 * @return
	 * @throws Exception
	 */
	private Integer canonizeFolder(AnyFolder folder,XslFile xslFilterFile, boolean compare) throws Exception {
		runner.debug(logger,"CHAIN","Serializing folder: " + folder);
		Integer diffsfound = 0;
		
		if (folder.isDirectory()) {
			String folderPath = folder.getCanonicalPath();
			String canonFolderPath = folderPath + "-canon";
			// remove the canonical folder when exists
			(new AnyFolder(canonFolderPath)).deleteDirectory();
			Vector<String> files = folder.listFilesToVector(true); // returns list of canonical paths
			for (int i = 0; i < files.size(); i++) {
				// "canonize" the file, replace existing file by the canonized form
				String origPath = files.get(i);
				String type = FilenameUtils.getExtension(origPath).toLowerCase();
				String relPath = StringUtils.substringAfter(origPath, folderPath);
				String canonPath = folderPath + "-canon" + relPath;
				AnyFile fileOrFolder = new AnyFile(origPath);
				if (fileOrFolder.isFile()) {
					if (type.equals("xml") || type.equals("xsd") || type.equals("xhtml")) { 
						// Compare XML contents
						xslFilterFile.setParm("file-path", relPath);
						xslFilterFile.setParm("file-type", type);
						xslFilterFile.transform(origPath, canonPath);
						XmlFile canonFile = new XmlFile(canonPath);
						if (FileUtils.sizeOf(canonFile) != 0) {
							// canoniseer, vervang het resultaat
							canonicalize(canonFile);
							if (compare) diffsfound += compare(canonPath);
						} else {
							// verwijder het file, XSLT heeft niks gegenereerd en speelt dus geen rol.
							canonFile.delete();
						}
					} else if (type.equals("xmi") || type.equals("png") || type.equals("html")) {
						// skip these files
					} else { 
						// compare raw, unprocessed contents
						fileOrFolder.copyFile(canonPath);
						if (compare) diffsfound += compare(canonPath);
					}
				}
	 		}
			// Verwijder de lege folders.
			removeEmptyFolders(new File(canonFolderPath));
			return diffsfound;
		} else {
			runner.error(logger,"Regression folder not found: " + folder + ", please complete regression setup");
			return 1;
		}
	}

	/**
	 * Compare a reference file with the corresponding test file, both canonized. Pass the ref path, the tst path is calculated by replacing "ref-canon" by "tst-canon". When differences found, signal a warning.
	 * 
	 * @param canonPath The pas to the ref folder.
	 * @return Integer 1 when differences found
	 * @throws IOException
	 * @throws ConfiguratorException
	 */
	private Integer compare(String canonPath) throws IOException, ConfiguratorException {
		String refPath = StringUtils.replacePattern(canonPath,"(\\\\)tst(\\\\)","$1ref$2");
		AnyFile refFile = new AnyFile(refPath);
		AnyFile tstFile = new AnyFile(canonPath);
		if (!refFile.isFile()) {
			runner.warn(logger, "Reference file not found: " + canonPath); 
			return 1;
		} else if (!refFile.compareContent(tstFile)) {
			runner.warn(logger, "Difference(s) found in file: " + canonPath); 
			return 1;
		} else 
			return 0;
	}
	
	private void canonicalize(XmlFile xmlFile) throws Exception {
		if (xmlFile.isWellFormed()) {
			XmlFile tempFile = new XmlFile(File.createTempFile("canonicalize.", "xml"));
			xmlFile.canonicalize(tempFile, "http://www.w3.org/2001/10/xml-exc-c14n#");
			FileUtils.copyFile(tempFile, xmlFile);
			tempFile.delete();
		}
	}
	
	private boolean removeEmptyFolders(File folder) {
		if(folder.isDirectory()){
	        File[] files = folder.listFiles();
	        if (files.length == 0) { //There is no file in this folder - safe to delete
	        	//System.out.println("1>" + folder);
	            folder.delete();
	            return true;
	        } else {
	            int totalFolderCount = 0;
	            int emptyFolderCount = 0;
	            for (File f : files) {
	                if (f.isDirectory()) {
	                    totalFolderCount++;
	                    if (removeEmptyFolders(f)) { //safe to delete
	                        emptyFolderCount++;
	                    }   
	                }
	            }
	            if (totalFolderCount == files.length && emptyFolderCount == totalFolderCount) { //only if all folders are safe to delete then this folder is also safe to delete
	            	//System.out.println("2>" + folder);
	                folder.delete();
	                return true;
	            }
	        }
	    }
	    return false;
	}
}
