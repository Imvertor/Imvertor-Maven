<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common-conceptual-map.xsl"/>
    
    <xsl:variable name="inp-folder" select="imf:get-config-string('system','inp-folder-path')"/>
    <xsl:variable name="xsd-folder" select="concat($inp-folder,'/xsd')"/>
    <xsl:variable name="configuration-cs-file" select="imf:document(concat($xsd-folder,'/conceptual-schemas.xml'),true())"/>
    
    <xsl:template match="/config" mode="metamodel-cs">
       
        <xsl:apply-templates select="$configuration-cs-file//conceptual-schema" mode="#current"/>
            
    </xsl:template>    
        
    <?x    
    <xsl:template match="conceptual-schema" mode="metamodel-cs">
        <div>
            <h2>Conceptual schema for: <xsl:value-of select="name"/></h2>
            <p><xsl:sequence select="imf:report-label('Description',desc)"/></p>
            <ul>
                <li><xsl:sequence select="imf:report-label('Short-name',short-name)"/></li>
                <li><xsl:sequence select="imf:report-label('URL',imf:get-xhtml-link(url,(),true()),true())"/></li>
            </ul>
            <xsl:apply-templates select="map" mode="#current"/>
        </div>       
    </xsl:template>

    <xsl:template match="map" mode="metamodel-cs">
        <div>
            <h3>Map: <xsl:value-of select="@name"/></h3>
            <p><xsl:sequence select="imf:report-label('Description',desc)"/></p>
            <ul>
                <li><xsl:sequence select="imf:report-label('Namespace',imf:get-xhtml-link(@namespace,(),true()),true())"/></li>
                <li><xsl:sequence select="imf:report-label('Location',imf:get-xhtml-link(@location,(),true()),true())"/></li>
                <li>
                    <xsl:sequence select="imf:report-label('Version',imf:get-xhtml-link(@version,(),true()))"/>
                    <xsl:sequence select="imf:report-label('Phase',imf:get-xhtml-link(@phase,(),true()))"/>
                </li>
                <li><xsl:sequence select="imf:report-label('Catalog template',if (catalog) then imf:get-xhtml-link(catalog,(),true()) else '--')"/></li>
            </ul>
            <p>This map is part of the conceptual mapping(s):
                <ul>
                    <xsl:for-each select="$configuration-cs-file//mapping[use = current()/@name]">
                        <li><xsl:value-of select="@name"/></li>
                    </xsl:for-each>
                </ul>
            </p>
            <p>This map has the following release(s):
                <ul>
                    <xsl:for-each select="releases/release">
                        <li><xsl:value-of select="."/></li>
                    </xsl:for-each>
                </ul>
            </p>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="construct">
                    <xsl:sort select="name"/>
                    <tr>
                        <td>
                            <xsl:variable name="curl" select="imf:create-catalog-url(.)"/>
                            <xsl:sequence select="if ($curl) then imf:get-xhtml-link($curl,name,true()) else name"/>
                            <xsl:if test="catalog-entry">
                                <br/>
                                <span class="tid">
                                    Catalog: <xsl:value-of select="catalog-entry"/> 
                                </span>
                            </xsl:if>
                        </td>
                        <td>
                            <xsl:value-of select="xsd-type/@name"/>
                        </td>
                        <td>
                            <xsl:value-of select="xsd-type/@asAttributeDesignation"/>:
                            <xsl:value-of select="xsd-type/@asAttribute"/> 
                        </td>
                        <td>
                            <xsl:value-of select="xsd-type/@hasNilreason"/> 
                        </td>
                        <td>
                            <xsl:value-of select="rdf-type/@name"/>
                        </td>
                        <td>
                            <xsl:value-of select="string-join(managed-ids/*,', ')"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$rows">
                    <xsl:sequence select="imf:create-result-table-by-tr($rows,'name:20,xsd-name:10,xsd-attribute:20,nilreason:10,rdf-name:20,ids:20','table-cs')"/>
                </xsl:when>
                <xsl:otherwise>
                    <strong>(Map is empty)</strong>
                </xsl:otherwise>
            </xsl:choose>
          </div>    
     
    </xsl:template>
    
    <xsl:function name="imf:get-xhtml-link" as="element()*">
        <xsl:param name="url"/>
        <xsl:param name="text"/>
        <xsl:param name="new-window" as="xs:boolean"/>
        <a href="{$url}" target="{if ($new-window) then 'catalog' else '_self'}">
            <xsl:value-of select="if (normalize-space($text)) then $text else $url"/>
        </a>
    </xsl:function>
    ?>
    
</xsl:stylesheet>