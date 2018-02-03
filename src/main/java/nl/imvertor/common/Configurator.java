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

package nl.imvertor.common;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Properties;
import java.util.TimeZone;
import java.util.Vector;
import java.util.concurrent.TimeUnit;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.xml.xpath.XPathConstants;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.configuration2.CombinedConfiguration;
import org.apache.commons.configuration2.builder.FileBasedConfigurationBuilder;
import org.apache.commons.configuration2.builder.fluent.Parameters;
import org.apache.commons.configuration2.builder.fluent.XMLBuilderParameters;
import org.apache.commons.configuration2.ex.ConfigurationException;
import org.apache.commons.configuration2.tree.NodeCombiner;
import org.apache.commons.configuration2.tree.OverrideCombiner;
import org.apache.commons.configuration2.tree.xpath.XPathExpressionEngine;
import org.apache.commons.lang3.StringUtils;
import org.apache.jena.shared.ConfigException;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.xml.resolver.Catalog;
import org.apache.xml.resolver.CatalogEntry;
import org.apache.xml.resolver.CatalogException;
import org.apache.xml.resolver.CatalogManager;
import org.apache.xml.resolver.tools.CatalogResolver;
import org.w3c.dom.NodeList;

import net.sf.saxon.Configuration;
import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.OutputFolder;
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.log.XparmLogger;
import nl.imvertor.common.log.XsltCallLogger;
import nl.imvertor.common.wrapper.XMLConfiguration;

/**
 * A configurator .........
 * 
 * 
 * 
 * @author arjan
 *
 */
public class Configurator {

	public static final Logger logger = Logger.getLogger(Configurator.class);
	public static final String VC_IDENTIFIER = "$Id: Configurator.java 7498 2016-04-15 07:51:23Z arjan $";
	public static final String PARMS_FILE_NAME = "parms.xml";
	public static final String TRACK_FILE_NAME = "track.txt";
	
	public static final String NAMESPACE_EXTENSION_FUNCTIONS = "http://www.imvertor.org/xsl/extensions";
	public static final String DEFAULT_METAMODEL = "BP";
	public static final String DEFAULT_SCHEMARULES = "BP";
	
	public static final Integer RUN_MODE_RUN = 1;
	public static final Integer RUN_MODE_DEVELOPMENT = 2;
	
	private Configuration saxonConfig;
	private Runner runner;
	private Messenger messenger; // TODO should messenger always be accessed through runner?
	
	private AnyFolder baseFolder;
	private AnyFolder workFolder;
	private AnyFolder appFolder;   
	private AnyFolder inputFolder;   
	private AnyFolder outputFolder;   

	private XMLConfiguration workConfiguration;
	private XMLConfiguration stepConfiguration;

	public XmlFile workConfigurationFile;
	public AnyFile trackerFile;
	
	private String currentStepName;
	private Boolean forceCompile = false; // allow compilation errors to be ignored?
	private Boolean docRelease = false;
	private Boolean suppressWarnings = false;
	private Boolean eaEnabled;
	
	private String metamodel;
	private String schemarules;
	
	private Options options;
	private HashMap<String,Boolean> requiredOption = new HashMap<String,Boolean> ();
	
	private HashMap<String,String> catalogMap = new HashMap<String,String> ();
	
	private Properties serverProperties;
	
	private PrintWriter pw = new PrintWriter(System.out);
	
	private long starttime = 0;
	
	private Integer runmode = RUN_MODE_DEVELOPMENT;
	
	private XparmLogger xParmLogger; // keeps track of the sequence of parameters set by the chain. A debugging tool.
	private XsltCallLogger xsltCallLogger; // keeps track of the XSLT calls. A debugging tool.
	
	private Configurator()  {
		
		runner = new Runner();
		options = new Options(); 
		xParmLogger = new XparmLogger();
		xsltCallLogger = new XsltCallLogger();
		
		try {
			if (System.getProperty("install.dir") == null)
				throw new ConfiguratorException("Missing system parameter install.dir, please pass as -Dinstall.dir=[filepath]");
			
			baseFolder = new AnyFolder(System.getProperty("install.dir"));
			
			if (!baseFolder.isDirectory())
				throw new ConfiguratorException("Not a folder: " + baseFolder.getCanonicalPath());
			
			if (System.getProperty("job.id") == null)
				throw new ConfiguratorException("Missing system parameter job.id, please pass as -Djob.id=[name]");
			
			// assume development, but if a runmode is supplied, and it is not development, assume deployed.
			if (System.getProperty("run.mode") != null)
				if (!System.getProperty("run.mode").equals("development"))
					runmode = RUN_MODE_RUN;

			workFolder = new AnyFolder(getServerProperty("work.dir") + "/" + System.getProperty("job.id"));
			appFolder = new AnyFolder(workFolder,"app");
			
			if (!workFolder.isDirectory())
				workFolder.mkdirs();
			if (!appFolder.isDirectory())
				appFolder.mkdirs();
			
			if (System.getProperty("owner.name") == null)
				throw new ConfiguratorException("Missing system parameter owner.name, please pass as -Downer.name=[name]");
			
			boolean regression = System.getProperty("is.reg") != null && System.getProperty("is.reg").equals("true");
					
			inputFolder  = new AnyFolder(baseFolder, "input" + File.separator + System.getProperty("owner.name"));
			outputFolder = new AnyFolder(getServerProperty(
					(regression) ? "output.dir.reg" : "output.dir") + "/" + System.getProperty("owner.name"));
			
			saxonConfig = new Configuration();
		
			messenger = new Messenger(saxonConfig.makePipelineConfiguration());
			runner.setMessenger(messenger);
			
			String ee = getServerProperty("ea.enabled"); // true or false; false typically on server environment; see redmine #487932
			eaEnabled = (ee == null || !ee.equals("false"));
			
		} catch (Exception e) {
			System.err.println("Invalid configuration: " + e.getMessage());
			System.exit(0);
		}
	}
	
