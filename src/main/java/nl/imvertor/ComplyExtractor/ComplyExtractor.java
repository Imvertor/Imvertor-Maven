/*
 * Copyright (C) 2016 VNG/KING
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

package nl.imvertor.ComplyExtractor;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.ZipFile;

public class ComplyExtractor extends Step {

	protected static final Logger logger = Logger.getLogger(ComplyExtractor.class);
	
	public static final String STEP_NAME = "ComplyExtractor";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
		
		// file:/D:/projects/validprojects/Kadaster-Imvertor/Imvertor-OS-work/KING/app/xsd/bsmr0320/bsmr0320.xsd
			
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Extracting Compliancy XML");
		
		// STUB
		configurator.setParm("appinfo","release","00000001");
		
		boolean succeeds = true;
		
		// fetch the fill-in form file, and serialize it to a folder
		String templateFilepath = configurator.getParm("cli", "cmpfile", true);
		String unzipFolderpath = configurator.getParm("properties", "WORK_COMPLY_TEMPLATE_FOLDERPATH", true);

		ZipFile template = new ZipFile(templateFilepath);
		AnyFolder serializeFolder = new AnyFolder(unzipFolderpath);
		template.serializeToXml(serializeFolder);
		
		// in the exported file we find _content.xml, which is the base for all transformations and holds all XML content found.
		// transform the exported folder any way required, on the basis of _content,xml.
		// No special processing (repackaging) is required for this step.
		Transformer transformer = new Transformer();

		XmlFile contentFile = new XmlFile(serializeFolder,AnyFolder.SERIALIZED_CONTENT_XML_FILENAME);
		configurator.setParm("system", "comply-content-file", contentFile.getCanonicalPath());
		// extract the instance info from the serialized OO XML excel file 
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_EXTRACT_FILE", "properties/WORK_COMPLY_EXTRACT_XSLPATH","system/comply-content-file") : false;
		// build the XML instances
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_BUILD_FILE", "properties/WORK_COMPLY_BUILD_XSLPATH","system/comply-content-file") : false;
		
		// now first generate the test files
		transformer.setXslParm("generation-mode", "final");
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_MAKE_FILE_FINAL", "properties/WORK_COMPLY_MAKE_XSLPATH") : false;
		
		// then do the same, but insert variables in order to test the validity of the tests
		transformer.setXslParm("generation-mode", "valid");
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_MAKE_FILE_VALID", "properties/WORK_COMPLY_MAKE_XSLPATH") : false;
		
		//validate the generate XML instances against the schema.
		AnyFolder folder = new AnyFolder(configurator.getParm("properties","WORK_COMPLY_MAKE_FOLDER_VALID"));
		if (folder.exists())
			succeeds = succeeds ? validateAndReport(folder) : false;
		else {
			succeeds = false;
			runner.error(logger,"No instances created.");
		}
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
		    
		return runner.succeeds();
		
	}
	
	/** 
	 * Process the validation results into reportable messages.
	 * 
	 * @param folder
	 * @return
	 * @throws IOException
	 * @throws ConfiguratorException
	 */
	public boolean validateAndReport(AnyFolder folder) throws IOException, ConfiguratorException {
		Vector<String> vl = validateXmlFolder(folder);
		if (vl.size() != 0) 
			runner.error(logger, vl.size() + " errors/warnings found in generated XSD. This release should not be distributed. Please notify your administrator.");
		Iterator<String> it = vl.iterator();
		while (it.hasNext()) {
			String m = it.next();
			runner.error(logger, "XML test instance error: " + m);
		}
		configurator.setParm("appinfo","test-instance-error-count", vl.size());
		return (vl.size() == 0) ? true : false;
	}
	
	/**
	 * Validate each file in the folder.
	 * Assume the file holds a reference to the schema (xsi:schemLocation)
	 * 
	 * @param folder
	 * @return
	 */
	public Vector<String> validateXmlFolder(AnyFolder folder) {
		//TODO improve format of message, check out xsd validation step.
		File[] filesAndDirs = folder.listFiles();
		List<File> filesDirs = Arrays.asList(filesAndDirs);
		Vector<String> vl = new Vector<String>();
		for (File file : filesDirs) {
			if (file.isDirectory()) {
				vl.addAll(validateXmlFolder(new AnyFolder(file)));
			} else if (file.getName().endsWith(".xml")) {
				XmlFile xmlFile = new XmlFile(file);
				xmlFile.isValid();
				Vector<String> v = xmlFile.getMessages();
				vl.addAll(v);			
			}
		}
		return vl;
	}
}
