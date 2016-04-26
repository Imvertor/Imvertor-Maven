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

package nl.imvertor.ReadmeCompiler;

import java.io.File;
import java.util.Iterator;
import java.util.Vector;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

/**
 * Analyse an existing readme file (from any previous run for same release) and store info in the configuration file.
 * 
 * @author arjan
 *
 */
public class ReadmeCompiler extends Step {

	protected static final Logger logger = Logger.getLogger(ReadmeCompiler.class);
	
	public static final String STEP_NAME = "ReadmeCompiler";
	public static final String VC_IDENTIFIER = "$Id: ReadmeCompiler.java 7431 2016-02-24 12:46:42Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() {
		
		try {
			// set up the configuration for this step
			configurator.setActiveStepName(STEP_NAME);
			prepare();
			runner.info(logger, "Generating readme file");
			
			Transformer transformer = new Transformer();
			
			// work-app-folder-path
			AnyFile readmeFile = new AnyFile(configurator.getParm("system","work-app-folder-path") + "/readme.html");
			configurator.setParm("system","readme-file-path",readmeFile.getCanonicalPath());
			
			configurator.setParm("appinfo","error-count",Integer.toString(runner.getErrorCount()));
		
			String path = configurator.getParm("appinfo","application-name");
			transformer.setXslParm("xsd-files-generated",listFiles(configurator.getParm("system", "work-xsd-folder-path") + "/" + path, "xsd/" + path + "/"));
			transformer.setXslParm("etc-files-generated",listFiles(configurator.getParm("system", "work-etc-folder-path"),"etc/"));
			transformer.transformStep("properties/WORK_BASE_FILE", "system/readme-file-path", "properties/IMVERTOR_README_XSLPATH");
			
			configurator.setStepDone(STEP_NAME);
			
		    // save any changes to the work configuration for report and future steps
		    configurator.save();
			
			// generate report
			report();
			
			return runner.succeeds();
			
		} catch (Exception e) {
			runner.fatal(logger, "Step fails by system error.", e);
			return false;
		} 
	}
	
	/**
	 * Return all files paths as ;-separated string.
	 * 
	 * @param folderPath The folder to search, recursively
	 * @param prefix A path to prefix before the subpath of the file found.
	 * @return String holding all (sub)paths.
	 * @throws Exception
	 */
	
	private String listFiles(String folderPath, String prefix ) throws Exception {
		AnyFolder folder = new AnyFolder(folderPath);
		if (folder != null && folder.isDirectory()) {
			String base = folder.toURI().toString();
			Vector<String> list1 = folder.listFilesToVector(true);
			Iterator<String> it = list1.iterator();
			String list2 = "";
			while (it.hasNext()) {
				File f = new File(it.next());
				list2 += prefix + StringUtils.substringAfter(f.toURI().toString(), base);
				list2 += (it.hasNext()) ? ";" : "";
			}
			return list2;
		} else return "";
	}
}
