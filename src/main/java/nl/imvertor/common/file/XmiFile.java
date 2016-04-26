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

/**
 * A representation of an XMI file.
 * 
 * The XmiFile is an AnyFile and therefore does not access the chain environment. 
 *  
 * @author arjan
 *
 */

public class XmiFile extends XmlFile {

	private static final long serialVersionUID = 7001368764997266115L;

	public XmiFile(String pathname) {
		super(pathname);
	}
	
	public XmiFile(File file) {
		super(file);
	}
	
}
