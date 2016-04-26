// SVN: $Id: ImvertorCompareXML.java 7229 2015-09-02 09:05:50Z arjan $

package nl.imvertor.ReleaseComparer.xsl.extensions;

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