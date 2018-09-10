<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ep="http://www.imvertor.org/schema/endproduct" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:functx="http://www.functx.com" version="2.0">
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes" />

	<xsl:variable name="message-sets" select="/ep:message-sets" />

	<!-- Deze functies halen alleen unieke nodes op uit een node collectie. 
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
		<xsl:param name="uri"/>
		
		<xsl:choose>
			<xsl:when test="contains($uri,'}')">
				<xsl:choose>
					<xsl:when test="starts-with(substring-after($uri,'/'),'{')">
						<ep:uriPart>
							<ep:entityName><xsl:value-of select="lower-case(substring-before($uri,'/'))"/></ep:entityName>
							<ep:param>
								<ep:name><xsl:value-of select="lower-case(substring-after(substring-before($uri,'}'),'{'))"/></ep:name>
							</ep:param>
						</ep:uriPart>
						<xsl:if test="contains(substring-after($uri,'}'),'/')">
							<xsl:sequence select="imf:determineUriStructure(substring-after($uri,'}/'))"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<ep:uriPart>
							<ep:entityName><xsl:value-of select="lower-case(substring-before($uri,'/'))"/></ep:entityName>
						</ep:uriPart>
						<xsl:sequence select="imf:determineUriStructure(substring-after($uri,'/'))"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($uri,'/')">
				<ep:uriPart>
					<ep:entityName><xsl:value-of select="lower-case(substring-before($uri,'/'))"/></ep:entityName>
				</ep:uriPart>
				<xsl:sequence select="imf:determineUriStructure(substring-after($uri,'/'))"/>
			</xsl:when>
			<xsl:otherwise>
				<ep:uriPart>
					<ep:entityName><xsl:value-of select="lower-case($uri)"/></ep:entityName>
				</ep:uriPart>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template match="ep:message-sets">
		<xsl:apply-templates select="ep:message-set"/>
	</xsl:template>

	<xsl:template match="ep:message-set">
	
		<xsl:variable name="KVname">
			<xsl:value-of select="../ep:name"/>
		</xsl:variable>
		<xsl:variable name="chars2bTranslated" select="translate($KVname,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ','')"/>
		<xsl:variable name="normalizedKVname">
			<!-- Nog in te vullen. Krijgt een voorlopige vaste waarde mee. -->
			<xsl:variable name="chars2bTranslated2">
				<xsl:variable name="lengthChars2bTranslated" select="string-length($chars2bTranslated)" as="xs:integer"/>
<!--				<xsl:call-template name="determineAmountOfUnderscores">
					<xsl:with-param name="length" select="$lengthChars2bTranslated"/>
				</xsl:call-template>
