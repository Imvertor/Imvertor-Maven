<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct.xsl 3 2015-11-05 10:35:07Z ArjanLoeffen $ 
-->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:UML="omg.org/UML1.3" 
	xmlns:imvert="http://www.imvertor.org/schema/system" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201" 
	xmlns:BG="http://www.egem.nl/StUF/sector/bg/0310" 
	xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
	xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" 
	xmlns:StUF="http://www.egem.nl/StUF/StUF0301" 
	xmlns:ep="http://www.imvertor.org/schema/endproduct" 
	xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" 
	version="2.0">
	
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>
	
	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-schema</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-schema.xsl 1 2015-11-11 12:02:00Z RobertMelskens $</xsl:variable>
	
	<xsl:variable name="globalComplexTypes" select="'no'"/>
	
	<xsl:variable name="typeBericht" select="/ep:message-set/ep:message/ep:type"/>
	<xsl:variable name="berichtCode" select="/ep:message-set/ep:message/ep:code"/>
	<xsl:variable name="prefix" select="ep:message-set/ep:namespace-prefix"/>

	<xsl:template match="ep:message-set">
		<xs:schema targetNamespace="{ep:namespace}" elementFormDefault="qualified" attributeFormDefault="unqualified" version="{concat(ep:patch-number,'-',ep:release)}">
			<xsl:namespace name="{$prefix}"><xsl:value-of select="ep:namespace"/></xsl:namespace>
			<xs:import namespace="http://www.egem.nl/StUF/StUF0301" schemaLocation="stuf0301.xsd"/>
			<xsl:apply-templates select="ep:message"/>
			<!--xsl:apply-templates select="//ep:construct[(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name]" mode="createSimpleTypes"/>
			<xsl:apply-templates select="//ep:construct[.//ep:construct[not(@ismetadata)]]" mode="createComplexTypes"/-->
			<xsl:apply-templates select="//ep:construct[(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and not(.//ep:construct)]" mode="createSimpleTypes"/>
			<xsl:apply-templates select="//ep:construct[(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and .//ep:construct[@ismetadata]]" mode="createSimpleTypes"/>

			<!--xsl:apply-templates select="//ep:construct[(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name]//ep:construct[@ismetadata='yes']" mode="createAttributeSimpleTypes"/-->
			<?x xsl:apply-templates select="//ep:attribute[not(.//ep:attribute)]" mode="createComplexTypes"/>
			<xsl:apply-templates select="//ep:attribute[not(.//ep:attribute)]" mode="createSimpleTypes"/ x?>
