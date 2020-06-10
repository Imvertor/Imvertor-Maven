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
    
    <xsl:variable name="uri-domein" select="'http://standaarden.omgevingswet.overheid.nl/id/conceptscheme/BRObegrippenkader'"/>
    <xsl:variable name="uri-id-template" select="'http://standaarden.omgevingswet.overheid.nl/BRObegrippenkader/id/[1]/[2]'"/>
    <xsl:variable name="uri-doc-template" select="'http://standaarden.omgevingswet.overheid.nl/BRObegrippenkader/doc/[1]/[2]/[3]'"/>
    
    <xsl:variable name="domain-packages" select="$document-packages[empty(imvert:conceptual-schema-name)]"/><!-- skip packages that are external -->
    
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
        <xsl:result-document href="file:/c:/temp/saxon-json.xml" method="xml">
            <xsl:sequence  select="$json-xml"/>
        </xsl:result-document>
        <xsl:sequence select="xml-to-json($json-xml,$json-map)"/>
    </xsl:template>
   
    <xsl:template match="imvert:package">
        <j:map>
            <j:string key='@type'>skos:ConceptScheme</j:string>
            <xsl:call-template name="create-uri">
                <xsl:with-param name="type">concept</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="create-naam"/>
            <xsl:call-template name="create-uitleg"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-uri">
                    <xsl:with-param name="type">concept</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
        </j:map>
        <xsl:apply-templates select="imvert:class"/>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype','stereotype-name-composite','stereotype-name-relatieklasse')]">
        <j:map>
            <j:string key='@type'>skos:Concept</j:string>
            <xsl:call-template name="create-uri">
                <xsl:with-param name="type">concept</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="create-naam"/>
            <xsl:call-template name="create-domein"/>
            <xsl:call-template name="create-definitie"/>
            <xsl:call-template name="create-term"/>
            <xsl:call-template name="create-toelichtingen"/>
            <xsl:call-template name="create-generalisatie"/>
            <xsl:call-template name="create-specialisatie"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-uri">
                    <xsl:with-param name="type">concept</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
        </j:map>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-referentielijst','stereotype-name-codelist')]">
        <j:map>
            <j:string key='@type'>catalogus:WaardelijstAsset</j:string>
            <xsl:call-template name="create-uri">
                <xsl:with-param name="type">waardelijst</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="create-naam"/>
            <xsl:call-template name="create-beschrijving"/>
            <xsl:call-template name="create-website"/>
            <xsl:call-template name="create-vervangt"/>
            <xsl:call-template name="create-versie"/>
            <xsl:call-template name="create-versienotities"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-uri">
                    <xsl:with-param name="type">waardelijst</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
            <j:array key="waardes">
                <xsl:apply-templates select="imvert:attributes/imvert:attribute"/>
            </j:array>
        </j:map>
    </xsl:template>
    
    <xsl:template match="imvert:attribute">
        <j:map>
            <xsl:call-template name="create-uri">
                <xsl:with-param name="type">concept</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="create-domein"/>
            <xsl:call-template name="create-term"/>
            <xsl:call-template name="create-definitie"/>
            <xsl:call-template name="create-codes"/>
            <xsl:call-template name="create-gerelateerd"/>
            <xsl:call-template name="create-isWaardeSpecialisatieVan"/>
            <j:map key="metadata">
                <xsl:call-template name="create-metadata-uri">
                    <xsl:with-param name="type">concept</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="create-metadata-startdatumgeldigheid"/>     
            </j:map>
        </j:map>
    </xsl:template>
    
    <xsl:template match="node()">
        <!-- stop here -->
    </xsl:template>
    
    <xsl:template name="create-uri">
        <xsl:param name="type"/>
        <j:string key='uri'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-id-template,($type,encode-for-uri(imvert:name/@original)),'','')"/>
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
            <xsl:value-of select="$uri-domein"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-definitie">
        <xsl:variable name="val" select="normalize-space(string-join(imf:get-most-relevant-compiled-taggedvalue(.,'##CFG-TV-DEFINITION')//text(),' '))"/>
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
            <xsl:value-of select="imvert:name/@original"/>
        </j:string>
    </xsl:template>
    <xsl:template name="create-generalisatie">
        <xsl:variable name="seq" select="imf:get-subclasses(.)"/>
        <xsl:if test="$seq">
            <j:array key="isGeneralisatieVan">
                <xsl:for-each select="$seq">
                    <j:string>
                        <xsl:value-of select="imf:insert-fragments-by-index($uri-id-template,('concept',encode-for-uri(imvert:name/@original)),'','')"/>
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
                        <xsl:value-of select="imf:insert-fragments-by-index($uri-id-template,('concept',encode-for-uri(imvert:name/@original)),'','')"/>
                    </j:string>
                </xsl:for-each>
            </j:array>
        </xsl:if>
    </xsl:template>
    <xsl:template name="create-metadata-uri">
        <xsl:param name="type"/>
        <j:string key='uri'>
            <xsl:value-of select="imf:insert-fragments-by-index($uri-doc-template,(imf:create-datumtijd((ancestor::*/imvert:release)[1]),$type,encode-for-uri(imvert:name/@original)),'','')"/>
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
        <j:string key='website'>TODO</j:string>
    </xsl:template>
    <xsl:template name="create-vervangt">
        <j:string key='vervangt'>TODO</j:string>
    </xsl:template>
    <xsl:template name="create-versie">
        <j:string key='versie'>TODO</j:string>
    </xsl:template>
    <xsl:template name="create-versienotities">
        <j:string key='versienotities'>TODO</j:string>
    </xsl:template>
    <xsl:template name="create-codes">
        <j:string key='codes'>TODO</j:string>
    </xsl:template>
    <xsl:template name="create-gerelateerd">
        <j:string key='gerelateerd'>TODO</j:string>
    </xsl:template>
    <xsl:template name="create-isWaardeSpecialisatieVan">
        <j:string key='isSpecialisatievan'>TODO</j:string>
    </xsl:template>
    
    <xsl:function name="imf:create-datum" as="xs:string">
        <xsl:param name="release" as="xs:string"/>
        <xsl:value-of select="string-join((substring($release,1,4),substring($release,5,2),substring($release,7,2)),'-')"/>
    </xsl:function>
    <xsl:function name="imf:create-datumtijd" as="xs:string">
        <xsl:param name="release" as="xs:string"/>
        <xsl:value-of select="string-join(($release,'000000'),'')"/>
    </xsl:function>
</xsl:stylesheet>