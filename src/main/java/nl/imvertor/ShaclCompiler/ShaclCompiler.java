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

package nl.imvertor.ShaclCompiler;

import java.nio.charset.StandardCharsets;

import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.ShaclFile;
import nl.imvertor.common.file.XmlFile;

public class ShaclCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(ShaclCompiler.class);
	
	public static final String STEP_NAME = "ShaclCompiler";
	public static final String VC_IDENTIFIER = "$Id: XsdCompiler.java 7509 2016-04-25 13:30:29Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling SHACL");
		generateSHACL();
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate Kadaster XSD from the compiled Imvert files.
	 * 
	 * See http://shacl.org/playground/ for validator
	 * 
	 * @throws Exception
	 */
	public boolean generateSHACL() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder shaclFolder = new AnyFolder(configurator.getXParm("system/work-shacl-folder-path"));
		shaclFolder.mkdirs();
				
		AnyFolder shaclApplicationFolder = new AnyFolder(configurator.getXParm("properties/RESULT_SHACL_APPLICATION_FOLDER"));
		shaclApplicationFolder.mkdirs();
		
		configurator.setXParm("system/shacl-folder-path", shaclApplicationFolder.toURI().toString());
	
		runner.debug(logger,"CHAIN","Generating SHACL to " + shaclApplicationFolder);
		
		succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_SHACL_FILE_PATH", "properties/IMVERTOR_METAMODEL_Kadaster_SHACL_XSLPATH");
		
		if (succeeds) {
			ShaclFile shaclFile = new ShaclFile(configurator.getXParm("properties/RESULT_SHACL_FILE_PATH"));
			
			if (configurator.isTrue("cli","validateshacl",false)) { 
				ShaclFile shapesGraphFile = new ShaclFile(Configurator.getInstance().getBaseFolder().getCanonicalPath() + "/etc/ttl/KKG.ttl");
				ShaclFile bigFile = new ShaclFile(configurator.getXParm("properties/BIG_SHACL_FILE_PATH"));
				bigFile.setEncoding(StandardCharsets.UTF_8.name());
				bigFile.setContent("### SHAPES GRAPH FILE COPY ###\n" + shapesGraphFile.getContent() + "\n### SHACL FILE COPY ###\n" + shaclFile.getContent());
				bigFile.validate(configurator);
			}
			// copy to the app folder
			XmlFile appShaclFile = new XmlFile(shaclFolder,"shacl.ttl");
			shaclFile.copyFile(appShaclFile);
			configurator.setXParm("system/shacl-created","true");
		}
		
		return succeeds;
	}
	
	
}
