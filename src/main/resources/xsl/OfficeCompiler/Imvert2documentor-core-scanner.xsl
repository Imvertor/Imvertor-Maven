<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2documentor-common.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:template match="/">
        
        <!-- 
            Alle xhtml bestanden staan klaar. 
            Integreren. 
            Start bij het document dat in /Report/modeldoc staat, dus bijv. voor Bakstenen basismodel is dat: /Report/modeldoc/Bakstenen basismodel/*.docx"
        -->
        <xsl:variable name="masterdoc-name" select="imf:get-xparm('documentor/masterdoc-name')"/> <!-- bijv. Bakstenen conceptueel model.docx -->

        <xsl:sequence select="local:log('section: Scanner on ' || $masterdoc-name,())"/>
        
        <!-- 
            stel het geintegreerde document samen. Dat zit in de <document> wrapper; het betreft XHTML, Leapinlist delivery, Solr docs etc.
        --> 
        <xsl:variable name="integrated" select="local:integrate($masterdoc-name,())"/>
        
        <xsl:sequence select="local:log('$integrated',$integrated)"/>
     
        <xsl:sequence select="$integrated"/>
       
    </xsl:template>
    
    <!-- 
       Integrate: invoegen van alle documenten in het master modeldoc document.
     -->
    <xsl:function name="local:integrate" as="element(document)">
        <xsl:param name="doc-name" as="xs:string"/>
        <xsl:param name="docs-processed" as="xs:string*"/>
        
        <xsl:variable name="doc-path" select="$module-work-folder-path || '/' || $doc-name || '.xhtml'"/>
        
        <xsl:variable name="doc" select="imf:document($doc-path)/document" as="element(document)?"/>
        
        <document name="{$doc-name}">
            <xsl:choose>
                <xsl:when test="$doc">
                    <!-- wanneer subdocument, dan alleen de echte inhoud van het subdocument; introductietekst en eerste heading overslaan. -->
                    <xsl:variable name="doc-effective" select="if (empty($docs-processed)) then $doc/* else $doc/page/*[empty(self::title)]"/>
                    <xsl:apply-templates select="$doc-effective" mode="local:integrate">
                        <xsl:with-param name="docs-processed" select="($docs-processed,$doc-name)" tunnel="yes"/>
                    </xsl:apply-templates>    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg('ERROR','Cannot find MsWord file [1]',$doc-name)"/>
                    <error loc="(scanner)">Geen MsWord bestand "{$doc-name}" aangetroffen.</error>
                </xsl:otherwise>
            </xsl:choose>
        </document>
    </xsl:function>
    
    <xsl:template match="include-section" mode="local:integrate">
        <xsl:param name="docs-processed" tunnel="yes"/>
        <xsl:variable name="doc-name" select="."/>
        <xsl:choose>
            <xsl:when test="$docs-processed = $doc-name">
                <xsl:sequence select="imf:msg('ERROR','Cannot process document [1] twice',$doc-name)"/>
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