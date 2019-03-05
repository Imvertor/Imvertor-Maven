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
import nl.imvertor.common.file.WikiFile;

/**
 * Parse a wiki string and return a (possibly non-well-formed) HTML string.
 * Requires two arguments: string to parse, and the wiki language of that string.
 * 
 * @author Arjan Loeffen
 */
public class ImvertorParseWiki extends ExtensionFunctionDefinition {
  
  private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorParseWiki");
  
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
    return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_STRING };
  }

  @Override
  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
    return SequenceType.SINGLE_STRING;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {
    return new ParseWikiCall();
  }
  
  private static class ParseWikiCall extends ExtensionFunctionCall {
    
    @Override
    public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
      try {
    	  String wikiFormatText = ((StringValue) arguments[0].head()).getStringValue();
    	  String language = ((StringValue) arguments[1].head()).getStringValue();
    	  
    	  int wikiLanguage;
    	  if (language.equals("markdown")) 
    		  wikiLanguage = WikiFile.FORMAT_MARKDOWN;
    	  else if (language.equals("mediawiki")) 
    		  wikiLanguage = WikiFile.FORMAT_MEDIAWIKI;
    	  else if (language.equals("textile")) 
    		  wikiLanguage = WikiFile.FORMAT_TEXTILE;
    	  else if (language.equals("confluence")) 
    		  wikiLanguage = WikiFile.FORMAT_CONFLUENCE;
      	  else
    		  throw new Exception("Not a recognized wiki language: " + language);
    	  String result = WikiFile.getHtmlFormatText(wikiFormatText, wikiLanguage);
    	  return StringValue.makeStringValue(result);
      } catch (Exception e) {
        throw new XPathException("Could not parse Wiki text", e);
      }
    }
  }
}
