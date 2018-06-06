<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">
	
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>

	<xsl:variable name="stylesheet-code" as="xs:string">OAS</xsl:variable>
	
	<!-- De eerste variabele is bedoelt voor de server omgeving, de tweede voor gebruik bij ontwikkeling in XML-Spy. -->
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
	<!--<xsl:variable name="debugging" select="true()" as="xs:boolean"/>-->
	
	<!-- This parameter defines which version of JSON has to be generated, it can take the next values:
		 * 2.0
		 * 3.0	
		 The default value is 3.0. -->
	<xsl:param name="json-version" select="'3.0'"/>
	
	<!-- TODO: De volgende variabelen moeten op een andere wijze dan in het stylesheet geconfigureerd worden.
			   Hoe is echter nog de vraag, vanuit het model, via parameters of via een configuration profiel. -->
	<!-- This variabele defines the type of output and can take the next values:
		 * json
		 * json+hal
		 * geojson	-->
    <xsl:variable name="uitvoerformaat" select="'json+hal'"/>
	<!-- This variabele defines if pagination applies, it can take the next values:
		 * true()
		 * false()	-->
    <xsl:variable name="pagination">
		<xsl:choose>
			<xsl:when test="//ep:message[@pagination='true']">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
    </xsl:variable>
	<!-- TODO: Volgende variabele moet mogelijk vervangen worden door een lokale variabele met dezelfde naam. De waarde kan dan per message verschillen. -->
	<!-- This variabele defines if it must be able to expand relations within the messages, it can take the next values:
		 * true()
		 * false()-->
<?x    <xsl:variable name="expand" select="true()"/>	?>
   
	<!-- The json topstructure depends on its version:
		 * if its version 2.0 the topstructure is #/definitions
		 * if its 3.0 the topstructure is #/components/schemas	-->
    <xsl:variable name="json-topstructure">
		<xsl:choose>
			<xsl:when test="$json-version = '2.0'">
				<xsl:value-of select="'#/definitions'"/>
			</xsl:when>
			<xsl:when test="$json-version = '3.0'">
				<xsl:value-of select="'#/components/schemas'"/>
			</xsl:when>
		</xsl:choose>
    </xsl:variable>  
	<!-- This variabele defines if the json file must be preceded with a json schemaversion declaration. 
		 It can have the following values and is only applicable with json schema 2.0:
		 * true()
		 * false()	-->
    <xsl:variable name="json-schemadeclaration" select="'true()'"/>
    
    <xsl:template match="ep:message-sets">
        
        <xsl:value-of select="'{'"/>
        <xsl:choose>
			<xsl:when test="$json-version = '2.0'">
				<xsl:if test="$json-schemadeclaration">
					"$schema": "http://json-schema.org/draft-04/schema#",
					"description": "Comment describing your JSON Schema",
				</xsl:if>
				<xsl:value-of select="'&quot;definitions&quot;: {'"/>
			</xsl:when>
			<xsl:when test="$json-version = '3.0'">
				<xsl:value-of select="'&quot;components&quot;: {'"/>
				<xsl:value-of select="'&quot;schemas&quot;: {'"/>
			</xsl:when>
		</xsl:choose>

        <!-- Loop over messages. -->
		<xsl:apply-templates select="ep:message-set/ep:message"/>,
		
        <!-- Loop over constructs which are refered to from the constructs within the messages but aren't enumeration constructs. -->
        <xsl:for-each select="ep:message-set/ep:construct[ep:tech-name = //ep:message/ep:seq/ep:construct/ep:type-name and not(ep:enum)]">
            <xsl:variable name="type-name" select="ep:type-name"/>
            <!-- The regular constructs are generated here. -->
            <xsl:call-template name="construct"/>
            
			<!-- As long as the current construct isn't the last constructs that's refered to from the constructs within the messages 
				 or if json_hal applies a comma separator has to be generated. -->
			<!-- TODO: Als de if onder de volgende TODO wordt ingeschakeld dan moet de volgende regel de daaronder staande ook vervangen. -->
			<!--xsl:if test="(position() != last()) or $uitvoerformaat = 'json+hal'"-->
			<xsl:if test="position() != last()">
				<xsl:value-of select="','"/>
			</xsl:if>
			
			<!-- TODO: De onderstaande if is op dit moment onnodig omdat we er nu vanuit gaan dat er altijd json+hal gegenereerd meot worden.
					   Alleen als we later besluiten dat er ook af en toe geen json_hal gegenereerd moet worden kan deze if weer opportuun worden. 
					   Voor nu isde if uitgeschakeld. -->
            <!-- Only if json+hal applies and the current construct has one or more associations, json+hal constructs are generated here. -->
