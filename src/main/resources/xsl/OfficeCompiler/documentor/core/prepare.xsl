<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  
    xmlns:local="urn:local"
    xmlns:ext="http://zoekservice.overheid.nl/extensions"  
    xmlns:ser="http://www.armatiek.com/xslweb/functions/serialize"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger"
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
    xmlns:webapp="http://www.armatiek.com/xslweb/functions/webapp"
    
    xmlns:log="http://www.armatiek.com/xslweb/functions/log"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/common.xsl"/>
    
    <xsl:template match="/">
        
        <xsl:try>
            <documentor>
                
                <xsl:sequence select="dlogger:init(true())"/>
                <xsl:sequence select="local:log('info: Documentor on ' || $module,'start')"/>
                
                <xsl:sequence select="local:log('section: Prepare',/)"/>
                
                <xsl:sequence select="local:log('$module-work-folder-path',$module-work-folder-path)"/>
                <xsl:sequence select="local:log('$configuration-i3n-owner-file-path',$configuration-i3n-owner-file-path)"/>
                <xsl:sequence select="local:log('$configuration-i3n-file',$configuration-i3n-file)"/>
                
                <xsl:sequence select="local:log('info: owner-folder-path',$owner-folder-path)"/>
                <xsl:sequence select="local:log('info: module-work-folder-path',$module-work-folder-path)"/>
                
                <!--
                    initialiseer het properties tabelletje.
                -->
                <xsl:variable name="props" as="element(prop)+">
                    <prop key="Documentor datetime">{current-dateTime()}</prop>
                </xsl:variable>
                <xsl:sequence select="webapp:set-attribute('props',$props)"/>
                
                <!-- 
                    Verwijder alle andere tijdelijke bestanden uit eerdere test-run 
                -->
                <xsl:sequence select="local:folder-cleanup()"/>
                
                <!-- 
                    Als de module folder al/nog bestaat, verwijder/maak leeg
                -->
                <xsl:if test="file:exists($module-work-folder-path)">
                    <xsl:sequence select="file:delete($module-work-folder-path,true())"/>      
                </xsl:if>
                
                <xsl:sequence select="file:create-dir($module-work-folder-path || '')"/>      
                <xsl:sequence select="file:create-dir($module-work-folder-path || '/img-store')"/>      
                
                <!-- 
                    We moeten de workfolder vullen met de bestanden uit de sourcefolder(s).
                    Welke dat zijn hangt af van de module.
                -->
               
                <!-- 
                    kopieer alle docx files naar de module folder: eerst generieke sections, dan de model sections, kan bestaande vervangen 
                -->
                <xsl:sequence select="local:log('info: running in Imvertor context',$work-folder-path)"/>
                <xsl:sequence select="local:copy-prepare($work-folder-path || '/xmi/Report/sections')"/>
                <xsl:sequence select="local:copy-prepare($work-folder-path || '/xmi/Report/modeldoc')"/>
                
            </documentor>
            <xsl:catch>
                <xsl:sequence select="local:log('error: prepare', $err:description || ' [' || $err:code || '] line: ' || $err:line-number || ', column: ' || $err:column-number)"/>
            </xsl:catch>
        </xsl:try>
    </xsl:template>
    
    <xsl:function name="local:copy-prepare" as="empty-sequence()">
        <xsl:param name="path" as="xs:string"/>
        <xsl:variable name="msword-files" select="local:file-list($path,true(),'*.docx')"/>
        <xsl:for-each select="$msword-files">
            <xsl:variable name="msword-path" select="$path || '/' || ."/>
            <xsl:sequence select="file:copy($msword-path, $module-work-folder-path)"/>    
           <!-- als naast de msword file ook data folders zijn opgenomen, die ook doorkopieren -->
            <xsl:variable name="assets-folder-path" select="file:parent($msword-path) || '/assets'"/>
            <xsl:sequence select="local:copy-if-exists($assets-folder-path, $module-work-folder-path)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="local:folder-cleanup">
        <xsl:variable name="work-files" select="local:file-list($module-work-folder-path,false(),())"/>
        <xsl:for-each select="$work-files">
            <xsl:sequence select="file:delete($module-work-folder-path || '/' || .,true())"/>      
        </xsl:for-each>        
    </xsl:function>
    
</xsl:stylesheet>