	private static class ConfigurationHolder { 
		private static final Configurator INSTANCE = new Configurator();
	}

	public static Configurator getInstance() {
		return ConfigurationHolder.INSTANCE;
	}

	public Configuration getSaxonConfiguration() {
		return saxonConfig;
	}
	
	public XMLConfiguration getXmlConfiguration() {
		return workConfiguration;
	}
	
	public Runner getRunner() {
		return runner;
	}
	
	public Messenger getMessenger() {
		return messenger;
	}
	
	public AnyFolder getBaseFolder() {
		return baseFolder;
	}

	public AnyFolder getWorkFolder() {
		return workFolder;
	}

	public AnyFolder getWorkFolder(String subfolderName) {
		return new AnyFolder(workFolder,subfolderName);
	}

	public String getMetamodel() {
		return metamodel;
	}

	public String getSchemarules() {
		return schemarules;
	}

	public XmlFile getStepConfigFile(String stepName) {
		return new XmlFile(baseFolder,"cfg" + File.separator + stepName + File.separator + Configurator.PARMS_FILE_NAME);
	}
	
	public XmlFile getStepConfigFile() {
		return getStepConfigFile(currentStepName);
	}
	
	/**
	 * Return the path to the folder where all results are recorded.
	 * This is the folder especially created for this current application release. 
	 * 
	 * Example: D:\projects\validprojects\Kadaster-Imvertor\Imvertor-output\applications\cdmkad\CDMKAD\20150601
	 * 
	 * @return
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public AnyFolder getApplicationFolder() throws IOException, ConfiguratorException {
		return getApplicationFolder(getXParm("appinfo/release"));
	}

	/**
	 * Return the path to the folder where all results are recorded.
	 * This is the folder especially created for this current application release. 
	 * 
	 * Example: D:\projects\validprojects\Kadaster-Imvertor\Imvertor-output\applications\cdmkad\CDMKAD\20150601
	 * 
	 * @param releaseNumber The release number. This is usually a string in the form YYYYMMDD.
	 * 
	 * @return Folder of the application that should hold all Imvert result files.
	 * 
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public AnyFolder getApplicationFolder(String releaseNumber) throws IOException, ConfiguratorException {
		return getApplicationFolder(getXParm("appinfo/project-name"),getXParm("appinfo/application-name"),releaseNumber);
	}

	public AnyFolder getApplicationFolder(String projectname, String modelName, String releaseNumber) throws IOException, ConfiguratorException {
		String sep = File.separator;
		return new AnyFolder(getOutputFolder() + sep + "applications" + sep + projectname + sep + modelName + sep + releaseNumber);
	}

	public File getOutputFolder() {
		return outputFolder;
	}

	public AnyFile getTrackerFile() {
		return trackerFile;
	}
	
	/**
	 * Return the full path of the XSL file that is passed by name.
	 * The XSL file must be part of the step declared, and must exist.
	 * 
	 * @param XslFilename
	 * @return
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 * @throws ConfigurationException 
	 */
	public String getXslPath(String xslFilename) throws ConfiguratorException, IOException {
		String folder = getParm(workConfiguration,"system","xsl-folder-path",true);
		File stepFolder = new File(folder, getParm(workConfiguration,"steps","step-name",true));
		XmlFile xslFile = new XmlFile(stepFolder, xslFilename);
		return xslFile.getCanonicalPath();
	}
	
	public XMLConfiguration getWorkConfig() {
		return workConfiguration;
	}
	
	/**
	 * Record the current step by name passed. 
	 * This name returns as the folder name within cfg/ and xsl/ folders.
	 * 
	 * @param stepName
	 * @throws IOException
	 * @throws ConfiguratorException
	 */
	public void setActiveStepName(String stepName) throws IOException, ConfiguratorException {
		xParmLogger.openOrigin(stepName);
		currentStepName = stepName;
	}

	/**
	 * Get the current step name.
	 * 
	 * @param stepName
	 * @throws IOException
	 * @throws ConfiguratorException
	 */
	public String getActiveStepName() {
		return currentStepName;
	}
	
