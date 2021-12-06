<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	xmlns:ep="http://www.imvertor.org/schema/endproduct" 
	xmlns:html="http://www.w3.org/1999/xhtml"
	version="2.0">
	
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:include href="Documentation.xsl"/> 
	
	<xsl:variable name="stylesheet-code" as="xs:string">YAMLB</xsl:variable>
	
	<!-- The first variable is meant for the server environment, the second one is used during development in XML-Spy. -->
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
	<!--<xsl:variable name="debugging" select="false()" as="xs:boolean"/>-->
	
	<xsl:variable name="standard-json-components-url" select="concat(imf:get-config-parameter('standard-components-url'),imf:get-config-parameter('standard-components-file'),imf:get-config-parameter('standard-json-components-path'))"/>
	<xsl:variable name="standard-json-gemeente-components-url" select="concat(imf:get-config-parameter('standaard-organisatie-components-url'),imf:get-config-parameter('standard-organisatie-components-file'),imf:get-config-parameter('standard-json-components-path'))"/>
	<xsl:variable name="standard-geojson-components-url" select="imf:get-config-parameter('geonovum-components-url')"/>
	<!--<xsl:variable name="standard-json-components-url" select="'http://www.test.nl/'"/>	
	<xsl:variable name="standard-geojson-components-url" select="'http://www.test.nl/'"/>-->
	
	
	<!-- This parameter defines which version of JSON has to be generated, it can take the next values:
		 * 2.0
		 * 3.0	
		 The default value is 2.0. -->
	<xsl:param name="json-version" select="'2.0'"/>
	
	<!-- This variabele defines the type of output and can take the next values:
		 * json
		 * hal+json
		 * geojson	-->
	<xsl:variable name="serialisation">
		<xsl:choose>
			<xsl:when test="empty(/ep:message-sets/ep:parameters/ep:parameter[ep:name='serialisation'])">
				<xsl:value-of select="'hal+json'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/ep:message-sets/ep:parameters/ep:parameter[ep:name='serialisation']/ep:value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- This variabele defines if pagination applies to at least one message, it can take the next values:
		 * true()
		 * false()	-->
	<xsl:variable name="pagination">
		<xsl:choose>
			<xsl:when test="//ep:message[ep:parameters/ep:parameter[ep:name='pagination']/ep:value='true']">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
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
	<xsl:variable name="json-schemadeclaration" select="true()"/>

	<xsl:variable name="message-sets">
		<ep:message-sets>
			<xsl:copy-of select="//ep:message-set"/>
		</ep:message-sets>
	</xsl:variable>
	
	<xsl:template match="ep:message-sets">
		
		<xsl:for-each select="/ep:message-sets/ep:message-set/ep:construct[ep:parameters/ep:parameter[ep:name='endpointavailable']/ep:value = 'Nee' and ep:tech-name = //ep:message/ep:seq/ep:construct/ep:type-name]">
			<xsl:sequence select="imf:msg(.,'ERROR','The tv &quot;[1]&quot; has been specified with the value &quot;Nee&quot; on the top level entity [2]. This is not allowed',(./ep:parameters/ep:parameter/ep:name[.='endpointavailable']/@original,./ep:name))" />			
		</xsl:for-each>


		
		<xsl:result-document href="{concat('file:/c:/temp/SubtypeConstruct/',generate-id(),'.xml')}" method="xml">
			<xsl:copy-of select="$message-sets"/>
		</xsl:result-document>
		
