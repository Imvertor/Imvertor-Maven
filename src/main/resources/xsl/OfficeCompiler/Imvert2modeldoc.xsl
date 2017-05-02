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
          Transform the embellishg file to a standard simplied documentation format, to be processed for display by separate metamodel/owner based modules.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="i3n-document" select="imf:document('../../config/i3n/translate.xml')"/>
    
    <xsl:variable name="quot"><!--'--></xsl:variable>
    
    <xsl:template match="/imvert:packages">
        <book name="{imvert:application}" type="{imvert:stereotype}" id="{imvert:id}" version="{$imvertor-version}" date="{$generation-date}">
            <xsl:apply-templates select="imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]"/>
        </book>
    </xsl:template>
    
    <xsl:template match="imvert:package"><!-- only domain packs -->
        <section type="DOMAIN" name="{imf:plugin-get-model-name(.)}" id="{imf:plugin-get-link-name(.)}">
            <section type="OVERVIEW-OBJECTTYPE">
                <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')]"/>
            </section>
            <section type="OVERVIEW-ASSOCIATIONCLASS">
                <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse')]"/>
            </section>
            <section type="OVERVIEW-REFERENCELIST">
                <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst')]"/>
            </section>
            <section type="OVERVIEW-CODELIST">
                <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-codelist')]"/>
            </section>
            <section type="OVERVIEW-UNION">
                <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union')]"/>
            </section>
            <section type="OVERVIEW-DATATYPE">
                <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-complextype')]"/>
            </section>
            <section type="OVERVIEW-ENUMERATION">
                <content>
                   <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]"/>
                </content>
            </section>
            <section type="DETAILS">
                <section type="DETAILS-OBJECTTYPE">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')]" mode="detail"/>
                 </section>
                <section type="DETAILS-ASSOCIATIONCLASS">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse')]" mode="detail"/>
                </section>
                <section type="DETAILS-REFERENCELIST">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst')]" mode="detail"/>
                </section>
                <section type="DETAILS-CODELIST">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-codelist')]" mode="detail"/>
                </section>
                <section type="DETAILS-UNION">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union')]" mode="detail"/>
                </section>
                <section type="DETAILS-DATATYPE">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-complextype')]" mode="detail"/>
                </section>
                <section type="DETAILS-ENUMERATION">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]" mode="detail"/>
                </section>
          </section>
       </section>
        
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-objecttype')]">
        
        <xsl:variable name="is-abstract-text" select="if (imf:boolean(imvert:abstract)) then 'Ja' else 'Nee'"/>
        
        <xsl:variable name="rel-aanduiding" select="imvert:associations/imvert:association[imvert:target-stereotype = imf:get-config-stereotypes('stereotype-name-composite-id')]"/>
        <xsl:variable name="con-aanduiding" select="imf:get-construct-by-id-for-office($rel-aanduiding/imvert:type-id)"/>
        <xsl:variable name="id-aanduiding" select="imf:get-tagged-value-unieke-aanduiding(.)"/>
        
        <xsl:variable name="aanduiding">
            <xsl:choose>
                <xsl:when test="exists($rel-aanduiding) and exists($id-aanduiding)">
                    <xsl:value-of select="concat('Combinatie van ', $id-aanduiding,' en ', $con-aanduiding/imvert:name/@original)"/>
                </xsl:when>
                <xsl:when test="exists($rel-aanduiding)">
                    <xsl:value-of select="$con-aanduiding/imvert:name/@original"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$id-aanduiding"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
      
        <section name="{imvert:name/@original}" type="OBJECTTYPE" id="{imf:plugin-get-link-name(.)}">
          <content>
             <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
             <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
             <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
             <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
             <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
             <xsl:sequence select="imf:create-part-2('UNIEKEAANDUIDING',$aanduiding)"/>
             <xsl:sequence select="imf:create-part-2('INDICATIEABSTRACTOBJECT',$is-abstract-text)"/>
             <xsl:sequence select="imf:create-part-2('POPULATIE',imf:get-tagged-value(.,'Populatie'))"/>
             <xsl:sequence select="imf:create-part-2('KWALITEITSBEGRIP',imf:get-tagged-value(.,'Kwaliteitsbegrip'))"/>
          </content>
          <!-- hier alle attributen; als ingebedde tabel -->
          <xsl:apply-templates select="imvert:attributes" mode="short"/>
          <!-- hier alle relaties; als ingebedde tabel -->
          <xsl:apply-templates select="imvert:associations" mode="short"/>
          <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
       </section>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse')]">
        
        <section name="{imvert:name/@original}" type="ASSOCIATIONCLASS" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('MNEMONIC',imvert:alias)"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('RELATIESOORT',imf:get-relatiesoort(.))"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle relaties; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:associations" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        </section>
       
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst')]">
        <section name="{imvert:name/@original}" type="REFERENCELIST" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('MNEMONIC',imvert:alias)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('DATALOCATIE',imf:get-tagged-value(.,'Data locatie'))"/>
                <xsl:sequence select="imf:create-part-2('UNIEKEAANDUIDING',imf:get-tagged-value-unieke-aanduiding(.))"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-codelist')]">
        <section name="{imvert:name/@original}" type="CODELIST" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('MNEMONIC',imvert:alias)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('DATALOCATIE',imf:get-tagged-value(.,'Data locatie'))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union')]">
        <section name="{imvert:name/@original}" type="UNION" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-complextype')]">
        <section name="{imvert:name/@original}" type="DATATYPE" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('PATROON',imf:get-tagged-value(.,'Patroon'))"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]">
        <xsl:variable name="naam" select="imvert:name/@original"/>
        <xsl:variable name="note" select="imf:get-clean-documentation-string(imvert:documentation)"/>
        <part>
            <item>
                <xsl:sequence select="imf:create-idref(.)"/>
                <xsl:sequence select="imf:create-content($naam)"/>          
            </item>
            <xsl:sequence select="imf:create-element('item',$note)"/>          
        </part>
     </xsl:template>

    <!-- uitzondering: gegevensgroeptype wordt apart getoond. -->
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')]">
        <section name="{imvert:name/@original}" type="COMPOSITE" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('MNEMONIC',imvert:alias)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/> 
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('UNIEKEAANDUIDING',imf:get-tagged-value-unieke-aanduiding(.))"/>
                <xsl:sequence select="imf:create-part-2('POPULATIE',imf:get-tagged-value(.,'Populatie'))"/>
                <xsl:sequence select="imf:create-part-2('KWALITEITSBEGRIP',imf:get-tagged-value(.,'Kwaliteitsbegrip'))"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="gegevensgroeptype"/>
            <!-- hier alle relaties; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:associations" mode="gegevensgroeptype"/>
        </section>
    </xsl:template>

    <xsl:template match="imvert:attributes" mode="short gegevensgroeptype">
        <xsl:variable name="r" as="element()*">
            <xsl:apply-templates select="imvert:attribute" mode="#current"/>
            <!-- als de class ook gegevensgroepen heeft, die attributen hier invoegen -->
            <xsl:for-each select="../imvert:associations/imvert:association">
                <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                <xsl:if test="$defining-class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')]">
                    <!-- eerst gegevensgroeptype info -->
                    <!--(4)-->
                    <xsl:apply-templates select="." mode="composition"/>
                    <!-- en dat de attributen daarin -->
                    <xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="gegevensgroeptype"/>
                    <xsl:apply-templates select="$defining-class/imvert:associations/imvert:association" mode="gegevensgroeptype-as-attribute"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($r)">
            <section type="SHORT-ATTRIBUTES">
              <content>
                 <itemtype/>
                 <itemtype type="ATTRIBUTE-NAME"/>
                 <itemtype type="ATTRIBUTE-DEFINITION"/>
                 <itemtype type="ATTRIBUTE-FORMAT"/>
                 <itemtype type="ATTRIBUTE-CARD"/>
                 <!-- and add rows -->
                 <xsl:sequence select="$r"/>
              </content>
           </section>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="short">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
       <part>
         <xsl:sequence select="imf:create-element('item',imf:create-link(.,'global',imvert:name/@original))"/> 
         <xsl:sequence select="imf:create-element('item',imf:get-clean-documentation-string(imvert:documentation))"/>
         <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
         <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
       </part>
    </xsl:template>

    <xsl:template match="imvert:attribute" mode="gegevensgroeptype">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
       <part type="COMPOSED">
          <xsl:sequence select="imf:create-element('item',imf:create-link(.,'global',imvert:name/@original))"/>
          <xsl:sequence select="imf:create-element('item',imf:get-clean-documentation-string(imvert:documentation))"/>
          <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
          <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
   
    <xsl:template match="imvert:association" mode="gegevensgroeptype-as-attribute">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <part type="COMPOSED">
           <xsl:sequence select="imf:create-element('item',imf:create-link(.,'global',imvert:name/@original))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-clean-documentation-string(imvert:documentation))"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imvert:type-name/@original,false())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="composition">
        <!-- toon alsof het een attribuut is -->
        <xsl:variable name="type" select="imf:get-construct-by-id(imvert:type-id)"/>
       <part type="COMPOSER">
          <item>
             <xsl:sequence select="imf:create-element('value',imf:create-link(.,'global',imvert:name/@original))"/>
          </item>
          <item>
             <xsl:sequence select="imf:create-element('value',imf:get-clean-documentation-string($type/imvert:documentation))"/>
          </item>
          <item>
             <!--<xsl:sequence select="imf:create-element('value',imf:plugin-translate-i3n(imvert:baretype,false()))"/>-->
              <!-- empty-->
          </item>
          <item>
             <xsl:sequence select="imf:create-element('value',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
          </item>
       </part>
    </xsl:template>
    
    <xsl:template match="imvert:associations" mode="short gegevensgroeptype">
        <xsl:variable name="r" as="element()*">
            <xsl:apply-templates select="../imvert:supertype" mode="#current"/>
            <xsl:apply-templates select="imvert:association[not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-association-to-composite'))]" mode="#current"/>
        </xsl:variable>
        <xsl:if test="exists($r)">
            <section type="SHORT-ASSOCIATIONS">
              <content>
                  <itemtype/>
                  <itemtype type="ASSOCIATION-NAME"/>
                  <itemtype type="ASSOCIATION-DEFINITION"/>
                  <xsl:sequence select="$r"/>
              </content>
           </section>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="short gegevensgroeptype">
        <xsl:variable name="type" select="imf:get-construct-by-id(imvert:type-id)"/>
        <part>
            <item>
                <!--
                Voorbeeld: ZAAKTYPE [1..*] heeft relevant BESLUITTYPE [0..*]
                -->
              <xsl:sequence select="imf:create-element('item',string(../../imvert:name/@original))"/>
              <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs-source,imvert:max-occurs-source),']'))"/>
              <xsl:sequence select="imf:create-element('item',imf:create-link(.,'global',imvert:name/@original))"/>
              <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imvert:type-name/@original))"/>
              <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs),']'))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-clean-documentation-string(imvert:documentation))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:supertype" mode="short gegevensgroeptype">
        <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <part>
            <item>
                <!--
                Voorbeeld: BENOEMD TERREIN is specialisatie van BENOEMD OBJECT
                -->
                <item>
                    <xsl:value-of select="../imvert:name/@original"/>
                </item>
                <item>
                    <xsl:value-of select="imf:plugin-translate-i3n('ISSPECIALISATIONOF',true())"/>
                </item>
                <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imvert:type-name/@original))"/>
            </item>
            <item>
                <xsl:value-of select="imf:get-clean-documentation-string(imvert:documentation)"/>
            </item>
        </part>
    </xsl:template>
    
    <!-- Stel detailinfo samen voor een objecttype, relatieklasse, enumeratie -->
    <xsl:template match="imvert:class" mode="detail">
        <section name="{imvert:name/@original}" type="{imvert:stereotype[1]}" id="{imf:plugin-get-link-name(.)}">
           
            <xsl:variable name="associations" select="imvert:associations/imvert:association"/>
            <xsl:variable name="compositions" select="$associations[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-association-to-composite')]"/>
          
            <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
            <xsl:for-each select="$compositions">
                <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                <xsl:apply-templates select="$defining-class" mode="detail"/>
                <!--<xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="detail"/>-->
            </xsl:for-each>
            <xsl:apply-templates select="($associations except $compositions)" mode="detail"/>       
        
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]" mode="detail">
        <section name="{imvert:name/@original}" type="DETAIL-ENUMERATION" id="{imf:plugin-get-link-name(.)}">
            <content>
                <part>
                    <xsl:sequence select="imf:create-element('item',imf:plugin-translate-i3n('DEFINITIE',true()))"/>
                    <xsl:sequence select="imf:create-element('item',imf:get-clean-documentation-string(imvert:documentation))"/>
                </part>
            </content>
            <content>
                <itemtype type="CODE"/>
                <itemtype type="NAME"/>
                <itemtype type="DEFINITION"/>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie"/>
            </content>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')]" mode="detail">
        
        <xsl:variable name="min" select="imvert:min-occurs"/>
        <xsl:variable name="max" select="imvert:max-occurs"/>
        
        <section name="{imvert:name/@original}" type="DETAIL-COMPOSITE" id="{imf:plugin-get-link-name(.)}">
            <content>
                <!-- precies hetzelfde als voor attributen ! -->
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('CODE',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('MOGELIJKGEENWAARDE',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEMATERIELEHISTORIE',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEFORMELEHISTORIE',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEINONDERZOEK',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:create-part-2('AANDUIDINGSTRIJDIGHEIDNIETIGHEID',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality($min,$max))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEAUTHENTIEK',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>
                <xsl:sequence select="imf:create-part-2('REGELS',imf:get-tagged-value(.,'Regels'))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
            <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
            <xsl:apply-templates select="imvert:associations/imvert:association" mode="detail"/>
        </section>
  
    </xsl:template>
    
    
    <xsl:template match="imvert:attribute" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <xsl:variable name="naam" select="$construct/imvert:name/@original"/>
        <xsl:choose>
            <xsl:when test="$defining-class/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')">
                <xsl:apply-templates select="$defining-class" mode="detail"/>
            </xsl:when>
            <xsl:when test="$construct/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')">
                <xsl:apply-templates select="." mode="detail-gegevensgroeptype"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentie-element')">
                <xsl:apply-templates select="." mode="detail-referentie-element"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union-element')">
                <xsl:apply-templates select="." mode="detail-unionelement"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype = imf:get-config-stereotypes('stereotype-name-data-element')">
                <xsl:apply-templates select="." mode="detail-dataelement"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="detail-normal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-normal">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <section name="{imvert:name/@original}" type="DETAIL-ATTRIBUTE" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('CODE',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('MOGELIJKGEENWAARDE',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:create-part-2('FORMAAT',imf:plugin-translate-i3n(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:create-part-2('PATROON',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEMATERIELEHISTORIE',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEFORMELEHISTORIE',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEINONDERZOEK',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:create-part-2('AANDUIDINGSTRIJDIGHEIDNIETIGHEID',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEAUTHENTIEK',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEAFLEIDBAAR',$is-afleidbaar-text)"/>
                <xsl:sequence select="imf:create-part-2('REGELS',imf:get-tagged-value(.,'Regels'))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        </section>       
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-enumeratie">
        <part>
            <xsl:sequence select="imf:create-element('item',imvert:alias)"/>
            <xsl:sequence select="imf:create-element('item',imvert:name/@original)"/>
            <xsl:sequence select="imf:create-element('item',imf:get-clean-documentation-string(imvert:documentation))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imvert:name/@original}" type="DETAIL-COMPOSITE-ATTRIBUTE" id="{imf:plugin-get-link-name(.)}">
            <content>
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', $construct/imvert:name/@original)"/>
                </part>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('CODE',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('MOGELIJKGEENWAARDE',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:create-part-2('FORMAAT',imf:plugin-translate-i3n(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:create-part-2('PATROON',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEMATERIELEHISTORIE',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEFORMELEHISTORIE',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEINONDERZOEK',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:create-part-2('AANDUIDINGSTRIJDIGHEIDNIETIGHEID',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEAUTHENTIEK',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>
                <xsl:sequence select="imf:create-part-2('REGELS',imf:get-tagged-value(.,'Regels'))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-referentie-element">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imvert:name/@original}" type="DETAIL-REFERENCEELEMENT" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('CODE',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('FORMAAT',imf:plugin-translate-i3n(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:create-part-2('PATROON',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        </section>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-unionelement">
        <xsl:variable name="construct" select="../.."/>
        <section name="{imvert:name/@original}" type="DETAIL-UNIONELEMENT" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('FORMAAT',imf:plugin-translate-i3n(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:create-part-2('PATROON',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-dataelement">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <section name="{imvert:name/@original}" type="DETAIL-DATAELEMENT" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('FORMAAT',imf:plugin-translate-i3n(imvert:baretype,false()))"/>
                <xsl:sequence select="imf:create-part-2('PATROON',imf:get-tagged-value(.,'Patroon'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>                
        </section>
    </xsl:template>
  
    <xsl:template match="imvert:association" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:choose>
            <xsl:when test="$construct/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')">
                <xsl:apply-templates select="." mode="detail-gegevensgroeptype"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="detail-normal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-normal">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <section name="{imvert:name/@original}" type="DETAIL-ASSOCIATION" id="{imf:plugin-get-link-name(.)}">
            <content>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('GERELATEERDOBJECTTYPE',imf:create-link($defining-class,'global',imvert:type-name/@original))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('CODE',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('MOGELIJKGEENWAARDE',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEMATERIELEHISTORIE',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEFORMELEHISTORIE',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEINONDERZOEK',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:create-part-2('AANDUIDINGSTRIJDIGHEIDNIETIGHEID',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEAUTHENTIEK',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>                
                <xsl:sequence select="imf:create-part-2('REGELS',imf:get-tagged-value(.,'Regels'))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <section name="{imvert:name/@original}" type="DETAIL-COMPOSITE-ASSOCIATION" id="{imf:plugin-get-link-name(.)}">
            <content>
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', $construct/imvert:name/@original)"/>
                </part>
                <xsl:sequence select="imf:create-part-2('NAAM',imvert:name/@original)"/>
                <xsl:sequence select="imf:create-part-2('GERELATEERDOBJECTTYPE',imf:create-link($defining-class,'global',imvert:type-name/@original))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEKARDINAILTEIT',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMST',imf:get-tagged-value(.,'Herkomst'))"/>
                <xsl:sequence select="imf:create-part-2('CODE',imf:get-tagged-value(.,'Code'))"/>
                <xsl:sequence select="imf:create-part-2('DEFINITIE',imf:get-clean-documentation-string(imvert:documentation))"/>
                <xsl:sequence select="imf:create-part-2('HERKOMSTDEFINITIE',imf:get-tagged-value(.,'Herkomst definitie'))"/>
                <xsl:sequence select="imf:create-part-2('DATUMOPNAME',imf:get-tagged-value(.,'Datum opname'))"/>
                <xsl:sequence select="imf:create-part-2('MOGELIJKGEENWAARDE',imf:get-tagged-value(.,'Mogelijk geen waarde'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEMATERIELEHISTORIE',imf:get-tagged-value(.,'Indicatie materiële historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEFORMELEHISTORIE',imf:get-tagged-value(.,'Indicatie formele historie'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEINONDERZOEK',imf:get-tagged-value(.,'Indicatie in onderzoek'))"/>
                <xsl:sequence select="imf:create-part-2('AANDUIDINGSTRIJDIGHEIDNIETIGHEID',imf:get-tagged-value(.,'Aanduiding strijdigheid/nietigheid'))"/>
                <xsl:sequence select="imf:create-part-2('INDICATIEAUTHENTIEK',concat(imf:get-tagged-value(.,'Indicatie authentiek'), imf:authentiek-is-derived(.)))"/>                
                <xsl:sequence select="imf:create-part-2('REGELS',imf:get-tagged-value(.,'Regels'))"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-clean-documentation-string(imf:get-tagged-value(.,'Toelichting')))"/>
        </section>
        
    </xsl:template>
    
    <!--
        de tagged value moet gelijk zijn aan de aangeven string. 
    -->
    <xsl:function name="imf:get-tagged-value" as="xs:string">
        <xsl:param name="this"/>
        <xsl:param name="tv-name"/>
        <xsl:variable name="normalized-tv-name" select="imf:get-normalized-name($tv-name,'tv-name')"/>
        <xsl:value-of select="imf:get-clean-documentation-string($this/*/imvert:tagged-value[imvert:name = $normalized-tv-name][1]/imvert:value/@original)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-unieke-aanduiding">
        <xsl:param name="this"/>
        <xsl:variable name="id-attribute" select="$this/imvert:attributes/imvert:attribute[imf:boolean(imvert:is-id)]"/>
        <xsl:sequence select="if (exists($id-attribute)) then $id-attribute/imvert:name/@original else ''"/>
    </xsl:function>
    
   <xsl:function name="imf:create-part-2" as="element(part)"> 
      <xsl:param name="label" as="item()*"/>
      <xsl:param name="waarde" as="item()*"/>
      <part>
          <xsl:sequence select="imf:create-element('item',imf:plugin-translate-i3n($label,true()))"/>          
          <xsl:sequence select="imf:create-element('item',$waarde)"/>          
      </part>
   </xsl:function>

    <xsl:function name="imf:get-cardinality" as="xs:string"> 
        <xsl:param name="min"/>
        <xsl:param name="max"/>
        <xsl:choose>
            <xsl:when test="$min = $max or empty($max)">
                <xsl:value-of select="$min"/>
            </xsl:when>
            <xsl:when test="$max = 'unbounded'">
                <xsl:value-of select="concat($min, ' .. *')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($min, ' .. ', $max)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-clean-documentation-string">
        <xsl:param name="doc-string"/>
        <xsl:variable name="r1" select="substring-after($doc-string,'&lt;memo&gt;')"/>
        <xsl:variable name="r2" select="if (normalize-space($r1)) then $r1 else $doc-string"/>
        <xsl:variable name="r3" select="if (starts-with($r2,'[newline]')) then substring($r2,10) else $r2"/>
        <xsl:variable name="r4" select="replace($r3,'\[newline\]',' ')"/>
        <xsl:variable name="r5" select="replace($r4,'&lt;.*?&gt;','')"/>
        <xsl:variable name="r6" select="replace($r5,'Description:','')"/>
        <xsl:value-of select="$r6"/>
    </xsl:function>
    
    <xsl:function name="imf:authentiek-is-derived">
        <xsl:param name="this"/>
        <xsl:if test="imf:get-tagged-value($this,'derived') = '1'">
            <xsl:value-of select="' (is afgeleid)'"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-toelichting">
        <xsl:param name="documentatie"/>
        <xsl:if test="normalize-space($documentatie)">
            <section type="EXPLANATION">
                <content>
                    <part>
                        <xsl:sequence select="imf:create-element('item',$documentatie)"/>
                    </part>
                </content>
            </section>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-relatiesoort">
        <xsl:param name="relatieklasse"/>
        <xsl:variable name="id" select="$relatieklasse/imvert:id"/>
        <xsl:variable name="assoc-class" select="$document-classes//imvert:association-class[imvert:type-id = $id]"/>
        <xsl:variable name="fromclass" select="$assoc-class/ancestor::imvert:class"/>
        <xsl:variable name="assoc" select="$assoc-class/.."/>
        <xsl:value-of select="concat($fromclass/imvert:name/@original, ' ',$assoc/imvert:name/@original,' ',$assoc/imvert:type-name/@original)"/>
    </xsl:function>
    
    
    <xsl:function name="imf:create-link">
        <xsl:param name="this"/>
        <xsl:param name="type"/>
        <xsl:param name="label"/>
        <item type="{$type}">
            <xsl:sequence select="imf:create-idref($this)"/>
            <xsl:sequence select="imf:create-content($label)"/>
        </item>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-by-id-for-office">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:if test="exists($id)">
            <xsl:sequence select="imf:get-construct-by-id($id)"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:create-element">
        <xsl:param name="name"/>
        <xsl:param name="content"/>
        <xsl:element name="{$name}">
            <xsl:sequence select="imf:create-content($content)"/>
        </xsl:element>
    </xsl:function>
    
    <xsl:function name="imf:create-content">
        <xsl:param name="content"/>
        <xsl:sequence select="if ($content instance of attribute()) then string($content) else $content"/>
    </xsl:function>
    
    <xsl:function name="imf:create-idref">
        <xsl:param name="construct"/>
        <xsl:if test="exists($construct)">
            <xsl:attribute name="idref" select="imf:plugin-get-link-name($construct)"/>
        </xsl:if>
    </xsl:function>
    
    <!-- =========== plugins ============= -->
    
    <!--
         return a translation of the term passed 
    -->
    <xsl:function name="imf:plugin-translate-i3n" as="xs:string?">
        <xsl:param name="key"/>
        <xsl:param name="must-be-known"/>
        <xsl:value-of select="imf:translate-i3n(upper-case($key), $language, if ($must-be-known) then () else $key)"/> 
    </xsl:function>
    
    <!-- 
        Verwijder het uppercase gedeelte uit de base type name. 
        Dus Splitsingstekeningreferentie APPARTEMENTSRECHTSPLITSING wordt Splitsingstekeningreferentie.
    -->
    <xsl:function name="imf:plugin-splice" as="xs:string?">
        <xsl:param name="typename"/>
        <xsl:variable name="t" select="normalize-space($typename)"/>
        <xsl:if test="$t">
            <xsl:analyze-string select="$t" regex="^(.*?)\s+?([^a-z]+)$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="$typename"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:plugin-get-link-name">
        <xsl:param name="this"/>
        <xsl:sequence select="generate-id($this)"/>
    </xsl:function>
    
    <!-- 
        return a section name for a model passed as a package 
    -->
    <xsl:function name="imf:plugin-get-model-name">
        <xsl:param name="package" as="element(imvert:package)"/>
        
        <xsl:value-of select="$package/imvert:name/@original"/>
    </xsl:function>
    
  
    
</xsl:stylesheet>
