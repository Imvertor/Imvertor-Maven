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

package nl.imvertor.HistoryCompiler;

import java.io.File;

import nl.imvertor.XmiCompiler.XmiCompiler;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.ExcelFile;
import nl.imvertor.common.file.XmlFile;

import org.apache.log4j.Logger;

public class HistoryCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(XmiCompiler.class);
	
	public static final String STEP_NAME = "HistoryCompiler";
	public static final String VC_IDENTIFIER = "$Id: HistoryCompiler.java 7457 2016-03-05 08:43:43Z arjan $";

	// TODO transformer per step?? as property like this?
	Transformer transformer;

	public boolean run() {
		
		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			if (configurator.isTrue("cli","createhistory")) {
				runner.info(logger,"Merging version info");

				transformer = new Transformer();
				mergeVersionsInfo();
			
				configurator.setStepDone(STEP_NAME);
			}
			
			// save any changes to the work configuration for report and future steps
		    configurator.save();

		    report();

			return runner.succeeds();

		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}

	/**
	 * Process the Excel history file by transforming it to INFO. Combine the
	 * INFO files into a single big INFO specification, holding only the
	 * relevant packages.
	 * 
	 * @throws Exception
	 */
	private boolean mergeVersionsInfo() throws Exception {
		// transform the Excel holding history info for this application to XML specification
		ExcelFile ef = new ExcelFile(configurator.getParm("properties","USER_HISTORY_FILE"));
		if (ef.exists()) {
			
			File hisXmlFile = File.createTempFile("mergeVersionsInfo.", ".xml");
			configurator.setParm("step","HIS_XML_FILE_PATH",hisXmlFile.getCanonicalPath());
			hisXmlFile.deleteOnExit();
			ef.toXmlFile(hisXmlFile.getCanonicalPath(),configurator.getParm("properties","FORMATWORKBOOK_DTD"));
			
		   // transform 
			boolean succeeds = true;
			
			// a compile list of steps to create all base files for final processing.
			succeeds = succeeds ? transformer.transformStep("step/HIS_XML_FILE_PATH","properties/WORK_HISTORY_FILE","properties/IMVERTOR_VERSIONS_XSLPATH") : false;
			// call the merger script, which merges all history info files
			// TODO WORK_DEPENDENCIES_FILE is gemaakt in algemene step; moet hier?
			succeeds = succeeds ? transformer.transformStep("properties/WORK_DEPENDENCIES_FILE","properties/WORK_VERSIONS_FILE", "properties/IMVERTOR_VERSIONS_MERGER_XSLPATH") : false;
	
			// copy the file to the etc folder for future reference and comparisons
			AnyFolder etcFolder = new AnyFolder(configurator.getParm("system","work-etc-folder-path"));
			XmlFile infoVersionsFile = new XmlFile(configurator.getParm("properties", "WORK_HISTORY_FILE"));	
			XmlFile hisModelFile = new XmlFile(etcFolder,"history.imvert.xml");	
			infoVersionsFile.copyFile(hisModelFile);
			
			return succeeds;
		} else { 
			runner.error(logger, "History file does not exist: " + ef.getPath());
			return false;
		}
	}
	

}
