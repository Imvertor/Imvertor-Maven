<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="ep:message-sets">
        
        <!-- vind de koppelvlak namespace: -->      
        <xsl:variable name="kvnamespace" select="ep:message-set[@KV-namespace = 'yes']/@prefix"></xsl:variable>
        
        <xsl:value-of select="'{'"/>
        <!--definitions -->
        <xsl:value-of select="'&quot;components&quot;: {'"/>
        <xsl:value-of select="'&quot;schemas&quot;: {'"/>

        <!-- Verwerken van alle costructs uit KV namespace, dus ook dataTypes  EN geen relatieNaarLosOpvraagbaarObject
        <xsl:for-each select="ep:message-set/ep:construct[@prefix = $kvnamespace][not(@ismetadata)][not(@relatieNaarLosOpvraagbaarObject)]">
            <xsl:call-template name="construct"/>
            <xsl:call-template name="construct-links"/>
            <xsl:call-template name="construct-self">
                <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
            </xsl:call-template>
            <xsl:call-template name="construct-previous">
                <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
            </xsl:call-template>
            <xsl:call-template name="construct-next">
                <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
            </xsl:call-template>
            <xsl:call-template name="construct-first">
                <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
            </xsl:call-template>
            <xsl:call-template name="construct-last">
                <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
            </xsl:call-template>
        </xsl:for-each>-->
        <!-- Verwerken van alle costructs uit KV namespace, dus ook dataTypes  EN WEL relatieNaarLosOpvraagbaarObject
        <xsl:for-each select="ep:message-set/ep:construct[@prefix = $kvnamespace][not(@ismetadata)][@relatieNaarLosOpvraagbaarObject]">
            <xsl:value-of select="','"/>
            <xsl:call-template name="construct_embedded">
                <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                <xsl:with-param name="elementName" select="@relatieNaarLosOpvraagbaarObject"/>
                <xsl:with-param name="type" select="ep:type-name"/>
            </xsl:call-template>
            <xsl:call-template name="construct-self_embedded">
                <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                <xsl:with-param name="elementName" select="@relatieNaarLosOpvraagbaarObject"/>
            </xsl:call-template>
        </xsl:for-each>
        -->
        
        <!-- Loop over constructs in KV-namespace -->
        <xsl:for-each select="ep:message-set/ep:construct[@prefix = $kvnamespace][not(@ismetadata)]">
            <xsl:variable name="constructName" select="ep:tech-name"/>
            <xsl:choose>
                <!-- Check of het een relatietype is. Als dat zo is, wordt het element embeddded opgenomen 
                Relatietype is een constuct met een type name, die verwijst naar een construct met een entiteittype > 3-->
                <xsl:when test="exists(ep:seq/ep:constructRef[ep:tech-name = 'entiteittype'][string-length(ep:enum[@fixed='yes']) > 3])">
                    <xsl:variable name="relatieNaam">
                        <xsl:choose>
                            <xsl:when test="exists(/ep:message-sets//ep:construct[ep:type-name = concat(@prefix, ':', $constructName)])">
                                <xsl:for-each select="/ep:message-sets//ep:construct[ep:type-name = concat(@prefix, ':', $constructName)]">
                                    <xsl:value-of select="ep:tech-name"/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(@prefix,'_',ep:tech-name)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:call-template name="construct_embedded">
                        <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                        <xsl:with-param name="elementName" select="$relatieNaam"/>
                    </xsl:call-template>
                    <xsl:call-template name="construct-self_embedded">
                        <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                        <xsl:with-param name="elementName" select="$relatieNaam"/>
                    </xsl:call-template>
                
                </xsl:when>
                <xsl:otherwise>
                    <!-- De niet embedded constructs -->
                    <xsl:call-template name="construct"/>
                    <!-- Dit moet uitgezet omdat er te veel links gemaakt worden. Maar misschien wordt er nu te veel weg gehaald?  -->
                    <xsl:if test="exists(ep:seq/ep:constructRef[ep:tech-name = 'entiteittype'])">
                        <xsl:call-template name="construct-links"/>
                        <xsl:call-template name="construct-self">
                            <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                        </xsl:call-template>
                        <xsl:call-template name="construct-previous">
                            <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                        </xsl:call-template>
                        <xsl:call-template name="construct-next">
                            <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                        </xsl:call-template>
                        <xsl:call-template name="construct-first">
                            <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                        </xsl:call-template>
                        <xsl:call-template name="construct-last">
                            <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <!-- Alle types behalve superconstructs uit andere namespaces XXXXXXXX UITGEZET omdat stuurgegevens en extraElementen niet nodig zijn
        <xsl:value-of select="','"/>
        <xsl:for-each select="ep:message-set[@prefix != $kvnamespace]/ep:construct[@prefix != $kvnamespace][not(@ismetadata)][not(@addedLevel)][not(@isdatatype)]">
            <xsl:variable name="prefixNameSup" select="@prefix"/>
            <xsl:variable name="elementNameSup" select="ep:tech-name"/>
            <xsl:if test="not(exists(/ep:message-sets/ep:message-set[@prefix=$kvnamespace]/ep:construct/ep:superconstructRef[@prefix=$prefixNameSup][ep:tech-name=$elementNameSup]))">
                <xsl:call-template name="construct"/>
                <xsl:call-template name="construct-links"/>
                <xsl:call-template name="construct-self">
                    <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                </xsl:call-template>
                <xsl:call-template name="construct-previous">
                    <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                </xsl:call-template>
                <xsl:call-template name="construct-next">
                    <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                </xsl:call-template>
                <xsl:call-template name="construct-first">
                    <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                </xsl:call-template>
                <xsl:call-template name="construct-last">
                    <xsl:with-param name="kvnamespace" select="$kvnamespace"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
         -->
        <!-- Voor alle dataType objecten uit andere namespaces (superconstruct data types) 
        <xsl:value-of select="','"/>-->
        <xsl:for-each select="ep:message-set[@prefix != $kvnamespace]/ep:construct[@prefix != $kvnamespace][@isdatatype][not(@addedLevel)]">
            <xsl:variable name="techname" select="ep:tech-name"/>
            <!-- if statement is voor het uitsluiten van dubbele types in meerdere namespaces (String10, String20) -->
            <xsl:if test="not(exists(/ep:message-sets/ep:message-set/ep:construct[@prefix = $kvnamespace][@isdatatype = 'yes'][ep:tech-name = $techname]))">
                <xsl:call-template name="construct"/>
            </xsl:if>
        </xsl:for-each>
        
        
        <!-- Toevoeging voor missend Datum, Tijdstip  en TijdstipMogelijkOnvolledig datatype (tijdelijk)-->
        <xsl:value-of select="'&quot;Datum&quot;: {&quot;type&quot;: &quot;string&quot;}'"/>
        <xsl:value-of select="',&quot;TijdstipMogelijkOnvolledig&quot;: {&quot;type&quot;: &quot;string&quot;}'"/>
        <xsl:value-of select="',&quot;Tijdstip&quot;: {&quot;type&quot;: &quot;string&quot;}'"/>
        

        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
    </xsl:template>

    <xsl:template name="construct">
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>


        <xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
        
       

        <xsl:choose>
            <!-- Datatypes -->
            <xsl:when test="@isdatatype = 'yes'">
                <xsl:variable name="datatype">
                    <xsl:call-template name="deriveDataType">
                        <xsl:with-param name="incomingType">
                            <xsl:choose>
                                <xsl:when test="contains(ep:data-type, 'scalar-')">
                                    <xsl:value-of select="substring-after(ep:data-type, 'scalar-')"></xsl:value-of>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ep:data-type"></xsl:value-of>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:value-of select="concat('&quot;type&quot;: &quot;',$datatype,'&quot;')"/>
                <xsl:call-template name="stringExtended"/>
            </xsl:when>
            <!-- Choises -->
            <xsl:when test="exists(ep:choice)">
                <!-- Choise elementen -->
                <xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
                
                <xsl:for-each select="ep:choice">
                    <xsl:value-of select="'&quot;oneOf&quot;: ['"/>
                    <xsl:for-each select="ep:construct[@prefix = $prefixName][not(@ismetadata)][not(@addedLevel)]">
                        <xsl:call-template name="choiceProperty"/>
                        <xsl:if test="position() != last()">
                            <xsl:value-of select="','"/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:value-of select="']'"/>
                </xsl:for-each>
            </xsl:when>
            <!-- Gewone properties -->
            <xsl:otherwise>


                <xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>

                <xsl:value-of select="'&quot;properties&quot;: {'"/>
                
                
                <!-- Waarden uit superconstruct (andere namespace) -->
                <xsl:if test="exists(ep:superconstructRef)">
                    <xsl:variable name="prefix" select="ep:superconstructRef/@prefix"/>
                    <xsl:variable name="name" select="ep:superconstructRef/ep:tech-name"/>
                    <xsl:for-each select="/ep:message-sets/ep:message-set[@prefix = $prefix]/ep:construct[@prefix = $prefix][ep:tech-name = $name]/ep:seq/ep:construct[not(@ismetadata)]">
                        <xsl:call-template name="property"/>
                        <xsl:value-of select="','"/>
                    </xsl:for-each>
                </xsl:if>
                
                <!-- Als er een verwijzing is naar ander constuct -->
                <xsl:if test="exists(ep:type-name)">
                    <xsl:call-template name="property"/>
                    
                    <!--<xsl:if test="position() != last()">
                    <xsl:value-of select="','"/>
                    </xsl:if>-->
                </xsl:if>
                
                <!-- Waarden uit eigen namespace -->
                <!-- Die geen relatie zijn die los opvraagbaar zijn! 
                <xsl:for-each select="ep:seq/ep:construct[@prefix = $prefixName][not(@ismetadata)][not(ep:seq)][not(@relatieNaarLosOpvraagbaarObject)]">
                    <xsl:call-template name="property"/>
                        <xsl:value-of select="','"/> 
                </xsl:for-each>-->
                <!-- Die WEL relatie zijn die los opvraagbaar zijn! 
                <xsl:if test="exists(ep:seq/ep:construct[@prefix = $prefixName][not(@ismetadata)][not(ep:seq)][@relatieNaarLosOpvraagbaarObject])">
                    <xsl:value-of select="'&quot;_embedded&quot;: {'"/>
                    <xsl:for-each select="ep:seq/ep:construct[@prefix = $prefixName][not(@ismetadata)][not(ep:seq)][@relatieNaarLosOpvraagbaarObject]">
                        <xsl:call-template name="embedded"/>
                    </xsl:for-each>
                    <xsl:value-of select="'},'"/>
                </xsl:if>-->
                
                <!--Als er een sequence in de construct aanwezig is, opnieuw constructs afleiden -->
                <xsl:for-each select="ep:seq/ep:construct[@prefix = $prefixName][not(@ismetadata)][not(ep:seq)]">
                    <xsl:variable name="prefix" select="@prefix"/>
                    <xsl:variable name="name" select="substring-after(ep:type-name, ':')"/>
                    <xsl:choose>
                        <xsl:when test="exists(/ep:message-sets/ep:message-set[@prefix = $prefix]/ep:construct[@prefix = $prefix][ep:tech-name = $name]/ep:seq/ep:constructRef[ep:tech-name = 'entiteittype'][string-length(ep:enum[@fixed='yes']) > 3])">
                            <xsl:value-of select="'&quot;_embedded&quot;: {'"/>
                                <xsl:call-template name="embedded">
                                    <xsl:with-param name="typeName" select="ep:tech-name"/>
                                </xsl:call-template>                            
                            <xsl:value-of select="'}'"/>
                            <xsl:if test="position() != last()">
                                <xsl:value-of select="','"/> 
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:call-template name="property"/>
                            <xsl:if test="position() != last()">
                                <xsl:value-of select="','"/> 
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                
                
                <!-- Hier moet een opdeling komen van de constucts  die als property opgenomen moeten worden,
                    En de constructs die als embedded elementen moeten worden opgenomen.-->
                <!--<xsl:variable name="prefix" select="@prefix"/>
                    <xsl:variable name="name" select="substring-after(ep:type-name, ':')"/>
                    <xsl:choose>
                        <xsl:when test="exists(/ep:message-sets/ep:message-set[@prefix = $prefix]/ep:construct[@prefix = $prefix][ep:tech-name = $name][@losOpvraagbaarObject = 'true'])">
                            <xsl:call-template name="embedded"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="property"/>
                        </xsl:otherwise>
                    </xsl:choose>-->
                
                <!-- Links alleen genereren als het een entiteittype is-->
                <xsl:if test="exists(ep:seq/ep:constructRef[ep:tech-name = 'entiteittype'])">
                    <xsl:value-of select="','"/>
                <xsl:value-of select="'&quot;_links&quot;: {'"/>
                <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'-links&quot;')"/>
                <xsl:value-of select="'}'"/>
                </xsl:if>
                 
               
                <xsl:value-of select="'}'"/>
            </xsl:otherwise>
        </xsl:choose>
        
        
                

        <xsl:value-of select="'}'"/>

        
        <xsl:value-of select="','"/>
    </xsl:template>
    
    <xsl:template name="property">  
        <xsl:variable name="derivedTypeName">
            <xsl:call-template name="derivePropertyTypeName">
                <xsl:with-param name="typeName" select="substring-after(ep:type-name, ':')"/>
                <xsl:with-param name="typePrefix" select="substring-before(ep:type-name, ':')"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:if test="exists(ep:type-name) or exists(ep:data-type)">
        <xsl:value-of select="concat('&quot;', ep:tech-name,'&quot;: {' )"/>
        <xsl:value-of select="$derivedTypeName"/>
        <xsl:value-of select="'}'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="embedded"> 
        <xsl:param name="typeName"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $typeName, '_embedded&quot;')"/>
    </xsl:template>
    
    <!--Template voor constructs in choise elementen -->
    <xsl:template name="choiceProperty">  
        <xsl:variable name="derivedTypeName">
            <xsl:call-template name="derivePropertyTypeName">
                <xsl:with-param name="typeName" select="substring-after(ep:type-name, ':')"/>
                <xsl:with-param name="typePrefix" select="substring-before(ep:type-name, ':')"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="'{'"/>
        <xsl:value-of select="$derivedTypeName"/>
        <xsl:value-of select="'}'"/>
    </xsl:template>

    <xsl:template name="derivePropertyTypeName">
        <xsl:param name="typeName"/>
        <xsl:param name="typePrefix"/>
        <xsl:choose>
            <xsl:when test="exists(ep:data-type)">
                <!-- Uitzondering voor constructs die niet verwijzen naar een ander type, maar die een datatype als soort hebben -->
                <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;'"></xsl:value-of>
