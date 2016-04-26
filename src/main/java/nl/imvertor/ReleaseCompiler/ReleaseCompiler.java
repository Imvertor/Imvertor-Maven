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

package nl.imvertor.ReleaseCompiler;

import nl.imvertor.common.Step;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.ZipFile;

import org.apache.log4j.Logger;

public class ReleaseCompiler  extends Step {

	protected static final Logger logger = Logger.getLogger(ReleaseCompiler.class);
	
	public static final String STEP_NAME = "ReleaseCompiler";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	AnyFolder targetZipFolder;
	AnyFolder targetUserZipFolder;
	
	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		try {
			if (configurator.isTrue("cli","createziprelease")) {
				
				// set up the configuration for this step
				configurator.setActiveStepName(STEP_NAME);
				prepare();
				runner.info(logger,"Compiling ZIP release");
			
				if (configurator.getParm("properties","USER_ZIP_FILE",false) == null) 
					throw new Exception("No valid ZIP file path specified.");
				
				// local temporary spot to store the zip to.
				targetZipFolder = new AnyFolder(configurator.getParm("properties","RELEASES_FOLDER"));
				targetZipFolder.mkdirs();
				// The place where to copy the zip result for distribution.
				targetUserZipFolder = new AnyFolder(configurator.getParm("properties","USER_ZIP_FILE"));
				targetUserZipFolder.mkdirs();
				
				createZipRelease();
				
				configurator.setStepDone(STEP_NAME);
				
				// save any changes to the work configuration for report and future steps
			    configurator.save();
			    
			    //report();
			    
			}
			return runner.succeeds();
			
		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}
	
	/**
	 * Create a zip file for a full released application
	 * 
	 * @param directoryToZip
	 * @param targetZipFilePath
	 * 
	 * @throws Exception
	 */
	public void createZipRelease() throws Exception {
		AnyFolder workFolder = new AnyFolder(configurator.getWorkFolder("app"));
		ZipFile zip = new ZipFile(configurator.getParm("properties","ZIP_APPLICATION_FILE"));
		zip.compress(workFolder);
		// copy this file to the indicated result path
		String f = targetUserZipFolder.getCanonicalPath() + "/" + zip.getName();
		ZipFile userZipFile = new ZipFile(f);
		zip.copyFile(userZipFile);
		configurator.setParm("system","zip-release-filepath", userZipFile.getCanonicalPath());
		runner.info(logger, "ZIP release saved at: " + userZipFile.getCanonicalPath());
	}
}