<?x            <xsl:if test="$uitvoerformaat = 'json+hal'">
				<xsl:for-each select=".[.//ep:construct[@type='association']]">
					<xsl:call-template name="construct_jsonHAL"/>
					<!-- As long as the current construct isn't the last constructs that's refered to from the constructs within the messages a comma separator as to be 
						 generated. -->
						 
					<!-- Volgende if moet alleen de constructs afgaan die een association hebben. Dus alleen voor constructs in de lijst van
						 constructs met associations die niet de laatste daarvan zijn moet ene komma gegenereerd worden. -->	 
					<xsl:if test="position() != last()">
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:for-each>
            </xsl:if> ?>
        </xsl:for-each>
        
        <!-- If the next loop is relevant a comma separator has to be generated. -->
        <xsl:if test="ep:message-set/ep:construct[(ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name) and not(ep:tech-name = //ep:message/ep:seq/ep:construct/ep:type-name) and not(ep:enum)]">,</xsl:if>
       
        <!-- Loop over constructs which are refered to from the global constructs but aren't enumeration constructs. -->
        <xsl:for-each select="ep:message-set/ep:construct[(ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name) and not(ep:tech-name = //ep:message/ep:seq/ep:construct/ep:type-name) and not(ep:enum)]">
            <xsl:variable name="type-name" select="ep:type-name"/>
            
            <!-- Only regular constructs are generated. -->
            <xsl:call-template name="construct"/>
			<!-- As long as the current construct isn't the last constructs that's refered to from the global constructs a comma separator as to be generated. -->
			<xsl:if test="position() != last()">
				<xsl:value-of select="','"/>
			</xsl:if>
        </xsl:for-each>

		<!-- Only if json+hal applies this if is relevant -->
        <xsl:if test="$uitvoerformaat = 'json+hal'">
			<!-- If the next loop is relevant a comma separator has to be generated. -->
			<xsl:if test="ep:message-set/ep:construct[.//ep:construct[@type='association']]">,</xsl:if>

			<!-- Loop over global constructs who do have themself a construct of 'association' type.
				 Global types are generated. -->
			<xsl:for-each select="ep:message-set/ep:construct[.//ep:construct[@type='association']]">

				<xsl:if test="$debugging">
					"--------------Debuglocatie-00600-<xsl:value-of select="generate-id()"/>": {
						"Debug": "AOS00600"
					},
				</xsl:if>

				<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_links&quot;: {' )"/>
				<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
				<xsl:value-of select="'&quot;properties&quot;: {'"/>
				
				<xsl:value-of select="'&quot;self&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/link&quot;')"/>
				<xsl:value-of select="'}'"/>
				<xsl:if test=".//ep:construct[@type ='association' and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]">,</xsl:if>
				<xsl:apply-templates select=".//ep:construct[@type ='association' and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="_links"/>
				<xsl:value-of select="'}'"/>
				<xsl:value-of select="'}'"/>

				<xsl:if test="$debugging">
					,"--------------Einde-00600-<xsl:value-of select="generate-id()"/>": {
						"Debug": "AOS00600"
					}

				</xsl:if>

				<!-- As long as the current construct isn't the last global constructs (that has itself a construct of 'association' type) a comma separator as 
					 to be generated. -->
				<xsl:if test="position() != last()">
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:for-each>
			
			<!-- When expand applies in one or more messages the following if is relevant. -->
			<xsl:if test="ep:message-set/ep:message[@expand = 'true']">
				<!-- If the next loop is relevant a comma separator has to be generated. -->
				<xsl:if test="ep:message-set/ep:construct[.//ep:construct[@type='association' and @expand = 'true']]">,</xsl:if>

				<!-- For all global constructs who have at least one association construct a global embedded version has to be generated. -->
				<xsl:for-each select="ep:message-set/ep:construct[.//ep:construct[@type='association' and @expand = 'true']]">

					<xsl:if test="$debugging">
						"--------------Debuglocatie-00700-<xsl:value-of select="generate-id()"/>": {
							"Debug": "AOS00700"
						},
					</xsl:if>

					<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_embedded&quot;: {' )"/>
					<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
					<xsl:value-of select="'&quot;properties&quot;: {'"/>
					<xsl:apply-templates select=".//ep:construct[@type ='association' and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embedded"/>
					<xsl:value-of select="'}'"/>
					<xsl:value-of select="'}'"/>

					<xsl:if test="$debugging">
						,"--------------Einde-00700-<xsl:value-of select="generate-id()"/>": {
							"Debug": "AOS00700"
						}
					</xsl:if>

					<!-- As long as the current construct isn't the last global constructs (that has at least one association construct) a comma separator as 
						 to be generated. -->
					<xsl:if test="position() != last()">
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:for-each>

				<!-- TODO: het volgende uitbecommentarieerde deel is waarschijnlijk niet nodig. De embedded types worden immers 
						   al in het ep:message-set template gegenereerd. --> 
<?x
				<!-- If the next loop is relevant a comma separator has to be generated. -->
				<xsl:if test="ep:message-set/ep:construct//ep:construct[@type='association' and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]">,</xsl:if>

				<!-- For all association constructs also a global embedded version has to be generated. -->
				
				<xsl:for-each select="ep:message-set/ep:construct//ep:construct[@type='association' and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]">
					<xsl:call-template name="construct_embedded"/>
					<!-- As long as the current construct isn't the last association constructs a comma separator as 
						 to be generated. -->
					<xsl:if test="position() != last()">
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:for-each> ?>

			</xsl:if> 

			<!-- Since json+hal applies the following properties are generated. -->    
			,
			"selflink": {
				"type": "object",
				"properties": {
					"self": {
						"$ref": "<xsl:value-of select="$json-topstructure"/>/link"
					}
				}
			},				
			<!-- If pagination is desired, collections apply, the following properties are generated. -->    
			<xsl:if test="$pagination">
				"pagineerlinks" : {
				"type" : "object",
				"properties" : {
				  "self" : {
					"type" : "object",
					"description" : "uri van de api aanroep die tot dit resultaat heeft geleid",
					"properties" : {
					  "href" : {
						"type" : "string",
						"format" : "uri",
						"example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=4"
					  }
					}
				  },
				  "next" : {
					"type" : "object",
					"description" : "uri voor het opvragen van de volgende pagina van deze collectie",
					"properties" : {
					  "href" : {
						"type" : "string",
						"format" : "uri",
						"example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=5"
					  }
					}
				  },
				  "previous" : {
					"type" : "object",
					"description" : "uri voor het opvragen van de vorige pagina van deze collectie",
					"properties" : {
					  "href" : {
						"type" : "string",
						"format" : "uri",
						"example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=3"
					  }
					}
				  },
				  "first" : {
					"type" : "object",
					"description" : "uri voor het opvragen van de eerste pagina van deze collectie",
					"properties" : {
					  "href" : {
						"type" : "string",
						"format" : "uri",
						"example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=1"
					  }
					}
				  },
				  "last" : {
					"type" : "object",
					"description" : "uri voor het opvragen van de laatste pagina van deze collectie",
					"properties" : {
					  "href" : {
						"type" : "string",
						"format" : "uri",
						"example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=8"
					  }
					}
				  }
				}
			  },
			</xsl:if>
			"link": {
				"type": "object",
				"description": "url naar een resource",
				"properties": {
					"href": {
						"type": "string",
						"format": "uri",
						"example": "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam"
					}
				}
			}
		</xsl:if>
		<!-- The following properties have to be generated always. -->    
		,
		"foutbericht" : {
        "type" : "object",
        "description" : "Terugmelding bij een fout",
			"properties" : {
			  "type" : {
				"type" : "string",
				"format" : "uri",
				"description" : "Link naar meer informatie over deze fout",
				"example" : "https://www.gemmaonline.nl/standaarden/api/ValidatieFout"
			  },
			  "title" : {
				"type" : "string",
				"description" : "Beschrijving van de fout",
				"example" : "Hier staat wat er is misgegaan..."
			  },
			  "status" : {
				"type" : "integer",
				"description" : "Http status code",
				"example" : 400
			  },
			  "detail" : {
				"type" : "string",
				"description" : "Details over de fout",
				"example" : "Meer details over de fout staan hier..."
			  },
			  "instance" : {
				"type" : "string",
				"format" : "uri",
				"description" : "Uri van de aanroep die de fout heeft veroorzaakt",
				"example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?parameter=waarde"
			  },
			  "invalid-params" : {
				"type" : "array",
				"items" : {
				  "$ref" : "<xsl:value-of select="$json-topstructure"/>/paramFoutDetails"
				},
				"description" : "Foutmelding per fout in een parameter. Alle gevonden fouten worden één keer teruggemeld."
			  }
			}
		  },
		  "paramFoutDetails" : {
			"type" : "object",
			"description" : "Details over fouten in opgegeven parameters",
			"properties" : {
			  "type" : {
				"type" : "string",
				"format" : "uri"
			  },
			  "name" : {
				"type" : "string",
				"description" : "Naam van de parameter"
			  },
			  "reason" : {
				"type" : "string",
				"description" : "Beschrijving van de fout op de parameterwaarde"
			  }
			}
		  }
        <!-- If the next loop is relevant a comma separator has to be generated. -->
        <xsl:if test="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:enum]">,</xsl:if>

		<!-- Loop over all enumeration constructs. -->    
        <xsl:for-each select="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:enum]">
<!--			<xsl:if test="$debugging">
				"//<xsl:value-of select="concat('OAS00400: ',generate-id())"/>": "<xsl:value-of select="ep:name"/>",
			</xsl:if>-->
            <xsl:variable name="type-name" select="ep:type-name"/>
            <!-- An enummeration property is generated. -->
            <xsl:call-template name="enumeration"/>
			<!-- As long as the current construct isn't the last enumeration construct a comma separator has to be generated. -->
			<xsl:if test="position() != last()">
				<xsl:value-of select="','"/>
			</xsl:if>
        </xsl:for-each>

        <xsl:value-of select="'}'"/>
        <xsl:choose>
			<xsl:when test="$json-version = '2.0'"/>
			<xsl:when test="$json-version = '3.0'">
				<xsl:value-of select="'}'"/>
			</xsl:when>
		</xsl:choose>
        <xsl:value-of select="'}'"/>
    </xsl:template>
    
	<!-- With this template message properties are generated.  -->
    <xsl:template match="ep:message">
        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
        <xsl:variable name="grouping" select="@grouping"/>
        <!-- TODO: Volgende variabele moet uiteindelijk dezelfde variabele op globaal niveau gaan vervangen. -->
        
        <xsl:variable name="messageName">
			<xsl:choose>
				<xsl:when test="$grouping = 'resource' and $debugging">
					<xsl:value-of select="concat($elementName,'_message')"/>
				</xsl:when>
				<xsl:when test="$grouping = 'resource'">
					<xsl:value-of select="$elementName"/>
				</xsl:when>
				<xsl:when test="$debugging">
					<xsl:value-of select="concat($elementName,'_collection_message')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($elementName,'_collection')"/>
				</xsl:otherwise>
			</xsl:choose>
        </xsl:variable>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-00100-<xsl:value-of select="generate-id()"/>": {
				"Debug": "AOS00100"
			},
		</xsl:if>

        <xsl:value-of select="concat('&quot;', $messageName,'&quot;: {' )"/>

		<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
		
		<xsl:variable name="type-name" select="ep:seq/ep:construct[@type!='requestclass']/ep:type-name"/>
		
		<xsl:choose>
			<xsl:when test="$grouping = 'resource'">
				<xsl:for-each select="//ep:message-set/ep:construct[ep:tech-name = $type-name]">
					<xsl:call-template name="construct">
						<xsl:with-param name="grouping" select="$grouping"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'&quot;properties&quot;: {'"/>
				<!-- If pagination is desired, so collections apply, a reference to the 'pagineerlinks' property is generated.
					 If not a reference to the selflink property is generated. -->    
				<xsl:value-of select="'&quot;_links&quot;: {'"/>
				<xsl:choose>
					<xsl:when test="@pagination='true' and $json-version = '2.0'">
						<xsl:value-of select="'&quot;$ref&quot;: &quot;#/definitions/pagineerlinks&quot;'"/>
					</xsl:when>
					<xsl:when test="@pagination='true'">
						<xsl:value-of select="'&quot;$ref&quot;: &quot;#/components/pagineerlinks&quot;'"/>
					</xsl:when>
					<xsl:when test="$json-version = '2.0'">
						<xsl:value-of select="'&quot;$ref&quot;: &quot;#/definitions/selflink&quot;'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'&quot;$ref&quot;: &quot;#/components/selflink&quot;'"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="'},'"/>
		
				<!-- Only if json+hal applies a reference to a HAL type is generated.
					 In al other cases a reference to a regular type is generated. -->    
				<xsl:choose>
					<xsl:when test="$uitvoerformaat = 'json'">
						<!-- TODO: Nagaan of in dit geval ook een '_embedded' gegenereerd moet worden. -->
						<xsl:value-of select="concat('&quot;',translate(ep:seq/ep:construct/ep:tech-name,'.','_'),'&quot;: {')"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="'&quot;$ref&quot;: &quot;#'"/>
						<xsl:choose>
							<xsl:when test="$json-version = '2.0'">
								<xsl:value-of select="'/definitions/'"/>
							</xsl:when>
							<xsl:when test="$json-version = '3.0'">
								<xsl:value-of select="'/components/schemas/'"/>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="concat(ep:seq/ep:construct/ep:type-name,'&quot;')"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$uitvoerformaat = 'json+hal'">
						<xsl:value-of select="'&quot;_embedded&quot; : {'"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
						<xsl:value-of select="'&quot;properties&quot; : {'"/>
						<!-- TODO: De naam van het _embedded type moet uiteindelijk de naam van het entiteittype in meervoud zijn. -->
						<xsl:value-of select="'&quot;'"/>
						<xsl:choose>
							<xsl:when test="ep:seq/ep:construct[@type!='requestclass']/@meervoudsnaam">
								<xsl:value-of select="ep:seq/ep:construct[@type!='requestclass']/@meervoudsnaam"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="translate(ep:seq/ep:construct[@type!='requestclass']/ep:tech-name,'.','_')"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="'&quot;: {'"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="'&quot;$ref&quot;: &quot;#'"/>
						<xsl:choose>
							<xsl:when test="$json-version = '2.0'">
								<xsl:value-of select="'/definitions/'"/>
							</xsl:when>
							<xsl:when test="$json-version = '3.0'">
								<xsl:value-of select="'/components/schemas/'"/>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="ep:seq/ep:construct[@type!='requestclass']/ep:type-name"/>
						
						<!-- Alleen indien het onderscheid tussen json_hal en gewoon json echt gemaakt moet worden komt wellicht de volgende
							 choose weer in beeld. -->
<?x						<xsl:choose>
							<xsl:when test="//ep:message-set/ep:construct[ep:tech-name = $type-name]//ep:construct[@type='association']">
								<xsl:value-of select="'_HAL&quot;'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'&quot;'"/>
							</xsl:otherwise>
						</xsl:choose>  ?>
						<xsl:value-of select="'&quot;'"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
				</xsl:choose>
				<xsl:value-of select="'}'"/>
			</xsl:otherwise>
		</xsl:choose>

        <xsl:value-of select="'}'"/>

		<xsl:if test="$debugging">
			,"--------------Einde-00100-<xsl:value-of select="generate-id()"/>": {
				"Debug": "AOS00100"
			}
		</xsl:if>

		<!-- As long as the current message isn't the last message a comma separator has to be generated. -->
		<xsl:if test="position() != last()">
			<xsl:value-of select="','"/>
		</xsl:if>

    </xsl:template>

	<!-- With this template global properties are generated.  -->
    <xsl:template name="construct">
		<xsl:param name="grouping" select="''"/>

        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:if test="$grouping != 'resource'">
			<xsl:if test="$debugging">
				"--------------Debuglocatie-00200-<xsl:value-of select="generate-id()"/>": {
					"Debug": "AOS00200"
				},
			</xsl:if>
			<xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
	
			<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
		</xsl:if>
		
		<xsl:variable name="documentation">
			<xsl:value-of select="ep:documentation//ep:p"/>
		</xsl:variable>
		<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
		<!-- Double quotes in documentation text is replaced by a  grave accent. -->
		<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
		<xsl:value-of select="'&quot;,'"/>

		<!-- The variable requiredproperties confirms if at least one of the properties of the current construct is required. -->
		<xsl:variable name="requiredproperties" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
					<xsl:value-of select="true()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Only if the variable requiredproperties is true a 'required' section has to be generated. -->
		<xsl:if test="$requiredproperties">
			<xsl:value-of select="'&quot;required&quot;: ['"/>
			
			<!--Only constructs which aren't optional are processed here. -->
			<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
				<xsl:value-of select="'&quot;'"/><xsl:value-of select="translate(ep:tech-name,'.','_')"/><xsl:value-of select="'&quot;'"/>
				<!-- As long as the current construct isn't the last required construct a comma separator has to be generated. -->
				<xsl:if test="position() != last()">
					<xsl:value-of select="','"/> 
				</xsl:if>
			</xsl:for-each>
			
			<xsl:value-of select="'],'"/>
		</xsl:if>

		<xsl:value-of select="'&quot;properties&quot;: {'"/>
		
<!--		<xsl:if test="$debugging">
			"//<xsl:value-of select="concat('OAS00500: ',generate-id())"/>": "",
		</xsl:if>-->

		<!-- All constructs (that don't have association type constructs) within the current construct are processed here. -->
		<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(@type = 'association')]">
			<xsl:variable name="name" select="substring-after(ep:type-name, ':')"/>

<!--			<xsl:if test="$debugging">
				"//<xsl:value-of select="concat('OAS00600: ',generate-id())"/>": "",
			</xsl:if>
-->
			<xsl:call-template name="property"/>

			<!-- As long as the current construct isn't the last non association type construct a comma separator has to be generated. -->
			<xsl:if test="(position() != last()) and following-sibling::ep:construct[not(@type = 'association')]">
				<xsl:value-of select="','"/> 
			</xsl:if>
		</xsl:for-each>
		

		<xsl:if test=".//ep:construct[@type='association']">
			<xsl:value-of select="','"/>
			<xsl:value-of select="'&quot;_links&quot;: {'"/>

			<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_links&quot;}')"/>
			
			<!-- When expand applies in the interface also an embedded version has to be generated.
				 At this place only a reference to such a type is generated. -->
			<xsl:if test=".//ep:construct[@type='association' and @expand = 'true']">
				<xsl:value-of select="',&quot;_embedded&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_embedded&quot;}')"/>
			</xsl:if>
		</xsl:if>



		<xsl:value-of select="'}'"/>

		<xsl:if test="$grouping != 'resource'">
			<xsl:value-of select="'}'"/>
			<xsl:if test="$debugging">
				,"--------------Einde-00200-<xsl:value-of select="generate-id()"/>": {
					"Debug": "AOS00200"
				}
			</xsl:if>
		</xsl:if>
        
    </xsl:template>
    
	<!-- Enummeration constructs are processed here. -->
    <xsl:template name="enumeration">
        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-00300-<xsl:value-of select="generate-id()"/>": {
				"Debug": "AOS00300"
			},
		</xsl:if>

        <xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>

		<xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>

		<xsl:value-of select="'&quot;enum&quot;: ['"/>
		
