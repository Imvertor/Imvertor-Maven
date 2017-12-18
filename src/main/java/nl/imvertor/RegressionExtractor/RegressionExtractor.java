/*
 * Copyright (C) 2016 VNG/KING
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

package nl.imvertor.RegressionExtractor;

import java.io.File;

import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.xsl.extensions.ImvertorCompareXML;

public class RegressionExtractor  extends Step {

	protected static final Logger logger = Logger.getLogger(RegressionExtractor.class);
	
	public static final String STEP_NAME = "RegressionExtractor";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
			
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Compiling Regression file");
		
		String url = (new File(configurator.getXParm("properties/COMPARE_GENERATED_XSLPATH"))).toURI().toURL().toString();
		configurator.addCatalogMap(
				"http://www.imvertor.org/imvertor/1.0/xslt/compare/compare-generated.xsl", 
				url);
		
		//1 serialize the tst folder
		AnyFolder reffolder = new AnyFolder(configurator.getXParm("cli/reffolder"));
		AnyFolder tstfolder = new AnyFolder(configurator.getXParm("cli/tstfolder"));
		AnyFolder outfolder = new AnyFolder(configurator.getXParm("cli/outfolder"));
		String identifier = configurator.getXParm("cli/identifier");
		
		XslFile xslFilterFile = new XslFile(configurator.getXslPath(configurator.getXParm("properties/REGRESSION_EXTRACT_XSLPATH")));
		
		runner.debug(logger,"CHAIN","Serializing test folder: " + tstfolder);
		tstfolder.serializeToXml(xslFilterFile,"test");
		
		//2 serialize the ref folder
		// determine the __content.xml locations in tst and ref
		XmlFile tstContentXML = new XmlFile(tstfolder,AnyFolder.SERIALIZED_CONTENT_XML_FILENAME);
		XmlFile refContentXML = new XmlFile(reffolder,AnyFolder.SERIALIZED_CONTENT_XML_FILENAME);
		XmlFile compareXML    = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_DIFF_FILE"));
		
		// normally the reference folder already holds the __content.xml file, but if not, recreate it here
		// when developing, always replace.
		if (!refContentXML.isFile() || configurator.getRunMode() == Configurator.RUN_MODE_DEVELOPMENT || configurator.isTrue("cli","rebuildref")) {
			runner.debug(logger,"CHAIN","Serializing reference folder; " + reffolder);
			reffolder.serializeToXml(xslFilterFile,"ctrl");
		}
		
		// now compare the two __content.xml files.
		
		XslFile tempXsl = new XslFile(configurator.getXParm("properties/COMPARE_GENERATED_XSLPATH")); // ...Imvertor-OS-work\default\compare\generated.xsl
		XslFile compareXsl = new XslFile(configurator.getXParm("properties/COMPARE_GENERATOR_XSLPATH")); // ...RegressionExtractor\compare\xsl\compare.generator.xsl
		XmlFile listingXml = new XmlFile(configurator.getXParm("properties/WORK_COMPARE_LISTING_FILE")); // ...Imvertor-OS-work\default\imvert\compare.2.listing.xml
		
		Boolean valid = true;
		
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorCompareXML());
		
		transformer.setXslParm("ctrl-filepath", refContentXML.getCanonicalPath());
		transformer.setXslParm("test-filepath", tstContentXML.getCanonicalPath());
		transformer.setXslParm("diff-filepath", compareXML.getCanonicalPath());
		transformer.setXslParm("max-difference-reported", configurator.getXParm("cli/maxreport"));
		
		//3 create includable stylesheet generated.xsl
		valid = valid && transformer.transform(refContentXML, tempXsl, compareXsl,null);
		
		//4 create listing, while including the generated.xsl
		XslFile listingXsl = new XslFile(configurator.getXParm("properties/IMVERTOR_COMPARE_LISTING_XSLPATH"));
		valid = valid && transformer.transform(refContentXML,listingXml,listingXsl,null);
		
		// copy the listing to the outfolder. 
		// This is picked up by the xslweb regression framework
		
		AnyFile outfile = new AnyFile(outfolder,identifier + ".report.xml");
		listingXml.copyFile(outfile);
		
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
		    
		return runner.succeeds();
		
	}
}
