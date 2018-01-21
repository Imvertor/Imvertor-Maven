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

import java.io.File;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.XmlFile;

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
	public boolean run() throws Exception{
		
		// First output the current parameter settings so that reporting hasd full access. 
		// Subsequent assignments will, not influence the output anymore.
		XmlFile xParmsChainFile = new XmlFile(configurator.getXParm("properties/WORK_XPARMS_CHAIN_FILE"));
		XmlFile xsltCallChainFile = new XmlFile(configurator.getXParm("properties/WORK_XSLTCALLS_CHAIN_FILE"));
		
		xParmsChainFile.setContent(configurator.getxParmLogger().export());
		xsltCallChainFile.setContent(configurator.getXsltCallLogger().export());
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger, "Analyzing this run");
		
		// when profiling, compile the tally profile file 
		if (runner.getDebug()) {
			File profileFolder = new File(configurator.getXParm("system/work-profile-folder-path"));
			String tally = "<profiles total=\"" + configurator.runtime() + "\">";
			String[] files = profileFolder.list();
			for (int f = 0; f < files.length; f++) {
				AnyFile profileFile = new AnyFile(profileFolder, files[f]);
				tally += "<file path=\"" + profileFile.getCanonicalPath() + "\">" + profileFile.getContent() + "</file>";
			}
			tally += "</profiles>";
			AnyFile profilesDoc = new AnyFile(profileFolder,"profiles.xml");
			configurator.setXParm("system/profiles-doc", profilesDoc.getCanonicalPath(), true);
			profilesDoc.setContent(tally);
		}	
		
		if (configurator.getXParm("system/cur-imvertor-filepath",false) != null) {
			Transformer transformer = new Transformer();
			transformer.transformStep("system/cur-imvertor-filepath", "properties/WORK_ANALYZER_FILE", "properties/RUN_ANALYZER_XSL"); 
			//TODO general: also provide default empty input, and default empty output files.
		}
			
		configurator.setStepDone(STEP_NAME);
		
	    // save any changes to the work configuration for report and future steps
	    configurator.save();
		
		// generate report
		report();
		
		return runner.succeeds();
			
	}
	
}
