<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ep="http://www.imvertor.org/schema/endproduct" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:functx="http://www.functx.com" 
	xmlns:html="http://www.w3.org/1999/xhtml"
	version="2.0">
	
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes" />

	<xsl:include href="Documentation.xsl"/>
	
	<xsl:variable name="message-sets" select="/ep:message-sets" />

	<!-- This variabele defines the type of output and can take the next values:
		 * json
		 * hal+json
		 * geojson	-->
	
	<xsl:variable name="serialisation" select="$message-sets/ep:parameters/ep:parameter[ep:name='serialisation']/ep:value"/>
	<xsl:variable name="stylesheet-code" as="xs:string">YAMLH</xsl:variable>
	<xsl:variable name="standard-yaml-headers-url" select="concat(imf:get-config-parameter('standard-components-url'),imf:get-config-parameter('standard-components-file'),imf:get-config-parameter('standard-yaml-headers-path'))"/>
	<xsl:variable name="standard-yaml-parameters-url" select="concat(imf:get-config-parameter('standard-components-url'),imf:get-config-parameter('standard-components-file'),imf:get-config-parameter('standard-yaml-parameters-path'))"/>
	<xsl:variable name="standard-yaml-responses-url" select="concat(imf:get-config-parameter('standard-components-url'),imf:get-config-parameter('standard-components-file'),imf:get-config-parameter('standard-yaml-responses-path'))"/>
	<xsl:variable name="standard-json-components-url" select="concat(imf:get-config-parameter('standard-components-url'),imf:get-config-parameter('standard-components-file'),imf:get-config-parameter('standard-json-components-path'))"/>
	<xsl:variable name="standard-json-gemeente-components-url" select="concat(imf:get-config-parameter('standaard-organisatie-components-url'),imf:get-config-parameter('standard-organisatie-components-file'),imf:get-config-parameter('standard-json-components-path'))"/>
	<xsl:variable name="geonovum-yaml-parameters-url" select="concat(imf:get-config-parameter('geonovum-components-url'),imf:get-config-parameter('geonovum-yaml-parameters-file'))"/>

	<xsl:variable name="Response406Required" select="boolean(//ep:construct/ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external')"/>
	
	<xsl:template match="ep:message-sets">
		<xsl:apply-templates select="ep:message-set"/>
	</xsl:template>

	<xsl:template match="ep:message-set">
	
		<xsl:variable name="KVname">
			<xsl:value-of select="../ep:name"/>
		</xsl:variable>
		
		<xsl:variable name="chars2bTranslated" select="translate($KVname,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ','')">
			<!-- Contains all characters which need to be translated which are all characters execept the a to z and A to Z. -->
		</xsl:variable>
		<xsl:variable name="normalizedKVname">
			<!-- The normalized name of the interface is equal the the name of the interface except that all characters other 
				 than a to z and A to Z are translated to underscores. -->
			<xsl:variable name="chars2bTranslated2">
				<!-- Within the translate function for each char to be translated there has to be an underscore. Since the amount of special 
					 chars is variable we have to determine the amount of underscores to be used within the translate function. -->
				<xsl:variable name="lengthChars2bTranslated" select="string-length($chars2bTranslated)" as="xs:integer"/>
				<xsl:sequence select="imf:determineAmountOfUnderscores($lengthChars2bTranslated)"/>
			</xsl:variable>
			<!-- Finally the string is actually translated using the variable. -->
			<xsl:value-of select="lower-case(translate($KVname,$chars2bTranslated,$chars2bTranslated2))"/>
		</xsl:variable>
		<xsl:variable name="major-version">
			<xsl:choose>
				<xsl:when test="contains(ep:patch-number,'.')">
					<xsl:value-of select="substring-before(ep:patch-number,'.')"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- If no dot is present within the patch-number. -->
					<xsl:sequence select="imf:msg(.,'WARNING','The version-number ([1]) does not contain a dot.', (ep:patch-number))" />			
					<xsl:value-of select="ep:patch-number"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Here the yaml header is generated. -->
		<xsl:text>openapi: 3.0.0</xsl:text>
        <xsl:text>&#xa;servers:</xsl:text>
		<xsl:text>&#xa;  - description: "SwaggerHub API Auto Mocking"</xsl:text>
		<xsl:text>&#xa;    url: https://virtserver.swaggerhub.com/VNGRealisatie/api/</xsl:text><xsl:value-of select="concat($normalizedKVname,'/v', $major-version)"/>
		<xsl:text>&#xa;  - description: "Referentie-implementatie"</xsl:text>
		<xsl:text>&#xa;    url: https://www.voorbeeldgemeente.nl/api/</xsl:text><xsl:value-of select="concat($normalizedKVname,'/v', $major-version)"/>
        <xsl:text>&#xa;info:</xsl:text>
		<xsl:text>&#xa;  title: </xsl:text><xsl:value-of select="$KVname"/>
		<xsl:text>&#xa;  description: "</xsl:text> <xsl:apply-templates select="ep:documentation"><xsl:with-param name="description" select="'no'"/><xsl:with-param name="pattern" select="'no'"/></xsl:apply-templates><xsl:text>"</xsl:text>
		<!--xsl:text>&#xa;  description: "</xsl:text> <xsl:value-of select="normalize-space(ep:documentation)"/><xsl:text>"</xsl:text-->
        <xsl:text>&#xa;  version: "</xsl:text><xsl:value-of select="ep:patch-number"/><xsl:text>"</xsl:text>
		<xsl:text>&#xa;  x-imvertor-generator-version: "</xsl:text><xsl:value-of select="../ep:parameters/ep:parameter[ep:name='imvertor-generator-version']/ep:value"/><xsl:text>"</xsl:text>
		<xsl:text>&#xa;  x-yamlCompiler-stylesheets-version: "</xsl:text><xsl:value-of select="imf:get-config-parameter('yamlCompiler-stylesheets-version')"/><xsl:text>"</xsl:text>
		<xsl:text>&#xa;  contact:</xsl:text>
		<xsl:text>&#xa;    url: </xsl:text><xsl:value-of select="/ep:message-sets/ep:parameters/ep:parameter[ep:name='project-url']/ep:value"/>
		<xsl:if test="/ep:message-sets/ep:parameters/ep:parameter[ep:name='administrator-e-mail']/ep:value">
			<xsl:text>&#xa;    email: </xsl:text><xsl:value-of select="/ep:message-sets/ep:parameters/ep:parameter[ep:name='administrator-e-mail']/ep:value"/>
		</xsl:if>
        <xsl:text>&#xa;  license:</xsl:text>
        <xsl:text>&#xa;    name: European Union Public License, version 1.2 (EUPL-1.2)</xsl:text>
        <xsl:text>&#xa;    url: https://eupl.eu/1.2/nl/</xsl:text>
		<xsl:text>&#xa;paths:</xsl:text>
		<xsl:for-each-group select="ep:message" group-by="ep:name">
			<xsl:sort select="ep:name" order="ascending"/>
			<!-- Loop over all ep:message elements. -->
			<xsl:variable name="messageName" select="current-grouping-key()"/>
			<xsl:text>&#xa;  </xsl:text><xsl:value-of select="$messageName" /><xsl:text>:</xsl:text>
			<xsl:apply-templates select="current-group()">
				<xsl:sort select="ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value"/>
			</xsl:apply-templates>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="ep:message">
		<!-- This template processes all ep:message elements grouped by their name. -->
		<xsl:variable name="tag" select="ep:parameters/ep:parameter[ep:name='tag']/ep:value"/>
		<xsl:variable name="rawMessageName" select="ep:name" />
		<xsl:variable name="rawCustomPathFacet" select="ep:parameters/ep:parameter[ep:name='customPathFacet']/ep:value"/>
		<xsl:variable name="customPathFacet">
			<xsl:choose>
				<xsl:when test="substring($rawCustomPathFacet,1,1) = '/' and substring($rawCustomPathFacet,string-length($rawCustomPathFacet),1) = '/'">
					<xsl:sequence select="imf:msg(.,'WARNING','The custom-path-facet [1] within the message [2] contains 2 slashes. Remove them.',($rawCustomPathFacet,$rawMessageName))"/>
					<xsl:value-of select="substring-before(substring-after($rawCustomPathFacet,'/'),'/')"/>
				</xsl:when>
				<xsl:when test="substring($rawCustomPathFacet,1,1) = '/'">
					<xsl:sequence select="imf:msg(.,'WARNING','The custom-path-facet [1] within the message [2] contains a slash. Remove it.',($rawCustomPathFacet,$rawMessageName))"/>
					<xsl:value-of select="substring-after($rawCustomPathFacet,'/')"/>
				</xsl:when>
				<xsl:when test="substring($rawCustomPathFacet,string-length($rawCustomPathFacet),1) = '/'">
					<xsl:sequence select="imf:msg(.,'WARNING','The custom-path-facet [1] within the message [2] contains a slash. Remove it.',($rawCustomPathFacet,$rawMessageName))"/>
					<xsl:value-of select="substring-before($rawCustomPathFacet,'/')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$rawCustomPathFacet"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="messageName">
			<xsl:choose>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='customPathFacet'])) and contains($rawMessageName,$customPathFacet)">
					<xsl:value-of select="substring-before($rawMessageName,concat('/',$customPathFacet))"/><xsl:value-of select="substring-after($rawMessageName,concat('/',$customPathFacet))"/>
				</xsl:when>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='customPathFacet'])) and not(contains($rawMessageName,$customPathFacet))">
					<xsl:sequence select="imf:msg(.,'WARNING','The custom-path-facet [1] has been declared but it is not used within the message [2].',($customPathFacet,$rawMessageName))"/>
					<xsl:value-of select="$rawMessageName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$rawMessageName"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="construct" select="./ep:seq/ep:construct/ep:type-name"/>
		<xsl:variable name="meervoudigeNaam" select="//ep:message-set/ep:construct[ep:tech-name = $construct]/ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
		<xsl:variable name="documentation">
			<xsl:text></xsl:text><xsl:apply-templates select="ep:documentation"><xsl:with-param name="description" select="'no'"/><xsl:with-param name="pattern" select="'no'"/></xsl:apply-templates><xsl:text></xsl:text>
		</xsl:variable>
		<xsl:variable name="berichttype" select="ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value"/>
		<xsl:variable name="messagetype" select="ep:parameters/ep:parameter[ep:name='messagetype']/ep:value"/>
		<xsl:choose>
			<xsl:when test="(contains($berichttype,'Gr') or contains($berichttype,'Gc')) and $messagetype = 'request'">
				<!-- This processes all ep:message elements representing the request tree of the Gr and Gc messages. -->
				<xsl:if test="$debugging">
					# ---------Debuglocatie-01000,  XPath: <xsl:sequence select="imf:xpath-string(.)"/>
				</xsl:if>
				<xsl:variable name="operationId">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[ep:name='operationId']/ep:value !=''">
							<xsl:value-of select="ep:parameters/ep:parameter[ep:name='operationId']/ep:value"/>
						</xsl:when>
						<xsl:when test="contains($berichttype,'Gr')">
							<xsl:value-of select="concat('getResource',ep:tech-name)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('getCollection',ep:tech-name)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="count(//ep:message[ep:parameters[ep:parameter[ep:name='messagetype' and ep:value='request'] and ep:parameter[ep:name='operationId' and ep:value = $operationId]]]) > 1 
							 or count(//ep:message/ep:tech-name = $operationId) > 1">
					<xsl:sequence select="imf:msg(.,'ERROR','There is more than one message having the operationId [1].', ($operationId))" />								
				</xsl:if>
				<!-- The tv custom_path_facet should, if present, have the correct format without a slash. We remove slashes from the tv but also generate a warning if a slash is present. -->
				<xsl:variable name="messageCategory" select="ep:parameters/ep:parameter[ep:name='messageCategory']/ep:value"/>
				<xsl:variable name="relatedResponseMessage">
					<xsl:sequence select="//ep:message[ep:name = $rawMessageName and ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value = $berichttype]"/>
				</xsl:variable>
				<xsl:variable name="responseConstructName" select="$relatedResponseMessage/ep:message/ep:seq/ep:construct/ep:type-name"/>

				<xsl:variable name="meervoudigeNaamResponseTree" select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]/ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameter[ep:name='berichtcode' and contains(ep:value,$berichttype)]]/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
				
				<xsl:variable name="determinedUriStructure">
					<!-- This variable contains a structure determined from the messageName. -->
					<ep:uriStructure name="{$rawMessageName}" customPathFacet="{$customPathFacet}">
						<xsl:choose>
							<xsl:when test="contains($messageName,'{') and contains($messageName,'/')">
								<xsl:sequence select="imf:determineUriStructure(substring-after($messageName,'/'))"/>
							</xsl:when>
							<xsl:when test="contains($messageName,'/')">
								<ep:uriPart>
									<ep:entityName><xsl:value-of select="lower-case(substring-after($messageName,'/'))"/></ep:entityName>
								</ep:uriPart>
							</xsl:when>
						</xsl:choose>
					</ep:uriStructure>
				</xsl:variable>
				<xsl:variable name="calculatedUriStructure">
					<!-- This  variable contains a similar structure as the variable determinedUriStructure but this time determined from 
						 the request tree. -->
					<ep:uriStructure name="{$rawMessageName}" customPathFacet="{$customPathFacet}">
						<xsl:choose>
							<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $construct])">
								<xsl:sequence select="imf:msg(.,'WARNING','There is no global construct [1].',$construct)"/>
							</xsl:when>
							<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $construct]/ep:parameters/ep:parameter[ep:name='meervoudigeNaam'])">
								<xsl:sequence select="imf:msg(.,'WARNING','The class [1] within message [2] does not have a tagged value naam in meervoud, define one.',($construct,$rawMessageName))"/>
							</xsl:when>
							<xsl:otherwise>
								<ep:uriPart>
									<ep:entityName original="{$meervoudigeNaam}"><xsl:value-of select="lower-case($meervoudigeNaam)"/></ep:entityName>
									<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $construct]" mode="getParameters"/>
								</ep:uriPart>
								<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $construct]" mode="getUriPart"/>
							</xsl:otherwise>
						</xsl:choose>
					</ep:uriStructure>
				</xsl:variable>
				<xsl:variable name="checkedUriStructure">
					<!-- Within this variable the variables determinedUriStructure and the calculatedUriStructure are compared with eachother
						 and during that process a comparable structure as in those variables is generated. It's also determined if a parameter
						 is a query or a path parameter. -->
					<xsl:variable name="checkOnParameters">
						<xsl:for-each select="$determinedUriStructure//ep:uriPart">
							<xsl:if test="contains(ep:entityName,'{') or contains(ep:entityName,'}')">Y</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($checkOnParameters,'Y')">
							<!-- Within the path 2 parameter uriparts are placed after eachother. -->
							<xsl:sequence select="imf:msg(.,'WARNING','Within the message [1] 2 parameters are placed after eachother.', ($rawMessageName))" />			
							<ep:uriStructure/>
						</xsl:when>
						<xsl:when test="count($determinedUriStructure//ep:uriPart) > count($calculatedUriStructure//ep:uriPart) or not($calculatedUriStructure//ep:uriPart)">
							<!-- If the amount of entities withn the determined structure is larger than within the calculated structure
								 comparisson isn't possible and a warnings is generated. The structure within the padtype class doesn't fit with the structure within the query tree.
								 This might be caused by names not being equal within both structures or by missing structure parts within the query tree. -->
							<xsl:sequence select="imf:msg(.,'WARNING','The structure of the padtype class within the message [1] does not comply with the structure within the query tree.', ($rawMessageName))" />			
							<ep:uriStructure/>
						</xsl:when>
						<xsl:otherwise>
							<!-- Process the calculated uristructure with the checkUriStructure template. -->
							<xsl:for-each select="$calculatedUriStructure/ep:uriStructure">
								<ep:uriStructure>
									<xsl:call-template name="checkUriStructure">
										<xsl:with-param name="uriPart2Check" select="1"/>
										<xsl:with-param name="determinedUriStructure" select="$determinedUriStructure"/>
										<xsl:with-param name="calculatedUriStructure" select="$calculatedUriStructure"/>
										<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
									</xsl:call-template>
								</ep:uriStructure>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="analyzedResponseStructure">
					<!-- Within this variable it's searched for characteristics of the message. -->
					<ep:analyzedStructure name="{$rawMessageName}" responseConstructName="{$responseConstructName}">
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]" mode="getCharacteristics"/>
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]" mode="getConstruct4Characteristics"/>
					</ep:analyzedStructure>
				</xsl:variable>

				<!-- If the message contains GM types the following variable is true. -->
				<xsl:variable name="acceptCrsParamPresent" select="boolean($analyzedResponseStructure//ep:hasGMtype)"/>
				
				<xsl:if test="$checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0 
								and empty(following-sibling::ep:uriPart[ep:param])]">

					<!-- If the checkedUriStructure contains uriparts with entitynames that are not part of the path and without param elements
						 a warning is generated. -->
					<xsl:variable name="falseAndEmptyUriParts">
						<xsl:for-each select="$checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0]">
							<xsl:value-of select="ep:entityName"/>
							<xsl:if test="following-sibling::ep:uriPart">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($falseAndEmptyUriParts,',')">
							<xsl:sequence select="imf:msg(.,'WARNING','The request tree of the message [1] contains empty entities ([2]) which are not part of the message.', ($messageName,$falseAndEmptyUriParts))" />			
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:msg(.,'WARNING','The request tree of the message [1] contains the empty entity ([2]) which is not part of the message.', ($messageName,$falseAndEmptyUriParts))" />			
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				<!--xsl:if test="$debugging and ($checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0 
					and empty(following-sibling::ep:uriPart[ep:param])])"-->
				<xsl:if test="$debugging">
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/analyzedResponseStructure/get',generate-id($analyzedResponseStructure/.),'message',translate(substring-after(ep:name,'/'),'/','-'),'.xml')}" method="xml">
						<xsl:sequence select="$analyzedResponseStructure"/>
					</xsl:result-document>

					<!--xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/message/',$messageCategory,'message-',ep:tech-name,'-',generate-id(),'.xml')}" method="xml">
						<xsl:element name="{concat('ep:',$messageCategory,'message')}">
							<xsl:attribute name="requestbodyConstructName" select="$requestbodyConstructName"/>
							<xsl:attribute name="responseConstructName" select="$responseConstructName"/>
							<xsl:sequence select="$requestbodymessage"/>
							<xsl:sequence select="$relatedResponseMessage"/>
						</xsl:element>
					</xsl:result-document-->
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/message/uriStructure-message-',$messageCategory,'-',ep:tech-name,'-',generate-id(),'.xml')}" method="xml">
						<uriStructure construct="{$construct}">
							<determinedUriStructure>
								<xsl:sequence select="$determinedUriStructure" />
							</determinedUriStructure>
							<calculatedUriStructure>
								<xsl:sequence select="$calculatedUriStructure" />
							</calculatedUriStructure>
							<checkedUriStructure>
								<xsl:sequence select="$checkedUriStructure" />
							</checkedUriStructure>
						</uriStructure>
					</xsl:result-document>
				</xsl:if>
				
				<!-- If desired we could also generate a warning which states the message name as derived from the calculated urstructure.
					 For now this has been disabled. -->
