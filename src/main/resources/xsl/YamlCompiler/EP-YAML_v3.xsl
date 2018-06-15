<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ep="http://www.imvertor.org/schema/endproduct" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:functx="http://www.functx.com" version="2.0">
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes" />

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

	<xsl:template match="ep:message-sets">

		<!-- vind de koppelvlak namespace: -->
		<xsl:variable name="root">
			<xsl:copy-of select="." />
		</xsl:variable>

		<!-- header -->
		<xsl:text>openapi: 3.0.0
servers:
  - description: Wat is de bron van deze description?
  - url: https://virtserver.swaggerhub.com/King3/King_OA3/1.0</xsl:text>
		info:
		title: Nog in tv koppelvlak-naam te voorzien
		description: Nog in te voorzien
		version: Nog in te voorzien
		license:
		name: European Union Public License, version 1.2 (EUPL-1.2)
		url: https://eupl.eu/1.2/nl/
		contact:
		email: Nog.inte.voorzien@vng.nl

		<xsl:text>&#xa;paths:</xsl:text>

		<!-- Vraagberichten en vrije berichten -->
		<xsl:for-each select="ep:message-set/ep:message[@messagetype = 'request']">
			<xsl:variable name="messagename" select="ep:name" />
			<xsl:variable name="servicename" select="@servicename" />
			<xsl:variable name="documentation">
				<xsl:apply-templates select="ep:documentation" />
			</xsl:variable>

			<xsl:text>&#xa; </xsl:text>
			<xsl:value-of select="$messagename" />
			<xsl:text>:</xsl:text>
			<xsl:text>&#xa;  get:</xsl:text>
			<xsl:text>&#xa;   summary: '</xsl:text>
			<xsl:value-of select="$documentation" />
			<xsl:text>'</xsl:text>
			<xsl:text>&#xa;   operationId: </xsl:text>
			<xsl:value-of select="$servicename" />
			<xsl:text>&#xa;   parameters: </xsl:text>
			<xsl:if test="@pagination = 'true'">
				<xsl:text>
    - in: query
      name: page
      description: Een pagina binnen de gepagineerde resultatenset.
      required: false
      schema:
        type: integer
        minimum: 1</xsl:text>
			</xsl:if>
			<xsl:if test="@expand = 'true'">
				<xsl:text>
    - in: query
      name: expand
      description: .... Nog te bepalen
      required: false
      schema:
        type: string</xsl:text>
			</xsl:if>
			<xsl:if test="@fields = 'true'">
				<xsl:text>
    - in: query
      name: fields
      description: Geeft de mogelijkheid de inhoud van de body van het antwoord naar behoefte aan te passen. Bevat een door komma's gescheiden lijst van veldennamen. Als niet-bestaande veldnamen worden meegegeven wordt een 400 Bad Request teruggegeven. Wanneer de parameter fields niet is opgenomen, worden alle gedefinieerde velden die een waarde hebben teruggegeven.
      required: false
      schema:
        type: string
        example: id,onderwerp,aanvrager,wijzig_datum</xsl:text>
			</xsl:if>
			<xsl:if test="@sort = 'true'">
				<xsl:text>
    - in: query
      name: sorteer
      description: Aangeven van de sorteerrichting van resultaten. Deze query-parameter accepteert een lijst van velden waarop gesorteerd moet worden gescheiden door een komma. Door een minteken (“-”) voor de veldnaam te zetten wordt het veld in aflopende sorteervolgorde gesorteerd.
      required: false
      schema:
        type: string
        example: -prio,aanvraag_datum</xsl:text>
			</xsl:if>
			<xsl:variable name="typelist" as="node()*">
				<xsl:for-each select="ep:seq/ep:construct/ep:type-name">
					<xsl:variable name="name" select="." />
					<xsl:for-each
						select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$name]/ep:seq/ep:construct">
						<xsl:copy-of select="." />
					</xsl:for-each>
				</xsl:for-each>
			</xsl:variable>
			<xsl:for-each select="functx:distinct-deep($typelist)">
				<xsl:text>
    - in: query
      name: </xsl:text>
				<xsl:value-of select="ep:tech-name" />
				<xsl:text>
      description: OK
      required: false
      schema:
        $ref: '#/components/schemas/</xsl:text>
				<xsl:value-of select="substring-after(ep:type-name, ':')" />
				<xsl:text>'</xsl:text>
			</xsl:for-each>
			<xsl:text>
   responses:
    200:
     description: Zoekactie geslaagd
     headers:
      api-version:
       $ref: '#/components/headers/api_version'</xsl:text>
			<xsl:if test="@grouping='collection'">
				<xsl:text>
		  X-Pagination-Count:
		   $ref: '#/components/headers/X_Pagination_Count'
		  X-Pagination-Page:  
		   $ref: '#/components/headers/X_Pagination_Page'
		  X-Pagination-Limit:
		   $ref: '#/components/headers/X_Pagination_Limit'</xsl:text>
			</xsl:if>
			<xsl:text>
      X-Rate-Limit-Limit:
       $ref: '#/components/headers/X_Rate_Limit_Limit'
      X-Rate-Limit-Remaining:
       $ref: '#/components/headers/X_Rate_Limit_Remaining'
      X-Rate-Limit-Reset:
       $ref: '#/components/headers/X_Rate_Limit_Reset'  
     content:
      application/json:
       schema:
       </xsl:text>
			<xsl:for-each
				select="../ep:message[@messagetype = 'response' and @servicename=$servicename and ep:name = $messagename]">
				<xsl:text>  $ref: '#/components/schemas/</xsl:text>
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
		</xsl:for-each>
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

</xsl:stylesheet>
