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
    xmlns:html="http://www.w3.org/1999/xhtml"
    
    xmlns:UML="omg.org/UML1.3" 
    exclude-result-prefixes="#all"
    version="2.0"
    >
    
    <!-- 
        Maak een reporting copy aan vanuit dit XMI bestand.
        De XMI is die van het oorspronkelijke UML project. Het wordt uitgebreid met informatie van elders.
        Met name:
        
            - documentatie die is vastgesteld in imvert slag.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    <xsl:import href="../common/Imvert-common-doc.xsl"/>
    
       <xsl:variable name="augmented" as="element()">
        <xsl:apply-templates select="/*" mode="augment"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <!-- first add documentation tagged values where missing ($augmented), and then process this result -->
        <xsl:apply-templates select="$augmented" mode="documentation"/>
    </xsl:template>
   
    <xsl:template match="node()|@*" mode="augment">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="augment"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="UML:ModelElement.taggedValue[not(UML:TaggedValue[@tag=('documentation','description','TESTTV')])]" mode="augment">
        <UML:ModelElement.taggedValue>
            <xsl:choose>
                <xsl:when test="ancestor::UML:Attribute">
                    <UML:TaggedValue tag="description" value="(none)"/>
                </xsl:when>
                <xsl:otherwise>
                    <UML:TaggedValue tag="documentation" value="(none)"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="augment"/>
        </UML:ModelElement.taggedValue>
    </xsl:template>
    
    <!-- assign the top model GUID to this XMI's top model. This certifies that the template model is replaced by the compiled model -->
    <xsl:template match="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement/UML:Package[@name='Model']" mode="documentation">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='xmi.id')]"/>
            <xsl:attribute name="xmi.id" select="$template-file-model-guid"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- tagged values are of contstructs and collaborations; fill all -->
    <xsl:template match="UML:TaggedValue" mode="documentation">
        <xsl:variable name="id" select="@modelElement"/>
        <xsl:choose>
            <!-- if referencing an ID of a collaboration, remove -->
            <xsl:when test="$id and $augmented//UML:Collaboration[@xmi.id=$id]">
                <!-- remove; these are separate tagged values assigned to a collaboration model element IM-208 -->
            </xsl:when>
            <!-- process documentation but not when this is the constraint description -->
            <xsl:when test="@tag='documentation' and not(ancestor::UML:ModelElement.constraint)">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(name()='value')]"/>
                    <xsl:variable name="classifier-role" select="../..[self::UML:ClassifierRole]"/>
                    <xsl:variable name="collaboration" select="$classifier-role/../.."/>
                    <xsl:variable name="collaboration-package" select="$collaboration/../UML:Package[@name=$classifier-role/@name]"/>
                    <xsl:variable name="cp-id" select="if (exists($classifier-role) and $collaboration-package/@xmi.id) then $collaboration-package/@xmi.id else ../../@xmi.id"/>
                    <xsl:variable name="general-construct" select="if (exists($cp-id)) then imf:get-construct-in-derivation-by-id($cp-id) else ()"/>
                    <xsl:variable name="compiled-documentation" select="imf:get-compiled-documentation($general-construct[1],$model-is-traced)"/>
                    <xsl:variable name="compiled-tagged-values" select="imf:get-compiled-tagged-values($general-construct[1],$model-is-traced,false())"/>
                    <xsl:variable name="documentation-tv" as="element()*">
                        <xsl:if test="exists($compiled-tagged-values)">
                            <html:p>METADATA</html:p>
                            <html:ul>
                                <xsl:for-each select="$compiled-tagged-values">
                                    <html:li>
                                        <xsl:value-of select="concat(@original-name,': ',@original-value)"/>
                                    </html:li>
                                </xsl:for-each>
                            </html:ul>
                        </xsl:if> 
                    </xsl:variable>
                    <xsl:variable name="body" as="element()">
                        <body>
                            <xsl:sequence select="$compiled-documentation"/>
                            <xsl:sequence select="$documentation-tv"/>
                        </body>
                    </xsl:variable>
                    
                    <!-- note: when copy-down, several associations may be returned. All are identical. -->
                    <xsl:choose>
                        <xsl:when test="exists($general-construct[1])">
                            <xsl:variable name="eadoc" select="imf:xhtml-to-eadoc($body)"/>
                            <xsl:attribute name="value" select="$eadoc" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="@value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
            </xsl:when>
            <?x
            <xsl:when test="@tag='description'">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(name()='value')]"/>
                    <xsl:variable name="attribute-construct" select="ancestor::UML:Attribute[1]"/>
                    <xsl:variable name="class-id" select="ancestor::UML:Class/@xmi.id"/>
                    <!-- note that in the derivation tree file several copies of the same package may be inserted. These are all the same, so select the first occurrence. --> 
                    <xsl:variable name="class" select="if (exists($class-id)) then imf:get-construct-in-derivation-by-id($class-id)[1] else ()"/>
                    <xsl:variable name="class-attribute" select="$class/imvert:attributes/imvert:attribute[imvert:name=$attribute-construct/@name]"/>
                    <xsl:variable name="compiled-documentation" select="imf:get-compiled-documentation($class-attribute)"/>
                    <xsl:choose>
                        <xsl:when test="not(exists($attribute-construct))">
                            <xsl:copy-of select="@value"/>
                        </xsl:when>
                        <xsl:when test="exists($class-attribute) ">
                            <xsl:attribute name="value" select="imf:export-ea-html($compiled-documentation)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- mag niet -->
                            <xsl:copy-of select="@value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
            </xsl:when>
            ?>
            <xsl:when test="@tag=('ref-version','ref-release','supplier-release','supplier-package-name','base-mapping')">
                <!-- removed, not to show in documentation -->
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>      
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="documentation">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="documentation"/>
        </xsl:copy>
    </xsl:template>
   
</xsl:stylesheet>