<!--                <xsl:call-template name="cardinality2"/>-->
            </xsl:when>
            <xsl:when test="exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName][@prefix=$typePrefix][exists(@addedLevel)]/ep:type-name)">
                <xsl:call-template name="cardinality"/>
                <xsl:value-of
                    select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', substring-after(/ep:message-sets//ep:construct[ep:tech-name = $typeName][@prefix=$typePrefix][exists(@addedLevel)]/ep:type-name, ':'), '&quot;')"
                />
            </xsl:when>
            <!-- Fix voor de StUF (Datum-e), Postcode-e en INDIC-e velden. Deze zouden eigenlijk met een @addedLevel moeten worden uitgerust-->
            <xsl:when test="$typePrefix = 'StUF' and ends-with($typeName, '-e')">
                <xsl:call-template name="cardinality"/>
                <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', substring-before($typeName, '-e'), '&quot;')"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:call-template name="cardinality"/>
                <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $typeName, '&quot;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="deriveDataType">
        <xsl:param name="incomingType"/>
        
        <xsl:variable name="incomingTypeDerived">
        <xsl:choose>
            <xsl:when test="contains($incomingType, 'scalar-')">
                <xsl:value-of select="substring-after($incomingType, 'scalar-')"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$incomingType"></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$incomingTypeDerived = 'decimal'">
                <xsl:value-of select="'number'"/>
            </xsl:when>
            <xsl:when test="$incomingTypeDerived = 'date'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingTypeDerived = 'dateTime'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingTypeDerived = 'nonNegativeInteger'">
                <xsl:value-of select="'number'"/>
            </xsl:when>
            <xsl:when test="$incomingTypeDerived = 'positiveInteger'">
                <xsl:value-of select="'number'"/>
            </xsl:when>
            <xsl:when test="$incomingTypeDerived = 'primitive-dateTime'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingTypeDerived = 'xs:anyURI'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$incomingTypeDerived"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="cardinality">
        <xsl:if test="exists(ep:min-occurs)">
            <xsl:value-of select="concat('&quot;minOccurs&quot;: &quot;', ep:min-occurs,'&quot;,' )"/>
        </xsl:if>
        <xsl:if test="exists(ep:max-occurs)">
            <xsl:value-of select="concat('&quot;maxOccurs&quot;: &quot;', ep:max-occurs,'&quot;,' )"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Toevoegen van minimale en maximale string lengtes, en een eventueel patroon -->
    <xsl:template name="stringExtended">
        <xsl:if test="exists(ep:formeel-patroon)">
            <xsl:value-of select="concat(',&quot;pattern&quot;: &quot;', replace(ep:formeel-patroon, '\\', '\\\\'),'&quot;' )"/>
        </xsl:if>
        <xsl:if test="exists(ep:min-length)">
            <xsl:value-of select="concat(',&quot;minLength&quot;: ', ep:min-length )"/>
        </xsl:if>
        <xsl:if test="exists(ep:max-length)">
            <xsl:value-of select="concat(',&quot;maxLength&quot;: ', ep:max-length )"/>
        </xsl:if>
        <xsl:if test="exists(ep:enum)">
            <xsl:value-of select="',&quot;enum&quot;: ['"/>
            <xsl:for-each select="ep:enum">
                <xsl:value-of select="concat('&quot;',., '&quot;')"/>
            <xsl:if test="position() != last()">
                <xsl:value-of select="','"/>
            </xsl:if>
        </xsl:for-each>
            <xsl:value-of select="']'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="construct-links">
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'-links&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;self&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'-self&quot;')"/>
        <xsl:value-of select="'},'"/>
        <xsl:value-of select="'&quot;previous&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'-previous&quot;')"/>
        <xsl:value-of select="'},'"/>
        <xsl:value-of select="'&quot;next&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'-next&quot;')"/>
        <xsl:value-of select="'},'"/>
        <xsl:value-of select="'&quot;first&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'-first&quot;')"/>
        <xsl:value-of select="'},'"/>
        <xsl:value-of select="'&quot;last&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'-last&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        
        <xsl:value-of select="','"/>
        
    </xsl:template>
    
    
    <xsl:template name="construct-self">
        <xsl:param name="kvnamespace"/>
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'-self&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;href&quot;: {'"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
        <xsl:value-of select="'&quot;format&quot;: &quot;URI&quot;,'"/>
        <!--<xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '/12345','&quot;')"/>-->
        <xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '?page=13','&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        
            <xsl:value-of select="','"/>
        
    </xsl:template>
    
    <xsl:template name="construct_embedded">
        <xsl:param name="kvnamespace"/>
        <xsl:param name="elementName"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'_embedded&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'_embedded_obj&quot;')"/>
        
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="','"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'_embedded_obj&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;_links&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $elementName,'_embedded_links&quot;')"/>
        <xsl:value-of select="'}'"/>

        <xsl:for-each select="ep:seq/ep:construct[@prefix = $kvnamespace][not(@ismetadata)]">
            <xsl:value-of select="','"/>
            <xsl:call-template name="property"/>
        </xsl:for-each>

        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        
        <xsl:value-of select="','"/>
        
    </xsl:template>
    
    <xsl:template name="construct-self_embedded">
        <xsl:param name="kvnamespace"/>
        <xsl:param name="elementName"/>
        <xsl:variable name="prefixName" select="@prefix"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'_embedded_links&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;self&quot;: {'"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;href&quot;: {'"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
        <xsl:value-of select="'&quot;format&quot;: &quot;URI&quot;,'"/>
        <!--<xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '/12345','&quot;')"/>-->
        <xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '?page=13','&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        
        <xsl:value-of select="','"/>
        
    </xsl:template>
    
    <xsl:template name="construct-previous">
        <xsl:param name="kvnamespace"/>
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'-previous&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;href&quot;: {'"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
        <xsl:value-of select="'&quot;format&quot;: &quot;URI&quot;,'"/>
        <xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '?page=12','&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        

            <xsl:value-of select="','"/>
        
    </xsl:template>
    
    <xsl:template name="construct-next">
        <xsl:param name="kvnamespace"/>
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'-next&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;href&quot;: {'"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
        <xsl:value-of select="'&quot;format&quot;: &quot;URI&quot;,'"/>
        <xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '?page=14','&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        

            <xsl:value-of select="','"/>
        
    </xsl:template>
    
    <xsl:template name="construct-first">
        <xsl:param name="kvnamespace"/>
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'-first&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;href&quot;: {'"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
        <xsl:value-of select="'&quot;format&quot;: &quot;URI&quot;,'"/>
        <xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '?page=1','&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        

            <xsl:value-of select="','"/>
        
    </xsl:template>
    
    <xsl:template name="construct-last">
        <xsl:param name="kvnamespace"/>
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>
        
        <xsl:value-of select="concat('&quot;', $elementName,'-last&quot;: {' )"/>
        <xsl:value-of select="'&quot;properties&quot;: {'"/>
        <xsl:value-of select="'&quot;href&quot;: {'"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
        <xsl:value-of select="'&quot;format&quot;: &quot;URI&quot;,'"/>
        <xsl:value-of select="concat('&quot;example&quot;: &quot;', 'https://service.voorbeeldgemeente.nl/publiek/gemeenten/api/', $kvnamespace, '/', $elementName, '?page=99','&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
        
        <xsl:value-of select="','"/>
        
    </xsl:template>
</xsl:stylesheet>
