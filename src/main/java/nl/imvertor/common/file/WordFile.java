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

package nl.imvertor.common.file;

import java.io.File;

import org.apache.commons.exec.CommandLine;
import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Runner;
import nl.imvertor.common.helper.OsExecutor;
import nl.imvertor.common.helper.OsExecutor.OsExecutorResultHandler;

public class WordFile extends AnyFile {

	public static final Logger logger = Logger.getLogger(ExecFile.class);
	private static final long serialVersionUID = 2409879811971148189L;
	
	public WordFile(String filepath) {
		super(filepath);
	}
	public WordFile(File file) {
		super(file.getAbsolutePath());
	}
	public WordFile(File file, String subpath) {
		super(file, subpath);
	}

	/**
	 * Transform the Doc file to XHTML structure.
	 * This uses Pandoc.
	 * 
	 * @return XmlFile
	 * @param filePath
	 * @throws Exception 
	 */
	public boolean toXhtmlFile(File outFile) throws Exception {
		
		Configurator configurator = Configurator.getInstance();
		Runner runner = configurator.getRunner();
		boolean debugging = runner.getDebug("DOCUMENTOR");
				
		// Implementatie van Pandoc omzetting naar XHTML.
		
		OsExecutor osExecutor = new OsExecutor();
		
		String toolloc = (new AnyFile(configurator.getServerProperty("documentor.msword.transformer"))).getCanonicalPath(); // location of the tool
		long osExecutorJobTimeout = Long.parseLong(configurator.getServerProperty("documentor.msword.transformer.timeout")); // location of the tool
		boolean osExecutorInBackground = false;
		
		runner.info(logger, "Reading: " + this.getName());
		
		OsExecutorResultHandler osExecutorResult = null;
		
		/*
		 * Dit batch file doet het volgende
		 * - Bereid MsWord voor door roep o.a. pandoc aan en corrigeert allerlei 
		 */
		CommandLine commandLine = new CommandLine(toolloc + "\\documentor.bat"); // TODO: *nix
		commandLine.addArgument(this.getName()); // the docx file
		commandLine.addArgument(toolloc); // the tool folder
		commandLine.addArgument(this.getParent()); // The work folder
		commandLine.addArgument(debugging ? "true" : "false"); // debugging?
			
		try {
			osExecutorResult = osExecutor.osexec(commandLine, osExecutorJobTimeout, osExecutorInBackground);
			osExecutorResult.waitFor();
			// assume the msword file * is transformed to *.xhtml
			configurator.setXParm("appinfo/documentor-transformation-result", outFile.getName(),false);
			return true;
			
		} catch (Exception e) {
			if (osExecutorResult != null)
				runner.error(logger, "Documentor exit value " + osExecutorResult.getExitValue() + ". " + osExecutorResult.getException().getMessage());
			else 
				runner.error(logger, e.getMessage());
		}
		return false;
		
	}
	
}