<?x				<xsl:variable name="calculatedMessageName">
					<xsl:for-each select="$calculatedUriStructure//ep:uriPart">
						<xsl:text>/</xsl:text><xsl:value-of select="ep:entityName"/>
						<xsl:for-each select="ep:param">
							<xsl:text>/{</xsl:text><xsl:value-of select="ep:name"/><xsl:text>}</xsl:text>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:if test="$messageName != $calculatedMessageName">
					<!--<xsl:message select="concat('WARNING: The messagename (',$messageName,') is not correct, according to the request tree in the model it should be ',$calculatedMessageName,'.')"/>-->
					<xsl:sequence select="imf:msg(.,'WARNING','The messagename ([1]) is not correct, according to the request tree in the model it should be [2].', ($messageName,$calculatedMessageName))" />			
				</xsl:if> ?>
				
				<xsl:variable name="method">get</xsl:variable>
				
				<xsl:variable name="expand" as="xs:boolean">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[upper-case(ep:name)='EXPAND']/ep:value = 'true' and $serialisation = 'hal+json'">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- Aangezien het uitgangspunt is dat in de parameters class expliciet een 'expand' attribute (dus parameter) wordt gedefinieerd
					 wordt gecheckt of deze wel terecht gedefiniëerd wordt. Dit is niet het geval als er geen hal+json wordt gegenereerd en/of als er 
					 in de onderliggende resources geen non-id type attributen voorkomen. Wel mag er natuurlijk voor worden gekozen geen expand te
					 definiëren terwijl dat wel zou mogen. -->
				<xsl:choose>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='EXPAND'] and $serialisation = 'json'">
						<xsl:sequence select="imf:msg(.,'ERROR','An expand parameter is only applicable for hal+json, remove it from the [1] message [2].', ($method, $messageName))" />			
					</xsl:when>
					<xsl:when test="$expand = false() and $checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='EXPAND']">
						<xsl:sequence select="imf:msg(.,'WARNING','An expand parameter is not applicable for the [1] message [2], remove it.', ($messageName))" />			
					</xsl:when>
				</xsl:choose>
				
<?x				<xsl:variable name="pagination" as="xs:boolean">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[ep:name='pagination']/ep:value = 'true'">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> ?>
				<!-- Aangezien het uitgangspunt is dat in de parameters class expliciet een 'page' en 'pagesize' attribute (dus parameter) wordt gedefinieerd
					 wordt gecheckt of pagination van toepassing is als deze gedefiniëerd zijn. 
					 Wel mag er natuurlijk voor worden gekozen een page attribute te definiëren terwijl dat voor het bericht niet strikt noodzakelijk is.
					 Daarnaast wordt ook gecheckt of er wel een 'page' parameter is gedefinieerd als er een 'pagesize' parameter is gedefinieerd. -->
				<xsl:choose>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGE'] and not(contains(upper-case($berichttype),'GC'))">
						<xsl:sequence select="imf:msg(.,'ERROR','A page parameter is not applicable for the [1] message [2], remove it.', ($method, $messageName))" />			
					</xsl:when>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGESIZE'] and not(contains(upper-case($berichttype),'GC'))">
						<xsl:sequence select="imf:msg(.,'ERROR','A pagesize parameter is not applicable for the [1] message [2], remove it', ($method, $messageName))" />			
					</xsl:when>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGESIZE'] and empty($checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGE']) and upper-case($berichttype) = 'GC'">
						<xsl:sequence select="imf:msg(.,'ERROR','A pagesize parameter is not applicable for the [1] message [2] since no page parameter has been created, remove it or create a page parameter.', ($method, $messageName))" />			
					</xsl:when>
				</xsl:choose>
				
