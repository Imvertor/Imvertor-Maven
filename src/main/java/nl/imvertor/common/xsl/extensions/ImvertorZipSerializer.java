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

package nl.imvertor.common.xsl.extensions;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFolder;
import nl.imvertor.common.file.ZipFile;

/**
* Saxon Extension function that serializes a zip file to a folder, providing access to all XML files in the ZIP in a single XML file.
* The serialized zip may be transformed and deserialized.
* This is especually useful for processing Excel, Office and ODF files. 
* The argument is the zip file to extract. 
* The extension function returns the full path to a temporary folder holding the file contents.
* 
* @author arjan
*
*/
public class ImvertorZipSerializer extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorZipSerializer");

	public StructuredQName getFunctionQName() {
		return qName;
	}

	public int getMinimumNumberOfArguments() {
		return 2;
	}

	public int getMaximumNumberOfArguments() {
		return 2;
	}

	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { 
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING
		};
	}

	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.STRING_SEQUENCE;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new ImvertorZipSerializerCall();
	}

	private static class ImvertorZipSerializerCall extends ExtensionFunctionCall {

		public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {

			try {
				String filepath = Transformer.getStringvalue(arguments[0]);
				String folderpath = Transformer.getStringvalue(arguments[1]);
				if (filepath.startsWith("file:/"))
					filepath = filepath.substring(6);
				ZipFile zipFile = new ZipFile(filepath);
				AnyFolder serializeFolder = new AnyFolder(folderpath); 
			    zipFile.serializeToXml(serializeFolder);
				return StringValue.makeStringValue(serializeFolder.getCanonicalPath());
			} catch (Exception e) {
				throw new XPathException(e);
			}
		}
		
	}
}
//