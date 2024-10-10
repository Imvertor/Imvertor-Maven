<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:local="urn:local"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:req="http://www.armatiek.com/xslweb/request"
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    xmlns:file="http://expath.org/ns/file"
    xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization"
    xmlns:webapp="http://www.armatiek.com/xslweb/functions/webapp"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger"
    xmlns:log="http://www.armatiek.com/xslweb/functions/log"
    
    expand-text="yes">
    
    <xsl:import href="DLogger.xsl"/>
    
    <xsl:param name="req:request-xml-doc" as="document-node()"/>
    <xsl:param name="config:webapp-dir" as="xs:string"/>
    <xsl:param name="config:development-mode" as="xs:boolean"/>
    
    <xsl:param name="source-folder-path" select="local:get-system-path($req:request-xml-doc//req:parameter[@name = 'sourcefolder']/req:value/text())" as="xs:string"/>
    <xsl:param name="work-folder-path" select="local:get-system-path($req:request-xml-doc//req:parameter[@name = 'workfolder']/req:value/text())" as="xs:string"/>
    
    <xsl:param name="active-owner-name" select="local:compact($req:request-xml-doc//req:parameter[@name = 'owner']/req:value/text())" as="xs:string?"/><!-- de naam in compacte vorm -->
    <xsl:param name="msword-file-subpath" select="$req:request-xml-doc//req:parameter[@name = 'msword']/req:value/text()" as="xs:string?"/><!-- bijv. sub/report (was sub/report.docx) -->

    <xsl:variable name="module" select="webapp:get-attribute('module')"/><!-- voorbeeld: "respec" -->
    <xsl:variable name="mode" select="webapp:get-attribute('mode')"/><!-- voorbeeld: "primer" -->
    
    <xsl:variable name="default-folder-path">{$config:webapp-dir}/local/cfg/owners/default</xsl:variable>
    <xsl:variable name="owner-folder-path">{$config:webapp-dir}/local/cfg/owners/{$active-owner-name}</xsl:variable>
    
    <xsl:variable name="module-work-folder-path" select="$work-folder-path || '/' || $module"/>
    <xsl:variable name="imvertor-cat-path" select="$work-folder-path || '/app/cat'"/>
    
    <xsl:variable name="configuration-i3n-owner-file-path" select="$config:webapp-dir || '/local/cfg/owners/' || $active-owner-name || '/i3n/translation.xml'"/>
    <xsl:variable name="configuration-i3n-file" select="local:document($configuration-i3n-owner-file-path)" as="document-node()?"/>
    
    <!-- 
        draaien we in docker? 
    -->
    <xsl:variable name="at-docker" select="true()"/>
    
    <!-- 
       Wordt Documentor gedraaid als onderdeel van executor? 
       Dan werken we in de executor work folder, daarin staat een parms.xml bestand. 
    -->
    <xsl:variable name="imvertor-context" select="file:exists($work-folder-path || '/parms.xml')"/>
    
    <!-- 
       de naam van het hoofddocument wordt ofwel meegegeven, of uitgelezen uit de Imvertor omgeving.
       
       Voorbeeld: "Primer-1.0.docx"
    --> 
    
    <xsl:variable name="passed-masterdoc" select="$req:request-xml-doc//req:parameter[@name = 'masterdoc']/req:value/text()"/>
    
    <!-- 
        standaard serialisatie parameters 
    -->
    <xsl:variable name="xml-ser-params" as="element(output:serialization-parameters)">
        <output:serialization-parameters>
            <output:method value="xml"/>
            <output:version value="1.0"/>
            <output:indent value="no"/>
        </output:serialization-parameters>
    </xsl:variable>
    
    <xsl:variable name="html-ser-params" as="element(output:serialization-parameters)">
        <output:serialization-parameters>
            <output:method value="html"/>
            <output:version value="5.0"/>
            <output:indent value="no"/>
        </output:serialization-parameters>
    </xsl:variable>
    
    <?x
    <!-- 
        return a document when it exists, otherwise return empty sequence 
    -->
    <xsl:function name="local:document" as="item()*">
        <xsl:param name="uri-or-path" as="xs:string"/>
        <xsl:variable name="uri" select="local:file-to-url($uri-or-path)"/>
        <xsl:variable name="dyn" select="matches($uri,'^(https?)|(xslweb):.*$')"/>
        <xsl:choose>
            <xsl:when test="$dyn">
                <xsl:sequence select="document($uri)"/>
            </xsl:when>
            <xsl:when test="unparsed-text-available($uri)">
                <xsl:sequence select="document($uri)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    x?>
    
    <?x
    <!-- 
        Zet een filepad om naar een URL.
        HTTP/xslweb referenties worden gewoon teruggegeven.
    -->
    <xsl:function name="local:file-to-url" as="xs:string?">
        <xsl:param name="path" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="empty($path)"/>
            <xsl:when test="matches($path,'^(http|https|file|xslweb):')">
                <xsl:value-of select="$path"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="protocol-prefix" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="starts-with($path, '\\')">file://</xsl:when> <!-- UNC path -->
                        <xsl:when test="matches($path, '[a-zA-Z]:[\\/]')">file:///</xsl:when> <!-- Windows drive path -->
                        <xsl:when test="starts-with($path, '/')">file://</xsl:when> <!-- Unix path -->
                        <xsl:otherwise>file://</xsl:otherwise>
                    </xsl:choose>  
                </xsl:variable>
                <xsl:variable name="norm-path" select="translate($path, '\', '/')" as="xs:string"/>
                <xsl:variable name="path-parts" select="tokenize($norm-path, '/')" as="xs:string*"/>
                <xsl:variable name="encoded-path" select="string-join(for $p in $path-parts return encode-for-uri($p), '/')" as="xs:string"/>
                <xsl:value-of select="concat($protocol-prefix, $encoded-path)"/>   
            </xsl:otherwise> 
        </xsl:choose>
    </xsl:function>
    x?>
    
    <!-- 
        Zet een filepad om naar een systeem pad, bijv. c:/abc of /mnt/c/... voor mounted folder.
    -->
    <xsl:function name="local:get-system-path" as="xs:string?">
        <xsl:param name="path" as="xs:string?"/>
        <xsl:variable name="match" select="analyze-string($path,'^(.):(.*)$')/*:match" as="element()?"/>
        <xsl:choose>
            <xsl:when test="$match and $at-docker">
                <xsl:value-of select="'/mnt/' || lower-case($match/*:group[@nr = '1']) || $match/*:group[@nr = '2']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$path"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        Vervang domweg alle \ door /
    -->
    <xsl:function name="local:safe-file-path" as="xs:string">
        <xsl:param name="filepath"/>
        <xsl:value-of select="replace($filepath,'\\','/')"/>
    </xsl:function>
   
    <!-- 
        file listing, folder doesn't have to exist
    -->
    <xsl:function name="local:file-list" as="xs:string*">
        <xsl:param name="folder" as="xs:string"/>
        <xsl:param name="recurse" as="xs:boolean"/>
        <xsl:param name="wildcard" as="xs:string?"/>
        <xsl:if test="file:exists($folder)">
            <xsl:for-each select="if ($wildcard) then file:list($folder,$recurse,$wildcard) else file:list($folder,$recurse)">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>

    <!-- 
        copy the file(s) if the input path exists; also copies folders; specify of contents should be copied. 
    -->
    <xsl:function name="local:copy-if-exists">
        <xsl:param name="in-path" as="xs:string"/>
        <xsl:param name="out-path" as="xs:string"/>
        <xsl:sequence select="local:copy-if-exists($in-path,$out-path,false())"/>
    </xsl:function>
    <xsl:function name="local:copy-if-exists">
        <xsl:param name="in-path" as="xs:string"/>
        <xsl:param name="out-path" as="xs:string"/>
        <xsl:param name="copy-content" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="not(file:exists($in-path))"/>
            <xsl:when test="$copy-content">
                <xsl:for-each select="file:list($in-path,false())">
                    <xsl:sequence select="file:copy($in-path || '/'|| .,$out-path)"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="file:copy($in-path,$out-path)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        verwijder alle tijdelijke bestanden die vanuit docx verwerking zijn ontstaan, inclusief het bronbestand 
    -->
    <xsl:function name="local:remove-temp-files">
        <xsl:param name="module-work-folder-path" as="xs:string"/>
        <xsl:for-each select="file:list($module-work-folder-path,false(),'*.docx')">
            <xsl:sequence select="file:delete($module-work-folder-path || '/' || .)"/>
        </xsl:for-each>
        <xsl:for-each select="file:list($module-work-folder-path,false(),'*.docx.*')">
            <xsl:sequence select="file:delete($module-work-folder-path || '/' || .)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="local:log">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="value" as="item()*"/>
        <xsl:variable name="status" select="lower-case(tokenize($key,':')[1])"/>
        <xsl:choose>
            <xsl:when test="$status = 'error'">
                <xsl:sequence select="log:log('ERROR',$key || ': ' || $value)"/>
            </xsl:when>
            <xsl:when test="$status = 'info'">
                <xsl:sequence select="log:log('INFO',$key || ': ' || $value)"/>
            </xsl:when>
            <xsl:when test="$config:development-mode">
                <xsl:variable name="type" select="dlogger:save-type($value[1])"/>
                <xsl:variable name="ell" select="if ($value[2]) then  ' [...]' else ''"/>
                <xsl:variable name="value-show" select="(if ($type = ('document','element')) then ('[' || $type || ']') else $value) || $ell"/>
                <xsl:sequence select="log:log('INFO','[dev] ' || $key || ': ' || $value-show)"/>
            </xsl:when>
        </xsl:choose>
        <xsl:sequence select="dlogger:save(if (normalize-space($key)) then $key else '(nokey)',$value)"/>
    </xsl:function>
    
    <xsl:function name="local:compact" as="xs:string">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:sequence select="replace(lower-case($string),'[^a-z0-9]+','')"/>
    </xsl:function>
    
</xsl:stylesheet>