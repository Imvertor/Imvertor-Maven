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
    
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:mim="http://www.geostandaarden.nl/mim/mim-core/1.2"
    xmlns:mim-ext="http://www.geostandaarden.nl/mim/mim-ext/1.0"
    xmlns:mim-ref="http://www.geostandaarden.nl/mim/mim-ref/1.0"
    
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:functx="http://www.functx.com"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy" 
    
    exclude-result-prefixes="#all"
    expand-text="yes"
    version="3.0">
    
    <!-- 
        Zet MIM om naar Imvert formaat. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-doc.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    <xsl:import href="../common/Imvert-common-inspire.xsl"/>
    
    <xsl:variable name="stylesheet-code">IMV</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>

    <xsl:variable name="mim-document" select="/"/>

    <xsl:key name="key-construct-by-id" match="//*[@id]" use="@id"/>
    <xsl:key name="key-construct-by-idref" match="//*[@xlink:href]" use="@xlink:href"/>
    
    <xsl:variable name="known-tagged-values" select="imf:get-config-tagged-values()" as="element(tv)*"/>
    
    <xsl:variable name="allow-duplicate-tv" select="imf:boolean(imf:get-config-string('cli','allowduplicatetv','no'))"/>
    
    <xsl:variable name="stereotype-info" as="element(stereo)+">
        <stereo name="Project" id="stereotype-name-project-package">PROJECT</stereo>
        <stereo name="Attribuutsoort" id="stereotype-name-attribute">ATTRIBUUTSOORT</stereo>
        <stereo name="Codelijst" id="stereotype-name-codelist">CODELIJST</stereo>
        <stereo name="?" id="stereotype-name-union-element">DATATYPE</stereo>
        <stereo name="Domein" id="stereotype-name-domain-package">DOMEIN</stereo>
        <stereo name="Enumeratie" id="stereotype-name-enumeration">ENUMERATIE</stereo>
        <stereo name="Waarde" id="stereotype-name-enum">ENUMERATIEWAARDE</stereo>
        <stereo name="Extern" id="stereotype-name-external-package">EXTERN</stereo>
        <stereo name="ExterneKoppeling" id="stereotype-name-externekoppeling">EXTERNE KOPPELING</stereo>
        <stereo name="Gegevensgroep" id="stereotype-name-attributegroup">GEGEVENSGROEP</stereo>
        <stereo name="Gegevensgroeptype" id="stereotype-name-composite">GEGEVENSGROEPTYPE</stereo>
        <stereo name="Generalisatie" id="stereotype-name-generalization">GENERALISATIE</stereo>
        <stereo name="GestructureerdDatatype" id="stereotype-name-complextype">GESTRUCTUREERD DATATYPE</stereo>
        <stereo name="DataElement" id="stereotype-name-data-element">DATA ELEMENT</stereo>
        <stereo name="Informatiemodel" id="stereotype-name-informatiemodel-package">INFORMATIEMODEL</stereo>
        <stereo name="Keuze" id="stereotype-name-union">KEUZE</stereo>
        <stereo name="KeuzeAttributen" id="stereotype-name-union-attributes">KEUZE ATTRIBUTEN</stereo>
        <stereo name="KeuzeAttribuut" id="stereotype-name-union-attribute">KEUZE ATTRIBUUT</stereo>
        <stereo name="KeuzeDatatypen" id="stereotype-name-union-datatypes">KEUZE DATATYPEN</stereo>
        <stereo name="KeuzeRelatie" id="stereotype-name-union-association">KEUZE RELATIE</stereo>
        <stereo name="KeuzeRelaties" id="stereotype-name-union-associations">KEUZE RELATIES</stereo>
        <stereo name="?" id="stereotype-name-union-for-attributes">KEUZE ZONDER BETEKENIS</stereo>
        <stereo name="Koppelklasse" id="stereotype-name-koppelklasse">KOPPELKLASSE</stereo>
        <stereo name="Objecttype" id="stereotype-name-objecttype">OBJECTTYPE</stereo>
        <stereo name="PrimitiefDatatype" id="stereotype-name-simpletype">PRIMITIEF DATATYPE</stereo>
        <stereo name="ReferentieElement" id="stereotype-name-referentie-element">REFERENTIE ELEMENT</stereo>
        <stereo name="Referentielijst" id="stereotype-name-referentielijst">REFERENTIELIJST</stereo>
        <stereo name="Relatieklasse" id="stereotype-name-relatieklasse">RELATIEKLASSE</stereo>
        <stereo name="Relatierol" id="stereotype-name-relation-role">RELATIEROL</stereo>
        <stereo name="Relatiesoort" id="stereotype-name-relatiesoort">RELATIESOORT</stereo>
        <stereo name="?" id="stereotype-name-static-generalization">STATIC</stereo>
        <stereo name="?" id="stereotype-name-static-liskov">STATIC LISKOV</stereo>
        <stereo name="View" id="stereotype-name-view-package">VIEW</stereo>
    </xsl:variable>
    
    <xsl:variable name="additional-tagged-values" select="imf:get-config-tagged-values()" as="element(tv)*"/>
    
    <xsl:template match="/mim:Informatiemodel">
        
        <xsl:variable name="release" select="imf:get-kenmerk(.,'release',true())"/>
        <xsl:variable name="project" select="imf:get-xparm('cli/project')"/>
        
        <imvert:packages>
            <xsl:sequence select="imf:create-output-element('imvert:debug',$debugging)"/>
            <xsl:sequence select="imf:create-output-element('imvert:task',imf:get-config-string('cli','task','compile'))"/>
            <xsl:sequence select="imf:create-output-element('imvert:project',$project)"/>
            <xsl:sequence select="imf:create-output-element('imvert:application',mim:naam)"/>
            <xsl:sequence select="imf:create-output-element('imvert:release',$release)"/>
            
            <xsl:sequence select="imf:create-output-element('imvert:metamodel',string-join($configuration-prologue/metamodels/metamodel/name,';'))"/>
            <xsl:sequence select="imf:create-output-element('imvert:model-designation',$configuration-prologue/metamodels/metamodel/model-designation)"/>
            <xsl:sequence select="imf:create-output-element('imvert:generated',$generation-date)"/>
            <xsl:sequence select="imf:create-output-element('imvert:generator',$imvertor-version)"/>
            <xsl:sequence select="imf:create-output-element('imvert:exported',imf:get-kenmerk(.,'export datum'))"/>
            <xsl:sequence select="imf:create-output-element('imvert:exporter',imf:get-kenmerk(.,'exporter'))"/>
            <xsl:sequence select="imf:create-output-element('imvert:created',imf:get-kenmerk(.,'start datum'))"/>
            <xsl:sequence select="imf:create-output-element('imvert:author',imf:get-kenmerk(.,'auteur'))"/>
            
            <xsl:sequence select="imf:create-output-element('imvert:model-level',(imf:get-kenmerk(.,'level'),'compact')[1])"/><!-- 'general' = basismodel waar je andere modellen uit maakt of van afleid, 'compact' = bedoeld voor inzet in productie -->
            
            <imvert:supports>
                <xsl:sequence select="imf:compile-support-info()"/>
            </imvert:supports>
            
            <imvert:filters>
                <xsl:sequence select="imf:compile-imvert-filter()"/>
            </imvert:filters>
            
            <xsl:sequence select="imf:set-config-string('appinfo','original-application-name',mim:naam)"/>
            <xsl:sequence select="imf:set-config-string('appinfo','application-name',mim:naam)"/>
            <xsl:sequence select="imf:set-config-string('appinfo','root-namespace',imf:get-namespace(.))"/>
            <xsl:sequence select="imf:set-config-string('appinfo','release',$release)"/>           
            
            <xsl:choose>
                <xsl:when test="not(imf:get-config-has-owner())">
                    <xsl:sequence select="imf:msg('ERROR',
                        'Not a known owner: [1]',
                        ($owner-name)
                        )"/>
                </xsl:when>
                <xsl:otherwise>
                    <imvert:package>
                        <xsl:sequence select="imf:create-output-element('imvert:is-root-package','true')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:short-name',imf:get-short-name(mim:naam))"/>
                        
                        <xsl:sequence select="imf:get-package-info(.)"/>
                        
                        <xsl:apply-templates select="mim:packages/*"/>
                        
                        <xsl:sequence select="imf:fetch-tagged-values(.)"/>
                        
                    </imvert:package>
                </xsl:otherwise>
            </xsl:choose>
            
            <imvert:package>
                <imvert:id>OUTSIDE</imvert:id>
                <!-- haal alle referenties op naar MIM datatypen --> 
                <xsl:for-each-group select="$mim-document//mim:Datatype" group-by=".">
                    <imvert:class origin="stub" umltype="DataType">
                        <imvert:found-name>{current-group()[1]}</imvert:found-name>
                        <imvert:id>MIMTYPE_{current-group()[1]}</imvert:id>
                    </imvert:class>
                </xsl:for-each-group>
                <!-- haal alle andere referenties op naar constructs die niet in dit model zitten --> 
                <xsl:for-each-group select="$mim-document//mim-ext:*" group-by="@xlink:href">
                    <xsl:variable name="type" select="imf:get-type(current-grouping-key())"/>
                    <imvert:class origin="stub" umltype="{'unknown-umltype'}">
                        <imvert:found-name>{$type/mim:naam}</imvert:found-name>
                        <imvert:id>{$type/@id}</imvert:id>
                    </imvert:class>
                </xsl:for-each-group>
            </imvert:package>
            
        </imvert:packages>
    </xsl:template>    
    
    <xsl:template match="mim:packages/(mim:Domein | mim:View)">
        <xsl:sequence select="imf:track('Transforming domein/view [1]',@name)"/>
        
        <!--TODO afleiding implementeren? / derived -->
                
        <imvert:package>
            <xsl:sequence select="imf:create-output-element('imvert:short-name',imf:get-short-name(mim:naam))"/>
            
            <xsl:sequence select="imf:get-package-info(.)"/>
            
             <xsl:apply-templates/>
            
            <!-- neem hier ook de relatieklassen op, deze zijn opgenomen in de relatiesoorten -->
            <xsl:apply-templates select=".//mim:Relatieklasse"/>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
            
            <!--TODO dependency? -->
            
        </imvert:package>      
    </xsl:template>    
    
    <xsl:template match="mim:objecttypen/mim:Objecttype | mim:relatieklasse/mim:Relatieklasse">
        
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            
            <imvert:attributes>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort | mim:gegevensgroepen/mim:Gegevensgroep"/>
                <xsl:apply-templates select="mim:keuzen/mim-ref:KeuzeRef">
                    <xsl:with-param name="keuze-soort">attributen</xsl:with-param>
                </xsl:apply-templates>
            </imvert:attributes>
            <imvert:associations>
                <xsl:apply-templates select="mim:relatiesoorten/mim:Relatiesoort | mim:externeKoppelingen/mim:ExterneKoppeling"/>
            </imvert:associations>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>      
        
    </xsl:template>    
    
    <xsl:template match="(mim:attribuutsoorten | mim:keuzeAttributen)/mim:Attribuutsoort">
        <imvert:attribute>
            <xsl:sequence select="imf:get-attass-info(.)"/>
            <xsl:sequence select="imf:get-attribute-info(.)"/>
            <xsl:sequence select="imf:get-datatype-info(.)"/>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:attribute>        
    </xsl:template>
    
    <xsl:template match="mim:gegevensgroepen/mim:Gegevensgroep">
        <imvert:attribute>
            <xsl:sequence select="imf:get-attass-info(.)"/>
            <xsl:sequence select="imf:get-attribute-info(.)"/>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:attribute>        
    </xsl:template>
    
    <xsl:template match="mim:relatiesoorten/mim:Relatiesoort">
        <imvert:association>
            <xsl:sequence select="imf:get-attass-info(.)"/>
            <xsl:sequence select="imf:get-association-info(.)"/>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:association>        
    </xsl:template>
    
    <xsl:template match="mim:externeKoppelingen/mim:ExterneKoppeling">
        <imvert:association>
            <xsl:sequence select="imf:get-attass-info(.)"/>
            <xsl:sequence select="imf:get-association-info(.)"/>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:association>        
    </xsl:template>
    
    <xsl:template match="mim:datatypen/mim:Referentielijst">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            
            <imvert:attributes>
                <xsl:apply-templates select="mim:referentieElementen/mim:ReferentieElement"/>
            </imvert:attributes>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>        
    </xsl:template>    
    <xsl:template match="mim:referentieElementen/mim:ReferentieElement">
        <imvert:attribute>
            <xsl:sequence select="imf:get-attass-info(.)"/>
            <xsl:sequence select="imf:get-attribute-info(.)"/>

            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:attribute>        
    </xsl:template>    
    
    <xsl:template match="mim:datatypen/mim:Codelijst">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>

            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>        
    </xsl:template>    
    
    <xsl:template match="mim:datatypen/mim:Enumeratie">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            
            <imvert:attributes>
                <xsl:apply-templates select="mim:waarden/mim:Waarde"/>
            </imvert:attributes>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>        
    </xsl:template>    
    <xsl:template match="mim:waarden/mim:Waarde">
        <imvert:attribute>
            <xsl:sequence select="imf:get-attass-info(.)"/>
            <xsl:sequence select="imf:get-enum-info(.)"/>

            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:attribute>        
    </xsl:template>    
    
    <xsl:template match="mim:datatypen/mim:GestructureerdDatatype">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            <xsl:sequence select="imf:get-datatype-info(.)"/>

            <imvert:attributes>
                <xsl:apply-templates select="mim:dataElementen/mim:DataElement"/>
            </imvert:attributes>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>        
    </xsl:template>    
    <xsl:template match="mim:dataElementen/mim:DataElement">
        <imvert:attribute>
            <xsl:sequence select="imf:get-attass-info(.)"/>
            <xsl:sequence select="imf:get-attribute-info(.)"/>
            <xsl:sequence select="imf:get-datatype-info(.)"/>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:attribute>        
    </xsl:template>
    
    <xsl:template match="mim:datatypen/mim:PrimitiefDatatype">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            <xsl:sequence select="imf:get-datatype-info(.)"/>

            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>        
    </xsl:template>    
    
    <xsl:template match="mim:packages/mim:Extern">
        <xsl:sequence select="imf:track('Transforming E [1]',@name)"/>
        <!--TODO ? -->      
    </xsl:template>    
    
    <xsl:template match="mim:keuzen/mim:Keuze[mim:keuzeRelatiedoelen]">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            <imvert:associations>
               <xsl:for-each select="mim:keuzeRelatiedoelen/mim:Relatiedoel">
                   <xsl:variable name="type" select="imf:get-type((mim-ref:*|mim-ext:*)/@xlink:href)"/>
                   <imvert:association>
                       <xsl:sequence select="imf:create-output-element('imvert:id',@id)"/>
                       <xsl:sequence select="imf:create-output-element('imvert:found-name',(mim-ref:*|mim-ext:*)/@label)"/>
                       <xsl:sequence select="imf:create-output-element('imvert:type-name',$type/mim:naam)"/>
                       <xsl:sequence select="imf:create-output-element('imvert:type-id',$type/@id)"/>
                       <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type/@id))"/>
                       <xsl:sequence select="imf:create-output-element('imvert:min-occurs','1')"/>
                       <xsl:sequence select="imf:create-output-element('imvert:max-occurs','1')"/>
                       <imvert:stereotype id="stereotype-name-union">KEUZE</imvert:stereotype>
                       <imvert:target>
                           <imvert:navigable>true</imvert:navigable>
                       </imvert:target>
                   </imvert:association>
               </xsl:for-each>
           </imvert:associations>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="mim:keuzen/mim:Keuze[mim:keuzeDatatypen]">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
          
            <imvert:attributes>
                <xsl:for-each select="mim:keuzeDatatypen/*">
                    
                    <imvert:attribute>
                        <xsl:choose>
                            <xsl:when test="@xlink:href">
                                <!-- referentie naar een type -->
                                <xsl:variable name="type" select="imf:get-type(@xlink:href)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:found-name',@label)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-name',$type/mim:naam)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-id',$type/@id)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type/@id))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- ingebouwd MIM datatyype -->
                                <xsl:sequence select="imf:create-output-element('imvert:found-name',.)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-name',.)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-id','MIMTYPE_' || .)"/>
                                <xsl:sequence select="imf:create-output-element('imvert:type-package','OUTSIDE')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:sequence select="imf:create-output-element('imvert:min-occurs','1')"/>
                        <xsl:sequence select="imf:create-output-element('imvert:max-occurs','1')"/>
                        <imvert:stereotype id="stereotype-name-union-element">DATATYPE</imvert:stereotype>
                    </imvert:attribute>
                </xsl:for-each>
            </imvert:attributes>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="mim:keuzen/mim:Keuze[mim:keuzeAttributen]">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            
            <imvert:attributes>
                <xsl:apply-templates select="mim:keuzeAttributen/mim:*"/>
            </imvert:attributes>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>
    </xsl:template>
    
    <xsl:template match="mim:keuzen/mim-ref:KeuzeRef">
        <xsl:param name="keuze-soort" as="xs:string"/>
        
        <xsl:variable name="type" select="imf:get-type(@xlink:href)"/>
        <xsl:variable name="type-name" select="$type/mim:naam"/>
        
        <xsl:if test="
            ($keuze-soort = 'attributen' and $type/mim:keuzeAttributen)
            ">
            <imvert:attribute>
                <xsl:sequence select="imf:create-output-element('imvert:found-name','KEUZE-' || $type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-id',$type/@id)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type/@id))"/>
                <xsl:sequence select="imf:create-output-element('imvert:min-occurs','1')"/>
                <xsl:sequence select="imf:create-output-element('imvert:max-occurs','1')"/>
                <imvert:stereotype id="stereotype-name-union">KEUZE</imvert:stereotype>
            </imvert:attribute>
        </xsl:if>
        
    </xsl:template>
        
    <xsl:template match="mim:gegevensgroeptypen/mim:Gegevensgroeptype">
        <imvert:class>
            <xsl:sequence select="imf:get-class-info(.)"/>
            
            <imvert:attributes>
                <xsl:apply-templates select="mim:attribuutsoorten/mim:Attribuutsoort"/>
            </imvert:attributes>
            
            <xsl:sequence select="imf:fetch-tagged-values(.)"/>
        </imvert:class>        
    </xsl:template>    
    
    
    
    <xsl:template match="mim-ext:constructies/mim-ext:Constructie">
        
    </xsl:template>    
    
    <xsl:template match="mim-ext:kenmerken/mim-ext:Kenmerk">
        
    </xsl:template>    
    
    
    <xsl:function name="imf:get-package-info" as="node()*">
        <xsl:param name="this" as="element()"/>
        
        <xsl:sequence select="imf:debug($this,'get-package-info')"/>
        <xsl:sequence select="imf:get-id-info($this,'P')"/>
        <!--TODO supplier-info? -->
        <xsl:sequence select="imf:get-history-info($this)"/>
        <!--TODO versiebeheer info? denk aan SVN -->
        <xsl:sequence select="imf:get-stereotypes-info($this)"/>
        <xsl:sequence select="imf:get-external-resources-info($this)"/>
        <xsl:sequence select="imf:get-config-info($this)"/>
        <xsl:sequence select="imf:get-constraint-info($this)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-class-info" as="node()*">
        <xsl:param name="this" as="element()"/>
        
        <xsl:sequence select="imf:debug($this,'get-class-info')"/>
        <xsl:sequence select="imf:create-output-element('imvert:designation',if (local-name($this) = ('Objecttype','Relatieklasse','Gegevensgroeptype')) then 'class' else if (local-name($this) = 'Keuze') then 'choice' else 'datatype')"/>
        <xsl:sequence select="imf:get-id-info($this,'C')"/>
        <xsl:sequence select="imf:get-type-info($this)"/>
        <xsl:sequence select="imf:get-history-info($this)"/>
        <xsl:sequence select="imf:get-stereotypes-info($this)"/>
        <xsl:sequence select="imf:get-external-resources-info($this)"/>
        <xsl:sequence select="imf:get-constraint-info($this)"/>
        
    </xsl:function>
    
    <xsl:function name="imf:get-attass-info" as="node()*">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="imf:debug($this,'get-attass-info')"/>
        <xsl:sequence select="imf:get-id-info($this,'A')"/>
        <xsl:sequence select="imf:get-scope-info($this)"/>
        <xsl:sequence select="imf:get-stereotypes-info($this)"/>
        <xsl:sequence select="imf:get-external-resources-info($this)"/>
        <xsl:sequence select="imf:get-constraint-info($this)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-id-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="type" as="xs:string"/><!-- Class, Attribute, Relation, Package --> 
        <xsl:sequence select="imf:debug($this,'get-id-info')"/>
        <xsl:sequence select="imf:create-output-element('imvert:found-name',$this/mim:naam)"/>
        <xsl:sequence select="imf:create-output-element('imvert:alias',imf:get-kenmerk($this,'alias'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:id',$this/@id)"/>
        <xsl:sequence select="imf:create-output-element('imvert:keywords',imf:get-kenmerk($this,'keywords'))"/> 
        <xsl:sequence select="imf:create-output-element('imvert:is-id',$this/mim:identificerend)"/> 
        <xsl:sequence select="imf:create-output-element('imvert:namespace',imf:get-namespace($this))"/>
        <!--TODO traces? -->
        <!--TODO dependencies? -->
        <!--TODO afleiding? -->
    </xsl:function>
    
    <xsl:function name="imf:get-type-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:where-populated>
            <xsl:for-each select="$this/mim:supertypen/mim:*"><!-- mim:GeneralisatieObjecttypen of mim:GeneralisatieDatatypen -->
                <imvert:supertype>
                    <xsl:sequence select="imf:create-output-element('imvert:id',@id)"/>
                    <xsl:variable name="mim-type" select="mim:supertype/mim:Datatype"/>
                    <xsl:choose>
                        <xsl:when test="$mim-type">
                            <xsl:sequence select="imf:create-output-element('imvert:type-name',$mim-type)"/>
                            <xsl:sequence select="imf:create-output-element('imvert:type-id','MIMTYPE_' || $mim-type)"/>
                            <xsl:sequence select="imf:create-output-element('imvert:type-package','OUTSIDE')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="type-href" select="mim:supertype/(mim-ref:*|mim-ext:*)"/>
                            <xsl:variable name="type" select="imf:get-type($type-href/@xlink:href)"/>
                            <xsl:sequence select="imf:create-output-element('imvert:type-name',$type-href)"/>
                            <xsl:sequence select="imf:create-output-element('imvert:type-id',$type/@id)"/>
                            <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type/@id))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <imvert:position>{(imf:get-kenmerk($this,'positie'),'100')[1]}</imvert:position>
                </imvert:supertype>
            </xsl:for-each>
        </xsl:where-populated>
    </xsl:function>
    
    <xsl:function name="imf:get-history-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:debug($this,'get-history-info')"/>
        <xsl:sequence select="imf:create-output-element('imvert:created',imf:date-to-isodate(imf:get-kenmerk($this,'gemaakt')))"/>
        <xsl:sequence select="imf:create-output-element('imvert:modified',imf:date-to-isodate(imf:get-kenmerk($this,'aangepast')))"/>
        <xsl:sequence select="imf:create-output-element('imvert:version',imf:get-kenmerk($this,('versie','version')))"/><!--TODO hoe omgaan met versie en fase als dat geen onderdeel is van MIM? ==> afspraken mbt vaste kenmerken vor een Imvertor job -->
        <xsl:sequence select="imf:create-output-element('imvert:phase', imf:get-kenmerk($this,('fase','phase')))"/>
        <xsl:sequence select="imf:create-output-element('imvert:author',imf:get-kenmerk($this,'auteur'))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-stereotypes-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:debug($this,'get-stereotypes-info')"/>
        <xsl:variable name="st" select="$stereotype-info[@name = local-name($this)]"/>
        <xsl:if test="$st">
            <imvert:stereotype id="{$st/@id}">
                <xsl:value-of select="$st"/>
            </imvert:stereotype>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-external-resources-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:debug($this,'get-external-resources-info')"/>
        <xsl:sequence select="imf:create-output-element('imvert:web-location',imf:get-kenmerk($this,'web locatie'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:location',$this/mim:locatie)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-config-info" as="node()*">
        <xsl:param name="this" as="node()"/> 
        <xsl:sequence select="imf:debug($this,'get-config-info')"/>
        
        <xsl:sequence select="imf:create-output-element('imvert:release',imf:get-kenmerk($this,'release'),true())"/>
        <xsl:sequence select="imf:create-output-element('imvert:ref-version',imf:get-kenmerk($this,'ref-version'))"/> <!-- optional -->
        <xsl:sequence select="imf:create-output-element('imvert:ref-release',imf:get-kenmerk($this,'ref-release'))"/> <!-- optional -->
    </xsl:function>

    <xsl:function name="imf:get-constraint-info" as="node()*">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="imf:debug($this,'get-constraint-info')"/>
        <!--TODO constraints uitwerken -->
        <xsl:variable name="constraints" select="$this/mim:Constraint"/>
        <xsl:where-populated>
            <imvert:constraints>
                <xsl:for-each select="$constraints">
                    <imvert:constraint>
                        <xsl:sequence select="imf:create-output-element('imvert:name',mim:naam)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:type',mim:type)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:weight',mim:gewicht)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:status',mim:status)"/>
                        <xsl:sequence select="imf:create-output-element('imvert:definition',mim:definitie)"/>
                    </imvert:constraint>
                </xsl:for-each>
            </imvert:constraints>
        </xsl:where-populated>
    </xsl:function>

    <xsl:function name="imf:get-scope-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:debug($this,'get-scope-info')"/>
        <xsl:sequence select="imf:create-output-element('imvert:visibility',imf:get-kenmerk($this,'visibility'))"/> 
        <xsl:sequence select="imf:create-output-element('imvert:scope',imf:get-kenmerk($this,'scope'))"/> 
        <xsl:sequence select="imf:create-output-element('imvert:static',imf:get-kenmerk($this,'static') = '1')"/> 
    </xsl:function>    
    
    <xsl:function name="imf:get-attribute-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- mim:Attribuutsoort of mim:Gegevensgroep -->
        
        <xsl:sequence select="imf:debug($this,'get-attribute/gegevensgroep-info/keuze-info')"/>
        
        <xsl:variable name="mim-type" select="$this/mim:type/mim:Datatype"/>
        <xsl:choose>
            <xsl:when test="$mim-type">
                <xsl:sequence select="imf:create-output-element('imvert:baretype',$mim-type)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$mim-type)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-id','MIMTYPE_' || $mim-type)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-package','OUTSIDE')"/>
            </xsl:when>
            <!-- process the typed attributes, referencing type object types -->
            <xsl:otherwise>
                <xsl:variable name="type" select="imf:get-type($this/(mim:type|mim:gegevensgroeptype)/(mim-ref:*|mim-ext:*)/@xlink:href)"/><!--TODO xslt bug? optimization? -->
                <xsl:variable name="type-name" select="$type/mim:naam"/>
                <xsl:sequence select="imf:create-output-element('imvert:baretype',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-id',$type/@id)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type/@id))"/>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:variable name="bounds" select="imf:get-bounds($this/mim:kardinaliteit)"/>
        
        <xsl:sequence select="imf:create-output-element('imvert:min-occurs',$bounds[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-occurs',$bounds[2])"/>
        <xsl:sequence select="imf:create-output-element('imvert:position',(imf:get-kenmerk($this,'positie'),'100')[1])"/>
        
        <xsl:sequence select="imf:create-output-element('imvert:is-value-derived',imf:boolean($this/mim:indicatieAfleidbaar))"/>
        <xsl:sequence select="imf:create-output-element('imvert:initial-value',imf:get-kenmerk($this,'startwaarde'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:read-only',imf:get-kenmerk($this,'readonly'))"/>
        
    </xsl:function>
    
    <xsl:function name="imf:get-enum-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- mim:Waarde -->
        
        <xsl:sequence select="imf:create-output-element('imvert:position',(imf:get-kenmerk($this,'positie'),'100')[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:initial-value',imf:get-kenmerk($this,'startwaarde'))"/>
        
    </xsl:function>
    
    <xsl:function name="imf:get-association-info" as="node()*">
        <xsl:param name="this" as="node()"/> <!-- mim:Relatiesoort of mim:ExterneKoppeling-->
        
        <xsl:sequence select="imf:debug($this,'get-association-info')"/>
        
        <xsl:variable name="type" select="imf:get-type($this/mim:doel/(mim-ref:*|mim-ext:*)/@xlink:href)"/>
        <xsl:variable name="type-name" select="$type/mim:naam"/>
        
        <xsl:variable name="source-bounds" select="imf:get-bounds(($this/mim:kardinaliteitBron,'1')[1])"/><!-- dit is default 1 voor externeKoppelingen -->
        <xsl:variable name="target-bounds" select="imf:get-bounds($this/mim:kardinaliteit)"/>
        
        <xsl:sequence select="imf:create-output-element('imvert:type-name',$type-name)"/>
        <xsl:sequence select="imf:create-output-element('imvert:type-id',$type/@id)"/> 
        <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type/@id))"/>
        <xsl:sequence select="imf:create-output-element('imvert:min-occurs',$target-bounds[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-occurs',$target-bounds[2])"/>
        <xsl:sequence select="imf:create-output-element('imvert:min-occurs-source',$source-bounds[1])"/>
        <xsl:sequence select="imf:create-output-element('imvert:max-occurs-source',$source-bounds[2])"/>
        <xsl:sequence select="imf:create-output-element('imvert:aggregation',if ($this/mim:aggregatietype = 'Compositie') then 'composite' else ())"/>
        <xsl:sequence select="imf:create-output-element('imvert:direction','destination')"/>
        
        <xsl:sequence select="imf:create-output-element('imvert:position',(imf:get-kenmerk($this,'positie'),'200')[1])"/>
      
        <xsl:for-each select="$this/mim:relatieklasse/mim:Relatieklasse"><!-- singleton -->
            <xsl:variable name="type" select="imf:get-type('#' || @id)"/>
            <xsl:variable name="type-name" select="$type/mim:naam"/>
            <imvert:association-class>
                <xsl:sequence select="imf:create-output-element('imvert:type-name',$type-name)"/>
                <xsl:sequence select="imf:create-output-element('imvert:type-id',$type/@id)"/> 
                <xsl:sequence select="imf:create-output-element('imvert:type-package',imf:get-package-name($type/@id))"/>
            </imvert:association-class>
        </xsl:for-each>
        
        <xsl:for-each select="$this/mim:relatierollen/mim:Bron"><!-- singleton -->
            <imvert:source>
                <xsl:sequence select="imf:get-role-info(.)"/>
            </imvert:source>
        </xsl:for-each>
        <xsl:for-each select="$this/mim:relatierollen/mim:Doel"><!-- singleton -->
            <imvert:target>
                <xsl:sequence select="imf:get-role-info(.)"/>
            </imvert:target>
        </xsl:for-each>
        
      
    </xsl:function>

    <xsl:function name="imf:get-role-info" as="node()*">
        <xsl:param name="this" as="element()"></xsl:param>
        <xsl:sequence select="imf:debug($this,'get-role-info')"/>
        <xsl:sequence select="imf:create-output-element('imvert:id',$this/@id)"/>
        <xsl:sequence select="imf:get-stereotypes-info($this)"/>
        <xsl:sequence select="imf:create-output-element('imvert:role',$this/mim:naam)"/>
        <xsl:sequence select="imf:create-output-element('imvert:navigable',if ($this/self::mim:Doel) then 'true' else ())"/>
        <xsl:sequence select="imf:create-output-element('imvert:alias',imf:get-kenmerk($this,'alias'))"/>
    </xsl:function>

    <xsl:function name="imf:get-datatype-info" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:sequence select="imf:debug($this,'get-datatype-info')"/>
        <xsl:sequence select="imf:create-output-element('imvert:primitive',imf:get-kenmerk($this,'primitive'))"/>
        <xsl:sequence select="imf:create-output-element('imvert:pattern',$this/mim:FormeelPatroon)"/>
        <xsl:sequence select="imf:create-output-element('imvert:min-length',if ($this/mim:Lengte) then '0' else ())"/><!--TODO check rol van Lengte -->
        <xsl:sequence select="imf:create-output-element('imvert:max-length',$this/mim:Lengte)"/>
        <xsl:sequence select="imf:create-output-element('imvert:any-from-package','unknown')"/><!--TODO wat is dat? -->
        <xsl:sequence select="imf:create-output-element('imvert:union',imf:get-kenmerk($this,'union'))"/><!--TODO wat is dat? -->
    </xsl:function>

    <xsl:function name="imf:compile-support-info" as="element(imvert:support)*">
        <imvert:support>
            <imvert:level>STEREOID</imvert:level>
        </imvert:support>
    </xsl:function>

    <xsl:function name="imf:get-type" as="element()?">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:variable name="type-id" select="if (starts-with($id,'#')) then substring-after($id,'#') else $id"/>
        <xsl:sequence select="imf:element-by-id($type-id)"/>
    </xsl:function>

    <xsl:function name="imf:get-kenmerk" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="name" as="xs:string+"/><!-- lower case -->
        <xsl:param name="required" as="xs:boolean"/>
        <xsl:variable name="km" select="$this/mim-ext:kenmerken/mim-ext:Kenmerk[lower-case(@naam) = $name]"/>
        <xsl:choose>
            <xsl:when test="exists($km)">
                <xsl:value-of select="$km"/>
            </xsl:when>
            <xsl:when test="$required">
                <xsl:sequence select="imf:msg($this,'ERROR', 'MIM extension: kenmerk required but not supplied: [1]',(imf:string-group($name,'or')))"/>           
            </xsl:when>
            <!-- anders lege sequence -->
        </xsl:choose>
    </xsl:function>
    <xsl:function name="imf:get-kenmerk" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="name" as="xs:string+"/><!-- lower case -->
        <xsl:sequence select="imf:get-kenmerk($this,$name,false())"/>
    </xsl:function>
    
    <xsl:function name="imf:get-namespace" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="namespace-1.1" select="imf:get-kenmerk($this,'namespace')"/>
        <xsl:variable name="namespace-1.2" select="$this/mim:basisURI"/>
        <xsl:sequence select="($namespace-1.2,$namespace-1.1)[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:debug">
        <xsl:param name="this"/>
        <xsl:param name="info"/>
        <xsl:if test="$debugging">
            <xsl:variable name="display-name" select="imf:get-display-name($this)"/>
            <!--<xsl:sequence select="dlogger:save('- ' || $display-name,$info)"/>-->
            <xsl:comment>{$display-name} - {$info}</xsl:comment>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:date-to-isodate" as="xs:string?">
        <xsl:param name="date" as="xs:string?"/>
        <xsl:if test="$date">
            <xsl:analyze-string select="$date" regex="^(.+)\s(.+)$">
                <!-- 2005-11-07 16:49:09 -->
                <xsl:matching-substring>
                    <xsl:value-of select="concat(regex-group(1),'T',regex-group(2))"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:element-by-id" as="node()*">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:variable name="elm" select="imf:get-key($mim-document,'key-construct-by-id',$id)"/>
        <xsl:choose>
            <xsl:when test="not($id)">
                <xsl:sequence select="imf:msg('ERROR','No ID passed', ())"/>
            </xsl:when>  
            <xsl:when test="not($elm)">
                <xsl:sequence select="imf:msg('ERROR','No element known by ID [1]', ($id))"/>
            </xsl:when>  
            <xsl:otherwise>
                <xsl:sequence select="$elm"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-package-name" as="xs:string">
        <xsl:param name="type-id" as="xs:string?"/>
        <xsl:variable name="class" select="imf:get-key($mim-document,'key-construct-by-id',$type-id)"/>
        <xsl:value-of select="($class/ancestor-or-self::*[local-name() = ('Domein', 'View', 'Extern')]/mim:naam,'OUTSIDE')[1]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-bounds" as="xs:string*">
        <xsl:param name="card" as="xs:string"/>
        <xsl:variable name="toks" select="tokenize($card,'\.+')"/>
        <xsl:value-of select="$toks[1]"/>
        <xsl:value-of select="if ($toks[2]) then if ($toks[2]='*') then 'unbounded' else $toks[2] else $toks[1]"/>
    </xsl:function>
    
    <!--
        Bepaalde tagged values zijn in MIM gerepresenteerd als MIM constructie, andere door een Kenmerk.
        Ga door alle bekende tagged values heen, en kijk of een waarde aan het MIM model te onttrekken is. Dit op basis van de naam van een modelelement (mim.*)
        Zo ja, maak daarvoor een tagged-value aan. 
        Zo nee, kijk of er een kenmerk is met precies die naam.
        Zo ja, maak daarvoor een tagged-value aan. 
        Anders geen tagged value aanmaken.    
    -->
    <xsl:function name="imf:fetch-tagged-values" as="element(imvert:tagged-values)?">
        <xsl:param name="this" as="element()"/>

        <xsl:variable name="stereo-id" select="$stereotype-info[@name = local-name($this)]/@id"/>
        <xsl:variable name="known-tags" select="$additional-tagged-values[stereotypes/stereo/@id = $stereo-id]"/>

        <xsl:where-populated>
            <imvert:tagged-values>
                <xsl:for-each select="$known-tags"> <!-- tv elementen uit de configuratie -->
                    <xsl:variable name="tv" select="."/>
                    <xsl:choose>
                        <xsl:when test="$tv/mimformat[@type = 'kenmerk']">
                            <xsl:sequence select="imf:fetch-tagged-values-sub($this,$tv,())"></xsl:sequence>
                        </xsl:when>
                        <xsl:when test="$tv/mimformat">
                            <xsl:sequence select="imf:fetch-tagged-values-sub($this,$tv,$this/*[local-name() = $tv/mimformat])"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- andere tagged values spelen geen rol in de MIM serialisatie -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </imvert:tagged-values> 
        </xsl:where-populated>
    </xsl:function>
    
    <xsl:function name="imf:fetch-tagged-values-sub" as="node()*">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="tv" as="element(tv)"/>
        <xsl:param name="value" as="item()*"/>
        
        <xsl:variable name="orig-value" select="if ($value) then $value else imf:get-kenmerk($this,$tv/name)"/>
        <xsl:for-each select="$orig-value">
            <xsl:variable name="norm-value" select="imf:norm-by-scheme(.,$tv/@norm,'tv')"/>
            <imvert:tagged-value id="{$tv/@id}">
                <imvert:name original="{$tv/name/@original}">
                    <xsl:value-of select="$tv/name"/>
                </imvert:name>
                <imvert:value original="{.}">
                    <xsl:sequence select="$norm-value"/>
                </imvert:value>
            </imvert:tagged-value>
        </xsl:for-each>
        
    </xsl:function>
    
    <xsl:function name="imf:norm-by-scheme" as="item()*">
        <xsl:param name="value" as="item()"/>
        <xsl:param name="normalization-rule" as="xs:string?"/> <!-- e.g. "space", defaults to no norm -->
        <xsl:param name="normalization-scheme" as="xs:string"/> <!-- e.g. "tv" -->
        
        <xsl:choose>
            <xsl:when test="not(normalize-space($normalization-rule))">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'space'">
                <xsl:value-of select="imf:normalize-space($value)"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'note' and $value/xhtml:body"><!-- MIM werkbank note fields worden geexporteerd als XHTML in een html:body element -->
                <xsl:sequence select="$value/xhtml:body"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'note'"><!-- voor het geval dat er een andere waarde is maar wel note field -->
                <xsl:sequence select="$value/node()"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'compact'">
                <xsl:value-of select="imf:extract(upper-case($value),'[A-Z0-9]+')"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'concept'">
                <xsl:value-of select="imf:get-concept-by-URI-or-name($value)"/>
            </xsl:when>
            <xsl:when test="$normalization-scheme ='tv' and $normalization-rule = 'janee'"> <!--TODO ? dit werkt alleen voor nederlands -->
                <xsl:value-of select="for $v in normalize-space($value) return if ($v = 'true') then 'Ja' else if ($v = 'false') then 'Nee' else $v"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR','Unknown normalization rule [1] in scheme [2], for value [3]', ($normalization-rule,$normalization-scheme,$value))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-display-name">
        <xsl:param name="this"/>
        <xsl:value-of select="string-join(for $i in $this/ancestor-or-self::*[@id] return $i/mim:naam,'/')"/>
    </xsl:function>
    
    <xsl:template match="node()|@*">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>
</xsl:stylesheet>
