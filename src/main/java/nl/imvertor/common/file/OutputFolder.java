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

import org.apache.commons.io.FileUtils;

public class OutputFolder extends AnyFolder {

	private static final long serialVersionUID = 734463381893479052L;

	public OutputFolder(File file) {
		super(file);
	}
	
	public OutputFolder(String path) {
		super(path);
	}

	/**
	 * Clear the complete folder, removing all subfiles and -folders.
	 * This is only allowed when the sentinel file _output is found in the root of the folder.
	 * If this is not the case, throw Exception.
	 * 
	 * @param safe
	 * @throws IOException
	 */
	public void clear(boolean safe) throws IOException {
		File sentinel = new File(this, "_output");
		boolean sentinelExists = sentinel.exists();
		if (isDirectory())
			if (!safe || sentinelExists) {
				try {
					FileUtils.deleteQuietly(this);
					this.mkdir();
					if (sentinelExists) sentinel.createNewFile();
				} catch (Exception e) {
					throw new IOException("Folder cannot be cleared: " + this.getCanonicalPath() + ", because: " + e.getMessage());
				}
			} else
				throw new IOException("Folder cannot be cleared, as no marker file \"_output\" was found: " + this.getCanonicalPath());
		else
			throw new IOException("Folder cannot be cleared, as it doesn't exist: " + this.getCanonicalPath());
	}
	
	public void clearIfExists(boolean safe) throws IOException {
		if (exists()) clear(safe); 
	}
}
