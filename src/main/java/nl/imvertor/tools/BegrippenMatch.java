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

package nl.imvertor.tools;

import java.util.HashMap;

import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.XslFile;

public class BegrippenMatch {

	public static void main(String[] args) throws Exception {
		
		match();
	}	
	
	static void match() throws Exception {
		XslFile stylesheet = new XslFile("xsl/tools/BegrippenMatch/BegrippenMatch.xsl");
		HashMap<String,String> map = stylesheet.getInitialParms();
		map.put("kenniskluis-file-path", (new XmlFile("input/BegrippenMatch/concepts-20160401.xml")).toURI().toString());
		map.put("kenniskluis-namemap-file-path", (new XmlFile("input/BegrippenMatch/BegrippenMatch.config.xml")).toURI().toString());

		stylesheet.transform(
				"input/BegrippenMatch/system.imvert.xml", 
				"input/BegrippenMatch/begrippen.html");
		System.out.println("done");
	}
}
