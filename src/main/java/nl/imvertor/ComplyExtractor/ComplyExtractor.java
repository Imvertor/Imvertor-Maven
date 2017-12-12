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

package nl.imvertor.ComplyExtractor;

import java.io.File;
import java.net.URI;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpHeaders;
import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.HttpFile;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.ZipFile;

public class ComplyExtractor extends Step {

	protected static final Logger logger = Logger.getLogger(ComplyExtractor.class);
	
	public static final String STEP_NAME = "ComplyExtractor";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
		
		// file:/D:/projects/validprojects/Kadaster-Imvertor/Imvertor-OS-work/KING/app/xsd/bsmr0320/bsmr0320.xsd
			
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Extracting Compliancy XML");
		
		// STUB
		configurator.setParm("appinfo","release","00000001");
		
		boolean succeeds = true;
		
		// fetch the fill-in form file, and serialize it to a folder
		String templateFilepath = configurator.getParm("cli", "cmpfile", true);
		String unzipFolderpath = configurator.getParm("properties", "WORK_COMPLY_TEMPLATE_FOLDERPATH", true);

		ZipFile template = new ZipFile(templateFilepath);
		AnyFolder serializeFolder = new AnyFolder(unzipFolderpath);
		template.serializeToXml(serializeFolder);
		
		// in the exported file we find _content.xml, which is the base for all transformations and holds all XML content found.
		// transform the exported folder any way required, on the basis of _content,xml.
		// No special processing (repackaging) is required for this step.
		Transformer transformer = new Transformer();

		XmlFile contentFile = new XmlFile(serializeFolder,AnyFolder.SERIALIZED_CONTENT_XML_FILENAME);
		configurator.setParm("system", "comply-content-file", contentFile.getCanonicalPath());
		// extract the instance info from the serialized OO XML excel file 
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_EXTRACT_FILE", "properties/WORK_COMPLY_EXTRACT_XSLPATH","system/comply-content-file") : false;
		
		// copy the XSD's to the test file location
		if (succeeds) {
			// get the location of the schema and copy that complete folder from the managed output folder to the result folder
			String subpath = configurator.getParm("appinfo", "model-subpath");
			String xsdpath = configurator.getOutputFolder() + "/applications/" + subpath + "/xsd";
			String locpath = configurator.getParm("appinfo", "schema-subpath");
		
			AnyFile xsdFile = new AnyFile(configurator.getOutputFolder() + "/applications/" + subpath + "/xsd/" + locpath);
			AnyFolder sourceXsdFolder = new AnyFolder(xsdpath);
			
			if (sourceXsdFolder.isDirectory() && xsdFile.isFile()) {
				// copy this xsd folder to the result folder
				AnyFolder targetXsdFolder = new AnyFolder(configurator.getWorkFolder("app/xsd"));
				sourceXsdFolder.copy(targetXsdFolder);		
			} else { 
				runner.error(logger, "No such model XSD folder: " + subpath);
				succeeds = false;
			}
		}
		
		// build a scenario file
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_SCENARIO_FILE", "properties/WORK_COMPLY_SCENARIO_XSLPATH") : false;

		AnyFile targetXmlFile = new AnyFile(configurator.getWorkFolder("app/tests"),"stp-config.xml");
		AnyFile scenario = new AnyFile(configurator.getParm("properties","WORK_COMPLY_SCENARIO_FILE"));
		scenario.copyFile(targetXmlFile);		

		// build the XML instances
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_BUILD_FILE", "properties/WORK_COMPLY_BUILD_XSLPATH","system/comply-content-file") : false;
		
		// now first generate the test files
		transformer.setXslParm("generation-mode", "final");
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_MAKE_FILE_FINAL", "properties/WORK_COMPLY_MAKE_XSLPATH") : false;
		
		// then do the same, but insert variables in order to test the validity of the tests
		transformer.setXslParm("generation-mode", "valid");
		succeeds = succeeds ? transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_MAKE_FILE_VALID", "properties/WORK_COMPLY_MAKE_XSLPATH") : false;

		//validate the generate XML instances against the schema.
		AnyFolder folder = new AnyFolder(configurator.getParm("properties","WORK_COMPLY_MAKE_FOLDER_VALID"));
		if (folder.exists()) {
				succeeds = succeeds ? validateAndReport(folder) : false;
		} else {
			succeeds = false;
			runner.error(logger,"No instances created.");
		}

		// finally set some release info
		configurator.setParm("appinfo","compliancy-filename",template.getNameNoExtension());
		configurator.setParm("appinfo","generation-id",configurator.getParm("system","generation-id"));
		
		// system/resolved-release-name
		String releasename = configurator.mergeParms(configurator.getParm("cli","releasename"));
		configurator.setParm("appinfo","release-name",StringUtils.replacePattern(releasename, "[^A-Za-z0-9_\\-.]", ""),true);
		
