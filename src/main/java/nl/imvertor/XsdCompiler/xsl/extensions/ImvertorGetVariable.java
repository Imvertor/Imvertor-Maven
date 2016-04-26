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

package nl.imvertor.XsdCompiler.xsl.extensions;

/*
 * get variable: am:get-variable(variableNameAsString) ->  variableValueAsString
 */
import java.util.HashMap;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.Configurator;

public class ImvertorGetVariable extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorGetVariable");

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
		return new SequenceType[] { SequenceType.SINGLE_STRING };
	}

	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.SINGLE_STRING;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new GetVariableCall();
	}

	private static class GetVariableCall extends ExtensionFunctionCall {

		@SuppressWarnings("unchecked")
		@Override
	    public StringValue call(XPathContext context, Sequence[] arguments) throws XPathException {

			HashMap<String,String> variableMap = (HashMap<String,String>) 
		    		  context.getController().getUserData("variableMap", "variableMap");
			if (variableMap == null) {
				variableMap = new HashMap<String,String>();
				context.getController().setUserData("variableMap", "variableMap", variableMap);
			}        
			String variableName = ((StringValue) arguments[0].head()).getStringValue();
			String variable = variableMap.get(variableName);
			if (variable != null) {
				String val = variableMap.get(variableName);
				if (val != null) 
					return StringValue.makeStringValue(val);
			}
			return StringValue.makeStringValue("");
		}
	}
}