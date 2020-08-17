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

import java.io.File;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Properties;

import javax.xml.transform.Result;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.io.FileUtils;

import net.sf.saxon.TransformerFactoryImpl;
import net.sf.saxon.expr.StaticProperty;
import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.AxisInfo;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.pattern.NodeKindTest;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.AxisIterator;
import net.sf.saxon.type.AnyItemType;
import net.sf.saxon.type.Type;
import net.sf.saxon.value.EmptySequence;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.Configurator;


/**
 * Write XML contents to a file. Circumvents limits of writing to a file from within Saxon/XSLT.
 * 
 * @author Maarten Kroon
 */
public class ImvertorExpathWrite extends ExtensionFunctionDefinition {
  
  private static final StructuredQName qName = new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorExpathWrite");
  
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
    return 3;
  }

  @Override
  public SequenceType[] getArgumentTypes() {    
    return new SequenceType[] { 
        SequenceType.SINGLE_STRING, 
        SequenceType.makeSequenceType(AnyItemType.getInstance(), StaticProperty.ALLOWS_ZERO_OR_MORE),
        SequenceType.SINGLE_NODE };
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
    return new ImvertorExpathWriteCall(false);
  }
  
  private static class ImvertorExpathWriteCall extends ExtensionFunctionCall {
    
	  private boolean append;
	  
	  public ImvertorExpathWriteCall(boolean append) {
	    this.append = append;
	  }

	  @Override
	  public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
	    try {
	      File file = new File(((StringValue) arguments[0].head()).getStringValue());
	      File parentFile = file.getParentFile();
	      if (!parentFile.exists()) {
	        throw new XPathException(String.format("Parent directory \"%s\" does not exist", 
	            parentFile.getAbsolutePath()), "ERROR_PATH_NOT_DIRECTORY");
	      }     
	      if (file.isDirectory()) {
	        throw new XPathException(String.format("Path \"%s\" points to a directory", 
	            file.getAbsolutePath()), "ERROR_PATH_IS_DIRECTORY");
	      }
	      Properties props = null;
	      if (arguments.length > 2) {
	        props = getOutputProperties((NodeInfo) arguments[2].head());
	      }
	      OutputStream os = FileUtils.openOutputStream(file, append);
	      try {
	        serialize(arguments[1], os, props);
	      } finally {
	        os.close();
	      }
	      return EmptySequence.getInstance();
	    } catch (XPathException fe) {
	      throw fe;
	    } catch (Exception e) {
	      throw new XPathException("Cannot write file", e);
	    }
	  }
	  
	  protected void serialize(Sequence seq, OutputStream os, Properties outputProperties) throws XPathException {
		    String encoding = "UTF-8";
		    if (outputProperties != null) {
		      encoding = outputProperties.getProperty("encoding", encoding);
		    }
		    try {
		      SequenceIterator iter = seq.iterate(); 
		      Item item;
		      while ((item = iter.next()) != null) {
		        if (item instanceof NodeInfo) {
		          serialize((NodeInfo) item, new StreamResult(os), outputProperties);
		        } else {
		          new OutputStreamWriter(os, encoding).append(item.getStringValue());
		        }
		      }
		    } catch (Exception e) {
		      throw new XPathException(e);
		    }
	  } 
	  
	  protected void serialize(NodeInfo nodeInfo, Result result, Properties outputProperties) throws XPathException {
		    try {
		      TransformerFactory factory = new TransformerFactoryImpl();
		      Transformer transformer = factory.newTransformer();
		      if (outputProperties != null) {
		        transformer.setOutputProperties(outputProperties);
		      }
		      transformer.transform(nodeInfo, result);
		    } catch (Exception e) {
		      throw new XPathException(e);
		    }
		  }
	  protected Properties getOutputProperties(NodeInfo paramsElem) {
		    Properties props = new Properties();
		    paramsElem = unwrapNodeInfo(paramsElem);
		    AxisIterator iter = paramsElem.iterateAxis(AxisInfo.CHILD, NodeKindTest.ELEMENT);
		    NodeInfo paramElem;
		    while ((paramElem = iter.next()) != null) {
		      props.put(paramElem.getLocalPart(), paramElem.getAttributeValue("", "value"));
		    }  
		    return props;
		  }
	  protected NodeInfo unwrapNodeInfo(NodeInfo nodeInfo) {
		    if (nodeInfo != null && nodeInfo.getNodeKind() == Type.DOCUMENT) {
		      nodeInfo = nodeInfo.iterateAxis(AxisInfo.CHILD, NodeKindTest.ELEMENT).next();
		    }
		    return nodeInfo;
		  }
		  
  }
}
