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

    <xsl:variable name="niet-herbruikbare-klassen" select="('Generalisatie','MEER?')" as="xs:string*"/>
    
    <xsl:template match="imvert:class" mode="mimformat">
        <xsl:comment>Processed class</xsl:comment>
        <xsl:copy>
            <xsl:apply-templates mode="#current"/>
            <xsl:if test="empty(imvert:stereotype)">
                <xsl:comment>Inserted stereo</xsl:comment>
                <imvert:stereotype id="stereotype-name-objecttype">OBJECTTYPE</imvert:stereotype>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:attributes" mode="mimformat">
        <xsl:variable name="supertypes" select="../imvert:supertype[imvert:type-package != 'OUTSIDE']"/>
        <xsl:copy>
            <!-- ID niet toekennen als al gedefinieerd op supertype, of als niet "herbruikbaar" -->
            <xsl:if test="empty($supertypes) and not(../imvert:name = $niet-herbruikbare-klassen)">
                <imvert:attribute>
                    <imvert:name original="id">id</imvert:name>
                    <imvert:is-id>true</imvert:is-id>
                    <imvert:static>false</imvert:static>
                    <imvert:baretype>Integer</imvert:baretype>
                    <imvert:type-name original="CharacterString">CharacterString</imvert:type-name>
                    <imvert:type-id>EAID_18BFBA8D_E3F4_4d8c_9A8F_4429FA54B041</imvert:type-id>
                    <imvert:type-package original="OUTSIDE">OUTSIDE</imvert:type-package>
                    <imvert:min-occurs>1</imvert:min-occurs>
                    <imvert:max-occurs>1</imvert:max-occurs>
                    <imvert:position>50</imvert:position><!-- positie van attributen is default 100 -->
                    <imvert:documentation>
                        <section>
                            <title>Definitie</title>
                            <body>
                                <text>
                                    <line>ID van de MIM format construct</line>
                                </text>
                            </body>
                        </section>
                    </imvert:documentation>
                    <imvert:stereotype id="stereotype-name-attribute">ATTRIBUUTSOORT</imvert:stereotype>
                </imvert:attribute>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="mimformat">
        <xsl:comment>Processed attribute</xsl:comment>
        <xsl:copy>
            <xsl:apply-templates mode="#current"/>
            <xsl:if test="empty(imvert:baretype)">
                <xsl:choose>
                    <xsl:when test="imvert:name = (
                        'indicatieAfleidbaar',
                        'indicatieClassificerend',
                        'indicatieMateriLeHistorie',
                        'indicatieFormeleHistorie',
                        'mogelijkGeenWaarde',
                        'identificerend'
                        )">
                        <imvert:baretype>Boolean</imvert:baretype>
                        <imvert:type-name original="Boolean">Boolean</imvert:type-name>
                        <imvert:type-id>EAID_70FBDB70_4B81_46ab_97BB_058195812ECB</imvert:type-id>
                        <imvert:type-package original="OUTSIDE">OUTSIDE</imvert:type-package>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:comment>Inserted type</xsl:comment>
                        <imvert:baretype>CharacterString</imvert:baretype>
                        <imvert:type-name original="CharacterString">CharacterString</imvert:type-name>
                        <imvert:type-id>EAID_18BFBA8D_E3F4_4d8c_9A8F_4429FA54B041</imvert:type-id>
                        <imvert:type-package original="OUTSIDE">OUTSIDE</imvert:type-package>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="empty(imvert:stereotype)">
                <xsl:choose>
                    <xsl:when test="false()"></xsl:when>
                    <xsl:otherwise>
                        <xsl:comment>Inserted stereo</xsl:comment>
                        <imvert:stereotype id="stereotype-name-attribute">ATTRIBUUTSOORT</imvert:stereotype>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>                
        </xsl:copy>
    </xsl:template>
    <xsl:template match="imvert:attribute/imvert:name" mode="mimformat">
        <xsl:comment>Processed attribute name</xsl:comment>
        <xsl:choose>
            <xsl:when test=". = 'identificatie'">
                <imvert:name original="{@original}">identificatie__F</imvert:name>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
                        
    <xsl:template match="imvert:association" mode="mimformat">
        <xsl:comment>Processed association</xsl:comment>
        <xsl:copy>
            <xsl:apply-templates mode="#current"/>
            <imvert:stereotype id="stereotype-name-relatiesoort">RELATIESOORT</imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:supertype" mode="mimformat">
        <xsl:comment>Processed supertype</xsl:comment>
        <xsl:copy>
            <xsl:apply-templates mode="#current"/>
            <xsl:choose>
                <xsl:when test="starts-with(imvert:type-name,'UML')">
                    <xsl:comment>Inserted stereo</xsl:comment>
                    <imvert:stereotype id="stereotype-name-static-generalization">STATIC</imvert:stereotype>
                </xsl:when>
                <xsl:otherwise>
                    <!-- niks -->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- verwijder constructies die de naam *__Z hebben -->
    <xsl:template match="*[ends-with(imvert:name,'__Z')]" mode="mimformat" priority="10">
        <!-- remove -->
    </xsl:template>
    
    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*" mode="mimformat">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>    
</xsl:stylesheet>
