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
        Concrete schema's may depend on other schema's, often passed on by their internet URL location.
        Project owner may decide to pass a copy of these schema's for the convenience of the user, as part of the schema 
        distribution. 
        This stylesheet adds information on schema dependencies of these external schemas.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="local-schema-mapping-file" select="imf:get-config-string('properties','LOCAL_SCHEMA_MAPPING_FILE')"/>
    <xsl:variable name="local-schema-mapping" select="imf:document($local-schema-mapping-file)/local-schemas"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:create-output-element('imvert:local-schema-svn-id',$local-schema-mapping/svn-id)"/>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <!-- compute schema dependencies of all packages in this release; remove possible doubles -->
            <imvert:local-schemas>
                <xsl:variable name="schema-dependencies" as="xs:string*">
                    <xsl:apply-templates select="imvert:package" mode="schema-dependencies"/>
                </xsl:variable>
                <xsl:for-each-group select="$schema-dependencies" group-by="string(.)">
                    <imvert:local-schema>
                        <xsl:value-of select="current-grouping-key()"/>
                    </imvert:local-schema>
                </xsl:for-each-group>
            </imvert:local-schemas>
            <!-- copy without adaptations -->
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="schema-dependencies">
        <xsl:choose>
            <xsl:when test="empty(imvert:namespace)">
                <xsl:sequence select="imf:msg(.,'ERROR','Namespace is missing.',())"/>
            </xsl:when>
            <xsl:when test="empty(imvert:version)">
                <xsl:sequence select="imf:msg(.,'ERROR','Version is missing.',())"/>
            </xsl:when>
            <xsl:when test="empty(imvert:release)">
                <xsl:sequence select="imf:msg(.,'ERROR','Release is missing.',())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="schemafolder" select="imf:get-schema-foldername(imvert:namespace,imvert:version,imvert:release)"/>
                <!-- if this is an imported external package, include in the list --> 
                <xsl:if test="imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-external-package','stereotype-name-system-package'))">
                    <xsl:value-of select="$schemafolder"/>
                </xsl:if>
                <!-- if this requires other external schemas, include them here --> 
                <xsl:for-each select="$local-schema-mapping/local-schema[@schemafolder=$schemafolder]">
                    <xsl:for-each select="depends-on">
                        <xsl:value-of select="@schemafolder"/>
                    </xsl:for-each>
                </xsl:for-each>        
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="*" mode="#default schema-dependencies">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
