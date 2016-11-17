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
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
      Build the configuration file.
    -->
   
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="configuration-owner-file" select="imf:prepare-config(imf:document($configuration-owner-name))"/>
    <xsl:variable name="configuration-metamodel-file" select="imf:prepare-config(imf:document($configuration-metamodel-name))"/>
    <xsl:variable name="configuration-schemarules-file" select="imf:prepare-config(imf:document($configuration-schemarules-name))"/>
    <xsl:variable name="configuration-tvset-file" select="imf:prepare-config(imf:document($configuration-tvset-name))"/>
    
    <xsl:variable name="metamodel-name" select="imf:get-normalized-name(imf:get-config-string('cli','metamodel'),'system-name')"/>
    <xsl:variable name="schemarules-name" select="imf:get-normalized-name(imf:get-config-string('cli','schemarules'),'system-name')"/>
    <xsl:variable name="tvset-name" select="imf:get-normalized-name(imf:get-config-string('cli','tvset'),'system-name')"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="empty($configuration-owner-file)">
                <xsl:sequence select="imf:msg('FATAL','Invalid/incomplete configuration for owner [1]', $owner-name)"/>
                <xsl:sequence select="imf:msg('DEBUG','Owner config at [1]', $configuration-owner-name)"/>
            </xsl:when>
            <xsl:when test="empty($configuration-metamodel-file)">
                <xsl:sequence select="imf:msg('FATAL','Invalid/incomplete configuration for metamodel [1]', $metamodel-name)"/>
                <xsl:sequence select="imf:msg('DEBUG','Metamodel config at [1]', $configuration-metamodel-name)"/>
            </xsl:when>
            <xsl:when test="empty($configuration-schemarules-file)">
                <xsl:sequence select="imf:msg('FATAL','Invalid/incomplete configuration for schema rules [1]', $schemarules-name)"/>
                <xsl:sequence select="imf:msg('DEBUG','Schemarules config at [1]', $configuration-schemarules-name)"/>
            </xsl:when>
            <xsl:when test="empty($configuration-tvset-file)">
                <xsl:sequence select="imf:msg('FATAL','Invalid/incomplete configuration for tvset [1]', $tvset-name)"/>
                <xsl:sequence select="imf:msg('DEBUG','Tvset config at [1]', $configuration-tvset-name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="config-raw">
                    <config>
                        <xsl:sequence select="$configuration-owner-file"/>
                        <xsl:sequence select="$configuration-metamodel-file"/>
                        <xsl:sequence select="$configuration-schemarules-file"/>
                        <xsl:sequence select="$configuration-tvset-file"/>
                    </config>
                </xsl:variable>
                <xsl:variable name="config-compact">
                    <xsl:apply-templates select="$config-raw" mode="finish-config"/>
                </xsl:variable>
                <xsl:sequence select="$config-compact"/>
                
                <!-- set some global configuration info -->
                <xsl:variable name="proxy" select="imf:get-config-stereotypes(('stereotype-name-att-proxy','stereotype-name-obj-proxy','stereotype-name-grp-proxy'), false())"/>
                <xsl:sequence select="imf:set-config-string('system','supports-proxy',if ($proxy = '#unknown') then 'no' else 'yes')"/>
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
        <xsl:sequence select="imf:prepare-config-name-element(.,'stereotype-name')"/>
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
    
    
    <!-- == finish the config, compact to a single config with no duplicates or extensions === -->
    
    <xsl:template match="config" mode="finish-config">
        <config xmlns:xi="http://www.w3.org/2001/XInclude">
            <project-owner>
                <xsl:variable name="project-owner" select="project-owner"/> 
                <xsl:apply-templates select="$project-owner/name" mode="#current"/>
                <xsl:for-each-group select="$project-owner/parameter" group-by="@name">
                    <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                </xsl:for-each-group>
                <patterns>
                    <xsl:for-each-group select="$project-owner/patterns/p" group-by="@name">
                        <xsl:apply-templates select="current-group()[last()]" mode="#current"/>
                    </xsl:for-each-group>
                </patterns>
            </project-owner>
            
            <metamodel>
                <xsl:variable name="metamodel" select="metamodel"/>
                <xsl:apply-templates select="$metamodel/name" mode="#current"/>
                <xsl:apply-templates select="$metamodel/desc" mode="#current"/>
                <scalars>
                    <xsl:for-each-group select="$metamodel//scalars/scalar" group-by="@id">
                        <scalar id="{current-grouping-key()}">
                            <xsl:variable name="scalar-group" select="current-group()"/>
                            <xsl:apply-templates select="imf:distinct($scalar-group/name)" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/type)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/fraction-digits)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/max-length)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/type-map)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($scalar-group/type-modifier)[last()]" mode="#current"/>
                        </scalar>
                    </xsl:for-each-group>
                </scalars>
       
                <xsl:apply-templates select="($metamodel//composition-direction-source)[last()]" mode="#current"/>
                
                <naming>
                    <xsl:for-each-group select="$metamodel//naming/*" group-by="local-name()">
                        <xsl:apply-templates select="(current-group())[last()]" mode="#current"/>
                    </xsl:for-each-group>
                </naming>
                
                <stereotypes>
                    <xsl:for-each-group select="$metamodel//stereotypes/stereo" group-by="@id">
                        <stereo id="{current-grouping-key()}">
                            <xsl:variable name="stereo-group" select="current-group()"/>
                            <xsl:apply-templates select="imf:distinct($stereo-group/name)" mode="#current"/>
                            <xsl:apply-templates select="($stereo-group/desc)[last()]" mode="#current"/>
                            <xsl:for-each-group select="$stereo-group/construct" group-by=".">
                                <xsl:variable name="construct-group" select="current-group()"/>
                                <xsl:apply-templates select="$construct-group[last()]" mode="#current"/>
                            </xsl:for-each-group>
                            <xsl:apply-templates select="($stereo-group/toplevel)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($stereo-group/entity-relation-constraint)[last()]" mode="#current"/>
                        </stereo>
                    </xsl:for-each-group> 
                </stereotypes>
                
            </metamodel>
            
            <schema-rules>
                <xsl:variable name="schema-rules" select="schema-rules"/> 
                <xsl:apply-templates select="imf:distinct($schema-rules/name)" mode="#current"/>
                
                <name-value-mapping>
                    <xsl:for-each-group select="$schema-rules//tagged-values/tv" group-by="@id">
                        <tv id="{current-grouping-key()}">
                            <xsl:variable name="tv-group" select="current-group()"/>
                            <xsl:apply-templates select="imf:distinct($tv-group/name)" mode="#current"/>
                            <xsl:apply-templates select="imf:distinct($tv-group/schema-name)" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/external-schema-name)[last()]" mode="#current"/>
                        </tv>
                    </xsl:for-each-group>
                </name-value-mapping>
            </schema-rules>

            <tagset>
                <xsl:variable name="tagset" select="tagset"/> 
                <xsl:apply-templates select="imf:distinct($tagset/name)" mode="#current"/>
                <xsl:apply-templates select="imf:distinct($tagset/desc)" mode="#current"/>
                
                <tagged-values>
                    <xsl:for-each-group select="$tagset//tagged-values/tv" group-by="@id">
                        <tv id="{current-grouping-key()}">
                            <xsl:variable name="tv-group" select="current-group()"/>
                            <xsl:apply-templates select="($tv-group/@norm)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/@rules)[last()]" mode="#current"/>
                            
                            <!-- hier: de laatste naam binnen dezelfde taal? we moeten af van synoniemen. -->
                            <xsl:apply-templates select="imf:distinct($tv-group/name)" mode="#current"/>
                            
                            <xsl:apply-templates select="$tv-group/desc" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/derive)[last()]" mode="#current"/>
                            <xsl:apply-templates select="($tv-group/inherit)[last()]" mode="#current"/>
                            <stereotypes>
                                <xsl:for-each-group select="$tv-group/stereotypes/stereo" group-by=".">
                                    <xsl:variable name="stereo-group" select="current-group()"/>
                                    <xsl:apply-templates select="$stereo-group[last()]" mode="#current"/>
                                </xsl:for-each-group>
                            </stereotypes>                                
                            <declared-values> <!-- TOD must also take @lang in to account -->
                                <xsl:for-each-group select="$tv-group/declared-values/value" group-by=".">
                                    <xsl:variable name="dec-group" select="current-group()"/>
                                    <xsl:apply-templates select="$dec-group[last()]" mode="#current"/>
                                </xsl:for-each-group>
                            </declared-values>
                        </tv>
                    </xsl:for-each-group>
                </tagged-values>
            </tagset>
        </config>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="finish-config">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:distinct" as="element()*">
        <xsl:param name="elms" as="element()*"/>
        <xsl:for-each-group select="$elms" group-by="concat(string(.),@lang)">
            <xsl:sequence select="current-group()[last()]"/>
        </xsl:for-each-group>
    </xsl:function>
    
</xsl:stylesheet>
