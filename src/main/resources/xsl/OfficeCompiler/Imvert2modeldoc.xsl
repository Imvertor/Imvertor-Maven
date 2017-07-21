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
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="i3n-document" select="imf:document('../../config/i3n/translate.xml')"/>
    
    <xsl:variable name="quot"><!--'--></xsl:variable>
    
    <xsl:template match="/imvert:packages">
        
        <xsl:variable name="sections" as="element()*">
            <xsl:apply-templates select="imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]"/>
        </xsl:variable>
        <book name="{imvert:application}" type="{imvert:stereotype}" id="{imvert:id}" version="{$imvertor-version}" date="{$generation-date}">
       
            <!-- first call a general initialization function -->
            <xsl:sequence select="imf:initialize-modeldoc()"/>
            
            <!-- then generate the contents -->
            <xsl:apply-templates select="$sections" mode="section-cleanup"/>    
        </book>
    </xsl:template>
    
    <xsl:template match="imvert:package"><!-- only domain packs -->
        <section type="DOMAIN" name="{imf:plugin-get-model-name(.)}" id="{imf:plugin-get-link-name(.,'global')}">
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
        <section name="{imvert:name/@original}" type="OBJECTTYPE" id="{imf:plugin-get-link-name(.,'global')}">
          <content>
              <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-OBJECTTYPE')"/>
          </content>
          <!-- hier alle attributen; als ingebedde tabel -->
          <xsl:apply-templates select="imvert:attributes" mode="short"/>
          <!-- hier alle relaties; als ingebedde tabel -->
          <xsl:apply-templates select="imvert:associations" mode="short"/>
          <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
       </section>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-relatieklasse')]">
        
        <section name="{imvert:name/@original}" type="ASSOCIATIONCLASS" id="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-ASSOCIATIONCLASS')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle relaties; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:associations" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
       
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-referentielijst')]">
        <section name="{imvert:name/@original}" type="REFERENCELIST" id="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-REFERENCELIST')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-codelist')]">
        <section name="{imvert:name/@original}" type="CODELIST" id="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-CODELIST')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-union')]">
        <section name="{imvert:name/@original}" type="UNION" id="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-UNION')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-complextype')]">
        <section name="{imvert:name/@original}" type="DATATYPE" id="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-DATATYPE')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-enumeration')]">
        <xsl:variable name="naam" select="imvert:name/@original"/>
        <part>
            <item>
                <xsl:sequence select="imf:create-idref(.,'detail')"/>
                <xsl:sequence select="imf:create-content($naam)"/>          
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
        </part>
     </xsl:template>

    <!-- uitzondering: gegevensgroeptype wordt apart getoond. -->
    <xsl:template match="imvert:class[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-composite')]">
        <section name="{imvert:name/@original}" type="COMPOSITE" id="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-COMPOSITE')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="gegevensgroeptype"/>
            <!-- hier alle relaties; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:associations" mode="gegevensgroeptype"/>
        </section>
    </xsl:template>

    <xsl:template match="imvert:attributes" mode="short gegevensgroeptype">
        <xsl:variable name="r" as="element()*">
            <xsl:choose>
                <xsl:when test="imf:get-config-stereotypes('stereotype-name-association-to-composite') = '#unknown'">
                    <!-- attribuut groepen zijn als attribuut opgenomen. -->
                    <xsl:apply-templates select="imvert:attribute[not(imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attributegroup'))]" mode="#current"/>
                    <!-- als de class ook gegevensgroepen heeft, die attributen hier invoegen -->
                    <xsl:for-each select="imvert:attribute[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-attributegroup')]">
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
                </xsl:when>
                <xsl:otherwise>
                    <!-- attribuut groepen zijn via associatie gekoppeld. -->
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
                </xsl:otherwise>
            </xsl:choose>
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
         <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imvert:name/@original))"/> 
         <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
         <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
         <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
       </part>
    </xsl:template>

    <xsl:template match="imvert:attribute" mode="gegevensgroeptype">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
       <part type="COMPOSED">
          <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imvert:name/@original))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
          <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
   
    <xsl:template match="imvert:association" mode="gegevensgroeptype-as-attribute">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <part type="COMPOSED">
           <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imvert:name/@original))"/>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
            <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imvert:type-name/@original,false())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:attribute | imvert:association" mode="composition">
        <!-- toon alsof het een attribuut is -->
        <xsl:variable name="type" select="imf:get-construct-by-id(imvert:type-id)"/>
       <part type="COMPOSER">
          <item>
             <xsl:sequence select="imf:create-element('value',imf:create-link($type,'detail',imvert:name/@original))"/>
          </item>
          <item>
              <xsl:sequence select="imf:create-element('value',imf:get-formatted-tagged-value($type,'CFG-TV-DEFINITION'))"/>
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
                <xsl:variable name="relation" select="imvert:name"/>
                <xsl:variable name="target" select="imvert:role-target"/>
                <xsl:variable name="relation-original-name" select="if (exists($relation) and exists($target)) then concat($relation/@original,': ',$target/@original) else ($relation/@original,$target/@original)"/>
                
              <xsl:sequence select="imf:create-element('item',string(../../imvert:name/@original))"/>
              <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs-source,imvert:max-occurs-source),']'))"/>
              <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',$relation-original-name))"/>
              <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imvert:type-name/@original))"/>
              <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs),']'))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value($type,'CFG-TV-DEFINITION'))"/>
            
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
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value($type,'CFG-TV-DEFINITION'))"/>
        </part>
    </xsl:template>
    
    <!-- Stel detailinfo samen voor een objecttype, relatieklasse, enumeratie -->
    <xsl:template match="imvert:class" mode="detail">
        <section name="{imvert:name/@original}" type="{imvert:stereotype[1]}" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
           
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
        <section name="{imvert:name/@original}" type="DETAIL-ENUMERATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <part>
                    <xsl:sequence select="imf:create-element('item',imf:plugin-translate-i3n('DEFINITIE',true()))"/>
                    <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
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
        
        <section name="{imvert:name/@original}" type="DETAIL-COMPOSITE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
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
        <section name="{imvert:name/@original}" type="DETAIL-ATTRIBUTE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-ATTRIBUTE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>       
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-enumeratie">
        <part>
            <xsl:sequence select="imf:create-element('item',imvert:alias)"/>
            <xsl:sequence select="imf:create-element('item',imvert:name/@original)"/>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
       </part>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imvert:name/@original}" type="DETAIL-COMPOSITE-ATTRIBUTE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', $construct/imvert:name/@original)"/>
                </part>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE-ATTRIBUTE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-referentie-element">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imvert:name/@original}" type="DETAIL-REFERENCEELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-REFERENCEELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-unionelement">
        <xsl:variable name="construct" select="../.."/>
        <section name="{imvert:name/@original}" type="DETAIL-UNIONELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-UNIONELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-dataelement">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <section name="{imvert:name/@original}" type="DETAIL-DATAELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-DATAELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
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
     
        <section name="{imvert:name/@original}" type="DETAIL-ASSOCIATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-ASSOCIATION')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <section name="{imvert:name/@original}" type="DETAIL-COMPOSITE-ASSOCIATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', $construct/imvert:name/@original)"/>
                </part>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE-ASSOCIATION')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
        
    </xsl:template>
    
    <xsl:function name="imf:get-formatted-tagged-value" as="xs:string">        
        <xsl:param name="this" />
        <xsl:param name="tv-id"/>
        <xsl:variable name="value" select="imf:get-most-relevant-compiled-taggedvalue($this,concat('##',$tv-id))"/>
        <xsl:value-of select="imf:get-clean-documentation-string($value)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-formatted-tagged-value-cfg" as="item()*">        
        <xsl:param name="level"/>
        <xsl:param name="this"/>
        <xsl:param name="tv-id"/>
        <xsl:choose>
            <xsl:when test="$level/@compile = 'full'">
                <xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,false())"/>
                <xsl:variable name="vals" select="$all-tv[@id = $tv-id]"/>
                <!--<xsl:message select="(imf:get-display-name($this), $tv-id, $vals/@value)"/>-->
                <xsl:for-each select="$vals">
                    <item type="TRACED">
                        <item type="SUPPLIER">
                            <xsl:value-of select="imf:get-subpath(@project,@application,@release)"/>
                        </item>
                        <item>
                            <xsl:value-of select="imf:get-clean-documentation-string(@value)"/>
                        </item>
                    </item>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="val" select="imf:get-most-relevant-compiled-taggedvalue($this,concat('##',$tv-id))"/>
                <xsl:value-of select="imf:get-clean-documentation-string($val)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-unieke-aanduiding">
        <xsl:param name="this"/>
        <xsl:variable name="id-attribute" select="$this/imvert:attributes/imvert:attribute[imf:boolean(imvert:is-id)]"/>
        <xsl:sequence select="if (exists($id-attribute)) then $id-attribute/imvert:name/@original else ''"/>
    </xsl:function>
    
   <xsl:function name="imf:create-part-2" as="element(part)*"> 
       <xsl:param name="level" as="element(level)"/>
       <xsl:param name="waarde" as="item()*"/>
     
       <xsl:variable name="doc-rule" select="$level/../.."/>
       
       <xsl:variable name="name" select="$doc-rule/name"/> 
       <xsl:variable name="doc-rule-id" select="$doc-rule/@id"/>
       
       <xsl:variable name="show" select="$level/@show"/> <!-- force, implied or none -->
       <xsl:variable name="compile" select="$level/@compile"/> <!-- single or full -->
       <xsl:variable name="format" select="$level/@format"/> <!-- plain or ? -->
       
       <xsl:variable name="exists-waarde" select="normalize-space(string-join($waarde,''))"/>
       
       <xsl:variable name="display-waarde" as="item()*">
           <xsl:choose>
               <xsl:when test="$show = 'none'">
                   <!-- skip; this is forced by the configuration -->
               </xsl:when>
               <xsl:when test="$show = 'implied' and not($exists-waarde)">
                   <!-- skip -->
               </xsl:when>
               <xsl:when test="$show = 'missing' and not($exists-waarde)">
                   <xsl:value-of select="'MISSING'"/>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:sequence select="$waarde"/>
               </xsl:otherwise>
           </xsl:choose>
       </xsl:variable>
       
       <xsl:choose>
           <xsl:when test="$show = 'implied' and not($exists-waarde)">
               <!-- skip -->
           </xsl:when>
           <xsl:otherwise>
               <part type="{$doc-rule-id}">
                   <xsl:sequence select="imf:create-element('item',$name)"/>
                   <xsl:choose>
                       <xsl:when test="$format = 'plain'">
                           <xsl:sequence select="imf:create-element('item',$display-waarde)"/>          
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:sequence select="imf:msg('FATAL','Unknown format: [1]',$format)"/>          
                       </xsl:otherwise>
                   </xsl:choose>
               </part>
           </xsl:otherwise>
       </xsl:choose>
   </xsl:function>
  
    <xsl:function name="imf:create-parts-cfg" as="element(part)*">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="level" as="xs:string"/> <!-- a description of what to show, see docrules. --> 
        
        <xsl:for-each select="$configuration-docrules-file/doc-rule/levels/level[. = $level]">
           
            <xsl:variable name="relation" select="$this/imvert:name"/>
            <xsl:variable name="target" select="$this/imvert:role-target"/>
            <xsl:variable name="relation-name" select="if (exists($relation) and exists($target)) then concat($relation,': ',$target) else ($relation,$target)"/>
            <xsl:variable name="relation-original-name" select="if (exists($relation) and exists($target)) then concat($relation/@original,': ',$target/@original) else ($relation/@original,$target/@original)"/>
           
            <xsl:variable name="doc-rule-id" select="../../@id"/>
           
            <xsl:choose>
                <!-- 
                    create and entry "name", "target role name" or "name: target role name" 
                -->
                <xsl:when test="$doc-rule-id = 'CFG-DOC-NORMNAAM'">
                    <xsl:sequence select="imf:create-part-2(.,$relation-name)"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-NAAM'">
                    <xsl:sequence select="imf:create-part-2(.,$relation-original-name)"/>
                </xsl:when>
                <!-- 
                    remainder is specified on target or relation, as may be the case 
                -->
                <xsl:when test="$doc-rule-id = 'CFG-DOC-ALTERNATIEVENAAM'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-NAME'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MNEMONIC'">
                    <xsl:sequence select="imf:create-part-2(.,$this/imvert:alias)"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-HERKOMST'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-SOURCE'))"/> 
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DEFINITIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DEFINITION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-HERKOMSTDEFINITIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-SOURCEOFDEFINITION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DATUMOPNAME'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DATERECORDED'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNIEKEAANDUIDING'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-tagged-value-unieke-aanduiding($this))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-POPULATIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-POPULATION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-KWALITEITSBEGRIP'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-QUALITY'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MOGELIJKGEENWAARDE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-VOIDABLE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEMATERIELEHISTORIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIONMATERIALHISTORY'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEFORMELEHISTORIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIONFORMALHISTORY'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEINONDERZOEK'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIEINONDERZOEK'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-AANDUIDINGSTRIJDIGHEIDNIETIGHEID'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-AANDUIDINGSTRIJDIGHEIDNIETIGHEID'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEKARDINALITEIT'">
                    <xsl:variable name="min" select="$this/imvert:min-occurs"/>
                    <xsl:variable name="max" select="$this/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:get-cardinality($min,$max))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEAUTHENTIEK'">
                    <xsl:sequence select="imf:create-part-2(.,concat(imf:get-formatted-tagged-value($this,'CFG-TV-INDICATIONAUTHENTIC'), imf:authentiek-is-derived($this)))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-REGELS'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-RULES'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNIEKEAANDUIDING'">
                    <xsl:variable name="rel-aanduiding" select="$this/imvert:associations/imvert:association[imvert:target-stereotype = imf:get-config-stereotypes('stereotype-name-composite-id')]"/>
                    <xsl:variable name="con-aanduiding" select="imf:get-construct-by-id-for-office($rel-aanduiding/imvert:type-id)"/>
                    <xsl:variable name="id-aanduiding" select="imf:get-tagged-value-unieke-aanduiding($this)"/>
                    
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
                    <xsl:sequence select="imf:create-part-2(.,$aanduiding)"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEABSTRACTOBJECT'">
                    <xsl:variable name="is-abstract-text" select="if (imf:boolean($this/imvert:abstract)) then 'YES' else 'NO'"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:plugin-translate-i3n($is-abstract-text,false()))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DATALOCATIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DATALOCATION'))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-PATROON'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-PATTERN'))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-FORMEELPATROON'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-FORMALPATTERN'))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-FORMAAT'">
                    <xsl:sequence select="imf:create-part-2(.,imf:plugin-translate-i3n($this/imvert:baretype,false()))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-RELATIESOORT'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-relatiesoort($this))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-GERELATEERDOBJECTTYPE'">
                    <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office($this/imvert:type-id)"/>          
                    <xsl:sequence select="imf:create-part-2(.,imf:create-link($defining-class,'global',$this/imvert:type-name/@original))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEAFLEIDBAAR'">
                    <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean($this/imvert:is-value-derived)) then 'YES' else 'NO'"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:plugin-translate-i3n($is-afleidbaar-text,false()))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-TRACE'">
                    <xsl:variable name="suppliers" select="imf:get-trace-suppliers-for-construct($this,1)"/>
                    <xsl:variable name="list" as="item()*">
                        <xsl:for-each select="subsequence($suppliers,2)">
                            <item type="TRACELINK">
                                <item type="DISPLAYNAME">
                                    <xsl:value-of select="@display-name"/>
                                </item>
                                <item type="SUBPATH">
                                    <xsl:value-of select="@subpath"/>
                                </item>
                            </item>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-part-2(.,$list)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg($this,'FATAL','No such document rule: [1]',$doc-rule-id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
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
        <xsl:if test="imf:get-formatted-tagged-value($this,'derived') = '1'">
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
            <xsl:sequence select="imf:create-idref($this,$type)"/>
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
        <xsl:param name="type"/><!-- global or detail -->
        <xsl:if test="exists($construct)">
            <xsl:attribute name="idref" select="imf:plugin-get-link-name($construct,$type)"/>
        </xsl:if>
    </xsl:function>
    
    <!-- =========== plugins ============= -->
    
    <!--
         return a translation of the term passed 
    -->
    <xsl:function name="imf:plugin-translate-i3n" as="xs:string?">
        <xsl:param name="key"/>
        <xsl:param name="must-be-known"/>
        <xsl:value-of select="imf:translate-i3n(upper-case($key), $language-model, if ($must-be-known) then () else $key)"/> 
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
        <xsl:param name="type"/> <!-- global or detail -->
        <xsl:sequence select="concat($type,'_',generate-id($this))"/>
    </xsl:function>
    
    <!-- 
        return a section name for a model passed as a package 
    -->
    <xsl:function name="imf:plugin-get-model-name">
        <xsl:param name="package" as="element(imvert:package)"/>
        
        <xsl:value-of select="$package/imvert:name/@original"/>
    </xsl:function>
    
    <xsl:function name="imf:initialize-modeldoc" as="item()*">
        <!-- stub: may be implemented by any modeldoc -->
    </xsl:function>
    
    <!-- ======== cleanup all section structure: remove empties =========== -->
    
    <xsl:template match="section" mode="section-cleanup">
        <xsl:choose>
            <xsl:when test="*">
                <xsl:next-match/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="section-cleanup">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="section-cleanup"/>
            <xsl:apply-templates select="node()" mode="section-cleanup"/>
        </xsl:copy>
    </xsl:template>    
</xsl:stylesheet>