	/**
	 * Initialize the chain process by creating the configuration in the work folder.
	 * This configuration is first filled with the common configuration.
	 *   
	 * @throws Exception 
	 */
	public void prepare() throws Exception {
		
		starttime = System.currentTimeMillis(); 
		
		trackerFile = new AnyFile(workFolder,Configurator.TRACK_FILE_NAME);
		trackerFile.setContent("Preparing"); // clear current contents
		
		workConfigurationFile = new XmlFile(workFolder,Configurator.PARMS_FILE_NAME);
		workConfigurationFile.setContent(
				"<config><run>"
				+ "<start>" + currentISOdate() + "</start>"
				+ "<version>" + Release.getVersionString("Imvertor") + "</version>"
				+ "<release>" + Release.getReleaseString() + "</release>"
				+ "</run></config>");
		
		workConfiguration = load(workConfigurationFile);
		
		// set system props.
		String s = File.separator;
		String wf = workFolder.getCanonicalPath();
		setXParm(workConfiguration,"system/work-folder-path", wf, true);
		String wff = workConfigurationFile.getCanonicalPath();
		setXParm(workConfiguration,"system/work-config-path", wff, true);
		
		setXParm(workConfiguration,"system/work-app-folder-path",     wf + s + "app", true);
		setXParm(workConfiguration,"system/work-etc-folder-path", 	  wf + s + "app" + s + "etc", true);
		setXParm(workConfiguration,"system/work-ea-folder-path", 	  wf + s + "app" + s + "ea", true);
		setXParm(workConfiguration,"system/work-xsd-folder-path",     wf + s + "app" + s + "xsd", true);
		setXParm(workConfiguration,"system/work-doc-folder-path",     wf + s + "app" + s + "doc", true);
		setXParm(workConfiguration,"system/work-uml-folder-path",     wf + s + "app" + s + "uml", true);
		setXParm(workConfiguration,"system/work-cmp-folder-path",     wf + s + "app" + s + "cmp", true);
		setXParm(workConfiguration,"system/work-job-folder-path",     wf + s + "app" + s + "job", true);
		setXParm(workConfiguration,"system/work-shacl-folder-path",   wf + s + "app" + s + "shacl", true);
		setXParm(workConfiguration,"system/work-cat-folder-path",     wf + s + "app" + s + "cat", true);
		setXParm(workConfiguration,"system/work-yaml-folder-path",    wf + s + "app" + s + "yaml", true);
		setXParm(workConfiguration,"system/work-xmi-folder-path",     wf + s + "app" + s + "xmi", true);
					
		setXParm(workConfiguration,"system/work-rep-folder-path",     wf + s + "rep", true);
		setXParm(workConfiguration,"system/work-imvert-folder-path",  wf + s + "imvert", true);
		setXParm(workConfiguration,"system/work-comply-folder-path",  wf + s + "comply", true);
		setXParm(workConfiguration,"system/work-profile-folder-path", wf + s + "profile", true);
		setXParm(workConfiguration,"system/work-debug-folder-path",   wf + s + "debug", true);
		setXParm(workConfiguration,"system/work-log-folder-path",     wf + s + "log", true);
		
		// clear the workfolder
		(new OutputFolder(getXParm(workConfiguration,"system/work-app-folder-path",true))).clear(false);
		(new OutputFolder(getXParm(workConfiguration,"system/work-rep-folder-path",true))).clear(false);
		(new OutputFolder(getXParm(workConfiguration,"system/work-imvert-folder-path",true))).clear(false);
		(new OutputFolder(getXParm(workConfiguration,"system/work-comply-folder-path",true))).clear(false);
		(new OutputFolder(getXParm(workConfiguration,"system/work-profile-folder-path",true))).clear(false);
		(new OutputFolder(getXParm(workConfiguration,"system/work-debug-folder-path",true))).clear(false);
		(new OutputFolder(getXParm(workConfiguration,"system/work-log-folder-path",true))).clear(false);
		(new OutputFolder(getXParm(workConfiguration,"system/work-xmi-folder-path",true))).clear(false);
				
		setXParm(workConfiguration,"system/managedoutputfolder", outputFolder.getCanonicalPath(), true);
		setXParm(workConfiguration,"system/managedinstallfolder", baseFolder.getCanonicalPath(), true);
		
		setXParm(workConfiguration,"system/latest-imvertor-release", getServerProperty("latest.imvertor.release"), true);

		setActiveStepName("common");
		
		prepareSSL();
		
		prepareStep();
		
	}

	/**
	 * Prepare a step in the chain process by merging its configuration to the parms file in the work folder, 
	 * from which all modules read their parameters.
	 *   
	 * @throws Exception 
	 */
	public void prepareStep() throws Exception {
		
		XmlFile stepFile = getStepConfigFile();
		if (!stepFile.isFile())
	   		throw new ConfiguratorException("A step configurator file is required, but could not locate " + stepFile.getCanonicalPath());
		
		stepConfiguration = load(stepFile);
		
		// Combine work with step configurations
		NodeCombiner combiner = new OverrideCombiner();
		CombinedConfiguration cc = new CombinedConfiguration(combiner);
		cc.addConfiguration(workConfiguration);
		cc.addConfiguration(stepConfiguration);
		
		// replace the work configuration with the merged configuration.
		workConfiguration = new XMLConfiguration(cc);
		workConfiguration.setExpressionEngine(new XPathExpressionEngine());
		
		setXParm(workConfiguration, "steps/step-name", currentStepName, false);

	}
	
	public void prepareSSL() {
		TrustManager[] trustAllCertsManager = new TrustManager[] { 
			new X509TrustManager() {
				@Override
				public java.security.cert.X509Certificate[] getAcceptedIssuers() { 
					return new java.security.cert.X509Certificate[0];
				}
				@Override
				public void checkClientTrusted(java.security.cert.X509Certificate[] certs, String authType) {
					// trust all
				}
				@Override
				public void checkServerTrusted(java.security.cert.X509Certificate[] certs, String authType) {
					// trust all
				}
			}
		};
		try {
			SSLContext sc = SSLContext.getInstance("SSL");
			sc.init(null, trustAllCertsManager, new java.security.SecureRandom());
			HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
		} catch (KeyManagementException | NoSuchAlgorithmException e) {
			runner.fatal(logger, "SSL init exception", e, "SIE");
		}
	}

	/**
	 * Return a XML configuration object for the file passed.
	 * 
	 * Properties are accessible by xpath expressions.
	 * 
	 * @param configfile
	 * @return
	 * @throws ConfigurationException
	 */
	private XMLConfiguration load(File configfile) throws ConfiguratorException, ConfigurationException {
		Parameters params = new Parameters();
		FileBasedConfigurationBuilder<XMLConfiguration> builder = new FileBasedConfigurationBuilder<XMLConfiguration>(XMLConfiguration.class);
		XMLBuilderParameters p = params.xml();
		p.setFile(configfile);
		builder.configure(p);
		XMLConfiguration c = builder.getConfiguration(); 
		c.setExpressionEngine(new XPathExpressionEngine());
		return c;
	}
	
	/**
	 * Save XML configuration to config file. 
	 * Overwrite when the file already exists.
	 * 
	 * @param config
	 * @throws IOException
	 * @throws ConfigurationException 
	 * @throws ConfiguratorException
	 */
	public void save() throws IOException, ConfigurationException {
		// see http://stackoverflow.com/questions/9852978/write-a-file-in-utf-8-using-filewriter-java
		OutputStreamWriter char_output = new OutputStreamWriter(
		     new FileOutputStream(workConfigurationFile),
		     Charset.forName("UTF-8").newEncoder() 
		);
	    workConfiguration.write(char_output);
	}
	