<?x			<xs:complexType name="test2">
				<xs:simpleContent>
					<xs:extension base="{concat($prefix,':test')}"/>			
				</xs:simpleContent>
			</xs:complexType>
			<xs:simpleType name="test">
				<xs:restriction base="xs:string"/>
			</xs:simpleType> x?>
		</xs:schema>
	</xsl:template>

	<xsl:template match="ep:message">
		<xs:element name="{ep:name}">
			<xs:complexType>
				<xsl:apply-templates select="ep:seq"/>
			</xs:complexType>
		</xs:element>
	</xsl:template>
	
	<xsl:template match="ep:seq">
		<xs:sequence>
			<xsl:apply-templates select="ep:construct[not(@ismetadata)]|ep:seq"/>
		</xs:sequence>
	</xsl:template>
	
	<xsl:template match="ep:seq" mode="generateAttributes">
		<xsl:apply-templates select="ep:construct[@ismetadata]" mode="generateAttributes"/>
	</xsl:template>

	<xsl:template match="ep:construct">
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<!--xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="contains(ep:tech-name,'StUF:')">
					<xsl:value-of select="substring-after(ep:tech-name,'StUF:')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ep:tech-name"/>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:variable-->
		<xs:element>
			<xsl:choose>
				<xsl:when test="contains(ep:tech-name,':')">
					<xsl:attribute name="ref" select="ep:tech-name"/>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>
				</xsl:when>
				<xsl:when test="contains(ep:type-name,':') and not(ep:enum)">
					<xsl:attribute name="name" select="ep:tech-name"/>
					<xsl:attribute name="type" select="ep:type-name"/>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>					
				</xsl:when>
				<xsl:when test="contains(ep:type-name,':') and ep:enum">
					<xsl:attribute name="name" select="ep:tech-name"/>
					<xsl:attribute name="type">
						<xsl:value-of select="concat($prefix,':simpleType-',ep:tech-name,'-',generate-id())"/>
					</xsl:attribute>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>					
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="name" select="ep:tech-name"/>
					<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
					<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>
					<xsl:choose>
						<xsl:when test="(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and $globalComplexTypes='yes'">
							<xsl:attribute name="type">
								<xsl:value-of select="concat($prefix,':simpleType-',ep:tech-name,'-',$id,'-',generate-id())"/>
							</xsl:attribute>
							<xsl:comment select="'situatie 1'"/>
						</xsl:when>
						<xsl:when test="(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and .//ep:construct[@ismetadata] and $globalComplexTypes='no'">
							<xsl:comment select="'situatie 2'"/>
							<xs:complexType>
								<xs:simpleContent>
									<xs:extension>
										<!--xsl:attribute name="base" select="concat($prefix,':simpleType-',ep:tech-name,'-',$id,'-',generate-id())"/-->
										<xsl:attribute name="base" select="concat($prefix,':simpleType-',ep:tech-name,'-',generate-id())"/>
										<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
										<!--xsl:apply-templates select=".//ep:construct[@ismetadata]" mode="generateAttributes"/-->
									</xs:extension>						
								</xs:simpleContent>	
							</xs:complexType>
						</xsl:when>
						<xsl:when test="(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and $globalComplexTypes='no'">
							<xsl:comment select="'situatie 3'"/>
							<xs:simpleType>
								<xs:restriction>
									<xsl:attribute name="base">
										<xsl:choose>
<!-- ROME: Zodra scalar-xxx is doorgevoerd kunnen de eerste 5 when's verwijderd worden. Welke scalars kan ik trouwens allemaal verwachten? -->
											<xsl:when test="ep:type-name = 'integer'">
												<xsl:value-of select="'xs:int'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'decimal'">
												<xsl:value-of select="'xs:decimal'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'string'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'datetime'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'boolean'">
												<xsl:value-of select="'xs:boolean'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-integer'">
												<xsl:value-of select="'xs:int'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-scalar-decimal'">
												<xsl:value-of select="'xs:decimal'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-datetime'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-boolean'">
												<xsl:value-of select="'xs:boolean'"/>
											</xsl:when>
											<!--xsl:when test="ep:type-name = 'MaximumAantal'">
										<xsl:value-of select="'xs:int'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Tijdstip'">
										<xsl:value-of select="'xs:date'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Sortering'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Berichtcode'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Refnummer'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Functie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Administratie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Applicatie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Gebruiker'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Organisatie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'POSTCODE'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when-->	
											<xsl:otherwise>
												<xsl:value-of select="'xs:string'"/>								
											</xsl:otherwise>
											<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
										</xsl:choose>
									</xsl:attribute>
