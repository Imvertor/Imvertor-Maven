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
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ekf="http://EliotKimber/functions"

    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <!-- 
        This stylesheet pre-processes the UML in accordance with 10-129r1_Geography_Markup_Language_GML_Version_3.3.pdf 
          
        This is:
          
        1/ 12.3 change association classes to regular classes.
          
    -->
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <!--
        10-129r1_Geography_Markup_Language_GML_Version_3.3.pdf 
        12.3.2
        
        Before applying the GML encoding rule, any UML association class shall be transformed
        as follows (in the following description the source class of the association is called S and
        the target class is called T):
        - The association class A is transformed into a regular class with the same name,
        stereotype, tagged values, constraints, attributes, relationships.
        - The association is replaced by two associations, one from S to A ("SA") and one from
        A to T ("AT").
        - The characteristics of the association end (in particular role name, navigability,
        multiplicity, documentation) of the original association class at T are used for
        association ends at A of SA and at T of AT with the exception that the multiplicity at
        the association end at T of association AT is set to 1.
        - The characteristics of the association end of the original association class at S are
        used for association ends at S of SA and at A of AT with the exception that the
        multiplicity at the association end at S of association SA is set to 1.
     -->
    
    <xsl:variable name="all-association-class-id" select="$document//imvert:association-class/imvert:type-id"/>
    
    <xsl:template match="imvert:class[imvert:id = $all-association-class-id]">
        <xsl:variable name="this" select="."/>
        <xsl:variable name="association" select="$imvert-document//imvert:association[imvert:association-class/imvert:type-id = $this/imvert:id]"/>
        <imvert:class>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()[empty((self::imvert:associations,self::imvert:stereotype))]"/>
            <imvert:stereotype id="stereotype-name-objecttype">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-objecttype')"/>
            </imvert:stereotype>
            <imvert:associations>
                <xsl:apply-templates select="imvert:associations/imvert:association"/>
                <!-- en voeg de nieuwe uitgaande relatie toe -->
                <imvert:association>
                    <xsl:apply-templates select="$association/@*"/>
                    <xsl:apply-templates select="$association/node()[empty((self::imvert:min-occurs,self::imvert:max-occurs))]"/>
                    <imvert:min-occurs>1</imvert:min-occurs>
                    <imvert:max-occurs>1</imvert:max-occurs>
                </imvert:association>
            </imvert:associations>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:associations/imvert:association/imvert:association-class]">
        <xsl:variable name="this" select="."/>
        <xsl:variable name="associations" select="imvert:associations/imvert:association[imvert:association-class]"/>
        <imvert:class>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()[empty(self::imvert:associations)]"/>
            <imvert:associations>
                <xsl:for-each select="imvert:associations/imvert:association">
                    <imvert:association>
                        <xsl:apply-templates select="@*"/>
                        <xsl:choose>
                            <xsl:when test=". = $associations">
                                <!-- omleggen naar de associatieklasse -->
                                <xsl:apply-templates select="node()[empty((self::imvert:association-class,self::imvert:type-name,self::imvert:type-id,self::imvert:type-package))]"/>
                                <xsl:apply-templates select="imvert:association-class/imvert:type-name"/>
                                <xsl:apply-templates select="imvert:association-class/imvert:type-id"/>
                                <xsl:apply-templates select="imvert:association-class/imvert:type-package"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="node()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </imvert:association>
                </xsl:for-each>
            </imvert:associations>
        </imvert:class>
        
    </xsl:template>
    
    <!-- Jira http://ota-portal.so.kadaster.nl/jira/browse/IM-556 -->
    
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-domain-package']">
        <xsl:variable name="tv-featurecollection" select="imf:get-tagged-value(.,'##CFG-TV-FEATURECOLLECTION')"/>
        <xsl:variable name="el-featurecollection" select="imf:class[imvert:stereotype/@id = 'stereotype-name-featurecollection']"/>
        
        <xsl:choose>
            <xsl:when test="exists($tv-featurecollection) and exists($el-featurecollection)">
                <xsl:sequence select="imf:report-error(.,true(),'Feature collections should have a [1] tagged value or a [2] class, but not both',
                    (imf:get-config-name-by-id('CFG-TV-FEATURECOLLECTION'),imf:get-config-name-by-id('stereotype-name-featurecollection')))"/>
            </xsl:when>
            <xsl:when test="exists($tv-featurecollection)">
                <!-- transform to method B -->
                <xsl:copy>
                    <xsl:apply-templates select="*"/>
                    <imvert:class display-name="STUB"
                        formal-name="STUB">
                        <imvert:name original="{$tv-featurecollection}"><xsl:value-of select="$tv-featurecollection"/></imvert:name>
                        <imvert:id>FC_<xsl:value-of select="generate-id(.)"/></imvert:id>
                        <imvert:designation>class</imvert:designation>
                        <imvert:stereotype id="stereotype-name-featurecollection">OBJECTVERZAMELING</imvert:stereotype>
                        <imvert:associations>
                            <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = 'stereotype-name-objecttype']" mode="featuremember"/>
                        </imvert:associations>
                    </imvert:class>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="featuremember">
        <imvert:association display-name="STUB.featureMember (assoc)"
            formal-name="STUB"
            type-display-name="{imf:get-display-name(.)}"
            type-formal-name="STUB">
            <imvert:name original="featureMember">featureMember</imvert:name>
            <imvert:id>FM_<xsl:value-of select="generate-id(.)"/></imvert:id>
            <imvert:type-name original="{imvert:name/@original}"><xsl:value-of select="imvert:name"/></imvert:type-name>
            <imvert:type-id><xsl:value-of select="imvert:id"/></imvert:type-id>
            <imvert:type-package><xsl:value-of select="../imvert:name"/></imvert:type-package>
            <imvert:min-occurs>0</imvert:min-occurs>
            <imvert:max-occurs>unbounded</imvert:max-occurs>
            <imvert:min-occurs-source>1</imvert:min-occurs-source>
            <imvert:max-occurs-source>1</imvert:max-occurs-source>
            <imvert:position original="200">200</imvert:position>
            <imvert:source>
                <imvert:navigable>false</imvert:navigable>
            </imvert:source>
            <imvert:target>
                <imvert:stereotype id="stereotype-name-relation-role"><xsl:value-of select="imf:get-config-name-by-id('stereotype-name-relation-role')"/></imvert:stereotype>
                <imvert:role original="featureMember">featureMember</imvert:role>
                <imvert:navigable>true</imvert:navigable>
            </imvert:target>
        </imvert:association>
        
    </xsl:template>
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
