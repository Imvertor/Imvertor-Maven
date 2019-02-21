package nl.imvertor.common.file;

import java.io.File;
import java.io.IOException;

public class WikiFile extends AnyFile {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public static void main(String[] args) throws IOException {
		WikiFile f = new WikiFile("c:\\temp\\test.txt");
		f.toHtml(new File("c:\\temp\\test.html"));
	}
	
	public WikiFile(String pathname) {
		super(pathname);
	}
	
	public void toHtml(File outfile) throws IOException {
		this.getContent();
		
	}
}
