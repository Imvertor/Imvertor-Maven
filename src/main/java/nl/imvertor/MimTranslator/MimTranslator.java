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

package nl.imvertor.MimTranslator;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;


/**
 * Translate MIM serialisation file to Imvertor format.
 * 
 * @author arjan
 *
 */
public class MimTranslator extends Step {

	protected static final Logger logger = Logger.getLogger(MimTranslator.class);
	
	public static final String STEP_NAME = "MimTranslator";
	public static final String VC_IDENTIFIER = "$Id$";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Translating MIM serialisation to Imvertor format");

		// create a transformer
		Transformer transformer = new Transformer();
			    
	    // transform 
		boolean succeeds = true;
		succeeds = succeeds ? transformer.transformStep("system/mim-export-file-path", "properties/WORK_BASE_FILE",  "properties/MIM_IMVERTOR_XSLPATH","system/cur-imvertor-filepath") : false ;
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
		return runner.succeeds();
			
	}
	
}
