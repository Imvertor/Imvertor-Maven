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

package nl.imvertor.XsdCompiler;

import javax.xml.xpath.XPathConstants;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.NodeList;

import nl.imvertor.XsdCompiler.xsl.extensions.ImvertorGetVariable;
import nl.imvertor.XsdCompiler.xsl.extensions.ImvertorSetVariable;
import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.exceptions.EnvironmentException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.xsl.extensions.ImvertorExcelSerializer;
import nl.imvertor.common.xsl.extensions.ImvertorStripAccents;
import nl.imvertor.common.xsl.extensions.ImvertorZipDeserializer;
import nl.imvertor.common.xsl.extensions.ImvertorZipSerializer;

public class XsdCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(XsdCompiler.class);
	
	public static final String STEP_NAME = "XsdCompiler";
	public static final String VC_IDENTIFIER = "$Id: XsdCompiler.java 7509 2016-04-25 13:30:29Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		runner.info(logger,"Compiling XML schemas");
		
		String schemarules = configurator.getSchemarules();
		if (schemarules.equals("Kadaster")) {
			generateXsdKadaster();
			supplyExternalSchemas();
		} else if (schemarules.equals("BRO")) {
			generateXsdBRO();
			supplyExternalSchemas();
		} else if (schemarules.equals("KINGUGM") || schemarules.equals("RWS-L")) {
			generateUgmXsdKING();
		} else if (schemarules.equals("KINGBSM") || schemarules.equals("RWS-B")) {
			generateBsmXsdKING();
		} else if (schemarules.equals("ISO19136")) {
			generateXsdISO19136();
			supplyExternalSchemas();
		} else if (schemarules.equals("RWS")) {
			generateXsdISO19136();
			supplyExternalSchemas();
		} else if (schemarules.equals("KadasterNEN3610")) {
			generateXsdISO19136();
			supplyExternalSchemas();
		} else if (schemarules.equals("KOOP")) {
			generateXsdISO19136();
			supplyExternalSchemas();
		} else
			runner.error(logger,"Schemarules not implemented: " + schemarules);
		
		// note: schema validation is a separate step
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
	    
	    return runner.succeeds();
	}

	/**
	 * Generate Kadaster XSD from the compiled Imvert files.
	 * 
	 * @throws Exception
	 */
	public boolean generateXsdKadaster() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorGetVariable());
		transformer.setExtensionFunction(new ImvertorSetVariable());
						
		boolean valid = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder xsdFolder = new AnyFolder(configurator.getXParm("system/work-xsd-folder-path"));
		xsdFolder.mkdirs();
				
		AnyFolder xsdApplicationFolder = new AnyFolder(configurator.mergeParms(configurator.getXParm("properties/RESULT_XSD_APPLICATION_FOLDER")));
		xsdApplicationFolder.mkdirs();
		configurator.setXParm("system/xsd-application-folder-path", xsdApplicationFolder.getCanonicalPath());
	
		runner.debug(logger,"CHAIN","Generating XML schemas to " + xsdApplicationFolder);
		
		valid = valid && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_XSD_PREFORM_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_Kadaster_XSD_PREFORM_XSLPATH","system/cur-imvertor-filepath");
		
		String n = configurator.getXParm("cli/STUBnilreason",false);
		if (n != null && n.equals("1.28"))
			valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_Kadaster_XSD_1.28_XSLPATH","system/cur-imvertor-filepath");
		else
			valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_Kadaster_XSD_XSLPATH","system/cur-imvertor-filepath");
		
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_POSTFORM_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_Kadaster_XSD_POSTFORM_XSLPATH","system/cur-imvertor-filepath");
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_IMPORT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_Kadaster_XSD_IMPORT_XSLPATH","system/cur-imvertor-filepath");
		
		// for each model named to flatten, process
		if (configurator.isTrue("cli","flattenschemas")) {
			valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/WORK_FLATTEN_FILE","properties/IMVERTOR_FLATTEN_XSLPATH","system/cur-imvertor-filepath");
		}
		
		configurator.setXParm("system/schema-created","true");
		
		return valid;
	}
	/**
	 * Generate BRO XSD from the compiled Imvert files.
	 * 
	 * @throws Exception
	 */
	public boolean generateXsdBRO() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorGetVariable());
		transformer.setExtensionFunction(new ImvertorSetVariable());
						
		boolean valid = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder xsdFolder = new AnyFolder(configurator.getXParm("system/work-xsd-folder-path"));
		xsdFolder.mkdirs();
				
		AnyFolder xsdApplicationFolder = new AnyFolder(configurator.getXParm("properties/RESULT_XSD_APPLICATION_FOLDER"));
		xsdApplicationFolder.mkdirs();
		configurator.setXParm("system/xsd-application-folder-path", configurator.mergeParms(xsdApplicationFolder.getCanonicalPath()));
		
		runner.debug(logger,"CHAIN","Generating XML schemas to " + xsdApplicationFolder);
		
		valid = valid && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_XSD_PREFORM_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KKG_XSD_PREFORM_XSLPATH","system/cur-imvertor-filepath");
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KKG_XSD_XSLPATH","system/cur-imvertor-filepath");
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_POSTFORM_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KKG_XSD_POSTFORM_XSLPATH","system/cur-imvertor-filepath");
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_IMPORT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KKG_XSD_IMPORT_XSLPATH","system/cur-imvertor-filepath");
		
		configurator.setXParm("system/schema-created","true");
		
		return valid;
	}
	/**
	 * Generate ISO 19136 XSD from the compiled Imvert files.
	 * 
	 * @throws Exception
	 */
	public boolean generateXsdISO19136() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
						
		boolean valid = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder xsdFolder = new AnyFolder(configurator.getXParm("system/work-xsd-folder-path"));
		xsdFolder.mkdirs();
				
		AnyFolder xsdApplicationFolder = new AnyFolder(configurator.mergeParms(configurator.getXParm("properties/RESULT_XSD_APPLICATION_FOLDER")));
		xsdApplicationFolder.mkdirs();
		configurator.setXParm("system/xsd-application-folder-path", xsdApplicationFolder.getCanonicalPath());
		
		
		runner.debug(logger,"CHAIN","Generating XML schemas to " + xsdApplicationFolder);
		
		valid = valid && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_XSD_PREFORM_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_ISO19136_XSD_PREFORM_XSLPATH","system/cur-imvertor-filepath");
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_ISO19136_XSD_XSLPATH","system/cur-imvertor-filepath");
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_POSTFORM_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_ISO19136_XSD_POSTFORM_XSLPATH","system/cur-imvertor-filepath");
		valid = valid && transformer.transformStep("system/cur-imvertor-filepath","properties/RESULT_XSD_IMPORT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_ISO19136_XSD_IMPORT_XSLPATH","system/cur-imvertor-filepath");
		
		configurator.setXParm("system/schema-created","true");
		
		return valid;
	}
	/**
	 * Generate KING BSM XSD from the compiled Imvert files.
	 * 
	 * @throws Exception
	 */
	public boolean generateBsmXsdKING() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorZipSerializer());
		transformer.setExtensionFunction(new ImvertorZipDeserializer());
		transformer.setExtensionFunction(new ImvertorExcelSerializer());
		// requires accent stripper
		transformer.setExtensionFunction(new ImvertorStripAccents());
						
		boolean valid = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder xsdFolder = new AnyFolder(configurator.getXParm("system/work-xsd-folder-path"));
		xsdFolder.mkdirs();
				
		AnyFolder xsdApplicationFolder = new AnyFolder(configurator.getXParm("properties/RESULT_XSD_APPLICATION_FOLDER"));
		xsdApplicationFolder.mkdirs();
		configurator.setXParm("system/xsd-application-folder-path", configurator.mergeParms(xsdApplicationFolder.getCanonicalPath()));
		
		runner.debug(logger,"CHAIN","Generating BSM XML schemas to " + xsdApplicationFolder);
		
		String infoXsdSourceFilePath = configurator.getXParm("properties/IMVERTOR_METAMODEL_KINGBSM_XSDSOURCE"); // system or model

		// when system, use the embellish file; when model use the model.
		if (infoXsdSourceFilePath.equals("system")) {
			
			// Migrate between models. This is a stub stylesHeet, which transforms any metamodel to the StUF defined & required metamodel
			valid = valid && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_METAMODEL_KINGBSM_XSD_MIGRATE", "properties/IMVERTOR_METAMODEL_KINGBSM_XSD_MIGRATE_XSLPATH","system/work-config-path");
			
			valid = valid && transformer.transformStep("system/work-config-path","properties/ROUGH_OPENAPI_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_ROUGH_OPENAPI_ENDPRODUCT_XML_XSLPATH");
			valid = valid && transformer.transformStep("properties/ROUGH_OPENAPI_ENDPRODUCT_XML_FILE_PATH","properties/RESULT_OPENAPI_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_OPENAPI_ENDPRODUCT_XML_XSLPATH");
		
			valid = valid && transformer.transformStep("system/work-config-path","properties/ROUGH_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_ROUGH_ENDPRODUCT_XML_XSLPATH");
			valid = valid && transformer.transformStep("properties/ROUGH_ENDPRODUCT_XML_FILE_PATH","properties/ENRICHED_ROUGH_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_ENRICHED_ROUGH_ENDPRODUCT_XML_XSLPATH");
			valid = valid && transformer.transformStep("properties/RESULT_METAMODEL_KINGBSM_XSD_MIGRATE","properties/RESULT_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_ENDPRODUCT_XML_XSLPATH");
			valid = valid && transformer.transformStep("properties/RESULT_ENDPRODUCT_XML_FILE_PATH","properties/RESULT_REPROCESSED_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_REPROCESS_ENDPRODUCT_XML_XSLPATH");
			valid = valid && transformer.transformStep("properties/RESULT_REPROCESSED_ENDPRODUCT_XML_FILE_PATH","properties/RESULT_SORTED_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_SORT_ENDPRODUCT_XML_XSLPATH");
			valid = valid && transformer.transformStep("properties/RESULT_SORTED_ENDPRODUCT_XML_FILE_PATH","properties/RESULT_CLEANED_ENDPRODUCT_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_CLEAN_ENDPRODUCT_XML_XSLPATH");
			valid = valid && transformer.transformStep("properties/RESULT_CLEANED_ENDPRODUCT_XML_FILE_PATH","properties/RESULT_ENDPRODUCT_XSD_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_ENDPRODUCT_XSD_XSLPATH");
		
			if (valid) {
				// and copy the onderlaag; this is a copy of all stuff in that folder
				AnyFolder onderlaag = new AnyFolder(configurator.getXParm("properties/KINGBSM_STUF_ONDERLAAG_0302"));
				onderlaag.copy(configurator.getXParm("system/work-xsd-folder-path"));
			}
			
			// and create a table representation; 
			valid = valid && transformer.transformStep("properties/RESULT_CLEANED_ENDPRODUCT_XML_FILE_PATH","properties/ENDPRODUCT_DOC_TABLES_FILE_PATH", "properties/IMVERTOR_ENDPRODUCT_DOC_TABLES_XSLPATH");
			
			if (valid) {
				// simply copy the table html file
				String fn = "office.tables.html";
				AnyFile infoOfficeTableFile = new AnyFile(configurator.getXParm("properties/ENDPRODUCT_DOC_TABLES_FILE_PATH"));
				AnyFile officeTableFile = new AnyFile(configurator.getXParm("system/work-etc-folder-path") + "/" + fn);
				infoOfficeTableFile.copyFile(officeTableFile);
				configurator.setXParm("appinfo/office-table-documentation-filename", fn);
			}
			
		} else // model
			valid = valid && transformer.transformStep("properties/WORK_SCHEMA_FILE","properties/RESULT_XSD_XML_FILE_PATH", "properties/IMVERTOR_METAMODEL_KINGBSM_XSD_XSLPATH");
		
		// fetch all checksum info from parms file and store to the local blackboard.
		valid = valid && transformer.transformStep("system/work-config-path","properties/IMVERTOR_BLACKBOARD_CHECKSUM_SIMPLETYPES_XMLPATH_LOCAL", "properties/IMVERTOR_BLACKBOARD_CHECKSUM_SIMPLETYPES_XSLPATH");
		
		// record the location of the resulting EP file for subsequent steps
		configurator.setXParm("system/imvertor-ep-result",configurator.getXParm("properties/RESULT_CLEANED_ENDPRODUCT_XML_FILE_PATH"));
		// and tell that a schema has been created
		configurator.setXParm("system/schema-created","true");
		
		return valid;
	}
	
	/**
	 * Generate KING UGM XSD (basis entiteiten) from the compiled Imvert files.
	 * 
	 * @throws Exception
	 */
	public boolean generateUgmXsdKING() throws Exception {
		
		// create a transformer
		Transformer transformer = new Transformer();
		// requires accent stripper
		transformer.setExtensionFunction(new ImvertorStripAccents());
						
		boolean valid = true;
		
		// Create the folder; it is not expected to exist yet.
		AnyFolder xsdTempFolder = new AnyFolder(configurator.getXParm("system/work-xsd-folder-path"));
		xsdTempFolder.mkdirs();
	
		// Migrate between models. This is a stub stylesheet, which transforms any metamodel to the StUF defined & required metamodel
		valid = valid && transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/RESULT_METAMODEL_KINGUGM_XSD_MIGRATE", "properties/IMVERTOR_METAMODEL_KINGUGM_XSD_MIGRATE_XSLPATH","system/work-config-path");
		
		//TODO let the stylesheet operate on system, not on model file. Try to determine if model file is required altogether.
		valid = valid && transformer.transformStep("system/work-config-path","properties/RESULT_METAMODEL_KINGUGM_XSD_PREFORM", "properties/IMVERTOR_METAMODEL_KINGUGM_XSD_PREFORM_XSLPATH","system/work-config-path");
		valid = valid && transformer.transformStep("system/work-config-path","properties/RESULT_METAMODEL_KINGUGM_XSD_MAIN", "properties/IMVERTOR_METAMODEL_KINGUGM_XSD_MAIN_XSLPATH","system/work-config-path");
		valid = valid && transformer.transformStep("system/work-config-path","properties/RESULT_METAMODEL_KINGUGM_XSD_SUBSET", "properties/IMVERTOR_METAMODEL_KINGUGM_XSD_SUBSET_XSLPATH","system/work-config-path");
		valid = valid && transformer.transformStep("system/work-config-path","properties/RESULT_METAMODEL_KINGUGM_XSD_CLEANUP", "properties/IMVERTOR_METAMODEL_KINGUGM_XSD_CLEANUP_XSLPATH","system/work-config-path");
		
		// now all is ready to generate the actual schemas
		AnyFolder xsdApplicationFolder = new AnyFolder(configurator.mergeParms(configurator.getXParm("properties/RESULT_XSD_APPLICATION_FOLDER")));
		configurator.setXParm("system/xsd-application-folder-path", configurator.mergeParms(xsdApplicationFolder.getCanonicalPath()));

		runner.debug(logger,"CHAIN","Generating UGM XML schemas to " + xsdApplicationFolder);
		
		valid = valid && transformer.transformStep("system/work-config-path","properties/RESULT_METAMODEL_KINGUGM_XSD_ENTDAT", "properties/IMVERTOR_METAMODEL_KINGUGM_XSD_ENTDAT_XSLPATH","system/work-config-path");
		
		// fetch all checksum info from parms file and store to the local blackboard.
		valid = valid && transformer.transformStep("system/work-config-path","properties/IMVERTOR_BLACKBOARD_CHECKSUM_SIMPLETYPES_XMLPATH_LOCAL", "properties/IMVERTOR_BLACKBOARD_CHECKSUM_SIMPLETYPES_XSLPATH");
		
		if (valid) {
			// pretty print the schema's just generated
			AnyFolder xsdFolder = new AnyFolder(configurator.getXParm("system/work-xsd-folder-path") + ".cleaned");
			prettyPrintXml(xsdTempFolder, xsdFolder);
			xsdTempFolder.deleteDirectory();
			xsdFolder.renameTo(xsdTempFolder); // now "xsd""
			
			// copy the onderlaag; this is a copy of all stuff in that folder
			AnyFolder onderlaag = new AnyFolder(configurator.getXParm("properties/KINGUGM_STUF_ONDERLAAG_0302"));
			onderlaag.copy(configurator.getXParm("system/work-xsd-folder-path"));
			
			// copy all schema's compiled for the supplier UGMs. 
			// This may be 0 or more.
			// These never replace the schema's just compiled.
			if (configurator.isTrue("appinfo", "xsd-is-subset")) {
				String[] projectNames = StringUtils.split(configurator.getXParm("appinfo/subset-supplier-project"),';');
				String[] modelNames = StringUtils.split(configurator.getXParm("appinfo/subset-supplier-name"),';');
				String[] releaseNumbers = StringUtils.split(configurator.getXParm("appinfo/subset-supplier-release"),';');
				for (int i = 0; i < projectNames.length; i++) {
					AnyFolder supplier = new AnyFolder(configurator.getApplicationFolder(projectNames[i],modelNames[i],releaseNumbers[i]) + "/xsd"); 
					supplier.copy(configurator.getXParm("system/work-xsd-folder-path"),false);
				}
			}
			// tell that a schema has been created
			configurator.setXParm("system/schema-created","true");
		} else {
			configurator.setXParm("system/schema-created","false");
			}
		return valid;
	}
	
	/**
	 * Supply the schema's referenced as external by the application. 
	 * These are copied from the project's xsd folder to the applications xsd folder. 
	 * 
	 * @throws Exception 
	 */
	private void supplyExternalSchemas() throws Exception {
		XmlFile infoEmbellishFile = new XmlFile(configurator.getXParm("properties/WORK_EMBELLISH_FILE"));
		NodeList nodes = (NodeList) infoEmbellishFile.xpathToObject("//*:local-schema", null, XPathConstants.NODESET);
		for (int i = 0; i < nodes.getLength(); i++) {
			String filepath = nodes.item(i).getTextContent();
			AnyFolder xsdFolder = new AnyFolder(configurator.getXParm("properties/EXTERNAL_XSD_FOLDER") + "/" + filepath);
			AnyFolder targetXsdFolder = new AnyFolder(configurator.getXParm("system/work-xsd-folder-path"));
			if (xsdFolder.isDirectory()) {
				runner.debug(logger,"CHAIN","Appending external schema from: " + xsdFolder);
				transformSchemas(xsdFolder, targetXsdFolder);
			} else 
				throw new EnvironmentException("Cannot find external XSD folder for schema to append: " + xsdFolder);
		}
	}
	
	/*
	 * Copy the contents of a folder by transforming all xsd files.
	 * Copies the contents of this folder to the xsd folder of the application just created.
	 * The application has its own folder within the xsd folder.
	 */
	private void transformSchemas(AnyFolder xsdFolder, AnyFolder targetXsdFolder) throws Exception {
		String xsdFolderSubpath = xsdFolder.getParentFile().getName() + "/" + xsdFolder.getName();
		String xslFilename = configurator.getXParm("properties/LOCALIZE_XSD_XSLPATH");
		// this is within the step XSL folder; get the full path here.
		XslFile xslFile = new XslFile(configurator.getXslPath(xslFilename));
		Transformer transformer = new Transformer();
		transformer.setXslParm("local-schema-folder-name",xsdFolderSubpath);
		transformer.setXslParm("local-schema-mapping-file", (new AnyFile(configurator.getXParm("properties/LOCAL_SCHEMA_MAPPING_FILE"))).toURI().toString());
		transformer.transformFolder(xsdFolder, targetXsdFolder, ".*\\.xsd", xslFile);
	}
	
	/*
	 * Clean all XSD's, reformatting them as a neat tree
	 */
	private void prettyPrintXml(AnyFolder xsdFolder, AnyFolder targetXsdFolder) throws Exception {
		XslFile prettyPrinter = new XslFile(configurator.getBaseFolder(),"xsl/common/tools/PrettyPrinter.xsl");
		Transformer transformer = new Transformer();
		transformer.setXslParm("xml-mixed","false");
		transformer.transformFolder(xsdFolder, targetXsdFolder, ".*\\.xsd", prettyPrinter);
	}
	
	
}
