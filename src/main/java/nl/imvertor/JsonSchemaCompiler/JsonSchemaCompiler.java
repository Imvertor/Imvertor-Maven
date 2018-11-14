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

package nl.imvertor.JsonSchemaCompiler;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.JsonFile;
import nl.imvertor.common.xsl.extensions.ImvertorStripAccents;

public class JsonSchemaCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(JsonSchemaCompiler.class);
	
	public static final String STEP_NAME = "JsonSchemaCompiler";
	public static final String VC_IDENTIFIER = "$Id: $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		String schemarules = configurator.getSchemarules();
		if (schemarules.equals("KadasterNEN3610")) {
			generateKadaster();
		} else
			runner.error(logger,"Schemarules not implemented: " + schemarules);
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate Json based on intermediate EP file.
	 * 
	 * See https://code.google.com/archive/p/yamlbeans/ for validator
	 * 
	 * @throws Exception
	 */
	public boolean generateKadaster() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
		// requires accent stripper
		transformer.setExtensionFunction(new ImvertorStripAccents());
						
		boolean succeeds = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder yamlFolder = new AnyFolder(configurator.getXParm("system/work-yaml-folder-path"));
		yamlFolder.mkdirs();
				
		configurator.setXParm("system/yaml-folder-path", yamlFolder.toURI().toString());
	
		runner.debug(logger,"CHAIN","Generating YAML to " + yamlFolder);
		
		// Create EP
		succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/WORK_EP_XMLPATH", "properties/IMVERTOR_EP_XSLPATH");
		
		// Transform to Json
		succeeds = succeeds && transformer.transformStep("properties/WORK_EP_XMLPATH","properties/WORK_SCHEMA_JSONPATH", "properties/IMVERTOR_JSON_XSLPATH");
		
		// Debug: test if json is okay
		JsonFile jsonFile = new JsonFile(configurator.getXParm("properties/WORK_SCHEMA_JSONPATH"));
		succeeds = succeeds && jsonFile.validate(configurator);
		
		// pretty print and store to json folder
		if (succeeds) {
			jsonFile.prettyPrint();
			
			// copy to the app folder
			String schemaName = configurator.mergeParms(configurator.getXParm("cli/jsonschemaname"));
			
			AnyFile appJsonFile = new AnyFile(yamlFolder,schemaName + ".json");
			jsonFile.copyFile(appJsonFile);
		}
		configurator.setXParm("system/json-schema-created",succeeds);
		
		return succeeds;
	}
}
