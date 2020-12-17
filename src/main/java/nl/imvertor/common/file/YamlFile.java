/*
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

package nl.imvertor.common.file;

import java.io.File;
import java.io.IOException;

import org.apache.log4j.Logger;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.exceptions.ConfiguratorException;

/**
 * A representation of a YAML file.
 * 
 * @author arjan
 *
 */

public class YamlFile extends AnyFile {

	private static final long serialVersionUID = 1L;
	protected static final Logger logger = Logger.getLogger(YamlFile.class);
	
	public YamlFile(String pathname) {
		super(pathname);
	}
	
	public YamlFile(File file) {
		super(file);
	}
	
	public static boolean validate(String yamlString) throws IOException, ConfiguratorException {
        try {
        	(new YAMLFactory()).createParser(yamlString);	
        	return true;
        } catch (Exception e) {
        	Configurator.getInstance().getRunner().error(logger, "Invalid Yaml: \"" + e.getMessage() + "\"", null, "", "IY");
            return false;
        }
	}
	
	/**
     * Set the content to the Yaml serialization of the specified XML file. 
     * 
     * The XML file must adhere to XML schema <a href="https://www.w3.org/TR/xpath-functions-31/#json-to-xml-mapping">here</a>
     * 
     */
    public void fromXml(XmlFile xmlFile) throws Exception {
		JsonFile tempJsonFile = new JsonFile(File.createTempFile("YamlFile.fromXml.", ".json"));
		tempJsonFile.deleteOnExit();
    	tempJsonFile.fromXml(xmlFile);
    	tempJsonFile.toYaml(this);
    }
    
    /**
     * Convert to XML.
     * 
     * The XML file adheres to XML schema <a href="https://www.w3.org/TR/xpath-functions-31/#json-to-xml-mapping">here</a>
     * 
     */
    public void toXml(XmlFile xmlFile) throws Exception {
		JsonFile tempJsonFile = new JsonFile(File.createTempFile("YamlFile.toXml.", ".json"));
		tempJsonFile.deleteOnExit();
    	toJson(tempJsonFile);
    	tempJsonFile.toXml(xmlFile);
    }
    
    /**
     * Convert to Json 
     * 
     * @param configurator
     * @param resultYamlFile
     * @return
     * @throws Exception 
     */
    public boolean toJson(JsonFile resultJsonFile) throws Exception {
		try {
			ObjectMapper yamlReader = new ObjectMapper(new YAMLFactory());
		    Object obj = yamlReader.readValue(getContent(), Object.class);
		    ObjectMapper jsonWriter = new ObjectMapper();
		    resultJsonFile.setContent(jsonWriter.writeValueAsString(obj));
		} catch (Exception e) {
			throw new Exception("Error parsing Yaml: " + e.getLocalizedMessage());
		}
		return true;
	}

}
