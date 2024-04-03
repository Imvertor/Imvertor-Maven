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

package nl.imvertor.common.xsl.extensions.expath;

import java.util.Base64;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.EmptySequence;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.file.AnyFile;


/**
 * Write base64 encoded string as binary contents to a file. 
 * 
 * @author Maarten Kroon, Arjan Loeffen
 */
public class ImvertorExpathWriteBinary extends ExtensionFunctionDefinition {
  
  private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorExpathWriteBinary");
  
  @Override
  public StructuredQName getFunctionQName() {
    return qName;
  }

  @Override
  public int getMinimumNumberOfArguments() {
    return 2;
  }

  @Override
  public int getMaximumNumberOfArguments() {
    return 2;
  }

  @Override
  public SequenceType[] getArgumentTypes() {    
    return new SequenceType[] { 
        SequenceType.SINGLE_STRING, // File path
        SequenceType.SINGLE_STRING}; // Base64 string
  }
  
  @Override
  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {    
    return SequenceType.OPTIONAL_BOOLEAN;
  }
  
  @Override
  public boolean hasSideEffects() {    
    return true;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {    
    return new ImvertorExpathWriteBinaryCall();
  }
  
  private static class ImvertorExpathWriteBinaryCall extends ExtensionFunctionCall {
    
	  @Override
	  public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
	    try {
    	  AnyFile file = new AnyFile(((StringValue) arguments[0].head()).getStringValue());
    	  String encoded = (arguments[1].head()).getStringValue();
  	      byte[] decoded = Base64.getDecoder().decode(encoded);
  	      file.setBinaryContent(decoded);
  	      return EmptySequence.getInstance();
  	    } 
  	    catch (Exception e) {
	      throw new XPathException("Cannot decode and write file", e);
	    }
	  }
	  		  
  }
}
