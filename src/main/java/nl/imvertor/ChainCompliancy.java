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
import nl.imvertor.ComplyExtractor.ComplyExtractor;
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

public class ChainCompliancy {

	protected static final Logger logger = Logger.getLogger(ChainCompliancy.class);
	
	public static void main(String[] args) {
		
		Configurator configurator = Configurator.getInstance();
		
		try {
			// fixed: show copyright info
			System.out.println("Imvertor - " + Release.getNotice());
			
			configurator.getRunner().info(logger, "Framework version - " + Release.getVersionString());
			configurator.getRunner().info(logger, "Chain version - " + "Compliancy extraction 0.1");
					
			configurator.prepare(); // note that the process config is relative to the step folder path
			configurator.getRunner().prepare();
			
			// parameter processing
			configurator.getCli(ComplyExtractor.STEP_NAME);
			
			configurator.setParmsFromOptions(args);
			configurator.setParmsFromEnv();
		
		    configurator.save();
		   
		    configurator.getRunner().info(logger,"Processing application " + configurator.getParm("cli","project") +": "+ configurator.getParm("cli","application"));
		    
		    boolean succeeds = true;
		    		    
			// compile compliancy xml
			succeeds = succeeds && (new ComplyExtractor()).run();
		
			// analyze this run. 
		    (new RunAnalyzer()).run();

		    // Run the reporter in all cases; grabs all fragments and status info in parms.xml and compiles the documentation.
			(new Reporter()).run();
			
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
