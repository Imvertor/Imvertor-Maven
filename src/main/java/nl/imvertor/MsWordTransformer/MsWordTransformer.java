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

package nl.imvertor.MsWordTransformer;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;

import org.apache.commons.exec.CommandLine;
import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.ZipFile;
import nl.imvertor.common.helper.OsExecutor;
import nl.imvertor.common.helper.OsExecutor.OsExecutorResultHandler;

public class MsWordTransformer extends Step {

	protected static final Logger logger = Logger.getLogger(MsWordTransformer.class);
	
	public static final String STEP_NAME = "MsWordTransformer";
	public static final String VC_IDENTIFIER = "$Id: ReleaseCompiler.java 7473 2016-03-22 07:30:03Z arjan $";
	
	/**
	 *  run the step
	 */
	public boolean run() throws Exception{
		
		// file:/D:/projects/validprojects/Kadaster-Imvertor/Imvertor-OS-work/KING/app/xsd/bsmr0320/bsmr0320.xsd
			
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();
		runner.info(logger,"Transforming MsWord");
		
		// STUB
		configurator.setXParm("appinfo/release","00000001");
		
		boolean succeeds = true;
	
		// TODO implement by standard imvertor xslt calls in stead of full batch 
		
		succeeds = succeeds ? transformByFullBatch() : false;
		
		configurator.setStepDone(STEP_NAME);
		 
		// save any changes to the work configuration for report and future steps
	    configurator.save();
	    
	    report();
		    
		return runner.succeeds();
		
	}
	
	private boolean transformByFullBatch() throws Exception {	
		
		AnyFolder workFolder = new AnyFolder(new File(configurator.getXParm("system/work-folder-path")), "msword");
		workFolder.deleteDirectory();
		workFolder.mkdirs();
		
		AnyFile mswordFile = new AnyFile(configurator.getXParm("cli/mswordfile"));
		if (!mswordFile.exists()) {
			runner.error(logger, "File not found: " + mswordFile.getName());
			return false;
		} else {
			
			// if zip, extract zip to work folder. else copy the file to the workfolder
			String filetype = mswordFile.getExtension();
			
			boolean succeeds = true;
			if (filetype.equals("zip")) {
				ZipFile zipFile = new ZipFile(mswordFile);
				zipFile.decompress(workFolder);
				Iterator<String> it = workFolder.listFilesToVector(false).iterator();
				while (it.hasNext()) {
					AnyFile f = new AnyFile(it.next());
					if (f.getExtension().equals("docx"))
						succeeds = succeeds ? transformDocx(f) : false ;
				}
			} else if (filetype.equals("docx")) {
				AnyFile workFile = new AnyFile(workFolder,mswordFile.getName());
				mswordFile.copyFile(workFile);
				succeeds = succeeds ? transformDocx(workFile) : false ;
			} else
				runner.error(logger, "Unrecognized file type: " + filetype);
			
			// now report on success or failure
			return succeeds;
		}
	
	}
	
	private boolean transformDocx(AnyFile mswordFile) throws IOException, ConfiguratorException {
	
		OsExecutor osExecutor = new OsExecutor();
		
		String toolloc = configurator.getServerProperty("full.batch.msword.transformer"); // location of the tool
		long osExecutorJobTimeout = Long.parseLong(configurator.getServerProperty("full.batch.msword.transformer.timeout")); // location of the tool
		boolean osExecutorInBackground = false;
		
		OsExecutorResultHandler osExecutorResult = null;
		
		CommandLine commandLine = new CommandLine(toolloc + "\\respec.bat");
		commandLine.addArgument(mswordFile.getNameNoExtension()); // the docx file
		commandLine.addArgument("true"); // debug 
		commandLine.addArgument(toolloc); // the tool folder
		commandLine.addArgument(mswordFile.getParent()); // The work folder

		try {
			osExecutorResult = osExecutor.osexec(commandLine, osExecutorJobTimeout, osExecutorInBackground);
			osExecutorResult.waitFor();
			return true;
			
		} catch (Exception e) {
			if (osExecutorResult != null)
				runner.error(logger, "Batch Exit value " + osExecutorResult.getExitValue() + ". " + osExecutorResult.getException().getMessage());
			else 
				runner.error(logger, e.getMessage());
		}
		return false;
	}
}
