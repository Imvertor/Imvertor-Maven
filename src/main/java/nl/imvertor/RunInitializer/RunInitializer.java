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

package nl.imvertor.RunInitializer;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.file.XmlFile;

/**
 * Analyse the full run results and pass info to the parms file for final processing (reporting).
 * 
 * @author arjan
 *
 */
public class RunInitializer extends Step {

	protected static final Logger logger = Logger.getLogger(RunInitializer.class);
	
	public static final String STEP_NAME = "RunInitializer";
	public static final String VC_IDENTIFIER = "$Id: RunAnalyzer.java 7431 2016-02-24 12:46:42Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception {
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger, "Initializing this run");
		
		// create empty workfile
		XmlFile initFile = new XmlFile(configurator.getParm("properties","WORK_INITIALIZER_FILE"));
		initFile.getParentFile().mkdirs();
		initFile.setContent("<root/>");
	
		configurator.setParm("system", "cur-imvertor-filepath", initFile.getCanonicalPath());
		
		configurator.setParm("appinfo", "project-name", "UNKNOWN-PROJECT-NAME");
		configurator.setParm("appinfo", "application-name", "UNKNOWN-APPLICATION-NAME");
		configurator.setParm("appinfo", "release-name", "UNKNOWN-RELEASE-NAME");
		configurator.setParm("appinfo", "release", "UNKNOWN-RELEASE");
		configurator.setParm("properties", "WORK_BASE_FILE", initFile.getCanonicalPath());
		configurator.setStepDone(STEP_NAME);
		
	    // save any changes to the work configuration for report and future steps
	    configurator.save();
		
		// generate report
		report();
		
		return runner.succeeds();
			
	}
	
}
