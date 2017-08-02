package nl.imvertor.tools;

import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.ZipFile;

public class FillerToExcel {

	public static void main(String[] args) throws Exception {
		
		XmlFile fillerFile = new XmlFile("D:/projects/validprojects/Kadaster-Imvertor/Imvertor-OS-work/default/imvert/imvertor.50.filler.xml");
		
		AnyFolder processingFolder = new AnyFolder("c:/temp/FillerToExcel/zip"); // Any non-existing temporary folder location; deleted when done.
				
		// process an excel file
		ZipFile targetExcel = new ZipFile("c:/temp/FillerToExcel/result.xlsx");
		
		// kopieer de step result naar __content.xml
		fillerFile.copyFile("c:/temp/FillerToExcel/zip/__content.xml");
		
		// do something here; process the __content.xml file
		targetExcel.deserializeFromXml(processingFolder,true);
	
		System.out.println("Done.");
	}
}
