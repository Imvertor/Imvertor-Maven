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

import nl.imvertor.ConfigCompiler.ConfigCompiler;
import nl.imvertor.MsWordTransformer.MsWordTransformer;
import nl.imvertor.ReadmeCompiler.ReadmeCompiler;
import nl.imvertor.ReleaseCompiler.ReleaseCompiler;
import nl.imvertor.Reporter.Reporter;
import nl.imvertor.RunAnalyzer.RunAnalyzer;
import nl.imvertor.RunInitializer.RunInitializer;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Release;

public class ChainMsWordTransformer {

	protected static final Logger logger = Logger.getLogger(ChainMsWordTransformer.class);
	
	public static void main(String[] args) {
		
		Configurator configurator = Configurator.getInstance();
		
		try {
			// fixed: show copyright info
			System.out.println("Imvertor chain - MsWord transformer");
			System.out.println("");
			System.out.println(Release.getNotice());
			System.out.println("");
			
			configurator.getRunner().info(logger, "Framework version " + Release.getVersionString("Imvertor"));
			configurator.getRunner().info(logger, "Chain version " + Release.getVersionString("ChainMsWordTransformer"));
					
			configurator.prepare(); // note that the process config is relative to the step folder path
			configurator.getRunner().prepare();
			
			// parameter processing
			configurator.getCli(ConfigCompiler.STEP_NAME);
			configurator.getCli(MsWordTransformer.STEP_NAME);
			configurator.getCli(Reporter.STEP_NAME);
			configurator.getCli(ReleaseCompiler.STEP_NAME);
			
			configurator.setParmsFromOptions(args);
			configurator.setParmsFromEnv();
		
		    configurator.save();
		   
		    configurator.getRunner().info(logger,"Processing application " + configurator.getXParm("cli/project") +"/"+ configurator.getXParm("cli/application"));
	    	configurator.getRunner().setDebug();
		    
	    	 // initialize this run. 
		    (new RunInitializer()).run();
		    
		    boolean succeeds = true;
		   
		    try {
		    	// Build the configuration file
		        succeeds = (new ConfigCompiler()).run();
			    
			    succeeds = succeeds && (new MsWordTransformer()).run();
		    
		    } catch (Exception e) {
				configurator.getRunner().error(logger,"Step-level system error - Please notify your system administrator: " + e.getMessage(),e);
			}   
		    
			 // Run the reporter in all cases; grabs all fragments and status info in parms.xml and compiles the documentation.
			(new Reporter()).run();
			
			// Create a readme file that provides access to the documentation and xsds generated.
			(new ReadmeCompiler()).run();
			
			// compile the release as well as the ZIP release
			(new ReleaseCompiler()).run();
			
			configurator.getRunner().windup();
			configurator.getRunner().info(logger, "Done, chain process " + (succeeds ? "succeeds" : "fails"));
		    if (configurator.getSuppressWarnings() && configurator.getRunner().hasWarnings())
		    	configurator.getRunner().info(logger, "** Warnings have been suppressed");

		} catch (Exception e) {
			configurator.getRunner().fatal(logger,"Please notify your system administrator.",e,"PNYSA");
		}
	}
}