<!--		<xsl:if test="$debugging">
			"//<xsl:value-of select="concat('OAS00700: ',generate-id())"/>": "",
		</xsl:if>-->

		<!-- TODO: Nagaan of een enumeration construct nog kan verwijzen naar een andere construct.
				   het lijkt me sterk en als dat niet zo is dan kan deze if verwijderd worden. -->
		<!-- If the construct refers to another construct. -->
		<xsl:if test="exists(ep:type-name)">
<!--			<xsl:if test="$debugging">
				"//<xsl:value-of select="concat('OAS00800: ',generate-id())"/>": "",
			</xsl:if>
-->			<xsl:call-template name="property"/>
		</xsl:if>
		
		<!--All enum elements are processed here. -->
		<xsl:for-each select="ep:enum">
			<xsl:value-of select="concat('&quot;',.,'&quot;')"/>
			<!-- As long as the current construct isn't the last construct a comma separator has to be generated. -->
			<xsl:if test="position() != last()">
				<xsl:value-of select="','"/> 
			</xsl:if>
		</xsl:for-each>
		
		<xsl:value-of select="']'"/>

        <xsl:value-of select="'}'"/>
        
 		<xsl:if test="$debugging">
			,"--------------Einde-00300-<xsl:value-of select="generate-id()"/>": {
				"Debug": "AOS00300"
			}
		</xsl:if>
   </xsl:template>
    
	<!-- TODO: Het onderstaande template en ook de aanroep daarvan zijn is op dit moment onnodig omdat we er nu vanuit gaan dat er altijd json+hal gegenereerd moet worden.
			   Alleen als we later besluiten dat er ook af en toe geen json_hal gegenereerd moet worden kan deze if weer opportuun worden. 
			   Voor nu is het template uitgeschakeld. -->
	<!-- A HAL type is generated here. -->
