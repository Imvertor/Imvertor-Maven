// SVN: $Id: SetVariable.java 558 2015-07-10 09:07:44Z arjan $

package nl.imvertor.common.xsl.extensions.counting;

import java.util.HashMap;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.EmptySequence;
import net.sf.saxon.value.Int64Value;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

public class AddNamedCount extends ExtensionFunctionDefinition {

	private static final StructuredQName qName = new StructuredQName("", "http://www.imvertor.org/xsl/extensions", "add-named-count");

	public StructuredQName getFunctionQName() {
		return qName;
	}

	public int getMinimumNumberOfArguments() {
		return 2;
	}

	public int getMaximumNumberOfArguments() {
		return 2;
	}

	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_INTEGER };
	}

	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_BOOLEAN;
	}

	public ExtensionFunctionCall makeCallExpression() {
		return new SetCall();
	}

	private static class SetCall extends ExtensionFunctionCall {

		@SuppressWarnings("unchecked")
		@Override
	    public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
			HashMap<String,Integer> countMap = (HashMap<String,Integer>) context.getController().getUserData("countMap", "countMap");
			if (countMap == null) {
				countMap = new HashMap<String,Integer>();
				context.getController().setUserData("countMap", "countMap", countMap);
			}     
			String variableName = ((StringValue) arguments[0].head()).getStringValue();
			Integer set = (int) ((Int64Value) arguments[1].head()).longValue();
			Integer cur = countMap.get(variableName);
			cur = (cur == null) ? set : cur + set;
			countMap.put(variableName, cur);
			return EmptySequence.getInstance();
		}
	}
}