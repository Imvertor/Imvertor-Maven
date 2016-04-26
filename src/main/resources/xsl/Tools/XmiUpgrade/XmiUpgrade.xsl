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
    
    xmlns:uml="http://schema.omg.org/spec/UML/2.1" 
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1" 
    xmlns:UPCC3_-_PRIMLibrary_Abstract_Syntax="http://www.sparxsystems.com/profiles/UPCC3_-_PRIMLibrary_Abstract_Syntax/1.0" 
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0" 
    xmlns:GML="http://www.sparxsystems.com/profiles/GML/1.0" 
    xmlns:Java="http://www.sparxsystems.com/profiles/Java/1.0"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    
    <xsl:output exclude-result-prefixes="#all"></xsl:output>
    <!-- upgrade XMI file to new metamodel -->
    
    <xsl:variable name="empty-value" select="''"/>
    
    <!-- objecttype -->
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = ('objecttype','koppelklasse')]]/tags">
        <xsl:comment select="'result=Objecttype of koppelklasse'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Eigenaar','Eigenaar')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Gebruiksvoorwaarden','Gebruiksvoorwaarden')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst definitie','Herkomst definitie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie authentiek','Authentiek')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Kwaliteit','Kwaliteit')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Populatie','Populatie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toegankelijkheid','Toegankelijkheid')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toelichting','Toelichting')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Wetgeving','Wetgeving')"/>
            
            <xsl:sequence select="imf:insert-tagged-value(.,'Base-mapping','Base-mapping')"/>
        </tags> 
    </xsl:template>
    
    <!-- gegevensgroeptype -->
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = 'gegevensgroeptype']]/tags">
        <xsl:comment select="'result=Gegevensgroeptype'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Eigenaar','Eigenaar')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst definitie','Herkomst definitie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie authentiek','Authentiek')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie formele historie','Indicatie formele historie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie materiële historie','Indicatie materiële historie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Mogelijk geen waarde','Mogelijk geen waarde')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toelichting','Toelichting')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Regels','Regels')"/>
        </tags> 
    </xsl:template>
    
    <!-- referentielijst -->
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = 'referentielijst']]/tags">
        <xsl:comment select="'result=Referentielijst'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Data locatie','data-location')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toelichting','Toelichting')"/>
        </tags> 
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = 'referentielijst']]/attributes/attribute/tags">
        <xsl:comment select="'result=Referentie element'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Data locatie','data-location')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Patroon','pattern')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Positie','position')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toelichting','Toelichting')"/>
        </tags> 
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = 'union']]/tags">
        <xsl:comment select="'result=Union'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
        </tags> 
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = 'union']]/attributes/attribute/tags">
        <xsl:comment select="'result=Union element'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Patroon','pattern')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Positie','position')"/>
        </tags> 
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = 'complex datatype']]/tags">
        <xsl:comment select="'result=Complex datatype'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Patroon','pattern')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toegankelijkheid','Toegankelijkheid')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Wetgeving','Wetgeving')"/>
        </tags> 
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = 'complex datatype']]/attributes/attribute/tags">
        <xsl:comment select="'result=Data element'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie authentiek','Authentiek')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Data location','Data-location')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Eigenaar','Eigenaar')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Populatie','Populatie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Kwaliteit','Kwaliteit')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toegankelijkheid','Toegankelijkheid')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Gebruiksvoorwaarden','Gebruiksvoorwaarden')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Patroon','Pattern')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Positie','position')"/>
        </tags> 
    </xsl:template>
    
    <!-- Attribuutsoort -->
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Class' and properties/@stereotype[lower-case(.) = ('objecttype','gegevensgroeptype')]]/attributes/attribute/tags">
        <xsl:comment select="'result=Attribuutsoort'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Data locatie','data-location')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Eigenaar','Eigenaar')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Gebruiksvoorwaarden','Gebruiksvoorwaarden')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst','Herkomst')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst definitie','Herkomst definitie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie authentiek','Authentiek')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie formele historie','Indicatie formele historie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie materiële historie','Indicatie materiële historie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Kwaliteit','Kwaliteit')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Mogelijk geen waarde','Mogelijk geen waarde')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Patroon','pattern')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Positie','position')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Populatie','Populatie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Regels','Regels')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toegankelijkheid','Toegankelijkheid')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toelichting','Toelichting')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Wetgeving','Wetgeving')"/>
        </tags>
    </xsl:template>
    
    <!-- relatiesoort -->
    <xsl:template match="/xmi:XMI/xmi:Extension/connectors/connector[properties/@stereotype[lower-case(.) = ('relatiesoort','externe koppeling')]]/tags">
        <xsl:comment select="'result=Relatiesoort of externe koppeling'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Datum opname','Datum opname')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst',())"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Herkomst definitie',())"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie authentiek','Authentiek')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie formele historie','Indicatie formele historie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Indicatie materiële historie','Indicatie materiële historie')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Mogelijk geen waarde','Mogelijk geen waarde')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Positie','position')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Regels','Regels')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Toelichting','Toelichting')"/>
        </tags>
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Package' and properties/@stereotype[lower-case(.) = 'external']]/tags">
        <xsl:comment select="'result=External'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Locatie','Location')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Release','Release')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Ref-release','ref-release')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Ref-version','ref-version')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Svnid','Svnid')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Web locatie','web-location')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Xsd-location','xsd-location')"/>
        </tags>
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Package' and properties/@stereotype[lower-case(.) = ('application','base')]]/tags">
        <xsl:comment select="'result=application or base'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Release','Release')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Supplier-name','supplier-name')"/> <!-- TODO check de lijst -->
            <xsl:sequence select="imf:insert-tagged-value(.,'Supplier-release','supplier-release')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Supplier-project','supplier-project')"/> <!-- TODO check de lijst -->
            <xsl:sequence select="imf:insert-tagged-value(.,'Svnid','Svnid')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Web locatie','web-location')"/>
        </tags>
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[@xmi:type='uml:Package' and properties/@stereotype[lower-case(.) = 'domain']]/tags">
        <xsl:comment select="'result=domain'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Ref-release','ref-release')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Ref-version','ref-version')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Release','Release')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Supplier-package-name','supplier-package-name')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Supplier-release','supplier-release')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Svnid','Svnid')"/>
            <xsl:sequence select="imf:insert-tagged-value(.,'Web locatie','web-location')"/>
        </tags>
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[properties/@stereotype[lower-case(.) = 'datatype']]/tags">
        <xsl:comment select="'result=Datatype'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Patroon','pattern')"/>
        </tags> 
    </xsl:template>
    
    <xsl:template match="/xmi:XMI/xmi:Extension/elements/element[properties/@stereotype[lower-case(.) = 'enum']]/tags"><!--TODO hoe herken je enums in 2.1 export? -->
        <xsl:comment select="'result=Enum'"/>
        <tags>
            <xsl:sequence select="imf:insert-tagged-value(.,'Positie','position')"/>
        </tags> 
    </xsl:template>
    
    <xsl:function name="imf:insert-tagged-value">
        <xsl:param name="this"/>
        <xsl:param name="name"/>
        <xsl:param name="existing-tagged-value-name" as="xs:string?"/>
        
        <xsl:variable name="existing-tagged-value" select="(imf:match-tag($this,$existing-tagged-value-name),imf:match-tag($this,$name))[1]"/>
        <xsl:variable name="modelelement" select="$this/../@xmi:idref"/>
        
        <xsl:choose>
            <xsl:when test="exists($existing-tagged-value)">
                <tag name="{$name}" value="{$existing-tagged-value/@value}" xmi:id="{$existing-tagged-value/@xmi:id}">
                    <xsl:if test="exists($modelelement)">
                        <xsl:attribute name="modelElement" select="$modelelement"/>
                    </xsl:if>
                </tag>
            </xsl:when>
            <xsl:otherwise>
                <tag name="{$name}" value="{$empty-value}" xmi:id="{imf:generate-id()}">
                    <xsl:if test="exists($modelelement)">
                        <xsl:attribute name="modelElement" select="$modelelement"/>
                    </xsl:if>
                </tag>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="imf:match-tag" as="element(tag)?">
        <xsl:param name="this"/>
        <xsl:param name="tagname"/>
        <xsl:variable name="r" select="$this/tag[lower-case(@name) = lower-case($tagname) and normalize-space(@value)]"/>
        <xsl:if test="$r[2]">
            <xsl:message select="concat('Meer dan een tagged value met een waarde aangetroffen: ', $r[2]/@xmi:id, ' = ', $tagname)"/>
        </xsl:if>
        <xsl:sequence select="$r[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:generate-id" as="xs:string">
        <xsl:value-of select="concat('MIGRATE_',ext:imvertorGetUUID())"/>
    </xsl:function>
    
    <!-- default -->
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>