<?x    <xsl:template name="construct_jsonHAL">
        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-00400-<xsl:value-of select="generate-id()"/>": {
				"Debug": "AOS00400"
			},
		</xsl:if>
 
        <xsl:value-of select="concat('&quot;', $elementName,'_HAL&quot;: {' )"/>
		<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>

        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:variable name="documentation">
			<xsl:value-of select="ep:documentation//ep:p"/>
		</xsl:variable>
		<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
		<!-- Double quotes in documentation text is replaced by a  grave accent. -->
		<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
		<xsl:value-of select="'&quot;,'"/>

		<!-- The variable requiredproperties confirms if at least one of the properties of the current construct is required. -->
		<xsl:variable name="requiredproperties" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
					<xsl:value-of select="true()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Only if the variable requiredproperties is true a 'required' section has to be generated. -->
		<xsl:if test="$requiredproperties">
			<xsl:value-of select="'&quot;required&quot;: ['"/>
			
			<!--Only constructs which aren't optional are processed here. -->
			<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
				<xsl:value-of select="'&quot;'"/><xsl:value-of select="translate(ep:tech-name,'.','_')"/><xsl:value-of select="'&quot;'"/>
				<!-- As long as the current construct isn't the last required construct a comma separator has to be generated. -->
				<xsl:if test="position() != last()">
					<xsl:value-of select="','"/> 
				</xsl:if>
			</xsl:for-each>
			
			<xsl:value-of select="'],'"/>
		</xsl:if>

		<xsl:value-of select="'&quot;properties&quot;: {'"/>
		
