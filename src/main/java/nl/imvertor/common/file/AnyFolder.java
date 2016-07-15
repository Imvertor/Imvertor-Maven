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
import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.StringUtils;

public class AnyFolder extends AnyFile {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4199645313296692076L;

	static String FOLDER_CONTENT_WRAPPER_NAMESPACE = "http://www.armatiek.nl/namespace/folder-content-wrapper";
	
	private String linesep = System.getProperty("line.separator");
	
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
	
	/**
	 * Serialize the entire folder to a content xml file.
	 * For each XML file found, transform the file using the XSL provided.
	 * This XSL must therefore cater for various XML files expected in the folder. 
	 * The result of the transformation is insert in the content XML file.
	 * The XSL file is provided with the local file URL for the file at hand. 
	 * This takes the form of a &lt;file path="c:\myfile.xml"/&gt; context document (a single element). 
	 * As such, any huge or unimportant XML files may be dismissed immediately without having to read and process it.
	 * The result of the transformation however is inserted in the __content.xml file as returned by the XSLT.
	 * 
	 * @param filterXslFile
	 * @throws Exception
	 */
	
	public void serializeToXml(XslFile filterXslFile) throws Exception {
		// create a content file.
    	XmlFile content = new XmlFile(this,"__content.xml");
    	// If from a previous run, remove
    	if (content.isFile()) content.delete();
    	// Build a writer
    	FileWriterWithEncoding contentWriter = content.getWriterWithEncoding("UTF-8", false);
    	// create a pattern that matches <?xml ... ?>
    	String xmlRegex = "<\\?(x|X)(m|M)(l|L).*?\\?>";
    	contentWriter.append(
    			"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    			+ "<zip-content-wrapper:files xmlns:zip-content-wrapper=\"" + FOLDER_CONTENT_WRAPPER_NAMESPACE + "\">");
    	// now go through all files in the folder. Based in the XML or binary type of the file, add to XML stream.
    	Vector<String> files = this.listFilesToVector(true);
    	for (int i = 0; i < files.size(); i++) {
    		AnyFile f = new AnyFile(files.get(i));
    		String relpath = f.getRelativePath(this);  // i.e. skip the "work1/" part
    		boolean done = false;
    		if (f.isDirectory())
    			done = true;
    		else if (f.isXml()) {
    			
    			XmlFile wrapperInputFile;
    			XmlFile wrapperOutputFile;
    			
    			XmlFile fx = new XmlFile(f);
    			if (fx.isWellFormed()) {
    				
    				String startWrapperString = 
    						"<zip-content-wrapper:file"
    						+ " xmlns:zip-content-wrapper=\"" + FOLDER_CONTENT_WRAPPER_NAMESPACE + "\""
    						+ " type=\"xml\" path=\"" + relpath + "\"" + getSpecs(f) + "/>";
    				String endWrapperString = 
    						"</zip-content-wrapper:file>";
     				
    				if (filterXslFile != null)
     					if (filterXslFile.isFile()) {
     						wrapperInputFile = new XmlFile(File.createTempFile("serializeToXml_", "_input.xml"));
     						wrapperOutputFile = new XmlFile(File.createTempFile("serializeToXml_", "_output.xml"));
     						wrapperInputFile.deleteOnExit();
     	    				wrapperOutputFile.deleteOnExit();
     	    				// do a filter transformation
     	    				wrapperInputFile.setContent(startWrapperString + fx.getContent() + endWrapperString);
     						filterXslFile.transform(wrapperInputFile,wrapperOutputFile);
	     					// place that result in the content XML.
	     					fx = wrapperOutputFile;
	     				}
     					else
     						throw new IOException("No such XSL file: " + filterXslFile.getCanonicalPath());
     			
     				// process the filtered results
     				int linesRead = 0;
    				while (true) {
    					String line = fx.getNextLine();
    					if (line == null) 
    						break;
    					else if (linesRead > 0) 
							contentWriter.append(line + linesep);
    					else 
    						contentWriter.append(StringUtils.removePattern(line, xmlRegex) + linesep);
    					linesRead += 1;
					}
    				contentWriter.append(endWrapperString);
    				done = true;
    			}
    		}
			if (!done) {	
				// and record in XML for informational purpose
				contentWriter.append("<zip-content-wrapper:file type=\"bin\" path=\"" + relpath + "\"" + getSpecs(f) + "/>");
			}
    	}
    	contentWriter.append("</zip-content-wrapper:files>");
    	contentWriter.close();
	}
	
	private String getSpecs(AnyFile file) throws IOException {
		return " date = \"" + file.lastModified() + "\""
			+ " name = \"" + file.getName() + "\""
			+ " ishidden = \"" + file.isHidden() + "\""
			+ " isreadonly = \"" + file.canRead() + "\""
			+ " ext = \"" + file.getExtensionCS() + "\""
			+ " fullpath = \"" + file.getCanonicalPath() + "\"";
	}
}
