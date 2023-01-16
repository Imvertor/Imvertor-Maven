<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:ep="http://www.imvertor.org/schema/endproduct" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	xmlns:j="http://www.w3.org/2005/xpath-functions"
	xmlns:html="http://www.w3.org/1999/xhtml"
	version="2.0">
	
	<xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
	
	<!--xsl:include href="Documentation.xsl"/--> 
	
	<xsl:variable name="stylesheet-code" as="xs:string">YAMLB</xsl:variable>
	
	<!-- The first variable is meant for the server environment, the second one is used during development in XML-Spy. -->
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
	<!--<xsl:variable name="debugging" select="false()" as="xs:boolean"/>-->
	
	<xsl:variable name="standard-json-components-url" select="concat(imf:get-config-parameter('standard-components-url'),imf:get-config-parameter('standard-components-file'),imf:get-config-parameter('standard-json-components-path'))"/>
	<xsl:variable name="standard-json-gemeente-components-url" select="concat(imf:get-config-parameter('standaard-organisatie-components-url'),imf:get-config-parameter('standard-organisatie-components-file'),imf:get-config-parameter('standard-json-components-path'))"/>
	<xsl:variable name="standard-geojson-components-url" select="concat(imf:get-config-parameter('standard-components-url'),imf:get-config-parameter('standard-geojson-components-file'))"/>
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

		<xsl:variable name="json-components">
			<!-- For each global construct a component is generated. -->
				<xsl:choose>
					<xsl:when test="$serialisation = 'hal+json'">
						<!-- Only if hal+json applies this when is relevant -->
						<!-- In case of Gr or Gc messages HalCollectie and Hal entities have to be generated. -->
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
								
								
								<j:map key="{concat($tech-name,'HalCollectie')}">
									<j:string key="type">object</j:string>
									<j:map key="properties">
										<j:map key="_links">	
											<xsl:choose>
												<xsl:when test="$pagination='true'">
													<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'HalPaginationLinks'))"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'HalCollectionLinks'))"/>
												</xsl:otherwise>
											</xsl:choose>
										</j:map>
										<j:map key="_embedded">
											<j:string key="type">object</j:string>
											<j:map key="properties">
												<j:map key="{ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value}">
													<j:string key="type">array</j:string>
													<j:map key="items">
														<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',translate($tech-name,'.','_'),'Hal'))"/>
													</j:map>
												</j:map>																									
											</j:map>												
										</j:map>
									</j:map>
								</j:map>
								
							</xsl:if>							
	
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01000',.)"/>

							<!-- The regular constructs are generated here. -->
							
							<xsl:sequence select="imf:createHalComponent($elementName,.)"/>
							
							<xsl:variable name="construct">
								<xsl:call-template name="construct"/>
							</xsl:variable>
							<xsl:sequence select="$construct"/>
						</xsl:for-each>
						<!-- In case of Pa, Po or Pu messages only Hal entities have to be generated. -->
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
	
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01100',.)"/>

							<!-- The regular constructs are generated here. -->
	
							<xsl:sequence select="imf:createHalComponent($elementName,.)"/>
							
							<xsl:variable name="construct">
								<xsl:call-template name="construct"/>
							</xsl:variable>
							<xsl:sequence select="$construct"/>
						</xsl:for-each>
						
						<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01200',.)"/>
						
					</xsl:when>
					<xsl:otherwise>
						<!-- Loop over global constructs which are refered to from constructs directly within the (collection) ep:message 
					 elements but aren't enumeration constructs. -->
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

							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01300',.)"/>
							
							<xsl:variable name="construct">
								<xsl:call-template name="construct"/>
							</xsl:variable>
							<xsl:sequence select="$construct"/>
						</xsl:for-each>

						<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01400',.)"/>
						
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:choose>
					<xsl:when test="$serialisation = 'hal+json'">
						<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't 'enumeration', 'superclass', 'complex-datatype','groep' or 'table-datatype' constructs.
							 This is only applicable when the serialisation is hal+json.
							 See 'Imvertor-Maven\src\main\resources\xsl\YamlCompiler\documentatie\Explanation query constructions.xlsx' tab 'Query1' for an explanation on this query. -->
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
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01500',.)"/>
							
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
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="$serialisation = 'json'">
						<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't 'enumeration', 'superclass', 'complex-datatype','groep' or 'table-datatype' constructs.
							 This is only applicable when the serialisation is json. -->
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
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01600',.)"/>
							
							<xsl:variable name="construct">
								<xsl:call-template name="construct"/>
							</xsl:variable>
							<xsl:sequence select="$construct"/>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-01900',.)"/>
			
				<!-- Loop over global superclass constructs which are refered to from constructs within the messages. -->
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
					
					<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02000',.)"/>
					
					<xsl:variable name="construct">
						<xsl:call-template name="construct"/>
					</xsl:variable>
					<xsl:sequence select="$construct"/>
				</xsl:for-each>
				
				<xsl:choose>
					<xsl:when test="$serialisation = 'hal+json'">
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
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02100',.)"/>
							
							<xsl:variable name="choiceConstructs2bprocessed">
								<ep:choiceConstructs2bprocessed>
									<xsl:for-each select="ep:seq/ep:choice">
										<xsl:apply-templates select="ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')  and ep:type-name = //ep:message-set/ep:construct/ep:tech-name][1]" mode="_links"/>
									</xsl:for-each>
								</ep:choiceConstructs2bprocessed>
							</xsl:variable>
							<xsl:variable name="choiceConstructs">
								
								<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02120',.)"/>
								
								<xsl:for-each select="$choiceConstructs2bprocessed/ep:choiceConstructs2bprocessed/ep:construct2bprocessed[.!='']">
									<xsl:sequence select="./*"/>
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
								
								<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02130',.)"/>
								
								<xsl:for-each select="$seqConstructs2bprocessed/ep:seqConstructs2bprocessed/ep:construct2bprocessed[.!='']">
									<xsl:sequence select="./*"/>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$choiceConstructs!='' or $seqConstructs!='' or empty(ep:parameters/ep:parameter[ep:name = 'abstract']) or ep:parameters/ep:parameter[ep:name = 'abstract']/ep:value = 'false'">
								
								<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02140',.)"/>
								
								<j:map key="{concat(translate(ep:tech-name,'.','_'),'_links')}">
									<j:string key="type">object</j:string>
									<j:map key="properties">
										<xsl:if test="empty(ep:parameters/ep:parameter[ep:name = 'abstract']) or ep:parameters/ep:parameter[ep:name = 'abstract']/ep:value = 'false'">
											<j:map key="self">
												<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'HalLink'))"/>
											</j:map>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="not($choiceConstructs='') and not($seqConstructs='')">
												<xsl:sequence select="$choiceConstructs"/>
												<xsl:sequence select="$seqConstructs"/>
											</xsl:when>
											<xsl:when test="not($choiceConstructs='')">
												<xsl:sequence select="$choiceConstructs"/>
											</xsl:when>
											<xsl:when test="not($seqConstructs='')">
												<xsl:sequence select="$seqConstructs"/>
											</xsl:when>
										</xsl:choose>
									</j:map>
								</j:map>
							</xsl:if>
							
							<xsl:sequence select="imf:generateDebugInfo('Einde-Debuglocatie-02100',.)"/>
							
						</xsl:for-each>
						<!-- When expand applies in one or more messages the following if is relevant. -->
						<xsl:if test="ep:message-set/ep:message[ep:parameters/ep:parameter[ep:name='expand']/ep:value = 'true']">
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02150',.)"/>
							
							<!-- For all global constructs who have at least one association or supertype-association construct a global embedded version has to 
								 be generated. Since it is not possible (or at least very hard) to detect if the next construct processed by this for each has content it is not possible to
								 determine if the for-each has to create a comma at the end. For that reason the comma is generated always and the content generated by the for-each is placed 
								 within a variable. After the for-each the last comma within the variable is removed. -->
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
								
								<xsl:if test="not(empty($content))">
									
									<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02200',.)"/>
									
									<j:map key="{concat(translate(ep:tech-name,'.','_'),'_embedded')}">
										<j:string key="type">object</j:string>
										<j:map key="properties">
											<xsl:apply-templates select="ep:seq">
												<xsl:with-param name="typeName" select="$typeName"/>
											</xsl:apply-templates>
										</j:map>
									</j:map>
									
									<xsl:sequence select="imf:generateDebugInfo('Einde-Debuglocatie-02200',.)"/>
									
								</xsl:if>
							</xsl:for-each>
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
								
								<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02300',.)"/>
								
								<j:map key="{concat(translate(ep:tech-name,'.','_'),'_embedded')}">
									<j:string key="type">object</j:string>
									<j:map key="properties">
										<xsl:apply-templates select=".//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association') and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embedded"/>
									</j:map>
								</j:map>
								
								<xsl:sequence select="imf:generateDebugInfo('Einde-Debuglocatie-02300',.)"/>
								
							</xsl:for-each>
						</xsl:if>
						<!-- Loop over global constructs which are refered to from other constructs and are 'complex-datatype','groep' or 'table-datatype' constructs.
							 This is only applicable when the serialisation is hal+json.
							 See 'Imvertor-Maven\src\main\resources\xsl\YamlCompiler\documentatie\Explanation query constructions.xlsx' tab 'Query1' for an explanation on this query. -->
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
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02400',.)"/>
							
							<xsl:call-template name="construct"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- If serialisation isn't hal+json no _links en _embedded components have to be generated. -->

						<!-- Loop over global constructs which are refered to from other constructs and are 'complex-datatype','groep' or 'table-datatype' constructs.
							 This is only applicable when the serialisation is json. -->
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
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02500',.)"/>
							
							<xsl:call-template name="construct"/>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			
				<!-- Loop over all enumeration constructs. -->
				<xsl:for-each select="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:enum]">
					<xsl:sort select="ep:tech-name" order="ascending"/>
					<!-- An enummeration component is generated. -->
					<xsl:call-template name="enumeration"/>
				</xsl:for-each>
		
				<!-- Loop over all simpletype constructs (local datatypes). -->
				<xsl:for-each select="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:parameters/ep:parameter[ep:name = 'type']/ep:value = 'simpletype-class']">
					<xsl:sort select="ep:tech-name" order="ascending"/>
					<!-- An simpletype component is generated. -->
					<xsl:call-template name="simpletype-class"/>
				</xsl:for-each>
		</xsl:variable>

		<!-- First the JSON top-level structure is generated. -->
		<j:map>
			<xsl:choose>
				<xsl:when test="$json-version = '2.0'">
					<xsl:if test="$json-schemadeclaration = true()">
						<j:string key="$schema">http://json-schema.org/draft-04/schema#</j:string>
						<j:string key="description">Comment describing your JSON Schema</j:string>
					</xsl:if>
					<j:map key="definitions">
						<xsl:sequence select="$json-components"/>
					</j:map>
				</xsl:when>
				<xsl:when test="$json-version = '3.0'">
					<j:map key="components">
						<j:map key="schemas">
							<xsl:sequence select="$json-components"/>
						</j:map>
					</j:map>
				</xsl:when>
			</xsl:choose>
		</j:map>
	</xsl:template>
	
	<xsl:template match="ep:seq">
		<xsl:param name="typeName"/>


		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02600',.)"/>
		
		<xsl:apply-templates select="ep:choice">
			<xsl:with-param name="typeName" select="$typeName"/>
		</xsl:apply-templates>
		
		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02700',.)"/>
		
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
					<xsl:apply-templates select="ep:construct[ep:parameters[(ep:parameter[ep:name='type']/ep:value ='association' or ep:parameter[ep:name='type']/ep:value ='supertype-association') and
																			ep:parameter[ep:name='contains-non-id-attributes']/ep:value ='true']]" mode="embedded"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
				<xsl:apply-templates select="ep:construct[ep:parameters[ep:parameter[ep:name='type']/ep:value ='association' or ep:parameter[ep:name='type']/ep:value ='supertype-association']]" mode="embedded"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ep:choice" mode="subclasscomponent">
		<xsl:for-each select="ep:construct">
			<xsl:variable name="type-name" select="ep:type-name"/>
			<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $type-name]" mode="subclasscomponent"/>
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
		<xsl:for-each select="$uniqueSupertypes//ep:type-name">
			<xsl:sort select="." order="ascending"/>
			<xsl:variable name="type-name" select="."/>
			<xsl:apply-templates select="$message-sets//ep:construct[ep:tech-name = $type-name and parent::ep:message-set]" mode="superclasscomponent"/>
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

		<j:map key="{concat($elementName,'Hal')}">
			<j:array key="allOf">
				<j:map>
					<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$elementName))"/>
				</j:map>
				<j:map>
					<j:string key="type">object</j:string>
					
					<xsl:variable name="allContextItems">
						<xsl:for-each select="$contextItem">
							<xsl:call-template name="construct">
								<xsl:with-param name="mode" select="'onlyLinksAndEmbedded'"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:variable>
					
					<xsl:if test="not($allContextItems='')">
						<j:map key="properties">
							<xsl:sequence select="$allContextItems"/>
						</j:map>
					</xsl:if>
				</j:map>
			</j:array>
		</j:map>
		
	</xsl:function>
	
	<xsl:template match="ep:choice">
		<xsl:param name="typeName"/>

		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02800',.)"/>
		
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
		
		
		<j:map key="{$elementName}">
			<j:string key="type"><xsl:value-of select="$occurence-type"/></j:string>
			<xsl:variable name="documentation">
				<xsl:apply-templates select="$firstChoice/ep:documentation"/>
			</xsl:variable>
			<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
			<xsl:if test="$occurence-type = 'array'">
				<xsl:if test="$maxOccurs != 'unbounded'">
					<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
				</xsl:if>
				<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
					<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
				</xsl:if>
			</xsl:if>
			<xsl:choose>
				<!-- Depending on the occurence-type and the type of construct content is generated. -->
				<xsl:when test="$serialisation = 'json'">
					<j:array key="enum">string</j:array>
				</xsl:when>
				<xsl:when test="$serialisation = 'hal+json'">
					<xsl:choose>
						<xsl:when test="$occurence-type = 'array'">
							<j:map key="items">
								<j:array key="oneOf">
									<!--j:map-->
										<xsl:choose>
											<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
												<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																			 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
											</xsl:when>
											<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
												<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
											</xsl:when>
										</xsl:choose>
									<!--/j:map-->
								</j:array>
							</j:map>
						</xsl:when>
						<xsl:otherwise>
							<j:array key="oneOf">
								<!--j:map-->
									<xsl:choose>
										<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
											<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																		 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
										</xsl:when>
										<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
											<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
										</xsl:when>
									</xsl:choose>
								<!--/j:map-->
							</j:array>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</j:map>
	</xsl:template>

	<xsl:template name="construct">
		<xsl:param name="mode" select="'all'"/>
		<xsl:param name="grouping" select="''"/>
		
		<!-- With this template global properties are generated.  -->
		
		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02850',.)"/>
		
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
						<j:map key="_links">
							<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$elementName,'_links'))"/>
						</j:map>
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
								($contentRelatedEmbeddedConstruct != '')">
								<!-- When expand applies in the interface also an embedded variant of the current construct has to be generated..
								 At this place only a reference to such a componenttype is generated. -->
								<j:map key="_embedded">
									<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$elementName,'_embedded'))"/>
								</j:map>
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
					<j:map key="properties">
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
							</xsl:for-each>
						</xsl:variable>
						
						<xsl:if test="$attribuutProperties != ''">
							<xsl:sequence select="$attribuutProperties"/>
						</xsl:if>
						<xsl:if test="$reference2links != '' and $serialisation = 'json'">
							<xsl:sequence select="$reference2links"/>
						</xsl:if>
						<xsl:if test="$associationProperties != '' and $serialisation = 'json'">
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-02900',.)"/>
							
							<xsl:sequence select="$associationProperties"/>
						</xsl:if>
					</j:map>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$mode = 'onlyLinksAndEmbedded'">
						
						<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03000',.)"/>
						
						<xsl:if test="$reference2links != ''">
							<xsl:sequence select="$reference2links"/>
						</xsl:if>
						<xsl:if test="$associationProperties != ''">
							
							<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03050',.)"/>
							
							<xsl:sequence select="$associationProperties"/>
						</xsl:if>
					</xsl:when>
					<!-- TODO: Volgende when moet vanuit een configuratie aan te sturen zijn. -->
					<xsl:when test="$elementName = 'Datum_onvolledig'">
						
						<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03060',.)"/>
						
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="content">
							<xsl:choose>
								<xsl:when test="ep:seq/ep:construct[ep:ref]">
									<!-- If the current construct has a construct with a ref (it has a supertype) an 'allOf' is generated. -->
									<xsl:variable name="ref" select="ep:seq/ep:construct/ep:ref"/>
									<j:array key="allOf">
										<j:map>
											<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$ref))"/>
										</j:map>
										<j:map>
											<j:string key="type">object</j:string>
											<j:string key="description"><xsl:sequence select="$documentation"></xsl:sequence></j:string>
											<xsl:if test="$requiredproperties">
												<!-- Only if the variable requiredproperties is true a 'required' section has to be generated. -->
												<j:array key="required">
													<xsl:choose>
														<xsl:when test="$serialisation='hal+json'">
															<xsl:for-each select="ep:seq/ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value != 'association' or empty(ep:parameters/ep:parameter[ep:name='type']/ep:value)) and not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
																<xsl:sort select="ep:tech-name" order="ascending"/>
																<!-- Loops over required constructs, which are required, are no associations and have no ep:seq. -->
																<j:string><xsl:value-of select="translate(ep:tech-name,'.','_')"/></j:string>
															</xsl:for-each>
														</xsl:when>
														<xsl:when test="$serialisation='json'">
															<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
																<xsl:sort select="ep:tech-name" order="ascending"/>
																<!-- Loops over constructs, which are required, are no associations and have no ep:seq. -->
																<xsl:choose>
																	<xsl:when test="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']">
																		<j:string><xsl:value-of select="translate(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value,'.','_')"/></j:string>
																	</xsl:when>
																	<xsl:otherwise>
																		<j:string><xsl:value-of select="translate(ep:tech-name,'.','_')"/></j:string>
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:for-each>
														</xsl:when>
													</xsl:choose>
												</j:array>
											</xsl:if>
											<xsl:if test="$properties != ''">
												<xsl:sequence select="$properties"/>
											</xsl:if>
										</j:map>
									</j:array>
								</xsl:when>
								<xsl:otherwise>
									<j:string key="type">object</j:string>
									<j:string key="description"><xsl:sequence select="$documentation"></xsl:sequence></j:string>
									<xsl:if test="$requiredproperties">
										<!-- Only if the variable requiredproperties is true a 'required' section has to be generated. -->
										<j:array key="required">
											<xsl:choose>
												<xsl:when test="$serialisation='hal+json'">
													<xsl:for-each select="ep:seq/ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value != 'association' or empty(ep:parameters/ep:parameter[ep:name='type']/ep:value)) and not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
														<xsl:sort select="ep:tech-name" order="ascending"/>
														<!-- Loops over required constructs, which are required, are no associations and have no ep:seq. -->
														<j:string><xsl:value-of select="translate(ep:tech-name,'.','_')"/></j:string>
													</xsl:for-each>
												</xsl:when>
												<xsl:when test="$serialisation='json'">
													<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
														<xsl:sort select="ep:tech-name" order="ascending"/>
														<!-- Loops over constructs, which are required, are no associations and have no ep:seq. -->
														<xsl:choose>
															<xsl:when test="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']">
																<j:string><xsl:value-of select="translate(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value,'.','_')"/></j:string>
															</xsl:when>
															<xsl:otherwise>
																<j:string><xsl:value-of select="translate(ep:tech-name,'.','_')"/></j:string>
															</xsl:otherwise>
														</xsl:choose>
													</xsl:for-each>
												</xsl:when>
											</xsl:choose>
										</j:array>
									</xsl:if>
									<xsl:if test="$properties != ''">
										<xsl:sequence select="$properties"/>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
							
						</xsl:variable>
						
						<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03070',.)"/>
						
						<xsl:choose>
							<xsl:when test="$grouping != 'resource'">
								
								<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03100',.)"/>
								
								<j:map key="{$elementName}">
									<xsl:sequence select="$content"/>
								</j:map>
							</xsl:when>
							<xsl:otherwise>
								
								<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03200',.)"/>
								
								<xsl:sequence select="$content"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				


			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="enumeration">
		<!-- Enummeration constructs are processed here. -->
		<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
		
		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03300',.)"/>
		
		<j:map key="{$elementName}">
			<j:string key="type">string</j:string>
	
			<xsl:variable name="enumeration-documentation">
				<j:string key="description">
					<xsl:if test="ep:documentation">
						<xsl:apply-templates select="ep:documentation"/>
					</xsl:if>
					<xsl:choose>
						<!-- If the content of all ep:name elements is equal to their sibbling ep:alias elements no further documentation is generated. -->
						<xsl:when test="count(ep:enum[ep:name=ep:alias])=count(ep:enum)"/>
						<xsl:when test="//ep:p/@format = 'markdown'">
							<xsl:text>&lt;body&gt;&lt;ul&gt;</xsl:text>
							<xsl:for-each select="ep:enum">
								<xsl:text>&lt;li&gt;</xsl:text><xsl:value-of select="concat('`',ep:alias,'` - ',ep:documentation)"/><xsl:text>&lt;/li&gt;</xsl:text>
							</xsl:for-each>
							<xsl:text>&lt;/ul&gt;&lt;/body&gt;</xsl:text>
						</xsl:when>
						<xsl:when test="//ep:p/@format = 'markdown'">
							<xsl:text>&lt;body&gt;&lt;ul&gt;</xsl:text>
							<xsl:for-each select="ep:enum">
								<xsl:text>&lt;li&gt;</xsl:text><xsl:value-of select="concat('`',ep:alias,'` - ',ep:name,' ',ep:documentation)"/><xsl:text>&lt;/li&gt;</xsl:text>
							</xsl:for-each>
							<xsl:text>&lt;/ul&gt;&lt;/body&gt;</xsl:text>
						</xsl:when>
						<xsl:when test="count(ep:enum[ep:name=ep:alias])=count(ep:enum) and //ep:p/@format != 'markdown'">
							<xsl:for-each select="ep:enum">
								<xsl:value-of select="concat('\n* `',ep:alias,'` - ',ep:documentation)"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="ep:enum">
								<xsl:value-of select="concat('\n* `',ep:alias,'` - ',ep:name,' ',ep:documentation)"/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</j:string>
			</xsl:variable>
			<xsl:sequence select="$enumeration-documentation"/>
			<!--xsl:sequence select="normalize-space($enumeration-documentation)"/-->
			
			<j:array key="enum">
				<xsl:for-each select="ep:enum">
					<!-- Loop over all enum elements. -->
					<j:string><xsl:value-of select="ep:alias"/></j:string>
				</xsl:for-each>
			</j:array>
		</j:map>
		
		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03400',.)"/>
		
	</xsl:template>
	
	
	<xsl:template name="simpletype-class">
		<!-- simpletype-class constructs are processed here. -->
		<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
		<xsl:variable name="derivedPropertyContent">
			<xsl:call-template name="derivePropertyContent">
				<xsl:with-param name="typeName" select="''"/>
			</xsl:call-template>
		</xsl:variable>


		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03430',.)"/>
		
		<j:map key="{$elementName}">
			<xsl:sequence select="$derivedPropertyContent"/>		
		</j:map>
		
		<xsl:sequence select="imf:generateDebugInfo('Einde-Debuglocatie-03430',.)"/>
		
	</xsl:template>
	

	<!-- TODO: Het onderstaande template en ook de aanroep daarvan zijn is op dit moment onnodig omdat we er nu vanuit gaan dat als er hal+json gegenereerd 
			   moet worden er ook in de gehele standaard hal+json gegenereerd moet worden.
			   Alleen als we later besluiten dat er ook af en toe geen json_hal gegenereerd moet worden kan deze if weer opportuun worden. 
			   Voor nu is het template uitgeschakeld. -->
	<!-- A HAL type is generated here. -->
	<?x <xsl:template name="construct_jsonHAL">
        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03500',.)"/>
						
        <j:map key="{concat($elementName,'_HAL)"/>
			<j:string key="type">object</j:string>

	        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
	
			<xsl:variable name="documentation">
				<!--xsl:value-of select="ep:documentation//ep:p"/-->
				<xsl:apply-templates select="ep:documentation"/>
			</xsl:variable>
			<j:string key="description">
				<!-- Double quotes in documentation text is replaced by a  grave accent. -->
				<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
			</j:string>
	
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
				<j:array key="required">
					<!--Only constructs which aren't optional are processed here. -->
					<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
						<j:string key="{translate(ep:tech-name,'.','_')}"/>
					</xsl:for-each>
				</j:array>
			</xsl:if>
	
			<j:map key="properties">
			
	<!--		<xsl:if test="$debugging">

			<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-00500',.)"/>
						
			</xsl:if>-->
	
				<!-- All constructs (that don't have association type constructs) within the current construct are processed here. -->
				<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association')]">
					<xsl:variable name="name" select="substring-after(ep:type-name, ':')"/>
		
		<!--			<xsl:if test="$debugging">

						<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-00600',.)"/>
						
					</xsl:if>
		-->
					<xsl:call-template name="property"/>
				</xsl:for-each>
				
		
				<!-- If the construct has association constructs a reference to a '_links' property is generated based on the same elementname. -->
				<xsl:if test=".//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='association']">
		
					<j:map key="properties>
						<xsl:if test="not(./ep:parameters/ep:parameter[ep:name='endpointavailable']/ep:value='Nee')">
							<j:map key="_links">
								<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$elementName,'_links'))"/>
							</j:map>
						</xsl:if>	
						<!-- When the construct also had attributes which are not id-type attributes in the interface also an embedded version has to be generated.
							 At this place only a reference to such a type is generated. -->
						<xsl:if test="$contains-non-id-attributes">
							<j:map key="_embedded">
								<xsl:value-of select="concat($json-topstructure,'/',$elementName,'_embedded')"/>
							</j:map>
						</xsl:if>
					</j:map>
				</xsl:if>
		
			</j:map>
		</j:map>

		<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-3600',.)"/>
						
   </xsl:template> ?>
   
	<xsl:template name="property">
		<!-- The properties representing an uml attribute are generated here.
			 To be able to do that it uses the derivePropertyContent template which on its turn uses the deriveDataType, deriveFormat and deriveFacets 
			 templates. -->
		<xsl:choose>
			<xsl:when test="ep:outside-ref=('VNGR','VNG-GENERIEK')">
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03700',.)"/>
				
				<j:map key="{translate(ep:tech-name,'.','_')}">
					<xsl:sequence select="imf:generateRef(concat($standard-json-gemeente-components-url,ep:type-name))"/>
				</j:map>
			</xsl:when>
			<xsl:otherwise>
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03800',.)"/>
				
				<xsl:variable name="derivedPropertyContent">
					<xsl:call-template name="derivePropertyContent">
						<xsl:with-param name="typeName" select="ep:type-name"/>
					</xsl:call-template>
				</xsl:variable>
				<!-- The following if only applies if the current construct has an ep:type-name or a ep:data-type and if it isn't an association type construct
			 or if it is a gml type. -->
				<xsl:if test="((exists(ep:type-name) or exists(ep:data-type)) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value='association') or ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external')">
					<j:map key="{translate(ep:tech-name,'.','_')}">
						<xsl:sequence select="$derivedPropertyContent"/>
					</j:map>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="derivePropertyContent">
		<!-- This template builds the content of the properties representing an uml attribute. -->
		<xsl:param name="typeName"/>
		<xsl:param name="typePrefix"/>
		<xsl:choose>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external'">
				<!-- If the property is a gml type this when applies. In all these case a standard content (except the documentation)
					 is generated. -->
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-03900',.)"/>
				
				<xsl:sequence select="imf:generateRef(concat($standard-geojson-components-url,'GeoJSONGeometry'))"/>
			</xsl:when>
			<xsl:when test="ep:type-name = 'Datum_onvolledig'">
				<!-- If the property is a Datum_onvolledig type this when applies. In all these case a standard content (except the documentation)
					 is generated. -->
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04000',.)"/>
				
				<j:array key="allOff">
					<j:map>
						<xsl:variable name="documentation">
							<xsl:apply-templates select="ep:documentation"/>
						</xsl:variable>
						<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
						<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'Datum_onvolledig'))"/>
					</j:map>
				</j:array>
			</xsl:when>
			<xsl:when test="exists(ep:data-type) and (ep:max-occurs = 'unbounded' or ep:max-occurs > 1)">
				<!-- If the construct has a ep:data-type element, a description, an optional format and, also optional, some facets have to be generated. -->
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04100',.)"/>
				
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
				<j:string key="type">array</j:string>
				<xsl:if test="ep:parameters/ep:parameter[ep:name='SIM-name']">
					<j:string key="title"><xsl:value-of select="ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value"/></j:string>
				</xsl:if>
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
				<xsl:if test="ep:min-occurs">
					<j:number key="minItems"><xsl:value-of select="ep:min-occurs"/></j:number>
				</xsl:if>
				<xsl:if test="ep:max-occurs != 'unbounded'">
					<j:number key="maxItems"><xsl:value-of select="ep:max-occurs"/></j:number>
				</xsl:if>
				<j:map key="items">
					<j:string key="type"><xsl:value-of select="$datatype"/></j:string>
					<xsl:sequence select="$format"/>
					<xsl:sequence select="$facets"/>
					<xsl:sequence select="$example"/>
				</j:map>
			</xsl:when>
			<xsl:when test="exists(ep:data-type)">
				<!-- If the construct has a ep:data-type element, a description, an optional format and, also optional, some facets have to be generated. -->
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04200',.)"/>
				
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
				<j:string key="type"><xsl:value-of select="$datatype"/></j:string>
				<xsl:if test="ep:parameters/ep:parameter[ep:name='SIM-name']">
					<j:string key="title"><xsl:value-of select="ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value"/></j:string>
				</xsl:if>
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04250',.)"/>
				
				<xsl:sequence select="$format"/>
				<xsl:sequence select="$facets"/>
				<xsl:sequence select="$example"/>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'table-datatype' and exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name)">
				<!-- If the current construct [A] refers to an existing tableconstruct [B] by its typename and the tableconstruct has a type-name on its turn
					 an allOf with a $ref to the construct B using the B-type-name and a title and description has to be generated. -->
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04300',.)"/>
				
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<j:array key="allOf">
					<j:map>
						<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/', /ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name))"/>
					</j:map>
					<j:map>
						<j:string key="title"><xsl:value-of select="ep:name"/></j:string>
						<j:string key="description"><xsl:sequence select="$documentation"/></j:string>						
					</j:map>
				</j:array>
			</xsl:when>
			<xsl:when test="exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name)">
				<!-- If the current construct [A] refers to an existing other construct [B] by its typename and that construct has a type-name on its turn
					 a $ref to the construct B has to be generated using the B-type-name. -->
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04400',.)"/>
				
				<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/', /ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name))"/>
			</xsl:when>
			<!-- In all othert cases a $ref to the type-name of the current construct has to be generated. -->
			<xsl:when test="ep:max-occurs = 'unbounded' or ep:max-occurs > 1">
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04500',.)"/>
				
				<j:string key="type">array</j:string>
				<j:map key="item">
					<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/', $typeName))"/>
				</j:map>
			</xsl:when>
			<xsl:when test="$typeName = 'NEN3610ID'">
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04600',.)"/>
				
				<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'Nen3610Id'))"/>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'table-datatype'">
				<!-- If the current construct is an tableconstruct an allOf with a $ref, a title and description has to be generated. -->
				
				<xsl:sequence select="imf:generateDebugInfo('Debuglocatie-04700',.)"/>
				
				<xsl:variable name="documentation">
					<xsl:apply-templates select="ep:documentation"/>
				</xsl:variable>
				<j:array key="allOf">
					<j:map>
						<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/', $typeName))"/>
					</j:map>
					<j:map>
						<j:string key="title"><xsl:value-of select="ep:name"/></j:string>
						<j:string key="description"><xsl:sequence select="$documentation"/></j:string>						
					</j:map>
				</j:array>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/', $typeName))"/>
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
				<j:string key="format">date</j:string>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<j:string key="format">date_fullyear</j:string>
			</xsl:when>
