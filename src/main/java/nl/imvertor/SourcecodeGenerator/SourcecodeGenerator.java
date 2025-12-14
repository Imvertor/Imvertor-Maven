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

import static java.lang.String.format;

import java.io.File;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.compress.utils.FileNameUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
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
  
  private static final String[] SUPPORTED_SOURCECODE_TYPES = { "entity-xml", "plantuml", "java-pojo", "java-jpa", "java-openapi", "java-openapi-model", "java-openapi-resource" }; 

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

    report();

    return runner.succeeds();
  }

  /**
   * Generate code on MIM serialization
   * 
   * @throws Exception
   */
  public boolean generateDefault() throws Exception {
    
    boolean succeeds = true;
    
    // check of MIM resultaat beschikbaar is
    succeeds = succeeds && AnyFile.exists(configurator.getXParm("properties/WORK_MIMFORMAT_XMLPATH", false));
    if (!succeeds) {
      runner.error(logger, "Error generating source code; no MIM serialization available");
      configurator.setXParm("system/sourcecode-generator-created", succeeds);
      return succeeds;
    }

    // create a transformer
    Transformer transformer = new Transformer();

    runner.debug(logger, "CHAIN", "Generating source code");

    // String mimVersion = configurator.getXParm("appinfo/metamodel-minor-version");
    // transformer.setXslParm("mim-version", mimVersion);

    /* We can set MIM version to 1.2 because we are going to transform the MIM serialization to 1.2 anyway: */
    String mimVersion = "1.2";
    
    String sourceCodeTypes = configurator.getXParm("cli/sourcecodetypes", false);
    if (sourceCodeTypes == null) {
      sourceCodeTypes = "java-openapi-model,java-openapi-resource";
    } else {
      sourceCodeTypes = configurator.mergeParms(sourceCodeTypes);
    }
    
    String xslFileParamMIM_11_to_12 = "properties/IMVERTOR_CODEGEN_MIM_1.1_TO_1.2_XSLPATH";
    String workFileParamMIM_11_to_12 = "properties/WORK_CODEGEN_MIM_1.1_TO_1.2_FILEPATH";
    
    String xslFileParamMIMResolved = "properties/IMVERTOR_CODEGEN_MIM_RESOLVED_" + mimVersion + "_XSLPATH";
    String workFileParamMIMResolved = "properties/WORK_CODEGEN_MIM_RESOLVED_FILEPATH";
    
    Set<String> types = new HashSet<>(Arrays.asList(sourceCodeTypes.trim().split("\\s*[,;]\\s*")));
    
    if (types.contains("java-openapi")) {
      /* Expand the type "java-openapi": */
      types.remove("java-openapi");
      types.add("java-openapi-resource");
      types.add("java-openapi-model");
    }
   
    for (String type: types) {
      if (!StringUtils.equalsAny(type, SUPPORTED_SOURCECODE_TYPES)) {
        runner.warn(logger, format("Unsupported sourcecodetype \"%s\"; must be one of %s", type, Arrays.toString(SUPPORTED_SOURCECODE_TYPES)));
        continue;
      }
      String xslFileParam = "properties/IMVERTOR_CODEGEN_" + type.toUpperCase().replace("-", "_") + "_" + mimVersion + "_XSLPATH";
      
      String workFileParam = "properties/WORK_CODEGEN_" + type.toUpperCase().replace("-", "_") + "_FILEPATH";
      String workDirParam = "properties/WORK_CODEGEN_" + type.toUpperCase().replace("-", "_") + "_DIRPATH";
      
      String workFilePath = configurator.getXParm(workFileParam, false);
      String workDirPath = configurator.getXParm(workDirParam, false);
      
      File workFile = null;
      if (workFilePath != null) {
        workFile = new File(workFilePath);
      }
      
      File workDirFile = null;
      if (workDirPath != null) {
        workDirFile = new File(workDirPath);
        transformer.setXslParm("output-uri", workDirFile.toURI().toString());  
      }

      String sourcecodeCopyDownMixins = configurator.getXParm("cli/sourcecodecopydownmixins", false);
      String sourcecodeResolveKeuzeAttribuutsoorten = configurator.getXParm("cli/sourcecoderesolvekeuzeattribuutsoorten", false);
      String sourcecodeResolveKeuzeRelatiedoelen = configurator.getXParm("cli/sourcecoderesolvekeuzerelatiedoelen", false);
      String sourcecodeResolveKeuzeDatatypen = configurator.getXParm("cli/sourcecoderesolvekeuzedatatypen", false);
      String openapiSpecVersion = configurator.getXParm("cli/openapispecversion", false);
      String openapiSchemasOnly = configurator.getXParm("cli/openapischemasonly", false);
      String openApiBundleDescriptions = configurator.getXParm("cli/openapibundledescriptions", false);
          
      if (sourcecodeCopyDownMixins != null)
        transformer.setXslParm("sourcecode-copy-down-mixins", sourcecodeCopyDownMixins);
      if (sourcecodeResolveKeuzeAttribuutsoorten != null)
        transformer.setXslParm("sourcecode-resolve-keuze-tussen-attribuutsoorten", sourcecodeResolveKeuzeAttribuutsoorten);
      if (sourcecodeResolveKeuzeRelatiedoelen != null)
        transformer.setXslParm("sourcecode-resolve-keuze-tussen-relatiedoelen", sourcecodeResolveKeuzeRelatiedoelen);
      if (sourcecodeResolveKeuzeDatatypen != null)
        transformer.setXslParm("sourcecode-resolve-keuze-tussen-datatypen", sourcecodeResolveKeuzeDatatypen);
      if (openapiSpecVersion != null)
        transformer.setXslParm("openapi-spec-version", openapiSpecVersion);
      if (openapiSchemasOnly != null)
        transformer.setXslParm("openapi-schemas-only", openapiSchemasOnly);
      if (openApiBundleDescriptions != null)
        transformer.setXslParm("openapi-bundle-descriptions", openApiBundleDescriptions);
      
      /* Convert MIM 1.1 to 1.2 namespaces : */ 
      succeeds = succeeds && transformer.transformStep("properties/WORK_MIMFORMAT_XMLPATH", workFileParamMIM_11_to_12, xslFileParamMIM_11_to_12);
      
      /* Optionally resolve Keuze constructs and copy down mixins: */
      succeeds = succeeds && transformer.transformStep(workFileParamMIM_11_to_12, workFileParamMIMResolved, xslFileParamMIMResolved);
      
      /* Generate the actual Java code: */
      succeeds = succeeds && transformer.transformStep(workFileParamMIMResolved, workFileParam, xslFileParam);

      // store to sourcecode folder
      if (succeeds) {
        AnyFolder outputFolder = new AnyFolder(configurator.getXParm("system/work-codegen-folder-path"));
        outputFolder.mkdirs();
        if (workDirFile != null && workDirFile.isDirectory()) {
          FileUtils.copyDirectory(workDirFile, new File(outputFolder, type));
        } else if (workFile != null) {
          String n = configurator.getXParm("cli/sourcecodename", false);
          String fileName = configurator.mergeParms((n != null) ? n : "[appinfo/application-name]");
          FileUtils.copyFile(workFile, new File(new File(outputFolder, type), fileName + "." + FileNameUtils.getExtension(workFilePath)));
        }
      }
    }

    configurator.setXParm("system/codegen-created", succeeds);
    configurator.setXParm("system/codegen-sourcecode-types", sourceCodeTypes);

    return succeeds;
  }
  
}