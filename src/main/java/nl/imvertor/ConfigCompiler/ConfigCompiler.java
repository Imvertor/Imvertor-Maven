/*
 * Copyright (C) 2016 VNG/KING
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

package nl.imvertor.ConfigCompiler;

import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.ShaclFile;
import nl.imvertor.common.file.XmlFile;

/**
 * create a configuration for the current owner, tagset, metamodel and schemas
 * 
 * @author arjan
 *
 */
public class ConfigCompiler  extends Step {

	protected static final Logger logger = Logger.getLogger(ConfigCompiler.class);
	
	public static final String STEP_NAME = "ConfigCompiler";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Compiling the configuration");
			
		Transformer transformer = new Transformer();
		
		 // transform 
		boolean succeeds = true;
		
		succeeds = succeeds ? transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_CONFIG_FILE", "properties/IMVERTOR_CONFIG_XSLPATH") : false ;
		
		// Save cfg file to etc folder
		AnyFolder etcFolder = new AnyFolder(configurator.getXParm("system/work-etc-folder-path"));
		XmlFile cfgFile = new XmlFile(configurator.getXParm("properties/WORK_CONFIG_FILE"));
		XmlFile appCfgFile = new XmlFile(etcFolder,"config.xml");
		cfgFile.copyFile(appCfgFile);
					
		// create the EA profile/toolbox when requested
		Boolean p = configurator.isTrue(configurator.getXParm("cli/createeaprofile",false));
		Boolean q = configurator.isTrue(configurator.getXParm("cli/createeatoolbox",false));
		
		if (p | q) {
			AnyFolder eaFolder = new AnyFolder(configurator.getXParm("system/work-ea-folder-path"));
			XmlFile tempProfileFile = new XmlFile(configurator.getXParm("properties/WORK_EAPROFILE_FILE"));
			if (p) {
				transformer.setXslParm("result-type", "profile");
				succeeds = succeeds ? transformer.transformStep("properties/WORK_CONFIG_FILE", "properties/WORK_EAPROFILE_FILE", "properties/IMVERTOR_EAPROFILE_XSLPATH") : false ;
				XmlFile profileFile = new XmlFile(eaFolder,configurator.getXParm("appinfo/ea-profile-file-name"));
				tempProfileFile.copyFile(profileFile); 
			}
			if (q) {
				transformer.setXslParm("result-type", "toolbox");
				succeeds = succeeds ? transformer.transformStep("properties/WORK_CONFIG_FILE", "properties/WORK_EAPROFILE_FILE", "properties/IMVERTOR_EAPROFILE_XSLPATH") : false ;
				XmlFile profileFile = new XmlFile(eaFolder,configurator.getXParm("appinfo/ea-toolbox-file-name"));
				tempProfileFile.copyFile(profileFile); 
			}
		}
		
		// create simple metamodel representation
		succeeds = succeeds ? transformer.transformStep("properties/WORK_CONFIG_FILE", "properties/WORK_METAMODEL_FILE", "properties/IMVERTOR_METAMODEL_XSLPATH") : false ;
		if (succeeds) {
			XmlFile metamodelFile = new XmlFile(configurator.getXParm("properties/WORK_METAMODEL_FILE"));
			XmlFile appModFile = new XmlFile(etcFolder,"metamodel.xml");
			metamodelFile.copyFile(appModFile); 
			// copy the XSD
			XmlFile managedMetamodelFile = new XmlFile(Configurator.getInstance().getBaseFolder().getCanonicalPath() + "/etc/xsd/metamodel/metamodel.xsd");
			XmlFile targetMetamodelFile = new XmlFile(etcFolder.getCanonicalPath() + "/xsd/metamodel/metamodel.xsd");
			managedMetamodelFile.copyFile(targetMetamodelFile);
		}
		
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();

	}
	
}
