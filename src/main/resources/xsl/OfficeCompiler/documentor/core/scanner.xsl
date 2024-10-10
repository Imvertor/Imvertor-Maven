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
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/common.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:template match="/">
        
        <xsl:sequence select="local:log('section: Scanner',/)"/>
        
        <!-- ga door alle MsWord documenten in de module folder heen en biedt deze aan aan de webapp -->
        <xsl:variable name="msword-files" select="local:file-list($module-work-folder-path,false(),'*.docx')"/>
        <xsl:for-each select="$msword-files">
            <xsl:if test="not(starts-with(.,'~')) and not(matches(.,'\.docx\.'))"><!-- in debug situatie wordt dezelfde folder hergebruikt; oude resultaten blijven staan. Ook hidden files. Hier overslaan. -->
                <xsl:sequence select="local:log('START MSWORD',.)"/>
                <xsl:variable name="xhtml-result" select="local:document('xslweb:///documentor/file?'
                    || 'owner=' || $active-owner-name 
                    || '&amp;workfolder=' || encode-for-uri($work-folder-path) 
                    || '&amp;msword=' || encode-for-uri(.))"/>      
                <!-- schrijf dit weg naar de module folder: documenten in de vorm van <document> met daarin mix van html en eigen elementen zoals <page> -->
                <xsl:sequence select="file:write($module-work-folder-path || '/' || file:name(.) || '.xhtml',$xhtml-result,$xml-ser-params)"/>
                <xsl:sequence select="local:log('EINDE MSWORD',$xhtml-result)"/>
            </xsl:if>
        </xsl:for-each>  
        
        <!-- 
            Nu staan alle xhtml bestanden klaar. 
            Integreren. 
            Start bij het document dat in /Report/modeldoc staat, dus bijv. voor Bakstenen basismodel is dat: /Report/modeldoc/Bakstenen basismodel/*.docx"
        -->
        <xsl:variable name="masterdoc-name" select="if ($imvertor-context) then local:file-list($work-folder-path || '/xmi/Report/modeldoc',false(),())[1] else $passed-masterdoc"/>
        
        <xsl:sequence select="req:set-attribute('masterdoc-name',$masterdoc-name)"/>
        <!-- 
            stel het geintegreerde document samen. Dat zit in de <document> wrapper; het betreft XHTML, Leapinlist delivery, Solr docs etc.
        --> 
        <xsl:variable name="integrated" select="local:integrate($masterdoc-name || '.docx',())"/>
        
        <xsl:sequence select="local:log('$integrated',$integrated)"/>
     
        <xsl:sequence select="$integrated"/>
        
    </xsl:template>
    
    <!-- 
       Integrate: invoegen van alle documenten in het mail modeldoc document.
     -->
    <xsl:function name="local:integrate" as="element(document)">
        <xsl:param name="doc-name" as="xs:string"/>
        <xsl:param name="docs-processed" as="xs:string*"/>
        <xsl:variable name="doc-path" select="$module-work-folder-path || '/' || $doc-name || '.xhtml'"/>
        <document name="{$doc-name}">
            <xsl:choose>
                <xsl:when test="file:exists($doc-path)">
                    <xsl:sequence select="local:log('Integrating report file',$doc-path)"/>
                    <xsl:variable name="doc" select="local:document($doc-path)/document" as="element(document)"/>
                    <!-- wanneer subdocument, dan alleen de echte inhoud van het subdocument; introductietekst en eerste heading overslaan. -->
                    <xsl:variable name="doc-effective" select="if (empty($docs-processed)) then $doc/* else $doc/page/*[empty(self::title)]"/>
                    <xsl:apply-templates select="$doc-effective" mode="local:integrate">
                        <xsl:with-param name="docs-processed" select="($docs-processed,$doc-name)" tunnel="yes"/>
                    </xsl:apply-templates>    
                </xsl:when>
                <xsl:otherwise>
                    <error loc="(scanner)">Geen MsWord bestand "{file:name($doc-path)}" aangetroffen.</error>
                    <xsl:sequence select="local:log('error: geen report file',$doc-path)"/>
                </xsl:otherwise>
            </xsl:choose>
        </document>
    </xsl:function>
    
    <xsl:template match="include-section" mode="local:integrate">
        <xsl:param name="docs-processed" tunnel="yes"/>
        <xsl:variable name="doc-name" select="."/>
        <xsl:choose>
            <xsl:when test="$docs-processed = $doc-name">
                <error loc="(scanner)">Dit document is al verwerkt: "{$doc-name}"</error>            
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="local:integrate($doc-name,$docs-processed)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*" mode="local:integrate">
        <xsl:copy>
            <xsl:variable name="id" select="(@metadata-id,@original-id)[normalize-space(.)][1]"/>
            <xsl:if test="$id">
                <xsl:attribute name="id" select="$id"/>
            </xsl:if>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="local:integrate" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>