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
        Generate a file that lists package dependencies.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <!-- get all imvert:packages elements that represent a supplier for this package -->
    <xsl:variable name="suppliers" select="/imvert:packages/imvert:supplier"/>
    <xsl:variable name="supplier-packages" select="for $supplier in $suppliers return imf:get-trace-supplier-document(imf:get-trace-supplier-subpath($supplier))"/>
    <xsl:variable name="supplier-subpaths" select="string-join(for $s in ($supplier-packages) return imf:get-trace-supplier-subpath($s/imvert:project, $s/imvert:application, $s/imvert:release),', ')"/>
    
    <xsl:template match="/">
        <root>
            <xsl:choose>
                <xsl:when test="exists($suppliers) and $validate-trace-full">
                    <xsl:apply-templates/>
                    <xsl:value-of select="'Traced and checked'"/>
                </xsl:when>
                <xsl:when test="exists($suppliers)">
                    <xsl:value-of select="'Traced but not checked'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Not traced and not checked'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:for-each select="$supplier-packages">
                <xsl:variable name="subpath" select="imf:get-trace-supplier-subpath(imvert:project, imvert:application, imvert:release)"/>
                <xsl:variable name="errors" select="xs:integer((imvert:process/imvert:errors,0)[1])"/>
                <xsl:variable name="warnings" select="xs:integer((imvert:process/imvert:warnings,0)[1])"/>
                <xsl:variable name="phase" select="xs:integer((imvert:phase,0)[1])"/>
                
                <xsl:sequence select="imf:report-error(., 
                    $errors != 0,
                    'The supplier [1] has [2] errors. You may not derive from that model.',($subpath,$errors))"/>
                <xsl:sequence select="imf:report-warning(., 
                    $warnings != 0,
                    'The supplier [1] has [2] warnings. Are you sure you want to derive from that model?',($subpath,$warnings))"/>
                <xsl:sequence select="imf:report-warning(., 
                    $phase != (2,3),
                    'The supplier [1] is in phase [2]. Are you sure you want to derive from that model?',($subpath,imvert:phase/(@original|text())[1]))"/>
    
            </xsl:for-each>
        </root>
    </xsl:template>
        
    <!-- check if the construct is in a derived package and if so, if it has a trace --> 
    <xsl:template match="imvert:class | imvert:attribute | imvert:association">
        <xsl:variable name="this" select="."/>
        <xsl:for-each select="$this/imvert:trace">
            <xsl:variable name="trace-id" select="."/>        
            <xsl:variable name="trace-construct" select="imf:get-trace-construct-by-id(..,$trace-id,$supplier-packages)"/>        
            
            <xsl:sequence select="imf:report-warning($this, 
                $validate-trace-full and empty($trace-id),
                'This construct should be derived (but is not)',())"/>
            
            <xsl:sequence select="imf:report-warning($this, 
                $validate-trace-full and exists($trace-id) and empty($trace-construct),
                'This construct is not derived from a known construct in (any of) the supplier(s) [1]',($supplier-subpaths))"/>
        </xsl:for-each>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>