<!--		<xsl:if test="$debugging">
			"//<xsl:value-of select="concat('OAS00500: ',generate-id())"/>": "",
		</xsl:if>-->

		<!-- All constructs (that don't have association type constructs) within the current construct are processed here. -->
		<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(@type = 'association')]">
			<xsl:variable name="name" select="substring-after(ep:type-name, ':')"/>

<!--			<xsl:if test="$debugging">
				"//<xsl:value-of select="concat('OAS00600: ',generate-id())"/>": "",
			</xsl:if>
-->
			<xsl:call-template name="property"/>

			<!-- As long as the current construct isn't the last non association type construct a comma separator has to be generated. -->
			<xsl:if test="(position() != last()) and following-sibling::ep:construct[not(@type = 'association')]">
				<xsl:value-of select="','"/> 
			</xsl:if>
		</xsl:for-each>
		

		<!-- If the construct has association constructs a reference to a '_links' property is generated based on the same elementname. -->
		<xsl:if test=".//ep:construct[@type='association']">
			<xsl:value-of select="','"/>
			<xsl:value-of select="'&quot;properties&quot;: {'"/>
			<xsl:value-of select="'&quot;_links&quot;: {'"/>
			<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_links&quot;}')"/>
			
			<!-- When expand applies in the interface also an embedded version has to be generated.
				 At this place only a reference to such a type is generated. -->
			<xsl:if test="$expand">
				<xsl:value-of select="',&quot;_embedded&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_embedded&quot;}')"/>
			</xsl:if>
			<xsl:value-of select="'}'"/>
		</xsl:if>

		<xsl:value-of select="'}'"/>
		<xsl:value-of select="'}'"/>

		<xsl:if test="$debugging">
			,"--------------Einde-00400-<xsl:value-of select="generate-id()"/>": {
				"Debug": "AOS00400"
			}
		</xsl:if>
   </xsl:template> ?>
    
	<!-- TODO: het volgende uitbecommentarieerde template is waarschijnlijk niet nodig evenals zijn aanroep. De embedded types worden immers 
			   al in het ep:message-set template gegenereerd. --> 

