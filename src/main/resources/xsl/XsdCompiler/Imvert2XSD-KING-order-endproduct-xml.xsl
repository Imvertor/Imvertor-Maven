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
    
    <!-- set the processing parameters of the stylesheets. -->
    <!--xsl:variable name="my-debug" select="'no'"/-->
    
    <xsl:template match="/">      
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*">
               <xsl:sort select="ep:position" order="ascending" data-type="number"/>                
            </xsl:apply-templates>
            <!-- Volgende if is om te testen of het juiste ep bestand als basis wordt gebruikt voor het genereren van de schema's -->
            <xsl:if test="parent::*[name(.) = 'ep:message']">
                <ep:construct sourceEntity="Bericht">
                    <ep:name>melding2</ep:name>
                    <ep:tech-name>melding2</ep:tech-name>
                    <ep:documentation/>
                    <ep:max-occurs>unbounded</ep:max-occurs>
                    <ep:min-occurs>0</ep:min-occurs>
                    <ep:authentiek>TO-DO: waar haal ik hiervoor de waarde vandaan</ep:authentiek>
                    <ep:id>{7BF68C7F-0BD4-485d-A42D-005EC3880774}</ep:id>
                    <ep:kerngegevens>TO-DO: waar haal ik hiervoor de waarde vandaan</ep:kerngegevens>
                    <ep:max-length>250</ep:max-length>
                    <ep:max-value>TO-DO: waar komt dit vandaan</ep:max-value>
                    <ep:min-value>TO-DO: waar komt dit vandaan</ep:min-value>
                    <ep:regels>TO-DO: waar haal ik hiervoor de waarde vandaan</ep:regels>
                    <ep:type-name>string</ep:type-name>
                    <ep:voidable>TO-DO: waar haal ik hiervoor de waarde vandaan. Zie ook opmerking in stylesheet Imvert2XSD-KING-create-endproduct-structure.xsl</ep:voidable>
                    <ep:position>100</ep:position>
                </ep:construct>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="*[not(*) and not(name(.)='ep:name' and parent::ep:message)]">
        <xsl:sequence
            select="imf:create-output-element(name(.), .)"/>	
    </xsl:template>

    <xsl:template match="ep:name[parent::ep:message]">
        <xsl:sequence
            select="imf:create-output-element('ep:name', concat(.,'ordered'))"/>	
    </xsl:template>
    
</xsl:stylesheet>
