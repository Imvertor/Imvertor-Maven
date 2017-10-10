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

package nl.imvertor.Validator;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.xsl.extensions.ImvertorStripAccents;
import nl.imvertor.common.xsl.extensions.ImvertorValidateRegex;


/**
 * Validate an Imvertor file in accordance with a particular Metamodel
 *  
 * 
 * @author arjan
 *
 */
public class Validator extends Step {

	protected static final Logger logger = Logger.getLogger(Validator.class);
	
	public static final String STEP_NAME = "Validator";
	public static final String VC_IDENTIFIER = "$Id: Validator.java 7509 2016-04-25 13:30:29Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Validating model");

		String mm = configurator.getParm("cli","metamodel");
				
		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorValidateRegex());
		    
	    // transform 
		boolean succeeds = true;

		// CANONIZATION IN STEPS; 
		// each second, third... step is known as _2, _3 etc. in the parameter sequence as configured.
		// first step has no sequence number.
		int i = 1;
		while (true) {
			String xslname = "IMVERTOR_METAMODEL_" + mm + "_CANONICAL_XSLPATH" + ((i == 1) ? "" : ("_" + i));
			String outname = "WORK_BASE_METAMODEL_FILE" + ((i == 1) ? "" : ("_" + i));
			if (configurator.getParm("properties", xslname, false) != null) {
				// curpath is "properties/WORK_BASE_FILE", 
				succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath","properties/" + outname, "properties/" + xslname, "system/cur-imvertor-filepath") : false ;
				i += 1;
			} else break;
		}
		
		succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_INTERFACE_FILE", "properties/IMVERTOR_INTERFACE_XSLPATH","system/cur-imvertor-filepath") : false ;

		if (configurator.isTrue("system", "supports-proxy")) {
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_PROXY_FILE", "properties/IMVERTOR_PROXY_XSLPATH","system/cur-imvertor-filepath") : false ;
		}
		
		if (succeeds) {
			// VALIDATION IN STEPS
			int j = 1;
			while (true) {
				String xslname = "IMVERTOR_METAMODEL_" + mm + "_VALIDATE_XSLPATH" + ((j == 1) ? "" : ("_" + j));
				String outname = "WORK_VALIDATE_FILE" + ((j == 1) ? "" : ("_" + j));
				if (configurator.getParm("properties", xslname, false) != null) {
					succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/" + outname, "properties/" + xslname) : false ;
					j += 1;
				} else break;
			}
			
			// final validation
			// must be performed even when canonical validation fails.
			succeeds = transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_VALIDATE_FILE", "properties/IMVERTOR_VALIDATE_XSLPATH") && succeeds ;
		}
		// set two parameter to appinfo here
		String docrelease = configurator.getParm("cli","docrelease");
		configurator.setParm("appinfo","documentation-release",docrelease.equals("00000000") ? "" : "-" + docrelease);
		configurator.setParm("appinfo","generation-id",configurator.getParm("system","generation-id"));
		
		// system/resolved-release-name
		String releasename = configurator.mergeParms(configurator.getParm("cli","releasename"));
		configurator.setParm("appinfo","release-name",StringUtils.replacePattern(releasename, "[^A-Za-z0-9_\\-.]", ""),true);
		
		// we now know the application name and should show it. 
		runner.info(logger, "Compiled name: " + configurator.getParm("appinfo","release-name"));
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds() && succeeds;
			 
	}
	
	
}