<!-- ROME: Zodra scalar-xxx is doorgevoerd kunnen in de onderstaande xsl:if statements xsl:when's verwijderd worden of vervangen worden door xsl:if. -->
									<xsl:if test="ep:length">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'string'">
												<xs:length value="{ep:length}"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
												<xs:totalDigits value="{ep:length}"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string'">
												<xs:length value="{ep:length}"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
												<xs:totalDigits value="{ep:length}"/>
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:min-length">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'string'">
												<xs:minLength value="1"/>
												<!--xs:minLength value="{ep:min-length}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string'">
												<xs:minLength value="1"/>
												<!--xs:minLength value="{ep:min-length}"/-->
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:max-length">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'string'">
												<xs:maxLength value="12"/>
												<!--xs:maxLength value="{ep:max-length}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string'">
												<xs:maxLength value="12"/>
												<!--xs:maxLength value="{ep:max-length}"/-->
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:min-value">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
												<xs:minInclusive value="1"/>
												<!--xs:minInclusive value="{ep:min-value}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'datetime'">
												<!--xs:minInclusive value="{ep:min-value}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
												<xs:minInclusive value="1"/>
												<!--xs:minInclusive value="{ep:min-value}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-datetime'">
												<!--xs:minInclusive value="{ep:min-value}"/-->
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:max-value and not(ep:type-name='datetime')">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
												<xs:maxInclusive value="99"/>
												<!--xs:maxInclusive value="{ep:max-value}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'datetime'">
												<!--xs:maxInclusive value="{ep:max-value}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
												<xs:maxInclusive value="99"/>
												<!--xs:maxInclusive value="{ep:max-value}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-datetime'">
												<!--xs:maxInclusive value="{ep:max-value}"/-->
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:fraction-digits">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'decimal'">
												<xs:fractionDigits value="{ep:fraction-digits}"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-decimal'">
												<xs:fractionDigits value="{ep:fraction-digits}"/>
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:enum">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'string' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
												<xsl:apply-templates select="ep:enum"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string' or ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
												<xsl:apply-templates select="ep:enum"/>
											</xsl:when>
										</xsl:choose>
									</xsl:if>
									<xsl:if test="ep:pattern">
										<xsl:choose>
											<xsl:when test="ep:type-name = 'string' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal' or ep:type-name = 'boolean'">
												<!--xs:pattern value="{ep:pattern}"/-->
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string' or ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-boolean'">
												<!--xs:pattern value="{ep:pattern}"/-->
											</xsl:when>
										</xsl:choose>
									</xsl:if>				
								</xs:restriction>						
							</xs:simpleType>				
						</xsl:when>
						<xsl:when test="ep:type-name and $globalComplexTypes='no'">
							<xsl:comment select="'situatie 4'"/>
							<xs:simpleType>
								<xs:restriction>
									<xsl:attribute name="base">
										<xsl:choose>
<!-- ROME: Zodra scalar-xxx is doorgevoerd kunnen de eerste 5 when's verwijderd worden. Welke scalars kan ik trouwens allemaal verwachten? -->
											<xsl:when test="ep:type-name = 'integer'">
												<xsl:value-of select="'xs:int'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'decimal'">
												<xsl:value-of select="'xs:decimal'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'string'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'datetime'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'boolean'">
												<xsl:value-of select="'xs:boolean'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-integer'">
												<xsl:value-of select="'xs:int'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-decimal'">
												<xsl:value-of select="'xs:decimal'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-string'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-datetime'">
												<xsl:value-of select="'xs:string'"/>
											</xsl:when>
											<xsl:when test="ep:type-name = 'scalar-boolean'">
												<xsl:value-of select="'xs:boolean'"/>
											</xsl:when>
											<!--xsl:when test="ep:type-name = 'MaximumAantal'">
										<xsl:value-of select="'xs:int'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Tijdstip'">
										<xsl:value-of select="'xs:date'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Sortering'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Berichtcode'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Refnummer'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Functie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Administratie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Applicatie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Gebruiker'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'Organisatie'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'POSTCODE'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when-->	
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
						<xsl:when test=".//ep:construct and $globalComplexTypes='no'">
							<xsl:comment select="'situatie 5'"/>
							<xs:complexType>
								<xsl:apply-templates select="ep:seq[not(@ismetadata)]"/>
								<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
							</xs:complexType>
						</xsl:when>
						<xsl:otherwise>
							<xsl:comment select="'situatie 6'"/>
							<xs:complexType>
								<xsl:apply-templates select="ep:seq[not(@ismetadata)]"/>
								<xsl:apply-templates select="ep:seq" mode="generateAttributes"/>
							</xs:complexType>					
						</xsl:otherwise>				
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xs:element>
	</xsl:template>
					
