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
    xmlns:functx="http://www.functx.com"
    
    xmlns:StUF="http://www.stufstandaarden.nl/onderlaag/stuf0302"
    xmlns:metadata="http://www.stufstandaarden.nl/metadataVoorVerwerking" 
   
    xmlns:gml="http://www.opengis.net/gml"
    
    exclude-result-prefixes="xsl UML imvert imvert ekf"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
     <xsl:output indent="yes" method="xml" encoding="UTF-8" exclude-result-prefixes="#all"/>
    
    <xsl:variable name="stylesheet-code">BESSUB</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>

    <xsl:variable name="must-apply-restrictions" select="imf:boolean(imf:get-config-string('cli','sys_createxsdrestrictions','false'))"/>
    
    <xsl:template match="/schemas">
        <xsl:sequence select="imf:track('Postforming schemas',())"/>
        
        <xsl:next-match/>
        
        <!-- pass info to the final steps -->
        
        <xsl:sequence select="imf:set-config-string('appinfo','xsd-is-subset',.//imvert:is-subsetting = 'true')"/>
        
    </xsl:template>
    
    <xsl:template match="schema">
        <xsl:next-match/> <!-- pass on all info stored in the root element -->
    </xsl:template>
    
    <!-- ============== resolve markers ================= -->
    
    <xsl:template match="xs:complexType">
        <xsl:variable name="is-subsetting" select="exists(../imvert:subset-info)"/>
        <xsl:variable name="is-subset" select="imf:boolean(../imvert:subset-info/imvert:is-subset-class)"/>
        <xsl:variable name="is-restriction" select="imf:boolean(../imvert:subset-info/imvert:is-restriction-class)"/>
        
        <xsl:variable name="supplier-prefix" select="../imvert:subset-info/imvert:supplier-prefix"/>
        <xsl:variable name="supplier-label" select="../imvert:subset-info/imvert:supplier-label"/>
       
        <xsl:variable name="is-matchgegevens" select="ends-with(@name,'matchgegevens')"/>
        
        <xsl:choose>
            <xsl:when test="not($is-subsetting)">
                <!-- het hele mechanisme van subsetting speelt niet want geen UGM dat teruggaat op UGM -->
                <xsl:next-match/>
            </xsl:when>
           <xsl:when test="$is-restriction and not($must-apply-restrictions)">
               <xsl:sequence select="imf:create-debug-comment(concat('A subset and restriction class, but cli/sys_createxsdrestrictions is false, so do not restrict: ', @name))"/>
               <xsl:next-match/>
           </xsl:when>
           <xsl:when test="$is-restriction and $is-matchgegevens">
               <xsl:sequence select="imf:create-debug-comment(concat('Matchgegevens, so do not restrict: ', @name))"/>
               <xsl:next-match/>
           </xsl:when>
           <xsl:when test="$is-restriction">
                <xsl:sequence select="imf:create-debug-comment(concat('A subset and restriction class: ', @name))"/>
                <xs:complexType name="{@name}">
                    <xs:complexContent>
                        <xs:restriction base="{$supplier-prefix}:{$supplier-label}-basis">
                            <!-- om dat heten restrictie betreft moet alles worden omgezet naar de supplier namespace. -->
                            <xsl:apply-templates mode="subset-supplier"/>
                        </xs:restriction>
                    </xs:complexContent>
                </xs:complexType>        
            </xsl:when>
            <xsl:when test="$is-subset"> 
                <xsl:sequence select="imf:create-debug-comment(concat('A subset class but not a restriction class, so remove: ', @name))"/>
                <!-- remove this -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment(concat('Not a subset class: ', @name))"/>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="subset-class-marker">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="imvert:subset-info">
        <!-- skip -->
    </xsl:template>
    
    <!-- vervang de prefix door de supplier prefix -->
    <xsl:template match="xs:element/@type" mode="subset-supplier">
        <xsl:variable name="supplier-prefix" select="ancestor::subset-class-marker[last()]/imvert:subset-info/imvert:supplier-prefix"/>
        <xsl:variable name="type" select="substring-after(.,':')"/>
        <xsl:attribute name="type" select="concat($supplier-prefix,':',$type)"/>
    </xsl:template>
    <xsl:template match="xs:attribute/@ref" mode="subset-supplier">
        <xsl:variable name="supplier-prefix" select="ancestor::subset-class-marker[last()]/imvert:subset-info/imvert:supplier-prefix"/>
        <xsl:variable name="type" select="substring-after(.,':')"/>
        <xsl:attribute name="ref" select="concat($supplier-prefix,':',$type)"/>
    </xsl:template>
    
    <xsl:template match="imvert:dummy"/>
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
