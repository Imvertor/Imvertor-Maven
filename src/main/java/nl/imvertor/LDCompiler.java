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

package nl.imvertor;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.RdfFile;
import nl.imvertor.common.file.XmlFile;

public class LDCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(LDCompiler.class);
	
	public static final String STEP_NAME = "LDCompiler";
	public static final String VC_IDENTIFIER = "$Id: XsdCompiler.java 7509 2016-04-25 13:30:29Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling Linked Data");
		generateLD();
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate Kadaster Linked data Turtle file from the compiled Imvert files.
	 * 
	 * @throws Exception
	 */
	public boolean generateLD() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder ldFolder = new AnyFolder(configurator.getXParm("system/work-ld-folder-path"));
		ldFolder.mkdirs();
				
		AnyFolder ldApplicationFolder = new AnyFolder(configurator.getXParm("properties/RESULT_LD_APPLICATION_FOLDER"));
		ldApplicationFolder.mkdirs();
		
		configurator.setXParm("system/ld-folder-path", ldApplicationFolder.toURI().toString());
	
		runner.debug(logger,"CHAIN","Generating Linked Data to " + ldApplicationFolder);
		
		succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_LD_RDF_FILE_PATH", "properties/IMVERTOR_METAMODEL_Kadaster_LD_XSLPATH");
		
		if (succeeds) {
			// This step generated an XML RDF file. Transform to Turtle.
			RdfFile xmlFile = new RdfFile(configurator.getXParm("properties/RESULT_LD_RDF_FILE_PATH")); // created by XSLT transform
			RdfFile turtleFile = new RdfFile(configurator.getXParm("properties/RESULT_LD_TTL_FILE_PATH")); // Created by Rio Turtle convertor
			xmlFile.export(turtleFile,RdfFile.EXPORT_FORMAT_XML,RdfFile.EXPORT_FORMAT_TURTLE);
			// copy to the app folder
			XmlFile appLdFile = new XmlFile(ldFolder,"LinkedData.ttl");
			turtleFile.copyFile(appLdFile);
			configurator.setXParm("system/ld-created","true");
		}
		
		return succeeds;
	}
	
	
}
