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
    xmlns:pack="http://www.armatiek.nl/functions/pack"
    
    xmlns:log="http://www.armatiek.com/xslweb/functions/log"

    expand-text="yes"
    >
    
    <xsl:import href="../common/common.xsl"/>
    <xsl:import href="../common/pack-xml-clean.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:param name="config:development-mode" as="xs:boolean"/>
    
    <xsl:variable name="masterdoc-name" select="req:get-attribute('masterdoc-name')"/> <!-- is bepaald in de scanner -->
    
    <xsl:template match="/">
        
        <xsl:sequence select="local:log('section: Windup Respec',/)"/>
        
        <xsl:variable name="module-result" select="$module-work-folder-path || '/' || $masterdoc-name || '.html'"/>
       
        <!-- schrijf HTML resultaat weg -->
        <xsl:sequence select="file:write($module-result,pack:xml-clean(/),$html-ser-params)"/>
        <xsl:sequence select="local:log('Respec module result',local:get-system-path($module-result))"/>
        <xsl:sequence select="if (not($config:development-mode)) then local:remove-temp-files($module-work-folder-path) else ()"/>
        <xsl:if test="$imvertor-context">
            <!-- 
                kopieer alle module resultaten naar de catalogus folder, maar check wel of de app folder bestaat (anders is dat al eerder gesignalleerd) 
            -->
            <xsl:if test="file:exists($imvertor-cat-path)">
                <xsl:for-each select="local:file-list($module-work-folder-path,false(),())">
                    <xsl:sequence select="file:copy($module-work-folder-path || '/' || ., $imvertor-cat-path)"/>
                </xsl:for-each>
                <xsl:sequence select="local:log('Imvertor model documentatie',local:get-system-path($imvertor-cat-path || '/' || $masterdoc-name || '.html'))"/>
            </xsl:if>
        </xsl:if>
        
        <result>Zie {$module-result}</result>
        
        <xsl:sequence select="local:log('info: Documentor on ' || $module,'done')"/>
        
    </xsl:template>
    
    
</xsl:stylesheet>