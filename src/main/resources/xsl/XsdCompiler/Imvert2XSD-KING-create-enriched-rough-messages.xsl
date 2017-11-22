<?xml version="1.0" encoding="UTF-8"?>
<!-- Robert Melskens 	2017-06-09	This stylesheet enriches the rough EP file structure generated in the previous
									step. The result serves as a base for creating the final EP file structure.
									The most important enrichment is determining the verwerkingsModus of each level.
									With this information the next step can determine teh content of each ep:construct
									structure. For example a verwerkingsModus with the value 'matchgegevens...' means
									only matchgegevens are allowed in the content. -->
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

	<xsl:import href="../common/Imvert-common.xsl"/>
	<xsl:import href="../common/Imvert-common-validation.xsl"/>
	<xsl:import href="../common/extension/Imvert-common-text.xsl"/>	
	<xsl:import href="../common/Imvert-common-derivation.xsl"/>
	<xsl:import href="Imvert2XSD-KING-common.xsl"/>
	
	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-enriched-rough-messages</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-enriched-rough-messages.xsl 1
		2016-12-01 13:33:00Z RobertMelskens $</xsl:variable>
	<xsl:variable name="stylesheet-code" as="xs:string">SKS</xsl:variable>
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
	<xsl:variable name="embellish-file" select="imf:document(imf:get-config-string('properties','WORK_EMBELLISH_FILE'))"/>  
	<xsl:variable name="packages" select="$embellish-file/imvert:packages"/>	
	
	<xsl:variable name="StUF-prefix" select="'StUF'"/>	
	<xsl:variable name="StUF-namespaceIdentifier" select="'http://www.stufstandaarden.nl/onderlaag/stuf0302'"/>
	<xsl:variable name="kv-prefix" select="imf:get-tagged-value($packages,'##CFG-TV-VERKORTEALIAS')"/>
	<xsl:variable name="prefix" as="xs:string">
		<xsl:choose>
			<xsl:when test="not(empty($kv-prefix))">
				<xsl:value-of select="$kv-prefix"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'TODO'"/>
				<xsl:variable name="msg" select="'You have not provided a short alias. Define the tagged value &quot;Verkorte alias&quot; on the package with the stereotyp &quot;Koppelvlak&quot;.'" as="xs:string"/>
				<xsl:sequence select="imf:msg('WARN',$msg)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="version" select="$packages/imvert:version"/>
	
	<xsl:variable name="enriched-rough-messages">
		<xsl:sequence select="imf:track('Constructing the enriched rough message-structure')"/>
		
		<xsl:apply-templates select="/ep:rough-messages" mode="enrich-rough-messages"/>
		
	</xsl:variable>
	
	<xsl:template match="/">
		
		<xsl:sequence select="imf:pretty-print($enriched-rough-messages,false())"/>

	</xsl:template>
	
	<xsl:template match="ep:rough-messages" mode="enrich-rough-messages">
		<xsl:sequence select="imf:create-debug-comment('debug:start B00000 /debug:start',$debugging)"/>

		<xsl:copy>
			<xsl:attribute name="kv-prefix" select="$kv-prefix"/>
			<xsl:apply-templates select="ep:rough-message" mode="enrich-rough-messages"/>
		</xsl:copy>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>
	
	<xsl:template match="ep:rough-message" mode="enrich-rough-messages">
		<xsl:sequence select="imf:create-debug-comment('debug:start B01000 /debug:start',$debugging)"/>

		<xsl:copy>
			<xsl:apply-templates select="*[name()!= 'ep:construct']"  mode="enrich-rough-messages"/>
			<xsl:apply-templates select="ep:construct" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="ep:code"/>
			</xsl:apply-templates>
		</xsl:copy>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>
	
	<xsl:template match="*" mode="enrich-rough-messages">
		<xsl:sequence select="imf:create-debug-comment('debug:start B02000 /debug:start',$debugging)"/>
		
		<xsl:copy-of select="."/>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template is the most important template in this stylesheet. Depending on the context of the construct 
		 and the position within the structure of constructs a copy of the construct, optionally extended with an attribute 
		 'verwerkingsModus', is created with a relevant value. In the next processing step for each construct a 
		 complexType is created based on the 'verwerkingsModus' attribute with relevant content. -->
	<xsl:template match="ep:construct" mode="enrich-rough-messages">
		<xsl:param name="berichtCode"/>
		
		<xsl:sequence select="imf:create-debug-comment('debug:start B03000 /debug:start',$debugging)"/>
		
		<xsl:copy>
			<!--xsl:copy-of select="@*"/-->
			<xsl:copy-of select="@*[name() != 'typeCode']"/>
			<xsl:choose>
				<xsl:when test="@typeCode = 'relatie' and parent::ep:construct[contains(@berichtCode,'Lk') and @typeCode='toplevel']">
					<xsl:attribute name="typeCode" select="'toplevel-relatie'"/>					
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="@typeCode"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="contains($berichtCode,'Lk') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'update' or ancestor::ep:construct[@context = 'update'])">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- This concerns constructs for 'parameters' and 'stuurgegevens'. They don't get a 'verwerkingsModus' attribute. -->
						</xsl:when>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- This concerns a construct for a fundamental 'entiteit'. -->
							<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
							<!-- This concerns a construct for an 'entiteit' on a deeper level. Typically one used within a 'gerelateerde' construct. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevensKennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns group constructs within a construct for a fundamental 'entiteit' or group constructs which are descendant of such a construct. -->
							<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns all other group constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevensKennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns association constructs within a construct for a fundamental 'entiteit'. -->
							<xsl:attribute name="verwerkingsModus" select="'kennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns all other association constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevensKennisgeving'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) >= 1)">
							<!-- This concerns all supertype constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevensKennisgeving'"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'La') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'antwoord' or ancestor::ep:construct[@context = 'antwoord'])">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- This concerns constructs for 'parameters' and 'stuurgegevens'. They don't get a 'verwerkingsModus' attribute. -->
						</xsl:when>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- This concerns a construct for a fundamental 'entiteit'. -->
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns a construct for an 'entiteit' on the second level. Typically one used within a 'gerelateerde' construct. -->
							<xsl:attribute name="verwerkingsModus" select="'gerelateerdeAntwoord'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns a construct for an 'entiteit' on a deeper level than second level. This one is also typically used within a 'gerelateerde' construct. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ancestor::ep:construct[(@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)) or 
							(@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1)) or
							(@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 2))]">
							<!-- This concerns group constructs descendants of a construct getting a 'verwerkingsModus' attribute with the value 'matchgegevens'.
							     These group constructs must themselves also get a 'verwerkingsModus' attribute with the value 'matchgegevens'. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ancestor::ep:construct[ep:tech-name = 'gerelateerde']">
							<!-- This concerns group constructs which are descendants of constructs for the 'gerelateerde' construct. -->
							<xsl:attribute name="verwerkingsModus" select="'gerelateerdeAntwoord'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2))">
							<!-- This concerns group constructs within the construct of a fundamental 'entiteit' or an 'entiteit' on the second level or 
								 group constructs which are descendants of those constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 2)">
							<!-- This concerns all other group constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type='association' and ancestor::ep:construct[(@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)) or 
							(@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1))]">
							<!-- This concerns association constructs which are descendants of construct getting a 'verwerkingsModus' attributevalue 'matchgegevens'.
							     These association constructs must themselves also get a 'verwerkingsModus' attribute with the value 'matchgegevens'. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns association constructs within construct for a fundamental 'entiteit'. -->
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns all other association constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns supertype constructs within construct for a fundamental 'entiteit'. -->
							<xsl:attribute name="verwerkingsModus" select="'antwoord'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns all other supertype constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'vraag' or ancestor::ep:construct[@context = 'vraag'])">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- This concerns constructs for 'parameters' and 'stuurgegevens'. They don't get a 'verwerkingsModus' attribute. -->
						</xsl:when>
						<xsl:when test="@type='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- This concerns a construct for a fundamental 'entiteit' in the 'gelijk', 'totEnMet', 'vanaf' of 'scope' context. -->
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns a construct for an 'entiteit' on the second level. Typically one used within a 'gerelateerde' construct in the 
								 'gelijk', 'totEnMet', 'vanaf' of 'scope' context. -->
							<xsl:attribute name="verwerkingsModus" select="'gerelateerdeVraag'"/>
						</xsl:when>
						<xsl:when test="@type='entity' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns a construct for an 'entiteit' on a deeper level than second level. This one is also typically used within a 'gerelateerde' construct. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ancestor::ep:construct[(@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)) or
							(@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)) or
							(@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 2))]">
							<!-- This concerns group constructs descendants of a construct getting a 'verwerkingsModus' attribute with the value 'matchgegevens'.
							     These group constructs must themselves also get a 'verwerkingsModus' attribute with the value 'matchgegevens'. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ancestor::ep:construct[ep:tech-name = 'gerelateerde']">
							<!-- This concerns group constructs which are descendants of constructs for the 'gerelateerde' construct. -->
							<xsl:attribute name="verwerkingsModus" select="'gerelateerdeVraag'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and ((count(ancestor::ep:construct[@type='entity']) = 1) or (count(ancestor::ep:construct[@type='entity']) = 2))">
							<!-- This concerns group constructs whithin constructs for the fundamental 'entiteit' construct or an 'entiteit' construct on the 
								 second level in the 'gelijk', 'totEnMet', 'vanaf' of 'scope' context. -->
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type=('group','complex datatype') and (count(ancestor::ep:construct[@type='entity']) > 2)">
							<!-- This concerns all other group constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type='association' and ancestor::ep:construct[(@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)) or
							(@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1))]">
							<!-- This concerns association constructs descendants of a construct getting a 'verwerkingsModus' attribute with the value 'matchgegevens'.
							     These group constructs must themselves also get a 'verwerkingsModus' attribute with the value 'matchgegevens'. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns association constructs whithin constructs for the fundamental 'entiteit' construct in the 'gelijk', 
								 'totEnMet', 'vanaf' of 'scope' context. -->
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='association' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns all association constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) = 1)">
							<!-- This concerns supertype constructs whithin constructs for the fundamental 'entiteit' construct in the 'gelijk', 
								 'totEnMet', 'vanaf' of 'scope' context. -->
							<xsl:attribute name="verwerkingsModus" select="'vraag'"/>
						</xsl:when>
						<xsl:when test="@type='supertype' and (count(ancestor::ep:construct[@type='entity']) > 1)">
							<!-- This concerns all supertype constructs. -->
							<xsl:attribute name="verwerkingsModus" select="'matchgegevens'"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="contains($berichtCode,'Di') or $berichtCode = 'Du01'">
					<xsl:choose>
						<xsl:when test="@type!='entity' and not(ancestor::ep:construct[@type='entity'])">
							<!-- This concerns constructs for 'parameters' and 'stuurgegevens'. They don't get a 'verwerkingsModus' attribute. -->
						</xsl:when>
						<xsl:when test="@typeCode = 'entiteitrelatie' or ancestor::ep:construct[@typeCode = 'entiteitrelatie']">
							<!-- This concerns association constructs relating a 'vrijbericht' to a fundamental 'entiteit'. -->
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="verwerkingsModus" select="'ROME'"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="(contains($berichtCode,'La') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'antwoord' or ancestor::ep:construct[@context = 'antwoord'])) and ep:tech-name = 'gerelateerde' and parent::ep:construct[@indicatieMaterieleHistorieRelatie='Ja']">
				<xsl:attribute name="indicatieMaterieleHistorieRelatie" select="'Ja'"/>
			</xsl:if>
			<xsl:if test="(contains($berichtCode,'La') or ((contains($berichtCode,'Di') or $berichtCode = 'Du01') and @context = 'antwoord' or ancestor::ep:construct[@context = 'antwoord'])) and ep:tech-name = 'gerelateerde' and parent::ep:construct[@indicatieFormeleHistorieRelatie='Ja']">
				<xsl:attribute name="indicatieFormeleHistorieRelatie" select="'Ja'"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="contains($berichtCode,'Di') or contains($berichtCode,'Du')">
					<xsl:choose>
						<xsl:when test="@typeCode = 'entiteitrelatie' or ancestor::ep:construct[@typeCode = 'entiteitrelatie']">
							<!-- This concerns association constructs having a 'typeCode' attributevalue of 'entiteitrelatie' and relating a 'vrijbericht' to a fundamental 'entiteit'. -->
							<xsl:attribute name="entiteitOrBerichtRelatie" select="ancestor-or-self::ep:construct[@typeCode = 'entiteitrelatie']/ep:tech-name"/>
						</xsl:when>
						<xsl:when test="@typeCode = 'berichtrelatie' or ancestor::ep:construct[@typeCode = 'berichtrelatie']">
							<!-- This concerns association constructs relating a 'vrijbericht' to a fundamental 'entiteit'. -->
							<xsl:attribute name="entiteitOrBerichtRelatie" select="ancestor-or-self::ep:construct[@typeCode = 'berichtrelatie']/ep:tech-name"/>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="count(ancestor::ep:construct[@type='entity']) >= 1">
				<xsl:sequence select="imf:create-debug-comment(concat('Count: ',count(ancestor::ep:construct[@type='entity']),' berichtCode: ',$berichtCode),$debugging)"/>
			</xsl:if>
			<xsl:if test="$debugging">
				<xsl:sequence select="imf:create-output-element('ep:generated-id', generate-id(.))"/>
			</xsl:if>
			<xsl:apply-templates select="*[name()!= 'ep:construct' and name()!= 'ep:choice' and name()!='ep:attribute']"  mode="enrich-rough-messages"/>
			<xsl:apply-templates select="ep:construct | ep:choice" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
			</xsl:apply-templates>
		</xsl:copy>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>
	
	<xsl:template match="ep:choice" mode="enrich-rough-messages">
		<xsl:param name="berichtCode"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start B04000 /debug:start',$debugging)"/>
		
		<xsl:copy>
			<xsl:apply-templates select="ep:construct" mode="enrich-rough-messages">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
			</xsl:apply-templates>
		</xsl:copy>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>
	
	<xsl:template match="ep:verkorteAliasGerelateerdeEntiteit" mode="enrich-rough-messages">
		<xsl:sequence select="imf:create-debug-comment('debug:start B05000 /debug:start',$debugging)"/>
		
		<ep:verkorteAliasGerelateerdeEntiteit>
			<xsl:choose>
				<xsl:when test=". != ''">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:when test="..//ep:verkorteAlias = $prefix">
					<xsl:value-of select="$prefix"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</ep:verkorteAliasGerelateerdeEntiteit>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>
	
	<xsl:template match="ep:namespaceIdentifierGerelateerdeEntiteit" mode="enrich-rough-messages">
		<xsl:sequence select="imf:create-debug-comment('debug:start B06000 /debug:start',$debugging)"/>
		
		<ep:namespaceIdentifierGerelateerdeEntiteit>
			<xsl:choose>
				<xsl:when test="..//ep:verkorteAlias = $prefix">
					<xsl:value-of select="$packages/imvert:base-namespace"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</ep:namespaceIdentifierGerelateerdeEntiteit>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>
	
	<!-- ROME: Deze functie slaat n.m.m. nergens op en heeft geen toegevoegde waarde. -->
	<xsl:function name="imf:create-verwerkingsModus">
		<xsl:param name="contextnode"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:value-of select="$verwerkingsModus"/>
	</xsl:function>
	
</xsl:stylesheet>
