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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.ArrayUtils;
import org.mozilla.universalchardet.UniversalDetector;

/**
 * Extension of File, by providing file functions frequently required from any file.
 *   
 * This implementation does not access the chain environment (Configurator, Transfomer or such).
 *   
 * @author arjan
 *
 */
public class AnyFile extends File  {

	private static final long serialVersionUID = -5935261977364630945L;

	public static HashMap<String, String> exts = new HashMap<String, String>(); 
	static {
		//TODO these extensions should be provided by the OS; the descriptions may have to be mimetypes.
		exts.put("jpeg","JPEG");
		exts.put("jpg","JPEG");
		exts.put("tiff","TIFF");
		exts.put("tif","TIFF");
		exts.put("png","PNG");
		exts.put("doc","MSWord");
		exts.put("docx","MSWord");
		exts.put("odt","ODF");
		exts.put("ott","ODF");
		exts.put("html","HTML");
		exts.put("htm","HTML");
		exts.put("xhtml","XHTML");
		exts.put("xml","XML");
		exts.put("properties","Properties");
	}
	
	public LinkedList<File> files;
	
	private BufferedReader lineReader = null;

	public AnyFile(String pathname) {
		super(pathname);
	}
	
	public AnyFile(File file) {
		super(file.getAbsolutePath());
	}
	
	public AnyFile(File file, String subpath) {
		super(file, subpath);
	}
	
	/**
	 * Determine if a file path specified is absolute.
	 * This is the case when that path starts with "\" or "drive:" (windows) or "/" (unix).
	 *  
	 * @param path
	 * @return
	 */
	public static boolean isAbsolutePath(String path) {
		return match(path,"^(\\|/|(.:))") != null;
	}
	
	public static boolean isFile(String path) {
		return (new File(path)).isFile() ? true : false;
	}
	
	/**
	 * Return a string indicating the type of file. This is based on the file extension.
	 * Returns null when the extension is null or unknown to the system.
	 * 
	 * Note that the filetype can be overridden bij classes implementing subtypes, such as {@link MsWordFile} and {@link HtmlFile}. 
	 * In these cases, a file extension may differ from the standard extensions defined by the OD.
	 * 
	 * @return
	 */
	public String getFileType() {
		return exts.get(getExtension());
	}
	
	/**
	 * Get the extension of the file. Note that the file doesn't have to exist. 
	 * 
	 * @return String The extension in lower case.
	 */
	public String getExtension() {
		return getExtensionCS().toLowerCase();
	}
	/**
	 * Get the case sensitive extension of the file. Note that the file doesn't have to exist. 
	 * 
	 * @return String The extension in lower case.
	 */
	public String getExtensionCS() {
		String ext = "";
		String s = this.getName();
		int i = s.lastIndexOf('.');
		if (i > 0 && i < s.length() - 1) ext = s.substring(i + 1);
		return ext;
	}
	
	public String getNameNoExtension() {
		String name = this.getName();
		int i = name.lastIndexOf('.');
		if (i > 0 && i < name.length() - 1) name = name.substring(0,i);
		return name;
	}
	
	public String getContent() throws IOException {
		StringBuffer fileData = new StringBuffer(1000);
        BufferedReader reader = new BufferedReader(new FileReader(this));
        char[] buf = new char[1024];
        int numRead=0;
        while((numRead=reader.read(buf)) != -1){
            String readData = String.valueOf(buf, 0, numRead);
            fileData.append(readData);
            buf = new char[1024];
        }
        reader.close();
        return fileData.toString();
	}
	
	public void setContent(String s) throws IOException {
		setContent(s, false);
	}
	
	public void setContent(String s, boolean append) throws IOException {
		FileWriterWithEncoding out = new FileWriterWithEncoding(this, "UTF-8", append);
        out.write(s);
        out.flush();
        out.close();
	}

	public void replaceAll(String oldString, String newString) throws IOException {
		String c = getContent();
		setContent(c.replace(oldString,newString));
	}
	
	public boolean matchesWildcard(String wildcard) {
		
		StringBuffer buffer = new StringBuffer();
		char [] chars = wildcard.toCharArray();
		for (int i = 0; i < chars.length; ++i) {
			if (chars[i] == '*')
				buffer.append(".*");
			else if (chars[i] == '?')
				buffer.append(".{1}");
			else if ("[\\^$.|+()".indexOf(chars[i]) != -1) 
				buffer.append("\\" + chars[i]);
			else
				buffer.append(chars[i]);
		}
		return matchesRegex(this, buffer.toString());

	}
	public boolean matchesRegex(File file, String regex) {
		String s = getAbsolutePath();
		regex = "^" + regex + "$";
		Matcher m = Pattern.compile(regex).matcher(s);
		return m.find();
	}
	
