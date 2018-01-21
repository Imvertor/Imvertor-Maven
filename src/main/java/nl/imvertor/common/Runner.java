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

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;
import java.util.Stack;

import org.apache.commons.configuration2.ex.ConfigurationException;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import nl.imvertor.common.exceptions.ConfiguratorException;
import nl.imvertor.common.file.AnyFile;

/**
 * The Runner is an object that represents all state information of a single run.
 * 
 * A runner is associated with a configurator.  
 * 
 * @author arjan
 *
 */
public class Runner {

	protected static final Logger logger = Logger.getLogger(Runner.class);
	
	public static final String VC_IDENTIFIER = "$Id: Runner.java 7498 2016-04-15 07:51:23Z arjan $";
	
	public static final Integer APPLICATION_PHASE_UNKNOWN = -1;
	public static final Integer APPLICATION_PHASE_CONCEPT = 0;
	public static final Integer APPLICATION_PHASE_DRAFT = 1;
	public static final Integer APPLICATION_PHASE_FINALDRAFT = 2;
	public static final Integer APPLICATION_PHASE_FINAL = 3;
	
	private int imvertorErrors = 0;
	private int imvertorWarnings = 0;

	private Boolean debugging = false;
	private String[] debugmodes = new String[0]; // debugmodes are codes; initially empty.
	
	private Integer appPhase = APPLICATION_PHASE_UNKNOWN;
	private Boolean mayRelease = true;

	private boolean internetAvailable = false;
	
	private Messenger messenger;
	
	private FileWriterWithEncoding trackerFileWriter;
	
	public static Stack<String> steps; 
	
	public Runner() {
		super();
	}
	
	/**
	 * Prepare the environment for the run. 
	 * 
	 * Clears the work folder.
	 * 
	 */
	public void prepare() {
		// remove pre-existing work folder; create new one. Keep existing xmi folder!
		File wf = Configurator.getInstance().getWorkFolder();
		if (wf.isDirectory()) {
			FileUtils.deleteQuietly(new File(wf, "imvert"));
			FileUtils.deleteQuietly(new File(wf, "doc"));
			FileUtils.deleteQuietly(new File(wf, "report"));
			FileUtils.deleteQuietly(new File(wf, Configurator.PARMS_FILE_NAME));
			FileUtils.deleteQuietly(new File(wf, Configurator.TRACK_FILE_NAME));
		} else {
			wf.mkdirs();
		}
	}
	
	/**
	 * Set the messenger for this runner.
	 * 
	 * @param messenger The messenger, usually as configured for the configurator.
	 * 
	 */
	public void setMessenger(Messenger messenger) {
		this.messenger = messenger;
	}
	
	/**
	 * Windup this run.
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public void windup() throws IOException, ConfiguratorException {
		if (imvertorErrors < 0)
			info(logger, "Task fails. Please contact your system administrator.");
		else {
			if (imvertorErrors == 0) 
				if (imvertorWarnings == 0)
					info(logger, "Task succeeds.");
				else
					info(logger, "Task succeeds with warnings.");
			else 
				if (imvertorWarnings == 0)
					info(logger, "Task fails with errors.");
				else
					info(logger, "Task fails with errors and warnings.");
		}
	}
	
	/**
	 * Determine if the run up to this point succeeds. 
	 * 
	 * This implies that are are no error conditions.
	 * These are reported in messages within the configuration, typically introduced within XSL stylesheets.  
	 * 
	 * @return
	 * @throws Exception 
	 */
	public boolean succeeds() throws Exception {
		return Configurator.getInstance().forceCompile() || (getFirstErrorText() == null && imvertorErrors <= 0);
	}

	/**
	 * Set the application phase; this is either 0, 1, 2 or 3.
	 * 
	 * @return
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public Integer getAppPhase() throws IOException, ConfiguratorException {
		if (appPhase == -1) {
			appPhase = 0;
			String phase = Configurator.getInstance().getXParm("appinfo/phase",false);
			try {appPhase = (phase != null) ? Integer.parseInt(phase) : appPhase;} catch (NumberFormatException e) {};
		}
		return appPhase;
	}
	
	/**
	 * Return true when this is a final release. 
	 * A final release is in release task (i.e. not compile only), the application is in phase 3, and not in debugging mode.
	 * 
	 * @return True when this is a final release.
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public boolean isFinal() throws IOException, ConfiguratorException {
		return appPhase == APPLICATION_PHASE_FINAL && !debugging && getReleasing();
	}		
	
	/**
	 * Return true when debugging in any of the modes passed.
	 * 
	 * @return
	 */
	public boolean getDebug(String viableMode) {
		return debugging && checkDebugmode(viableMode);
	}	
	
