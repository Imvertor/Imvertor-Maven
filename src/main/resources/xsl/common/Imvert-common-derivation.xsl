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
	
	<xsl:variable name="derivation-tree" select="imf:document($derivationtree-file-url)"/>

	<xsl:variable name="model-is-traced-by-user" select="imf:boolean(imf:get-config-string('cli','modelistraced'))"/>
	<xsl:variable name="model-is-traced" select="imf:boolean(imf:get-config-string('system','traces-available'))"/>
	
	<xsl:variable name="allow-multiple-suppliers" select="imf:boolean(imf:get-config-string('cli','allowmultiplesuppliers','no'))"/>
	
	<!-- 
		Return the construct in the derivation tree with the specified ID 
		In case of copy-down there may be several.
	-->
	<xsl:function name="imf:get-construct-in-derivation-by-id" as="element()*">
		<xsl:param name="id" as="xs:string"/> <!-- the ID of the construct -->
		<xsl:sequence select="imf:key-imvert-construct-by-id($id,$derivation-tree)"/>
	</xsl:function>
	
	<!-- 
		Pass any construct, and return all derived or deriving client + supplier constructs wrapped in imvert:layer elements 
		Example:
		
		<imvert:layer xmlns:imvert="http://www.imvertor.org/schema/system" project="INFOMOD" application="RM-487531-SIM" release="20140401">
		  <imvert:class display-name="Basismodel::Adresseerbaar object aanduiding_SIM" layered-name="Basismodel_AdresseerbaarObjectAanduiding_SIM">
		     ...
		  </imvert:class>
		</imvert:layer>
	-->
	<xsl:function name="imf:get-construct-in-all-layers" as="element(imvert:layer)*">
		<xsl:param name="client-construct" as="element()"/> <!-- the construct in the layer -->
		
		<!-- note that all construct are traced as the traces are set by user, or inferred by the system -->
		
		<!-- based on trace id, get all constructs in all layers, ordered from client to supplier. -->
		<xsl:variable name="client-name" select="$client-construct/imvert:name"/>
		<xsl:variable name="client-construct-id" select="$client-construct/imvert:id"/>
		<xsl:variable name="client-construct-in-tree" select="if (exists($client-construct-id)) then imf:get-construct-by-id($client-construct-id,$derivation-tree)[1] else ()"/>
		<xsl:variable name="traced" select="imf:get-trace-supply-chain($client-construct,())"/>
		<xsl:variable name="constructs" select="($client-construct-in-tree, $traced)"/>
		<xsl:for-each select="$constructs">
			<xsl:choose>
				<xsl:when test="self::supply-chain-error[@type='NO-SUPPLIER']">
					<!--<xsl:sequence select="imf:msg('WARN','Trace: no supplier found for client [1]', ($client-name))"/>-->
				</xsl:when>
				<xsl:when test="self::supply-chain-error[@type='MULTIPLE-SUPPLIER']">
					<xsl:variable name="supplier-names" select="string-join(for $c in (tokenize(@id,'\s+')) return imf:get-construct-by-id($c,$derivation-tree)/imvert:name,', ')"/>
					<xsl:sequence select="imf:msg('WARN','Trace: more than one supplier found for client [1], suppliers are: [2]', ($client-name, $supplier-names ))"/>
				</xsl:when>
				<xsl:when test="self::supply-chain-error[@type='TRACE-RECURSION']">
					<xsl:sequence select="imf:msg('ERROR','Trace error: recursive trace for client [1]', ($client-name))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="layer" select="ancestor::imvert:supplier"/>
					<xsl:sequence select="imf:create-layer($layer/@project,$layer/@application,$layer/@release,$layer/@level,.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:function>
	
	<!-- create a imvert:layer element -->
	<xsl:function name="imf:create-layer" as="element()">
		<xsl:param name="project" as="xs:string"/>
		<xsl:param name="application" as="xs:string"/>
		<xsl:param name="release" as="xs:string"/>
		<xsl:param name="level" as="xs:string"/>
		<xsl:param name="content" as="item()*"/>
		<imvert:layer id="{imf:get-supplier-id($project,$application,$release)}" project="{$project}" application="{$application}" release="{$release}" level="{$level}">
			<xsl:sequence select="$content"/>
		</imvert:layer>
	</xsl:function>
	
	<!-- 
		Combine all imvert documentation elements. 
		This returns the HTML for the documentation with special markers between the derived documentation parts. 
	-->
	<xsl:function name="imf:get-compiled-documentation" as="item()*">
		<xsl:param name="construct" as="element()"/> <!-- any construct that may have documentation -->
		
		<xsl:variable name="layers" select="imf:get-construct-in-all-layers($construct)"/>
		<xsl:variable name="result" as="item()*">
			<xsl:for-each select="$layers">
				<xsl:if test="position() = 1 or imf:boolean($derive-documentation)">
					<xsl:variable name="doc" select="*/imvert:documentation[*]"/>
					<!-- if supplier has documentation, mark this as extracted from the supplier -->
					<xsl:if test="position() gt 1 and exists($doc/node())">
						<p class="supplierMark" xmlns="http://www.w3.org/1999/xhtml">
							<xsl:value-of select="concat(imf:get-config-parameter('documentation-separator'),@application,' (', @release, ')',imf:get-config-parameter('documentation-separator'))"/>
						</p>
					</xsl:if>
					<xsl:sequence select="$doc/node()"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:sequence select="$result"/>
	</xsl:function>
	
	<!-- 
		Get the latest (client) value specified or derived of any tagged value 
	-->
	<xsl:function name="imf:get-compiled-tagged-values" as="element()*">
		<xsl:param name="construct" as="element()"/> <!-- any construct that may have tagged values -->
		<xsl:param name="include-empty" as="xs:boolean"/>
			
		<xsl:variable name="layers" select="imf:get-construct-in-all-layers($construct)"/>
		
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
					<!-- 
						if derivable (config: derive=yes) get the last tv that actually has a value from the derivation stack 
						otherwise get the current layer value, if any.
					--> 
					<xsl:variable name="is-derivable" select="imf:boolean(derive)"/>
					<xsl:variable name="tv" select="
						if ($is-derivable) 
						then ($layers/imvert:*/imvert:tagged-values/imvert:tagged-value[imvert:name=$tv-name and normalize-space(imvert:value)])[1]
						else $layers[1]/imvert:*/imvert:tagged-values/imvert:tagged-value[imvert:name=$tv-name]"/>
					<xsl:if test="exists($tv)">
						<!-- The tagged value is provided, there's a most specific value -->
						<xsl:variable name="supplier" select="imf:get-supplier-from-layers($tv)"/>
						<xsl:variable name="local" select="if (empty($supplier/preceding-sibling::*)) then 'true' else 'false'"/>
						<d 
							name="{$tv-name}" 
							original-name="{$tv/imvert:name/@original}" 
							value="{$tv/imvert:value}" 
							original-value="{$tv/imvert:value/@original}" 
							project="{$supplier/@project}"
							application="{$supplier/@application}"
							release="{$supplier/@release}"
							local="{$local}"
						/>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:sequence select="if ($include-empty) then $tvs else $tvs[normalize-space(@value)]"/>
	</xsl:function>
	
	
	
	<xsl:function name="imf:get-supplier-from-layers">
		<xsl:param name="construct" as="element()"/>
		<xsl:variable name="construct-id" select="($construct/ancestor::*[imvert:id])[1]/imvert:id"/>
		<xsl:sequence select="imf:get-construct-by-id($construct-id,$derivation-tree)/ancestor::imvert:supplier"/>
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
	
	<!-- for tracing: -->
	
	<!-- 
		Get all constructs in the trace tree that are in supply chain for the supplied client construct 
	-->
	<xsl:function name="imf:get-trace-supply-chain" as="element()*">
		<xsl:param name="client" as="element()*"/>
		<xsl:param name="trace-history" as="element()*"/>
		
		<xsl:for-each select="$client">
			<xsl:variable name="client-id" select="imvert:id"/>
			
			<xsl:variable name="client-in-tree" select="imf:get-construct-by-id($client-id,$derivation-tree)"/> 
			<xsl:variable name="supplier-id" select="$client-in-tree/imvert:trace"/> <!-- may be 0...* traces! -->
			<xsl:variable name="suppliers" select="for $id in ($supplier-id) return imf:get-trace-construct-by-id(.,$id,$derivation-tree)[1]"/>
		
			<!--<xsl:if test="$client-id = 'EAID_490D1086_4161_4c00_A8A9_3C58CFF2CC37'">
				<xsl:message  select="count($client-in-tree)"></xsl:message>
				<xsl:message  select="$supplier-id"></xsl:message>
				<xsl:message  select="count($suppliers)"></xsl:message>
				<xsl:message  select="'-'"></xsl:message>
			</xsl:if>-->
			<xsl:choose>
				<xsl:when test="empty($client-id)">
					<!-- skip: recursion ends here -->
				</xsl:when>
				<xsl:when test="empty($client-in-tree)">
					<!-- skip: there is no (more) client in the derivation -->
				</xsl:when>
				<xsl:when test="empty($supplier-id)">
					<!-- skip, no derivation was specified or inferred -->
				</xsl:when>
				<xsl:when test="$suppliers[2] and not($allow-multiple-suppliers)">
					<supply-chain-error id="{$suppliers/imvert:id}" type="MULTIPLE-SUPPLIER"/>
				</xsl:when>
				<xsl:when test="empty($suppliers)">
					<supply-chain-error id="{$supplier-id}" type="NO-SUPPLIER"/>
				</xsl:when>
				<xsl:when test="$trace-history = $suppliers">
					<supply-chain-error id="{$supplier-id}" type="TRACE-RECURSION"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="for $id in ($supplier-id) return imf:get-trace-construct-by-id(.,$id,$derivation-tree)[1]"/>
					<xsl:sequence select="imf:get-trace-supply-chain($suppliers,($trace-history,$suppliers))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:function>
	
	<!-- get the construct by ID where the id supplied is passed as the value of a trace (imvert:trace) -->
	<xsl:function name="imf:get-trace-construct-by-id">
		<xsl:param name="client"/>
		<xsl:param name="supplier-id"/>
		<xsl:param name="document-root"/>
		<xsl:variable name="supplier-id-corrected">
			<xsl:choose>
				<xsl:when test="$client/self::imvert:class">
					<xsl:value-of select="$supplier-id"/> <!-- EAID_xxx becomes EAID_xxx -->
				</xsl:when>
				<xsl:when test="$client/self::imvert:attribute">
					<xsl:value-of select="$supplier-id"/>  <!-- {xxx} becomes {xxx} -->
				</xsl:when>
				<xsl:when test="$client/self::imvert:association">
					<xsl:value-of select="concat('EAID_',replace(substring($supplier-id,2,string-length($supplier-id) - 2),'-','_'))"/> <!-- {xxx} becomes EAID_xxx -->
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="imf:get-construct-by-id($supplier-id-corrected,$document-root)"/>
	</xsl:function>
	
	<!-- redmine #487844
		
		Get all derived information on the specified construct.
		Specify the name of the informational item. Convention is the name of the imvert element, i.e.
		min-occurs return imvert:min-occurs
		baretype return imvert:baretype 
		etc.
		
		This effectively returns the imvert:N list of this client and all suppliers, in that order.
		Each element has the attributes, taken from the trace info:
		
		@project="GREEN" 
		@application="SampleApplication" 
		@release="20140701" 
		@level="0"
		
		If tagged value is intended:
		Get all the tagged-value elements. 
		This effectively returns the imvert:tagged-value list of this and all suppliers, in that order.
	-->
	<xsl:variable name="traceable-item-names" select="tokenize('
		name
		short-name
		alias
		created
		modified
		version
		phase
		author
		stereotype
		baretype
		type-name
		min-occurs
		max-occurs
		position
		data-location
		documentation
	','\s+')"/>
	
	<xsl:function name="imf:get-construct-derived-items" as="element()*">
		<xsl:param name="construct" as="element()"/> <!-- any construct that may have such information items -->
		<xsl:param name="item-name"/>
		<xsl:param name="is-tagged-value"/>
		<xsl:variable name="layers" select="imf:get-construct-in-all-layers($construct)"/>
		<xsl:choose>
			<xsl:when test="$is-tagged-value">
				<xsl:for-each select="$layers/imvert:*/imvert:tagged-values/imvert:tagged-value[imvert:name = $item-name]">
					<xsl:copy>
						<xsl:copy-of select="../../../@*"/>
						<xsl:sequence select="node()"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$item-name = ($traceable-item-names)">
				<xsl:for-each select="$layers/imvert:*/imvert:*[local-name(.) = $item-name]">
					<xsl:copy>
						<xsl:copy-of select="../../@*"/>
						<xsl:sequence select="node()"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- no alternative -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="imf:get-construct-derived-items" as="element()*">
		<xsl:param name="construct" as="element()"/> <!-- any construct that may have such information items -->
		<xsl:param name="item-name"/>
		<xsl:sequence select="imf:get-construct-derived-items($construct,$item-name,false())"/>
	</xsl:function>
	
	<xsl:function name="imf:get-supplier-id">
		<xsl:param name="application-project"/>
		<xsl:param name="application-name"/>
		<xsl:param name="application-release"/>
		<xsl:sequence select="concat($application-project,'/',$application-name,'/',$application-release)"/>
	</xsl:function>
	
</xsl:stylesheet>