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

package nl.imvertor.common.file;

import java.io.File;
import java.io.IOException;
import java.util.Vector;

import nl.imvertor.SchemaValidator.xerces.ErrorHandler;
import nl.imvertor.SchemaValidator.xerces.ErrorHandlerMessage;
import nl.imvertor.SchemaValidator.xerces.XMLGrammarBuilder;

import org.apache.log4j.Logger;
import org.apache.xerces.xni.XNIException;

public class XsdFile extends XmlFile {

	private static final long serialVersionUID = -3939175124241905868L;
	
	protected static final Logger logger = Logger.getLogger(XsdFile.class);
	
	public XsdFile(File file) throws XNIException, IOException {
		super(file);
	}

	/*
	 * Validate the schema in this file.
	 */
	public Vector<ErrorHandlerMessage> validateGrammar(Boolean quiet, Boolean setHonourAllSchemaLocations, Boolean setSchemaFullChecking) throws Exception {
		XMLGrammarBuilder gb = new XMLGrammarBuilder(quiet);
		gb.setHonourAllSchemaLocations(setHonourAllSchemaLocations);
		gb.setSchemaFullChecking(setSchemaFullChecking);
		gb.parseXSD(this.getCanonicalPath());
		ErrorHandler e = gb.getErrorHandler();
		return e.getErrors();
	}
	
}
