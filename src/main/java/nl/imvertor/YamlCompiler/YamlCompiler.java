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

package nl.imvertor.YamlCompiler;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.YamlFile;

public class YamlCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(YamlCompiler.class);
	
	public static final String STEP_NAME = "YAMLCompiler";
	public static final String VC_IDENTIFIER = "$Id: YamlCompiler.java 7509 2016-04-25 13:30:29Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling YAML");
		generateYAML();
	
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate YAML compiled EP file.
	 * 
	 * See https://code.google.com/archive/p/yamlbeans/ for validator
	 * 
	 * @throws Exception
	 */
	public boolean generateYAML() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder yamlFolder = new AnyFolder(configurator.getParm("system","work-yaml-folder-path"));
		yamlFolder.mkdirs();
				
		AnyFolder yamlApplicationFolder = new AnyFolder(configurator.getParm("properties","RESULT_YAML_APPLICATION_FOLDER"));
		yamlApplicationFolder.mkdirs();
		
		configurator.setParm("system","yaml-folder-path", yamlApplicationFolder.toURI().toString());
	
		runner.debug(logger,"CHAIN","Generating YAML to " + yamlApplicationFolder);
		
		succeeds = succeeds && transformer.transformStep("properties/RESULT_SORTED_ENDPRODUCT_XML_FILE_PATH","properties/RESULT_YAMLHEADER_FILE_PATH", "properties/IMVERTOR_METAMODEL_KING_YAMLHEADER_XSLPATH");
		succeeds = succeeds && transformer.transformStep("properties/RESULT_SORTED_ENDPRODUCT_XML_FILE_PATH","properties/RESULT_YAMLBODY_FILE_PATH", "properties/IMVERTOR_METAMODEL_KING_YAMLBODY_XSLPATH");
			
		if (succeeds) {
			// concatenate
			AnyFile headerFile = new AnyFile(configurator.getParm("properties", "RESULT_YAMLHEADER_FILE_PATH"));
			AnyFile bodyFile = new AnyFile(configurator.getParm("properties", "RESULT_YAMLBODY_FILE_PATH"));
			YamlFile yamlFile = new YamlFile(configurator.getParm("properties", "RESULT_YAML_FILE_PATH"));
			
			yamlFile.setContent(headerFile.getContent() + bodyFile.getContent());
			
			// validate
			yamlFile.validate(configurator);
			
			// copy to the app folder
			XmlFile appYamlFile = new XmlFile(yamlFolder,"yaml.ttl");
			yamlFile.copyFile(appYamlFile);
		}
		
		configurator.setParm("system","yaml-created","true");
		
		return succeeds;
	}
	
	
}
