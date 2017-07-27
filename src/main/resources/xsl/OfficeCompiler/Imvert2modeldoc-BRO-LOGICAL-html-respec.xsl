<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!-- the way the Modeldoc is processed for logical models is (temporarily) conform that for conceptual models -->  
    
    <xsl:import href="Imvert2modeldoc-BRO-CONCEPTUAL-html-respec.xsl"/>
    
</xsl:stylesheet>