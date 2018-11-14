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
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <!-- 
       Migreer het MIM metamodel voor logische modellen naar het MBG, voor aansluiting op de Yaml straat. 
       Doel is alléén de payload (JSon schema) te genereren. Daarvoor is wat truckage nodig.
       Zie JIRA SampleIM000 JSON model variant D voor hoe deze code is bedoeld.
       Zie JIRA SampleIM000 JSON model variant E voor het model waar deze stylesheet op werkt.
    -->
    
    <xsl:template match="/imvert:packages">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <xsl:call-template name="imf:create-STUB2-package"/>
        </xsl:copy>
    </xsl:template>
        
    <!-- add tagged value naam in meervoud -->
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-objecttype']">
        <xsl:copy>
            <xsl:apply-templates/>
            <imvert:tagged-values>
                <imvert:tagged-value id="CFG-TV-NAMEPLURAL">
                    <imvert:value><xsl:value-of select="imvert:name"/>-MEERVOUD</imvert:value>
                </imvert:tagged-value>
            </imvert:tagged-values>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="imf:create-STUB2-package">
        <imvert:package>
            <imvert:name original="STUB2">STUB2</imvert:name>
            <imvert:short-name>STUB2</imvert:short-name>
            <imvert:alias>/Sample-IM/BERICHTSJABLOON</imvert:alias>
            <imvert:id>STUB2</imvert:id>
            <!--<imvert:derived reason="No indication of derivation">false</imvert:derived>-->
            <imvert:namespace>/Sample-IM/BERICHTSJABLOON</imvert:namespace>
            <!--<imvert:documentation/>
            <imvert:created>2018-11-06T13:46:02</imvert:created>
            <imvert:modified>2018-11-06T12:49:43</imvert:modified>
            <imvert:version>1.0.0</imvert:version>
            <imvert:phase original="Klad">1</imvert:phase>
            -->
            <imvert:author>IMVERTOR</imvert:author>
            <imvert:stereotype id="stereotype-name-domain-package">DOMEIN</imvert:stereotype>
            <imvert:release>20181101</imvert:release>
            <imvert:tagged-values>
                <imvert:tagged-value id="CFG-TV-RELEASE">
                    <imvert:name>release</imvert:name>
                    <imvert:value>20181101</imvert:value>
                </imvert:tagged-value>
            </imvert:tagged-values>
            <imvert:class>
                <imvert:name>Gr01Getresource</imvert:name>
                <imvert:id>STUB2_SAMPLE_GR01GETRESOURCE</imvert:id>
                <imvert:designation>class</imvert:designation>
                <imvert:abstract>false</imvert:abstract>
                <imvert:documentation/>
                <!--
                <imvert:created>2018-11-01T11:14:05</imvert:created>
                <imvert:modified>2018-11-06T12:47:10</imvert:modified>
                <imvert:version>1.0</imvert:version>
                <imvert:phase original="1.0">1</imvert:phase>
                -->
                <imvert:author>IMVERTOR</imvert:author>
                <?x <imvert:stereotype id="stereotype-name-getberichttype">GETBERICHTTYPE</imvert:stereotype> x?>
                <imvert:attributes/>
                <imvert:associations/>
                <imvert:tagged-values>
                    <imvert:tagged-value id="CFG-TV-BERICHTCODE">
                        <imvert:name>berichtcode</imvert:name>
                        <imvert:value>Gr01</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-GROUPING">
                        <imvert:value>resource</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-PAGE">
                        <imvert:value>false</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-SERIALISATION">
                        <imvert:value>json+hal</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-BERICHTCODE">
                        <imvert:name>berichtcode</imvert:name>
                        <imvert:value>Gr01</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-DERIVED">
                        <imvert:value>no</imvert:value>
                    </imvert:tagged-value>
                </imvert:tagged-values>
            </imvert:class>
            <imvert:class display-name="STUB2::/Sample/id" formal-name="class_STUB2_SampleId">
                <imvert:name original="/Sample/id">SampleId</imvert:name>
                <imvert:id>STUB2_SAMPLE_ID</imvert:id>
                <imvert:designation>class</imvert:designation>
                <imvert:abstract>false</imvert:abstract>
                <imvert:stereotype id="stereotype-name-padtype">PADTYPE</imvert:stereotype>
                <imvert:attributes/>
                <imvert:associations/>
                <imvert:tagged-values>
                    <imvert:tagged-value id="CFG-TV-NAMEPLURAL">
                        <imvert:value>STUB2_SAMPLE_ID-MEERVOUD</imvert:value>
                    </imvert:tagged-value>
                </imvert:tagged-values>
            </imvert:class>
            <imvert:class display-name="STUB2::/Sample" formal-name="class_STUB2_Sample">
                <imvert:name original="/Sample">Sample</imvert:name>
                <imvert:id>STUB2_SAMPLE</imvert:id>
                <imvert:designation>class</imvert:designation>
                <imvert:abstract>false</imvert:abstract>
                <!--
                <imvert:documentation>
                    <section>
                        <title>Definitie</title>
                        <body>
                            <text>
                                <line>GET bericht dat één specifieke class opvraagt.</line>
                            </text>
                        </body>
                    </section>
                </imvert:documentation>
                <imvert:created>2018-11-06T13:46:02</imvert:created>
                <imvert:modified>2018-11-06T13:46:02</imvert:modified>
                <imvert:version>1.0</imvert:version>
                <imvert:phase original="1.0">1</imvert:phase>
                <imvert:author>Melsk_R</imvert:author>
                -->
                <imvert:stereotype id="stereotype-name-getberichttype">GETBERICHTTYPE</imvert:stereotype>
                <imvert:supertype>
                    <imvert:type-name>Gr01Getresource</imvert:type-name>
                    <imvert:type-id>STUB2_SAMPLE_GR01GETRESOURCE</imvert:type-id>
                    <imvert:type-replacement>internal</imvert:type-replacement>
                    <imvert:type-package>Berichtstructuren</imvert:type-package>
                </imvert:supertype>
                <imvert:attributes/>
                <imvert:associations>
                    <imvert:association>
                        <imvert:name original="pad">pad</imvert:name>
                        <imvert:id>STUB2_SAMPLE_PAD</imvert:id>
                        <imvert:visibility>public</imvert:visibility>
                        <imvert:static>false</imvert:static>
                        <imvert:type-name>SampleId</imvert:type-name>
                        <imvert:type-id>STUB2_SAMPLE_ID</imvert:type-id>
                        <imvert:type-package>STUB2</imvert:type-package>
                        <imvert:min-occurs>1</imvert:min-occurs>
                        <imvert:max-occurs>1</imvert:max-occurs>
                        <imvert:min-occurs-source>1</imvert:min-occurs-source>
                        <imvert:max-occurs-source>1</imvert:max-occurs-source>
                        <imvert:source>
                            <imvert:navigable>false</imvert:navigable>
                            <imvert:tagged-values/>
                        </imvert:source>
                        <imvert:target>
                            <imvert:navigable>true</imvert:navigable>
                            <imvert:tagged-values/>
                        </imvert:target>
                        <imvert:documentation/>
                        <imvert:stereotype id="stereotype-name-padrelatie">PADRELATIE</imvert:stereotype>
                        <imvert:tagged-values/>
                    </imvert:association>
                    <imvert:association>
                        <imvert:name original="request">request</imvert:name>
                        <imvert:id>STUB2_SAMPLE_REQUEST</imvert:id>
                        <imvert:visibility>public</imvert:visibility>
                        <imvert:static>false</imvert:static>
                        <imvert:type-name original="Algemeen_parameters">Algemeen_parameters</imvert:type-name>
                        <imvert:type-id>STUB2_ALGEMEEN_PARAMETERS</imvert:type-id>
                        <imvert:type-package>STUB2</imvert:type-package>
                        <imvert:min-occurs>1</imvert:min-occurs>
                        <imvert:max-occurs>1</imvert:max-occurs>
                        <imvert:min-occurs-source>1</imvert:min-occurs-source>
                        <imvert:max-occurs-source>1</imvert:max-occurs-source>
                        <imvert:position original="200">200</imvert:position>
                        <imvert:source>
                            <imvert:navigable>false</imvert:navigable>
                            <imvert:tagged-values/>
                        </imvert:source>
                        <imvert:target>
                            <imvert:navigable>true</imvert:navigable>
                            <imvert:tagged-values/>
                        </imvert:target>
                        <imvert:documentation/>
                        <imvert:stereotype id="stereotype-name-entiteitrelatie">ENTITEITRELATIE</imvert:stereotype>
                        <imvert:tagged-values/>
                    </imvert:association>
                    <imvert:association>
                        <imvert:name original="response">response</imvert:name>
                        <imvert:id>STUB2_SAMPLE_RESPONSE</imvert:id>
                        <imvert:visibility>public</imvert:visibility>
                        <imvert:static>false</imvert:static>
                        <imvert:type-name original="STUBCOLLECTION">STUBCOLLECTION</imvert:type-name>
                        <imvert:type-id>STUB2_STUBCOLLECTION</imvert:type-id>
                        <imvert:type-package>STUB2</imvert:type-package>
                        <imvert:min-occurs>1</imvert:min-occurs>
                        <imvert:max-occurs>1</imvert:max-occurs>
                        <imvert:min-occurs-source>1</imvert:min-occurs-source>
                        <imvert:max-occurs-source>1</imvert:max-occurs-source>
                        <imvert:source>
                            <imvert:navigable>false</imvert:navigable>
                            <imvert:tagged-values/>
                        </imvert:source>
                        <imvert:target>
                            <imvert:navigable>true</imvert:navigable>
                            <imvert:tagged-values/>
                        </imvert:target>
                        <imvert:documentation/>
                        <imvert:stereotype id="stereotype-name-entiteitrelatie">ENTITEITRELATIE</imvert:stereotype>
                    </imvert:association>
                </imvert:associations>
                <imvert:tagged-values>
                    <imvert:tagged-value id="CFG-TV-BERICHTCODE" level="2">
                        <imvert:value original="Gr01">Gr01</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-ISDERIVED" level="2">
                        <imvert:value original="Nee">Nee</imvert:value>
                    </imvert:tagged-value>
                    <imvert:tagged-value id="CFG-TV-NAMEPLURAL">
                        <imvert:value>STUB2_SAMPLE-MEERVOUD</imvert:value>
                    </imvert:tagged-value>
                </imvert:tagged-values>
                <imvert:subpackage>KadasterImkad</imvert:subpackage>
                <imvert:subpackage>SampleIM000JSONModelVariantD</imvert:subpackage>
                <imvert:subpackage>STUB2</imvert:subpackage>
            </imvert:class>
            <imvert:class display-name="STUB2::Algemeen_parameters = MVT"
                formal-name="class_STUB2_Algemeen_parameters">
                <imvert:name original="Algemeen_parameters">Algemeen_parameters</imvert:name>
                <imvert:alias>MVT</imvert:alias>
                <imvert:id>STUB2_ALGEMEEN_PARAMETERS</imvert:id>
                <imvert:designation>class</imvert:designation>
                <imvert:abstract>false</imvert:abstract>
                <imvert:documentation/>
                <imvert:created>2018-11-06T13:46:03</imvert:created>
                <imvert:modified>2018-11-06T13:46:03</imvert:modified>
                <imvert:version>1.0</imvert:version>
                <imvert:phase original="1.0">1</imvert:phase>
                <imvert:author>Johan</imvert:author>
                <imvert:stereotype id="stereotype-name-objecttype">OBJECTTYPE</imvert:stereotype>
                <imvert:attributes>
                    <imvert:attribute display-name="STUB2::Algemeen_parameters.id (attrib)"
                        formal-name="attribute_STUB2_Algemeen_parameters_id"
                        type-display-name="scalar-string">
                        <imvert:name original="id">id</imvert:name>
                        <imvert:id>STUB2_ALGEMEEN_PARAMETERS_ID</imvert:id>
                        <imvert:is-id>true</imvert:is-id>
                        <imvert:visibility>public</imvert:visibility>
                        <imvert:static>true</imvert:static>
                        <imvert:baretype>AN10</imvert:baretype>
                        
                        <imvert:type-name>scalar-string</imvert:type-name>
                        <imvert:max-length>10</imvert:max-length>
                        <imvert:min-occurs>1</imvert:min-occurs>
                        <imvert:max-occurs>1</imvert:max-occurs>
                        <imvert:position original="100">100</imvert:position>
                        <imvert:pattern>([0-9]{2})(-)([A-Z]{2})(-)([0-9]{2})|([A-Z]{2})(-)([0-9]{2})(-)([A-Z]{2})|([A-Z]{2})(-)([A-Z]{2})(-)([0-9]{2})</imvert:pattern>
                        <imvert:documentation/>
                        <imvert:stereotype id="stereotype-name-attribute">ATTRIBUUTSOORT</imvert:stereotype>
                        <imvert:stereotype id="stereotype-name-identification">IDENTIFICATIE</imvert:stereotype>
                        <imvert:tagged-values>
                            <imvert:tagged-value id="CFG-TV-INDICATIONFORMALHISTORY" level="1">
                                <imvert:name original="Indicatie formele historie">indicatie formele historie</imvert:name>
                                <imvert:value original="Nee">Nee</imvert:value>
                            </imvert:tagged-value>
                            <imvert:tagged-value id="CFG-TV-VOIDABLE" level="1">
                                <imvert:name original="Mogelijk geen waarde">mogelijk geen waarde</imvert:name>
                                <imvert:value original="Nee">Nee</imvert:value>
                            </imvert:tagged-value>
                            <imvert:tagged-value id="CFG-TV-INDICATIONMATERIALHISTORY" level="1">
                                <imvert:name original="Indicatie materiële historie">indicatie materiële historie</imvert:name>
                                <imvert:value original="Nee">Nee</imvert:value>
                            </imvert:tagged-value>
                            <imvert:tagged-value id="CFG-TV-FORMALPATTERN" level="1">
                                <imvert:name original="Formeel patroon">formeel patroon</imvert:name>
                                <imvert:value original="([0-9]{2})(-)([A-Z]{2})(-)([0-9]{2})|([A-Z]{2})(-)([0-9]{2})(-)([A-Z]{2})|([A-Z]{2})(-)([A-Z]{2})(-)([0-9]{2})">([0-9]{2})(-)([A-Z]{2})(-)([0-9]{2})|([A-Z]{2})(-)([0-9]{2})(-)([A-Z]{2})|([A-Z]{2})(-)([A-Z]{2})(-)([0-9]{2})</imvert:value>
                            </imvert:tagged-value>
                            <imvert:tagged-value id="CFG-TV-PATTERN" level="1">
                                <imvert:name original="Patroon">patroon</imvert:name>
                                <imvert:value original="een combinatie van cijfers en letters">een combinatie van cijfers en letters</imvert:value>
                            </imvert:tagged-value>
                        </imvert:tagged-values>
                    </imvert:attribute>
                </imvert:attributes>
                <imvert:associations/>
                <imvert:tagged-values>
                    <imvert:tagged-value id="CFG-TV-NAMEPLURAL">
                        <imvert:value>STUB2_ALGEMEEN_PARAMETERS-MEERVOUD</imvert:value>
                    </imvert:tagged-value>
                </imvert:tagged-values>
                <imvert:subpackage>KadasterImkad</imvert:subpackage>
                <imvert:subpackage>SampleIM000JSONModelVariantD</imvert:subpackage>
                <imvert:subpackage>STUB2</imvert:subpackage>
            </imvert:class>
            <imvert:class display-name="STUB2::STUBCOLLECTION" formal-name="class_STUB2_STUBCOLLECTION">
                <imvert:name original="STUBCOLLECTION">STUBCOLLECTION</imvert:name>
                <imvert:id>STUB2_STUBCOLLECTION</imvert:id>
                <imvert:designation>class</imvert:designation>
                <!--<imvert:abstract>false</imvert:abstract>
                <imvert:documentation/>
                <imvert:created>2018-11-06T13:46:03</imvert:created>
                <imvert:modified>2018-11-06T13:47:42</imvert:modified>
                <imvert:version>1.0</imvert:version>
                <imvert:phase original="1.0">1</imvert:phase>-->
                <imvert:author>IMVERTOR</imvert:author>
                <imvert:stereotype id="stereotype-name-objecttype">OBJECTTYPE</imvert:stereotype>
                <imvert:attributes/>
                <imvert:associations>
                    <xsl:for-each select="/imvert:packages/imvert:package/imvert:class[imvert:stereotype/@id = 'stereotype-name-objecttype' and not(imf:boolean(imvert:abstract))]">
                        <xsl:variable name="class" select="."/>
                        <imvert:association>
                            <xsl:variable name="relname" select="concat('rel_',$class/imvert:name)"/>
                                
                            <imvert:name original="{$relname}"><xsl:value-of select="$relname"/></imvert:name>
                            <imvert:id>STUB2_STUBCOLLECTION_<xsl:value-of select="$relname"/></imvert:id>
                            <!-- 
                            <imvert:visibility>public</imvert:visibility>
                            <imvert:static>false</imvert:static>
                            -->
                            <imvert:type-name><xsl:value-of select="$class/imvert:name"/></imvert:type-name>
                            <imvert:type-id><xsl:value-of select="$class/imvert:id"/></imvert:type-id>
                            <imvert:type-package><xsl:value-of select="$class/../imvert:name"/></imvert:type-package>
                            <imvert:min-occurs>1</imvert:min-occurs>
                            <imvert:max-occurs>1</imvert:max-occurs>
                            <imvert:min-occurs-source>1</imvert:min-occurs-source>
                            <imvert:max-occurs-source>1</imvert:max-occurs-source>
                            <imvert:target>
                                <imvert:stereotype id="stereotype-name-relation-role">RELATIEROL</imvert:stereotype>
                                <imvert:role><xsl:value-of select="concat('rol_',$class/imvert:name)"/></imvert:role>
                                <imvert:navigable>true</imvert:navigable>
                                <imvert:tagged-values/>
                            </imvert:target>
                            <!--<imvert:documentation/>-->
                            <imvert:stereotype id="stereotype-name-relatiesoort">RELATIESOORT</imvert:stereotype>
                            <imvert:tagged-values>
                                <imvert:tagged-value id="CFG-TV-NAMEPLURAL">
                                    <imvert:value>rel_<xsl:value-of select="imvert:name"/>-MEERVOUD</imvert:value>
                                </imvert:tagged-value>
                            </imvert:tagged-values>
                        </imvert:association>
                    </xsl:for-each>
                </imvert:associations>
                <imvert:tagged-values>
                    <imvert:tagged-value id="CFG-TV-NAMEPLURAL">
                        <imvert:value>STUB2_COLLECTION-MEERVOUD</imvert:value>
                    </imvert:tagged-value>
                </imvert:tagged-values>
            </imvert:class>
        </imvert:package>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template> 
        
</xsl:stylesheet>
