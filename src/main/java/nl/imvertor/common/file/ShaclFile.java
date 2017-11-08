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

import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.Resource;
import org.apache.jena.riot.RiotException;
import org.apache.jena.util.FileUtils;
import org.apache.log4j.Logger;
import org.topbraid.shacl.util.ModelPrinter;
import org.topbraid.shacl.validation.ValidationUtil;
import org.topbraid.spin.util.JenaUtil;

import nl.imvertor.common.Configurator;

/**
 * A representation of a Shacl file.
 * 
 * @author arjan
 *
 */

public class ShaclFile extends RdfFile {

	private static final long serialVersionUID = 1L;
	protected static final Logger logger = Logger.getLogger(ShaclFile.class);
	
	private Model dataShape;
	private Model dataModel;
	
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
	
	public void parse(Configurator configurator) throws Exception {

		try {
			// Load the main data model
			dataShape = JenaUtil.createMemoryModel();
			dataShape.read(this.getFileInputStream(), "",
					FileUtils.langTurtle);
			
		} catch (RiotException re) {
			configurator.getRunner().error(logger,re.getMessage());
			
		} catch (Exception e) {
			throw e;
		}
		
	}

	public void parse(Configurator configurator, String ttlDataFilePath) throws Exception {

		parse(configurator);
		// if the model is read okay, parse the TTL data file passed.
		
		if (configurator.getRunner().succeeds()) {
			try {
				
				dataModel = JenaUtil.createMemoryModel();
				RdfFile dataFile = new RdfFile(ttlDataFilePath);
				dataModel.read(dataFile.getFileInputStream(), "",
						FileUtils.langTurtle);
		
				// Perform the validation of everything, using the data model
				// also as the shapes model - you may have them separated
				Resource report = ValidationUtil.validateModel(dataModel, dataShape, true);
		
				/* This will return a small report on the status of the model. Format:
				
					@base          <http://example.org/random> .
					@prefix ex:    <http://example.org#> .
					@prefix owl:   <http://www.w3.org/2002/07/owl#> .
					@prefix uml:   <http://bp4mc2.org/def/uml#> .
					@prefix sh:    <http://www.w3.org/ns/shacl#> .
					@prefix kkg:   <http://bp4mc2.org/def/kkg/id/begrip> .
					@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
					
					[ a            sh:ValidationReport ;
					  sh:conforms  true
					] .
				*/
				//ModelPrinter.get().print(report.getModel());
				
			} catch (RiotException re) {
				configurator.getRunner().error(logger,re.getMessage());
				
			} catch (Exception e) {
				throw e;
			}
		}
		
	}
}
