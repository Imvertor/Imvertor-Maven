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
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcat="http://www.w3.org/ns/dcat#"
    xmlns:rschema="http://www.w3.org/2000/01/rdf-schema#"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!-- 
          Introduce lists.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="includedoclist" select="imf:boolean(imf:get-config-string('cli','includedoclist'))"/>
    <xsl:variable name="doclist-xml-url" select="imf:get-config-parameter('doclist-xml-url',false())"/>
    
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$includedoclist and not($doclist-xml-url)">
                <xsl:sequence select="imf:msg($imvert-document,'ERROR','Property [1] cannot be yes when parameter [2] is not specified',('includedoclist','doclist-xml-url'))"/>
            </xsl:when>
            <xsl:when test="$owner = 'BRO'">
                <!-- TODO aanpassen initialisatie codelists....!
                    
                    dit moet beter. dit is ook al onderdeel van modeldoc zelf. de wijze waarop je bepaalt wat de LOC is van de codelist moet apart worden uitgewerkt voor iedere klant of aanpak. 
                
                -->
                    
                <xsl:variable name="configuration-registration-objects-path" select="concat(imf:get-config-string('system','inp-folder-path'),'/cfg/local/registration-objects.xml')"/>
                <xsl:variable name="configuration-registration-objects-doc" select="imf:document($configuration-registration-objects-path,true())"/>

                <!-- the abbreviation for the registration object must be set here; this is part of the path in GIT where the catalog is uploaded -->
                <xsl:variable name="namespace" select="$imvert-document/imvert:packages/imvert:base-namespace"/>
                <xsl:variable name="abbrev" select="tokenize($namespace,'/')[last()]" as="xs:string?"/>
                <xsl:variable name="object" select="$configuration-registration-objects-doc//registratieobject[abbrev = $abbrev]"/>
                
                <!--check if known. -->
                <xsl:choose>
                    <xsl:when test="empty($object)">
                        <xsl:sequence select="imf:msg($imvert-document,'ERROR','The abbreviation [1] taken from [2] is not valid',($abbrev,$namespace))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:set-config-string('appinfo','model-abbreviation',$abbrev)"/>
                       <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/><!-- TODO: no list handling yet -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- codelists that have no entries are assumed to be external, therefore try to read these entries from the TV "data location" -->
    <xsl:template match="imvert:class[
        imvert:stereotype/@id = ('stereotype-name-codelist') and empty(imvert:attributes/imvert:attribute) 
        or
        imvert:stereotype/@id = ('stereotype-name-referentielijst') 
        ]">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
             <!-- fetch the code list contents -->
            <xsl:variable name="loc" select="imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DATALOCATION')"/>
            <xsl:sequence select="imf:set-config-string('temp','latest-list-url',$loc)"/>
            <xsl:sequence select="imf:set-config-string('temp','latest-list-key',tokenize($loc,'/')[last()])"/>
           
            <xsl:variable name="referring-attributes" select="//imvert:attribute[imvert:type-id = current()/imvert:id]"/>
            <xsl:variable name="referring-attributes-loc" select="$referring-attributes[exists(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DATALOCATION'))]"/>
            <xsl:variable name="referring-attributes-noloc" select="$referring-attributes[empty(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DATALOCATION'))]"/>
            
            <xsl:choose>
                <xsl:when test="exists($loc) and exists($referring-attributes-loc)">
                    <xsl:sequence select="imf:msg(.,'WARNING','List contents specified on both attribute(s) and list. Attributes are: [1]',imf:string-group(for $a in $referring-attributes-loc return imf:get-display-name($a)))"/>
                    <!-- ignore -->
                </xsl:when>
                <xsl:when test="not($includedoclist)">
                    <!-- skip -->
                </xsl:when>
                <xsl:when test="starts-with($loc,'urn:')">
                    <!-- ignore -->
                </xsl:when>
                <xsl:when test="empty($doclist-xml-url)">
                    <xsl:sequence select="imf:msg(.,'ERROR','Owner parameter doclist-xml-url not defined',())"/>
                </xsl:when>
                <xsl:when test="normalize-space($loc)">
                    <!-- Wanneer het een URL met xmlk extensie betreft, dan integraal overnemen. Anders oplossen op basis van de doclist-xml-url. -->
                    <xsl:variable name="url" select="if (matches($loc,'^https?://.*?\.xml$','i')) then $loc else imf:merge-parms($doclist-xml-url)"/>
                    <xsl:sequence select="imf:msg(.,'DEBUG','Reading [1] entries from: [2]',(imf:get-config-stereotypes(imvert:stereotype/@id),$url))"/>
                    <xsl:variable name="xml" select="if (unparsed-text-available($url)) then document($url) else ()"/>
                    <xsl:choose>
                        <xsl:when test="exists($xml) and imvert:stereotype/@id = 'stereotype-name-codelist'">
                            <xsl:apply-templates select="$xml" mode="codelist">
                                <xsl:with-param name="construct" select="."/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="exists($xml) and imvert:stereotype/@id = 'stereotype-name-referentielijst'">
                            <xsl:apply-templates select="$xml" mode="reflist">
                                <xsl:with-param name="construct" select="."/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg(.,'WARNING','List contents cannot be retrieved from location [1], tried [2]',($loc, $url))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="exists($referring-attributes-noloc)">
                    <xsl:sequence select="imf:msg(.,'WARNING','Codelist content location not specified',())"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- specified at all attributes that reference this codelist -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
   
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>    
    
    <!-- when reading from RDF -->
    
    <xsl:template match="/rdf:RDF" mode="codelist">
        <xsl:apply-templates select="rdf:Description[rdf:type/@rdf:resource='http://www.w3.org/ns/dcat#Dataset']/dcat:theme" mode="#current">
            <xsl:with-param name="rdf" select="."/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="dcat:theme" mode="codelist">
        <xsl:param name="rdf" as="element(rdf:RDF)"/><!-- the rdf root -->
        <xsl:variable name="resource" select="@rdf:resource"/>
        <imvert:entry uri="{$resource}">
            <xsl:variable name="entry" select="$rdf/rdf:Description[@rdf:about=$resource]"/>
            <xsl:value-of select="$entry/rschema:label"/>
        </imvert:entry>
    </xsl:template>
    
    <!-- when reading from BRO XML listing -->
  
    <!-- BRO lists -->
    <xsl:template match="/(domeintabel | Waardelijst)" mode="codelist reflist">
        <xsl:param name="construct" as="element()"/>
        <imvert:attributes>
            <xsl:variable name="values" as="element()*"> <!-- imvert:attribute or imvert:refelement -->
                <xsl:apply-templates select="*" mode="#current"/>
            </xsl:variable>
            <!-- when no values found; assume the list is not defined -->
            <xsl:choose>
                <xsl:when test="exists($values)">
                    <xsl:sequence select="$values"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg($construct,'ERROR','Unknown type of entries in list (domeintabel): [1]',name(*[1]))"/>
                </xsl:otherwise>
            </xsl:choose>
        </imvert:attributes>
    </xsl:template>
  
    <!-- BRO codelists -->
 
    <xsl:template match="
          /domeintabel/Waardebepalingsmethode
        | /domeintabel/Waardebepalingstechniek
        | /domeintabel/Meetapparaat
        " mode="codelist">
        <imvert:attribute origin="system">
            <imvert:name original="{Code}">
                <xsl:value-of select="Code"/>
            </imvert:name>
            <imvert:id>
                <xsl:value-of select="concat(local-name(.),'_',ID)"/>
            </imvert:id>
            <imvert:stereotype id="stereotype-name-enum">ENUMERATIEWAARDE</imvert:stereotype>
            <xsl:if test="Kwaliteitsregime = 'IMBRO/A'">
                <imvert:stereotype id="stereotype-name-imbroa">IMBRO/A</imvert:stereotype>
            </xsl:if>
            <imvert:tagged-values>
                <imvert:tagged-value id="CFG-TV-DEFINITION">
                    <imvert:value>
                        <xsl:sequence select="Omschrijving/node()"/>
                    </imvert:value>
                </imvert:tagged-value>
            </imvert:tagged-values>
        </imvert:attribute>
    </xsl:template>
    
    <xsl:template match="domeintabel/OeverType" mode="codelist">
        <imvert:attribute origin="system">
            <imvert:name original="{ID}">
                <xsl:value-of select="ID"/>
            </imvert:name>
            <imvert:id>
                <xsl:value-of select="concat(local-name(.),'_',ID)"/>
            </imvert:id>
            <imvert:stereotype id="stereotype-name-enum">ENUMERATIEWAARDE</imvert:stereotype>
            <xsl:if test="Kwaliteitsregime = 'IMBRO/A'">
                <imvert:stereotype id="stereotype-name-imbroa">IMBRO/A</imvert:stereotype>
            </xsl:if>
            <imvert:tagged-values>
                <imvert:tagged-value id="CFG-TV-DEFINITION">
                    <imvert:value>
                        <xsl:sequence select="Omschrijving/node()"/>
                    </imvert:value>
                </imvert:tagged-value>
            </imvert:tagged-values>
        </imvert:attribute>
    </xsl:template>
    
    <xsl:template match="
        /domeintabel/Kleur
        | /domeintabel/Kleursterkte
        " mode="codelist">
        <imvert:attribute origin="system">
            <imvert:name original="{Waarde}">
                <xsl:value-of select="Waarde"/>
            </imvert:name>
            <imvert:id>
                <xsl:value-of select="concat(local-name(.),'_',ID)"/>
            </imvert:id>
            <imvert:stereotype id="stereotype-name-enum">ENUMERATIEWAARDE</imvert:stereotype>
            <xsl:if test="Kwaliteitsregime = 'IMBRO/A'">
                <imvert:stereotype id="stereotype-name-imbroa">IMBRO/A</imvert:stereotype>
            </xsl:if>
            <imvert:tagged-values>
                <imvert:tagged-value id="CFG-TV-DEFINITION">
                    <imvert:value>
                        <xsl:sequence select="Omschrijving/node()"/>
                    </imvert:value>
                </imvert:tagged-value>
            </imvert:tagged-values>
        </imvert:attribute>
    </xsl:template>
    
    <!-- BRO reference lists; vrije kolommen, zoals /Waardelijst/GeologischeGrondsoort/* -->
    <xsl:template match="/(domeintabel | Waardelijst)/*" mode="reflist">
        <imvert:refelement>
            <xsl:for-each select="*">
                <imvert:element>
                    <xsl:sequence select="node()"/>
                </imvert:element>
            </xsl:for-each>
        </imvert:refelement>
    </xsl:template>

    <!-- any list that has unsupported root element -->
    <xsl:template match="/*" mode="codelijst reflist" priority="-1">
        <xsl:param name="construct" as="element()"/>
        <xsl:sequence select="imf:msg($construct,'ERROR','No strategy for reading value list rooted in: [1]',name(.))"/>
    </xsl:template>
    
</xsl:stylesheet>
