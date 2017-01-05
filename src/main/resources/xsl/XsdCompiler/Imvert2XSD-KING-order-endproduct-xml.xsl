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
    
    <xsl:template match="/">      
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="ep:tv-position"/>
    
    <xsl:template match="*">
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*"/>
            <xsl:choose>
                <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                    <xsl:apply-templates select="*"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*">
                        <xsl:sort select="ep:position" order="ascending" data-type="number"/>                
                    </xsl:apply-templates>
                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ep:construct[parent::ep:message-set]">
        <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
        <xsl:if test="ep:seq/* | ep:choice/*">
            <xsl:element name="{name(.)}">
                <xsl:apply-templates select="@*"/>
                <xsl:choose>
                    <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                        <xsl:apply-templates select="*"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*">
                            <xsl:sort select="ep:position" order="ascending" data-type="number"/>                
                        </xsl:apply-templates>
                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:if test="not(local-name()='orderingDesired')">
           <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[not(*) and not(name() = 'ep:tv-position') and not(name() = 'ep:namespace')]">
        <xsl:sequence
            select="imf:create-output-element(name(.), .)"/>	
    </xsl:template>
    
    <!-- The following template takes care of replicating the 'ep:constructRef' element removing the 'ep:id' element. -->
    <xsl:template match="ep:constructRef">
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[name() != 'ep:id']"/>
        </xsl:element>       
    </xsl:template>
    
    <xsl:template match="ep:namespace">
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="."/>
        </xsl:element>       
    </xsl:template>
    
</xsl:stylesheet>
