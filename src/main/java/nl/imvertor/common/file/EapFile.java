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
import java.util.Iterator;
import java.util.Vector;

import org.apache.commons.io.FileUtils;
import org.sparx.Collection;
import org.sparx.EnumXMIType;
import org.sparx.Package;
import org.sparx.Project;
import org.sparx.Repository;

/**
 * An EapFile is a representation of an EAP project file. 
 * 
 * The EapFile is an AnyFile and therefore does not access the chain environment. 
 *  
 * EA reference:
 * http://www.sparxsystems.com/enterprise_architect_user_guide/10/automation_and_scripting/reference.html
 * 
 * @author arjan
 *
 */
public class EapFile extends AnyFile {

	private static final long serialVersionUID = -6533178446439903883L;

	public static int SUPPRESS_DIAGRAM = 0;
	public static int EXPORT_DIAGRAM = 1;
	public static int EXPORT_DIAGRAM_AND_ALTERNATE = 2;
	
	public static int EXPORT_IMAGE_TYPE_NONE = -1;
	public static int EXPORT_IMAGE_TYPE_EMF = 0;
	public static int EXPORT_IMAGE_TYPE_BMP = 1;
	public static int EXPORT_IMAGE_TYPE_GIF = 2;
	public static int EXPORT_IMAGE_TYPE_PNG = 3;
	public static int EXPORT_IMAGE_TYPE_JPG = 4;
	
	private Repository repo;
	private Project project;
	private String htmlReportStyle;

	public int exportDiagrams = SUPPRESS_DIAGRAM; // 0 = Do not export diagrams, 1 = Export diagrams, 2 = Export diagrams along with alternate images
	public int exportDiagramImage = EXPORT_IMAGE_TYPE_PNG; // DiagramImage:  - the format for diagram images to be created at the same time; accepted values: -1=NONE 0=EMF 1=BMP 2=GIF 3=PNG 4=JPG.
	public int exportFormatXML = 1; // FormatXML:  - true if XML output should be formatted prior to saving.
	public int exportUseDTD = 0; // UseDTD: - true if a DTD should be used.
	
	/**
	 * Create an EAP file by supplying a full path.
	 * 
	 * @param path
	 */
	public EapFile(String path) {
		super(path);
	}
	
	/**
	 * Create an EAP file by supplying a File.
	 * 
	 * @param path
	 */
	public EapFile(File file) {
		super(file.getAbsolutePath());
	}
	
	public void setExportDiagrams(int imageFormat) {
		if (imageFormat >= 0) {
			exportDiagrams = 2;
			exportDiagramImage = imageFormat;
		} else 
			exportDiagrams = 0;
	}
	
	/**
	 * Export EAP as an XMI file which is retained until the program end. 
	 * In order to save the XMI create a copy the result XmlFile.
	 * 
	 * @return XmlFile which is available until end of program.
	 * @throws Exception
	 */
	public XmlFile exportToXmiFile() throws Exception {
		File outFile = File.createTempFile("exportToXmiFile", ".xml");
		outFile.deleteOnExit();
		return exportToXmiFile(outFile.getCanonicalPath());
	}
	
	/**
	 * Export EAP as an XMI file, writing to the specified output file.
	 * If the file exists, it is overwritten.
	 * 
	 * @param xmiFile
	 * @return
	 * @throws Exception
	 */
	public XmlFile exportToXmiFile(String xmiFilePath) throws Exception {
		exportXML(nativePath(xmiFilePath),true);
		return new XmlFile(xmiFilePath);
	}
	
	/**
	 * Export a particular package (and its subpackages) in EAP as an XMI file, writing to the specified output file.
	 * If the file exists, it is overwritten.
	 * 
	 * @param xmiFile
	 * @return
	 * @throws Exception
	 */
	public XmlFile exportToXmiFile(String xmiFilePath, String packageGUID) throws Exception {
		exportXML(packageGUID, nativePath(xmiFilePath), true);
		return new XmlFile(xmiFilePath);
	}
	/**
	 * Import XMI into this EAP file. The XMI is fully imported at model level.
	 * 
	 * @param xmiFile
	 * @return
	 * @throws Exception
	 */
	public void importFromXmiFile(String xmiFilePath) throws Exception {
		importXML(project.GUIDtoXML(getRootModel().GetPackageGUID()), nativePath(xmiFilePath));
	}
	
	/**
	 * Export EAP as an HTML file report, writing to the specified output directory.
	 * If any files exist in that directory, they are removed first.
	 * Specify any style declared within the EA project, or pass the empty string.
	 * 
	 * @param outFile
	 * @return
	 * @throws Exception
	 */
	public File exportToHtmlReport(String outFolderPath, String packageName, String style) throws Exception {
		htmlReportStyle = style;
		exportHTML(nativePath(outFolderPath),packageName);
		return new File(outFolderPath);
	}