<!--			<xsl:when test="$incomingType = 'yearmonth'">
				<j:string key="format">jaarmaand</j:string>
			</xsl:when> -->
			<xsl:when test="$incomingType = 'month'">
				<j:string key="format">date_month</j:string>
			</xsl:when>
			<xsl:when test="$incomingType = 'day'">
				<j:string key="format">date_mday</j:string>
			</xsl:when>
			<xsl:when test="$incomingType = 'datetime'">
				<j:string key="format">date-time</j:string>
			</xsl:when>
			<xsl:when test="$incomingType = 'uri'">
				<j:string key="format">uri</j:string>
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
					<j:string key="pattern">^<xsl:value-of select="ep:pattern"/>$</j:string>
				</xsl:if>
				<xsl:if test="ep:max-length">
					<j:number key="maxLength"><xsl:value-of select="ep:max-length"/></j:number>
				</xsl:if>
				<xsl:if test="ep:min-length and empty(ep:pattern)">
					<j:number key="minLength"><xsl:value-of select="ep:min-length"/></j:number>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$incomingType = ('integer','real','decimal')">
				<xsl:if test="ep:min-value">
					<j:number key="minimum"><xsl:value-of select="ep:min-value"/></j:number>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<j:number key="maximum"><xsl:value-of select="ep:max-value"/></j:number>
				</xsl:if>
			</xsl:when>