<!-- ROME: Onderstaande template kan mogelijk komen te vervallen (integreren met de andere ep:construct templates). -->
	<xsl:template match="ep:construct" mode="createSimpleTypes">
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="contains(ep:tech-name,'StUF:')">
					<xsl:value-of select="substring-after(ep:tech-name,'StUF:')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ep:tech-name"/>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains(ep:tech-name,':')"/>		
			<xsl:when test="contains(ep:type-name,':')">
				<xs:simpleType name="{concat('simpleType-',ep:tech-name,'-',generate-id())}">
					<xs:restriction>
						<xsl:attribute name="base">
							<xsl:value-of select="ep:type-name"/>
						</xsl:attribute>
						<?x xsl:if test="ep:length">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string'">
									<xs:length value="{ep:length}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
									<xs:totalDigits value="{ep:length}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xs:length value="{ep:length}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xs:totalDigits value="{ep:length}"/>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:min-length">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string'">
									<xs:minLength value="1"/>
									<!--xs:minLength value="{ep:min-length}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xs:minLength value="1"/>
									<!--xs:minLength value="{ep:min-length}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:max-length">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string'">
									<xs:maxLength value="12"/>
									<!--xs:maxLength value="{ep:max-length}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xs:maxLength value="12"/>
									<!--xs:maxLength value="{ep:max-length}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:min-value">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
									<xs:minInclusive value="1"/>
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'datetime'">
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xs:minInclusive value="1"/>
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-datetime'">
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:max-value and not(ep:type-name='datetime')">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
									<xs:maxInclusive value="99"/>
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'datetime'">
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xs:maxInclusive value="99"/>
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-datetime'">
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:fraction-digits">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'decimal'">
									<xs:fractionDigits value="{ep:fraction-digits}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-decimal'">
									<xs:fractionDigits value="{ep:fraction-digits}"/>
								</xsl:when>
							</xsl:choose>
						</xsl:if x?>
						<xsl:if test="ep:enum">
							<xsl:apply-templates select="ep:enum"/>
						</xsl:if>
						<?x xsl:if test="ep:pattern">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal' or ep:type-name = 'boolean'">
									<!--xs:pattern value="{ep:pattern}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string' or ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-boolean'">
									<!--xs:pattern value="{ep:pattern}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if x?>				
					</xs:restriction>
				</xs:simpleType>
			</xsl:when>
			<xsl:otherwise>
				<xs:simpleType name="{concat('simpleType-',ep:tech-name,'-',generate-id())}">
					<xs:restriction>
						<xsl:attribute name="base">
							<xsl:choose>
<!-- ROME: Zodra scalar-xxx is doorgevoerd kunnen de eerste 5 when's verwijderd worden. Welke scalars kan ik trouwens allemaal verwachten? -->
								<xsl:when test="ep:type-name = 'integer'">
									<xsl:value-of select="'xs:int'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'decimal'">
									<xsl:value-of select="'xs:decimal'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'string'">
									<xsl:value-of select="'xs:string'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'datetime'">
									<xsl:value-of select="'xs:string'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'boolean'">
									<xsl:value-of select="'xs:boolean'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer'">
									<xsl:value-of select="'xs:int'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-decimal'">
									<xsl:value-of select="'xs:decimal'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xsl:value-of select="'xs:string'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-datetime'">
									<xsl:value-of select="'xs:string'"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-boolean'">
									<xsl:value-of select="'xs:boolean'"/>
								</xsl:when>
								<!--xsl:when test="ep:type-name = 'MaximumAantal'">
							<xsl:value-of select="'xs:int'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Tijdstip'">
							<xsl:value-of select="'xs:date'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Sortering'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Berichtcode'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Refnummer'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Functie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Administratie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Applicatie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Gebruiker'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Organisatie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'POSTCODE'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when-->	
								<xsl:otherwise>
									<xsl:value-of select="'xs:string'"/>								
								</xsl:otherwise>
								<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
							</xsl:choose>
						</xsl:attribute>
