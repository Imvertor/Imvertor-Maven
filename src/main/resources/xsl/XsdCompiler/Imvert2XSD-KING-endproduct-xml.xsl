<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $ 
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
    <xsl:import href="Imvert2XSD-KING-enrich-excel.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-create-endproduct-structure.xsl"/>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="stylesheet">Imvert2XSD-KING-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $</xsl:variable>  
    
    <!-- set the processing parameters of the stylesheets. -->
    <!--xsl:variable name="my-debug" select="'no'"/-->
    
    <!-- Within the next variable the configurations defined within the Base-configuration spreadsheet are placed in a processed XML format.
         With this configuration the attributes to be used on each location within the XML schemas are determined. -->
    <xsl:variable name="enriched-endproduct-base-config-excel">
        <result>
             <xsl:choose> 
                <xsl:when test="ends-with(lower-case($endproduct-base-config-excel),'.xlsx')">
                    <!-- excel based on OO-XML -->
                    <xsl:for-each select="$content-doc/files/file/ss:worksheet">
                        <xsl:variable name="worksheet">
                            <xsl:apply-templates select="." mode="resolve-strings"/>
                        </xsl:variable>
                        <!-- OO-XML is an XML format. Preproces that format if needed. -->
                        <xsl:sequence select="$worksheet"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="ends-with(lower-case($endproduct-base-config-excel),'.xls')">
                    <!-- excel 97-2003 --> 
                    <xsl:message  select="$endproduct-base-config-excel"></xsl:message>
                    <xsl:variable name="xml-path" select="imf:serializeExcel($endproduct-base-config-excel,concat($workfolder-path,'/excel.xml'),$excel-97-dtd-path)"/>
                    <xsl:variable name="xml-doc" select="imf:document(imf:file-to-url($xml-path))"/>
                    <!-- excel 97-2003 is'nt an XML format. Using the above variables the format is translated to XML.
                         The XML format then is processed to be able to use it. -->
                    <xsl:apply-templates select="$xml-doc/workbook"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg('WARNING','No or not a known endproduct base configuration excel file: [1] ', ($endproduct-base-config-excel))"/>
                </xsl:otherwise>
            </xsl:choose>
        </result>
    </xsl:variable>
    
   <xsl:variable name="berichtNaam" select="/imvert:packages/imvert:application"/>
	
    <!-- Within these variables all messages defined within the BSM of the koppelvlak are placed transformed to the imvertor endproduct format.-->
    <xsl:variable name="imvert-endproduct">
       <ep:message-set>
            <xsl:sequence select="imf:create-output-element('ep:date', substring-before(/imvert:packages/imvert:generated,'T'))"/>
            <xsl:sequence select="imf:create-output-element('ep:name', /imvert:packages/imvert:project)"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace', 'TO-DO')"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', 'TO-DO')"/>
            <xsl:sequence select="imf:create-output-element('ep:patch-number', 'TO-DO')"/>
            <xsl:sequence select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)"/>
            
            <xsl:variable name="messages" select="/imvert:packages/imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package')]"/>
            <xsl:comment select="imf:get-config-stereotypes('stereotype-name-domain-package')"/>
            <xsl:apply-templates select="$messages" mode="create-message-structure"/>
        </ep:message-set>
     </xsl:variable>
    
    <xsl:template match="/">
        <!-- This template is used to place the content of the variable '$imvert-endproduct' within the ep file. -->
        <?x xsl:result-document href="file:/c:/temp/imvert-endproduct.xml">
            <xsl:sequence select="$enriched-endproduct-base-config-excel"/>
            
            <!-- xsl:sequence select="$imvert-endproduct/*"/ -->
        </xsl:result-document x?> 
        
        <xsl:sequence select="$imvert-endproduct/*"/>
    </xsl:template>
    
    <!-- supress the suppressXsltNamespaceCheck message -->
    <xsl:template match="/imvert:dummy"/>
    
</xsl:stylesheet>
