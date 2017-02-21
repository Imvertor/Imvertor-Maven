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
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:html="http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="#all" 
	version="2.0">
	<!-- 
		
		This stylesheet provides some utility functions that access traced information, i.e. derivation info 
		
	-->
	<xsl:variable name="model-is-traced-by-user" select="imf:boolean(imf:get-config-string('cli','modelistraced'))"/>
	<xsl:variable name="model-is-traced" select="imf:boolean(imf:get-config-string('system','traces-available'))"/>
	
	<!-- 
		Combine all imvert documentation elements. 
		This returns the HTML for the documentation with special markers between the derived documentation parts. 
	-->
	<xsl:function name="imf:get-compiled-documentation-as-html" as="item()*">
		<xsl:param name="construct" as="element()"/> <!-- any construct that may have documentation -->
		
		<xsl:variable name="docs" select="imf:get-compiled-documentation($construct)" as="element(imvert:documentation)*"/>
		
		<xsl:for-each select="$docs">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<!-- first is the construct passed -->
					<xsl:sequence select="node()"/>
				</xsl:when>
				<xsl:when test="imf:boolean($derive-documentation)">
					<p class="supplierMark" xmlns="http://www.w3.org/1999/xhtml">
						<xsl:value-of select="concat(imf:get-config-parameter('documentation-separator'),@application,' (', @release, ')',imf:get-config-parameter('documentation-separator'))"/>
					</p>
					<xsl:sequence select="node()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		
	</xsl:function>
	
	<!-- 
		Combine all imvert documentation elements. 
		This returns imvert:documentation for any documentation that is specified for that supplier.
	-->
	<xsl:function name="imf:get-compiled-documentation" as="element(imvert:documentation)*">
		<xsl:param name="construct" as="element()"/> <!-- any construct that may have documentation -->
		<xsl:variable name="suppliers" select="imf:get-trace-suppliers-for-construct($construct,1)"/>
		<xsl:for-each select="$suppliers">
			<xsl:variable name="supplier" select="."/>
			
			<xsl:variable name="documentation" as="element(imvert:documentation)?">
				<xsl:variable name="supplied-documentation" select="imf:get-trace-construct-by-supplier($supplier,$imvert-document)/imvert:documentation"/>
				<!-- copy the suppler info attributes to the documentation element -->
				<xsl:if test="exists($supplied-documentation/node())">
					<imvert:documentation>
						<xsl:copy-of select="$supplier/@*"/>
						<xsl:sequence select="$supplied-documentation/node()"/>
					</imvert:documentation>
				</xsl:if>						
			</xsl:variable>
			
			<xsl:sequence select="$documentation"/>
		</xsl:for-each>
		
	</xsl:function>
	
	<!-- 
		Get the latest (client) value specified or derived of any tagged value 
	-->
	<xsl:function name="imf:get-compiled-tagged-values" as="element(tv)*">
		<xsl:param name="construct" as="element()"/> <!-- any construct that may have tagged values -->
		<xsl:param name="include-empty" as="xs:boolean"/>
			
		<xsl:variable name="suppliers" select="imf:get-trace-suppliers-for-construct($construct,1)"/>
		
		<xsl:variable name="tvs" as="element()*">
			<!-- 
				haal alle tagged values op die bekend zijn voor dit model, dus in de configuratie voorkomen 
			-->
			<xsl:for-each-group select="imf:get-config-tagged-values()" group-by="name"> 
				<!-- 
					verzamel deze declararies bij naam, neem de laatste (meest specifieke) 
				-->
				<xsl:for-each select="current-group()[last()]">
					<xsl:variable name="tv-name" select="name"/>
					<xsl:for-each select="if (imf:boolean(derive)) then $suppliers else $suppliers[1]">
						<xsl:variable name="supplier" select="."/>
						<xsl:variable name="supplier-construct" select="imf:get-trace-construct-by-supplier($supplier,$imvert-document)"/>
						<xsl:variable name="tv" select="($supplier-construct/imvert:tagged-values/imvert:tagged-value[imvert:name=$tv-name and normalize-space(imvert:value)])[1]"/>
						<xsl:if test="exists($tv)">
							<tv 
								name="{$tv-name}" 
								original-name="{$tv/imvert:name/@original}" 
								value="{$tv/imvert:value}" 
								original-value="{$tv/imvert:value/@original}" 
								project="{$supplier/@project}"
								application="{$supplier/@application}"
								release="{$supplier/@release}"
								level="{$supplier/@level}"
							/>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:sequence select="if ($include-empty) then $tvs else $tvs[normalize-space(@value)]"/>
	</xsl:function>
	
	<xsl:function name="imf:get-applicable-tagged-values" as="element(tv)*">
		<xsl:param name="this" as="element()"/>
		<xsl:variable name="all-tv" select="imf:get-compiled-tagged-values($this,false())"/>
		<xsl:for-each-group select="$all-tv" group-by="@name">
			<xsl:for-each select="current-group()">
				<xsl:sort select="@level" data-type="number"/>
				<xsl:if test="position() = 1">
					<xsl:sequence select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each-group>
	</xsl:function>
	
	<xsl:function name="imf:get-most-relevant-compiled-taggedvalue" as="xs:string?">
		<xsl:param name="this" as="element()"/>
		<xsl:param name="tv-name" as="xs:string"/>
		<xsl:variable name="tvs" select="imf:get-applicable-tagged-values($this)"/>
		<xsl:variable name="val" select="$tvs[@name=$tv-name]/@value"/>
		<xsl:sequence select="if (exists($val)) then string($val) else ()"/>
	</xsl:function>
	
	<!-- This function gets the most relevant value of a specific tagged-value. The one which is in the current layer or 
		 in the layer most near to the current layer. -->
	<xsl:function name="imf:get-most-relevant-compiled-taggedvaluex" as="xs:string?">
		<xsl:param name="this"/>
		<xsl:param name="name"/>
		<xsl:variable name="most-relevant-level">
			<xsl:for-each select="$this//tv[@name = $name]">
				<xsl:sort select="@level" data-type="number"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="@level"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$this//tv[@name = $name and @level = $most-relevant-level]/@value"/>
	</xsl:function>
	
	<xsl:function name="imf:get-adapted-display-name" as="xs:string?">
		<xsl:param name="client-construct" as="element()"/>
		<!-- 
			A package may have the tagged value "supplier-package-name". 
			This is set to the name of the supplier package (normally, client and supplier package names are the same).
			Note that you cannot (yet) re-map names of classes and properties.
		-->
		<xsl:variable name="remapped-package" select="$client-construct/ancestor-or-self::imvert:package[imvert:supplier-package-name][1]"/>
		<xsl:choose>
			<xsl:when test="empty($remapped-package)"/>
			<xsl:when test="$client-construct/self::imvert:package">
				<xsl:value-of select="imf:compile-construct-name($remapped-package/imvert:supplier-package-name, (), (), ())"/>
			</xsl:when>
			<xsl:when test="$client-construct/self::imvert:class">
				<xsl:value-of select="imf:compile-construct-name($remapped-package/imvert:supplier-package-name, $client-construct/imvert:name, (), ())"/>
			</xsl:when>
			<xsl:when test="$client-construct[self::imvert:attribute or self::imvert:association]">
				<xsl:value-of select="imf:compile-construct-name($remapped-package/imvert:supplier-package-name, $client-construct/../../imvert:name, $client-construct/imvert:name, ())"/>
			</xsl:when>
		</xsl:choose> 
	</xsl:function>
	
	<xsl:function name="imf:canonical-name" as="xs:string">
		<xsl:param name="name"/>
		<xsl:value-of select="lower-case(string-join(tokenize($name,'_'),''))"/>
	</xsl:function>
	
</xsl:stylesheet>