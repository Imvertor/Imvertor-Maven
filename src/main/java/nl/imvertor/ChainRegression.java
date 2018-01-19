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

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.log4j.Logger;

import nl.imvertor.RegressionExtractor.RegressionExtractor;
import nl.imvertor.RunAnalyzer.RunAnalyzer;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Release;

public class ChainRegression {

	protected static final Logger logger = Logger.getLogger(ChainRegression.class);
	
	public static void main(String[] args) {
		
		Configurator configurator = Configurator.getInstance();
		
		try {
			System.out.println("Imvertor chain - Regression tester");
			System.out.println("");
			System.out.println(Release.getNotice());
			System.out.println("");
			
			configurator.getRunner().info(logger, "Framework version - " + Release.getVersionString("Imvertor"));
			configurator.getRunner().info(logger, "Chain version - " + Release.getVersionString("ChainRegression"));
					
			configurator.prepare(); // note that the process config is relative to the step folder path
			configurator.getRunner().prepare();
			
			DateFormat dateFormat = new SimpleDateFormat("yyyyMMdd"); // set format to 20171024
			String releaseIdentifier = dateFormat.format(new Date());
			configurator.setXParm("appinfo/release", releaseIdentifier);
				
			// parameter processing
			configurator.getCli(RegressionExtractor.STEP_NAME); // builds a single XML file for integral comparison of ref and tst.
			//configurator.getCli(RegressionComparer.STEP_NAME); // compares two XML representations.
					
			configurator.setParmsFromOptions(args);
			configurator.setParmsFromEnv();
		
		    configurator.save();
		   
		    configurator.getRunner().info(logger,"Processing " + configurator.getXParm("cli/tstfolder"));
		    
		    boolean succeeds = true;
		    		    
			// compile regression test xml
		    succeeds = succeeds && (new RegressionExtractor()).run();
		   
			// analyze this run. 
		    (new RunAnalyzer()).run();

		    configurator.windup();
			
			configurator.getRunner().windup();
			configurator.getRunner().info(logger, "Done, chain process " + (succeeds ? "succeeds" : "fails"));
		    if (configurator.getSuppressWarnings() && configurator.getRunner().hasWarnings())
		    	configurator.getRunner().info(logger, "** Warnings have been suppressed");

		} catch (Exception e) {
			configurator.getRunner().fatal(logger,"Please notify your administrator.",e,"PNYSA");
		}
	}
}
