/*
\ * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
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
import java.util.Properties;

import org.apache.commons.lang3.StringUtils;

import nl.imvertor.common.file.XmlFile;

/**
 * This class represents the release info on Imvertor.
 *  
 * @author Arjan
 *
 */
public class Release {
	// TODO determine a valid version identifier based on all resources, i.e. java and XSLT 
	
	// change version number manually here, on each adaptation made in the imvertor sources! 
	private static XmlFile imvertorVersionInfo; 
	private static Properties imvertorBuildInfo; 
	
	private static String imvertorSVNVersion = val1("$Id: Release.java 7503 2016-04-15 14:46:57Z arjan $");
	
	private static void loadVersionInfo() throws IOException {
		Configurator configurator = Configurator.getInstance();
		
		if (imvertorVersionInfo == null) {
			imvertorVersionInfo = new XmlFile(configurator.getBaseFolder(), "static/release/release.xml");
		}
		if (imvertorBuildInfo == null) {
			File propFile = new File(configurator.getBaseFolder().getParent(),"build.properties");
			if (propFile.exists()) // may not exists outside of build process of Imvertor as intended by nightly build.
				imvertorBuildInfo = configurator.getProperties(propFile);
			else
				imvertorBuildInfo = new Properties();
		}
	}
	
	public static String getVersionString(String artifact) throws Exception {
		loadVersionInfo();
		
		// release is set by build process or oitherwise read from release.xml. 
		String release = imvertorBuildInfo.getProperty("release");
		if (release == null)
			release = 
				imvertorVersionInfo.xpath("/release-info/release[artifact = '" +artifact+ "']/major-minor")
				+ "." +
				imvertorVersionInfo.xpath("/release-info/release[artifact = '" +artifact+ "']/bugfix");
		
		// Add version adornment, such as "EVALUATION VERSION"
		String va = System.getProperty("version.adornment");
		if (va != null && !va.equals(""))
			release += " - " + va;

		return release;
	}
	
	public static String getReleaseString() {
		return imvertorSVNVersion;
	}
	
	private static String val1(String svnString) {
		return svnString.substring(svnString.indexOf(" ") + 1, svnString.length() - 2);
	}
	private static String val2(String String) {
		return StringUtils.replacePattern(String, "((^|\n)(\u0020|\t)+)|((\u0020|\t)+($|\n))","\n");
	}
	
	public static String getNotice() throws Exception {
		loadVersionInfo();
		return val2(imvertorVersionInfo.xpath("/release-info/release[artifact = 'Imvertor']/notice"));
	}
	
	public static String getDetails() throws Exception {
		loadVersionInfo();
		return val2(imvertorVersionInfo.xpath("/release-info/release[artifact = 'Imvertor']/details"));
	}
}
