<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct-xml.xsl 7487 2016-04-02 07:27:03Z arjan $ 
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    
    xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310" 
    xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
    xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" 
    xmlns:stuf="http://www.stufstandaarden.nl/onderlaag/stuf0302" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>

    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
      
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="stylesheet-code" as="xs:string">SKS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>

    <xsl:variable name="stylesheet">Imvert2XSD-KING-ordered-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-ordered-endproduct-xml.xsl 7487 2016-04-02 07:27:03Z arjan $</xsl:variable> 
    
    <xsl:variable name="kv-prefix" select="/ep:message-set/ep:namespace-prefix"/>
    
    <xsl:variable name="patch">
        <xsl:apply-templates select="ep:message-set" mode="patch"/>        
    </xsl:variable>

    <xsl:template match="/">      
        <ep:message-sets>
            <xsl:apply-templates select="ep:message-set"/>
        </ep:message-sets>
    </xsl:template>
    
    <xsl:template match="ep:message-set" mode="patch">
        <ep:constructRef prefix="StUF" ismetadata="yes">
            <ep:name>patch</ep:name>
            <ep:tech-name>patch</ep:tech-name>
            <ep:min-occurs>1</ep:min-occurs>
            <ep:href>patch</ep:href>
        </ep:constructRef>
        <xsl:for-each-group select="/ep:message-set/ep:*[name() = 'ep:message' or name() = 'ep:construct']" group-by="@prefix">
            <xsl:variable name="groupPrefix" select="current-grouping-key()"/>
            <xsl:comment select="'$groupPrefix'"/>
            <ep:constructRef prefix="{$groupPrefix}" ismetadata="yes">
                <ep:name>patch</ep:name>
                <ep:tech-name>patch</ep:tech-name>
                <ep:min-occurs>1</ep:min-occurs>
                <ep:href>patch</ep:href>
            </ep:constructRef>
        </xsl:for-each-group>            
    </xsl:template>
    
    <xsl:template match="ep:message-set">
        <xsl:variable name="namespaces">
            <ep:namespaces>
                <xsl:apply-templates select="ep:namespaces/ep:namespace"/>
                <xsl:for-each select="ep:*[@prefix != $kv-prefix and @namespaceId and @prefix != ''  and @namespaceId != '']">
                    <xsl:variable name="prefix" select="@prefix"/>
                    <xsl:if test="$prefix != preceding-sibling::*/@prefix">
                        <ep:namespace prefix="{$prefix}"><xsl:value-of select="@namespaceId"/></ep:namespace>
                    </xsl:if>
                </xsl:for-each>
            </ep:namespaces>
        </xsl:variable>
        <xsl:for-each-group select="ep:*[name() = 'ep:message' or name() = 'ep:construct']" group-by="@prefix">
            <xsl:variable name="groupPrefix" select="current-grouping-key()"/>
            <xsl:variable name="groupNamespaceId" select="../ep:construct[@prefix = $groupPrefix and @namespaceId][1]/@namespaceId"/>
            <ep:message-set prefix="{$groupPrefix}">
                <xsl:if test="$kv-prefix = $groupPrefix">
                    <xsl:attribute name="KV-namespace" select="'yes'"/>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$groupPrefix = $kv-prefix">
                        <xsl:sequence select="imf:create-debug-comment('Dit is de KV namespace.',$debugging)"/>                
                        <xsl:apply-templates select="../ep:*[name() != 'ep:message' and name() != 'ep:construct' and name() != 'ep:namespaces']">
                        <!--xsl:apply-templates select="../ep:*[name() != 'ep:message' and name() != 'ep:construct']"-->
                            <xsl:with-param name="actualPrefix" select="$groupPrefix"/>
                        </xsl:apply-templates>
                        <xsl:sequence select="$namespaces"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-output-element('ep:name', upper-case($groupPrefix))"/>
                        <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $groupPrefix)"/>                       
                        <xsl:sequence select="imf:create-output-element('ep:namespace', $groupNamespaceId)"/>
                        <ep:namespaces>
                            <xsl:apply-templates select="../ep:namespaces/ep:namespace[@prefix != $kv-prefix]"/>
                            <xsl:for-each select="../ep:*[@prefix and @namespaceId and @prefix != ''  and @namespaceId != '']">
                                <xsl:variable name="prefix" select="@prefix"/>
                                <xsl:if test="$prefix != preceding-sibling::*/@prefix">
                                    <ep:namespace prefix="{$prefix}"><xsl:value-of select="@namespaceId"/></ep:namespace>
                                </xsl:if>
                            </xsl:for-each>
                        </ep:namespaces>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="current-group()"/>
                <ep:construct prefix="{$groupPrefix}" ismetadata="yes">
                    <ep:name>entiteittype</ep:name>
                    <ep:tech-name>entiteittype</ep:tech-name>
                    <ep:type-name>scalar-string</ep:type-name>
                </ep:construct>
                <ep:construct prefix="{$groupPrefix}" ismetadata="yes">
                    <ep:name>patch</ep:name>
                    <ep:tech-name>patch</ep:tech-name>
                    <ep:type-name>scalar-integer</ep:type-name>
                    <ep:min-value>0</ep:min-value>
                </ep:construct>
            </ep:message-set>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="*|@*">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ep:constructRef[@prefix = 'StUF' and ep:name = 'patch']">
        <xsl:copy-of select="$patch"/>    
    </xsl:template>
</xsl:stylesheet>
