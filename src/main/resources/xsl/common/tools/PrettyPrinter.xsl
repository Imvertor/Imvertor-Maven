<?xml version="1.0" encoding="UTF-8"?>

<!-- generic pretty printer for XML -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    >
    
    <xsl:import href="../imvert-common-prettyprint.xsl"/>
   
    <xsl:param name="xml-mixed-content" select="'true'"/> 
        
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <xsl:sequence select="imf:pretty-print(.,not($xml-mixed-content = 'false'))"/>
    </xsl:template>
    
</xsl:stylesheet>