<?x				<xsl:variable name="sort" as="xs:boolean">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[ep:name='sort']/ep:value = 'true'">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> ?>
				<!-- Aangezien het uitganspunt is dat in de parameters class expliciet een 'sort' attribute (dus parameter) wordt gedefinieerd
					 wordt gecheckt of deze wel gedefiniëerd is als sorting van toepassing is. 
					 Wel mag er natuurlijk voor worden gekozen een sort attribute te definiëren terwijl dat voor het bericht niet strikt noodzakelijk is. -->
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='SORTEER'] and not(contains(upper-case($berichttype),'GC'))">
					<xsl:sequence select="imf:msg(.,'ERROR','A sorteer parameter is not applicable for the [1] message [2], remove it', ($method,$messageName))" />			
				</xsl:if>
				
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[(empty(@path) or @path = 'false') and (not(@position) or @position='')]">
					<xsl:sequence select="imf:msg(.,'WARNING','On one or more query parameters on the [1] message [2] no tagged value Positie has been defined. These parameters will be sorted alphabetically!', ($method, $messageName))" />			
				</xsl:if>
				
				<!-- For each message the next structure is generated. -->
				<xsl:text>&#xa;    </xsl:text><xsl:value-of select="$method"/><xsl:text>:</xsl:text>
				<xsl:text>&#xa;      operationId: </xsl:text><xsl:value-of select="$operationId" />
				<xsl:text>&#xa;      description: "</xsl:text><xsl:value-of select="$documentation" /><xsl:text>"</xsl:text>
				<xsl:if test="$acceptCrsParamPresent or
								$checkedUriStructure//ep:uriPart/ep:param[@path = 'true'] or 
								$checkedUriStructure//ep:uriPart/ep:param[empty(@path) or @path = 'false']">
					<!-- If parameters apply the parameters section is generated. -->
					<xsl:text>&#xa;      parameters: </xsl:text>
					<xsl:if test="$acceptCrsParamPresent">
						<!-- If accept-Crs-parameter applies that parameter is generated. -->
						<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$geonovum-yaml-parameters-url,'acceptCrs&quot;')"/>
					</xsl:if>

					<xsl:for-each select="$checkedUriStructure//ep:uriPart/ep:param">
						<xsl:sort order="ascending" select="@position" data-type="number"/>
						<xsl:sort order="ascending" select="ep:name"/>
						<!-- Loop over the ep:param elements within the checkeduristructure and generate for each of them a path or a query parameter. -->
						<xsl:choose>
							<xsl:when test="@path = 'true'">
								<!-- Loop over de path ep:param elements in ascending order (by ep:name) within the checkeduristructure and generate for each of them a path parameter. -->
								<xsl:variable name="incomingType" select="lower-case(ep:data-type)"/>
								<xsl:variable name="incomingTypeName" select="lower-case(ep:type-name)"/>
								<xsl:variable name="datatype">
									<xsl:call-template name="deriveDataType">
										<xsl:with-param name="incomingType" select="$incomingType"/>
										<xsl:with-param name="incomingTypeName" select="$incomingTypeName"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="ep:outside-ref=('VNGR','VNG-GENERIEK')">
										<xsl:text>&#xa;        - in: path</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: true</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-json-gemeente-components-url,ep:type-name,'&quot;')"/>
									</xsl:when>
									<?x							<xsl:when test="upper-case(ep:name) = 'UUID'">
									<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'uuid&quot;')"/>
								</xsl:when> ?>
									<xsl:when test="ep:data-type">
										<xsl:text>&#xa;        - in: path</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: true</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
										<xsl:variable name="format">
											<xsl:call-template name="deriveFormat">
												<xsl:with-param name="incomingType" select="$incomingType"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="facets">
											<xsl:call-template name="deriveFacets">
												<xsl:with-param name="incomingType" select="$incomingType"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:value-of select="$format"/>
										<xsl:value-of select="$facets"/>
										<xsl:if test="ep:example">
											<xsl:text>&#xa;          example: </xsl:text><xsl:value-of select="ep:example"/>
										</xsl:if>
									</xsl:when>
									<xsl:when test="ep:type-name">
										<xsl:text>&#xa;        - in: path</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: true</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;#/components/schemas/',ep:type-name,'&quot;')"/>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="empty(@path) or @path = 'false'">
								<xsl:if test="$debugging">
									# ---------Debuglocatie-01000a,  XPath: <xsl:sequence select="imf:xpath-string(.)"/>
								</xsl:if>
								<!-- Loop over de query ep:param elements in ascending order (by ep:name) within the checkeduristructure and generate for each of them a query parameter. -->
								<xsl:variable name="type-name">
									<xsl:if test="ep:type-name">
										<xsl:value-of select="ep:type-name"/>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<!-- Als de expand parameter toegestaan is en ook voorkomt in de parametersclass wordt een referentie naar het expand component in de common.yaml geplaatst. -->
									<xsl:when test="$expand = true() and upper-case(ep:name)='EXPAND'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'expand&quot;')"/>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'PAGESIZE'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'pageSize&quot;')"/>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'PAGE'">
										<xsl:text>&#xa;        - in: query</xsl:text><xsl:text></xsl:text>
										<xsl:text>&#xa;          name: page</xsl:text>
										<xsl:text>&#xa;          description: "Een pagina binnen de gepagineerde resultatenset."</xsl:text>
										<xsl:text>&#xa;          required: false</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            type: integer</xsl:text>
										<xsl:text>&#xa;            minimum: 1</xsl:text>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'SORTEER'">
										<xsl:text>&#xa;        - in: query</xsl:text>
										<xsl:text>&#xa;          name: sorteer</xsl:text>
										<xsl:text>&#xa;          description: "Aangeven van de sorteerrichting van resultaten. Deze query-parameter accepteert een lijst van velden waarop gesorteerd moet worden gescheiden door een komma. Door een minteken (“-”) voor de veldnaam te zetten wordt het veld in aflopende sorteervolgorde gesorteerd."</xsl:text>
										<xsl:text>&#xa;          required: false</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            type: string</xsl:text>
										<xsl:text>&#xa;            example: -prio,aanvraag_datum</xsl:text>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'FIELDS'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'fields&quot;')"/>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'PEILDATUM'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'peildatum&quot;')"/>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'DATUMTOTENMET'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'datumtotenmet&quot;')"/>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'DATUMVAN'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'datumvan&quot;')"/>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'API-VERSION'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'api-version&quot;')"/>
									</xsl:when>
									<xsl:when test="ep:outside-ref=('VNGR','VNG-GENERIEK')">
										<xsl:variable name="required">
											<xsl:choose>
												<xsl:when test="not(empty(ep:min-occurs)) and ep:min-occurs > 0">true</xsl:when>
												<xsl:otherwise>false</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:text>&#xa;        - in: query</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="translate(ep:name/@original,'.','_')" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: </xsl:text><xsl:value-of select="$required"/>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-json-gemeente-components-url,ep:type-name,'&quot;')"/>
									</xsl:when>
									<xsl:when test="ep:data-type">
										<xsl:variable name="incomingType" select="lower-case(ep:data-type)"/>
										<xsl:variable name="incomingTypeName" select="lower-case(ep:type-name)"/>
										<xsl:variable name="datatype">
											<xsl:call-template name="deriveDataType">
												<xsl:with-param name="incomingType" select="$incomingType"/>
												<xsl:with-param name="incomingTypeName" select="$incomingTypeName"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="required">
											<xsl:choose>
												<xsl:when test="not(empty(ep:min-occurs)) and ep:min-occurs > 0">true</xsl:when>
												<xsl:otherwise>false</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:text>&#xa;        - in: query</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="translate(ep:name/@original,'.','_')" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: </xsl:text><xsl:value-of select="$required"/>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
										<xsl:variable name="format">
											<xsl:call-template name="deriveFormat">
												<xsl:with-param name="incomingType" select="$incomingType"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="facets">
											<xsl:call-template name="deriveFacets">
												<xsl:with-param name="incomingType" select="$incomingType"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:value-of select="$format"/>
										<xsl:value-of select="$facets"/>
										<xsl:if test="ep:example">
											<xsl:text>&#xa;            example: </xsl:text><xsl:value-of select="ep:example"/>
										</xsl:if>
									</xsl:when>
									<xsl:when test="$type-name != '' and $message-sets//ep:message-set/ep:construct[ep:tech-name=$type-name and ep:parameters/ep:parameter[ep:name = 'type']/ep:value = 'simpletype-class']">
										<!-- Deze when is voor het afhandelen van request parameters die gebruik maken van lokale datatypen. -->
										<xsl:variable name="required">
											<xsl:choose>
												<xsl:when test="not(empty(ep:min-occurs)) and ep:min-occurs > 0">true</xsl:when>
												<xsl:otherwise>false</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:text>&#xa;        - in: query</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="translate(ep:name/@original,'.','_')" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: </xsl:text><xsl:value-of select="$required"/>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:apply-templates select="$message-sets//ep:message-set/ep:construct[ep:tech-name=$type-name and ep:parameters/ep:parameter[ep:name = 'type']/ep:value = 'simpletype-class']" mode="simpletype-class"/> 
									</xsl:when>
									<xsl:when test="ep:type-name">
										<xsl:variable name="required">
											<xsl:choose>
												<xsl:when test="not(empty(ep:min-occurs)) and ep:min-occurs > 0">true</xsl:when>
												<xsl:otherwise>false</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:text>&#xa;        - in: query</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="translate(ep:name/@original,'.','_')" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: </xsl:text><xsl:value-of select="$required"/>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;#/components/schemas/',ep:type-name,'&quot;')"/>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>&#xa;      responses:</xsl:text>
				<xsl:call-template name="response200">
					<xsl:with-param name="berichttype" select="$berichttype"/>
					<xsl:with-param name="meervoudigeNaamResponseTree" select="$meervoudigeNaamResponseTree"/>
					<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
					<xsl:with-param name="responseConstructName" select="$responseConstructName"/>
				</xsl:call-template>
				<xsl:variable name="queryParamsPresent" select="boolean($checkedUriStructure//ep:uriPart/ep:param[@path = 'false'] or empty($checkedUriStructure//ep:uriPart/ep:param/@path))"/>
				<xsl:variable name="pathParamsPresent" select="boolean($checkedUriStructure//ep:uriPart/ep:param[@path = 'true'])"/>
				<xsl:sequence select="imf:Foutresponses($berichttype,$queryParamsPresent,$pathParamsPresent,$acceptCrsParamPresent)"/>
				<xsl:text>&#xa;      tags: </xsl:text>
				<xsl:text>&#xa;      - </xsl:text><xsl:value-of select="$tag" />
			</xsl:when>
			<xsl:when test="(contains($berichttype,'Po') or contains($berichttype,'Pa') or contains($berichttype,'Pu')) and $messagetype = 'request'">
				<xsl:if test="$debugging">
					# ---------Debuglocatie-02000,  XPath: <xsl:sequence select="imf:xpath-string(.)"/>
				</xsl:if>
				<xsl:variable name="messageCategory" select="ep:parameters/ep:parameter[ep:name='messageCategory']/ep:value"/>
				<xsl:variable name="operationId">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[ep:name='operationId']/ep:value !=''">
							<xsl:value-of select="ep:parameters/ep:parameter[ep:name='operationId']/ep:value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
								<xsl:when test="$messageCategory = 'Pa'">patch</xsl:when>
								<xsl:when test="$messageCategory = 'Po'">post</xsl:when>
								<xsl:when test="$messageCategory = 'Pu'">put</xsl:when>
							</xsl:choose>
							<xsl:value-of select="ep:tech-name" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- This processes al ep:message elements represent the request tree of the Po messages. -->		
				<xsl:variable name="method">
					<xsl:choose>
						<xsl:when test="$messageCategory = 'Pa'">patch</xsl:when>
						<xsl:when test="$messageCategory = 'Po'">post</xsl:when>
						<xsl:when test="$messageCategory = 'Pu'">put</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="requestbodymessage">
					<xsl:sequence select="//ep:message[ep:name = $rawMessageName and ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'requestbody'and ep:parameter[ep:name='berichtcode']/ep:value = $berichttype]]"/>
				</xsl:variable>
				<xsl:variable name="relatedResponseMessage">
					<xsl:sequence select="//ep:message[ep:name = $rawMessageName and ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response'and ep:parameter[ep:name='berichtcode']/ep:value = $berichttype]]"/>
				</xsl:variable>
				<xsl:variable name="responseConstruct" select="$relatedResponseMessage/ep:message/ep:seq/ep:construct/ep:type-name"/>







				<!-- De uitwerking in de uitbecommentarieerde variabele kreeg alleen een waarde als de betreffende responseConstruct ook een parameter met de naam 'berichtcode' had die gelijk was aan de in bewerking zijnde 
					 berichttype (Pa01, Pu01, Po01, etc...).
				     Aangezien een responseConstruct die in meerdere berichten gebruikt wordt in het EP formaat maar voor 1 van die berichten wordt uitgewerkt kan het voorkomen dat voor de andere berichten geen meervoudige 
				     naam kan worden gevonden wat in de yaml code resulteert in een fout. Vandaar dat de tweede vorm van deze variabele is uitgewerkt.
					 De kans is echter dat deze uitwerking weer tot andere fouten leidt. -->
				<xsl:variable name="meervoudigeNaamResponseTree" select="//ep:message-set/ep:construct[ep:tech-name = $responseConstruct]/ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameter[ep:name='berichtcode' and contains(ep:value,$berichttype)]]/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
				<!--xsl:variable name="meervoudigeNaamResponseTree" select="//ep:message-set/ep:construct[ep:tech-name = $responseConstruct]/ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameter[ep:name='berichtcode']/ep:value = $berichttype]/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/-->
				<!--xsl:variable name="meervoudigeNaamResponseTree" select="//ep:message-set/ep:construct[ep:tech-name = $responseConstruct]/ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response']/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/-->









				<xsl:variable name="requestbodyConstructName" select="$requestbodymessage//ep:type-name"/>
				<xsl:variable name="responseConstructName" select="$relatedResponseMessage//ep:type-name"/>

				<xsl:variable name="exampleSleutelEntiteittype">
					<xsl:variable name="construct" select="//ep:message-set/ep:construct[ep:tech-name = $requestbodyConstructName]"/>
					<xsl:value-of select="$construct//ep:construct[ep:parameters/ep:parameter[ep:name='is-id']/ep:value='true']/ep:example"/>
				</xsl:variable>

				<xsl:variable name="determinedUriStructure">
					<!-- This variable contains a structure determined from the messageName. -->
					<ep:uriStructure name="{$rawMessageName}" customPathFacet="{$customPathFacet}">
						<xsl:choose>
							<xsl:when test="contains($messageName,'{') and contains($messageName,'/')">
								<xsl:sequence select="imf:determineUriStructure(substring-after($messageName,'/'))"/>
							</xsl:when>
							<xsl:when test="contains($messageName,'/')">
								<ep:uriPart>
									<ep:entityName original="{substring-after($messageName,'/')}"><xsl:value-of select="lower-case(substring-after($messageName,'/'))"/></ep:entityName>
								</ep:uriPart>
							</xsl:when>
						</xsl:choose>
					</ep:uriStructure>
				</xsl:variable>
				<xsl:variable name="calculatedUriStructure">
					<!-- This  variable contains a similar structure as the variable determinedUriStructure but this time determined from 
						 the request tree. -->
					<ep:uriStructure name="{$rawMessageName}" customPathFacet="{$customPathFacet}">
						<xsl:choose>
							<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $construct])">
								<xsl:sequence select="imf:msg(.,'WARNING','There is no global construct [1].',$construct)"/>
							</xsl:when>
							<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $construct]/ep:parameters/ep:parameter[ep:name='meervoudigeNaam'])">
								<xsl:sequence select="imf:msg(.,'WARNING','The class [1] within message [2] does not have a tagged value naam in meervoud, define one.',($construct,$rawMessageName))"/>
							</xsl:when>
							<xsl:otherwise>
								<ep:uriPart>
									<ep:entityName original="{$meervoudigeNaam}"><xsl:value-of select="lower-case($meervoudigeNaam)"/></ep:entityName>
									<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $construct]" mode="getParameters"/>
								</ep:uriPart>
								<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $construct]" mode="getUriPart"/>
							</xsl:otherwise>
						</xsl:choose>
					</ep:uriStructure>
				</xsl:variable>
				<xsl:variable name="checkedUriStructure">
					<!-- Within this variable the variables determinedUriStructure and the calculatedUriStructure are compared with eachother
						 and durng that process a comparable structure as in those variables is generated. It's also determined if a parameter
						 is a query or a path parameter. -->
					<xsl:variable name="checkOnParameters">
						<xsl:for-each select="$determinedUriStructure//ep:uriPart">
							<xsl:if test="contains(ep:entityName,'{') or contains(ep:entityName,'}')">Y</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($checkOnParameters,'Y')">
							<!-- Within the path 2 parameter uriparts are placed after eachother. -->
							<xsl:sequence select="imf:msg(.,'WARNING','Within the message [1] 2 parameters are placed after eachother.', ($rawMessageName))" />			
							<ep:uriStructure/>
						</xsl:when>
						<xsl:when test="count($determinedUriStructure//ep:uriPart) > count($calculatedUriStructure//ep:uriPart) or not($calculatedUriStructure//ep:uriPart)">
							<!-- If the amount of entities within the detremined structure is larger than withn the calculated structure
								 comparisson isn't possible and a warnings is generated. -->
							<xsl:sequence select="imf:msg(.,'WARNING','The amount of entities within the message [1] is larger than the amount of entities within the query tree.', ($rawMessageName))" />			
							<ep:uriStructure/>
						</xsl:when>
						<xsl:otherwise>
							<!-- Process the calculated uristructure with the checkUriStructure template. -->
							<xsl:for-each select="$calculatedUriStructure/ep:uriStructure">
								<ep:uriStructure>
									<xsl:call-template name="checkUriStructure">
										<xsl:with-param name="uriPart2Check" select="1"/>
										<xsl:with-param name="determinedUriStructure" select="$determinedUriStructure"/>
										<xsl:with-param name="calculatedUriStructure" select="$calculatedUriStructure"/>
										<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
									</xsl:call-template>
								</ep:uriStructure>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:if test="$checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0 
					and empty(following-sibling::ep:uriPart[ep:param])]">
					<!-- If the checkedUriStructure contains uriparts with entitynames that are not part of the path and without param elements
						 a warning is generated. -->
					<xsl:variable name="falseAndEmptyUriParts">
						<xsl:for-each select="$checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0]">
							<xsl:value-of select="ep:entityName"/>
							<xsl:if test="following-sibling::ep:uriPart">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($falseAndEmptyUriParts,',')">
							<xsl:sequence select="imf:msg(.,'WARNING','The request tree of the message [1] contains empty entities ([2]) which are not part of the message.', ($messageName,$falseAndEmptyUriParts))" />			
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:msg(.,'WARNING','The request tree of the message [1] contains the empty entity ([2]) which is not part of the message.', ($messageName,$falseAndEmptyUriParts))" />			
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$debugging and ($checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0 
					and empty(following-sibling::ep:uriPart[ep:param])])">
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/message/',$messageCategory,'message-',ep:tech-name,'-',generate-id(),'.xml')}" method="xml">
						<xsl:element name="{concat('ep:',$messageCategory,'message')}">
							<xsl:attribute name="requestbodyConstructName" select="$requestbodyConstructName"/>
							<xsl:attribute name="responseConstructName" select="$responseConstructName"/>
							<xsl:sequence select="$requestbodymessage"/>
							<xsl:sequence select="$relatedResponseMessage"/>
						</xsl:element>
					</xsl:result-document>
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/message/uriStructure-message-',$messageCategory,'-',ep:tech-name,'-',generate-id(),'.xml')}" method="xml">
						<uriStructure>
							<determinedUriStructure>
								<xsl:sequence select="$determinedUriStructure" />
							</determinedUriStructure>
							<calculatedUriStructure>
								<xsl:sequence select="$calculatedUriStructure" />
							</calculatedUriStructure>
							<checkedUriStructure>
								<xsl:sequence select="$checkedUriStructure" />
							</checkedUriStructure>
						</uriStructure>
					</xsl:result-document>
				</xsl:if>
				
				<!-- With the following it's determined if geo-type attributes are present within the requesttree of the post message. -->
				<xsl:variable name="analyzedRequestbodyStructure">
					<!-- Within this variable it's searched for characteristics of the message. -->
					<ep:analyzedStructure name="{$rawMessageName}" requestbodyConstructName="{$requestbodyConstructName}">
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $requestbodyConstructName]" mode="getCharacteristics"/>
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $requestbodyConstructName]" mode="getConstruct4Characteristics"/>
					</ep:analyzedStructure>
				</xsl:variable>
				<xsl:variable name="analyzedResponseStructure">
					<!-- Within this variable it's searched for characteristics of the message. -->
					<ep:analyzedStructure name="{$rawMessageName}" responseConstructName="{$responseConstructName}">
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]" mode="getCharacteristics"/>
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]" mode="getConstruct4Characteristics"/>
					</ep:analyzedStructure>
				</xsl:variable>
								
				<xsl:if test="$debugging">
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/determinedUriStructure/',$messageCategory,generate-id($determinedUriStructure/.),'message',translate(substring-after(ep:name,'/'),'/','-'),'.xml')}"  method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
						<xsl:sequence select="$determinedUriStructure"/>
					</xsl:result-document> 
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/calculatedUriStructure/',$messageCategory,generate-id($calculatedUriStructure/.),'message',translate(substring-after(ep:name,'/'),'/','-'),'.xml')}"  method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
						<xsl:sequence select="$calculatedUriStructure"/>
					</xsl:result-document>
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/checkedUriStructure/',$messageCategory,generate-id($checkedUriStructure/.),'message',translate(substring-after(ep:name,'/'),'/','-'),'.xml')}"  method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
						<xsl:sequence select="$checkedUriStructure"/>
					</xsl:result-document> 
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/analyzedRequestbodyStructure/',$messageCategory,generate-id($analyzedRequestbodyStructure/.),'message',translate(substring-after(ep:name,'/'),'/','-'),'.xml')}"  method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
						<xsl:sequence select="$analyzedRequestbodyStructure"/>
					</xsl:result-document>
					<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/analyzedResponseStructure/',$messageCategory,generate-id($analyzedResponseStructure/.),'message',translate(substring-after(ep:name,'/'),'/','-'),'.xml')}"  method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
						<xsl:sequence select="$analyzedResponseStructure"/>
					</xsl:result-document>
				</xsl:if>					

				<xsl:variable name="queryParamsPresent" select="boolean($checkedUriStructure//ep:uriPart/ep:param[@path = 'false'] or empty($checkedUriStructure//ep:uriPart/ep:param/@path))"/>
				<xsl:variable name="pathParamsPresent" select="false()"/>
				<xsl:variable name="contentCrsParamPresent" select="boolean($analyzedRequestbodyStructure//ep:hasGMtype)"/>
				<xsl:variable name="acceptCrsParamPresent" select="boolean($analyzedResponseStructure//ep:hasGMtype)"/>

				<!-- Een expand parameter is niet van toepassing op een PATCH, POST en PUT bericht. -->
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='EXPAND']">
					<xsl:sequence select="imf:msg(.,'ERROR','An expand parameter is not applicable for [1] messages, remove it from the [2] message.', ($method, $messageName))" />		
				</xsl:if>
				
