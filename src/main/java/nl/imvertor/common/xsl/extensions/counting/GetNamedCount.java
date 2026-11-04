// SVN: $Id: GetVariable.java 533 2015-01-14 13:57:41Z arjan $

package nl.imvertor.common.xsl.extensions.counting;

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
import net.sf.saxon.value.Int64Value;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

public class GetNamedCount extends ExtensionFunctionDefinition {

  private static final StructuredQName qName = new StructuredQName("", "http://www.imvertor.org/xsl/extensions", "get-named-count");

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
    return SequenceType.SINGLE_INTEGER;
  }

  @Override
  public ExtensionFunctionCall makeCallExpression() {
    return new GetCall();
  }
  
  @Override
  public boolean dependsOnFocus() {
    return true;
  }

  @Override
  public boolean hasSideEffects() {
    return true;
  }

  private static class GetCall extends ExtensionFunctionCall {

    @SuppressWarnings("unchecked")
    @Override
    public Int64Value call(XPathContext context, Sequence[] arguments) throws XPathException {
      HashMap<String, Integer> countMap = (HashMap<String, Integer>) context.getController().getUserData("countMap", "countMap");
      if (countMap == null) {
        countMap = new HashMap<String, Integer>();
        context.getController().setUserData("countMap", "countMap", countMap);
      }
      String variable = ((StringValue) arguments[0].head()).getStringValue();
      Integer value = countMap.get(variable);
      if (value == null)
        value = 0;
      return Int64Value.makeIntegerValue(value);
    }
    
  }
}