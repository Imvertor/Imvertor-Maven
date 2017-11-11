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
import nl.imvertor.common.file.XmlFile;

/**
* Saxon Extension function that serializes a folder to an XML representation.
* The arguments are 
* 1/ the folder to serialize, 
* 2/ the path to the result xml file
* 3/ the info string that determines which info to store in the XML (constraints)
*  
* The extension function returns the full path to the resulting xml file.
* 
* @author arjan
*
*/
public class ImvertorFolderSerializer extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorFolderSerializer");

	public StructuredQName getFunctionQName() {
		return qName;
	}

	public int getMinimumNumberOfArguments() {
		return 3;
	}

	public int getMaximumNumberOfArguments() {
		return 3;
	}

	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { 
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING
		};
	}

	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.STRING_SEQUENCE;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new ImvertorFolderSerializerCall();
	}

	private static class ImvertorFolderSerializerCall extends ExtensionFunctionCall {

		public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {

			try {
				String folderpath = Transformer.getStringvalue(arguments[0]);
				String filepath = Transformer.getStringvalue(arguments[1]);
				// TODO add this for speed: constraint to specific file info
				//String constraints = Transformer.getStringvalue(arguments[2]);
				
				if (filepath.startsWith("file:/")) filepath = filepath.substring(6);
				if (folderpath.startsWith("file:/")) folderpath = folderpath.substring(6);
				
				AnyFolder serializeFolder = new AnyFolder(folderpath);
				XmlFile xmlFile = new XmlFile(filepath);
				serializeFolder.setSerializedFilePath(xmlFile.getCanonicalPath());
			    serializeFolder.serializeToXml();
			    
				return StringValue.makeStringValue(xmlFile.getCanonicalPath());
			} catch (Exception e) {
				throw new XPathException(e);
			}
		}
		
	}
}
//