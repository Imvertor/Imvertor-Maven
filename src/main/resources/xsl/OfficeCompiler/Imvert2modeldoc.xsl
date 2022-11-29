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
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all" 
    version="3.0">

    <!-- 
          Transform the embellishg file to a standard simplied documentation format, to be processed for display by separate metamodel/owner based modules.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/extension/extension-parse-html.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="stylesheet-code">OFFICE-MD</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:variable name="i3n-document" select="imf:document('../../config/i3n/translate.xml')"/>
    
    <xsl:variable name="quot"><!--'--></xsl:variable>
    
    <xsl:variable name="subpath" select="imf:get-subpath(/*/imvert:project,/*/imvert:application,/*/imvert:release)"/>
    
    <xsl:variable name="create-links" select="imf:get-config-string('cli','createofficemode','click') = 'click'"/>
    
    <xsl:variable name="link-by-eaid" select="($configuration-docrules-file/link-by,'EAID')[1] eq 'EAID'"/>
    <xsl:variable name="explanation-location" select="$configuration-docrules-file/explanation-location"/>
    <xsl:variable name="append-role-name" select="imf:boolean($configuration-docrules-file/append-role-name)"/>
    
    <xsl:variable name="imagemap-path" select="imf:get-config-string('properties','WORK_BASE_IMAGEMAP_FILE')"/>
    <xsl:variable name="imagemap" select="imf:document($imagemap-path)/imvert-imap:diagrams"/>
    
    <xsl:variable name="include-incoming-associations" select="imf:boolean($configuration-docrules-file/include-incoming-associations)"/>
    <xsl:variable name="lists-to-listing" select="imf:boolean($configuration-docrules-file/lists-to-listing)"/>
    <xsl:variable name="reveal-composition-name" select="imf:boolean($configuration-docrules-file/reveal-composition-name)"/>
    <xsl:variable name="show-properties" select="($configuration-docrules-file/show-properties,'config')[1]"/>
    
    <xsl:variable name="has-material-history" select="exists(//imvert:tagged-value[@id = 'CFG-TV-INDICATIONMATERIALHISTORY']/imvert:value[imf:boolean(.)])" as="xs:boolean"/>
    <xsl:variable name="has-formal-history" select="exists(//imvert:tagged-value[@id = 'CFG-TV-INDICATIONFORMALHISTORY']/imvert:value[imf:boolean(.)])" as="xs:boolean"/>
    
    <xsl:variable name="has-imbroa" select="//imvert:attribute/imvert:stereotype/@id = 'stereotype-name-imbroa'"/>
    
    <xsl:variable name="derived-props-order" select="$configuration-docrules-file/derived-props-order"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:sequence select="imf:track('Generating modeldoc',())"/>
        
        <book name="{imvert:application}" subpath="{$subpath}" type="{imvert:stereotype}" id="{imvert:id}" generator-version="{$imvertor-version}" generator-date="{$generation-date}">
            
            <!-- call a general initialization function -->
            <xsl:sequence select="imf:initialize-modeldoc()"/>

            <chapter title="CHAPTER-CATALOG" type="cat">
                <xsl:variable name="sections" as="element()*">
                    <section type="MODEL" name="{imf:plugin-get-model-name(.)}" id="{imf:plugin-get-link-name(.,'global')}">
                        <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
                        <section type="OVERVIEW-MODEL">
                            <content>
                                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-MODEL')"/>
                            </content>
                        </section>
                    </section>
                    <!-- exclude package replacements (resolved stereotype internal) -->
                    <xsl:apply-templates select="imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package','stereotype-name-view-package') and empty(imvert:package-replacement)]"/>
                </xsl:variable>
                <xsl:apply-templates select="$sections" mode="section-cleanup"/>    
            </chapter>
            
            <xsl:if test="$lists-to-listing">
                <xsl:variable name="domain-packages" select="imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package','stereotype-name-view-package') and empty(imvert:package-replacement)]"/>

                <xsl:where-populated>
                    <chapter title="CHAPTER-LISTS" type="lis">
                        <xsl:where-populated>
                            <section type="CONTENTS-REFERENCELIST">
                                <xsl:apply-templates select="$domain-packages/imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]" mode="content"/>
                            </section>
                        </xsl:where-populated>
                        <xsl:where-populated>
                            <section type="CONTENTS-CODELIST">
                                <xsl:apply-templates select="$domain-packages/imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]" mode="content"/>
                            </section>
                        </xsl:where-populated>
                        <xsl:where-populated>
                            <section type="CONTENTS-ENUMERATION">
                                <xsl:apply-templates select="$domain-packages/imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]" mode="content"/>
                            </section>
                        </xsl:where-populated>
                    </chapter>
                </xsl:where-populated>
            </xsl:if>
            
        </book>
    </xsl:template>
    
    <xsl:template match="imvert:package"><!-- only domain or view packs -->
        <section type="DOMAIN" name="{imf:plugin-get-model-name(.)}" id="{imf:plugin-get-link-name(.,'global')}">
            
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            
            <xsl:variable name="include-overview-section-level" select="imf:boolean($configuration-docrules-file/include-overview-section-level)"/>
            <xsl:variable name="include-detail-section-level" select="imf:boolean($configuration-docrules-file/include-detail-section-level)"/>
         
            <xsl:variable name="include-overview-sections-by-type" select="imf:boolean($configuration-docrules-file/include-overview-sections-by-type)"/>
            <xsl:variable name="include-detail-sections-by-type" select="imf:boolean($configuration-docrules-file/include-detail-sections-by-type)"/>
            
            <xsl:variable name="sections" as="element(section)*">
                <section type="OVERVIEW" include="{$include-overview-section-level}">
                    <section type="OVERVIEW-OBJECTTYPE" include="{$include-overview-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype','stereotype-name-koppelklasse')]"/>
                    </section>
                    <section type="OVERVIEW-ASSOCIATIONCLASS" include="{$include-overview-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]"/>
                    </section>
                    <section type="OVERVIEW-REFERENCELIST" include="{$include-overview-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]"/>
                    </section>
                    <section type="OVERVIEW-UNION" include="{$include-overview-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]"/>
                    </section>
                    <section type="OVERVIEW-COMPOSITION" include="{$include-overview-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]"/>
                    </section>
                    <section type="OVERVIEW-STRUCTUREDDATATYPE" include="{$include-overview-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]"/>
                    </section>
                    <section type="OVERVIEW-PRIMITIVEDATATYPE" include="{$include-overview-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]"/>
                    </section>
                    <section type="OVERVIEW-CODELIST" include="{$include-overview-sections-by-type}">
                        <content>
                            <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]"/>
                        </content>
                    </section>
                    <section type="OVERVIEW-ENUMERATION" include="{$include-overview-sections-by-type}">
                        <content>
                            <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]"/>
                        </content>
                    </section>
                </section>
                <section type="DETAILS" include="{$include-detail-section-level}">
                    <section type="DETAILS-OBJECTTYPE" include="{$include-detail-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype','stereotype-name-koppelklasse')]" mode="detail"/>
                    </section>
                    <section type="DETAILS-COMPOSITE" include="{$include-detail-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]" mode="detail"/>
                    </section>
                    <section type="DETAILS-ASSOCIATIONCLASS" include="{$include-detail-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]" mode="detail"/>
                    </section>
                    <section type="DETAILS-UNION" include="{$include-detail-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]" mode="detail"/>
                    </section>
                    <section type="DETAILS-STRUCTUREDDATATYPE" include="{$include-detail-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]" mode="detail"/>
                    </section>
                    <section type="DETAILS-PRIMITIVEDATATYPE" include="{$include-detail-sections-by-type}">
                        <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]" mode="detail"/>
                    </section>
                    <xsl:if test="not($lists-to-listing)">
                        <section type="DETAILS-REFERENCELIST" include="{$include-detail-sections-by-type}">
                            <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]" mode="detail"/>
                        </section>
                        <section type="DETAILS-CODELIST" include="{$include-detail-sections-by-type}">
                            <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]" mode="detail"/>
                        </section>
                        <section type="DETAILS-ENUMERATION" include="{$include-detail-sections-by-type}">
                            <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]" mode="content"/>
                        </section>
                    </xsl:if>
                </section>
            </xsl:variable>
            <xsl:apply-templates select="$sections" mode="section-include"/>
        </section>
   
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype','stereotype-name-koppelklasse')]">
        <section name="{imf:get-name(.,true())}" type="OBJECTTYPE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
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

    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]">
        <section name="{imf:get-name(.,true())}" type="ASSOCIATIONCLASS" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
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
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]">
        <section name="{imf:get-name(.,true())}" type="REFERENCELIST" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-REFERENCELIST')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
   
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]">
        <section name="{imf:get-name(.,true())}" type="UNION" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-UNION')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]">
        <section name="{imf:get-name(.,true())}" type="STRUCTUREDDATATYPE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-STRUCTUREDDATATYPE')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]">
        <section name="{imf:get-name(.,true())}" type="PRIMITIVEDATATYPE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-PRIMITIVEDATATYPE')"/>
            </content>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
  
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist')]">
        <xsl:variable name="naam" select="imf:get-name(.,true())"/>
        <part>
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <item id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
                <xsl:sequence select="imf:create-idref(.,'detail')"/>
                <xsl:sequence select="imf:create-content($naam)"/>          
            </item>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
        </part>
     </xsl:template>

    <!-- uitzondering: gegevensgroeptype wordt apart getoond. -->
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]">
        <section name="{imf:get-name(.,true())}" type="COMPOSITE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
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
        
        <xsl:variable name="attribute-kind" select="
            if (../imvert:stereotype/@id = ('stereotype-name-complextype')) then 'D' 
            else if (../imvert:stereotype/@id = ('stereotype-name-union')) then 'U'
            else if (../imvert:stereotype/@id = ('stereotype-name-referentielijst')) then 'R'
            else 'A'"/>
        
            <!-- (D)ata element or (U)nion element or (A)ttribute -->
        
        <xsl:variable name="r" as="element()*">
            <xsl:choose>
                <xsl:when test="imf:get-config-stereotypes('stereotype-name-association-to-composite') = '#unknown'">
                    <!-- attribuut groepen zijn als attribuut opgenomen. -->
                    <xsl:apply-templates select="imvert:attribute[not(imvert:stereotype/@id = ('stereotype-name-attributegroup'))]" mode="#current"/>
                    <!-- als de class ook gegevensgroepen heeft, die attributen hier invoegen -->
                    <xsl:for-each select="imvert:attribute[imvert:stereotype/@id = ('stereotype-name-attributegroup')]">
                        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                        <xsl:if test="$defining-class[imvert:stereotype/@id = ('stereotype-name-composite')]">
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
                        <xsl:if test="$defining-class[imvert:stereotype/@id = ('stereotype-name-composite')]">
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
            <xsl:choose>
                <xsl:when test="$attribute-kind = 'A'">
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
                </xsl:when>
                <xsl:when test="$attribute-kind = 'U'">
                    <section type="SHORT-UNIONELEMENTS">
                        <content>
                            <itemtype/>
                            <itemtype type="UNIONELEMENT-NAME"/>
                            <itemtype type="UNIONELEMENT-DEFINITION"/>
                            <itemtype type="UNIONELEMENT-FORMAT"/>
                            <itemtype type="UNIONELEMENT-CARD"/>
                            <!-- and add rows -->
                            <xsl:sequence select="$r"/>
                        </content>
                    </section>
                </xsl:when>
                <xsl:when test="$attribute-kind = 'R'">
                    <section type="SHORT-REFERENCEELEMENTS">
                        <content>
                            <itemtype/>
                            <itemtype type="REFERENCEELEMENT-NAME"/>
                            <itemtype type="REFERENCEELEMENT-DEFINITION"/>
                            <itemtype type="REFERENCEELEMENT-FORMAT"/>
                            <itemtype type="REFERENCEELEMENT-CARD"/>
                            <!-- and add rows -->
                            <xsl:sequence select="$r"/>
                        </content>
                    </section>
                </xsl:when>
                <xsl:otherwise>
                    <section type="SHORT-DATAELEMENTS">
                        <content>
                            <itemtype/>
                            <itemtype type="DATAELEMENT-NAME"/>
                            <itemtype type="DATAELEMENT-DEFINITION"/>
                            <itemtype type="DATAELEMENT-FORMAT"/>
                            <itemtype type="DATAELEMENT-CARD"/>
                            <!-- and add rows -->
                            <xsl:sequence select="$r"/>
                        </content>
                    </section>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="short">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
       <part>
           <xsl:sequence select="imf:calculate-node-position(.)"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imf:get-name(.,true())))"/> 
           <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
       </part>
    </xsl:template>

    <xsl:template match="imvert:attribute" mode="gegevensgroeptype">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
       <part type="COMPOSED">
           <xsl:sequence select="imf:calculate-node-position(.)"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imf:get-name(.,true())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
          <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
   
    <xsl:template match="imvert:association" mode="gegevensgroeptype-as-attribute">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <part type="COMPOSED">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imf:get-name(.,true())))"/>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
            <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imvert:type-name/@original,false())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:attribute | imvert:association" mode="composition">
        <!-- toon alsof het een attribuut is -->
        <xsl:variable name="type" select="imf:get-construct-by-id(imvert:type-id)"/>
        <part type="COMPOSER">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <item>
              <xsl:variable name="attname" select="imf:get-name(.,true())"/>
              <xsl:variable name="typname" select="imf:get-name($type,true())"/>
              <xsl:variable name="name" select="if ($reveal-composition-name) then concat($attname,' (', $typname, ')') else ($attname)"/>
              <xsl:sequence select="imf:create-link(.,'detail',$name)"/>
          </item>
          <item>
              <xsl:sequence select="imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION')"/>
          </item>
          <item>
              <xsl:variable name="typname" select="imf:get-name($type,true())"/>
              <xsl:sequence select="imf:create-link($type,'detail',$typname)"/>
          </item>
          <item>
             <xsl:sequence select="imf:get-cardinality(imvert:min-occurs,imvert:max-occurs)"/>
          </item>
       </part>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="type-relations">
        <xsl:variable name="r1" as="element()*">
            <xsl:apply-templates select="imvert:supertype" mode="short"/>
        </xsl:variable>
        <xsl:if test="exists($r1)">
            <section type="SHORT-TYPERELATIONS">
                <content approach="association">
                    <itemtype/>
                    <itemtype type="SUPERTYPE-NAME"/>
                    <itemtype type="SUPERTYPE-DEFINITION"/>
                    <xsl:sequence select="$r1"/>
                </content>
                <content approach="target">
                    <itemtype/>
                    <itemtype type="SUPERTYPE-NAME"/>
                    <itemtype type="SUPERTYPE-DEFINITION"/>
                    <xsl:sequence select="$r1"/>
                </content>
            </section>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:associations" mode="short gegevensgroeptype">
        <xsl:variable name="id" select="../imvert:id"/>
        <xsl:variable name="incoming-assocs" select="root(.)//imvert:association[imvert:type-id = $id]"/>
        <xsl:variable name="incoming-assocs-non-recursive" select="$incoming-assocs[../../imvert:id ne $id]"/>
        
        <xsl:variable name="r1" as="element()*">
            <xsl:apply-templates select="imvert:association[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]" mode="#current">
                <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
            </xsl:apply-templates>
            <xsl:if test="$include-incoming-associations">
                <xsl:apply-templates select="$incoming-assocs-non-recursive[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]" mode="#current">
                    <xsl:with-param name="incoming" select="true()"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:apply-templates select="../imvert:supertype" mode="#current"/>
        </xsl:variable>
        <xsl:variable name="r2" as="element()*">
            <xsl:apply-templates select="imvert:association[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]/imvert:target" mode="#current">
                <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
            </xsl:apply-templates>
            <xsl:if test="$include-incoming-associations">
                <xsl:apply-templates select="$incoming-assocs-non-recursive[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]/imvert:target" mode="#current">
                    <xsl:with-param name="incoming" select="true()"/>
                </xsl:apply-templates>
            </xsl:if>
            <xsl:apply-templates select="../imvert:supertype" mode="#current"/>
        </xsl:variable>
        
        <xsl:if test="exists(($r1,$r2))">
            <section type="SHORT-ASSOCIATIONS">
                <content approach="association">
                    <itemtype/>
                    <itemtype type="ASSOCIATION-NAME"/>
                    <itemtype type="ASSOCIATION-DEFINITION"/>
                    <xsl:sequence select="$r1"/>
                </content>
                <content approach="target">
                    <itemtype/>
                    <itemtype type="ROLE-NAME"/>
                    <itemtype type="ROLE-DEFINITION"/>
                    <xsl:sequence select="$r2"/>
                </content>
            </section>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="short gegevensgroeptype">
        <xsl:param name="incoming" as="xs:boolean" select="false()"/>
        
        <xsl:variable name="type" select="imf:get-construct-by-id(imvert:type-id)"/>
        <part>
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <item>
                <!--
                Voorbeeld: ZAAKTYPE [1..*] heeft relevant BESLUITTYPE [0..*]
                
                maar kan ook een rol betreffen
                -->
                <xsl:variable name="relation" select="imvert:name"/>
                <xsl:variable name="target" select="imvert:target/imvert:role"/>
                <xsl:variable name="relation-original-name" select="if (exists($relation) and exists($target)) then concat($relation/@original,': ',$target/@original) else ($relation/@original,$target/@original)"/>
                
                <xsl:sequence select="imf:create-element('item',if ($incoming) then imf:create-link(../..,'global',../../imvert:name/@original) else string(../../imvert:name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs-source,imvert:max-occurs-source),']'))"/>
                <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',$relation-original-name))"/>
                <xsl:sequence select="imf:create-element('item',if ($incoming) then string(imvert:type-name/@original) else imf:create-link($type,'global',imvert:type-name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs),']'))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
            
        </part>
    </xsl:template>
  
    <xsl:template match="imvert:association/imvert:target" mode="short gegevensgroeptype">
        <xsl:param name="incoming" as="xs:boolean" select="false()"/>
     
        <xsl:variable name="type" select="imf:get-construct-by-id(../imvert:type-id)"/>
        <part>
            <item>
                <!--
                    De weergave van de informtie mbt een target role
                -->
                <xsl:variable name="relation" select="../imvert:name"/>
                <xsl:variable name="target" select="imvert:role"/>
                <xsl:variable name="relation-original-name" select="if (exists($relation) and exists($target)) then concat($relation/@original,': ',$target/@original) else ($relation/@original,$target/@original)"/>
                
                <xsl:sequence select="imf:create-element('item',if ($incoming) then imf:create-link(../../..,'global',../../../imvert:name/@original) else string(../../../imvert:name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(../imvert:min-occurs-source,../imvert:max-occurs-source),']'))"/>
                <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',$relation-original-name))"/>
                <xsl:sequence select="imf:create-element('item',if ($incoming) then string(../imvert:type-name/@original) else imf:create-link($type,'global',../imvert:type-name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(../imvert:min-occurs,../imvert:max-occurs),']'))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
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
                    <xsl:value-of select="imf:get-name(..,true())"/>
                </item>
                <item>
                    <xsl:value-of select="imf:plugin-translate-i3n('ISSPECIALISATIONOF',true())"/>
                </item>
                <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',(imvert:type-name/@original,string(imvert:conceptual-schema-type))[1]))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value($type,'CFG-TV-DEFINITION'))"/>
        </part>
    </xsl:template>
    
    <!-- Stel detailinfo samen voor een objecttype, relatieklasse, enumeratie -->
    <xsl:template match="imvert:class" mode="detail">
        <section name="{imf:get-name(.,true())}" type="{imvert:stereotype[1]}" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            
            <xsl:variable name="associations" select="imvert:associations/imvert:association"/>
            <xsl:variable name="compositions" select="$associations[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]"/>
          
            <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
            <xsl:for-each select="$compositions">
                <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                <xsl:apply-templates select="$defining-class" mode="detail"/>
                <!--<xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="detail"/>-->
            </xsl:for-each>
            <xsl:apply-templates select="($associations except $compositions)" mode="detail">
                <xsl:sort select="imf:calculate-position(.)" data-type="number" order="ascending"/>
            </xsl:apply-templates>       
        
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist','stereotype-name-enumeration')]" mode="content">
        <xsl:variable name="is-codelist" select="imvert:stereotype/@id = ('stereotype-name-codelist')"/>
        <!-- 
            All BRO tables are IMBRO/A tables, holding 4 columns.
            When all values are imbro/a this is redundant info, so in that case we do not add the IMBRO/A coumns.
        -->
        <xsl:variable name="is-imbro-list" select="(imf:get-config-string('cli','owner') eq 'BRO') and $has-imbroa"/>
        <!-- Check if ANY value has an alias, in that case assume a code column should be added -->
        <xsl:variable name="has-code" select="exists(imvert:attributes/imvert:attribute/imvert:alias)"/>
        <section 
            name="{imf:get-name(.,true())}" 
            type="{if ($is-codelist) then 'DETAIL-CODELIST' else 'DETAIL-ENUMERATION'}" 
            id="{imf:plugin-get-link-name(.,'detail')}" 
            id-global="{imf:plugin-get-link-name(.,'global')}" 
            uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <part>
                    <?x <xsl:sequence select="imf:create-element('item',imf:plugin-translate-i3n('DEFINITIE',true()))"/> x?>
                    <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
                </part>
            </content>
            <content>
                <xsl:choose>
                    <xsl:when test="$is-imbro-list and $has-code">
                        <itemtype type="CODE"/>
                        <itemtype type="VALUE"/>
                        <itemtype type="IMBRO"/>
                        <itemtype type="IMBROA"/>
                        <itemtype type="DEFINITION"/>
                        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie">
                            <xsl:with-param name="is-imbroa" select="true()"/>
                            <xsl:with-param name="is-coded" select="true()"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="$is-imbro-list">
                        <itemtype type="VALUE"/>
                        <itemtype type="IMBRO"/>
                        <itemtype type="IMBROA"/>
                        <itemtype type="DEFINITION"/>
                        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie">
                            <xsl:with-param name="is-imbroa" select="true()"/>
                            <xsl:with-param name="is-coded" select="false()"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="$has-code">
                        <itemtype type="CODE"/>
                        <itemtype type="VALUE"/>
                        <itemtype type="DEFINITION"/>
                        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie">
                            <xsl:with-param name="is-imbroa" select="false()"/>
                            <xsl:with-param name="is-coded" select="true()"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <itemtype type="VALUE"/>
                        <itemtype type="DEFINITION"/>
                        <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie">
                            <xsl:with-param name="is-imbroa" select="false()"/>
                            <xsl:with-param name="is-coded" select="false()"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </content>
        </section>
    </xsl:template>
  
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]" mode="content">
        <xsl:variable name="is-imbro-list" select="imf:get-config-string('cli','owner') eq 'BRO'"/>
        <section 
            name="{imf:get-name(.,true())}" 
            type="DETAIL-REFERENCELIST" 
            id="{imf:plugin-get-link-name(.,'detail')}" 
            id-global="{imf:plugin-get-link-name(.,'global')}" 
            uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <part>
                    <item>
                        <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
                        <item>
                            <ol>
                                <xsl:for-each select="imvert:attributes/imvert:attribute">
                                    <xsl:variable name="is-id-text" select="if (imf:boolean(imvert:is-id)) then imf:plugin-translate-i3n('REFERENCEELEMENT-IS-ID',true()) else ''"/>
                                    <xsl:variable name="def" select="imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION')"/>
                                    <li>
                                        <b><xsl:value-of select="imvert:name/@original"/></b>
                                        <xsl:value-of select="$is-id-text"/>
                                        <xsl:text>: </xsl:text>
                                        <xsl:for-each select="$def"><!-- opgebouwd uit paragrafen -->
                                            <xsl:sequence select="node()"/>
                                            <xsl:if test="position() ne last()">
                                                <br/>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </li>
                                </xsl:for-each>
                            </ol>
                        </item>
                    </item>
                </part>
            </content>
            <content>
                <!-- the attributes are the names of the reference list columns. -->
                <xsl:for-each select="imvert:attributes/imvert:attribute">
                    <itemtype type="LABEL" name="{imvert:name}" is-id="{imf:boolean(imvert:is-id)}">
                        <xsl:value-of select="imvert:name/@original"/>
                    </itemtype>
                </xsl:for-each>
                <!-- and the add the columns for this reference list -->
                <xsl:apply-templates select="imvert:attributes/imvert:refelement" mode="detail-refelement"/>
            </content>
        </section>
    </xsl:template>
    
    <?x
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]" mode="detail">
        
        <section name="{imf:get-name(.,true())}" type="DETAIL-COMPOSITE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
            <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
            <xsl:apply-templates select="imvert:associations/imvert:association" mode="detail"/>
        </section>
  
    </xsl:template>
    x?>
    
    <xsl:template match="imvert:attribute" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <xsl:variable name="naam" select="imf:get-name($construct,true())"/>
        <xsl:choose>
            <xsl:when test="$defining-class/imvert:stereotype/@id = ('stereotype-name-composite')">
                <xsl:apply-templates select="." mode="detail-gegevensgroeptype"/>
                <xsl:apply-templates select="$defining-class" mode="detail"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-referentie-element')">
                <xsl:apply-templates select="." mode="detail-referentie-element"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-union')">
                <xsl:apply-templates select="." mode="detail-union"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-union-element')">
                <xsl:apply-templates select="." mode="detail-unionelement"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-data-element')">
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
        <section name="{imf:get-name(.,true())}" type="DETAIL-ATTRIBUTE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-ATTRIBUTE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>       
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-enumeratie">
        <xsl:param name="is-imbroa" as="xs:boolean"/>
        <xsl:param name="is-coded" as="xs:boolean"/>
        <part>
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:if test="$is-coded">
                <xsl:sequence select="imf:create-element('item',imvert:alias)"/>
            </xsl:if>
            <xsl:sequence select="imf:create-element('item',imf:get-name(.,true()))"/>
            <xsl:if test="$is-imbroa">
                <xsl:sequence select="imf:create-element('item',if (imvert:stereotype/@id = ('stereotype-name-imbroa')) then '' else '&#x2714;')"/>
                <xsl:sequence select="imf:create-element('item','&#x2714;')"/>
            </xsl:if>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:refelement" mode="detail-refelement">
        <part>
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <xsl:for-each select="imvert:element">
                <xsl:sequence select="imf:create-element('item',string(.))"/>
            </xsl:for-each>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-COMPOSITE-ATTRIBUTE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', imf:get-name($construct,true()))"/>
                </part>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE-ATTRIBUTE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-referentie-element">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-REFERENCEELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-REFERENCEELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-unionelement"><!-- het attribuut representeert een optie binnen een keuze -->
        <xsl:variable name="construct" select="../.."/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-UNIONELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-UNIONELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-union"><!-- het attribuut representeert een keuze -->
        <xsl:variable name="construct" select="../.."/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-UNION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-UNION')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-dataelement">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-DATAELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-DATAELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
  
    <xsl:template match="imvert:association" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:choose>
            <xsl:when test="$construct/imvert:stereotype/@id = ('stereotype-name-composite')">
                <xsl:apply-templates select="." mode="detail-gegevensgroeptype"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-externekoppeling')">
                <xsl:apply-templates select="." mode="detail-externekoppeling"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="detail-normal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-normal">
     
        <section name="{imf:get-name(.,true())}" type="DETAIL-ASSOCIATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:if test="imvert:original-stereotype"><!-- https://github.com/Imvertor/Imvertor-Maven/issues/147 -->
                <xsl:attribute name="original-stereotype-id" select="imvert:original-stereotype/@id"/>                
            </xsl:if>
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content approach="association">
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-ASSOCIATION')"/>
            </content>
            <content approach="target">
                <xsl:sequence select="imf:create-parts-cfg(imvert:target,'DISPLAY-DETAIL-ASSOCIATION')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(imvert:target,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-COMPOSITE-ASSOCIATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <?x
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', imf:get-name($construct,true()))"/>
                </part>
                ?>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE-ASSOCIATION')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
        
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-externekoppeling">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-EXTERNEKOPPELING" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <xsl:sequence select="imf:calculate-node-position(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-EXTERNEKOPPELING')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
        
    </xsl:template>
    
    <xsl:function name="imf:get-formatted-tagged-value" as="item()*">        
        <xsl:param name="this" />
        <xsl:param name="tv-id"/>
        
        <xsl:variable name="tv-element" select="imf:get-most-relevant-compiled-taggedvalue-element($this,concat('##',$tv-id))"/>
        <xsl:choose>
            <xsl:when test="exists($tv-element)">
                <xsl:variable name="default-value" select="$configuration-tvset-file//tagged-values/tv[@id = $tv-id]/declared-values/value[imf:boolean(@default)]"/>
                <xsl:variable name="value" select="if ($tv-element) then imf:get-clean-documentation-string(imf:get-tv-value($tv-element)) else $default-value"/>
                <xsl:sequence select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- terugval optie: afgeleide tagged values niet beschikbaar voor lijstwaarden uitgelezen uit externe bronnen (modeldoc-lists) --> 
                <xsl:variable name="tv-element-local" select="imf:get-tagged-value($this,concat('##',$tv-id))"/>
                <xsl:value-of select="$tv-element-local"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-formatted-tagged-value-cfg" as="item()*">        
        <xsl:param name="level"/>
        <xsl:param name="this"/>
        <xsl:param name="tv-id"/>
        <xsl:choose>
            <xsl:when test="$level/@compile = 'full'">
                <xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,false())" as="element(tv)*"/>
                <xsl:variable name="vals" select="$all-tv[@id = $tv-id]"/>
                
                <!-- ontdubbelen -->
                <xsl:variable name="vals-single" as="element(tv)*">
                    <xsl:for-each-group select="$vals" group-by="lower-case(normalize-space(.))">
                        <xsl:sequence select="current-group()[1]"/>
                    </xsl:for-each-group>
                </xsl:variable>
                
                <xsl:variable name="vals-single-ordered" as="element(tv)*">
                    <xsl:choose>
                        <xsl:when test="$derived-props-order eq 'current-model'">
                            <xsl:sequence select="$vals-single[1]"/>
                        </xsl:when>
                        <xsl:when test="$derived-props-order eq 'supplier-client'">
                            <xsl:sequence select="reverse($vals-single)"/>
                        </xsl:when>
                        <xsl:otherwise><!-- client-supplier -->
                            <xsl:sequence select="$vals-single"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:for-each select="$vals-single-ordered">
                    <item type="TRACED">
                        <item type="SUPPLIER">
                            <xsl:value-of select="imf:get-subpath(@project,@application,@release)"/>
                        </item>
                        <item>
                            <xsl:sequence select="imf:get-clean-documentation-string(imf:get-tv-value(.))"/>
                        </item>
                    </item>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tv-element" select="imf:get-most-relevant-compiled-taggedvalue-element($this,concat('##',$tv-id))"/>
                <xsl:sequence select="imf:get-clean-documentation-string(imf:get-tv-value($tv-element))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-unieke-aanduiding">
        <xsl:param name="this"/>
        <xsl:variable name="id-attribute" select="$this/imvert:attributes/imvert:attribute[imf:boolean(imvert:is-id)]"/>
        <xsl:sequence select="string-join(for $i in $id-attribute return imf:get-name($i,true()),' + ')"/>
        <!-- hieronder uitwerking van #263 -->
        <xsl:if test="imf:boolean($configuration-docrules-file/identifying-attribute-with-context)">
            <xsl:variable name="subtypes-with-id" select="imf:get-subclasses($this)[imvert:attributes/imvert:attribute/imvert:is-id = 'true']"/>
            <xsl:variable name="supertypes-with-id" select="imf:get-superclasses($this)[imvert:attributes/imvert:attribute/imvert:is-id = 'true']"/>
            <xsl:if test="$id-attribute and exists($subtypes-with-id)">
                <xsl:sequence select="imf:get-tagged-value-unieke-aanduiding-text($subtypes-with-id,'sub')"/>
            </xsl:if>
            <xsl:if test="$id-attribute and exists($supertypes-with-id)">
                <xsl:sequence select="imf:get-tagged-value-unieke-aanduiding-text($supertypes-with-id,'super')"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-indicatie-identificerend">
        <xsl:param name="this"/>
        <!-- hieronder uitwerking van #263 -->
        <xsl:if test="imf:boolean($configuration-docrules-file/identifying-attribute-with-context)">
            <xsl:variable name="subtypes-with-id" select="imf:get-subclasses($this)[imvert:attributes/imvert:attribute/imvert:is-id = 'true']"/>
            <xsl:variable name="supertypes-with-id" select="imf:get-superclasses($this)[imvert:attributes/imvert:attribute/imvert:is-id = 'true']"/>
            <xsl:if test="exists($subtypes-with-id)">
                <xsl:sequence select="imf:get-tagged-value-unieke-aanduiding-text($subtypes-with-id,'sub')"/>
            </xsl:if>
            <xsl:if test="exists($supertypes-with-id)">
                <xsl:sequence select="imf:get-tagged-value-unieke-aanduiding-text($supertypes-with-id,'super')"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-unieke-aanduiding-text">
        <xsl:param name="types-with-id" as="element()+"/>
        <xsl:param name="sub-or-super" as="xs:string"/>
        <item type="ISIDTEXT">
            <xsl:choose>
                <xsl:when test="$sub-or-super = 'sub'">
                    <xsl:text>In combinatie met de unieke aanduiding van de </xsl:text>
                    <xsl:sequence select="if ($types-with-id[2]) then 'specialisaties' else 'specialisatie'"/>
                    <xsl:text> </xsl:text>
                    <xsl:for-each select="$types-with-id">
                        <item>
                            <xsl:sequence select="imf:create-idref(.,'global')"/>
                            <xsl:sequence select="imf:create-content(imvert:name/@original)"/>          
                        </item>
                        <xsl:if test="position() ne last()"> en </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:text>In combinatie met de unieke aanduiding van de </xsl:text>
                        <xsl:sequence select="if ($types-with-id[2]) then 'generalisaties' else 'generalisatie'"/>
                        <xsl:text> </xsl:text>
                        <xsl:for-each select="$types-with-id">
                            <item>
                                <xsl:sequence select="imf:create-idref(.,'global')"/>
                                <xsl:sequence select="imf:create-content(imvert:name/@original)"/>          
                            </item>
                            <xsl:if test="position() ne last()"> en </xsl:if>
                        </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </item>
    </xsl:function>
    
   <xsl:function name="imf:create-part-2" as="element(part)*"> 
       <xsl:param name="level" as="element(level)"/>
       <xsl:param name="waarde" as="item()*"/>
     
       <xsl:variable name="doc-rule" select="$level/../.."/>
       
       <xsl:variable name="name" select="$doc-rule/name"/> 
       <xsl:variable name="doc-rule-id" select="$doc-rule/@id"/>
       
       <xsl:variable name="show" select="$level/@show"/> <!-- force, implied, none, or missing -->
       <xsl:variable name="compile" select="$level/@compile"/> <!-- single or full -->
       <xsl:variable name="format" select="$level/@format"/> <!-- plain or ? -->
       
       <xsl:variable name="exists-waarde" select="imf:is-content($waarde)"/>
       
       <xsl:variable name="display-waarde" as="item()*">
           <xsl:choose>
               <xsl:when test="$show-properties = 'config' and $show = 'none'">
                   <!-- skip; this is forced by the configuration -->
               </xsl:when>
               <xsl:when test="$exists-waarde">
                   <xsl:sequence select="$waarde"/> <!-- show in all cases when waarde exists -->
               </xsl:when>
               <xsl:when test="$show-properties = 'config' and $show = 'force'">
                   <xsl:sequence select="($waarde,' ')"/> <!-- show in all cases -->
               </xsl:when>
               <xsl:when test="$show-properties = 'config' and $show = 'implied' and not($exists-waarde)">
                   <!-- skip -->
               </xsl:when>
               <xsl:when test="$show-properties = 'config' and $show = 'missing' and not($exists-waarde)">
                   <xsl:value-of select="'MISSING'"/>
               </xsl:when>
               <xsl:when test="$show-properties = 'all' and not($exists-waarde)">
                   <xsl:sequence select="'&#160;'"/><!-- force the value entry to be shown -->
               </xsl:when>  
               <xsl:otherwise>
                   <!-- no value to pass -->
               </xsl:otherwise>
           </xsl:choose>
       </xsl:variable>
   
       <xsl:if test="exists($display-waarde)">
           <part type="{$doc-rule-id}">
               <xsl:variable name="debug-string" select="if ($debugging) then '[id:' || $doc-rule-id || ']' else ''"/>
               <xsl:sequence select="imf:create-element('item',string($name) || $debug-string)"/>
               <xsl:choose>
                   <xsl:when test="$format = 'plain'">
                       <xsl:sequence select="imf:create-element('item',$display-waarde)"/>          
                   </xsl:when>
                   <xsl:when test="$format = 'math'">
                       <xsl:sequence select="imf:create-element('item',imf:math($display-waarde))"/>          
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:sequence select="imf:msg('FATAL','Unknown format: [1]',$format)"/>          
                   </xsl:otherwise>
               </xsl:choose>
           </part>
       </xsl:if> 
       
   </xsl:function>
  
    <xsl:function name="imf:create-parts-cfg" as="element(part)*">
        <xsl:param name="this" as="element()"/><!-- an imvert:* element -->
        <xsl:param name="level" as="xs:string"/> <!-- a description of what to show, see docrules. --> 
        
        <xsl:variable name="isrole" select="exists($this/self::imvert:target)"/>
        <xsl:variable name="relation" select="if ($isrole) then $this/.. else $this"/>
        
        <xsl:for-each select="$configuration-docrules-file/doc-rule/levels/level[. = $level]"><!-- a level in a docrule, i.e. indication of where the tagged value should be shown, for example "DISPLAY-GLOBAL-OBJECTTYPE" -->
           
            <xsl:variable name="doc-rule-id" select="../../@id"/>
            
            <xsl:choose>
                <!-- 
                    create and entry "name", "target role name" or "name: target role name" 
                -->
                <xsl:when test="$doc-rule-id = 'CFG-DOC-NORMNAAM'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-name($this,false()))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-NAAM'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-name($this,true()))"/>
                </xsl:when>
                <!-- 
                    remainder is specified on target or relation, as may be the case 
                -->
                <xsl:when test="$doc-rule-id = 'CFG-DOC-ALTERNATIEVENAAM'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-NAME'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MNEMONIC'">
                    <xsl:sequence select="imf:create-part-2(.,string($relation/imvert:alias))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-ATTRIBUTEDOMAIN'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DOMAIN'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-HERKOMST'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-SOURCE'))"/> 
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-BEGRIP'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-CONCEPT'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DEFINITIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DEFINITION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-HERKOMSTDEFINITIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-SOURCEOFDEFINITION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-TOELICHTING'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DESCRIPTION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UITLEG'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-EXPLANATION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-VOORBEELD'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-EXAMPLE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DATUMOPNAME'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DATERECORDED'))"/>
                </xsl:when>
                <?x
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNIEKEAANDUIDING'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-tagged-value-unieke-aanduiding($this))"/>
                </xsl:when>
                x?>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-POPULATIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-POPULATION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-KWALITEITSBEGRIP'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-QUALITY'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MOGELIJKGEENWAARDE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-VOIDABLE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-EXPLAINNOVALUE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-EXPLAINNOVALUE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEMATERIELEHISTORIE'">
                    <xsl:sequence select="if ($has-material-history) then imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIONMATERIALHISTORY')) else ()"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEFORMELEHISTORIE'">
                    <xsl:sequence select="if ($has-formal-history) then imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIONFORMALHISTORY')) else ()"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEINONDERZOEK'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIEINONDERZOEK'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-AANDUIDINGSTRIJDIGHEIDNIETIGHEID'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-AANDUIDINGSTRIJDIGHEIDNIETIGHEID'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNITOFMEASURE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-UNITOFMEASURE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MINVALUEINCLUSIVE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-MINVALUEINCLUSIVE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MAXVALUEINCLUSIVE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-MAXVALUEINCLUSIVE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEKARDINALITEIT'">
                    <xsl:variable name="min" select="$relation/imvert:min-occurs"/>
                    <xsl:variable name="max" select="$relation/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:get-cardinality($min,$max))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEAUTHENTIEK'">
                    <xsl:sequence select="imf:create-part-2(.,concat(imf:get-formatted-tagged-value($this,'CFG-TV-INDICATIONAUTHENTIC'), imf:authentiek-is-derived($this)))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-REGELS'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-RULES'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-REGELS-IMBROA'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-RULES-IMBROA'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DOMAIN-IMBROA'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DOMAIN-IMBROA'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNIEKEAANDUIDING'">
                    <xsl:variable name="rel-aanduiding" select="$relation/imvert:associations/imvert:association[(imvert:target | .)/imvert:stereotype/@id = ('stereotype-name-composite-id')][1]"/>
                    <xsl:variable name="con-aanduiding" select="imf:get-construct-by-id-for-office($rel-aanduiding/imvert:type-id)"/>
                    <xsl:variable name="id-aanduiding" select="imf:get-tagged-value-unieke-aanduiding($this)"/>
                    
                    <xsl:variable name="con" select="concat($relation/imvert:name/@original, ' ', $rel-aanduiding/imvert:name/@original, ' ', $con-aanduiding/imvert:name/@original)"/>
                    
                    <xsl:variable name="aanduiding">
                        <xsl:choose>
                            <xsl:when test="exists($rel-aanduiding) and exists($id-aanduiding)">
                                <xsl:sequence select="concat($id-aanduiding,', ', $con)"/>
                            </xsl:when>
                            <xsl:when test="exists($rel-aanduiding)">
                                <xsl:sequence select="string($con-aanduiding/imvert:name/@original)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="$id-aanduiding"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-part-2(.,$aanduiding)"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEABSTRACTOBJECT'">
                    <xsl:variable name="is-abstract-text" select="if (imf:boolean($relation/imvert:abstract)) then 'YES' else 'NO'"/>
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
                    <xsl:variable name="type" select="imf:get-construct-by-id-for-office($this/imvert:type-id)"/>
                    <!-- we hebben geen detailinfo over bepaalde datatypen, dus verwijs in de hyperlink naar globale datatypen --> 
                    <xsl:variable name="global-or-detail" select="if ($type/imvert:stereotype/@id = ('stereotype-name-simpletype')) then 'global' else 'detail'"/>
                    <xsl:variable name="formaat-type" select="if ($type) then imf:create-link($type,$global-or-detail,imf:get-name($type,true())) else ()"/>
                    <xsl:variable name="formaat-bare" select="imf:plugin-translate-i3n($relation/imvert:baretype,false())"/>
                    <xsl:sequence select="imf:create-part-2(., ($formaat-type,$formaat-bare)[1])"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-LENGTH'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-LENGTH'))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-RELATIESOORT'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-relatiesoort($relation))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-GERELATEERDOBJECTTYPE'">
                    <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office($relation/imvert:type-id)"/>
                    <xsl:choose>
                        <!-- als het een keuze klasse is, dan de gerelateerde objecten linken. -->
                        <xsl:when test="$defining-class/imvert:stereotype/@id = 'stereotype-name-union-associations'">
                            <xsl:variable name="links" as="element(item)">
                                <item>
                                    <item><xsl:value-of select="imf:plugin-translate-i3n('KEUZEUIT',false())"/></item>
                                    <xsl:for-each select="$defining-class/imvert:associations/imvert:association">
                                        <xsl:variable name="choice-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                                        <xsl:sequence select="imf:create-link($choice-class,'global',imvert:type-name/@original)"/>
                                        <xsl:if test="following-sibling::imvert:association">, </xsl:if>
                                    </xsl:for-each>
                                </item>
                            </xsl:variable>
                            <xsl:sequence select="imf:create-part-2(.,$links)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:create-part-2(.,imf:create-link($defining-class,'global',$relation/imvert:type-name/@original))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEAFLEIDBAAR'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-ISDERIVED'))"/>   
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-WAARDEAFLEIDBAAR'">
                    <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean($relation/imvert:is-value-derived)) then 'YES' else 'NO'"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:plugin-translate-i3n($is-afleidbaar-text,false()))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEIDENTIFICEREND'"> 
                    <xsl:choose>
                        <xsl:when test="imf:boolean($this/imvert:is-id)">
                            <xsl:variable name="class" select="$this/../.."/>
                            <xsl:sequence select="imf:create-part-2(.,(imf:plugin-translate-i3n('YES',false()),imf:get-tagged-value-indicatie-identificerend($class)))"/>        
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:create-part-2(.,(imf:plugin-translate-i3n('NO',false())))"/>        
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIECLASSIFICATIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIONCLASSIFICATION'))"/>         
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
    
    <xsl:function name="imf:authentiek-is-derived">
        <xsl:param name="this"/>
        <xsl:if test="imf:get-formatted-tagged-value($this,'derived') = '1'">
            <xsl:value-of select="' (is afgeleid)'"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-toelichting">
        <xsl:param name="documentatie"/>
        <xsl:if test="imf:is-content($documentatie) and $explanation-location = 'at-bottom'">
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
        <xsl:choose>
            <xsl:when test="empty($assoc-class)"><!-- relatieklasse zoals kadaster hanteert -->
                <!--
                <xsl:variable name="source-assoc" select="$document-classes//imvert:class/imvert:associations/imvert:association[imvert:type-id = $id]"/>
                <xsl:variable name="source-class" select="$source-assoc/../.."/>
                <xsl:variable name="target-assoc" select="imvert:associations/imvert:association[1]"/>
                <xsl:variable name="target-class" select="$document-classes//imvert:class[imvert:id = $target-assoc/imvert:type-id]"/>
                <xsl:value-of select="concat(
                    imf:get-name($source-class,true()), ' ',
                    imf:get-name($source-assoc,true()), ' ',
                    imf:get-name($relatieklasse,true()),' ',
                    imf:get-name($target-assoc,true()), ' ', 
                    imf:get-name($target-class,true()))"/>
                -->
                <xsl:value-of select="'TODO NAMING PATH'"/>
            </xsl:when>
            <xsl:otherwise><!-- echte associatieklasse -->
                <xsl:variable name="fromclass" select="$assoc-class/ancestor::imvert:class"/>
                <xsl:variable name="assoc" select="$assoc-class/.."/>
                <xsl:value-of select="concat(imf:get-name($fromclass,true()), ' ',imf:get-name($assoc,true()),' ',$assoc/imvert:type-name/@original)"/>
            </xsl:otherwise>
        </xsl:choose>
       
    </xsl:function>
    
    
    <xsl:function name="imf:create-link" as="element(item)*">
        <xsl:param name="this"/>
        <xsl:param name="type"/>
        <xsl:param name="label"/>
        <!--
            if the link is to an external type, insert catalog reference, otherwise insert a link to this documentation 
        -->
        <xsl:choose>
            <xsl:when test="exists($this/imvert:catalog) ">
                <item type="{$type}">
                    <xsl:sequence select="imf:create-external-idref($this)"/>
                    <xsl:sequence select="imf:create-external-content($label)"/>
                </item>
            </xsl:when>
            <xsl:otherwise>
                <item type="{$type}">
                    <xsl:sequence select="imf:create-idref($this,$type)"/>
                    <xsl:sequence select="imf:create-content($label)"/>
                </item>            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-by-id-for-office">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:if test="exists($id)">
            <xsl:sequence select="imf:get-construct-by-id($id)"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:create-element" as="element()">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:element name="{$name}">
            <xsl:sequence select="imf:create-content($content)"/>
        </xsl:element>
    </xsl:function>
    
    <xsl:function name="imf:create-content" as="item()*">
        <xsl:param name="content" as="item()*"/>
        <xsl:sequence select="if ($content instance of attribute()) then string($content) else $content"/>
    </xsl:function>
    
    <xsl:function name="imf:create-idref">
        <xsl:param name="construct"/>
        <xsl:param name="type"/><!-- global or detail -->
        <xsl:if test="$create-links and exists($construct)">
            <xsl:attribute name="idref" select="imf:plugin-get-link-name($construct,$type)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-external-content">
        <xsl:param name="content"/>
        <xsl:sequence select="if ($content instance of attribute()) then string($content) else $content"/>
    </xsl:function>

    <xsl:function name="imf:create-external-idref">
        <xsl:param name="construct"/>
        <xsl:if test="$create-links">
            <xsl:attribute name="idref" select="imf:plugin-get-external-link-name($construct)"/>
            <xsl:attribute name="idref-type" select="'external'"/>
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
    
    <!-- 
        return the link name. 
        when doc-rule: link-by is set to EAID, use the ID, else use the formal name. 
    -->
    <xsl:function name="imf:plugin-get-link-name">
        <xsl:param name="this"/>
        <xsl:param name="type"/> <!-- global or detail or graph; when graph always use the EAID -->
        <xsl:variable name="isrole" select="exists($this/self::imvert:target)"/>
        <xsl:variable name="construct" select="if ($isrole) then $this/.. else $this"/>
        <xsl:variable name="link-id" select="if ($type = 'graph' or $link-by-eaid) then $construct/imvert:id else $construct/@formal-name"/>
        <xsl:variable name="link-name" select="if ($link-id) then $link-id else generate-id($construct)"/>
        <xsl:sequence select="concat($type,'_',$link-name)"/>
    </xsl:function>
    
    <xsl:function name="imf:plugin-get-external-link-name">
        <xsl:param name="this"/>
        <xsl:value-of select="$this/imvert:catalog"/>
    </xsl:function>
    
    <!-- 
        return a section name for a model passed as a package 
    -->
    <xsl:function name="imf:plugin-get-model-name">
        <xsl:param name="construct" as="element()"/><!-- imvert:package or imvert:packages -->
        
        <xsl:value-of select="imf:get-name($construct,true())"/>
    </xsl:function>
    
    <xsl:function name="imf:initialize-modeldoc" as="item()*">
        <!-- stub: may be implemented by any modeldoc -->
    </xsl:function>
    
    <!-- geef de naam terug van de construct, en de target naam als het een associatie betreft. -->
    <xsl:function name="imf:get-name" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="original" as="xs:boolean"/>

        <xsl:variable name="isrole" select="exists($this/self::imvert:target)"/>
        
        <xsl:variable name="relation" select="if ($isrole) then $this/.. else $this"/>
        <xsl:variable name="target" select="if ($isrole) then $this else $this/imvert:target"/>
        
        <xsl:variable name="relation-name" select="$relation/imvert:name"/>
        <xsl:variable name="target-name" select="if (not($append-role-name)) then () else $target/imvert:role"/>
        
        <xsl:variable name="construct-name" select="if (exists($relation-name) and exists($target-name)) then concat($relation-name,': ',$target-name) else ($relation-name,$target-name)"/>
        <xsl:variable name="construct-original-name" select="if (exists($relation-name) and exists($target-name)) then concat($relation-name/@original,': ',$target-name/@original) else ($relation-name/@original,$target-name/@original)"/>
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="$original">
                    <xsl:value-of select="$construct-original-name"/>                
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$construct-name"/>                
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="normalize-space($name)">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg($this,'ERROR','Cannot determine the name of this construct',())"/>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:function>
    
    <xsl:function name="imf:get-tv-value" as="item()*">
       <xsl:param name="tv-element" as="element(tv)?"/>
       <xsl:variable name="val" select="if (normalize-space($tv-element/@original-value)) then $tv-element/@original-value else $tv-element/node()"/>
       <xsl:choose>
            <xsl:when test="imf:is-url(string-join($val,''))">
                <span>
                    <a href="{$val}" target="_blank">
                        <xsl:value-of select="$val"/>
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$val"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="imf:create-section-for-diagrams">
        <xsl:param name="construct"/> <!-- either the packages (=model) or a package or a class -->
        
        <xsl:variable name="insert-diagrams" select="imf:boolean(imf:get-config-string('cli','createimagemap'))"/> <!-- TODO dit moet beter, eiegnlijk een parameter in modeldoc config -->
        <xsl:variable name="diagrams-in-construct" select="$imagemap/imvert-imap:diagram[(imvert-imap:in-construct,imvert-imap:in-package)[1] = $construct/imvert:id]"/>
        <xsl:choose>
            <xsl:when test="$insert-diagrams and exists($diagrams-in-construct)">
                <section type="IMAGEMAPS" name="{imf:plugin-get-model-name($construct)}-imagemap" id="{imf:plugin-get-link-name($construct,'imagemap')}">
                    <xsl:for-each select="$diagrams-in-construct">
                        <xsl:if test="exists(imvert-imap:purpose)">
                            <section type="IMAGEMAP" name="{imvert-imap:name}" id="{imvert-imap:id}">
                               <xsl:choose>
                                   <xsl:when test="imf:boolean(imvert-imap:show-caption)">
                                       <content>
                                           <part type="CFG-DOC-NAAM">
                                               <item>
                                                   <xsl:value-of select="imf:plugin-translate-i3n('DIAGRAM-NAME',true())"/>
                                               </item>
                                               <item><xsl:value-of select="imvert-imap:name"/></item>
                                           </part>
                                           <part type="CFG-DOC-DESCRIPTION">
                                               <item>
                                                   <xsl:value-of select="imf:plugin-translate-i3n('DIAGRAM-DESCRIPTION',true())"/>
                                               </item>
                                               <item><xsl:sequence select="imvert-imap:documentation/node()"/></item>
                                           </part>
                                       </content>
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <empty/><!-- signals empty content; section will not be removed as "empty"--> 
                                   </xsl:otherwise>
                               </xsl:choose>
                            </section>    
                        </xsl:if>
                    </xsl:for-each>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <!-- no alternatives -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="imf:is-content" as="xs:boolean">
        <xsl:param name="content" as="item()*"/>
        <xsl:sequence select="imf:boolean-or(for $c in $content return if (normalize-space($c)) then true() else false())"/> 
    </xsl:function>
    
    <!-- return a physical position of the construct in the tree. a higher position value means furtheron in the sequence within that branch. Positions are 1...n. --> 
    <xsl:function name="imf:calculate-node-position" as="attribute(position)">
        <xsl:param name="this" as="element()"/>
        <xsl:attribute name="position" select="count($this/preceding-sibling::*) + 1"/>
    </xsl:function>
    
    <xsl:function name="imf:math" as="item()*"><!--https://github.com/Imvertor/Imvertor-Maven/issues/119 -->
        <xsl:param name="value" as="item()*"/>
        <xsl:for-each select="$value">
            <xsl:analyze-string select="." regex="([0-9\.]+)\*10\^(-?\d+)">
                <xsl:matching-substring>
                    <xsl:value-of select="concat(regex-group(1), '&#183;10')"/>
                    <sup>
                        <xsl:value-of select="regex-group(2)"/>
                    </sup>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:is-url" as="xs:boolean">
        <xsl:param name="url" as="xs:string?"/>
        <xsl:sequence select="matches($url,'^https?:')"/>
    </xsl:function>
    
    <!-- ======== remove the sections that have @include set to false (as configured) =========== -->
    
    <xsl:template match="section" mode="section-include">
        <xsl:choose>
            <xsl:when test="empty(@include)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="imf:boolean(@include)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>skipped excluded section</xsl:comment>
                <xsl:apply-templates select="section" mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ======== cleanup all section structure: remove empties =========== -->
    
    <xsl:template match="section" mode="section-cleanup">
        <xsl:choose>
            <xsl:when test="exists(.//item)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="exists(.//empty)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>removed empty content</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="section-cleanup section-include">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>    
    
    
</xsl:stylesheet>
