/* 
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

package nl.imvertor.SourcecodeGenerator;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import nl.imvertor.common.Step;
import nl.imvertor.common.Transformer;
import nl.imvertor.common.file.AnyFile;
import nl.imvertor.common.file.AnyFolder;

/**
 * The CodeGenerator takes the MIM serialization and transforms it to source
 * code (Java-JPA, ...).
 */
public class SourcecodeGenerator extends Step {

  protected static final Logger logger = Logger.getLogger(SourcecodeGenerator.class);

  public static final String STEP_NAME = "SourcecodeGenerator";
  public static final String VC_IDENTIFIER = "$Id: $";

  /**
   * run the main translation
   */
  public boolean run() throws Exception {

    // set up the configuration for this step
    configurator.setActiveStepName(STEP_NAME);
    prepare();

    runner.info(logger, "Generating source code");

    boolean succeeds = true;

    succeeds = succeeds && generateDefault();

    configurator.setStepDone(STEP_NAME);

    // save any changes to the work configuration for report and future steps
    configurator.save();

    // report(); TODO

    return runner.succeeds();
  }

  /**
   * Generate code on MIM serialization
   * 
   * @throws Exception
   */
  public boolean generateDefault() throws Exception {

    // create a transformer
    Transformer transformer = new Transformer();

    boolean succeeds = true;

    runner.debug(logger, "CHAIN", "Generating source code");

    String mimVersion = configurator.getXParm("appinfo/metamodel-minor-version");

    transformer.setXslParm("mim-version", mimVersion);

    String sourceCodeType = configurator.getXParm("cli/sourcecodetype", false);
    if (sourceCodeType == null) {
      sourceCodeType = "java-jpa";
    } else {
      sourceCodeType = configurator.mergeParms(sourceCodeType);
    }

    String xslFileParam;
    switch (sourceCodeType) {
    case "entity-xml":
      xslFileParam = "properties/IMVERTOR_SOURCECODE_ENTITY_XML_" + mimVersion + "_XSLPATH";
      break;
    case "java-jpa-dto":
      xslFileParam = "properties/IMVERTOR_SOURCECODE_JAVA_JPA_DTO_" + mimVersion + "_XSLPATH";
      break;
    default: /* java-jpa */
      xslFileParam = "properties/IMVERTOR_SOURCECODE_JAVA_JPA_" + mimVersion + "_XSLPATH";
      break;
    }

    // check of MIM resultaat beschikbaar is
    succeeds = succeeds && AnyFile.exists(configurator.getXParm("properties/WORK_MIMFORMAT_XMLPATH", false));

    File codePath = new File(configurator.getXParm("properties/WORK_SOURCECODE_CODEPATH", false));
    File xmlPath = new File(configurator.getXParm("properties/WORK_SOURCECODE_XMLPATH", false));
    transformer.setXslParm("output-uri", codePath.toURI().toString());

    succeeds = succeeds && transformer.transformStep("properties/WORK_MIMFORMAT_XMLPATH", "properties/WORK_SOURCECODE_XMLPATH", xslFileParam);

    // store to sourcecode folder
    if (succeeds) {
      AnyFolder outputFolder = new AnyFolder(configurator.getXParm("system/work-sc-folder-path"));
      outputFolder.mkdirs();
      if (codePath.isDirectory()) {
        FileUtils.copyDirectory(codePath, outputFolder);
      } else {
        String n = configurator.getXParm("cli/entityxmlname", false);
        String entityXmlName = configurator.mergeParms((n != null) ? n : "[appinfo/application-name]");
        FileUtils.copyFile(xmlPath, new File(outputFolder, entityXmlName + ".xml"));
      }
    }

    configurator.setXParm("system/sourcecode-generator-created", succeeds);
    configurator.setXParm("system/sourcecode-generator-type", sourceCodeType);

    return succeeds;
  }

}