<?x				<xsl:variable name="pagination" as="xs:boolean">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[ep:name='pagination']/ep:value = 'true' and $method ='post'">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> ?>
				<!-- Aangezien het uitgangspunt is dat in de parameters class expliciet een 'page' en 'pagesize' attribute (dus parameter) wordt gedefinieerd
					 wordt gecheckt of pagination van toepassing is als deze gedefiniëerd zijn. 
					 Wel mag er natuurlijk voor worden gekozen een page attribute te definiëren terwijl dat voor het bericht niet strikt noodzakelijk is.
					 Daarnaast wordt ook gecheckt of er wel een 'page' parameter is gedefinieerd als er een 'pagesize' parameter is gedefinieerd. -->
				<xsl:choose>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGE'] and not(contains(upper-case($berichttype),'PO'))">
						<xsl:sequence select="imf:msg(.,'ERROR','A page parameter is not applicable for [1] messages, remove it from the [2] message.', ($method, $messageName))" />			
					</xsl:when>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGESIZE'] and not(contains(upper-case($berichttype),'PO'))">
						<xsl:sequence select="imf:msg(.,'ERROR','A pagesize parameter is not applicable for [1] messages, remove it from the [2] message.', ($method, $messageName))" />			
					</xsl:when>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGESIZE'] and empty($checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGE'])">
						<xsl:sequence select="imf:msg(.,'ERROR','A pagesize parameter is not applicable for [1] message [2] since no page parameter has been created, remove it or create a page parameter.', ($method, $messageName))" />			
					</xsl:when>
				</xsl:choose>
				
<?x				<xsl:variable name="sort" as="xs:boolean">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[ep:name='sort']/ep:value = 'true' and $method ='post'">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> ?>
				<!-- Aangezien het uitganspunt is dat in de parameters class expliciet een 'sort' attribute (dus parameter) wordt gedefinieerd
					 wordt gecheckt of deze wel gedefiniëerd is als sorting van toepassing is. 
					 Wel mag er natuurlijk voor worden gekozen een sort attribute te definiëren terwijl dat voor het bericht niet strikt noodzakelijk is. -->
				<xsl:choose>
					<xsl:when test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='SORTEER'] and not(contains(upper-case($berichttype),'PO'))">
						<xsl:sequence select="imf:msg(.,'ERROR','A sorteer parameter is not applicable for [1] messages, remove it from the [2] message.', ($method, $messageName))" />			
					</xsl:when>
				</xsl:choose>
				
