<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    
    xmlns:file="http://expath.org/ns/file"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:local"
    xmlns:util="http://www.armatiek.com/xslweb/functions/util"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    expand-text="yes" 
    >
  
    <xsl:function name="pack:xml-clean" as="item()*">
        <xsl:param name="xml-frag" as="item()*"/>
        <xsl:apply-templates select="$xml-frag" mode="pack:xml-clean"/>
    </xsl:function>
    <xsl:function name="pack:xml-clean" as="item()*">
        <xsl:param name="xml-frag" as="item()*"/>
        <xsl:param name="cleandef" as="element(def)*"/>
        <xsl:apply-templates select="$xml-frag" mode="pack:xml-clean">
            <xsl:with-param name="cleandef" select="$cleandef"/>
            <xsl:with-param name="default" select="$cleandef[@mode = 'default']"/>
        </xsl:apply-templates>
    </xsl:function>
    
    <xsl:template match="*" mode="pack:xml-clean">
        <xsl:param name="cleandef" as="element(def)*"/>
        <xsl:param name="default" as="element(def)?"/>
        <xsl:variable name="my-uri" select="namespace-uri()"/>
        <xsl:variable name="def" select="$cleandef[@namespace = $my-uri]"/>
        <xsl:variable name="retain" select="$def/@mode = 'retain'"/>
        <xsl:choose>
            <xsl:when test="$retain">
                <xsl:element name="{$default/@prefix}:{local-name()}">
                    <xsl:apply-templates select="node()|@*" mode="#current">
                        <xsl:with-param name="cleandef" select="$cleandef"/>
                        <xsl:with-param name="default" select="$default"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$default">
                <xsl:element name="{$default/@prefix}:{local-name()}">
                    <xsl:apply-templates select="node()|@*" mode="#current">
                        <xsl:with-param name="cleandef" select="$cleandef"/>
                        <xsl:with-param name="default" select="$default"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{local-name()}">
                    <xsl:apply-templates select="node()|@*" mode="#current"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="comment() | processing-instruction() | @*" mode="pack:xml-clean">
        <xsl:copy-of select="."/>
    </xsl:template>   
    
</xsl:stylesheet>