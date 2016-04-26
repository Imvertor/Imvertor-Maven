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

package nl.imvertor.common.wrapper;

import javax.xml.transform.Transformer;

import nl.imvertor.common.Configurator;

import org.apache.commons.configuration2.CombinedConfiguration;
import org.apache.commons.configuration2.ex.ConfigurationException;
import org.apache.commons.configuration2.io.FileLocator;
import org.apache.commons.configuration2.io.FileLocator.FileLocatorBuilder;
import org.apache.commons.configuration2.io.FileLocatorUtils;

/**
 * Wrapper for apache XMLConfiguration, required for creating a transformer with a locator (bug fix).
 * 
 * @author arjan
 *
 */
public class XMLConfiguration extends org.apache.commons.configuration2.XMLConfiguration {

	
	public XMLConfiguration() {
		super();
	}
	
	public XMLConfiguration(CombinedConfiguration cc) {
		super(cc);
	}
	
    public Transformer createTransformer() throws ConfigurationException  {
    	FileLocatorBuilder builder = FileLocatorUtils.fileLocator();
    	builder.basePath(Configurator.getInstance().getConfigFilepath());
    	builder.encoding("UTF-8");
		FileLocator locator = new FileLocator(builder);
		initFileLocator(locator);
        return super.createTransformer();
    }
  
}