-->				<xsl:sequence select="imf:determineAmountOfUnderscores($lengthChars2bTranslated)"/>
			</xsl:variable>
			<xsl:value-of select="lower-case(translate($KVname,$chars2bTranslated,$chars2bTranslated2))"/>
		</xsl:variable>
		<xsl:variable name="major-version">
			<xsl:choose>
				<xsl:when test="contains(ep:patch-number,'.')">
					<xsl:value-of select="substring-before(ep:patch-number,'.')"/>
				</xsl:when>
				<!-- If no dot is present within the patch-number. -->
				<xsl:otherwise>
					<!--<xsl:message select="concat('WARNING: The version-number (',ep:patch-number,') does not contain a dot.')"/>-->
					<xsl:sequence select="imf:msg(.,'WARNING','The version-number ([1]) does not contain a dot.', (ep:patch-number))" />			
					<xsl:value-of select="ep:patch-number"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- header -->
		<xsl:text>openapi: 3.0.0</xsl:text>
        <xsl:text>&#xa;servers:</xsl:text>
		<xsl:text>&#xa;  - description: SwaggerHub API Auto Mocking</xsl:text>
		<xsl:text>&#xa;    url: https://virtserver.swaggerhub.com/VNGRealisatie/api/</xsl:text><xsl:value-of select="concat($normalizedKVname,'/v', $major-version)"/>

        <xsl:text>&#xa;info:</xsl:text>
        <xsl:text>&#xa;  description: "</xsl:text> <xsl:value-of select="normalize-space(ep:documentation)"/><xsl:text>"</xsl:text>
        <xsl:text>&#xa;  version: "</xsl:text><xsl:value-of select="ep:patch-number"/><xsl:text>"</xsl:text>
        <xsl:text>&#xa;  title: </xsl:text><xsl:value-of select="$KVname"/>
        <xsl:text>&#xa;  contact:</xsl:text>
        <xsl:text>&#xa;    email: voornaam.achternaam@vng.nl</xsl:text>
        <xsl:text>&#xa;  license:</xsl:text>
        <xsl:text>&#xa;    name: European Union Public License, version 1.2 (EUPL-1.2)</xsl:text>
        <xsl:text>&#xa;    url: https://eupl.eu/1.2/nl/</xsl:text>
		<xsl:text>&#xa;paths:</xsl:text>
		<!-- Vraagberichten en vrije berichten -->
		<xsl:for-each-group select="ep:message" group-by="ep:name">
            <xsl:variable name="messageName" select="current-grouping-key()"/>
			<xsl:text>&#xa;  </xsl:text><xsl:value-of select="$messageName" /><xsl:text>:</xsl:text>
			<xsl:apply-templates select="current-group()"/>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="ep:message">
		<xsl:choose>
			<xsl:when test="(contains(@berichtcode,'Gr') or contains(@berichtcode,'Gc')) and @messagetype = 'request'">
				<xsl:variable name="messageName" select="ep:name" />
				<!-- The following variable contains a structure determined from the messageName. -->
				<xsl:variable name="determinedUriStructure">
					<ep:uriStructure>
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
	
				<!-- The following variable contains an similar structure but this time determined from the request tree. -->
				<xsl:variable name="calculatedUriStructure">
					<ep:uriStructure>
						<xsl:choose>
							<xsl:when test="@berichtcode = ('Gr01','Gc01','Gc02')">
								<xsl:variable name="parameterConstruct" select="./ep:seq/ep:construct/ep:type-name"/>
								<xsl:choose>
									<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct])">
										<xsl:sequence select="imf:msg(.,'WARNING','There is no global construct [1].',$parameterConstruct)"/>
									</xsl:when>
									<xsl:when test="empty(//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]/@meervoudigeNaam)">
										<xsl:sequence select="imf:msg(.,'WARNING','The class [1] within message [2] does not have a tagged value naam in meervoud, define one.',($parameterConstruct,$messageName))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="meervoudigeNaam" select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]/@meervoudigeNaam"/>
										<ep:uriPart>
											<ep:entityName><xsl:value-of select="lower-case($meervoudigeNaam)"/></ep:entityName>
											<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]" mode="getParameters"/>
										</ep:uriPart>
										<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]" mode="getUriPart"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</ep:uriStructure>
				</xsl:variable>

				<xsl:if test="$debugging">
					<xsl:result-document href="{concat('file:/c:/temp/determinedUriStructure',ep:name,'.xml')}" method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
						<xsl:sequence select="$determinedUriStructure"/>
					</xsl:result-document> 
					<xsl:result-document href="{concat('file:/c:/temp/calculatedUriStructure',ep:name,'.xml')}" method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
						<xsl:sequence select="$calculatedUriStructure"/>
					</xsl:result-document>
				</xsl:if>
				
				<!-- Within the following variable  the determinedUriStructure and the calculatedUriStructure are compared with eachother. 
					 If differences are perceived errors or warnings are generated. -->
				<xsl:variable name="checkedUriStructure">
					<xsl:choose>
						<!-- TODO: Kijken of ik hier nog preciesere foutmeldingen kan geven. -->
						
						<xsl:when test="count($determinedUriStructure//ep:uriPart) > count($calculatedUriStructure//ep:uriPart) or not($calculatedUriStructure//ep:uriPart)">
							<xsl:sequence select="imf:msg(.,'WARNING','The amount of entities within the message [1] is larger than the amount of entities within the query tree.', ($messageName))" />			
							<ep:uriStructure/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="$calculatedUriStructure/ep:uriStructure">
								<ep:uriStructure>
									<xsl:call-template name="checkUriStructure">
										<xsl:with-param name="uriPart2Check" select="1"/>
										<xsl:with-param name="determinedUriStructure" select="$determinedUriStructure"/>
										<xsl:with-param name="calculatedUriStructure" select="$calculatedUriStructure"/>
										<xsl:with-param name="messageName" select="$messageName"/>
									</xsl:call-template>
								</ep:uriStructure>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="$checkedUriStructure//ep:uriPart[ep:entityName/@path='false' and count(ep:param)=0 and empty(following-sibling::ep:uriPart[ep:param])]">
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
				<xsl:if test="$debugging">
					<xsl:result-document method="xml" href="{concat('file:/c:/temp/message/message-',ep:tech-name,'-',generate-id(),'.xml')}">
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

				<xsl:variable name="documentation">
					<xsl:text>"</xsl:text><xsl:apply-templates select="ep:documentation" /><xsl:text>"</xsl:text>
				</xsl:variable>
				<xsl:variable name="method">get</xsl:variable>
				<xsl:variable name="parametersRequired">
					<xsl:if test="@pagination = 'true'">J</xsl:if>
					<xsl:if test="@expand = 'true'">J</xsl:if>
					<xsl:if test="@fields = 'true'">J</xsl:if>
					<xsl:if test="@sort = 'true'">J</xsl:if>
					
				</xsl:variable>
	
				<xsl:text>&#xa;    </xsl:text><xsl:value-of select="$method"/><xsl:text>:</xsl:text>
				<xsl:text>&#xa;      operationId: </xsl:text><xsl:value-of select="ep:tech-name" />
				<xsl:text>&#xa;      description: '</xsl:text><xsl:value-of select="$documentation" /><xsl:text>'</xsl:text>
				<xsl:choose>
					<xsl:when test="contains($parametersRequired,'J') or 
									$checkedUriStructure//ep:uriPart/ep:param[@path='true'] or 
									$checkedUriStructure//ep:uriPart/ep:param[empty(@path) or @path = 'false']">
						<xsl:text>&#xa;      parameters: </xsl:text>
						<xsl:if test="@pagination = 'true'">
							<xsl:text>&#xa;        - in: query</xsl:text>
							<xsl:text>&#xa;          name: page</xsl:text>
							<xsl:text>&#xa;          description: Een pagina binnen de gepagineerde resultatenset.</xsl:text>
							<xsl:text>&#xa;          required: false</xsl:text>
							<xsl:text>&#xa;          schema:</xsl:text>
							<xsl:text>&#xa;            type: integer</xsl:text>
							<xsl:text>&#xa;            minimum: 1</xsl:text>
						</xsl:if>
						<xsl:if test="@expand = 'true'">
							<xsl:text>&#xa;        - in: query</xsl:text>
							<xsl:text>&#xa;          name: expand</xsl:text>
							<xsl:text>&#xa;          description: "Hier kan aangegeven worden welke gerelateerde resources meegeladen moeten worden. Als expand=true wordt meegegeven, dan worden alle geneste resources geladen en in _embedded meegegeven. Ook kunnen de specifieke resources en velden van resources die gewenst zijn in de expand parameter kommagescheiden worden opgegeven. Specifieke velden van resource kunnen worden opgegeven door het opgeven van de resource-naam gevolgd door de veldnaam, met daartussen een punt."</xsl:text>
							<xsl:text>&#xa;          required: false</xsl:text>
							<xsl:text>&#xa;          schema:</xsl:text>
							<xsl:text>&#xa;            type: string</xsl:text>
							<xsl:text>&#xa;            example: kinderen,adressen.postcode,adressen.huisnummer</xsl:text>
									</xsl:if>
						<xsl:if test="@fields = 'true'">
							<xsl:text>&#xa;        - in: query</xsl:text>
							<xsl:text>&#xa;          name: fields</xsl:text>
							<xsl:text>&#xa;          description: "Geeft de mogelijkheid de inhoud van de body van het antwoord naar behoefte aan te passen. Bevat een door komma's gescheiden lijst van veldennamen. Als niet-bestaande veldnamen worden meegegeven wordt een 400 Bad Request teruggegeven. Wanneer de parameter fields niet is opgenomen, worden alle gedefinieerde velden die een waarde hebben teruggegeven."</xsl:text>
							<xsl:text>&#xa;          required: false</xsl:text>
							<xsl:text>&#xa;          schema:</xsl:text>
							<xsl:text>&#xa;            type: string</xsl:text>
							<xsl:text>&#xa;            example: id,onderwerp,aanvrager,wijzig_datum</xsl:text>
						</xsl:if>
						<xsl:if test="@sort = 'true'">
							<xsl:text>&#xa;        - in: query</xsl:text>
							<xsl:text>&#xa;          name: sorteer</xsl:text>
							<xsl:text>&#xa;          description: "Aangeven van de sorteerrichting van resultaten. Deze query-parameter accepteert een lijst van velden waarop gesorteerd moet worden gescheiden door een komma. Door een minteken (“-”) voor de veldnaam te zetten wordt het veld in aflopende sorteervolgorde gesorteerd."</xsl:text>
							<xsl:text>&#xa;          required: false</xsl:text>
							<xsl:text>&#xa;          schema:</xsl:text>
							<xsl:text>&#xa;            type: string</xsl:text>
							<xsl:text>&#xa;            example: -prio,aanvraag_datum</xsl:text>
						</xsl:if>
