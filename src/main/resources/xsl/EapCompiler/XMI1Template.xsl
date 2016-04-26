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
    
    xmlns:UML="omg.org/UML1.3" 

    exclude-result-prefixes="#all"
    version="2.0"
    >
    
    <!-- maak een working copy aan vanuit dit XMI bestand. -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:param name="original-project-name" select="imf:get-config-string('appinfo','original-project-name')"/>
    <xsl:param name="original-application-name" select="imf:get-config-string('appinfo','original-application-name')"/>
    
    <xsl:param name="new-application-name" select="concat($application-package-name, ' (template)')"/>
    <xsl:param name="new-application-author" select="'NEWAUTHOR'"/>
    
    <!-- get all ID values -->
    <!--TODO optimize, see jira IM-423 Must be a keydef?-->
    <xsl:variable name="idmap" as="element()+">
        <xsl:apply-templates select="//@xmi.id" mode="idmap"/>
    </xsl:variable>
    
    <!-- determine which element/attributes are typed as ID -->
    <xsl:variable name="idrep" as="element()+">
        <xsl:variable name="n" as="element()+">
            <xsl:for-each select="//@*">
                <xsl:if test="$idmap/@old=current()">
                    <m ns="" elm="{local-name(parent::*)}" att="{local-name(.)}"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each-group select="$n" group-by="concat(@elm, '/', @att)">
            <xsl:sequence select="current-group()[1]"/>
        </xsl:for-each-group>
    </xsl:variable>
    
    <xsl:variable name="project-package" select="/XMI/XMI.content/UML:Model/UML:Namespace.ownedElement/UML:Package/UML:Namespace.ownedElement/UML:Package[@name = $original-project-name]"/>
    <xsl:variable name="model-package" select="$project-package/UML:Namespace.ownedElement/UML:Package[@name = $original-application-name][1]"/>
    <xsl:variable name="domain-package" select="$model-package/UML:Namespace.ownedElement/UML:Package"/>
    
    <xsl:variable name="model-package-id" select="$model-package/@xmi.id"/>
    <xsl:variable name="domain-package-id" select="$domain-package/@xmi.id"/>
    
    <xsl:variable name="model-classifier-role" select="$model-package/../UML:Collaboration/UML:Namespace.ownedElement/UML:ClassifierRole[imf:id-match(@xmi.id,$model-package-id)]"/>
    <xsl:variable name="domain-classifier-role" select="$domain-package/../UML:Collaboration/UML:Namespace.ownedElement/UML:ClassifierRole[imf:id-match(@xmi.id,$domain-package-id)]"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- change the name of the application -->
    <xsl:template match="*[. intersect ($model-package,$model-classifier-role)]">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()=$original-application-name)]"/>
            <xsl:attribute name="name" select="$new-application-name"/>
            <xsl:apply-templates select="node()" mode="model-package"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*[. intersect ($domain-package,$domain-classifier-role)]" mode="model-package">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()" mode="domain-package"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="UML:TaggedValue[@tag=('ea_sourceName','package_name') and @value=$original-application-name]" mode="model-package">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='value')]"/>
            <xsl:attribute name="value" select="'$new-application-name'"/>
        </xsl:copy>
    </xsl:template>
 
    <!-- change the stereotype of the application -->
    
    <xsl:template match="UML:ClassifierRole[@name=$original-application-name]/UML:ModelElement.stereotype/UML:Stereotype"  mode="model-package">
        <UML:Stereotype name="toepassing"/>
    </xsl:template>
    
    <!-- change the tagged values -->
   
    <xsl:template match="*[. intersect ($model-package,$model-classifier-role)]/UML:ModelElement.taggedValue/UML:TaggedValue" mode="model-package">
        <xsl:choose>
            <xsl:when test="@tag='alias'">
                <UML:TaggedValue tag="alias" value="{concat(@value,'/template')}"/>
            </xsl:when>
            <xsl:when test="@tag='status'">
                <UML:TaggedValue tag="alias" value="'Draft'"/>
            </xsl:when>
            <xsl:when test="@tag='documentation'">
                <xsl:sequence select="imf:create-documentation(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[. intersect ($domain-package,$domain-classifier-role)]/UML:ModelElement.taggedValue/UML:TaggedValue" mode="domain-package">
        <xsl:choose>
            <xsl:when test="@tag='alias'">
                <UML:TaggedValue tag="alias" value="{concat(@value,'/template')}"/>
            </xsl:when>
            <xsl:when test="@tag='documentation'">
                <xsl:sequence select="imf:create-documentation(.)"/>
            </xsl:when>
            <xsl:when test="@tag='stereotype' and @value='basismodel'">
                <UML:TaggedValue tag="stereotype" value="toepassing"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[self::UML:Class | self::UML:Attribute | self::UML:Association]/UML:ModelElement.taggedValue/UML:TaggedValue" mode="domain-package">
        <xsl:choose>
            <xsl:when test="@tag='documentation'">
                <xsl:sequence select="imf:create-documentation(.)"/>
            </xsl:when>
            <xsl:when test="@tag='description'">
                <xsl:sequence select="imf:create-documentation(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@xmi.id" mode="idmap">
        <m ns="" old="{.}" new="{.}"/> <!-- no change needed; automatic import will reset all GUIDs -->
    </xsl:template>
    
    <xsl:template match="@*" mode="#all">
        <xsl:variable name="attname" select="local-name(.)"/>
        <xsl:variable name="attval" select="."/>
        <xsl:variable name="mappedval" select="$idmap[@old=$attval]/@new"/>
        <xsl:variable name="elmname" select="local-name(..)"/>
        <xsl:choose>
            <xsl:when test="local-name(.) = 'xmi.id'">
                <xsl:attribute name="xmi.id" select="$idmap[@old=current()]/@new"/>
            </xsl:when>
            <xsl:when test="$idrep[@elm=$elmname and @att=$attname and $mappedval]">
                <xsl:attribute name="{$attname}" select="$mappedval"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{$attname}" select="$attval"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <xsl:template match="node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:function name="imf:create-documentation">
        <xsl:param name="tagged-value"/>
        <xsl:for-each select="$tagged-value"><!-- singleton-->
            <xsl:copy>
                <xsl:copy-of select="@*[not(name()='value')]"/>
                <xsl:attribute name="value" select="concat(imf:get-config-parameter('documentation-newline'), imf:get-config-parameter('documentation-separator'), $original-application-name, imf:get-config-parameter('documentation-separator'), imf:get-config-parameter('documentation-newline'), @value)"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
        identifiers may start with EAID_ or EAPK_. In some bases, '-collaboration'is added. Check if identifiers still match 'for the most part'. 
    -->
    <xsl:function name="imf:id-match" as="xs:boolean">
        <xsl:param name="id1" as="xs:string+"/>
        <xsl:param name="id2" as="xs:string+"/>
        <xsl:variable name="id1norm" select="for $id in ($id1) return substring-after(replace(replace($id,'-','_'),'_Collaboration',''),'_')"/>
        <xsl:variable name="id2norm" select="for $id in ($id2) return substring-after(replace(replace($id,'-','_'),'_Collaboration',''),'_')"/>
        <xsl:sequence select="$id1norm = $id2norm"/>
    </xsl:function>
</xsl:stylesheet>
