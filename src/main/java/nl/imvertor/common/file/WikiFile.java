package nl.imvertor.common.file;

import org.commonmark.node.*;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;

public class WikiFile extends AnyFile {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	public static int FORMAT_MARKDOWN = 0;
	public static int FORMAT_MEDIAWIKI = 1;
	public static int FORMAT_TEXTILE = 2;
	public static int FORMAT_CONFLUENCE = 3;
	
	public static void main(String[] args) throws Exception {
		WikiFile f = new WikiFile("c:\\temp\\test.txt");
		f.toHtml(new XmlFile("c:\\temp\\test.xhtml"),FORMAT_MARKDOWN);
	}
	
	public WikiFile(String pathname) {
		super(pathname);
	}
	
	public void toHtml(AnyFile outfile, int language) throws Exception {	
		if (language == FORMAT_MARKDOWN) 
			outfile.setContent(getHtmlFormatText(getContent(), language));
		else
			throw new Exception("Wiki format not supported: " + language);
	}

	public static String getHtmlFormatText(String wikiFormatText, int language) throws Exception {
		Parser parser = Parser.builder().build();
		Node document = parser.parse(wikiFormatText);
		HtmlRenderer renderer = HtmlRenderer.builder().build();
		return renderer.render(document);
	}
	
}
