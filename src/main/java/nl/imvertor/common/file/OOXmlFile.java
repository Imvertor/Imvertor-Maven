package nl.imvertor.common.file;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.HashMap;

import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;

public class OOXmlFile extends ZipFile {

	private static final long serialVersionUID = 3914823189952042460L;

	public static final Logger logger = Logger.getLogger(OOXmlFile.class);
	
	public static final int OFFICE_SERIALIZATION_TO_SIMPLE_WORKBOOK = 1;
	
	public static final int OFFICE_TYPE_EXCEL = 1;
	
	private int officeType = -1; // records the type of file at hand
		
	public OOXmlFile(String filepath) throws IOException {
		super(filepath);
	}
	public OOXmlFile(File file) throws IOException {
		super(file.getAbsolutePath());
	}
	public OOXmlFile(File file, String subpath) throws IOException {
		super(file, subpath);
	}

	public Integer getOfficeType() {
		return officeType;
	}
	private void setOfficeType(int officeType) {
		this.officeType = officeType;
	}
	
	private void detemineOfficeType() throws Exception {
		String ext = this.getExtension();
		if (officeType != -1) 
			{} // skip, already determined
		else if (ext.equals("xlsx"))
			setOfficeType(OFFICE_TYPE_EXCEL);
		else 
			throw new Exception("Unknown OOXML file type, extension not recognized: " + ext);
	}
	/**
	 * Transform the Excel file to XML structure in accordance with the serialization convention specified.
	 *  
	 * @return XmlFile
	 * @param outFile The XML output file holding the workbook serialization
	 * @param workFolder A workfolder (temporary)
	 * @param convention A convention to be used for outputting
	 * @throws Exception 
	 */
	public XmlFile toXmlFile(XmlFile outFile, AnyFolder workFolder, int convention) throws Exception {
		// find out what type of file this is
		detemineOfficeType();
		
		// process office to workbook
		if (officeType == OFFICE_TYPE_EXCEL && convention == OFFICE_SERIALIZATION_TO_SIMPLE_WORKBOOK) {
			// extract XML, generates __content.xml
			serializeToXml(workFolder);
			
			XmlFile ooxmlFile = new XmlFile(workFolder,"__content.xml");
			
			//XmlFile resultFile = new XmlFile(workFolder,"__content.simple-workbook.xml");
			
			// create processable table format 
			XslFile extractXsl = new XslFile(Configurator.getInstance().getResource("static/xsl/OOXmlFile/toXmlFile-SimpleWorkbook.xsl"));
			HashMap<String,String> extractMap = extractXsl.getInitialParms();
			extractMap.put("workfolder", workFolder.getCanonicalPath());
			
			extractXsl.transform( ooxmlFile, outFile);
			
			return outFile;
		} else 
			throw new Exception("Unknown OOXML serialization convention");
	}
	/**
	 * Transform to XML representation. 
	 * Intermediate work folder results are lost.
	 * 
	 * @param outFile
	 * @param workFolder
	 * @param convention
	 * @return
	 * @throws Exception
	 */
	public XmlFile toXmlFile(XmlFile outFile, int convention) throws Exception {
		AnyFolder workFolder = new AnyFolder(Files.createTempDirectory("OOXmlFile.").toFile());
		XmlFile resultFile = toXmlFile(outFile, workFolder, convention);
		workFolder.deleteDirectory();
		return resultFile;
	}
 
}
