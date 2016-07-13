<?xml version="1.0" encoding="UTF-8"?>
<!-- SVN: $Id: Imvert2XSD-KING-endproduct.xsl 3 2015-11-05 10:35:07Z ArjanLoeffen 
	$ This stylesheet generates the EP file structure based on the embellish 
	file of a BSM EAP file. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:UML="omg.org/UML1.3"
	xmlns:imvert="http://www.imvertor.org/schema/system" xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
	xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310" xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking"
	xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" xmlns:stuf="http://www.egem.nl/StUF/StUF0301"
	xmlns:ep="http://www.imvertor.org/schema/endproduct" xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
	version="2.0">

	<xsl:output indent="yes" method="xml" encoding="UTF-8" />

	<xsl:variable name="stylesheet">
		Imvert2XSD-KING-create-endproduct-structure
	</xsl:variable>
	<xsl:variable name="stylesheet-version">
		$Id: Imvert2XSD-KING-create-endproduct-structure.xsl 1
		2015-11-11
		11:50:00Z RobertMelskens $
	</xsl:variable>

	<!-- This template is used to start generating the ep structure for an individual 
		message. -->
	<xsl:template match="/imvert:packages/imvert:package"
		mode="create-message-structure"> <!-- this is an embedded message schema within the koppelvlak -->
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:package[mode=create-message-structure]'" />
		</xsl:if>
		<xsl:variable name="tagged-values">
			<xsl:sequence select="imvert:tagged-values" />
		</xsl:variable>
		<xsl:if
			test="count(imvert:class[imvert:stereotype = 'VRAAGBERICHTTYPE' or imvert:stereotype = 'ANTWOORDBERICHTTYPE' or imvert:stereotype = 'KENNISGEVINGSBERICHTTYPE' or imvert:stereotype = 'VRIJBERICHTTYPE']) != 1">
			<xsl:message
				select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The amount of classes suitable for being processed as a message is less or larger than 1. Only 1 such class is allowed.')" />
		</xsl:if>
		<xsl:variable name="berichtType">
			<xsl:choose>
				<xsl:when test="imvert:class[imvert:stereotype = 'VRAAGBERICHTTYPE']">
					Vraagbericht
				</xsl:when>
				<xsl:when test="imvert:class[imvert:stereotype = 'ANTWOORDBERICHTTYPE']">
					Antwoordbericht
				</xsl:when>
				<xsl:when
					test="imvert:class[imvert:stereotype = 'KENNISGEVINGSBERICHTTYPE']">
					Kennisgevingsbericht
				</xsl:when>
				<xsl:when test="imvert:class[imvert:stereotype = 'VRIJBERICHTTYPE']">
					Vrij bericht
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- create the bericht message -->
		<!-- ROME: Onderstaande variabele wordt zo mogelijk, indien de tv 'Berichtcode' 
			niet voorkomt, afgeleid van een aantal tagged values. Indien deze tagged 
			value nog wel voorkomt dan wordt de waarde daar direct uit onttrokken. Het 
			is de bedoeling dat deze tv uiteindelijk verdwijnt zodat de xsl:choose in 
			deze variabele ook kan worden verwijderd. In dat geval kan ook de variabele 
			berichtCodeDeterming worden verwijderd en de processing er omheen. -->
		<xsl:variable name="berichtCode">
			<xsl:choose>
				<xsl:when
					test="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
					'stereotype-name-vraagberichttype',
					'stereotype-name-antwoordberichttype',
					'stereotype-name-vrijberichttype',
					'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode' and imvert:value != '']">
					<xsl:value-of
						select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
						'stereotype-name-vraagberichttype',
						'stereotype-name-antwoordberichttype',
						'stereotype-name-vrijberichttype',
						'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode']/imvert:value" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="Stereotype"
						select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
						'stereotype-name-vraagberichttype',
						'stereotype-name-antwoordberichttype',
						'stereotype-name-vrijberichttype',
						'stereotype-name-kennisgevingsberichttype'))]/imvert:stereotype" />
					<xsl:variable name="Inkomend">
						<xsl:choose>
							<xsl:when
								test="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
								'stereotype-name-vraagberichttype',
								'stereotype-name-antwoordberichttype',
								'stereotype-name-vrijberichttype',
								'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Inkomend' and imvert:value != '']">
								<xsl:value-of
									select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
									'stereotype-name-vraagberichttype',
									'stereotype-name-antwoordberichttype',
									'stereotype-name-vrijberichttype',
									'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Inkomend']/imvert:value" />
							</xsl:when>
							<xsl:otherwise>
								-
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="AanduidingActualiteit">
						<xsl:choose>
							<xsl:when
								test="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
								'stereotype-name-vraagberichttype',
								'stereotype-name-antwoordberichttype',
								'stereotype-name-vrijberichttype',
								'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'AanduidingActualiteit' and imvert:value != '']">
								<xsl:value-of
									select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
									'stereotype-name-vraagberichttype',
									'stereotype-name-antwoordberichttype',
									'stereotype-name-vrijberichttype',
									'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'AanduidingActualiteit']/imvert:value" />
							</xsl:when>
							<xsl:otherwise>
								-
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="Synchroon">
						<xsl:choose>
							<xsl:when
								test="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
								'stereotype-name-vraagberichttype',
								'stereotype-name-antwoordberichttype',
								'stereotype-name-vrijberichttype',
								'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Synchroon' and imvert:value != '']">
								<xsl:value-of
									select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
									'stereotype-name-vraagberichttype',
									'stereotype-name-antwoordberichttype',
									'stereotype-name-vrijberichttype',
									'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Synchroon']/imvert:value" />
							</xsl:when>
							<xsl:otherwise>
								-
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="AanduidingToekomstmutaties">
						<xsl:choose>
							<xsl:when
								test="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
								'stereotype-name-vraagberichttype',
								'stereotype-name-antwoordberichttype',
								'stereotype-name-vrijberichttype',
								'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'AanduidingToekomstmutaties' and imvert:value != '']">
								<xsl:value-of
									select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
									'stereotype-name-vraagberichttype',
									'stereotype-name-antwoordberichttype',
									'stereotype-name-vrijberichttype',
									'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'AanduidingToekomstmutaties']/imvert:value" />
							</xsl:when>
							<xsl:otherwise>
								-
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="Samengesteld">
						<xsl:choose>
							<xsl:when
								test="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
								'stereotype-name-vraagberichttype',
								'stereotype-name-antwoordberichttype',
								'stereotype-name-vrijberichttype',
								'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Samengesteld' and imvert:value != '']">
								<xsl:value-of
									select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
									'stereotype-name-vraagberichttype',
									'stereotype-name-antwoordberichttype',
									'stereotype-name-vrijberichttype',
									'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Samengesteld']/imvert:value" />
							</xsl:when>
							<xsl:otherwise>
								-
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of
						select="imf:determineBerichtCode($Stereotype,$Inkomend,$AanduidingActualiteit,$Synchroon,$AanduidingToekomstmutaties,$Samengesteld)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="berichtCodeDeterming">
			<xsl:choose>
				<xsl:when
					test="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
					'stereotype-name-vraagberichttype',
					'stereotype-name-antwoordberichttype',
					'stereotype-name-vrijberichttype',
					'stereotype-name-kennisgevingsberichttype'))]/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode']">
					Using-Berichtcode-tv
				</xsl:when>
				<xsl:otherwise>
					Using-Other-tvs
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$berichtCode = 'Niet te bepalen'">
			<xsl:message
				select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The berichtcode can not be determined. To be able to generate correct messages this is neccessary. Check your model for missing tagged values.')" />
		</xsl:if>
		<?x xsl:variable name="berichtCode" select="imvert:class[imvert:stereotype = 'VRAAGBERICHTTYPE' or imvert:stereotype = 'ANTWOORDBERICHTTYPE' or imvert:stereotype = 'KENNISGEVINGSBERICHTTYPE' or imvert:stereotype = 'VRIJBERICHTTYPE']/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode']/imvert:value"/ x?>
		<ep:message>
			<?x xsl:sequence
				select="imf:create-output-element('ep:documentation', 'TO-DO: bepalen of er documentatie op message niveau kan zijn. Zo ja dan dit toevoegen aan UML model van EP')"/ x?>
			<xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)" />
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)" />
			<xsl:sequence
				select="imf:create-output-element('ep:package-type', imvert:stereotype)" />
			<xsl:sequence
				select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)" />
			<xsl:sequence select="imf:create-output-element('ep:type', $berichtType)" />
			<!-- Start of the message is always a class with an imvert:stereotype 
				with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' 
				or 'KENNISGEVINGSBERICHTTYPE'. Since the toplevel structure of a message 
				complies to different rules in comparison with the entiteiten structure this 
				template is initialized within the 'create-initial-message-structure' mode. -->
			<xsl:apply-templates
				select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
																			'stereotype-name-vraagberichttype',
																			'stereotype-name-antwoordberichttype',
																			'stereotype-name-vrijberichttype',
																			'stereotype-name-kennisgevingsberichttype'))]"
				mode="create-toplevel-message-structure">
				<xsl:with-param name="berichtCode" select="$berichtCode" />
				<xsl:with-param name="useStuurgegevens" select="'yes'" />
				<xsl:with-param name="berichtCodeDeterming" select="$berichtCodeDeterming" />
			</xsl:apply-templates>
		</ep:message>
	</xsl:template>

	<!-- This template only processes imvert:class elements with an imvert:stereotype 
		with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' 
		or 'KENNISGEVINGSBERICHTTYPE'. Those classes contain a relation to the 'Parameters' 
		group (if not removed), a relation to a class with an imvert:stereotype with 
		the value 'ENTITEITTYPE' or, in case of a ''VRIJBERICHTTYPE', a relation 
		with one or more classes with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
		'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 'KENNISGEVINGSBERICHTTYPE'. These 
		classes also have a supertype with an imvert:stereotype with the value 'BERICHTTYPE' 
		which contain a 'melding' attribuut and have a relation to the 'Stuurgegevens' 
		group. This supertype is also processed here. -->
	<xsl:template match="imvert:class" mode="create-toplevel-message-structure">
		<xsl:param name="messagePrefix" select="''" />
		<xsl:param name="berichtCode" />
		<xsl:param name="berichtCodeDeterming" />

		<!-- The purpose of this parameter is to determine if the element 'stuurgegevens' 
			must be generated or not. The 'kennisgevingsbericht' , 'vraagbericht' or 
			'antwoordbericht' objects within the context of a 'vrijbericht' object aren't 
			allowed to contain 'stuurgegevens' after all. -->
		<xsl:param name="useStuurgegevens" select="'yes'" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:class[mode=create-initial-message-structure]'" />
		</xsl:if>
		<ep:seq>
			<xsl:if test="$useStuurgegevens = 'yes'">
				<xsl:variable name="Stuurgegevens">
					<xsl:call-template name="buildParametersAndStuurgegevens">
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="elements2bTested">
							<imvert:taggedValues>
								<xsl:if test="$berichtCodeDeterming = 'Using-Other-tvs'">
									<imvert:tv>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', 'Berichtcode')" />
										<xsl:sequence
											select="imf:create-output-element('imvert:value', $berichtCode)" />
									</imvert:tv>
								</xsl:if>
								<xsl:for-each select=".//imvert:tagged-value">
									<imvert:tv>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', imvert:name)" />
										<xsl:sequence
											select="imf:create-output-element('imvert:value', imvert:value)" />
									</imvert:tv>
								</xsl:for-each>
							</imvert:taggedValues>
						</xsl:with-param>
						<xsl:with-param name="parent" select="'Stuurgegevens'" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:if test="$Stuurgegevens != ''">
					<ep:construct>
						<ep:name>stuurgegevens</ep:name>
						<ep:tech-name>stuurgegevens</ep:tech-name>
						<ep:max-occurs>1</ep:max-occurs>
						<ep:min-occurs>1</ep:min-occurs>
						<ep:position>0</ep:position>
						<ep:seq>
							<xsl:sequence select="$Stuurgegevens" />
						</ep:seq>
					</ep:construct>
				</xsl:if>
			</xsl:if>
			<xsl:variable name="Parameters">
				<xsl:call-template name="buildParametersAndStuurgegevens">
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="elements2bTested">
						<imvert:taggedValues>
							<xsl:for-each select=".//imvert:tagged-value">
								<imvert:tv>
									<xsl:sequence
										select="imf:create-output-element('imvert:name', imvert:name)" />
									<xsl:sequence
										select="imf:create-output-element('imvert:value', imvert:value)" />
								</imvert:tv>
							</xsl:for-each>
						</imvert:taggedValues>
					</xsl:with-param>
					<xsl:with-param name="parent" select="'Parameters'" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="$Parameters != ''">
				<ep:construct>
					<ep:name>parameters</ep:name>
					<ep:tech-name>parameters</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>1</ep:min-occurs>
					<ep:position>50</ep:position>
					<ep:seq>
						<xsl:sequence select="$Parameters" />
					</ep:seq>
				</ep:construct>
			</xsl:if>
			<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:attribute' 
				elements within the supertype of imvert:class elements with an imvert:stereotype 
				with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' 
				or 'KENNISGEVINGSBERICHTTYPE' and those within the current class. -->
			<xsl:apply-templates select="imvert:supertype"
				mode="create-message-content">
				<xsl:with-param name="proces-type" select="'attributes'" />
				<xsl:with-param name="berichtCode" select="$berichtCode" />
			</xsl:apply-templates>
			<xsl:apply-templates select=".//imvert:attribute"
				mode="create-message-content">
				<xsl:with-param name="berichtCode" select="$berichtCode" />
			</xsl:apply-templates>
			<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:association' 
				elements with the stereotype 'GEGEVENSGROEP COMPOSITIE' within the supertype 
				of imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
				'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 'KENNISGEVINGSBERICHTTYPE' and 
				those within the current class. The first one generates the 'stuurgegevens' 
				element, the second one the 'parameters' element. -->
			<xsl:apply-templates select="imvert:supertype"
				mode="create-message-content">
				<xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
				<xsl:with-param name="berichtCode" select="$berichtCode" />
			</xsl:apply-templates>
			<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 'GEGEVENSGEGEVENSGROEP 
				COMPOSITIE' wordt gebruikt ipv 'GEGEVENSGROEP COMPOSITIE'. De uitbecommentarieerde 
				apply-templates kan met de eerste vorm omgaan maar moet tzt (zodra imvertor 
				daarop checkt) worden verwijdert. -->
			<!--xsl:apply-templates select=".//imvert:association[contains(imvert:stereotype,'GEGEVENSGROEP 
				COMPOSITIE')]" mode="create-message-content" -->
			<xsl:apply-templates
				select=".//imvert:association[imvert:stereotype='GEGEVENSGROEP COMPOSITIE']"
				mode="create-message-content">
				<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so the related object has already been processed) processing 
					stops. -->

				<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
					wel noodzakelijk is. -->
				<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')" />
				<xsl:with-param name="berichtCode" select="$berichtCode" />
			</xsl:apply-templates>

			<!-- ROME: De volgende apply template is volgens mij niet nodig. In een 
				supertype op dit niveau wordt immers alleen een relatie gelegd met de Stuurgegevens 
				en die heeft geen stereotype die gelijk is aan 'RELATIE' en mag die ook niet 
				hebben. Deze apply-template kan dus waarschijnlijk worden verwijderd en is 
				voor nu uitbecommentarieerd. -->
			<!--xsl:apply-templates select="imvert:supertype" mode="create-message-content"> 
				<xsl:with-param name="proces-type" select="'associationsRelatie'"/> <xsl:with-param 
				name="berichtCode" select="$berichtCode"/> </xsl:apply-templates -->

			<!-- At this level an association with a class having the stereotype 'ENTITEITTYPE' 
				always has the stereotype 'ENTITEITRELATIE'. The following apply-templates 
				initiates the processing of such an association. -->
			<xsl:apply-templates
				select=".//imvert:association[imvert:stereotype='ENTITEITRELATIE' and not(contains($berichtCode, 'Di')) and not(contains($berichtCode, 'Du'))]"
				mode="create-message-content">
				<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so the related object has already been processed) processing 
					stops. -->

				<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
					wel noodzakelijk is. -->
				<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')" />
				<xsl:with-param name="berichtCode" select="$berichtCode" />
				<!-- ROME: De waardetoekenning van de volgende parameter gaat er vanuit 
					dat in een vraagbericht of in een vrijbericht van het type selectie de associations 
					van het stereotype 'ENTITEITRELATIE' altijd de waardes 'gelijk', 'vanaf', 
					'totEnMet', 'start' of 'scope' hebben. -->
				<xsl:with-param name="orderingDesired" select="'no'" />
			</xsl:apply-templates>
			<!-- Associations linking from a class with a imvert:stereotype with the 
				value 'VRIJBERICHTTYPE' need special treatment. Those linking to a class 
				with a imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE' 
				or 'KENNISGEVINGSBERICHTTYPE' and those linking to a class with a imvert:stereotype 
				with the value 'ENTITEITRELATIE' must also be processed as from toplevel-message 
				type. -->
			<xsl:apply-templates
				select=".//imvert:association[contains($berichtCode, 'Di') and contains($berichtCode, 'Du')]"
				mode="create-toplevel-message-structure">
				<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so teh related object has already been processed) processing 
					stops. -->
				<xsl:with-param name="berichtCode" select="$berichtCode" />
			</xsl:apply-templates>
		</ep:seq>
	</xsl:template>

	<!-- This template takes care of associations from a 'vrijbericht' type 
		to the other message types 'vraagbericht', 'antwoordbericht' and 'kennisgevingsbericht'. -->
	<!-- ROME: De werking van dit template moet nog gecheckt worden zodra er 
		vrije berichten zijn. Waarschijnlijk moet er nog iets gebeuren met de context. -->
	<xsl:template match="imvert:association" mode="create-toplevel-message-structure">
		<xsl:param name="berichtCode" />
		<ep:construct>
			<xsl:sequence
				select="imf:create-output-element('ep:name', imvert:name/@original)" />
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
			<xsl:choose>
				<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
					<!-- ROME: Volgende apply-templates moet natuurlijk het template aanschoppen 
						met als match 'imvert:association[imvert:stereotype='ENTITEITRELATIE']'en 
						als mode 'create-message-content'. -->
					<xsl:apply-templates select="."
						mode="create-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->

						<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
							wel noodzakelijk is. -->
						<xsl:with-param name="id-trail"
							select="concat('#1#', imvert:id, '#')" />
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="'-'" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="imvert:stereotype='BERICHTRELATIE'">
					<xsl:variable name="type-id" select="imvert:type-id" />
					<xsl:apply-templates
						select="imvert:class[imvert:id = $type-id and imvert:stereotype = imf:get-config-stereotypes((
																						'stereotype-name-vraagberichttype',
																						'stereotype-name-antwoordberichttype',
																						'stereotype-name-kennisgevingsberichttype'))]"
						mode="create-toplevel-message-structure">
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="stuurgegevens" select="'no'" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
			<ep:seq>
				<ep:construct ismetadata="yes">
					<xsl:sequence
						select="imf:create-output-element('ep:name', 'StUF:functie')" />
					<xsl:sequence
						select="imf:create-output-element('ep:enum', imvert:name/@original)" />
				</ep:construct>
				<!-- ROME: Voor de volgende construct moet nog bepaald worden hoe het 
					zijn waarde krijgt. -->
				<ep:construct ismetadata="yes">
					<xsl:sequence
						select="imf:create-output-element('ep:name', 'StUF:entiteittype')" />
					<xsl:sequence select="imf:create-output-element('ep:enum', 'TODO')" />
				</ep:construct>
			</ep:seq>
		</ep:construct>
	</xsl:template>


	<!-- This template takes care of processing superclasses of the class being 
		processed. -->
	<xsl:template match="imvert:supertype" mode="create-message-content">
		<xsl:param name="proces-type" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:supertype[mode=create-message-content]'" />
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
			mode="create-message-content">
			<xsl:with-param name="proces-type" select="$proces-type" />
			<xsl:with-param name="berichtCode" select="$berichtCode" />
			<xsl:with-param name="context" select="$context" />
		</xsl:apply-templates>
	</xsl:template>

	<!-- This template transforms an 'imvert:attribute' element to an 'ep:construct' 
		element. -->
	<xsl:template match="imvert:attribute" mode="create-message-content">
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-message-content]'" />
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:variable name="MogelijkGeenWaarde">
			<xsl:choose>
				<xsl:when
					test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'MogelijkGeenWaarde'">
					yes
				</xsl:when>
				<xsl:otherwise>
					no
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<ep:construct>
			<!-- ROME: Samen met Arjan bepalen hoe we enkele elementen hieronder kunnen 
				vullen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:name', imvert:name/@original)" />
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)" />
			<xsl:sequence
				select="imf:create-output-element('ep:documentation', imvert:documentation)" />
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', imvert:tagged-values/imvert:tagged-value[imvert:name='IndicatieAuthentiek']/imvert:value)" />
			<xsl:if test="imvert:type-id">
				<xsl:apply-templates
					select="//imvert:class[imvert:id = $type-id and imvert:stereotype = 'ENUMERATION']"
					mode="create-datatype-content" />
			</xsl:if>
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)" />
			<xsl:sequence select="imf:create-output-element('ep:is-id', imvert:is-id)" />
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegeven', imvert:tagged-values/imvert:tagged-value[imvert:name='IndicateKerngegeven']/imvert:value)" />
			<!-- ROME: Wellicht overwegen om het volgende element toch maar 'total-digits' 
				te noemen aangezien het ook zo heet in XSD. De vraag is of ep:length dan 
				nog wel nodig is? -->
			<xsl:sequence
				select="imf:create-output-element('ep:length', imvert:total-digits)" />
			<xsl:sequence
				select="imf:create-output-element('ep:max-length', imvert:max-length)" />
			<xsl:sequence
				select="imf:create-output-element('ep:max-value', 'TO-DO: waar komt dit vandaan')" />
			<xsl:sequence
				select="imf:create-output-element('ep:min-length', imvert:min-length)" />
			<xsl:sequence
				select="imf:create-output-element('ep:min-value', 'TO-DO: waar komt dit vandaan')" />
			<!-- ROME: pattern kan een xml fragment bevatten wat geheel moet worden 
				overgenomen. Tenminste als dat de bedoeling is. -->
			<xsl:sequence
				select="imf:create-output-element('ep:pattern', imvert:pattern)" />
			<xsl:sequence
				select="imf:create-output-element('ep:regels', imvert:tagged-values/imvert:tagged-value[imvert:name='Regels']/imvert:value)" />
			<!-- ROME: Wat kunnen we met een type-modifier? Een '?' bij een datum 
				attribuut zou betekenen dat er een onvolledigedatum mogelijk kan zijn. Navragen 
				bij Henri od het idd zo is dat elke datum het onVolledigeDatum attribute 
				moet krijgen. Zijn er nog meer situaties waarin een modifier van belang kan 
				zijn. -->
			<xsl:sequence
				select="imf:create-output-element('ep:type-modifier', imvert:type-modifier)" />
			<xsl:sequence
				select="imf:create-output-element('ep:type-name', imvert:type-name)" />
			<!-- ROME: Ik vermoed dat onderstaande element op basis van het voidable 
				tagged value gegenereerd moet worden. Je zou zeggen dat op basis van die 
				tagged value echter ook de construct 'noValue' gegenereerd moet worden. Dit 
				is idd het geval. Het is afgeleid van de tagged value 'mogelijkGeenWaarde'. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', imvert:tagged-values/imvert:tagged-value[imvert:name='MogelijkGeenWaarde']/imvert:value)" />
			<!-- When a tagged-value 'Positie' exists this is used to assign a value 
				to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when
					test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)" />
					<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')" />
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)" />
				</xsl:when>
				<xsl:otherwise />
			</xsl:choose>
			<!-- Attributes with the name 'melding' or which are descendants of a 
				class with the name 'Stuurgegevens', 'Systeem' or 'Parameters' mustn't get 
				XML attributes. -->
			<xsl:if
				test="imvert:name != 'melding' and ancestor::imvert:class[imvert:name!='Stuurgegevens'] and ancestor::imvert:class[imvert:name!='Systeem'] and ancestor::imvert:class[imvert:name!='Parameters']">
				<ep:seq>
					<!-- The function imf:createAttributes is used to determine the XML 
						attributes neccessary for this context. It has the following parameters: 
						- typecode - berichttype - context - datumType The first 3 parameters relate 
						to columns with the same name within an Excel spreadsheet used to configure 
						a.o. XML attributes usage. The last parameter is used to determine the need 
						for the XML-attribute 'StUF:indOnvolledigeDatum'. -->

					<!-- ROME: De berichtcode is niet als globale variabele aanwezig en 
						kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig 
						verkregen worden aangezien het element op basis waarvan de berichtcode kan 
						worden gegenereerd geen ancestor is van het huidige element. Er zijn 2 opties: 
						* De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven. 
						* De attributes pas aan de EP structuur toevoegen in een aparte slag nadat 
						de EP structuur al gegenereerd is. Het message element dat de berichtcode 
						bevat is dan nl. wel altijd de ancestor van het element dat het nodig heeft. 
						Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook 
						nog herleid en doorgegeven worden. -->
					<xsl:variable name="datumType">
						<xsl:choose>
							<!-- ROME: Zodra scalar-xxx is doorgevoerd kan de eerste when verwijderd 
								worden. -->
							<xsl:when test="imvert:type-name='datetime'">
								yes
							</xsl:when>
							<xsl:when test="imvert:type-name='scalar-datetime'">
								yes
							</xsl:when>
							<xsl:otherwise>
								no
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:comment
						select="concat('Attributes voor bottemlevel, berichtcode: -, context: - met datumtype?: ', $datumType)" />
					<xsl:variable name="attributes"
						select="imf:createAttributes('bottomlevel', '-', '-', $datumType, '',$MogelijkGeenWaarde)" />
					<xsl:sequence select="$attributes" />
				</ep:seq>
			</xsl:if>
		</ep:construct>
	</xsl:template>

	<!-- This template transforms an 'imvert:association' element to an 'ep:construct' 
		element.. -->
	<xsl:template match="imvert:association[imvert:stereotype='ENTITEITRELATIE']"
		mode="create-message-content">
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="orderingDesired" select="'yes'" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:variable name="context">
			<xsl:choose>
				<xsl:when
					test="imvert:name = 'gelijk' or imvert:name = 'vanaf' or imvert:name = 'totEnMet'">
					selectie
				</xsl:when>
				<xsl:when test="imvert:name = 'start'">
					start
				</xsl:when>
				<xsl:when test="imvert:name = 'scope'">
					scope
				</xsl:when>
				<xsl:otherwise>
					-
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association[mode=create-message-content]'" />
		</xsl:if>
		<xsl:comment
			select="concat('berichtCode: ', $berichtCode, ', context: ', $context)" />
		<xsl:choose>
			<xsl:when test="contains($berichtCode,'La')">
				<!-- ROME: bij een antwoordbericht wordt er een niveau tussen gegenereerd. 
					Waarom we dat daar wel doen en bij een vraag- en kennisgevingbericht niet 
					vraag ik me af. -->

				<!-- La05: een synchroon antwoordbericht met de gegevens op peiltijdstip 
					zoals bekend in de registratie op peiltijdstip formele historie La06: een 
					asynchroon antwoordbericht met de gegevens op peiltijdstip zoals bekend in 
					de registratie op peiltijdstip formele historie La07: een synchroon antwoordbericht 
					met materiële historie voor de gevraagde objecten op entiteitniveau La08: 
					een asynchroon antwoordbericht met materiële historie voor de gevraagde objecten 
					op entiteitniveau La09: een synchroon antwoordbericht met materiële en formele 
					historie voor de gevraagde objecten op entiteitniveau La10: een asynchroon 
					antwoordbericht met materiële en formele historie voor de gevraagde objecten 
					op entiteitniveau -->
				<ep:construct>
					<ep:name>antwoord</ep:name>
					<ep:tech-name>antwoord</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>200</ep:position>
					<ep:seq orderingDesired="no">
						<xsl:call-template name="createEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
							<xsl:with-param name="type-id" select="$type-id" />
							<xsl:with-param name="constructName" select="'-'" />
							<xsl:with-param name="historyApplies">
								<xsl:choose>
									<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">
										yes-Materieel
									</xsl:when>
									<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">
										yes
									</xsl:when>
									<xsl:otherwise>
										no
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</ep:seq>
				</ep:construct>
			</xsl:when>
			<xsl:when test="contains($berichtCode,'Lv')">
				<xsl:choose>
					<xsl:when test="$context = 'selectie'">
						<xsl:call-template name="createEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
							<xsl:with-param name="type-id" select="$type-id" />
							<xsl:with-param name="constructName" select="'-'" />
							<xsl:with-param name="historyApplies" select="'no'" />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$context = 'start'">
						<ep:construct>
							<ep:name>
								<xsl:value-of select="$context" />
							</ep:name>
							<ep:tech-name>
								<xsl:value-of select="$context" />
							</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>200</ep:position>
							<ep:seq orderingDesired="no">
								<xsl:call-template name="createEntityConstruct">
									<xsl:with-param name="id-trail" select="$id-trail" />
									<xsl:with-param name="berichtCode" select="$berichtCode" />
									<xsl:with-param name="context" select="$context" />
									<xsl:with-param name="type-id" select="$type-id" />
									<xsl:with-param name="constructName" select="imvert:name" />
									<xsl:with-param name="historyApplies" select="'no'" />
								</xsl:call-template>
							</ep:seq>
						</ep:construct>
					</xsl:when>
					<xsl:when test="$context = 'scope'">
						<ep:construct>
							<ep:name>
								<xsl:value-of select="$context" />
							</ep:name>
							<ep:tech-name>
								<xsl:value-of select="$context" />
							</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>200</ep:position>
							<ep:seq orderingDesired="no">
								<xsl:call-template name="createEntityConstruct">
									<xsl:with-param name="id-trail" select="$id-trail" />
									<xsl:with-param name="berichtCode" select="$berichtCode" />
									<xsl:with-param name="context" select="$context" />
									<xsl:with-param name="type-id" select="$type-id" />
									<xsl:with-param name="constructName" select="imvert:name" />
									<xsl:with-param name="historyApplies" select="'no'" />
								</xsl:call-template>
							</ep:seq>
						</ep:construct>
					</xsl:when>
				</xsl:choose>

			</xsl:when>
			<xsl:when test="contains($berichtCode,'Lk')">
				<xsl:call-template name="createEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
					<xsl:with-param name="type-id" select="$type-id" />
					<xsl:with-param name="constructName" select="'-'" />
					<xsl:with-param name="historyApplies" select="'no'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($berichtCode,'Sh')">

			</xsl:when>
			<xsl:when test="contains($berichtCode,'Sa')">

			</xsl:when>
			<xsl:when test="contains($berichtCode,'Di')">

			</xsl:when>
			<xsl:when test="contains($berichtCode,'Du')">

			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="createEntityConstruct">
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="orderingDesired" select="'yes'" />
		<xsl:param name="type-id" />
		<xsl:param name="constructName" />
		<xsl:param name="historyApplies" />
		<ep:construct>
			<xsl:choose>
				<xsl:when test="$constructName='-'">
					<xsl:sequence
						select="imf:create-output-element('ep:name', imvert:name/@original)" />
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imvert:name)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-output-element('ep:name', $constructName)" />
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', $constructName)" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', //imvert:class[imvert:id = $type-id]/imvert:alias)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', imvert:alias)" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence
				select="imf:create-output-element('ep:documentation', imvert:documentation)" />
			<!-- Onderstaande sequence zou gebruikt kunnen worden voor het ophalen 
				van de documentatie behorende bij de class waarnaar verwezen wordt. -->
			<!--xsl:sequence select="imf:create-output-element('ep:documentation', 
				//imvert:class[imvert:id = $type-id]/imvert:documentation)"/ -->
			<!-- ROME: t.b.v. kennisgevingen is onderstaande choose geplaatst. Zodra 
				zeker is dat we de waarden van de min- en maxoccurs ook uit de gerelateerde 
				imvert elementen kunnen halen kan deze choose weer worden verwijderd en vervangen 
				worden door de code binnen de otherwise tak. -->
			<xsl:choose>
				<xsl:when test="contains($berichtCode,'Lk')">
					<xsl:if test="imvert:max-occurs > 2 or imvert:max-occurs = 'unbounded'">
						<xsl:message
							select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The element ', ep:name, ' has a maxOccurs of ', ep:max-occurs, '. In Kennisgevingen only a maxOccurs between 1 and 2 is allowed.')" />
					</xsl:if>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', 2)" />
					<xsl:if test="imvert:min-occurs > 1">
						<xsl:message
							select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The element ', ep:name, ' has a minOccurs of ', ep:min-occurs, '. In Kennisgevingen only a minOccurs of 1 is allowed.')" />
					</xsl:if>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', 1)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:if
						test="($berichtCode = 'La02' or $berichtCode = 'La04' or $berichtCode = 'La06' or $berichtCode = 'La08' or $berichtCode = 'La10') and imvert:max-occurs != '1'">
						<xsl:message
							select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The element ', imvert:name, ' has a maxOccurs of ', imvert:max-occurs, '. In asynchrone messages only a maxOccurs of 1 is allowed.')" />
					</xsl:if>
					<xsl:sequence
						select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:sequence
						select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', imvert:tagged-values/imvert:tagged-value[imvert:name='IndicatieAuthentiek']/imvert:value)" />
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)" />
			<xsl:sequence select="imf:create-output-element('ep:is-id', imvert:is-id)" />
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegeven', imvert:tagged-values/imvert:tagged-value[imvert:name='IndicateKerngegeven']/imvert:value)" />
			<xsl:sequence
				select="imf:create-output-element('ep:regels', imvert:tagged-values/imvert:tagged-value[imvert:name='Regels']/imvert:value)" />
			<!-- Ik vermoed dat onderstaande element op basis van het voidable tagged 
				value gegenereerd moet worden. Je zou zeggen dat op basis van die tagged 
				value echter ook de construct 'noValue' gegenereerd moet worden. Dat is echter 
				de vraag omdat dat een XML requirement is en mogelijk geen JSON requirement. 
				De vraag is dus of we dat wel moeten doen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', imvert:tagged-values/imvert:tagged-value[imvert:name='MogelijkGeenWaarde']/imvert:value)" />
			<!-- When a tagged-value 'Positie' exists this is used to assign a value 
				to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when
					test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)" />
					<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')" />
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)" />
				</xsl:when>
				<xsl:otherwise />
			</xsl:choose>
			<!-- An 'ep:construct' based on an 'imvert:association' element can contain 
				several other 'ep:construct' elements (e.g. 'ep:constructs' for the attributes 
				of the association itself of for the associations of the association) therefore 
				an 'ep:seq' element is generated here. -->
			<ep:seq>
				<xsl:if test="$orderingDesired='no'">
					<xsl:attribute name="orderingDesired" select="'no'" />
				</xsl:if>
				<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
					and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
					be placed directly within the current 'ep:seq'. -->
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer 
					of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar 
					ook aan 'tijdvakRelatie', 'historieMaterieel' en 'historieFormeel'. Onderstaande 
					elementen 'StUF:tijdvakGeldigheid' en 'StUF:tijdstipRegistratie' mogen trouwens 
					alleen voorkomen als voor een van de attributen van het huidige object historie 
					is gedefinieerd of als er om gevraagd wordt. De vraag is echter of daarbij 
					alleen gekeken moet worden naar de attributen waarvan de elementen op hetzelfde 
					niveau als onderstaande elementen worden gegenereerd of dat deze elementen 
					ook al gegenereerd moeten worden als er ergens dieper onder het huidige niveau 
					een element voorkomt waarbij op het gerelateerde attribuut historie is gedefinieerd. 
					Dit geldt voor alle locaties waar onderstaande elementen worden gedefinieerd. -->
				<ep:construct>
					<ep:name>StUF:tijdvakGeldigheid</ep:name>
					<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>150</ep:position>
				</ep:construct>
				<ep:construct>
					<ep:name>StUF:tijdstipRegistratie</ep:name>
					<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>151</ep:position>
				</ep:construct>
				<ep:construct>
					<ep:name>StUF:extraElementen</ep:name>
					<ep:tech-name>StUF:extraElementen</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>152</ep:position>
				</ep:construct>
				<xsl:message select="concat('$historyApplies ',$historyApplies)" />
				<xsl:if
					test="($historyApplies='yes-Materieel' or $historyApplies='yes') and //imvert:class[imvert:id = $type-id and 
							  .//imvert:tagged-value[imvert:name='IndicatieMateriLeHistorie' and contains(imvert:value,'Ja')]]">
					<ep:construct>
						<ep:name>historieMaterieel</ep:name>
						<ep:tech-name>historieMaterieel</ep:tech-name>
						<ep:max-occurs>unbounded</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>153</ep:position>
						<xsl:if test="$orderingDesired='no'">
							<xsl:attribute name="orderingDesired" select="'no'" />
						</xsl:if>
						<ep:seq>
							<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
								and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
								be placed directly within the current 'ep:seq'. -->
							<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-message-content">
								<xsl:with-param name="proces-type" select="'attributes'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
							<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-message-content">
								<xsl:with-param name="proces-type"
									select="'associationsGroepCompositie'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
							<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-message-content">
								<xsl:with-param name="proces-type" select="'associationsRelatie'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
						</ep:seq>
					</ep:construct>
				</xsl:if>
				<xsl:if
					test="$historyApplies='yes' and //imvert:class[imvert:id = $type-id and 
							  .//imvert:tagged-value[imvert:name='IndicatieFormeleHistorie' and contains(imvert:value,'Ja')]]">
					<ep:construct>
						<ep:name>historieFormeel</ep:name>
						<ep:tech-name>historieFormeel</ep:tech-name>
						<ep:max-occurs>unbounded</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>154</ep:position>
						<xsl:if test="$orderingDesired='no'">
							<xsl:attribute name="orderingDesired" select="'no'" />
						</xsl:if>
						<ep:seq>
							<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
								and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
								be placed directly within the current 'ep:seq'. -->
							<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-message-content">
								<xsl:with-param name="proces-type" select="'attributes'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
							<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-message-content">
								<xsl:with-param name="proces-type"
									select="'associationsGroepCompositie'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
							<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-message-content">
								<xsl:with-param name="proces-type" select="'associationsRelatie'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
						</ep:seq>
					</ep:construct>
				</xsl:if>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<xsl:variable name="mnemonic">
					<xsl:choose>
						<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
							<xsl:value-of select="//imvert:class[imvert:id = $type-id]/imvert:alias" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="imvert:alias" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- The function imf:createAttributes is used to determine the XML attributes 
					neccessary for this context. It has the following parameters: - typecode 
					- berichttype - context - datumType The first 3 parameters relate to columns 
					with the same name within an Excel spreadsheet used to configure a.o. XML 
					attributes usage. The last parameter is used to determine the need for the 
					XML-attribute 'StUF:indOnvolledigeDatum'. -->

				<!-- ROME: De berichtcode is niet als globale variabele aanwezig en kan 
					dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig verkregen 
					worden aangezien het element op basis waarvan de berichtcode kan worden gegenereerd 
					geen ancestor is van het huidige element. Er zijn 2 opties: * De berichtcode 
					als parameter aan alle templates toevoegen en steeds doorgeven. * De attributes 
					pas aan de EP structuur toevoegen in een aparte slag nadat de EP structuur 
					al gegenereerd is. Het message element dat de berichtcode bevat is dan wel 
					altijd de ancestor van het element dat het nodig heeft. Voor nu heb ik gekozen 
					voor de eerste optie. Overigens moet de context ook nog herleid en doorgegeven 
					worden. -->
				<xsl:comment
					select="concat('Attributes voor toplevel, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
				<xsl:variable name="attributes"
					select="imf:createAttributes('toplevel', substring($berichtCode,1,2), $context, 'no', $mnemonic, 'no')" />
				<xsl:sequence select="$attributes" />
			</ep:seq>
		</ep:construct>

	</xsl:template>

	<!-- This template transforms an 'imvert:association' element to an 'ep:construct' 
		element.. -->
	<xsl:template match="imvert:association" mode="create-message-content">
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="orderingDesired" select="'yes'" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:variable name="MogelijkGeenWaarde">
			<xsl:choose>
				<xsl:when
					test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'MogelijkGeenWaarde'">
					yes
				</xsl:when>
				<xsl:otherwise>
					no
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association[mode=create-message-content]'" />
		</xsl:if>
		<ep:construct>
			<xsl:sequence
				select="imf:create-output-element('ep:name', imvert:name/@original)" />
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)" />
			<xsl:choose>
				<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', //imvert:class[imvert:id = $type-id]/imvert:alias)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', imvert:alias)" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence
				select="imf:create-output-element('ep:documentation', imvert:documentation)" />
			<!-- Onderstaande sequence zou gebruikt kunnen worden voor het ophalen 
				van de documentatie behorende bij de class waarnaar verwezen wordt. -->
			<!--xsl:sequence select="imf:create-output-element('ep:documentation', 
				//imvert:class[imvert:id = $type-id]/imvert:documentation)"/ -->
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', imvert:tagged-values/imvert:tagged-value[imvert:name='IndicatieAuthentiek']/imvert:value)" />
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)" />
			<xsl:sequence select="imf:create-output-element('ep:is-id', imvert:is-id)" />
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegeven', imvert:tagged-values/imvert:tagged-value[imvert:name='IndicateKerngegeven']/imvert:value)" />
			<xsl:sequence
				select="imf:create-output-element('ep:regels', imvert:tagged-values/imvert:tagged-value[imvert:name='Regels']/imvert:value)" />				
			<!-- Ik vermoed dat onderstaande element op basis van het voidable tagged 
				value gegenereerd moet worden. Je zou zeggen dat op basis van die tagged 
				value echter ook de construct 'noValue' gegenereerd moet worden. Dat is echter 
				de vraag omdat dat een XML requirement is en mogelijk geen JSON requirement. 
				De vraag is dus of we dat wel moeten doen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', imvert:tagged-values/imvert:tagged-value[imvert:name='MogelijkGeenWaarde']/imvert:value)" />
			<!-- When a tagged-value 'Positie' exists this is used to assign a value 
				to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when
					test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)" />
					<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')" />
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)" />
				</xsl:when>
				<xsl:otherwise />
			</xsl:choose>
			<!-- An 'ep:construct' based on an 'imvert:association' element can contain 
				several other 'ep:construct' elements (e.g. 'ep:constructs' for the attributes 
				of the association itself of for the associations of the association) therefore 
				an 'ep:seq' element is generated here. -->
			<ep:seq>
				<!-- ROME: De test op de variabele $oderingDesired is hier wellicht niet 
					meer nodig omdat er nu een separaat template is voor het afhandelen het 'imvert:association' 
					element met het stereotype 'ENTITEITRELATIE'. -->
				<xsl:if test="$orderingDesired='no'">
					<xsl:attribute name="orderingDesired" select="'no'" />
				</xsl:if>
				<!-- The following choose processes the 3 situations an association can 
					represent. -->
				<xsl:choose>
					<!-- The association is a 'relatie' and it has to contain a 'gerelateerde' 
						construct. -->
					<xsl:when
						test="//imvert:class[imvert:id = $type-id] and imvert:stereotype='RELATIE'">
						<ep:construct>
							<ep:name>gerelateerde</ep:name>
							<ep:tech-name>gerelateerde</ep:tech-name>
							<xsl:sequence
								select="imf:create-output-element('ep:mnemonic', //imvert:class[imvert:id = $type-id]/imvert:alias)" />
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>1</ep:position>
							<ep:seq>
								<!-- ROME: Waarschijnlijk moeten afhankelijk van de context (mag 
									de gerelateerde alleen de kerngegevens bevatten of wel meer) de volgende 
									apply-templates van extra parameters worden voorzien zodat de te genereren 
									structuur aangescherpt kan worden. -->
								<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
									mode="create-message-content">
									<xsl:with-param name="proces-type" select="'attributes'" />
									<!-- ROME: Het is de vraag of deze parameter en het checken op id 
										nog wel noodzakelijk is. -->
									<xsl:with-param name="id-trail" select="$id-trail" />
									<xsl:with-param name="berichtCode" select="$berichtCode" />
									<xsl:with-param name="context" select="$context" />
								</xsl:apply-templates>
								<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
									mode="create-message-content">
									<xsl:with-param name="proces-type"
										select="'associationsGroepCompositie'" />
									<!-- ROME: Het is de vraag of deze parameter en het checken op id 
										nog wel noodzakelijk is. -->
									<xsl:with-param name="id-trail" select="$id-trail" />
									<xsl:with-param name="berichtCode" select="$berichtCode" />
									<xsl:with-param name="context" select="$context" />
								</xsl:apply-templates>
								<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context 
									meer of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' 
									maar ook aan 'tijdvakRelatie', 'historieMaterieel' en 'historieFormeel'. -->
								<ep:construct>
									<ep:name>StUF:tijdvakGeldigheid</ep:name>
									<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
									<ep:max-occurs>1</ep:max-occurs>
									<ep:min-occurs>0</ep:min-occurs>
									<ep:position>150</ep:position>
								</ep:construct>
								<ep:construct>
									<ep:name>StUF:tijdstipRegistratie</ep:name>
									<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
									<ep:max-occurs>1</ep:max-occurs>
									<ep:min-occurs>0</ep:min-occurs>
									<ep:position>151</ep:position>
								</ep:construct>
								<ep:construct>
									<ep:name>StUF:extraElementen</ep:name>
									<ep:tech-name>StUF:extraElementen</ep:tech-name>
									<ep:max-occurs>1</ep:max-occurs>
									<ep:min-occurs>0</ep:min-occurs>
									<ep:position>152</ep:position>
								</ep:construct>
								<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
									mode="create-message-content">
									<xsl:with-param name="proces-type" select="'associationsRelatie'" />
									<!-- ROME: Het is de vraag of deze parameter en het checken op id 
										nog wel noodzakelijk is. -->
									<xsl:with-param name="id-trail" select="$id-trail" />
									<xsl:with-param name="berichtCode" select="$berichtCode" />
									<xsl:with-param name="context" select="$context" />
								</xsl:apply-templates>
								<xsl:variable name="mnemonic">
									<xsl:value-of
										select="//imvert:class[imvert:id = $type-id]/imvert:alias" />
								</xsl:variable>
								<!-- The function imf:createAttributes is used to determine the XML 
									attributes neccessary for this context. It has the following parameters: 
									- typecode - berichttype - context - datumType The first 3 parameters relate 
									to columns with the same name within an Excel spreadsheet used to configure 
									a.o. XML attributes usage. The last parameter is used to determine the need 
									for the XML-attribute 'StUF:indOnvolledigeDatum'. -->

								<!-- ROME: De berichtcode is niet als globale variabele aanwezig 
									en kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig 
									verkregen worden aangezien het element op basis waarvan de berichtcode kan 
									worden gegenereerd geen ancestor is van het huidige element. Er zijn 2 opties: 
									* De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven. 
									* De attributes pas aan de EP structuur toevoegen in een aparte slag nadat 
									de EP structuur al gegenereerd is. Het message element dat de berichtcode 
									bevat is dan wel altijd de ancestor van het element dat het nodig heeft. 
									Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook 
									nog herleid en doorgegeven worden. -->
								<xsl:comment
									select="concat('Attributes voor gerelateerde, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
								<xsl:variable name="attributes"
									select="imf:createAttributes('gerelateerde', substring($berichtCode,1,2), $context, 'no', $mnemonic, 'no')" />
								<xsl:sequence select="$attributes" />
							</ep:seq>
						</ep:construct>
						<!-- The following 'apply-templates' initiates the processing of the 
							class which contains the attributes of the 'relatie' type element. -->
						<xsl:apply-templates select="imvert:association-class">
							<xsl:with-param name="proces-type" select="'attributes'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<!-- The following 'apply-templates' initiates the processing of the 
							class which contains the attributegroups of the 'relatie' type element. -->
						<xsl:apply-templates select="imvert:association-class">
							<xsl:with-param name="proces-type"
								select="'associationsGroepCompositie'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<ep:construct>
							<ep:name>StUF:tijdvakGeldigheid</ep:name>
							<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>150</ep:position>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:tijdstipRegistratie</ep:name>
							<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>151</ep:position>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:extraElementen</ep:name>
							<ep:tech-name>StUF:extraElementen</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>152</ep:position>
						</ep:construct>
						<!-- The following 'apply-templates' initiates the processing of the 
							class which contains the associations of the 'relatie' type element. -->
						<xsl:apply-templates select="imvert:association-class">
							<xsl:with-param name="proces-type" select="'associations'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
					</xsl:when>
					<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
						and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
						be placed directly within the current 'ep:seq'. -->
					<xsl:when
						test="//imvert:class[imvert:id = $type-id and imvert:stereotype='ENTITEITTYPE']">
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-message-content">
							<xsl:with-param name="proces-type" select="'attributes'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-message-content">
							<xsl:with-param name="proces-type"
								select="'associationsGroepCompositie'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer 
							of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar 
							ook aan 'tijdvakRelatie', 'historieMaterieel' en 'historieFormeel'. -->
						<ep:construct>
							<ep:name>StUF:tijdvakGeldigheid</ep:name>
							<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>150</ep:position>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:tijdstipRegistratie</ep:name>
							<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>151</ep:position>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:extraElementen</ep:name>
							<ep:tech-name>StUF:extraElementen</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>152</ep:position>
						</ep:construct>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-message-content">
							<xsl:with-param name="proces-type" select="'associationsRelatie'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<xsl:variable name="mnemonic">
							<xsl:choose>
								<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
									<xsl:value-of
										select="//imvert:class[imvert:id = $type-id]/imvert:alias" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="imvert:alias" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<!-- The function imf:createAttributes is used to determine the XML 
							attributes neccessary for this context. It has the following parameters: 
							- typecode - berichttype - context - datumType The first 3 parameters relate 
							to columns with the same name within an Excel spreadsheet used to configure 
							a.o. XML attributes usage. The last parameter is used to determine the need 
							for the XML-attribute 'StUF:indOnvolledigeDatum'. -->

						<!-- ROME: De berichtcode is niet als globale variabele aanwezig en 
							kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig 
							verkregen worden aangezien het element op basis waarvan de berichtcode kan 
							worden gegenereerd geen ancestor is van het huidige element. Er zijn 2 opties: 
							* De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven. 
							* De attributes pas aan de EP structuur toevoegen in een aparte slag nadat 
							de EP structuur al gegenereerd is. Het message element dat de berichtcode 
							bevat is dan wel altijd de ancestor van het element dat het nodig heeft. 
							Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook 
							nog herleid en doorgegeven worden. -->
						<xsl:comment
							select="concat('Attributes voor toplevel, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
						<xsl:variable name="attributes"
							select="imf:createAttributes('toplevel', substring($berichtCode,1,2), $context, 'no', $mnemonic, 'no')" />
						<xsl:sequence select="$attributes" />
					</xsl:when>
					<!-- The association is a 'berichtRelatie' and it contains a 'bericht'. 
						This situation can occur whithin the context of a 'vrij bericht'. -->
					<!-- ROME: Checken of de volgende when idd de berichtRelatie afhandelt 
						en of alle benodigde (standaard) elementen wel gegenereerd worden. Er wordt 
						geen supertype in afgehandeld, ik weet even niet meer waarom. -->
					<xsl:when test="//imvert:class[imvert:id = $type-id]">
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-message-content">
							<xsl:with-param name="proces-type" select="'attributes'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-message-content">
							<xsl:with-param name="proces-type"
								select="'associationsGroepCompositie'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-message-content">
							<xsl:with-param name="proces-type" select="'associationsRelatie'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
					</xsl:when>
				</xsl:choose>
				<!-- Only in case of an association representing a 'relatie' and containing 
					a 'gerelateerde' construct (within the above choose the first 'when' XML 
					Attributes for the 'relatie' type element have to be generated. Because these 
					has to be placed outside the 'gerelateerde' element it has to be done here. -->
				<xsl:if test="imvert:stereotype='RELATIE'">
					<!-- The function imf:createAttributes is used to determine the XML 
						attributes neccessary for this context. It has the following parameters: 
						- typecode - berichttype - context - datumType The first 3 parameters relate 
						to columns with the same name within an Excel spreadsheet used to configure 
						a.o. XML attributes usage. The last parameter is used to determine the need 
						for the XML-attribute 'StUF:indOnvolledigeDatum'. -->

					<!-- ROME: De berichtcode is niet als globale variabele aanwezig en 
						kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig 
						verkregen worden aangezien het element op basis waarvan de berichtcode kan 
						worden gegenereerd geen ancestor is van het huidige element. Er zijn 2 opties: 
						* De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven. 
						* De attributes pas aan de EP structuur toevoegen in een aparte slag nadat 
						de EP structuur al gegenereerd is. Het message element dat de berichtcode 
						bevat is dan wel altijd de ancestor van het element dat het nodig heeft. 
						Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook 
						nog herleid en doorgegeven worden. -->
					<xsl:variable name="mnemonic">
						<xsl:choose>
							<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
								<xsl:value-of
									select="//imvert:class[imvert:id = $type-id]/imvert:alias" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="imvert:alias" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:comment
						select="concat('Attributes voor relatie, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
					<xsl:variable name="attributes"
						select="imf:createAttributes('relatie', substring($berichtCode,1,2), $context, 'no', $mnemonic, $MogelijkGeenWaarde)" />
					<xsl:sequence select="$attributes" />
				</xsl:if>
			</ep:seq>
		</ep:construct>
	</xsl:template>

	<!-- This template generates the structure of the 'relatie' type element 
		excluding the 'gerelateerde' element. -->
	<!-- ROME: De werking van dit template moet adhv van een voorbeeld gecheckt 
		en mogelijk geoptimaliseerd worden. Zo is de vraag of een association-class 
		een supertype kan hebben. Zo ja dan moeten er nog apply-templates worden 
		opgenomen voor het verwerken van de supertypes. -->
	<xsl:template match="imvert:association-class">
		<xsl:param name="proces-type" select="'associations'" />
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment
				select="'imvert:association-class[mode=create-message-relations-content]'" />
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:choose>
			<!-- Following when processes the attributes of the association-class. -->
			<xsl:when test="$proces-type='attributes'">
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
			</xsl:when>
			<!-- Following otherwise processes the relatie type associations and group 
				compositie associations of the association-class. -->
			<xsl:otherwise>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<!-- ROME: Aangezien een association-class alleen de attributen levert 
			van een relatie en dat relatie element al ergens anders zijn XML-attributes 
			toegekend krijgt hoeven er hier geen attributes meer toegekend te worden. -->
	</xsl:template>

	<!-- Declaration of the content of an 'imvert:association' and 'imvert:association-class' 
		finaly always takes place within an 'imvert:class' element. This element 
		is processed within this template. -->
	<xsl:template match="imvert:class" mode="create-message-content">
		<xsl:param name="proces-type" select="''" />
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:choose>
			<!-- The following when initiate the processing of the attributes belonging 
				to the current class. First the ones found within the superclass of the current 
				class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:apply-templates select="imvert:supertype"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:attribute"
					mode="create-message-content">
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
			</xsl:when>
			<!-- The following when initiate the processing of the attributegroups 
				belonging to the current class. First the ones found within the superclass 
				of the current class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsGroepCompositie'">
				<!-- If the class is about the 'stuurgegevens' or 'parameters' one of 
					the following when's is activated to check if all children of the stuurgegevens 
					are allowed within the current berichttype. If not a warning is generated. -->
				<!-- ROME: Er wordt nu alleen gecheckt of de elementen die gedefinieerd 
					worden wel voor mogen komen. De vraag is of ook gecheckt moet worden of de 
					elementen die niet zijn gedefinieerd wel weggelaten mogen worden. -->
				<!--xsl:if test="upper-case(imvert:name)='STUURGEGEVENS' or upper-case(imvert:name)='PARAMETERS'"> 
					<xsl:call-template name="areParametersAndStuurgegevensAllowedOrRequired"> 
					<xsl:with-param name="berichtCode" select="$berichtCode"/> <xsl:with-param 
					name="elements2bTested"> <imvert:attributesAndAssociations> <xsl:for-each 
					select=".//imvert:attribute"> <imvert:attribute> <xsl:sequence select="imf:create-output-element('imvert:name', 
					imvert:name)"/> </imvert:attribute> </xsl:for-each> <xsl:for-each select=".//imvert:association"> 
					<imvert:association> <xsl:sequence select="imf:create-output-element('imvert:name', 
					imvert:name)"/> </imvert:association> </xsl:for-each> </imvert:attributesAndAssociations> 
					</xsl:with-param> <xsl:with-param name="parent" select="imvert:name"/> </xsl:call-template> 
					</xsl:if -->
				<!--xsl:choose> <xsl:when test="imvert:name='Stuurgegevens'"> <xsl:for-each 
					select=".//imvert:attribute"> <xsl:variable name="isElementAllowed" select="imf:isElementAllowed($berichtCode, 
					imvert:name)"/> <xsl:if test="$isElementAllowed = 'no'"> <xsl:message select="concat('WARN 
					', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), 
					'+'), ' : Within messagetype ', $berichtCode, ' element ', imvert:name, ' 
					is not allowed within stuurgegevens.')"/> </xsl:if> </xsl:for-each> <xsl:for-each 
					select=".//imvert:association"> <xsl:variable name="isElementAllowed" select="imf:isElementAllowed($berichtCode, 
					imvert:name)"/> <xsl:if test="$isElementAllowed = 'no'"> <xsl:message select="concat('WARN 
					', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), 
					'+'), ' : Within messagetype ', $berichtCode, ' element ', imvert:name, ' 
					is not allowed within stuurgegevens.')"/> </xsl:if> </xsl:for-each> <xsl:variable 
					name="availableStuurgegevens"> <imvert:attributesAndAssociations> <xsl:for-each 
					select=".//imvert:attribute"> <imvert:attribute> <xsl:sequence select="imf:create-output-element('imvert:name', 
					imvert:name)"/> </imvert:attribute> </xsl:for-each> <xsl:for-each select=".//imvert:association"> 
					<imvert:association> <xsl:sequence select="imf:create-output-element('imvert:name', 
					imvert:name)"/> </imvert:association> </xsl:for-each> </imvert:attributesAndAssociations> 
					</xsl:variable> <xsl:for-each select="$enriched-endproduct-base-config-excel//sheet 
					[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data 
					= $berichtCode]/col[@number > 2 and @number &lt; 11 and data != '-']"> <xsl:if 
					test="count($availableStuurgegevens//imvert:name = @name) = 0"> <xsl:message 
					select="concat('WARN ', substring-before(string(current-date()), '+'), ' 
					', substring-before(string(current-time()), '+'), ' : Within messagetype 
					', $berichtCode, ' element ', @name, ' must be available within stuurgegevens.')"/> 
					</xsl:if> </xsl:for-each> </xsl:when> <xsl:when test="imvert:name='Parameters'"> 
					<xsl:for-each select=".//imvert:attribute"> <xsl:variable name="isElementAllowed" 
					select="imf:isElementAllowed($berichtCode, imvert:name)"/> <xsl:if test="$isElementAllowed 
					= 'no'"> <xsl:message select="concat('WARN ', substring-before(string(current-date()), 
					'+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype 
					', $berichtCode, ' element ', imvert:name, ' is not allowed within parameters.')"/> 
					</xsl:if> </xsl:for-each> <xsl:for-each select=".//imvert:association"> <xsl:variable 
					name="isElementAllowed" select="imf:isElementAllowed($berichtCode, imvert:name)"/> 
					<xsl:if test="$isElementAllowed = 'no'"> <xsl:message select="concat('WARN 
					', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), 
					'+'), ' : Within messagetype ', $berichtCode, ' element ', imvert:name, ' 
					is not allowed within parameters.')"/> </xsl:if> </xsl:for-each> <xsl:variable 
					name="availableParameters"> <imvert:attributesAndAssociations> <xsl:for-each 
					select=".//imvert:attribute"> <imvert:attribute> <xsl:sequence select="imf:create-output-element('imvert:name', 
					imvert:name)"/> </imvert:attribute> </xsl:for-each> <xsl:for-each select=".//imvert:association"> 
					<imvert:association> <xsl:sequence select="imf:create-output-element('imvert:name', 
					imvert:name)"/> </imvert:association> </xsl:for-each> </imvert:attributesAndAssociations> 
					</xsl:variable> <xsl:for-each select="$enriched-endproduct-base-config-excel//sheet 
					[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data 
					= $berichtCode]/col[@number > 11 and data != '-']"> <xsl:if test="count($availableParameters//imvert:name 
					= @name) = 0"> <xsl:message select="concat('WARN ', substring-before(string(current-date()), 
					'+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype 
					', $berichtCode, ' element ', @name, ' must be available within parameters.')"/> 
					</xsl:if> </xsl:for-each> </xsl:when> </xsl:choose -->
				<xsl:apply-templates select="imvert:supertype"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
						<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 
							'GEGEVENSGEGEVENSGROEP COMPOSITIE' wordt gebruikt ipv 'GEGEVENSGROEP COMPOSITIE'. 
							De uitbecommentarieerde apply-templates kan met de eerste vorm omgaan maar 
							moet tzt (zodra imvertor daarop checkt) worden verwijdert. -->
						<xsl:apply-templates
							select=".//imvert:association[imvert:stereotype='GEGEVENSGROEP COMPOSITIE']"
							mode="create-message-content">
							<!--xsl:apply-templates select=".//imvert:association[contains(imvert:stereotype,'GEGEVENSGROEP 
								COMPOSITIE')]" mode="create-message-content" -->
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail">
								<xsl:choose>
									<xsl:when test="contains($id-trail, concat('#1#', imvert:id, '#'))">
										<xsl:value-of select="concat('#2#', imvert:id, '#', $id-trail)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('#1#', imvert:id, '#', $id-trail)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<!-- Indien we besluiten recursie voor mag gaan komen dan moet dit 
							nog worden gecodeerd. -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- The following when initiate the processing of the associations belonging 
				to the current class. First the ones found within the superclass of the current 
				class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsRelatie'">
				<xsl:apply-templates select="imvert:supertype"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
						<xsl:apply-templates
							select=".//imvert:association[imvert:stereotype='RELATIE']" mode="create-message-content">
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail">
								<xsl:choose>
									<xsl:when test="contains($id-trail, concat('#1#', imvert:id, '#'))">
										<xsl:value-of select="concat('#2#', imvert:id, '#', $id-trail)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="concat('#1#', imvert:id, '#', $id-trail)" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<!-- Indien we besluiten recursie voor mag gaan komen dan moet dit 
							nog worden gecodeerd. -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- This template simply replicates elements. May be replaced later. -->
	<xsl:template match="*" mode="replicate-imvert-elements">
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:element name="{concat('ep:',local-name())}">
			<xsl:choose>
				<xsl:when test="*">
					<xsl:apply-templates select="*"
						mode="replicate-imvert-elements">
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- ROME: Checken of alle takken van dit template wel worden gebruikt. -->
	<!-- This template creates the constructs on datatype level. -->
	<xsl:template match="imvert:class" mode="create-datatype-content">
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:choose>
			<!-- The first when tackles the situation in which the datatype of an 
				attribute isn't a simpleType but a complexType. An attribute refers in that 
				case to an objectType (probably now an entitytype). This situation occurs 
				for example if within a union is refered to an entity withinn a ´Model´ package. -->
			<!-- ROME: Dit template moet wellicht later aangepast of verwijderd worden 
				afhankelijk van of unions gebruikt blijven worden of de wijze waarop we die 
				gebruiken. -->
			<xsl:when test="imvert:stereotype = 'ENTITEITTYPE'">
				<ep:seq>
					<xsl:apply-templates select="imvert:supertype"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'" />
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
					<xsl:apply-templates select=".//imvert:attribute"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
					<xsl:apply-templates select="imvert:supertype"
						mode="create-message-content">
						<xsl:with-param name="proces-type"
							select="'associationsGroepCompositie'" />
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
					<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 'GEGEVENSGEGEVENSGROEP 
						COMPOSITIE' wordt gebruikt ipv 'GEGEVENSGROEP COMPOSITIE'. De uitbecommentarieerde 
						apply-templates kan met de eerste vorm omgaan maar moet tzt (zodra imvertor 
						daarop checkt) worden verwijdert. -->
					<xsl:apply-templates
						select=".//imvert:association[imvert:stereotype='GEGEVENSGROEP COMPOSITIE']"
						mode="create-message-content">
						<!--xsl:apply-templates select=".//imvert:association[contains(imvert:stereotype,'GEGEVENSGROEP 
							COMPOSITIE')]" mode="create-message-content" -->							
						<?x xsl:with-param name="id-trail"
							select="concat('#1#', imvert:id, '#', $id-trail)"/ x?>
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
					<ep:construct>
						<ep:name>StUF:tijdvakGeldigheid</ep:name>
						<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
						<ep:max-occurs>1</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>150</ep:position>
					</ep:construct>
					<ep:construct>
						<ep:name>StUF:tijdstipRegistratie</ep:name>
						<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
						<ep:max-occurs>1</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>151</ep:position>
					</ep:construct>
					<ep:construct>
						<ep:name>StUF:extraElementen</ep:name>
						<ep:tech-name>StUF:extraElementen</ep:tech-name>
						<ep:max-occurs>1</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>152</ep:position>
					</ep:construct>
					<xsl:apply-templates select="imvert:supertype"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsRelatie'" />
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
					<xsl:apply-templates
						select=".//imvert:association[imvert:stereotype='RELATIE']" mode="create-message-content">
						<?x xsl:with-param name="id-trail"
							select="concat('#1#', imvert:id, '#', $id-trail)"/ x?>
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
				</ep:seq>
			</xsl:when>
			<!-- If it's an 'Enumeration' class it's attributes, which represent the 
				enumeration values) processed. -->
			<xsl:when test="imvert:stereotype = 'ENUMERATION'">
				<xsl:apply-templates select="imvert:attributes/imvert:attribute"
					mode="create-datatype-content" />
			</xsl:when>
			<xsl:when test="imvert:stereotype = 'DATATYPE'">
				<xsl:choose>
					<!-- If the class stereotype is a Datatype and it contains 'imvert:attribute' 
						elements they are placed as constructs within a 'ep:seq' element. -->
					<xsl:when test="imvert:attributes/imvert:attribute">
						<ep:seq>
							<xsl:apply-templates select="imvert:attributes/imvert:attribute"
								mode="create-datatype-content">
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
							</xsl:apply-templates>
						</ep:seq>
					</xsl:when>
					<!-- If not an 'ep:datatype' element is generated. -->
					<xsl:otherwise>
						<ep:datatype id="{imvert:id}">
							<xsl:apply-templates select="imvert:documentation"
								mode="replicate-imvert-elements">
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
							</xsl:apply-templates>
						</ep:datatype>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- ROME: De vraag is of deze otherwise tak ooit wordt gebruikt. -->
			<xsl:otherwise>
				<xsl:comment select="'De otherwise tak wordt gebruikt.'" />
				<ep:seq>
					<xsl:apply-templates select="imvert:attributes/imvert:attribute"
						mode="create-datatype-content">
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="context" select="$context" />
					</xsl:apply-templates>
				</ep:seq>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- The following template creates the construct representing the lowest 
		level elements or the 'ep:enum' element representing one of the possible 
		values of an enumeration. -->
	<xsl:template match="imvert:attribute" mode="create-datatype-content">
		<xsl:param name="berichtCode" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-datatype-content]'" />
		</xsl:if>
		<xsl:choose>
			<xsl:when test="imvert:stereotype = 'ENUM'">
				<xsl:sequence select="imf:create-output-element('ep:enum', imvert:name)" />
			</xsl:when>
			<xsl:otherwise>
				<ep:construct>
					<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)" />
					<xsl:sequence
						select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence
						select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:if test="imvert:type-id">
						<xsl:apply-templates
							select="//imvert:class[imvert:id = current()/imvert:type-id]"
							mode="create-datatype-content" />
					</xsl:if>
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- This function checks if a parameter or stuurgegeven is allowed within 
		the current messagetype and if not if it is: * really not allowed (it can 
		not be used within the messagetype); * not applicable (the parent-type isn't 
		checked at the moment.); * or not in scope (in EA it is allowed within the 
		messagetype but it can be ignored for the berichtCode or the tagged value 
		isn't a placeholder for a parameter or stuurgegevens element and has another 
		function). -->
	<xsl:function name="imf:isElementAllowed">
		<xsl:param name="berichtCode" as="xs:string" />
		<xsl:param name="element" as="xs:string" />
		<xsl:param name="parent" as="xs:string" />
		<!-- The following variable wil contain information from a spreadsheetrow 
			which is determined using the above 3 parameters. The content of the variable 
			$enriched-endproduct-base-config-excel used within the following variable 
			is generated using the XSLT stylesheet 'Imvert2XSD-KING-enrich-excel.xsl'. -->
		<xsl:variable name="attributeTypeRow"
			select="$enriched-endproduct-base-config-excel//sheet
			[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'Berichtcode']/data = $berichtCode]" />
		<!-- Within the following choose the output of this function is detremined. -->
		<xsl:choose>
			<xsl:when
				test="$attributeTypeRow//col[@type = $parent and @name = $element and data != '-']">
				allowed
			</xsl:when>
			<xsl:when
				test="$attributeTypeRow//col[@type = $parent and @name = $element and data = '-']">
				notAllowed
			</xsl:when>
			<xsl:when test="$attributeTypeRow//col[@name = $element]">
				notApplicable
			</xsl:when>
			<xsl:otherwise>
				notInScope
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- The BSM profiel of EA already takes care of which parameters en stuurgegevens 
		are allowed on the different berichttypen. Those are configured on them as 
		tagged-values. Because these tagged-values are configured also within the 
		tv-set a message-designer can't just add tagged-values thay easy. Well, actualy 
		he or she can but they won't be processed. Within the bounds of the berichttypes 
		even more restriction apply within the berichtcodes for the parameters and 
		stuurgegevens. Unfortunately it's not possible to enforce them using the 
		tv-set. However it can be checked using the base-configuration file. This 
		function, in which this is done, generates the content of the 'parameters' 
		or 'stuurgegevens' element depending on the value of the 'parent' variable. -->
	<!-- ROME: The stuurgegeven 'Entiteittype' komt nu nog niet voor in het 
		BSM profiel aangezien het idee was dat deze toch overal verplicht was. Dit 
		moet n.m.m. echter toch toegevoegd worden. Er zullen ook tagged-values worden 
		toegevoegd waarmee we de standaard waarde van een parameter of stuurgegeven 
		vanuit EA kunnen sturen. Dit zal nog in de onderstaande code moeten worden 
		geimplementeerd. -->
	<xsl:template name="buildParametersAndStuurgegevens">
		<xsl:param name="berichtCode" as="xs:string" />
		<xsl:param name="elements2bTested" as="document-node()" />
		<xsl:param name="parent" as="xs:string" />
		<!-- This for-each checks if for all required parameters of stuurgegevens 
			a tagged-value has been provided within the EA file. If not it generates 
			an error message. -->
		<xsl:for-each
			select="$enriched-endproduct-base-config-excel//sheet[name = 'Berichtgerelateerde gegevens']/
																		row[col[@name = 'Berichtcode']/data = $berichtCode]/
																		col[@type = $parent and data = 'V']">
			<xsl:variable name="normalizedElementName" select="@name" />
			<xsl:choose>
				<xsl:when
					test="$elements2bTested//imvert:tv[imvert:name = $normalizedElementName]" />
				<xsl:otherwise>
					<xsl:message
						select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Element ', $normalizedElementName, ' is not available within the ', $parent, ' of the compiled message of messagetype ', $berichtCode, ' but is required.')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<!-- This for-each checks each tagged value provided within the berichttype 
			object within the EA file. -->
		<xsl:for-each select="$elements2bTested//imvert:tv">
			<xsl:variable name="normalizedElementName" select="imvert:name" />
			<xsl:variable name="elementValue" select="imvert:value" />
			<!-- Following variable contains a value which determines if a tagged-value 
				is allowed within the current messagetype and if not in what way. -->
			<xsl:variable name="isElementAllowed"
				select="imf:isElementAllowed($berichtCode, $normalizedElementName, $parent)" />
			<!-- Within this choose the correct action is determined and performed 
				depending on the value of the 'elementValue' and 'isElementAllowed' variable: 
				* 1st when If the parameter or stuurgegevens isn't desired (value = 'N.v.t.) 
				and this is allowed according to the base-configuration no action is taken; 
				* 2nd when If the parameter or stuurgegevens isn't desired (value = 'N.v.t.) 
				but this isn't allowed according to the base-configuration an Error message 
				is sent; * 3th when If the element is allowed and provided an ep:construct 
				element with all its content will be generated; * 4th when If the element 
				isn't allowed and it hasn't been disabled (value = 'N.v.t/) or not set to 
				comply to the standard configuration an Error message is sent. If it isn't 
				allowed but has been disabled or set set to comply to the standard configuration 
				no action is taken; * 5th when if the element is not applicable or not in 
				scope no action is taken. -->
			<xsl:choose>
				<xsl:when
					test="$elementValue = 'N.v.t.' and $enriched-endproduct-base-config-excel//sheet
					[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'Berichtcode']/data = $berichtCode]/col[@name = $normalizedElementName and @type = $parent and data != 'V']" />
				<xsl:when
					test="$elementValue = 'N.v.t.' and $enriched-endproduct-base-config-excel//sheet
					[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'Berichtcode']/data = $berichtCode]/col[@name = $normalizedElementName and @type = $parent and data = 'V']">
					<xsl:message
						select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Element ', $normalizedElementName, ' has been disabled but must be available within the ', $parent, ' of messagetype ', $berichtCode, '.')" />
				</xsl:when>
				<xsl:when test="$isElementAllowed = 'allowed'">
					<xsl:for-each
						select="$enriched-endproduct-base-config-excel//sheet
						[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'Berichtcode']/data = $berichtCode]/col[@name = $normalizedElementName and @type = $parent and data != '-']">
						<xsl:variable name="colName" select="@name" />
						<ep:construct>
							<ep:name>
								<xsl:value-of select="$normalizedElementName" />
							</ep:name>
							<ep:tech-name>
								<!-- The normalized name most of the time isn't desired. The name 
									to be placed within the 'ep:tech-name' element is derived from the schemarules 
									file. -->
								<xsl:value-of
									select="$config-schemarules//tv[name = $normalizedElementName]/schema-name" />
							</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>
								<!-- If a parameter or stuurgegeven is required is determined using 
									the base-configuration ('data' element) and value of the \ tagged-value being 
									processed. The 'Berichtcode' element is allways required. -->
								<xsl:choose>
									<xsl:when test="@name = 'Berichtcode'">
										1
									</xsl:when>
									<xsl:when test="data = 'V' or $elementValue = 'Verplicht'">
										1
									</xsl:when>
									<xsl:when test="data = 'O'">
										0
									</xsl:when>
								</xsl:choose>
							</ep:min-occurs>
							<xsl:choose>
								<xsl:when
									test="$config-schemarules//tv[name = $normalizedElementName]/schema-type">
									<ep:type-name>
										<xsl:value-of
											select="$config-schemarules//tv[name = $normalizedElementName]/schema-type" />
									</ep:type-name>
								</xsl:when>
								<xsl:when
									test="$config-schemarules//tv[name = $normalizedElementName]/external-schema-type">
									<ep:external-type-name>
										<xsl:value-of
											select="$config-schemarules//tv[name = $normalizedElementName]/external-schema-type" />
									</ep:external-type-name>
								</xsl:when>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="$normalizedElementName = 'Berichtcode'">
									<ep:enum>
										<xsl:value-of select="$berichtCode" />
									</ep:enum>
								</xsl:when>
								<!-- ROME: otherwise te vullen zodra meer tagged-values een fixed 
									waarde kunnen hebben. Het stuurgegeven 'entiteittype' moet overigens altijd 
									alleen de waarde van de fundamentele entiteit krijgen. -->
								<xsl:otherwise />
							</xsl:choose>
						</ep:construct>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="$isElementAllowed = 'notAllowed'">
					<xsl:choose>
						<xsl:when
							test="$elementValue = 'N.v.t.' or $elementValue = 'Conform standaard'" />
						<xsl:otherwise>
							<xsl:message
								select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', $normalizedElementName, ' is not allowed within the ', $parent, '.')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when
					test="$isElementAllowed = 'notApplicable' or $isElementAllowed = 'notInScope'" />
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- The function imf:createAttributes is used to determine the XML attributes 
		neccessary for a certain context. It has the following parameters: - typecode 
		- berichttype - context - datumType The first 3 parameters relate to columns 
		with the same name within an Excel spreadsheet used to configure a.o. XML 
		attributes usage. The last parameter is used to determine the need for the 
		XML-attribute 'StUF:indOnvolledigeDatum'. -->
	<xsl:function name="imf:createAttributes">
		<xsl:param name="typeCode" as="xs:string" />
		<xsl:param name="berichtType" as="xs:string" />
		<xsl:param name="context" as="xs:string" />
		<xsl:param name="datumType" as="xs:string" />
		<xsl:param name="mnemonic" as="xs:string" />
		<xsl:param name="MogelijkGeenWaarde" as="xs:string" />
		<!-- The following variable wil contain information from a spreadsheetrow 
			which is determined using the first 3 parameters. The variable $enriched-endproduct-base-config-excel 
			used within the following variable is generated using the XSLT stylesheet 
			'Imvert2XSD-KING-enrich-excel.xsl'. -->
		<xsl:variable name="attributeTypeRow"
			select="$enriched-endproduct-base-config-excel//sheet
													  [name = 'XML attributes']/row[col[@name = 'typecode']/data = $typeCode and 
																			  	          col[@name = 'berichttype']/data = $berichtType and 
																				          col[@name = 'context']/data = $context]" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:message>
				attributeTypeRow:
				<xsl:value-of select="$attributeTypeRow/@number" />
				(
				<xsl:value-of select="$typeCode" />
				,
				<xsl:value-of select="$berichtType" />
				,
				<xsl:value-of select="$context" />
				,
				<xsl:value-of select="$datumType" />
				)
			</xsl:message>
		</xsl:if>
		<!-- The following if statements checks if a specific column in the spreadsheetrow 
			in the 'attributeTypeRow' variable contains an 'O' or an 'V'. If this is 
			the case the related XML-Attribute is generated (required if the 'attributeTypeRow' 
			variable contains an 'V' and optional if the variable contains an 'O'). Since 
			these are all XML-Attributes which are defined within de so-called 'StUF-onderlaag' 
			(they all have the prefix 'StUF') we only have to generate the name and occurence. 
			For attributes generated in other namespaces which must be used within the 
			koppelvlak namespace counts the same. XML-attributes to be defined within 
			the koppelvlak namespace will need a type-name, enum or other format defining 
			element. -->
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:noValue' and data = 'O' and $MogelijkGeenWaarde = 'yes']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:noValue</ep:name>
				<ep:tech-name>StUF:noValue</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:noValue' and data = 'V' and $MogelijkGeenWaarde = 'yes']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:noValue</ep:name>
				<ep:tech-name>StUF:noValue</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:exact' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:exact</ep:name>
				<ep:tech-name>StUF:exact</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:exact' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:exact</ep:name>
				<ep:tech-name>StUF:exact</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:metagegeven' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:metagegeven</ep:name>
				<ep:tech-name>StUF:metagegeven</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:metagegeven' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:metagegeven</ep:name>
				<ep:tech-name>StUF:metagegeven</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<!-- ROME: De vraag is of ik het gebruik van het XML attribute 'StUF:indOnvolledigeDatum' 
			wel in het spreadsheet moet configureren. Moeten niet gewoon alle elementen 
			van het datumType dit XML attribute krijgen? -->
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:indOnvolledigeDatum' and data = 'O'] and $datumType = 'yes'">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:indOnvolledigeDatum</ep:name>
				<ep:tech-name>StUF:indOnvolledigeDatum</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:indOnvolledigeDatum' and data = 'V'] and $datumType = 'yes'">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:indOnvolledigeDatum</ep:name>
				<ep:tech-name>StUF:indOnvolledigeDatum</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<!-- ROME: De waarde van het attribute 'StUF:entiteittype' moet m.b.v. 
			een enum constuctie worden gedefinieerd. Die waarde zal aan de functie meegegeven 
			moeten worden. Deze waarde zou uit het 'imvert:alias' element moeten komen. 
			Dat is echter niet altijd aanwezig. -->
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:entiteittype' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace 
					van het koppelvlak. Later zal ik echter een restriction moeten definieren 
					in de namespace van de StUF onderlaag. -->
				<ep:name>StUF:entiteittype</ep:name>
				<!--ep:tech-name>StUF:entiteittype</ep:tech-name -->
				<ep:tech-name>entiteittype</ep:tech-name>
				<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een 
					warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:if test="$mnemonic!=''">
					<xsl:sequence select="imf:create-output-element('ep:type-name', 'char')" />
					<xsl:sequence select="imf:create-output-element('ep:enum', $mnemonic)" />
				</xsl:if>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:entiteittype' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace 
					van het koppelvlak. Later zal ik echter een restriction moeten definieren 
					in de namespace van de StUF onderlaag. -->
				<ep:name>StUF:entiteittype</ep:name>
				<!--ep:tech-name>StUF:entiteittype</ep:tech-name -->
				<ep:tech-name>entiteittype</ep:tech-name>
				<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een 
					warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:if test="$mnemonic!=''">
					<xsl:sequence select="imf:create-output-element('ep:type-name', 'char')" />
					<xsl:sequence select="imf:create-output-element('ep:enum', $mnemonic)" />
				</xsl:if>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelVerzendend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelVerzendend</ep:name>
				<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelVerzendend' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelVerzendend</ep:name>
				<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelOntvangend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelOntvangend</ep:name>
				<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelOntvangend' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelOntvangend</ep:name>
				<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelGegevensbeheer' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelGegevensbeheer</ep:name>
				<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelGegevensbeheer' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelGegevensbeheer</ep:name>
				<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelSynchronisatie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelSynchronisatie</ep:name>
				<ep:tech-name>StUF:sleutelSynchronisatie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:sleutelSynchronisatie' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelSynchronisatie</ep:name>
				<ep:tech-name>StUF:sleutelSynchronisatie</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:scope' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:scope</ep:name>
				<ep:tech-name>StUF:scope</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:scope' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:scope</ep:name>
				<ep:tech-name>StUF:scope</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:verwerkingssoort' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:verwerkingssoort</ep:name>
				<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:verwerkingssoort' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:verwerkingssoort</ep:name>
				<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:functie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:functie</ep:name>
				<ep:tech-name>StUF:functie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:functie' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:functie</ep:name>
				<ep:tech-name>StUF:functie</ep:tech-name>
			</ep:construct>
		</xsl:if>
	</xsl:function>

	<xsl:function name="imf:determineBerichtCode">
		<xsl:param name="Stereotype" as="xs:string" />
		<xsl:param name="Inkomend" as="xs:string" />
		<xsl:param name="AanduidingActualiteit" as="xs:string" />
		<xsl:param name="Synchroon" as="xs:string" />
		<xsl:param name="AanduidingToekomstmutaties" as="xs:string" />
		<xsl:param name="Samengesteld" as="xs:string" />
		<xsl:choose>
			<xsl:when test="$Stereotype='VRIJBERICHTTYPE'">
				<xsl:choose>
					<xsl:when test="$Inkomend = 'Ja' and $Synchroon = 'Ja'">
						Di01
					</xsl:when>
					<xsl:when test="$Inkomend = 'Ja' and $Synchroon = 'Nee'">
						Di02
					</xsl:when>
					<xsl:when test="$Inkomend = 'Nee' and $Synchroon = 'Ja'">
						Di03
					</xsl:when>
					<xsl:when test="$Inkomend = 'Nee' and $Synchroon = 'Nee'">
						Di04
					</xsl:when>
					<xsl:otherwise>
						Niet te bepalen
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$Stereotype='VRAAGBERICHTTYPE'">
				<xsl:choose>
					<xsl:when
						test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Ja'">
						Lv01
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Nee'">
						Lv02
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Ja'">
						Lv03
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Nee'">
						Lv04
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Ja'">
						Lv05
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Nee'">
						Lv06
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Ja'">
						Lv07
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Nee'">
						Lv08
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Ja'">
						Lv09
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Nee'">
						Lv10
					</xsl:when>
					<xsl:otherwise>
						Niet te bepalen
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$Stereotype='ANTWOORDBERICHTTYPE'">
				<xsl:choose>
					<xsl:when
						test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Ja'">
						La01
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Nee'">
						La02
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Ja'">
						La03
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Nee'">
						La04
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Ja'">
						La05
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Nee'">
						La06
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Ja'">
						La07
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Nee'">
						La08
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Ja'">
						La09
					</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Nee'">
						La10
					</xsl:when>
					<xsl:otherwise>
						Niet te bepalen
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$Stereotype='KENNISGEVINGSBERICHTTYPE'">
				<xsl:choose>
					<xsl:when
						test="$Synchroon = 'Ja' and $AanduidingToekomstmutaties = 'Zonder toekomstmutaties' and $Samengesteld = 'Nee'">
						Lk01
					</xsl:when>
					<xsl:when
						test="$Synchroon = 'Nee' and $AanduidingToekomstmutaties = 'Zonder toekomstmutaties' and $Samengesteld = 'Nee'">
						Lk02
					</xsl:when>
					<xsl:when test="$Synchroon = 'Ja' and $Samengesteld = 'Ja'">
						Lk03
					</xsl:when>
					<xsl:when test="$Synchroon = 'Nee' and $Samengesteld = 'Ja'">
						Lk04
					</xsl:when>
					<xsl:when
						test="$Synchroon = 'Ja' and $AanduidingToekomstmutaties = 'Met toekomstmutaties' and $Samengesteld = 'Nee'">
						Lk05
					</xsl:when>
					<xsl:when
						test="$Synchroon = 'Nee' and $AanduidingToekomstmutaties = 'Met toekomstmutaties' and $Samengesteld = 'Nee'">
						Lk06
					</xsl:when>
					<xsl:otherwise>
						Niet te bepalen
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- ROME: Voor de onderstaande situaties moet deze functie nog aangevuld 
				worden. -->
			<?x xsl:when test="contains($name,'Sa01')">Sa01</xsl:when>
			<xsl:when test="contains($name,'Sa02')">Sa02</xsl:when>
			<xsl:when test="contains($name,'Sa03')">Sa03</xsl:when>
			<xsl:when test="contains($name,'Sa04')">Sa04</xsl:when>
			<xsl:when test="contains($name,'Sh01')">Sh01</xsl:when>
			<xsl:when test="contains($name,'Sh02')">Sh02</xsl:when>
			<xsl:when test="contains($name,'Sh03')">Sh03</xsl:when>
			<xsl:when test="contains($name,'Sh04')">Sh04</xsl:when x?>
		</xsl:choose>

	</xsl:function>

</xsl:stylesheet>
