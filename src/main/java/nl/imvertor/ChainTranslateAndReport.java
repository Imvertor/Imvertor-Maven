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
import nl.imvertor.ConfigCompiler.ConfigCompiler;
import nl.imvertor.EapCompiler.EapCompiler;
import nl.imvertor.EpCompiler.EpCompiler;
import nl.imvertor.HistoryCompiler.HistoryCompiler;
import nl.imvertor.ImvertCompiler.ImvertCompiler;
import nl.imvertor.JsonConceptsCompiler.JsonConceptsCompiler;
import nl.imvertor.JsonSchemaCompiler.JsonSchemaCompiler;
import nl.imvertor.MIMCompiler.MIMCompiler;
import nl.imvertor.ModelHistoryAnalyzer.ModelHistoryAnalyzer;
import nl.imvertor.OfficeCompiler.OfficeCompiler;
import nl.imvertor.ParmsCopier.ParmsCopier;
import nl.imvertor.ReadmeCompiler.ReadmeCompiler;
import nl.imvertor.RegressionExtractor.RegressionExtractor;
import nl.imvertor.ReleaseComparer.ReleaseComparer;
import nl.imvertor.ReleaseCompiler.ReleaseCompiler;
import nl.imvertor.Reporter.Reporter;
import nl.imvertor.RunAnalyzer.RunAnalyzer;
import nl.imvertor.RunInitializer.RunInitializer;
import nl.imvertor.SchemaValidator.SchemaValidator;
import nl.imvertor.ShaclCompiler.ShaclCompiler;
import nl.imvertor.SkosCompiler.SkosCompiler;
import nl.imvertor.StcCompiler.StcCompiler;
import nl.imvertor.Validator.Validator;
import nl.imvertor.XmiCompiler.XmiCompiler;
import nl.imvertor.XmiTranslator.XmiTranslator;
import nl.imvertor.XsdCompiler.XsdCompiler;
import nl.imvertor.YamlCompiler.YamlCompiler;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Release;
import nl.imvertor.common.Transformer;

public class ChainTranslateAndReport {

	protected static final Logger logger = Logger.getLogger(ChainTranslateAndReport.class);
	
