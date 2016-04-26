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
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.ExcelFile;
import nl.imvertor.common.file.XmlFile;

/**
* Saxon Extension function that serializes an Excel 1997-2003 file to a result XML file, rooted in a <workbook> element.
* First argument is the Excel path. 
* Second argument is the result file.
* Third argument is path to the DTD for workbooks.
* The extension function returns the full path of the XML file.
* 
* @author arjan
*
*/
public class ImvertorExcelSerializer extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorExcelSerializer");

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
		return new ImvertorZipSerializerCall();
	}

	private static class ImvertorZipSerializerCall extends ExtensionFunctionCall {

		public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {

			try {
				String filepath = Transformer.getStringvalue(arguments[0]);
				String xmlpath = Transformer.getStringvalue(arguments[1]);
				String dtdpath = Transformer.getStringvalue(arguments[2]);
				ExcelFile excelFile = new ExcelFile(filepath);
				XmlFile xmlFile = new XmlFile(xmlpath);
				AnyFile dtdFile = new AnyFile(dtdpath);
			    if (!excelFile.isFile()) throw new Exception("Not a file: " + excelFile.getCanonicalPath());
			    if (!dtdFile.isFile()) throw new Exception("Not a file: " + dtdFile.getCanonicalPath());
			    xmlFile.getParentFile().mkdirs();
				excelFile.toXmlFile(xmlpath, dtdpath);
				return StringValue.makeStringValue(xmlFile.getCanonicalPath());
			} catch (Exception e) {
				throw new XPathException(e);
			}
		}
		
	}
}
//