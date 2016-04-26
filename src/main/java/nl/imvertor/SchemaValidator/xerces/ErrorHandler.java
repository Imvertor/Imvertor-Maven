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

package nl.imvertor.SchemaValidator.xerces;

import java.util.Iterator;
import java.util.Vector;

import org.apache.xerces.xni.parser.XMLParseException;

public class ErrorHandler {

	Vector<ErrorHandlerMessage> errors;
	Boolean quiet = false;
	
	public ErrorHandler(Boolean quiet) {
		this.errors = new Vector<ErrorHandlerMessage>();
		this.quiet = quiet;
	}
	
	public void genericMessage(String type, String arg0, String arg1, XMLParseException arg2) {
		ErrorHandlerMessage m = new ErrorHandlerMessage();
		m.file = arg2.getExpandedSystemId();
		m.line = arg2.getLineNumber();
		m.column = arg2.getColumnNumber();
		m.message = arg2.getLocalizedMessage();
		m.type = type;
		m.context = arg0;
		m.code = arg1;
		errors.add(m);
		if (!quiet) show(m); 
	}
	
	public void show(ErrorHandlerMessage m) {
		System.out.println(m.type + ": " + m.message + ", in file: " + m.file + " [" + m.line + "," + m.column + "]");
	}

	public void showAll() {
		Iterator<ErrorHandlerMessage> it = errors.iterator();
		while (it.hasNext()) {
			show(it.next());
		}
	}
	
	public Vector<ErrorHandlerMessage> getErrors() {
		return errors;
	}
}


