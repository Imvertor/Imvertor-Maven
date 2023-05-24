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

import java.io.File;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.JsonFile;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.YamlFile;
import nl.imvertor.common.xsl.extensions.ImvertorFolderSerializer;
import nl.imvertor.common.xsl.extensions.ImvertorParseYaml;
import nl.imvertor.common.xsl.extensions.expath.ImvertorExpathReadText;

/**
 * The json schema compiler takes an EP file and transforms it to a Json schema file.
 * 
 * @author arjan
 *
 */
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
		
		runner.info(logger,"Compiling JSON schema");
		
		generate();
		
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
	public boolean generate() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorFolderSerializer());
		transformer.setExtensionFunction(new ImvertorExpathReadText());
		transformer.setExtensionFunction(new ImvertorParseYaml());
							
		boolean succeeds = true;
		
		runner.debug(logger,"CHAIN","Generating Json");
		
		// Transform previously generated EP to Json XML
		if (configurator.getXParm("system/ep-schema-version").equals("1"))
			succeeds = succeeds && transformer.transformStep("properties/WORK_EP_XMLPATH","properties/WORK_JSONXML_XMLPATH", "properties/IMVERTOR_JSONXML_XSLPATH");
		else 
			succeeds = succeeds && transformer.transformStep("properties/WORK_EP_XMLPATH","properties/WORK_JSONXML_XMLPATH", "properties/IMVERTOR_JSONXML2_XSLPATH");
				
		// convert the json xml to Json.
		XmlFile jsonXmlFile = new XmlFile(configurator.getXParm("properties/WORK_JSONXML_XMLPATH"));
		JsonFile jsonFile = new JsonFile(configurator.getXParm("properties/WORK_SCHEMA_JSONPATH"));
		YamlFile yamlFile = new YamlFile(configurator.getXParm("properties/WORK_SCHEMA_YAMLPATH"));
		jsonXmlFile.toJson(jsonFile);
		
		// Debug: test if json is okay
		succeeds = succeeds && jsonFile.validate();
		
		// pretty print and store to json folder
		if (succeeds) {
	
			jsonFile.toYaml(yamlFile);
			
			// copy to the app folder
			String schemaName = configurator.mergeParms(configurator.getXParm("cli/jsonschemaname"));
			
			// Create the folder; it is not expected to exist yet.
			AnyFolder jsonFolder = new AnyFolder(configurator.getXParm("system/work-json-folder-path"));
			
			JsonFile appJsonFile = new JsonFile(new File(jsonFolder,schemaName + ".json"));
			YamlFile appYamlFile = new YamlFile(new File(jsonFolder,schemaName + ".yaml"));
			
			jsonFolder.mkdirs();
			jsonFile.copyFile(appJsonFile);
			yamlFile.copyFile(appYamlFile);
			
		}
		configurator.setXParm("system/json-schema-created",succeeds);
		
		return succeeds;
	}
}
