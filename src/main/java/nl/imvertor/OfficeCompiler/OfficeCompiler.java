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

package nl.imvertor.OfficeCompiler;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.FtpFolder;

public class OfficeCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(OfficeCompiler.class);
	
	public static final String STEP_NAME = "OfficeCompiler";
	public static final String VC_IDENTIFIER = "$Id: OfficeCompiler.java 7457 2016-03-05 08:43:43Z arjan $";
	
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		
		generateOfficeReport();
		configurator.setStepDone(STEP_NAME);
		
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    report();
		return runner.succeeds();

	}
	
	/**
	 * Generate a Pdf Report.
	 * This transforms the imvertor system code to some format that may be inserted into an Office doument environment, not defined yet.
	 * At least, for now, it is assumed to generate HTML.  
	 * 
	 * @throws Exception
	 */
	public void generateOfficeReport() throws Exception {
		String op = configurator.getParm("cli", "createoffice");
		String mm = configurator.getParm("cli","metamodel");
		
		if (op.equals("none")) {
			// skip this
		} else if (op.equals("html")) {
			runner.info(logger,"Creating Office documentation");
			Transformer transformer = new Transformer();
			// creates a HTML file which is the basis for output
			transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/WORK_OFFICE_FILE", "properties/IMVERTOR_METAMODEL_" + mm + "_OFFICE_XSLPATH");
			// simply copy the html file as this is identical to the requested HTML
			String fn = "office.html";
			AnyFile infoOfficeFile = new AnyFile(configurator.getParm("properties","WORK_OFFICE_FILE"));
			AnyFile officeFile = new AnyFile(configurator.getParm("system","work-etc-folder-path") + "/" + fn);
			infoOfficeFile.copyFile(officeFile);
			configurator.setParm("appinfo", "office-documentation-filename", fn);
			
			// see if this result should be sent on to FTP
			String target = configurator.getParm("cli", "passoffice",false);
			if (target != null && target.equals("ftp")) {
				String passftp  = configurator.getParm("cli", "passftp");
				String passpath = configurator.getParm("cli", "passpath");
				String passuser = configurator.getParm("cli", "passuser");
				String passpass = configurator.getParm("cli", "passpass");
				
				String targetpath = "ftp://" + passftp + passpath;
				
				runner.info(logger, "Uploading office HTML");
				
				FtpFolder ftpFolder = new FtpFolder();
				
				ftpFolder.server = passftp;
				ftpFolder.protocol = "false";
				ftpFolder.username = passuser;
				ftpFolder.password = passpass;

				try {
					ftpFolder.login();
					ftpFolder.upload(officeFile.getCanonicalPath(),passpath);
					ftpFolder.logout();
				} catch (Exception e) {
					runner.warn(logger, "Cannot upload office HTML to " + targetpath);
				}
			}
		} else {
			runner.error(logger,"Transformation to Office format not implemented yet!");
		}
	}
}
