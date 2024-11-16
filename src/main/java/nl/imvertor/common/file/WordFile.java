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
import java.net.URI;
import java.util.Base64;
import java.util.HashMap;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpHeaders;
import org.apache.log4j.Logger;
import org.json.JSONObject;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Runner;
import nl.imvertor.common.Transformer;
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
	public boolean toXhtmlFile(XmlFile outFile) throws Exception {
		
		Configurator configurator = Configurator.getInstance();
		Runner runner = configurator.getRunner();
		boolean debugging = runner.getDebug("DOCUMENTOR");
			
		String pandocServerUrl = configurator.getServerProperty("pandoc.server", false);
		if (pandocServerUrl != null) {
			// gebruik de pandoc server: https://pandoc.org/pandoc-server.html
			
			HttpFile localFile = new HttpFile(this);
			
			HashMap<String,String> headerMap = new HashMap<String,String>();
			//headerMap.put(HttpHeaders.AUTHORIZATION,"token " + OAUTH);
			headerMap.put(HttpHeaders.ACCEPT, "application/octet-stream");
			headerMap.put(HttpHeaders.CONTENT_TYPE, "application/json");
			headerMap.put(HttpHeaders.CONTENT_ENCODING, getEncoding());
			
			String payloadBase64 = Base64.getEncoder().encodeToString(this.getBinaryContent());
			String payload = "{"
					+ "\"from\": \"docx+styles\","
					+ "\"to\": \"html\","
					+ "\"indented-code-classes\": ["
						+ "\"Programmacode\""
					+ "],"
					+ "\"section-divs\": true,"
					+ "\"embed-resources\": true,"
					//+ "\"ipynb-output\": \"all\","
					+ "\"standalone\": true,"
					+ "\"variables\": {"
						+ "\"lang\": \"nl-NL\","
						+ "\"title-meta\": \"NOTITLE\""
					+ "},"
					+ "\"text\": \"" + payloadBase64 + "\""
					+ "}";		
			try {
				String result = localFile.post(HttpFile.METHOD_POST_CONTENT, URI.create(pandocServerUrl), headerMap, null, new String[] {payload});
				if (StringUtils.startsWith(result,"<")) {
					outFile.setContent(result);
					return true;
				} else {
					runner.error(logger, "Documentor processing error: \"" + result + "\"");
					return false;
				}
			} catch (Exception e) {
				runner.error(logger, "Documentor server error: \"" + e.getMessage() + "\"");
			}
			return false;
		} else {
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
		}
		return false;
		
	}
	
	/*
	 * Uitlezen van msword gaat niet altijd goed; in preserveSpace secties worden leading blanks niet goed verwerkt. Vervang deze door harde spaties.
	 */
	public boolean correctCodeSpaces() throws Exception{
		Configurator configurator = Configurator.getInstance();
		try {
			ZipFile thisFile = new ZipFile(this);
			AnyFolder tempFolder = configurator.getWorkFolder("documentor/msword");
			thisFile.decompress(tempFolder);
			// run stylesheet om de spaties in code vast te zetten
			XmlFile wordFile = new XmlFile(tempFolder,"/word/document.xml");
			XmlFile outFile = new XmlFile(tempFolder,"/word/document.xml.transformed");
			XslFile xslFile = new XslFile(configurator.getBaseFolder() + "/xsl/OfficeCompiler/Imvert2documentor-msword-fixes.xsl");
			Transformer transformer = new Transformer();
			transformer.transform(wordFile, outFile, xslFile, "filefix");
			// zet het resultaat van de transformatie op de plek van het input document
			outFile.copyFile(wordFile);
			outFile.delete();
			// Maak het MdWord bestand opnieuw aan door de tijdelijke folder weer te zippen.
			thisFile.compress(tempFolder);
			return true;
		} catch (Exception e) {
			configurator.getRunner().error(logger,"Cannot fix MsWord program code fragment(s)",e);
			return false;
		}
	}
}
