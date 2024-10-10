<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:ext="http://zoekservice.overheid.nl/extensions"  
    xmlns:ser="http://www.armatiek.com/xslweb/functions/serialize"
    xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
   
    xmlns:amf="http://www.armatiek.nl/functions" 
    
    xmlns:dynfunc="http://www.armatiek.com/xslweb/functions/dynfunc"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:utils="https://koop.overheid.nl/namespaces/utils"
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    
    xmlns:file="http://expath.org/ns/file"
    xmlns:req="http://www.armatiek.com/xslweb/request"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/common.xsl"/>
    <xsl:import href="../common/common-pandoc.xsl"/>
    <xsl:import href="../common/pack-xml-clean.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:template match="/msword-output-file">
        
        <xsl:sequence select="local:log('section: file-pandoc',string(.))"/>
        
        <xsl:variable name="url" select="local:file-to-url(local:get-system-path(.))"/>
        <xsl:variable name="added-parms" as="xs:string">
            --indented-code-classes=Programmacode --section-divs
            --self-contained
            --metadata=pagetitle:"NOTITLE"
            --ipynb-output=all
            --variable=lang:nl-NL
            --log=/pandoc-log/log.txt
        </xsl:variable>
        <xsl:variable name="html-result" select="amf:convert-doc-to-html($url,'pandoc -f docx+styles -t html ' || normalize-space($added-parms))"/>

        <document>
            <xsl:choose>
                <xsl:when test="$html-result/error">
                    <error loc="{.}">{$html-result/error/@http-status-code} | Cannot process {file:name(.)} | Message: {$html-result/error/@message}</error>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="pack:xml-clean($html-result)"/>
                </xsl:otherwise>
            </xsl:choose>
        </document>
        
    </xsl:template>
    
</xsl:stylesheet>