<!--			<xsl:when test="$incomingType = 'real'">
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
			</xsl:when> -->
			<xsl:when test="$incomingType = 'year'">
				<xsl:if test="$json-version != '2.0'">
					<j:string key="pattern"><xsl:value-of select="'^[1-2]{1}[0-9]{3}$'"/></j:string>
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
			<xsl:when test="ep:example != ''">
				<j:string key="example"><xsl:value-of select="ep:example"/></j:string>
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
						<j:string key="title"><xsl:value-of select="ep:name"/></j:string>
					</xsl:if>
					<j:string key="type"><xsl:value-of select="$occurence-type"/></j:string>
					<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
				</xsl:variable>
		
				<j:map key="{$elementName}">
					<xsl:choose>
						<!-- Depending on the occurence-type and the type of construct content is generated. -->
						<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
							<xsl:sequence select="$titleTypeAndDescriptionContent"/>
							<xsl:if test="$maxOccurs != 'unbounded'">
								<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
							</xsl:if>
							<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
								<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
							</xsl:if>
							<j:map key="items">
								<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'HalLink'))"/>
							</j:map>
						</xsl:when>
						<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
							<j:array key="allOf">
								<j:map>
									<xsl:sequence select="$titleTypeAndDescriptionContent"/>
								</j:map>
								<j:map>
									<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'HalLink'))"/>
								</j:map>
							</j:array>
						</xsl:when>
						<!--xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
							<xsl:sequence select="concat($titleTypeAndDescriptionContent,',')"/>
							<xsl:if test="$maxOccurs != 'unbounded'">
								<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
							</xsl:if>
							<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
								<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
							</xsl:if>
							<j:map key="items">
								<j:string key="type">object</j:string>
								<j:string key="description">
									<xsl:value-of select="'uri van een van de volgende mogelijke typen ',$elementName,': '"/>
									<xsl:apply-templates select="//ep:construct[ep:tech-name = $type-name]" mode="supertype-association-in-links">
										<xsl:sort select="ep:tech-name" order="ascending"/>
									</xsl:apply-templates>
								</j:string>
								<j:map key="properties">
									<j:map key="href">
										<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'Href'))"/>
									</j:map>
								</j:map>
							</j:map>
						</xsl:when-->
						<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
							<xsl:sequence select="concat($titleTypeAndDescriptionContent,',')"/>
							<xsl:if test="$maxOccurs != 'unbounded'">
								<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
							</xsl:if>
							<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
								<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
							</xsl:if>
							<j:map key="items">
								<j:array key="allOf">
									<j:map>
										<j:string key="type">object</j:string>
										<j:string key="description">
											<xsl:value-of select="'uri van een van de volgende mogelijke typen ',$elementName,': '"/>
											<xsl:apply-templates select="//ep:construct[ep:tech-name = $type-name]" mode="supertype-association-in-links">
												<xsl:sort select="ep:tech-name" order="ascending"/>
											</xsl:apply-templates>
										</j:string>
									</j:map>
									<j:map>
										<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'HalLink'))"/>
									</j:map>
								</j:array>
							</j:map>
						</xsl:when>
						<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
							<j:array key="allOf">
								<j:map>
									<xsl:sequence select="$titleTypeAndDescriptionContent"/>
								</j:map>
								<j:map>
									<xsl:sequence select="imf:generateRef(concat($standard-json-components-url,'HalLink'))"/>
								</j:map>
							</j:array>
						</xsl:when>
					</xsl:choose>
				</j:map>
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
		<j:map key="{$elementName}">
			<xsl:variable name="documentation">
				<xsl:apply-templates select="ep:documentation"/>
			</xsl:variable>
			
			<xsl:choose>
				<xsl:when test="$serialisation = 'hal+json'">
			
					<!-- ROME: Deze toevoeging (nav #490159) geeft een warning in Swaggerhub. -->
					<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
						<j:string key="title"><xsl:value-of select="$title"/></j:string>
						<j:string key="type"><xsl:value-of select="$occurence-type"/></j:string>
					</xsl:if>
					
					<xsl:choose>
						<!-- Depending on the occurence-type and the type of construct content is generated. -->
						<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
							<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
							<xsl:if test="$maxOccurs != 'unbounded'">
								<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
							</xsl:if>
							<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
								<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
							</xsl:if>
							<j:map key="items">
								<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$typeName,'Hal'))"/>
							</j:map>
						</xsl:when>
						<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
							<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$typeName,'Hal'))"/>
						</xsl:when>
						<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
							<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
							<xsl:if test="$maxOccurs != 'unbounded'">
								<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
							</xsl:if>
							<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
								<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
							</xsl:if>
							<j:map key="items">
								<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded">
									<xsl:sort select="ep:tech-name" order="ascending"/>
								</xsl:apply-templates>
							</j:map>
						</xsl:when>
						<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
							<j:string key="description"><xsl:sequence select="$documentation"/></j:string>
							<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded">
								<xsl:sort select="ep:tech-name" order="ascending"/>
							</xsl:apply-templates>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$serialisation = 'json'">
			
					<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
						<j:string key="type"><xsl:value-of select="$occurence-type"/></j:string>
					</xsl:if>
	
					<!--<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">-->
					<j:string key="title"><xsl:value-of select="$title"/></j:string>
					<!--</xsl:if>-->
					
					<j:string key="description">
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space($documentation)"/>
					</j:string>
					
					<xsl:choose>
						<!-- Depending on the occurence-type and the type of construct content is generated. -->
						<xsl:when test="$occurence-type = 'array' and (ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')">
							<xsl:if test="$maxOccurs != 'unbounded'">
								<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
							</xsl:if>
							<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
								<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
							</xsl:if>
							<j:map key="items">
								<j:string key="type">string</j:string>
								<j:string key="format">uri</j:string>
							</j:map>
							<j:boolean key="readOnly">true</j:boolean>
							<j:boolean key="uniqueItems">true</j:boolean>
							<j:string key="example"><xsl:value-of select="concat('datapunt.voorbeeldgemeente.nl/api/v1/',$sourceName,'/123456789')"/></j:string>
						</xsl:when>
						<xsl:when test="$occurence-type != 'array' and (ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')">
							<!--RM: Hier klopt iets niet. In regel 2380 wordt een string met key="type" aangemaakt. Hieronder gebeurd dat nogmaals terwijl we nog steeds in hetzelfde object zitten.
									Ik kan er nog niet helemaal de vinger opleggen welke fout is maar ze mogen niet beide voorkomen. -->
							<j:string key="type">string</j:string>
							<j:string key="format">uri</j:string>
							<j:boolean key="readOnly">true</j:boolean>
							<j:string key="example"><xsl:value-of select="concat('datapunt.voorbeeldgemeente.nl/api/v1/',$sourceName,'/123456789')"/></j:string>
						</xsl:when>
	<?x					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
							<xsl:if test="$maxOccurs != 'unbounded'">
								<j:number key="maxItems"><xsl:value-of select="$maxOccurs"/></j:number>
							</xsl:if>
							<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
								<j:number key="minItems"><xsl:value-of select="$minOccurs"/></j:number>
							</xsl:if>
							<j:map key="items">
								<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
							</j:map>
						</xsl:when>
						<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
							<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
						</xsl:when> ?>
					</xsl:choose>
						
				</xsl:when>
			</xsl:choose>
		</j:map>
	</xsl:template>

	<xsl:template match="ep:construct" mode="embeddedchoices">
		<!-- This template generates for each association an embedded properties with a reference to an embedded type. -->
		<xsl:variable name="typeName" select="ep:type-name"/>
		<xsl:choose>
			<!-- Depending on the occurence-type and the type of construct content is generated. -->
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
				<j:map>
					<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',$typeName,'Hal'))"/>
				</j:map>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
				<j:map>
					<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded">
						<xsl:sort select="ep:tech-name" order="ascending"/>
					</xsl:apply-templates>
				</j:map>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="supertype-association-in-embedded">
		<xsl:apply-templates select="ep:choice" mode="supertype-association-in-embedded"/>
	</xsl:template>
	
	<xsl:template match="ep:choice" mode="supertype-association-in-embedded">
		<j:array key="oneOf">
			<j:map>
				<!--xsl:apply-templates select="//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']" mode="subclass-embedded"-->
				<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']" mode="subclass-embedded">
					<xsl:sort select="ep:tech-name" order="ascending"/>
				</xsl:apply-templates>
			</j:map>
		</j:array>
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
			<xsl:sequence select="imf:generateRef(concat($json-topstructure,'/',ep:type-name,'Hal'))"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:documentation">
		<xsl:param name="definition" select="'yes'"/>
		<xsl:param name="description" select="'yes'"/>
		<xsl:param name="pattern" select="'yes'"/>
		<xsl:variable name="completeDefinition">
			<xsl:if test="$definition = 'yes'">
				<xsl:apply-templates select="ep:definition"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="completeDescription">
			<xsl:if test="$description = 'yes'">
				<xsl:apply-templates select="ep:description"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="completePattern">
			<xsl:if test="$pattern = 'yes'">
				<xsl:apply-templates select="ep:pattern"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:sequence select="$completeDefinition"/>
		<xsl:if test="not(empty($completeDefinition)) and not(empty($completeDescription))"><xsl:text>
  </xsl:text><xsl:text>
