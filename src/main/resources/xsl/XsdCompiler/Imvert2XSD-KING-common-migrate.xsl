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
    
    <!-- 
       Migreer het MIM metamodel voor logische modellen naar het MUG/MBG, voor aansluiting op de StUF straat voor schema's.
       
       Dit is:
       
       mode=groep
           omzetten van groepen
           
       mode=
    -->
    
    <xsl:template match="/imvert:packages" mode="migrate">
      
        <!-- 
            zet gegevensgroep om naar een groepcompositie, omdat algoritme daarvan uit gaat 
        -->
        <xsl:variable name="result-groep" as="node()*">
            <xsl:apply-templates select="." mode="migrate-groep"/>
        </xsl:variable>
        
        <!-- 
            zet rollen om naar relaties, omdat algoritme daarvan uit gaat 
        -->
        <xsl:variable name="result-rol" as="node()*">
            <xsl:apply-templates select="$result-groep" mode="migrate-role"/>
        </xsl:variable>
        
        <xsl:sequence select="$result-rol"/>
        
    </xsl:template>
    
    <!-- 
        Zet gegevensgroepen om naar composities
    -->
    <xsl:template match="imvert:class" mode="migrate-groep">
        <xsl:variable name="groepen" as="element(imvert:association)*">
            <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype/@id = ('stereotype-name-attributegroup')]" mode="#current"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="*[empty(self::imvert:attributes) and empty(self::imvert:associations) and empty(self::imvert:stereotype)]" mode="#current"/>
        
            <!-- verplaats gegevensgroep naar compositie relatie -->
            <imvert:attributes>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute[not(imvert:stereotype/@id = ('stereotype-name-attributegroup'))]" mode="#current"/>
            </imvert:attributes>
            <imvert:associations>
                 <xsl:apply-templates select="imvert:associations/imvert:association" mode="#current"/> 
                <!-- plus de nieuwe groep att omgezet naar compositie -->
                <xsl:sequence select="$groepen"/>
            </imvert:associations>
           
            <!-- vervang stereotype naam -->
            <xsl:for-each select="imvert:stereotype">
                <xsl:choose>
                    <xsl:when test="./@id = ('stereotype-name-composite')">
                        <imvert:stereotype id="stereotype-name-composite">GROEP</imvert:stereotype>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="#current"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
        
    <!-- 
        zet een groepsattribuut om naar een compositie associatie 
    -->
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = ('stereotype-name-attributegroup')]" mode="migrate-groep">
        <imvert:association>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:comment>Created as a stub for StUF alignment: stereotypes renamed, traces removed</xsl:comment>
            <xsl:apply-templates select="*[
                empty(self::imvert:stereotype) and 
                empty(self::imvert:trace) and
                empty(self::imvert:aggregation)]" mode="#current"/>
            
            <imvert:aggregation>composite</imvert:aggregation>
            
            <!-- ID in trace must be replaced by an underscore format (attributes are {X-Y-Z}, associations are X_Y_Z format) -->
            <xsl:for-each select="imvert:trace">
                <xsl:sequence select="."/>
                <xsl:comment select="concat('Trace okay?, cannot yet trace from association to attribute: ', .)"/>
            </xsl:for-each>
            
            <!-- and set the stereotype -->
            <imvert:stereotype id="stereotype-name-association-to-composite">GROEP COMPOSITIE</imvert:stereotype>
        </imvert:association>      
    </xsl:template>
        
    <!-- 
        zet een rol om naar een associatie, maar niet als het een zojuist opgebouwde compositie relatie is 
    -->
    <xsl:template match="imvert:association[not(imvert:stereotype/@id = (
        'stereotype-name-association-to-composite',
        'stereotype-name-entiteitrelatie',
        'stereotype-name-berichtrelatie'))]" mode="migrate-role">
      
        <imvert:association>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()[
                empty(self::imvert:name) and 
                empty(self::imvert:source) and 
                empty(self::imvert:target) and 
                empty(self::imvert:tagged-values)]" mode="#current"/>
            
            <xsl:comment>Created as a stub for StUF alignment: moved role info to association</xsl:comment>
            
            <!-- plaats de rol naam als de naam van de associatie -->
            <xsl:choose>
                <xsl:when test="imvert:target/imvert:role">
                    <xsl:apply-templates select="imvert:target/imvert:role" mode="#current"/>
                </xsl:when>
                <xsl:otherwise>  <!-- TODO mag niet in MIM, relatie rollen worden gevolgd. -->
                    <xsl:apply-templates select="imvert:name" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- zet het stereotype -->
            <imvert:stereotype id="stereotype-name-relatiesoort">RELATIE</imvert:stereotype>
            
            <!-- set the full set of tagged values on the relation itself; avoid duplicates -->
            <xsl:variable name="tagged-values" select="(imvert:target/imvert:tagged-values/imvert:tagged-value, imvert:tagged-values/imvert:tagged-value)"/>
            <imvert:tagged-values>
                <xsl:for-each-group select="$tagged-values" group-by="concat(@id,imvert:value)">
                    <xsl:apply-templates select="current-group()[1]" mode="#current"/>
                </xsl:for-each-group>            </imvert:tagged-values>
            
            <!-- TODO is-id? -->
            
        </imvert:association>
    </xsl:template>
    
    <xsl:template match="imvert:target/imvert:role" mode="migrate-role">
        <imvert:name original="{@original}">
            <xsl:value-of select="."/>
        </imvert:name>    
    </xsl:template>
  
    <!-- =========== common ================== -->
    
    <xsl:template match="node()|@*" mode="migrate-groep migrate-role migrate-names">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
