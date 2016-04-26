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
          Transform KING UML constructs to canonical UML constructs.
          This applies to the BSM.
    -->
    
    <xsl:import href="Imvert2canonical-KING-common.xsl"/>
   
    <xsl:variable name="koppelvlak-package" select="$document-packages[imvert:name/@original = $application-package-name and imvert:stereotype = imf:get-config-stereotypes('stereotype-name-application-package')][1]"/>
    <xsl:variable name="bericht-packages" select="$koppelvlak-package//imvert:package[imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))]"/>
    <xsl:variable name="bericht-classes" select="$bericht-packages//imvert:class"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- TODO ik kopieer de release van het koppelvlak door naar de berichten. dat moet eigenlijk niet; de release van het koppelvlak is de release van de berichten dus overbodig. Maar validatie is nog generiek. -->
    <xsl:template match="imvert:package[. = $bericht-packages]">
        <xsl:copy>
            <xsl:sequence select="(ancestor::imvert:package/imvert:release)[1]"/>
            <xsl:apply-templates select="*[empty(self::imvert:package)]"/>
            <xsl:apply-templates select="imvert:package" mode="remove-stereotypes"/>
        </xsl:copy>
    </xsl:template>
 
    <!-- TODO ik verwijder domein, dat is overgekopieerd vanuit UGM. Maar alle packages zijn 1 niveau naar beneden gedrukt.. -->
    <xsl:template match="imvert:package" mode="remove-stereotypes">
        <xsl:copy>
            <xsl:apply-templates select="*[empty(self::imvert:stereotype)]"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