</xsl:text></xsl:if>
  		<xsl:sequence select="$completeDescription"/>
		<xsl:if test="(not(empty($completeDescription)) and not(empty($completePattern))) or (not(empty($completeDefinition)) and not(empty($completePattern)))"><xsl:text>
  </xsl:text><xsl:text>
</xsl:text></xsl:if>
  		<xsl:sequence select="$completePattern"/>
	</xsl:template>
	
	<xsl:template match="ep:definition">
		<xsl:variable name="SIM-definition">
			<xsl:apply-templates select="ep:p[@level='SIM']"/>
		</xsl:variable>
		<xsl:variable name="UGM-definition">
			<xsl:apply-templates select="ep:p[@level='UGM']"/>
		</xsl:variable>
		<xsl:variable name="BSM-definition">
			<xsl:apply-templates select="ep:p[@level='BSM']"/>
		</xsl:variable>
		<xsl:sequence select="$SIM-definition"/>
		<xsl:if test="not(empty($SIM-definition)) and not(empty($UGM-definition))"><xsl:text>
  </xsl:text><xsl:text>
</xsl:text></xsl:if>
		<xsl:sequence select="$UGM-definition"/>
		<xsl:if test="(not(empty($UGM-definition)) and not(empty($BSM-definition))) or (not(empty($SIM-definition)) and not(empty($BSM-definition)))"><xsl:text>
  </xsl:text><xsl:text>
