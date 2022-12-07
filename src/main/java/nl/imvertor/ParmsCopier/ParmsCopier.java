package nl.imvertor.ParmsCopier;

import java.io.File;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Step;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;

public class ParmsCopier extends Step {

	/**
	 * copy the parms.xml file to /etc folder, and filter its contents 
	 */
	public boolean run() throws Exception {

		// copy the parms.xml to the etc folder as parms.xml; filter the file paths
		Configurator configurator = Configurator.getInstance();
		XmlFile sourceParmsFile = new XmlFile(configurator.getWorkFolder(),Configurator.PARMS_FILE_NAME);
		XmlFile targetParmsFile = new XmlFile(new File(configurator.getXParm("system/work-etc-folder-path"),"parms.xml"));
		XslFile transXsl = new XslFile(configurator.getResource("static/xsl/Configurator/parms.xsl")); 
		transXsl.transform(sourceParmsFile,targetParmsFile);
		
		return true; // assume no exceptions
	
	}

}