	/**
	 * Return true when debugging (in any mode).
	 * 
	 * @return
	 */
	public boolean getDebug() {
		return debugging;
	}	
	

	/**
	 * 
	 * @throws IOException
	 * @throws ConfiguratorException
	 * @throws ConfigurationException
	 */
	public void setDebug() throws IOException, ConfiguratorException, ConfigurationException {
		debugging = Configurator.getInstance().isTrue("cli","debug");
		// debug is stored in debugmode
		if (debugging) {
			String debugmode = Configurator.getInstance().getXParm("cli/debugmode"); // a string separated list of codes
			debugmodes = StringUtils.split(debugmode.replace(" ", ""),';');
		}
	}	
	/**
	 * Check if the debug mode allows the system (java chain) to produce a debug message. 
	 * When no debug modes specified, succeed.  
	 * When #ALL is specified, succeed.
	 * 
	 * @return
	 */
	private boolean checkDebugmode(String viableMode) {
		if (debugmodes.length == 0) return true;
		for (int i = 0; i < debugmodes.length; i++) {
			if (debugmodes[i].equals("#ALL")) return true;
			if (debugmodes[i].equals(viableMode)) return true; 
		}
		return false;
	}	
	
	
	/**
	 * Return true when this app should be released.
	 * This is determined by the cli parameter "task".
	 * 
	 * @return
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public Boolean getReleasing() throws IOException, ConfiguratorException {
		String r = Configurator.getInstance().getXParm("cli/task",false);
		return (r == null) ? false : r.equals("release");
	}
	
	public void setMayRelease(boolean may) {
		mayRelease = may;
	}
	
	public Boolean getMayRelease() {
		return mayRelease;
	}
	
	/**
	 * The ERROR level designates error events that might still allow the application to continue running.
	 * Pass an Exception which information is added to the log.
	 * 
	 * Such process information is logged and/or show in screen when configured as such.
	 *  
	 * @param logger
	 * @param text
	 * @param e
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public void error(Logger logger, String text, Exception e, String id, String wiki) throws IOException, ConfiguratorException {
		imvertorErrors += 1;
		Configurator.getInstance().setXParm("system/error-count", String.valueOf(imvertorErrors),true);
		messenger.writeMsg(logger.getName(), "ERROR", "", text, id, wiki);
		logger.error(text,e);
	}
	public void error(Logger logger, String text, Exception e) throws IOException, ConfiguratorException {
		error(logger, text, e, null, null);
	}
	/**
	 * The ERROR level designates error events that might still allow the application to continue running.
	 * 
	 * Such process information is logged and/or show in screen when configured as such.
	 *  
	 * @param logger
	 * @param text
	 * @param e
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public void error(Logger logger, String text, String id, String wiki) throws IOException, ConfiguratorException {
		imvertorErrors += 1;
		Configurator.getInstance().setXParm("system/error-count", String.valueOf(imvertorErrors),true);
		messenger.writeMsg(logger.getName(), "ERROR", "", text, id, wiki);
		logger.error(text);
	}
	public void error(Logger logger, String text) throws IOException, ConfiguratorException {
		imvertorErrors += 1;
		Configurator.getInstance().setXParm("system/error-count", String.valueOf(imvertorErrors),true);
		messenger.writeMsg(logger.getName(), "ERROR", "", text, null,null);
		logger.error(text);
	}

	/**
	 * The WARN level designates potentially harmful situations.
	 * 
	 * Such process information is logged and/or show in screen when configured as such.
	 *  
	 * @param logger
	 * @param text
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public void warn(Logger logger, String text, String id, String wiki) throws IOException, ConfiguratorException {
		imvertorWarnings += 1;
		Configurator.getInstance().setXParm("system/warning-count", String.valueOf(imvertorWarnings),true);
		messenger.writeMsg(logger.getName(), "WARN", "", text, id, wiki);
		logger.warn(text);
	}
	public void warn(Logger logger, String text) throws IOException, ConfiguratorException {
		warn(logger, text, null,null);
	}
	/**
	 * The INFO level designates informational messages that highlight the progress of the application at coarse-grained level.
	 * 
	 * Such process information is logged and/or show in screen when configured as such.
	 *  
	 * @param logger
	 * @param text
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public void info(Logger logger, String text) throws IOException, ConfiguratorException {
		info(logger,text,false);
	}
	
	public void info(Logger logger, String text, boolean store) throws IOException, ConfiguratorException {
		logger.info(text);
		if (store) messenger.writeMsg(logger.getName(), "INFO", "", text);
		track(text);
	}
	
	/**
	 * The DEBUG Level designates fine-grained informational events that are most useful to debug an application.
	 * 
	 * Such process information is logged and/or show in screen when configured as such.
	 *  
	 * The viableMode is a mode used to select relevant debug messages. For the regular chain this is CHAIN.
	 *   
	 * @param logger
	 * @param text
	 */
	public void debug(Logger logger, String viableMode, String text) {
		if (getDebug(viableMode)) {
			messenger.writeMsg(logger.getName(), "DEBUG", "", text, null,null);
			logger.debug(text);
		}
	}
	/**
	 * The TRACE Level designates finer-grained informational events than the DEBUG
	 * 
	 * Such process information is logged and/or show in screen when configured as such.
	 *  
	 * @param logger
	 * @param text
	 */
	public void trace(Logger logger, String text) {
		logger.trace(text);
	}
	/**
	 * The FATAL level designates very severe error events that will presumably lead the application to abort.
	 * 
	 * Such process information is logged and/or show in screen when configured as such.
	 *  
	 * For Imvertor, fatal errors abort all processing.
	 * 
	 * @param logger
	 * @param text
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public void fatal(Logger logger, String text, Exception e, String id, String wiki)  {
		try {
			imvertorErrors += 1;
			Configurator.getInstance().setXParm("system/error-count", String.valueOf(imvertorErrors),true);
			messenger.writeMsg(logger.getName(), "FATAL", "", text, id, wiki);
			logger.fatal(text);
			info(logger, "");
			info(logger, "Must stop.");
			info(logger, "Please contact your system administrator.");
			info(logger, "");
			logger.fatal("Details on the error", e);
		} catch (Exception ex) {
			// Do not handle exception
		}
		System.exit(0); // TODO must be -1, see mail "exec:exec-external met exitcode -1"
	}
	public void fatal(Logger logger, String text, Exception e, String wiki)  {
		fatal(logger, text, e, null, wiki);
	}
	/**
	 * Tracker intended for external applications, keeping track of states the process is in. 
	 * Typically read in parallel, focussing on the last line.
	 *  
	 * @param logger
	 * @param text
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public void track(String text) throws IOException, ConfiguratorException {
		try {
			String fulltext = Configurator.getInstance().runtimeForDisplay() + " - " + text;
			AnyFile tf = Configurator.getInstance().getTrackerFile();
			if (tf != null) {
				if (trackerFileWriter == null) {
					trackerFileWriter = tf.getWriterWithEncoding("UTF-8", true);
				}
				trackerFileWriter.append(fulltext + System.lineSeparator());
				trackerFileWriter.flush();
			}
		} catch (Exception e) {
			fatal(logger, "Cannot track", e, "WIKISTUB");
		}
	}
	
	public void msg(String type, String text) {
		messenger.writeMsg(logger.getName(), type, "", text);
	}
	

	
	/*
	 * return a count of all errors found
	 * 
	 */
	public int getErrorCount() throws Exception {
		return getErrorTexts(null).size();
	}
	/**
	 * Return the first transformation error on the last processed stylesheet.
	 * 
	 */
	public String getFirstErrorText() throws Exception {
		return getFirstErrorText(null);
	}
	