</xsl:text></xsl:if>
		<xsl:sequence select="$BSM-definition"/>
	</xsl:template>
	
	<xsl:template match="ep:description">
		<xsl:variable name="SIM-description">
			<xsl:apply-templates select="ep:p[@level='SIM']"/>
		</xsl:variable>
		<xsl:variable name="UGM-description">
			<xsl:apply-templates select="ep:p[@level='UGM']"/>
		</xsl:variable>
		<xsl:variable name="BSM-description">
			<xsl:apply-templates select="ep:p[@level='BSM']"/>
		</xsl:variable>
		<xsl:sequence select="$SIM-description"/>
		<xsl:if test="not(empty($SIM-description)) and not(empty($UGM-description))"><xsl:text>
  </xsl:text><xsl:text>
</xsl:text></xsl:if>
		<xsl:sequence select="$UGM-description"/>
		<xsl:if test="(not(empty($UGM-description)) and not(empty($BSM-description))) or (not(empty($SIM-description)) and not(empty($BSM-description)))"><xsl:text>
  </xsl:text><xsl:text>
</xsl:text></xsl:if>
		<xsl:sequence select="$BSM-description"/>
	</xsl:template>
	
	<xsl:template match="ep:pattern">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:p">
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:if test="following-sibling::ep:p">
			<xsl:text> </xsl:text>
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
	
	<xsl:function name="imf:generateRef">
		<xsl:param name="Path"/>

		<j:string key="$ref" escaped="true">
			<xsl:value-of select="$Path"/>
		</j:string>
	</xsl:function>
	
	<xsl:function name="imf:generateDebugInfo">
		<xsl:param name="debugId"/>
		<xsl:param name="contextItem"/>		
		
		<xsl:if test="$debugging">
			<j:map key="{concat('--------------',$debugId,'--------------',generate-id($contextItem))}">
				<j:string key="XPath"><xsl:sequence select="imf:xpath-string($contextItem)"/></j:string>
			</j:map>
		</xsl:if>
		
	</xsl:function>
	
</xsl:stylesheet>