	public static void main(String[] args) {
		
		Configurator configurator = Configurator.getInstance();
		
		try {
			// fixed: show copyright info
			System.out.println("Imvertor chain - Translate and Report on Information model");
			System.out.println("");
			System.out.println(Release.getNotice());
			System.out.println("");
			
			configurator.getRunner().info(logger, "Framework version " + Release.getVersionString("Imvertor"));
			configurator.getRunner().info(logger, "Chain version " + Release.getVersionString("ChainTranslateAndReport"));
			configurator.getRunner().info(logger, "Job ID \"" + System.getProperty("job.id") + "\"");
			
			configurator.prepare(); // note that the process config is relative to the step folder path
			configurator.getRunner().prepare();
			
			// parameter processing
			configurator.getCli("common");
			configurator.getCli(ConfigCompiler.STEP_NAME);
			configurator.getCli(ApcModifier.STEP_NAME);
			configurator.getCli(XmiCompiler.STEP_NAME);
			configurator.getCli(XmiTranslator.STEP_NAME);
			configurator.getCli(Validator.STEP_NAME);
			configurator.getCli(ModelHistoryAnalyzer.STEP_NAME);
			configurator.getCli(ConceptCollector.STEP_NAME);
			configurator.getCli(ImvertCompiler.STEP_NAME);
			configurator.getCli(MIMCompiler.STEP_NAME);
			configurator.getCli(StcCompiler.STEP_NAME);
			configurator.getCli(XsdCompiler.STEP_NAME);
			configurator.getCli(ShaclCompiler.STEP_NAME);
			configurator.getCli(LDCompiler.STEP_NAME);
			configurator.getCli(EpCompiler.STEP_NAME);
			configurator.getCli(JsonSchemaCompiler.STEP_NAME);
			configurator.getCli(JsonConceptsCompiler.STEP_NAME);
			configurator.getCli(YamlCompiler.STEP_NAME);
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
		   
		    String model = configurator.getXParm("cli/project") +"/"+ configurator.getXParm("cli/application");
		    
		    configurator.getRunner().info(logger,"Processing application " + model);
		    configurator.getRunner().setDebug();
		    
		    boolean succeeds = true;
		    boolean forced = false;
		    
		    // initialize this run. 
		    (new RunInitializer()).run();
		    
		    try {
		    	
		    	// Build the configuration file
			    succeeds = (new ConfigCompiler()).run();
			 
			    Transformer.setMayProfile(true);
			    
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
			    	if (true) // TODO must add condition here
			    		succeeds = succeeds && (new ApcModifier()).run();
					
					// analyze the model history file. 
			    	// this records the state of the previous release.
				    succeeds = succeeds && (new ModelHistoryAnalyzer()).run();
					
					// check if we can start the release, i.e. overwrite the contents of the application folder
					// this is not allowed when previous release was a release, no errors, and in phase 3.
					// note: this could be postponed when first creating the application, and then deciding to copy the (temporary) folder to the output folder. 
					// However, this implies a full run and we want to signal this at early stage.
				    succeeds = configurator.prepareRelease() && succeeds;
					
					// get all concept info to be used in validation: URI references must be valid.
				    if (!configurator.getXParm("cli/refreshconcepts").equals("never")) 
				    	succeeds = succeeds && (new ConceptCollector()).run();
					
					// compile a final usable representation of the input file for XML schema generation.
					// TODO determine if this steps must be split into several steps
				    succeeds = succeeds && (new ImvertCompiler()).run();
				    
				    // generate the MIM format from Imvertor embellish format
				    if (configurator.isTrue("cli","createmimformat",false))
			 			(new MIMCompiler()).run(); // MIM compiler does not block further processing
					
				    // generate the Stelselcatalogus CSV
				    if (configurator.isTrue("cli","createstccsv",false))
			 			succeeds = succeeds && (new StcCompiler()).run();
					
					// compare releases. 
				    // Eg. check if this only concerns a "documentation release". If so, must not be different from existing release.
				    // also includes other types of release comparisons
				    if (configurator.isTrue("cli","compare",false))
				    	succeeds = succeeds && (new ReleaseComparer()).run();
				    
				    // generate the XSD 
					if (configurator.isTrue("cli","createxmlschema",false))
						succeeds = succeeds && (new XsdCompiler()).run();
								
					// validate the generated XSDs 
					if (succeeds)
						if (configurator.isTrue("cli","createxmlschema",false))
							if (configurator.isTrue("cli","validateschema",false) || configurator.getRunner().isFinal())
								(new SchemaValidator()).run(); // XML schema validation does not block further processing
					
					// Generate a json schema
				    if (configurator.isTrue("cli","createjsonschema",false)) {
			    		succeeds = succeeds && (new EpCompiler()).run();
		    			succeeds = succeeds && (new JsonSchemaCompiler()).run();
					}
				    // compile the history info 
					if (configurator.isTrue("cli","createhistory",false))
						succeeds = succeeds && (new HistoryCompiler()).run();
								
					// compile Office documentation 
					if (!configurator.getXParm("cli/createoffice").equals("none"))
						succeeds = succeeds && (new OfficeCompiler()).run();
			
					// compile templates and reports on UML EAP 
				    succeeds = succeeds && (new EapCompiler()).run();
			
					// compile compliancy Excel
				   	if (configurator.isTrue("cli","createxmlschema",false))
					    if (configurator.isTrue("cli","createcomplyexcel",false))
				    		succeeds = succeeds && (new ComplyCompiler()).run();
				     
				    if (configurator.isTrue("cli","createshacl",false)) 
				    	succeeds = succeeds && (new ShaclCompiler()).run();
				    if (configurator.isTrue("cli","createld",false)) 
				    	succeeds = succeeds && (new LDCompiler()).run();
		
				    if (configurator.isTrue("cli","createjsonconcepts",false))
			 			succeeds = succeeds && (new JsonConceptsCompiler()).run();
				
				    if (configurator.isTrue("cli","createskos",false)) 
				    	succeeds = succeeds && (new SkosCompiler()).run();
		
				    if (configurator.isTrue("cli","createyaml",false)) 
			    		succeeds = succeeds && (new YamlCompiler()).run();
				  
			    }
	    		(new ParmsCopier()).run();
	    		
			    // finally, a regression test if requested, independent of success/failure of the chain
			    if (configurator.isTrue("cli","regression",false)) {
			    	configurator.setXParm("cli/identifier","DEVELOPMENT");
			    	(new RegressionExtractor()).run();
			    }
		    
		    } catch (Exception e) {
				configurator.getRunner().error(logger,"Step-level system error - Please notify your system administrator: " + e.getMessage(),e);
			}   
		    
		    Transformer.setMayProfile(false);
	    	
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
			configurator.getRunner().info(logger, "Done, job \"" + System.getProperty("job.id") + "\" for model \"" + model + "\" " + (succeeds ? "succeeds" : "fails") + " in " + configurator.runtimeForDisplay());
		    if (configurator.getSuppressWarnings() && configurator.getRunner().hasWarnings())
		    	configurator.getRunner().info(logger, "** Warnings have been suppressed");
		    
		} catch (Exception e) {
			configurator.getRunner().fatal(logger,"Chain-level system error - Please notify your administrator: " + e.getMessage(),e,"PNYSA");
		}
		System.exit(0); // should be 1 , "okay"
	}
}
