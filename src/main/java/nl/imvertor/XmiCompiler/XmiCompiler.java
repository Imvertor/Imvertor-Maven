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
import java.io.FileWriter;
import java.io.IOException;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.exceptions.EnvironmentException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.EapFile;
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
		
		AnyFile umlFile = new AnyFile(configurator.getFile(configurator.getParm("cli", "umlfile")));
		boolean mustReread = configurator.isTrue("cli", "refreshxmi", false);

		EapFile eapFile = umlFile.getExtension().toLowerCase().equals("eap") ? new EapFile(umlFile) : null;
		XmiFile xmiFile = umlFile.getExtension().toLowerCase().equals("xmi") ? new XmiFile(umlFile) : null;
		ZipFile zipFile = umlFile.getExtension().toLowerCase().equals("zip") ? new ZipFile(umlFile) : null; // always holds single XMI
		
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
			activeFile = new XmlFile(configurator.getParm("properties","WORK_XMI_FOLDER") + File.separator + passedFile.getName() + ".xmi");
			
			if (passedFile instanceof EapFile) {
				// EAP is provided
				// IM-108 speed up: do not read same EAP twice
				String f1 = "";
				idFile = new AnyFile(activeFile.getCanonicalPath() + ".id");
				activeFile.getParentFile().mkdirs();
				if (activeFile.exists()) 
					f1 = (idFile.exists()) ? idFile.getContent() : "";
				String f2 = passedFile.getFileInfo();
				if (!f1.equals(f2) || mustReread) {
					runner.info(logger,"Reading" + filespec);
					exportEapToXmi((EapFile) passedFile, activeFile);
					// and place file info in ID file
					idFile.setContent(passedFile.getFileInfo());
					cleanXMI(activeFile);
				} else {
					runner.info(logger,"Reusing" + filespec);
				}
			} else if (passedFile instanceof ZipFile) {
				// XMI is provided in compressed form
				AnyFolder tempFolder = new AnyFolder(configurator.getParm("properties","WORK_ZIP_FOLDER"));
				((ZipFile) passedFile).decompress(tempFolder);
				File[] files = tempFolder.listFiles();
				if (files.length == 0) 
					runner.fatal(logger, "No files found in ZIP",null,"NFFIZ");
				else if (files.length > 1) 
					runner.fatal(logger, "Multiple files found in ZIP",null,"MFFIZ");
				else {
					(new AnyFile(files[0])).copyFile(activeFile);
					cleanXMI(activeFile);
				}
				tempFolder.deleteDirectory();
			} else {
				// XMI is provided directly
				runner.info(logger,"Reading" + filespec);
				passedFile.copyFile(activeFile);
				cleanXMI(activeFile);
			}
		
			if (configurator.isTrue(configurator.getParm("cli","migrate",false))) 
				migrateXMI(activeFile);
			
			configurator.setParm("system","xmi-export-file-path",activeFile.getCanonicalPath());
			configurator.setParm("system","xmi-file-path",activeFile.getCanonicalPath() + ".compact.xmi");
			
			// now compact the XMI file: remove all irrelevant sections
			runner.debug(logger,"CHAIN", "Compacting XMI: " + activeFile.getCanonicalPath());
			Transformer transformer = new Transformer();
		    // transform 
			boolean succeeds = true;
			succeeds = succeeds ? transformer.transformStep("system/xmi-export-file-path", "system/xmi-file-path",  "properties/XMI_COMPACT_XSLPATH") : false ;
				
		}
					
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
		return runner.succeeds();

	}
	
	private XmlFile exportEapToXmi(EapFile eapFile, XmlFile xmifile) throws Exception {
		eapFile.open();
		String rootPackageGUID = eapFile.getRootPackageGUID();
		XmlFile r = eapFile.exportToXmiFile(xmifile.getCanonicalPath(), rootPackageGUID);
		eapFile.close();
		return r;
	}
	
	/**
	 * Fix on EA bug. XMI must not contain invalid character references. Hope this solves it.
	 * 
	 * @param xmiFile
	 * @throws IOException
	 */
	private void cleanXMI(XmlFile xmiFile) throws IOException {
		AnyFile outFile = new AnyFile(File.createTempFile("cleanXMI.", ".xmi"));
		outFile.deleteOnExit();
		//FileWriterWithEncoding writer = outFile.getWriterWithEncoding("UTF-8", false);
		FileWriter writer = outFile.getWriter(false);
		String line = xmiFile.getNextLine();
		while (line != null) {
			line = StringUtils.replacePattern(line, "&#5[0-9]{4};", "X");
			//line = StringUtils.replacePattern(line, "encoding=\"windows-1252\"", "encoding=\"UTF-8\"");
			writer.write(line + "\n");
			line = xmiFile.getNextLine();
		}
		writer.flush();
		writer.close();
		outFile.copyFile(xmiFile);
	}
	
	private void migrateXMI(XmlFile xmiFile) throws Exception {
		AnyFile outFile = new AnyFile(File.createTempFile("migrateXMI.", ".xmi"));
		outFile.deleteOnExit();
		String xslFilePath = configurator.getXslPath(configurator.getParm("properties", "XMI_MIGRATE_XSLPATH"));
		XslFile xslFile = new XslFile(xslFilePath);
		runner.debug(logger,"CHAIN", "Migrating XMI: " + activeFile.getCanonicalPath());
		Transformer transformer = new Transformer();
		transformer.transform(xmiFile, outFile, xslFile,null);
		outFile.copyFile(xmiFile);
	}
	
}
