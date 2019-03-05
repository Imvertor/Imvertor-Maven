package nl.imvertor.common.file;

import org.eclipse.mylyn.wikitext.parser.MarkupParser;
import org.eclipse.mylyn.wikitext.parser.markup.MarkupLanguage;
import org.eclipse.mylyn.wikitext.util.ServiceLocator;

import org.eclipse.mylyn.wikitext.mediawiki.MediaWikiLanguage;
import org.eclipse.mylyn.wikitext.markdown.MarkdownLanguage;
import org.eclipse.mylyn.wikitext.textile.TextileLanguage;
import org.eclipse.mylyn.wikitext.confluence.ConfluenceLanguage;

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
		outfile.setContent(getHtmlFormatText(getContent(), language));
	}

	public static String getHtmlFormatText(String wikiFormatText, int language) throws Exception {
		Object formatClass;
		switch (language) {
			case 0:
				formatClass = new MarkdownLanguage();
				break;
			case 1:
				formatClass = new MediaWikiLanguage();
				break;
			case 2:
				formatClass = new TextileLanguage();
				break;
			case 3:
				formatClass = new ConfluenceLanguage();
				break;
			default:
				throw new Exception("No such wiki language");
		}
		
		MarkupLanguage markupLanguage = ServiceLocator.getInstance().getMarkupLanguage(formatClass.getClass().getName());
	    MarkupParser parser = new MarkupParser(markupLanguage);
	    String dirtyHtml = parser.parseToHtml(wikiFormatText);
	    return dirtyHtml;
	}
	
}
