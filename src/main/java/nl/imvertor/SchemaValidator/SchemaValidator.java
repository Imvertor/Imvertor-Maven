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

package nl.imvertor.SchemaValidator;

import java.io.File;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import org.apache.log4j.Logger;

import nl.imvertor.SchemaValidator.xerces.ErrorHandlerMessage;
import nl.imvertor.common.Step;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XsdFile;

public class SchemaValidator extends Step {

	protected static final Logger logger = Logger.getLogger(SchemaValidator.class);
	
	public static final String STEP_NAME = "SchemaValidator";
	public static final String VC_IDENTIFIER = "$Id: SchemaValidator.java 7431 2016-02-24 12:46:42Z arjan $";
	
	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			runner.info(logger,"Validating XML schemas");
			
			boolean valid = true;
			configurator.setParm("appinfo","schema-validation-status",
				configurator.isTrue("cli","validateschema") ? "requested" : runner.isFinal() ? "required" : 
					configurator.isTrue("cli","createxmlschema") ? "skipped" : "schemas not generated");
		
			if (configurator.isTrue("cli","createxmlschema"))
				if (configurator.isTrue("cli","validateschema") || runner.isFinal()) {
					valid = validateSchemas();
					configurator.setStepDone(STEP_NAME);
				}
			
			// save any changes to the work configuration for report and future steps
		    configurator.save();
		    
		    report();
		    
		    return runner.succeeds() && valid;
			
		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}
	
	/**
	 * Validate the schemas. This should not result in any errors.
	 *   
	 * @return
	 * @throws Exception
	 */
	public boolean validateSchemas() throws Exception {
		
		AnyFolder xsdApplicationFolder = new AnyFolder(configurator.getParm("properties","RESULT_XSD_APPLICATION_FOLDER"));
		
		Vector<ErrorHandlerMessage> vl = validateSchemasSub(xsdApplicationFolder);
		if (vl.size() != 0) 
			runner.error(logger, vl.size() + " errors/warnings found in generated XSD. This release should not be distributed. Please notify your administrator.");
		Iterator<ErrorHandlerMessage> it = vl.iterator();
		while (it.hasNext()) {
			ErrorHandlerMessage m = it.next();
			switch (m.type.toLowerCase()) {
				case "error":
					runner.error(logger, "XML schema: " + m.file + " at line " + m.line + " (" + m.code + ") " + m.message);
					break;
				case "warning":
					runner.warn(logger, "XML schema: " + m.file + " at line " + m.line + " (" + m.code + ") " + m.message);
					break;
				default: 
					runner.debug(logger, "XML-schema: " + m.file + " at line " + m.line + " (" + m.code + ") " + m.message);
					break;
			}
		}
		configurator.setParm("appinfo","schema-error-count", vl.size());
		return (vl.size() == 0) ? true : false;
	}
	
	private Vector<ErrorHandlerMessage> validateSchemasSub(AnyFolder folder) throws Exception {
		File[] filesAndDirs = folder.listFiles();
		List<File> filesDirs = Arrays.asList(filesAndDirs);
		Vector<ErrorHandlerMessage> vl = new Vector<ErrorHandlerMessage>();
		for (File file : filesDirs) {
			if (file.isDirectory()) {
				vl.addAll(validateSchemasSub(new AnyFolder(file)));
			} else if (file.getName().endsWith(".xsd")) {
				XsdFile schema = new XsdFile(file);
				Vector<ErrorHandlerMessage> v = schema.validateGrammar(true, true, true);
				vl.addAll(v);
			}
		}
		return vl;
	}

	public Vector<ErrorHandlerMessage> validateSchema(String schemapath) throws Exception {
		XsdFile schema = new XsdFile(new File(schemapath));
		return schema.validateGrammar(true, true, true);
	}

}
