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
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import org.apache.commons.lang.StringUtils;
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
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();

		// set some status info
		String approach = configurator.getXParm("appinfo/xml-schemalocation-approach",false);
		String xs = 
				(approach != null && approach.equals("absolute")) ? "impossible" : 
				configurator.isTrue("cli","validateschema") ? "requested" : runner.isFinal() ? "required" : 
				configurator.isTrue("cli","createxmlschema") ? "skipped" : "schemas not generated";
		
		configurator.setXParm("appinfo/schema-validation-status", xs);
		
		if (xs.equals("requested") || xs.equals("required")) {
			runner.info(logger,"Validating XML schemas");
			
			validateSchemas(); // ignore result boolean

		} else if (xs.equals("impossible")) {
			runner.info(logger,"Not validating XML schemas, because schemas will be relocated");
		}
		
		configurator.setStepDone(STEP_NAME);

		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
			
	}
	
	/**
	 * Validate the schemas. This should not result in any errors.
	 *   
	 * @return
	 * @throws Exception
	 */
	public boolean validateSchemas() throws Exception {
		
		AnyFolder xsdApplicationFolder = new AnyFolder(configurator.getXParm("system/xsd-application-folder-path"));
		
		Vector<ErrorHandlerMessage> vl = validateSchemasSub(xsdApplicationFolder);
		if (vl.size() != 0) 
			runner.info(logger, vl.size() + " errors/warnings found in generated XSD. This release should not be distributed. Please notify your administrator.");
		Iterator<ErrorHandlerMessage> it = vl.iterator();
		int i = 1;
		while (i <= 10 && it.hasNext()) {
			ErrorHandlerMessage m = it.next();
			String msg = "XML schema: " +  StringUtils.substringAfter(m.message, m.code + ": ")  + " [" + URLDecoder.decode(StringUtils.substringAfter(m.file,"/xsd/"), StandardCharsets.UTF_8.name()) + ":" + m.line + "]";
			switch (m.type.toLowerCase()) {
				case "error":
					runner.error(logger, msg,"","XERCES-" + m.code);
					break;
				case "warning":
					runner.warn(logger, msg,"","XERCES-" + m.code);
					break;
				default: 
					runner.debug(logger,"CHAIN", msg);
					break;
			}
			i++;
		}
		if (i < vl.size()) 
			runner.info(logger, "No showing " + (vl.size() - i) + " additional messages");
		configurator.setXParm("appinfo/schema-error-count", vl.size());
		return (vl.size() == 0) ? true : false;
	}
	
	private Vector<ErrorHandlerMessage> validateSchemasSub(AnyFolder folder) throws Exception {
		File[] filesAndDirs = folder.listFiles();
		List<File> filesDirs = Arrays.asList(filesAndDirs);
		Vector<ErrorHandlerMessage> vl = new Vector<ErrorHandlerMessage>();
		for (File file : filesDirs) {
			if (file.isDirectory()) {
				vl.addAll(validateSchemasSub(new AnyFolder(file)));
			} else if (file.getName().toLowerCase().endsWith(".xsd")) {
				XsdFile schema = new XsdFile(file);
				schema.allownsimports = true;
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