<?x	<!-- Embedded types are generated here. -->
    <xsl:template name="construct_embedded">
        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
        <xsl:variable name="typeName" select="translate(ep:type-name,'.','_')"/>

			<xsl:if test="$debugging">
				"--------------Debuglocatie-00500-<xsl:value-of select="generate-id()"/>": {
					"Debug": "AOS00500"
				},
			</xsl:if>
	
			<xsl:value-of select="concat('&quot;', $elementName,'_embedded&quot;: {' )"/>
	
			<xsl:value-of select="'&quot;allOf&quot;: ['"/>
	
			<!-- An '_embedded' property is generated based on the same elementname. -->
			<xsl:value-of select="concat('{&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'&quot;},')"/>
			<xsl:value-of select="'{&quot;type&quot;: &quot;object&quot;}],'"/>
	
			<xsl:value-of select="'&quot;properties&quot;: {'"/>
			<xsl:value-of select="'&quot;_links&quot;: {'"/>
			<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/selflink&quot;}')"/>
			<xsl:value-of select="'}'"/>
			<xsl:value-of select="'}'"/>
	
			<xsl:if test="$debugging">
				,"--------------Einde-00500-<xsl:value-of select="generate-id()"/>": {
					"Debug": "AOS00500"
				}
			</xsl:if>
   </xsl:template> ?>
    
	<!-- The properties representing an uml attribute are generated here.
		 To be able to do that it uses the derivePropertyContent template which on its turn uses the deriveDataType, deriveFormat and deriveFacets templates. -->
    <xsl:template name="property">  
        <xsl:variable name="derivedPropertyContent">
            <xsl:call-template name="derivePropertyContent">
                <xsl:with-param name="typeName" select="ep:type-name"/>
            </xsl:call-template>
        </xsl:variable>
        
		<!-- The following if only applies if the current construct has an ep:type-name or a ep:data-type and if it isn't an association type construct. -->
        <xsl:if test="(exists(ep:type-name) or exists(ep:data-type)) and not(@type='association')">
 			<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'&quot;: {' )"/>
			<xsl:value-of select="$derivedPropertyContent"/>
			<xsl:value-of select="'}'"/>
        </xsl:if>
    </xsl:template>
    
	<!-- This template builds the content of the properties representing an uml attribute. -->
    <xsl:template name="derivePropertyContent">
        <xsl:param name="typeName"/>
        <xsl:param name="typePrefix"/>
        <xsl:choose>
			<!-- If the construct has a data-type a type, a description, an optional format and, also optional, some facets have to be generated. -->
            <xsl:when test="exists(ep:data-type)">
                <xsl:variable name="datatype">
                    <xsl:call-template name="deriveDataType">
                        <xsl:with-param name="incomingType">
                            <xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="format">
                    <xsl:call-template name="deriveFormat">
                        <xsl:with-param name="incomingType">
                            <xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="facets">
                    <xsl:call-template name="deriveFacets">
                        <xsl:with-param name="incomingType">
                            <xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="concat('&quot;type&quot;: &quot;',$datatype,'&quot;')"/>

				<xsl:variable name="documentation">
					<xsl:value-of select="ep:documentation//ep:p"/>
				</xsl:variable>
				<xsl:value-of select="',&quot;description&quot;: &quot;'"/>
				<!-- Double quotes in documentation text is replaced by a  grave accent. -->
				<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
				<xsl:value-of select="'&quot;'"/>
                <xsl:value-of select="$format"/>
                <xsl:value-of select="$facets"/>
            </xsl:when>
 			<!-- If a construct [B] exists which has a type-name and which tech-name is equal to the type-name of the current construct [A] a $ref to the has to be 
				 generated using the B-type-name. -->
           <xsl:when test="exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name)">
                <xsl:value-of
                    select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', /ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name, '&quot;')"
                />
            </xsl:when>
  			<!-- In all othert cases a $ref to the type-name of the current construct has to be generated. -->
           <xsl:otherwise>
                <xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', $typeName, '&quot;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="deriveDataType">
        <xsl:param name="incomingType"/>
        
		<!-- Each scalar type resolves to a type 'string', 'integer', 'number' or 'boolean'. -->
        <xsl:choose>
            <xsl:when test="$incomingType = 'date'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'year'">
                <xsl:value-of select="'integer'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'yearmonth'">
                <xsl:value-of select="'integer'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'dateTime'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'postcode'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'boolean'">
                <xsl:value-of select="'boolean'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'string'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'integer'">
                <xsl:value-of select="'integer'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'decimal'">
                <xsl:value-of select="'number'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'uri'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'string'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="deriveFormat">
        <xsl:param name="incomingType"/>
        
 		<!-- Some scalar typse resolve to a format and/or pattern. -->
       <xsl:choose>
            <xsl:when test="$incomingType = 'date'">
                <xsl:value-of select="',&quot;format&quot;: &quot;date&quot;'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'year'">
                <xsl:value-of select="',&quot;format&quot;: &quot;jaar&quot;,'"/>
                <xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-2]{1}[0-9]{3}$&quot;,'"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$incomingType = 'yearmonth'">
                <xsl:value-of select="',&quot;format&quot;: &quot;jaarmaand&quot;,'"/>
                <xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-2]{1}[0-9]{3}-^[0-1]{1}[0-9]{1}$&quot;,'"/>
				</xsl:if>
            </xsl:when>
            <xsl:when test="$incomingType = 'dateTime'">
                <xsl:value-of select="',&quot;format&quot;: &quot;date-time&quot;'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'postcode'">
                <xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-9]{1}[0-9]{3}[A-Z]{2}$&quot;'"/>
				</xsl:if>
            </xsl:when>
            <xsl:when test="$incomingType = 'uri'">
                <xsl:value-of select="',&quot;format&quot;: &quot;uri&quot;'"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="deriveFacets">
        <xsl:param name="incomingType"/>
        
  		<!-- Some scalar typse can have one or more facets which restrict the allowed value. -->
       <xsl:choose>
            <xsl:when test="$incomingType = 'string'">
				<xsl:if test="ep:patroon and $json-version != '2.0'">
					<xsl:value-of select="concat(',&quot;pattern&quot;: &quot;^',ep:patroon,'$&quot;')"/>
				</xsl:if>
				<xsl:if test="ep:max-length">
					<xsl:value-of select="concat(',&quot;maxLength&quot;: ',ep:max-length)"/>
				</xsl:if>
				<xsl:if test="ep:min-length">
					<xsl:value-of select="concat(',&quot;minLength&quot;: ',ep:min-length)"/>
				</xsl:if>
            </xsl:when>
            <xsl:when test="$incomingType = 'integer'">
				<xsl:if test="ep:min-value">
					<xsl:value-of select="concat(',&quot;minimum&quot;: ',ep:min-value)"/>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<xsl:value-of select="concat(',&quot;maximum&quot;: ',ep:max-value)"/>
				</xsl:if>
            </xsl:when>
            <xsl:when test="$incomingType = 'decimal'">
				<xsl:if test="ep:min-value">
					<xsl:value-of select="concat(',&quot;minimum&quot;: ',ep:min-value)"/>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<xsl:value-of select="concat(',&quot;maximum&quot;: ',ep:max-value)"/>
				</xsl:if>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
	<!-- This template generates for each association a links properties with a reference to a link type. -->
    <xsl:template match="ep:construct[@type='association']" mode="_links">
        <!--<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>-->
        <xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="not(empty(@meervoudsnaam))">
					<xsl:value-of select="@meervoudsnaam"/>
				</xsl:when>
				<xsl:when test="not(empty(@targetrole))">
					<xsl:value-of select="@targetrole"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
				</xsl:otherwise>
			</xsl:choose>
        </xsl:variable>
        
        <xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>

		<xsl:variable name="documentation">
			<xsl:value-of select="ep:documentation//ep:p"/>
		</xsl:variable>
		<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
		<!-- Double quotes in documentation text is replaced by a  grave accent. -->
		<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
		<xsl:value-of select="'&quot;,'"/>
        <xsl:value-of select="'&quot;items&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/link&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
		<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
		<xsl:if test="position() != last()">
			<xsl:value-of select="','"/>
		</xsl:if>
        
    </xsl:template>
    
	<!-- This template generates for each association an embedded properties with a reference to an embedded type. -->
    <xsl:template match="ep:construct" mode="embedded">
        <xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="not(empty(@meervoudsnaam))">
					<xsl:value-of select="@meervoudsnaam"/>
				</xsl:when>
				<xsl:when test="not(empty(@targetrole))">
					<xsl:value-of select="@targetrole"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
				</xsl:otherwise>
			</xsl:choose>
        </xsl:variable>
        <xsl:variable name="typeName" select="ep:type-name"/>
        

        <xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>
        <xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>
        <xsl:value-of select="'&quot;items&quot;: {'"/>
        <xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'&quot;')"/>
        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
		<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
		<xsl:if test="position() != last()">
			<xsl:value-of select="','"/>
		</xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>
