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

import nl.imvertor.common.file.XslFile;
import nl.imvertor.common.xsl.extensions.ImvertorGetUUID;

public class XmiUpgrade {

	public static void main(String[] args) throws Exception {
		
		cleanup();
	}

	static void upgrade() throws Exception {
		XslFile stylesheet = new XslFile("xsl/tools/XmiUpgrade/XmiUpgrade.xsl");
		stylesheet.setExtensionFunction(new ImvertorGetUUID());
		stylesheet.transform(
				"input/XmiUpgrade/CDMKAD-xmi-2.1.xml", 
				"input/XmiUpgrade/CDMKAD-xmi-2.1.result.xml");
		System.out.println("done");
	}
	
	static void cleanup() throws Exception {
		XslFile stylesheet = new XslFile("xsl/tools/XmiUpgrade/XmiCleanup.xsl");
		stylesheet.setExtensionFunction(new ImvertorGetUUID());
		stylesheet.transform(
				"input/XmiUpgrade/CDMKAD-1.8-4-export.xmi", 
				"input/XmiUpgrade/CDMKAD-1.8-4-export-result.xmi");
		System.out.println("done");
	}
}
