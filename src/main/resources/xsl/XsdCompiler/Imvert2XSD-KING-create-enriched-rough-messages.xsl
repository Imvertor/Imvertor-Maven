<?xml version="1.0" encoding="UTF-8"?>
<!-- SVN: $Id: Imvert2XSD-KING-endproduct.xsl 3 2015-11-05 10:35:07Z ArjanLoeffen 
	$ This stylesheet generates the EP file structure based on the embellish 
	file of a BSM EAP file. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:UML="omg.org/UML1.3"
	xmlns:imvert="http://www.imvertor.org/schema/system"
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
	xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310"
	xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking"
	xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" xmlns:stuf="http://www.egem.nl/StUF/StUF0301"
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" version="2.0">


	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-enriched-rough-messages</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-enriched-rough-messages.xsl 1
		2016-12-01 13:33:00Z RobertMelskens $</xsl:variable>
	
	<xsl:template match="ep:rough-messages" mode="enrich-rough-messages">
		<xsl:copy>
			<xsl:apply-templates select="ep:rough-message" mode="enrich-rough-messages"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="ep:rough-message" mode="enrich-rough-messages">
		<xsl:copy>
			<xsl:apply-templates select="*[name()!= 'ep:construct']"  mode="enrich-rough-messages"/>
			<xsl:apply-templates select="ep:construct" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="ep:code"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*" mode="enrich-rough-messages">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="ep:construct" mode="enrich-rough-messages">
		<xsl:param name="berichtCode"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="contains($berichtCode,'Lk')">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])"/>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'La')">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])"/>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<xsl:attribute name="verwerkingsModus" select="'gerelateerdeAntwoord'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
						<xsl:when test="@type='group' and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2))">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) > 2)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv')">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity']) and (@context != 'start' and @context != 'scope')"/>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity']) and (@context = 'selectie' or @context = 'scope')">
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity']) and @context = 'start'">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1) and (@context = 'selectie' or @context = 'scope')">
							<xsl:attribute name="verwerkingsModus" select="'gerelateerdeVraag'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1) and @context = 'start'">
							<xsl:attribute name="verwerkingsModus" select="'gerelateerdeAntwoord'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
						<xsl:when test="@type='group' and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2)) and (@context = 'selectie' or @context = 'scope')">
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='group' and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2)) and @context = 'start'">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) > 2)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
						<xsl:when test="@type='association' and not(ancestor::ep:construct[@type='entity'] and @context = 'scope')">
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1) and (@context = 'selectie' or @context = 'scope')">
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='association' and not(ancestor::ep:construct[@type='entity'] and @context = 'start')">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1) and @context = 'start'">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1) and (@context = 'selectie' or @context = 'scope')">
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1) and @context = 'start'">
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'Di')">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])"/>
						<xsl:when test="@typeCode = 'entiteitrelatie' or ancestor::ep:construct[@typeCode = 'entiteitrelatie']"/>
						<xsl:when test="@context = 'update' or ancestor::ep:construct[@context = 'update']">
							<xsl:choose>
								<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])"/>
								<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
									<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
								</xsl:when>
								<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
								</xsl:when>
								<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) = 1)">
									<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
								</xsl:when>
								<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
								</xsl:when>
								<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
									<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
								</xsl:when>
								<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
								</xsl:when>
								<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevensKennisgeving'"/>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="@context = 'vraag' or ancestor::ep:construct[@context = 'vraag']">
							<xsl:choose>
								<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity']) and (@context != 'start' and @context != 'scope')"/>
								<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity']) and (@context = 'selectie' or @context = 'scope')">
									<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
								</xsl:when>
								<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity']) and @context = 'start'">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1) and (@context = 'selectie' or @context = 'scope')">
									<xsl:attribute name="verwerkingsModus" select="'gerelateerdeVraag'"/>
								</xsl:when>
								<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1) and @context = 'start'">
									<xsl:attribute name="verwerkingsModus" select="'gerelateerdeAntwoord'"/>
								</xsl:when>
								<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
								<xsl:when test="@type='group' and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2)) and (@context = 'selectie' or @context = 'scope')">
									<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
								</xsl:when>
								<xsl:when test="@type='group' and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2)) and @context = 'start'">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) > 2)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
								<xsl:when test="@type='association' and not(ancestor::ep:construct[@type='entity'] and @context = 'scope')">
									<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
								</xsl:when>
								<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1) and (@context = 'selectie' or @context = 'scope')">
									<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
								</xsl:when>
								<xsl:when test="@type='association' and not(ancestor::ep:construct[@type='entity'] and @context = 'start')">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1) and @context = 'start'">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
								<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1) and (@context = 'selectie' or @context = 'scope')">
									<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
								</xsl:when>
								<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1) and @context = 'start'">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="@context = 'antwoord' or ancestor::ep:construct[@context = 'antwoord']">
							<xsl:choose>
								<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])"/>
								<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1)">
									<xsl:attribute name="verwerkingsModus" select="'gerelateerdeAntwoord'"/>
								</xsl:when>
								<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
								<xsl:when test="@type='group' and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2))">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='group' and (count(ancestor::ep:construct[@type='entity']) > 2)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
								<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
								<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1)">
									<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
								</xsl:when>
								<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
									<xsl:attribute name="verwerkingsModus" select="'kerngegevens'"/>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="verwerkingsModus" select="'ROME'"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="count(ancestor::ep:construct[@type='entity']) >= 1">
				<xsl:comment select="concat('Count: ',count(ancestor::ep:construct[@type='entity']),' berichtCode: ',$berichtCode)"/>
			</xsl:if>
			<xsl:apply-templates select="*[name()!= 'ep:construct' and name()!= 'ep:choice']"  mode="enrich-rough-messages"/>
			<xsl:apply-templates select="ep:construct | ep:choice" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ep:choice" mode="enrich-rough-messages">
		<xsl:param name="berichtCode"/>
		<xsl:comment select="' ROME'"/>
		<xsl:copy>
			<xsl:apply-templates select="ep:construct" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
