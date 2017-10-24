<xsl:stylesheet 
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    xmlns:imf="http://www.armatiek.nl/functions" 
    
    version="2.0">
  
    <xsl:param name="workfolder"/>
    <xsl:param name="source-language"/>
    <xsl:param name="target-language"/>
    
    <xsl:variable name="profile-doc" select="root()"/>
    <xsl:variable name="config-doc" select="document(concat('file:/',replace(concat($workfolder,'/__content.config.xml'),'\\','/')))"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="*" mode="translate"/>
    </xsl:template>
    
    <xsl:template match="@name | @notes | @description | @id | @version" mode="translate">
        <xsl:variable name="type" select="local-name()"/>
        
        <xsl:choose>
            <xsl:when test="normalize-space(.)">
                
                <xsl:variable name="elm" select=".."/>
                <xsl:variable name="att" select="."/>
               
                <!-- als voor dit attribuut een vertaling beschikbaar is, geef dan dat configuratie element terug --> 
                <xsl:variable name="declaration" as="element(attribute)*">
                    <xsl:for-each select="$config-doc//attribute[@name = $type and value[@lang = $source-language and imf:matches($att,.)]]">
                        
                        <!-- kijk welke config voor deze specifieke plek was opgenomen -->
                        <xsl:sequence select="if (imf:resolve-context(.)) then . else ()"/>
                        
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:variable name="translation" as="xs:string*">
                    <xsl:value-of select="$declaration/value[@lang = $target-language]"/>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="$translation[2]">
                        <xsl:message select="concat('Duplicate translation for: ',$att)"/>
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="$translation[1]">
                        <xsl:attribute name="{$type}" select="$translation[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="concat('No translation for: ',$type,'=', $att)"/>
                        <xsl:attribute name="{$type}" select="$att"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()" mode="translate">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*" mode="translate">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:function name="imf:resolve-context" as="element()*">
        <xsl:param name="config-attribute"/>
        
        <xsl:variable name="section" select="$config-attribute/ancestor::section/@value[not(starts-with(.,'('))]"/>
        <xsl:variable name="lsubject" select="$config-attribute/ancestor::location/@subject"/>
        <xsl:variable name="lobject" select="$config-attribute/ancestor::location/@object"/>
        <xsl:variable name="csubject" select="$config-attribute/ancestor::condition/@subject"/>
        <xsl:variable name="cobject" select="$config-attribute/ancestor::condition/@object"/>
        
        <!-- check de sectie of ga uit van de root. -->
        <xsl:for-each select="if (empty($section)) then $profile-doc else $profile-doc//*[local-name(.) = $section]">
            <!-- check de locatie -->
            <xsl:for-each select=".//*[local-name(.) = $lsubject]/*[local-name(.) = $lobject]">
                <!-- check de conditie -->
                <xsl:for-each select="@*[if (exists($csubject)) then (local-name(.) = $csubject and . = $cobject) else true()]">
                    <!-- geef het profiel element af dat moet worden vertaald. -->
                    <xsl:sequence select=".."/>
                </xsl:for-each>    
            </xsl:for-each>    
        </xsl:for-each>    
        
    </xsl:function>
    
    <xsl:function name="imf:matches" as="xs:boolean">
        <xsl:param name="source-att"/>
        <xsl:param name="config-att"/>

        <xsl:variable name="attval" select="if (ends-with($config-att,'...')) then substring($config-att,1,string-length($config-att) - 3) else ()"/>
        <xsl:sequence select="if (exists($attval)) then starts-with($source-att,$attval) else $source-att = $config-att"/>
        
    </xsl:function>
</xsl:stylesheet>