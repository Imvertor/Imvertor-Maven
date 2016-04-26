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

/*
 * Compare two XML files and save the result to a document.
 * The result is a set of edits. 
 * Each edit tells what is changed in the NEW file, as compared to the OLD file.
 * Arguments:
 * 	1/ new file
 *  2/ old file
 *  3/ edits file (compare results)
 * 
 * returns true when compare succeeds, false when some error occurred.
 * 
 */
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.BooleanValue;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.file.XmlFile;

public class ImvertorCompareXML extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorCompareXml");
	
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
		return SequenceType.SINGLE_BOOLEAN;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new CompareXMLCall();
	}

	private static class CompareXMLCall extends ExtensionFunctionCall {

		@Override
	    public BooleanValue call(XPathContext context, Sequence[] arguments) throws XPathException { 
			XmlFile ctrlFile = new XmlFile(((StringValue) arguments[0].head()).getStringValue());		
			XmlFile testFile = new XmlFile(((StringValue) arguments[1].head()).getStringValue());		
			XmlFile diffFile = new XmlFile(((StringValue) arguments[2].head()).getStringValue());		
			try {
				Boolean succes = true; 
				succes = ctrlFile.xmlUnitCompareXML(testFile,diffFile);
				return BooleanValue.get(succes);
			} catch (Exception e) {
				throw new XPathException(e);
			}
		}
	}
}