<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
        
    xmlns:local="urn:local"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    xmlns:functx="http://www.functx.com" 
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/extension/imvert-common-hash.xsl"/>
    
     <!-- 
        omzetten van het xhtml formaat dat uit XHTML van pandoc
        Deze HTML bevat ook eigen tags, die hier naar XHTML equivalent worden omgezet. 
    -->
    
    <!-- == metadata == -->
   
    <xsl:template match="meta">
        <!-- skip; dealt with in calling xsl -->
    </xsl:template>
    
    <!-- == structure == -->
    
    <xsl:template match="page">
        <xsl:element name="{ 'h' || count(ancestor-or-self::page)}">
            <a name="{@id}"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="title">
        <xsl:element name="{ 'h' || count(ancestor-or-self::page)}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="heading">
        <p>
            <strong>
                <xsl:apply-templates/>
            </strong>
        </p>
    </xsl:template>
    
    <!-- == code == -->
    
    <xsl:template match="code[@metadata-format]">
        <div class="code">
            <pre><code class="{@metadata-format}"><xsl:apply-templates select="line"/></code></pre>
            <div class="code_format">
                <xsl:value-of select="@metadata-format"/>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="code | codechar">
        <xsl:choose>
            <xsl:when test="line">
                <div class="code">
                    <pre><code class="nohighlight"><xsl:apply-templates select="line"/></code></pre> 
                </div>
            </xsl:when>
            <xsl:otherwise>
                <code class="nohighlight"><xsl:apply-templates/></code>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="code/line">
        <xsl:apply-templates/>
        <xsl:if test="position() != last()">
            <xsl:value-of select="'&#10;'"/>
        </xsl:if> 
    </xsl:template>
    
    <!-- == images == -->
    
    <xsl:template match="image">
        <figure class="image image-type-{(@metadata-type,'default')[1]}">
            <xsl:choose>
                <xsl:when test="raw">
                    <xsl:variable name="raw" as="xs:string+">
                        <xsl:analyze-string select="raw" regex="^data:(.+?);base64,(.*)$">
                            <xsl:matching-substring>
                                <xsl:sequence select="(regex-group(1),regex-group(2))"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    
                    <xsl:variable name="page" select="(ancestor::page[@original-id])[last()]"/>
                    <xsl:variable name="imgs" select="$page//image"/>
                    <xsl:variable name="hash" select="imf:calculate-hash($raw[2])"/>
                    <xsl:variable name="img-name" select="'img_hash_' || $hash || '.' || local:get-extension-for-mime($raw[1])"/>
                    <xsl:variable name="img-src" select="'Images-store/' || $img-name"/>
                    <xsl:variable name="img-path" select="imf:get-xparm('system/work-app-folder-path') || '/cat/Images-store/' || $img-name"/>
                    
                    <!-- save there -->
                    <xsl:try>
                        <xsl:sequence xmlns:ext="http://www.imvertor.org/xsl/extensions" select="ext:imvertorExpathWriteBinary($img-path,$raw[2])"/> 
                        <!--TODO 
                            toevoegen aan expath extensions, en die ook (allemaal) testen
                            nb expath vraag niet om string maar om een xs:base64Binary dus xs:base64Binary($raw[2])
                        -->
                        <xsl:catch xmlns:err="http://www.w3.org/2005/xqt-errors">
                            <xsl:message select="'Error reading binary data for ' || $img-name || ': ' || $err:description"/>
                        </xsl:catch>          
                    </xsl:try>
                    
                    <!-- determine the size from style, e.g. width:4.74861in;height:0.74028in -->
                    <xsl:variable name="dims" as="xs:string*">
                        <xsl:analyze-string select="style" regex="^width:(.+?);height:(.+?)$">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/>
                                <xsl:value-of select="regex-group(2)"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                  
                    <!-- and create the link to the image -->
                    <div style="width:auto;">
                        <img src="{$img-src}" style="max-width: 100%; width: auto; height: auto;"/> <!-- width="{$dims[1]}" height="{$dims[2]}" --> 
                    </div>
                    
                </xsl:when>
                <xsl:otherwise>
                    <img src="img/{@src}"  style="max-width: 100%; width: auto; height: auto;"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="caption"/>
        </figure>
    </xsl:template>
    
    <xsl:function name="functx:index-of-node" as="xs:integer*">
        <xsl:param name="nodes" as="node()*"/> 
        <xsl:param name="nodeToFind" as="node()"/> 
        
        <xsl:sequence select=" 
            for $seq in (1 to count($nodes))
            return $seq[$nodes[$seq] is $nodeToFind]
            "/>
        
    </xsl:function>
    
    <xsl:template match="caption">
        <figcaption class="caption">
            <xsl:apply-templates/>
        </figcaption>
    </xsl:template>
    
    <!-- == boxes == -->
    
    <xsl:template match="box">
        <xsl:variable name="format" select="if (@metadata-format) then ('_' || @metadata-format) else if (@type) then ('_' || @type) else ''"/>
        <xsl:variable name="label" select="if (@label) then @label else ()"/>
        <div class="box{$format}">
            <xsl:if test="$label">
                <div class="box_inner_label">
                    <xsl:value-of select="$label"/>:
                </div>
            </xsl:if>
            <div class="box_inner_body">
                <xsl:apply-templates/>
            </div>
            <xsl:if test="@href">
                <div class="box_inner_href">
                    <a href="{@href}">
                        <xsl:value-of select="@href"/>
                    </a>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    
    <!-- == functions == -->
    
    <xsl:function name="local:get-extension-for-mime" as="xs:string?">
        <xsl:param name="mimetype"/>
        <xsl:choose>
            <xsl:when test="$mimetype = 'image/jpeg'">jpg</xsl:when>
            <xsl:when test="$mimetype = 'image/png'">png</xsl:when>
            <xsl:otherwise>
                <error>UNRECOGNIZED MIMETYPE: {$mimetype}</error>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- == default == -->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>