package nl.imvertor.ReleaseComparer;

import java.io.FileWriter;

import org.w3c.dom.Element;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.diff.Comparison;
import org.xmlunit.diff.ComparisonResult;
import org.xmlunit.diff.DefaultNodeMatcher;
import org.xmlunit.diff.Diff;
import org.xmlunit.diff.Difference;
import org.xmlunit.diff.DifferenceEvaluator;
import org.xmlunit.diff.ElementSelector;
import org.xmlunit.diff.ElementSelectors;
import org.xmlunit.diff.NodeMatcher;

import nl.imvertor.common.file.XmlFile;

public class XmlComparer {

	public static Integer compare(XmlFile controlFile, XmlFile testFile, XmlFile resultFile) throws Exception {
		/* https://github.com/xmlunit/user-guide/wiki/DiffBuilder */
		
		XmlComparerFormatter formatter = new XmlComparerFormatter(controlFile, testFile);
		
        // Create custom ElementSelector
        ElementSelector selector = new ElementSelector() {
			@Override
			public boolean canBeCompared(Element controlElement, Element testElement) {
				if (controlElement.getLocalName().equals(testElement.getLocalName()))
					return true;
				else
					return false;
        	}
        };
        // Create NodeMatcher with custom ElementSelector
        NodeMatcher nodeMatcher = new DefaultNodeMatcher(ElementSelectors.byNameAndText, selector);
        
		// Create custom DifferenceEvaluator
        DifferenceEvaluator evaluator = new DifferenceEvaluator() {
            @Override
            public ComparisonResult evaluate(Comparison comparison, ComparisonResult outcome) {
            	return outcome;
            }
        };
        
		Diff myDiff = DiffBuilder.compare(controlFile)
		        .withTest(testFile)
		        //.checkForSimilar()
		        .checkForIdentical()
		        .ignoreComments()
		        .ignoreWhitespace()
		        .normalizeWhitespace()
		        .ignoreElementContentWhitespace()
		        .withNodeMatcher(nodeMatcher)
		        .withDifferenceEvaluator(evaluator)
		        .withComparisonFormatter(formatter)
		        .build();
		
		// Get differences
        Iterable<Difference> differences = myDiff.getDifferences();

        FileWriter myWriter = new FileWriter(resultFile);
        myWriter.write("<cmps>");
	        
        Integer count = 0;
        for (Difference difference : differences) {
            myWriter.write(difference.toString().replaceAll(" \\(DIFFERENT\\)$", ""));
            count += 1;
        }
        myWriter.write("</cmps>");
	    myWriter.close();
        
	    resultFile.prettyPrintXml(false);
	    
        // Check if XML files are identical
        return count;
  
	}
	
}

