package nl.imvertor.common.file;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import org.eclipse.rdf4j.model.Model;
import org.eclipse.rdf4j.model.impl.LinkedHashModel;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFHandlerException;
import org.eclipse.rdf4j.rio.RDFParseException;
import org.eclipse.rdf4j.rio.RDFParser;
import org.eclipse.rdf4j.rio.Rio;
import org.eclipse.rdf4j.rio.helpers.StatementCollector;

public class RdfFile extends AnyFile {

	private static final long serialVersionUID = -8890889086447502503L;
	
	private boolean isOpen = false;
	private Model model;
	
	public static int EXPORT_FORMAT_XML = 0;
	public static int EXPORT_FORMAT_XMLABBREVIATED = 1;
	public static int EXPORT_FORMAT_NTRIPLE = 2;
	public static int EXPORT_FORMAT_TURTLE = 3;
	public static int EXPORT_FORMAT_TRIG = 4;
	public static int EXPORT_FORMAT_N3 = 5;
	
	private String[] map = {"RDF/XML", "RDF/XML-ABBREV", "N-TRIPLE", "TURTLE", "TriG", "N3"};
	
	public RdfFile(String pathname) {
		super(pathname);
	}
	
	public RdfFile(File file) {
		super(file.getAbsolutePath());
	}
	
	public RdfFile(File file, String subpath) {
		super(file, subpath);
	}	

	public void open() {
		//TODO open and mainatin model in memory for query and the like.
	}
	
	public void parse() throws Exception {
	
		if (isOpen) close();
		
		if (isFile() && canRead()) {
			 
			 String ext = this.getExtension().toLowerCase();
			 if (ext.equals("ttl")) {
				 
				 java.net.URL documentURL = this.toURI().toURL();
				 InputStream inputStream = documentURL.openStream();

				 RDFParser rdfParser = Rio.createParser(RDFFormat.TURTLE);

				 Model model = new LinkedHashModel();
				 rdfParser.setRDFHandler(new StatementCollector(model));
				 try {
					 rdfParser.parse(inputStream, documentURL.toString());
				 }
				 catch (IOException e) {
					 // handle IO problems (e.g. the file could not be read)
					 throw e;
				 }
				 catch (RDFParseException e) {
					 // handle unrecoverable parse error
					 throw e;
				 }
				 catch (RDFHandlerException e) {
					 // handle a problem encountered by the RDFHandler
					 throw e;
				 }
				 finally {
					 inputStream.close();
				 }

			 } else 
				 throw new Exception("No known file extension: " + ext);
			 isOpen = true;
		} else {
			throw new Exception("No such file: " + this.getAbsolutePath());
		}
				
	}

	public void close() {
		
		// release memory
		model = null;
		
		isOpen = false;
	}
	
	/**
	 * @param file
	 * @param exportFileType
	 * @throws Exception 
	 */
	public void export(File file, int exportFileType) throws Exception {
		testOpen();
		//TODO
	}
	
	/**
	 * see http://www.ibm.com/developerworks/xml/library/j-sparql/
	 * @throws Exception 
	 * 
	 */
	public void query(String queryString,File outFile) throws Exception {
		testOpen();
		//TODO
	}
	
	private void testOpen() throws Exception {
		if (!isOpen)
			throw new Exception("RDF file is not opened: " + this.getAbsolutePath());
	}
	
	public void canonize(RdfFile resultRdfFile) throws Exception {
		//TODO		
	}
}