	/**
	 * Return the first transformation error on the stylesheet passed by name.
	 * 
	 * The "name" of a stylesheet is the file name.
	 * 
	 */
	public String getFirstErrorText(String stylesheetName) throws Exception {
		List<Object> et = getErrorTexts(stylesheetName);
		return (et.size() == 0) ? null : et.get(0).toString();   
	}
	
	/**
	 * Return all errors (ERROR, FATAL) that originate in the stylesheet passed by name. 
	 * This has the form of an array of strings.
	 * When null stylesheet name passed, return all errors.
	 * 
	 * @throws Exception 
	 */
	private List<Object> getErrorTexts(String stylesheetName) throws Exception {
		String condition = (stylesheetName != null) ? "[src='" + stylesheetName + "']" : "";
		return Configurator.getInstance().getXmlConfiguration().getList("messages/message" + condition + "/type[. = 'ERROR' or . = 'FATAL']");
	}

	// TODO suppress warnings werkt nog niet; waarom de warnings aan het einde op 0?
	public boolean hasWarnings() {
		return imvertorWarnings > 0;
	}
	
	/**
	 * Try to access the internet. If this is not possible, try proxy. If not possible, record the internet as unavailable.
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 * @throws Exception
	 */
	public boolean activateInternet() throws IOException, ConfiguratorException {
		if (!internetAvailable) {
			debug(logger,"CHAIN", "Try internet connection");
			
			String proxyTestUrl = Configurator.getInstance().getXParm("cli/proxyurl");
			
			URL address = new URL(proxyTestUrl);
			try {
				URLConnection con = address.openConnection();
				con.getContentType();
			} catch (Exception e) {
				internetAvailable = false;
				debug(logger,"CHAIN", "No accessible internet connection detected");
			}
			internetAvailable = true;
		}
		return internetAvailable;
	}
	
}