<!-- ROME: Zodra scalar-xxx is doorgevoerd kunnen in de onderstaande xsl:if statements xsl:when's verwijderd worden of vervangen worden door xsl:if. -->
						<xsl:if test="ep:length">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string'">
									<xs:length value="{ep:length}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
									<xs:totalDigits value="{ep:length}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xs:length value="{ep:length}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xs:totalDigits value="{ep:length}"/>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:min-length">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string'">
									<xs:minLength value="1"/>
									<!--xs:minLength value="{ep:min-length}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xs:minLength value="1"/>
									<!--xs:minLength value="{ep:min-length}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:max-length">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string'">
									<xs:maxLength value="12"/>
									<!--xs:maxLength value="{ep:max-length}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string'">
									<xs:maxLength value="12"/>
									<!--xs:maxLength value="{ep:max-length}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:min-value">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
									<xs:minInclusive value="1"/>
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'datetime'">
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xs:minInclusive value="1"/>
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-datetime'">
									<!--xs:minInclusive value="{ep:min-value}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:max-value and not(ep:type-name='datetime')">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
									<xs:maxInclusive value="99"/>
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'datetime'">
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xs:maxInclusive value="99"/>
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-datetime'">
									<!--xs:maxInclusive value="{ep:max-value}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:fraction-digits">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'decimal'">
									<xs:fractionDigits value="{ep:fraction-digits}"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-decimal'">
									<xs:fractionDigits value="{ep:fraction-digits}"/>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:enum">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
									<xsl:apply-templates select="ep:enum"/>
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string' or ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
									<xsl:apply-templates select="ep:enum"/>
								</xsl:when>
							</xsl:choose>
						</xsl:if>
						<xsl:if test="ep:pattern">
							<xsl:choose>
								<xsl:when test="ep:type-name = 'string' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal' or ep:type-name = 'boolean'">
									<!--xs:pattern value="{ep:pattern}"/-->
								</xsl:when>
								<xsl:when test="ep:type-name = 'scalar-string' or ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-boolean'">
									<!--xs:pattern value="{ep:pattern}"/-->
								</xsl:when>
							</xsl:choose>
						</xsl:if>				
					</xs:restriction>
				</xs:simpleType>
			</xsl:otherwise>
		</xsl:choose>
		<!--xs:simpleType name="{concat('simpleType-',ep:tech-name,'-',$id,'-',generate-id())}"-->
	</xsl:template>
	
	<!--xsl:template match="ep:construct" mode="createComplexTypes">
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="contains(ep:tech-name,'StUF:')">
					<xsl:value-of select="substring-after(ep:tech-name,'StUF:')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ep:tech-name"/>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:variable>
		<xsl:choose>
			<xsl:when test=".//ep:construct[not(@ismetadata)]">
				<xs:complexType name="{concat('complexType-',$name,'-',$id,'-',generate-id())}">
					<xsl:apply-templates select="ep:seq"/>
				</xs:complexType>
			</xsl:when>
			<xsl:when test="(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and .//ep:construct[@ismetadata]">
				<xs:complexType name="{concat('complexType-',$name,'-',$id,'-',generate-id())}">
					<xs:simpleContent>
						<xs:extension base="{concat($prefix,':simpleType-',$name,'-',$id,'-',generate-id())}">
							<xsl:apply-templates select="ep:seq/ep:construct[@ismetadata='yes']" mode="generateAttributes"/>
						</xs:extension>			
					</xs:simpleContent>
				</xs:complexType>				
			</xsl:when>
		</xsl:choose>								
	</xsl:template-->
	
	<?x xsl:template match="ep:construct[@ismetadata='yes']" mode="createAttributeSimpleTypes">
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="contains(ep:tech-name,'StUF:')">
					<xsl:value-of select="substring-after(ep:tech-name,'StUF:')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ep:tech-name"/>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:variable>
		<xsl:if test="not(preceding::ep:construct/ep:id=$id)">
			<xs:simpleType name="{concat('attributeSimpleType-',$name,'-',$id,'-',generate-id())}">
				<xs:restriction>
					<xsl:attribute name="base">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'integer'">
								<xsl:value-of select="'xs:int'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'decimal'">
								<xsl:value-of select="'xs:decimal'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'char'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'datetime'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'boolean'">
								<xsl:value-of select="'xs:boolean'"/>
							</xsl:when>
							<!--xsl:when test="ep:type-name = 'MaximumAantal'">
								<xsl:value-of select="'xs:int'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Tijdstip'">
								<xsl:value-of select="'xs:date'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Sortering'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Berichtcode'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Refnummer'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Functie'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Administratie'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Applicatie'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Gebruiker'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'Organisatie'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'POSTCODE'">
								<xsl:value-of select="'xs:string'"/>
							</xsl:when-->	
							<xsl:otherwise>
								<xsl:value-of select="'xs:string'"/>								
							</xsl:otherwise>
							<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
						</xsl:choose>
					</xsl:attribute>
					<xsl:if test="ep:length">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'char'">
								<xs:length value="{ep:length}"/>
							</xsl:when>
							<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
								<xs:totalDigits value="{ep:length}"/>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:min-length">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'char'">
								<xs:minLength value="1"/>
								<!--xs:minLength value="{ep:min-length}"/-->
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:max-length">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'char'">
								<xs:maxLength value="12"/>
								<!--xs:maxLength value="{ep:max-length}"/-->
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:min-value">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
								<xs:minInclusive value="1"/>
								<!--xs:minInclusive value="{ep:min-value}"/-->
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:max-value">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
								<xs:maxInclusive value="99"/>
								<!--xs:maxInclusive value="{ep:max-value}"/-->
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:fraction-digits">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'decimal'">
								<xs:fractionDigits value="{ep:fraction-digits}"/>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:enum">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'char' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
								<xsl:apply-templates select="ep:enum"/>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:pattern">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'char' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal' or ep:type-name = 'boolean'">
								<!--xs:pattern value="{ep:pattern}"/-->
							</xsl:when>
						</xsl:choose>
					</xsl:if>				
				</xs:restriction>
			</xs:simpleType>
		</xsl:if>
	</xsl:template x?>
	
	<!-- ROME: Onderstaande template kan mogelijk komen te vervallen (integreren met de andere ep:construct templates). -->
	<xsl:template match="ep:construct[@ismetadata='yes']" mode="generateAttributes">
		<xsl:variable name="id" select="substring-before(substring-after(ep:id,'{'),'}')"/>
		<!--xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="contains(ep:tech-name,'StUF:')">
					<xsl:value-of select="substring-after(ep:tech-name,'StUF:')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="ep:tech-name"/>
				</xsl:otherwise>
			</xsl:choose>				
		</xsl:variable>
		<xsl:comment select="concat(ep:tech-name, '-' ,generate-id())"/-->
		<xsl:choose>
			<xsl:when test="contains(ep:tech-name,':') and ep:tech-name!='StUF:entiteittype'">
				<xs:attribute ref="{ep:tech-name}">
					<xsl:attribute name="use">
						<xsl:choose>
							<xsl:when test="not(ep:min-occurs) or ep:min-occurs=1">required</xsl:when>
							<xsl:otherwise>optional</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xs:attribute>
			</xsl:when>
			<xsl:when test="$globalComplexTypes='yes'">
				<!--xs:attribute name="{ep:tech-name}" type="{concat($prefix,':attributeSimpleType-',ep:tech-name,'-',$id,'-',generate-id())}"-->
				<xs:attribute name="{ep:tech-name}" type="{concat($prefix,':attributeSimpleType-',ep:tech-name,'-',generate-id())}">
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
<!-- ROME: Zodra scalar-xxx is doorgevoerd kunnen de eerste 5 when's verwijderd worden. Welke scalars kan ik trouwens allemaal verwachten? -->
									<xsl:when test="ep:type-name = 'integer'">
										<xsl:value-of select="'xs:int'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'decimal'">
										<xsl:value-of select="'xs:decimal'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'string'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'datetime'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'boolean'">
										<xsl:value-of select="'xs:boolean'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-integer'">
										<xsl:value-of select="'xs:int'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-decimal'">
										<xsl:value-of select="'xs:decimal'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-datetime'">
										<xsl:value-of select="'xs:string'"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-boolean'">
										<xsl:value-of select="'xs:boolean'"/>
									</xsl:when>
									<!--xsl:when test="ep:type-name = 'MaximumAantal'">
							<xsl:value-of select="'xs:int'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Tijdstip'">
							<xsl:value-of select="'xs:date'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Sortering'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Berichtcode'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Refnummer'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Functie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Administratie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Applicatie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Gebruiker'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'Organisatie'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when>
						<xsl:when test="ep:type-name = 'POSTCODE'">
							<xsl:value-of select="'xs:string'"/>
						</xsl:when-->	
									<xsl:otherwise>
										<xsl:value-of select="'xs:string'"/>								
									</xsl:otherwise>
									<!-- Voor de situaties waar sprake is van een andere package (bijv. GML3) moet nog code vervaardigd worden. -->
								</xsl:choose>
							</xsl:attribute>
