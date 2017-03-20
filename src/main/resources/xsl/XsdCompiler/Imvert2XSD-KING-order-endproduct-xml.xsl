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
    xmlns:stuf="http://www.egem.nl/StUF/StUF0301" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>

    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
      
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="stylesheet">Imvert2XSD-KING-ordered-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-ordered-endproduct-xml.xsl 7487 2016-04-02 07:27:03Z arjan $</xsl:variable> 
    
    <xsl:variable name="kv-prefix" select="/ep:message-set/ep:namespace-prefix"/>
    
    <xsl:template match="/">      
        <ep:message-sets>
            <xsl:apply-templates select="ep:message-set"/>
        </ep:message-sets>
    </xsl:template>
    
    <xsl:template match="ep:message-set">
        <xsl:for-each-group select="ep:*[name() = 'ep:message' or name() = 'ep:construct']" group-by="@prefix">
            <xsl:variable name="groupPrefix" select="current-grouping-key()"/>
            <xsl:variable name="groupNamespaceId" select="../ep:construct[@prefix = $groupPrefix and @namespaceId][1]/@namespaceId"/>
            <ep:message-set prefix="{$groupPrefix}">
                <xsl:choose>
                    <xsl:when test="$groupPrefix = $kv-prefix">
                        <xsl:comment select="'Dit is het KV namespace'"/>
                        <xsl:apply-templates select="../ep:*[name() != 'ep:message' and name() != 'ep:construct']">
                            <xsl:with-param name="actualPrefix" select="$groupPrefix"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-output-element('ep:name', upper-case($groupPrefix))"/>
                        <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $groupPrefix)"/>                       
                        <xsl:sequence select="imf:create-output-element('ep:namespace', $groupNamespaceId)"/>
                        <ep:namespaces>
                            <xsl:apply-templates select="../ep:namespaces/ep:namespace[@prefix != $kv-prefix]">
                                <xsl:with-param name="actualPrefix" select="$groupPrefix"/>
                            </xsl:apply-templates>  
                        </ep:namespaces>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="current-group()">
                    <xsl:with-param name="actualPrefix" select="$groupPrefix"/>
                </xsl:apply-templates>
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

    <xsl:template match="ep:tv-position"/>
    
    <xsl:template match="*">
        <xsl:param name="actualPrefix"/>
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
            </xsl:apply-templates>
            <xsl:choose>
                <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                    <xsl:apply-templates select="*">
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*">
                        <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                    </xsl:apply-templates>              
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ep:construct[parent::ep:message-set]">
        <xsl:param name="actualPrefix"/>
        <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
        <xsl:choose>
            <xsl:when test="ep:seq/* | ep:choice/*">
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*">
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                    </xsl:apply-templates>
                    <xsl:choose>
                        <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                            <xsl:apply-templates select="*">
                                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*">
                                <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>
            <xsl:when test="@ismetadata">
                <xsl:copy-of select="."/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct[ep:tech-name = 'authentiek']">
        <xsl:param name="actualPrefix"/>
        <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
        <xsl:variable name="authentiek">
            <xsl:copy-of select="."/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:authentiek and ep:authentiek != '']]">
                <xsl:sequence select="$authentiek"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="authentiekValid">
                    <xsl:for-each select="ep:constructRef[starts-with(ep:href,'Grp')]">
                        <xsl:variable name="href" select="ep:href"/>
                        <xsl:if test="//ep:construct[ep:tech-name = $href and .//ep:construct[ep:authentiek and ep:authentiek != '']]">
                            <xsl:value-of select="'yes'"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="contains($authentiekValid,'yes')">
                    <xsl:sequence select="$authentiek"/>                        
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct[ep:tech-name = 'inOnderzoek']">
        <xsl:param name="actualPrefix"/>
        <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
        <xsl:variable name="inOnderzoek">
            <xsl:copy-of select="."/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:inOnderzoek and ep:inOnderzoek != '']]">
                <xsl:sequence select="$inOnderzoek"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="inOnderzoekValid">
                    <xsl:for-each select="ep:constructRef[starts-with(ep:href,'Grp')]">
                        <xsl:variable name="href" select="ep:href"/>
                        <xsl:if test="//ep:construct[ep:tech-name = $href and .//ep:construct[ep:inOnderzoek and ep:inOnderzoek != '']]">
                            <xsl:value-of select="'yes'"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="contains($inOnderzoekValid,'yes')">
                    <xsl:sequence select="$inOnderzoek"/>                        
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:param name="actualPrefix"/>
        <xsl:if test="not(local-name()='orderingDesired')">
           <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@prefix">
        <xsl:param name="actualPrefix"/>
        <xsl:choose>
               <xsl:when test=". != '$actualPrefix'">
                   <xsl:copy-of select="."/>
              </xsl:when>
               <xsl:otherwise>
                   <xsl:attribute name="prefix" select="$actualPrefix"/>
               </xsl:otherwise>
           </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[not(*) and not(name() = 'ep:tv-position') and not(name() = 'ep:namespace')]">
        <xsl:param name="actualPrefix"/>
        <xsl:sequence
            select="imf:create-output-element(name(.), .)"/>	
    </xsl:template>
    
    <!-- The following template takes care of replicating the 'ep:constructRef' element removing the 'ep:id' element. -->
    <xsl:template match="ep:constructRef">
        <xsl:param name="actualPrefix"/>
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="*[name() != 'ep:id']"/>
        </xsl:element>       
    </xsl:template>
    
    <xsl:template match="ep:namespace">
        <xsl:param name="actualPrefix"/>
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
            </xsl:apply-templates>
            <xsl:value-of select="."/>
        </xsl:element>       
    </xsl:template>
    
</xsl:stylesheet>