<?x				<xsl:variable name="fields" as="xs:boolean">
					<xsl:choose>
						<xsl:when test="$method ='post'">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> ?>
				<!-- Aangezien het uitganspunt is dat in de parameters class expliciet een 'sort' attribute (dus parameter) wordt gedefinieerd
					 wordt gecheckt of deze wel gedefiniëerd is als sorting van toepassing is. 
					 Wel mag er natuurlijk voor worden gekozen een sort attribute te definiëren terwijl dat voor het bericht niet strikt noodzakelijk is. -->
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='FIELDS'] and not(contains(upper-case($berichttype),'PO'))">
					<xsl:sequence select="imf:msg(.,'ERROR','A fields parameter is not applicable for [1] messages, remove it from the [2] message.', ($method, $messageName))" />			
				</xsl:if>
				
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[(empty(@path) or @path = 'false') and (not(@position) or @position='')]">
					<xsl:sequence select="imf:msg(.,'WARNING','On one or more query parameters on the [1] message [2] no tagged value Positie has been defined. These parameters will be sorted alphabetically!', ($method, $messageName))" />			
				</xsl:if>
								
				<!-- For each message the next structure is generated. -->
				<xsl:text>&#xa;    </xsl:text><xsl:value-of select="$method"/><xsl:text>:</xsl:text>
				<xsl:text>&#xa;      operationId: </xsl:text><xsl:value-of select="$operationId" />
				<xsl:text>&#xa;      description: "</xsl:text><xsl:value-of select="$documentation" /><xsl:text>"</xsl:text>
				<xsl:if test="($messageCategory = 'Po' and ($contentCrsParamPresent or 
							  $acceptCrsParamPresent)) or
							  $checkedUriStructure//ep:uriPart/ep:param[@path = 'true'] or 
							  $checkedUriStructure//ep:uriPart/ep:param[empty(@path) or @path = 'false']">
					<!-- If Crs-parameters, path or query parameters apply the parameters section is generated. -->
					<xsl:text>&#xa;      parameters: </xsl:text>
					<xsl:if test="$messageCategory = 'Po' and $contentCrsParamPresent">
						<!-- If content-Crs-parameter applies that parameter is generated. -->
						<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$geonovum-yaml-parameters-url,'contentCrs&quot;')"/>
					</xsl:if>
					<xsl:for-each select="$checkedUriStructure//ep:uriPart/ep:param">
						<xsl:sort order="ascending" select="@position" data-type="number"/>
						<xsl:sort order="ascending" select="ep:name"/>
						<!-- Loop over the ep:param elements within the checkeduristructure and generate for each of them a path or a query parameter. -->
						<xsl:choose>
							<xsl:when test="@path = 'true'">
								<xsl:variable name="incomingType" select="lower-case(ep:data-type)"/>
								<xsl:variable name="incomingTypeName" select="lower-case(ep:type-name)"/>
								<xsl:variable name="datatype">
									<xsl:call-template name="deriveDataType">
										<xsl:with-param name="incomingType" select="$incomingType"/>
										<xsl:with-param name="incomingTypeName" select="$incomingTypeName"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="ep:outside-ref=('VNGR','VNG-GENERIEK')">
										<xsl:text>&#xa;        - in: path</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: true</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-json-gemeente-components-url,ep:type-name,'&quot;')"/>
									</xsl:when>
									<!--							<xsl:when test="upper-case(ep:name) = 'UUID'">
								<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'uuid&quot;')"/>
							</xsl:when> -->
									<xsl:when test="ep:data-type">
										<xsl:text>&#xa;        - in: path</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: true</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
										<xsl:variable name="format">
											<xsl:call-template name="deriveFormat">
												<xsl:with-param name="incomingType" select="$incomingType"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="facets">
											<xsl:call-template name="deriveFacets">
												<xsl:with-param name="incomingType" select="$incomingType"/>
											</xsl:call-template>
										</xsl:variable>
										<xsl:value-of select="$format"/>
										<xsl:value-of select="$facets"/>
										<xsl:if test="ep:example">
											<xsl:text>&#xa;          example: </xsl:text><xsl:value-of select="ep:example"/>
										</xsl:if>
									</xsl:when>
									<xsl:when test="ep:type-name">
										<xsl:text>&#xa;        - in: path</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: true</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;#/components/schemas/',ep:type-name,'&quot;')"/>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="empty(@path) or @path = 'false'">
								<xsl:variable name="incomingType" select="lower-case(ep:data-type)"/>
								<xsl:variable name="incomingTypeName" select="lower-case(ep:type-name)"/>
								<xsl:variable name="datatype">
									<xsl:call-template name="deriveDataType">
										<xsl:with-param name="incomingType" select="$incomingType"/>
										<xsl:with-param name="incomingTypeName" select="$incomingTypeName"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="type-name">
									<xsl:if test="ep:type-name">
										<xsl:value-of select="ep:type-name"/>
									</xsl:if>
								</xsl:variable>
								<xsl:if test="$debugging">
									# ---------Debuglocatie-01000b,  XPath: <xsl:sequence select="imf:xpath-string(.)"/>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="upper-case(ep:name) = 'PAGESIZE'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'pageSize&quot;')"/>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'PAGE'">
										<xsl:text>&#xa;        - in: query</xsl:text><xsl:text></xsl:text>
										<xsl:text>&#xa;          name: page</xsl:text>
										<xsl:text>&#xa;          description: "Een pagina binnen de gepagineerde resultatenset."</xsl:text>
										<xsl:text>&#xa;          required: false</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            type: integer</xsl:text>
										<xsl:text>&#xa;            minimum: 1</xsl:text>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'SORTEER'">
										<xsl:text>&#xa;        - in: query</xsl:text>
										<xsl:text>&#xa;          name: sorteer</xsl:text>
										<xsl:text>&#xa;          description: "Aangeven van de sorteerrichting van resultaten. Deze query-parameter accepteert een lijst van velden waarop gesorteerd moet worden gescheiden door een komma. Door een minteken (“-”) voor de veldnaam te zetten wordt het veld in aflopende sorteervolgorde gesorteerd."</xsl:text>
										<xsl:text>&#xa;          required: false</xsl:text>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:text>&#xa;            type: string</xsl:text>
										<xsl:text>&#xa;            example: -prio,aanvraag_datum</xsl:text>
									</xsl:when>
									<xsl:when test="upper-case(ep:name) = 'FIELDS'">
										<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'fields&quot;')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="required">
											<xsl:choose>
												<xsl:when test="not(empty(ep:min-occurs)) and ep:min-occurs > 0">true</xsl:when>
												<xsl:otherwise>false</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:text>&#xa;        - in: query</xsl:text>
										<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="translate(ep:name/@original,'.','_')" />
										<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
										<xsl:text>&#xa;          required: </xsl:text><xsl:value-of select="$required"/>
										<xsl:text>&#xa;          schema:</xsl:text>
										<xsl:choose>
											<xsl:when test="ep:outside-ref=('VNGR','VNG-GENERIEK')">
												<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-json-gemeente-components-url,ep:type-name,'&quot;')"/>
											</xsl:when>
											<xsl:when test="ep:data-type">
												<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
												<xsl:variable name="format">
													<xsl:call-template name="deriveFormat">
														<xsl:with-param name="incomingType" select="$incomingType"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:variable name="facets">
													<xsl:call-template name="deriveFacets">
														<xsl:with-param name="incomingType" select="$incomingType"/>
													</xsl:call-template>
												</xsl:variable>
												<xsl:value-of select="$format"/>
												<xsl:value-of select="$facets"/>
												<xsl:if test="ep:example">
													<xsl:text>&#xa;          example: </xsl:text><xsl:value-of select="ep:example"/>
												</xsl:if>
											</xsl:when>
											<xsl:when test="$type-name != '' and $message-sets//ep:message-set/ep:construct[ep:tech-name=$type-name and ep:parameters/ep:parameter[ep:name = 'type']/ep:value = 'simpletype-class']">
												<!-- Deze when is voor het afhandelen van request parameters die gebruik maken van lokale datatypen. -->
												<xsl:apply-templates select="$message-sets//ep:message-set/ep:construct[ep:tech-name=$type-name and ep:parameters/ep:parameter[ep:name = 'type']/ep:value = 'simpletype-class']" mode="simpletype-class"/> 
											</xsl:when>
											<xsl:when test="ep:type-name">
												<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;#/components/schemas/',ep:type-name,'&quot;')"/>
											</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>	
						
				</xsl:if>
				<xsl:text>&#xa;      requestBody:</xsl:text>
				<xsl:text>&#xa;        content:</xsl:text>
				<xsl:text>&#xa;          application/</xsl:text><xsl:value-of select="$serialisation"/><xsl:text>:</xsl:text>
				<xsl:text>&#xa;            schema:</xsl:text>
				<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$requestbodyConstructName"/><xsl:text>'</xsl:text>
				<xsl:text>&#xa;      responses:</xsl:text>
				<xsl:choose>
					<xsl:when test="$messageCategory = 'Pa' or $messageCategory = 'Pu'">
						<xsl:call-template name="response200">
							<xsl:with-param name="berichttype" select="$berichttype"/>
							<xsl:with-param name="meervoudigeNaamResponseTree" select="$meervoudigeNaamResponseTree"/>
							<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
							<xsl:with-param name="responseConstructName" select="$responseConstructName"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="response201">
							<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
							<xsl:with-param name="responseConstructName" select="$responseConstructName"/>
							<xsl:with-param name="exampleSleutelEntiteittype" select="$exampleSleutelEntiteittype"/>
							<xsl:with-param name="acceptCrsParamPresent" select="$acceptCrsParamPresent"/>
							<xsl:with-param name="messageCategory" select="$messageCategory"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<!-- TODO: De 2e t/m 4e variabele moeten nog op een andere wijze een waarde krijgen. Daarvoor moeten eerst de in het hoofdstuk voor het POST bericht
						       beschreven wijzigingen in het algoritme behorende bij issue #490151 worden geimplementeerd.
							   Die beschrijving moet overigens nog aangepast worden omdat bij een POST bericht de request tree wordt gebruikt voor de 
							   content van het bericht en deze volgens mij niet ook nog eens voor de parameters gebruikt kan worden. -->
				<xsl:sequence select="imf:Foutresponses($berichttype,$queryParamsPresent,$pathParamsPresent,($messageCategory = 'Po' and ($contentCrsParamPresent or 
					$acceptCrsParamPresent)))"/>
				<xsl:text>&#xa;      tags: </xsl:text>
				<xsl:text>&#xa;      - </xsl:text><xsl:value-of select="$tag" />
				
			</xsl:when>
			<xsl:when test="contains($berichttype,'De') and $messagetype = 'request'">
				<!-- This processes all ep:message elements representing the request tree of the Gr and Gc messages. -->
				<xsl:if test="$debugging">
					# ---------Debuglocatie-03000,  XPath: <xsl:sequence select="imf:xpath-string(.)"/>
				</xsl:if>
				<xsl:variable name="operationId">
					<xsl:choose>
						<xsl:when test="ep:parameters/ep:parameter[ep:name='operationId']/ep:value !=''">
							<xsl:value-of select="ep:parameters/ep:parameter[ep:name='operationId']/ep:value"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('deleteResource',ep:tech-name)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="method">delete</xsl:variable>

				<xsl:if test="count(//ep:message[ep:parameters[ep:parameter[ep:name='messagetype' and ep:value='request'] and ep:parameter[ep:name='operationId' and ep:value = $operationId]]]) > 1 
							 or count(//ep:message/ep:tech-name = $operationId) > 1">
					<xsl:sequence select="imf:msg(.,'ERROR','There is more than one message having the operationId [1].', ($operationId))" />								
				</xsl:if>
				<!-- The tv custom_path_facet should, if present, have the correct format without a slash. We remove slashes from the tv but also generate a warning if a slash is present. -->
				<xsl:variable name="messageCategory" select="ep:parameters/ep:parameter[ep:name='messageCategory']/ep:value"/>
				<xsl:variable name="relatedResponseMessage">
					<xsl:sequence select="//ep:message[ep:name = $rawMessageName and ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value = $berichttype]"/>
				</xsl:variable>
				
				
				
				<!--xsl:variable name="responseConstructName" select="$relatedResponseMessage/ep:message/ep:seq/ep:construct/ep:type-name"/>

				<xsl:variable name="meervoudigeNaamResponseTree" select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]/ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameter[ep:name='berichtcode' and contains(ep:value,$berichttype)]]/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/-->
				<!--xsl:variable name="meervoudigeNaamResponseTree" select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]/ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameter[ep:name='berichtcode']/ep:value = $berichttype]/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/-->
				<!--xsl:variable name="meervoudigeNaamResponseTree" select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]/ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response']/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/-->
				
				<xsl:variable name="determinedUriStructure">
					<!-- This variable contains a structure determined from the messageName. -->
					<ep:uriStructure name="{$rawMessageName}" customPathFacet="{$customPathFacet}">
						<xsl:choose>
							<xsl:when test="contains($messageName,'{') and contains($messageName,'/')">
								<xsl:sequence select="imf:determineUriStructure(substring-after($messageName,'/'))"/>
							</xsl:when>
							<xsl:when test="contains($messageName,'/')">
								<ep:uriPart>
									<ep:entityName original="{substring-after($messageName,'/')}"><xsl:value-of select="lower-case(substring-after($messageName,'/'))"/></ep:entityName>
								</ep:uriPart>
							</xsl:when>
						</xsl:choose>
					</ep:uriStructure>
				</xsl:variable>
				<xsl:variable name="calculatedUriStructure">
					<!-- This  variable contains a similar structure as the variable determinedUriStructure but this time determined from 
						 the request tree. -->
					<ep:uriStructure name="{$rawMessageName}" customPathFacet="{$customPathFacet}">
						<xsl:choose>
							<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $construct])">
								<xsl:sequence select="imf:msg(.,'WARNING','There is no global construct [1].',$construct)"/>
							</xsl:when>
							<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $construct]/ep:parameters/ep:parameter[ep:name='meervoudigeNaam'])">
								<xsl:sequence select="imf:msg(.,'WARNING','The class [1] within message [2] does not have a tagged value naam in meervoud, define one.',($construct,$rawMessageName))"/>
							</xsl:when>
							<xsl:otherwise>
								<ep:uriPart>
									<ep:entityName original="{$meervoudigeNaam}"><xsl:value-of select="lower-case($meervoudigeNaam)"/></ep:entityName>
									<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $construct]" mode="getParameters"/>
								</ep:uriPart>
								<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $construct]" mode="getUriPart"/>
							</xsl:otherwise>
						</xsl:choose>
					</ep:uriStructure>
				</xsl:variable>
				<xsl:variable name="checkedUriStructure">
					<!-- Within this variable the variables determinedUriStructure and the calculatedUriStructure are compared with eachother
						 and durng that process a comparable structure as in those variables is generated. It's also determined if a parameter
						 is a query or a path parameter. -->
					<xsl:variable name="checkOnParameters">
						<xsl:for-each select="$determinedUriStructure//ep:uriPart">
							<xsl:if test="contains(ep:entityName,'{') or contains(ep:entityName,'}')">Y</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($checkOnParameters,'Y')">
							<!-- Within the path 2 parameter uriparts are placed after eachother. -->
							<xsl:sequence select="imf:msg(.,'WARNING','Within the message [1] 2 parameters are placed after eachother.', ($rawMessageName))" />			
							<ep:uriStructure/>
						</xsl:when>
						<xsl:when test="count($determinedUriStructure//ep:uriPart) > count($calculatedUriStructure//ep:uriPart) or not($calculatedUriStructure//ep:uriPart)">
							<!-- If the amount of entities withn the determined structure is larger than within the calculated structure
								 comparisson isn't possible and a warnings is generated. The structure within the padtype class doesn't fit with the structure within the query tree.
								 This might be caused by names not being equal within both structures or by missing structure parts within the query tree. -->
							<xsl:sequence select="imf:msg(.,'WARNING','The structure of the padtype class within the message [1] does not comply with the structure within the query tree.', ($rawMessageName))" />			
							<ep:uriStructure/>
						</xsl:when>
						<xsl:otherwise>
							<!-- Process the calculated uristructure with the checkUriStructure template. -->
							<xsl:for-each select="$calculatedUriStructure/ep:uriStructure">
								<ep:uriStructure>
									<xsl:call-template name="checkUriStructure">
										<xsl:with-param name="uriPart2Check" select="1"/>
										<xsl:with-param name="determinedUriStructure" select="$determinedUriStructure"/>
										<xsl:with-param name="calculatedUriStructure" select="$calculatedUriStructure"/>
										<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
									</xsl:call-template>
								</ep:uriStructure>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!--xsl:variable name="analyzedResponseStructure">
					<ep:analyzedStructure name="{$rawMessageName}" responseConstructName="{$responseConstructName}">
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]" mode="getCharacteristics"/>
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $responseConstructName]" mode="getConstruct4Characteristics"/>
					</ep:analyzedStructure>
				</xsl:variable-->

				<xsl:if test="$checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0 
								and empty(following-sibling::ep:uriPart[ep:param])]">

					<!-- If the checkedUriStructure contains uriparts with entitynames that are not part of the path and without param elements
						 a warning is generated. -->
					<xsl:variable name="falseAndEmptyUriParts">
						<xsl:for-each select="$checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0]">
							<xsl:value-of select="ep:entityName"/>
							<xsl:if test="following-sibling::ep:uriPart">
								<xsl:text>, </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($falseAndEmptyUriParts,',')">
							<xsl:sequence select="imf:msg(.,'WARNING','The request tree of the message [1] contains empty entities ([2]) which are not part of the message.', ($messageName,$falseAndEmptyUriParts))" />			
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:msg(.,'WARNING','The request tree of the message [1] contains the empty entity ([2]) which is not part of the message.', ($messageName,$falseAndEmptyUriParts))" />			
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				
				<!-- If desired we could also generate a warning which states the message name as derived from the calculated uristructure.
					 For now this has been disabled. -->
