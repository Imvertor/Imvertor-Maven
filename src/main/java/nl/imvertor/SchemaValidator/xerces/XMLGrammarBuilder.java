package nl.imvertor.SchemaValidator.xerces;

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.io.IOException;

import org.apache.xerces.impl.Constants;
import org.apache.xerces.parsers.XIncludeAwareParserConfiguration;
import org.apache.xerces.parsers.XMLGrammarPreparser;
import org.apache.xerces.util.SymbolTable;
import org.apache.xerces.util.XMLGrammarPoolImpl;
import org.apache.xerces.xni.XNIException;
import org.apache.xerces.xni.grammars.Grammar;
import org.apache.xerces.xni.grammars.XMLGrammarDescription;
import org.apache.xerces.xni.parser.XMLErrorHandler;
import org.apache.xerces.xni.parser.XMLInputSource;
import org.apache.xerces.xni.parser.XMLParseException;
import org.apache.xerces.xni.parser.XMLParserConfiguration;

/**
 * Implementation of schema parser based on Xerces sample code for XMLGrammarBuilder 
 * described at at http://xerces.apache.org/xerces2-j/faq-grammars.html#faq-3
 *
 * @author Neil Graham, IBM
 * @version $Id: XMLGrammarBuilder.java 7431 2016-02-24 12:46:42Z arjan $
 */
public class XMLGrammarBuilder implements XMLErrorHandler {

    //
    // Constants
    //

    // property IDs:

    /** Property identifier: symbol table. */
    public static final String SYMBOL_TABLE =
        Constants.XERCES_PROPERTY_PREFIX + Constants.SYMBOL_TABLE_PROPERTY;

    /** Property identifier: grammar pool. */
    public static final String GRAMMAR_POOL =
        Constants.XERCES_PROPERTY_PREFIX + Constants.XMLGRAMMAR_POOL_PROPERTY;

    // feature ids

    /** Namespaces feature id (http://xml.org/sax/features/namespaces). */
    protected static final String NAMESPACES_FEATURE_ID = "http://xml.org/sax/features/namespaces";

    /** Validation feature id (http://xml.org/sax/features/validation). */
    protected static final String VALIDATION_FEATURE_ID = "http://xml.org/sax/features/validation";

    /** Schema validation feature id (http://apache.org/xml/features/validation/schema). */
    protected static final String SCHEMA_VALIDATION_FEATURE_ID = "http://apache.org/xml/features/validation/schema";

    /** Schema full checking feature id (http://apache.org/xml/features/validation/schema-full-checking). */
    protected static final String SCHEMA_FULL_CHECKING_FEATURE_ID = "http://apache.org/xml/features/validation/schema-full-checking";
    
    /** Honour all schema locations feature id (http://apache.org/xml/features/honour-all-schemaLocations). */
    protected static final String HONOUR_ALL_SCHEMA_LOCATIONS_ID = "http://apache.org/xml/features/honour-all-schemaLocations";

    // a larg(ish) prime to use for a symbol table to be shared
    // among
    // potentially man parsers.  Start one as close to 2K (20
    // times larger than normal) and see what happens...
    public static final int BIG_PRIME = 2039;

    // default settings

    /** Default Schema full checking support (false). */
    protected static final boolean DEFAULT_SCHEMA_FULL_CHECKING = false;
    
    /** Default honour all schema locations (false). */
    protected static final boolean DEFAULT_HONOUR_ALL_SCHEMA_LOCATIONS = false;

    XMLGrammarPreparser preparser;
    XMLGrammarPoolImpl grammarPool;
    SymbolTable sym;
    XMLParserConfiguration parserConfiguration;
    boolean schemaFullChecking = DEFAULT_SCHEMA_FULL_CHECKING;
    boolean honourAllSchemaLocations = DEFAULT_HONOUR_ALL_SCHEMA_LOCATIONS;
    ErrorHandler errorHandler;
    
    /** Main program entry point. 
     * @throws IOException 
     * @throws XNIException */
    public static void main(String argv[]) throws XNIException, IOException {
        XMLGrammarBuilder builder = new XMLGrammarBuilder(true);
        builder.parseXSD("c:\\temp\\a\\xsd\\Ruilakte\\aanbod\\v20121101\\Ruilakte_Aanbod_v1_1_2.xsd");
    } 
  
    private static XMLInputSource stringToXIS(String uri) {
        return new XMLInputSource(null, uri, null);
    }
    