<?x						<xsl:variable name="typelist" as="node()*">
							<xsl:for-each select="ep:seq/ep:construct/ep:type-name">
								<xsl:variable name="name" select="." />
								<xsl:for-each
									select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$name]/ep:seq/ep:construct[empty(@type)]">
									<xsl:copy-of select="." />
								</xsl:for-each>
							</xsl:for-each>
						</xsl:variable> ?>
			
						<xsl:for-each select="$checkedUriStructure//ep:uriPart/ep:param[@path='true']">
							<xsl:variable name="datatype">
								<xsl:choose>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'date'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'year'">
										<xsl:value-of select="'integer'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'yearmonth'">
										<xsl:value-of select="'integer'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'dateTime'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'postcode'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'boolean'">
										<xsl:value-of select="'boolean'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'string'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'integer'">
										<xsl:value-of select="'integer'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'decimal'">
										<xsl:value-of select="'number'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'uri'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name">
										<xsl:variable name="type" select="ep:type-name"/>
										<xsl:variable name="enumtype" select="$message-sets//ep:message-set/ep:construct[ep:tech-name = $type]/ep:data-type"/>
										<xsl:choose>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'date'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'year'">
												<xsl:value-of select="'integer'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'yearmonth'">
												<xsl:value-of select="'integer'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'dateTime'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'postcode'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'boolean'">
												<xsl:value-of select="'boolean'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'string'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'integer'">
												<xsl:value-of select="'integer'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'decimal'">
												<xsl:value-of select="'number'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'uri'">
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
							</xsl:variable>
							<xsl:text>&#xa;        - in: path</xsl:text>
							<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
							<xsl:text>&#xa;          description: "</xsl:text><xsl:value-of select="translate(ep:documentation,'&quot;',' ')" /><xsl:text>"</xsl:text>
							<xsl:text>&#xa;          required: true</xsl:text>
							<xsl:text>&#xa;          schema:</xsl:text>
							<xsl:choose>
								<xsl:when test="ep:data-type">
									<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
									<xsl:variable name="facets">
										<xsl:call-template name="deriveFacets">
											<xsl:with-param name="incomingType">
												<xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:value-of select="$facets"/>
									<xsl:if test="ep:example">
										<xsl:text>&#xa;          example: </xsl:text><xsl:value-of select="ep:example"/>
									</xsl:if>
								</xsl:when>
								<xsl:when test="ep:type-name">
									<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;#/components/schemas/',ep:type-name,'&quot;')"/>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
						<xsl:for-each select="$checkedUriStructure//ep:uriPart/ep:param[empty(@path) or @path = 'false']">
							<xsl:variable name="datatype">
								<xsl:choose>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'date'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'year'">
										<xsl:value-of select="'integer'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'yearmonth'">
										<xsl:value-of select="'integer'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'dateTime'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'postcode'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'boolean'">
										<xsl:value-of select="'boolean'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'string'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'integer'">
										<xsl:value-of select="'integer'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'decimal'">
										<xsl:value-of select="'number'"/>
									</xsl:when>
									<xsl:when test="substring-after(ep:data-type, 'scalar-') = 'uri'">
										<xsl:value-of select="'string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name">
										<xsl:variable name="type" select="ep:type-name"/>
										<xsl:variable name="enumtype" select="$message-sets//ep:message-set/ep:construct[ep:tech-name = $type]/ep:data-type"/>
										<xsl:choose>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'date'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'year'">
												<xsl:value-of select="'integer'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'yearmonth'">
												<xsl:value-of select="'integer'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'dateTime'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'postcode'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'boolean'">
												<xsl:value-of select="'boolean'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'string'">
												<xsl:value-of select="'string'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'integer'">
												<xsl:value-of select="'integer'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'decimal'">
												<xsl:value-of select="'number'"/>
											</xsl:when>
											<xsl:when test="substring-after($enumtype, 'scalar-') = 'uri'">
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
							</xsl:variable>
							<xsl:text>&#xa;        - in: query</xsl:text>
							<xsl:text>&#xa;          name: </xsl:text><xsl:value-of select="ep:name" />
							<xsl:text>&#xa;          description: "</xsl:text><xsl:value-of select="translate(ep:documentation,'&quot;',' ')" /><xsl:text>"</xsl:text>
							<xsl:text>&#xa;          required: false</xsl:text>
							<xsl:text>&#xa;          schema:</xsl:text>
							<xsl:choose>
								<xsl:when test="ep:data-type">
									<xsl:text>&#xa;            type: </xsl:text><xsl:value-of select="$datatype" />
									<xsl:variable name="facets">
										<xsl:call-template name="deriveFacets">
											<xsl:with-param name="incomingType">
												<xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
											</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:value-of select="$facets"/>
									<xsl:if test="ep:example">
										<xsl:text>&#xa;          example: </xsl:text><xsl:value-of select="ep:example"/>
									</xsl:if>
								</xsl:when>
								<xsl:when test="ep:type-name">
									<xsl:text>&#xa;              $ref: </xsl:text><xsl:value-of select="concat('&quot;#/components/schemas/',ep:type-name,'&quot;')"/>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<xsl:text>&#xa;      responses:</xsl:text>
				<xsl:text>&#xa;        '200':</xsl:text>
				<xsl:text>&#xa;          description: Zoekactie geslaagd</xsl:text>
				<xsl:text>&#xa;          headers:</xsl:text>
				<xsl:text>&#xa;            api-version:</xsl:text>
				<xsl:text>&#xa;              $ref: '#/components/headers/api_version'</xsl:text>
				<xsl:text>&#xa;            warning:</xsl:text>
				<xsl:text>&#xa;              $ref: '#/components/headers/warning'</xsl:text>
				<xsl:if test="@grouping='collection'">
					<xsl:text>&#xa;            X-Total-Count:</xsl:text>
					<xsl:text>&#xa;              $ref: '#/components/headers/X_Total_Count'</xsl:text>
					<xsl:if test="@pagination='true'">
						<xsl:text>&#xa;            X-Pagination-Count:</xsl:text>
						<xsl:text>&#xa;              $ref: '#/components/headers/X_Pagination_Count'</xsl:text>
						<xsl:text>&#xa;            X-Pagination-Page:</xsl:text>
						<xsl:text>&#xa;              $ref: '#/components/headers/X_Pagination_Page'</xsl:text>
						<xsl:text>&#xa;            X-Pagination-Limit:</xsl:text>
						<xsl:text>&#xa;              $ref: '#/components/headers/X_Pagination_Limit'</xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:text>&#xa;            X-Rate-Limit-Limit:</xsl:text>
				<xsl:text>&#xa;              $ref: '#/components/headers/X_Rate_Limit_Limit'</xsl:text>
				<xsl:text>&#xa;            X-Rate-Limit-Remaining:</xsl:text>
				<xsl:text>&#xa;              $ref: '#/components/headers/X_Rate_Limit_Remaining'</xsl:text>
				<xsl:text>&#xa;            X-Rate-Limit-Reset:</xsl:text>
				<xsl:text>&#xa;              $ref: '#/components/headers/X_Rate_Limit_Reset'  </xsl:text>
				<xsl:text>&#xa;          content:</xsl:text>
				<xsl:text>&#xa;            application/hal+json:</xsl:text>
				<xsl:text>&#xa;              schema:</xsl:text>
				<xsl:for-each
					select="../ep:message[@messagetype = 'response' and ep:name = $messageName]">
					<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text>
					<xsl:choose>
						<xsl:when test="@grouping = 'resource'">
							<xsl:value-of select="ep:seq/ep:construct/ep:type-name" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="concat(ep:seq/ep:construct/ep:type-name,'_collection')" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>'</xsl:text>
				</xsl:for-each>
				<xsl:text>&#xa;        default:</xsl:text>
				<xsl:text>&#xa;          description: Er is een onverwachte fout opgetreden.</xsl:text>
				<xsl:text>&#xa;          content:</xsl:text>
				<xsl:text>&#xa;            application/problem+json:</xsl:text>
				<xsl:text>&#xa;              schema:  </xsl:text>
				<xsl:text>&#xa;                $ref: '#/components/schemas/Foutbericht'</xsl:text>
			</xsl:when>
			<xsl:when test="contains(@berichtcode,'Po') and @messagetype = 'request'">
				<xsl:variable name="messageName" select="ep:name" />
				<xsl:variable name="documentation">
					<xsl:text>"</xsl:text><xsl:apply-templates select="ep:documentation" /><xsl:text>"</xsl:text>
				</xsl:variable>
				<xsl:variable name="method">post</xsl:variable>
				<xsl:variable name="exampleSleutelEntiteittype">
					<xsl:variable name="id" select=".//ep:type-name"/>
					<xsl:variable name="construct" select="//ep:message-set/ep:construct[ep:tech-name = $id]"/>
					<xsl:value-of select="$construct//ep:construct[@is-id='true']/ep:example"/>
				</xsl:variable>
	
				<xsl:text>&#xa;    </xsl:text><xsl:value-of select="$method"/><xsl:text>:</xsl:text>
				<xsl:text>&#xa;      operationId: </xsl:text>post<xsl:value-of select="ep:tech-name" />
				<xsl:text>&#xa;      description: '</xsl:text><xsl:value-of select="$documentation" /><xsl:text>'</xsl:text>
				<xsl:text>&#xa;      requestBody:</xsl:text>
				<xsl:text>&#xa;        content:</xsl:text>
				<xsl:text>&#xa;          application/hal+json:</xsl:text>
				<xsl:text>&#xa;            schema:</xsl:text>
				<xsl:text>&#xa;              $ref: '#/components/schemas/</xsl:text><xsl:value-of select="ep:seq/ep:construct/ep:type-name" /><xsl:text>'</xsl:text>
				<xsl:text>&#xa;      responses:</xsl:text>
				<xsl:text>&#xa;        '201':</xsl:text>
				<xsl:text>&#xa;          description: OK</xsl:text>
				<xsl:text>&#xa;          headers:</xsl:text>
				<xsl:text>&#xa;            Location:</xsl:text>
				<xsl:text>&#xa;              description: URI van de nieuwe resource</xsl:text>
				<xsl:text>&#xa;              schema:</xsl:text>
				<xsl:text>&#xa;                type: string</xsl:text>
				<xsl:text>&#xa;                format: uri</xsl:text>
				<xsl:text>&#xa;                example: '</xsl:text><xsl:value-of select="concat($messageName,'/',$exampleSleutelEntiteittype)" /><xsl:text>'</xsl:text>
				<xsl:text>&#xa;          content:</xsl:text>
				<xsl:text>&#xa;            application/hal+json:</xsl:text>
				<xsl:text>&#xa;              schema:</xsl:text>
				<xsl:text>&#xa;                $ref: '#/components/schemas/</xsl:text><xsl:value-of select="ep:seq/ep:construct/ep:type-name" /><xsl:text>'</xsl:text>
				<xsl:text>&#xa;        default:</xsl:text>
				<xsl:text>&#xa;          description: Bad Request.</xsl:text>
				<xsl:text>&#xa;          content:</xsl:text>
				<xsl:text>&#xa;            application/problem+problem:</xsl:text>
				<xsl:text>&#xa;              schema:  </xsl:text>
				<xsl:text>&#xa;                $ref: '#/components/schemas/Foutbericht'</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ep:documentation">
		<xsl:apply-templates select="ep:description" />
	</xsl:template>

	<xsl:template match="ep:description">
		<xsl:apply-templates select="ep:p" />
	</xsl:template>

	<xsl:template match="ep:p">
		<xsl:value-of select="." />
		<xsl:if test="following-sibling::ep:p">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ep:construct" mode="getParameters">
		<xsl:for-each select="ep:seq/ep:construct[empty(@type)]">
			<ep:param>
				<xsl:if test="@is-id = 'true'">
					<xsl:attribute name="is-id" select="'true'"/>
				</xsl:if>
				<ep:name><xsl:value-of select="lower-case(ep:name)"/></ep:name>
				<ep:documentation><xsl:value-of select="ep:documentation"/></ep:documentation>
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
				<xsl:if test="ep:min-waarde != ''">
					<ep:min-waarde><xsl:value-of select="ep:min-waarde"/></ep:min-waarde>
				</xsl:if>
				<xsl:if test="ep:max-waarde != ''">
					<ep:max-waarde><xsl:value-of select="ep:max-waarde"/></ep:max-waarde>
				</xsl:if>
				<xsl:if test="ep:patroon != ''">
					<ep:patroon><xsl:value-of select="ep:patroon"/></ep:patroon>
				</xsl:if>
				<xsl:if test="ep:example != ''">
					<ep:example><xsl:value-of select="ep:example"/></ep:example>
				</xsl:if>
