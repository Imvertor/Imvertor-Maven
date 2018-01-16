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
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    <xsl:import href="Imvert2XSD-KING-common-migrate.xsl"/>
    
    <!-- 
       Migreer het MIM metamodel voor logische modellen naar het MBG, voor aansluiting op de StUF straat voor schema's.
     
       Doe dit alleen als het metamodel niet KINGBSM is (of bevat).
    -->
    
    <xsl:template match="/imvert:packages">
        <xsl:choose>
            <xsl:when test="not(tokenize(imvert:metamodel,';') = 'KINGBSM')">
                <xsl:comment>Migration to BSM performed for StUF alignment</xsl:comment>
                <xsl:apply-templates select="." mode="migrate"/>    
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>No migration required, identity transform</xsl:comment>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
</xsl:stylesheet>
