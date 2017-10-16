package nl.imvertor.tools;

import java.util.HashMap;

import org.apache.commons.lang.StringUtils;

import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.file.ZipFile;

public class ExtractWorkbooksFromExcel {

	public static void main(String[] args) throws Exception {
		
		try {
			XmlFile profileFile = new XmlFile(args[0]);

			ZipFile excelfile = new ZipFile(args[1]);
			AnyFolder workFolder = new AnyFolder(args[2]);
			
			String sourceLanguage = StringUtils.split(args[6],':')[0];
			String targetLanguage = StringUtils.split(args[6],':')[1];
			
			// extract XML
			excelfile.serializeToXml(workFolder);
			
			// create processable table format 
			XslFile extractXsl = new XslFile(args[3]);
			HashMap<String,String> extractMap = extractXsl.getInitialParms();
			extractMap.put("workfolder", workFolder.getCanonicalPath());
			
			extractXsl.transform(
					(new XmlFile(workFolder,"__content.xml")).getCanonicalPath(), 
					(new XmlFile(workFolder,"__content.result.xml")).getCanonicalPath());
			
			// process config, create a configuration representation 
			XslFile configXsl = new XslFile(args[4]);
			HashMap<String,String> configMap = configXsl.getInitialParms();
			configMap.put("workfolder", workFolder.getCanonicalPath());
			
			configXsl.transform(
					(new XmlFile(workFolder,"__content.result.xml")).getCanonicalPath(), 
					(new XmlFile(workFolder,"__content.config.xml")).getCanonicalPath());
					
			// process contents of the EA profile, i.e. translate
			XslFile translateXsl = new XslFile(args[5]);
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
