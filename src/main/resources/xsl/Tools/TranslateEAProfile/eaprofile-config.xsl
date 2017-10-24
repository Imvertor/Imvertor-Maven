<xsl:stylesheet 
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:config="http://www.armatiek.com/xslweb/configuration"
    xmlns:amf="http://www.armatiek.nl/functions" 
    
    version="2.0">

    <!-- 
        build a translation configuration from the Excel table
    -->
    
    <xsl:param name="workfolder"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="/worksheets/worksheet">
        <xsl:if test="@name = 'EA profile'">
            <xsl:comment select="'Build by Imvertor, do not edit'"/>
            <config>
                <xsl:for-each-group select="row[not(starts-with(cell[@nr = '1'],'#'))]" group-by="cell[@nr = '1']">
                    <section value="{current-grouping-key()}">
                        <xsl:for-each-group select="current-group()" group-by="cell[@nr = '2']">
                            <location subject="{substring-before(current-grouping-key(),'/')}" object="{substring-after(current-grouping-key(),'/')}">
                                <xsl:for-each-group select="current-group()" group-by="cell[@nr = '3']">
                                    <condition subject="{substring-before(current-grouping-key(),'=')}" object="{substring-after(current-grouping-key(),'=')}">
                                        <xsl:for-each-group select="current-group()" group-by="cell[@nr = '4']">
                                            <attribute name="{current-grouping-key()}" token="{cell[@nr = '5']}">
                                                <value lang="NL"><xsl:value-of select="current-group()/cell[@nr = '7']"/></value>
                                                <value lang="EN"><xsl:value-of select="current-group()/cell[@nr = '8']"/></value>
                                            </attribute>
                                        </xsl:for-each-group>
                                    </condition>
                                </xsl:for-each-group>
                            </location>
                        </xsl:for-each-group>
                    </section>
                </xsl:for-each-group>     
            </config>
        </xsl:if>
        <!-- skip other worksheets -->
    </xsl:template>
        
</xsl:stylesheet>