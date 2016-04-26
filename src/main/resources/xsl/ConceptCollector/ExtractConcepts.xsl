<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	
	xmlns:imvert="http://www.imvertor.org/schema/system"
	xmlns:ext="http://www.imvertor.org/xsl/extensions"
	xmlns:imf="http://www.imvertor.org/xsl/functions"

	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:n0pred="http://purl.org/vocab/lifecycle/schema#"
	
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="../common/Imvert-common.xsl"/>	
	
	<!--
     Read all info from kenniskluis. Parse into a local representation of all concepts.
    -->
	
	<xsl:variable name="stylesheet">ExtractConcepts</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: ExtractConcepts.xsl 7440 2016-03-01 15:28:37Z arjan $</xsl:variable>

	<xsl:variable name="concept-documentation-url-mapping" select="imf:get-config-string('properties','CONCEPT_DOCUMENTATION_URL_MAPPING')"/>
	<!-- this parameter may have the infixes [year], [month] and [day] --> 
	<xsl:variable name="concept-documentation-listing-uri" select="imf:get-config-string('properties','CONCEPT_DOCUMENTATION_LISTING_URI')"/>
	<xsl:variable name="concept-documentation-uri" select="imf:get-config-string('properties','CONCEPT_DOCUMENTATION_URI')"/>
	
	<!-- compute correct base url's for RDF concepts -->
	<xsl:variable name="rdf-about-base-url" select="tokenize($concept-documentation-url-mapping,'\s+')[1]"/>
	<xsl:variable name="rdf-inscheme-base-url" select="tokenize($concept-documentation-url-mapping,'\s+')[1]"/>
	<xsl:variable name="rdf-about-mapped-url" select="tokenize($concept-documentation-url-mapping,'\s+')[2]"/>
	<xsl:variable name="rdf-inscheme-mapped-url" select="tokenize($concept-documentation-url-mapping,'\s+')[2]"/>
	
	<xsl:variable name="concept-documentation-listing-uri-expanded" select="imf:insert-fragments-by-name($concept-documentation-listing-uri,$release-info)"/>
	
	<xsl:template match="/imvert:packages">
		<!-- we only write concepts, but processing context document is the imvert file -->
			
		<imvert:concepts>
			<xsl:sequence select="imf:compile-imvert-filter()"/>
			<xsl:variable name="concepts" select="imf:get-rdf-document($concept-documentation-listing-uri-expanded)"/>
			<xsl:variable name="publication-url" select="($concepts/rdf:RDF/rdf:Description/rdfs:isDefinedBy)[1]/@rdf:resource"/>
			<xsl:choose>
				<xsl:when test="not(unparsed-text-available($concept-documentation-listing-uri-expanded))">
					<xsl:sequence select="imf:msg('ERROR','Cannot access the concept listing information using [1]',$concept-documentation-listing-uri-expanded)"/>
				</xsl:when>
				<xsl:when test="not($concepts/rdf:RDF)">
					<xsl:sequence select="imf:msg('ERROR','Unexpected concept listing file structure: [1]',$concept-documentation-listing-uri-expanded)"/>
				</xsl:when>
				<xsl:otherwise>
					<!--
					The date of publication of the complete set of concepts. 
					Note that all concepts are in all cases in the same publication (version management 
					not on the concept level) 
					-->
					<imvert:publication>
						<xsl:value-of select="$publication-url"/>
					</imvert:publication>
					<xsl:apply-templates select="$concepts/rdf:RDF/rdf:Description"/>
				</xsl:otherwise>
			</xsl:choose>
		</imvert:concepts>
	</xsl:template>
	
	<xsl:template match="rdf:Description">
		<xsl:variable name="concept"/>
		<xsl:variable name="about-id" select="imf:map-kenniskluis-about(@rdf:about)"/> <!-- example: ondergronds_bouwwerk -->
		<xsl:variable name="rdf-uri" select="imf:map-kenniskluis-uri(skos:inScheme/@rdf:resource,$about-id)"/>
		<xsl:variable name="info" select="imf:get-rdf-document($rdf-uri)/rdf:RDF/rdf:Description"/>
		<xsl:sequence select="imf:msg('DEBUG','Concept [1]',$info/*:naam)"/>
		<imvert:concept>
			<imvert:id>
				<xsl:value-of select="imf:map-kenniskluis-about(@rdf:about)"/>
			</imvert:id>
			<imvert:uri>
				<xsl:value-of select="@rdf:about"/>
			</imvert:uri>
			<imvert:rdf-uri>
				<xsl:value-of select="$rdf-uri"/>
			</imvert:rdf-uri>
			<xsl:apply-templates select="$info/*"/>
		</imvert:concept>
	</xsl:template>
	
	<xsl:template match="rdf:Description/*:naam">
		<imvert:name lang="{imf:select-lang(.)}">
			<xsl:value-of select="."/>
		</imvert:name>
	</xsl:template>
	<xsl:template match="rdf:Description/*:definitie">
		<imvert:definition lang="{imf:select-lang(.)}">
			<xsl:value-of select="."/>
		</imvert:definition>
	</xsl:template>
	<xsl:template match="rdf:Description/*:toelichting">
		<imvert:explanation lang="{imf:select-lang(.)}">
			<xsl:value-of select="."/>
		</imvert:explanation>
	</xsl:template>
	<xsl:template match="rdf:Description/*:uitleg">
		<imvert:explanation lang="{imf:select-lang(.)}">
			<xsl:value-of select="."/>
		</imvert:explanation>
	</xsl:template>
	<xsl:template match="rdf:Description/*:rationale">
		<imvert:rationale lang="{imf:select-lang(.)}">
			<xsl:value-of select="."/>
		</imvert:rationale>
	</xsl:template>
	
	<xsl:template match="rdf:Description/*:bron">
		<imvert:legal>
			<xsl:value-of select="."/>
		</imvert:legal>
	</xsl:template>
	
	<xsl:template match="rdf:Description/*:state">
		<xsl:if test="@rdf:resource = imf:get-config-parameter('concept-documentation-state-obsolete-uri')">
			<imvert:obsolete/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="rdf:Description/rdf:type">
		<imvert:type>
			<xsl:value-of select="substring-after(@rdf:resource,'#')"/>
		</imvert:type>
	</xsl:template>
	
	<xsl:template match="rdf:Description/rdfs:label">
		<xsl:variable name="lang" select="if (@xml:lang) then @xml:lang else 'nl'"/>
		<imvert:label lang="{$lang}">
			<xsl:value-of select="."/>
		</imvert:label>
	</xsl:template>
	
	<xsl:template match="rdf:Description/rdfs:isDefinedBy">
		<!-- skip in no mode -->
	</xsl:template>
	
	<xsl:template match="rdf:Description/n0pred:isVersionOf">
		<!-- not used -->
	</xsl:template>
	
	<!-- 
		geef de keyword af voor het begrip
		Voorbeeld: kadastraal_object 
	-->
	<xsl:function name="imf:map-kenniskluis-about" as="xs:string">
		<xsl:param name="about-url" as="xs:string"/>
		<xsl:value-of select="tokenize($about-url,'/')[last()]"/>
	</xsl:function>
	
	<!-- 
		Geef een URI af naar het begrip in kenniskluis, op basis van de release datum. 
		Voorbeeld: http://www.kenniskluis.nl/kadaster/doc/2013/03/18/begrippen/kadastraal_object 
	-->
	<xsl:function name="imf:map-kenniskluis-uri" as="xs:string">
		<xsl:param name="resource-url" as="xs:string"/>
		<xsl:param name="about-id" as="xs:string"/>
		<xsl:variable name="info" as="element()+">
			<xsl:sequence select="$release-info"/>
			<frag key="key" value="{$about-id}"/>
		</xsl:variable>
		<xsl:value-of select="imf:insert-fragments-by-name($concept-documentation-uri,$info)"/>
	</xsl:function>

	<!-- RDF content negotiation is currently supplied by ?format=rdf%2Bxml parameter in URL passed -->
	<xsl:function name="imf:get-rdf-document" as="document-node()?">
		<xsl:param name="uri" as="xs:string"/>
		<xsl:sequence select="imf:document($uri)"/>
	</xsl:function>
	
	<xsl:function name="imf:select-lang" as="xs:string">
		<xsl:param name="rdf-element"/>
		<xsl:sequence select="if (exists($rdf-element/@xml:lang)) then $rdf-element/@xml:lang else 'nl'"/>
	</xsl:function>
		
	
</xsl:stylesheet>