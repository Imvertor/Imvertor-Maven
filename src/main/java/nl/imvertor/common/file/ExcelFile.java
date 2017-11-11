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

import org.apache.log4j.Logger;

import jxl.Workbook;
import jxl.demo.XML;
import nl.imvertor.common.Configurator;

public class ExcelFile extends AnyFile {

	public static final Logger logger = Logger.getLogger(ExecFile.class);
	private static final long serialVersionUID = 2409879811971148189L;
	
	public static void main(String[] args) throws Exception {
		ExcelFile excelfile1 = new ExcelFile("c:\\Temp\\Book1.xls");
		excelfile1.toXmlFile(new File("c:/temp/result1.xml"));
		System.out.println("Done 1.");
	}
	
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
	 * Pass the DTD File to use.
	 * Normally this is implied, use toXmlFile(File outFile) in stead.
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
		is.close();
		os.flush();
		os.close();
		XmlFile resultFile = new XmlFile(outFile);
		resultFile.replaceAll("<!DOCTYPE workbook SYSTEM \"formatworkbook.dtd\">","<!DOCTYPE workbook SYSTEM \"" + dtdUrl + "\">");
		// when we could not create well-formed XML, remove. 
		if (!resultFile.isWellFormed()) {
			resultFile.delete();
			Configurator.getInstance().getRunner().error(logger, "Cannot create a (valid) XML representation of this Excel file: " + this.getName() + ", because: " + resultFile.getLastError());
		}
		return resultFile;
	}
	
	/**
	 * Transform Excel, by passing the resource DTD (for formatted workbooks).
	 *  
	 * @param outFile The result XML file.
	 * @return
	 * @throws Exception
	 */
	public XmlFile toXmlFile(File outFile) throws Exception {
		// copy the DTD file from resources to a work location
		AnyFile dtdFile = new AnyFile(Configurator.getInstance().getBaseFolder().getCanonicalPath() + "/etc/dtd/ExcelFile/formatworkbook.dtd");
		return toXmlFile(outFile, dtdFile);
	}
	
	public XmlFile toXmlFile(String outPath) throws Exception {
		return toXmlFile(new File(outPath));
	}
	
	public void setSuppressWarnings(boolean suppress) {
		//TODO implement setSuppressWarnings
	}
	
	/**
	 * Check if this is a valid Excel file
	 * 
	 * @return
	 */
	public boolean isValid() {
		try {
			FileInputStream is = new FileInputStream(this);
			return (Workbook.getWorkbook(is) != null);
		} catch (Exception e) {
			// nothing
		}
		return false;
	}
}
