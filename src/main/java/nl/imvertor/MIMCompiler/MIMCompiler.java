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

package nl.imvertor.MIMCompiler;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;

/**
 * The MIM compiler takes the imvertor embellish file and transforms it to a MIM compiler format file.
 * 
 * @author maarten
 *
 */
public class MIMCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(MIMCompiler.class);
	
	public static final String STEP_NAME = "MIMCompiler";
	public static final String VC_IDENTIFIER = "$Id: $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling MIM format");
		
		boolean succeeds = true;
		
		succeeds = succeeds && generateDefault();
		
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate MIM format based on imvertor format
	 * 
	 * @throws Exception
	 */
	public boolean generateDefault() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean succeeds = true;
		
		runner.debug(logger,"CHAIN","Generating MIM format");
		
		// Transform Imvertor info to MIM format
		if (configurator.getXParm("properties/WORK_EMBELLISH_FILE", false) != null) {
			String mimFormatType = configurator.getXParm("cli/mimformattype", false);
			if (mimFormatType == null) {
				mimFormatType = "xml";
			} else {
				mimFormatType = configurator.mergeParms(mimFormatType);	
			}
			boolean isRDFType = StringUtils.equalsAny(mimFormatType, "rdf");
			
			String xslFileParam;
			switch (mimFormatType) {
			case "legacy": 
				xslFileParam = "properties/IMVERTOR_MIMFORMAT_LEGACY_XSLPATH";
				break;
			default:
				xslFileParam = "properties/IMVERTOR_MIMFORMAT_XSLPATH";
				break;
			}
			
			
			if (isRDFType) {
				transformer.setXslParm("generate-readable-ids", "false");
				transformer.setXslParm("generate-all-ids", "true");
			}
			
			succeeds = succeeds && transformer.transformStep("properties/WORK_EMBELLISH_FILE", "properties/WORK_MIMFORMAT_XMLPATH", xslFileParam); //TODO must relocate generation of WORK_LISTS_FILE to a EMBELLISH step.
			
			/*
			// Debug: test if xml is okay
			succeeds = succeeds && xmlFile.isValid(); // TODO: add when XML schema is available and schemaLocation is set
			*/
			
			if (isRDFType) {
				succeeds = succeeds && transformer.transformStep("properties/WORK_MIMFORMAT_XMLPATH", "properties/WORK_MIMFORMAT_RDFPATH", "properties/IMVERTOR_MIMFORMAT_RDF_XSLPATH");
			}
			
			// store to mim folder
			if (succeeds) {
				XmlFile resultMimFile = new XmlFile(configurator.getXParm("properties/WORK_MIMFORMAT_XMLPATH"));
				
				// copy to the app folder
				String mimFormatName = configurator.mergeParms(configurator.getXParm("cli/mimformatname"));
				// Create the folder; it is not expected to exist yet.
				AnyFolder xmlFolder = new AnyFolder(configurator.getXParm("system/work-mim-folder-path"));
				AnyFile appXmlFile = new AnyFile(xmlFolder, mimFormatName + ".xml");
				xmlFolder.mkdirs();
				resultMimFile.copyFile(appXmlFile);
				
				if (!mimFormatType.equals("legacy")) {
					/* Copy the MIM XML Schema directory: */
					File xslDir = new File(configurator.getXslPath(configurator.getParm("properties", "IMVERTOR_MIMFORMAT_XSLPATH"))).getParentFile();
					File xsdSourceFolder = new File(xslDir, "../../etc/xsd/MIMformat");
					File xsdTargetFolder = new File(xmlFolder, "xsd");
					FileUtils.copyDirectory(xsdSourceFolder, xsdTargetFolder);
				}
				
				if (isRDFType) {
					XmlFile resultRDFFile = new XmlFile(configurator.getXParm("properties/WORK_MIMFORMAT_RDFPATH"));
					AnyFile appRDFFile = new AnyFile(xmlFolder, mimFormatName + ".rdf");
					resultRDFFile.copyFile(appRDFFile);
				}
				
			}
			
		} else {
			runner.error(logger, "MIM format cannot be compiled.");
			succeeds = false;
		}
		configurator.setXParm("system/mim-compiler-format-created", succeeds);	
		return succeeds;
		
	}
	
}
