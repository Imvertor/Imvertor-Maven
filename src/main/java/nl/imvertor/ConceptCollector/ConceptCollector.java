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

package nl.imvertor.ConceptCollector;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.XmlFile;

public class ConceptCollector extends Step {
	
	protected static final Logger logger = Logger.getLogger(ConceptCollector.class);
	
	public static final String STEP_NAME = "ConceptCollector";
	public static final String VC_IDENTIFIER = "$Id: ConceptCollector.java 7451 2016-03-04 09:07:56Z arjan $";

	private XmlFile infoConceptsFile;
	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		// determine the path of the concepts file
		// This is the file holding imvert representation of all concepts
		// The parameter file holds a name in which the release date is placed between [YYYYMMDD]. 
		
		String infoConceptsFilePath = StringUtils.replace(configurator.getXParm("properties/CONCEPT_DOCUMENTATION_PATH"), "[release]", configurator.getXParm("appinfo/release"));
		infoConceptsFile = new XmlFile(infoConceptsFilePath);
	    configurator.setXParm("appinfo/concepts-file",infoConceptsFile.getCanonicalPath()); 
		
	    // determine if concepts must be read.
	    // This is when forced, of when the concepts file is not available, or when the application phase is 3 (final).
	    boolean block = configurator.getXParm("cli/refreshconcepts").equals("never");
	    boolean forc = configurator.isTrue("cli","refreshconcepts");
	    boolean must = (!infoConceptsFile.isFile() || !infoConceptsFile.isWellFormed() || infoConceptsFile.xpath("//*:concept").equals(""));
	    boolean finl = configurator.getXParm("appinfo/phase").equals("3"); 	
	   
	    if (forc) configurator.setXParm("appinfo/concepts-extraction-reason", "forced by user");
	    if (must) configurator.setXParm("appinfo/concepts-extraction-reason", "must be refreshed");
	    if (finl) configurator.setXParm("appinfo/concepts-extraction-reason", "final release");
	    
	    if (!block && (forc || must || finl) ) {
	    	
	    	runner.info(logger,"Collecting concepts");
	    	
	    	configurator.setXParm("appinfo/concepts-extraction", "true");
	    	
			// This implementation accsses the internet, and reads RDF statements. Check if internet s avilable.
			if (!runner.activateInternet())
				throw new Exception("Cannot access the internet, cannot read concepts");
		
			// create a transformer
			Transformer transformer = new Transformer();
			    
			// pass the api key
			String apikey = configurator.getServerProperty("catalog.x.api.key"); // key to access the API
			transformer.setXslParm("x-api-key", apikey);
			
		    // transform; if anything goes wrong remove the concept file so that next time try again.
			//IM-216
			
			boolean succeeds = true;
			//TODO this extracts the RDF XML to a location in the managed output folder. Better is to check the common managed input folder, copy that and procesds, or recomnpile when not available in common input folder?
			boolean okay = transformer.transformStep("system/cur-imvertor-filepath", "appinfo/concepts-file", "properties/IMVERTOR_EXTRACTCONCEPTS_XSLPATH");
			if (okay)
				configurator.setXParm("appinfo/concepts-extraction-succeeds", "true");
			else {
				configurator.setXParm("appinfo/concepts-extraction-succeeds", "false");
				infoConceptsFile.delete(); 
			}
			succeeds = succeeds ? okay : false ;
			
			
			configurator.setStepDone(STEP_NAME);
			
	    } else {
			configurator.setXParm("appinfo/concepts-extraction", "false");
			configurator.setXParm("appinfo/concepts-extraction-reason", (block ? "blocked" : "precompiled"));
			configurator.setXParm("appinfo/concepts-extraction-succeeds", "true");
		}
	
	    // save any changes to the work configuration for report and future steps
	    configurator.save();
		
		// generate report
		report();

		return runner.succeeds();
			
	}
	
}