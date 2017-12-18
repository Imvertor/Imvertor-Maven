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

package nl.imvertor.ComplyCompiler;

import java.util.Iterator;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.file.ZipFile;
import nl.imvertor.common.xsl.extensions.counting.AddNamedCount;
import nl.imvertor.common.xsl.extensions.counting.GetNamedCount;
import nl.imvertor.common.xsl.extensions.counting.SetNamedCount;

public class ComplyCompiler  extends Step {

	protected static final Logger logger = Logger.getLogger(ComplyCompiler.class);
	
	public static final String STEP_NAME = "ComplyCompiler";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
		
		/*
		 Boolean develop = false; // TODO remove temporary
		*/
		
		if (configurator.getXParm("system/imvertor-ep-result",false) == null)
			runner.warn(logger, "Creation of Excel requires an EP file");
		else {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			runner.info(logger,"Compiling Compliancy Excel");
			
			// fetch the template file, and serialize it to a folder
			String templateFilepath = configurator.getXParm("properties/IMVERTOR_COMPLY_TEMPLATE_EXCELPATH", true);
			String unzipFolderpath = configurator.getXParm("properties/WORK_COMPLY_TEMPLATE_FOLDERPATH", true);

			ZipFile template = new ZipFile(templateFilepath);
			AnyFolder serializeFolder = new AnyFolder(unzipFolderpath);
			template.serializeToXml(serializeFolder);
			
			// in the exported file we find _content.xml, which is the base for all transformations and holds all XML content found.
			// transform the exported folder any way required, on the basis of _content,xml.
			// When done, the results will be compressed back, except for the _content,xml.
			Transformer transformer = new Transformer();
			
			transformer.setExtensionFunction(new GetNamedCount());
			transformer.setExtensionFunction(new SetNamedCount());
			transformer.setExtensionFunction(new AddNamedCount());
			
			XmlFile contentFile = new XmlFile(serializeFolder,AnyFolder.SERIALIZED_CONTENT_XML_FILENAME);
			
			/*
			// TODO REMOVE debug; remove next lines
			XslFile prettyPrinter = new XslFile(configurator.getBaseFolder(),"xsl/common/tools/PrettyPrinter.xsl");
			if (develop) {
				prettyPrinter.transform(contentFile.getCanonicalPath(), "c:/Temp/comply/__content.template.xml");
			 
				ZipFile templateOkay = new ZipFile("c:/Temp/comply/Testberichten gevuld.xlsx");
				if (templateOkay.isFile()) {
					AnyFolder serializeFolderOkay = new AnyFolder(unzipFolderpath);
					templateOkay.serializeToXml(serializeFolder);
					prettyPrinter.transform(contentFile.getCanonicalPath(), "c:/temp/comply/before.xml");
					serializeFolderOkay.delete();
				} else 
					develop = false;
			}
			*/
			
			configurator.setXParm("system/comply-content-file", contentFile.getCanonicalPath());
			transformer.transformStep("system/imvertor-ep-result","properties/WORK_COMPLY_STUB_FILE", "properties/WORK_COMPLY_STUB_XSLPATH","system/imvertor-ep-result");
			transformer.transformStep("system/imvertor-ep-result","properties/WORK_COMPLY_FLAT_FILE", "properties/WORK_COMPLY_FLAT_XSLPATH","system/imvertor-ep-result");
			transformer.transformStep("system/comply-content-file","properties/WORK_COMPLY_FILL_FILE", "properties/WORK_COMPLY_FILL_XSLPATH");
			
			// replace the __content.xml file by the newly created workfile. 
			// And pack the result.
			// Store in the folder for result compliancy fill-in forms
			
			AnyFolder formFolder = new AnyFolder(configurator.getXParm("properties/IMVERTOR_COMPLY_TARGET"));
			formFolder.mkdirs();
			
			String zipname = configurator.getXParm("appinfo/application-name") + ".xlsx";
			ZipFile formFile = new ZipFile(formFolder,zipname);
			
			XmlFile newContentFile = new XmlFile(configurator.getXParm("properties/WORK_COMPLY_FILL_FILE",true));
			newContentFile.copyFile(contentFile);
			formFile.deserializeFromXml(serializeFolder,true);
			
			/*
			// TODO REMOVE debug, remove next 1 line
			if (develop) {
				prettyPrinter.transform(newContentFile.getCanonicalPath(),"c:/temp/comply/after.xml");
			}
			*/
			
			// XML validate the generated worksheets
			if (configurator.isTrue("cli","validatecomplyexcel")) {
				Iterator<String> files = serializeFolder.listFilesToVector(true).iterator();
				while (files.hasNext()) {
					XmlFile file = new XmlFile(files.next());
					if (file.getName().matches("^sheet\\d+\\.xml$") || file.getName().matches("^comment\\d+\\.xml$"))
						if (!file.isValid()) {
							Iterator<String> messages = file.getMessages().iterator();
							while (messages.hasNext()) {
								runner.warn(logger, messages.next());
							}
							runner.error(logger, file.getMessages().size() + " problems found in generating: " + file.getCanonicalPath());
						}
				}
			}
			
			configurator.setXParm("appinfo/compliancy-result-form-path",formFile.getCanonicalPath());
				
			configurator.setStepDone(STEP_NAME);
			 
			// save any changes to the work configuration for report and future steps
		    configurator.save();
		    
		    report();
			    
		}
		return runner.succeeds();

	}
	
}
