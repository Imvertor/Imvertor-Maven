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
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Vector;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.StringUtils;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class ZipFile extends AnyFile {

	static String ZIP_CONTENT_WRAPPER_NAMESPACE = "http://www.armatiek.nl/namespace/zip-content-wrapper";
	
	private static final long serialVersionUID = 1L;
    
    List<String> fileList;
    String sourceFolder = "";
	String linesep = System.getProperty("line.separator");
    
	public ZipFile(String zipFilePath) throws IOException {
		super(zipFilePath);
		fileList = new ArrayList<String>();
	}
	public ZipFile(File file) throws IOException {
		super(file);
		fileList = new ArrayList<String>();
	}
	public ZipFile(File folder, String file) throws IOException {
		super(folder, file);
		fileList = new ArrayList<String>();
	}
	
	/**
	 * Compress contents of a folder to this ZipFile.
	 * If the file exists, overwrite. 
	 * Replaces all zip file contents, if any.
	 * s
	 * @param folderToCompress
	 * @throws Exception
	 */
    public void compress(File folderToCompress) throws Exception {
    	if (folderToCompress.isDirectory()) {
    	  	ZipUtils.zipDirectory(folderToCompress, this); 
    	} else 
    		throw new Exception("Source folder for zip is not a folder: " + folderToCompress);
    }
 
    /**
     * Write zip contents to a target folder. 
     * Add to existing contents.
     * When no such folder, create it. 
     * @param targetFolder
     * @throws Exception 
     */
	public void decompress(AnyFolder targetFolder) throws Exception {
		ZipUtils.unzipFile(this, targetFolder);
	}
	
    /**
     * Create an XML serialization in a folder that will hold 
     * 1/ a single xml file content.xml
     * 2/ for each binary object a folder holding the binary object
     * 3/ a workfolder for the original extraction 
     * 
     * @param xmlFile
     * @throws Exception 
     */
    public void serializeToXml(AnyFolder serializeFolder) throws Exception {
    	// serialize folder must be new
    	
    	//if (serializeFolder.exists())
    	//		throw new Exception("Temporary processing folder must not exist: " + serializeFolder.getAbsolutePath());
    	
    	// create the serialize folder, and work folder.
    	AnyFolder workFolder = new AnyFolder(serializeFolder,"work");
    	workFolder.mkdirs();
    	// unzip this file to the workfolder
    	decompress(workFolder);
    	// create a content file.
    	XmlFile content = new XmlFile(serializeFolder,"__content.xml");
    	FileWriterWithEncoding contentWriter = content.getWriter(false);
    	// create a pattern that matches <?xml ... ?>
    	String xmlRegex = "<\\?(x|X)(m|M)(l|L).*?\\?>";
    	contentWriter.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?><cw:files xmlns:cw=\"" + ZIP_CONTENT_WRAPPER_NAMESPACE + "\">");
    	// now go through all files in the workfolder. Based in the XML or binary type of the file, add to XML stream or save to a bin folder.
    	Vector<String> files = workFolder.listFilesToVector(true);
    	for (int i = 0; i < files.size(); i++) {
    		XmlFile f = new XmlFile(files.get(i));
    		String relpath = f.getRelativePath(serializeFolder).substring(5);  // i.e. skip the "work1/" part
    		if (f.isDirectory()) {
    			// skip 
    		} else if (f.isXml() && f.isWellFormed()) {
 				contentWriter.append("<cw:file type=\"xml\" path=\"" + relpath + "\">");
		    	int linesRead = 0;
				while (true) {
					String line = f.getNextLine();
					if (line == null) 
						break;
					else if (linesRead > 0) 
						contentWriter.append(line + linesep);
					else 
						contentWriter.append(StringUtils.removePattern(line, xmlRegex) + linesep);
					linesRead += 1;
				}
				f.close();
				contentWriter.append("</cw:file>");
			} else {	
				AnyFile fb = new AnyFile(serializeFolder,relpath);
				AnyFolder fbf = new AnyFolder(fb.getParentFile());
				fbf.mkdirs();
				f.copyFile(fb);
				// and record in XML for informational purpose
				contentWriter.append("<cw:file type=\"bin\" path=\"" + relpath + "\"/>");
			}
    	}
    	contentWriter.append("</cw:files>");
    	contentWriter.close();
    	// and remove the work folder
    	workFolder.deleteDirectory();
    }
    
    /**
     * Take a serialized folder and deserialize it; pack to the result file path specified.
     * 
     * @param serializeFolder
     * @param replace
     * @throws Exception 
     */
    public void deserializeFromXml(AnyFolder serializeFolder, boolean replace) throws Exception {
    	XmlFile contentFile = new XmlFile(serializeFolder,"__content.xml");
    	// test if this is a non-exitsing zip file
    	if (exists() && !replace)
    		throw new Exception("ZIP file exists: " + getCanonicalPath());
    	//get the content file.
      	if (!serializeFolder.exists())
    		throw new Exception("Serialized folder doesn't exist: " + serializeFolder.getCanonicalPath());
    	if (!contentFile.exists())
    		throw new Exception("Serialized folder has invalid format");
    	// process the XML and recreate the ZIP structure.
    	Document dom = contentFile.toDocument();
    	
    	List<Node> nodes = getElements(getElements(getNodes(dom.getChildNodes()),"cw:files").get(0).getChildNodes(),"cw:file"); // get all <file> nodes. 
    	for (int i = 0; i < nodes.size(); i++) {
    		Node filenode = nodes.get(i);
    		if (filenode.getNodeType() == Node.ELEMENT_NODE && filenode.getNodeName().equals("cw:file")) {
    			String fileType = getAttribute(filenode, "type");
    			String filePath = getAttribute(filenode, "path");
    			
    			File resultFile = new File(serializeFolder,filePath);
    			
    			if (fileType.equals("xml")) {
    				// pass the contents of the XML file to the XML file
    				List<Node> elms = getElements(filenode.getChildNodes());
    				if (elms.size() > 1)
    		    		throw new Exception("More than one root element found for file: \"" + filePath + "\"");
    				Node contentNode = elms.get(0); 
    				resultFile.getParentFile().mkdirs();
    				FileWriter writer = new FileWriter(resultFile);
    				Transformer transformer = TransformerFactory.newInstance().newTransformer();
    				transformer.transform(new DOMSource((Node) contentNode), new StreamResult(writer));
    				writer.close();
    				
    			} else if (fileType.equals("bin")) {
    				// already there 
    			} else 
    				throw new Exception("Unknown result file type: \"" + fileType + "\"");
    		}
    	}
    	// done; remove the __content.xml file, pack to result
    	contentFile.delete();
    	compress(serializeFolder);
    	
    	// and remove the work folder.
    	//serializeFolder.deleteDirectory();
    }
    
    /**
     * Helper method.
     * 
     * Get the attribute value for specified attribute name
     * 
     * @param filenode
     * @param name
     * @return
     */
    private String getAttribute(Node filenode, String name) {
    	NamedNodeMap atts = filenode.getAttributes();
    	for (int i = 0; i < atts.getLength(); i++) {
    		Node node = atts.item(i);
    		if (node.getNodeName().equals(name)) 
    			return node.getNodeValue();
    	}
    	return null;
    }
    
    /**
     * Helper method.
     * 
     * Get the elements in a list of nodes.
     * 
     * @param nodes
     * @param name
     * @return
     */
    private List<Node> getElements(List<Node> nodes, String name) {
    	List<Node> list = new LinkedList<Node>();
    	for (int i = 0; i < nodes.size(); i++) {
    		Node node = nodes.get(i);
    		if (node.getNodeType() == Node.ELEMENT_NODE)
    			if (name == null || node.getNodeName().equals(name)) 
    				list.add(node);
    	}
    	return list;
    }
    
    /**
     * Helper method.
     * 
     * Get the elements in a nodelist.
     * 
     * @param nodes
     * @param name
     * @return
     */
    private List<Node> getElements(NodeList nodes, String name) {
    	return getElements(getNodes(nodes), name);
    }
    private List<Node> getElements(NodeList nodes) {
    	return getElements(getNodes(nodes), null);
    }
    
    /**
     * Transform a NodeList to a list of nodes.
     * 
     * @param nodes
     * @return
     */
    private List<Node> getNodes(NodeList nodes) {
    	List<Node> list = new LinkedList<Node>();
    	for (int i = 0; i < nodes.getLength(); i++) 
    		list.add(nodes.item(i));
    	return list;
    }
}