<?x		<xsl:for-each select="//ep:construct[ep:parameters/ep:parameter[ep:name = 'type' and ep:value = 'association'] and ep:choice]">
			<xsl:variable name="types">
				<xsl:for-each select="ep:choice/ep:construct">
					<xsl:sort select="ep:type-name" order="ascending"/>
					<xsl:variable name="type" select="ep:type-name"/>
					<xsl:if test="not(preceding-sibling::ep:construct/ep:type-name = $type)">
						<ep:type-name><xsl:value-of select="ep:type-name"/></ep:type-name>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:result-document href="{concat('file:/c:/temp/SubtypeConstruct/',generate-id(),'.xml')}">
				<a>
					<xsl:copy-of select="$types"/>
				</a>
			</xsl:result-document>
		</xsl:for-each> ?>
		
		
		
		<!-- First the JSON top-level structure is generated. -->
		<xsl:value-of select="'{'"/>
		<xsl:choose>
			<xsl:when test="$json-version = '2.0'">
				<xsl:if test="$json-schemadeclaration = true()">
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

		<!-- For each global construct a component is generated. -->

		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<!-- Only if hal+json applies this when is relevant -->
				<!-- In case of Gr or Gc messages HalCollectie and Hal entities have to be generated. -->
				<xsl:variable name="halEntiteiten">
					<!-- Loop over global constructs which are refered to from constructs directly within the (collection) ep:message 
					 elements (the top-level classes). So enumeration constructs and group constructs are not included.
					 In case of hal+json serialisation for-each of those entities an '[eniteitnaam]Hal' component has to be created. -->
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
						ep:tech-name = //ep:message
						[
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
						)
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
						]
						/ep:*/ep:construct/ep:type-name 
						and 
						not( ep:enum )
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>

						<xsl:variable name="type-name" select="ep:type-name"/>
						<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
						
						<!-- If the class is a construct for a Gc message a HalCollectie component is created. -->
						<xsl:if test="contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc')">
							<xsl:variable name="tech-name" select="ep:tech-name"/>
							<xsl:variable name="pagination" select="//ep:message
								[
								contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
								and 
								ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
								and
								ep:*/ep:construct/ep:type-name = $tech-name
								]
								/ep:parameters/ep:parameter[ep:name='pagination']/ep:value"/>
							<xsl:value-of select="concat('&quot;',$tech-name,'HalCollectie&quot;: {')"/>
							<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
							<xsl:value-of select="'&quot;properties&quot;: {'"/>
							<xsl:value-of select="'&quot;_links&quot;: {'"/>
							<xsl:choose>
								<xsl:when test="$pagination='true'">
									<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'HalPaginationLinks','&quot;')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'HalCollectionLinks','&quot;')"/>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="'},'"/>
							<xsl:value-of select="'&quot;_embedded&quot;: {'"/>
							<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
							<xsl:value-of select="'&quot;properties&quot;: {'"/>
							<xsl:value-of select="concat('&quot;',ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value,'&quot;: {')"/>
							<xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>
							<xsl:value-of select="'&quot;items&quot;: {'"/>
							<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',translate($tech-name,'.','_'),'Hal&quot;')" />
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'},'"/>
						</xsl:if>							

						<!-- The regular constructs are generated here. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-01000 ": {
			                "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                },
						</xsl:if>
						
						<xsl:sequence select="imf:createHalComponent($elementName,.)"/>
						
						<xsl:variable name="construct">
							<xsl:call-template name="construct"/>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- In case of Pa, Po or Pu messages only Hal entities have to be generated. -->
				<xsl:variable name="entiteiten">
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
						ep:tech-name = //ep:message
						[
						(
						(
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						) 
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
						)
						or 
						(							
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa' ) 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po' ) 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu' ) 
						
						)
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
						)
						)
						]
						/ep:*/ep:construct/ep:type-name 
						and 
						not( ep:enum )
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>

						<xsl:variable name="type-name" select="ep:type-name"/>
						<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

						<!-- The regular constructs are generated here. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-01100 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							},
						</xsl:if>

						<xsl:sequence select="imf:createHalComponent($elementName,.)"/>
						
						<xsl:variable name="construct">
							<xsl:call-template name="construct"/>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$halEntiteiten != ''">
					<xsl:sequence select='$halEntiteiten'/>
				</xsl:if>
				<xsl:if test="$entiteiten != '' and $halEntiteiten != ''">
					,
				</xsl:if>
				<xsl:if test="$entiteiten != ''">
					<xsl:sequence select='$entiteiten'/>
				</xsl:if>
				<xsl:if test="$debugging">
					,"--------------Debuglocatie-01200 ": {
					"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
					}
				</xsl:if>	
			</xsl:when>
			<xsl:otherwise>
				<!-- Loop over global constructs which are refered to from constructs directly within the (collection) ep:message 
			 elements but aren't enumeration constructs. -->
				<xsl:variable name="entiteiten">
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
						ep:tech-name = //ep:message
						[
						(
						(
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						or 
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
						or 
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc')
						) 
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
						)
						or 
						(							
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa' ) 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po' ) 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu' ) 
						
						)
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
						)
						)
						]
						/ep:*/ep:construct/ep:type-name 
						and 
						not( ep:enum )
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>
						<xsl:variable name="type-name" select="ep:type-name"/>
						<!-- The regular constructs are generated here. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-01300 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							},
						</xsl:if>
						<xsl:variable name="construct">
							<xsl:call-template name="construct"/>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="$entiteiten != ''">
					<xsl:sequence select='$entiteiten'/>
				</xsl:if>
				<xsl:if test="$debugging">
					,"--------------Debuglocatie-01400 ": {
					"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
					}
				</xsl:if>				
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't 'enumeration', 'superclass', 'complex-datatype','groep' or 'table-datatype' constructs.
					 This is only applicable when the serialisation is hal+json.
					 See 'Imvertor-Maven\src\main\resources\xsl\YamlCompiler\documentatie\Explanation query constructions.xlsx' tab 'Query1' for an explanation on this query. -->
				<xsl:variable name="entiteiten">
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
								(
								ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name
								or
								ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:choice/ep:construct/ep:type-name
								) 
							and 
								not
									(
										ep:tech-name = //ep:message
										[
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
										]
										/ep:*/ep:construct/ep:type-name
									) 
							and 
								not(ep:enum) 
							and 
								(
									(
										(
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
											or
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
											or
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
										)
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
									) 
								or 
									(
										( 
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
											or
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
											or
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
											or
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
											or 	
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
										) 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
									)
								)
						and 
							(
									(
										not
											(
												ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
												and 
												ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
											)
									and
										not
											(
												ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
												[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
												/ep:type-name
											)
									and
										(
											ep:parameters/ep:parameter[ep:name='type']/ep:value != '' 
											and 
											ep:parameters/ep:parameter[ep:name='expand']/ep:value = 'true'
										)
									and
									
									
										(
											not
												(
													ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
													and 
													not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
												)
											or
											ep:parameters[ep:parameter[ep:name='contains-non-id-attributes' and ep:value='true']]
										)
									
									)
								or
									(
										ep:parameters/ep:parameter[ep:name='type']/ep:value='association' 
										or
										ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association'
									)
							)
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>
						<!-- Only regular constructs are generated. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-01500 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							},
						</xsl:if>
						<xsl:variable name="construct">
							<xsl:choose>
								<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value='association' or
									ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association'">
									<xsl:call-template name="construct">
										<xsl:with-param name="mode" select="'onlyLinksAndEmbedded'"/>
									</xsl:call-template>								
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="type-name" select="ep:type-name"/>
									<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
									
									<xsl:sequence select="imf:createHalComponent($elementName,.)"/>
									
									<xsl:call-template name="construct"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- If the variable 'constructs' has content it's content can be dropped here preceded by a comma separator. -->
				<xsl:if test="$entiteiten != ''">
					,<xsl:sequence select='$entiteiten'/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
				<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't 'enumeration', 'superclass', 'complex-datatype','groep' or 'table-datatype' constructs.
					 This is only applicable when the serialisation is json. -->
				<xsl:variable name="entiteiten">					
					<xsl:for-each select="ep:message-set/ep:construct
									[ 
										(
											ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name
											or
											ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:choice/ep:construct/ep:type-name
										) 
										and 
										not(
										   ep:tech-name = //ep:message
										   [
											 ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
										   ]
										   /ep:*/ep:construct/ep:type-name
										) 
										and 
										not(ep:enum) 
										and 
										(
										  (
											(
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
											or
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
											or
											contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
											)
											and 
											ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
										  ) 
										  or 
										  (
											( 
											  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
											  or
											  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
											  or
											  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
											  or
											  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
											  or 	
											  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
											) 
											and 
											ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
										  )
										)
										and 
										not(
										   ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
										   and 
										   ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
										)
										and
										not(
											ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
											[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
											/ep:type-name
										)
										and
										not(
											ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
											and 
											not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
										)
									]">
						<xsl:sort select="ep:tech-name" order="ascending"/>
						<!-- Only regular constructs are generated. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-01600 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							},
						</xsl:if>
						<xsl:variable name="construct">
							<xsl:call-template name="construct"/>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- If the variable 'constructs' has content it's content can be dropped here preceded by a comma separator. -->
				<xsl:if test="$entiteiten != ''">
					,<xsl:sequence select='$entiteiten'/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		
		<?x		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't enumeration and superclass constructs.
					 This is only applicable when the serialisation is hal+json.
					 See 'Imvertor-Maven\src\main\resources\xsl\YamlCompiler\documentatie\Explanation query constructions.xlsx' tab 'Query1' for an explanation on this query. -->
				<xsl:variable name="constructs">
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
						(
						ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name
						or
						ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:choice/ep:construct/ep:type-name
						) 
						and 
						not(
						ep:tech-name = //ep:message
						[
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
						]
						/ep:*/ep:construct/ep:type-name
						) 
						and 
						not(ep:enum) 
						and 
						(
						(
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						)
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
						) 
						or 
						(
						( 
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
						or 	
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
						) 
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
						)
						)
						and 
						not(
						ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
						and 
						ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
						)
						and
						not(
						ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
						[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
						/ep:type-name
						)
						and
						(
						(
						ep:parameters/ep:parameter[ep:name='type']/ep:value != '' 
						and 
						ep:parameters/ep:parameter[ep:name='expand']/ep:value = 'true'
						) 
						or 
						(
						ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groep','table-datatype')
						)
						)
						and
						not(
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groep'])] 
						and 
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
						and 
						not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
						)
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>
						<!-- Only regular constructs are generated. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-01700 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							},
						</xsl:if>
						<xsl:variable name="construct">
							<xsl:call-template name="construct"/>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- If the variable 'constructs' has content it's content can be dropped here preceded by a comma separator. -->
				<xsl:if test="$constructs != ''">
					,<xsl:sequence select='$constructs'/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
				<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't enumeration and superclass constructs.
					 This is only applicable when the serialisation is json. -->
				<xsl:variable name="constructs">					
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
						(
						ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name
						or
						ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:choice/ep:construct/ep:type-name
						) 
						and 
						not(
						ep:tech-name = //ep:message
						[
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
						]
						/ep:*/ep:construct/ep:type-name
						) 
						and 
						not(ep:enum) 
						and 
						(
						(
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						)
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
						) 
						or 
						(
						( 
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
						or 	
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
						) 
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
						)
						)
						and 
						not(
						ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
						and 
						ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
						)
						and
						not(
						ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
						[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
						/ep:type-name
						)
						and
						ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groep','table-datatype')
						and
						not(
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groep'])] 
						and 
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
						and 
						not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
						)
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>
						<!-- Only regular constructs are generated. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-01800 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							},
						</xsl:if>
						<xsl:variable name="construct">
							<xsl:call-template name="construct"/>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- If the variable 'constructs' has content it's content can be dropped here preceded by a comma separator. -->
				<xsl:if test="$constructs != ''">
					,<xsl:sequence select='$constructs'/>
				</xsl:if>
			</xsl:when>
		</xsl:choose> ?>
		
		<xsl:if test="$debugging">
			,"--------------Debuglocatie-01900 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			}
		</xsl:if>
		<!-- Loop over global superclass constructs which are refered to from constructs within the messages. -->
		<xsl:variable name="global-superclass-constructs">
			<xsl:for-each select="ep:message-set/ep:construct
				[
				ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
				and 
				not(
				ep:tech-name = //ep:message-set/ep:construct
				[
				ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
				[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
				/ep:type-name
				]
				/ep:*/ep:construct/ep:ref
				)
				]">
				<xsl:sort select="ep:tech-name" order="ascending"/>
				<!-- Only regular constructs are generated. -->
				<xsl:if test="$debugging">
					"--------------Debuglocatie-02000 ": {
			        "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			        },
				</xsl:if>
				<xsl:variable name="construct">
					<xsl:call-template name="construct"/>
				</xsl:variable>
				<xsl:sequence select="$construct"/>
				<xsl:if test="position() != last() and $construct!=''">
					<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
						 and the variable $construct isn't empty a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- If the variable 'global-superclass-constructs' has content it's content can be dropped here preceded by a comma separator. -->
		<xsl:if test="$global-superclass-constructs != ''">
			,<xsl:sequence select="$global-superclass-constructs"/>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<xsl:variable name="global-constructs">
					<!-- Loop over global constructs which 
						 * aren't reffered to from ep:construct elements of type 'subclass' which are child of an ep:choice;
						 * aren't abstract;
						 * are part of the requesttree of a Po message or in the responsetree of an Gc or Gr message;
						 * aren't of type 'complex-datatype';
						 * aren't of type 'table-datatype';
						 * aren't of type 'groep';
						 * aren't of type 'groepCompositieAssociation';
						 * do have a type;
						 * are part of a message which must be expanded or do have themself an ep:construct of 'association' type  or are reffered to from a 
						   top-level ep:construct within an ep:message;
						 * has attributes which aren't part of the id of the ep:construct.
						 in those cases a global _link types (and under certain circumstances global _embedded types) are generated. -->
					<xsl:for-each select="ep:message-set/ep:construct
											[
												(
													(
													  	not(
															 ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
																		    [ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
																		    /ep:type-name
															) 
														and 
														(
															empty(
																 ep:parameters/ep:parameter[ep:name='abstract']
																) 
															or
															ep:parameters/ep:parameter[ep:name='abstract']/ep:value = 'false'
														)
														and 
														(
														  (
															(
															contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
															or
															contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
															or
															contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
															)
															and 
															ep:parameters/ep:parameter[ep:name='messagetype']/ep:value='requestbody'
														  ) 
														  or 
														  (
														    (
														      contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
														      or
														      contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
														      or
														      contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
														      or
														      contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
																or 
																contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
															) 
															and 
															ep:parameters/ep:parameter[ep:name='messagetype']/ep:value='response'
														  )
														) 
														and 
														ep:parameters/ep:parameter[ep:name='type']/ep:value!='complex-datatype' 
														and 
														ep:parameters/ep:parameter[ep:name='type']/ep:value!='table-datatype' 
														and 
														ep:parameters/ep:parameter[ep:name='type']/ep:value!='groep' 
														and 
														ep:parameters/ep:parameter[ep:name='type']/ep:value!='groepCompositieAssociation' 
														and 
														ep:parameters/ep:parameter[ep:name='type']/ep:value != '' 
														and 
														(
														  ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
														  or 
														  .//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='association'] 
														  or 
														  ep:tech-name = //ep:message/ep:seq/ep:construct/ep:type-name
														)
														and (
														.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]]
														or
														empty(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id']]])
														or
														ep:parameters/ep:parameter[ep:name='contains-non-id-attributes' and ep:value='true']
														)
														and ep:seq/ep:*
													)
													or
													(
														ep:tech-name = //ep:message-set/ep:construct
														[ 
														(
														ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name
														or
														ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:choice/ep:construct/ep:type-name
														) 
														and 
														not(
														ep:tech-name = //ep:message
														[
														ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
														]
														/ep:*/ep:construct/ep:type-name
														) 
														and 
														not(ep:enum) 
														and 
														(
														(
														(
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
														or
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
														or
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
														)
														and 
														ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
														) 
														or 
														(
														( 
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
														or
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
														or
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
														or
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
														or 	
														contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
														) 
														and 
														ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
														)
														)
														and 
														(
														ep:parameters/ep:parameter[ep:name='type']/ep:value='association' or
														ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association'
														)
														]/ep:choice/ep:construct/ep:type-name
													)
												)
												and
												not(ep:parameters/ep:parameter[ep:name='endpointavailable']/ep:value='Nee')
											]">

						<xsl:sort select="ep:tech-name" order="ascending"/>
						<xsl:if test="$debugging">
								"--------------Debuglocatie-02100 ": {
			                    "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                    },
						</xsl:if>
						<xsl:variable name="choiceConstructs2bprocessed">
							<ep:choiceConstructs2bprocessed>
								<xsl:for-each select="ep:seq/ep:choice">
									<xsl:apply-templates select="ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')  and ep:type-name = //ep:message-set/ep:construct/ep:tech-name][1]" mode="_links"/>
								</xsl:for-each>
							</ep:choiceConstructs2bprocessed>
						</xsl:variable>
						<xsl:variable name="choiceConstructs">
							<xsl:for-each select="$choiceConstructs2bprocessed/ep:choiceConstructs2bprocessed/ep:construct2bprocessed[.!='']">
								<xsl:sequence select="."/>
								<xsl:if test="position() != last()">
									<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
									<xsl:value-of select="','"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:variable name="seqConstructs2bprocessed">
							<ep:seqConstructs2bprocessed>
								<xsl:for-each select=".//ep:seq">
									<xsl:apply-templates select="ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')  and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="_links"/>
								</xsl:for-each>
							</ep:seqConstructs2bprocessed>
						</xsl:variable>
						<xsl:variable name="seqConstructs">
							<xsl:for-each select="$seqConstructs2bprocessed/ep:seqConstructs2bprocessed/ep:construct2bprocessed[.!='']">
								<xsl:sequence select="."/>
								<xsl:if test="position() != last()">
									<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
									<xsl:value-of select="','"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="$choiceConstructs!='' or $seqConstructs!='' or empty(ep:parameters/ep:parameter[ep:name = 'abstract']) or ep:parameters/ep:parameter[ep:name = 'abstract']/ep:value = 'false'">
							<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_links&quot;: {' )"/>
							<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
							<xsl:value-of select="'&quot;properties&quot;: {'"/>
							<xsl:if test="empty(ep:parameters/ep:parameter[ep:name = 'abstract']) or ep:parameters/ep:parameter[ep:name = 'abstract']/ep:value = 'false'">
								<xsl:value-of select="'&quot;self&quot;: {'"/>
								<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'HalLink&quot;')"/>
								<xsl:value-of select="'}'"/>
								<xsl:if test=".//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association') and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]">,</xsl:if>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="not($choiceConstructs='') and not($seqConstructs='')">
									<xsl:sequence select="$choiceConstructs"/>
									<xsl:value-of select="','"/>
									<xsl:sequence select="$seqConstructs"/>
								</xsl:when>
								<xsl:when test="not($choiceConstructs='')">
									<xsl:sequence select="$choiceConstructs"/>
								</xsl:when>
								<xsl:when test="not($seqConstructs='')">
									<xsl:sequence select="$seqConstructs"/>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'}'"/>
						</xsl:if>
						<xsl:if test="$debugging">
							,"------------Einde-Debuglocatie-02100 ": {
		                    "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
		                    }
						</xsl:if>
						<xsl:if test="position() != last()">
							<!-- As long as the current construct isn't the last global constructs (that has itself a construct of 'association' type) 
								 a comma separator as to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- If the variable 'global-constructs' has content it's content can be dropped here preceded by a comma separator. -->
				<xsl:if test="$global-constructs != ''">
					<xsl:variable name="length" select="string-length($global-constructs)"/>
					,
					<xsl:choose>
						<xsl:when test="substring($global-constructs,$length,1) = ','">
							<xsl:variable name="global-constructs-without-end-comma">
								<xsl:sequence select="substring($global-constructs,1,$length - 1)"/>
							</xsl:variable>
							<xsl:sequence select="$global-constructs-without-end-comma"/>	
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="$global-constructs"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<!-- When expand applies in one or more messages the following if is relevant. -->
				<xsl:if test="ep:message-set/ep:message[ep:parameters/ep:parameter[ep:name='expand']/ep:value = 'true']">
					<!-- For all global constructs who have at least one association or supertype-association construct a global embedded version has to 
						 be generated. Since it is not possible (or at least very hard) to detect if the next construct processed by this for each has content it is not possible to
						 determine if the for-each has to create a comma at the end. For that reason the comma is generated always and the content generated by the for-each is placed 
						 within a variable. After the for-each the last comma within the variable is removed. -->
					<xsl:variable name="global-embedded-constructs">
						<xsl:for-each select="ep:message-set/ep:construct
											    [
													ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
													and
													not(
														 ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
																	    [ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
																	    /ep:type-name
													) 
													and 
													.//ep:construct
													[
													  (
													    ep:parameters/ep:parameter[ep:name='type']/ep:value='association' 
													    or 
													    ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association'
													  )  
													  and 
													  ep:parameters/ep:parameter[ep:name='contains-non-id-attributes']/ep:value = 'true'
													]
												]">
							<xsl:sort select="ep:tech-name" order="ascending"/>
							<xsl:variable name="typeName" select="ep:type-name"/>
							<!-- The embedded component must only be generated when the apply-template of the ep:seq element results in content.
								 That is determined here. For now this is only determined for one _embedded level. If this isn't enough I have to implement a more thorough solution.  -->
							<xsl:variable name="content">
								<xsl:apply-templates select="ep:seq">
									<xsl:with-param name="typeName" select="$typeName"/>
								</xsl:apply-templates>
							</xsl:variable>
							
							<xsl:if test="contains($content,'{')">
								<xsl:if test="$debugging">
									"--------------Debuglocatie-02200 ": {
			                        "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                        },
								</xsl:if>
								<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_embedded&quot;: {' )"/>
								<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
								<xsl:value-of select="'&quot;properties&quot;: {'"/>
		
								<xsl:apply-templates select="ep:seq">
									<xsl:with-param name="typeName" select="$typeName"/>
								</xsl:apply-templates>
								<xsl:value-of select="'}'"/>
								<xsl:value-of select="'}'"/>
								<xsl:if test="$debugging">
									,"-------------Einde-Debuglocatie-02200 ": {
			                        "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                        }
								</xsl:if>
								<xsl:value-of select="','"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="$global-embedded-constructs != ''">
						<xsl:variable name="length" select="string-length($global-embedded-constructs)"/>
						,
						<xsl:choose>
							<xsl:when test="substring($global-embedded-constructs,$length,1) = ','">
								<xsl:variable name="global-embedded-constructs-without-end-comma">
									<xsl:sequence select="substring($global-embedded-constructs,1,$length - 1)"/>
								</xsl:variable>
								<xsl:sequence select="$global-embedded-constructs-without-end-comma"/>							
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="$global-embedded-constructs"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<!-- ROME: Ik twijfel er aan of de volgende if en for-each sowieso ooit afgevuurd zullen worden.
							   In de huidge modellen (19-9-2018)  gebeurd dat i.i.g niet. 
							   Wellicht kunnen ze dus verwijderd worden. -->

					<xsl:variable name="refered-global-constructs">
					<!-- For all global constructs who are refered to from an association construct within a message construct
						 a global embedded version has to be generated. -->
						<xsl:for-each select="ep:message-set/ep:construct
									  [
									    ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
									    and 
									    ep:tech-name = //ep:message
													   [
													     ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
													     and 
													     (
													       ep:parameters/ep:parameter[ep:name='messagetype']/ep:value != 'request' 
													       and 
													       (
													         contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
													         or 
													         contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
													       )
													     )
													   ]
													   //ep:construct
													   [ep:parameters/ep:parameter[ep:name='type']/ep:value='association']/ep:type-name
									  ]">
							<xsl:sort select="ep:tech-name" order="ascending"/>
							<xsl:if test="$debugging">
								"--------------Debuglocatie-02300 ": {
			                    "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                    },
							</xsl:if>
							<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_embedded&quot;: {')"/>
							<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
							<xsl:value-of select="'&quot;properties&quot;: {'"/>
							<xsl:apply-templates select=".//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association') and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embedded"/>
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'}'"/>
							<xsl:if test="$debugging">
								,"--------------Einde-02300 ": {
			                    "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                    }
							</xsl:if>
							<xsl:if test="position() != last()">
								<!-- As long as the current construct isn't the last global constructs 
									(that has at least one association construct) a comma separator as to be 
									generated. -->
								<xsl:value-of select="','"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<!-- If the variable 'refered-global-constructs' has content it's content can be dropped without trailing comma here preceded by a comma separator. -->
					<xsl:if test="$refered-global-constructs != ''">
						<xsl:variable name="length" select="string-length($refered-global-constructs)"/>
						,
						<xsl:choose>
							<xsl:when test="substring($refered-global-constructs,$length,1) = ','">
								<xsl:variable name="refered-global-constructs-without-end-comma">
									<xsl:sequence select="substring($refered-global-constructs,1,$length - 1)"/>
								</xsl:variable>
								<xsl:sequence select="$refered-global-constructs-without-end-comma"/>							
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="$refered-global-constructs"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- If serialisation isn't hal+json no _links en _embedded components have to be generated, only a comma. -->
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<!-- Loop over global constructs which are refered to from other constructs and are 'complex-datatype','groep' or 'table-datatype' constructs.
					 This is only applicable when the serialisation is hal+json.
					 See 'Imvertor-Maven\src\main\resources\xsl\YamlCompiler\documentatie\Explanation query constructions.xlsx' tab 'Query1' for an explanation on this query. -->
				<xsl:variable name="constructs">
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
						(
						(
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						)
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
						) 
						or 
						(
						( 
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
						or 	
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
						) 
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
						)
						)
						and
						(
						ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groep','table-datatype')
						)
						and
						ep:tech-name = //ep:construct/ep:type-name
						and
						not(
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groep'])] 
						and 
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
						and 
						not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
						)
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>
						<!-- Only regular constructs are generated. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-02400 ": {
			                "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                },
						</xsl:if>
						<xsl:variable name="construct">
							<xsl:call-template name="construct"/>
						</xsl:variable>
						<xsl:sequence select="$construct"/>
						<xsl:if test="position() != last() and $construct!=''">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs
								 and the variable $construct isn't empty a comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- If the variable 'constructs' has content it's content can be dropped here preceded by a comma separator. -->
				<xsl:if test="$constructs != ''">
					,<xsl:sequence select='$constructs'/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
				<!-- Loop over global constructs which are refered to from other constructs and are 'complex-datatype','groep' or 'table-datatype' constructs.
					 This is only applicable when the serialisation is json. -->
				<xsl:variable name="constructs">					
					<xsl:for-each select="ep:message-set/ep:construct
						[ 
						(
						(
						(
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						)
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'
						) 
						or 
						(
						( 
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu') 
						or
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
						or 	
						contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
						) 
						and 
						ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
						)
						)
						and
						ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groep','table-datatype')
						and
						ep:tech-name = //ep:construct/ep:type-name
						and
						not(
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groep'])] 
						and 
						ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
						and 
						not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
						)
						]">
						<xsl:sort select="ep:tech-name" order="ascending"/>
						<!-- Only regular constructs are generated. -->
						<xsl:if test="$debugging">
							"--------------Debuglocatie-02500 ": {
			                "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                },
						</xsl:if>
						<xsl:call-template name="construct"/>
						<xsl:if test="position() != last()">
							<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs a 
								 comma separator has to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<!-- If the variable 'constructs' has content it's content can be dropped here preceded by a comma separator. -->
				<xsl:if test="$constructs != ''">
					,<xsl:sequence select='$constructs'/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	
		<!-- Loop over all enumeration constructs. -->
		<xsl:variable name="global-enumeration-constructs">
			<xsl:for-each select="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:enum]">
				<xsl:sort select="ep:tech-name" order="ascending"/>
				<xsl:variable name="type-name" select="ep:type-name"/>
				<!-- An enummeration property is generated. -->
				<xsl:call-template name="enumeration"/>
				<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last enumeration construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="$global-enumeration-constructs != ''">
			<xsl:variable name="length" select="string-length($global-enumeration-constructs)"/>
			,
			<xsl:choose>
				<xsl:when test="substring($global-enumeration-constructs,$length,1) = ','">
					<xsl:variable name="global-enumeration-constructs-without-end-comma">
						<xsl:sequence select="substring($global-enumeration-constructs,1,$length - 1)"/>
					</xsl:variable>
					<xsl:sequence select="$global-enumeration-constructs-without-end-comma"/>						
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$global-enumeration-constructs"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<!-- Loop over all simpletype constructs (local datatypes). -->
		<xsl:variable name="global-simpletype-constructs">
			<xsl:for-each select="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:parameters/ep:parameter[ep:name = 'type']/ep:value = 'simpletype-class']">
				<xsl:sort select="ep:tech-name" order="ascending"/>
				<xsl:variable name="type-name" select="ep:type-name"/>
				<!-- An enummeration property is generated. -->
				<xsl:call-template name="simpletype-class"/>
				<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last enumeration construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="$global-simpletype-constructs != ''">
			<xsl:variable name="length" select="string-length($global-simpletype-constructs)"/>
			,
			<xsl:choose>
				<xsl:when test="substring($global-simpletype-constructs,$length,1) = ','">
					<xsl:variable name="global-simpletype-constructs-without-end-comma">
						<xsl:sequence select="substring($global-simpletype-constructs,1,$length - 1)"/>
					</xsl:variable>
					<xsl:sequence select="$global-simpletype-constructs-without-end-comma"/>						
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$global-simpletype-constructs"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$json-version = '2.0'"/>
			<xsl:when test="$json-version = '3.0'">
				<xsl:value-of select="'}'"/>
			</xsl:when>
		</xsl:choose>

		<xsl:value-of select="'}'"/>
		<xsl:value-of select="'}'"/>
	</xsl:template>
	
	<xsl:template match="ep:seq">
		<xsl:param name="typeName"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-02600 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			},
		</xsl:if>
		<xsl:apply-templates select="ep:choice">
			<xsl:with-param name="typeName" select="$typeName"/>
		</xsl:apply-templates>
		<xsl:if test="$debugging">
			"--------------Debuglocatie-02700 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			},
		</xsl:if>
			<!-- Only for the association constructs properties have to be generated. This is not applicable for supertype-association 
				 constructs. -->
		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<xsl:variable name="indicatorNonIdProperties">
					<xsl:choose>
						<xsl:when test="ep:construct/ep:parameters[(ep:parameter[ep:name='type']/ep:value ='association' or ep:parameter[ep:name='type']/ep:value ='supertype-association') and
													 ep:parameter[ep:name='contains-non-id-attributes']/ep:value ='true']">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="$indicatorNonIdProperties">
					<xsl:if test="ep:choice and ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association']">,</xsl:if>
					<xsl:apply-templates select="ep:construct[ep:parameters[(ep:parameter[ep:name='type']/ep:value ='association' or ep:parameter[ep:name='type']/ep:value ='supertype-association') and
																			ep:parameter[ep:name='contains-non-id-attributes']/ep:value ='true']]" mode="embedded"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
				<xsl:if test="ep:choice and (ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'] or ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'])">,</xsl:if>
				<xsl:apply-templates select="ep:construct[ep:parameters[ep:parameter[ep:name='type']/ep:value ='association' or ep:parameter[ep:name='type']/ep:value ='supertype-association']]" mode="embedded"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ep:choice" mode="subclasscomponent">
		<xsl:for-each select="ep:construct">
			<xsl:variable name="type-name" select="ep:type-name"/>
			<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $type-name]" mode="subclasscomponent"/>
			<xsl:if test="position() != last()">
				<!-- As long as the current construct isn't the last constructs that's refered to from the constructs within the messages 
						 a comma separator has to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="ep:choice" mode="superclasscomponent">
		<xsl:variable name="types">
			<ep:types>
				<xsl:for-each select="ep:construct">
					<xsl:sort select="ep:type-name" order="ascending"/>
					<xsl:variable name="type" select="ep:type-name"/>
					<xsl:if test="not(preceding-sibling::ep:construct/ep:type-name = $type)">
						<ep:type-name><xsl:value-of select="ep:type-name"/></ep:type-name><xsl:text>
						</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</ep:types>
		</xsl:variable>
		<xsl:variable name="supertypes">
			<ep:supertypes>
				<xsl:for-each select="$types//ep:type-name">
					<xsl:variable name="type-name" select="."/>
					<xsl:for-each select="$message-sets//ep:construct[ep:tech-name = $type-name]//ep:construct[ep:ref]">
						<ep:type-name><xsl:value-of select="ep:ref"/></ep:type-name>
					</xsl:for-each>
				</xsl:for-each>
			</ep:supertypes>
		</xsl:variable>
		<xsl:variable name="uniqueSupertypes">
			<ep:supertypes>
				<xsl:for-each select="$supertypes//ep:type-name">
					<xsl:variable name="type-name" select="."/>
					<xsl:if test="not(preceding::ep:type-name[. = $type-name])">
						<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>					
					</xsl:if>
				</xsl:for-each>
			</ep:supertypes>
		</xsl:variable>
		<xsl:if test="$uniqueSupertypes//ep:type-name">,</xsl:if>
		<xsl:for-each select="$uniqueSupertypes//ep:type-name">
			<xsl:sort select="." order="ascending"/>
			<xsl:variable name="type-name" select="."/>
			<xsl:apply-templates select="$message-sets//ep:construct[ep:tech-name = $type-name and parent::ep:message-set]" mode="superclasscomponent"/>
			<xsl:if test="position() != last()">
				<!-- As long as the current construct isn't the last construct that's refered to from the constructs within the messages 
					 a comma separator has to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="superclasscomponent">
		
		<xsl:call-template name="construct"/>
		
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="subclasscomponent">
		<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
		
		<xsl:sequence select="imf:createHalComponent($elementName,.)"/>

		<xsl:call-template name="construct"/>
		
	</xsl:template>
	
	<xsl:function name="imf:createHalComponent">
		<xsl:param name="elementName"/>
		<xsl:param name="contextItem"/>

		<xsl:value-of select="concat('&quot;', $elementName,'Hal&quot;: {' )"/>
		<xsl:value-of select="'&quot;allOf&quot;: ['"/>
		<xsl:value-of select="concat('{&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'&quot;},')"/>
		<xsl:value-of select="'{'"/>
		<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;'"/>
		
		<xsl:variable name="allContextItems">
			<xsl:for-each select="$contextItem">
				<xsl:call-template name="construct">
					<xsl:with-param name="mode" select="'onlyLinksAndEmbedded'"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:if test="not($allContextItems='')">
			<xsl:value-of select="',&quot;properties&quot;: {'"/>
			<xsl:sequence select="$allContextItems"/>
			<xsl:value-of select="'}'"/>
		</xsl:if>
		
		
		<xsl:value-of select="'}'"/>
		<xsl:value-of select="']'"/>
		<xsl:value-of select="'},'"/>
		
	</xsl:function>
	
	<xsl:template match="ep:choice">
			<xsl:param name="typeName"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-02800 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			},
		</xsl:if>

			<xsl:variable name="firstChoice" select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
										 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name][1]"/>
			<xsl:variable name="elementName">
				<xsl:choose>
					<xsl:when test="not(empty($firstChoice/ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value))">
						<xsl:value-of select="$firstChoice/ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
					</xsl:when>
					<xsl:when test="not(empty($firstChoice/ep:parameters/ep:parameter[ep:name='targetrole']/ep:value))">
						<xsl:value-of select="$firstChoice/ep:parameters/ep:parameter[ep:name='targetrole']/ep:value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="translate($firstChoice/ep:tech-name,'.','_')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="maxOccurs" select="$firstChoice/ep:max-occurs"/>
			<xsl:variable name="minOccurs" select="$firstChoice/ep:min-occurs"/>
			<xsl:variable name="occurence-type">
				<xsl:choose>
					<xsl:when test="$maxOccurs = 'unbounded' or $maxOccurs > 1">array</xsl:when>
					<xsl:otherwise>object</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="typeName" select="$firstChoice/ep:type-name"/>
			
			<xsl:if test="$serialisation = 'json'">,</xsl:if>
			
			<xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>	
			<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
			<xsl:variable name="documentation">
				<xsl:apply-templates select="$firstChoice/ep:documentation"/>
			</xsl:variable>
			<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
			<xsl:sequence select="$documentation"/>
			<xsl:value-of select="'&quot;,'"/>
			<xsl:if test="$occurence-type = 'array'">
				<xsl:if test="$maxOccurs != 'unbounded'">
					<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
				</xsl:if>
				<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
					<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
				</xsl:if>
			</xsl:if>
			<xsl:choose>
				<!-- Depending on the occurence-type and the type of construct content is generated. -->
				<xsl:when test="$serialisation = 'json'">
					<xsl:value-of select="'&quot;enum&quot;: [&quot;string&quot;]'"/>
				</xsl:when>
				<xsl:when test="$serialisation = 'hal+json'">
					<xsl:choose>
						<xsl:when test="$occurence-type = 'array'">
							<xsl:value-of select="'&quot;items&quot;: {'"/>
							<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
							<xsl:choose>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
									<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
								</xsl:when>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
									<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="']'"/>
							<xsl:value-of select="'}'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
							<xsl:choose>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
									<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
								</xsl:when>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
									<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="']'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="'}'"/>
			<xsl:if test="following-sibling::ep:choice">
				<!-- As long as the current construct isn't the last global constructs (that has at least one association construct) a comma separator as 
					 to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
	</xsl:template>

	<xsl:template name="construct">
		<xsl:param name="mode" select="'all'"/>
		<xsl:param name="grouping" select="''"/>
		
		<!-- With this template global properties are generated.  -->
		
		<xsl:choose>
			<xsl:when test="ep:parameters/ep:parameter[ep:name = 'type' and ep:value = 'association'] and ep:choice">
				<xsl:apply-templates select="ep:choice" mode="subclasscomponent"/>
				<xsl:apply-templates select="ep:choice" mode="superclasscomponent"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="tech-name" select="ep:tech-name"/>
				<xsl:variable name="elementName" select="translate($tech-name,'.','_')"/>
				<xsl:variable name="expand" select="ep:parameters/ep:parameter[ep:name='expand']/ep:value"/>
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<xsl:variable name="requiredproperties" as="xs:boolean">
					<!-- The variable requiredproperties confirms if at least one of the properties of the current construct is required. -->
					<xsl:choose>
						<xsl:when test="$serialisation='hal+json' and ep:seq/ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value != 'association' or empty(ep:parameters/ep:parameter[ep:name='type']/ep:value)) and not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:when test="$serialisation='json' and ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="reference2links">
					<xsl:if test="$serialisation = 'hal+json' and
						(
						empty(ep:parameters/ep:parameter[ep:name='abstract']) or 
						ep:parameters/ep:parameter[ep:name='abstract']/ep:value = 'false'
						) and 
						ep:parameters/ep:parameter[ep:name='type']/ep:value != 'complex-datatype' and 
						ep:parameters/ep:parameter[ep:name='type']/ep:value != 'table-datatype' and 
						ep:parameters/ep:parameter[ep:name='type']/ep:value != 'groep' and
						not(./ep:parameters/ep:parameter[ep:name='endpointavailable']/ep:value='Nee')">
						<!-- If the current construct:
						 * isn't abstract
						 * isn't of type 'complex-datatype', table-datatype' and groupsÇompositie'
						 a _links component variant of the current construct has to be generated.
						 In that case a reference to such a componenttype is generated at this place. -->
						<xsl:value-of select="'&quot;_links&quot;: {'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_links&quot;}')"/>
					</xsl:if>
				</xsl:variable>
				<!-- Now all constructs being an association has to be processed. How depends on the serialisation. -->
				<xsl:variable name="associationProperties">
					<xsl:choose>
						<xsl:when test="$serialisation = 'hal+json'">
							<!-- The reference to the embedded component must only be generated when the related embedded component is generated. That is only the case if that component has content.
							 That is determined here. For now this is only determined for one _embedded level. If this must be determined for more levels or even recursive a more thorough solution has to be implemented. -->
							<xsl:variable name="contentRelatedEmbeddedConstruct">
								<xsl:variable name="relatedGlobalConstruct">
									<xsl:copy-of select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$elementName]"/>
								</xsl:variable>
								<xsl:variable name="typeName" select="$relatedGlobalConstruct/ep:type-name"/>
								<xsl:apply-templates select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$elementName]/ep:seq">
									<xsl:with-param name="typeName" select="$typeName"/>
								</xsl:apply-templates>
							</xsl:variable>
							
							<xsl:if test=".[ep:parameters/ep:parameter[ep:name='type']/ep:value!='complex-datatype' and 
								ep:parameters/ep:parameter[ep:name='type']/ep:value!='table-datatype' and 
								ep:parameters/ep:parameter[ep:name='type']/ep:value!='groep']
								//ep:construct
								[(ep:parameters/ep:parameter[ep:name='type']/ep:value='association' or
								ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association') and 
								ep:parameters/ep:parameter[ep:name='contains-non-id-attributes']/ep:value = 'true'] and 
								contains($contentRelatedEmbeddedConstruct,'{')">
								<!-- When expand applies in the interface also an embedded variant of the current construct has to be generated..
								 At this place only a reference to such a componenttype is generated. -->
								<xsl:value-of select="'&quot;_embedded&quot;: {'"/>
								<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_embedded&quot;}')"/>
							</xsl:if>
						</xsl:when>
						<xsl:when test="$serialisation = 'json'">
							<xsl:if test=".[ep:parameters/ep:parameter[ep:name='type']/ep:value!='complex-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value!='table-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value!='groep']//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value='association' 
								or ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association')]">
								<xsl:variable name="typeName" select="ep:type-name"/>
								<xsl:apply-templates select="ep:seq">
									<xsl:with-param name="typeName" select="$typeName"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="properties">
					<xsl:value-of select="',&quot;properties&quot;: {'"/>
					<!-- Loop over all constructs within the current construct (that don't have association type, supertype-association type and superclass type constructs) 
				 within the current construct. -->
					<xsl:variable name="attribuutProperties">
						<xsl:for-each select="ep:seq/ep:construct[
							not(ep:seq) and 
							not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association') and 
							not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'supertype-association') and 
							not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'superclass') and 
							not(ep:ref)]">
							<xsl:sort select="ep:tech-name" order="ascending"/>
							<xsl:call-template name="property"/>
							<xsl:if test="(position() != last())">
								<!-- As long as the current construct isn't the last non association type construct a comma separator has to be generated. -->
								<xsl:value-of select="','"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					
					<xsl:if test="$attribuutProperties != ''">
						<xsl:sequence select="$attribuutProperties"/>
					</xsl:if>
					<xsl:if test="$attribuutProperties != '' and ($reference2links != '' or $associationProperties != '') and $serialisation = 'json'">
						<xsl:value-of select="','"/>
					</xsl:if>
					<xsl:if test="$reference2links != '' and $serialisation = 'json'">
						<xsl:sequence select="$reference2links"/>
					</xsl:if>
					<xsl:if test="$reference2links != '' and $associationProperties != '' and $serialisation = 'json'">
						<xsl:value-of select="','"/>
					</xsl:if>
					<xsl:if test="$associationProperties != '' and $serialisation = 'json'">
						<xsl:if test="$debugging">
							"--------------Debuglocatie-02900 ": {
			                "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                },
						</xsl:if>
						<xsl:sequence select="$associationProperties"/>
					</xsl:if>
					
					
					<xsl:value-of select="'}'"/>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$mode = 'onlyLinksAndEmbedded'">
						<xsl:if test="$debugging">
							"--------------Debuglocatie-03000 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							}
						</xsl:if>
						<xsl:if test="($debugging and $reference2links != '') or ($debugging and $associationProperties != '')">
							,
						</xsl:if>
						<xsl:if test="$reference2links != ''">
							<xsl:sequence select="$reference2links"/>
						</xsl:if>
						<xsl:if test="$reference2links != '' and $associationProperties != ''">
							<xsl:value-of select="','"/>
						</xsl:if>
						<xsl:if test="$associationProperties != ''">
							<xsl:if test="$debugging">
								"--------------Debuglocatie-03100 ": {
			                	"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                	},
							</xsl:if>
							<xsl:sequence select="$associationProperties"/>
						</xsl:if>
					</xsl:when>
					<!-- TODO: Volgende when moet vanuit een configuratie aan te sturen zijn. -->
					<xsl:when test="$elementName = 'Datum_onvolledig'">
						<xsl:if test="$debugging">
							"--------------Debuglocatie-03020 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							}
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$debugging">
							"--------------Debuglocatie-03040 ": {
							"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
							},
						</xsl:if>
						<xsl:if test="$grouping != 'resource'">
							<!-- RM: Bepalen waarom dit noodzakelijk is. Ik twijfel er niet aan dat het nodig is maar ik wil weten waarom zodat ik het kan documenteren. -->
							<xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
						</xsl:if>
						<xsl:if test="ep:seq/ep:construct[ep:ref]">
							<!-- If the current construct has a construct with a ref (it has a supertype) an 'allOf' is generated. -->
							<xsl:variable name="ref" select="ep:seq/ep:construct/ep:ref"/>
							<xsl:value-of select="'&quot;allOf&quot;: ['"/>
							<xsl:value-of select="concat('{&quot;$ref&quot;: &quot;',$json-topstructure,'/',$ref,'&quot;},')"/>
							<xsl:value-of select="'{'"/>
						</xsl:if>
						<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<xsl:sequence select="$documentation"/>
						<xsl:value-of select="'&quot;'"/>
						<xsl:if test="$requiredproperties">
							<!-- Only if the variable requiredproperties is true a 'required' section has to be generated. -->
							<xsl:value-of select="',&quot;required&quot;: ['"/>
							<xsl:choose>
								<xsl:when test="$serialisation='hal+json'">
									<xsl:for-each select="ep:seq/ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value != 'association' or empty(ep:parameters/ep:parameter[ep:name='type']/ep:value)) and not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
										<xsl:sort select="ep:tech-name" order="ascending"/>
										<!-- Loops over required constructs, which are required, are no associations and have no ep:seq. -->
										<xsl:value-of select="'&quot;'"/>
										<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
										<xsl:value-of select="'&quot;'"/>
										<xsl:if test="position() != last()">
											<!-- As long as the current construct isn't the last required construct a comma separator has to be generated. -->
											<xsl:value-of select="','"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$serialisation='json'">
									<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
										<xsl:sort select="ep:tech-name" order="ascending"/>
										<!-- Loops over constructs, which are required, are no associations and have no ep:seq. -->
										<xsl:value-of select="'&quot;'"/>
										<xsl:choose>
											<xsl:when test="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']">
												<xsl:value-of select="translate(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value,'.','_')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="'&quot;'"/>
										<xsl:if test="position() != last()">
											<!-- As long as the current construct isn't the last required construct a comma separator has to be generated. -->
											<xsl:value-of select="','"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="']'"/>
						</xsl:if>
						<xsl:if test="$properties != ',&quot;properties&quot;: {}'">
							<xsl:sequence select="$properties"/>
						</xsl:if>
						<xsl:if test="ep:seq/ep:construct[ep:ref]">
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="']'"/>
						</xsl:if>
						<xsl:if test="$grouping != 'resource'">
							<xsl:value-of select="'}'"/>
							<xsl:if test="$debugging">
								,"--------------Debuglocatie-03200 ": {
			                	"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			                	}
							</xsl:if>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="enumeration">
		<!-- Enummeration constructs are processed here. -->
		<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
		<xsl:if test="$debugging">
			"--------------Debuglocatie-03300 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			},
		</xsl:if>
		<xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
		<xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>

		<xsl:variable name="enumeration-documentation">
			<xsl:value-of select="'&quot;description&quot; : &quot;'"/>
			<xsl:if test="ep:documentation">
				<xsl:apply-templates select="ep:documentation"/>
			</xsl:if>
			<xsl:choose>
				<!-- If the content of all ep:name elements is equal to their sibbling ep:alias elements no further documentation is generated. -->
				<xsl:when test="count(ep:enum[ep:name=ep:alias])=count(ep:enum)"/>
				<xsl:when test="//ep:p/@format = 'markdown'">
					<xsl:text>&lt;body&gt;&lt;ul&gt;</xsl:text>
						<xsl:for-each select="ep:enum">
							<xsl:text>&lt;li&gt;</xsl:text><xsl:value-of select="concat('`',ep:alias,'` - ',ep:name)"/><xsl:text>&lt;/li&gt;</xsl:text>
						</xsl:for-each>
					<xsl:text>&lt;/ul&gt;&lt;/body&gt;</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<!--xsl:text>:</xsl:text-->
					<xsl:for-each select="ep:enum">
						<xsl:value-of select="concat('\n* `',ep:alias,'` - ',ep:name)"/>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="'&quot;,'"/>
		</xsl:variable>
		<xsl:sequence select="$enumeration-documentation"/>

		<xsl:value-of select="'&quot;enum&quot;: ['"/>
		<xsl:for-each select="ep:enum">
			<!-- Loop over all enum elements. -->
			<xsl:value-of select="concat('&quot;',ep:alias,'&quot;')"/>
			<xsl:if test="position() != last()">
				<!-- As long as the current construct isn't the last construct a comma separator has to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:value-of select="']'"/>
		<xsl:value-of select="'}'"/>
		<xsl:if test="$debugging">
			,"--------------Debuglocatie-03400 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			}
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template name="simpletype-class">
		<!-- simpletype-class constructs are processed here. -->
		<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
		<xsl:variable name="derivedPropertyContent">
			<xsl:call-template name="derivePropertyContent">
				<xsl:with-param name="typeName" select="''"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-03430 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			},
		</xsl:if>
		<xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
		<xsl:value-of select="$derivedPropertyContent"/>		
		<xsl:value-of select="'}'"/>
		<xsl:if test="$debugging">
			,"--------------Debuglocatie-03460 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			}
		</xsl:if>
	</xsl:template>
	

	<!-- TODO: Het onderstaande template en ook de aanroep daarvan zijn is op dit moment onnodig omdat we er nu vanuit gaan dat als er hal+json gegenereerd 
			   moet worden er ook in de gehele standaard hal+json gegenereerd moet worden.
			   Alleen als we later besluiten dat er ook af en toe geen json_hal gegenereerd moet worden kan deze if weer opportuun worden. 
			   Voor nu is het template uitgeschakeld. -->
	<!-- A HAL type is generated here. -->
	<?x <xsl:template name="construct_jsonHAL">
        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-03500 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			},
		</xsl:if>
 
        <xsl:value-of select="concat('&quot;', $elementName,'_HAL&quot;: {' )"/>
		<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>

        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:variable name="documentation">
			<!--xsl:value-of select="ep:documentation//ep:p"/-->
			<xsl:apply-templates select="ep:documentation"/>
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
			"--------------Debuglocatie-00500 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			},
		</xsl:if>-->

		<!-- All constructs (that don't have association type constructs) within the current construct are processed here. -->
		<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association')]">
			<xsl:variable name="name" select="substring-after(ep:type-name, ':')"/>

<!--			<xsl:if test="$debugging">
				"--------------Debuglocatie-00600 ": {
			    "XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			    },
			</xsl:if>
-->
			<xsl:call-template name="property"/>

			<!-- As long as the current construct isn't the last non association type construct a comma separator has to be generated. -->
			<xsl:if test="(position() != last()) and following-sibling::ep:construct[not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association')]">
				<xsl:value-of select="','"/> 
			</xsl:if>
		</xsl:for-each>
		

		<!-- If the construct has association constructs a reference to a '_links' property is generated based on the same elementname. -->
		<xsl:if test=".//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='association']">
			<xsl:value-of select="','"/>
			<xsl:value-of select="'&quot;properties&quot;: {'"/>
			<xsl:if test="not(./ep:parameters/ep:parameter[ep:name='endpointavailable']/ep:value='Nee')">
				<xsl:value-of select="'&quot;_links&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_links&quot;}')"/>
			</xsl:if>	
			<!-- When the construct also had attributes which are not id-type attributes in the interface also an embedded version has to be generated.
				 At this place only a reference to such a type is generated. -->
			<xsl:if test="$contains-non-id-attributes">
				<xsl:value-of select="',&quot;_embedded&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_embedded&quot;}')"/>
			</xsl:if>
			<xsl:value-of select="'}'"/>
		</xsl:if>

		<xsl:value-of select="'}'"/>
		<xsl:value-of select="'}'"/>

		<xsl:if test="$debugging">
			,"--------------Debuglocatie-03600 ": {
			"XPath": "<xsl:sequence select="imf:xpath-string(.)"/>"
			}
		</xsl:if>
   </xsl:template> ?>
   
	<xsl:template name="property">
		<!-- The properties representing an uml attribute are generated here.
			 To be able to do that it uses the derivePropertyContent template which on its turn uses the deriveDataType, deriveFormat and deriveFacets 
			 templates. -->
		<xsl:choose>
			<xsl:when test="ep:outside-ref='VNGR'">
				<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'&quot;: {' )"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-gemeente-components-url,ep:type-name,'&quot;')"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="derivedPropertyContent">
					<xsl:call-template name="derivePropertyContent">
						<xsl:with-param name="typeName" select="ep:type-name"/>
					</xsl:call-template>
				</xsl:variable>
				<!-- The following if only applies if the current construct has an ep:type-name or a ep:data-type and if it isn't an association type construct
			 or if it is a gml type. -->
				<xsl:if test="((exists(ep:type-name) or exists(ep:data-type)) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value='association') or ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external')">
					<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'&quot;: {' )"/>
					<xsl:value-of select="$derivedPropertyContent"/>
					<xsl:value-of select="'}'"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="derivePropertyContent">
		<!-- This template builds the content of the properties representing an uml attribute. -->
		<xsl:param name="typeName"/>
		<xsl:param name="typePrefix"/>
		<xsl:choose>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external' and not(ep:data-type)">
				<!-- If the property is a gml type this when applies. In all these case a standard content (except the documentation)
					 is generated. -->
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-geojson-components-url,'GeoJSONGeometry&quot;')"/>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external'">
				<!-- If the property is a gml type this when applies. In all these case a standard content (except the documentation)
					 is generated. -->
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-geojson-components-url,ep:data-type,'&quot;')"/>
			</xsl:when>
			<xsl:when test="ep:type-name = 'Datum_onvolledig'">
				<!-- If the property is a Datum_onvolledig type this when applies. In all these case a standard content (except the documentation)
					 is generated. -->
				<xsl:value-of select="'&quot;allOff&quot;: ['"/>
				<xsl:value-of select="'{'"/>
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
				<xsl:sequence select="$documentation"/>
				<xsl:value-of select="'&quot;,'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'Datum_onvolledig&quot;')"/>
				<xsl:value-of select="'}'"/>
				<xsl:value-of select="']'"/>
			</xsl:when>
			<xsl:when test="exists(ep:data-type) and (ep:max-occurs = 'unbounded' or ep:max-occurs > 1)">
				<!-- If the construct has a ep:data-type element, a description, an optional format and, also optional, some facets have to be generated. -->
				<xsl:variable name="datatype">
					<xsl:call-template name="deriveDataType">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="lower-case(ep:data-type)"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="format">
					<xsl:call-template name="deriveFormat">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="lower-case(ep:data-type)"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="facets">
					<xsl:call-template name="deriveFacets">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="lower-case(ep:data-type)"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="example">
					<xsl:call-template name="deriveExample">
						<xsl:with-param name="datatype" select="$datatype"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>
				<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value,'&quot;')"/>
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<xsl:value-of select="',&quot;description&quot;: &quot;'"/>
				<xsl:sequence select="$documentation"/>
				<xsl:value-of select="'&quot;'"/>
				<xsl:if test="ep:min-occurs">
					<xsl:value-of select="concat(',&quot;minItems&quot;: ',ep:min-occurs,',')"/>
				</xsl:if>
				<xsl:if test="ep:max-occurs != 'unbounded'">
					<xsl:value-of select="concat(',&quot;maxItems&quot;: ',ep:max-occurs,',')"/>
				</xsl:if>
				<xsl:value-of select="'&quot;items&quot;: {'"/>
				<xsl:value-of select="concat('&quot;type&quot;: &quot;',$datatype,'&quot;')"/>
				<xsl:value-of select="$format"/>
				<xsl:value-of select="$facets"/>
				<xsl:value-of select="$example"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
			<xsl:when test="exists(ep:data-type)">
				<!-- If the construct has a ep:data-type element, a description, an optional format and, also optional, some facets have to be generated. -->
				<xsl:variable name="datatype">
					<xsl:call-template name="deriveDataType">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="lower-case(ep:data-type)"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="format">
					<xsl:call-template name="deriveFormat">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="lower-case(ep:data-type)"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="facets">
					<xsl:call-template name="deriveFacets">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="lower-case(ep:data-type)"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="example">
					<xsl:call-template name="deriveExample">
						<xsl:with-param name="datatype" select="$datatype"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat('&quot;type&quot;: &quot;',$datatype,'&quot;')"/>
				<xsl:if test="ep:parameters/ep:parameter[ep:name='SIM-name']">
					<xsl:value-of select="concat(',&quot;title&quot;: &quot;',ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value,'&quot;')"/>					
				</xsl:if>
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<xsl:value-of select="',&quot;description&quot;: &quot;'"/>
				<xsl:sequence select="$documentation"/>
				<xsl:value-of select="'&quot;'"/>
				<xsl:value-of select="$format"/>
				<xsl:value-of select="$facets"/>
				<xsl:value-of select="$example"/>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'table-datatype' and exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name)">
				<!-- If the current construct [A] refers to an existing tableconstruct [B] by its typename and the tableconstruct has a type-name on its turn
					 an allOf with a $ref to the construct B using the B-type-name and a title and description has to be generated. -->
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<xsl:value-of select="'&quot;allOf&quot;: [ {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', /ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name, '&quot;')"/>
				<xsl:value-of select="'}, {'"/>
				<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:name,'&quot;,')"/>
				<xsl:value-of select="concat('&quot;description&quot;: &quot;',$documentation,'&quot;')"/>
				<xsl:value-of select="'&quot;allOf&quot;: ] }'"/>
			</xsl:when>
			<xsl:when test="exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name)">
				<!-- If the current construct [A] refers to an existing other construct [B] by its typename and that construct has a type-name on its turn
					 a $ref to the construct B has to be generated using the B-type-name. -->
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', /ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name, '&quot;')"/>
			</xsl:when>
			<!-- In all othert cases a $ref to the type-name of the current construct has to be generated. -->
			<xsl:when test="ep:max-occurs = 'unbounded' or ep:max-occurs > 1">
				<xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>
				<xsl:value-of select="'&quot;items&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', $typeName, '&quot;')"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
			<xsl:when test="$typeName = 'NEN3610ID'">
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'Nen3610Id&quot;')"/>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'table-datatype'">
				<!-- If the current construct is an tableconstruct an allOf with a $ref, a title and description has to be generated. -->
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<xsl:value-of select="'&quot;allOf&quot;: [ {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', $typeName, '&quot;')"/>
				<xsl:value-of select="'}, {'"/>
				<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:name,'&quot;,')"/>
				<xsl:value-of select="concat('&quot;description&quot;: &quot;',$documentation,'&quot;')"/>
				<xsl:value-of select="'} ]'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', $typeName, '&quot;')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveDataType">
		<xsl:param name="incomingType"/>
		<xsl:choose>
			<!-- Each type resolves to a type 'string', 'integer', 'number' or 'boolean'. -->
			<xsl:when test="$incomingType = 'boolean'">
				<xsl:value-of select="'boolean'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'string'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'date'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'datetime'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'day'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'decimal'">
				<xsl:value-of select="'number'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'integer'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'month'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'real'">
				<xsl:value-of select="'number'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'uri'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'string'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveFormat">
		<xsl:param name="incomingType"/>
		<xsl:choose>
			<!-- Some types resolve to a format and/or pattern. -->
			<xsl:when test="$incomingType = 'date'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date_fullyear&quot;'"/>
			</xsl:when>
