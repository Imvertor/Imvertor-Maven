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

package nl.imvertor.ReadmeAnalyzer;

import nl.imvertor.common.Step;
import nl.imvertor.common.file.AnyFile;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

/**
 * Analyse an existing readme file (from any previous run for same release) and store info in the configuration file.
 * 
 * @author arjan
 *
 */
public class ReadmeAnalyzer  extends Step {

	protected static final Logger logger = Logger.getLogger(ReadmeAnalyzer.class);
	
	public static final String STEP_NAME = "ReadmeAnalyzer";
	public static final String VC_IDENTIFIER = "$Id: ReadmeAnalyzer.java 7431 2016-02-24 12:46:42Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			runner.info(logger,"Analyzing supplier state");

			// determine the readmefile for the current application, and analyze that
			AnyFile readme = new AnyFile(configurator.getApplicationFolder(),"readme.html");
			if (readme.exists()) analyze(readme);
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
	
	/**
	 * Collect info on the previous run of this application.
	 * Sets the appinfo previous-* parameters.
	 * 
	 * @param readmeFilePath
	 * @return
	 * @throws Exception
	 */
	public void analyze(AnyFile readmeFile) throws Exception {
		// look for the processing string . Example #ph:2#ts:release#er:8#re:20150601#dt:2015-07-08 16:50:35#
		String[] toks = StringUtils.split(readmeFile.getContent(), "#"); 
		for (int i = 0; i < toks.length; i++) {
			String[] tok = StringUtils.split(toks[i],":");
			if (tok.length == 2) {
				switch (tok[0]) {
					case "ph": configurator.setParm("appinfo", "previous-phase", tok[1],true); 
					case "ts": configurator.setParm("appinfo", "previous-task", tok[1],true); 
					case "er": configurator.setParm("appinfo", "previous-errors", tok[1],true); 
					case "re": configurator.setParm("appinfo", "previous-release", tok[1],true); 
					case "dt": configurator.setParm("appinfo", "previous-date", tok[1],true); 
				}
			}
		}
		
		// TODO improve by writing and reading a xml file. For now, check this file contents by regex. Rather brute force.
		//create a transformer
		//Transformer transformer = new Transformer();
		//String xslFilePath = configurator.getXslPath(configurator.getParm("properties", "IMVERTOR_README_ANALYZE_XSLPATH"));
	    //return transformer.transform(readmeFilePath, null, xslFilePath);
	}
}
