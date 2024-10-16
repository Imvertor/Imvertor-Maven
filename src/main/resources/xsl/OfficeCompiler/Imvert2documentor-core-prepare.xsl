<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:local="urn:local"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    
    exclude-result-prefixes="#all"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2documentor-common.xsl"/>
    
    <xsl:output method="xml" indent="no"/>
    
    <xsl:template match="/">
        
        <xsl:try>
            <documentor>
                
                <xsl:sequence select="local:log('section: Prepare',/)"/>
                
                <xsl:sequence select="local:log('$module-work-folder-path',$module-work-folder-path)"/>
                <xsl:sequence select="local:log('$configuration-i3n-owner-file-path',$configuration-i3n-owner-file-path)"/>
                <xsl:sequence select="local:log('$configuration-i3n-file',$configuration-i3n-file)"/>
                
                <xsl:sequence select="local:log('info: owner-folder-path',$owner-folder-path)"/>
                <xsl:sequence select="local:log('info: module-work-folder-path',$module-work-folder-path)"/>
                
                <xsl:sequence select="file:create-dir($module-work-folder-path || '')"/>      
                <xsl:sequence select="file:create-dir($module-work-folder-path || '/img-store')"/>      
                
                <!-- 
                    We moeten de workfolder vullen met de bestanden uit de sourcefolder(s).
                    Welke dat zijn hangt af van de module.
                -->
                <xsl:choose>
                    <xsl:when test="$imvertor-context">
                        <!-- 
                            kopieer alle docx files naar de module folder: eerst generieke sections, dan de model sections, kan bestaande vervangen 
                        -->
                        <xsl:sequence select="local:log('info: running in Imvertor context',$work-folder-path)"/>
                        <xsl:sequence select="local:copy-prepare($work-folder-path || '/xmi/Report/sections')"/>
                        <xsl:sequence select="local:copy-prepare($work-folder-path || '/xmi/Report/modeldoc')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="local:log('info: source-folder-path',$source-folder-path)"/>
                        <!-- 
                            kopieer de img en att folders, en het master doc file.
                        -->
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/../sections', $module-work-folder-path,true())"/>
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/../sections/att', $module-work-folder-path)"/>
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/../sections/img', $module-work-folder-path)"/>
                        <!-- de root overschrijft mogelijke duplicaten -->
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/sections', $module-work-folder-path,true())"/>
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/sections/att', $module-work-folder-path)"/>
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/sections/img', $module-work-folder-path)"/>
                        <!-- de root overschrijft mogelijke duplicaten -->
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/' || $passed-masterdoc || '.docx', $module-work-folder-path)"/>
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/att', $module-work-folder-path)"/>
                        <xsl:sequence select="local:copy-if-exists($source-folder-path || '/img', $module-work-folder-path)"/>
                    </xsl:otherwise>
                </xsl:choose>
                
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