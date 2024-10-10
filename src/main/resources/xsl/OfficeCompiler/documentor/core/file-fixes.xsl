<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  
    xmlns:local="urn:local"
    xmlns:ext="http://zoekservice.overheid.nl/extensions"  
    xmlns:ser="http://www.armatiek.com/xslweb/functions/serialize"
    xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dynfunc="http://www.armatiek.com/xslweb/functions/dynfunc"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:utils="https://koop.overheid.nl/namespaces/utils"
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    
    xmlns:req="http://www.armatiek.com/xslweb/request"
    xmlns:zip="http://www.armatiek.com/xslweb/functions/zip"
    xmlns:file="http://expath.org/ns/file"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/common.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:template match="/">
        
        <xsl:sequence select="local:log('section: file-fixes',$msword-file-subpath)"/>
            
        <!-- unzip de msword files in de folder, en herstel de spaties in de programmacode, Zip terug als msword file. -->
        
        <xsl:variable name="msword-input-file" select="local:safe-file-path($module-work-folder-path || '/' || $msword-file-subpath)"/>
        <xsl:variable name="msword-output-folder" select="local:safe-file-path($module-work-folder-path || '/temp')"/>
        <xsl:variable name="msword-output-file" select="local:safe-file-path($module-work-folder-path || '/' || $msword-file-subpath || '.fixes')"/>
        
        <xsl:sequence select="if (file:exists($msword-output-folder)) then file:delete($msword-output-folder,true()) else ()"/>
        <xsl:sequence select="file:create-dir($msword-output-folder)"/>
        
        <xsl:sequence select="zip:unzip($msword-input-file,$msword-output-folder)"/>
        
        <xsl:variable name="msword-document" select="local:safe-file-path($msword-output-folder || '/word/document.xml')"/>
        <!-- pas de inhoud aan: corrigeer de spaces in code van document.xml -->
        <xsl:variable name="msword-corrected">
            <xsl:apply-templates select="local:document($msword-document)" mode="fix"/>
        </xsl:variable>
        
        <!-- overschrijf het getransformeerde document -->
        <xsl:sequence select="file:write($msword-document, $msword-corrected)"/>
        
        <!-- zip de folder terug naar docx -->
        <xsl:sequence select="zip:zip($msword-output-folder,$msword-output-file)"/>
        <xsl:sequence select="file:delete($msword-output-folder,true())"/>
   
        <msword-output-file>{$msword-output-file}</msword-output-file>  
                    
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="fix">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="w:t[@xml:space='preserve']" mode="fix">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="../../w:pPr/w:pStyle/@w:val = 'Programmacode'">
                    <xsl:analyze-string select="." regex="^(\s+)">
                        <xsl:matching-substring>
                            <xsl:value-of select="string-join(for $n in (1 to string-length(.)) return '&#160;','')"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO oplossen instrText HYPERLINK issue; 
        zie mail Handle w:instrTex for DOCX to HTML conversion
        en https://forum.aspose.com/t/docx-saving-hyperlinks-using-w-hyperlink-instead-of-using-complex-fields/177869/3 
    -->
    
</xsl:stylesheet>