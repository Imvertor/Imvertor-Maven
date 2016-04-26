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

import java.io.StringReader;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXSource;

import net.sf.saxon.Configuration;
import net.sf.saxon.TransformerFactoryImpl;
import net.sf.saxon.dom.DocumentWrapper;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.BooleanValue;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.Configurator;

import org.apache.commons.lang3.StringEscapeUtils;
import org.ccil.cowan.tagsoup.HTMLSchema;
import org.ccil.cowan.tagsoup.Schema;
import org.ccil.cowan.tagsoup.jaxp.SAXParserImpl;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;


/**
 * 
 * 
 * @author Maarten Kroon
 */
public class ImvertorParseHTML extends ExtensionFunctionDefinition {
  
  private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorParseHTML");
  
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
    return 2;
  }

  @Override
  public SequenceType[] getArgumentTypes() {
    return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.OPTIONAL_BOOLEAN };
  }

  @Override
  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
    return SequenceType.SINGLE_NODE;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {
    return new ParseHTMLCall();
  }
  
  private static class ParseHTMLCall extends ExtensionFunctionCall {
    
    private static final Schema HTML_SCHEMA = new HTMLSchema();
    
    private Document parseHTML(String html) throws SAXException, ParserConfigurationException, TransformerException {      
      // Create SAXSource:      
      SAXParser saxParser = SAXParserImpl.newInstance(null);
      saxParser.setProperty(org.ccil.cowan.tagsoup.Parser.schemaProperty, HTML_SCHEMA);
      XMLReader reader = saxParser.getXMLReader();      
      SAXSource source = new SAXSource(reader, new InputSource(new StringReader(html)));
      
      // Create resulting DOM document:        
      DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();         
      dbf.setNamespaceAware(true);
      dbf.setValidating(false);        
      dbf.setIgnoringElementContentWhitespace(true);
      Document doc = dbf.newDocumentBuilder().newDocument();
                  
      // Use Saxon's or whatever TransformerFactoryImpl to execute identity transformation 
      // and serialize SAX events to XML:
      DOMResult result = new DOMResult(doc);
      TransformerFactory factory = new TransformerFactoryImpl();
      Transformer transformer = factory.newTransformer();            
      transformer.transform(source, result);
    
      return doc;
    }
    
    protected NodeInfo source2NodeInfo(Source source, Configuration configuration) {        
	    Node node = ((DOMSource)source).getNode();
	    String baseURI = source.getSystemId();
	    DocumentWrapper documentWrapper = new DocumentWrapper(node.getOwnerDocument(), baseURI, configuration);
	    return documentWrapper.wrap(node);            
	  }

    @Override
    public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
      try {
        String htmlString = ((StringValue) arguments[0].head()).getStringValue();
        boolean isEscaped = (arguments.length > 1) && ((BooleanValue) arguments[1].head()).getBooleanValue();        
        if (isEscaped) {
          htmlString = StringEscapeUtils.unescapeHtml4(htmlString);
        }                
        Document htmlDoc = parseHTML(htmlString);
        return source2NodeInfo(new DOMSource(htmlDoc.getDocumentElement()), context.getConfiguration());
      } catch (Exception e) {
        throw new XPathException("Could not parse HTML", e);
      }
    }
  }
}
