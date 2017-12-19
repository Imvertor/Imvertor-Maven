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

package nl.imvertor.ModelHistoryAnalyzer;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.file.XmlFile;

/**
 * Analyse an existing readme file (from any previous run for same release) and store info in the configuration file.
 * 
 * @author arjan
 *
 */
public class ModelHistoryAnalyzer  extends Step {

	protected static final Logger logger = Logger.getLogger(ModelHistoryAnalyzer.class);
	
	public static final String STEP_NAME = "ModelHistoryAnalyzer";
	public static final String VC_IDENTIFIER = "$Id: ModelHistoryAnalyzer.java 7431 2016-02-24 12:46:42Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Analyzing model history");

		XmlFile imvertFile = new XmlFile(configurator.getApplicationFolder(),"etc/system.imvert.xml");
		if (imvertFile.exists()) analyze(imvertFile);
		configurator.setStepDone(STEP_NAME);
		
	    // save any changes to the work configuration for report and future steps
	    configurator.save();
		
		// generate report
		report();
		
		return runner.succeeds();
			
	}
	
	/**
	 * Collect info on the previous run of this application.
	 * Sets the appinfo previous-* parameters.
	 * 
	 * @param readmeFilePath
	 * @return
	 * @throws Exception
	 */
	public void analyze(XmlFile imvertorFile) throws Exception {
		configurator.setXParm("appinfo/previous-phase", imvertorFile.xpath("/*:packages/*:phase"),true); 
		configurator.setXParm("appinfo/previous-errors", imvertorFile.xpath("/*:packages/*:process/*:errors"),true); 
		configurator.setXParm("appinfo/previous-release", imvertorFile.xpath("/*:packages/*:release"),true); 
		configurator.setXParm("appinfo/previous-date", imvertorFile.xpath("/*:packages/*:generated"),true); 
		configurator.setXParm("appinfo/previous-imvertor", imvertorFile.xpath("/*:packages/*:generator"),true); 
	}
}
