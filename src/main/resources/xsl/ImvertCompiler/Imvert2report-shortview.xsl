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

    <xsl:template match="imvert:packages" mode="shortview">

        <xsl:if test="imf:boolean(imf:get-config-string('cli','reportshortview','no'))">
            
            <!-- preprare the reportrules info -->
            <xsl:variable name="domain-packages" select="root()//imvert:package[imvert:stereotype/@id = (
                'stereotype-name-domain-package',
                'stereotype-name-view-package')]"/>
            
            <xsl:sequence select="imf:set-config-string('appinfo','count-domain-packages', count($domain-packages))"/>
            <xsl:sequence select="imf:set-config-string('appinfo','count-domain-classes', count($domain-packages/imvert:class))"/>
            <xsl:sequence select="imf:set-config-string('appinfo','count-domain-attributes', count($domain-packages/imvert:class/*/imvert:attribute))"/>
            <xsl:sequence select="imf:set-config-string('appinfo','count-domain-associations', count($domain-packages/imvert:class/*/imvert:association))"/>
            
            <!-- build the page -->
            <xsl:variable name="title">Short view</xsl:variable>
            <page>
                <title>Short view</title>
                <intro/>
                <content>
                    <div>
                        <h1>Object types</h1>
                        <p>
                            This table reports on object types, attributes and some properties of these constructs.
                            The view is originally defined by BRO, and intended to load into a spreadsheet.
                        </p>
                        <p>
                            For each construct the following is specified:
                        </p>
                        <ul>
                            <li>Name (Naam)</li>
                            <li>Multiplicity</li>
                            <li>Type (Waarde)</li>
                            <li>Definition (Definitie)</li>
                            <li>Rules (Regels)</li>
                            <li>Description (Toelichting)</li>
                            <li>Remarks (Opmerkingen) (empty, for convenience)</li>
                        </ul>
                        <table>
                            <xsl:apply-templates select="$domain-packages" mode="shortview-objecttype">
                                <xsl:with-param name="stereotype-id">stereotype-name-objecttype</xsl:with-param>
                            </xsl:apply-templates>
                        </table>
                    </div>
                    
                    <div>
                        <h1>Groups</h1>
                        <p>
                            This table reports on "gegevensgroeptype" types, attributes and some properties of these constructs.
                        </p>
                        <xsl:apply-templates select="$domain-packages" mode="shortview-objecttype">
                            <xsl:with-param name="stereotype-id">stereotype-name-composite</xsl:with-param>
                        </xsl:apply-templates>
                    </div>
                    
                    <div class="intro">
                        <h1>Value lists</h1>
                        <p>
                            This table reports on value lists.
                            The view is originally defined by BRO, and intended to load into a spreadsheet.
                        </p>
                        <p>
                            For each construct the following is specified:
                        </p>
                        <ul>
                            <li>Name or value (Naam)</li>
                            <li>IMBRO</li>
                            <li>IMBRO/A (archived)</li>
                            <li>Definition (Definitie)</li>
                            <li>Description (Omschrijving)</li>
                        </ul>
                        <table>
                            <xsl:apply-templates select="$domain-packages" mode="shortview-valuelist"/>
                        </table>
                    </div>
                </content>
            </page>        
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="shortview-objecttype">
        <xsl:param name="stereotype-id"/>
        <table class="tablesorter"> 
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = $stereotype-id]" mode="#current"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'Naam:20,Mult:5,Waarde:15,Definitie:15,Regels:15,Toelichting:15,Opmerkingen:15','table-shortview-objecttypes')"/>
        </table>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="shortview-objecttype">
        <tr class="shortviewHeader">
            <td>
                <xsl:value-of select="imf:get-display-name(.)"/>
            </td>
            <td><!-- empty by design --></td>
            <td><!-- empty by design --></td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DEFINITION')"/>
            </td>
            <td><!-- empty by design --></td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DESCRIPTION')"/>
            </td>
            <td><!-- empty by design --></td>
        </tr>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="#current"/>
    </xsl:template>
  
  
    <xsl:template match="imvert:attribute" mode="shortview-objecttype">
        <tr>
            <td>
                <xsl:value-of select="imf:get-display-name(.)"/>
            </td>
            <td>
                <xsl:if test="not(imvert:min-occurs = '1') or not(imvert:max-occurs = '1')">
                    <xsl:value-of select="imvert:min-occurs"/>
                    ..
                    <xsl:value-of select="imvert:max-occurs"/>
                </xsl:if>
            </td>   
            <td>
                <xsl:value-of select="imvert:type-name/@original"/>
            </td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DEFINITION')"/>
            </td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-RULES')"/>
            </td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DESCRIPTION')"/>
            </td>
            <td><!-- empty by design --></td>
            
        </tr>
    </xsl:template>
    
    <xsl:template match="imvert:package" mode="shortview-valuelist">
        <table class="tablesorter"> 
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = 'stereotype-name-enumeration']" mode="#current"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-result-table-by-tr($rows,'Naam:30,IMBRO:5,IMBRO/A:5,Definitie:30,Omschrijving:30','table-shortview-valuelists')"/>
        </table>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="shortview-valuelist">
        <tr class="shortviewHeader">
            <td>
                <xsl:value-of select="imvert:name/@original"/>
            </td>
            <td><!-- empty by design --></td>
            <td><!-- empty by design --></td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DEFINITION')"/>
            </td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DESCRIPTION')"/>
            </td>
        </tr>
        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="#current"/>
    </xsl:template>

    <xsl:template match="imvert:attribute" mode="shortview-valuelist">
        <tr>
            <td>
                <xsl:value-of select="imvert:name/@original"/>
            </td>
            <td>
                <!-- imbro -->
            </td>
            <td>
                <!-- imbro -->
            </td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DEFINITION')"/>
            </td>
            <td>
                <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DESCRIPTION')"/>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
