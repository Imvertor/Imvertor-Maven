<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    
    xmlns:cs="http://www.imvertor.org/metamodels/conceptualschemas/model/v20181210"
    xmlns:cs-ref="http://www.imvertor.org/metamodels/conceptualschemas/model-ref/v20181210" 
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    
    >
    <xsl:output indent="yes"/>
    
    <xsl:template match="/conceptual-schemas">
        <cs:ConceptualSchemas 
            xsi:schemaLocation="http://www.imvertor.org/metamodels/conceptualschemas/model/v20181210 
            ../../../etc/xsd/ConceptualSchema/root/model/v20181210/ConceptualSchemas_Model_v1_0.xsd">
            
            <cs:mappings>
                <xsl:for-each select="mapping">
                    <cs:Mapping>
                        <cs:name><xsl:value-of select="@name"/></cs:name>
                        <cs:use>
                            <xsl:for-each select="use">
                                <cs-ref:MapRef xlink:href="#{.}"/>
                            </xsl:for-each>
                        </cs:use>
                    </cs:Mapping>
                </xsl:for-each>
            </cs:mappings>
            
            <cs:components>
                <cs:ConceptualSchemasComponents>
                    <xsl:for-each select="conceptual-schema">
                        <cs:ConceptualSchema>
                            <cs:id><xsl:value-of select="name"/></cs:id>
                            <cs:shortName><xsl:value-of select="short-name"/></cs:shortName>
                            <xsl:if test="normalize-space(desc)">
                                <cs:desc><xsl:value-of select="normalize-space(desc)"/></cs:desc>
                            </xsl:if>
                            <cs:url><xsl:value-of select="url"/></cs:url>
                            <xsl:if test="catalog">
                                <cs:catalogUrl><xsl:value-of select="catalog"/></cs:catalogUrl>
                            </xsl:if>
                        </cs:ConceptualSchema>
                    </xsl:for-each>
                    <xsl:for-each select="conceptual-schema/map">
                        <cs:Map>
                            <cs:id><xsl:value-of select="@name"/></cs:id>
                            <cs:namespace><xsl:value-of select="@namespace"/></cs:namespace>
                            <xsl:if test="normalize-space(desc)">
                                <cs:desc><xsl:value-of select="normalize-space(desc)"/></cs:desc>
                            </xsl:if>
                            <cs:location><xsl:value-of select="@location"/></cs:location>
                            <cs:phase><xsl:value-of select="@phase"/></cs:phase>
                            <cs:version><xsl:value-of select="@version"/></cs:version>
                            <xsl:for-each select="releases/release">
                                <cs:release><xsl:value-of select="."/></cs:release>
                            </xsl:for-each>
                            <cs:forSchema>
                                <xsl:for-each select="..">
                                    <cs-ref:ConceptualSchemaRef xlink:href="#{name}"/>
                                </xsl:for-each>
                            </cs:forSchema>
                            <cs:constructs>
                                <xsl:for-each select="construct">
                                    <cs:Construct>
                                        <cs:name><xsl:value-of select="name"/></cs:name>
                                        <xsl:if test="normalize-space(desc)">
                                            <cs:desc><xsl:value-of select="normalize-space(desc)"/></cs:desc>
                                        </xsl:if>
                                        <cs:sentinel><xsl:value-of select="(sentinel,'false')[1]"/></cs:sentinel>
                                        <xsl:for-each select="managed-ids/managed-id">
                                            <cs:managedId><xsl:value-of select="."/></cs:managedId>
                                        </xsl:for-each>
                                        <xsl:if test="catalog-entry">
                                            <cs:catalogEntries>
                                                <xsl:for-each select="catalog-entry">
                                                    <cs:CatalogEntry>
                                                        <cs:name><xsl:value-of select="."/></cs:name>
                                                    </cs:CatalogEntry>
                                                </xsl:for-each>
                                            </cs:catalogEntries>
                                        </xsl:if>
                                        <xsl:if test="xsd-type">
                                            <cs:xsdTypes>
                                               <xsl:for-each select="xsd-type">
                                                   <cs:XsdType>
                                                       <cs:name><xsl:value-of select="@name"/></cs:name>
                                                       <xsl:if test="@asAttribute">
                                                           <cs:asAttribute><xsl:value-of select="@asAttribute"/></cs:asAttribute>
                                                       </xsl:if>
                                                       <xsl:if test="@asAttributeDesignation">
                                                           <cs:asAttributeDesignation><xsl:value-of select="@asAttributeDesignation"/></cs:asAttributeDesignation>
                                                       </xsl:if>
                                                       <cs:primitive><xsl:value-of select="(@primitive,'false')[1]"/></cs:primitive>
                                                   </cs:XsdType>
                                               </xsl:for-each>
                                           </cs:xsdTypes>
                                        </xsl:if>
                                        <xsl:if test="rdf-type">
                                            <cs:rdfTypes>
                                                <xsl:for-each select="rdf-type">
                                                    <cs:RdfType>
                                                        <cs:name><xsl:value-of select="@name"/></cs:name>
                                                    </cs:RdfType>
                                                </xsl:for-each>
                                            </cs:rdfTypes>
                                        </xsl:if>
                                    </cs:Construct>
                                </xsl:for-each>
                            </cs:constructs>
                          
                        </cs:Map> 
                    </xsl:for-each>
                </cs:ConceptualSchemasComponents>
            
            </cs:components>
            
        </cs:ConceptualSchemas>
    </xsl:template>
</xsl:stylesheet>