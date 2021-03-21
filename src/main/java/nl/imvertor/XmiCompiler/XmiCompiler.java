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

package nl.imvertor.XmiCompiler;

import java.io.File;
import java.io.IOException;

import javax.xml.xpath.XPathConstants;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.NodeList;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.exceptions.EnvironmentException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.EapFile;
import nl.imvertor.common.file.OutputFolder;
import nl.imvertor.common.file.XmiFile;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.file.ZipFile;

/**
 * This step-class compiles an XMI file or passes a provides file provided,
 * and places it in the workspace. 
 *  
 * @author arjan
 *
 */
public class XmiCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(XmiCompiler.class);
	
	public static final String STEP_NAME = "XmiCompiler";
	public static final String VC_IDENTIFIER = "$Id: XmiCompiler.java 7501 2016-04-15 14:37:27Z arjan $";

	private AnyFile passedFile;
	private XmlFile activeFile;
	private AnyFile idFile;
	private String activeFileOrigin;
	
	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Compiling XMI");

		// check what file is passed on the command line.
		
		AnyFile umlFile = new AnyFile(configurator.getFile(configurator.getXParm("cli/umlfile")));
		boolean refreshXmi = configurator.isTrue("cli", "refreshxmi", false);

		EapFile eapFile = umlFile.getExtension().toLowerCase().equals("eap") ? new EapFile(umlFile) : null;
		XmiFile xmiFile = umlFile.getExtension().toLowerCase().equals("xmi") ? new XmiFile(umlFile) : null;
		ZipFile zipFile = umlFile.getExtension().toLowerCase().equals("zip") ? new ZipFile(umlFile) : null; // holds single XMI, /images, and an optional /modeldoc folder 
		
		AnyFolder xmiFolder = umlFile.isDirectory() ? new AnyFolder(umlFile) : null; // may hold a range of files and folders
		
		boolean succeeds = true;
		
		// assmume no images passed.
		configurator.setXParm("system/xmi-image-count", 0);
		
		if (activeFileOrigin == null && xmiFolder != null) {
			runner.debug(logger,"CHAIN", "Try XMI folder at: " + xmiFolder);
			passedFile = xmiFolder;
			activeFileOrigin = "XMI folder passed";
		}
		if (activeFileOrigin == null && zipFile != null) {
			runner.debug(logger,"CHAIN", "Try compressed XMI file at: " + zipFile);
			if (zipFile.isFile()) {
				passedFile = zipFile;
				activeFileOrigin = "Compressed XMI passed";
			}
		}
		if (activeFileOrigin == null && xmiFile != null) {
			runner.debug(logger,"CHAIN", "Try XMI file at: " + xmiFile);
			if (xmiFile.isFile()) {
				passedFile = xmiFile;
				activeFileOrigin = "XMI passed";
			}
		}
		if (activeFileOrigin == null && eapFile != null) {
		    runner.debug(logger,"CHAIN","Try EAP file at: " + eapFile);
		    if (!configurator.isEaEnabled()) {
		    	runner.error(logger,"EAP file is not supported in this environment: " + eapFile);
		    } else if (!eapFile.isFile()) {
		    	runner.error(logger,"EAP file doesn't exist: " + eapFile);
		    } else if (eapFile.isAccessible()) {
				passedFile = eapFile;
				activeFileOrigin = "EAP passed";
			} else 
				throw new EnvironmentException("Cannot access EA (on 32 bit java)");
		}	
		
		if (activeFileOrigin == null) {
			runner.error(logger,"No such ZIP, XMI or EAP file");
		} else {
			String filespec = " " + passedFile + " (" + activeFileOrigin + ")";
			activeFile = new XmlFile(configurator.getXParm("properties/WORK_XMI_FOLDER") + File.separator + passedFile.getName() + ".xmi");
			String compactXmiFilePath = activeFile.getCanonicalPath() + ".compact.xmi";
			
			if (passedFile instanceof EapFile) {
				// EAP is provided
				// IM-108 speed up: do not read same EAP twice
				String f1 = "";
				idFile = new AnyFile(activeFile.getCanonicalPath() + ".id");
				activeFile.getParentFile().mkdirs();
				if (activeFile.exists()) 
					f1 = (idFile.exists()) ? idFile.getContent() : "";
				String f2 = passedFile.getFileInfo();
				
				String projectname = configurator.getXParm("cli/owner") + ": " + configurator.getXParm("cli/project");
				String modelname = configurator.getXParm("cli/application");
		
				Boolean noSuchModel = checkModel(compactXmiFilePath,projectname,modelname); // when changing the requested model and EA export has not changed, determine that EA should be re-read.
				
				if (!f1.equals(f2) || refreshXmi || noSuchModel) {
					runner.info(logger,"Reading" + filespec);
					
					// clean the XMI folder here
					(new OutputFolder(configurator.getXParm("system/work-xmi-folder-path",true))).clear(false);
					
					// Export images here. The type of image is set to PNG. The images are stored in /XMI folder under /Images.
					if (configurator.isTrue(configurator.getXParm("cli/createimagemap"))) 
						((EapFile) passedFile).setExportDiagrams(EapFile.EXPORT_IMAGE_TYPE_PNG);
					else
						((EapFile) passedFile).setExportDiagrams(EapFile.EXPORT_IMAGE_TYPE_NONE);
					
					if (exportEapToXmi((EapFile) passedFile, activeFile,projectname,modelname) != null) { 
						// and place file info in ID file
						idFile.setContent(passedFile.getFileInfo());
						cleanXMI(activeFile);
					} else {
						succeeds = false;
					}
				} else {
					runner.info(logger,"Reusing" + filespec);
				}
				
				AnyFolder targetFolder = new AnyFolder(activeFile.getParentFile().getCanonicalPath() + "/Images");
				if (targetFolder.isDirectory() && targetFolder.list().length != 0) {
					configurator.setXParm("system/xmi-image-count", targetFolder.list().length);
				} 
				
			} else if (passedFile instanceof ZipFile) {
				// XMI is provided in compressed form
				AnyFolder tempFolder = new AnyFolder(configurator.getXParm("properties/WORK_ZIP_FOLDER"));
				((ZipFile) passedFile).decompress(tempFolder);
				
				processFilesInDeliveryFolder(tempFolder);
				
				tempFolder.deleteDirectory();
				
			} else if (passedFile instanceof AnyFolder) { 
				
				processFilesInDeliveryFolder(passedFile);
				
			} else {
				// XMI is provided directly
				runner.info(logger,"Reading" + filespec);
				passedFile.copyFile(activeFile);
				cleanXMI(activeFile);
			}
		
			if (succeeds) {
				// first copy this source file to xmi folder when requested; this does not include the images!
				if (configurator.isTrue("cli","copyxmi",false)) {
					File targetFile = new File(configurator.getXParm("system/work-xmi-s-folder-path"),"model.xmi");
					activeFile.copyFile(targetFile);
				}
				
				// then process it.
				String mode = configurator.getXParm("cli/migrate",false);
				if (mode != null) 
					migrateXMI(activeFile,mode);
				
				configurator.setXParm("system/xmi-export-file-path",activeFile.getCanonicalPath());
				configurator.setXParm("system/xmi-file-path",compactXmiFilePath);
				
				// now compact the XMI file: remove all irrelevant sections
				runner.debug(logger,"CHAIN", "Compacting XMI: " + activeFile.getCanonicalPath());
				Transformer transformer = new Transformer();
		
				// transform 
				succeeds = succeeds ? transformer.transformStep("system/xmi-export-file-path", "system/xmi-file-path",  "properties/XMI_CONFIG_XSLPATH") : false ;
				succeeds = succeeds ? transformer.transformStep("system/xmi-export-file-path", "system/xmi-file-path",  "properties/XMI_COMPACT_XSLPATH") : false ;
			}
		}
					
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
		return runner.succeeds();

	}
		
	/**
	 * Kopieer de relevante onderdelen van de aangeleverde folder naar de werkomgeving
	 * 
	 * @param tempFolder
	 * @throws Exception
	 */
	private void processFilesInDeliveryFolder(File tempFolder) throws Exception {
		File[] files = tempFolder.listFiles(); // may be one file (xmi) or two (xmi and Images folder)
		
		if (files.length == 0) 
			runner.fatal(logger, "No files found in ZIP",null,"NFFIZ");
		else {
			for (int i = 0; i < files.length; i++) {
				if (files[i].isDirectory()) {
					AnyFolder sourceFolder = new AnyFolder(files[i]);
					AnyFolder targetFolder = new AnyFolder(activeFile.getParentFile().getCanonicalPath() + File.separator + sourceFolder.getName());
					sourceFolder.copy(targetFolder);
					if (sourceFolder.getName().equals("Images")) 
						configurator.setXParm("system/xmi-image-count", sourceFolder.list().length);
				} 
				else if (files[i].getName().endsWith(".xmi")) {
					AnyFile file = new AnyFile(files[i]);
					file.copyFile(activeFile);
					cleanXMI(activeFile);
				}
			}
		}
	}

	private XmlFile exportEapToXmi(EapFile eapFile, XmlFile xmifile, String projectName, String modelName) throws Exception {
		eapFile.open();
		String packageGUID = (modelName == null) ? eapFile.getProjectPackageGUID(projectName) : eapFile.getModelPackageGUID(projectName, modelName);
		XmlFile r = null;
		if (packageGUID.equals("")) 
			if (modelName == null)
				configurator.getRunner().error(logger, "No such project \"" + projectName + "\" found");
			else
				configurator.getRunner().error(logger, "No such project/model \"" + projectName + "/" + modelName + "\" found");
		else 
			r = eapFile.exportToXmiFile(xmifile.getCanonicalPath(), packageGUID);
		eapFile.close();
		return r;
	}
	
	/**
	 * Fix on EA bug. XMI must not contain invalid character references. Hope this solves it.
	 * 
	 * @param xmiFile
	 * @throws Exception 
	 */
	private void cleanXMI(XmlFile xmiFile) throws Exception {
		
		String c = xmiFile.getContent();
		if (c.contains("&#5"))
			xmiFile.setContent(StringUtils.replacePattern(c, "&#5[0-9]{4};", "?"));
	}
	
	private void migrateXMI(XmlFile xmiFile, String mode) throws Exception {
		runner.warn(logger,"This model is subject to migration rules, please consider aligning the model with the metamodel",null,"TMISTMR");
		AnyFile outFile = new AnyFile(File.createTempFile("migrateXMI.", ".xmi"));
		outFile.deleteOnExit();
		String xslFilePath = configurator.getXslPath(configurator.getXParm("properties/XMI_MIGRATE_XSLPATH"));
		XslFile xslFile = new XslFile(xslFilePath);
		runner.debug(logger,"CHAIN", "Migrating XMI: " + activeFile.getCanonicalPath());
		Transformer transformer = new Transformer();
		transformer.setXslParm("migration-mode",mode);
		transformer.transform(xmiFile, outFile, xslFile,null);
		outFile.copyFile(xmiFile);
	}
	
	private Boolean checkModel(String compactXmiFilePath, String projectname, String modelname) {
		// the passed file is an EAP. The export is in the XMI workfolder
		XmlFile f = new XmlFile(compactXmiFilePath);
		try {
			NodeList models = (NodeList) f.xpathToObject("/XMI/XMI.content[1]/*:Model[1]/*:Namespace.ownedElement[1]/*:Package[1][@name = '" + modelname + "']",null,XPathConstants.NODESET);
			return models.getLength() != 1;
		} catch (Exception e) {
			return true; // something happened; check.
		}
		
		
	}
}