<!--			<xsl:when test="$incomingType = 'yearmonth'">
				<xsl:value-of select="',&quot;format&quot;: &quot;jaarmaand&quot;'"/>
			</xsl:when> -->
			<xsl:when test="$incomingType = 'month'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date_month&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'day'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date_mday&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'datetime'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date-time&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'uri'">
				<xsl:value-of select="',&quot;format&quot;: &quot;uri&quot;'"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveFacets">
		<xsl:param name="incomingType"/>
		<xsl:choose>
			<!-- Some types can have one or more facets which restrict the allowed value. -->
			<xsl:when test="$incomingType = 'string'">
				<xsl:if test="ep:pattern and $json-version != '2.0'">
					<xsl:value-of select="concat(',&quot;pattern&quot;: &quot;^',ep:pattern,'$&quot;')"/>
				</xsl:if>
				<xsl:if test="ep:max-length">
					<xsl:value-of select="concat(',&quot;maxLength&quot;: ',ep:max-length)"/>
				</xsl:if>
				<xsl:if test="ep:min-length and empty(ep:pattern)">
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
			<xsl:when test="$incomingType = 'real'">
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
			<xsl:when test="$incomingType = 'year'">
				<xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-2]{1}[0-9]{3}$&quot;'"/>
				</xsl:if>
			</xsl:when>
