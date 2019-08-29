// SVN: $Id: OsExecute.java 589 2016-02-03 13:57:20Z arjan $

package nl.imvertor.common.xsl.extensions;

/*
 * Perform an OS execution. Provide the following parameters:
 * 
 * 1/ command script (e.g. c:\1.bat)
 * 2/ sequence of parameters
 * 3/ timeout in mseconds
 * 4/ run in background, a boolean 
 * 
 */
import java.math.BigInteger;

import org.apache.commons.exec.CommandLine;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Item;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.BooleanValue;
import net.sf.saxon.value.IntegerValue;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;
import nl.imvertor.common.helper.OsExecutor;
import nl.imvertor.common.helper.OsExecutor.OsExecutorResultHandler;

public class ImvertorOsExecute extends ExtensionFunctionDefinition {
	
	private static final StructuredQName qName = new StructuredQName("", "http://www.armatiek.nl/functions", "ImvertorOsExecute");
	
	public StructuredQName getFunctionQName() {
		return qName;
	}

	public int getMinimumNumberOfArguments() {
		return 4;
	}

	public int getMaximumNumberOfArguments() {
		return 4;
	}

	 public SequenceType[] getArgumentTypes() {
		    return new SequenceType[] { 
		    		SequenceType.SINGLE_STRING, 
		    		SequenceType.ANY_SEQUENCE,
		    		SequenceType.SINGLE_INTEGER, 
		    		SequenceType.SINGLE_BOOLEAN};
	}

	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.SINGLE_INTEGER;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new OsExecuteCall();
	}

	private static class OsExecuteCall extends ExtensionFunctionCall {

		@Override
	    public IntegerValue call(XPathContext context, Sequence[] arguments) throws XPathException {
			OsExecutor exec = new OsExecutor();
			String script = ((StringValue) arguments[0].head()).getStringValue();		
			CommandLine commandLine = new CommandLine(script);
			
			SequenceIterator it = arguments[1].iterate();
			Item item = it.next();
			while (item != null) {
				commandLine.addArgument( item.getStringValue() );
				item = it.next();
			}
			long osexecJobTimeout = ((IntegerValue) arguments[2].head()).longValue();
			boolean osexecInBackground = ((BooleanValue) arguments[3].head()).effectiveBooleanValue();

			int exitvalue = 0;
			OsExecutorResultHandler osexecResult;
			try {
	            osexecResult = exec.osexec(commandLine, osexecJobTimeout, osexecInBackground);
	            osexecResult.waitFor();	 
            }
	        catch (final Exception e) {
	           exitvalue = 1;
	        }
			return IntegerValue.makeIntegerValue(BigInteger.valueOf(exitvalue));
		}
	}
}