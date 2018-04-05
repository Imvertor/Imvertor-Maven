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
* Merge parameters in the input string based on the current configuration (parms.xml).
*  
*/
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

public class ImvertorMergeParms extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorMergeParms");

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
		return SequenceType.SINGLE_STRING;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new ImvertorMergeParmsCall();
	}

	private static class ImvertorMergeParmsCall extends ExtensionFunctionCall {

		public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {

			try {
				if (arguments.length != 1)
					throw new Exception("Invalid number of arguments: " + arguments.length);
				
				String inputString = Transformer.getStringvalue(arguments[0]);
				String outputString = Configurator.getInstance().mergeParms(inputString);
				return StringValue.makeStringValue(outputString);
				
			} catch (Exception e) {
				throw new XPathException(e);
			}
		}
		
	}
}
