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

package nl.imvertor.ReleaseComparer;

import java.net.URL;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.XmlFile;

/**
 * Release comparer compares two releases.
 * This is: documentation release, and/or client and supplier, and/or previous release of this application.
 * 
 * @author arjan
 *
 */
public class ReleaseComparer extends Step {

	protected static final Logger logger = Logger.getLogger(ReleaseComparer.class);
	
	public static final String STEP_NAME = "ReleaseComparer";
	public static final String VC_IDENTIFIER = "$Id: ReleaseComparer.java 7460 2016-03-08 14:39:05Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		//TODO allow comparisons between models: client and supplier; two releases of client.
		
		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();

			Boolean succeeds = true;
			succeeds = succeeds && docReleaseCompare();
			succeeds = succeeds && releaseCompare();
			succeeds = succeeds && supplierCompare();
			
			configurator.setStepDone(STEP_NAME);
			
			// save any changes to the work configuration for report and future steps
		    configurator.save();
		    
		    XmlFile ctrlNameFile = new XmlFile(configurator.getParm("properties","WORK_COMPARE_CONTROL_NAME_FILE"));
			XmlFile testNameFile = new XmlFile(configurator.getParm("properties","WORK_COMPARE_TEST_NAME_FILE"));
			XmlFile infoConfig   = new XmlFile(configurator.getParm("properties","IMVERTOR_COMPARE_CONFIG"));
			
			Transformer stepTransformer = new Transformer();
			stepTransformer.setXslParm("ctrl-name-mapping-filepath", ctrlNameFile.toURI().toString());
			stepTransformer.setXslParm("test-name-mapping-filepath", testNameFile.toURI().toString());
			stepTransformer.setXslParm("info-config", infoConfig.toURI().toString());  

		    report(stepTransformer);
		    
		    return runner.succeeds() && runner.getMayRelease();
			
		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}
	
	private boolean releaseCompare() throws Exception {
		configurator.setParm("system", "compare-label", "release",true); 
		
		String releaseString = configurator.getParm("cli","comparewith",false);
		Boolean release = releaseString != null && !releaseString.equals("00000000");
		
		String curReleaseString = configurator.getParm("appinfo","release");
		
		// This step succeeds when a release may be made, depending on possible differences in the most recent and current model file 
		XmlFile oldModelFile = new XmlFile(configurator.getApplicationFolder(releaseString), "etc/model.imvert.xml");
		XmlFile newModelFile = new XmlFile(configurator.getParm("properties", "WORK_SCHEMA_FILE"));
		
		if (release) { // a request is made to produce a docrelease
			if (oldModelFile.exists()) {
				if (releaseString.equals(curReleaseString))
					runner.warn(logger, "Comparing release " + releaseString + " to most recent compilation");
				else
					runner.info(logger,"Comparing releases");
				return oldModelFile.compare( newModelFile, configurator); 
			} else {
				runner.error(logger, "Cannot compare releases, because release " + releaseString + " could not be found");
				return false;
			}	
		}
		return true;
	}
	
	private boolean docReleaseCompare() throws Exception {
		// Set the compare label; this label is used in temporary file names. eg. docRelease
		configurator.setParm("system", "compare-label", "documentation",true); 
		
		// set the docrelease. This is either not specified, or 00000000, or a valid date in the form YYYYMMDD
		String docreleaseString = configurator.getParm("cli","docrelease",false);
		Boolean docRelease = docreleaseString != null && !docreleaseString.equals("00000000");
		
		// This step succeeds when a release may be made, depending on possible differences in the most recent and current model file 
		XmlFile oldModelFile = new XmlFile(configurator.getApplicationFolder(), "etc/model.imvert.xml");
		XmlFile infoSchemaFile = new XmlFile(configurator.getParm("properties", "WORK_SCHEMA_FILE"));
		
		if (docRelease) { // a request is made to produce a docrelease
			runner.info(logger,"Comparing releases for documentation release");
			if (oldModelFile.exists()) { 
				// Check if there's a significant difference between the previous and current release
				boolean equal = oldModelFile.compare( infoSchemaFile, configurator); 
				runner.setMayRelease(equal);
				if (!equal)
					runner.error(logger,"This is not a valid documentation release.");
				return equal;
			} else {
				runner.error(logger, "Cannot create a documentation release when no previous release could be found");
				runner.setMayRelease(false);
				return false;
			}	
			}
			return true;
	}
	
	private boolean supplierCompare() throws Exception {

		// Set the compare label; this label is used in temporary file names. eg. docRelease
		configurator.setParm("system", "compare-label", "derivation",true); 
					
		String path = configurator.getParm("appinfo","supplier-etc-model-imvert-path",false);
	
		String cmp = configurator.getParm("cli","compare",false);
		Boolean supplierCheck = (cmp != null) && cmp.equals("supplier");
		
		if (path != null && path.length() > 0) {
			// determine the identifier of the supplier
			String suppId = (new URL(path)).getPath();
			
			XmlFile supplierModelFile = new XmlFile(suppId);
			XmlFile clientModelFile = new XmlFile(configurator.getParm("properties", "WORK_SCHEMA_FILE"));
			
			if (supplierCheck) // a request is made to check differences with the supplier
				if (supplierModelFile.exists()) { 
					runner.info(logger,"Comparing client and supplier releases");
					runner.debug(logger,"Client is: " + clientModelFile);
					runner.debug(logger,"Supplier is: " + supplierModelFile);
					boolean equal = supplierModelFile.compare( clientModelFile, configurator); 
					if (!equal) 
						runner.info(logger,"Differences found between client and supplier.");
				} else {
					runner.warn(logger, "Cannot compare client and supplier when no supplier release could be found");
					return false;
				}
		} else if (supplierCheck)
			runner.warn(logger, "Cannot compare client and supplier because the model is not derived");
		return true;
	}
}
