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

package nl.imvertor.ImvertCompiler;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.xsl.extensions.ImvertorParseHTML;

import org.apache.log4j.Logger;

public class ImvertCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(ImvertCompiler.class);
	
	public static final String STEP_NAME = "ImvertCompiler";
	public static final String VC_IDENTIFIER = "$Id: ImvertCompiler.java 7475 2016-03-23 10:54:06Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		try {
			
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			runner.info(logger,"Compiling processable Imvertor format");

			// create a transformer
			Transformer transformer = new Transformer();
			transformer.setExtensionFunction(new ImvertorParseHTML());
			    
		    // transform 
			boolean succeeds = true;
			// a compile list of steps to create all base files for final processing.
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_DOMAINS_FILE", "properties/IMVERTOR_DOMAINS_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_DEPENDENCIES_FILE", "properties/IMVERTOR_DEPENDENCIES_XSLPATH") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_VARIANT_FILE", "properties/IMVERTOR_APPLICATION_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_COPYDOWN_FILE", "properties/IMVERTOR_COPYDOWN_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_REF_FILE", "properties/IMVERTOR_REF_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_CONCRETESCHEMA_FILE", "properties/IMVERTOR_CONCRETESCHEMA_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_LOCALSCHEMA_FILE", "properties/IMVERTOR_LOCALSCHEMA_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_EXPANDDOC_FILE", "properties/IMVERTOR_EXPANDDOC_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_DERIVATIONTREE_FILE", "properties/IMVERTOR_DERIVATIONTREE_XSLPATH") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_DERIVATIONEXPAND_FILE", "properties/IMVERTOR_DERIVATIONEXPAND_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_EMBELLISH_FILE", "properties/IMVERTOR_EMBELLISH_XSLPATH","system/cur-imvertor-filepath") : false ;
			succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_SCHEMA_FILE", "properties/IMVERTOR_SCHEMA_XSLPATH","system/cur-imvertor-filepath") : false ;
			
			if (!succeeds && configurator.forceCompile())
				runner.warn(logger,"Ignoring data processing errors found (forced compilation)");
			
			// If derivation must be checked, create the derivation file.
			if (configurator.isTrue("cli","validatederivation")) 
				succeeds = succeeds ? transformer.transformStep("properties/WORK_EMBELLISH_FILE", "properties/WORK_DERIVATION_FILE", "properties/IMVERTOR_DERIVATION_XSLPATH") : false ;
			
			AnyFolder etcFolder = new AnyFolder(configurator.getParm("system","work-etc-folder-path"));
			
			XmlFile infoEmbellishFile = new XmlFile(configurator.getParm("properties", "WORK_EMBELLISH_FILE"));
			XmlFile oldEmbellishFile = new XmlFile(etcFolder,"system.imvert.xml");
			infoEmbellishFile.copyFile(oldEmbellishFile); // IM-172 compare must work on simpler imvertor format
	    	
			XmlFile infoSchemaFile = new XmlFile(configurator.getParm("properties", "WORK_SCHEMA_FILE"));
			XmlFile oldModelFile = new XmlFile(etcFolder,"model.imvert.xml");
			infoSchemaFile.copyFile(oldModelFile); // IM-169 schema based imvertor output
			
			//TODO copy the xsd to the etc. folder
			AnyFolder sourceXsdFolder = new AnyFolder(configurator.getParm("properties", "IMVERTOR_APPLICATION_LOCATION_SOURCE")); 
			AnyFolder targetXsdFolder = new AnyFolder(configurator.getParm("properties", "IMVERTOR_APPLICATION_LOCATION_TARGET")); 
			sourceXsdFolder.copy(targetXsdFolder);
			
			configurator.setStepDone(STEP_NAME);
			
			// save any changes to the work configuration for report and future steps
		    configurator.save();
		    
		    report();
		    
		    return runner.succeeds();
			
		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}

}