	/**
	 * 
	 * @throws Exception
	 */
	public void debug() throws Exception {
		org.sparx.Collection<org.sparx.Package> models = repo.GetModels();
		for (Package pkg : models) {
			dumpPackageHierarchy(pkg, 0);
		}
	}

	/**
	 * Open a EA instance for subsequent actions. 
	 * 
	 * Note that from Java we cannot access an open EA process (which would speed up things):
	 * http://sparxsystems.com/forums/smf/index.php?topic=2066.0
	 * 
	 * @return
	 * @throws Exception
	 */
	public boolean open() throws Exception {
		if (!this.canRead()) 
			throw new Exception("Cannot read the EA file.");
		boolean result = false;
		repo = new Repository();
		repo.ShowWindow(0);
		repo.SetEnableUIUpdates(false);
		result = repo.OpenFile(this.getAbsolutePath());
		project = repo.GetProjectInterface();
		return result;
	}

	/**
	 * 
	 */
	public void close() {
		if (repo != null) {
			repo.CloseFile();
			repo.Exit();
			repo.destroy();
			repo = null;
		}
	}

	/**
	 * Code adapted from http://sourceforge.jp/projects/ea2ddl/scm/svn/blobs/87/trunk/EaConnect/src/main/java/jp/sourceforge/ea2ddl/eaconnect/EaConnect.java
	 * Info at http://www.sparxsystems.com/uml_tool_guide/sdk_for_enterprise_architect/project_2.htm
	 * 
	 * @param guid
	 * @param fullpath
	 * @param recurse
	 * @throws Exception 
	 */
	private void exportXML(String fullpath, boolean recurse) throws Exception {
		exportXML(getModels().firstElement().GetPackageGUID(), fullpath, recurse);
	}
	/**
	 * 
	 * @param guid
	 * @param fullpath
	 * @param recurse
	 */
	private void exportXML(String guid, String fullpath, boolean recurse) {
		int xmiFlag = recurse ? 0 : 1;
		String g = project.GUIDtoXML(guid);
		project.ExportPackageXMIEx(g, EnumXMIType.xmiEADefault, exportDiagrams, exportDiagramImage, exportFormatXML, exportUseDTD, fullpath, xmiFlag);
	}

	/**
	 * 
	 * @param folderPath
	 * @param packageName
	 * @throws Exception
	 */
	private void exportHTML(String folderPath, String packageName) throws Exception {
		Iterator<Package> mit = repo.GetModels().iterator();
		Package model;
		Package applicationPackage = null;
		while (mit.hasNext()) {
			model = mit.next();
			Iterator<Package> pit = getPackageHierarchy(model).iterator();
			while (pit.hasNext()) {
				applicationPackage = pit.next();
				if (applicationPackage.GetName().equals(packageName)) 
					break; 
			}
			if (applicationPackage != null) 
				break;
		}
		if (applicationPackage != null)
			exportHTMLByGuid(folderPath,applicationPackage.GetPackageGUID());
		else 
			throw new Exception("No package by that name: \"" + packageName + "\"");
	}
	
	/**
	 * 
	 * @param folderPath
	 * @param guid
	 * @throws Exception
	 */
	private void exportHTMLByGuid(String folderPath, String guid) throws Exception {
		File folder = new File(folderPath);
		File root = new File(folder,"EARoot");
		if (folder.exists())
			if (root.exists())
				FileUtils.deleteQuietly(folder);
			else 
				throw new Exception("Will not write to a non-EA output HTML folder: \"" + folder.getCanonicalPath() + "\"");
		folder.mkdirs();
		project.RunHTMLReport(project.GUIDtoXML(guid), folderPath, "PNG", htmlReportStyle, "html");
	}
	
	/**
	 * Import XMI file.
	 * 
	 * Based on EA http://www.sparxsystems.com/uml_tool_guide/sdk_for_enterprise_architect/project_2.htm
	 * ImportPackageXMI (string PackageGUID, string Filename, long ImportDiagrams, long StripGUID)
	 * 
	 * Note that an XML GUID must be passed, ie. project.GUIDtoXML(GUID).
	 * 
	 * @param packageXMLGUID
	 * @param filepath
	 */
	public void importXML(String packageXMLGUID, String filepath) {
		project.ImportPackageXMI(packageXMLGUID, filepath, 1, 1); // import diagrams AND strip GUIDs on import
	}
	
	/**
	 * 
	 * @return
	 * @throws Exception
	 */
	public Package getRootModel() throws Exception {
		Iterator<Package> it = repo.GetModels().iterator();
		Package model = null;
		while (it.hasNext()) {
			model = it.next();
			if (model.GetIsModel()) break; 
		}
		if (model != null)
			return model;
		else 
			throw new Exception("No root model found.");
	}
	/**
	 * Return a list of all packages that are children of the package passed.
	 *  
	 * @return
	 * @throws Exception
	 */
	public Vector<Package> getChildPackages(Package parentPackage) throws Exception {
		Iterator<Package> it = parentPackage.GetPackages().iterator();
		Vector<Package> v = new Vector<Package>();
		while (it.hasNext()) v.add(it.next());
		return v;
	}
	/**
	 * Return a list of all packages that are children of any EAP root model.
	 *  
	 * @return
	 * @throws Exception
	 */
	public Vector<Package> getChildPackages() throws Exception {
		Vector<Package> v = new Vector<Package>();
		Iterator<Package> it = repo.GetModels().iterator();
		while (it.hasNext()) {
			v.addAll(getChildPackages(it.next()));
		}
		return v;
	}
	
