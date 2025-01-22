package nl.imvertor.common.file;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.apache.log4j.Logger;
import org.eclipse.rdf4j.model.Model;
import org.eclipse.rdf4j.model.impl.LinkedHashModel;
import org.eclipse.rdf4j.rio.ParseErrorListener;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.rio.RDFParser;
import org.eclipse.rdf4j.rio.RDFWriter;
import org.eclipse.rdf4j.rio.Rio;
import org.eclipse.rdf4j.rio.helpers.StatementCollector;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.exceptions.ConfiguratorException;

public class RdfFile extends AnyFile {

	private static final long serialVersionUID = -8890889086447502503L;
	
	protected static final Logger logger = Logger.getLogger(RdfFile.class);

	private boolean isOpen = false;
	
	public static int EXPORT_FORMAT_XML = 0;
	public static int EXPORT_FORMAT_XMLABBREVIATED = 1;
	public static int EXPORT_FORMAT_NTRIPLE = 2;
	public static int EXPORT_FORMAT_TURTLE = 3;
	public static int EXPORT_FORMAT_TRIG = 4;
	public static int EXPORT_FORMAT_N3 = 5;
	
	//private String[] map = {"RDF/XML", "RDF/XML-ABBREV", "N-TRIPLE", "TURTLE", "TriG", "N3"};
	
	public static void main(String[] args) throws Exception {
		RdfFile input = new RdfFile("c:/temp/rdf/input.xml");
		RdfFile output = new RdfFile("c:/temp/rdf/input2.ttl");
		input.export(output,RdfFile.EXPORT_FORMAT_XML,RdfFile.EXPORT_FORMAT_TURTLE);
	}
	
	
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
		//TODO open and maintain model in memory for query and the like.
	}
	
	public void parse(Configurator configurator) throws Exception {
	
		if (isOpen) close();
		
		if (isFile() && canRead()) {
			 
			 String ext = this.getExtension().toLowerCase();
			 if (ext.equals("ttl")) {
				 
				 java.net.URL documentURL = this.toURI().toURL();
				 InputStream inputStream = documentURL.openStream();

				 RDFFormat format = RDFFormat.TURTLE;
				 RDFParser rdfParser = Rio.createParser(format);
				 
				 ParseErrorListener el = new MyParseErrorListener(this, configurator);
				 rdfParser.setParseErrorListener(el);

				 Model model = new LinkedHashModel();
				 rdfParser.setRDFHandler(new StatementCollector(model));
				 try {
					 rdfParser.parse(inputStream, documentURL.toString()); // playground voor shacl schema's: https://shacl-playground.zazuko.com/
				 } catch (Exception e) {
					// ignore
			 	 } finally {
					 inputStream.close();
				 }
			
			 } else if (ext.equals("yml")) {
				 
				 // TODO
				 configurator.getRunner().error(logger,"Not a supported RDF file extension: \"" + ext + "\"",null,"rdf-uns","RDF-NASRFE1");
				 
			 } else 
				configurator.getRunner().fatal(logger,"Not a known RDF file extension: \"" + ext + "\"",null,"rdf-unk","RDF-NAKRFE1");
		
			 isOpen = true;
		} else {
			throw new Exception("No such file: " + this.getAbsolutePath());
		}
				
	}

	public void close() {
		
		// release memory
		//model = null;
		
		isOpen = false;
	}
	
	/**
	 * @param file
	 * @param exportFileType
	 * @throws Exception 
	 */
	public void export(File file, int inputFileType, int outputFileType) throws Exception {
		if (isOpen) close();
		
		InputStream inputStream = new FileInputStream(this);
		FileOutputStream outputStream = new FileOutputStream(file);
		
		try {
			// guess the format of the input file (default to RDF/XML)
			
			RDFFormat inputFormat = null;
			if (inputFileType == EXPORT_FORMAT_XML)
				inputFormat = Rio.getParserFormatForFileName("").orElse(RDFFormat.RDFXML);
			else if (inputFileType == EXPORT_FORMAT_TURTLE)
				inputFormat = Rio.getParserFormatForFileName("").orElse(RDFFormat.TURTLE);
			else
				throw new Exception("Unsupported output format: " + inputFileType);
			
			RDFWriter rdfWriter = null;
			if (outputFileType == EXPORT_FORMAT_XML)
				rdfWriter = Rio.createWriter(RDFFormat.RDFXML, outputStream);
			else if (outputFileType == EXPORT_FORMAT_TURTLE)
				rdfWriter = Rio.createWriter(RDFFormat.TURTLE, outputStream);
			else
				throw new Exception("Unsupported input format: " + outputFileType);
			
			// create a parser for the input file and a writer for Turtle format
			RDFParser rdfParser = Rio.createParser(inputFormat);
			
			// link the parser to the writer
			rdfParser.setRDFHandler(rdfWriter);
	
			// start the conversion
			rdfParser.parse(inputStream, this.getCanonicalPath());
		
		} catch (Exception e) { 
			Configurator.getInstance().getRunner().error(logger,e.getLocalizedMessage());
		} finally {
			inputStream.close();
			outputStream.close();
		}
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

	public class MyParseErrorListener implements ParseErrorListener {
		
		private Configurator configurator;
		private RdfFile file;
		
		public MyParseErrorListener(RdfFile file, Configurator configurator) {
			super();
			this.file = file;
			this.configurator = configurator;
		}
		
		@Override
		public void warning(String msg, long lineNo, long colNo) {
			try {
				this.configurator.getRunner().warn(logger,"At "+ file.getName() + " [" + lineNo + ":" + colNo + "]:" + msg);
			} catch (IOException | ConfiguratorException e) {
				//ignore
			}
		}
		
		@Override
		public void fatalError(String msg, long lineNo, long colNo) {
			try {
				this.configurator.getRunner().error(logger,"Fatal at "+ file.getName() + " [" + lineNo + ":" + colNo + "]:" + msg);
			} catch (IOException | ConfiguratorException e) {
				//ignore
			}
		}
		
		@Override
		public void error(String msg, long lineNo, long colNo) {
			try {
				this.configurator.getRunner().error(logger,"At " + file.getName() + " [" + lineNo + ":" + colNo + "]:" + msg);
			} catch (IOException | ConfiguratorException e) {
				// ignore
			}
		}
	};
}