<?x				<xsl:variable name="calculatedMessageName">
					<xsl:for-each select="$calculatedUriStructure//ep:uriPart">
						<xsl:text>/</xsl:text><xsl:value-of select="ep:entityName"/>
						<xsl:for-each select="ep:param">
							<xsl:text>/{</xsl:text><xsl:value-of select="ep:name"/><xsl:text>}</xsl:text>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:if test="$messageName != $calculatedMessageName">
					<!--<xsl:message select="concat('WARNING: The messagename (',$messageName,') is not correct, according to the request tree in the model it should be ',$calculatedMessageName,'.')"/>-->
					<xsl:sequence select="imf:msg(.,'WARNING','The messagename ([1]) is not correct, according to the request tree in the model it should be [2].', ($messageName,$calculatedMessageName))" />			
				</xsl:if> ?>
				
				<!-- At the moment query parameters become applicable for DELETE massage the following Error messages can be enabled. -->
				<?x				<!-- Een expand parameter is niet van toepassing op een DELETE bericht. -->
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='EXPAND']">
					<xsl:sequence select="imf:msg(.,'ERROR','An expand parameter is not applicable for [1] messages, remove it from the [2] message.', ($method, $messageName))" />			
				</xsl:if>
				
				<!-- Een page en pagesize parameter zijn niet van toepassing op een DELETE bericht. -->
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGE']">
					<xsl:sequence select="imf:msg(.,'ERROR','A page parameter is not applicable for [1] messages, remove it from the [2] message.', ($method, $messageName))" />			
				</xsl:if>
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='PAGESIZE']">
					<xsl:sequence select="imf:msg(.,'ERROR','A pagesize parameter is not applicable for [1] messages, remove it from the [2 message.', ($method, $messageName))" />			
				</xsl:if>
				
				<!-- Een sorteer parameter is niet van toepassing op een DELETE bericht. -->
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='SORTEER']">
					<xsl:sequence select="imf:msg(.,'ERROR','A sorteer parameter is not applicable for [1] messages, rremove it from the [2] message.', ($method, $messageName))" />			
				</xsl:if>
				
				<!-- Een fields parameter is niet van toepassing op een DELETE bericht. -->
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[upper-case(ep:name)='FIELDS']">
					<xsl:sequence select="imf:msg(.,'ERROR','A fields parameter is not applicable for [1] messages, remove it from the [2 message.', ($method, $messageName))" />			
				</xsl:if>
	
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[not(@position) or @position='']">
					<xsl:sequence select="imf:msg(.,'WARNING','On one or more parameters on the [1] message [2] no tagged value Positie has been defined. These parameters will be sorted alphabetically!', ($method, $messageName))" />			
				</xsl:if> ?>
				
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[empty(@path) or @path = 'false']">
					<xsl:sequence select="imf:msg(.,'ERROR','Query parameters are not allowed on [1] messages, remove them on the [2] message.', ($method, $messageName))" />			
				</xsl:if>
				
				<!-- For each message the next structure is generated. -->
				<xsl:text>&#xa;    </xsl:text><xsl:value-of select="$method"/><xsl:text>:</xsl:text>
				<xsl:text>&#xa;      operationId: </xsl:text><xsl:value-of select="$operationId" />
				<xsl:text>&#xa;      description: "</xsl:text><xsl:value-of select="$documentation" /><xsl:text>"</xsl:text>
				<xsl:if test="$checkedUriStructure//ep:uriPart/ep:param[@path = 'true']">
					<!-- If parameters apply the parameters section is generated. -->
					<xsl:text>&#xa;      parameters: </xsl:text>
					<xsl:for-each select="$checkedUriStructure//ep:uriPart/ep:param[@path = 'true']">
						<xsl:sort order="ascending" select="@position" data-type="number"/>
						<xsl:sort order="ascending" select="ep:name"/>
						<!-- Loop over the path ep:param elements within the checkeduristructure and generate for each of them a path parameter. -->
						<xsl:variable name="incomingType" select="lower-case(ep:data-type)"/>
						<xsl:variable name="incomingTypeName" select="lower-case(ep:type-name)"/>
						<xsl:variable name="datatype">
							<xsl:call-template name="deriveDataType">
								<xsl:with-param name="incomingType" select="$incomingType"/>
								<xsl:with-param name="incomingTypeName" select="$incomingTypeName"/>
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="ep:outside-ref=('VNGR','VNG-GENERIEK')">
								<xsl:text>&#xa;        - in: path</xsl:text>
								<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
								<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
								<xsl:text>&#xa;          required: true</xsl:text>
								<xsl:text>&#xa;          schema:</xsl:text>
								<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-json-gemeente-components-url,ep:type-name,'&quot;')"/>
							</xsl:when>
<!--							<xsl:when test="upper-case(ep:name) = 'UUID'">
								<xsl:text>&#xa;        - $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-parameters-url,'uuid&quot;')"/>
							</xsl:when> -->
							<xsl:when test="ep:data-type">
								<xsl:text>&#xa;        - in: path</xsl:text>
								<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
								<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
								<xsl:text>&#xa;          required: true</xsl:text>
								<xsl:text>&#xa;          schema:</xsl:text>
								<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
								<xsl:variable name="format">
									<xsl:call-template name="deriveFormat">
										<xsl:with-param name="incomingType" select="$incomingType"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="facets">
									<xsl:call-template name="deriveFacets">
										<xsl:with-param name="incomingType" select="$incomingType"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="$format"/>
								<xsl:value-of select="$facets"/>
								<xsl:if test="ep:example">
									<xsl:text>&#xa;          example: </xsl:text><xsl:value-of select="ep:example"/>
								</xsl:if>
							</xsl:when>
							<xsl:when test="ep:type-name">
								<xsl:text>&#xa;        - in: path</xsl:text>
								<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
								<xsl:text>&#xa;          description: "</xsl:text><xsl:apply-templates select="ep:documentation"/><xsl:text>"</xsl:text>
								<xsl:text>&#xa;          required: true</xsl:text>
								<xsl:text>&#xa;          schema:</xsl:text>
								<xsl:text>&#xa;            $ref: </xsl:text><xsl:value-of select="concat('&quot;#/components/schemas/',ep:type-name,'&quot;')"/>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:text>&#xa;      responses:</xsl:text>
				<xsl:call-template name="response200">
					<xsl:with-param name="berichttype" select="'delete'"/>
					<xsl:with-param name="meervoudigeNaamResponseTree" select="''"/>
					<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
					<xsl:with-param name="responseConstructName" select="''"/>
				</xsl:call-template>
				<xsl:sequence select="imf:Foutresponse('204')"/>
				<xsl:sequence select="imf:Foutresponse('404')"/>
				<xsl:text>&#xa;      tags: </xsl:text>
				<xsl:text>&#xa;      - </xsl:text><xsl:value-of select="$tag" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="simpletype-class">
		<xsl:variable name="incomingType" select="lower-case(ep:data-type)"/>
		<xsl:variable name="datatype">
			<xsl:call-template name="deriveDataType">
				<xsl:with-param name="incomingType" select="$incomingType"/>
				<xsl:with-param name="incomingTypeName" select="''"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
		<xsl:variable name="format">
			<xsl:call-template name="deriveFormat">
				<xsl:with-param name="incomingType" select="$incomingType"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="facets">
			<xsl:call-template name="deriveFacets">
				<xsl:with-param name="incomingType" select="$incomingType"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$format"/>
		<xsl:value-of select="$facets"/>
		<xsl:if test="ep:example">
			<xsl:text>&#xa;          example: </xsl:text><xsl:value-of select="ep:example"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="response200">
		<xsl:param name="berichttype"/>
		<xsl:param name="meervoudigeNaamResponseTree"/>
		<xsl:param name="rawMessageName"/>
		<xsl:param name="responseConstructName"/>
		
		<xsl:text>&#xa;        '200':</xsl:text>
		<xsl:choose>
			<xsl:when test="$berichttype = 'delete'">
				<xsl:text>&#xa;          description: "Verwijderactie geslaagd"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#xa;          description: "Zoekactie geslaagd"</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xa;          headers:</xsl:text>
		<xsl:text>&#xa;            api-version:</xsl:text>
		<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'api_version&quot;')"/>
		<xsl:if test="$berichttype != 'delete'">
			<xsl:text>&#xa;            warning:</xsl:text>
			<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'warning&quot;')"/>
			<xsl:if test="ep:parameters/ep:parameter[ep:name='grouping']/ep:value='collection' and ep:parameters/ep:parameter[ep:name='pagination']/ep:value='true' and $serialisation = 'hal+json'">
				<!-- In case of a collection type message and if pagination and hal+json applies create the following properties. -->
				<xsl:text>&#xa;            X-Pagination-Page:</xsl:text>
				<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'X_Pagination_Page&quot;')"/>
				<xsl:text>&#xa;            X-Pagination-Limit:</xsl:text>
				<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'X_Pagination_Limit&quot;')"/>
			</xsl:if>
			<xsl:text>&#xa;            X-Rate-Limit-Limit:</xsl:text>
			<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'X_Rate_Limit_Limit&quot;')"/>
			<xsl:text>&#xa;            X-Rate-Limit-Remaining:</xsl:text>
			<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'X_Rate_Limit_Remaining&quot;')"/>
			<xsl:text>&#xa;            X-Rate-Limit-Reset:</xsl:text>
			<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'X_Rate_Limit_Reset&quot;')"/>
			<xsl:text>&#xa;          content:</xsl:text>
			<xsl:text>&#xa;            application/</xsl:text><xsl:value-of select="$serialisation"/><xsl:text>:</xsl:text>
			<xsl:text>&#xa;              schema:</xsl:text>
			<xsl:for-each
				select="../ep:message[ep:parameters[ep:parameter[ep:name='messagetype']/ep:value = 'response' and ep:parameter[ep:name='berichtcode']/ep:value = $berichttype] and ep:name = $rawMessageName]">
				<!-- For the response type message related to the current message generate the next refs to the toplevel component within the 
						 json part of the yaml file. -->
				<xsl:choose>
					<xsl:when test="$serialisation = 'json' and ep:parameters/ep:parameter[ep:name='grouping']/ep:value = 'resource'">
						<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName" /><xsl:text>'</xsl:text>
					</xsl:when>
					<xsl:when test="$serialisation = 'json' and ep:parameters/ep:parameter[ep:name='messageCategory']/ep:value = 'Gc'">
						<xsl:text>&#xa;                type: array</xsl:text>
						<xsl:text>&#xa;                items:</xsl:text>
						<xsl:text>&#xa;                  $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName" /><xsl:text>'</xsl:text>
					</xsl:when>
					<xsl:when test="$serialisation = 'json' and (contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') or contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu'))">
						<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName" /><xsl:text>'</xsl:text>
					</xsl:when>
					<xsl:when test="ep:parameters/ep:parameter[ep:name='grouping']/ep:value = 'resource'">
						<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName" />Hal<xsl:text>'</xsl:text>
					</xsl:when>
					<xsl:when test="contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc')">
						<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName"/><xsl:text>HalCollectie'</xsl:text>
					</xsl:when>
					<xsl:when test="contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pa') or contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Pu')">
						<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName" />Hal<xsl:text>'</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template name="response201">
		<xsl:param name="rawMessageName"/>
		<xsl:param name="responseConstructName"/>
		<xsl:param name="exampleSleutelEntiteittype"/>
		<xsl:param name="acceptCrsParamPresent"/>
		<xsl:param name="messageCategory"/>

		<xsl:text>&#xa;        '201':</xsl:text>
		<xsl:text>&#xa;          description: "OK"</xsl:text>
		<xsl:text>&#xa;          headers:</xsl:text>
		<xsl:text>&#xa;            Location:</xsl:text>
		<xsl:text>&#xa;              description: "URI van de nieuwe resource"</xsl:text>
		<xsl:text>&#xa;              schema:</xsl:text>
		<xsl:text>&#xa;                type: string</xsl:text>
		<xsl:text>&#xa;                format: uri</xsl:text>
		<xsl:text>&#xa;                example: '</xsl:text><xsl:value-of select="concat($rawMessageName,'/',$exampleSleutelEntiteittype)" /><xsl:text>'</xsl:text>
		<xsl:text>&#xa;            api-version:</xsl:text>
		<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'api_version&quot;')"/>
		<xsl:text>&#xa;            warning:</xsl:text>
		<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-headers-url,'warning&quot;')"/>
		<xsl:if test="$messageCategory = 'Po' and $acceptCrsParamPresent">
			<xsl:text>&#xa;            parameters: </xsl:text>
			<!-- If accept-Crs-parameter applies that parameter is generated. -->
			<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;',$geonovum-yaml-parameters-url,'acceptCrs&quot;')"/>
		</xsl:if>
		<xsl:text>&#xa;          content:</xsl:text>
		<xsl:text>&#xa;            application/</xsl:text><xsl:value-of select="$serialisation"/><xsl:text>:</xsl:text>
		<xsl:text>&#xa;              schema:</xsl:text>
		<xsl:choose>
			<xsl:when test="$serialisation = 'json'">
				<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName" /><xsl:text>'</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="$responseConstructName" /><xsl:text>Hal'</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:function name="imf:Foutresponses">
		<xsl:param name="berichttype"/>
		<xsl:param name="queryParamsPresent"/>
		<xsl:param name="pathParamsPresent"/>
		<xsl:param name="crsParamPresent"/>
		
		<xsl:sequence select="imf:Foutresponse('400')"/>
		<xsl:sequence select="imf:Foutresponse('401')"/>
		<xsl:sequence select="imf:Foutresponse('403')"/>
		<xsl:if test="$pathParamsPresent">
			<xsl:sequence select="imf:Foutresponse('404')"/>
		</xsl:if>
		<xsl:if test="$Response406Required">
			<xsl:sequence select="imf:Foutresponse('406')"/>
		</xsl:if>
		<xsl:sequence select="imf:Foutresponse('409')"/>
		<xsl:sequence select="imf:Foutresponse('410')"/>
		<xsl:if test="$crsParamPresent">
			<xsl:sequence select="imf:Foutresponse('412')"/>
		</xsl:if>
		<xsl:sequence select="imf:Foutresponse('415')"/>
		<xsl:sequence select="imf:Foutresponse('429')"/>
		<xsl:sequence select="imf:Foutresponse('500')"/>
		<xsl:sequence select="imf:Foutresponse('501')"/>
		<xsl:sequence select="imf:Foutresponse('503')"/>
		<xsl:sequence select="imf:Foutresponse('default')"/>
	</xsl:function>
	
	<xsl:function name="imf:Foutresponse">
		<xsl:param name="foutcode"/>
		<xsl:text>&#xa;        '</xsl:text><xsl:value-of select="$foutcode"/><xsl:text>':</xsl:text>
		<xsl:text>&#xa;          $ref: </xsl:text><xsl:value-of select="concat('&quot;',$standard-yaml-responses-url,$foutcode,'&quot;')"/>
	</xsl:function>