	public String getIsoDateTime() {
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mmZ");
		return df.format(this.lastModified());
	}
	
	public String getFileInfo() throws IOException {
		String date = new Date(this.lastModified()).toString();
		return "\"" + this.getCanonicalPath() + "\" " + (this.isDirectory() ? "(DIR) " : "") + "of " + date + ", " + this.length() + " bytes"; 
	}
	
	/**
	 * Filespec is an array of strings:
	 * 
	 * 0 Path,
	 * 1 URL,
	 * 2 name (no extension),
	 * 3 extension,
	 * 4 E when exists, otherwise e.
	 * 
	 * The following strings are added when the path exists:
	 *  
	 * 5 F when it is a file, otherwise f (it's a directory)
	 * 6 H when it is hidden, otherwise h
	 * 7 R when it can be read, otherwise r
	 * 8 W when it can be written to, otherwise w
	 * 9 E when it can be executed, otherwise e
	 * 10 the date & time in ISO format
	 *
	 * When an error occured, only 1 string is returned, the error message.
	 * 
	 * @param filepath
	 * @return
	 */
	public String[] getFilespec() {
		String name = getName();
		int i = name.lastIndexOf('.');
		String[] parms = {}, specs = {};
		try {
			if (exists()) {
				parms = new String[] {
						(isDirectory()) ? "f" : "F",
						(isHidden()) ? "H" : "h",
						(canRead()) ? "R" : "r",
						(canWrite()) ? "W" : "w",
					    (canExecute()) ? "E" : "e",
						(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:sssZ")).format(lastModified())
				};
			} 
			specs = new String[] {
					getCanonicalPath(),
					toURI().toURL().toString(),
					(i > 0 && i < name.length() - 1) ? name.substring(0,i) : name,
					(i > 0 && i < name.length() - 1) ? name.substring(i + 1) : "",
					(exists()) ? "E" : "e"
				};
			return ArrayUtils.addAll(specs, parms);
		} catch (Exception e) {
			return new String[] {e.getMessage()};
		}
	}

	
	/**
	 * Maak een kopie van dit file naar opgegeven pad. 
	 * Als target pad is een directory, plaats het dan daar onder de file naaam.
	 * Wanneer de doeldirectory niet bestaat, maak die dan aan.
	 * Overschrijft eventueel bestaand file.
	 * @throws IOException 
	 */
	
	public void copyFile(File targetFile) throws IOException {
		if (this.isDirectory()) throw new IOException("Kan geen directory als file kopieren: " + this.getCanonicalPath());
		if (targetFile.isDirectory()) targetFile = new File(targetFile.getAbsolutePath() + File.separator + this.getName());
		FileUtils.copyFile(this, targetFile, true);
	}
	public void copyFile(String targetFile) throws Exception {
		copyFile(new File(targetFile));
	}
	

	/**
	 * break a path down into individual elements and add to a list.
	 * example : if a path is /a/b/c/d.txt, the breakdown will be [d.txt,c,b,a]
	 * 
	 * taken from: http://www.devx.com/tips/Tip/13737
	 * 
	 * @param f input file
	 * @return a List collection with the individual elements of the path in reverse order
	 */
	private List<String> getPathList(File f) {
		List<String> l = new ArrayList<String>();
		File r;
		try {
			r = f.getCanonicalFile();
			while(r != null) {
				l.add(r.getName());
				r = r.getParentFile();
			}
		}
		catch (IOException e) {
			e.printStackTrace();
			l = null;
		}
		return l;
	}

	/**
	 * Figure out a string representing the relative path of
	 * 'f' with respect to 'r'
	 * 
	 * taken from: http://www.devx.com/tips/Tip/13737
	 * @param r home path
	 * @param f path of file
	 */
	private String matchPathLists(List<String> r,List<String> f) {
		
		// start at the beginning of the lists
		// iterate while both lists are equal
		String s = "";
		int i = r.size()-1;
		int j = f.size()-1;

		// first eliminate common root
		while((i >= 0)&&(j >= 0)&&(r.get(i).equals(f.get(j)))) {
			i--;
			j--;
		}

		// for each remaining level in the home path, add a ..
		for(;i>=0;i--) {
			s += ".." + File.separator;
		}

		// for each level in the file path, add the path
		for(;j>=1;j--) {
			s += f.get(j) + File.separator;
		}

		// file name
		s += f.get(j);
		return s;
	}

	/**
	 * get relative path of File 'f' with respect to 'home' directory
	 * example : home = /a/b/c
	 *           f    = /a/d/e/x.txt
	 *           s = getRelativePath(home,f) = ../../d/e/x.txt
	 * 
	 * taken from: http://www.devx.com/tips/Tip/13737
	 * 
	 * @param home base path, should be a directory, not a file, or it doesn't make sense
	 * @param f file to generate path for
	 * @return path from home to f as a string
	 */
	public String getRelativePath(File home){
		List<String> homelist = getPathList(home);
		List<String> filelist = getPathList(this);
		String s = matchPathLists(homelist,filelist);
		return s;
	}
	public String getRelativePath(String homePath){
		List<String> homelist = getPathList(new File(homePath));
		List<String> filelist = getPathList(this);
		String s = matchPathLists(homelist,filelist);
		return s;
	}
	
	/**
	 * Return a file writer, which allow strings to be written to this file. 
	 * If writing lines, append \n to the string.
	 * 
	 * @param append Append to the existing file?
	 * @return
	 * @throws IOException
	 */
	public FileWriterWithEncoding getWriterWithEncoding(String encoding, boolean append) throws IOException {
		return new FileWriterWithEncoding(this,"UTF-8",append); 
	}
	/**
	 * Return a file writer, which allow strings to be written to this file. 
	 * If writing lines, append \n to the string.
	 * 
	 * @param append Append to the existing file?
	 * @return
	 * @throws IOException
	 */
	public FileWriter getWriter(boolean append) throws IOException {
		return new FileWriter(this,append); 
	}
	/**
	 * Return a buffered file writer, which allow strings to be written to this file. 
	 * If writing lines, append \n to the string.
	 * 
	 * @param append Append to the existing file?
	 * @return
	 * @throws IOException
	 */
	public BufferedWriter getBufferedWriter(boolean append) throws IOException {
		return new BufferedWriter(getWriter(append)); 
	}
	
	public FileReader getReader() throws IOException {
		return new FileReader(this); 
	}

	/** 
	 * Write all file contents to the writer passed.
	 * 
	 * @param writer
	 * @throws IOException
	 */
	public void readToWriter(Writer writer) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(this));
        char[] buf = new char[1024];
        int numRead=0;
        while((numRead=reader.read(buf)) != -1){
            String readData = String.valueOf(buf, 0, numRead);
            writer.write(readData);
            buf = new char[1024];
        }
        reader.close();
    }

	/**
	 * Guess if this file is an XML file.
	 * Test if the file starts with <?xml. 
	 * Only suited for UTF-8.
	 *  
	 * @return
	 * @throws Exception 
	 */
	public boolean isXml() throws Exception {
        return getHead(5).equals("<?xml");
	}
	
	public String getHead(int numberBytes) throws Exception {
		FileInputStream is = new FileInputStream(this.getAbsolutePath());
		byte bytes[] = new byte[numberBytes];
        is.read(bytes);
        String r = new String(bytes, "UTF-8");
        is.close();
        return r;
	}
	
	/**
	 * Dit gaat terug op
	 * https://code.google.com/p/juniversalchardet/
	 * 
	 * @return
	 * @throws IOException
	 */
	public String guessEncoding() throws IOException {
		byte[] buf = new byte[4096];
	    FileInputStream fis = new FileInputStream(this.getAbsolutePath());

	    // (1)
	    UniversalDetector detector = new UniversalDetector(null);

	    // (2)
	    int nread;
	    while ((nread = fis.read(buf)) > 0 && !detector.isDone()) {
	      detector.handleData(buf, 0, nread);
	    }
	    // (3)
	    detector.dataEnd();

	    // (4)
	    String encoding = detector.getDetectedCharset();
	    
	    // (5)
	    detector.reset();
	    fis.close();

        return encoding;
 	}

	private static String match(String s, String regex) {
		Matcher m = Pattern.compile(regex).matcher(s);
		if (m.find()) 
			return s.substring(m.start(), s.length() - m.end());
		else 
			return null;
	}
	
	/**
	 * Read the next line. 
	 * If  no more lines available, close the stream and return null. 
	 * Next call, reopen the stream and start again.
	 * 
	 * @return
	 * @throws IOException
	 */
	public String getNextLine() throws IOException {
		String line = null;
		
		if (lineReader == null)
			lineReader = new BufferedReader(new FileReader(this));
	
		if (!(lineReader.ready() && (line = lineReader.readLine()) != null))
				lineReader.close();	
	
		return line;
	}
	
	
}


