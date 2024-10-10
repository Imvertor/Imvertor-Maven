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
    
    expand-text="yes"
    >
    
    <xsl:function name="pack:mode-default" as="element(document)">
        <xsl:param name="document" as="element(document)"/>
        <xsl:apply-templates select="$document" mode="pack:mode-default"/>
    </xsl:function>
   
    <?x
    <xsl:template match="extension" mode="pack:mode-default">
        <error loc="{ancestor-or-self::document[1]/@name}">Geen bekende extensie: {@key}</error>
    </xsl:template>
    x?>
    
    <xsl:template match="node()|@*"  mode="pack:mode-default">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>