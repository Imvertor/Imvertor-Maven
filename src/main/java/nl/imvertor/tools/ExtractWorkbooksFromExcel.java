package nl.imvertor.tools;

import java.util.HashMap;

import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.file.ZipFile;

public class ExtractWorkbooksFromExcel {

	public static void main(String[] args) throws Exception {
		
		ZipFile excelfile = new ZipFile(args[0]);
		AnyFolder workFolder = new AnyFolder(args[1]);
		
		// extract XML
		excelfile.serializeToXml(workFolder);
		
		// process contents 
		XslFile stylesheet = new XslFile(args[2]);
		HashMap<String,String> map = stylesheet.getInitialParms();
		map.put("workfolder", workFolder.getCanonicalPath());

		stylesheet.transform(
				(new XmlFile(workFolder,"__content.xml")).getCanonicalPath(), 
				(new XmlFile(workFolder,"__content.result.xml")).getCanonicalPath());

		// done
		System.out.println("Done.");
	}
	
	
}
