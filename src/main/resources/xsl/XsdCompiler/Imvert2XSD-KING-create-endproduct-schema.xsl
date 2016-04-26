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
	
	<xsl:variable name="typeBericht" select="/ep:message-set/ep:message/ep:type"/>
	<xsl:variable name="berichtCode" select="/ep:message-set/ep:message/ep:code"/>
	<xsl:variable name="prefix" select="ep:message-set/ep:namespace-prefix"/>

	<xsl:template match="ep:message-set">
		<xs:schema targetNamespace="{ep:namespace}" elementFormDefault="qualified" attributeFormDefault="unqualified" version="{concat(ep:patch-number,'-',ep:release)}">
			<xsl:namespace name="{$prefix}"><xsl:value-of select="ep:namespace"/></xsl:namespace>
			<xs:import namespace="http://www.egem.nl/StUF/StUF0301" schemaLocation="stuf0301.xsd"/>
			<xsl:apply-templates select="ep:message"/>
			<xsl:apply-templates select="//ep:construct[(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and not(.//ep:construct)]" mode="createSimpleTypes"/>
			<xsl:apply-templates select="//ep:construct[(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and .//ep:construct]" mode="createComplexTypes"/>
			<xsl:apply-templates select="//ep:construct[(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name]//ep:construct" mode="createAttributeSimpleTypes"/>
			<?x xsl:apply-templates select="//ep:attribute[not(.//ep:attribute)]" mode="createComplexTypes"/>
			<xsl:apply-templates select="//ep:attribute[not(.//ep:attribute)]" mode="createSimpleTypes"/ x?>
			<xs:complexType name="test2">
				<xs:simpleContent>
					<xs:extension base="{concat($prefix,':test')}"/>			
				</xs:simpleContent>
			</xs:complexType>
			<xs:simpleType name="test">
				<xs:restriction base="xs:string"/>
			</xs:simpleType>
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
			<xsl:apply-templates select="ep:construct|ep:seq"/>
		</xs:sequence>
	</xsl:template>
	
	<xsl:template match="ep:construct">
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
		<xs:element>
			<xsl:attribute name="name" select="$name"/>
			<xsl:attribute name="minOccurs" select="ep:min-occurs"/>
			<xsl:attribute name="maxOccurs" select="ep:max-occurs"/>
			<xsl:choose>
				<xsl:when test="(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and not(.//ep:construct)">
					<xsl:attribute name="type">
						<xsl:value-of select="concat($prefix,':simpleType-',$name,'-',$id,'-',generate-id())"/>
					</xsl:attribute>				
				</xsl:when>
				<xsl:when test="(ep:max-length or ep:min-length or ep:max-value or ep:min-value or ep:regels or ep:enum) and ep:type-name and .//ep:construct">
					<xsl:attribute name="type">
						<xsl:value-of select="concat($prefix,':complexType-',$name,'-',$id,'-',generate-id())"/>
					</xsl:attribute>				
				</xsl:when>
				<xsl:otherwise>
					<xs:complexType>
						<xsl:apply-templates select="ep:seq"/>
					</xs:complexType>					
				</xsl:otherwise>				
			</xsl:choose>
		</xs:element>
	</xsl:template>
					
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
		<xsl:if test="not(preceding::ep:construct/ep:id=$id)">
			<xs:simpleType name="{concat('simpleType-',$name,'-',$id,'-',generate-id())}">
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
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="createAttributeSimpleTypes">
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
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="createComplexTypes">
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
			<xs:simpleType name="{concat('simpleType-',$name,'-',$id,'-',generate-id())}">
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
							<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
								<xs:minInclusive value="1"/>
								<!--xs:minInclusive value="{ep:min-value}"/-->
							</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="ep:max-value">
						<xsl:choose>
							<xsl:when test="ep:type-name = 'integer' or ep:type-name = 'decimal'">
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
			<xs:complexType name="{concat('complexType-',$name,'-',$id,'-',generate-id())}">
				<xs:simpleContent>
					<xs:extension base="{concat($prefix,':simpleType-',$name,'-',$id,'-',generate-id())}">
						<xsl:apply-templates select="ep:seq/ep:construct" mode="generateAttributes"/>
					</xs:extension>			
				</xs:simpleContent>
			</xs:complexType>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="generateAttributes">
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
		<xs:attribute name="{$name}" type="{concat($prefix,':attributeSimpleType-',$name,'-',$id,'-',generate-id())}">
			<xsl:attribute name="use">
				<xsl:choose>
					<xsl:when test="not(ep:min-occurs) or ep:min-occurs=1">required</xsl:when>
					<xsl:otherwise>optional</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xs:attribute>
	</xsl:template>
	
</xsl:stylesheet>
