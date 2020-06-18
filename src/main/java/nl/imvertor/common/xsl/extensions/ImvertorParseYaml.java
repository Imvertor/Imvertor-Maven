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

import java.io.File;

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
import nl.imvertor.common.file.XmlFile;
import nl.imvertor.common.file.YamlFile;

/**
* Saxon Extension function that serializes a yaml file to a single XML string. 
* The XML string can be read using parse-xml().
* 
* @author arjan
*
*/
public class ImvertorParseYaml extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorParseYaml");

	public StructuredQName getFunctionQName() {
		return qName;
	}

	public int getMinimumNumberOfArguments() {
		return 1;
	}

	public int getMaximumNumberOfArguments() {
		return 1;
	}

	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { 
				SequenceType.SINGLE_STRING
		};
	}

	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.STRING_SEQUENCE;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new ImvertorParseYamlCall();
	}

	private static class ImvertorParseYamlCall extends ExtensionFunctionCall {

		public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {

			try {
				String filepath = Transformer.getStringvalue(arguments[0]);
				if (filepath.startsWith("file:/"))
					filepath = filepath.substring(6);
				YamlFile yamlFile = new YamlFile(filepath);
				XmlFile xmlFile = new XmlFile(File.createTempFile("ImvertorParseYamlCall.", ".xml"));
				yamlFile.toXml(xmlFile);
				return StringValue.makeStringValue(xmlFile.getContent());
			} catch (Exception e) {
				throw new XPathException(e);
			}
		}
		
	}
}
//