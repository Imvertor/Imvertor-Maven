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

package nl.imvertor.SkosCompiler;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.ShaclFile;
import nl.imvertor.common.file.SkosFile;
import nl.imvertor.common.file.XmlFile;

public class SkosCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(SkosCompiler.class);
	
	public static final String STEP_NAME = "SkosCompiler";
	public static final String VC_IDENTIFIER = "$Id: XsdCompiler.java 7509 2016-04-25 13:30:29Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling SKOS concepts");
		generateSKOS();
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate SKOS
	 * 
	 * See ? for validator
	 * 
	 * @throws Exception
	 */
	public boolean generateSKOS() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder skosFolder = new AnyFolder(configurator.getXParm("system/work-skos-folder-path"));
		skosFolder.mkdirs();
				
		AnyFolder skosApplicationFolder = new AnyFolder(configurator.getXParm("properties/RESULT_SKOS_APPLICATION_FOLDER"));
		skosApplicationFolder.mkdirs();
		
		configurator.setXParm("system/skos-folder-path", skosApplicationFolder.toURI().toString());
	
		runner.debug(logger,"CHAIN","Generating SKOS to " + skosApplicationFolder);
		
		succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_SKOS_FILE_PATH", "properties/IMVERTOR_METAMODEL_BRO_SKOS_XSLPATH");
		
		if (succeeds) {
			SkosFile skosFile = new SkosFile(configurator.getXParm("properties/RESULT_SKOS_FILE_PATH"));
			
			if (configurator.isTrue("cli","validateskos",false)) { 
				String skosSchemaUrl = configurator.getXParm("system/skos-schema-url"); // wordt gezet bij het genereren van een SKOS file. 
				if (skosSchemaUrl != null) {
					ShaclFile skosSchema = shaclFileByCatalog(skosSchemaUrl);
					skosFile.validate(configurator, skosSchema); // TODO
				
				} else 
					skosFile.validate(configurator);
			}
			// copy to the app folder
			XmlFile appSkosFile = new XmlFile(skosFolder,"skos.ttl");
			skosFile.copyFile(appSkosFile);
			configurator.setXParm("system/skos-created","true");
		}
		
		return succeeds;
	}
	
	static ShaclFile shaclFileByCatalog(String Url) throws Exception {
		String path = AnyFile.fileByCatalog(Url);
		return new ShaclFile(path); 	
	}
	
}
