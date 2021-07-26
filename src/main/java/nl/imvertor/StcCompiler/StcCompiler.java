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

package nl.imvertor.StcCompiler;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;

/**
 * The Stelselcatalogus compiler takes the imvertor embellish file and transforms it to CSV.
 * 
 * @author arjan
 *
 */
public class StcCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(StcCompiler.class);
	
	public static final String STEP_NAME = "StcCompiler";
	public static final String VC_IDENTIFIER = "$Id: $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling Stelselcatalogus format");
		
		boolean succeeds = true;
		
		succeeds = succeeds && generateDefault();
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate Stelselcatalogus (stc) csv
	 *  
	 * @throws Exception
	 */
	public boolean generateDefault() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		runner.debug(logger,"CHAIN","Generating Stelselcatalogus format");
		
		// Transform Imvertor info to MIM format
		if (configurator.getXParm("properties/WORK_EMBELLISH_FILE", false) != null) {
			succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE", "properties/WORK_STCCSVG_XMLPATH", "properties/IMVERTOR_STCCSVG_XSLPATH"); 
			succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE", "properties/WORK_STCCSVB_XMLPATH", "properties/IMVERTOR_STCCSVB_XSLPATH"); 
					
			// store to stc folder
			// bovenstaande conversies leveren XML op volgens voorgedefinieerd formaat, dat kan worden omgezet door csvFile naar CSV
			if (succeeds) {
				// Create the output folder; it is not expected to exist yet.
				AnyFolder xmlFolder = new AnyFolder(configurator.getXParm("system/work-stc-folder-path"));
				xmlFolder.mkdirs();
				// verwerk gegevenstab
				XmlFile resultStcgFile = new XmlFile(configurator.getXParm("properties/WORK_STCCSVG_XMLPATH"));
				String stcCsvgName = configurator.mergeParms(configurator.getXParm("cli/stccsvname")) + "-gegevenselementen";
				resultStcgFile.toCsv(new AnyFile(xmlFolder, stcCsvgName + ".csv"));
				// verwerk bronnen tab
				XmlFile resultStcbFile = new XmlFile(configurator.getXParm("properties/WORK_STCCSVB_XMLPATH"));
				String stcCsvbName = configurator.mergeParms(configurator.getXParm("cli/stccsvname")) + "-bronnen";
				resultStcbFile.toCsv(new AnyFile(xmlFolder, stcCsvbName + ".csv"));
			}
			
		} else {
			runner.error(logger, "Stelselcatalogus CSV cannot be compiled.");
			succeeds = false;
		}
		configurator.setXParm("system/stc-compiler-csv-created", succeeds);	
		return succeeds;
		
	}
	
}
