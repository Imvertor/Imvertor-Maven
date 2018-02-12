<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/> 
        
    <xsl:template match="/">
        <analysis>
            <xsl:apply-templates/>
        </analysis>
    </xsl:template>
    
    <xsl:template match="cw:file">
        <xsl:variable name="fullpath-file" select="replace(@path,'\\','/')"/>
        <stylesheet>
            <path><xsl:value-of select="$fullpath-file"/></path>
            <imports>
                <xsl:for-each select="xsl:stylesheet/xsl:import">
                    <xsl:variable name="fullpath-import" select="imf:get-fullpath(concat($fullpath-file,'/../',@href))"/>
                    <import>
                        <path><xsl:value-of select="$fullpath-import"/></path>
                    </import>
                </xsl:for-each>
                <xsl:for-each select="../cw:file">
                    <xsl:variable name="fullpath-otherfile" select="replace(@path,'\\','/')"/>
                    <xsl:for-each select="xsl:stylesheet/xsl:import">
                        <xsl:variable name="fullpath" select="imf:get-fullpath(concat($fullpath-otherfile,'/../',@href))"/>
                        <xsl:if test="$fullpath = $fullpath-file">
                            <imported-by>
                                <path><xsl:value-of select="$fullpath-otherfile"/></path>
                            </imported-by>
                        </xsl:if> 
                    </xsl:for-each>
                </xsl:for-each>
            </imports>
            <params>
                <xsl:for-each select="xsl:stylesheet/xsl:param">
                    <param>
                        <name><xsl:value-of select="@name"/></name>
                    </param>
                </xsl:for-each>
            </params>
            <variables>
                <xsl:for-each select="xsl:stylesheet/xsl:variable">
                    <xsl:variable name="name" select="@name"/>
                    <variable>
                        <name><xsl:value-of select="$name"/></name>
                    </variable>
                </xsl:for-each>
            </variables>
            <functions>
                <xsl:for-each select="xsl:stylesheet/xsl:function">
                    <xsl:variable name="params" select="for $p in xsl:param return $p/xsl:name"/>
                    <function>
                        <template><xsl:value-of select="concat(@name,'(',count(xsl:param),')')"/></template>
                        <name><xsl:value-of select="@name"/></name>
                        <params>
                            <xsl:for-each select="xsl:param">
                                <param>
                                    <name><xsl:value-of select="@name"/></name>
                                </param>
                            </xsl:for-each>
                        </params>
                        <variables>
                            <xsl:for-each select=".//xsl:variable">
                                <variable>
                                    <name><xsl:value-of select="@name"/></name>
                                </variable>
                            </xsl:for-each>
                        </variables>
                        <variable-calls>
                            <xsl:variable name="local-declarations" select="(xsl:param/@name,.//xsl:variable/@name)"/>
                            <xsl:apply-templates select="." mode="variable-calls">
                                <xsl:with-param name="local-declarations" select="$local-declarations"/>
                            </xsl:apply-templates>
                        </variable-calls>
                        <function-calls>
                            <xsl:variable name="local-declarations" select="../xsl:function/@name"/>
                            <xsl:apply-templates select="." mode="function-calls">
                                <xsl:with-param name="local-declarations" select="$local-declarations"/>
                            </xsl:apply-templates>
                        </function-calls>
                    </function>
                </xsl:for-each>
            </functions>
            
        </stylesheet>
    </xsl:template>
    
    <xsl:variable name="imf:frags" as="element(frag)+">
        <frag key="prefix" value="[A-Za-z\-\._0-9]+"/>
        <frag key="name" value="[A-Za-z\-\._0-9]+"/>
    </xsl:variable>
    <xsl:variable name="imf:varname-regex" select="imf:insert-fragments-by-name('\$(([prefix]:)?[name])',$imf:frags)"/>
    <xsl:variable name="imf:funname-regex" select="imf:insert-fragments-by-name('([prefix]:[name])\(',$imf:frags)"/>
    
    <xsl:template match="*" mode="variable-calls">
        <xsl:param name="local-declarations"/>
        <xsl:for-each select="(@test,@select,@group-by)">
            <xsl:variable name="vcalls" as="element()*">
                <xsl:analyze-string select="." regex="{$imf:varname-regex}">
                    <xsl:matching-substring>
                        <xsl:variable name="name" select="regex-group(1)"/>
                        <variable-call local="{$name = $local-declarations}">
                            <name><xsl:value-of select="$name"/></name>
                        </variable-call>
                    </xsl:matching-substring>
                </xsl:analyze-string>     
            </xsl:variable>
            <xsl:sequence select="if ($vcalls) then $vcalls else ()"/>
        </xsl:for-each>
        <xsl:apply-templates select="*" mode="#current">
            <xsl:with-param name="local-declarations" select="$local-declarations"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*" mode="function-calls">
        <xsl:param name="local-declarations"/>
        <xsl:for-each select="(@test,@select,@group-by)">
            <xsl:variable name="fcalls" as="element()*">
                <xsl:analyze-string select="." regex="{$imf:funname-regex}">
                    <xsl:matching-substring>
                        <xsl:variable name="name" select="regex-group(1)"/>
                        <function-call local="{$name = $local-declarations}">
                            <name><xsl:value-of select="regex-group(1)"/></name>
                        </function-call>
                    </xsl:matching-substring>
                </xsl:analyze-string>     
            </xsl:variable>
            <xsl:sequence select="if ($fcalls) then $fcalls else ()"/>
        </xsl:for-each>
        <xsl:apply-templates select="*" mode="#current">
            <xsl:with-param name="local-declarations" select="$local-declarations"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:function name="imf:get-fullpath">
        <xsl:param name="full-path"/>
        <xsl:variable name="absolutepath" select="ekf:getAbsolutePath($full-path)"/>
        <xsl:value-of select="$absolutepath"/>
    </xsl:function>
    
</xsl:stylesheet>