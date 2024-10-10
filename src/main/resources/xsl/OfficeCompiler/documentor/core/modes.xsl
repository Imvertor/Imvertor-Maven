<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:ext="http://zoekservice.overheid.nl/extensions"  
    xmlns:ser="http://www.armatiek.com/xslweb/functions/serialize"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dynfunc="http://www.armatiek.com/xslweb/functions/dynfunc"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:utils="https://koop.overheid.nl/namespaces/utils"
    
    xmlns:req="http://www.armatiek.com/xslweb/request"
    xmlns:zip="http://www.armatiek.com/xslweb/functions/zip"
    xmlns:file="http://expath.org/ns/file"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    
    xmlns:log="http://www.armatiek.com/xslweb/functions/log"
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    xmlns:webapp="http://www.armatiek.com/xslweb/functions/webapp"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/common.xsl"/>
    <xsl:import href="../modes/mode-default.xsl"/>
    <xsl:import href="../modes/mode-primer.xsl"/>
    
    <xsl:template match="/">
    
        <xsl:variable name="props" select="webapp:get-attribute('props')"/><!-- alle properties uitgelezen uit master document -->
        
        <xsl:choose>
            <xsl:when test="$mode = 'primer' or $props[@key = 'Module'] = 'Primer'">
                <xsl:sequence select="pack:mode-primer(/document)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="pack:mode-default(/document)"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

</xsl:stylesheet>