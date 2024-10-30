/* 
 * $HeadURL$
 * $LastChangedRevision$
 * $LastChangedDate$
 * $LastChangedBy$
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

public class ImvertorCalculateHashlabel extends ExtensionFunctionDefinition {
  
  private static final StructuredQName qName = 
		  new StructuredQName("", Configurator.NAMESPACE_EXTENSION_FUNCTIONS, "imvertorCalculateHashLabel");

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
    return new SequenceType[] { SequenceType.SINGLE_STRING, SequenceType.SINGLE_STRING  };
  }

  public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
    return SequenceType.SINGLE_STRING;
  }

  public ExtensionFunctionCall makeCallExpression() {
    return new HashlabelCall();
  }
  
  private static class HashlabelCall extends ExtensionFunctionCall {

	  /**
	   * Extension function. 
	   * Create Hash on the string passed. Return a label (characters, digits,... based on the supplied pool of characters) or a full hash (digits) for the supplied string. 
	   * 
	   * @param string to create a hash label for
	   * @return string hash
	   * @throws Exception
	   */

	  /**
	   * Calculate Hashlabel on input data
	   */
	  public static String calculateHashlabel(String s,String characters) { 
		  int hash = s.hashCode() & 0xfffffff; // Maak het positief, gegenereerde hashes kunnen negatief zijn. - https://stackoverflow.com/questions/33219638/how-to-make-a-hashcodeinteger-value-positive
		  if (characters.length() > 0)
			  return subtract(hash,"",characters);
		  else
			  return String.valueOf(hash);
	  }
	  
	  private static String subtract(int seed, String result, String pool) {
		  int l = pool.length();
		  int m = seed % l;
		  int r = seed / l;
		  String c = pool.substring(m,m + 1);
		  if (r > 0) 
			  return result + c + subtract(r,result,pool);
		  else
			  return result + c;
	  }

	  @Override
	  public Sequence call(XPathContext arg0, Sequence[] arguments) throws XPathException {
		  String s1 = arguments[0].head().getStringValue();
		  String s2 = arguments[1].head().getStringValue();
		  return StringValue.makeStringValue(calculateHashlabel(s1,s2));
	  }

  }
}