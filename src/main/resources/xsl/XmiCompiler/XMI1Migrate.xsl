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
    xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    xmlns:UML="omg.org/UML1.3"
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
    xmlns:EAUML="http://www.sparxsystems.com/profiles/EAUML/1.0"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:functx="http://www.functx.com"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
        fix some XMI constructs before transforming the XMI to imvert 
    
        zie "\Documents\20160907 Kadaster migratie naar nieuwe metamodel.xlsx"  
    -->

    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:param name="migration-mode"/>
    
    <xsl:template match="/XMI">
        <xsl:comment select="concat('Migrated dd. ', current-dateTime(), ' in mode ',$migration-mode)"/>
        <xsl:variable name="resolved">
            <xsl:apply-templates select="." mode="resolve-idrefs"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$migration-mode = 'VNG'">
                <xsl:apply-templates select="$resolved" mode="mode-VNG"/>
            </xsl:when>
            <xsl:when test="$migration-mode = ('IMGEO','IMKL','NEN3610')">
                <xsl:apply-templates select="$resolved" mode="mode-Geonovum"/>
            </xsl:when>
            <xsl:otherwise>
                <error>
                    <xsl:sequence select="imf:msg('ERROR','Unsuppported migration mode [1]',$migration-mode)"/>
                </error>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <?X
    <!-- localize de stereotypes -->
    <xsl:template match="UML:Stereotype/@name">
        <xsl:variable name="v" select="lower-case(.)"/>
        <xsl:attribute name="name">
            <xsl:choose>
                <xsl:when test="$v = 'domain'">domein</xsl:when>
                <xsl:when test="$v = 'application'">toepassing</xsl:when>
                <xsl:when test="$v = 'external'">extern</xsl:when>
                <xsl:when test="$v = 'recyclebin'">prullenbak</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!-- localize de stereotypes -->
    <xsl:template match="UML:TaggedValue[@tag = 'stereotype']/@value">
        <xsl:variable name="v" select="lower-case(.)"/>
        <xsl:attribute name="value">
            <xsl:choose>
                <xsl:when test="$v = 'domain'">domein</xsl:when>
                <xsl:when test="$v = 'application'">toepassing</xsl:when>
                <xsl:when test="$v = 'external'">extern</xsl:when>
                <xsl:when test="$v = 'recyclebin'">prullenbak</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="UML:TaggedValue[@tag = '$ea_xref_property']/@value">
        <xsl:variable name="v1" select="."/>
        <xsl:variable name="v2" select="replace($v1,'@STEREO;Name=application;','@STEREO;Name=toepassing;')"/>
        <xsl:variable name="v3" select="replace($v2,'@STEREO;Name=domain;','@STEREO;Name=domein;')"/>
        <xsl:variable name="v4" select="replace($v3,'@STEREO;Name=external;','@STEREO;Name=extern;')"/>
        <xsl:variable name="v5" select="replace($v4,'@STEREO;Name=recyclebin;','@STEREO;Name=prullenbak;')"/>
        
        <xsl:attribute name="value" select="$v5"/>
    </xsl:template>
    X?>
    
    <!-- VNG migrations -->
    
    <xsl:template match="UML:Stereotype/@name[starts-with(.,'MUG ')]" mode="mode-VNG">
        <xsl:attribute name="name" select="substring-after(.,'MUG ')"/>
    </xsl:template>
    <xsl:template match="UML:TaggedValue[@tag='stereotype']/@value[starts-with(.,'MUG ')]" mode="mode-VNG">
        <xsl:attribute name="value" select="substring-after(.,'MUG ')"/>
    </xsl:template>
    
    <xsl:template match="UML:Stereotype/@name[starts-with(.,'MBG ')]" mode="mode-VNG">
        <xsl:attribute name="name" select="substring-after(.,'MBG ')"/>
    </xsl:template>
    <xsl:template match="UML:TaggedValue[@tag='stereotype']/@value[starts-with(.,'MBG ')]" mode="mode-VNG">
        <xsl:attribute name="value" select="substring-after(.,'MBG ')"/>
    </xsl:template>
    
    <!-- Geonovum migrations -->
    
    <xsl:template match="UML:Model" mode="mode-Geonovum">
        <UML:Model name="EA Model" xmi.id="MX_EAID_A74CE7E8_412F_4656_877F_E486E31317EB_DUMMY">
            <xsl:apply-templates select="*" mode="#current"/>
        </UML:Model>
        <UML:TaggedValue tag="Release" xmi.id="EAID_3AE37A01_E69F_cfe6_B040_66BE9B7CCD74" value="20200618" modelElement="MX_EAID_A74CE7E8_412F_4656_877F_E486E31317EB_DUMMY"/>
        <UML:TaggedValue tag="Release" xmi.id="EAID_3AE37A01_3E98_c43e_A110_4417A01ED8F7" value="20200618" modelElement="EAID_FA54572B_55A1_4f43_A1CC_2037A8B656FC_DUMMY"/>
        <UML:TaggedValue tag="Afkorting" xmi.id="EAID_0C9EE2AB_630B_4b68_AC97_32B80AEEE298" value="{$migration-mode}" modelElement="MX_EAID_A74CE7E8_412F_4656_877F_E486E31317EB_DUMMY"/>
    </xsl:template>
    
    <xsl:template match="UML:Package[UML:ModelElement.stereotype/UML:Stereotype = ('applicationSchema')]" mode="mode-Geonovum">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <UML:ModelElement.stereotype>
                <UML:Stereotype>Basismodel</UML:Stereotype>
            </UML:ModelElement.stereotype>
            <UML:ModelElement.taggedValue>
                <UML:TaggedValue tag="version" value="1.0.0"/>
                <UML:TaggedValue tag="phase" value="1"/>
                <UML:TaggedValue tag="stereotype" value="Basismodel"/>
                <UML:TaggedValue tag="alias" value="/site"/>
                <UML:TaggedValue tag="release" value="20200622"/>
            </UML:ModelElement.taggedValue>
            <UML:Namespace.ownedElement>
                <UML:Package name="Model" xmi.id="EAPK_FA54572B_55A1_4f43_A1CC_2037A8B656FC_DUMMY" isRoot="false" isLeaf="false" isAbstract="false" visibility="public">
                    <UML:ModelElement.stereotype>
                        <UML:Stereotype>Domein</UML:Stereotype>
                    </UML:ModelElement.stereotype>
                    <UML:ModelElement.taggedValue>
                        <UML:TaggedValue tag="version" value="1.0.0"/>
                        <UML:TaggedValue tag="phase" value="1"/>
                        <UML:TaggedValue tag="stereotype" value="Domein"/>
                        <UML:TaggedValue tag="alias" value="/site/page"/>
                        <UML:TaggedValue tag="release" value="20200622"/>
                    </UML:ModelElement.taggedValue>
                    <xsl:apply-templates select="UML:Namespace.ownedElement" mode="#current"/>
                </UML:Package>
            </UML:Namespace.ownedElement>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="UML:Class/UML:ModelElement.stereotype/UML:Stereotype/@name[. = ('ADEElement','featureType','ADE')]" mode="mode-Geonovum">
        <xsl:attribute name="name" select="'ObjectType'"/>
    </xsl:template>
    <xsl:template match="UML:Class/UML:ModelElement.taggedValue/UML:TaggedValue[@tag = 'stereotype']/@value[. = ('ADEElement','featureType','ADE')]" mode="mode-Geonovum">
        <xsl:attribute name="name" select="'ObjectType'"/>
    </xsl:template>
    
    <xsl:template match="UML:Class/UML:ModelElement.stereotype/UML:Stereotype/@name[. = ('codeList')]" mode="mode-Geonovum">
        <xsl:attribute name="name" select="'Enumeratie'"/>
    </xsl:template>
    <xsl:template match="UML:Class/UML:ModelElement.taggedValue/UML:TaggedValue[@tag = 'stereotype']/@value[. = ('codeList')]" mode="mode-Geonovum">
        <xsl:attribute name="name" select="'Enumeratie'"/>
    </xsl:template>
    
    <xsl:template match="UML:Class[UML:ModelElement.stereotype/UML:Stereotype/@name = ('codeList')]/UML:Classifier.feature/UML:Attribute/UML:ModelElement.stereotype/UML:Stereotype/@name[. = ('BGT')]" mode="mode-Geonovum" priority="10">
        <!-- remove -->
    </xsl:template>
    <xsl:template match="UML:Class[UML:ModelElement.stereotype/UML:Stereotype/@name = ('codeList')]/UML:Classifier.feature/UML:Attribute/UML:ModelElement.taggedValue/UML:TaggedValue[@tag = 'stereotype']/@value[. = ('BGT')]" mode="mode-Geonovum" priority="10">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="UML:Attribute/UML:ModelElement.stereotype/UML:Stereotype/@name[. = ('attribuuttype','BGT')]" mode="mode-Geonovum">
        <xsl:attribute name="name" select="'Attribuutsoort'"/>
    </xsl:template>
    <xsl:template match="UML:Attribute/UML:ModelElement.taggedValue/UML:TaggedValue[@tag = 'stereotype']/@value[. = ('attribuuttype','BGT')]" mode="mode-Geonovum">
        <xsl:attribute name="value" select="'Attribuutsoort'"/>
    </xsl:template>
    
    <xsl:template match="UML:Attribute/UML:ModelElement.stereotype/UML:Stereotype/@name[. = ('enumeratiewaarde')]" mode="mode-Geonovum">
        <xsl:attribute name="name" select="'Enumeratiewaarde'"/>
    </xsl:template>
    <xsl:template match="UML:Attribute/UML:ModelElement.taggedValue/UML:TaggedValue[@tag = 'stereotype']/@value[. = ('enumeratiewaarde')]" mode="mode-Geonovum">
        <xsl:attribute name="value" select="'Enumeratiewaarde'"/>
    </xsl:template>
    
    <xsl:template match="UML:Association/UML:ModelElement.stereotype/UML:Stereotype" mode="mode-Geonovum">
        <xsl:copy>
            <xsl:attribute name="name" select="'Relatiesoort'"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="UML:Association/UML:ModelElement.taggedValue" mode="mode-Geonovum">
        <xsl:copy>
            <UML:TaggedValue tag="stereotype" value="Relatiesoort"/>
            <xsl:apply-templates select="*[not(@tag = 'stereotype')]" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="UML:TaggedValue[@tag = 'version']/@value" mode="mode-Geonovum">
        <xsl:attribute name="value" select="'1.0.0'"/>
    </xsl:template>
    <xsl:template match="UML:TaggedValue[@tag = 'phase']/@value" mode="mode-Geonovum">
        <xsl:attribute name="value" select="'1'"/>
    </xsl:template>
    
    
    <!-- defaults -->
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
   
    <!-- resolve idrefs -->
    <xsl:variable name="idmap" select="//*[@xmi.id]"/>
    
    <xsl:template match="*[@xmi.idref]" mode="resolve-idrefs">
        <xsl:variable name="id" select="@xmi.idref"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="self::UML:Stereotype">
                    <xsl:value-of select="$idmap[@xmi.id = $id]/@name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@xmi.idref"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
