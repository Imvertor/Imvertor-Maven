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

package nl.imvertor.EapCompiler;

import java.io.File;

import nl.imvertor.XmiCompiler.XmiCompiler;
import nl.imvertor.common.Runner;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.EapFile;
import nl.imvertor.common.file.XmlFile;

import org.apache.log4j.Logger;

/**
 * An EapCompiler creates new EAP files based on a template and data provided. 
 * 
 * @author arjan
 *
 */
public class EapCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(XmiCompiler.class);
	
	public static final String STEP_NAME = "EapCompiler";
	public static final String VC_IDENTIFIER = "$Id: EapCompiler.java 7497 2016-04-14 07:11:24Z arjan $";

	private EapFile templateFile;
	private String templateFileModelGUID;

	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
	
			// get the template file information, notably the GUID for the model in this template. 
			templateFile = new EapFile(configurator.getParm("properties","TEMPLATE_TEMPLATE_FILE"));
			templateFileModelGUID = (new AnyFile(configurator.getParm("properties","TEMPLATE_TEMPLATE_FILE_GUID"))).getContent();
			configurator.setParm("system","template-file-model-guid", templateFileModelGUID);
			
			// compile EAP from template based on current Imvertor file.
			boolean may = runner.getAppPhase() != Runner.APPLICATION_PHASE_CONCEPT;
			boolean must = runner.getAppPhase() == Runner.APPLICATION_PHASE_FINAL;
			boolean wantTemplate = configurator.isTrue("cli","createtemplate");
			boolean wantDocument = configurator.isTrue("cli","createumlreport"); // || configurator.isTrue("cli", "createderivedeap");
			boolean iseap = (new AnyFile(configurator.getParm("cli","umlfile"))).getExtension().equals("eap");
			
			// generate UML template
			if (may) 
				if (wantTemplate || must) 
					if (iseap)
						createEapTemplate();
					else 
						createXmiTemplate();
			else 
				if (wantTemplate) 
					runner.warn(logger,"Model is in phase 0 (concept), no template generated.");
			
			// generate UML report
			if (may) {
				if (wantDocument)
					if (iseap) 
						generateUmlReport();
					else
						runner.warn(logger,"An UML document can only be generated for EAP source UML files.");
			} else
				if (wantDocument) runner.warn(logger,"Model is in phase 0 (concept), no document generated.");
						
			configurator.setStepDone(STEP_NAME);
			
			// save any changes to the work configuration for report and future steps
		    configurator.save();
		    
		    report();

			return runner.succeeds();

		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}
	
	/**
	 * Create template XMI.
	 *  
	 * @param eapFile
	 * @return
	 * @throws Exception
	 */
	private void createXmiTemplate() throws Exception  {
		runner.info(logger,"Creating template XMI");
		
		// create a transformer
		Transformer transformer = new Transformer();
		transformer.transformStep("system/xmi-export-file-path","properties/RESULT_TEMPLATE_XMI_FILE", "properties/IMVERTOR_TEMPLATE_XSLPATH");
	
	}
	
	/**
	 * Create a template by importing the XMI into the EAP template file.
	 *  
	 * @param eapFile
	 * @return
	 * @throws Exception
	 */
	private EapFile createEapTemplate() throws Exception  {
	    createXmiTemplate();
		
		runner.info(logger,"Creating template EAP file");
		EapFile localCopyFile = new EapFile(configurator.getParm("properties","RESULT_TEMPLATE_EAP_FILE")); // result eap file
		// Create template file by copying the template file, and importing the XMI
		runner.debug(logger,"Importing XMI into EAP: " + localCopyFile.getName());
		templateFile.copyFile(localCopyFile);
		localCopyFile.open();
		localCopyFile.importFromXmiFile(configurator.getParm("properties","RESULT_TEMPLATE_XMI_FILE"));
		localCopyFile.close();
		
		return localCopyFile;
 
	}
	
	
	/**
	 * Generate a template for future derived applications.
	 * Copy the source file to the etc folder
	 * 
	 * @throws Exception
	 */
	public void generateUmlReport() throws Exception {
		
		EapFile eapFile = new EapFile(configurator.getParm("cli","umlfile"));
		
		runner.info(logger,"Reporting on EA UML");
		boolean succeeds = true;
		
		/**
		 * process is:
		 * 	take the original EAP.
		 * 	create an EAP copy
		 * 	export to XMI
		 * 	add info to the XMI
		 * 	import this into the copy.
		 */
		runner.debug(logger,"Enhancing EAP information");
		
		EapFile tempEapFile = new EapFile(configurator.getParm("properties", "WORK_EAP_FILE"));
		XmlFile tempXmiFile = new XmlFile(configurator.getParm("properties", "WORK_TEMP_XMI_FILE"));
		XmlFile fullXmiFile = new XmlFile(configurator.getParm("properties", "WORK_FULL_XMI_FILE"));
	
		// TODO opening EA files is time consuming; can this be enhanced?
		eapFile.open();
		try {
			eapFile.exportToXmiFile(tempXmiFile.getCanonicalPath());
			// transform XMI file
			Transformer transformer = new Transformer();
			succeeds = transformer.transformStep("properties/WORK_TEMP_XMI_FILE","properties/WORK_FULL_XMI_FILE", "properties/IMVERTOR_REPORTINGCOPY_XSLPATH");
		} finally {
			eapFile.close();
		}
		if (!succeeds)
			throw new Exception("Errors found while compiling XMI information");
		
		runner.debug(logger,"Importing enhanced information into EAP");
		templateFile.copyFile(tempEapFile);
		tempEapFile.open();
		try {
			tempEapFile.importXML(templateFileModelGUID, fullXmiFile.getCanonicalPath());
			if (configurator.isTrue("cli","createumlreport")) {
				File workDirectoryToReport = new File(configurator.getParm("system","work-uml-folder-path"),"report");
				File directoryToReport = new File(configurator.getParm("properties","RESULT_UML_FOLDER"));
				runner.debug(logger,"Generating UML report to " + directoryToReport);
				tempEapFile.exportToHtmlReport(workDirectoryToReport.getAbsolutePath(), configurator.getParm("cli","application"), "");
				configurator.setParm("system", "uml-report-available", "true");
			}
		} finally {
			tempEapFile.close();
		}
		if (configurator.isTrue("cli","createumlreport") && configurator.isTrue("cli","createderivedeap")) {
			EapFile targetFile = new EapFile(configurator.getParm("properties","RESULT_DERIVED_EAP_FILE")); 
			tempEapFile.copyFile(targetFile);
		}
	}
	
}
