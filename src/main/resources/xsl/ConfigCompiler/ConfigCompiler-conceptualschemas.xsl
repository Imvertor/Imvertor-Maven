<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    xmlns:cs="http://www.imvertor.org/metamodels/conceptualschemas/model/v20181210"
    xmlns:cs-ref="http://www.imvertor.org/metamodels/conceptualschemas/model-ref/v20181210"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common-conceptual-map.xsl"/>
    
    <xsl:variable name="inp-folder" select="imf:get-config-string('system','inp-folder-path')"/>
    <xsl:variable name="xsd-folder" select="concat($inp-folder,'/xsd')"/>
    <xsl:variable name="configuration-cs-file" select="imf:document(concat($xsd-folder,'/conceptual-schemas.xml'),true())"/>
    
    <xsl:template match="/config" mode="metamodel-cs">
       
        <xsl:apply-templates select="$configuration-cs-file/cs:ConceptualSchemas" mode="#current"/>
            
    </xsl:template>    
        
    <xsl:template match="cs:ConceptualSchemas" mode="metamodel-cs">
        <div>
            <h2>Mappings</h2>
            <ul>
                <xsl:for-each select="cs:mappings/cs:Mapping">
                    <li>
                        <a name="MAPPING_{cs:name}"/>
                        The mapping 
                        <xsl:value-of select="cs:name"/>
                        uses the following maps: 
                        <ul>
                            <xsl:for-each select="cs:use/cs-ref:MapRef">
                                <xsl:variable name="cid" select="imf:resolve-cs-ref(.,'Map')/cs:id"/>
                                <li>
                                    <a href="#MAP_{$cid}">
                                        <xsl:value-of select="$cid"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
        <div>
            <h2>Conceptual schemas</h2>
            <xsl:apply-templates select="cs:components/cs:ConceptualSchemasComponents/cs:ConceptualSchema" mode="#current"/>
        </div>
        <div>
            <h2>Maps</h2>
            <xsl:apply-templates select="cs:components/cs:ConceptualSchemasComponents/cs:Map" mode="#current"/>
        </div>        
    </xsl:template>

    <xsl:template match="cs:ConceptualSchema" mode="metamodel-cs">
        <div>
            <a name="CS_{cs:id}"/>
            <h3>Conceptual schema: <xsl:value-of select="cs:id"/></h3>
            <p><xsl:sequence select="imf:report-label('Description',cs:desc)"/></p>
            <ul>
                <li><xsl:sequence select="imf:report-label('Short-name',cs:shortName)"/></li>
                <li><xsl:sequence select="imf:report-label('URL',imf:get-xhtml-link(cs:url,(),true()),true())"/></li>
                <li><xsl:sequence select="imf:report-label('Catalog URL',imf:get-xhtml-link(cs:catalogUrl,(),true()),true())"/></li>
            </ul>
        </div>       
    </xsl:template>

    <xsl:template match="cs:Map" mode="metamodel-cs">
        <div>
            <a name="MAP_{cs:id}"/>
            <h3>Map: <xsl:value-of select="cs:id"/></h3>
            <p><xsl:sequence select="imf:report-label('Description',cs:desc)"/></p>
            <ul>
                <li><xsl:sequence select="imf:report-label('Namespace',imf:get-xhtml-link(cs:namespace,(),true()),true())"/></li>
                <li><xsl:sequence select="imf:report-label('Location',imf:get-xhtml-link(cs:location,(),true()),true())"/></li>
                <li>
                    <xsl:sequence select="imf:report-label('Version',imf:get-xhtml-link(cs:version,(),true()))"/>
                    <xsl:sequence select="imf:report-label('Phase',imf:get-xhtml-link(cs:phase,(),true()))"/>
                    <xsl:sequence select="imf:report-label('Release',imf:get-xhtml-link(cs:release,(),true()))"/>
                </li>
                <li><xsl:sequence select="imf:report-label('Catalog template',if (cs:catalog) then imf:get-xhtml-link(cs:catalog,(),true()) else '--')"/></li>
            </ul>
            <p>For conceptual schema: 
                <xsl:variable name="cid" select="imf:resolve-cs-ref(cs:forSchema/cs-ref:ConceptualSchemaRef,'ConceptualSchema')/cs:id"/>
                <a href="#CS_{$cid}">
                    <xsl:value-of select="$cid"/>
                </a>
            </p>
            <p>This map is part of the mapping(s):
                <ul>
                    <xsl:for-each select="$configuration-cs-file//cs:Mapping[cs:use/cs-ref:MapRef/@xlink:href = concat('#',current()/@name)]">
                        <li>
                            <a href="#MAPPING_{cs:name}">
                                <xsl:value-of select="cs:name"/>    
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </p>
            <xsl:variable name="rows" as="element(tr)*">
                <xsl:for-each select="cs:constructs/cs:Construct">
                    <xsl:sort select="cs:name"/>
                    <xsl:variable name="xt" select="cs:xsdTypes/cs:XsdType"/>
                    <xsl:variable name="rt" select="cs:rdfTypes/cs:RdfType"/>
                    <tr>
                        <td>
                            <xsl:variable name="curl" select="imf:create-catalog-url(.)"/>
                            <xsl:sequence select="if ($curl) then imf:get-xhtml-link($curl,cs:name,true()) else cs:name"/>
                            <xsl:for-each select="cs:catalogEntries/cs:CatalogEntry">
                                <span class="tid">
                                    <xsl:sequence select="imf:get-xhtml-link(cs:url,cs:name,true())"/> 
                                </span>
                                <br/>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:value-of select="$xt/cs:name"/>
                        </td>
                        <td>
                            <xsl:value-of select="$xt/cs:primitive"/>
                        </td>
                        <td>
                            <xsl:if test="$xt/cs:asAttribute">
                                <xsl:value-of select="$xt/cs:asAttributeDesignation"/>:
                                <xsl:value-of select="$xt/cs:asAttribute"/> 
                            </xsl:if>
                        </td>
                        <td>
                            <xsl:value-of select="$xt/cs:hasNilreason"/> 
                        </td>
                        <td>
                            <xsl:value-of select="$rt/cs:name"/>
                        </td>
                        <td>
                            <xsl:value-of select="string-join(cs:managedIds/*,', ')"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$rows">
                    <xsl:sequence select="imf:create-result-table-by-tr($rows,'name:20,xsd-name:10,prim?:5,xsd-attribute:20,nilreason:10,rdf-name:15,ids:20','table-cs')"/>
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
   
    
</xsl:stylesheet>