<?x	<xsl:template match="ep:documentation">
		<xsl:apply-templates select="ep:description" />
	</xsl:template>

	<xsl:template match="ep:description">
		<xsl:apply-templates select="ep:p" />
	</xsl:template>

	<!--xsl:template match="ep:p">
		<xsl:value-of select="." />
		<xsl:if test="following-sibling::ep:p">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template-->

	<xsl:template match="ep:p">
		<xsl:choose>
			<xsl:when test="@format = 'plain'">
				<xsl:text>(test)</xsl:text><xsl:value-of select="."/>
				<xsl:if test="following-sibling::ep:p">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@format = 'markdown'">
				<xsl:apply-templates select="html:body"/>
			</xsl:when>
			<xsl:otherwise>De otherwise tak.</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:body">
		<xsl:value-of select="'# Titel'"/>
		<xsl:apply-templates select="html:*"/>
	</xsl:template>
	
	<xsl:template match="html:h2">
		<xsl:value-of select="concat('## ',.)"/><xsl:text>
			
		</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:p">
		<xsl:value-of select="."/>
		<xsl:apply-templates select="html:*"/>
	</xsl:template>
	
	<xsl:template match="html:ul">
		<xsl:text>
			
		</xsl:text><xsl:apply-templates select="html:*"/>
	</xsl:template>
	
	<xsl:template match="html:ol">
		<xsl:text>
			
		</xsl:text><xsl:apply-templates select="html:*"/>
	</xsl:template>
	
	<xsl:template match="html:li">
		<xsl:value-of select="concat('* ',.)"/><xsl:text>
			
		</xsl:text>
	</xsl:template> ?>

	<xsl:template match="ep:construct" mode="getParameters">
		<xsl:for-each select="ep:seq/ep:construct[empty(ep:parameters/ep:parameter[ep:name='type'])]">
			<ep:param position="{ep:parameters/ep:parameter[ep:name='position']/ep:value}">
				<xsl:if test="ep:parameters/ep:parameter[ep:name='is-id']/ep:value = 'true'">
					<xsl:attribute name="is-id" select="'true'"/>
				</xsl:if>
				<ep:name original="{ep:name}"><xsl:value-of select="lower-case(ep:name)"/></ep:name>
				<xsl:copy-of select="ep:documentation"/>
				<xsl:choose>
					<xsl:when test="ep:data-type">
						<ep:data-type><xsl:value-of select="ep:data-type"/></ep:data-type>
					</xsl:when>
					<xsl:when test="ep:type-name">
						<ep:type-name><xsl:value-of select="ep:type-name"/></ep:type-name>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="ep:max-length != ''">
					<ep:max-length><xsl:value-of select="ep:max-length"/></ep:max-length>
				</xsl:if>
				<xsl:if test="ep:min-value != ''">
					<ep:min-value><xsl:value-of select="ep:min-value"/></ep:min-value>
				</xsl:if>
				<xsl:if test="ep:max-value != ''">
					<ep:max-value><xsl:value-of select="ep:max-value"/></ep:max-value>
				</xsl:if>
				<xsl:if test="ep:pattern != ''">
					<ep:pattern><xsl:value-of select="ep:pattern"/></ep:pattern>
				</xsl:if>
				<xsl:if test="ep:example != ''">
					<ep:example><xsl:value-of select="ep:example"/></ep:example>
				</xsl:if>
				<xsl:if test="ep:outside-ref != ''">
					<ep:outside-ref><xsl:value-of select="ep:outside-ref"/></ep:outside-ref>
				</xsl:if>
				<xsl:sequence select="imf:create-output-element('ep:min-occurs', ep:min-occurs)" />
				<xsl:sequence select="imf:create-output-element('ep:max-occurs', ep:max-occurs)" />				
			</ep:param>
		</xsl:for-each>
		<xsl:for-each select="ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'groep']">
			<xsl:variable name="parameterConstruct" select="ep:type-name"/>
			<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]" mode="getParameters"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="ep:construct" mode="getUriPart">
		<xsl:choose>
			<xsl:when test="count(ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association']) > 1">
				<xsl:sequence select="imf:msg(.,'ERROR','There are more than one associations connected to the request class [1] this is not allowed.', (ep:name))" />			
			</xsl:when>
			<xsl:when test="ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association' and (empty(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']) or ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value = '')]">
				<xsl:sequence select="imf:msg(.,'ERROR','The association connected to and orginated from the request class [1] does not have a tagged value meervoudige naam, supply one.', (ep:name))" />			
			</xsl:when>
			<xsl:when test="ep:tech-name = ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association']/ep:type-name">
				<xsl:sequence select="imf:msg(.,'ERROR','An association connected to and orginated from the request class [1] is creating a recursive relation. This is not allowed within the request tree.', (ep:name))" />			
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association']">
					<xsl:variable name="meervoudigeNaam" select="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
					<xsl:variable name="parameterConstruct" select="ep:type-name"/>
					<ep:uriPart>
						<ep:entityName original="{$meervoudigeNaam}"><xsl:value-of select="lower-case($meervoudigeNaam)"/></ep:entityName>
						<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]" mode="getParameters"/>
					</ep:uriPart>
					<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]" mode="getUriPart"/>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ep:construct" mode="getCharacteristics">
		<xsl:variable name="hasGMtype">
			<!--xsl:if test="ep:seq/ep:construct/ep:parameters[empty(ep:parameter[ep:name='type'])]/ep:parameter[ep:name='type']/ep:value = 'GM-external'"-->
			<xsl:if test="ep:seq/ep:construct/ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external'">
				<xsl:value-of select="'true'"/>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$hasGMtype != 'true'">
				<xsl:for-each select="ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'groep']">
					<xsl:variable name="constructName" select="ep:type-name"/>
					<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $constructName]" mode="getCharacteristics"/>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<ep:hasGMtype>true</ep:hasGMtype>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="getConstruct4Characteristics">
		<xsl:param name="constructNames" select="''"/>
		<xsl:for-each select="ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association']">
			<xsl:variable name="meervoudigeNaam" select="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
			<xsl:variable name="constructName" select="ep:type-name"/>
			
			<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $constructName]" mode="getCharacteristics"/>
			<xsl:if test="not(contains($constructNames,$constructName))">
				<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $constructName]" mode="getConstruct4Characteristics">
					<xsl:with-param name="constructNames" select="concat($constructNames,';',$constructName)"/>
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="checkUriStructure">
		<xsl:param name="determinedUriStructure"/>
		<xsl:param name="calculatedUriStructure"/>
		<xsl:param name="uriPart2Check"/>
		<xsl:param name="rawMessageName"/>
		
		<xsl:for-each select="ep:uriPart[position() = $uriPart2Check]">
			<!-- Loop over all ep:uriPart elements within the calculatedstructure and reproduce that. -->
			<xsl:variable name="entityName" select="ep:entityName"/>
			<xsl:variable name="originalEntityName" select="ep:entityName/@original"/>
			<ep:uriPart>
				<xsl:choose>
					<xsl:when test="substring($rawMessageName,string-length($rawMessageName),1) = '/'">
						<xsl:sequence select="imf:msg(.,'ERROR','The messagename [1] ends with a &quot;/&quot;, this is not allowed.', ($rawMessageName))" />			
						<ep:entityName original="{$originalEntityName}" path="false"><xsl:value-of select="$entityName"/></ep:entityName>
					</xsl:when>
					<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:entityName = $entityName">
						<!-- If the entityname of the current uriPart is equal to the entityname of the corresponding uriPart within the determined
							 uri structure. The entity belongs to the path. -->
						<ep:entityName original="{$originalEntityName}" path="true"><xsl:value-of select="$entityName"/></ep:entityName>
					</xsl:when>
					<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:entityName != $entityName">
						<!-- If the entityname of the current uriPart isn't equal to the entityname of the corresponding uriPart within the determined
							 uri structure it doesn't belong to the path. This is an error and for now a warning is generated. -->
						<xsl:sequence select="imf:msg(.,'WARNING','The entityname [1] within the message [2] is not available within the query tree or is not on the right position within the path.', ($entityName,$rawMessageName))" />			
						<ep:entityName original="{$originalEntityName}" path="false"><xsl:value-of select="$entityName"/></ep:entityName>
					</xsl:when>
					<xsl:when test="empty($determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check])">
						<!-- The path in the determined uri structure is smaller than the path within the calculated uri structure.
							 This is allowed but it's indicated the entity doesn't belong to the path. -->
						<ep:entityName original="{$originalEntityName}" path="false"><xsl:value-of select="$entityName"/></ep:entityName>
					</xsl:when>
				</xsl:choose>
				<xsl:for-each select="ep:param">
					<!-- Loop over the ep:param elements within the current (calculated) uripart a.o. mistakes within the determined uripart. -->
					<xsl:variable name="paramName" select="ep:name"/>
					<xsl:variable name="originalParamName" select="ep:name/@original"/>
					<xsl:variable name="is-id">
						<xsl:choose>
							<xsl:when test="@is-id = 'true'">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="data-type">
						<xsl:value-of select="ep:data-type"/>
					</xsl:variable>
					<xsl:variable name="type-name">
						<xsl:value-of select="ep:type-name"/>
					</xsl:variable>
					<xsl:variable name="max-length">
						<xsl:value-of select="ep:max-length"/>
					</xsl:variable>
					<xsl:variable name="min-value">
						<xsl:value-of select="ep:min-value"/>
					</xsl:variable>
					<xsl:variable name="max-value">
						<xsl:value-of select="ep:max-value"/>
					</xsl:variable>
					<xsl:variable name="patroon">
						<xsl:value-of select="ep:pattern"/>
					</xsl:variable>
					<xsl:variable name="example">
						<xsl:value-of select="ep:example"/>
					</xsl:variable>
					<xsl:variable name="outside-ref">
						<xsl:value-of select="ep:outside-ref"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param/ep:name = $paramName and $is-id = 'true'">
							<!-- If the param is part of the path and it's an id-type it's reproduced as a path parameter with all necessary 
								 properties. -->
							<ep:param path="true" position="{@position}">
								<ep:name original="{$originalParamName}"><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<xsl:copy-of select="ep:documentation"/>
								<xsl:sequence select="imf:create-output-element('ep:min-occurs', ep:min-occurs)" />
								<xsl:sequence select="imf:create-output-element('ep:max-occurs', ep:max-occurs)" />
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-value != ''">
									<ep:min-value><xsl:value-of select="$min-value"/></ep:min-value>
								</xsl:if>
								<xsl:if test="$max-value != ''">
									<ep:max-value><xsl:value-of select="$max-value"/></ep:max-value>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:pattern><xsl:value-of select="$patroon"/></ep:pattern>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
								<xsl:if test="$outside-ref != ''">
									<ep:outside-ref><xsl:value-of select="$outside-ref"/></ep:outside-ref>
								</xsl:if>
	<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-value', $min-value)" />
								<xsl:sequence select="imf:create-output-element('ep:max-value', $max-value)" />
								<xsl:sequence select="imf:create-output-element('ep:pattern', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:when>
						<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param/ep:name = $paramName and $is-id = 'false'">
							<!-- If the param is part of the path and it's not an id-type it is reproduced with all necessary properties and with 
								 an indcator stating there's an error. There's also a warning generated since all path parameters must be of 
								 id-type. -->
							<xsl:sequence select="imf:msg(.,'WARNING','The path parameter ([1]) within the message [2] is not an id attribute.', ($paramName,$rawMessageName))" />			
							<ep:param path="false" position="{@position}">
								<ep:name original="{$originalParamName}"><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<xsl:copy-of select="ep:documentation"/>
								<xsl:sequence select="imf:create-output-element('ep:min-occurs', ep:min-occurs)" />
								<xsl:sequence select="imf:create-output-element('ep:max-occurs', ep:max-occurs)" />
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-value != ''">
									<ep:min-value><xsl:value-of select="$min-value"/></ep:min-value>
								</xsl:if>
								<xsl:if test="$max-value != ''">
									<ep:max-value><xsl:value-of select="$max-value"/></ep:max-value>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:pattern><xsl:value-of select="$patroon"/></ep:pattern>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
								<xsl:if test="$outside-ref != ''">
									<ep:outside-ref><xsl:value-of select="$outside-ref"/></ep:outside-ref>
								</xsl:if>
								<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-value', $min-value)" />
								<xsl:sequence select="imf:create-output-element('ep:max-value', $max-value)" />
								<xsl:sequence select="imf:create-output-element('ep:pattern', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:when>
						<xsl:otherwise>
							<!-- In all other cases the parameter is reproduced with all necessary properties. -->
							<ep:param position="{@position}">
								<ep:name original="{$originalParamName}"><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<xsl:copy-of select="ep:documentation"/>
								<xsl:sequence select="imf:create-output-element('ep:min-occurs', ep:min-occurs)" />
								<xsl:sequence select="imf:create-output-element('ep:max-occurs', ep:max-occurs)" />
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-value != ''">
									<ep:min-value><xsl:value-of select="$min-value"/></ep:min-value>
								</xsl:if>
								<xsl:if test="$max-value != ''">
									<ep:max-value><xsl:value-of select="$max-value"/></ep:max-value>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:pattern><xsl:value-of select="$patroon"/></ep:pattern>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
								<xsl:if test="$outside-ref != ''">
									<ep:outside-ref><xsl:value-of select="$outside-ref"/></ep:outside-ref>
								</xsl:if>
								<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-value', $min-value)" />
								<xsl:sequence select="imf:create-output-element('ep:max-value', $max-value)" />
								<xsl:sequence select="imf:create-output-element('ep:pattern', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param">
						<!-- Since we also want to detect mistakes within the calculated uripart we also loop over the ep:param elements of the 
							 determined uripart corresponding with the current calcutaled uriPart. -->
						<xsl:variable name="paramName" select="ep:name"/>
						<xsl:variable name="originalParamName" select="ep:name/@original"/>
						<xsl:if test="not($calculatedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param/ep:name = $paramName)">
							<!-- If there is no param within the current calculated urpart which is equal to the name of the param of the corresponding
								 determined uripart it is reproduced with all necessary properties and with an indcator stating there's an error.
								 Also a warning is generated. -->
							<xsl:sequence select="imf:msg(.,'WARNING','The path parameter ([1]) within the message [2] is not avalable as query parameter.', ($paramName,$rawMessageName))" />			
							<ep:param path="false" position="{@position}">
								<ep:name original="{$originalParamName}"><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<xsl:copy-of select="ep:documentation"/>
								<xsl:sequence select="imf:create-output-element('ep:min-occurs', ep:min-occurs)" />
								<xsl:sequence select="imf:create-output-element('ep:max-occurs', ep:max-occurs)" />
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-value != ''">
									<ep:min-value><xsl:value-of select="$min-value"/></ep:min-value>
								</xsl:if>
								<xsl:if test="$max-value != ''">
									<ep:max-value><xsl:value-of select="$max-value"/></ep:max-value>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:pattern><xsl:value-of select="$patroon"/></ep:pattern>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
								<xsl:if test="$outside-ref != ''">
									<ep:outside-ref><xsl:value-of select="$outside-ref"/></ep:outside-ref>
								</xsl:if>
								<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-value', $min-value)" />
								<xsl:sequence select="imf:create-output-element('ep:max-value', $max-value)" />
								<xsl:sequence select="imf:create-output-element('ep:pattern', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</ep:uriPart>
		</xsl:for-each>
		<xsl:if test="not($uriPart2Check + 1 > count($calculatedUriStructure//ep:uriPart))">
			<!-- If there's are following uripart process it too with the current template. -->
			<xsl:call-template name="checkUriStructure">
				<xsl:with-param name="uriPart2Check" select="$uriPart2Check + 1"/>
				<xsl:with-param name="determinedUriStructure" select="$determinedUriStructure"/>
				<xsl:with-param name="calculatedUriStructure" select="$calculatedUriStructure"/>
				<xsl:with-param name="rawMessageName" select="$rawMessageName"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="deriveDataType">
		<xsl:param name="incomingType"/>
		<xsl:param name="incomingTypeName"/>
		<xsl:choose>
			<xsl:when test="$incomingType = 'boolean'">
				<xsl:value-of select="'boolean'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'string'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'date'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'dateTime'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'decimal'">
				<xsl:value-of select="'number'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'integer'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'real'">
				<xsl:value-of select="'number'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'monty'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'day'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<!--			<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'yearmonth'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'postcode'">
				<xsl:value-of select="'string'"/>
			</xsl:when> -->
			<xsl:when test="$incomingType = 'uri'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingTypeName != ''">
				<xsl:variable name="enumtype" select="$message-sets//ep:message-set/ep:construct[ep:tech-name = $incomingTypeName]/ep:data-type"/>
				<xsl:choose>
					<xsl:when test="lower-case($enumtype) = 'boolean'">
						<xsl:value-of select="'boolean'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'string'">
						<xsl:value-of select="'string'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'date'">
						<xsl:value-of select="'string'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'dateTime'">
						<xsl:value-of select="'string'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'decimal'">
						<xsl:value-of select="'number'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'integer'">
						<xsl:value-of select="'integer'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'real'">
						<xsl:value-of select="'number'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'year'">
						<xsl:value-of select="'integer'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'month'">
						<xsl:value-of select="'integer'"/>
					</xsl:when>
					<xsl:when test="lower-case($enumtype) = 'day'">
						<xsl:value-of select="'integer'"/>
					</xsl:when>
					<!--					<xsl:when test="substring-after($enumtype, 'scalar-') = 'yearmonth'">
						<xsl:value-of select="'integer'"/>
					</xsl:when>
					<xsl:when test="substring-after($enumtype, 'scalar-') = 'postcode'">
						<xsl:value-of select="'string'"/>
					</xsl:when> -->
					<xsl:when test="lower-case($enumtype) = 'uri'">
						<xsl:value-of select="'string'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'string'"/>
					</xsl:otherwise>
				</xsl:choose>
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
				<xsl:text>&#xa;            format: date</xsl:text>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<xsl:text>&#xa;            format: jaar</xsl:text>
			</xsl:when>
