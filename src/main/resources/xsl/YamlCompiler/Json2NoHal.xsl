<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	version="2.0"
	
	exclude-result-prefixes="xs xsl imf"
	>
	
	<!-- 
		
		resolve HAL references. This is a stub as EP generation doen not yet allow for non-HAL output. 
	
	-->
	
	<xsl:import href="../common/Imvert-common.xsl"/>
	
	<xsl:variable name="stylesheet-code" as="xs:string">JNOHAL</xsl:variable>
	
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
		
	<xsl:template match="/json">
		<JSON>
			<JSONOP_schema>http://json-schema.org/draft-05/schema#</JSONOP_schema>
			<title>UNKNOWN</title>
			<xsl:apply-templates select="*"/>
		</JSON>
	</xsl:template>
	
	<xsl:template match="/json/components">
		<definitions>
			<xsl:apply-templates/>
		</definitions>
	</xsl:template>
	
	<xsl:template match="
		/json/components/schemas/Foutbericht | 
		/json/components/schemas/ParamFoutDetails | 
		/json/components/headers
		">
		<!-- remove -->
	</xsl:template>
	
	<xsl:template match="
		/json/components/schemas/*[ends-with(local-name(),'_embedded')]
		">
		<!-- remove -->
	</xsl:template>
	
	<xsl:template match="STUBCOLLECTION">
		<!-- this is a stub -->
	</xsl:template>
	
	<xsl:template match="
		*[ends-with(local-name(),'_links')]
		">
		<!-- remove -->
	</xsl:template>
	
	<xsl:template match="
		/json/components/schemas/Href |
		/json/components/schemas/Link
		">
		<!-- remove -->
	</xsl:template>
	
	<!-- e.g. 
		"_embedded": {"$ref": "#/components/schemas/Regeltypering_embedded"}
     -->
	<xsl:template match="properties/_embedded">
		<xsl:variable name="ref-embedded" select="tokenize(JSONOP_ref,'/')[last()]"/>
		<xsl:variable name="replace-struct" select="/json/components/schemas/*[name() = $ref-embedded]"/>
		<xsl:apply-templates select="$replace-struct/properties/*"/>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template> 
		
</xsl:stylesheet>