	/**
	 * Last call to the configuration in a chain is to wind up all processing.
	 * 
	 * This copies the work results to the application result folder, but only when not overriding a final application.
	 * @throws Exception 
	 *  
	 */
	public void windup() throws Exception {
		
		setXParm("run/time",runtime());
		
		OutputFolder appWorkFolder = new OutputFolder(getXParm("system/work-app-folder-path"));
		OutputFolder appFinalFolder;
	
		if (runner.getMayRelease()) {
			appFinalFolder = new OutputFolder(getXParm("properties/APPLICATION_FOLDER"));
		} else {
			appFinalFolder = new OutputFolder(getXParm("properties/INVALID_APPLICATION_FOLDER"));
		}
		// copy the complete application folder to the final destination. Note that a zip release may already have been compiled.
		appFinalFolder.clearIfExists(false);
		appWorkFolder.copy(appFinalFolder);	
		
		// set this as a system property; to be picked up by any outside application such as xslweb executor
		setXParm("system/result-output-folder", appFinalFolder.getCanonicalPath());
		
		save();
		
		if (runner.isFinal() && isTrue("system","schema-created",false)) { 
			runner.info(logger, "Copying the result XML schemas to distribution folder");
			AnyFolder sourceXsdFolder = new AnyFolder(getXParm("system/work-xsd-folder-path"));
			AnyFolder targetXsdFolder = new AnyFolder(getXParm("properties/DISTRIBUTION_APPLICATION_FOLDER"));
			runner.debug(logger,"CHAIN","Distributing " + sourceXsdFolder + " to " + targetXsdFolder);
			targetXsdFolder.mkdirs();
			sourceXsdFolder.copy(targetXsdFolder);
		}
		
	}
	
	public float runtime() throws Exception {
		long millis = System.currentTimeMillis() - starttime; 
		return ((float) millis) / 1000;
	}
	
