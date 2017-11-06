package nl.imvertor.common.file.filter;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;

import org.apache.commons.lang3.StringUtils;

import nl.imvertor.common.file.AnyFolder;

public class FileExistsFileFilter implements FileFilter {

	private String sourceFolderPath;
	private String targetFolderPath;
	
	public FileExistsFileFilter(AnyFolder sourceFolder,AnyFolder targetFolder) throws IOException {
		super();
		sourceFolderPath = slash(sourceFolder.getCanonicalPath());
		targetFolderPath = slash(targetFolder.getCanonicalPath());
	}
	
	@Override
	public boolean accept(File file) {
		// check if the file exists in the target folder (in that subpath); if so, reject.
		try {
			if (file.isFile()) {
				String subpath = slash(file.getCanonicalPath()).replaceFirst(sourceFolderPath, "");
				String targetPath = targetFolderPath + slash(subpath);
				if ((new File(targetPath)).exists())
					return false;
			}
		} catch (IOException e) {
			return false;
		}
		return true;
	}

	static String slash(String path) {
		return StringUtils.replace(path,"\\","/");
	}
}
