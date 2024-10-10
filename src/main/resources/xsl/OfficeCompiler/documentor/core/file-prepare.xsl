<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:ext="http://zoekservice.overheid.nl/extensions"  
    xmlns:ser="http://www.armatiek.com/xslweb/functions/serialize"
    xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
   
    
    xmlns:dynfunc="http://www.armatiek.com/xslweb/functions/dynfunc"
    xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:utils="https://koop.overheid.nl/namespaces/utils"
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    
    xmlns:file="http://expath.org/ns/file"
    xmlns:req="http://www.armatiek.com/xslweb/request"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:webapp="http://www.armatiek.com/xslweb/functions/webapp"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/common.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <!-- deze stap leest, als vorige stappen geen problemen geven, de XHTML en geeft die verder door. Als wel problemen, hier signalleren in een eigen gegenereerd XHTML document --> 
        
    <xsl:template match="/">
        <xsl:sequence select="local:log('section: file-prepare',/)"/>
        
        <document>
            <xsl:variable name="resolved-body-norm" as="element()*">
                <xsl:apply-templates select="/document/*" mode="resolve-norm"/>
            </xsl:variable>            
            
            <xsl:variable name="resolved-body-pre" as="element()*">
                <!-- resolve all special pattern constructs in content; this is now only <meta> and extension-->
                <xsl:apply-templates select="$resolved-body-norm" mode="resolve-pre"/>
            </xsl:variable>
            
            <xsl:variable name="resolved-body-ext" as="element()*">
                <!-- assign metadata to the element it applies to -->
                <xsl:apply-templates select="$resolved-body-pre" mode="resolve-ext"/>
            </xsl:variable>
            
            <?x
            <xsl:sequence select="local:log('$resolved-body-norm',$resolved-body-norm)"/>
            <xsl:sequence select="local:log('$resolved-body-pre',$resolved-body-pre)"/>
            <xsl:sequence select="local:log('$resolved-body-ext',$resolved-body-ext)"/>
            x?>
            
            <xsl:sequence select="$resolved-body-ext"/>
            
            <!--
                lees alle (evt. aanvullende) properties uit uit de eerste tabel, als die er is 
            -->
            <xsl:variable name="webapp-props" select="webapp:get-attribute('props')" as="element(prop)*"/>
            
            <xsl:variable name="local-props" as="element(prop)*"><!-- kunnen lokaal worden opgegeven; wanneer aangetroffen, voeg toe aan webapp props --> 
                <xsl:for-each select="$resolved-body-ext/body/table[1]/tbody/tr[normalize-space()]">
                    <xsl:variable name="key" select="normalize-space(td[1])"/>
                    <xsl:variable name="val" as="item()*">
                        <xsl:choose>
                            <xsl:when test="td[2]/p">
                                <xsl:for-each select="td[2]/p">
                                    <xsl:sequence select="local:get-keyval(.)"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="local:get-keyval(td[2])"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <prop key="{$key}">
                        <xsl:sequence select="$val"/>
                    </prop>
                </xsl:for-each>
            </xsl:variable>
            
            <xsl:variable name="props" select="($webapp-props[not(@key = $local-props/@key)],$local-props)" as="element(prop)*"/>
            
            <!-- 
                geef deze door aan alle processen binnen deze webapp 
            -->
            <xsl:sequence select="webapp:set-attribute('props',$props)"/>
        </document>
   
    </xsl:template>

    <!-- == resolving meta constructs, currently only for sections: special meta pars, and titles == -->
    
    <xsl:template match="node()|@*" mode="resolve-pre resolve-ext resolve-norm" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
  
    <!-- 
        vervang de namen van data-custom-style door een unieke code 
        dus bijv. 
        div:Quote wordt quote
        Quote Char wordt quotechar
    -->
    <xsl:template match="@data-custom-style" mode="resolve-norm">
        <xsl:variable name="cs" select="tokenize(.,':')[last()]"/>
        <xsl:attribute name="data-custom-style" select="local:compact($cs)"/>
    </xsl:template>
    
    <xsl:template match="html/head" mode="resolve-pre">
        <!-- verwijder de head die door pandoc is ingevoegd -->
    </xsl:template>
    
    <xsl:template match="h1|h2|h3|h4|h5|h6|h7" mode="resolve-pre">
        <title>
            <xsl:apply-templates mode="#current"/>
        </title>
    </xsl:template>
    
    <xsl:template match="header[@id='title-block-header']" mode="resolve-pre">
        <!-- alleen voor het hele rapport-->
        <title>
            <xsl:value-of select=".//p[1]"/>
        </title>
        <subtitle>
            <xsl:value-of select=".//p[2]"/>
        </subtitle>
    </xsl:template>
    
    <xsl:template match="div[@data-custom-style = 'titel']/p" mode="resolve-pre"><!-- situatie aangetroffen op IMWOZ document, nederlandse versie msword? -->
        <xsl:choose>
            <xsl:when test="../preceding-sibling::div[@data-custom-style = 'titel']">
                <subtitle>
                    <xsl:apply-templates mode="#current"/>
                </subtitle>
            </xsl:when>
            <xsl:otherwise>
                <title>
                    <xsl:apply-templates mode="#current"/>
                </title>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[@data-custom-style = 'metadata']" mode="resolve-pre" priority="10">
        <xsl:sequence select="local:get-metadata(.)"/>
    </xsl:template>
    
    <xsl:template match="div[@data-custom-style = 'extension']" mode="resolve-pre" priority="10">
        <xsl:sequence select="local:get-extension(.)"/>
    </xsl:template>
    
    <xsl:template match="span[@data-custom-style = 'extensionchar']" mode="resolve-pre" priority="10">
        <xsl:sequence select="local:get-extension(.)"/>
    </xsl:template>
    
    <!-- == resolving @id and @lang == -->
    <xsl:template match="section" mode="resolve-ext">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <!-- metadata can be found after the title. There may 0..* metadata elements -->
            <xsl:sequence select="local:get-metadata-attributes(title)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*" mode="resolve-ext">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <!-- metadata can be found after this element. There may 0..* metadata elements -->
            <xsl:sequence select="local:get-metadata-attributes(.)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="metadata" mode="resolve-ext">
        <!-- remove -->
    </xsl:template>


    <!--
        Return the metadata as found in a div[@data-custom-style = metadata] with a single p
        The metadata elements have a key and value. 
        Value is case sensitive.
    -->
    <xsl:function name="local:get-metadata" as="element()*">
        <xsl:param name="div" as="element(div)"/>
        
        <xsl:variable name="wiki-pat">^(\d+);\s*(FATAL|WARNING|ERROR|INFO);(.+?);\s*(.+?);\s*(.+)$</xsl:variable>
        <xsl:variable name="kv-pat">^(.+?):\s*(.+)$</xsl:variable>
        
        <xsl:variable name="firstpar" select="normalize-space($div/p[1])"/>
        <xsl:choose>
            <xsl:when test="matches($firstpar,$wiki-pat)">
                <xsl:analyze-string select="$firstpar" regex="{$wiki-pat}">
                    <xsl:matching-substring>
                        <metadata key="nr" val="{regex-group(1)}"/>
                        <metadata key="severity" val="{regex-group(2)}"/>
                        <metadata key="source" val="{regex-group(3)}"/>
                        <metadata key="id" val="{regex-group(4)}"/>
                        <metadata key="lang" val="{lower-case(regex-group(5))}"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($firstpar,$kv-pat)">
                <xsl:analyze-string select="$firstpar" regex="{$kv-pat}">
                    <xsl:matching-substring>
                        <metadata key="{lower-case(regex-group(1))}" val="{regex-group(2)}"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <error loc="{$msword-file-subpath}">Metadata formaat niet herkend: {$firstpar}</error>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <!-- 
        Extensions introduce external constructs 
    
        format is 
        key: value
        
        Not case sensitive.
    -->
    
    <xsl:function name="local:get-extension" as="item()*">
        <xsl:param name="elm" as="element()"/>
        
        <xsl:variable name="kv-pat">^(.+?)(:\s*(.+))?$</xsl:variable>
        
        <xsl:variable name="ext" select="normalize-space($elm)"/>
      
        <xsl:analyze-string select="$ext" regex="{$kv-pat}">
            <xsl:matching-substring>
                <xsl:variable name="key" select="replace(lower-case(regex-group(1)),'[^a-z]+','')"/>
                <xsl:choose>
                    <xsl:when test="$key = 'currentdatetime'">
                        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01] om [H01]:[m01]:[s01]')"/>
                    </xsl:when>
                    <xsl:when test="$key = 'currentdate'">
                        <xsl:value-of select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                    </xsl:when>
                    <xsl:when test="$key = 'currentdocument'">
                        <xsl:value-of select="$msword-file-subpath"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <extension key="{$key}" val="{regex-group(3)}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <error loc="{$msword-file-subpath}">Extension formaat niet herkend: {$ext}</error>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
        
    </xsl:function>

    <!-- 
        return all attributes that result from adjacent metadata elements after the element passed . 
    -->
    <xsl:function name="local:get-metadata-attributes" as="item()*">
        <xsl:param name="preceding" as="element()?"/>
        <xsl:variable name="following" select="$preceding/following-sibling::*[1]"/>
        <xsl:if test="$following/self::metadata">
            <xsl:choose>
                <xsl:when test="matches($following/@key,'^[a-z0-9]+$')">
                    <xsl:attribute name="metadata-{$following/@key}" select="$following/@val"/>
                    <xsl:sequence select="local:get-metadata-attributes($following)"/>
                </xsl:when>
                <xsl:otherwise>
                    <error>Invalid or unknown metadata key: {$following/@key}</error>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="local:get-keyval" as="item()*">
        <xsl:param name="string" as="xs:string"/>
        
        <xsl:variable name="kv-pat">^(.+?):\s+(.+)$</xsl:variable>
        <xsl:choose>
            <xsl:when test="matches($string,$kv-pat)">
                <xsl:analyze-string select="$string" regex="{$kv-pat}">
                    <xsl:matching-substring>
                        <prop key="{regex-group(1)}">
                            <xsl:value-of select="regex-group(2)"/>
                        </prop>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
        
</xsl:stylesheet>