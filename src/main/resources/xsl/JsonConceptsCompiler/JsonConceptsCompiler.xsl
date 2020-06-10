<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    
    exclude-result-prefixes="#all"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:variable name="stylesheet-code">JSONCONCEPTS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/> 
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:variable name="uri-domein-id-template" select="'http://register.geostandaarden.nl/[1]'"/>
    <xsl:variable name="uri-concept-id-template" select="'http://register.geostandaarden.nl/[1]/id/concept/[2]'"/>
    <xsl:variable name="uri-waardelijst-id-template" select="'http://register.geostandaarden.nl/[1]/id/waardelijst/[2]_[3]'"/>
    <xsl:variable name="uri-concept-doc-template" select="'http://register.geostandaarden.nl/[1]/doc/concept/[2]/[3]'"/>
    <xsl:variable name="uri-waardelijst-doc-template" select="'http://register.geostandaarden.nl/[2]/doc/waardelijst/[2]/[3]_[4]'"/>
    
    <xsl:variable name="domain-packages" select="$document-packages[empty(imvert:conceptual-schema-name)]"/><!-- skip packages that are external -->
    <xsl:variable name="model-abbrev" select="imf:get-tagged-value(/imvert:packages,'##CFG-TV-ABBREV')"/>
    <xsl:variable name="model-version" select="/imvert:packages/imvert:version"/>
    
    <xsl:variable name="json-map" as="map(xs:string, xs:boolean)">
        <xsl:map>
            <xsl:map-entry key="'indent'" select="true()"/>
        </xsl:map>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:if test="$domain-packages[2]">
            <xsl:sequence select="imf:msg('More than one package found while creating Json concepts: [1]',imf:string-group($domain-packages/imvert:name/@original))"/>
        </xsl:if>
        <xsl:variable name="json-xml" as="element(j:array)">
            <j:array>
                <xsl:apply-templates select="$domain-packages[1]"/>
            </j:array>
        </xsl:variable>
        <xsl:sequence select="xml-to-json($json-xml,$json-map)"/>
    </xsl:template>
   
    <xsl:template match="imvert:package">
        <j:map>
            <j:string key='@type'>skos:ConceptScheme</j:string>
            <xsl:call-template name="create-domein-uri"/>
            <xsl:call-template name="create-naam"/>
            <xsl:call-template name="create-uitleg"/>
            <j:map key="metadata">
                <xsl:call-template name="create-domein-uri"/>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
        </j:map>
        <xsl:apply-templates select="imvert:class"/>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype','stereotype-name-composite','stereotype-name-relatieklasse')]">
        <j:map>
            <j:string key='@type'>skos:Concept</j:string>
            <xsl:call-template name="create-concept-uri"/>
            <xsl:call-template name="create-naam"/>
            <xsl:call-template name="create-domein"/>
            <xsl:call-template name="create-definitie"/>
            <xsl:call-template name="create-term"/>
            <xsl:call-template name="create-toelichtingen"/>
            <xsl:call-template name="create-generalisatie"/>
            <xsl:call-template name="create-specialisatie"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-concept-uri"/>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
        </j:map>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-referentielijst','stereotype-name-codelist')]">
        <j:map>
            <j:string key='@type'>catalogus:WaardelijstAsset</j:string>
            <xsl:call-template name="create-waardelijst-uri"/>
            <xsl:call-template name="create-naam"/>
            <xsl:call-template name="create-beschrijving"/>
            <xsl:call-template name="create-website"/>
            <xsl:call-template name="create-vervangt"/>
            <xsl:call-template name="create-versie"/>
            <xsl:call-template name="create-versienotities"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-waardelijst-uri"/>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
            <j:array key="waardes">
               <xsl:choose>
                   <xsl:when test="imvert:stereotype/@id = ('stereotype-name-referentielijst')">
                       <xsl:apply-templates select="imvert:attributes/imvert:refelement"/>
                   </xsl:when>
                   <xsl:otherwise>
                       <xsl:apply-templates select="imvert:attributes/imvert:attribute"/>
                   </xsl:otherwise>
               </xsl:choose>
            </j:array>
        </j:map>
    </xsl:template>
    
    <xsl:template match="imvert:attribute">
        <j:map>
            <xsl:call-template name="create-concept-uri"/>
            <xsl:call-template name="create-domein"/>
            <xsl:call-template name="create-term"/>
            <xsl:call-template name="create-definitie"/>
            <xsl:call-template name="create-codes"/>
            <xsl:call-template name="create-gerelateerd"/>
            <xsl:call-template name="create-isWaardeSpecialisatieVan"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-concept-uri"/>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
        </j:map>
    </xsl:template>
    
    <xsl:template match="imvert:refelement">
        <j:map>
            <xsl:call-template name="create-concept-uri"/>
            <xsl:call-template name="create-domein"/>
            <xsl:call-template name="create-term"/>
            <xsl:call-template name="create-definitie"/>
            <xsl:call-template name="create-codes"/>
            <xsl:call-template name="create-gerelateerd"/>
            <xsl:call-template name="create-isWaardeSpecialisatieVan"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-concept-uri"/>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
        </j:map>
    </xsl:template>
    
    <xsl:template match="node()">
        <!-- stop here -->
    </xsl:template>
    
    <xsl:template name="create-domein-uri">
        <j:string key='uri'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-domein-id-template,(
                $model-abbrev
            ),'','')"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-concept-uri">
        <xsl:param name="type"/>
        <j:string key='uri'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-concept-id-template,(
                $model-abbrev,
                imf:create-name(.)
                ),'','')"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-waardelijst-uri">
        <xsl:param name="type"/>
        <j:string key='uri'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-waardelijst-id-template,(
                $model-abbrev,
                imf:create-name(.),
                $model-version
            ),'','')"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-naam">
        <j:string key='naam'>
            <xsl:value-of select="imvert:name/@original"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-uitleg">
        <j:string key='uitleg'>TODO</j:string>
    </xsl:template>
    <xsl:template name="create-domein">
        <j:string key='domein'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-domein-id-template,(
                $model-abbrev
            ),'','')"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-definitie">
        <xsl:variable name="val" select="imf:create-definitie(.)"/>
        <xsl:if test="$val">
            <j:string key='definitie'>
                <xsl:value-of select="$val"/>
            </j:string>
        </xsl:if>
    </xsl:template>
    <xsl:template name="create-toelichtingen">
        <xsl:variable name="val" select="normalize-space(string-join(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DESCRIPTION')//text(),' '))"/>
        <xsl:if test="$val">
            <j:array key='toelichtingen'>
                <j:string>
                    <xsl:value-of select="$val"/>
                </j:string>
            </j:array>
        </xsl:if>
    </xsl:template>
    <xsl:template name="create-term">
        <j:string key='term'>
            <xsl:value-of select="imf:create-name(.)"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-generalisatie">
        <xsl:variable name="seq" select="imf:get-subclasses(.)"/>
        <xsl:if test="$seq">
            <j:array key="isGeneralisatieVan">
                <xsl:for-each select="$seq">
                    <j:string>
                        <xsl:value-of select="imf:insert-fragments-by-index($uri-concept-id-template,(
                            $model-abbrev,
                            imf:create-name(.)
                        ),'','')"/>
                    </j:string>
                </xsl:for-each>
            </j:array>
        </xsl:if>
    </xsl:template>
    <xsl:template name="create-specialisatie">
        <xsl:variable name="seq" select="imf:get-superclasses(.)"/>
        <xsl:if test="$seq">
            <j:array key="isSpecialisatieVan">
                <xsl:for-each select="$seq">
                    <j:string>
                        <xsl:value-of select="imf:insert-fragments-by-index($uri-concept-id-template,(
                            $model-abbrev,
                            imf:create-name(.)
                        ),'','')"/>
                    </j:string>
                </xsl:for-each>
            </j:array>
        </xsl:if>
    </xsl:template>
    <xsl:template name="create-metadata-concept-uri">
        <j:string key='uri'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-concept-doc-template,(
                $model-abbrev,
                imf:create-datumtijd((ancestor::*/imvert:release)[1]),
                imf:create-name(.),
                $model-version
            ),'','')"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-metadata-waardelijst-uri">
        <j:string key='uri'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-waardelijst-doc-template,(
                $model-abbrev,
                imf:create-datumtijd((ancestor::*/imvert:release)[1]),
                imf:create-name(.),
                $model-version
                ),'','')"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-metadata-startdatumgeldigheid">
        <j:string key='startdatumGeldigheid'>
            <xsl:value-of select="imf:create-datum((ancestor::*/imvert:release)[1])"/>
        </j:string>
    </xsl:template>
 
    <xsl:template name="create-beschrijving">
        <j:string key='beschrijving'>
            <xsl:value-of select="normalize-space(string-join(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DESCRIPTION')//text(),' '))"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-website">
        <!--<j:string key='website'>TODO</j:string>-->
    </xsl:template>
    <xsl:template name="create-vervangt">
        <!--<j:string key='vervangt'>TODO</j:string>-->
    </xsl:template>
    <xsl:template name="create-versie">
        <j:string key='versie'>
            <xsl:value-of select="$model-version"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-versienotities">
        <!--<j:string key='versienotities'>TODO</j:string>-->
    </xsl:template>
    <xsl:template name="create-codes">
        <j:string key='codes'>
            <xsl:value-of select="imf:create-name(.)"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-gerelateerd">
        <!-- <j:string key='gerelateerd'>TODO</j:string> -->
    </xsl:template>
    <xsl:template name="create-isWaardeSpecialisatieVan">
        <!-- <j:string key='isSpecialisatievan'>TODO</j:string> -->
    </xsl:template>
    
    <xsl:function name="imf:create-datum" as="xs:string">
        <xsl:param name="release" as="xs:string"/>
        <xsl:value-of select="string-join((substring($release,1,4),substring($release,5,2),substring($release,7,2)),'-')"/>
    </xsl:function>
    <xsl:function name="imf:create-datumtijd" as="xs:string">
        <xsl:param name="release" as="xs:string"/>
        <xsl:value-of select="string-join(($release,'000000'),'')"/>
    </xsl:function>
    
    <!--
        Name and definition may differ between valuelist values and other constructs 
    -->
    <xsl:function name="imf:create-name">
        <xsl:param name="construct"/>
        <xsl:value-of select="($construct/imvert:element[1],$construct/imvert:name/@original)[1]"/>
    </xsl:function>
    <xsl:function name="imf:create-definitie">
        <xsl:param name="construct"/>
        <xsl:variable name="val1" select="string-join($construct/imvert:element[position() ne 1],'; ')"/><!-- for reference lists -->
        <xsl:variable name="val2" select="imf:get-most-relevant-compiled-taggedvalue($construct,'##CFG-TV-DEFINITION')//text()"/> <!-- default -->
        <xsl:variable name="val3" select="imf:get-tagged-value($construct,'##CFG-TV-DEFINITION')"/> <!-- for codelists -->
        <xsl:value-of select="normalize-space(string-join(if ($construct/imvert:element) then $val1 else if ($val2) then $val2 else $val3,''))"/>
    </xsl:function>
    
</xsl:stylesheet>