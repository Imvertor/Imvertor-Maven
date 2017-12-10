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


/**
 * This class represents the release info on Imvertor.
 *  
 * @author Arjan
 *
 */
public class Release {
	// TODO determine a valid version identifier based on all resources, i.e. java and XSLT 
	
	// change version number manually here, on each adaptation made in the imvertor sources! 
	private static String imvertorVersion = "Imvertor OS 1.36.3"; 
	
	private static String imvertorSVNVersion = val("$Id: Release.java 7503 2016-04-15 14:46:57Z arjan $");
	
	public static String getVersion() {
		return imvertorVersion;
	}
	
	public static String getVersionString() {
		return imvertorVersion;
	}
	
	public static String getReleaseString() {
		return imvertorSVNVersion;
	}
	
	private static String val(String svnString) {
		return svnString.substring(svnString.indexOf(" ") + 1, svnString.length() - 2);
	}
	
	public static String getNotice() {
		return 
				"Copyright (C) 2016,2018 Dienst voor het Kadaster en de openbare registers.\n" 
				+ "This program comes with ABSOLUTELY NO WARRANTY; for details pass -help program.\n" 
				+ "This is free software, and you are welcome to redistribute it " 
				+ "under certain conditions; pass -help license for full details.\n";
	}
	
	public static String getDetails() {
		return 
				"Imvertor is free software: you can redistribute it and/or modify "
				+ "it under the terms of the GNU General Public License as published by "
				+ "the Free Software Foundation, either version 3 of the License, or "
				+ "(at your option) any later version.\n"
				+ "\n"
				+ "Imvertor is distributed in the hope that it will be useful, "
				+ "but WITHOUT ANY WARRANTY; without even the implied warranty of "
				+ "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the "
				+ "GNU General Public License for more details.\n"
				+ "\n"
				+ "A copy of the GNU General Public License is placed in install folder.";
	}
}