<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
				<xsl:sequence select="imf:create-output-element('ep:min-waarde', $min-waarde)" />
				<xsl:sequence select="imf:create-output-element('ep:max-waarde', $max-waarde)" />
				<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)" />
				<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
			</ep:param>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="ep:construct" mode="getUriPart">
		<xsl:if test="count(ep:seq/ep:construct[@type = 'association']) > 1">
			<!--<xsl:message select="concat('ERROR: There are more than one relations connected to the request class ',ep:name,', this is not allowed.')"/>-->
			<xsl:sequence select="imf:msg(.,'ERROR','There are more than one relations connected to the request class [1] this is not allowed.', (ep:name))" />			
		</xsl:if>
		<xsl:for-each select="ep:seq/ep:construct[@type = 'association']">
			<xsl:variable name="meervoudigeNaam" select="@meervoudigeNaam"/>
			<xsl:variable name="parameterConstruct" select="ep:type-name"/>
			<ep:uriPart>
				<ep:entityName><xsl:value-of select="lower-case($meervoudigeNaam)"/></ep:entityName>
				<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]" mode="getParameters"/>
			</ep:uriPart>
			<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $parameterConstruct]" mode="getUriPart"/>
		</xsl:for-each>
	</xsl:template>

<!--	<xsl:function name="imf:checkUriStructure">-->
	<xsl:template name="checkUriStructure">
		<xsl:param name="determinedUriStructure"/>
		<xsl:param name="calculatedUriStructure"/>
		<xsl:param name="uriPart2Check"/>
		<xsl:param name="messageName"/>
		
		<xsl:for-each select="ep:uriPart[position() = $uriPart2Check]">
			<xsl:variable name="entityName" select="ep:entityName"/>
			<ep:uriPart>
				<xsl:choose>
					<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:entityName = $entityName">
						<ep:entityName path="true"><xsl:value-of select="$entityName"/></ep:entityName>
					</xsl:when>
					<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:entityName != $entityName">
						<xsl:sequence select="imf:msg(.,'WARNING','The entityname [1] within the message [2] is not available within the query tree or is not on the right position within the path.', ($entityName,$messageName))" />			
						<ep:entityName path="false"><xsl:value-of select="$entityName"/></ep:entityName>
					</xsl:when>
					<xsl:when test="empty($determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check])">
						<ep:entityName path="false"><xsl:value-of select="$entityName"/></ep:entityName>
					</xsl:when>
				</xsl:choose>
				<xsl:for-each select="ep:param">
					<xsl:variable name="paramName" select="ep:name"/>
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
					<xsl:variable name="min-waarde">
						<xsl:value-of select="ep:min-waarde"/>
					</xsl:variable>
					<xsl:variable name="max-waarde">
						<xsl:value-of select="ep:max-waarde"/>
					</xsl:variable>
					<xsl:variable name="patroon">
						<xsl:value-of select="ep:patroon"/>
					</xsl:variable>
					<xsl:variable name="example">
						<xsl:value-of select="ep:example"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param/ep:name = $paramName and $is-id = 'true'">
							<ep:param path="true">
								<ep:name><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<ep:documentation><xsl:value-of select="normalize-space(ep:documentation)"/></ep:documentation>
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-waarde != ''">
									<ep:min-waarde><xsl:value-of select="$min-waarde"/></ep:min-waarde>
								</xsl:if>
								<xsl:if test="$max-waarde != ''">
									<ep:max-waarde><xsl:value-of select="$max-waarde"/></ep:max-waarde>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:patroon><xsl:value-of select="$patroon"/></ep:patroon>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
	<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-waarde', $min-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:max-waarde', $max-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:when>
						<xsl:when test="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param/ep:name = $paramName and $is-id = 'false'">
							<!--<xsl:message select="concat('WARNING: The path parameter ',$paramName,' within the message ',$messageName,' is not an id attribute.')"/>-->
							<xsl:sequence select="imf:msg(.,'WARNING','The path parameter ([1]) within the message [2] is not an id attribute.', ($paramName,$messageName))" />			
							<ep:param path="false">
								<ep:name><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<ep:documentation><xsl:value-of select="normalize-space(ep:documentation)"/></ep:documentation>
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-waarde != ''">
									<ep:min-waarde><xsl:value-of select="$min-waarde"/></ep:min-waarde>
								</xsl:if>
								<xsl:if test="$max-waarde != ''">
									<ep:max-waarde><xsl:value-of select="$max-waarde"/></ep:max-waarde>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:patroon><xsl:value-of select="$patroon"/></ep:patroon>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
	<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-waarde', $min-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:max-waarde', $max-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:when>
						<xsl:otherwise>
							<ep:param>
								<ep:name><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<ep:documentation><xsl:value-of select="normalize-space(ep:documentation)"/></ep:documentation>
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-waarde != ''">
									<ep:min-waarde><xsl:value-of select="$min-waarde"/></ep:min-waarde>
								</xsl:if>
								<xsl:if test="$max-waarde != ''">
									<ep:max-waarde><xsl:value-of select="$max-waarde"/></ep:max-waarde>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:patroon><xsl:value-of select="$patroon"/></ep:patroon>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
	<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-waarde', $min-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:max-waarde', $max-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:for-each select="$determinedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param">
						<xsl:variable name="paramName" select="ep:name"/>
						<xsl:if test="not($calculatedUriStructure/ep:uriStructure/ep:uriPart[position() = $uriPart2Check]/ep:param/ep:name = $paramName)">
							<xsl:sequence select="imf:msg(.,'WARNING','The path parameter ([1]) within the message [2] is not avalable as query parameter.', ($paramName,$messageName))" />			
							<ep:param path="false">
								<ep:name><xsl:value-of select="$paramName"/></ep:name>
								<xsl:choose>
									<xsl:when test="string-length($data-type)">
										<ep:data-type><xsl:value-of select="$data-type"/></ep:data-type>
									</xsl:when>
									<xsl:when test="string-length($type-name)">
										<ep:type-name><xsl:value-of select="$type-name"/></ep:type-name>
									</xsl:when>
								</xsl:choose>
								<ep:documentation><xsl:value-of select="normalize-space(ep:documentation)"/></ep:documentation>
								<xsl:if test="$max-length != ''">
									<ep:max-length><xsl:value-of select="$max-length"/></ep:max-length>
								</xsl:if>
								<xsl:if test="$min-waarde != ''">
									<ep:min-waarde><xsl:value-of select="$min-waarde"/></ep:min-waarde>
								</xsl:if>
								<xsl:if test="$max-waarde != ''">
									<ep:max-waarde><xsl:value-of select="$max-waarde"/></ep:max-waarde>
								</xsl:if>
								<xsl:if test="$patroon != ''">
									<ep:patroon><xsl:value-of select="$patroon"/></ep:patroon>
								</xsl:if>
								<xsl:if test="$example != ''">
									<ep:example><xsl:value-of select="$example"/></ep:example>
								</xsl:if>
	<?x							<xsl:sequence select="imf:create-output-element('ep:max-length', $min-length)" />
								<xsl:sequence select="imf:create-output-element('ep:min-waarde', $min-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:max-waarde', $max-waarde)" />
								<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)" />
								<xsl:sequence select="imf:create-output-element('ep:example', $example)" /> ?>
							</ep:param>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</ep:uriPart>
		</xsl:for-each>
		<xsl:if test="not($uriPart2Check + 1 > count($calculatedUriStructure//ep:uriPart))">
