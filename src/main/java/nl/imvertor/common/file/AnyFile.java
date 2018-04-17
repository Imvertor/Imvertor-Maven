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
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Writer;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.output.FileWriterWithEncoding;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
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
	
	public static final Integer FILE_IDENTIFICATION = 1;
	public static final Integer CONTENT_IDENTIFICATION = 2;
	public static final Integer FILE_AND_CONTENT_IDENTIFICATION = 3;
	
	public LinkedList<File> files;
	
	
	private BufferedReader lineReader = null;
	
	private Charset charset;
	
	
	/**
	 * Convenience method: fast read of file contents.
	 * 
	 * @param filepath
	 * @return
	 * @throws IOException
	 */
	public static String getFileContent(String filepath) throws IOException {
		return (new AnyFile(filepath)).getContent();
	}
	/**
	 * Convenience method: fast write to file.
	 * 
	 * @param filepath
	 * @param content
	 * @throws IOException
	 */
	public static void setFileContent(String filepath, String content) throws IOException {
		(new AnyFile(filepath)).setContent(content);
	}
	
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
		return path.startsWith("\\") || path.startsWith("/") |  (match(path,"^(.:)") != null);
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
		String encoding = guessEncoding();
		if (encoding == null) encoding = StandardCharsets.UTF_8.name();
		return getContent(encoding);
	}
	
	/**
	 * Return a string containing the entire file contents. 
	 * Pass encoding, i.e. the name of a character set.
	 * Get the right name using StandardCharsets.UTF_8 etc.
	 * 
	 * @param encoding
	 * @return
	 * @throws IOException
	 */
	public String getContent(String encoding) throws IOException {
		StringBuffer fileData = new StringBuffer(1000);
	    BufferedReader reader = new BufferedReader(new InputStreamReader(getFileInputStream(), encoding));
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
		createFile();
		FileWriterWithEncoding out = new FileWriterWithEncoding(this, "UTF-8", append);
        out.write(s);
        out.flush();
        out.close();
	}

	public void replaceAll(String oldString, String newString) throws IOException {
		String c = getContent();
		setContent(StringUtils.replace(c,oldString,newString));
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
	 * Filespec is an array of strings. This holds info on the file, based on the requested info type, expressed as an Uppercase letter in options.
	 * 
	 * 0 P Path,
	 * 1 U URL,
	 * 2 N name (no extension),
	 * 3 X extension,
	 * 4 E E when exists, otherwise e.
	 * 
	 * The following strings are added when the path exists: requires E parameter (this info is only extracted when E is tested):
	 *  
	 * 5 F when it is a file, otherwise f (it's a directory)
	 * 6 H when it is hidden, otherwise h
	 * 7 R when it can be read, otherwise r
	 * 8 W when it can be written to, otherwise w
	 * 9 C when it can be executed, otherwise c
	 * 10 D the date & time in ISO format
	 *
	 * When an error occurred, only 1 string is returned, the error message.
	 * 
	 * @param filepath
	 * @return
	 */
	public String[] getFilespec(String options) {
		String name = getName();
		Boolean fileExists = options.contains("E") ? exists() : false; 
		int i = name.lastIndexOf('.');
		String[] parms = {}, specs = {};
		try {
			if (fileExists) {
				parms = new String[] {
					options.contains("F") ? ((isDirectory()) ? "f" : "F") : "",
					options.contains("H") ? ((isHidden()) ? "H" : "h") : "",
					options.contains("R") ? ((canRead()) ? "R" : "r") : "",
					options.contains("W") ? ((canWrite()) ? "W" : "w") : "",
					options.contains("C") ? ((canExecute()) ? "C" : "c") : "",
					options.contains("D") ? ((new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:sssZ")).format(lastModified()))  : ""
				};
			} 
			specs = new String[] {
					options.contains("P") ? getCanonicalPath() : "",
					options.contains("U") ? toURI().toURL().toString() : "",
					options.contains("N") ? ((i > 0 && i < name.length() - 1) ? name.substring(0,i) : name) : "",
					options.contains("X") ? ((i > 0 && i < name.length() - 1) ? name.substring(i + 1) : "") : "",
					options.contains("E") ? ((fileExists) ? "E" : "e") : ""
				};
			return ArrayUtils.addAll(specs, parms);
		} catch (Exception e) {
			return new String[] {e.getMessage()};
		}
	}
	/**
	 * Pass the full filespec as an array of strings. 
	 * Retrieves all possible info.
	 */
	public String[] getFilespec() {
		return getFilespec("PUNXEFHRWCD");
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
	 * Test if the file starts with <?xml or <xml. 
	 * Only suited for UTF-8.
	 *  
	 * @return
	 * @throws Exception 
	 */
	public boolean isXml() throws Exception {
		if (getExtension().equals("xml")) return true;
		if (getExtension().equals("xsl")) return true;
		if (getExtension().equals("xslt")) return true;
		if (getExtension().equals("xmi")) return true;
		
		byte[] head = getHeadBytes(5);
		if ((new String(Arrays.copyOfRange(head,0,5), "UTF-8")).equals("<?xml")) return true;
		if ((new String(Arrays.copyOfRange(head,0,5), "UTF-8")).equals("<xsl:")) return true;
		if ((new String(Arrays.copyOfRange(head,0,4), "UTF-8")).equals("<xml")) return true;
	
		return false;
	}
	
	public byte[] getHeadBytes(int numberBytes) throws Exception {
		FileInputStream is = getFileInputStream();
		byte bytes[] = new byte[numberBytes];
        is.read(bytes);
        is.close();
        return bytes;
	}
	
	public FileInputStream getFileInputStream() throws FileNotFoundException {
		return new FileInputStream(this.getAbsolutePath());
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
	    FileInputStream fis = getFileInputStream();

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

	/**
	 * Get the character set for the encoding name passed.
	 * If encoding is not specified, return UTF-8 Charset.
	 * 
	 * @param encoding
	 * @return
	 * @throws Exception 
	 */
	public static Charset getCharsetForEncoding(String encoding) throws Exception {
		if (encoding == null)
			return StandardCharsets.UTF_8;
		else if (encoding.equals("WINDOWS-1252"))
			return StandardCharsets.ISO_8859_1;
		else 
			return StandardCharsets.UTF_8;
	}
	
	private static String match(String s, String regex) {
		Matcher m = Pattern.compile(regex).matcher(s);
		if (m.find()) 
			return s.substring(m.start(), m.end());
		else 
			return null;
	}
	
	/**
	 * Read the next line. 
	 * If  no more lines available, close the stream and return null. 
	 * Next call, reopen the stream and start again.
	 * 
	 * Encoding is optional; when not provided guess the encoding of the file.
	 * 
	 * @return
	 * @throws Exception 
	 */
	public String getNextLine() throws Exception {
		if (charset == null) 
			charset = getCharsetForEncoding(guessEncoding());
		return getNextLine(charset);
	}
	
	public String getNextLine(Charset cs) throws IOException {
		if (charset == null) 
			charset = cs;

		String line = null;
		
		if (lineReader == null) {
			FileInputStream is = new FileInputStream(this);
			InputStreamReader isr = new InputStreamReader(is, cs);
			lineReader = new BufferedReader(isr);
		}
		if (!(lineReader.ready() && (line = lineReader.readLine()) != null))
				close();	
	
		return line;
	}
	
	/**
	 * Close the file for line reading. 
	 * Closing a closed file has no effect.
	 * @throws IOException 
	 */
	public void close() throws IOException {
		if (lineReader != null) 
			lineReader.close();
	}
	
	/**
	 * Create this file if it doesn't exists yet. 
	 * @throws IOException 
	 * 
	 */
	public void createFile() throws IOException {
		if (!exists()) {
			getParentFile().mkdirs();
			createNewFile();
		}
	}
	
	public String getLastLine() throws Exception {  // TODO introduce encoding like in  getNextLine()
		String lastLine = ""; 
		while (true) {
			String line = getNextLine();
			if (line == null) 
				break;
			else
				lastLine = line;
		}
		return lastLine;
	}
	
	/*
	 * Return Etag based on MD5; this is a weak or strong referrer based on the file specs, its contents, or both 
	 */
	public String getETag(Integer type) throws IOException {
		String content = 
				(type == CONTENT_IDENTIFICATION) ? this.getContent() : 
					(type == FILE_IDENTIFICATION) ? this.getFileInfo() : 
						this.getFileInfo() + this.getContent();
		
		return String.valueOf(DigestUtils.md5(content));
	}
}


