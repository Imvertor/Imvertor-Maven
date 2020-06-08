package nl.imvertor.common.file;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;

import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLEventWriter;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamReader;
import javax.xml.stream.XMLStreamWriter;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stax.StAXResult;
import javax.xml.transform.stax.StAXSource;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLGenerator.Feature;
import com.fasterxml.jackson.dataformat.yaml.YAMLMapper;

import de.odysseus.staxon.json.JsonXMLConfig;
import de.odysseus.staxon.json.JsonXMLConfigBuilder;
import de.odysseus.staxon.json.JsonXMLInputFactory;
import de.odysseus.staxon.json.JsonXMLOutputFactory;
import de.odysseus.staxon.xml.util.PrettyXMLEventWriter;
import nl.imvertor.common.Configurator;
import nl.imvertor.common.exceptions.ConfiguratorException;

public class JsonFile extends AnyFile {
	
	private static final long serialVersionUID = 5245273749795090247L;
	protected static final Logger logger = Logger.getLogger(JsonFile.class);
	
	static JsonXMLConfig config;
		 
	public static void main(String[] args) {
		JsonFile jsonInputFile = new JsonFile("d:\\projects\\validprojects\\BRO\\input\\SKOS-JSON\\aquo-data.json");
		XmlFile xmlOutputFile = new XmlFile("c:/temp/sample.xml");
		JsonFile jsonOutputFile = new JsonFile("c:/temp/sample.json");
		try {
			jsonInputFile.jsonToXml(xmlOutputFile);
			xmlOutputFile.xmlToJson(jsonOutputFile);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("done");
	}
	
	public JsonFile(File file) throws IOException {
		super(file);
    }
	public JsonFile(String pathname) {
		super(pathname);
	}
	/**
     * Create a json representation of this file. 
     * 
     */
    public void jsonToXml(XmlFile targetFile) throws Exception {
    	targetFile.setContent(JsonFile.jsonToXml(getContent()));
    }

    public static void setConfig() {
		if (config == null)
			config = new JsonXMLConfigBuilder()
					.autoArray(true)
		            .autoPrimitive(true)
					.prettyPrint(true)
					.build();
    }

    public static String jsonToXml(String jsonString) throws Exception {
		
    	setConfig();
    	
		jsonString = "{\"json\": " + jsonString + "}";
		
		StringReader input = new StringReader(jsonString);
		StringWriter output = new StringWriter();
		
		try {
			/*
			 * Create reader (JSON).
			 */
			XMLEventReader reader = new JsonXMLInputFactory(config).createXMLEventReader(input);

			/*
			 * Create writer (XML).
			 */
			XMLEventWriter writer = XMLOutputFactory.newInstance().createXMLEventWriter(output);
			writer = new PrettyXMLEventWriter(writer); // format output

			/*
			 * Copy events from reader to writer.
			 */
			writer.add(reader);

			/*
			 * Close reader/writer.
			 */
			reader.close();
			writer.close();
		} finally {
			/*
			 * As per StAX specification, XMLEventReader/Writer.close() doesn't
			 * close the underlying stream.
			 */
			output.close();
			input.close();
		}
		return JsonFile.escapeJsonOperator(output.toString());
	}
	
	public static String xmlToJson(String xmlString) throws Exception {
		
		setConfig();
    	
		StringReader input = new StringReader(xmlString);
		StringWriter output = new StringWriter();
		
		 /*
         * If we want to insert JSON array boundaries for multiple elements,
         * we need to set the <code>autoArray</code> property.
         * If our XML source was decorated with <code>&lt;?xml-multiple?&gt;</code>
         * processing instructions, we'd set the <code>multiplePI</code>
         * property instead.
         * With the <code>autoPrimitive</code> property set, element text gets
         * automatically converted to JSON primitives (number, boolean, null).
         */
		
		try {
			 /*
             * Create source (XML).
             */
            XMLStreamReader reader = XMLInputFactory.newInstance().createXMLStreamReader(input);
            Source source = new StAXSource(reader);

            /*
             * Create result (JSON).
             */
            XMLStreamWriter writer = new JsonXMLOutputFactory(config).createXMLStreamWriter(output);
            Result result = new StAXResult(writer);

            /*
             * Copy source to result via "identity transform".
             */
             TransformerFactory.newInstance().newTransformer().transform(source, result);

			/*
			 * Close reader/writer.
			 */
		} finally {
			/*
			 * As per StAX specification, XMLEventReader/Writer.close() doesn't
			 * close the underlying stream.
			 */
			output.close();
			input.close();
		}
		return output.toString();
	}
	
	/**
	 * Json query operators in XML are prefixed using json:eq in stead of $eg.
	 * This avoids &lt;$eq element names.
	 * 
	 * @param xmlString
	 * @return
	 * @throws Exception
	 */
	public static String xmlToJsonQuery(String xmlString) throws Exception {
		String jsonString = xmlToJson(xmlString);
		return deescapeJsonOperator(jsonString);
	}
	
	public static String escapeJsonOperator(String xmlString) {
		String resultString = xmlString;
		resultString = StringUtils.replace(StringUtils.replace(resultString, "<$", "<JSONOP_DOLLAR_"),"</$", "</JSONOP_DOLLAR_");
		resultString = StringUtils.replace(StringUtils.replace(resultString, "<@", "<JSONOP_AT_"),"</@", "</JSONOP_AT_");
		return resultString;
	}
	public static String deescapeJsonOperator(String jsonString) {
		String resultString = jsonString;
		resultString = StringUtils.replace(resultString, "JSONOP_DOLLAR_", "$");
		resultString = StringUtils.replace(resultString, "JSONOP_AT_", "@");
		return resultString;
	}
	
	/**
	 * Pretty printer for any Json string. 
	 * 
	 * Check https://stackoverflow.com/questions/4105795/pretty-print-json-in-java
	 * 
	 * @param jsonString
	 * @return Formatted string.
	 * @throws JSONException Will throw exception when not valid Json.
	 */
	public static String prettyPrintString(String jsonString) throws JSONException {
		JSONObject json = new JSONObject(jsonString); // Convert text to object
		return json.toString(3); // Print it with specified indentation
	}
	/**
	 * Pretty print the contents of the Json file, replacing the current file content.
	 * 
	 * @throws IOException When file cannot be read.
	 * @throws JSONException Will throw exception when not valid Json.
	 */
	public void prettyPrint() throws JSONException, IOException {
		setContent(prettyPrintString(getContent()));
	}

	/**
	 * Validate json string; when errors occur, return that error message.
	 * 
	 * @param jsonString
	 * @return
	 * @throws ConfiguratorException 
	 * @throws IOException 
	 */
	public static boolean validateString(Configurator configurator, String jsonString) throws IOException, ConfiguratorException {
		try {
			new JSONObject(jsonString); // Convert text to object
		} catch (Exception e) {
			configurator.getRunner().error(logger, "Invalid Json: \"" + e.getMessage() + "\"", null, "", "IJ");
			return false;
		}
		return true;
	}
	
	public boolean validate(Configurator configurator) throws IOException, ConfiguratorException {
		return validateString(configurator, getContent());
	}
	
	public boolean convertToYaml(Configurator configurator, YamlFile resultYamlFile) throws IOException, ConfiguratorException {
		try {
			 // parse JSON
	        JsonNode jsonNodeTree = new ObjectMapper().readTree(getContent());
	        // save it as YAML
	        YAMLMapper m = new YAMLMapper();
	        m.disable(Feature.WRITE_DOC_START_MARKER);
	        String jsonAsYaml = m.writeValueAsString(jsonNodeTree);
	        resultYamlFile.setContent(jsonAsYaml);
        } catch (Exception e) {
			configurator.getRunner().error(logger,"Error parsing Json: " + e.getLocalizedMessage());
		}
		return true;
	}
	
	/**
	 * Remove the root sequence with key "JSON", returning a regular sequence. 
	 * @throws IOException 
	 */
	public void stripJSONroot() throws IOException {
		setContent(StringUtils.replacePattern(getContent(),"^\\{\\s*\"JSON\"\\s*:\\s*(.*?)\\s*\\}\\s*$","$1"));
	}
}
