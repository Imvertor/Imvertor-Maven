package nl.imvertor.tools;

import java.io.File;
import java.util.HashMap;

import org.apache.commons.lang.StringUtils;

import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.OOXmlFile;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.file.ZipFile;

public class TranslateEAProfile {

	public static void main(String[] args) throws Exception {
		
		/*
		 * Arguments:
		 * 0 = the XML profile file to be translated
		 * 1 = The Excel file holding the translations
		 * 2 = a Path to a work folder (will not be deleted after the run)
		 * 3 = Path to the XSL that transforms the workbook to a configuration (eaprofile-config.xsl)
		 * 4 = Path to the XSL that transforms the profile according to the configuration (eaprofile-translate.xsl)
		 * 5 = The source and target langauges, typically "NL:EN"
		*/
		try {
			XmlFile profileFile = new XmlFile(args[0]);

			OOXmlFile excelfile = new OOXmlFile(args[1]);
			AnyFolder workFolder = new AnyFolder(args[2]);
			
			XmlFile workFile = new XmlFile(workFolder,"__content.simple-workbook.xml");// This is a fixed name set by OOXxmlFile
			XmlFile configFile = new XmlFile(workFolder,"__content.config.xml");
			
			String sourceLanguage = StringUtils.split(args[5],':')[0];
			String targetLanguage = StringUtils.split(args[5],':')[1];
			
			// first extract to simple workbook format
			excelfile.toXmlFile(workFile, workFolder, OOXmlFile.OFFICE_SERIALIZATION_TO_SIMPLE_WORKBOOK);
			
			// process config, create a configuration representation 
			XslFile configXsl = new XslFile(args[3]);
			HashMap<String,String> configMap = configXsl.getInitialParms();
			configMap.put("workfolder", workFolder.getCanonicalPath());
			
			configXsl.transform(
					workFile.getCanonicalPath(), 
					configFile.getCanonicalPath());
					
			// process contents of the EA profile, i.e. translate
			XslFile translateXsl = new XslFile(args[4]);
			HashMap<String,String> stylesheetMap = translateXsl.getInitialParms();
			stylesheetMap.put("workfolder", workFolder.getCanonicalPath());
			stylesheetMap.put("source-language", sourceLanguage);
			stylesheetMap.put("target-language", targetLanguage);
			
			translateXsl.transform(
					profileFile.getCanonicalPath(), 
					(new XmlFile(workFolder,"__content.profile.xml")).getCanonicalPath());
			
		} catch (Exception e) {
			// TODO: handle exception
			System.err.println(e);
		}
		// done
		System.out.println("Done.");
	}
	
	
}
