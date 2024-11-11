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

    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:functx="http://www.functx.com"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
      Build the configuration file.
    -->
   
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="Imvert2configuration-speed-analyzer.xsl"/>
    
    <xsl:variable name="configuration-owner-doc" select="imf:document($configuration-owner-name,true())"/>
    <xsl:variable name="configuration-metamodel-doc" select="imf:document($configuration-metamodel-name)"/>
    <xsl:variable name="configuration-tvset-doc" select="imf:document($configuration-tvset-name)"/>
    <xsl:variable name="configuration-notesrules-doc" select="imf:document($configuration-notesrules-name)"/>
    <xsl:variable name="configuration-docrules-doc" select="imf:document($configuration-docrules-name)"/>
    <xsl:variable name="configuration-versionrules-doc" select="imf:document($configuration-versionrules-name,true())"/>
    <xsl:variable name="configuration-visuals-doc" select="imf:document($configuration-visuals-name)"/>
    
    <xsl:variable name="configuration-xmlschemarules-doc" select="imf:document($configuration-xmlschemarules-name)"/><!-- not required -->
    <xsl:variable name="configuration-jsonschemarules-doc" select="imf:document($configuration-jsonschemarules-name)"/><!-- not required -->
    <xsl:variable name="configuration-shaclrules-doc" select="imf:document($configuration-shaclrules-name)"/><!-- not required -->
    <xsl:variable name="configuration-skosrules-doc" select="imf:document($configuration-skosrules-name)"/><!-- not required -->
    
    <xsl:variable name="configuration-owner-file" select="imf:prepare-config($configuration-owner-doc)"/>
    <xsl:variable name="configuration-metamodel-file" select="imf:prepare-config($configuration-metamodel-doc)"/>
    <xsl:variable name="configuration-tvset-file" select="imf:prepare-config($configuration-tvset-doc)"/>
    <xsl:variable name="configuration-notesrules-file" select="imf:prepare-config($configuration-notesrules-doc)"/>
    <xsl:variable name="configuration-docrules-file" select="imf:prepare-config($configuration-docrules-doc)"/>
    <xsl:variable name="configuration-versionrules-file" select="imf:prepare-config($configuration-versionrules-doc)"/>
    <xsl:variable name="configuration-visuals-file" select="imf:prepare-config($configuration-visuals-doc)"/>
    
    <xsl:variable name="configuration-xmlschemarules-file" select="imf:prepare-config($configuration-xmlschemarules-doc)"/><!-- not required -->
    <xsl:variable name="configuration-jsonschemarules-file" select="imf:prepare-config($configuration-jsonschemarules-doc)"/><!-- not required -->
    <xsl:variable name="configuration-shaclrules-file" select="imf:prepare-config($configuration-shaclrules-doc)"/><!-- not required -->
    <xsl:variable name="configuration-skosrules-file" select="imf:prepare-config($configuration-skosrules-doc)"/><!-- not required -->
    
    <xsl:variable name="translations" as="element(trans)*">
        <xsl:sequence select="imf:prepare-translations($configuration-metamodel-doc)"/>
        <xsl:sequence select="imf:prepare-translations($configuration-tvset-doc)"/>
    </xsl:variable>

    <xsl:template match="/" priority="10">
        <!-- 
            Meld wanneer een van de vereiste metamodel files niet beschikbaar is 
        -->
        <xsl:variable name="r" as="xs:integer*">
            <xsl:sequence select="if (empty($configuration-metamodel-doc)) then imf:msg('ERROR','Metamodel not available: [1]',imf:get-reportable-config-path($configuration-metamodel-name)) else 1"/>
            <xsl:sequence select="if (empty($configuration-tvset-doc)) then imf:msg('ERROR','Tvset not available: [1]',imf:get-reportable-config-path($configuration-tvset-name)) else 1"/>
            <xsl:sequence select="if (empty($configuration-notesrules-doc)) then imf:msg('ERROR','Notesrules not available: [1]',imf:get-reportable-config-path($configuration-notesrules-name)) else 1"/>
            <xsl:sequence select="if (empty($configuration-docrules-doc)) then imf:msg('ERROR','Docrules not available: [1]',imf:get-reportable-config-path($configuration-docrules-name)) else 1"/>
            <xsl:sequence select="if (empty($configuration-visuals-doc)) then imf:msg('ERROR','Visuals not available: [1]',imf:get-reportable-config-path($configuration-visuals-name)) else 1"/>
        </xsl:variable>
       
        <xsl:choose>
            <xsl:when test="count($r) = 5">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <config>
                    <xsl:comment>Error reading metamodel files</xsl:comment>
                    <xsl:sequence select="$configuration-owner-file"/>
                </config>
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:template>
 
    <xsl:template match="/">
        <!--<xsl:apply-templates select="/" mode="speed-analyzer"/>-->
       
        <xsl:variable name="config-raw">
            <config>
                <xsl:sequence select="$configuration-owner-file"/>
                <xsl:sequence select="$configuration-metamodel-file"/>
                <xsl:sequence select="$configuration-xmlschemarules-file"/>
                <xsl:sequence select="$configuration-jsonschemarules-file"/>
                <xsl:sequence select="$configuration-tvset-file"/>
                <xsl:sequence select="$configuration-notesrules-file"/>
                <xsl:sequence select="$configuration-docrules-file"/>
                <xsl:sequence select="$configuration-versionrules-file"/>
                <xsl:sequence select="$configuration-visuals-file"/>
                <xsl:sequence select="$configuration-shaclrules-file"/>
                <xsl:sequence select="$configuration-skosrules-file"/>
            </config>
        </xsl:variable>
        
        <!-- create a short tre-like representation of this config for referecing purposes; this will reappear in the documentation -->
        <xsl:variable name="tree-includes">
            <xsl:apply-templates select="$config-raw" mode="tree-includes"/>
        </xsl:variable>
        
        <xsl:result-document href="{imf:file-to-url(imf:get-xparm('properties/WORK_CONFIG_TREE_FILE'))}">
            <xsl:sequence select="$tree-includes"/>
        </xsl:result-document>
        
        <xsl:variable name="config-compact" as="element(config)">
            <xsl:apply-templates select="$config-raw" mode="finish-config"/>
        </xsl:variable>
        <xsl:sequence select="$config-compact"/>
        
        <!-- set some global configuration info -->
        <xsl:variable name="proxy" select="imf:get-config-stereotypes(('stereotype-name-att-proxy','stereotype-name-obj-proxy','stereotype-name-grp-proxy','stereotype-name-prd-proxy'), false())"/>
        <xsl:sequence select="imf:set-config-string('system','supports-proxy',if ($proxy = '#unknown') then 'no' else 'yes')"/>
        
        <xsl:variable name="okeys" select="$config-compact/project-owner/parameter[@name = 'message-collapse-keys'][last()]"/>
        <xsl:sequence select="imf:set-config-string('system','message-collapse-keys',$okeys)"/>
        <xsl:variable name="keys" select="imf:merge-parms(imf:get-config-string('cli','messagecollapsekeys'))"/>
        <xsl:sequence select="imf:set-config-string('appinfo','message-collapse-keys',$keys)"/>
        
        <xsl:variable name="metamodel-configured-version" select="(for $m in $config-compact/prologue/metamodels/metamodel return if (starts-with($m,'MIM ')) then $m else ())[1]"/> <!-- lijst van MIM metamodel names, de eerste is de gekozen metamodel versie -->
        <xsl:sequence select="imf:set-config-string('appinfo','metamodel-configured-version',substring-after($metamodel-configured-version,'MIM '))"/>
        
        <!-- signal if not using the latest release or a nightly build (or other feature branch build) of imvertor -->
        <xsl:variable name="crx" select="imf:get-config-string('run','version')"/>
        <xsl:variable name="lrx" select="imf:get-config-string('system','latest-imvertor-release')"/>
        <xsl:choose>
            <xsl:when test="matches($crx, '^\d+\.\d+\.\d+.*$')"> <!-- (starts with) a regular major-minor version? -->
                <xsl:variable name="cr" select="string-join(for $m in subsequence(tokenize($crx,'\.'),1,2) return functx:pad-integer-to-length($m,5),'')"/>
                <xsl:variable name="lr" select="string-join(for $m in subsequence(tokenize($lrx,'\.'),1,2) return functx:pad-integer-to-length($m,5),'')"/>
                <xsl:sequence select="imf:report-warning(.,$cr lt $lr,'You are using Imvertor version [1], however a more recent version [2] is available.',($crx,$lrx))"/>
            </xsl:when>
            <xsl:otherwise> <!-- nightly or other feature branch "non-stable" build: -->
                <xsl:sequence select="imf:report-warning(.,true(),'You are using Imvertor version [1] which is not considered a stable version. The most recent stable version is [2].',($crx,$lrx))"/>                 
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- name normalization on all configuration files -->
    
    <xsl:function name="imf:prepare-config">
        <xsl:param name="document" as="document-node()?"/>
        <xsl:apply-templates select="$document" mode="prepare-config"/>
    </xsl:function>
    
    <xsl:template match="tv/name" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'tv-name')"/>
    </xsl:template>
    
    <xsl:template match="tv/declared-values/value" mode="prepare-config">
        <xsl:variable name="norm" select="(../../@norm,'space')[1]"/>
        <xsl:sequence select="imf:prepare-config-tagged-value-element(.,$norm)"/>
    </xsl:template>
    
    <xsl:template match="tv/stereotypes/stereo" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element-tv(.,'stereotype-name')"/>
    </xsl:template>
    
    <xsl:template match="stereotypes/stereo/name" mode="prepare-config">
        <xsl:sequence select="imf:prepare-config-name-element(.,'stereotype-name')"/>
    </xsl:template>
    
    <xsl:function name="imf:prepare-config-name-element" as="element()?">
        <xsl:param name="name-element" as="element()"/>
        <xsl:param name="name-type" as="xs:string"/>
        <xsl:if test="$name-element/@lang = ($language,'#all')">
            <xsl:element name="{name($name-element)}">
                <xsl:apply-templates select="$name-element/@*" mode="prepare-config"/>
                <xsl:attribute name="original" select="$name-element/text()"/>
                <xsl:value-of select="imf:get-normalized-name($name-element,$name-type)"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <!-- content is ID of the stereotype for which the TV is valid -->
    <xsl:function name="imf:prepare-config-name-element-tv" as="element()?">
        <xsl:param name="name-element" as="element()"/>
        <xsl:param name="name-type" as="xs:string"/>
        <xsl:variable name="stereo-def" select="$configuration-metamodel-file//stereo[@id = $name-element]"/>
        <xsl:choose>
            <xsl:when test="exists($stereo-def)">
                <xsl:element name="{name($name-element)}">
                    <xsl:apply-templates select="$name-element/@*" mode="prepare-config"/>
                    <!-- note that several names may be assigned to the same stereotype ID. assume the last. -->
                    <xsl:variable name="applicable-name" select="($stereo-def/name)[last()]"/>
                    <xsl:copy-of select="$applicable-name/@original"/>
                    <xsl:attribute name="id" select="$name-element"/>
                    <xsl:value-of select="$applicable-name"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('FATAL','No such stereotype @id=[1]', $name-element)"/>
            </xsl:otherwise>
        </xsl:choose>
  
    </xsl:function>
    
    <xsl:function name="imf:prepare-config-tagged-value-element" as="element()?">
        <xsl:param name="value-element" as="element()"/>
        <xsl:param name="norm-rule" as="xs:string"/>
        <xsl:if test="($value-element/ancestor-or-self::*/@lang)[1] = ($language,'#all')">
            <xsl:element name="{name($value-element)}">
                <xsl:apply-templates select="$value-element/@*" mode="prepare-config"/>
                <xsl:attribute name="original" select="$value-element/text()"/>
                <xsl:value-of select="imf:get-tagged-value-norm-prepare($value-element,$norm-rule)"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    
    <!-- === finish the config, compact to a single config with no duplicates or extensions === -->
    
    <xsl:template match="config" mode="finish-config">
        <config xmlns:xi="http://www.w3.org/2001/XInclude">
            
            <prologue>
                <metamodels>
                    <xsl:for-each select="$configuration-metamodel-doc//metamodel">
                        <metamodel>
                            <xsl:sequence select="name"/>
                            <xsl:sequence select="model-designation"/>
                        </metamodel>
                    </xsl:for-each>
                </metamodels>
                <!-- TODO more info required? -->
            </prologue>
            
            <project-owner root="true">
                <xsl:variable name="project-owner" select=".//project-owner"/> 
                <xsl:apply-templates select="($project-owner/name)[last()]" mode="#current"/>
                <xsl:for-each-group select="$project-owner/parameter" group-by="@name">
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
                <patterns>
                    <xsl:for-each-group select="$project-owner/patterns/p" group-by="@name">
                        <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                    </xsl:for-each-group>
                </patterns>
            </project-owner>
            
            <metamodel root="true">
                <xsl:variable name="metamodel" select="metamodel"/>
                <!-- Names override previously assigned names -->
                <xsl:sequence select="imf:fetch-applicable-name($metamodel/name)"/>
                <xsl:apply-templates select="$metamodel/desc" mode="#current"/>
                
                <profiles>
                    <xsl:for-each-group select="$metamodel//profiles/profile" group-by="@lang">
                        <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                    </xsl:for-each-group>   
                </profiles>
                
                <scalars>
                    <xsl:for-each-group select="$metamodel//scalars/scalar" group-by="@id">
                        <xsl:sort select="current-grouping-key()"/>
                        <scalar id="{current-grouping-key()}">
                            <xsl:variable name="scalar-group" select="current-group()"/>
                            <xsl:sequence select="imf:fetch-applicable-name($scalar-group/name)"/>
                            <xsl:apply-templates select="($scalar-group/desc[@lang=($language,'#all')])[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/type)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/fraction-digits)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/max-length)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/type-map)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/type-modifier)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/source)" mode="#current"/><!-- retain all sources -->
                            <xsl:apply-templates select="($scalar-group/catalog)[last()]" mode="#current"/>
                        </scalar>
                    </xsl:for-each-group>
                </scalars>
                
                <naming>
                    <xsl:for-each-group select="$metamodel//naming/*" group-by="local-name()">
                        <xsl:sort select="current-grouping-key()"/>
                        <xsl:apply-templates select="(current-group())[last()]" mode="#current"/>
                    </xsl:for-each-group>
                </naming>
                
                <features>
                    <xsl:for-each-group select="$metamodel//features/feature" group-by="@name">
                        <xsl:sort select="current-grouping-key()"/>
                        <xsl:apply-templates select="(current-group())[last()]" mode="#current"/>
                    </xsl:for-each-group>
                </features>
                
                <stereotypes>
                    <xsl:for-each-group select="$metamodel//stereotypes/stereo" group-by="@id">
                        <xsl:sort select="current-grouping-key()"/>
                        <stereo id="{current-grouping-key()}" primary="{(current-group()/@primary)[last()]}">
                            <xsl:variable name="stereo-group" select="current-group()"/>
                            <xsl:sequence select="imf:fetch-applicable-name($stereo-group/name)"/>
                            <xsl:apply-templates select="($stereo-group/desc[@lang=($language,'#all')])[last()]" mode="#current"/>
                            <xsl:for-each-group select="$stereo-group/construct" group-by=".">
                                <xsl:sort select="current-grouping-key()"/>
                                <xsl:variable name="construct-group" select="current-group()"/>
                                <xsl:apply-templates select="$construct-group[last()]" mode="#current"/>
                            </xsl:for-each-group>
                            <context>
                                <xsl:for-each-group select="$stereo-group/context/parent-stereo" group-by=".">
                                    <xsl:sort select="current-grouping-key()"/>
                                    <xsl:variable name="construct-group" select="current-group()"/>
                                    <xsl:apply-templates select="$construct-group[last()]" mode="#current"/>
                                </xsl:for-each-group>
                                <xsl:for-each-group select="$stereo-group/context/super-stereo" group-by=".">
                                    <xsl:sort select="current-grouping-key()"/>
                                    <xsl:variable name="construct-group" select="current-group()"/>
                                    <xsl:apply-templates select="$construct-group[last()]" mode="#current"/>
                                </xsl:for-each-group>
                            </context>
                            <xsl:apply-templates select="($stereo-group/toplevel)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($stereo-group/entity-relation-constraint)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($stereo-group/source)" mode="#current"/><!-- retain all sources -->
                            <xsl:apply-templates select="($stereo-group/catalog)[last()]" mode="#current"/>
                        </stereo>
                    </xsl:for-each-group> 
                </stereotypes>
                
            </metamodel>
            
            <visuals>
                <xsl:variable name="visuals" select="visuals"/>
                <xsl:sequence select="imf:fetch-applicable-name($visuals/name)"/>
                <xsl:for-each-group select="$visuals//categories/category" group-by="@id">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>   
                <xsl:for-each-group select="$visuals//measures/measure" group-by="@id">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>   
                <xsl:for-each-group select="$visuals//stereos/stereo" group-by="@id">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>   
            </visuals>
            
            <xmlschema-rules root="true">
                <xsl:variable name="xmlschema-rules" select="xmlschema-rules"/> 
                <xsl:apply-templates select="imf:distinct($xmlschema-rules/name[@lang=($language,'#all')])" mode="#current"/>
                
                <name-value-mapping>
                    <xsl:for-each-group select="$xmlschema-rules//tagged-values/tv" group-by="@id">
                        <xsl:sort select="current-grouping-key()"/>
                        <tv id="{current-grouping-key()}">
                            <xsl:variable name="tv-group" select="current-group()"/>
                            <xsl:apply-templates select="imf:distinct($tv-group/name[@lang=($language,'#all')])" mode="#current"/>
                            <xsl:apply-templates select="imf:distinct($tv-group/schema-name)" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/external-schema-name)[last()]" mode="#current"/>
                        </tv>
                    </xsl:for-each-group>
                </name-value-mapping>
          
                <xsl:for-each-group select="$xmlschema-rules//parameter" group-by="@name">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
          
            </xmlschema-rules>

            <jsonschema-rules root="true">
                <xsl:variable name="jsonschema-rules" select="jsonschema-rules"/> 
                <xsl:apply-templates select="imf:distinct($jsonschema-rules/name[@lang=($language,'#all')])" mode="#current"/>
                
                <xsl:for-each-group select="$jsonschema-rules//parameter" group-by="@name">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
                
            </jsonschema-rules>
            
            <tagset root="true">
                <xsl:variable name="tagset" select="tagset"/> 
                <xsl:apply-templates select="imf:distinct($tagset/name[@lang=($language,'#all')])" mode="#current"/>
                <xsl:apply-templates select="imf:distinct($tagset/desc[@lang=($language,'#all')])" mode="#current"/>
                
                <tagged-values>
                    <xsl:for-each-group select="$tagset//tagged-values/tv" group-by="@id">
                        <xsl:sort select="current-grouping-key()"/>
                        <tv id="{current-grouping-key()}">
                            <xsl:variable name="tv-group" select="current-group()"/>
                            <xsl:apply-templates select="($tv-group/@norm)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/@rules)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/@cross-meta)[last()]" mode="#current"/>
                            
                            <!-- hier: de laatste naam binnen dezelfde taal -->
                            <xsl:sequence select="imf:fetch-applicable-name($tv-group/name)"/>
                            <xsl:apply-templates select="($tv-group/desc[@lang=($language,'#all')])[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/derive)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/override)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/inherit)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/source)" mode="#current"/><!-- retain all sources -->
                            <xsl:apply-templates select="($tv-group/catalog)[last()]" mode="#current"/>
                            <stereotypes>
                                <xsl:for-each-group select="$tv-group/stereotypes/stereo" group-by=".">
                                    <xsl:sort select="current-grouping-key()"/>
                                    <xsl:variable name="stereo-group" select="current-group()"/>
                                    <xsl:apply-templates select="$stereo-group[last()]" mode="#current"/>
                                </xsl:for-each-group>
                            </stereotypes>                                
                            <declared-values> <!-- TODO must also take @lang in to account -->
                                <xsl:for-each-group select="$tv-group/declared-values[@lang=($language,'#all')]/value" group-by=".">
                                    <xsl:sort select="current-grouping-key()"/>
                                    <xsl:variable name="dec-group" select="current-group()"/>
                                    <xsl:apply-templates select="$dec-group[last()]" mode="#current"/>
                                </xsl:for-each-group>
                            </declared-values>
                        </tv>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="$tagset//tagged-values/pseudo-tv" group-by="@id">
                        <xsl:sort select="current-grouping-key()"/>
                        <pseudo-tv id="{current-grouping-key()}">
                            <xsl:variable name="tv-group" select="current-group()"/>
                            <!-- hier: de laatste naam binnen dezelfde taal -->
                            <xsl:sequence select="imf:fetch-applicable-name($tv-group/name)"/>
                            <xsl:apply-templates select="($tv-group/desc[@lang=($language,'#all')])[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/source)" mode="#current"/><!-- retain all sources -->
                            <xsl:apply-templates select="($tv-group/catalog)[last()]" mode="#current"/>
                        </pseudo-tv>
                    </xsl:for-each-group>
                </tagged-values>
            </tagset>

            <notes-rules root="true">
                <xsl:variable name="notes-rules" select="notes-rules"/> 
                <xsl:apply-templates select="imf:distinct($notes-rules//notes-format)[last()]" mode="#current"/>
                <xsl:apply-templates select="imf:distinct($notes-rules//notes-rule[@lang=($language,'#all')])" mode="#current"/>
            </notes-rules>
            
            <version-rules root="true">
                <xsl:variable name="version-rules" select="version-rules"/> 
                <xsl:apply-templates select="$version-rules//version-rule" mode="#current"/>
                <xsl:apply-templates select="$version-rules//phase-rule" mode="#current"/>
            </version-rules>

            <doc-rules root="true">
                <xsl:variable name="doc-rules" select="doc-rules"/> 
             
                <xsl:apply-templates select="($doc-rules//link-by)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//explanation-location)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//diagram-type-strategy)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//include-incoming-associations)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//lists-to-listing)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//reveal-composition-name)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//include-overview-section-level)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//include-detail-section-level)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//include-overview-sections-by-type)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//include-detail-sections-by-type)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//show-properties)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//respec-config)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//identifying-attribute-with-context)[last()]" mode="#current"/>
                <xsl:apply-templates select="($doc-rules//gegevensgroep-attribute-container)[last()]" mode="#current"/>
                
                <xsl:for-each-group select="$doc-rules//doc-rule[name/@lang=($language,'#all')]" group-by="@id">
                    <xsl:sort select="@order" order="ascending"/>
                    <doc-rule id="{current-grouping-key()}" order="{@order}">
                        <xsl:apply-templates select="current-group()[last()]/name" mode="#current"/>
                        <levels>
                            <xsl:for-each-group select="current-group()/levels/level" group-by="text()">
                                <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                            </xsl:for-each-group>
                        </levels>
                    </doc-rule>
                </xsl:for-each-group>
                <xsl:for-each-group select="$doc-rules//image-purpose[name/@lang=($language,'#all')]" group-by="@id">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
            </doc-rules>
            
            <shacl-rules root="true">
                <xsl:variable name="shacl-rules" select="shacl-rules"/> 
                <xsl:for-each select="$shacl-rules//vocabularies">
                    <xsl:apply-templates select="." mode="#current"/>
                </xsl:for-each>
                <xsl:for-each select="$shacl-rules//node-mapping">
                    <xsl:apply-templates select="." mode="#current"/>
                </xsl:for-each>
                <xsl:for-each-group select="$shacl-rules//parameter" group-by="@name">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
            </shacl-rules>
            
            <skos-rules root="true">
                <xsl:variable name="skos-rules" select="skos-rules"/> 
                <xsl:for-each select="$skos-rules//vocabularies">
                    <xsl:apply-templates select="." mode="#current"/>
                </xsl:for-each>
                <xsl:for-each select="$skos-rules//node-mapping">
                    <xsl:apply-templates select="." mode="#current"/>
                </xsl:for-each>
                <xsl:for-each-group select="$skos-rules//parameter" group-by="@name">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
            </skos-rules>
            
            <translations>
                <xsl:for-each-group select="$translations" group-by="@orig-id">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
            </translations>
            
        </config>
    </xsl:template>
    
    <xsl:template match="*" mode="finish-config">
        <xsl:if test="empty(@lang) or @lang = ($language,'#all')">
            <xsl:variable name="embedding" select="reverse(ancestor::*[@type = 'config'])"/>
            <xsl:copy>
                <xsl:apply-templates select="@*" mode="#current"/>
                <!-- add the origins of the configurated value, i.e. the call stack -->
                <xsl:attribute name="srcbase" select="($embedding[1])/@xml:base"/>
                <xsl:attribute name="src" select="string-join(for $c in $embedding return $c/name,'&lt;')"/>
                <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@*" mode="finish-config">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="config" mode="tree-includes">
        <config>
            <xsl:apply-templates mode="#current"/>
        </config>
    </xsl:template>
    <xsl:template match="*[@type = 'config']" mode="tree-includes">
        <includes type="{local-name()}" name="{name}" desc="{imf:fetch-applicable-name(desc)}">
            <xsl:apply-templates mode="#current"/>
        </includes>
    </xsl:template>
    <xsl:template match="*" mode="tree-includes">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="text()" mode="tree-includes">
        <!-- skip -->
    </xsl:template>
    
   <!-- 
       determine the distinct values, based on what is considered to be distinct in processing configuration elements 
       That is: the content and all attributes are the same. The config elements are duplicated in this sense.
   -->
    <xsl:function name="imf:distinct" as="element()*">
        <xsl:param name="elms" as="element()*"/>
        <xsl:for-each-group select="$elms" group-by="imf:serialize(.)">
            <xsl:sequence select="current-group()[last()]"/>
        </xsl:for-each-group>
    </xsl:function>
    
    <xsl:function name="imf:serialize" as="xs:string">
        <xsl:param name="elm" as="element()"/>
        <xsl:variable name="r">
            <xsl:for-each select="$elm/descendant-or-self::*">
                <xsl:value-of select="name(.)"/>
                <xsl:value-of select="string(.)"/>
                <xsl:for-each select="@*">
                    <xsl:value-of select="name(.)"/>
                    <xsl:value-of select="string(.)"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$r"/>
    </xsl:function>
    
    <xsl:function name="imf:fetch-applicable-name" as="element()?">
        <xsl:param name="names"/>
        <xsl:for-each-group select="$names" group-by="@lang">
            <xsl:apply-templates select="current-group()[last()]" mode="finish-config"/>
        </xsl:for-each-group>
    </xsl:function>
    
    <xsl:function name="imf:prepare-translations" as="element(trans)*"> 
        <xsl:param name="document" as="document-node()?"/>
        <xsl:apply-templates select="$document" mode="prepare-translations"/>
    </xsl:function>
    
    <xsl:template match="*[@id and name/@lang]" mode="prepare-translations">
        <trans orig-id="{@id}">
            <root><xsl:value-of select="local-name(root(.)/*)"/></root>
            <part><xsl:value-of select="local-name(.)"/></part>
            <xsl:for-each select="name">
                <name orig-lang="{@lang}"><xsl:value-of select="."/></name>
            </xsl:for-each>
            <paths>
                <xsl:for-each select="ancestor::*[@type='config' and @xml:base]">
                    <path loc="{@xml:base}"><xsl:value-of select="name"/></path>
                </xsl:for-each>
            </paths>
        </trans>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="node()" mode="prepare-translations">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
</xsl:stylesheet>
