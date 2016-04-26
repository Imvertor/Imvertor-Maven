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

package nl.imvertor.Reporter;

import nl.imvertor.common.Step;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.OutputFolder;

import org.apache.log4j.Logger;

/**
 * This class reports on the state of a run, 
 * Based on the current parms.xml, and possible XHTML fragments found in the work folder in files with names [step]-report.xml. 
 * 
 * @author arjan
 *
 */
public class Reporter extends Step {

	protected static final Logger logger = Logger.getLogger(Reporter.class);
	
	public static final String STEP_NAME = "Reporter";
	public static final String VC_IDENTIFIER = "$Id: Reporter.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the main translation
	 * @throws Exception 
	 */
	public boolean run() {

		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			runner.info(logger,"Compiling final report");

			// copy the HTML stuff to the result documentation workfolder
			String owner = configurator.getParm("cli", "owner");
			String sourceHtml = configurator.getParm("system", "cfg-folder-path") + "/common/owners/" + owner + "/web";
			AnyFolder sourceHtmlFolder = new AnyFolder(sourceHtml);
			if (!sourceHtmlFolder.isDirectory())
				throw new Exception("Not a folder: " + sourceHtmlFolder.getCanonicalPath());
			OutputFolder targetHtmlFolder = new OutputFolder(configurator.getParm("system","work-doc-folder-path") + "/web");
			if (targetHtmlFolder.exists()) 
				targetHtmlFolder.clear(false);
			sourceHtmlFolder.copy(targetHtmlFolder);
			
			configurator.setStepDone(STEP_NAME);
			
			// no additional transformations, just report
			report();
			return runner.succeeds();

		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}
}