	/**
	 * 
	 * 
	 * @param pkg
	 * @param hierarchy
	 */
	private void dumpPackageHierarchy(Package pkg, int hierarchy) {
		for (int i = 0; i < hierarchy; i++) {
			System.out.print(" ");
		}
		System.out.printf("%s	%s	D: %d	E: %d\n", pkg.GetName(), pkg.GetPackageGUID(), pkg.GetDiagrams().GetCount(), pkg.GetElements().GetCount());
		for (Package subPkg : pkg.GetPackages()) {
			dumpPackageHierarchy(subPkg, hierarchy + 1);
		}
	}
	/**
	 * 
	 * @param pkg
	 * @return
	 */
	private Vector<Package> getPackageHierarchy(Package pkg) {
		Vector<Package> v = new Vector<Package>();
		v.add(pkg);
		for (Package subPkg : pkg.GetPackages()) {
			v.addAll(getPackageHierarchy(subPkg));
		}
		return v;
	}
	
	/**
	 * 
	 * @param path
	 * @return
	 * @throws IOException
	 */
	private String nativePath(String path) throws IOException {
		return (new File(path)).getCanonicalPath();
	}
	
	/**
	 * Return the GUID of the root package
	 * 
	 * @return
	 * @throws Exception
	 */
	public String getRootPackageGUID() throws Exception {
		Package rootPackage = this.getModels().firstElement(); // This is the first root in the EAP tree! This should be "Models" or the like
		return rootPackage.GetPackageGUID();
	}
	
	/**
	 * Get the GUID of the requested application package
	 * 
	 * @return
	 * @throws Exception
	 */
	public String getModelPackageGUID(String projectName, String modelName) throws Exception {
		Package p = null;
		for (int i = 0; i < repo.GetModels().GetCount(); i++) {
			Package r = repo.GetModels().GetAt((short) i);
			if (p == null) 
				p = getPackageByName(r, projectName);
			else
				throw new Exception("Multiple projects with name \"" + projectName + "\" found");
			}
		if (p == null) return "";
		Package m = getPackageByName(p, modelName);
		return (m != null) ? m.GetPackageGUID() : ""; 
	}
	/**
	 * Get the GUID of the requested project package
	 * 
	 * @return
	 * @throws Exception
	 */
	public String getProjectPackageGUID(String projectName) throws Exception {
		Package p = getPackageByName(repo.GetModels().GetAt((short) 0), projectName);
		return (p != null) ? p.GetPackageGUID() : ""; 
	}
	
	/**
	 * get the models the the repository
	 * 
	 * @return
	 */
	public Vector<Package> getModels() {
		Vector<Package> v = new Vector<Package>();
		Iterator<Package> it = repo.GetModels().iterator();
		while (it.hasNext()) {
			v.add(it.next());
		}
		return v;	
	}
	/**
	 * Get the models the the repository by name. The name must be an exact match.
	 * 
	 * @return
	 */
	public Vector<Package> getModelsByName(String name) {
		Vector<Package> v = new Vector<Package>();
		Iterator<Package> it = repo.GetModels().iterator();
		while (it.hasNext()) {
			Package pack = it.next();
			if (pack.GetName().equals(name))
				v.add(pack);
		}
		return v;	
	}
		
	/**
	 * Get all models (packages) as a vector, by depth first selection.
	 *  
	 * @return
	 */
	public Vector<Package> getAllModels() {
		Vector<Package> packs = new Vector<Package>();
		for (short idx = 0; idx < repo.GetModels().GetCount(); idx++) {
	        dumpPackage(packs,repo.GetModels().GetAt(idx));
		}
		return packs;
		
	}
	
	private void dumpPackage(Vector<Package> packs, Package p) {
		packs.add(p);
		Collection<Package> coll = p.GetPackages();
		for (short idx = 0; idx < coll.GetCount(); idx++) {
			dumpPackage(packs,coll.GetAt(idx));
		}
	}
	
	/**
	 * get a package by name, that must occur anywhere within the package passed.
	 * 
	 * @param ancestorPack
	 * @param packageName
	 */
	private Package getPackageByName(Package ancestorPack, String packageName) throws Exception {
		Iterator<Package> pit = getPackageHierarchy(ancestorPack).iterator();
		while (pit.hasNext()) {
			Package selectedPackage = pit.next();
			if (selectedPackage.GetName().equals(packageName)) // removed: selectedPackage.GetStereotypeEx().toLowerCase().equals("project") && 
				return selectedPackage; 
		}
		return null;
	}
	
	
}