<!-- ROME: Zodra scalar-xxx is doorgevoerd kunnen in de onderstaande xsl:if statements xsl:when's verwijderd worden of vervangen worden door xsl:if. -->
							<xsl:if test="ep:length">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'string'">
										<xs:length value="{ep:length}"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
										<xs:totalDigits value="{ep:length}"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string'">
										<xs:length value="{ep:length}"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
										<xs:totalDigits value="{ep:length}"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:min-length">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'string'">
										<xs:minLength value="1"/>
										<!--xs:minLength value="{ep:min-length}"/-->
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string'">
										<xs:minLength value="1"/>
										<!--xs:minLength value="{ep:min-length}"/-->
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:max-length">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'string'">
										<xs:maxLength value="12"/>
										<!--xs:maxLength value="{ep:max-length}"/-->
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string'">
										<xs:maxLength value="12"/>
										<!--xs:maxLength value="{ep:max-length}"/-->
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:min-value">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
										<xs:minInclusive value="1"/>
										<!--xs:minInclusive value="{ep:min-value}"/-->
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
										<xs:minInclusive value="1"/>
										<!--xs:minInclusive value="{ep:min-value}"/-->
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:max-value">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
										<xs:maxInclusive value="99"/>
										<!--xs:maxInclusive value="{ep:max-value}"/-->
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
										<xs:maxInclusive value="99"/>
										<!--xs:maxInclusive value="{ep:max-value}"/-->
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:fraction-digits">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'decimal'">
										<xs:fractionDigits value="{ep:fraction-digits}"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-decimal'">
										<xs:fractionDigits value="{ep:fraction-digits}"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:enum">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'string' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal'">
										<xsl:apply-templates select="ep:enum"/>
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string' or ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal'">
										<xsl:apply-templates select="ep:enum"/>
									</xsl:when>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="ep:pattern">
								<xsl:choose>
									<xsl:when test="ep:type-name = 'string' or ep:type-name = 'datetime' or ep:type-name = 'integer' or ep:type-name = 'decimal' or ep:type-name = 'boolean'">
										<!--xs:pattern value="{ep:pattern}"/-->
									</xsl:when>
									<xsl:when test="ep:type-name = 'scalar-string' or ep:type-name = 'scalar-datetime' or ep:type-name = 'scalar-integer' or ep:type-name = 'scalar-decimal' or ep:type-name = 'scalar-boolean'">
										<!--xs:pattern value="{ep:pattern}"/-->
									</xsl:when>
								</xsl:choose>
							</xsl:if>				
						</xs:restriction>
					</xs:simpleType>
				</xs:attribute>				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:enum">
		<xs:enumeration value="{.}"/>
	</xsl:template>
	
</xsl:stylesheet>
