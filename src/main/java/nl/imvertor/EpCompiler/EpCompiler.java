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

package nl.imvertor.EpCompiler;

import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;

// see also https://github.com/Imvertor/Imvertor-Maven/issues/56

public class EpCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(EpCompiler.class);
	
	public static final String STEP_NAME = "EpCompiler";
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
	 * Generate EP file suited for Kadaster Json schema.
	 * 
	 * @throws Exception
	 */
	public boolean generateKadaster() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		runner.debug(logger,"CHAIN","Generating EP");
		
		transformer.setXslParm("ep-schema-path","../etc/xsd/EP/EP.xsd");
		
		// Create EP
		succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/WORK_EP_XMLPATH", "properties/IMVERTOR_EP_XSLPATH");
		
		// if this succeeds, copy the EP schema to the app and validate
		if (succeeds) {
			AnyFolder workAppFolder = new AnyFolder(Configurator.getInstance().getXParm("system/work-app-folder-path"));
			
			XmlFile resultEpFile = new XmlFile(configurator.getXParm("properties/WORK_EP_XMLPATH"));
			XmlFile targetEpFile = new XmlFile(workAppFolder.getCanonicalPath() + "/ep/ep.xml"); // TODO nette naam, bepaald door gebruiker oid.
			resultEpFile.copyFile(targetEpFile);
			
			XmlFile managedSchemaFile = new XmlFile(Configurator.getInstance().getBaseFolder().getCanonicalPath() + "/etc/xsd/EP/EP.xsd");
			XmlFile targetSchemaFile = new XmlFile(workAppFolder.getCanonicalPath() + "/etc/xsd/EP/EP.xsd");
			managedSchemaFile.copyFile(targetSchemaFile);
			
			// Debug: test if EP is okay
			succeeds = succeeds && resultEpFile.isValid();
		}
		return succeeds;
	}
}
