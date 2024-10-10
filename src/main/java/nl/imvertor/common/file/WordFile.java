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

import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;

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
	public void toXhtmlFile(File outFile) throws Exception {
		
		//TODO Hier de immplementatie van Pandoc omzetting naar XHTML.
		
		//STUB
		XmlFile stubFile = new XmlFile(Configurator.getInstance().getBaseFolder() + "/resources/etc/xhtml/test1.xhtml");
		stubFile.copyFile(outFile);
	}
	
}
