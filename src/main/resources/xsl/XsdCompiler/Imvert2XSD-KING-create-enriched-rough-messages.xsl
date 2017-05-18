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
	xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" xmlns:stuf="http://www.stufstandaarden.nl/onderlaag/stuf0302"
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" version="2.0">


	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-enriched-rough-messages</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-enriched-rough-messages.xsl 1
		2016-12-01 13:33:00Z RobertMelskens $</xsl:variable>
	
	<xsl:variable name="kv-prefix" select="ep:rough-messages/ep:namespace-prefix"/>
	
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
				<xsl:when test="contains($berichtCode,'Lk') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'update' or ancestor::ep:construct[@context = 'update'])">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- Het gaat hier om constructs voor parameters en stuurgegevens. -->
						</xsl:when>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- Dit betreft een construct voor een fundamentele entiteit. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'kennisgeving')"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
							<!-- Dit betreft een construct voor een entiteit op een dieper niveau. Typisch een dat gebruikt wordt in een gerelateerde. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevensKennisgeving')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft group constructs binnen de construct voor de fundamentele entiteit of group constructs die daar een nakomeling van zijn. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'kennisgeving')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft alle overige group constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevensKennisgeving')"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft association constructs binnen de construct voor de fundamentele entiteit. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'kennisgeving')"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft alle overige association constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevensKennisgeving')"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
							<!-- Dit betreft alle supertype constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevensKennisgeving')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'La') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'antwoord' or ancestor::ep:construct[@context = 'antwoord'])">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- Het gaat hier om constructs voor parameters en stuurgegevens. -->
						</xsl:when>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- Dit betreft een construct voor een fundamentele entiteit. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'antwoord')"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft een construct voor een entiteit op het tweede niveau. Typisch een dat gebruikt wordt in een gerelateerde. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'gerelateerdeAntwoord')"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft een construct voor een entiteit op een nog dieper niveau. Typisch een dat gebruikt wordt in een gerelateerde. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ancestor::ep:construct[ep:tech-name = 'gerelateerde']">
							<!-- Dit betreft group constructs binnen de construct voor de fundamentele entiteit of een entiteit op het tweede niveau of 
								 group constructs die daar een nakomeling van zijn. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'gerelateerdeAntwoord')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2))">
							<!-- Dit betreft group constructs binnen de construct voor de fundamentele entiteit of een entiteit op het tweede niveau of 
								 group constructs die daar een nakomeling van zijn. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'antwoord')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 2)">
							<!-- Dit betreft alle overige group constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft association constructs binnen de construct voor de fundamentele entiteit. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'antwoord')"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft alle overige association constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft supertype constructs voor de construct van de fundamentele entiteit. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'antwoord')"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft alle overige supertype constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'vraag' or ancestor::ep:construct[@context = 'vraag'])">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
								<!-- Het gaat hier om constructs voor parameters en stuurgegevens. -->
						</xsl:when>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- Dit betreft een construct voor een fundamentele entiteiten in de context van een gelijk, totEnMet, vanaf of scope element. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'vraag')"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft een construct voor een entiteit op het tweede niveau. Typisch een dat gebruikt wordt in een gerelateerde in de 
								 context van een gelijk, totEnMet, vanaf of scope element. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'gerelateerdeVraag')"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft een construct voor een entiteit op een nog dieper niveau. Typisch een dat gebruikt wordt in een gerelateerde in de context. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ancestor::ep:construct[ep:tech-name = 'gerelateerde']">
							<!-- Dit betreft group constructs binnen de construct voor de fundamentele entiteit of een entiteit op het tweede niveau binnen de 
								 context van een gelijk, totEnMet, vanaf of scope element of group constructs die daar een nakomeling van zijn. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'gerelateerdeVraag')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2))">
							<!-- Dit betreft group constructs binnen de construct voor de fundamentele entiteit of een entiteit op het tweede niveau binnen de 
								 context van een gelijk, totEnMet, vanaf of scope element of group constructs die daar een nakomeling van zijn. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'vraag')"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 2)">
							<!-- Dit betreft alle overige group constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft association constructs binnen de construct voor de fundamentele entiteit binnen de 
								 context van een gelijk, totEnMet, vanaf of scope element. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'vraag')"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft alle overige association constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- Dit betreft supertype constructs voor de construct van de fundamentele entiteit binnen de 
								 context van een gelijk, totEnMet, vanaf of scope element. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'vraag')"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- Dit betreft alle overige supertype constructs. -->
							<xsl:attribute name="verwerkingsModus" select="imf:create-verwerkingsModus(.,'matchgegevens')"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'Di') or $berichtCode = 'Du01'">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- Het gaat hier om constructs voor parameters en stuurgegevens. -->
						</xsl:when>
						<xsl:when test="@typeCode = 'entiteitrelatie' or ancestor::ep:construct[@typeCode = 'entiteitrelatie']">
							<!-- Dit betreft constructs die vanuit een vrijbericht direct naar  fundamentele entiteit lopen. -->
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="verwerkingsModus" select="'ROME'"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="(contains($berichtCode,'La') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'antwoord' or ancestor::ep:construct[@context = 'antwoord'])) and ep:name = 'gerelateerde' and parent::ep:construct[@indicatieMaterieleHistorieRelatie='Ja']">
				<xsl:attribute name="indicatieMaterieleHistorieRelatie" select="'Ja'"/>
			</xsl:if>
			<xsl:if test="(contains($berichtCode,'La') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'antwoord' or ancestor::ep:construct[@context = 'antwoord'])) and ep:name = 'gerelateerde' and parent::ep:construct[@indicatieFormeleHistorieRelatie='Ja']">
				<xsl:attribute name="indicatieFormeleHistorieRelatie" select="'Ja'"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="contains($berichtCode,'Di') or contains($berichtCode,'Du')">
					<xsl:choose>
						<xsl:when test="@typeCode = 'entiteitrelatie' or ancestor::ep:construct[@typeCode = 'entiteitrelatie']">
							<!-- Dit betreft constructs die vanuit een vrijbericht direct naar  fundamentele entiteit lopen. -->
							<xsl:attribute name="entiteitOrBerichtRelatie" select="ancestor-or-self::ep:construct[@typeCode = 'entiteitrelatie']/ep:name"/>
						</xsl:when>
						<xsl:when test="@typeCode = 'berichtrelatie' or ancestor::ep:construct[@typeCode = 'berichtrelatie']">
							<!-- Dit betreft constructs die vanuit een vrijbericht direct naar  fundamentele entiteit lopen. -->
							<xsl:attribute name="entiteitOrBerichtRelatie" select="ancestor-or-self::ep:construct[@typeCode = 'berichtrelatie']/ep:name"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="count(ancestor::ep:construct[@type='entity']) >= 1">
				<xsl:sequence select="imf:create-debug-comment(concat('Count: ',count(ancestor::ep:construct[@type='entity']),' berichtCode: ',$berichtCode),$debugging)"/>
			</xsl:if>
			<xsl:apply-templates select="*[name()!= 'ep:construct' and name()!= 'ep:choice' and name()!='ep:attribute']"  mode="enrich-rough-messages"/>
			<xsl:apply-templates select="ep:construct | ep:choice" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ep:choice" mode="enrich-rough-messages">
		<xsl:param name="berichtCode"/>
		<xsl:copy>
			<xsl:apply-templates select="ep:construct" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="ep:verkorteAliasGerelateerdeEntiteit" mode="enrich-rough-messages">
		<ep:verkorteAliasGerelateerdeEntiteit>
			<xsl:choose>
				<xsl:when test="..//ep:verkorteAlias = $prefix">
					<xsl:value-of select="$prefix"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</ep:verkorteAliasGerelateerdeEntiteit>
	</xsl:template>
	
	<xsl:template match="ep:namespaceIdentifierGerelateerdeEntiteit" mode="enrich-rough-messages">
		<ep:namespaceIdentifierGerelateerdeEntiteit>
			<xsl:choose>
				<xsl:when test="..//ep:verkorteAlias = $prefix">
					<xsl:value-of select="$packages-doc/imvert:packages/imvert:base-namespace"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</ep:namespaceIdentifierGerelateerdeEntiteit>
	</xsl:template>
	
	<xsl:function name="imf:create-verwerkingsModus">
		<xsl:param name="contextnode"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:value-of select="$verwerkingsModus"/>
	</xsl:function>
	
</xsl:stylesheet>
