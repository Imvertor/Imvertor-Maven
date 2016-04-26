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
import java.io.FileInputStream;
import java.io.FileOutputStream;

import jxl.Workbook;
import jxl.demo.XML;

public class ExcelFile extends AnyFile {

	private static final long serialVersionUID = 2409879811971148189L;
	
	public ExcelFile(String filepath) {
		super(filepath);
	}
	public ExcelFile(File file) {
		super(file.getAbsolutePath());
	}
	public ExcelFile(File file, String subpath) {
		super(file, subpath);
	}

	/**
	 * Transform the Excel file to XML structure.
	 *  
	 * @return XmlFile
	 * @param filePath
	 * @throws Exception 
	 */
	public XmlFile toXmlFile(File outFile, File sourceDtdFile) throws Exception {
		// first insert the DTD location for the Excel module
		String dtdUrl = (new AnyFile(sourceDtdFile)).toURI().toURL().toString();
		FileInputStream is = new FileInputStream(this);
		FileOutputStream os = new FileOutputStream(outFile);
		Workbook workbook = Workbook.getWorkbook(is);
		new XML(workbook, os, null, true);
		XmlFile resultFile = new XmlFile(outFile);
		resultFile.replaceAll("<!DOCTYPE workbook SYSTEM \"formatworkbook.dtd\">","<!DOCTYPE workbook SYSTEM \"" + dtdUrl + "\">");
		return resultFile;
	}
	
	public XmlFile toXmlFile(String outPath, String dtdPath) throws Exception {
		return toXmlFile(new File(outPath), new File(dtdPath));
	}
	
	public void setSuppressWarnings(boolean suppress) {
		//TODO implement setSuppressWarnings
	}
	
	
}
