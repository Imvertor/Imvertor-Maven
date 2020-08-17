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

package nl.imvertor.GenericTransformer;

import java.io.File;

import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.xsl.extensions.ImvertorExcelSerializer;
import nl.imvertor.common.xsl.extensions.ImvertorFolderSerializer;
import nl.imvertor.common.xsl.extensions.ImvertorParseHTML;
import nl.imvertor.common.xsl.extensions.ImvertorParseWiki;
import nl.imvertor.common.xsl.extensions.ImvertorParseYaml;
import nl.imvertor.common.xsl.extensions.ImvertorZipDeserializer;
import nl.imvertor.common.xsl.extensions.ImvertorZipSerializer;
import nl.imvertor.common.xsl.extensions.expath.ImvertorExpathCopy;
import nl.imvertor.common.xsl.extensions.expath.ImvertorExpathReadText;


/**
 * Generic transformer allows any set of XML files to be transformed using any sequence of XSLTs.
 * 
 *  So, provide a folder of file name for input, folder or file name for output, and configure a set of XSLTs.
 *  
 * 
 * @author arjan
 *
 */
public class GenericTransformer extends Step {

	protected static final Logger logger = Logger.getLogger(GenericTransformer.class);
	
	public static final String STEP_NAME = "GenericTransformer";
	public static final String VC_IDENTIFIER = "$Id: Tester.java 7431 2016-02-24 12:46:42Z arjan $";

	/**
	 *  run the main translation
	 */
	public boolean run() throws Exception{
		
		// set up the configuration for this step
		configurator.setActiveStepName(STEP_NAME);
		prepare();

		// create a transformer
		Transformer transformer = new Transformer();
		transformer.setExtensionFunction(new ImvertorZipSerializer());
		transformer.setExtensionFunction(new ImvertorZipDeserializer());
		transformer.setExtensionFunction(new ImvertorExcelSerializer());
		transformer.setExtensionFunction(new ImvertorFolderSerializer());
		transformer.setExtensionFunction(new ImvertorParseHTML());
		transformer.setExtensionFunction(new ImvertorParseWiki());
		transformer.setExtensionFunction(new ImvertorParseYaml());
		transformer.setExtensionFunction(new ImvertorExpathReadText());
		transformer.setExtensionFunction(new ImvertorExpathCopy());
			
	    // check the input 
		AnyFile infile = new AnyFile(configurator.getXParm("cli/infile"));
		AnyFile outfile = new AnyFile(configurator.getXParm("cli/outfile"));
		AnyFile xslfile = new AnyFile(configurator.getXParm("cli/xslfile"));
		String extension = configurator.getXParm("cli/extension");
		
		if (infile.isDirectory() && outfile.isDirectory()) {
			// process the full folder
			AnyFolder infolder = new AnyFolder(infile);
			transformDir(transformer,infolder,outfile,xslfile, extension);
		} else if (infile.isFile() && outfile.isDirectory()) { 
			// transform the file to same named file in the target folder 
			File target = new File(outfile, infile.getName());
			transform(transformer, infile, target, xslfile);
		} else if (infile.isFile()) {
			// transform to the result file given
			transform(transformer, infile, outfile, xslfile);
		} else
			configurator.getRunner().error(logger,"Cannot transform " + infile.getName() + " to " + outfile.getName());
		
		configurator.setStepDone(STEP_NAME);
		
	    // save any changes to the work configuration for report and future steps
	    configurator.save();
		
		// generate report
		report();
		
		return runner.succeeds();
			
	}
	
	private boolean transformDir(Transformer transformer, AnyFile infolder, AnyFile outfolder, AnyFile xslfile, String extension) throws Exception {
		File[] files = infolder.listFiles();
		Boolean succeeds = true;
		for (int i = 0; i < files.length; i++) {
			AnyFile source = new AnyFile(files[i]);
			AnyFile target = new AnyFile(outfolder, files[i].getName() + extension);
			if (source.isDirectory())
				succeeds = succeeds && transformDir(transformer, source, target, xslfile, extension);
			else if (source.getExtension().equals("xml"))
				succeeds = succeeds && transform(transformer, source, target, xslfile);
		}
		return succeeds;
	}
	
	private boolean transform(Transformer transformer, File infile, File outfile, File xslfile) throws Exception {
		System.out.println(infile.getAbsolutePath());
		return transformer.transform(infile, outfile, xslfile,null);
	}
}
