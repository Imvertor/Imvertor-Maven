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

package nl.imvertor;

import org.apache.log4j.Logger;

import nl.imvertor.ApcModifier.ApcModifier;
import nl.imvertor.ComplyCompiler.ComplyCompiler;
import nl.imvertor.ConceptCollector.ConceptCollector;
import nl.imvertor.EapCompiler.EapCompiler;
import nl.imvertor.HistoryCompiler.HistoryCompiler;
import nl.imvertor.ImvertCompiler.ImvertCompiler;
import nl.imvertor.OfficeCompiler.OfficeCompiler;
import nl.imvertor.ReadmeAnalyzer.ReadmeAnalyzer;
import nl.imvertor.ReadmeCompiler.ReadmeCompiler;
import nl.imvertor.ReleaseComparer.ReleaseComparer;
import nl.imvertor.ReleaseCompiler.ReleaseCompiler;
import nl.imvertor.Reporter.Reporter;
import nl.imvertor.RunAnalyzer.RunAnalyzer;
import nl.imvertor.SchemaValidator.SchemaValidator;
import nl.imvertor.Validator.Validator;
import nl.imvertor.XmiCompiler.XmiCompiler;
import nl.imvertor.XmiTranslator.XmiTranslator;
import nl.imvertor.XsdCompiler.XsdCompiler;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Release;

public class ChainTranslateAndReport {

	protected static final Logger logger = Logger.getLogger(ChainTranslateAndReport.class);
	
	public static void main(String[] args) {
		
		Configurator configurator = Configurator.getInstance();
		
		try {
			// fixed: show copyright info
			System.out.println("Imvertor - " + Release.getNotice());
			
			configurator.getRunner().info(logger, "Framework version - " + Release.getVersionString());
			configurator.getRunner().info(logger, "Chain version - " + "Translate and report 0.9");
	
			configurator.prepare(); // note that the process config is relative to the step folder path
			configurator.getRunner().prepare();
			
			// parameter processing
			configurator.getCli("common");
			configurator.getCli(ApcModifier.STEP_NAME);
			configurator.getCli(XmiCompiler.STEP_NAME);
			configurator.getCli(XmiTranslator.STEP_NAME);
			configurator.getCli(Validator.STEP_NAME);
			configurator.getCli(ReadmeAnalyzer.STEP_NAME);
			configurator.getCli(ConceptCollector.STEP_NAME);
			configurator.getCli(ImvertCompiler.STEP_NAME);
			configurator.getCli(XsdCompiler.STEP_NAME);
			configurator.getCli(ReleaseComparer.STEP_NAME);
			configurator.getCli(SchemaValidator.STEP_NAME);
			configurator.getCli(HistoryCompiler.STEP_NAME);
			configurator.getCli(OfficeCompiler.STEP_NAME);
			configurator.getCli(EapCompiler.STEP_NAME);
			configurator.getCli(ComplyCompiler.STEP_NAME);
			configurator.getCli(RunAnalyzer.STEP_NAME);
			configurator.getCli(Reporter.STEP_NAME);
			configurator.getCli(ReadmeCompiler.STEP_NAME);
			configurator.getCli(ReleaseCompiler.STEP_NAME);

			configurator.setParmsFromOptions(args);
			configurator.setParmsFromEnv();
		
		    configurator.save();
		   
		    configurator.getRunner().info(logger,"Processing application " + configurator.getParm("cli","project") +": "+ configurator.getParm("cli","application"));
		    
		    boolean succeeds = true;
		    boolean forced = false;
		    		    
			// Create the XMI file from EAP or other sources
		    succeeds = (new XmiCompiler()).run();
			
		    // Translate XMI to Imvertor format
		    succeeds = succeeds && (new XmiTranslator()).run();
			
		    // Validate the Imvertor format against metamodel
		    succeeds = succeeds && (new Validator()).run();

		    // normally, stop when errors are reported. 
		    // However, in some circumstances (debugging or prototyping) we may want to continue anyway. 
		    forced = configurator.forceCompile() && !succeeds;
		    
		    // read the current application phase
		    configurator.getRunner().getAppPhase(); 
		    
		    if (succeeds || forced) {
		    
		    	if (forced) { 
			    	configurator.getRunner().warn(logger,"Ignoring metamodel errors found (forced compilation)");
			    	succeeds = true;
		    	}
		    	
		    	// Add information to the Imvertor file that is specific for a particular run
		    	succeeds = succeeds && (new ApcModifier()).run();
				
				// analyze the readme file. this records the state of the previous release.
			    succeeds = succeeds && (new ReadmeAnalyzer()).run();
				
				// check if we can start the release, i.e. overwrite the contents of the application folder
				// this is not allowed when previous release was a release, no errors, and in phase 3.
				// note: this could be postponed when first creating the application, and then deciding to copy the (temporary) folder to the output folder. 
				// However, this implies a full run and we want to signal this at early stage.
			    succeeds = configurator.prepareRelease() && succeeds;
				
				// get all concept info to be used in validation: URI references must be valid.
			    succeeds = succeeds && (new ConceptCollector()).run();
				
				// compile a final usable representation of the input file for XML schema generation.
				// TODO determine if this steps must be split into several steps
			    succeeds = succeeds && (new ImvertCompiler()).run();
				
				// compare releases. 
			    // Eg. check if this only concerns a "documentation release". If so, must not be different from existing release.
			    // also includes other types of release comparisons
			    succeeds = succeeds && (new ReleaseComparer()).run();
			    			
				// generate the XSD 
			    succeeds = succeeds && (new XsdCompiler()).run();
							
				// validate the generated XSDs 
			    succeeds = succeeds && (new SchemaValidator()).run();
							
				// compile the history info 
			    succeeds = succeeds && (new HistoryCompiler()).run();
							
				// compile Office documentation 
			    succeeds = succeeds && (new OfficeCompiler()).run();
		
				// compile templates and reports on UML EAP 
			    succeeds = succeeds && (new EapCompiler()).run();
		
				// compile compliancy Excel
			    succeeds = succeeds && (new ComplyCompiler()).run();
		
		    }
			// analyze this run. 
		    (new RunAnalyzer()).run();

		    // Run the reporter in all cases; grabs all fragments and status info in parms.xml and compiles the documentation.
			(new Reporter()).run();
			
			// Create a readme file that provides access to the documentation and xsds generated.
			(new ReadmeCompiler()).run();
			
			// compile the release as well as the ZIP release
			(new ReleaseCompiler()).run();
			
			configurator.windup();
			
			configurator.getRunner().windup();
			configurator.getRunner().info(logger, "Done, chain process " + (succeeds ? "succeeds" : "fails"));
		    if (configurator.getSuppressWarnings() && configurator.getRunner().hasWarnings())
		    	configurator.getRunner().info(logger, "** Warnings have been suppressed");

		} catch (Exception e) {
			configurator.getRunner().fatal(logger,"Please notify your administrator.",e);
		}
	}
}
