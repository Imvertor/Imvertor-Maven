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

import nl.imvertor.XsltAnalyzer.XsltAnalyzer;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Release;


public class ChainXsltAnalyzer {

	protected static final Logger logger = Logger.getLogger(ChainXsltAnalyzer.class);
	
	public static void main(String[] args) {
		
		Configurator configurator = Configurator.getInstance();
		
		try {
			System.out.println("Imvertor chain - ChainXsltAnalyzer");
			System.out.println("");
			System.out.println(Release.getNotice());
			System.out.println("");
			
			configurator.getRunner().info(logger, "Framework version - " + Release.getVersionString("Imvertor"));
			configurator.getRunner().info(logger, "Chain version - " + Release.getVersionString("ChainXsltAnalyzer"));
			
			configurator.prepare(); // note that the process config is relative to the step folder path
			configurator.getRunner().prepare();
			
			// parameter processing
			configurator.getCli(XsltAnalyzer.STEP_NAME);
			
			configurator.setParmsFromOptions(args);
			configurator.setParmsFromEnv();
		
		    configurator.save();
		   
		    boolean succeeds = true;
		    		    
			// call single tester step
		    succeeds = (new XsltAnalyzer()).run();
			
			configurator.getRunner().windup();
			configurator.getRunner().info(logger, "Done, chain process " + (succeeds ? "succeeds" : "fails"));
		    if (configurator.getSuppressWarnings() && configurator.getRunner().hasWarnings())
		    	configurator.getRunner().info(logger, "** Warnings have been suppressed");

		} catch (Exception e) {
			configurator.getRunner().fatal(logger,"Please notify your administrator.",e,"PNYSA");
		}
	}
}