		// we now know the application name and should show it. 
		runner.info(logger, "Compiled name: " + configurator.getParm("appinfo","release-name"));
		
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
		    
		return runner.succeeds();
		
	}
	
	/** 
	 * Process the test instance validation results into reportable messages.
	 * 
	 * @param folder
	 * @return
	 * @throws Exception 
	 */
	public boolean validateAndReport(AnyFolder folder) throws Exception {
		Vector<String> vl = validateXmlFolder(folder);
		if (vl.size() != 0) 
			runner.error(logger, vl.size() + " exceptions found in generated test instances.");
		Iterator<String> it = vl.iterator();
		while (it.hasNext()) {
			String m = it.next();
			runner.msg("COMPLY",m);
		}
		configurator.setParm("appinfo","compliancy-error-count", vl.size());
		return (vl.size() == 0) ? true : false;
	}
	
	/**
	 * Validate each file in the folder.
	 * Assume the file holds a reference to the schema (xsi:schemLocation)
	 * 
	 * @param folder
	 * @return
	 * @throws Exception 
	 */
	public Vector<String> validateXmlFolder(AnyFolder folder) throws Exception {
		
		URI stpUrl = URI.create(configurator.getParm("cli","complySTPurl"));
		
		File[] filesAndDirs = folder.listFiles();
		List<File> filesDirs = Arrays.asList(filesAndDirs);
		Vector<String> vl = new Vector<String>();
		for (File file : filesDirs) {
			if (file.isDirectory()) {
				vl.addAll(validateXmlFolder(new AnyFolder(file)));
			} else if (file.getName().endsWith(".xml")) {
				XmlFile xmlFile = new XmlFile(file);
				Vector<String> v = null;
				Boolean succeeds = true;
				runner.track("Validating " + xmlFile.getName());
				if (configurator.isTrue("cli","complyValidateXML")) {
					succeeds = xmlFile.isValid();
					v = xmlFile.getMessages();
					vl.addAll(v);
				} 
				if (succeeds && configurator.isTrue("cli","complyValidateSTP")) {
					// for each instance, pass to SOAP server STP.
					String[] messages = postToSTP(stpUrl,xmlFile);
					v = new Vector<String>(Arrays.asList(messages));
					vl.addAll(v);
				}
			}
		}
		return vl;
	}

	public String[] postToSTP(URI url, XmlFile xmlInstance) throws Exception {
		
		HttpFile httpFile = new HttpFile("unknown");
		
		HashMap<String,String> headerMap = new HashMap<String,String>();
		headerMap.put(HttpHeaders.ACCEPT, "text/xml");
		headerMap.put(HttpHeaders.CONTENT_TYPE, "text/xml");
		headerMap.put(HttpHeaders.CONTENT_ENCODING, "UTF-8");
	
		// transform to soap wrapper
		Transformer transformer = new Transformer();
		transformer.setXslParm("xmlfile-name", xmlInstance.getName());
		boolean succeeds = true;
		
		// creates an XML modeldoc intermediate file which is the basis for output
		configurator.setParm("system","comply-input-file",xmlInstance.getCanonicalPath());
		succeeds = succeeds ? transformer.transformStep("system/comply-input-file", "properties/IMVERTOR_COMPLY_EXTRACT_SOAP_REQUEST_FILE", "properties/IMVERTOR_COMPLY_EXTRACT_SOAP_REQUEST_XSLPATH") : false;

		// pass the contents as body to STP
		XmlFile soapRequestXml = new XmlFile(configurator.getParm("properties", "IMVERTOR_COMPLY_EXTRACT_SOAP_REQUEST_FILE"));
		String result = httpFile.post(HttpFile.METHOD_POST_CONTENT, url, headerMap, null, soapRequestXml.getContent("UTF-8"));
		
		// transform to messages
		XmlFile soapResponseXml = new XmlFile(configurator.getParm("properties", "IMVERTOR_COMPLY_EXTRACT_SOAP_RESPONSE_FILE"));
		soapResponseXml.setContent(result);
		succeeds = succeeds ? transformer.transformStep("properties/IMVERTOR_COMPLY_EXTRACT_SOAP_RESPONSE_FILE", "properties/IMVERTOR_COMPLY_EXTRACT_SOAP_FLAT_FILE", "properties/IMVERTOR_COMPLY_EXTRACT_SOAP_RESPONSE_XSLPATH") : false;
		
		AnyFile messagesFile = new AnyFile(configurator.getParm("properties", "IMVERTOR_COMPLY_EXTRACT_SOAP_FLAT_FILE"));
		
		return StringUtils.splitByWholeSeparator(messagesFile.getContent(),"[nl]");
	}
	
}
