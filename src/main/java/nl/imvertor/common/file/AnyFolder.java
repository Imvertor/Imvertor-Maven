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
import java.util.Vector;

import org.apache.commons.io.FileUtils;

public class AnyFolder extends AnyFile {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4199645313296692076L;

	public AnyFolder(File file) {
		super(file);
	}

	public AnyFolder(String path) {
		super(path);
	}

	public AnyFolder(File parent, String filename) {
		super(parent, filename);
	}

	/**
	 * Create a copy of this folder within the target folder. 
	 * Example /a -> /b creates : /b/a/*
	 * 
	 * @param targetFolder
	 * @throws Exception
	 */
	public void copy(AnyFolder targetFolder) throws Exception {
		FileUtils.copyDirectory(this, targetFolder);
	}
	public void copy(String targetFolder) throws Exception {
		FileUtils.copyDirectory(this, (new File(targetFolder)));
	}
	public boolean hasFile(String filename) throws IOException {
		if (!this.exists() || this.isFile()) return false;
		return (new File(this.getCanonicalPath() + File.separator + filename)).isFile(); 
	}

	public Vector<String> listFilesToVector(boolean recurse) throws Exception {
		Vector<String> list = new Vector<String>();
		if (this.isDirectory()) {
			getFilesSub(list, this, recurse);
			return list;
		} else {
			throw new Exception("Not a folder");
		}
	}

	private void getFilesSub(Vector<String> list, File currentFile, boolean recurse) throws IOException {
		File[] listOfFiles = currentFile.listFiles();
		if (listOfFiles != null) // may be null when this is a LNK and not a folder or file 
			for (File rFile : listOfFiles) {
				list.add(rFile.getCanonicalPath());
				if(rFile.isDirectory() && recurse) {
					getFilesSub(list, rFile, recurse);
				} 
			}
	}
	public void deleteDirectory() throws IOException {
		if (this.isDirectory()) FileUtils.deleteDirectory(this);
	}
}
