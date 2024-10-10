<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all" 
    version="3.0">
    
    <!--
        Genereer een compleet document met documentor.
     
        Vereist is een ZIP file met daarin alle MsWord bestanden e.d. die alle inleidende en uitleidende hoofdstukken bevatten.
        
    -->
    
    <xsl:output method="xhtml" indent="yes"/>
    
    <!-- 
        Folder die alle bestanden bevat. 
        Alle msword bestanden zijn omgezet naar *.xhtml bestanden 
    -->
    <xsl:param name="modeldoc-folder"/> 
    
    <xsl:template match="/html/body/section[@id = 'cat']">
        <html>
            <head>
                
            </head>
            <body>
                <xsl:sequence select="."/> 
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>