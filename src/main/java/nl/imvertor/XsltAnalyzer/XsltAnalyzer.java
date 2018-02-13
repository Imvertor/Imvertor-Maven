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

package nl.imvertor.XsltAnalyzer;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.OutputFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;


/**
 * XsltAnalyzer creates a report on XSLT aspects. Pass folder of XSLT files. 
 * 
 * @author arjan
 *
 */
public class XsltAnalyzer extends Step {

	protected static final Logger logger = Logger.getLogger(XsltAnalyzer.class);
	
	public static final String STEP_NAME = "XsltAnalyzer";
	public static final String VC_IDENTIFIER = "$$";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception {
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();

		// create a transformer
		Transformer transformer = new Transformer();
			
		boolean succeeds = true;

		// serialize the input folder 
		AnyFile folder = new AnyFile(configurator.getXParm("cli/folder"));
		XslFile filterXslFile = new XslFile(configurator.getXslPath(configurator.getXParm("properties/XSLTANALYZER_FILTER_XSL")));
		XmlFile serializedFile = new XmlFile(configurator.getXParm("properties/XSLTANALYZER_FILTER_RESULT_XML"));
			
		if (folder.isDirectory()) {
			// process the full folder. Create an XML file holding all XSLTs.
			AnyFolder infolder = new AnyFolder(folder);
			infolder.setSerializedFilePath(serializedFile.getCanonicalPath());
			int selected = infolder.serializeToXml(filterXslFile);
			
			runner.info(logger,"Analyzing " + selected + " XSLT files");
			
			// transform this to an XML representation of all info
			succeeds = succeeds ? transformer.transformStep(
					"properties/XSLTANALYZER_FILTER_RESULT_XML", 
					"properties/XSLTANALYZER_ANALYSIS_RESULT_XML", 
					"properties/XSLTANALYZER_ANALYSIS_XSL") : false ;

			OutputFolder outFolder = new OutputFolder(configurator.getXParm("system/work-app-folder-path") + "/xslt");
			outFolder.clear(false);
					
			// transform this to HTML
			transformer.setXslParm("output-folder-path", outFolder.getCanonicalPath());
			succeeds = succeeds ? transformer.transformStep(
					"properties/XSLTANALYZER_ANALYSIS_RESULT_XML", 
					"properties/XSLTANALYZER_HTML_RESULT", 
					"properties/XSLTANALYZER_HTML_XSL") : false ;
			
		} else 
			configurator.getRunner().error(logger,"Please pass folder holding XSLT files: " + folder.getName());
		
		configurator.setStepDone(STEP_NAME);
		
	    // save any changes to the work configuration for report and future steps
	    configurator.save();
		
		// generate report
		report();
		
		return runner.succeeds();
			
	}
	
}