<!--			<xsl:when test="$incomingType = 'yearmonth'">
				<xsl:text>&#xa;            format: jaarmaand</xsl:text>
			</xsl:when> -->
			<xsl:when test="$incomingType = 'dateTime'">
				<xsl:text>&#xa;            format: date-time</xsl:text>
			</xsl:when>
			<xsl:when test="$incomingType = 'uri'">
				<xsl:text>&#xa;            format: uri</xsl:text>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
    <xsl:template name="deriveFacets">
        <xsl:param name="incomingType"/>
        
  		<!-- Some types can have one or more facets which restrict the allowed value. -->
       <xsl:choose>
       	<xsl:when test="$incomingType = 'string'">
				<xsl:if test="ep:pattern">
					<xsl:text>&#xa;            pattern: </xsl:text><xsl:value-of select="concat('^',ep:pattern,'$')"/>
				</xsl:if>
				<xsl:if test="ep:max-length">
					<xsl:text>&#xa;            maxLength: </xsl:text><xsl:value-of select="ep:max-length"/>
				</xsl:if>
				<xsl:if test="ep:min-length">
					<xsl:text>&#xa;            minLength: </xsl:text><xsl:value-of select="ep:min-length"/>
				</xsl:if>
            </xsl:when>
            <xsl:when test="$incomingType = 'integer'">
				<xsl:if test="ep:min-value">
					<xsl:text>&#xa;            minimum: </xsl:text><xsl:value-of select="ep:min-value"/>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<xsl:text>&#xa;            maximum: </xsl:text><xsl:value-of select="ep:max-value"/>
				</xsl:if>
            </xsl:when>
	       	<xsl:when test="$incomingType = 'real'">
	       		<xsl:if test="ep:min-value">
	       			<xsl:text>&#xa;            minimum: </xsl:text><xsl:value-of select="ep:min-value"/>
	       		</xsl:if>
	       		<xsl:if test="ep:max-value">
	       			<xsl:text>&#xa;            maximum: </xsl:text><xsl:value-of select="ep:max-value"/>
	       		</xsl:if>
	       	</xsl:when>
	       	<xsl:when test="$incomingType = 'decimal'">
				<xsl:if test="ep:min-value">
					<xsl:text>&#xa;            minimum: </xsl:text><xsl:value-of select="ep:min-value"/>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<xsl:text>&#xa;            maximum: </xsl:text><xsl:value-of select="ep:max-value"/>
				</xsl:if>
            </xsl:when>
	       	<xsl:when test="$incomingType = 'year'">
	       		<xsl:text>&#xa;            pattern: ^[1-2]{1}[0-9]{3}$</xsl:text>
	       	</xsl:when>
<!--	       	<xsl:when test="$incomingType = 'yearmonth'">
	       		<xsl:text>&#xa;            pattern: ^[1-2]{1}[0-9]{3}-^[0-1]{1}[0-9]{1}$</xsl:text>
	       	</xsl:when>
	       	<xsl:when test="$incomingType = 'postcode'">
	       		<xsl:text>&#xa;            pattern: ^[1-9]{1}[0-9]{3}[A-Z]{2}$</xsl:text>
	       	</xsl:when> -->
	       	<xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

	<!-- De 'functx' functies halen alleen unieke nodes op uit een node collectie. 
		 Hierdoor worden dubbelingen verwijderd -->
	<xsl:function name="functx:is-node-in-sequence-deep-equal"
		as="xs:boolean">
		<xsl:param name="node" as="node()?" />
		<xsl:param name="seq" as="node()*" />
		
		<xsl:sequence
			select="
			some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
			" />
	</xsl:function>
	
	<xsl:function name="functx:distinct-deep" as="node()*">
		<xsl:param name="nodes" as="node()*" />
		
		<xsl:sequence
			select="
			for $seq in (1 to count($nodes))
			return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
			.,$nodes[position() &lt; $seq]))]
			" />
	</xsl:function>
	
	<xsl:function name="imf:determineAmountOfUnderscores">
		<xsl:param name="length"/>
		<xsl:if test="$length > 0">
			<xsl:value-of select="'_'"/>
			<xsl:sequence select="imf:determineAmountOfUnderscores($length - 1)"/>
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="imf:determineUriStructure">
		<!-- This function translates the uri of the pathclass into a uripart structure where each uripart consists of an 
			 entityname and an optional parameter. All entitynames (except the first one) and all parameters are preceded by a '/' char. -->
		<xsl:param name="uri"/>
		
		<xsl:choose>
			<xsl:when test="contains($uri,'}')">
				<!-- If the uri contains '}' characters it has path parameters. -->
				<xsl:choose>
					<xsl:when test="starts-with(substring-after($uri,'/'),'{')">
						<!-- If the first uripart has a parameter the uriPart element will consist of an entityName and a param element. -->
						<ep:uriPart condition="1">
							<ep:entityName original="{substring-before($uri,'/')}"><xsl:value-of select="lower-case(substring-before($uri,'/'))"/></ep:entityName>
							<ep:param>
								<ep:name original="{substring-before($uri,'}')}"><xsl:value-of select="lower-case(substring-after(substring-before($uri,'}'),'{'))"/></ep:name>
							</ep:param>
						</ep:uriPart>
						<xsl:if test="contains(substring-after($uri,'}'),'/')">
							<!-- If there's a '/' char after the first uripart there is a following uripart which is processed again with the 
								 current function. -->
							<xsl:sequence select="imf:determineUriStructure(substring-after($uri,'}/'))"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<!-- Otherwise only an entityName element is generated. -->
						<ep:uriPart condition="2">
							<ep:entityName original="{substring-before($uri,'/')}"><xsl:value-of select="lower-case(substring-before($uri,'/'))"/></ep:entityName>
						</ep:uriPart>
						<!-- If there's a '/' char after the first uripart there is a following uripart which is processed again with the 
							 current function. -->
						<xsl:sequence select="imf:determineUriStructure(substring-after($uri,'/'))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($uri,'/')">
				<!-- If the uri doesn't contains '}' characters it consists only of entityName. -->
				<ep:uriPart condition="3">
					<ep:entityName original="{substring-before($uri,'/')}"><xsl:value-of select="lower-case(substring-before($uri,'/'))"/></ep:entityName>
				</ep:uriPart>
				<!-- If there's a '/' char after the first uripart there is a following uripart which is processed again with the 
								 current function. -->
				<xsl:sequence select="imf:determineUriStructure(substring-after($uri,'/'))"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- The messagepath consists of only one uripart. -->
				<ep:uriPart condition="4">
					<ep:entityName original="{$uri}"><xsl:value-of select="lower-case($uri)"/></ep:entityName>
				</ep:uriPart>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>
