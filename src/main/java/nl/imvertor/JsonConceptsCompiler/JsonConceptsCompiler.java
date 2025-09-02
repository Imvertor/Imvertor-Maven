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

package nl.imvertor.JsonConceptsCompiler;

import java.util.HashMap;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.JsonFile;

/**
 * The json concepts compiler takes the imvertor embesllish file and transforms parts of it (concepts and values) to a Json file.
 * 
 * @author arjan
 *
 */
public class JsonConceptsCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(JsonConceptsCompiler.class);
	
	public static final String STEP_NAME = "JsonConceptsCompiler";
	public static final String VC_IDENTIFIER = "$Id: $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling JSON Concepts");
		
		boolean succeeds = true;
		
		succeeds = succeeds && generateDefault();
		succeeds = succeeds && validateDefault();
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate Json based on imvertor format
	 * 
	 * See https://code.google.com/archive/p/yamlbeans/ for validator
	 * 
	 * @throws Exception
	 */
	public boolean generateDefault() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		runner.debug(logger,"CHAIN","Generating Json concepts");
		
		// Transform Imvertor info to Json XML
		if (configurator.getXParm("properties/WORK_LISTS_FILE", false) != null) {
			succeeds = succeeds && transformer.transformStep("properties/WORK_LISTS_FILE","properties/WORK_JSONCONCEPTS_JSONPATH", "properties/IMVERTOR_JSONCONCEPTS_XSLPATH"); //TODO must relocate generation of WORK_LISTS_FILE to a EMBELLISH step.
			
			JsonFile jsonFile = new JsonFile(configurator.getXParm("properties/WORK_JSONCONCEPTS_JSONPATH"));
			
			// Debug: test if json is okay
			succeeds = succeeds && jsonFile.isWellformed();
			
			// pretty print and store to json folder
			if (succeeds) {
				// copy to the app folder
				String jsonConceptsName = configurator.mergeParms(configurator.getXParm("cli/jsonconceptsname"));
				// Create the folder; it is not expected to exist yet.
				AnyFolder jsonFolder = new AnyFolder(configurator.getXParm("system/work-json-c-folder-path"));
				AnyFile appJsonFile = new AnyFile(jsonFolder,jsonConceptsName + ".json");
				jsonFolder.mkdirs();
				jsonFile.copyFile(appJsonFile);
			}
			
		} else {
			runner.error(logger, "Json concepts cannot be compiled. Missing list info.");
			succeeds = false;
		}
		configurator.setXParm("system/json-concepts-created",succeeds);	
		return succeeds;
		
	}
	/**
	 * Validate the URIs extracted for concepts. 
	 * 
	 * Not implemented yet; succeeds in all cases.
	 * 
	 * @return
	 * @throws Exception
	 */
	public boolean validateDefault() throws Exception {
		
		boolean succeeds = true;
		
		runner.debug(logger,"CHAIN","Validating Json concepts");
		runner.track("Validating Json concepts");
		
		String[] uris = configurator.getXParms("json-concepts/uri");
		HashMap<String, String> headerMap = new HashMap<String, String>();
		headerMap.put("Accept","application/json");
		for (int i = 0; i < uris.length; i++) {
			succeeds = succeeds && true;
		}
		configurator.setXParm("system/json-concepts-validated",succeeds);	
		return succeeds;
			
	}
	
}
