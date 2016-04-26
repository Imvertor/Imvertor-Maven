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

package nl.imvertor.RunAnalyzer;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;

import org.apache.log4j.Logger;

/**
 * Analyse the full run results and pass info to the parms file for final processing (reporting).
 * 
 * @author arjan
 *
 */
public class RunAnalyzer extends Step {

	protected static final Logger logger = Logger.getLogger(RunAnalyzer.class);
	
	public static final String STEP_NAME = "RunAnalyzer";
	public static final String VC_IDENTIFIER = "$Id: RunAnalyzer.java 7431 2016-02-24 12:46:42Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			runner.info(logger, "Analyzing this run");
			
			Transformer transformer = new Transformer();
			transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_ANALYZER_FILE", "properties/RUN_ANALYZER_XSL"); 
			//TODO general: also provide default empty input, and default empty output files.
			
			configurator.setStepDone(STEP_NAME);
			
		    // save any changes to the work configuration for report and future steps
		    configurator.save();
			
			// generate report
			report();
			
			return runner.succeeds();
			
		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}
	
}
