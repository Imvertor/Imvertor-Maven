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
import java.io.FileFilter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.Vector;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.RegExUtils;

import nl.imvertor.common.Configurator;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.filter.FileExistsFileFilter;

public class AnyFolder extends AnyFile {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4199645313296692076L;
	
	static public String FOLDER_CONTENT_WRAPPER_NAMESPACE = "http://www.armatiek.nl/namespace/folder-content-wrapper";
	static public String SERIALIZED_CONTENT_XML_FILENAME = "__content.xml";
	
	private String serializedFilePath = SERIALIZED_CONTENT_XML_FILENAME;
	
	
	public static void main(String[] args) throws Exception {
		AnyFolder a1 = new AnyFolder("c:/Temp/app-canon");
		a1.removeEmptyFolders();
	}
	
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
	public void copy(AnyFolder targetFolder, boolean overwriteAll) throws Exception {
		if (overwriteAll) {
			FileUtils.copyDirectory(this, targetFolder);
		} else {
			FileFilter filter = new FileExistsFileFilter(this,targetFolder);
			FileUtils.copyDirectory(this, targetFolder, filter);
		}
	}
	/**
	 * Copy and overwrite the file/folder(s).
	 * 
	 * @param targetFolder
	 * @throws Exception
	 */
	public void copy(AnyFolder targetFolder) throws Exception {
		copy(targetFolder,true);
	}
	/**
	 * Copy, and specify if must overwrite.
	 * 
	 * @param targetFolderPath
	 * @param overwriteAll
	 * @throws Exception
	 */
	public void copy(String targetFolderPath, boolean overwriteAll) throws Exception {
		copy(new AnyFolder(targetFolderPath),overwriteAll);
	}
	/**
	 * Copy and overwrite the file/folder(s).
	 * 
	 * @param targetFolderPath
	 * @throws Exception
	 */
	public void copy(String targetFolderPath) throws Exception {
		copy(new AnyFolder(targetFolderPath),true);
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
	 * @param filterXslFile Pass XSL file to filter search file found, operating on the cw:file root element.
	 * @param roleInfo Pass roleInfo when the result should be typed for further processing. This role info will appear on the @role attribute of the cw:files root element. 
	 * @param includeContents Include the contents of the XML (possibly after transform)?
	 * @throws Exception
	 * @returns Number of files selected
	 */
	
	// TODO deze code moet worden uitgefaseerd: beter is het meegeven van een transformer, en, nog beter, een gecompileerd stylesheet ipv. een stylesheet file.
	// Zie hieronder: serializeToXml(Transformer transformer, XslFile filterXslFile, String roleInfo, boolean includeContents)
	public int serializeToXml(XslFile filterXslFile, String roleInfo, boolean includeContents) throws Exception {
		// create a content file. If local name, the relative, else assume absolute.
		XmlFile content = (serializedFilePath == SERIALIZED_CONTENT_XML_FILENAME) ? new XmlFile(this,serializedFilePath) : new XmlFile(serializedFilePath);
    	// If from a previous run, remove
    	if (content.isFile()) content.delete();
    	// Build a writer
    	FileWriterWithEncoding contentWriter = content.getWriter(false);
    	contentWriter.append(
    			"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    			+ "<cw:files xmlns:cw=\"" + FOLDER_CONTENT_WRAPPER_NAMESPACE + "\" role=\"" + roleInfo + "\">");
    	// now go through all files in the folder. Based in the XML or binary type of the file, add to XML stream.
    	Vector<String> files = this.listFilesToVector(true);
    	int selected = 0;
    	for (int i = 0; i < files.size(); i++) {
    		AnyFile f = new AnyFile(files.get(i));
    		String relpath = f.getRelativePath(this);  // i.e. skip the "work1/" part
    		
    		if (f.isFile() && !f.getName().equals(serializedFilePath)) {
    			
    			XmlFile wrapperInputFile = new XmlFile(File.createTempFile("serializeToXml_", "_input.xml"));
				wrapperInputFile.deleteOnExit();

				String type;
    			String contentString;
    			
    			if (f.isXml()) {
    				type = "xml";
    				if (includeContents) {
	    				XmlFile fx = new XmlFile(f);
	    				if (f.getName().endsWith(".ea-profile.xml") || f.getName().endsWith(".ea-toolbox.xml"))
	    	    			fx.setEncoding(StandardCharsets.UTF_16.displayName());
	    	    		if (fx.isWellFormed()) 
	         	    		contentString = cleanXmlPI(fx.getContent());
	        			else
	        				contentString = "<!--not wellformed-->";
    				} else
    					contentString = "<!--see xml-->";
	      		} else {
					type = "bin";
					contentString = "<!--see binary-->";
				}
				
				String startWrapperString = 
						"<cw:file"
						+ " xmlns:cw=\"" + FOLDER_CONTENT_WRAPPER_NAMESPACE + "\""
						+ " type=\"" + type + "\" path=\"" + XmlFile.xmlescape(relpath) + "\"" + getSpecs(f) + ">";
				String endWrapperString = 
						"</cw:file>";
     				
    			wrapperInputFile.setContent(startWrapperString + contentString + endWrapperString);
    				
				if (filterXslFile != null)
 					if (filterXslFile.isFile()) {
 						XmlFile wrapperOutputFile = new XmlFile(File.createTempFile("serializeToXml_", "_output.xml"));
 						wrapperOutputFile.deleteOnExit();
 	    				// do a filter transformation
 	    				filterXslFile.transform(wrapperInputFile,wrapperOutputFile);
     					// place that result in the content XML.
     					wrapperInputFile = wrapperOutputFile;
     					selected += 1;
     				}
 					else
 						throw new IOException("No such XSL file: " + filterXslFile.getCanonicalPath());
 			
 				contentWriter.append(wrapperInputFile.getContent());
			}
			
    	}
    	contentWriter.append("</cw:files>");
    	contentWriter.close();
    	return selected;
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
	 * @param filterXslFile Pass XSL file to filter search file found, operating on the cw:file root element.
	 * @param roleInfo Pass roleInfo when the result should be typed for further processing. This role info will appear on the @role attribute of the cw:files root element. 
	 * @param includeContents Include the contents of the XML (possibly after transform)?
	 * @throws Exception
	 * @returns Number of files selected
	 */
	
	public int serializeToXml(Transformer transformer, XslFile filterXslFile, String roleInfo, boolean includeContents) throws Exception {
		// create a content file. If local name, the relative, else assume absolute.
		XmlFile content = (serializedFilePath == SERIALIZED_CONTENT_XML_FILENAME) ? new XmlFile(this,serializedFilePath) : new XmlFile(serializedFilePath);
    	// If from a previous run, remove
    	if (content.isFile()) content.delete();
    	// Build a writer
    	FileWriterWithEncoding contentWriter = content.getWriter(false);
    	contentWriter.append(
    			"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    			+ "<cw:files xmlns:cw=\"" + FOLDER_CONTENT_WRAPPER_NAMESPACE + "\">");
    	// now go through all files in the folder. Based in the XML or binary type of the file, add to XML stream.
    	Vector<String> files = this.listFilesToVector(true);
    	int selected = 0;
    	for (int i = 0; i < files.size(); i++) {
    		AnyFile f = new AnyFile(files.get(i));
    		String relpath = f.getRelativePath(this);  // i.e. skip the "work1/" part
    		
    		if (f.isFile() && !f.getName().equals(serializedFilePath)) {
    			
    			XmlFile wrapperInputFile = new XmlFile(File.createTempFile("serializeToXml_", "_input.xml"));
				wrapperInputFile.deleteOnExit();

				String type;
    			String contentString;
    			
    			if (f.isXml()) {
    				type = "xml";
    				if (includeContents) {
	    				XmlFile fx = new XmlFile(f);
	    	   			fx.setEncoding(f.guessEncoding());  // UTF-16BE etc wordt later teruggezet als UTF-8 bij serialisatie
    		    	 	if (fx.isWellFormed()) 
	         	    		contentString = cleanXmlPI(fx.getContent());
	        			else
	        				contentString = "<!--not wellformed-->";
    				} else
    					contentString = "<!--see xml-->";
	      		} else {
					type = "bin";
					contentString = "<!--see binary-->";
				}
				
				String startWrapperString = 
						"<cw:file"
						+ " xmlns:cw=\"" + FOLDER_CONTENT_WRAPPER_NAMESPACE + "\""
						+ " type=\"" + type + "\" path=\"" + XmlFile.xmlescape(relpath) + "\"" + getSpecs(f) + ">";
				String endWrapperString = 
						"</cw:file>";
     				
    			wrapperInputFile.setContent(startWrapperString + contentString + endWrapperString);
    				
				if (filterXslFile != null)
 					if (filterXslFile.isFile()) {
 						XmlFile wrapperOutputFile = new XmlFile(File.createTempFile("serializeToXml_", "_output.xml"));
 						wrapperOutputFile.deleteOnExit();
 	    				// do a filter transformation
 	    				transformer.transform(wrapperInputFile,wrapperOutputFile,filterXslFile,"filtered");
     					// place that result in the content XML.
     					wrapperInputFile = wrapperOutputFile;
     					selected += 1;
     				}
 					else
 						throw new IOException("No such XSL file: " + filterXslFile.getCanonicalPath());
 			
 				contentWriter.append(wrapperInputFile.getContent());
			}
			
    	}
    	contentWriter.append("</cw:files>");
    	contentWriter.close();
    	
    	// nu beide files indenteren en canoniseren, zodat je het goed kunt vergelijken
    	content.prettyPrintXml(true);
    	
    	return selected;
	}
	
	public int serializeToXml(XslFile filterXslFile, String roleInfo) throws Exception {
		return serializeToXml(filterXslFile,roleInfo,true);
	}

	public int serializeToXml(XslFile filterXslFile) throws Exception {
		return serializeToXml(filterXslFile,"",true);
	}
	
	public int serializeToXml() throws Exception {
		return serializeToXml(null,"");
	}
	
	public void setSerializedFilePath(String path) {
		serializedFilePath = path;
	}
	
	private String getSpecs(AnyFile file) throws IOException {
		return " date = \"" + file.lastModified() + "\""
			+ " name = \"" + XmlFile.xmlescape(file.getName()) + "\""
			+ " ishidden = \"" + file.isHidden() + "\""
			+ " isreadonly = \"" + file.canRead() + "\""
			+ " ext = \"" + XmlFile.xmlescape(file.getExtensionCS()) + "\""
			;
	}
	
	private String cleanXmlPI(String xmlString) {
		return RegExUtils.removePattern(xmlString, XmlFile.xmlPiRegex);
	}
	
	/*
	 * Clean all XML's, reformatting them as a neat tree
	 */
	public void prettyPrintXml(AnyFolder targetXmlFolder,boolean hasMixedContent) throws Exception {
		XslFile prettyPrinter = new XslFile(Configurator.getInstance().getBaseFolder(),"xsl/common/tools/PrettyPrinter.xsl");
		Transformer transformer = new Transformer();
		transformer.setXslParm("xml-mixed-content",(hasMixedContent) ? "true" : "false");
		transformer.transformFolder(this, targetXmlFolder, ".*\\.xml", prettyPrinter);
	}
	
	/* 
	 * Remove all files that have a 0 size
	 */
	public void removeEmptyFiles() {
	    File[] listofFiles = this.listFiles();
        for (int j = 0; j < listofFiles.length; j++) {
            File file = listofFiles[j];
            if (file.isDirectory()) 
                (new AnyFolder(file)).removeEmptyFiles();
            else if (file.isFile() && file.length() == 0) 
                file.delete();
        }
	}
	
	/* 
	 * Remove all folders that are empty
	 */
	public void removeEmptyFolders() {
		Vector<AnyFolder> list = new Vector<AnyFolder>();
		listFoldersDepthFirst(list);
	    Iterator<AnyFolder> listIt = list.iterator();
		while (listIt.hasNext()) {
			AnyFolder folder = listIt.next();
			if (folder.list().length == 0)
				folder.delete();
		}
	}
	
	/*
	 * List all subfolders depth-first, adding each AnyFolder found to the list passed.
	 */
	public void listFoldersDepthFirst(Vector<AnyFolder> list) {
	    File[] listofFiles = this.listFiles();
	    for (int j = 0; j < listofFiles.length; j++) {
            File file = listofFiles[j];
            if (file.isDirectory())
            	(new AnyFolder(file)).listFoldersDepthFirst(list);
	    }
	    if (isDirectory())
	    	list.add(this);
	}
}
