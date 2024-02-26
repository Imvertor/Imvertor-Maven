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

import org.apache.log4j.Logger;

import nl.imvertor.common.Configurator;

/**
 * A representation of a Shacl file.
 * 
 * @author arjan
 *
 */

public class SkosFile extends RdfFile {

	private static final long serialVersionUID = 1L;
	protected static final Logger logger = Logger.getLogger(SkosFile.class);
	
	public SkosFile(String pathname) {
		super(pathname);
	}
	
	public SkosFile(File file) {
		super(file);
	}

	public void validate(Configurator configurator, ShaclFile shaclSchemaFile) throws Exception {
		super.parse(configurator);
		// and parse this file; this is the validation of the model itself 
		this.parse(configurator, shaclSchemaFile);
	}

	public void validate(Configurator configurator) throws Exception {
		parse(configurator, null);
	}
	
	public void parse(Configurator configurator, ShaclFile shaclSchemaFile) throws Exception {
		if (shaclSchemaFile != null)
		   shaclSchemaFile.parse(configurator, this.getAbsolutePath());
	}
}
