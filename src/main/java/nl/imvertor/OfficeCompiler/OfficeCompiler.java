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
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.FtpFolder;
import nl.imvertor.common.git.ResourcePusher;

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
		String op = configurator.getXParm("cli/createoffice");
		String mm = configurator.getXParm("cli/metamodel");
		
		if (op.equals("html")) {
			runner.info(logger,"Creating documentation");
			Transformer transformer = new Transformer();
			
			boolean succeeds = true;
			
			// creates an XML modeldoc intermediate file which is the basis for output
			succeeds = succeeds ? transformer.transformStep("properties/WORK_EMBELLISH_FILE","properties/WORK_MODELDOC_FILE", "properties/IMVERTOR_METAMODEL_" + mm + "_MODELDOC_XSLPATH") : false;
			// creates an html file 
			succeeds = succeeds ? transformer.transformStep("properties/WORK_MODELDOC_FILE","properties/WORK_OFFICE_FILE", "properties/IMVERTOR_METAMODEL_" + mm + "_MODELDOC_OFFICE_XSLPATH") : false;
			
			if (succeeds) {
				String template = configurator.getXParm("cli/officename");
				String fn = configurator.mergeParms(template);
				configurator.setXParm("appinfo/office-documentation-filename", fn);
				
				AnyFile infoOfficeFile = new AnyFile(configurator.getXParm("properties/WORK_OFFICE_FILE"));
				AnyFile officeFile = new AnyFile(configurator.getXParm("system/work-cat-folder-path") + "/" + fn + ".html");
				
				infoOfficeFile.copyFile(officeFile);
				
				// see if this result should be sent on to FTP
				String target = configurator.getXParm("cli/passoffice",false);
				if (target != null) 
					if (target.equals("ftp")) {
						String passftp  = configurator.getXParm("cli/passftp");
						String passpath = configurator.getXParm("cli/passpath");
						String passuser = configurator.getXParm("cli/passuser");
						String passpass = configurator.getXParm("cli/passpass");
						
						String targetpath = "ftp://" + passftp + passpath + officeFile.getName();
						
						runner.info(logger, "Uploading office HTML as " + officeFile.getName());
						
						FtpFolder ftpFolder = new FtpFolder();
						
						ftpFolder.server = passftp;
						ftpFolder.protocol = "false";
						ftpFolder.username = passuser;
						ftpFolder.password = passpass;
		
						ftpFolder.connectTimeout = 120000;
						ftpFolder.controlKeepAliveTimeout = 180;
						ftpFolder.dataTimeout = 120000;
		
						try {
							ftpFolder.login();
							ftpFolder.upload(officeFile.getCanonicalPath(),passpath + officeFile.getName());
							ftpFolder.logout();
					    } catch (Exception e) {
							runner.warn(logger, "Cannot upload office HTML to " + targetpath);
						}
					} else if (target.equals("git")) {
						
						AnyFolder catfolder = new AnyFolder(officeFile.getParent());
						
						String gituser     	            = System.getProperty("git.user"); // user name
						String gitpass     	            = System.getProperty("git.pass"); // password
						String gitlocal     	        = System.getProperty("git.local"); // location of local git 
							
						String gitpathremote     	    = configurator.mergeParms(configurator.getXParm("cli/gitpathremote",false)); //full patn to remote reos
						String gitpathlocal     	    = configurator.mergeParms(configurator.getXParm("cli/gitpathlocal",false));  // full patrh to local repos
						String gitcomment 				= configurator.mergeParms(configurator.getXParm("cli/gitcomment",false)); // comment to set on update
											
						runner.info(logger, "GIT Pushing office HTML as " + officeFile.getName());
						
						AnyFolder gitfolder = new AnyFolder("d:/projects/gitprojects" + gitpathlocal);
						
						// create and prepare the GIT resource pusher
						ResourcePusher rp = new ResourcePusher();
						rp.prepare("https://github.com" + gitpathremote, gitfolder, gituser, gitpass);
						
						// copy the files to the work folder
						catfolder.copy(new AnyFolder(gitfolder,"data"));
				        
						// push with appropriate comment
						rp.push(gitcomment);
						
					} 
				// all other cases: do not pass anywhere. 
			}
		} else {
			runner.error(logger,"Transformation to Office format not implemented yet!");
		}
	}
}