<!--			<xsl:when test="$incomingType = 'yearmonth'">
				<xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-2]{1}[0-9]{3}-^[0-1]{1}[0-9]{1}$&quot;'"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$incomingType = 'postcode'">
				<xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-9]{1}[0-9]{3}[A-Z]{2}$&quot;'"/>
				</xsl:if>
			</xsl:when> -->
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveExample">
		<xsl:param name="datatype" select="'string'"/>
		<xsl:choose>
			<!-- Some types can have one or more facets which restrict the allowed value. -->
			<xsl:when test="ep:example != '' and $datatype = 'integer'">
				<xsl:value-of select="concat(',&quot;example&quot;: ',ep:example)"/>
			</xsl:when>
			<xsl:when test="ep:example != '' and $datatype = 'real'">
				<xsl:value-of select="concat(',&quot;example&quot;: ',ep:example)"/>
			</xsl:when>
			<xsl:when test="ep:example != '' and $datatype = 'decimal'">
				<xsl:value-of select="concat(',&quot;example&quot;: ',ep:example)"/>
			</xsl:when>
			<xsl:when test="ep:example != ''">
				<xsl:value-of select="concat(',&quot;example&quot;: &quot;',ep:example,'&quot;')"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="_links">
		<!-- This template generates for each association a links properties with a reference to a link type. -->
		<xsl:variable name="type-name" select="ep:type-name"/>
		<ep:construct2bprocessed>
			<xsl:if test="not(//ep:construct[ep:tech-name = $type-name]/ep:parameters/ep:parameter[ep:name='endpointavailable' and ep:value='Nee'])">
				<xsl:variable name="elementName">
					<xsl:choose>
						<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value))">
							<xsl:value-of select="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
						</xsl:when>
						<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='targetrole']/ep:value))">
							<xsl:value-of select="ep:parameters/ep:parameter[ep:name='targetrole']/ep:value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="maxOccurs" select="ep:max-occurs"/>
				<xsl:variable name="minOccurs" select="ep:min-occurs"/>
				<xsl:variable name="occurence-type">
					<xsl:choose>
						<xsl:when test="$maxOccurs = 'unbounded' or $maxOccurs > 1">array</xsl:when>
						<xsl:otherwise>object</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
					<xsl:if test="$debugging">
						<xsl:value-of select="ep:name"/>
					</xsl:if>
					<xsl:if test="parent::ep:choice">
						<xsl:text>\nLink naar een van de volgende mogelijke typen </xsl:text><xsl:value-of select="$elementName"/><xsl:text>:</xsl:text>
						<xsl:for-each select="../ep:construct">
							<xsl:text>\n* </xsl:text><xsl:value-of select="ep:type-name"/>
						</xsl:for-each>
					</xsl:if>
				</xsl:variable>
				<xsl:variable name="titleTypeAndDescriptionContent">
					<!-- ROME: Deze toevoeging (nav #490159) geeft een warning in Swaggerhub. -->
					<xsl:if test="empty(parent::ep:choice)">
						<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:name,'&quot;,')"/>
					</xsl:if>
					<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
					<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
					<xsl:sequence select="$documentation"/>
					<xsl:value-of select="'&quot;'"/>
				</xsl:variable>
		
				<xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>
				<xsl:choose>
					<!-- Depending on the occurence-type and the type of construct content is generated. -->
					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
						<xsl:sequence select="concat($titleTypeAndDescriptionContent,',')"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'HalLink&quot;')"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
						<xsl:value-of select="'&quot;allOf&quot;: ['"/>
						<xsl:value-of select="'{'"/>
						<xsl:sequence select="$titleTypeAndDescriptionContent"/>
						<xsl:value-of select="'},{'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'HalLink&quot;')"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="']'"/>
					</xsl:when>
					<!--xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:sequence select="concat($titleTypeAndDescriptionContent,',')"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
						<xsl:value-of select="'&quot;description&quot;: &quot;uri van een van de volgende mogelijke typen ',$elementName,': '"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $type-name]" mode="supertype-association-in-links">
							<xsl:sort select="ep:tech-name" order="ascending"/>
						</xsl:apply-templates>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:value-of select="'&quot;properties&quot;: {'"/>
						<xsl:value-of select="'&quot;href&quot;: {'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'Href&quot;')"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
					</xsl:when-->
					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:sequence select="concat($titleTypeAndDescriptionContent,',')"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="'&quot;allOf&quot;: ['"/>
						<xsl:value-of select="'{'"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
						<xsl:value-of select="'&quot;description&quot;: &quot;uri van een van de volgende mogelijke typen ',$elementName,': '"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $type-name]" mode="supertype-association-in-links">
							<xsl:sort select="ep:tech-name" order="ascending"/>
						</xsl:apply-templates>
						<xsl:value-of select="'&quot;'"/>
						<xsl:value-of select="'},{'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'HalLink&quot;')"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="']'"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;allOf&quot;: ['"/>
						<xsl:value-of select="'{'"/>
						<xsl:sequence select="$titleTypeAndDescriptionContent"/>
						<xsl:value-of select="'},{'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$standard-json-components-url,'HalLink&quot;')"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="']'"/>
					</xsl:when>
				</xsl:choose>
				<xsl:value-of select="'}'"/>
	<?x			<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if> ?>
			</xsl:if>
		</ep:construct2bprocessed>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="supertype-association-in-links">
		<xsl:apply-templates select="ep:choice" mode="supertype-association-in-links"/>
	</xsl:template>
	
	<xsl:template match="ep:choice" mode="supertype-association-in-links">
		<xsl:apply-templates select="//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']" mode="subclass">
			<xsl:sort select="ep:tech-name" order="ascending"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="subclass">
		<xsl:value-of select="concat('* ',ep:type-name)"/>
		<xsl:if test="position() != last()">
			<xsl:value-of select="' '"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="embedded">
		<!-- This template generates for each association an embedded properties with a reference to an embedded type. -->
		<xsl:variable name="typeName" select="ep:type-name"/>
		<xsl:variable name="sourceName">
			<xsl:for-each select="//ep:construct[ep:tech-name = $typeName]">
				<xsl:value-of select="ep:parameters/ep:parameter[ep:name = 'meervoudigeNaam']/ep:value"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value))">
					<xsl:value-of select="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
				</xsl:when>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='targetrole']/ep:value))">
					<xsl:value-of select="ep:parameters/ep:parameter[ep:name='targetrole']/ep:value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="maxOccurs" select="ep:max-occurs"/>
		<xsl:variable name="minOccurs" select="ep:min-occurs"/>
		<xsl:variable name="occurence-type">
			<xsl:choose>
				<xsl:when test="$maxOccurs = 'unbounded' or $maxOccurs > 1">array</xsl:when>
				<xsl:otherwise>object</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="title">
			<xsl:choose>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value))">
					<xsl:value-of select="ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ep:name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>
		<xsl:variable name="documentation">
			<xsl:apply-templates select="ep:documentation"/>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
		
				<!-- ROME: Deze toevoeging (nav #490159) geeft een warning in Swaggerhub. -->
				<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
					<xsl:value-of select="concat('&quot;title&quot;: &quot;',$title,'&quot;,')"/>
					<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
				</xsl:if>
				
				<xsl:choose>
					<!-- Depending on the occurence-type and the type of construct content is generated. -->
					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<xsl:sequence select="$documentation"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'Hal&quot;')"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'Hal&quot;')"/>
					</xsl:when>
					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<xsl:sequence select="$documentation"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded">
							<xsl:sort select="ep:tech-name" order="ascending"/>
						</xsl:apply-templates>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<xsl:sequence select="$documentation"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded">
							<xsl:sort select="ep:tech-name" order="ascending"/>
						</xsl:apply-templates>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
		
				<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
					<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
				</xsl:if>

				<!--<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">-->
					<xsl:value-of select="concat('&quot;title&quot;: &quot;',$title,'&quot;,')"/>
				<!--</xsl:if>-->
				
				<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
				<!-- Double quotes in documentation text is replaced by a  grave accent. -->
				<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
				<xsl:value-of select="'&quot;,'"/>
				
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<xsl:choose>
					<!-- Depending on the occurence-type and the type of construct content is generated. -->
					<xsl:when test="$occurence-type = 'array' and (ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')">
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
						<xsl:value-of select="'&quot;format&quot;: &quot;uri&quot;'"/>
						<xsl:value-of select="'},'"/>
						<xsl:value-of select="'&quot;readOnly&quot;: true,'"/>
						<xsl:value-of select="'&quot;uniqueItems&quot;: true,'"/>
						<xsl:value-of select="concat('&quot;example&quot;: &quot;datapunt.voorbeeldgemeente.nl/api/v1/',$sourceName,'/123456789&quot;')"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and (ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')">
						<xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
						<xsl:value-of select="'&quot;format&quot;: &quot;uri&quot;,'"/>
						<xsl:value-of select="'&quot;readOnly&quot;: true,'"/>
						<xsl:value-of select="concat('&quot;example&quot;: &quot;datapunt.voorbeeldgemeente.nl/api/v1/',$sourceName,'/123456789&quot;')"/>
					</xsl:when>
<?x					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
					</xsl:when> ?>
				</xsl:choose>
					
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="'}'"/>
		<xsl:if test="position() != last()">
			<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
			<xsl:value-of select="','"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ep:construct" mode="embeddedchoices">
		<!-- This template generates for each association an embedded properties with a reference to an embedded type. -->
		<xsl:variable name="typeName" select="ep:type-name"/>
		<xsl:choose>
			<!-- Depending on the occurence-type and the type of construct content is generated. -->
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
				<xsl:value-of select="'{'"/>
					<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'Hal&quot;')"/>
				<xsl:value-of select="'}'"/>
				<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
				<xsl:value-of select="'{'"/>
				<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded">
					<xsl:sort select="ep:tech-name" order="ascending"/>
				</xsl:apply-templates>
				<xsl:value-of select="'}'"/>
				<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="supertype-association-in-embedded">
		<xsl:apply-templates select="ep:choice" mode="supertype-association-in-embedded"/>
	</xsl:template>
	
	<xsl:template match="ep:choice" mode="supertype-association-in-embedded">
		<xsl:value-of select="'&quot;oneOf&quot; : ['"/>
		<!--xsl:apply-templates select="//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']" mode="subclass-embedded"-->
		<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']" mode="subclass-embedded">
			<xsl:sort select="ep:tech-name" order="ascending"/>
		</xsl:apply-templates>
		<xsl:value-of select="']'"/>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="subclass-embedded">
		
		<xsl:variable name="type-name" select="ep:type-name"/>
		
		<!-- The following variable indicates the necessity to place a ref to a subclass within an embedded component. If only id-type attributes are present the subclass isn't placed.
			 Also the superclass attributes of the subclass are taken into account. -->
		<xsl:variable name="indicatorNonIdProperties" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="//ep:construct[ep:tech-name=$type-name]/ep:seq/ep:construct/ep:parameters[ep:parameter[ep:name='is-id']/ep:value ='false']">
					<xsl:value-of select="true()"/>
				</xsl:when>
				<xsl:when test="//ep:construct[ep:tech-name=$type-name]/ep:seq[not(ep:construct/ep:parameters[ep:parameter[ep:name='is-id']/ep:value ='false']) and ep:construct/ep:ref]">
					<xsl:variable name="indicatorNonIdPropertiesInRef">
						<xsl:sequence select="imf:determineIndicatorNonIdProperties($type-name)"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($indicatorNonIdPropertiesInRef,'true')">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$indicatorNonIdProperties">
			<xsl:value-of select="concat('{ &quot;$ref&quot; : &quot;',$json-topstructure,'/',ep:type-name,'Hal&quot; }')"/>
			<xsl:if test="position() != last()">
				<xsl:value-of select="','"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:function name="imf:determineIndicatorNonIdProperties">
		<xsl:param name="type-name"/>
		
		<xsl:for-each select="$message-sets//ep:construct[ep:tech-name=$type-name]/ep:seq/ep:construct[ep:ref]">
			<xsl:variable name="type-nameRefConstruct" select="ep:ref"/>
			<xsl:choose>
				<xsl:when test="$message-sets//ep:construct[ep:tech-name = $type-nameRefConstruct]/ep:seq/ep:construct/ep:parameters[ep:parameter[ep:name='is-id']/ep:value ='false']">
					<xsl:value-of select="'true;'"/>
				</xsl:when>
				<xsl:when test="$message-sets//ep:construct[ep:tech-name = $type-nameRefConstruct]/ep:seq[not(ep:construct/ep:parameters[ep:parameter[ep:name='is-id']/ep:value ='false']) and ep:construct/ep:ref]">
					<xsl:sequence select="imf:determineIndicatorNonIdProperties($type-nameRefConstruct)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'false;'"/>
				</xsl:otherwise>
			</xsl:choose>						
		</xsl:for-each>
	</xsl:function>
	
</xsl:stylesheet>
