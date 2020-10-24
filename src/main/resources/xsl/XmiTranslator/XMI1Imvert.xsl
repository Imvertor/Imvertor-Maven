<?xml version="1.0" encoding="UTF-8"?>
<!-- 
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
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    xmlns:UML="omg.org/UML1.3"
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
    xmlns:EAUML="http://www.sparxsystems.com/profiles/EAUML/1.0"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-doc.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    <xsl:import href="../common/Imvert-common-inspire.xsl"/>
    
    <xsl:import href="Note-field.xsl"/>
   
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="stylesheet-code">IMV</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <!-- Transform XMI 1.1 to Imvert format. According to metamodel BP. -->
 
    <xsl:variable name="xmi-document" select="/"/>

    <xsl:variable 
        name="extension-elements"          
        select="$xmi-document//xmi:Extension/elements/element[@scope='public']"/>
    <xsl:variable 
        name="extension-attributes"      
        select="$extension-elements/attributes/attribute[@scope='Public']"/>
    <xsl:variable 
        name="extension-connectors" 
        select="$xmi-document//xmi:Extension/connectors/connector"/>
    
    <xsl:variable 
        name="document-thecustomprofile" 
        select="$xmi-document//thecustomprofile:*"/>
    <xsl:variable 
        name="document-EAUML" 
        select="$xmi-document//EAUML:*"
        as="element()*"/>
    
    <xsl:variable 
        name="document-packages" 
        select="$xmi-document//UML:Package"
        as="element(UML:Package)*"/>
    <xsl:variable 
        name="document-classes" 
        select="$xmi-document//UML:Class"
        as="element(UML:Class)*"/>
    <xsl:variable 
        name="document-attributes" 
        select="$xmi-document//UML:Attribute"
        as="element(UML:Attribute)*"/>
    <xsl:variable 
        name="document-associations" 
        select="$xmi-document//UML:Association"
        as="element(UML:Association)*"/>
    <xsl:variable 
        name="document-classifier-roles" 
        select="$xmi-document//UML:ClassifierRole"
        as="element(UML:ClassifierRole)*"/>
    <xsl:variable 
        name="document-generalizations" 
        select="$xmi-document//UML:Generalization"
        as="element(UML:Generalization)*"/>
    
    <xsl:variable 
        name="document-association-traces" 
        select="$document-associations[UML:ModelElement.stereotype/UML:Stereotype/@name = 'trace']"/>
    
    <xsl:variable 
        name="document-association-nontraces" 
        select="$document-associations except $document-association-traces"
        as="element(UML:Association)*"/>
    
    <!-- 
        Determine what package is the root package (the model).
        This is the first package with the specified application name.
    -->
    <xsl:variable name="root-package" select="$document-packages[@name = $application-package-name][1]"/>
    <xsl:variable name="root-package-release" select="imf:get-profile-tagged-value($root-package,'release')[1]"/>
    
    <xsl:key name="key-construct-by-id" match="//*[@xmi.id]" use="@xmi.id"/>
    <xsl:key name="key-construct-by-idref" match="//*[@xmi:idref]" use="@xmi:idref"/>
    <xsl:key name="key-packages-by-alias" match="//package" use="properties/@alias"/>
    
    <xsl:variable 
        name="document-realisations" 
        select="$xmi-document//UML:Dependency[UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_type' and @value='Realisation']]"/>
    
    <xsl:variable name="additional-tagged-values" select="imf:get-config-tagged-values()" as="element(tv)*"/>
    
    <xsl:variable name="allow-duplicate-tv" select="imf:boolean(imf:get-config-string('cli','allowduplicatetv','no'))"/>
    <xsl:variable name="imvertor-task" select="imf:get-config-string('cli','task','compile')"/>
    
    <xsl:variable name="allow-native-scalars" select="imf:boolean(imf:get-config-string('cli','nativescalars','yes'))"/>
    <xsl:variable name="supports-baretype-transformation" select="imf:boolean($configuration-metamodel-file//features/feature[@name='supports-baretype-transformation'])"/>
    
    <xsl:template match="/">
        <imvert:packages>
            <xsl:choose>
                <xsl:when test="empty($root-package)">
                    <xsl:sequence select="imf:msg(.,'ERROR',
                        'Cannot find a model by the name [1]',
                        ($application-package-name)
                        )"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$debugging">
                        <debug-info>
                            <xref-props>
                                <xsl:sequence select="$parsed-xref-properties"/> 
                            </xref-props>
                            <additional-tagged-values>
                                <xsl:sequence select="$additional-tagged-values"/> 
                            </additional-tagged-values>
                        </debug-info>
                    </xsl:if>
                    <xsl:sequence select="imf:create-output-element('imvert:debug',$debugging)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:task',$imvertor-task)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:project',$project-name)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:application',$application-package-name)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:release',$root-package-release)"/>
                    
                    <xsl:sequence select="imf:create-output-element('imvert:metamodel',string-join($configuration-prologue/metamodels/metamodel/name,';'))"/>
                    <xsl:sequence select="imf:create-output-element('imvert:model-designation',$configuration-prologue/metamodels/metamodel/model-designation)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:generated',$generation-date)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:generator',$imvertor-version)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:exported',concat(replace(/XMI/@timestamp,' ','T'),'Z'))"/>
                    <xsl:sequence select="imf:create-output-element('imvert:exporter',concat(//XMI.documentation/XMI.exporter,' v ', //XMI.documentation/XMI.exporterVersion))"/>
                    
                    <imvert:supports>
                        <xsl:sequence select="imf:compile-support-info()"/>
                    </imvert:supports>
                    
                    <imvert:filters>
                        <xsl:sequence select="imf:compile-imvert-filter()"/>
                    </imvert:filters>
                    
                    <xsl:variable name="project-name-shown" select="($project-name, concat($owner-name,': ',$project-name))" as="xs:string+"/>
                    <xsl:variable name="project-package" select="$document-packages[imf:get-stereotypes(.)=imf:get-config-stereotypes('stereotype-name-project-package')]"/>
                    <xsl:variable name="root-project-package" select="$project-package[@name = $project-name-shown]"/>
                    
                    <xsl:sequence select="imf:set-config-string('appinfo','original-project-name',$root-project-package/@name)"/>
                    <xsl:sequence select="imf:set-config-string('appinfo','original-application-name',$application-package-name)"/>
                    
                    <xsl:sequence select="imf:set-config-string('appinfo','project-name',$project-name)"/>
                    <xsl:sequence select="imf:set-config-string('appinfo','application-name',$application-package-name)"/>
                    
                    <xsl:choose>
                        <xsl:when test="exists($project-package) and empty($root-project-package)">
                            <xsl:sequence select="imf:msg('ERROR',concat(
                                'Specified project &quot;', 
                                string-join($project-name-shown,'&quot; or &quot;'),
                                '&quot; should exist and be stereotyped as: ', 
                                imf:get-config-stereotypes('stereotype-name-project-package')))"/>
                        </xsl:when>
                        <xsl:when test="not(imf:get-config-has-owner())">
                            <xsl:sequence select="imf:msg('ERROR',
                                'Not a known owner: [1]',
                                ($owner-name)
                                )"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="$content/UML:Model/UML:Namespace.ownedElement/UML:Package[not(imf:is-diagram-package(.))]">
                                <xsl:sort select="imf:compile-sort-key(.)"/>
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                            
                            <!-- check if xlinks must be included -->
                            <xsl:if test="not(exists($document-packages[imf:get-normalized-name(@name,'package-name') = imf:get-normalized-name('xlinks','package-name')]))" >
                                <imvert:package>
                                    <imvert:found-name>Xlinks</imvert:found-name>
                                    <imvert:short-name>xlinks</imvert:short-name>
                                    <imvert:id>XLINKS</imvert:id>
                                    <imvert:conceptual-schema-name>XLINKS</imvert:conceptual-schema-name>
                                    <imvert:namespace>http://www.w3.org/1999/xlink</imvert:namespace>
                                    <imvert:documentation>
                                        <html:body><html:p>XLinks is an external specification. For documentation please consult http://www.w3.org/TR/xlink/</html:p></html:body>
                                    </imvert:documentation>
                                    <imvert:created>2014-10-30T17:01:50</imvert:created>
                                    <imvert:modified>2014-10-30T17:01:50</imvert:modified>
                                    <imvert:version>1.0.0</imvert:version>
                                    <imvert:phase>3</imvert:phase>
                                    <imvert:author>Simon Cox</imvert:author>
                                    <imvert:svn-string>Id: xlinks.xml 346 2013-05-06 08:34:33Z loeffa </imvert:svn-string>
                                    <imvert:stereotype id="stereotype-name-system-package">
                                        <xsl:value-of select="imf:get-normalized-name('system','stereotype-name')"/>
                                    </imvert:stereotype>
                                    <imvert:location>http://schemas.opengis.net/xlink/1.0.0/xlinks.xsd</imvert:location>
                                    <imvert:release>20010627</imvert:release>
                                </imvert:package>
                            </xsl:if>
                            
                            <!-- check if outside constructs are found 
                            
                               Ignore stubs that are source in a association. 
                               This is because traces may be recorded at the target, in stead of the source.  
                            -->
                            <xsl:variable name="stubs" select="$xmi-document/XMI/XMI.extensions/EAStub"/>
                            <xsl:if test="exists($stubs)" >
                                <imvert:package>
                                    <imvert:id>OUTSIDE</imvert:id>
                                    <xsl:for-each select="$stubs">
                                        <xsl:variable name="id" select="string(@xmi.id)"/>
                                        <xsl:variable name="attribute-end" select="exists($xmi-document//UML:Attribute/UML:StructuralFeature.type/UML:Classifier[@xmi.idref = $id])"/>
                                        <xsl:variable name="association-end" select="exists($document-association-nontraces//UML:AssociationEnd[@type = $id]/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_end' and @value = 'target'])"/>
                                        <xsl:variable name="generalization-end" select="exists($xmi-document//UML:Generalization[@supertype = $id])"/>
                                        <xsl:choose>
                                            <xsl:when test="@type = 'sentinel'">
                                                <imvert:class origin="stub" umltype="class" type="sentinel">
                                                    <imvert:found-name>
                                                        <xsl:value-of select="@name"/>
                                                    </imvert:found-name>
                                                </imvert:class> 
                                            </xsl:when>
                                            <xsl:when test="$attribute-end or $association-end or $generalization-end">
                                                <imvert:class origin="stub" umltype="{@UMLType}">
                                                    <!--
                                                        <xsl:comment select="string-join(('attribute-end', string($attribute-end), for $x in ($xmi-document//UML:Attribute[UML:StructuralFeature.type/UML:Classifier[@xmi.idref = $id]]/@name) return string($x)),' ')"/>
                                                        <xsl:comment select="string-join(('associate-end', string($association-end), for $x in ($xmi-document//UML:AssociationEnd[@type = $id and UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_end' and @value = 'target']]/../../@xmi.id) return string($x)),' ')"/>
                                                        <xsl:comment select="string-join(('generaliz-end', string($generalization-end), $xmi-document//UML:Generalization[@supertype = $id]//*[@tag='ea_sourceName']/@value),' ')"/>
                                                     -->
                                                    <imvert:found-name>
                                                        <xsl:value-of select="@name"/>
                                                    </imvert:found-name>
                                                    <imvert:id>
                                                        <xsl:value-of select="$id"/>
                                                    </imvert:id>
                                                </imvert:class> 
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:comment select="concat('Removed construct that is not referenced by this model: ', @name)"/>
                                            </xsl:otherwise>
                                        </xsl:choose> 
                                    </xsl:for-each>
                                </imvert:package>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
          
        </imvert:packages>
    </xsl:template>
  
    <!-- all selected packages result in schema's -->
    <xsl:template match="UML:Package">
        <xsl:param name="parent-is-derived" select="false()"/>
        
        <xsl:sequence select="imf:track('Transforming package [1]',@name)"/>
        
        <xsl:variable name="package-name" select="@name" as="xs:string"/>
        <xsl:variable name="package-id" select="@xmi.id" as="xs:string"/>
        <xsl:variable name="namespace" select="imf:get-alias(.,'P')"/>
        <xsl:variable name="metamodel" select="string-join($configuration,' ')"/>
        <xsl:variable name="model-level" select="imf:get-profile-tagged-value(.,'level','compact')"/>
        
        <xsl:variable name="supplier-info" select="imf:get-supplier-info(.,$parent-is-derived)" as="element()*"/>
        <xsl:variable name="is-derived" select="imf:boolean($supplier-info[self::imvert:derived])"/>
        
        <!-- is this the application package? -->
        <xsl:variable name="is-root-package" select=". is $root-package"/>

        <xsl:sequence select="if ($is-root-package) then imf:set-config-string('appinfo','application-alias',imf:get-alias(.,'P')) else ()"/>
        <xsl:sequence select="if ($is-root-package) then imf:set-config-string('appinfo','release',imf:get-profile-tagged-value(.,'release')[1]) else ()"/>
        
        <imvert:package>
            <xsl:sequence select="imf:create-output-element('imvert:is-root-package',if ($is-root-package) then 'true' else ())"/>
            <xsl:sequence select="imf:get-id-info(.,'P')"/>
            <xsl:sequence select="$supplier-info"/>
            <xsl:sequence select="imf:create-output-element('imvert:namespace',$namespace)"/>
            <xsl:sequence select="imf:create-output-element('imvert:model-level',$model-level)"/>
            <xsl:sequence select="imf:get-element-documentation-info(.)"/>
            <xsl:sequence select="imf:get-history-info(.)"/>
            <xsl:sequence select="imf:get-svn-info(.)"/>
            <xsl:sequence select="imf:get-stereotypes-info(.,'my')"/>
            <xsl:sequence select="imf:get-external-resources-info(.)"/>
            <xsl:sequence select="imf:get-config-info(.)"/>
            
            <xsl:for-each select="UML:Namespace.ownedElement/UML:Class"> <!-- was: [not(imf:get-stereotype-local-names(*/UML:Stereotype/@name)='enumeration')] -->
                <xsl:sort select="imf:compile-sort-key(.)"/>
                <xsl:apply-templates select="." mode="class-normal"/>
            </xsl:for-each>
            <xsl:for-each select="UML:Namespace.ownedElement/UML:Package[not(imf:is-diagram-package(.))]">
                <xsl:sort select="imf:compile-sort-key(.)"/>
                <!--<xsl:sort select="imf:get-alias(.,'P')"/>-->
                <xsl:apply-templates select=".">
                    <xsl:with-param name="parent-is-derived" select="$is-derived"/>
                </xsl:apply-templates>
            </xsl:for-each>
            
            <!-- add info on import dependecy relations (always to external packages) -->
            <xsl:for-each select="UML:Namespace.ownedElement/UML:Dependency[imf:get-stereotype-local-names(UML:ModelElement.stereotype/UML:Stereotype/@name)='import' and @client=$package-id]">
                <xsl:sequence select="imf:create-output-element('imvert:imported-package-id',@supplier)"/>
            </xsl:for-each>
           
            <xsl:variable name="seq" as="element(imvert:tagged-values)*">
                <xsl:sequence select="imf:fetch-additional-tagged-values(.)"/>
                <!-- sometimes tags are placed on the model in stead of on the package -->
                <xsl:if test="$is-root-package">
                    <xsl:sequence select="imf:fetch-additional-tagged-values($content/UML:Model)"/>
                </xsl:if>
            </xsl:variable>
            <imvert:tagged-values>
                <xsl:for-each-group select="$seq/*" group-by="@id">
                    <xsl:sequence select="current-group()[1]"/>
                </xsl:for-each-group>
            </imvert:tagged-values>           
            
            <!-- get package wide constraints -->
            <xsl:sequence select="imf:get-constraint-info(.)"/>
           
        </imvert:package>
    </xsl:template>
    
    <xsl:template match="UML:Package[imf:get-stereotypes(.) = imf:get-config-stereotypes('stereotype-name-recyclebin')]">
        <!-- IM-86: skip! -->
    </xsl:template>
    
    <xsl:template match="UML:Class" mode="class-normal">
        <xsl:variable name="this" select="."/>
        <xsl:variable name="id" select="@xmi.id"/>
        <xsl:variable name="supertype-ids" select="$document-generalizations-type[@subtype=$id]/@supertype"/>
        <xsl:variable name="attributes" select="UML:Classifier.feature/UML:Attribute"/>
        <xsl:variable name="stereotypes" select="imf:get-stereotypes(.)" as="xs:string*"/>
        <xsl:variable name="associations" select="imf:get-key($xmi-document,'key-document-associations-type',$id)"/>
        <xsl:variable name="is-abstract" select="if (imf:boolean(@isAbstract)) then 'true' else 'false'"/>
        <xsl:variable name="is-datatype" select="$stereotypes=imf:get-config-stereotypes('stereotype-name-simpletype') or imf:get-system-tagged-value(.,'ea_stype')='DataType'"/>
        <xsl:variable name="is-complextype" select="$stereotypes=imf:get-config-stereotypes('stereotype-name-complextype')"/>
        <!-- TODO overal de referenties naar expliciete stereotype names vervangen door imf:get-config-stereotypes('stereotype-name-*') -->
        <xsl:variable name="class-cardinality" select="imf:get-class-cardinality-bounds(.)"/>
        <xsl:variable name="designation">
            <xsl:choose>
                <xsl:when test="imf:get-system-tagged-value(.,'ea_stype')='DataType'">datatype</xsl:when>
                <xsl:when test="$stereotypes[imf:get-normalized-name(.,'class-name') = imf:get-normalized-name('datatype','class-name')]">datatype</xsl:when>
                <xsl:when test="$stereotypes[imf:get-normalized-name(.,'stereotype-name') = imf:get-normalized-name('enumeration','stereotype-name')]">enumeration</xsl:when>
                <xsl:when test="imf:get-system-tagged-value(.,'ea_stype')='Class'">class</xsl:when>
                <xsl:when test="$document-associations/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='associationclass']/@value=$id">associationclass</xsl:when>
                <xsl:otherwise>other</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$designation != 'other'">
            <imvert:class>
                <xsl:sequence select="imf:get-id-info(.,'C')"/>
                <xsl:sequence select="imf:create-output-element('imvert:designation',$designation)"/>
                <xsl:sequence select="imf:create-output-element('imvert:abstract',$is-abstract)"/>
                <xsl:sequence select="imf:get-element-documentation-info(.)"/>
                <xsl:sequence select="imf:get-history-info(.)"/>
                <xsl:sequence select="imf:get-stereotypes-info(.,'my')"/>
                <xsl:sequence select="imf:get-external-resources-info(.)"/>
                <xsl:for-each select="$supertype-ids">
                    <xsl:variable name="supertype-id" select="."/>
                    <xsl:variable name="supertype" select="imf:element-by-id($supertype-id)"/>
                   
                    <xsl:variable name="generalizations" select="imf:get-key($xmi-document,'key-document-generalizations', concat($id,'#',$supertype-id))"/>
                    <xsl:variable name="generalization" select="$generalizations[1]"/>
                    
                    <xsl:sequence select="if ($generalizations[2]) then imf:msg($this,'WARNING','Cannot handle multiple references to same supertype [1]',($supertype/@name)) else ()"/>
                    
                    <xsl:variable name="stereotypes" select="imf:get-stereotypes($generalization)"/>
                    
                    <xsl:choose>
                        <xsl:when test="$stereotypes=imf:get-config-stereotypes('stereotype-name-static-liskov')">
                            <imvert:substitution>
                                <xsl:sequence select="imf:create-output-element('imvert:supplier',$supertype/@name)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:supplier-id',$supertype-id)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:supplier-package',imf:get-package-name($supertype-id))"/>
                                <xsl:for-each select="$stereotypes">
                                    <xsl:variable name="s" select="."/>
                                    <xsl:for-each select="imf:get-stereotypes-ids(.)">
                                        <imvert:stereotype id="{.}">
                                            <xsl:value-of select="$s"/>
                                        </imvert:stereotype>
                                    </xsl:for-each>
                                </xsl:for-each>
                                <xsl:sequence select="imf:create-output-element('imvert:position',imf:get-position-value($generalization,'100'))"/>
                            </imvert:substitution>     
                        </xsl:when>
                        <xsl:otherwise>
                            <imvert:supertype>
                                <xsl:sequence select="imf:create-output-element('imvert:type-name',$supertype/@name)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-id',$supertype-id)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($supertype-id))"/>
                                <xsl:for-each select="$stereotypes">
                                    <xsl:variable name="s" select="."/>
                                    <xsl:for-each select="imf:get-stereotypes-ids(.)">
                                        <imvert:stereotype id="{.}">
                                            <xsl:value-of select="$s"/>
                                        </imvert:stereotype>
                                    </xsl:for-each>
                                </xsl:for-each>
                                <xsl:sequence select="imf:create-output-element('imvert:position',imf:get-position-value($generalization,'100'))"/>
                            </imvert:supertype>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                
                <xsl:sequence select="imf:create-output-element('imvert:min-occurs',$class-cardinality[1])"/>
                <xsl:sequence select="imf:create-output-element('imvert:max-occurs',$class-cardinality[2])"/>
                
                <xsl:choose>
                    <xsl:when test="$is-datatype or $is-complextype">
                        <xsl:sequence select="imf:get-datatype-info(.)"/>
                        <imvert:attributes>
                            <xsl:for-each select="$attributes">
                                <imvert:attribute>
                                    <xsl:sequence select="imf:get-id-info(.,'A')"/>
                                    <xsl:sequence select="imf:get-scope-info(.)"/>
                                    <xsl:sequence select="imf:get-attribute-info(.)"/>
                                    <xsl:sequence select="imf:get-attribute-documentation-info(.)"/>
                                    <!-- <xsl:sequence select="imf:get-history-info(.)"/> not available for attribute -->
                                    <xsl:sequence select="imf:get-stereotypes-info(.,'my')"/>
                                    <xsl:sequence select="imf:get-constraint-info(.)"/>
                                    <xsl:sequence select="imf:get-external-resources-info(.)"/>
                                    <xsl:sequence select="imf:fetch-additional-tagged-values(.)"/>
                                </imvert:attribute>
                            </xsl:for-each>
                        </imvert:attributes>
                    </xsl:when>
                    <xsl:otherwise>
                        <imvert:attributes>
                            <xsl:for-each select="$attributes">
                                <imvert:attribute>
                                    <xsl:sequence select="imf:get-id-info(.,'A')"/>
                                    <xsl:sequence select="imf:get-scope-info(.)"/>
                                    <xsl:sequence select="imf:get-attribute-info(.)"/>
                                    <xsl:sequence select="imf:get-attribute-documentation-info(.)"/>
                                    <!-- <xsl:sequence select="imf:get-history-info(.)"/> not available for attribute -->
                                    <xsl:sequence select="imf:get-stereotypes-info(.,'my')"/>
                                    <xsl:sequence select="imf:get-constraint-info(.)"/>
                                    <xsl:sequence select="imf:get-external-resources-info(.)"/>
                                    <xsl:sequence select="imf:fetch-additional-tagged-values(.)"/>
                                </imvert:attribute>
                            </xsl:for-each>
                        </imvert:attributes>
                        <imvert:associations>
                            <xsl:for-each select="$associations">
                                <xsl:sort select="imf:compile-sort-key(.)"/>
                                <imvert:association>
                                    <xsl:sequence select="imf:get-id-info(.,'R')"/>
                                    <xsl:sequence select="imf:get-scope-info(.)"/>
                                    <xsl:sequence select="imf:get-association-info(.)"/>
                                    <xsl:sequence select="imf:get-association-documentation-info(.)"/>
                                    <!-- <xsl:sequence select="imf:get-history-info(.)"/>-->
                                    <xsl:sequence select="imf:get-stereotypes-info(.,'my')"/>
                                    <xsl:sequence select="imf:get-constraint-info(.)"/>
                                    <xsl:sequence select="imf:get-association-class-info(.)"/>
                                    <xsl:sequence select="imf:fetch-additional-tagged-values(.)"/>
                                </imvert:association>                            
                            </xsl:for-each>
                        </imvert:associations>
                        <xsl:if test="$designation='associationclass'">
                            <!--TODO enhance: check correct implementation of association class -->
                            <xsl:variable name="association" select="$document-associations[imf:get-system-tagged-value(.,'associationclass')=$id]"/>
                            <imvert:associates>
                                <xsl:variable name="source-localid" select="$association/*/UML:AssociationEnd[imf:get-system-tagged-value(.,'ea_end')='source']/@type"/>
                                <xsl:variable name="source" select="imf:element-by-id($source-localid)"/>
                                <xsl:variable name="target-localid" select="$association/*/UML:AssociationEnd[imf:get-system-tagged-value(.,'ea_end')='target']/@type"/>
                                <xsl:variable name="target" select="imf:element-by-id($target-localid)"/>
                                <imvert:source>
                                    <xsl:sequence select="imf:get-id-info($source,'C')"/>
                                </imvert:source>
                                <imvert:target>
                                    <xsl:sequence select="imf:get-id-info($target,'C')"/>
                                </imvert:target>
                            </imvert:associates>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:sequence select="imf:get-constraint-info(.)"/>
                <xsl:sequence select="imf:fetch-additional-tagged-values(.)"/>
                
            </imvert:class>     
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="UML:Class" mode="class-enumeration">
        <imvert:class>
            <xsl:sequence select="imf:get-id-info(.,'C')"/>
            <xsl:sequence select="imf:create-output-element('imvert:designation','enumeration')"/>
            <xsl:sequence select="imf:get-element-documentation-info(.)"/>
            <xsl:sequence select="imf:get-history-info(.)"/>
            <xsl:sequence select="imf:get-stereotypes-info(.,'my')"/>
            <xsl:sequence select="imf:get-constraint-info(.)"/>
            <xsl:sequence select="imf:get-external-resources-info(.)"/>
            <xsl:for-each select="*/UML:Attribute">
                <xsl:sequence select="imf:create-output-element('imvert:enum',@name)"/>
            </xsl:for-each>
            <xsl:sequence select="imf:fetch-additional-tagged-values(.)"/>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="*|@*|text()">
      <xsl:apply-templates/>  
    </xsl:template>
    
    <xsl:function name="imf:element-by-id" as="node()*">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:if test="$id">
            <xsl:sequence select="imf:get-key($xmi-document,'key-construct-by-id',$id)"/>
        </xsl:if>
    </xsl:function>
  
    <xsl:function name="imf:get-custom-values" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:variable name="id" select="$this/@xmi:id"/>
        <xsl:variable name="customs" select="($document-thecustomprofile[@*=$id], $document-EAUML[@*=$id])"/>
        <xsl:for-each select="$customs">
            <xsl:variable name="name" select="local-name(.)"/>
            <custom xmlns="" name="{$name}">
                <xsl:variable name="value" select="@*[local-name()=$name]"/>
                <xsl:if test="$value">
                    <xsl:attribute name="value" select="$value"/>
                </xsl:if>
            </custom>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="imf:get-stereotypes" as="xs:string*">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="local-stereotype" select="imf:get-system-tagged-value($this,('stereotype','destStereotype'))"/> <!-- destStereotype only for association destinations -->
        <xsl:variable name="xref-stereotype" select="imf:get-stereotypes($this,'my')"/>
        <!-- if stereotypes have been stored in xref stereotype string, then this also holds the local stereotypes -->
        <xsl:variable name="stereotypes" select="for $s in ($xref-stereotype,$local-stereotype) return imf:get-normalized-name($s,'stereotype-name')"/>
        <xsl:sequence select="imf:get-stereotype-local-names(distinct-values($stereotypes))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-stereotypes" as="xs:string*">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="origin" as="xs:string"/>
        <xsl:variable name="stereotypes" as="xs:string*">
            <!-- stereotypes are sometimes set on the relation as a tagged value, as well as within a xref string -->
            <xsl:sequence select="if ($origin = 'my') then imf:get-system-tagged-value($this,'stereotype') else ()"/> 
            <!-- if stereotypes have been stored in xref stereotype string, then this also holds the local stereotypes -->
            <xsl:sequence select="$parsed-xref-properties[@id=generate-id($this) and @origin=$origin]/imvert:props/imvert:stereos/imvert:name"/>
        </xsl:variable>
        <xsl:variable name="stereotypes" select="distinct-values(for $s in $stereotypes return imf:get-normalized-name($s,'stereotype-name'))"/>
        <xsl:sequence select="imf:get-stereotype-local-names($stereotypes)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-stereotypes-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="origin" as="xs:string"/>
        <xsl:variable name="stereotypes" select="imf:get-stereotypes($this,$origin)"/>
        <xsl:for-each select="$stereotypes">
            <xsl:sort select="."/>
            <xsl:variable name="name" select="imf:get-normalized-name(.,'stereotype-name')"/>
            <xsl:for-each select="imf:get-stereotypes-ids($name)">
                <imvert:stereotype id="{.}">
                    <xsl:value-of select="$name"/>
                </imvert:stereotype>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-element-documentation-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <imvert:documentation>
            <xsl:sequence select="imf:get-documentation-info($this,'documentation')"/>
        </imvert:documentation>
    </xsl:function>
   
    <xsl:function name="imf:get-attribute-documentation-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <imvert:documentation>
            <xsl:sequence select="imf:get-documentation-info($this,'description')"/>
        </imvert:documentation>
    </xsl:function>
  
    <xsl:function name="imf:get-association-documentation-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <imvert:documentation>
            <xsl:sequence select="imf:get-documentation-info($this,'documentation')"/>                   
        </imvert:documentation>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation-info" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="doctext" select="imf:get-system-tagged-value($this,$name,'')"/>
        <xsl:variable name="xhtml-doctext" select="imf:eadoc-to-xhtml($doctext)"/>
        
        <xsl:variable name="formatted-doctext">
            <xsl:apply-templates select="$xhtml-doctext" mode="notes"/>
        </xsl:variable>
        
        <xsl:variable name="relevant-doc-string" select="imf:fetch-relevant-doc-string(string-join($formatted-doctext,'&#10;'))"/>
        <xsl:variable name="sections" as="element(section)*">
            <!-- Parse into sections; raw text is section titled "Raw" --> 
            <xsl:variable name="sections" select="imf:inspire-notes($relevant-doc-string)" as="element(section)*"/>
            <!-- report if sections with same title occur -->
            <xsl:variable name="duplicates" select="for $s in $sections return if ($s/following-sibling::section[title = $s/title]) then $s/title else ()" as="xs:string*"/>
            <xsl:if test="exists($duplicates)">
                <xsl:sequence select="imf:msg($this,'WARNING','Duplicated note sections: [1]', string-join($duplicates,', '))"/>
            </xsl:if>
            <xsl:sequence select="$sections"/>
        </xsl:variable>

        <xsl:variable name="f" select="imf:get-config-parameter('documentation-formatting')"/>
        <xsl:choose>
            <xsl:when test="empty($relevant-doc-string)"/>
            <xsl:when test="$f = 'inspire'">
                <xsl:sequence select="$sections"/>
            </xsl:when>
            <xsl:when test="normalize-space($relevant-doc-string) and $f = 'html'">
                <xsl:sequence select="imf:eadoc-to-xhtml($relevant-doc-string)" exclude-result-prefixes="#all"/>
            </xsl:when>
            <xsl:when test="normalize-space($relevant-doc-string) and $f = 'plain'">
                <xsl:value-of select="$relevant-doc-string"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-history-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-output-element('imvert:created',imf:date-to-isodate(imf:get-system-tagged-value($this,('created','date_created'))[1]))"/>
        <xsl:sequence select="imf:create-output-element('imvert:modified',imf:date-to-isodate(imf:get-system-tagged-value($this,('modified','date_modified'))[1]))"/>
        <xsl:sequence select="imf:create-output-element('imvert:version',imf:get-system-tagged-value($this,'version'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:phase', imf:get-phase-description(imf:get-system-tagged-value($this,'phase'))[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:author',imf:get-system-tagged-value($this,'author'))"/>
    </xsl:function>
 
    <xsl:function name="imf:get-external-resources-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <!-- imvert:data-location now removed (1.46) -->
        <xsl:variable name="type-id" select="$this/UML:StructuralFeature.type/UML:Classifier/@xmi.idref"/>
        <xsl:variable name="type-name" select="$this/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='type']/@value"/>
        <xsl:variable name="vl" select="imf:element-by-id($type-id)"/>
        <xsl:variable name="webloc" select="if (exists($vl)) then (imf:get-profile-tagged-value($vl,'web-location'),imf:get-profile-tagged-value($vl,'Web locatie')) else ()"/>
       <xsl:sequence select="imf:create-output-element('imvert:web-location',
            (imf:get-profile-tagged-value($this,'web-location'),
             imf:get-profile-tagged-value($this,'Web locatie'),
             $webloc)[1])"/>
    </xsl:function>
   
    <xsl:function name="imf:get-xsd-filepath" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="imf:get-profile-tagged-value($this,'location')[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-client-release" as="xs:string">
        <xsl:param name="this" as="node()"/>
        <xsl:value-of select="imf:get-profile-tagged-value($this,'release')[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-id-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="type" as="xs:string"/><!-- Class, Attribute, Relation, Package --> 
        <xsl:variable name="name" select="distinct-values(($this/@name, $this/*/UML:AssociationEnd[imf:get-system-tagged-value(.,'ea_end')='target']/@name))"/> <!-- 2nd option only for associations, deprecated when following RSB profile -->
        <xsl:variable name="xref-isid" select="$parsed-xref-properties[@id=generate-id($this)]/imvert:props/imvert:des[imvert:name = 'isID']/imvert:valu = '1'"/>
        <xsl:if test="$name[1]">
            <xsl:sequence select="imf:create-output-element('imvert:found-name',normalize-space($name[1]))"/>
            <xsl:if test="$this/self::UML:Package">
                <xsl:sequence select="imf:create-output-element('imvert:short-name',imf:get-short-name($name[1]))"/>
            </xsl:if>
        </xsl:if>
        <xsl:sequence select="imf:create-output-element('imvert:alias',imf:get-alias($this,$type))"/>
        <xsl:variable name="id" select="distinct-values(($this/@xmi.id, imf:get-system-tagged-value($this,'ea_guid')))"/> 
        <xsl:sequence select="imf:create-output-element('imvert:id',$id[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:keywords',imf:get-system-tagged-value($this,'keywords'))"/> 
     
        <xsl:sequence select="imf:create-output-element('imvert:is-id',if ($xref-isid) then 'true' else ())"/> 
        <xsl:for-each select="imf:get-trace-id($this,$type)">
            <xsl:sequence select="imf:create-output-element('imvert:trace',.)"/> 
        </xsl:for-each>
        <xsl:sequence select="imf:create-output-element('imvert:dependency',imf:get-dependency-id($this,$type))"/> 
       
        <xsl:variable name="att-der" select="imf:get-system-tagged-value($this,'derived') = '1'"/>
        <xsl:variable name="ass-der" select="$parsed-xref-properties[@id=generate-id($this)]/imvert:props/imvert:des[imvert:name = 'isDerived']/imvert:valu = '-1'"/>
        <xsl:sequence select="imf:create-output-element('imvert:is-value-derived',if ($att-der or $ass-der) then 'true' else ())"/> 
        
    </xsl:function>
    
    <xsl:function name="imf:get-scope-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:create-output-element('imvert:visibility',$this/@visibility)"/> 
        <xsl:sequence select="imf:create-output-element('imvert:scope',imf:get-system-tagged-value($this,'scope'))"/> 
        <xsl:sequence select="imf:create-output-element('imvert:static',imf:get-system-tagged-value($this,'static') = '1')"/> 
    </xsl:function>    
 
    <xsl:function name="imf:get-supplier-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="parent-is-derived" as="xs:boolean"/>
        
        <xsl:variable name="supplier-names" select="for $t in (tokenize(imf:get-profile-tagged-value($this,'supplier-name') ,';')) return normalize-space($t)"/>
        <xsl:variable name="supplier-projects" select="for $t in (tokenize(imf:get-profile-tagged-value($this,'supplier-project'),';')) return normalize-space($t)"/>
        <xsl:variable name="supplier-releases" select="for $t in (tokenize(imf:get-profile-tagged-value($this,'supplier-release'),';')) return normalize-space($t)"/>
        <xsl:variable name="supplier-packs" select="for $t in (tokenize(imf:get-profile-tagged-value($this,'supplier-package-name'),';')) return normalize-space($t)"/>
        
        <xsl:variable name="counts" select="(count($supplier-names),count($supplier-projects), count($supplier-releases), count($supplier-packs))"/>
        <xsl:variable name="scount" select="functx:sort($counts)[last()]"/>
        <xsl:variable name="supplier-info" as="element()*">
            <xsl:for-each select="1 to $scount">
                <xsl:variable name="index" select="position()"/>
                <xsl:variable name="supplier-project" select="imf:fallback($supplier-projects, $index)"/>
                <xsl:variable name="supplier-name" select="imf:fallback($supplier-names, $index)"/>
                <xsl:variable name="supplier-release" select="imf:fallback($supplier-releases, $index)"/>
                <imvert:supplier>
                    <xsl:attribute name="subpath" select="imf:get-subpath($supplier-project,$supplier-name,$supplier-release)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:supplier-name',$supplier-name)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:supplier-project',$supplier-project)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:supplier-release',$supplier-release)"/>
                    <xsl:sequence select="imf:create-output-element('imvert:supplier-package-name',imf:fallback($supplier-packs,$index))"/>
                </imvert:supplier>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="derived" select="imf:get-profile-tagged-value($this,'derived')"/>
        
        <xsl:sequence select="$supplier-info"/>
        <xsl:variable name="derived-because-stated" select="(exists($derived) and imf:boolean($derived))"/>
        <xsl:variable name="not-derived-because-stated" select="(exists($derived) and not(imf:boolean($derived)))"/>
        
        <xsl:variable name="derived-code" select="
            if (exists($supplier-info) and $not-derived-because-stated) then ('false','Supplier info found, but stated not to be derived') 
            else if ($derived-because-stated) then ('true','Stated to be derived') 
            else if (exists($supplier-info)) then ('true','Supplier info found') 
            else if ($parent-is-derived and $not-derived-because-stated) then ('false','Parent is derived, but stated not to be derived') 
            else if ($parent-is-derived) then ('true','Parent is derived') 
            else    ('false','No indication of derivation')
        "/>
        <imvert:derived reason="{$derived-code[2]}">
            <xsl:value-of select="$derived-code[1]"/>
        </imvert:derived>
        
        <!-- avoid duplicate models for derivation -->
        <xsl:variable name="shortened-subpaths" select="for $s in $supplier-info return concat($s/imvert:supplier-project, '/', $s/imvert:supplier-name)"/>
        <xsl:if test="count(distinct-values($shortened-subpaths)) ne count($shortened-subpaths)">
            <xsl:sequence select="imf:msg($this,'ERROR','Attempt to derive from more than one releases of the same package: [1]',$shortened-subpaths)"/>
        </xsl:if>
        
    </xsl:function>
   
    <xsl:function name="imf:get-config-info" as="node()*">
        <xsl:param name="this" as="node()"/> 
        <xsl:sequence select="imf:create-output-element('imvert:location',imf:get-xsd-filepath($this))"/>
        <xsl:sequence select="imf:create-output-element('imvert:release',imf:get-client-release($this))"/>
        <xsl:sequence select="imf:create-output-element('imvert:ref-version',imf:get-profile-tagged-value($this,'ref-version'))"/> <!-- optional -->
        <xsl:sequence select="imf:create-output-element('imvert:ref-release',imf:get-profile-tagged-value($this,'ref-release'))"/> <!-- optional -->
    </xsl:function>
    
    <xsl:function name="imf:get-datatype-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- packagedElement -->
        <xsl:sequence select="imf:create-output-element('imvert:primitive',imf:get-profile-tagged-value($this,'primitive'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:pattern',imf:get-formal-pattern($this))"/>
        <xsl:sequence select="imf:create-output-element('imvert:min-length',imf:get-profile-tagged-value($this,'minLength'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-length',imf:get-profile-tagged-value($this,'maxLength'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:union',imf:get-profile-tagged-value($this,'union'))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-attribute-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- an UML:Attribute -->
        <xsl:variable name="type-id" select="$this/UML:StructuralFeature.type/UML:Classifier/@xmi.idref"/>
        <xsl:variable name="type-tv-name" select="$this/UML:ModelElement.taggedValue/UML:TaggedValue[@tag='type']/@value"/>
        
        <xsl:if test="$type-id and not($type-tv-name) and not(starts-with($type-id,'eaxmiid'))">
            <!--<xsl:sequence select="imf:msg($this, 'ERROR','Attribute type conflict at UML:Classifier [1], at path [2]',($type-id,imf:compile-name-path($this)))"/>-->
            <xsl:sequence select="imf:msg($this, 'ERROR','Expected attribute type, but found none, at UML:Classifier [1], at path [2]',($type-id,imf:compile-name-path($this)))"/>
        </xsl:if>
        
        <xsl:variable name="type" select="imf:element-by-id($type-id)"/>
        <xsl:variable name="type-fullname" select="$type/@name"/>
        <xsl:variable name="type-modifier" select="if (contains($type-fullname,'?')) then '?' else if (contains($type-fullname,'+P')) then '+P' else ()"/> 
        <xsl:variable name="type-name" select="if (exists($type-modifier)) then substring-before($type-fullname,$type-modifier) else $type-fullname"/>
        
        <xsl:choose>
            <xsl:when test="empty($type-name)">
                <!-- this is an enumeration (value), skip -->
            </xsl:when>
            <!-- process the baretypes -->
            <xsl:when test="$allow-native-scalars and $type-id and $supports-baretype-transformation and imf:is-baretype($type-name)">
                <!-- a type such as AN, N10, AN10, N8.2 or N8,2. Baretypes are translated to local type declarations -->
                <xsl:sequence select="imf:create-output-element('imvert:baretype',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-package','Info_Types_Package')"/>
                
                <xsl:analyze-string select="$type-name" regex="{$baretype-pattern}">
                    <xsl:matching-substring>
                        <xsl:variable name="type" select="regex-group(1)"/>
                        <xsl:variable name="positions" select="regex-group(2)"/>
                        <xsl:variable name="decimals" select="regex-group(4)"/>
                        <xsl:variable name="pattern" select="regex-group(5)"/>
                        <xsl:choose>
                            <xsl:when test="$type='AN'">
                                <xsl:sequence select="imf:create-output-element('imvert:type-name','scalar-string')"/><!-- used to be 'char' -->
                                <xsl:sequence select="imf:create-output-element('imvert:max-length',$positions)"/>
                            </xsl:when>
                            <xsl:when test="$type='N' and not($decimals)">
                                <xsl:sequence select="imf:create-output-element('imvert:type-name','scalar-integer')"/>
                                <xsl:sequence select="imf:create-output-element('imvert:total-digits',$positions)"/>
                            </xsl:when>
                            <xsl:when test="$type='N'">
                                <xsl:sequence select="imf:create-output-element('imvert:type-name','scalar-decimal')"/>
                                <xsl:sequence select="imf:create-output-element('imvert:fraction-digits',$decimals)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:total-digits',xs:string(xs:integer($positions) + xs:integer($decimals)))"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:sequence select="imf:create-output-element('imvert:type-modifier',$type-modifier)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            
            <!-- process the other scalars: -->
            <xsl:when test="$allow-native-scalars and substring($type-id,1,5) = ('eaxmi')">
                <xsl:variable name="type-normname" select="imf:get-normalized-name($type-name,'baretype-name')"/>
                <xsl:variable name="scalar" select="$all-scalars[name[@lang=$language] = $type-normname][last()]"/>

                <xsl:sequence select="imf:create-output-element('imvert:baretype',$type-normname)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$scalar/@id)"/>
                <xsl:choose>
                    <xsl:when test="$type-modifier and $scalar/type-modifier">
                        <xsl:sequence select="imf:create-output-element('imvert:type-modifier',$type-modifier)"/>
                    </xsl:when>
                    <xsl:when test="$type-modifier">
                        <xsl:sequence select="imf:msg('ERROR','A modifier [1] is not allowed on type [2]', ($type-modifier,$type-normname))"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            
            <!-- process the typed attributes, referencing type object types -->
            <xsl:when test="$type-id">
                <xsl:sequence select="imf:create-output-element('imvert:baretype',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-id',$type-id)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type-id))"/>
            </xsl:when>
            <!-- unexpected other constructs?? -->
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR',concat('Unexpected attribute type: ', $type-name))"/>
                <xsl:sequence select="imf:create-output-element('imvert:baretype',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$this/type/@href)"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="lbound" select="imf:get-system-tagged-value($this,'lowerBound')"/>
        <xsl:variable name="ubound" select="imf:get-system-tagged-value($this,'upperBound')"/>
        
        <xsl:sequence select="imf:create-output-element('imvert:min-occurs',$lbound)"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-occurs',if ($ubound='*') then 'unbounded' else $ubound)"/>
        <xsl:sequence select="imf:create-output-element('imvert:position',imf:get-position-value($this,'100'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:pattern',imf:get-formal-pattern($this))"/>
        <xsl:sequence select="imf:create-output-element('imvert:min-length',imf:get-profile-tagged-value($this,'minLength'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-length',imf:get-profile-tagged-value($this,'maxLength'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:any-from-package',imf:get-profile-tagged-value($this,'package'))"/>
       
    </xsl:function>
    
    <xsl:function name="imf:get-association-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- UML:Association -->
        
        <xsl:variable name="source" select="$this/*/UML:AssociationEnd[*/UML:TaggedValue[@tag='ea_end' and @value='source']]"/>
        <xsl:variable name="target" select="$this/*/UML:AssociationEnd[*/UML:TaggedValue[@tag='ea_end' and @value='target']]"/>
        
        <xsl:variable name="type-id" select="$target/@type"/>
        <xsl:variable name="type" select="imf:element-by-id($type-id)"/>
        
        <xsl:variable name="source-bounds" select="imf:get-association-end-bounds($source)"/>
        <xsl:variable name="target-bounds" select="imf:get-association-end-bounds($target)"/>
        
        <xsl:variable name="source-role" select="$source/@name"/>
        <xsl:variable name="target-role" select="$target/@name"/>
        
        <xsl:variable name="aggregation" select="$source/@aggregation"/>
        
        <xsl:sequence select="imf:create-output-element('imvert:type-name',$type/@name)"/>
        <xsl:sequence select="imf:create-output-element('imvert:type-id',$type-id)"/> 
        <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type-id))"/>
        <xsl:sequence select="imf:create-output-element('imvert:min-occurs',$target-bounds[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-occurs',$target-bounds[2])"/>
        <xsl:sequence select="imf:create-output-element('imvert:min-occurs-source',$source-bounds[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-occurs-source',$source-bounds[2])"/>
        <xsl:sequence select="imf:create-output-element('imvert:aggregation',if (not($aggregation='none')) then $aggregation else '')"/>
        
        <xsl:variable name="rp" select="imf:get-position-value($this,'200')"/>
        <xsl:variable name="tp" select="imf:get-position-value($target,())"/>
        <xsl:sequence select="imf:create-output-element('imvert:position',if ($tp) then $tp else $rp)"/>
        
        <xsl:variable name="source-parse" select="imf:parse-style($source/*/UML:TaggedValue[@tag='sourcestyle']/@value)"/>
        <xsl:variable name="target-parse" select="imf:parse-style($target/*/UML:TaggedValue[@tag='deststyle']/@value)"/>
        
        <imvert:source>
            <xsl:sequence select="imf:get-stereotypes-info($this,'src')"/>
            <xsl:sequence select="imf:create-output-element('imvert:role',$source-role)"/>
            <xsl:sequence select="imf:create-output-element('imvert:navigable',if ($source-parse[@name='Navigable'] = 'Navigable') then 'true' else 'false')"/>
            <xsl:sequence select="imf:create-output-element('imvert:alias',normalize-space($source-parse[@name='alias']))"/>
            <xsl:sequence select="imf:create-output-element('imvert:documentation',imf:get-documentation-info($source,'description'),(),false(),false())"/>
            <xsl:sequence select="imf:fetch-additional-tagged-values($source)"/>
        </imvert:source>
        
        <imvert:target>
            <xsl:sequence select="imf:get-stereotypes-info($this,'dst')"/>
            <xsl:sequence select="imf:create-output-element('imvert:role',$target-role)"/>
            <xsl:sequence select="imf:create-output-element('imvert:navigable',if ($target-parse[@name='Navigable'] = 'Navigable') then 'true' else 'false')"/>
            <xsl:sequence select="imf:create-output-element('imvert:alias',normalize-space($target-parse[@name='alias']))"/>
            <xsl:sequence select="imf:create-output-element('imvert:documentation',imf:get-documentation-info($target,'description'),(),false(),false())"/>
            <xsl:sequence select="imf:fetch-additional-tagged-values($target)"/>
        </imvert:target>
               
    </xsl:function>
    
    <xsl:function name="imf:get-association-end-bounds" as="xs:string*">
        <xsl:param name="this" as="node()"/>
        <xsl:variable name="mult" select="$this/@multiplicity"/> <!-- vorm: 1..*, 1..2, 1, 4, null -->
        <xsl:variable name="mult-tokens" select="tokenize($mult,'\.+')"/>
        <xsl:choose>
            <xsl:when test="$mult-tokens[2]">
                <xsl:sequence select="($mult-tokens[1],if ($mult-tokens[2]='*') then 'unbounded' else $mult-tokens[2])"/>
            </xsl:when>
            <xsl:when test="$mult-tokens[1]">
                <xsl:sequence select="($mult-tokens[1],$mult-tokens[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="('1','1')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-association-class-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- UML:Association -->
        <xsl:variable name="association-id" select="imf:get-system-tagged-value($this,'associationclass')"/>
        <xsl:variable name="association-class" select="imf:element-by-id($association-id)"/>
        <xsl:if test="$association-class">
            <imvert:association-class>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$association-class/@name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-id',$association-id)"/> 
                <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($association-id))"/>
            </imvert:association-class>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-package-by-namespace" as="node()*">
        <xsl:param name="package-namespace" as="xs:string"/>
        <xsl:variable name="element" select="imf:get-key($xmi-document,'key-packages-by-alias',$package-namespace)"/>
        <xsl:choose>
            <xsl:when test="$element">
                <xsl:variable name="id" select="$element/@xmi:idref" as="xs:string"/>
                <xsl:if test="not($id)">
                    <xsl:sequence select="imf:msg('ERROR','No such package namespace (alias): [1]', $package-namespace)"/>
                </xsl:if>
                <xsl:sequence select="imf:get-uml-model-info($id)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR','Configured namespace alias not found in XMI: [1]', $package-namespace)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-uml-model-info" as="node()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="imf:element-by-id($id)"/>
    </xsl:function>
    <xsl:function name="imf:get-uml-element-info" as="node()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="imf:get-key($xmi-document,'key-construct-by-idref',$id)[self::element]"/>
    </xsl:function>
    <xsl:function name="imf:get-uml-connector-info" as="node()*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="imf:get-key($xmi-document,'key-construct-by-idref',$id)[self::connector]"/>
    </xsl:function>
    <xsl:function name="imf:get-uml-attribute-info" as="node()*">
        <xsl:param name="id" as="xs:string"/>    
        <xsl:sequence select="imf:get-key($xmi-document,'key-construct-by-idref',$id)[self::attribute]"/>
    </xsl:function>
    
    <!-- 
        Tagged values komen binnen subelement 
        .//UML:ModelElement.taggedValue voor, 
        en zo niet, dan terugvallen op
        /XMI/XMI.content/UML:TaggedValue
        
        Als niet beschikbaar op package zelf, dan wellicht wel op UML:ClassifierRole? 
        Voorbeeld:
        <UML:ClassifierRole name="Package5" xmi.id="EAID_877368D3_AF62_4cf7_8FF7_230ED08FEA87" ..> 
        <UML:Package        name="Package5" xmi.id="EAPK_877368D3_AF62_4cf7_8FF7_230ED08FEA87" ..>
    -->
 
    <xsl:function name="imf:get-profile-tagged-value" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tagged-value-name" as="xs:string*"/>
        <xsl:sequence select="imf:get-profile-tagged-value($this,$tagged-value-name,'space')"/>
    </xsl:function>
    
    <xsl:function name="imf:get-profile-tagged-value" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tagged-value-name" as="xs:string*"/>
        <xsl:param name="normalized" as="xs:string?"/>
        <xsl:sequence select="imf:get-tagged-value($this,$tagged-value-name,$normalized,true())"/>
    </xsl:function>
    
    <xsl:function name="imf:get-system-tagged-value" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tagged-value-name" as="xs:string*"/>
        <xsl:sequence select="imf:get-system-tagged-value($this,$tagged-value-name,'space')"/>
    </xsl:function>
    
    <xsl:function name="imf:get-system-tagged-value" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tagged-value-name" as="xs:string*"/>
        <xsl:param name="normalized" as="xs:string?"/>
        <xsl:sequence select="imf:get-tagged-value($this,$tagged-value-name,$normalized,false())"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tagged-value-name" as="xs:string*"/>
        <xsl:param name="normalized" as="xs:string?"/>
        <xsl:param name="profiled" as="xs:boolean"/>
        <xsl:sequence select="imf:get-tagged-values($this,$tagged-value-name,$normalized,$profiled)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-values" as="item()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tagged-value-name" as="xs:string*"/>
        <xsl:param name="profiled" as="xs:boolean"/>
        <!-- 
            this implements the equivalent of:
            if ($local-value) then $local-value else 
            if ($global-value) then $global-value else 
            if ($local-cr-value) then $local-cr-value else 
            if ($global-cr-value) then $global-cr-value else 
            if ($root-model-value) then $root-model-value else 
            ()
        -->
        <xsl:variable name="tagged-values" select="$this/UML:ModelElement.taggedValue/UML:TaggedValue[imf:tagged-value-select-profiled(.,$profiled) and imf:name-match(@tag,$tagged-value-name,'tv-name-ea')]"/>
        
        <xsl:if test="$tagged-values[2] and not($allow-duplicate-tv)">
            <xsl:sequence select="imf:msg('WARNING','Duplicate assignment of tagged value [1] at [2] (at mode [3])', ($tagged-value-name, imf:compile-name-path($this),'0'))"/>
            <xsl:sequence select="imf:msg('DEBUG','At path: [1]', imf:compile-xpath($this))"/>
        </xsl:if>
        <xsl:variable name="local-value" select="$tagged-values"/>
        <xsl:choose>
            <xsl:when test="exists($local-value)">
                 <xsl:sequence select="$local-value"/>   
                <xsl:sequence select="imf:msg('DEBUG','Tagged value [1] is [2] (at mode [3]) at path: [4] ', (imf:string-group($tagged-value-name),imf:compile-xpath($this),'0',imf:string-group($local-value)))"/>
            </xsl:when>
            <xsl:when test="not($profiled)"><!-- assume that all tagged values in different locations in the XMI are profiled -->
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tagged-values" select="$content/UML:TaggedValue[@modelElement=$this/@xmi.id and imf:name-match(@tag,$tagged-value-name,'tv-name-ea')]"/>
                <xsl:if test="$tagged-values[2] and not($allow-duplicate-tv)"> 
                    <xsl:sequence select="imf:msg('WARNING','Duplicate assignment of tagged value [1] at [2] (at mode [3])', ($tagged-value-name, imf:compile-name-path($this),'1'))"/>
                    <xsl:sequence select="imf:msg('DEBUG','At path: [1]', imf:compile-xpath($this))"/>
                </xsl:if>
                <xsl:variable name="global-value" select="$tagged-values"/>
                <xsl:choose>
                    <xsl:when test="exists($global-value)">
                        <xsl:sequence select="$global-value"/>   
                        <xsl:sequence select="imf:msg('DEBUG','Tagged value [1] is [2] (at mode 1) at path: [3] ', (imf:string-group($tagged-value-name),imf:compile-xpath($this),imf:string-group($global-value)))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="crole" select="imf:get-classifier-role($this)"/>
                        <xsl:variable name="tagged-values" select="$crole/UML:ModelElement.taggedValue/UML:TaggedValue[imf:name-match(@tag,$tagged-value-name,'tv-name-ea')]"/>
                        <xsl:if test="$tagged-values[2] and not($allow-duplicate-tv)"> 
                            <xsl:sequence select="imf:msg('WARNING','Duplicate assignment of tagged value [1] within classifier role [2] (at mode [3])', ($tagged-value-name,imf:compile-name-path($crole),'2'))"/>
                            <xsl:sequence select="imf:msg('DEBUG','At path: [1]', imf:compile-xpath($this))"/>
                        </xsl:if>
                        <xsl:variable name="local-cr-value" select="$tagged-values"/>
                        <xsl:choose>
                            <xsl:when test="exists($local-cr-value)">
                                <xsl:sequence select="$local-cr-value"/>   
                                <xsl:sequence select="imf:msg('DEBUG','Tagged value [1] is [2] (at mode 2) at path: [3] ', (imf:string-group($tagged-value-name),imf:compile-xpath($this),imf:string-group($local-cr-value)))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="tagged-values" select="$content/UML:TaggedValue[@modelElement=$crole/@xmi.id and imf:name-match(@tag,$tagged-value-name,'tv-name-ea')]"/>
                                <xsl:if test="$tagged-values[2] and not($allow-duplicate-tv)"> 
                                    <xsl:sequence select="imf:msg('WARNING','Duplicate assignment of tagged value [1] at classifier role [2] (at mode [3]', ($tagged-value-name,imf:compile-name-path($crole),'3'))"/>
                                    <xsl:sequence select="imf:msg('DEBUG','At path: [1]', imf:compile-xpath($this))"/>
                                </xsl:if>
                                <xsl:variable name="global-cr-value" select="$tagged-values"/>
                                <xsl:choose>
                                    <xsl:when test="exists($global-cr-value)">
                                        <xsl:sequence select="$global-cr-value"/>   
                                        <xsl:sequence select="imf:msg('DEBUG','Tagged value [1] is [2] (at mode 3) at path: [3] ', (imf:string-group($tagged-value-name),imf:compile-xpath($this),imf:string-group($global-cr-value)))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="root-model" select="$content/UML:Model"/>
                                        <xsl:variable name="tagged-values" select="$content/UML:TaggedValue[@modelElement=$root-model/@xmi.id and imf:name-match(@tag,$tagged-value-name,'tv-name-ea')]"/>
                                        <xsl:if test="$tagged-values[2] and not($allow-duplicate-tv)"> 
                                            <xsl:sequence select="imf:msg('WARNING','Duplicate assignment of tagged value [1] at root model [2] (at mode [3])', ($tagged-value-name,imf:compile-name-path($root-model),'4'))"/>
                                            <xsl:sequence select="imf:msg('DEBUG','At path: [1]', imf:compile-xpath($this))"/>
                                        </xsl:if>
                                        <xsl:variable name="root-model-value" select="$tagged-values"/>
                                        <xsl:choose>
                                            <xsl:when test="exists($root-model-value)">
                                                <xsl:sequence select="$root-model-value"/>   
                                                <xsl:sequence select="imf:msg('DEBUG','Tagged value [1] is [2] (at mode 4) at path: [3] ', (imf:string-group($tagged-value-name),imf:compile-xpath($this),imf:string-group($root-model-value)))"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!-- not specified -->
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-values">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="tagged-value-name" as="xs:string*"/>
        <xsl:param name="normalized" as="xs:string?"/>
        <xsl:param name="profiled" as="xs:boolean"/>
        <xsl:sequence select="for $tv in imf:get-tagged-values($this,$tagged-value-name,$profiled) return imf:get-tagged-value-norm(imf:get-tagged-value-original($tv),$normalized)"/>
    </xsl:function>
    
    <!-- return string value, as found -->
    <xsl:function name="imf:get-tagged-value-original" as="xs:string?"> 
        <xsl:param name="tv" as="element()?"/>
       
        <xsl:variable name="value" select="$tv/@value"/>
        <xsl:if test="normalize-space($value)">
            <!-- 
                OPTIONS:
                1/    value
                2/    <memo>#NOTES#value
                3/    value#NOTES#note
                4/    $ea_notes=....
            -->        
            <xsl:variable name="tokens" select="tokenize($value,'(#NOTES#)|(\$ea_notes=)')"/> 
            <xsl:variable name="value-select" select="
                if (exists($tokens[2]))
                then 
                    if ($tokens[1] = '&lt;memo&gt;')
                    then $tokens[2]
                    else $tokens[1]
                else
                    if ($tokens[1] = '&lt;memo&gt;')
                    then $tv/XMI.extension/UML:Comment/@name
                    else $tokens[1]
            "/>
            <xsl:sequence select="if (normalize-space($value-select)) then $value-select else ()"/>
        </xsl:if>
   </xsl:function>
    
    <!-- return normalized string value-->
    <xsl:function name="imf:get-tagged-value-norm" as="xs:string?"> 
        <xsl:param name="value" as="xs:string?"/>
        <xsl:param name="norm" as="xs:string?"/>
        
        <xsl:sequence select="if (exists($value)) then imf:get-tagged-value-norm-by-scheme($value,$norm,'tv') else ()"/>
    </xsl:function>
    
    <xsl:function name="imf:tagged-value-select-profiled" as="xs:boolean">
        <xsl:param name="tv"/>
        <xsl:param name="profiled" as="xs:boolean"/>
        <xsl:variable name="tv-is-profiled" select="exists($tv/@xmi.id)"/> <!-- signals that the tagged value is taken from some profile definition -->
        <xsl:sequence select="($profiled and $tv-is-profiled) or (not($profiled) and not($tv-is-profiled))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-position-value" as="xs:string?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="default" as="xs:string?"/>
        <xsl:variable name="positions" select="imf:get-tagged-values($this,('positie','position','Positie','Position'),(),true())[1]"/>
        <xsl:variable name="positions-1" select="if (matches($positions[1],'\d+')) then $positions[1] else ()"/>
        <xsl:variable name="positions-2" select="if (matches($positions[2],'\d+')) then $positions[2] else ()"/>
        <xsl:value-of select="normalize-space(
                if ($this/self::UML:Generalization and $positions-1) then $positions-1 else
                if ($this/self::UML:Association and $positions-1) then $positions-1 else
                if ($this/self::UML:AssociationEnd and $positions-1) then $positions-1 else
                if ($positions-2) then $positions-2 
                else $default
        )"/>
    </xsl:function> 
    
    <xsl:function name="imf:get-custom-value" as="xs:string?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="custom-value-name" as="xs:string*"/>
        <xsl:variable name="element" select="imf:get-custom-values($this)"/>
        <xsl:value-of select="$element[@name=$custom-value-name]/@value"/>
    </xsl:function>
 
    <xsl:function name="imf:get-extension-element-value" as="xs:string?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="extension-value-name" as="xs:string*"/> 
        <xsl:variable name="element" select="$extension-elements[@xmi:idref=$this/@xmi:id]"/>
        <xsl:value-of select="imf:get-extension-info($element,$extension-value-name,'')"/>
    </xsl:function>
    <xsl:function name="imf:get-extension-element-value" as="xs:string?">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="extension-value-name" as="xs:string*"/> 
        <xsl:param name="base-element" as="xs:string"/> 
        <xsl:variable name="element" select="$extension-elements[@xmi:idref=$this/@xmi:id]"/>
        <xsl:value-of select="imf:get-extension-info($element,$extension-value-name,$base-element)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-extension-attribute-value" as="xs:string?">
        <xsl:param name="this" as="node()"/> <!-- must be an ownedAttribute node -->
        <xsl:param name="extension-value-name" as="xs:string*"/> 
        <xsl:variable name="attribute" select="$extension-attributes[@xmi:idref=$this/@xmi:id]"/>
        <xsl:value-of select="imf:get-extension-info($attribute,$extension-value-name,'')"/>
    </xsl:function>
  
    <xsl:function name="imf:get-extension-connector-value" as="xs:string?">
        <xsl:param name="this" as="node()"/> <!-- must be an ownedAttribute node -->
        <xsl:param name="extension-value-name" as="xs:string*"/>
        <xsl:variable name="connector" select="$extension-connectors[@xmi:idref=$this/@association]"/>
        <xsl:value-of select="imf:get-extension-info($connector,$extension-value-name,'')"/>
    </xsl:function>

    <xsl:function name="imf:get-extension-info" as="xs:string?">
        <xsl:param name="this" as="node()?"/> <!-- any node in extension part -->
        <xsl:param name="extension-value-name" as="xs:string*"/>
        <xsl:param name="base-element" as="xs:string?"/>
        <xsl:if test="$this">
            <xsl:choose>
                <xsl:when test="$base-element">
                    <xsl:value-of select="$this/*[local-name()=$base-element]/@*[local-name()=$extension-value-name]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="element" select="$this/*[local-name()=$extension-value-name]"/>
                    <xsl:variable name="node" select="if ($element) then $element else $this/*/@*[local-name()=$extension-value-name]"/>
                    <xsl:value-of select="if ($node/@value) then $node/@value else $node"/> 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:get-package-name" as="xs:string">
        <xsl:param name="type-id" as="xs:string?"/>
        <xsl:variable name="class" select="imf:get-key($xmi-document,'key-construct-by-id',$type-id)"/>
        <xsl:value-of select="imf:get-canonical-name((($class/ancestor-or-self::UML:Package)[last()]/@name,'OUTSIDE')[1])"/>
    </xsl:function>
    
    <xsl:function name="imf:date-to-isodate" as="xs:string?">
        <xsl:param name="date" as="xs:string?"/>
        <xsl:if test="$date">
            <xsl:analyze-string select="$date" regex="^(.+)\s(.+)$">
                <!-- 2005-11-07 16:49:09 -->
                <xsl:matching-substring>
                    <xsl:value-of select="concat(regex-group(1),'T',regex-group(2))"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:is-baretype" as="xs:boolean">
        <xsl:param name="type" as="xs:string"/>
        <xsl:copy-of select="matches($type,$baretype-pattern)"/>
    </xsl:function>
    
    <!-- XMI 1.1 ADDITIONS -->
    
    <xsl:variable name="content" select="/XMI/XMI.content"/>
    
    <xsl:key name="key-document-generalizations" match="//UML:Generalization" use="concat(@subtype,'#', @supertype)"/>
    
    <xsl:variable name="document-generalizations-merge" select="//UML:Generalization[imf:get-stereotypes(.)=imf:get-config-stereotypes('stereotype-name-variant-merge')]"/>
    <xsl:variable name="document-generalizations-copy-down" select="//UML:Generalization[imf:get-stereotypes(.)=imf:get-config-stereotypes('stereotype-name-static-generalization')]"/>
    <xsl:variable name="document-generalizations-type" select="//UML:Generalization except $document-generalizations-merge"/>
    <xsl:key name="key-document-associations-type" 
        match="//UML:Association" 
        use="UML:Association.connection/UML:AssociationEnd[UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_end' and @value='source']]/@type"/>
    
    <xsl:variable name="main-package-stereotypes" select="(
        imf:get-config-stereotypes('stereotype-name-base-package'), 
        imf:get-config-stereotypes('stereotype-name-variant-package'), 
        imf:get-config-stereotypes('stereotype-name-application-package')
        )"></xsl:variable>
    
    <!-- tagged values $ea_xref_property zijn complexe strings; deze worden voor gemakkelijke herkenning omgezet naar een interne XML struktuur -->
    <xsl:variable name="parsed-xref-properties" as="node()*">
        <xsl:for-each select="$document-packages | $document-classes | $document-attributes | $document-associations | $document-classifier-roles | $document-generalizations">
            <xsl:variable name="my-property" select="UML:ModelElement.taggedValue/UML:TaggedValue[@tag='$ea_xref_property'][1]"/> <!-- use the first; bug in EA, may be multiple, see "Problem when exporting XML 1.2" dd 20161025 -->
            <xsl:variable name="dst-property" select="UML:ModelElement.taggedValue/UML:TaggedValue[@tag='$ea_dst_xref_property'][1]"/>
            <xsl:variable name="src-property" select="UML:ModelElement.taggedValue/UML:TaggedValue[@tag='$ea_src_xref_property'][1]"/>
            <xsl:sequence select="imf:parse-xref-property-props(., if ($my-property) then $my-property/@value else ())"/>
            <xsl:sequence select="imf:parse-xref-property-props(., if ($dst-property) then $dst-property/@value else (),'dst')"/>
            <xsl:sequence select="imf:parse-xref-property-props(., if ($src-property) then $src-property/@value else (),'src')"/>
        </xsl:for-each>
    </xsl:variable>
    
    
    <!-- 
        Het volgende is een grammatica voor het uiteenpluizen van xrefprop, dus de string in content van:
        
        <UML:TaggedValue tag="$ea_xref_property" value="$XREFPROP=$XID={98........REF;"/>
        
        Dit geeft toegang tot bijv. meerdere stereotypes.
     
        Voorbeeld van de parse is:
        <imvert:xrefprop id="d2e9904" type="UML:Class">
            <imvert:props>
                <imvert:xid>{7C3FF6B4-114B-41de-9AAC-E119BCEE2284}</imvert:xid>
                <imvert:nam>CustomProperties</imvert:nam>
                <imvert:typ>element property</imvert:typ>
                <imvert:vis>Public</imvert:vis>
                <imvert:clt>{EBEAF581-57BC-4bf7-938D-AE0E1C5C1DBA}</imvert:clt>
                <imvert:des>
                    <imvert:name>isActive</imvert:name>
                    <imvert:type-name>Boolean</imvert:type>
                </imvert:des>
                <imvert:stereos/>
            </imvert:props>
            <imvert:props>
                <imvert:xid>{20B412B9-1FDE-432a-85A3-62C06BF01496}</imvert:xid>
                <imvert:nam>Stereotypes</imvert:nam>
                <imvert:typ>element property</imvert:typ>
                <imvert:vis>Public</imvert:vis>
                <imvert:par>0</imvert:par>
                <imvert:clt>{EBEAF581-57BC-4bf7-938D-AE0E1C5C1DBA}</imvert:clt>
                <imvert:sup>&lt;none&gt;</imvert:sup>
                <imvert:des/>
                <imvert:stereos>
                    <imvert:name>dataType</imvert:name>
                    <imvert:name>nog-een-stereo</imvert:name>
                </imvert:stereos>
            </imvert:props>
        </imvert:xrefprop>
     -->
     
    <xsl:function name="imf:parse-xref-property-props" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="xrefprop" as="xs:string?"/>
        <xsl:sequence select="imf:parse-xref-property-props($this,$xrefprop,'my')"/>
    </xsl:function>
    
    <xsl:function name="imf:parse-xref-property-props" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="xrefprop" as="xs:string?"/>
        <xsl:param name="origin" as="xs:string?"/>
        <xsl:if test="$xrefprop">
            <!-- als de property wordt gezet op een ClassifierRole en de base is een package, dan betreft het de base van deze role. -->
            <xsl:variable name="base" as="element()?">
                <xsl:variable name="package-id" select="imf:get-system-tagged-value($this,'package2')"/>
                <xsl:variable name="package-id-corrected" select="if ($normalize-ids) then $package-id else replace($package-id,'^EAID_','EAPK_')"/> <!-- EA specific! -->
                <xsl:choose>
                    <xsl:when test="$this/self::UML:ClassifierRole and $package-id-corrected">
                        <xsl:sequence select="imf:element-by-id($package-id-corrected)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$this"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="exists($base)">
                <imvert:xrefprop id="{generate-id($base)}" type="{name($base)}" origin="{$origin}">
                    <xsl:analyze-string select="$xrefprop" regex="\$XREFPROP=(.+?)\$ENDXREF;">
                        <xsl:matching-substring>
                            <xsl:variable name="props" select="regex-group(1)"/>
                            <imvert:props>
                                <xsl:sequence select="imf:create-output-element('imvert:xid',if ($normalize-ids) then imf:normalize-xmi-id(imf:parse-xref-property-prop($props,'XID')) else imf:parse-xref-property-prop($props,'XID'))"/>
                                <xsl:sequence select="imf:create-output-element('imvert:nam',imf:parse-xref-property-prop($props,'NAM'))"/>
                                <xsl:sequence select="imf:create-output-element('imvert:typ',imf:parse-xref-property-prop($props,'TYP'))"/>
                                <xsl:sequence select="imf:create-output-element('imvert:vis',imf:parse-xref-property-prop($props,'VIS'))"/>
                                <xsl:sequence select="imf:create-output-element('imvert:par',imf:parse-xref-property-prop($props,'PAR'))"/>
                                <xsl:sequence select="imf:create-output-element('imvert:clt',if ($normalize-ids) then imf:normalize-xmi-id(imf:parse-xref-property-prop($props,'CLT')) else imf:parse-xref-property-prop($props,'CLT'))"/>
                                <xsl:sequence select="imf:create-output-element('imvert:sup',imf:parse-xref-property-prop($props,'SUP'))"/>
                                <xsl:variable name="des" select="imf:parse-xref-property-prop($props,'DES')"/>
                                <xsl:if test="exists($des)">
                                    <xsl:analyze-string select="$des" regex="@PROP=(.+?)@ENDPROP;">
                                        <xsl:matching-substring>
                                            <imvert:des>
                                                <xsl:variable name="des-sub" select="regex-group(1)"/>
                                                <xsl:sequence select="imf:create-output-element('imvert:name',imf:parse-xref-property-des($des-sub,'NAME'))"/>
                                                <xsl:sequence select="imf:create-output-element('imvert:type',imf:parse-xref-property-des($des-sub,'TYPE'))"/>
                                                <xsl:sequence select="imf:create-output-element('imvert:valu',imf:parse-xref-property-des($des-sub,'VALU'))"/>
                                                <xsl:sequence select="imf:create-output-element('imvert:prmt',imf:parse-xref-property-des($des-sub,'PRMT'))"/>
                                            </imvert:des>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                    <imvert:stereos>
                                        <xsl:variable name="stereo" select="imf:parse-xref-property-des($des,'STEREO')"/>
                                        <xsl:for-each select="$stereo">
                                            <xsl:sequence select="imf:create-output-element('imvert:name',imf:parse-xref-property-des-att(.,'Name'))"/>
                                        </xsl:for-each>
                                    </imvert:stereos>
                                </xsl:if>
                            </imvert:props>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </imvert:xrefprop>
            </xsl:if>    
              </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:parse-xref-property-prop" as="node()?">
        <xsl:param name="props" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:analyze-string select="$props" regex="{concat('\$',$name,'=','(.+?)','\$',$name,';')}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="imf:parse-xref-property-des" as="node()*">
        <xsl:param name="props" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:analyze-string select="$props" regex="{concat('@',$name,'[=;]','(.+?)','@END',$name,';')}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="imf:parse-xref-property-des-att" as="node()*">
        <xsl:param name="props" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:analyze-string select="concat(';',$props)" regex="{concat(';',$name,'=','(.+?)',';')}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="imf:get-classifier-role" as="node()?">
        <xsl:param name="this" as="node()"/>
        <xsl:variable name="id" select="if ($normalize-ids) then $this/@xmi.id else concat('EAID_', substring($this/@xmi.id,6))"/>
        <xsl:variable name="role" select="imf:element-by-id($id)"/>
        <!-- classifier role may also be identified through package2 tagged value. Take any classifier role with package2 is same as the ID -->
        <xsl:variable name="croles" select="$document-classifier-roles[UML:ModelElement.taggedValue/UML:TaggedValue[@tag='package2' and @value=$id]]"/>
        <xsl:sequence select="if (exists($role)) then $role else $croles"/>
    </xsl:function>
    
    <!-- return the lower and upper bound of a class. This is only applicable when stereotype is union. 
        We pass this informsation on such that for all other stereotrypes this can be checked and reported, 
        if the values are set. 
        The format is 2..* or 1..1 or empty or the like. 
    -->
    <xsl:function name="imf:get-class-cardinality-bounds" as="xs:string+">
        <xsl:param name="this" as="node()"/> <!-- a class -->
        <xsl:variable name="cardinality" select="tokenize(imf:get-system-tagged-value($this,'cardinality'),'\.\.')"/>
        <xsl:variable name="lbound" select="$cardinality[1]"/>
        <xsl:variable name="ubound" select="$cardinality[2]"/>
        <xsl:value-of select="if ($lbound) then $lbound else ''"/>
        <xsl:value-of select="if ($ubound) then (if ($ubound='*') then 'unbounded' else $ubound) else ''"/>
    </xsl:function>
    
    <xsl:function name="imf:get-svn-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- a package -->
        <!-- [dollar]Id: tester-base-pack_package1.xml 4186 2012-01-05 16:02:47Z arjan [dollar] -->
        <xsl:variable name="id" select="imf:get-profile-tagged-value($this,'Version ID')"/>
        <xsl:if test="$id">
            <xsl:sequence select="imf:create-output-element('imvert:svn-string',substring($id,2,string-length($id) - 2))"/>
            <xsl:analyze-string select="$id" regex="\$Id: (.+) (\d+) ([0-9\-]+) ([0-9:Z]+) (.+)\$">
                <xsl:matching-substring>
                    <xsl:sequence select="imf:create-output-element('imvert:svn-file',regex-group(1))"/>
                    <xsl:sequence select="imf:create-output-element('imvert:svn-revision',regex-group(2))"/>
                    <xsl:sequence select="imf:create-output-element('imvert:svn-date',regex-group(3))"/>
                    <xsl:sequence select="imf:create-output-element('imvert:svn-time',regex-group(4))"/>
                    <xsl:sequence select="imf:create-output-element('imvert:svn-user',regex-group(5))"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <!--
        Get the tagged values that are specified anywhere in this metamodel. 
        A test if the tagged value is appropriate is performed later in validation
    -->
    <xsl:function name="imf:fetch-additional-tagged-values" as="element()*">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="imf:get-tvquick-info($this)"/>
    </xsl:function>
  
    <xsl:function name="imf:get-stereotype-local-names" as="xs:string*">
        <xsl:param name="stereotypes" as="xs:string*"/>
        <xsl:sequence select="for $s in $stereotypes return imf:get-stereotype-local-name($s)"/>
    </xsl:function>

    <xsl:function name="imf:get-stereotype-local-name" as="xs:string?">
        <xsl:param name="stereotype" as="xs:string?"/>
        <xsl:variable name="parts" select="if (exists($stereotype)) then tokenize($stereotype,'::') else ()"/>
        <xsl:sequence select="if ($parts[2]) then $parts[2] else $parts[1]"/>
    </xsl:function>

    <!--  IM-77 - OCL / constraints opnemen in imvert en documentatie -->
    <xsl:function name="imf:get-constraint-info" as="element()*">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="constraints" select="$this/*/UML:Constraint"/>
        <xsl:if test="exists($constraints)">
            <imvert:constraints>
                <xsl:for-each select="$constraints">
                    <imvert:constraint>
                        <xsl:variable name="name" select="UML:ModelElement.stereotype/UML:Stereotype/@name"/>
                        <xsl:variable name="stereotype-name" select="if ($name) then imf:get-normalized-name($name,'stereotype-name') else ()"/>
                        <xsl:for-each select="imf:get-stereotypes-ids($stereotype-name)">
                            <imvert:stereotype id="{.}">
                                <xsl:value-of select="$stereotype-name"/>
                            </imvert:stereotype>
                        </xsl:for-each>
                        <xsl:sequence select="imf:create-output-element('imvert:name',@name)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type',imf:get-system-tagged-value(.,'type'))"/>
                        <xsl:sequence select="imf:create-output-element('imvert:weight',imf:get-system-tagged-value(.,'weight'))"/>
                        <xsl:sequence select="imf:create-output-element('imvert:status',imf:get-system-tagged-value(.,'status'))"/>
                        <xsl:sequence select="imf:create-output-element('imvert:definition',(imf:get-system-tagged-value(.,'description'),imf:get-system-tagged-value(.,'documentation'))[1])"/>
                       
                        <!-- when constraint on association: -->
                        <xsl:variable name="links" select="imf:get-system-tagged-value(.,'relatedlinks')"/>
                        <xsl:if test="exists($links)">
                            <imvert:connectors>
                                <xsl:analyze-string select="$links" regex="(.+?)=(.+?);">
                                    <xsl:matching-substring>
                                        <xsl:sequence select="imf:create-output-element('imvert:connector',regex-group(2))"/>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>
                            </imvert:connectors>
                        </xsl:if>
                    </imvert:constraint>
                </xsl:for-each>
            </imvert:constraints>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-alias" as="xs:string?">
        <xsl:param name="this"/>
        <xsl:param name="type"/><!-- Class, Attribute, Relation, Package -->
        <xsl:choose>
            <xsl:when test="$type='P'">
                <xsl:variable name="tv" select="imf:get-system-tagged-value($this,'alias')"/>
                <xsl:value-of select="$tv"/>
            </xsl:when>
            <xsl:when test="$type='C'">
                <xsl:variable name="tv" select="imf:get-system-tagged-value($this,'alias')"/>
                <xsl:value-of select="$tv"/>
            </xsl:when>
            <xsl:when test="$type='A'">
                <xsl:variable name="tv" select="imf:get-system-tagged-value($this,'style')"/>
                <xsl:value-of select="$tv"/>
            </xsl:when>
            <xsl:when test="$type='R'">
                <xsl:variable name="tv" select="imf:get-system-tagged-value($this,'styleex')"/>
                <xsl:value-of select="if ($tv) then imf:parse-xref-property-des-att($tv,'alias') else ''"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:parse-style" as="element()*">
        <xsl:param name="parsestring"/>
        <xsl:analyze-string select="$parsestring" regex="(.*?)=(.*?);">
            <xsl:matching-substring>
                <s name="{regex-group(1)}">
                    <xsl:value-of select="regex-group(2)"/>
                </s>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- 
        Get the ID of the construct that is the target of the trace, starting in the construct supplied. 
        For example, if class1 has a trace relation with class2, return the ID of class2.
        If multiple traces, return multiple ID's.  
    -->   
    <xsl:function name="imf:get-trace-id" as="xs:string*">
        <xsl:param name="construct"/>
        <xsl:param name="type"/>
        <xsl:variable name="construct-id" select="$construct/@xmi.id"/>
        <xsl:choose>
            <xsl:when test="$type = 'C' and $construct/self::UML:Class">
                <xsl:variable name="connection" select="$document-association-traces/UML:Association.connection[
                    UML:AssociationEnd[@type = $construct-id and UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_end' and @value='source']]
                    ]"/>
                <xsl:variable name="target" select="$connection/UML:AssociationEnd[UML:ModelElement.taggedValue/UML:TaggedValue[@tag='ea_end' and @value='target']]"/>
                <xsl:sequence select="for $r in ($target) return string($r/@type)"/>
            </xsl:when>
            <xsl:when test="$type = 'P'">
                <!-- no implementation -->
            </xsl:when>   
            <xsl:when test="$type = 'A'">
                <xsl:variable name="connection" select="imf:get-profile-tagged-value($construct,'SourceAttribute')"/>
                <xsl:sequence select="for $c in $connection return string($c)"/>
            </xsl:when>   
            <xsl:when test="$type = 'R'">
                <xsl:variable name="connection" select="imf:get-profile-tagged-value($construct,'SourceAssociation')"/>
                <xsl:sequence select="for $c in $connection return string($c)"/>
            </xsl:when>   
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('FATAL','Invalid trace request: type [1] called at [2]', ($type, name($construct)))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:variable name="document-association-dependencies" select="$document-packages/UML:Namespace.ownedElement/UML:Dependency"/>
    
    <xsl:function name="imf:get-dependency-id" as="xs:string*">
        <xsl:param name="construct"/>
        <xsl:param name="type"/>
        <xsl:variable name="construct-id" select="$construct/@xmi.id"/>
        <xsl:choose>
            <xsl:when test="$type = 'C' and $construct/self::UML:Class">
                <xsl:variable name="connection" select="$document-association-dependencies[@client = $construct-id]"/>
                <xsl:value-of select="$connection/@supplier"/>
            </xsl:when>
            <xsl:when test="$type = 'P'">
                <!-- no implementation -->
            </xsl:when>    
            <xsl:when test="$type = 'A'">
                <!-- no implementation -->
            </xsl:when>  
            <xsl:when test="$type = 'R'">
                <!-- no implementation -->
            </xsl:when>   
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('FATAL','Invalid dependency request: type [1] called at [2]', ($type, name($construct)))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:is-diagram-package" as="xs:boolean">
        <xsl:param name="pack" as="element()"/>
        <!-- TODO determine a way to determine of a package contains diagrams only -->
        <xsl:sequence select="$pack/@name = 'Diagram'"/>    
    </xsl:function>
    
    <!-- get the etry at position $index, or the last (previous) item in sequence. -->
    <xsl:function name="imf:fallback" as="item()?">
        <xsl:param name="sequence" as="item()*"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:sequence select="if (exists($sequence[$index])) then $sequence[$index] else $sequence[last()]"/>
    </xsl:function>
    
    <!-- http://www.xsltfunctions.com/xsl/functx_sort.html -->
    <xsl:function name="functx:sort" as="item()*">
        <xsl:param name="seq" as="item()*"/>
        <xsl:for-each select="$seq">
            <xsl:sort select="."/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:compile-name-path">
        <xsl:param name="this"/>
        <xsl:variable name="names" select="$this/ancestor-or-self::*/@name"/>
        <xsl:value-of select="string-join($names,' / ')"/>
    </xsl:function>
    <xsl:function name="imf:compile-xpath">
        <xsl:param name="this"/>
        <xsl:variable name="path" select="for $e in $this/ancestor-or-self::* return concat('/*:', local-name($e), '[',count($e/preceding-sibling::*[local-name(.) = local-name($e)]) + 1,']')" as="xs:string*"/>
        <xsl:value-of select="string-join($path,'')"/>
    </xsl:function>
    
    <xsl:function name="imf:get-formal-pattern" as="xs:string?">
        <xsl:param name="this"/>
        <xsl:variable name="localized-name-formal" select="imf:get-config-tagged-values('CFG-TV-FORMALPATTERN',false())"/> <!-- "Formeel patroon"of "patroon", afhankelijk van metamodel -->
        <xsl:sequence select="imf:get-profile-tagged-value($this,$localized-name-formal)[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:fetch-relevant-doc-string">
        <xsl:param name="doctext"/>
        <xsl:variable name="parts" select="tokenize($doctext,imf:get-config-parameter('documentation-separator-pattern'),'s')"/>
        <xsl:value-of select="$parts[1]"/>
    </xsl:function>
    
    
    <!-- == optimization == -->
    
    <xsl:function name="imf:get-tvquick-info" as="element(imvert:tagged-values)?">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:fetch-additional-tagged-values-quick($this)"/> 
    </xsl:function>   
    
    <xsl:function name="imf:fetch-additional-tagged-values-quick" as="element(imvert:tagged-values)?">
        <xsl:param name="this" as="element()"/>
        
        <xsl:variable name="tagged-values" select="imf:get-tagged-values-quick($this,true())"/>
        <xsl:variable name="seq" as="element()*">
            <xsl:for-each select="$tagged-values"> <!-- <tv> elements --> 
                <xsl:variable name="name" select="@tag"/>
                <xsl:variable name="level" select="@imvert-level"/>
                <xsl:variable name="norm-name" select="imf:get-normalized-name(string($name),'tv-name')"/>
                <xsl:variable name="declared-tv" select="$additional-tagged-values[name = $norm-name]"/>
                <xsl:variable name="value" select="imf:get-tagged-value-original(.)"/>
                <xsl:variable name="norm-value" select="imf:get-tagged-value-norm($value,$declared-tv/@norm)"/>
                <xsl:if test="exists($declared-tv) and normalize-space($norm-value)">
                    <imvert:tagged-value id="{$declared-tv/@id}" level="{$level}">
                        <imvert:name original="{$name}">
                            <xsl:value-of select="$norm-name"/>
                        </imvert:name>
                        <imvert:value original="{$value}">
                            <xsl:value-of select="$norm-value"/>
                        </imvert:value>
                    </imvert:tagged-value>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <imvert:tagged-values>
            <xsl:sequence select="$seq"/>
        </imvert:tagged-values>
    
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-values-quick" as="element(UML:TaggedValue)*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="profiled" as="xs:boolean"/>
        <!-- 
            this implements the equivalent of:
            if ($local-value) then $local-value else 
            if ($global-value) then $global-value else 
            if ($local-cr-value) then $local-cr-value else 
            if ($global-cr-value) then $global-cr-value else 
            if ($root-model-value) then $root-model-value else 
            ()
        -->
        <xsl:variable name="crole" select="imf:get-classifier-role($this)"/>
        <xsl:variable name="root-model" select="$content/UML:Model"/>
        
        <xsl:variable name="local-value" select="imf:filter-tagged-values-quick($this/UML:ModelElement.taggedValue/UML:TaggedValue,$profiled,1)"/>
        <xsl:variable name="global-value" select="imf:filter-tagged-values-quick($content/UML:TaggedValue[@modelElement=$this/@xmi.id],$profiled,2)"/>
        <xsl:variable name="local-cr-value" select="imf:filter-tagged-values-quick($crole/UML:ModelElement.taggedValue/UML:TaggedValue,$profiled,3)"/>
        <xsl:variable name="global-cr-value" select="imf:filter-tagged-values-quick($content/UML:TaggedValue[@modelElement=$crole/@xmi.id],$profiled,4)"/>
        <!--<xsl:variable name="root-model-value" select="imf:filter-tagged-values-quick($content/UML:TaggedValue[@modelElement=$root-model/@xmi.id],$profiled,5)"/>-->
        
        <!-- 
            assume that tagged values must be defined on the same level, and local valueshave prio 
        -->
        <xsl:variable name="tagged-values" select="
            if (exists($local-value)) then $local-value else 
            if (exists($global-value)) then $global-value else 
            if (exists($local-cr-value)) then $local-cr-value else
            if (exists($global-cr-value)) then $global-cr-value else 
            ()
            "/>
        
        <xsl:sequence select="$tagged-values"/>
        
    </xsl:function>
    
    <xsl:function name="imf:filter-tagged-values-quick" as="element(UML:TaggedValue)*">
        <xsl:param name="tvs"/>
        <xsl:param name="profiled"/>
        <xsl:param name="level"/>
        <xsl:sequence select="for $tv in $tvs[imf:tagged-value-select-profiled(.,$profiled)] return imf:set-level-quick($tv,$level)"/>
    </xsl:function>
    
    <xsl:function name="imf:set-level-quick" as="element(UML:TaggedValue)">
        <xsl:param name="tv"/>
        <xsl:param name="level"/>
        <xsl:element name="{name($tv)}">
            <xsl:copy-of select="$tv/@*"/>
            <xsl:attribute name="imvert-level" select="$level"/>
            <xsl:copy-of select="$tv/node()"/>
        </xsl:element>
    </xsl:function>
    
    <xsl:function name="imf:compile-support-info" as="element(imvert:support)*">
        <imvert:support>
            <imvert:level>STEREOID</imvert:level>
        </imvert:support>
    </xsl:function>
    
</xsl:stylesheet>
