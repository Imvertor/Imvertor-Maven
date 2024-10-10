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
    
    <xsl:template match="/">
        
        <documentor>
        
            <xsl:sequence select="local:log('section: Prepare respec',/)"/>
            
            
            <!-- 
                zet de module folders klaar 
            -->
            <xsl:sequence select="file:create-dir($module-work-folder-path || '/web')"/>      
            <xsl:sequence select="file:create-dir($module-work-folder-path || '/profile')"/>      
            
            <!-- 
                Kopieer eerst de default web-assets
                Kopieer dan de web-assets uit de beheerde folder voor owner specifieke css / js 
                kopieer vervolgens lokale versies van web-assets; kan bestaande vervangen 
            -->
            <xsl:sequence select="local:copy-if-exists($default-folder-path || '/web', $module-work-folder-path)"/>
            <xsl:sequence select="local:copy-if-exists($owner-folder-path || '/web', $module-work-folder-path)"/>
            <xsl:sequence select="local:copy-if-exists($work-folder-path || '/xmi/Report/web',$module-work-folder-path)"/><!-- handmatig bijhouden door administrator -->
            
            <!-- 
                kopieer het profiel uit de beheerde folder voor de owner 
                kopieer vervolgens lokale versies van profile; kan bestaande vervangen 
            -->
            <xsl:sequence select="local:copy-if-exists($owner-folder-path || '/profile/', $module-work-folder-path)"/>
            <xsl:sequence select="local:copy-if-exists($work-folder-path || '/xmi/Report/profile',$module-work-folder-path)"/><!-- als respec: samengesteld middels NPM module builder en overgedragen aan owner -->      
            
       </documentor>
        
    </xsl:template>
    
    
</xsl:stylesheet>