/*
 * Copyright (C) 2016 VNG/KING
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

package nl.imvertor.RegressionExtractor;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XslFile;

public class RegressionExtractor  extends Step {

	protected static final Logger logger = Logger.getLogger(RegressionExtractor.class);
	
	public static final String STEP_NAME = "RegressionExtractor";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
			
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Compiling Regression file");
		
		// STUB
		//- configurator.setParm("appinfo","release","00000001");
		
		// serialize the ref and tst to a folder
		AnyFolder reffolder = new AnyFolder(configurator.getParm("cli","reffolder"));
		AnyFolder tstfolder = new AnyFolder(configurator.getParm("cli","tstfolder"));
		XslFile xslFilterFile = new XslFile(configurator.getXslPath(configurator.getParm("properties","REGRESSION_EXTRACT_XSLPATH")));
		
		tstfolder.serializeToXml(xslFilterFile);
		
		/*
		ZipFile template = new ZipFile(templateFilepath);
		AnyFolder serializeFolder = new AnyFolder(unzipFolderpath);
		template.serializeToXml(serializeFolder);
		
		// in the exported file we find _content.xml, which is the base for all transformations and holds all XML content found.
		// transform the exported folder any way required, on the basis of _content,xml.
		// No secial processing (repackaging) is required for this step.
		Transformer transformer = new Transformer();

		XmlFile contentFile = new XmlFile(serializeFolder,"__content.xml");
		configurator.setParm("system", "comply-content-file", contentFile.getCanonicalPath());
		transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_EXTRACT_FILE", "properties/WORK_COMPLY_EXTRACT_XSLPATH","system/cur-imvertor-filepath");
		
		*/
		
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
		    
		return runner.succeeds();
		
	}
}
