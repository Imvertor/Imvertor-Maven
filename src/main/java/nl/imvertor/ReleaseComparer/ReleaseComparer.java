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

import java.io.File;

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
	public boolean run() throws Exception{
		
		//TODO allow comparisons between models: client and supplier; two releases of client.
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();

		// add the generated XSL to the catalog
		// note that the catalog is global to all steps.
		
		String compareMethod = configurator.getXParm("cli/comparemethod");
		
		if (compareMethod.equals("default")) {
			String url = (new File(configurator.getXParm("properties/COMPARE_GENERATED_XSLPATH"))).toURI().toURL().toString();
			configurator.addCatalogMap(
					"http://www.imvertor.org/imvertor/1.0/xslt/compare/compare-generated.xsl", 
					url);
		}
		
		Boolean succeeds = true;
		succeeds = succeeds && docReleaseCompare(compareMethod);
		succeeds = succeeds && releaseCompare(compareMethod);
		succeeds = succeeds && supplierCompare(compareMethod);
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    XmlFile ctrlNameFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_CONTROL_NAME_FILE"));
		XmlFile testNameFile = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_TEST_NAME_FILE"));
		XmlFile infoConfig   = new XmlFile(configurator.getXParm("properties/IMVERTOR_COMPARE_CONFIG"));
		
		Transformer stepTransformer = new Transformer();
		stepTransformer.setXslParm("ctrl-name-mapping-filepath", ctrlNameFile.toURI().toString());
		stepTransformer.setXslParm("test-name-mapping-filepath", testNameFile.toURI().toString());
		stepTransformer.setXslParm("info-config", infoConfig.toURI().toString());  

	    report(stepTransformer);
	    
	    return runner.succeeds() && runner.getMayRelease();
			
	}
	
	/**
	 * 
	 * @param compareMethod Values may be "default" or "V2"
	 * @return true when comparsion is made
	 * @throws Exception
	 */
	private boolean releaseCompare(String compareMethod) throws Exception {
		
		configurator.setXParm("system/compare-label", "release",true);
		
		String cmp = configurator.getXParm("cli/compare",false);
		Boolean releaseCheck = (cmp != null) && cmp.equals("release");
		
		if (releaseCheck) { // a request is made to produce a release comparison
			
			// als release compare en geen release opgegeven, neem aan dat je met de vorige run wilt vergelijken 
			String curReleaseString = configurator.getXParm("appinfo/release");
			String releaseString = configurator.getXParm("cli/comparewith",false);
			if (releaseString == null || releaseString.equals("unspecified")) releaseString = curReleaseString;
			
			// This step succeeds when a release may be made, depending on possible differences in the most recent and current model file 
			XmlFile oldModelFile = new XmlFile(configurator.getApplicationFolder(releaseString), "etc/system.imvert.xml");
			XmlFile newModelFile = new XmlFile(configurator.getXParm("properties/WORK_EMBELLISH_FILE"));
		
			if (oldModelFile.exists()) {
				if (releaseString.equals(curReleaseString))
					runner.warn(logger, "Comparing release " + releaseString + " to most recent compilation");
				else
					runner.info(logger,"Comparing releases");
				return oldModelFile.compareV2( newModelFile, configurator); 
			} else if (releaseString != null ) {
				runner.error(logger, "Cannot compare releases, because release \"" + releaseString + "\" could not be found");
				return false;
			} else {
				runner.error(logger, "You have not supplied a release to compare with, please specify the \"comparewith\" property");
				return false;
			}	
		}
		return true;
	}
	
	//TODO bijwerken obv releaseCompare
	private boolean docReleaseCompare(String compareMethod) throws Exception {
		// Set the compare label; this label is used in temporary file names. eg. docRelease
		configurator.setXParm("system/compare-label", "documentation",true); 
		
		// set the docrelease. This is either not specified, or 00000000, or a valid date in the form YYYYMMDD
		String docreleaseString = configurator.getXParm("cli/docrelease",false);
		Boolean docRelease = docreleaseString != null && !docreleaseString.equals("00000000");
		
		if (docRelease) { // a request is made to produce a docrelease
			// This step succeeds when a release may be made, depending on possible differences in the most recent and current model file 
			XmlFile oldModelFile = new XmlFile(configurator.getApplicationFolder(), "etc/model.imvert.xml");
			XmlFile newModelFile = new XmlFile(configurator.getXParm("properties/WORK_EMBELLISH_FILE"));
			
			runner.info(logger,"Comparing releases for documentation release");
			if (oldModelFile.exists()) { 
				// Check if there's a significant difference between the previous and current release
				boolean equal = oldModelFile.compareV2(newModelFile, configurator); 
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
	
	//TODO bijwerken obv releaseCompare
	private boolean supplierCompare(String compareMethod) throws Exception {

		// Set the compare label; this label is used in temporary file names. eg. docRelease
		configurator.setXParm("system/compare-label", "derivation",true); 
					
		String cmp = configurator.getXParm("cli/compare",false);
		Boolean supplierCheck = (cmp != null) && cmp.equals("supplier");
		
		if (supplierCheck) {

			String subpath = configurator.getXParm("appinfo/supplier-subpath",false); // sample format: "green/SampleBase/20130318"
			//TODO may be multiple subpaths; getXParm not equipped to handle this, always returns last...
			
			if (subpath == null) 
				runner.warn(logger, "Cannot compare client and supplier, unable to determine subpath for supplier");
			else if (subpath.length() > 0) {

				String path = configurator.getOutputFolder() + "/applications/" + subpath + "/etc/system.imvert.xml"; // sample format: "c:\applications\green/SampleBase/20130318/etc/system.imvert.xml"
				
				XmlFile supplierModelFile = new XmlFile(path);
				XmlFile clientModelFile = new XmlFile(configurator.getXParm("properties/WORK_EMBELLISH_FILE"));
				
				if (supplierModelFile.exists()) { 
					runner.info(logger,"Comparing client and supplier releases");
					runner.debug(logger,"CHAIN","Client is: " + clientModelFile);
					runner.debug(logger,"CHAIN","Supplier is: " + supplierModelFile);
					boolean equal = supplierModelFile.compareV2( clientModelFile, configurator); 
					if (!equal) 
						runner.info(logger,"Differences found between client and supplier.");
				} else {
					runner.warn(logger, "Cannot compare client and supplier when no supplier release could be found");
					return false;
				}
			} else
				runner.warn(logger, "Cannot compare client and supplier because the model is not derived");
		}
		return true;
	}
}
