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

package nl.imvertor.XmiTranslator;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.xsl.extensions.ImvertorBase64Decode;
import nl.imvertor.common.xsl.extensions.ImvertorCompareXML;
import nl.imvertor.common.xsl.extensions.expath.ImvertorExpathWriteBinary;


/**
 * Translate XMI file to Imvertor format.
 * 
 * @author arjan
 *
 */
public class XmiTranslator extends Step {

	protected static final Logger logger = Logger.getLogger(XmiTranslator.class);
	
	public static final String STEP_NAME = "XmiTranslator";
	public static final String VC_IDENTIFIER = "$Id: XmiTranslator.java 7475 2016-03-23 10:54:06Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Translating XMI to Imvertor format");

		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorBase64Decode());
		transformer.setExtensionFunction(new ImvertorExpathWriteBinary());
			    
	    // transform 
		boolean succeeds = true;
		succeeds = succeeds ? transformer.transformStep("system/xmi-file-path", "properties/WORK_BASE_FILE",  "properties/XMI_IMVERTOR_XSLPATH","system/cur-imvertor-filepath") : false ;
		
		String imageCount = configurator.getXParm("system/xmi-image-count");
		
		if (configurator.isTrue("cli","createimagemap"))
			if (imageCount == null || imageCount.equals("0"))
				runner.warn(logger, "Imagemap not created because no diagram images found", null, "INCBNDIF");
			else 
			    succeeds = succeeds ? transformer.transformStep("system/xmi-file-path", "properties/WORK_BASE_IMAGEMAP_FILE",  "properties/XMI_IMVERTOR_IMAGEMAP_XSLPATH") : false ;
		
	    if (!configurator.isTrue("cli","createimagemap"))
			if (imageCount != null && !imageCount.equals("0"))
				runner.warn(logger, "Imagemap not created but diagram images found", null, "INCBDIF");
				
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
		return runner.succeeds();
			
	}
	
}
