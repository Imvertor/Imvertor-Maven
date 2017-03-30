<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct.xsl 3 2015-11-05 10:35:07Z ArjanLoeffen $ 
-->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:UML="omg.org/UML1.3" 
	xmlns:imvert="http://www.imvertor.org/schema/system" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201" 
	xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
	xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" 
	xmlns:StUF="http://www.stufstandaarden.nl/onderlaag/stuf0302" 
	xmlns:ep="http://www.imvertor.org/schema/endproduct" 
	xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" 
	version="2.0">
	
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>
	
	<xsl:variable name="stylesheet-code">SKS</xsl:variable>
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-schema</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-schema.xsl 1 2015-11-11 12:02:00Z RobertMelskens $</xsl:variable>
	
	<xsl:variable name="StUF-prefix" select="'StUF'"/>
	<xsl:variable name="typeBericht" select="/ep:message-set/ep:message/ep:type"/>
	<xsl:variable name="berichtCode" select="/ep:message-set/ep:message/ep:code"/>
	
	<xsl:template match="ep:message-set">
		<xsl:variable name="message-set-prefix" select="ep:namespace-prefix"/>
		<xsl:variable name="message-set-namespaceIdentifier" select="ep:namespace"/>
		<xsl:variable name="msg" select="'Creating the StUF XML-Schema'"/>
		<xsl:sequence select="imf:msg('DEBUG',$msg)"/>
		<xs:schema targetNamespace="{$message-set-namespaceIdentifier}" elementFormDefault="qualified" attributeFormDefault="unqualified" version="{concat(ep:patch-number,'-',ep:release)}">
			<xsl:for-each select="ep:namespaces/ep:namespace">
				<xsl:namespace name="{@prefix}"><xsl:value-of select="."/></xsl:namespace>
			</xsl:for-each>
			<xsl:variable name="namespaces2bImported">
				<ep:namespaces>
					<!--xsl:for-each select=".//ep:constructRef[@namespaceId and @prefix and not(@prefix = $message-set-prefix) and not(@prefix = $StUF-prefix)] | .//ep:construct[@namespaceId and @prefix and not(@prefix = $message-set-prefix) and not(@prefix = $StUF-prefix)]">
						<xsl:variable name="href" select="ep:href"/>
						<ep:namespace identifier="{@namespaceId}" prefix="{@prefix}"/>
					</xsl:for-each-->
					<xsl:if test="@KV-namespace = 'yes'">
						<xsl:for-each select="..//ep:constructRef[@namespaceId and @prefix and not(@prefix = $message-set-prefix) and not(@prefix = $StUF-prefix)] | ..//ep:construct[@namespaceId and @prefix and not(@prefix = $message-set-prefix) and not(@prefix = $StUF-prefix)]">
							<xsl:variable name="href" select="ep:href"/>
							<ep:namespace identifier="{@namespaceId}" prefix="{@prefix}"/>
						</xsl:for-each>
					</xsl:if>
				</ep:namespaces>
			</xsl:variable>

			<xsl:for-each select="$namespaces2bImported/ep:namespaces/ep:namespace[@prefix != '' and @identifier != '']">
				<xsl:namespace name="{@prefix}"><xsl:value-of select="@identifier"/></xsl:namespace>
			</xsl:for-each>

			<xs:import namespace="http://www.stufstandaarden.nl/onderlaag/stuf0302" schemaLocation="stuf0302.xsd"/>
			<xsl:for-each select="$namespaces2bImported/ep:namespaces/ep:namespace[@prefix != $message-set-prefix and @prefix != '' and not(@prefix = preceding-sibling::ep:namespace/@prefix)]">
				<xs:import namespace="{@identifier}" schemaLocation="{concat(upper-case(@prefix),'.xsd')}"/>
			</xsl:for-each>
			
			<xsl:apply-templates select="ep:message"/>
			<xsl:apply-templates select="ep:construct[@type='group']" mode="complexType"/>
			<xsl:apply-templates select="ep:construct[@type='complexData']" mode="complexType"/>
			<xsl:apply-templates select="ep:construct[not(@type)]" mode="complexType"/>

			<xsl:sequence select="imf:create-debug-comment('simpleTypes to be extended with XML attributes',$debugging)"/>

			<xsl:apply-templates select=".//ep:construct[(ep:length or ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:fraction-digits or ep:formeel-patroon or ep:regels or ep:enum) and ep:type-name and .//ep:construct[@ismetadata]]" mode="createSimpleTypes"/>
			<xsl:apply-templates select="ep:constructRef[@ismetadata]|ep:construct[@ismetadata]" mode="generateAttributes"/>
		</xs:schema>
	</xsl:template>

	<xsl:template match="ep:message">
		<xs:element name="{ep:tech-name}">
			<xsl:if test="ep:documentation">
				<xs:annotation>
					<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
				</xs:annotation>
			</xsl:if>
			<xs:complexType>
				<xsl:apply-templates select="ep:seq"/>
				<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
			</xs:complexType>
		</xs:element>
	</xsl:template>
	
	<xsl:template match="ep:seq">
		<xsl:if test="ep:constructRef[not(@ismetadata)]|ep:construct[not(@ismetadata)]|ep:seq|ep:choice">
			<xs:sequence>
				<xsl:apply-templates select="ep:constructRef[not(@ismetadata)]|ep:construct[not(@ismetadata)]|ep:seq|ep:choice"/>
			</xs:sequence>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:seq" mode="generateAttributes">
		<xsl:apply-templates select="ep:constructRef[@ismetadata]|ep:construct[@ismetadata]" mode="generateAttributes"/>
	</xsl:template>

	<xsl:template match="ep:choice">
		<xs:choice>
			<xsl:apply-templates select="ep:constructRef|ep:construct[not(@ismetadata)]|ep:seq"/>
		</xs:choice>
	</xsl:template>
	
	<xsl:template match="ep:construct">
		<!-- ROME: Waar moet ep:regels naar vertaald worden? -->
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<xsl:variable name="type-name" select="ep:type-name"/>
		<xs:element>
			<xsl:if test="ep:voidable = 'Ja'">
				<xsl:attribute name="nillable" select="'true'"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="contains($type-name,':') and not(ep:enum)">
					<xsl:attribute name="name" select="ep:tech-name"/>
					<xsl:attribute name="type" select="$type-name"/>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>					
					<xsl:if test="ep:documentation">
						<xs:annotation>
							<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
						</xs:annotation>
					</xsl:if>
				</xsl:when>