	public String runtimeForDisplay() {
		long millis = System.currentTimeMillis() - starttime;
		return String.format("%d min %d sec", 
			    TimeUnit.MILLISECONDS.toMinutes(millis),
			    TimeUnit.MILLISECONDS.toSeconds(millis) - 
			    TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis))
			);
	}
	
	/**
	 * Return the full file path of the xml configuration file.
	 * 
	 * @return
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public String getConfigFilepath() {
		try {
			return workConfigurationFile.getCanonicalPath();
		} catch (IOException e) {
			runner.fatal(logger, "Cannot access the configuration file at " + workConfigurationFile, e, null);
		}
		return "";
	}
	
	/**
	 * get the current date in ISO 8601 format
	 * 
	 * @return
	 */
	public String currentISOdate() {
		TimeZone tz = TimeZone.getTimeZone("UTC");
	    DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
	    df.setTimeZone(tz);
	    return df.format(new Date());
	}
	
	/**
	 * Create parameters from arguments passed to the java application. 
	 * Arguments are parsed by CLI conventions. 
	 * Existing argument parameters are replaced.
	 * 
	 * Parameters set from command line option are placed in /config/cli subelement and take the form 
	 * /config/cli/parameter[@name]/text()  
	 * 
	 * @param options Command line options
	 * @throws Exception 
	 */
	public void setParmsFromOptions(String[] args) throws Exception {
		
		xParmLogger.openOrigin("#CLI");
		
		CommandLine commandLine = null;
		File curFolder = baseFolder;
		try {
			BasicParser parser = new BasicParser();
			commandLine = parser.parse(options, args);
			if (commandLine.hasOption("help")) 
		        dieOnCli(commandLine.getOptionValue("help"));
		} catch (ParseException e) {
			runner.error(logger, e.getMessage());
			dieOnCli("error");
		}
		
		@SuppressWarnings("unchecked")
		Iterator<Option> it = commandLine.iterator();
		while (it.hasNext()) {
			Option option = it.next();
			String optionName = option.getOpt();
			String[] v = commandLine.getOptionValues(optionName); // same option many times returns array of values.
			if (v.length > 1)
				throw new Exception("Duplicate argument -" + optionName + " on command line");
			if (optionName.equals("arguments")) 
				loadFromPropertyFiles(curFolder,v[0]);
			setParm(workConfiguration, "cli",optionName,v[0],true);
			setOptionIsReady(optionName, true);
		}
		
		String missing = checkOptionsAreReady();
		if (!missing.equals("")) {
			runner.error(logger, "Missing required parameters: " + missing);
			dieOnCli("program");
		}

		String task = getParm(workConfiguration,"cli","task",false);
		if (task != null && (task.equals("compile") || task.equals("release"))) {
			// This is a regular run, processing an Imvert file. 
			
			// record the metamodel used
			metamodel = getParm(workConfiguration,"cli","metamodel",false);
			metamodel = (metamodel == null) ? DEFAULT_METAMODEL : metamodel;
			
			// schema rules used
			schemarules = getParm(workConfiguration,"cli","schemarules",false);
			schemarules = (schemarules == null) ? DEFAULT_SCHEMARULES : schemarules;
			
			// set the task
			setXParm(workConfiguration,"appinfo/task",getParm(workConfiguration,"cli","task",true),true);
			
		    // If forced compilation, try all steps irrespective of any errors
		    forceCompile = isTrue(getParm(workConfiguration,"cli","forcecompile",true)); 
		    
		    // If documentation release, set the suffix for the application id
		    String docReleaseString = getParm(workConfiguration,"cli","docrelease",false);

		    docRelease = docReleaseString != null && !docReleaseString.equals("00000000");
		    if (docRelease) 
		    	setXParm("system/documentation-release","-" + docReleaseString);
		    else 
		    	setXParm("system/documentation-release","");
	
	    } else {
			// this is a free chain run
		}
	    
	    // if warnings should be signaled
	    suppressWarnings = isTrue("cli","suppresswarnings",false);
	    
	    xParmLogger.closeOrigin();
	}
	
	/**
	 * Set the location of all system files/folders. 
	 *
	 * @throws IOException
	 * @throws ConfigException
	 * @throws ConfiguratorException 
	 */
	public void setParmsFromEnv() throws IOException, ConfiguratorException {
		xParmLogger.openOrigin("#ENV");
		
		setXParm(workConfiguration, "system/folder-path",baseFolder.getCanonicalPath(),true);
		setFileXParm(workConfiguration, "system/etc-folder-path","etc",baseFolder);
		setFileXParm(workConfiguration, "system/cfg-folder-path","cfg",baseFolder);
		setFileXParm(workConfiguration, "system/xsl-folder-path","xsl",baseFolder);
		
		setXParm(workConfiguration, "system/inp-folder-path",inputFolder.getCanonicalPath(),true);
		
		// also set some general relevant info
		setXParm(workConfiguration, "system/generation-id", getCurrentDate("yyyyMMdd-HHmmss"),true);
		
		xParmLogger.closeOrigin();
	}

	/**
	 * Set a parameter. 
	 * Parameters have the XML form /group/name/...value...
	 * Replaces existing parameters.
	 *
	 * @param group The name of the group this parameter is part of
	 * @param name  The name of the parameter 
	 * @param value The value of the parameter
	 * 
	 * @throws IOException
	 * @throws ConfigException
	 * @throws ConfiguratorException 
	 */
	public void setParm(String group, String name, Object value) throws IOException, ConfiguratorException {
		setParm(workConfiguration, group, name, value, true);
	}
	public void setXParm(String name, Object value) throws IOException, ConfiguratorException {
		setXParm(workConfiguration, name, value, true);
	}

	/**
	 * Set a parameter. 
	 * Specifies if the parameter should be replaced.
	 * 
	 * @param group The name of the group this parameter is part of
	 * @param name  The name of the parameter 
	 * @param value The value of the parameter
	 * 
	 * @throws IOException
	 * @throws ConfigException
	 * @throws ConfiguratorException 
	 */
	public void setParm(String group, String name, String value, boolean replace) throws IOException, ConfiguratorException {
		setParm(workConfiguration, group, name, value, replace);
	}
	public void setXParm(String name, String value, boolean replace) throws IOException, ConfiguratorException {
		setXParm(workConfiguration, name, value, replace);
	}
	/**
	 * Get a parameter. A parameter is in all cases member of a group.
	 * The parameter must exist. 
	 *
	 * Parameters have the XML form /config/[group]/[name]/...value...
	 * 
	 * @param group The name of the group this parameter is part of
	 * @param name  The name of the parameter 
	 * 
	 * @throws IOException
	 * @throws ConfigException
	 * @throws ConfiguratorException 
	 * @throws ConfigurationException 
	 */
	public String getParm(String group, String name) throws IOException, ConfiguratorException {
		return getParm(workConfiguration, group, name, true);
	}
	public String getXParm(String name) throws IOException, ConfiguratorException {
		return getXParm(workConfiguration, name, true);
	}

	/**
	 * See getParm(). 
	 *
	 * Specifies if the parameter must exist.
	 * 
	 * @param group The name of the group this parameter is part of
	 * @param name  The name of the parameter 
	 * 
	 * @throws IOException
	 * @throws ConfigException
	 * @throws ConfiguratorException 
	 * @throws ConfigurationException 
	 */
	public String getParm(String group, String name, boolean mustExist) throws IOException, ConfiguratorException {
		return getParm(workConfiguration, group, name, mustExist);
	}
	public String getXParm(String name, boolean mustExist) throws IOException, ConfiguratorException {
		return getXParm(workConfiguration, name, mustExist);
	}
	
	/**
	 * Get the alias of the configuration entry. This takes the form of attribute @alias on the XML entry,
	 * If not defined, return null.
	 * 
	 * @param group
	 * @param name
	 * @return
	 * @throws IOException
	 * @throws ConfiguratorException
	 */
	public String getAlias(String group, String name) throws IOException, ConfiguratorException {
		return getAlias(workConfiguration, group, name);
	}

	/**
	 * Set parameter for a particular XML configuration. 
	 * 
	 * @param xmlConfig
	 * @param group
	 * @param name
	 * @param value
	 * @param replace Replace the property if already exists.
	 * 
	 * @throws ConfiguratorException
	 */
	private void setParm(XMLConfiguration xmlConfig, String group, String name, Object value, boolean replace) throws ConfiguratorException {
		setXParm(xmlConfig, group + "/" + name,value,replace);
	}
	
	private void setXParm(XMLConfiguration xmlConfig, String name, Object value, boolean replace) throws ConfiguratorException {
		String svalue = (value == null) ? "" : StringUtils.trim(value.toString());
		if (replace)
			xmlConfig.setProperty(name, svalue);
		else 
			xmlConfig.addProperty(name, svalue);
		
		// add this setting to the Xparm log: a list of settings which clarifies which parameter was set by which step
		xParmLogger.add(name, svalue, replace);
		
		// if this is a debug parameter, set debug level
	    if (name.equals("cli/debug") && isTrue(svalue)) {
	    	Logger.getRootLogger().setLevel(Level.DEBUG);
	    	getRunner().debug(logger,"CHAIN","Debugging started.");
	    }
	}
	
	/**
	 * Remove a parameter from the configuration.
	 * 
	 * @param group
	 * @param name
	 * @throws IOException
	 * @throws ConfiguratorException
	 */
	public void removeParm(String group, String name) throws IOException, ConfiguratorException {
		removeParm(workConfiguration, group, name);
	}
	
	private void removeParm(XMLConfiguration xmlConfig, String group, String name) throws ConfiguratorException {
		xmlConfig.clearProperty(group + "/" + name);
	}
	
	/**
	 * Get parameter for a particular XML configuration.
	 * When the parameter has multiple occurrences, return the last.
	 * Leading and trailings spaces are trimmed.
	 * 
	 * @param xmlConfig
	 * @param group
	 * @param path
	 * @param mustExist
	 * @throws ConfiguratorException
	 * @throws ConfigurationException 
	 */
	private String getParm(XMLConfiguration xmlConfig, String group, String name, boolean mustExist) throws ConfiguratorException {
		return getXParm(xmlConfig, group + "/" + name, mustExist);
	}
	
	private String getXParm(XMLConfiguration xmlConfig, String name, boolean mustExist) throws ConfiguratorException {
		String v = xmlConfig.getString(name + "[last()]");
		if (mustExist && v == null)
			throw new ConfiguratorException("Parameter not set: " + name);
		else if (v == null)
			return v;
		else if (isInterpolated(v))
			return v;
		else
			throw new ConfiguratorException("Cannot resolve configuration parameter: " + name + ", value is (" + v + ")");
	}
	
	/**
	 * Return the alias of the parameter. 
	 * The alias is a short name which is referenced when profiling or debugging is requested.
	 * 
	 * @param xmlConfig
	 * @param group
	 * @param name
	 * @return
	 * @throws ConfiguratorException
	 */
	private String getAlias(XMLConfiguration xmlConfig, String group, String name) throws ConfiguratorException {
		String v = xmlConfig.getString(group + "/" + name + "[last()]/@alias");
		if (v == null)
			return v;
		else if (isInterpolated(v))
			return v;
		else
			throw new ConfiguratorException("Cannot resolve configuration alias for: " + group + "/" + name + ", value is (" + v + ")");
	}

	
	/**
	 * Set a file parameter. This resolves the path as a canonical file path. 
	 * File doesn't have to exist.
	 * This replaces any existing file parameters.
	 * 
	 * @param name name of the parameter
	 * @param subpath Subpath of the file, e.g. "etc"
	 * @param rootFile Path to the root folder for the subpath. When null, assume user folder.
	 * @throws IOException
	 * @throws ConfiguratorException 
	 */
	private void setFileXParm(XMLConfiguration xmlConfig, String name, String subpath, File rootFile) throws IOException, ConfiguratorException {
		subpath = StringUtils.trim(subpath);
		if (rootFile == null) rootFile = new File(System.getProperty("user.dir"));
		File f = isFullPath(subpath) ? new File(subpath) : new File(rootFile, subpath);
		setXParm(xmlConfig, name, f.getCanonicalPath(),true);
	}
	
	/**
	 * Return true when the path passed is a full file path, i.e. a path starting in the root of the filesystem.
	 * 
	 * @param filepath
	 * @return
	 */
	private boolean isFullPath(String filepath) {
		return (filepath.startsWith("\\") || filepath.startsWith("/") || filepath.substring(1).startsWith(":"));
	}
	
	/**
	 * Return true when the parameter specified is equivalent to "true", otherwise false.
	 * 
	 * A parameter is true when it has a value and its value is "yes" or "true". 
	 * It is false in all other cases. 
	 *  
	 * @param group
	 * @param name
	 * @return
	 * @throws IOException
	 * @throws ConfiguratorException
	 * @throws ConfigurationException 
	 */
	public boolean isTrue(String group, String name) throws IOException, ConfiguratorException {
		return isTrue(getParm(group, name));
	}
	public boolean isTrue(String group, String name, boolean defaultTrue) throws IOException, ConfiguratorException {
		String r = getParm(group, name,false);
		return (r != null) ? (r.equals("yes") | r.equals("true")) : defaultTrue;
	}
	
	/**
	 * A string is considered "true" when it is "yes" or "true", and false in all other cases.
	 *  
	 * @param v
	 * @return
	 */
	public boolean isTrue(String v) {
		return (v == null) ? false : (v.equals("yes") || v.equals("true"));
	}
	
	/**
	 * Return a file path for the path specified, relative to the configured base folder.
	 * If the path is absolute, return that path.
	 * 
	 * @param path
	 * @return
	 */
	public File getFile(String path) {
		if (AnyFile.isAbsolutePath(path)) 
			return new File(path);
		else
			return new File(getBaseFolder(),path);
	}

	/**
	 * Read property file used to represent cli parameters, and put these in the work configuration.
	 * Do not override existing property values.
	 * 
	 * Property file may also have an arguments property, set to a comma-separated list of relative paths to other property files to be included, in that order.
	 * 
	 * The file is located relative to the property file holding the include statement. 
	 * If not available, it is assume it is available in the props folder of the managed input folder.
	 * If not found there, an exception is raised. 
	 * 
	 * @param filePath
	 * @throws Exception 
	 */
	private void loadFromPropertyFile(String filePath) throws Exception {
		
		xParmLogger.openOrigin(filePath);
		
		File f = getFile(filePath);
		runner.debug(logger,"CHAIN","Reading property file " + f.getCanonicalPath());
		
		Properties properties = getProperties(f);
		
		// read arguments first
		String arguments = properties.getProperty("arguments");
		if (arguments != null)
			loadFromPropertyFiles(f.getParentFile(),arguments);
		
		// then process the arguments
		Enumeration<Object> e = properties.keys();
		while (e.hasMoreElements()) {
			String optionName = e.nextElement().toString();
			String value = properties.getProperty(optionName);
			// process file properties in context of the current file
			if (optionName.equals("umlfile") | optionName.equals("zipfile") | optionName.equals("hisfile")) {
				File parent = (new File(filePath)).getParentFile();
				if (AnyFile.isAbsolutePath(value))
					value = (new File(value)).getCanonicalPath();
				else
					value = (new File(parent, value)).getCanonicalPath();
			} 
			setParm(workConfiguration,"cli",optionName,value,true); 
			setOptionIsReady(optionName, true);
			
		}
		
		xParmLogger.closeOrigin();
	}
	
	private void loadFromPropertyFiles(File curFolder, String filenames) throws Exception {
		if (filenames != null) {
			String[] files = filenames.trim().split("\\s*,\\s*");
			for (int i = 0; i < files.length; i++) {
				File incFile;
				if (AnyFile.isAbsolutePath(files[i]))
					incFile = new File(files[i]);
				else 
					incFile = new File(curFolder,files[i]);
				xParmLogger.add("arguments", files[i], false);
				loadFromPropertyFile(selectIncFile(incFile).getCanonicalPath());
			}
		}
	}
	
	private File selectIncFile(File incFile) throws Exception {
		if (incFile.exists())
			return incFile;
		else {
			File commonIncFile = new File(inputFolder,"props/" + incFile.getName());
			if (commonIncFile.exists())
				return commonIncFile;
			else
				throw new Exception("Properties not found, tried files at " + incFile.getCanonicalPath() + " and " + commonIncFile.getCanonicalPath());
		}
	}
	
    /**
     * Check if a property is fully interpolated (all variables such as ${x} resolved).
     * 
     * See also https://commons.apache.org/proper/commons-configuration/userguide/howto_basicfeatures.html
     * 
     * @return
     */
    private boolean isInterpolated(String v) {
    	return !v.contains("${");
    }

    /**
     * Get the current date in the specified format.
     * 
     * @param format
     * @return
     */
    public String getCurrentDate(String format) {
		DateFormat df = new SimpleDateFormat(format,Locale.UK);
		return df.format(System.currentTimeMillis());
	}

	public boolean forceCompile() {
		return forceCompile;
	}

	/**
	 * Check if a release may be created in the output folder.
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 * 
	 */
	public boolean prepareRelease() throws IOException, ConfiguratorException {
		String ph = getXParm("appinfo/previous-phase",false);
		String ts = getXParm("appinfo/previous-task",false);
		String er = getXParm("appinfo/previous-errors",false);
		
		if (
				ph != null && ph.equals("3") && 
				ts != null && ts.equals("release") && 
				er != null && er.equals("0") && 
				!docRelease
			) {
			runner.error(logger, "Cannot replace a final release");
			runner.setMayRelease(false);
			return false;
		} else {
			if (runner.isFinal())
				runner.info(logger,"+++ Building final release, overriding any restriction settings +++");
			runner.setMayRelease(true);
			return true;
		}
	}

	@SuppressWarnings("static-access")
	public void createOption(String stepName, String longKey, String description, String argKey, Boolean isRequired) throws Exception {
		if (longKey == null) throw new Exception("Missing option \"name\" in step " + stepName);
		if (description == null) throw new Exception("Missing option \"tip\" in step " + stepName);
		if (argKey == null) throw new Exception("Missing option \"arg\" in step " + stepName);
		if (isRequired == null) throw new Exception("Missing option \"required\" in step " + stepName);
		boolean hasArg = (argKey != null); 
		Option option;
		option = OptionBuilder
				.withDescription(description)
				.hasArg(hasArg)
				.withArgName(argKey)
				.create(longKey);
		// Options are not required for the cli processor; they are required in the chain.
		// So declare all parameters as optional and let every test check if the parameter is actually set
		// Note that this is because there is no way a parameter file can be read dynamically within the commonc CLI module. 
		// TODO check required parameters of replace commons CLI interface package
		option.setRequired(false);
		setOptionIsReady(longKey,!isRequired);
		options.addOption(option);
		
		// store the option to the configurator for final reporting
		writeCli(stepName,longKey,description,argKey,isRequired);
		
	}
	
	public void createOption(String stepName, String shortKey, String longKey, String description, String argKey, boolean isRequired) throws Exception {
		createOption(stepName, longKey, description, argKey, isRequired);
	}
	
	private void writeCli(String stepName, String longKey, String description, String argKey, Boolean isRequired) {
			int messageIndex = workConfiguration.getMaxIndex("clispecs/clispec") + 2;   // -1 when no messages.
			workConfiguration.addProperty("clispecs/clispec", "");
			workConfiguration.addProperty("clispecs/clispec[" + messageIndex + "]/stepName", stepName);
			workConfiguration.addProperty("clispecs/clispec[" + messageIndex + "]/longKey", longKey);
			workConfiguration.addProperty("clispecs/clispec[" + messageIndex + "]/description", description);
			workConfiguration.addProperty("clispecs/clispec[" + messageIndex + "]/argKey", argKey);
			workConfiguration.addProperty("clispecs/clispec[" + messageIndex + "]/isRequired", isRequired);
	}
	
	/**
	 * Retrieve the cli parameters from the configuration file. 
	 * These are specified as &lt;cli-parm&gt; within the XML specification.
	 * This method is typically called for each step in the chain before the chain processed is started.
	 * 
	 * @param stepName 
	 * 	The formal name of the step, as defined by the step itself.  
	 * 	This step name occurs in the setup of Java, cfg en xsl folders.
	 * 
	 * @throws Exception
	 */
	public void getCli(String stepName) throws Exception {
		// Iterate over all CLI options as declared in the step configuration file
		XmlFile cfg = getStepConfigFile(stepName);
		
		NodeList cliparms = (NodeList) cfg.xpathToObject("/config/cli-parms/cli-parm", null, XPathConstants.NODESET);
		// iterate over the parameters
		for (int i = 0; i < cliparms.getLength(); ++i) {
			NodeList parms = cliparms.item(i).getChildNodes();
			String name = null;
			String arg = null;
			String tip = null;
			boolean required = false;
			// iterate over the properties
			for (int j = 0; j < parms.getLength(); ++j) {
				String cname = parms.item(j).getNodeName(); 
				String cvalue = parms.item(j).getTextContent();
				switch (cname) {
					case "name" : name = cvalue; break; 
					case "arg" : arg = cvalue;  break;
					case "tip" : tip = cvalue; break;
					case "required" : required = cvalue.equals("true"); break;
				}
			}
			// and create the cli parameter from these settings
			createOption(stepName, name, tip, arg, required);
			
		}
	}
	
	private void dieOnCli(String infotype) throws Exception {
		HelpFormatter formatter = new HelpFormatter();
		int width = 118;
		int leftpad = 2;
		int descpad = 4;
		
		if (infotype.equals("program")) {
			formatter.printHelp( pw, width, "Imvertor -param [value] (-param [value]...)", "Imvertor", options ,leftpad, descpad, "");
		} else	if (infotype.equals("license")) {
			formatter.printWrapped( pw, width, "The following information is shown because you specified -help license at the command line.");
			formatter.printWrapped( pw, width, "");
			formatter.printWrapped( pw, width, Release.getDetails());
			formatter.printWrapped( pw, width, "");
			formatter.printWrapped( pw, width, "Imvertor exits.");
		} else { // assume "error"
			formatter.printWrapped( pw, width, "Error occurred processing the command line. ");
			formatter.printWrapped( pw, width, "Please specify:\nImvertor -param [value] (-param [value]...)");
			formatter.printWrapped( pw, width, "Pass -help program for an overview of all program parameters.");
			formatter.printWrapped( pw, width, "Imvertor exits.");
		} 
			
		pw.flush();
		System.exit(0);
	}
	
	/** 
	 * Record an option to be required. 
	 * This is not handled by common CLI but by the configurator, as the configurator also has access to the property files passed as -argument on the command line.
	 * 
	 * @param optionName
	 */
	private void setOptionIsReady(String optionName, Boolean isReady) {
		requiredOption.put(optionName,isReady);
	}
	
	/**
	 * Check if all options are ready; that is, if all required options are associated with true.
	 * Return the names of all options not set but required, delimited by space.
	 * 
	 */
	private String checkOptionsAreReady() {
		String r = "";
		Iterator<String> iterator = requiredOption.keySet().iterator();
		while (iterator.hasNext()) {
			String key = iterator.next();
			Boolean ready = requiredOption.get(key);
			if (!ready) r += key + " ";
		}
		return r;
	}

	public void setStepDone(String step) throws IOException, ConfiguratorException{
		setParm("step-done", step, "true");
		xParmLogger.closeOrigin();
	}
	public boolean getStepDone(String step) throws IOException, ConfiguratorException {
		return isTrue(getParm("step-done", step, false));
	}

	public boolean getSuppressWarnings() {
		return suppressWarnings;
	}
	
	/**
	 * OASIS catalog support: get URI resolver based on OASIS catalog file.
	 * 
	 * Mapping are set using configurator.addCatalogMap().
	 * 
	 * @return CatalogResolver
	 * @throws IOException
	 * @throws ConfiguratorException 
	 * @throws CatalogException 
	 */
	public CatalogResolver getUriResolver() throws IOException, ConfiguratorException, CatalogException {
		
		CatalogManager cm = CatalogManager.getStaticManager();
		cm.setIgnoreMissingProperties(true);
		
		Catalog c = cm.getCatalog();
		
		Iterator<String> keys = catalogMap.keySet().iterator();
		while (keys.hasNext()) {
			String key = keys.next();
			Vector<String> v = new Vector<String>();
			v.add(key);
			v.add(catalogMap.get(key));
			CatalogEntry e = new CatalogEntry("URI", v);
			c.addEntry(e);
			// and remove from the entry list; it is now known and retained in the catalog vector, which is global to this run.
			catalogMap.remove(key);
		}
		return new CatalogResolver(cm);
	}
	
	/**
	 * Add a mapping from a name to an URI in the catalog.
	 * 
	 * @param name
	 * @param uri
	 */
	public void addCatalogMap(String name, String uri) {
		catalogMap.put(name,uri);
	}
	
	/**
	 * Get the run mode (run or development)
	 */
	public Integer getRunMode() {
		return runmode; 
	}

	public boolean isEaEnabled() {
		return eaEnabled;
	}
	/**
	 * Merge parameters into a string, parameters taken by default from appinfo section of the parms.xml; otherwise use [group/name] syntax.
	 * 
	 * @param template
	 * @return
	 */
	public String mergeParms(String template) {
		String[] parts = StringUtils.splitPreserveAllTokens(template,"[]");
		String result = "";
		for (int i = 0; i < parts.length; i++) {
			if (i % 2 == 0) { // even locations are strings
				result += parts[i];
			} else 
				if (!parts[i].equals("")) { // uneven are (group and) name
					try {
						String[] subs = StringUtils.splitPreserveAllTokens(parts[i],"/");
						String group = null;
						String name = null;
						if (subs.length == 1) {
							group = "appinfo";
							name = subs[0];
						} else if (subs.length == 2) {
							group = subs[0];
							name = subs[1];
						} else {
							runner.fatal(logger, "Invalid reference to property: [" + parts[i] + "]", null, "IRTP1");
						}
						// this is a name, extract from declared application parameters
						String val = getParm(group, name,false);
						if (val == null) val = "[" + parts[i] + "]";
						result += val;
					} catch (Exception e) {
						result += parts[i];
					}
			}
		}
		return result;
	}

	/**
	 * Get the system resource i.. in the resources folder.
	 * 
	 * @param name
	 * @return
	 */
	public File getResource(String subpath) {
		return new File(Configurator.getInstance().getBaseFolder(),subpath);
	}
	
	public XparmLogger getxParmLogger() {
		return xParmLogger;
	}
	public XsltCallLogger getXsltCallLogger() {
		return xsltCallLogger;
	}

	public String getCurrentStepName() {
		return currentStepName;
	}

	private Properties getProperties(File file) throws IOException {
		Properties properties = new Properties();
		FileInputStream s = new FileInputStream(file);
		BufferedReader in = new BufferedReader(new InputStreamReader(s, "UTF-8"));
		properties.load(in); 
		s.close();
		return properties;
	}

	private void getServerProperties() throws IOException {
		String basefolder = (runmode == RUN_MODE_DEVELOPMENT) ? (new File(".")).getCanonicalPath() : System.getenv("imvertor_os_basefolder");
		File propsFile = new File(basefolder + "/server.properties");
		serverProperties = getProperties(propsFile);
	}

	public String getServerProperty(String key) throws IOException {
		if (serverProperties == null) getServerProperties();
		return serverProperties.getProperty(key);
	}
}
