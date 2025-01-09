<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:file="http://expath.org/ns/file"
    
    expand-text="yes">
    
    <xsl:variable name="cfg-folder">file:/D:/Projects/gitprojects/Imvertor-Maven/src/main/resources/cfg</xsl:variable>
    
    <xsl:template match="/">
        <xsl:variable name="list" select="file:list($cfg-folder,true(),'parms.xml')"/>
        <html>
            <body>
                <xsl:variable name="result" as="element(div)+">
                    <xsl:for-each select="$list">
                        <xsl:variable name="file" select="$cfg-folder || '/' || replace(.,'\\','/')"/>
                        <xsl:message select="$file"/>
                        <xsl:apply-templates select="document($file)" mode="sub">
                            <xsl:with-param name="file" tunnel="yes">{$file}</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="$result">
                    <xsl:sort select="lower-case(@name)"/>
                    <xsl:sequence select="*"/>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="config/cli-parms/cli-parm" mode="sub">
        <xsl:param name="file" tunnel="yes"/>
        <div name="{name}">
            <h2>Pxxx: {name}</h2>
            <p class="Metadata">1; INFO; system; cli-{name}; NL</p>
            <p>{tip}</p>
            <p>Waarde: {arg}, type: {(type,'string')[1]}, verplicht: {required}, default: {(default,'(geen)')[1]}</p>
            <xsl:if test="context">
                <p>Context: {context}</p>
            </xsl:if>            
            <xsl:variable name="toks" select="tokenize($file,'/')"/>
            <p>Module: {$toks[count($toks) - 1]} ({root(.)/config/id/name})</p>
            <xsl:for-each select="*[not(name() = ('name','arg','tip','required','type','context','desc','default'))]">
                <xsl:message select="$file || ' ---> ' || name()"/>
            </xsl:for-each>
            <p>{desc}</p>
        </div>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="sub">
        <xsl:apply-templates select="node()|@*" mode="#current"/>
    </xsl:template>
    
</xsl:stylesheet>