<!-- ROME: Hieronder wordt een id gegenereerd. Dat is echter eigenlijk niet gewenst omdat daarbij de naam van de simpleType na elke generatie slag anders kan zijn.
		   Dat zou betekenen dat leveranciers steeds hun gegenereerde code moeten aanpassen. We moeten dus een manier zien te vinden die toekomstvaster is. -->
				<xsl:when test="contains($type-name,':') and ep:enum">
					<xsl:attribute name="name" select="ep:tech-name"/>
					<xsl:attribute name="type">
						<xsl:value-of select="concat(ancestor::ep:message-set/@prefix,':',imf:get-normalized-name(concat('simpleType-',ep:tech-name,'-',generate-id()),'type-name'))"/>
					</xsl:attribute>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>					
					<xsl:if test="ep:documentation">
						<xs:annotation>
							<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
						</xs:annotation>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$type-name = 'scalar-date' or $type-name = 'scalar-datetime' or $type-name = 'scalar-year' or $type-name = 'scalar-yearmonth' or $type-name = 'scalar-postcode'">						
					<xsl:attribute name="name" select="ep:tech-name"/>
					<xsl:attribute name="type">
						<xsl:choose>
							<xsl:when test="$type-name = 'scalar-date' and ep:type-modifier = '?'">
								<xsl:value-of select="concat($StUF-prefix,':DatumMogelijkOnvolledig-e')"/>
							</xsl:when>
							<xsl:when test="$type-name = 'scalar-date'">
								<xsl:value-of select="concat($StUF-prefix,':Datum-e')"/>
							</xsl:when>
							<xsl:when test="$type-name = 'scalar-datetime' and ep:type-modifier = '?'">
								<xsl:value-of select="concat($StUF-prefix,':TijdstipMogelijkOnvolledig-e')"/>
							</xsl:when>
							<xsl:when test="$type-name = 'scalar-datetime'">
								<xsl:value-of select="concat($StUF-prefix,':Tijdstip-e')"/>
							</xsl:when>
							<xsl:when test="$type-name = 'scalar-year'">
								<xsl:value-of select="concat($StUF-prefix,':Jaar-e')"/>
							</xsl:when>
							<xsl:when test="$type-name = 'scalar-yearmonth'">
								<xsl:value-of select="concat($StUF-prefix,':JaarMaand-e')"/>
							</xsl:when>
							<xsl:when test="$type-name = 'scalar-postcode'">
								<xsl:value-of select="concat($StUF-prefix,':Postcode-e')"/>
							</xsl:when>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>					
					<xsl:if test="ep:documentation">
						<xs:annotation>
							<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
						</xs:annotation>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="name" select="ep:tech-name"/>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>
					<xsl:choose>
						<!-- When a construct contains facets (which means it has to become an element without child elements) and it contains metadata constructs a 
							 extension complexType needs to be generated which contains the xml-attributes based on a simpleType which contains the facets. -->
						<xsl:when test="(ep:length or ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:fraction-digits or ep:formeel-patroon or ep:regels or ep:enum) and ep:type-name and .//ep:construct[@ismetadata]">
							<xsl:if test="ep:documentation">
								<xs:annotation>
									<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
								</xs:annotation>
							</xsl:if>
							
							<xsl:sequence select="imf:create-debug-comment('situatie 2',$debugging)"/>
							
							<xs:complexType>
								<xs:simpleContent>
									<xs:extension>
										<xsl:attribute name="base" select="concat(ancestor::ep:message-set/@prefix,':',imf:get-normalized-name(concat('simpleType-',ep:tech-name,'-',generate-id()),'type-name'))"/>
										<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
									</xs:extension>						
								</xs:simpleContent>	
							</xs:complexType>
						</xsl:when>
						<!-- When a construct contains facets (which means it has to become an element without child elements) and it doesn't contain metadata constructs 
							 a restriction simpleType can be generated which contains the facets. -->
						<xsl:when test="(ep:length or ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:fraction-digits or ep:formeel-patroon or ep:regels or ep:enum) and ep:type-name">
							<xsl:if test="ep:documentation">
								<xs:annotation>
									<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
								</xs:annotation>
							</xsl:if>

							<xsl:sequence select="imf:create-debug-comment('situatie 3',$debugging)"/>
							
							<xs:simpleType>
								<xs:restriction>
									<xsl:attribute name="base">
										<xsl:choose>
											<xsl:when test="$type-name = 'scalar-integer'">
												<xsl:value-of select="'xs:integer'"/>
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-decimal'">
												<xsl:value-of select="'xs:decimal'"/>
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-string'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-date'">
												<xsl:value-of select="'xs:dateTime'"/>
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-boolean'">
												<xsl:value-of select="'xs:boolean'"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="'xs:string'"/>								
											</xsl:otherwise>
											<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
										</xsl:choose>
									</xsl:attribute>
									<xsl:if test="ep:length">
										<xsl:choose>
											<xsl:when test="$type-name = 'scalar-string'">
												<xs:length value="{ep:length}" />
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-integer' or $type-name = 'scalar-decimal'">
												<xs:totalDigits value="{ep:length}" />
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:max-length">
										<xs:maxLength value="{ep:max-length}" />
									</xsl:if>
									<xsl:if test="ep:min-length">
										<xs:minLength value="{ep:min-length}" />
									</xsl:if>
									<xsl:if test="ep:min-value and ($type-name = 'scalar-integer' or $type-name = 'scalar-decimal')">
										<xs:minInclusive value="{ep:min-value}" />
									</xsl:if>
									<xsl:if test="ep:max-value and ($type-name = 'scalar-integer' or $type-name = 'scalar-decimal')">
										<xs:maxInclusive value="{ep:max-value}" />
									</xsl:if>
									<xsl:if test="ep:fraction-digits">
										<xs:fractionDigits value="{ep:fraction-digits}" />
									</xsl:if>
									<xsl:if test="ep:enum and ($type-name != 'scalar-boolean')">
										<xsl:apply-templates select="ep:enum"/>
									</xsl:if>
									<xsl:if test="ep:formeel-patroon and ($type-name = 'scalar-string' or $type-name = 'scalar-integer' or $type-name = 'scalar-decimal' or $type-name = 'scalar-boolean')">
										<xs:pattern value="{ep:formeel-patroon}" />
									</xsl:if>				
								</xs:restriction>						
							</xs:simpleType>				
						</xsl:when>
						<!-- When a construct doensn't contain facets and metadata constructs a restriction simpleType can be generated without facets. -->
						<xsl:when test="$type-name and .//ep:construct[@ismetadata]">
							<xsl:if test="ep:documentation">
								<xs:annotation>
									<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
								</xs:annotation>
							</xsl:if>

							<xsl:sequence select="imf:create-debug-comment('situatie 4',$debugging)"/>
							
							<xs:complexType>
								<xs:simpleContent>
									<xs:extension>
										<xsl:attribute name="base">
											<xsl:choose>
												<xsl:when test="$type-name = 'scalar-integer'">
													<xsl:value-of select="'xs:integer'"/>
												</xsl:when>
												<xsl:when test="$type-name = 'scalar-decimal'">
													<xsl:value-of select="'xs:decimal'"/>
												</xsl:when>
												<xsl:when test="$type-name = 'scalar-string'">
													<xsl:value-of select="'xs:string'"/>
												</xsl:when>
												<xsl:when test="$type-name = 'scalar-boolean'">
													<xsl:value-of select="'xs:boolean'"/>
												</xsl:when>
												<!-- Wat moet er met scalar-indic gebeuren? -->
												<xsl:otherwise>
													<xsl:value-of select="'xs:string'"/>								
												</xsl:otherwise>
												<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
											</xsl:choose>											
										</xsl:attribute>
										<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
									</xs:extension>						
								</xs:simpleContent>	
							</xs:complexType>
						</xsl:when>
						<!-- When a construct doensn't contain facets and metadata constructs a restriction simpleType can be generated without facets. -->
						<xsl:when test="ep:type-name">
							<xsl:if test="ep:documentation">
								<xs:annotation>
									<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
								</xs:annotation>
							</xsl:if>

							<xsl:sequence select="imf:create-debug-comment('situatie 5',$debugging)"/>
							
							<xs:simpleType>
								<xs:restriction>
									<xsl:attribute name="base">
										<xsl:choose>
											<xsl:when test="$type-name = 'scalar-integer'">
												<xsl:value-of select="'xs:integer'"/>
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-decimal'">
												<xsl:value-of select="'xs:decimal'"/>
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-string'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="$type-name = 'scalar-boolean'">
												<xsl:value-of select="'xs:boolean'"/>
											</xsl:when>
											<!-- Wat moet er met scalar-indic gebeuren? -->
											<xsl:otherwise>
												<xsl:value-of select="'xs:string'"/>								
											</xsl:otherwise>
											<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
										</xsl:choose>
									</xsl:attribute>
									<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
								</xs:restriction>						
							</xs:simpleType>				
						</xsl:when>
						<xsl:when test=".//ep:construct">
							<xsl:if test="ep:documentation">
								<xs:annotation>
									<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
								</xs:annotation>
							</xsl:if>

							<xsl:sequence select="imf:create-debug-comment('situatie 6',$debugging)"/>
							
							<xs:complexType>
								<xsl:apply-templates select="ep:seq[not(@ismetadata)] | ep:choice"/>
								<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
							</xs:complexType>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="ep:documentation">
								<xs:annotation>
									<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
								</xs:annotation>
							</xsl:if>

							<xsl:sequence select="imf:create-debug-comment('situatie 7',$debugging)"/>
							
							<xs:complexType>
								<xsl:apply-templates select="ep:seq[not(@ismetadata)] | ep:choice"/>
								<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
							</xs:complexType>					
						</xsl:otherwise>				
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xs:element>
	</xsl:template>
					
	<xsl:template match="ep:construct" mode="complexType">
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<xsl:if test="ep:seq/ep:* or ep:choice/ep:*">
			<xs:complexType>
				<xsl:attribute name="name" select="ep:tech-name"/>
				<xsl:if test="ep:documentation">
					<xs:annotation>
						<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
					</xs:annotation>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="ep:superconstructRef">
						<xs:complexContent>
							<xs:extension base="{concat(ep:superconstructRef/@prefix,':',ep:superconstructRef/ep:tech-name)}">
								<xsl:apply-templates select="ep:seq | ep:choice"/>
								<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>						
							</xs:extension>
						</xs:complexContent>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="ep:seq | ep:choice"/>
						<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>						
					</xsl:otherwise>
				</xsl:choose>
			</xs:complexType>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:constructRef">
		<xsl:variable name="href" select="ep:href"/>
		<!-- Only if the ep:constructRef refers to an available ep:construct it's transformed to an element. 
			 In theory (and maybe in practice) this can lead to another empty ep:construct which on its turn should be ignored.
			 That situation however isn't solved here. -->
		<xsl:if test=" @prefix = $StUF-prefix or ancestor::ep:message-set//ep:construct[ep:tech-name = $href and (ep:seq/ep:* or ep:choice/ep:*)]">
			<xs:element>
				<xsl:choose>
					<xsl:when test="ep:href">
						<xsl:attribute name="name" select="ep:tech-name"/>
						<xsl:variable name="actualPrefix">
							<xsl:choose>
								<xsl:when test="@prefix"><xsl:value-of select="@prefix"/></xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="ancestor::ep:message-set//ep:construct[ep:tech-name = $href]/@prefix"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:attribute name="type" select="concat($actualPrefix,':',ep:href)"/>					
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="ref" select="concat(@prefix,':',ep:tech-name)"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
				<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>
				<xsl:if test="ep:documentation">
					<xs:annotation>
						<xs:documentation><xsl:value-of select="ep:documentation"/></xs:documentation>
					</xs:annotation>
				</xsl:if>
			</xs:element>
		</xsl:if>
	</xsl:template>
	
	<!-- ROME: Onderstaande template kan mogelijk komen te vervallen (integreren met de andere ep:construct templates). -->
	<xsl:template match="ep:construct" mode="createSimpleTypes">
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="contains(ep:tech-name,concat($StUF-prefix,':'))">
					<xsl:value-of select="substring-after(ep:tech-name,concat($StUF-prefix,':'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ep:tech-name"/>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:variable>
		<xsl:choose>
			<!--xsl:when test="contains(ep:tech-name,':')"/-->		
			<xsl:when test="contains(ep:type-name,':')">
				<xs:simpleType name="{imf:get-normalized-name(concat('simpleType-',ep:tech-name,'-',generate-id()),'type-name')}">
					<xs:restriction>
						<xsl:attribute name="base">
							<xsl:value-of select="ep:type-name"/>
						</xsl:attribute>
						<xsl:if test="ep:enum">
							<xsl:apply-templates select="ep:enum"/>
						</xsl:if>
					</xs:restriction>
				</xs:simpleType>
			</xsl:when>
			<xsl:otherwise>
				<xs:simpleType name="{imf:get-normalized-name(concat('simpleType-',ep:tech-name,'-',generate-id()),'type-name')}">
					<xs:restriction>
						<xsl:attribute name="base">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'scalar-integer'">
									<xsl:value-of select="'xs:integer'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-decimal'">
									<xsl:value-of select="'xs:decimal'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xsl:value-of select="'xs:string'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-date'">
									<xsl:value-of select="'xs:dateTime'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-boolean'">
									<xsl:value-of select="'xs:boolean'"/>
								</xsl:when>
								<!-- Wat moet er met scalar-indic gebeuren? -->
								<xsl:otherwise>
									<xsl:value-of select="'xs:string'"/>								
								</xsl:otherwise>
								<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
							</xsl:choose>
						</xsl:attribute>
						<xsl:if test="ep:length">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xs:length value="{ep:length}" />
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xs:totalDigits value="{ep:length}" />
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:max-length">
							<xs:maxLength value="{ep:max-length}" />
						</xsl:if>
						<xsl:if test="ep:min-length">
							<xs:minLength value="{ep:min-length}" />
						</xsl:if>
						<xsl:if test="ep:min-value and (ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-date')">
							<xs:minInclusive value="{ep:min-value}" />
						</xsl:if>
						<xsl:if test="ep:max-value and (ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-date')">
							<xs:maxInclusive value="{ep:max-value}" />
						</xsl:if>
						<xsl:if test="ep:fraction-digits">
							<xs:fractionDigits value="{ep:fraction-digits}" />
						</xsl:if>
						<!--xsl:if test="ep:enum and (ep:type-name = 'scalar-string' or ep:type-name = 'scalar-date' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal')"-->
						<xsl:if test="ep:enum">
							<xsl:apply-templates select="ep:enum"/>
						</xsl:if>
						<xsl:if test="ep:formeel-patroon and (ep:type-name = 'scalar-string' or ep:type-name = 'scalar-date' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-boolean')">
							<xs:pattern value="{ep:formeel-patroon}" />
						</xsl:if>				
					</xs:restriction>
				</xs:simpleType>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ROME: Onderstaande template kan mogelijk komen te vervallen (integreren met de andere ep:construct templates). -->
	<xsl:template match="ep:construct[@ismetadata='yes']" mode="generateAttributes">
		<xsl:choose>
			<xsl:when test="parent::ep:message-set">
				<xs:attribute name="{ep:tech-name}">
					<xsl:choose>
						<xsl:when test="ep:length or ep:max-length or ep:min-length or ep:min-value or ep:max-value or ep:fraction-digits or ep:enum or ep:formeel-patroon">
							<xs:simpleType>
								<xs:restriction>
									<xsl:attribute name="base">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'scalar-integer'">
												<xsl:value-of select="'xs:integer'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-decimal'">
												<xsl:value-of select="'xs:decimal'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-date'">
												<xsl:value-of select="'xs:dateTime'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-boolean'">
												<xsl:value-of select="'xs:boolean'"/>
											</xsl:when>
											<!-- Wat moet er met scalar-indic gebeuren? -->
											<xsl:otherwise>
												<xsl:value-of select="'xs:string'"/>								
											</xsl:otherwise>
											<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
										</xsl:choose>
									</xsl:attribute>
									<xsl:if test="ep:length">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'scalar-string'">
												<xs:length value="{ep:length}" />
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
												<xs:totalDigits value="{ep:length}" />
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:max-length">
										<xs:maxLength value="{ep:max-length}" />
									</xsl:if>
									<xsl:if test="ep:min-length">
										<xs:minLength value="{ep:min-length}" />
									</xsl:if>
									<xsl:if test="ep:min-value and (ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-date')">
										<xs:minInclusive value="{ep:min-value}" />
									</xsl:if>
									<xsl:if test="ep:max-value and (ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-date')">
										<xs:maxInclusive value="{ep:max-value}" />
									</xsl:if>
									<xsl:if test="ep:fraction-digits">
										<xs:fractionDigits value="{ep:fraction-digits}" />
									</xsl:if>
									<xsl:if test="ep:enum and (ep:type-name = 'scalar-string' or ep:type-name = 'scalar-date' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal')">
										<xsl:apply-templates select="ep:enum"/>
									</xsl:if>
									<xsl:if test="ep:formeel-patroon and (ep:type-name = 'scalar-string' or ep:type-name = 'scalar-date' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-boolean')">
										<xs:pattern value="{ep:formeel-patroon}" />
									</xsl:if>				
								</xs:restriction>
							</xs:simpleType>						
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="type">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'scalar-integer'">
										<xsl:value-of select="'xs:integer'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-decimal'">
										<xsl:value-of select="'xs:decimal'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-date'">
										<xsl:value-of select="'xs:dateTime'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-boolean'">
										<xsl:value-of select="'xs:boolean'"/>
									</xsl:when>
									<!-- Wat moet er met scalar-indic gebeuren? -->
									<xsl:otherwise>
										<xsl:value-of select="'xs:string'"/>								
									</xsl:otherwise>
									<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
								</xsl:choose>							
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xs:attribute>
			</xsl:when>
			<xsl:when test="not(ep:href) and @prefix">
				<xsl:variable name="actualPrefix">
					<xsl:choose>
						<xsl:when test="@prefix = '$actualPrefix'"><xsl:value-of select="ancestor::ep:message-set/@prefix"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="@prefix"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xs:attribute ref="{concat($actualPrefix,':',ep:tech-name)}">
					<xsl:attribute name="use">
						<xsl:choose>
							<xsl:when test="not(ep:min-occurs) or ep:min-occurs=1">required</xsl:when>
							<xsl:otherwise>optional</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xs:attribute>
			</xsl:when>
			<xsl:when test="ep:href">
				<xs:attribute name="{ep:tech-name}" type="{ep:href}">
					<xsl:attribute name="use">
						<xsl:choose>
							<xsl:when test="not(ep:min-occurs) or ep:min-occurs=1">required</xsl:when>
							<xsl:otherwise>optional</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xs:attribute>
			</xsl:when>
			<xsl:when test="not(ep:href) and not(@prefix) and contains(ep:type-name,concat($StUF-prefix,':'))">
				<xs:attribute name="{ep:tech-name}" type="{ep:type-name}">
					<xsl:attribute name="use">
						<xsl:choose>
							<xsl:when test="not(ep:min-occurs) or ep:min-occurs=1">required</xsl:when>
							<xsl:otherwise>optional</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xs:attribute>				
			</xsl:when>
			<xsl:otherwise>
				<xs:attribute name="{ep:tech-name}">
					<xsl:attribute name="use">
						<xsl:choose>
							<xsl:when test="not(ep:min-occurs) or ep:min-occurs=1">required</xsl:when>
							<xsl:otherwise>optional</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xs:simpleType>
						<xs:restriction>
							<xsl:attribute name="base">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'scalar-integer'">
										<xsl:value-of select="'xs:integer'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-decimal'">
										<xsl:value-of select="'xs:decimal'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-date'">
										<xsl:value-of select="'xs:dateTime'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-boolean'">
										<xsl:value-of select="'xs:boolean'"/>
									</xsl:when>
									<!-- Wat moet er met scalar-indic gebeuren? -->
									<xsl:otherwise>
										<xsl:value-of select="'xs:string'"/>								
									</xsl:otherwise>
									<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
								</xsl:choose>
							</xsl:attribute>
							<xsl:if test="ep:length">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'scalar-string'">
										<xs:length value="{ep:length}" />
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
										<xs:totalDigits value="{ep:length}" />
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:max-length">
								<xs:maxLength value="{ep:max-length}" />
							</xsl:if>
							<xsl:if test="ep:min-length">
								<xs:minLength value="{ep:min-length}" />
							</xsl:if>
							<xsl:if test="ep:min-value and (ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-date')">
								<xs:minInclusive value="{ep:min-value}" />
							</xsl:if>
							<xsl:if test="ep:max-value and (ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-date')">
								<xs:maxInclusive value="{ep:max-value}" />
							</xsl:if>
							<xsl:if test="ep:fraction-digits">
								<xs:fractionDigits value="{ep:fraction-digits}" />
							</xsl:if>
							<xsl:if test="ep:enum and (ep:type-name = 'scalar-string' or ep:type-name = 'scalar-date' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal')">
								<xsl:apply-templates select="ep:enum"/>
							</xsl:if>
							<xsl:if test="ep:formeel-patroon and (ep:type-name = 'scalar-string' or ep:type-name = 'scalar-date' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-boolean')">
								<xs:pattern value="{ep:formeel-patroon}" />
							</xsl:if>				
						</xs:restriction>
					</xs:simpleType>
				</xs:attribute>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:constructRef[@ismetadata='yes']" mode="generateAttributes">
		<xsl:variable name="actualPrefix">
			<xsl:choose>
				<xsl:when test="@prefix = '$actualPrefix'"><xsl:value-of select="ancestor::ep:message-set/@prefix"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="@prefix"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xs:attribute ref="{concat($actualPrefix,':',ep:href)}">
			<xsl:attribute name="use">
				<xsl:choose>
					<xsl:when test="not(ep:min-occurs) or ep:min-occurs=1">required</xsl:when>
					<xsl:otherwise>optional</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="ep:enum">
				<xsl:attribute name="fixed" select="ep:enum"/>
			</xsl:if>
		</xs:attribute>
	</xsl:template>
	
	<xsl:template match="ep:enum">
		<xs:enumeration value="{.}"/>
	</xsl:template>
	
</xsl:stylesheet>
