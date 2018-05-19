<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ep="http://www.imvertor.org/schema/endproduct" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com" version="2.0">
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>

    <!-- Deze functies halen alleen unieke nodes op uit een node collectie. Hierdoor worden dubbelingen verwijderd -->
    <xsl:function name="functx:is-node-in-sequence-deep-equal" as="xs:boolean">
        <xsl:param name="node" as="node()?"/>
        <xsl:param name="seq" as="node()*"/>

        <xsl:sequence select="
            some $nodeInSeq in $seq satisfies deep-equal($nodeInSeq,$node)
            "/>
    </xsl:function>

    <xsl:function name="functx:distinct-deep" as="node()*">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:sequence
            select="
            for $seq in (1 to count($nodes))
            return $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
            .,$nodes[position() &lt; $seq]))]
            "
        />
    </xsl:function>

    <xsl:template match="ep:message-sets">

        <!-- vind de koppelvlak namespace: -->
        <xsl:variable name="root">
            <xsl:copy-of select="."/>
        </xsl:variable>

        <!-- header-->
        <xsl:text>openapi: 3.0.0
info:
    version: "1.0"
    title: 'xml2json'
    description: 'xml2json'
servers:
  - url: https://virtserver.swaggerhub.com/King3/King_OA3/1.0</xsl:text>

        <!--
            Namen van methodes in Vraag/antwoord berichten worden anders aangegeven. Bijvoorbeeld bij de API voor het opvragen van 'vergadering' heet de methode 'vergaderingen'.
Vervolgens heet het antwoord object 'vergadering'. Deze naamgevingen moeten gebruikt worden in de API beschrijving als pad namen.
            -->
        <xsl:text>&#xa;paths:</xsl:text>

        <!-- Vraagberichten en vrije berichten-->
        <xsl:for-each select="ep:message-set/ep:message[@messagetype = 'request']">
            <xsl:variable name="servicename" select="@servicename"/>
            <xsl:if test="exists(/ep:message-sets/ep:message-set/ep:message[@servicename = $servicename][@messagetype = 'response'])">
                <xsl:text>&#xa; </xsl:text>
                <xsl:value-of select="concat('/',$servicename,':')"/>
                <xsl:text>&#xa;  get:
   tags:
    - </xsl:text>
                <xsl:value-of select="'Nog-in-te-vullen'"/>
                <xsl:text>   
   summary: ''
   operationId: </xsl:text>
                <xsl:value-of select="$servicename"/>
                <xsl:text>&#xa;   parameters: </xsl:text>
                <xsl:variable name="typelist" as="node()*">
                    <!-- - Bij vraagberichten mag er vanuit worden gegaan dat er altijd een 'gelijk', 'vanaf' en 'tot en met' construct benoemd is. Daar mag dus hard op gecodeerd worden.
	De inhoud van deze drie constructs vormen de parameters van het vraagbericht.-->
                    <xsl:for-each
                        select="ep:seq/ep:construct/ep:type-name">
                        <xsl:variable name="name" select="."/>
                        <xsl:for-each
                            select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$name]/ep:seq/ep:construct">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:for-each select="functx:distinct-deep($typelist)">
                    <xsl:text>
    - in: </xsl:text>
                    <!-- TODO: Bepalen wanneer 'path' moet worden gegenereerd en wanneer 'query'. -->
                    <!--xsl:choose>
                        <xsl:when test="ep:kerngegeven = 'JA'">
                            <xsl:value-of select="'path'"/>
                        </xsl:when>
                        <xsl:otherwise-->
                            <xsl:value-of select="'query'"/>
                        <!--/xsl:otherwise>
                    </xsl:choose-->
                    <xsl:text>
      name: </xsl:text>
                    <xsl:value-of select="ep:tech-name"/>
                    <xsl:text>
      description: OK
      required: </xsl:text>
                    <!-- TODO: Bepalen wanneer 'true' moet worden gegenereerd en wanneer 'false'. -->
                    <!--xsl:choose>
                        <xsl:when test="ep:kerngegeven = 'JA'">
                            <xsl:value-of select="'true'"/>
                        </xsl:when>
                        <xsl:otherwise-->
                            <xsl:value-of select="'false'"/>
                        <!--/xsl:otherwise>
                    </xsl:choose-->
                    <xsl:text>
      schema:
        $ref: '#/components/schemas/</xsl:text>
                    <xsl:value-of select="substring-after(ep:type-name, ':')"/>
                    <xsl:text>'</xsl:text>
                </xsl:for-each>



                <xsl:text>
   responses:
    200:
     description: OK
     content:
      application/json:
       schema:
        items:
       </xsl:text>
                <xsl:for-each select="../ep:message[@messagetype = 'response'][@servicename=$servicename]">
                    <xsl:text>  $ref: '#/components/schemas/</xsl:text>
                    <xsl:value-of select="ep:seq/ep:construct/ep:type-name"/>
                    <xsl:text>'</xsl:text>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>



        <!-- Kennisgevingen: 
        <xsl:for-each select="ep:message-set/ep:message[ep:type = 'Kennisgevingbericht'][@messagetype = 'request']">
            <xsl:variable name="servicename" select="@servicename"/>

                <xsl:text>&#xa; </xsl:text><xsl:value-of select="concat('/',$kvnamespace,'/',ep:tech-name,':')"/>
                <xsl:text>&#xa;  post:
   tags:
    - </xsl:text><xsl:value-of select="$kvnamespace"/>
                <xsl:text>   
   summary: ''
   operationId: </xsl:text><xsl:value-of select="concat($kvnamespace, '_', ep:tech-name)"/>
                <xsl:text>&#xa;   requestBody: 
        description: OK
        required: true
        content:
         application/json:
          schema:
           $ref: '#/components/schemas/</xsl:text><xsl:value-of select="substring-after(ep:seq/ep:construct[not(@ismetadata)][@prefix='bsmr'][starts-with(ep:type-name, 'bsmr:') or starts-with(ep:type-name, 'bg:')][1]/ep:type-name, ':')"/><xsl:text>'</xsl:text>
                <xsl:text>
   responses:
    200:
     description: OK
     content:
      application/json:
       schema:
        items:
       </xsl:text>
                <xsl:for-each select="../ep:message[@messagetype = 'response'][@servicename=$servicename]">
                    <xsl:text>  $ref: '#/components/schemas/</xsl:text><xsl:value-of select="substring-after(ep:seq/ep:construct[not(@ismetadata)][@prefix='bsmr'][starts-with(ep:type-name, 'bsmr:')][1]/ep:type-name, ':')"/><xsl:text>'</xsl:text>
                </xsl:for-each>
            
        </xsl:for-each>
        -->
    </xsl:template>
</xsl:stylesheet>
