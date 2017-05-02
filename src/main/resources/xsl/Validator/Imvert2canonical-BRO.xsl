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
          Transform BP UML constructs to canonical UML constructs.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- generate the correct name here -->
    <xsl:template match="imvert:found-name">
        <xsl:variable name="type" select="
            if (parent::imvert:package) then 'package-name' else 
            if (parent::imvert:attribute) then 'property-name' else
            if (parent::imvert:association) then 'property-name' else 'class-name'"/>
        <imvert:name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,$type)"/>
        </imvert:name>
    </xsl:template>
    
    <xsl:template match="imvert:supplier-packagename">
        <imvert:supplier-package-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:supplier-package-name>
    </xsl:template>
    
    <!-- generate the correct name for types specified, but only when the type is declared as a class (i.e. no system types) -->
    <xsl:template match="imvert:*[imvert:type-id]/imvert:type-name">
        <imvert:type-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'class-name')"/>
        </imvert:type-name>
    </xsl:template>
    
    <!-- generate the correct name for packages of types specified -->
    <xsl:template match="imvert:type-package">
        <imvert:type-package original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:type-package>
    </xsl:template>
    
    <!-- when composition, and no name, generate name of the target class on that composition relation -->
    <!-- 
        KKG ISO doesnt require composition relation stereotype.
        when composition, and no stereotype, put the composition stereotype there -->
    <xsl:template match="imvert:association[imvert:aggregation='composite']">
        <imvert:association>
            <xsl:choose>
                <xsl:when test="empty(imvert:found-name)">
                    <imvert:name original="" origin="system">
                        <xsl:value-of select="imf:get-normalized-name(imvert:type-name,'property-name')"/>
                    </imvert:name>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:found-name"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="empty(imvert:stereotype)">
                    <imvert:stereotype origin="system">
                        <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-association-to-composite')"/>
                    </imvert:stereotype>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:stereotype"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[not(self::imvert:stereotype or self::imvert:found-name)]"/>
        </imvert:association>
    </xsl:template>
    
    <xsl:template match="imvert:phase">
        <xsl:variable name="original" select="normalize-space(lower-case(.))"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="original" select="$original"/>
            <xsl:choose>
                <xsl:when test="$original='1.0'">1</xsl:when> 
                <xsl:when test="$original='concept'">0</xsl:when> 
                <xsl:when test="$original='draft'">1</xsl:when> 
                <xsl:when test="$original='finaldraft'">2</xsl:when> 
                <xsl:when test="$original='final draft'">2</xsl:when> 
                <xsl:when test="$original='final'">3</xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="$original"/>
                </xsl:otherwise> 
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

<?x
    <!-- temporary map from KKG to KK -->
    
    <xsl:template match="imvert:baretype">
        
        <xsl:choose>
            <xsl:when test=". = 'REAL'"> 
                <imvert:baretype original="Real">N20,10</imvert:baretype>
                <imvert:type-name>scalar-decimal</imvert:type-name>
                <imvert:total-digits>20</imvert:total-digits>
                <imvert:fraction-digits>10</imvert:fraction-digits>
            </xsl:when>
            <xsl:when test=". = 'CHARACTERSTRING'">
                <imvert:baretype original="CharacterString">AN</imvert:baretype>
                <imvert:type-name>scalar-string</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'BOOLEAN'">
                <imvert:baretype original="Boolean">INDIC</imvert:baretype>
                <imvert:type-name>scalar-boolean</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'INTEGER'">
                <imvert:baretype original="Integer">N100</imvert:baretype>
                <imvert:type-name>scalar-integer</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'DATE'">
                <imvert:baretype original="Date">DATUM</imvert:baretype>
                <imvert:type-name>scalar-date</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'DATETIME'">
                <imvert:baretype original="DateTime">DT</imvert:baretype>
                <imvert:type-name>scalar-datetime</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'YEAR'">
                <imvert:baretype original="Year">YEAR</imvert:baretype>
                <imvert:type-name>scalar-year</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'MONTH'">
                <imvert:baretype original="Month">MONTH</imvert:baretype>
                <imvert:type-name>scalar-month</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'DAY'">
                <imvert:baretype original="Day">DAY</imvert:baretype>
                <imvert:type-name>scalar-day</imvert:type-name>
            </xsl:when>
            <xsl:when test=". = 'URI'">
                <imvert:baretype original="URI">URI</imvert:baretype>
                <!--<imvert:type-name>scalar-uri</imvert:type-name>-->
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:sequence select="."/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
x?>    
    
    <?x
    <!-- mapping KKG -->
    
    <xsl:template match="imvert:class[empty(imvert:stereotype)]">
        <imvert:class>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="false()">
                    <!-- test of deze klasse als target van een compositie relatie voorkomt -->
                </xsl:when>
                <xsl:when test="true()">
                    <imvert:stereotype premap="">OBJECTTYPE</imvert:stereotype>
                </xsl:when>
            </xsl:choose>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[empty(imvert:stereotype)]">
        <imvert:attribute>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="false()">
                    <!-- test of dit een data element is  -->
                </xsl:when>
                <xsl:when test="true()">
                    <imvert:stereotype premap="">ATTRIBUUTSOORT</imvert:stereotype>
                </xsl:when>
            </xsl:choose>
        </imvert:attribute>
    </xsl:template>
    
    <xsl:template match="imvert:association[empty(imvert:stereotype)]">
        <imvert:attribute>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="false()">
                    <!-- test of dit een compositie relatie  is  -->
                </xsl:when>
                <xsl:when test="true()">
                    <imvert:stereotype premap="">RELATIESOORT</imvert:stereotype>
                </xsl:when>
            </xsl:choose>
        </imvert:attribute>
    </xsl:template>
    
    <xsl:template match="imvert:stereotype">
        <xsl:variable name="construct" select="parent::imvert:*"/>
        <imvert:stereotype premap="{.}"> 
            <xsl:choose>
                <xsl:when test=". = 'FEATURETYPE'">OBJECTTYPE</xsl:when>
                <xsl:when test=". = 'DATATYPE'">COMPLEX DATATYPE</xsl:when>
                <xsl:when test=". = 'TYPE'">DATATYPE</xsl:when>
                <xsl:when test=". = 'PROPERTY'">ATTRIBUUTSOORT</xsl:when>
                <xsl:when test=". = 'CODEDVALUEDOMAIN'">COMPLEX DATATYPE</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </imvert:stereotype>
    </xsl:template>

x?>
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
  
</xsl:stylesheet>