    public XMLGrammarBuilder(Boolean quiet) {
    	sym = new SymbolTable(BIG_PRIME);
        preparser = new XMLGrammarPreparser(sym);
        grammarPool = new XMLGrammarPoolImpl();
        errorHandler = new ErrorHandler(quiet);
    }
    
    public ErrorHandler getErrorHandler() {
    	return errorHandler;
    }
    public void setErrorHandler(ErrorHandler errorHandler) {
    	this.errorHandler = errorHandler;
    }
    
    public void setSchemaFullChecking(Boolean check) {
    	schemaFullChecking = check;
    }
    public void setHonourAllSchemaLocations(Boolean honour) {
    	honourAllSchemaLocations = honour;
    }
    
    public void parseDTD(String dtdFile) throws XNIException, IOException {
    	preparser.registerPreparser(XMLGrammarDescription.XML_DTD, null);
    	preparePreparser();
        // Grammar g = preparser.preparseGrammar(XMLGrammarDescription.XML_DTD, stringToXIS(dtdFile)); // grammar can be saved for cache.
        finishPreparser();
    }
    public void parseXSD(String xsdFile) throws XNIException, IOException {
    	preparser.registerPreparser(XMLGrammarDescription.XML_SCHEMA, null);
    	preparePreparser();
        Grammar g = preparser.preparseGrammar(XMLGrammarDescription.XML_SCHEMA, stringToXIS(xsdFile));
        finishPreparser();
    }
    public void parseByDTD(String xmlFile, String dtdFile) throws XNIException, IOException {
    	parseDTD(dtdFile);
    	validate(xmlFile);
    }
    public void parseByXSD(String xmlFile, String xsdFile) throws XNIException, IOException {
    	parseXSD(xsdFile);
    	validate(xmlFile);
    }
    
    private void preparePreparser() {
    	preparser.setProperty(GRAMMAR_POOL, grammarPool);
    	preparser.setFeature(NAMESPACES_FEATURE_ID, true);
    	preparser.setFeature(VALIDATION_FEATURE_ID, true);
    	// note we can set schema features just in case...
    	preparser.setFeature(SCHEMA_VALIDATION_FEATURE_ID, true);
    	preparser.setFeature(SCHEMA_FULL_CHECKING_FEATURE_ID, schemaFullChecking);
    	preparser.setFeature(HONOUR_ALL_SCHEMA_LOCATIONS_ID, honourAllSchemaLocations);
    	preparser.setErrorHandler(this);
    }     

    private void finishPreparser() {
    	if (parserConfiguration == null) {
    		parserConfiguration = new XIncludeAwareParserConfiguration(sym, grammarPool);
    	} 
    	else {
    		// set GrammarPool and SymbolTable...
    		parserConfiguration.setProperty(SYMBOL_TABLE, sym);
    		parserConfiguration.setProperty(GRAMMAR_POOL, grammarPool);
    	}
    	// now must reset features, unfortunately:

    	parserConfiguration.setFeature(NAMESPACES_FEATURE_ID, true);
    	parserConfiguration.setFeature(VALIDATION_FEATURE_ID, true);
    	// now we can still do schema features just in case,
    	// so long as it's our configuraiton......
    	parserConfiguration.setFeature(SCHEMA_VALIDATION_FEATURE_ID, true);
    	parserConfiguration.setFeature(SCHEMA_FULL_CHECKING_FEATURE_ID, schemaFullChecking);
    	parserConfiguration.setFeature(HONOUR_ALL_SCHEMA_LOCATIONS_ID, honourAllSchemaLocations);
    }

    private void validate(String xmlfile) throws XNIException, IOException {
    	parserConfiguration.parse(stringToXIS(xmlfile));
    }

	@Override
	public void error(String arg0, String arg1, XMLParseException arg2)
			throws XNIException {
		errorHandler.genericMessage("ERROR", arg0, arg1, arg2);
	}

	@Override
	public void fatalError(String arg0, String arg1, XMLParseException arg2)
			throws XNIException {
		errorHandler.genericMessage("FATAL", arg0, arg1, arg2);
	}

	@Override
	public void warning(String arg0, String arg1, XMLParseException arg2)
			throws XNIException {
		errorHandler.genericMessage("WARNING", arg0, arg1, arg2);
	}

} // class XMLGrammarBuilder

