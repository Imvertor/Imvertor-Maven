<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:pack="http://www.armatiek.nl/functions/pack"

    xmlns:file="http://expath.org/ns/file"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:local"
    xmlns:util="http://www.armatiek.com/xslweb/functions/util"
    
    expand-text="yes" 
    >
    
    <!-- 
        Dit pack verwerkt de XHTML catalogus uit een Imvertor run naar een catalogus in het documentor resultaat.
        
        De volgende zaken worden opgepakt:
        
        1/ Zet alle image sources om naar het correcte /Images pad. Dat is het pad dat Imvertor zelf invoegt voor diagrammen.
        2/ Verlaag alle h* elementen naar h* - 1
        3/ Wanneer in definitie of toelichting oid. naar een file in de aangeleverde modeldoc folder wordt gerefereerd (zgn. asset), 
           plaats dat file dan op de juiste manier op die plek.  
        
    -->
    <xsl:function name="pack:process-catalog" as="element()">
        <xsl:param name="catalog-path" as="xs:string"/>
        
        <xsl:variable name="cat-xhtml-doc" select="imf:document($catalog-path)/*"/>
        <xsl:sequence select="local:log('$cat-xhtml',$cat-xhtml-doc)"/>
        <div>
            <xsl:choose>
                <xsl:when test="$cat-xhtml-doc">
                    <xsl:apply-templates select="$cat-xhtml-doc" mode="pack:process-catalog"/>             
                </xsl:when>
                <xsl:otherwise>
                    <error>Cannot read catalog</error>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:function>
    
    <!-- verwijder de HTML namespace -->
    <xsl:template match="*" mode="pack:process-catalog">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*" mode="pack:process-catalog">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*:img/@src" mode="pack:process-catalog">
        <xsl:variable name="src">
            <xsl:choose>
                <xsl:when test="contains(.,'/Images/')">
                    <xsl:value-of select="'Images/' || substring-after(.,'/Images/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="string(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="src">{$src}</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="*:h2|*:h3|*:h4|*:h5|*:h6|*:h7" mode="pack:process-catalog">
        <xsl:choose>
            <xsl:when test="true()">
                <xsl:variable name="n" select="xs:integer(substring(local-name(),2))"/>
                <xsl:element name="h{$n - 1}">
                    <xsl:apply-templates mode="#current"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*:td//*:a" mode="pack:process-catalog">
        <xsl:variable name="href" select="imf:file-to-url(@href)"/>
        <xsl:variable name="subpath" select="substring-after($href,'/modeldoc/')"/>
        <xsl:variable name="file" select="tokenize($subpath,'/')[last()]"/>
        <xsl:variable name="fileext" select="lower-case(tokenize($file,'\.')[last()])"/>
        <xsl:variable name="filetype" select="if ($fileext = ('jpg','jpeg','png','gif')) then 'image' else 'unknown'"/>
        <xsl:choose>
            <xsl:when test="$file and $filetype = 'image'">
                <img class="image-asset" src="assets/{$file}"/>
            </xsl:when>
            <xsl:when test="$file and $filetype = 'unknown'">
                <b>ERROR: UNKNOWN FILE EXTENSION: "{$fileext}"</b>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
</xsl:stylesheet>