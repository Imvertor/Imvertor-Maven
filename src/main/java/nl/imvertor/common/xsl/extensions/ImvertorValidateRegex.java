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

import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.Configurator;


/**
 * 
 * @author Arjan Loeffen
 */
public class ImvertorValidateRegex extends ExtensionFunctionDefinition {
  
  private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorValidateRegex");
  
  @Override
  public StructuredQName getFunctionQName() {
    return qName;
  }

  @Override
  public int getMinimumNumberOfArguments() {
    return 1;
  }

  @Override
  public int getMaximumNumberOfArguments() {
    return 1;
  }

  @Override
  public SequenceType[] getArgumentTypes() {
    return new SequenceType[] { SequenceType.SINGLE_STRING };
  }

  @Override
  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
    return SequenceType.SINGLE_STRING;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {
    return new ValidateRegexCall();
  }
  
  private static class ValidateRegexCall extends ExtensionFunctionCall {
    
	  @Override
	  public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
		  String r = "";
		  try {
			  String s = ((StringValue) arguments[0].head()).getStringValue();
			  Pattern.compile(s);
		  } catch (PatternSyntaxException exception) {
			  r = exception.getDescription();
		  }
		  return StringValue.makeStringValue(r);
	  }
  }
  
}
