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
import java.io.InputStreamReader;

import org.apache.log4j.Logger;
import org.eclipse.rdf4j.common.exception.ValidationException;
import org.eclipse.rdf4j.model.vocabulary.RDF4J;
import org.eclipse.rdf4j.repository.RepositoryConnection;
import org.eclipse.rdf4j.repository.RepositoryException;
import org.eclipse.rdf4j.repository.sail.SailRepository;
import org.eclipse.rdf4j.rio.RDFFormat;
import org.eclipse.rdf4j.sail.memory.MemoryStore;
import org.eclipse.rdf4j.sail.shacl.ShaclSail;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Runner;

/**
 * A representation of a Shacl file.
 * 
 * @author arjan
 *
 */

public class ShaclFile extends RdfFile {

	private static final long serialVersionUID = 1L;
	protected static final Logger logger = Logger.getLogger(ShaclFile.class);
	
	/*private Model dataShape;
	private Model dataModel;*/
	
	public ShaclFile(String pathname) {
		super(pathname);
	}
	
	public ShaclFile(File file) {
		super(file);
	}
	
	public void validate(Configurator configurator) throws Exception {
		super.parse(configurator);
		// and parse this file; this is the validation of the model itself 
		this.parse(configurator);
	}
	
	/**
	 * Valideer een turtle file (well-formedness check). 
	 * 
	 * @param configurator De Configurator instance
	**/
	public void parse(Configurator configurator) throws Exception {
		this.parse(configurator, "");
	}
	
	/**
	 * Valideer een turtle file en lever de fouten op in de vorm van error messages.
	 * 
	 * <p>Zie ook https://rdf4j.org/documentation/programming/shacl/
	 *  
	 * @param configurator  De Configurator instance
	 * @param ttlDataFilePath Pad naar het Turtle file
	 * @throws Exception Een fout die niet betrekking heeft op de validatie van Turtle zelf.
	 */
	public void parse(Configurator configurator, String ttlDataFilePath) throws Exception {

		Runner runner = Configurator.getInstance().getRunner();
		
	    ShaclSail shaclSail = new ShaclSail(new MemoryStore());
        
        SailRepository sailRepository = new SailRepository(shaclSail);
        sailRepository.init();

        try (RepositoryConnection connection = sailRepository.getConnection()) {
        	connection.begin();
        	
        	InputStreamReader shaclRulesReader = getReader();
        	
        	connection.add(shaclRulesReader, "", RDFFormat.TURTLE, RDF4J.SHACL_SHAPE_GRAPH);
            connection.commit();

            if (!ttlDataFilePath.equals("")) {
            
	            AnyFile dataFile = new AnyFile(ttlDataFilePath);
		      
	            InputStreamReader dataReader = dataFile.getReader();
	        	
	            connection.begin();
	            connection.add(dataReader, "", RDFFormat.TURTLE);
	            try {
	                connection.commit();
	            } catch (RepositoryException exception) {
	                Throwable cause = exception.getCause();
	                if (cause instanceof ValidationException) {
	                	runner.error(logger, "Shacl validator reports RDF error: \"" + exception.getMessage() + "\"","shacl-parse","SHACL-SVRRE1");
	                } else 
	                    throw exception;
	            }
            }
            
		} catch (Exception e) {
			runner.warn(logger, "Shacl validator schema file \"" + getName() + "\" invalid, cannot validate RDF: \"" + e.getMessage() + "\"","rdf-parse","SHACL-SVSF1ICVR2");
		}
		
	}
}