<!--			<xsl:sequence select="imf:checkUriStructure($determinedUriStructure,$calculatedUriStructure,$uriPart2Check + 1,$messageName)"/>
-->			<xsl:call-template name="checkUriStructure">
				<xsl:with-param name="uriPart2Check" select="$uriPart2Check + 1"/>
				<xsl:with-param name="determinedUriStructure" select="$determinedUriStructure"/>
				<xsl:with-param name="calculatedUriStructure" select="$calculatedUriStructure"/>
				<xsl:with-param name="messageName" select="$messageName"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!--</xsl:function>-->

    <xsl:template name="deriveFacets">
        <xsl:param name="incomingType"/>
        
  		<!-- Some scalar typse can have one or more facets which restrict the allowed value. -->
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
            <xsl:when test="$incomingType = 'decimal'">
				<xsl:if test="ep:min-value">
					<xsl:text>&#xa;            minimum: </xsl:text><xsl:value-of select="ep:min-value"/>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<xsl:text>&#xa;            maximum: </xsl:text><xsl:value-of select="ep:max-value"/>
				</xsl:if>
            </xsl:when>
       	<xsl:when test="$incomingType = 'postcode'">
       		<xsl:text>&#xa;            pattern: ^[1-9]{1}[0-9]{3}[A-Z]{2}$</xsl:text>
       	</xsl:when>
       	<xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
