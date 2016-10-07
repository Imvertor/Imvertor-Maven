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

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-structure</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-structure.xsl 1 2015-11-11 11:50:00Z RobertMelskens $</xsl:variable>

	<!-- ======= Block of templates used to create the message structure. ======= -->	
	
	<!-- This template is used to start generating the ep structure for an individual message. -->
	
	<xsl:template match="/imvert:packages/imvert:package[not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-rough-message-structure"> 
		<!-- this is an embedded message schema within the koppelvlak -->
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template 1: imvert:package[mode=create-rough-message-structure]'" />
		</xsl:if>
		<xsl:for-each select="imvert:class[imvert:stereotype = 'VRAAGBERICHTTYPE' or imvert:stereotype = 'ANTWOORDBERICHTTYPE' or imvert:stereotype = 'KENNISGEVINGBERICHTTYPE' or imvert:stereotype = 'VRIJBERICHTTYPE']">			
			<xsl:variable name="berichtType">
				<xsl:choose>
					<xsl:when test="imvert:stereotype = 'VRAAGBERICHTTYPE'">Vraagbericht</xsl:when>
					<xsl:when test="imvert:stereotype = 'ANTWOORDBERICHTTYPE'">Antwoordbericht</xsl:when>
					<xsl:when test="imvert:stereotype = 'KENNISGEVINGBERICHTTYPE'">kennisgevingbericht</xsl:when>
					<xsl:when test="imvert:stereotype = 'VRIJBERICHTTYPE'">Vrij bericht</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="berichtstereotype">
				<xsl:value-of select="imvert:stereotype" />
			</xsl:variable>
			<xsl:variable name="berichtCode">
				<xsl:value-of
					select="imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode']/imvert:value" />
			</xsl:variable>
			<xsl:if test="$berichtCode = ''">
				<xsl:message
					select="concat('ERROR ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The berichtcode can not be determined. To be able to generate correct messages this is neccessary. Check your model for missing tagged values. (',$berichtstereotype)" />
			</xsl:if>
			<!-- create the message -->
			<ep:rough-message>
				<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)" />
				<xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)" />
				<!-- Start of the message is always a class with an imvert:stereotype 
					with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' 
					or 'KENNISGEVINGBERICHTTYPE'. Since the toplevel structure of a message 
					complies to different rules in comparison with the entiteiten structure this 
					template is initialized within the 'create-initial-message-structure' mode. -->
				<xsl:apply-templates
					select=".[imvert:stereotype = imf:get-config-stereotypes((
					'stereotype-name-vraagberichttype',
					'stereotype-name-antwoordberichttype',
					'stereotype-name-vrijberichttype',
					'stereotype-name-kennisgevingberichttype'))]"
					mode="create-toplevel-rough-message-structure">
					<xsl:with-param name="package-id" select="../imvert:id"/>
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="useStuurgegevens" select="'yes'" />
				</xsl:apply-templates>
			</ep:rough-message>
		</xsl:for-each>
	</xsl:template>
	
	<!-- This template (1) only processes imvert:class elements with an imvert:stereotype 
		with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' 
		or 'KENNISGEVINGBERICHTTYPE'. Those classes contain a relation to the 'Parameters' 
		group (if not removed), a relation to a class with an imvert:stereotype with 
		the value 'ENTITEITTYPE' or, in case of a ''VRIJBERICHTTYPE', a relation 
		with one or more classes with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
		'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE'. These 
		classes also have a supertype with an imvert:stereotype with the value 'BERICHTTYPE' 
		which contain a 'melding' attribuut and have a relation to the 'Stuurgegevens' 
		group. This supertype is also processed here. -->
	<xsl:template match="imvert:class" mode="create-toplevel-rough-message-structure">
		<xsl:param name="package-id"/>
		<xsl:param name="messagePrefix" select="''" />
		<xsl:param name="berichtCode" />
		
		<!-- The purpose of this parameter is to determine if the element 'stuurgegevens' 
			must be generated or not. This is important because the 'kennisgevingbericht' , 
			'vraagbericht' or 'antwoordbericht' objects within the context of a 'vrijbericht' 
			object aren't allowed to contain 'stuurgegevens'. -->
		<xsl:param name="useStuurgegevens" select="'yes'" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template 2: imvert:class[mode=create-toplevel-rough-message-structure]'" />
		</xsl:if>
		<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:association' 
				elements with the stereotype 'GROEP COMPOSITIE' within the supertype 
				of imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
				'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE' and 
				those within the current class. The first one generates the 'stuurgegevens' 
				element, the second one the 'parameters' element. 
				The empty value for the variable 'context' guarantee's not xml attributes are 
				generated with the attributen.-->
			<xsl:apply-templates select="imvert:supertype"
				mode="create-rough-message-content">
				<xsl:with-param name="package-id" select="$package-id"/>
				<xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
				<xsl:with-param name="berichtCode" select="$berichtCode" />
				<xsl:with-param name="context" select="''" />
			</xsl:apply-templates>
			<xsl:apply-templates
				select=".//imvert:association[imvert:stereotype='GROEP COMPOSITIE']"
				mode="create-rough-message-content">
				<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so the related object has already been processed) processing 
					stops. -->
				
				<xsl:with-param name="package-id" select="$package-id"/>
				<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
					wel noodzakelijk is. -->
				<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')" />
				<xsl:with-param name="berichtCode" select="$berichtCode" />
				<xsl:with-param name="context" select="''" />
			</xsl:apply-templates>
			
			<!-- At this level an association with a class having the stereotype 'ENTITEITTYPE' 
				always has the stereotype 'ENTITEITRELATIE'. The following apply-templates 
				initiates the processing of such an association.
				The supertype of the current class will never contain an association with a stereotype 
				of 'ENTITEITRELATIE'. For that reason no apply-templates on the supertype in this context 
				is implemented. -->
			<xsl:choose>
				<xsl:when test="not(contains($berichtCode, 'Di')) and not(contains($berichtCode, 'Du'))">
					<xsl:apply-templates
						select=".//imvert:association[imvert:stereotype='ENTITEITRELATIE']" 
						mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so the related object has already been processed) processing 
					stops. -->
						
						<xsl:with-param name="package-id" select="$package-id"/>
						<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
					wel noodzakelijk is. -->
						<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')" />
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="orderingDesired" select="'no'" />
					</xsl:apply-templates>				
				</xsl:when>
				<xsl:otherwise>
						<!-- Associations linking from a class with a imvert:stereotype with the 
					value 'VRIJBERICHTTYPE' need special treatment. E.g. the construct to be created must 
					contain a meta-data construct called 'functie'. For that reason those linking to a class 
					with a imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE' 
					or 'KENNISGEVINGBERICHTTYPE' and those linking to a class with a imvert:stereotype 
					with the value 'ENTITEITRELATIE' must also be processed as from toplevel-message 
					type. -->
					<xsl:apply-templates
						select=".//imvert:association"
						mode="create-toplevel-rough-message-structure">
						<xsl:with-param name="package-id" select="$package-id"/>
						<xsl:with-param name="berichtCode" select="$berichtCode" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>
	
	<!-- This template (2) takes care of processing superclasses of the class being 
		processed. -->
	<xsl:template match="imvert:supertype" mode="create-rough-message-content">
		<xsl:param name="package-id"/>
		<xsl:param name="proces-type" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template 3: imvert:supertype[mode=create-rough-message-content]'" />
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
			mode="create-rough-message-content">
			<xsl:with-param name="package-id" select="$package-id"/>
			<xsl:with-param name="proces-type" select="$proces-type" />
			<xsl:with-param name="berichtCode" select="$berichtCode" />
			<xsl:with-param name="context" select="$context" />
		</xsl:apply-templates>
	</xsl:template>

	<!-- Declaration of the content of a superclass, an 'imvert:association' and 'imvert:association-class' 
		finaly always takes place within an 'imvert:class' element. This element 
		is processed within this template (3). -->
	<xsl:template match="imvert:class" mode="create-rough-message-content">
		<xsl:param name="package-id"/>
		<xsl:param name="proces-type" select="''" />
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template 4: imvert:class[mode=create-rough-message-content]'" />
		</xsl:if>
		<xsl:choose>
			<!-- The following when initiates the processing of the attributegroups 
				belonging to the current class. First the ones found within the superclass 
				of the current class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'attributes'">

			</xsl:when>
			<!-- The following when initiates the processing of the attributegroups 
				belonging to the current class. First the ones found within the superclass 
				of the current class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsGroepCompositie'">
				<!-- If the class is about the 'stuurgegevens' or 'parameters' one of 
					the following when's is activated to check if all children of the stuurgegevens 
					are allowed within the current berichttype. If not a warning is generated. -->
				<xsl:apply-templates select="imvert:supertype"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type" select="$proces-type" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
						<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 
							'GEGEVENSGROEP COMPOSITIE' wordt gebruikt ipv 'GROEP COMPOSITIE'. 
							De uitbecommentarieerde apply-templates kan met de eerste vorm omgaan maar 
							moet tzt (zodra imvertor daarop checkt) worden verwijdert. -->
						<xsl:apply-templates
							select=".//imvert:association[imvert:stereotype='GROEP COMPOSITIE']"
							mode="create-rough-message-content">
							<!--xsl:apply-templates select=".//imvert:association[contains(imvert:stereotype,'GEGEVENSGROEP 
								COMPOSITIE')]" mode="create-message-content" -->
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="package-id" select="$package-id"/>
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
				</xsl:choose>
			</xsl:when>
			<!-- The following when initiates the processing of the associations belonging 
				to the current class. First the ones found within the superclass of the current 
				class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsRelatie'">
				<xsl:apply-templates select="imvert:supertype"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type" select="$proces-type" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
						<xsl:apply-templates
							select=".//imvert:association[imvert:stereotype='RELATIE']" mode="create-rough-message-content">
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="package-id" select="$package-id"/>
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
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- This template (4) transforms an 'imvert:association' element to an 'ep:construct' 
		 element. -->
	<xsl:template match="imvert:association" mode="create-rough-message-content">
		<xsl:param name="package-id"/>
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="orderingDesired" select="'yes'" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:variable name="MogelijkGeenWaarde">
			<xsl:choose>
				<xsl:when
					test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'MogelijkGeenWaarde'">yes</xsl:when>
				<xsl:otherwise>no</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template 5: imvert:association[mode=create-rough-message-content]'" />
		</xsl:if>
		<ep:construct context="{$context}" typeCode="relatie">
			<xsl:attribute name="type">
				<xsl:choose>
					<xsl:when test="imvert:stereotype = 'GROEP COMPOSITIE'">groupType</xsl:when>
					<xsl:otherwise>relationType</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="imvert:stereotype != 'GROEP COMPOSITIE'">
					<xsl:if test="count(//imvert:class[imvert:id = $type-id]//imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'Ja' or imvert:value = 'Ja, zie regels')]) >= 1">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'" />
					</xsl:if>
					<xsl:if test="count(//imvert:class[imvert:id = $type-id]//imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'Ja']) >= 1">
						<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'" />
					</xsl:if>				
				</xsl:when>
				<xsl:otherwise>
					
					<xsl:variable name="tvs-class">
						<ep:tagged-values>
							<xsl:copy-of select="imf:get-compiled-tagged-values($packages//imvert:class[imvert:id = $type-id], true())"/>
						</ep:tagged-values>
					</xsl:variable>
					<xsl:variable name="tvs-attributes">
						<xsl:for-each select="$packages//imvert:class[imvert:id = $type-id]//imvert:attribute">
							<ep:tagged-values>
								<xsl:copy-of select="imf:get-compiled-tagged-values(., true())"/>
							</ep:tagged-values>
						</xsl:for-each>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="contains(imf:get-most-relevant-compiled-taggedvalue($tvs-class, 'Indicatie materiële historie'),'Ja')">
							<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="tv-materieleHistorie-attributes">
								<xsl:for-each select="$tvs-attributes/ep:tagged-values">
									<ep:tagged-value><xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie materiële historie')"/></ep:tagged-value>
								</xsl:for-each>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$tv-materieleHistorie-attributes//ep:tagged-value = 'Ja'">
									<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja op attributes'" />
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="contains(imf:get-most-relevant-compiled-taggedvalue($tvs-class, 'Indicatie formele historie'),'Ja')">
							<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="tv-formeleHistorie-attributes">
								<xsl:for-each select="$tvs-attributes/ep:tagged-values">
									<ep:tagged-value><xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie formele historie')"/></ep:tagged-value>
								</xsl:for-each>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="$tv-formeleHistorie-attributes//ep:tagged-value = 'Ja'">
									<xsl:attribute name="indicatieFormeleHistorie" select="'Ja op attributes'" />
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence
				select="imf:create-output-element('ep:name', imvert:name/@original)" />
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name,'element-name'))" />
			<!-- De volgende elementen moeten alleengevuld worden als de relatie gekoppeld is aan een association-class. 
				 De realtie heeft dan zelf attributen waarop historie van toepassing kan zijn. -->
			<xsl:choose>
				<!-- In het geval van een associationgroup wordt er geen 'gerelateerde' elementen tussen gegenereerd en mag het id en type-id gewoon op het huidige element worden gegenereerd. -->
				<xsl:when test="imvert:stereotype!='RELATIE'">
					<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)" />
					<xsl:sequence select="imf:create-output-element('ep:type-id', imvert:type-id)" />
				</xsl:when>
			</xsl:choose>
			<!-- The following choose processes the 3 situations an association can 
			represent. -->
				<xsl:call-template name="createSimpleRelatiePartOfAssociation">
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="id" select="imvert:id"/>
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:call-template>
				<!-- Only in case of an association representing a 'relatie' and containing 
			a 'gerelateerde' construct (within the above choose the first 'when' XML 
			Attributes for the 'relatie' type element have to be generated. Because these 
			has to be placed outside the 'gerelateerde' element it has to be done here. -->
		</ep:construct>
	</xsl:template>
	
	<!-- This template (5) takes care of associations from a 'vrijbericht' type 
		to the other message types 'vraagbericht', 'antwoordbericht' and 'kennisgevingbericht'. -->
	<!-- ROME: De werking van dit template moet nog gecheckt worden zodra er 
		vrije berichten zijn. Waarschijnlijk moet er nog iets gebeuren met de context.
		Ook moet er nog voor gezorgd worden dat het 'functie' xml attribute gegenereerd wordt.-->
	<xsl:template match="imvert:association" mode="create-toplevel-rough-message-structure">
		<xsl:param name="package-id"/>
		<xsl:param name="berichtCode" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template 6: imvert:association[mode=create-toplevel-rough-message-structure]'" />
		</xsl:if>
		<ep:construct type="'association'">
			<xsl:sequence
				select="imf:create-output-element('ep:name', imvert:name/@original)" />
			<xsl:sequence
				select="imf:create-output-element('ep:id', imvert:id)" />
			<xsl:sequence
				select="imf:create-output-element('ep:type-id', imvert:type-id)" />
			<xsl:choose>
				<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
					<!-- ROME: Volgende apply-templates moet natuurlijk het template aanschoppen 
						met als match 'imvert:association[imvert:stereotype='ENTITEITRELATIE']'en 
						als mode 'create-message-content'. -->
					<xsl:apply-templates select="."	mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						
						<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
							wel noodzakelijk is. -->
						<xsl:with-param name="package-id" select="$package-id"/>
						<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')" />
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
						'stereotype-name-kennisgevingberichttype'))]"
						mode="create-toplevel-rough-message-structure">
						<xsl:with-param name="package-id" select="$package-id"/>
						<xsl:with-param name="berichtCode" select="$berichtCode" />
						<xsl:with-param name="stuurgegevens" select="'no'" />
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</ep:construct>
	</xsl:template>
	
	<!-- This template (6) transforms an 'imvert:association' element of stereotype 'ENTITEITRELATIE' to an 'ep:construct' 
		element.. -->
	<xsl:template match="imvert:association[imvert:stereotype='ENTITEITRELATIE']" mode="create-rough-message-content">
		<xsl:param name="package-id"/>
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="orderingDesired" select="'yes'" />
		<xsl:param name="historyApplies" select="'no'" />
		<xsl:variable name="context">
			<xsl:choose>
				<xsl:when
					test="imvert:name = 'gelijk' or imvert:name = 'vanaf' or imvert:name = 'totEnMet'">selectie</xsl:when>
				<xsl:when test="imvert:name = 'start'">start</xsl:when>
				<xsl:when test="imvert:name = 'scope'">scope</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template 7: imvert:association[imvert:stereotype=ENTITEITRELATIE and mode=create-rough-message-content]'" />
		</xsl:if>
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
				<ep:construct context="{$context}" type="'association'">
					<ep:name>antwoord</ep:name>
					<?x xsl:sequence
						select="imf:create-output-element('ep:id', imvert:id)" />
					<xsl:sequence
						select="imf:create-output-element('ep:type-id', imvert:type-id)" / x?>
					<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="package-id" select="$package-id"/>
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
							<xsl:with-param name="type-id" select="$type-id" />
							<xsl:with-param name="constructName" select="'-'" />
							<xsl:with-param name="historyApplies">
								<xsl:choose>
									<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">yes-Materieel</xsl:when>
									<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">yes</xsl:when>
									<xsl:otherwise>no</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>

				</ep:construct>
			</xsl:when>
			<xsl:when test="contains($berichtCode,'Lv')">
				<xsl:choose>
					<xsl:when test="$context = 'selectie'">
						<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="package-id" select="$package-id"/>
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
							<xsl:with-param name="type-id" select="$type-id" />
							<xsl:with-param name="constructName" select="'-'" />
							<xsl:with-param name="historyApplies" select="'no'" />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$context = 'start'">
						<ep:construct context="{$context}" type="'association'">
							<ep:name>
								<xsl:value-of select="$context" />
							</ep:name>
							<ep:tech-name>
								<xsl:value-of select="$context" />
							</ep:tech-name>
								<xsl:call-template name="createRoughEntityConstruct">
									<xsl:with-param name="package-id" select="$package-id"/>
									<xsl:with-param name="id-trail" select="$id-trail" />
									<xsl:with-param name="berichtCode" select="$berichtCode" />
									<xsl:with-param name="context" select="$context" />
									<xsl:with-param name="type-id" select="$type-id" />
									<xsl:with-param name="constructName" select="imvert:name" />
									<xsl:with-param name="historyApplies" select="'no'" />
								</xsl:call-template>

						</ep:construct>
					</xsl:when>
					<xsl:when test="$context = 'scope'">
						<ep:construct context="{$context}" type="'association'">
							<ep:name>
								<xsl:value-of select="$context" />
							</ep:name>
							<ep:tech-name>
								<xsl:value-of select="$context" />
							</ep:tech-name>
								<xsl:call-template name="createRoughEntityConstruct">
									<xsl:with-param name="package-id" select="$package-id"/>
									<xsl:with-param name="id-trail" select="$id-trail" />
									<xsl:with-param name="berichtCode" select="$berichtCode" />
									<xsl:with-param name="context" select="$context" />
									<xsl:with-param name="type-id" select="$type-id" />
									<xsl:with-param name="constructName" select="imvert:name" />
									<xsl:with-param name="historyApplies" select="'no'" />
								</xsl:call-template>
						</ep:construct>
					</xsl:when>
				</xsl:choose>
				
			</xsl:when>
			<xsl:when test="contains($berichtCode,'Lk')">
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="package-id" select="$package-id"/>
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
	
	<!-- This template (8) generates the structure of a relatie on a relatie. -->
	<!-- ROME: De werking van dit template moet adhv van een voorbeeld gecheckt 
		en mogelijk geoptimaliseerd worden. Zo is de vraag of een association-class 
		een supertype kan hebben. Zo ja dan moeten er nog apply-templates worden 
		opgenomen voor het verwerken van de supertypes. -->
	<xsl:template match="imvert:association-class" mode="create-rough-message-content">
		<xsl:param name="package-id"/>
		<xsl:param name="proces-type" select="'associations'" />
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template8: imvert:association-class[mode=create-rough-message-content]'" />
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id" />
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type" select="$proces-type" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
		<!-- ROME: Aangezien een association-class alleen de attributen levert 
			van een relatie en dat relatie element al ergens anders zijn XML-attributes 
			toegekend krijgt hoeven er hier geen attributes meer toegekend te worden. -->
	</xsl:template>
	
	<xsl:template name="createRoughEntityConstruct">
		<xsl:param name="package-id"/>
		<xsl:param name="id-trail" />
		<xsl:param name="berichtCode" />
		<xsl:param name="context" />
		<xsl:param name="orderingDesired" select="'yes'" />
		<xsl:param name="type-id" />
		<xsl:param name="constructName" />
		<xsl:param name="historyApplies" />
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template9: createRoughEntityConstruct'" />
		</xsl:if>
		<ep:construct context="{$context}"  type="'entity'" typeCode="toplevel">
			<xsl:if test="(count(//imvert:class[imvert:id = $type-id]//imvert:attribute//imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'Ja' or imvert:value = 'Ja, zie regels')]) >= 1) or 
				(count(//imvert:class[imvert:id = $type-id]//imvert:association//imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'Ja' or imvert:value = 'Ja, zie regels')]) >= 1)">
				<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'" />
			</xsl:if>
			<xsl:if test="(count(//imvert:class[imvert:id = $type-id]//imvert:attribute//imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'Ja']) >= 1) or 
				(count(//imvert:class[imvert:id = $type-id]//imvert:association//imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'Ja']) >= 1)">
				<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'" />
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$constructName='-'">
					<xsl:sequence
						select="imf:create-output-element('ep:name', imvert:name/@original)" />
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name,'element-name'))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-output-element('ep:name', $constructName)" />
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($constructName,'element-name'))" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence
				select="imf:create-output-element('ep:id', imvert:id)" />
			<xsl:sequence
				select="imf:create-output-element('ep:type-id', imvert:type-id)" />
			<xsl:variable name="class-id" select="imvert:type-id"/>
			<xsl:sequence
				select="imf:create-output-element('ep:class-name', //imvert:class[imvert:id = $class-id]/ep:name)" />
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<xsl:if test="imf:boolean($debug)">	
					<xsl:message select="concat('$historyApplies ',$historyApplies)" />
				</xsl:if>
				<xsl:if
					test="($historyApplies='yes-Materieel' or $historyApplies='yes') and //imvert:class[imvert:id = $type-id and 
							  .//imvert:tagged-value[imvert:name='IndicatieMateriLeHistorie' and contains(imvert:value,'Ja')]]">
					<ep:construct context="{$context}"  type="'entity'">
						<ep:name>historieMaterieel</ep:name>
						<ep:tech-name>historieMaterieel</ep:tech-name>
						<xsl:sequence
							select="imf:create-output-element('ep:id', imvert:id)" />
						<xsl:sequence
							select="imf:create-output-element('ep:type-id', imvert:type-id)" />
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-rough-message-content">
								<xsl:with-param name="package-id" select="$package-id"/>
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
								mode="create-rough-message-content">
								<xsl:with-param name="package-id" select="$package-id"/>
								<xsl:with-param name="proces-type" select="'associationsRelatie'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
					</ep:construct>
				</xsl:if>
				<xsl:if
					test="$historyApplies='yes' and //imvert:class[imvert:id = $type-id and 
							  .//imvert:tagged-value[imvert:name='IndicatieFormeleHistorie' and contains(imvert:value,'Ja')]]">
					<ep:construct context="{$context}"  type="'entity'">
						<ep:name>historieFormeel</ep:name>
						<ep:tech-name>historieFormeel</ep:tech-name>
						<xsl:sequence
							select="imf:create-output-element('ep:id', imvert:id)" />
						<xsl:sequence
							select="imf:create-output-element('ep:type-id', imvert:type-id)" />
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
								mode="create-rough-message-content">
								<xsl:with-param name="package-id" select="$package-id"/>
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
								mode="create-rough-message-content">
								<xsl:with-param name="package-id" select="$package-id"/>
								<xsl:with-param name="proces-type" select="'associationsRelatie'" />
								<!-- ROME: Het is de vraag of deze parameter en het checken op id 
									nog wel noodzakelijk is. -->
								<xsl:with-param name="id-trail" select="$id-trail" />
								<xsl:with-param name="berichtCode" select="$berichtCode" />
								<xsl:with-param name="context" select="$context" />
								<xsl:with-param name="historyApplies" select="$historyApplies" />
							</xsl:apply-templates>
					</ep:construct>
				</xsl:if>
			<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type" select="'associationsRelatie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog 
						wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
		</ep:construct>

	</xsl:template>

	<!-- This template generates the structure of the 'gerelateerde' type element. -->	
	<xsl:template name="createSimpleRelatiePartOfAssociation">
		<xsl:param name="type-id"/>
		<xsl:param name="id"/>
		<xsl:param name="package-id"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template9: createSimpleRelatiePartOfAssociation'" />
		</xsl:if>
		<xsl:choose>
			<!-- The association is a 'relatie' and it has to contain a 'gerelateerde' 
				 construct. -->
			<xsl:when
				test="//imvert:class[imvert:id = $type-id and ancestor::imvert:package[imvert:id = $package-id]] and imvert:stereotype='RELATIE'">
				<ep:construct context="{$context}" typeCode="toplevel">
					<xsl:if test="(count(//imvert:class[imvert:id = $type-id and ancestor::imvert:package[imvert:id = $package-id]]//imvert:attribute//imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'Ja' or imvert:value = 'Ja, zie regels')]) >= 1) or 
						(count(//imvert:class[imvert:id = $type-id and ancestor::imvert:package[imvert:id = $package-id]]//imvert:association//imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'Ja' or imvert:value = 'Ja, zie regels')]) >= 1)">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'" />
					</xsl:if>
					<xsl:if test="(count(//imvert:class[imvert:id = $type-id and ancestor::imvert:package[imvert:id = $package-id]]//imvert:attribute//imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'Ja']) >= 1) or 
						(count(//imvert:class[imvert:id = $type-id and ancestor::imvert:package[imvert:id = $package-id]]//imvert:association//imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'Ja']) >= 1)">
						<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'" />
					</xsl:if>
					<ep:name>gerelateerde</ep:name>
					<ep:tech-name>gerelateerde</ep:tech-name>
					<xsl:sequence select="imf:create-output-element('ep:id', $id)" />
					<xsl:sequence select="imf:create-output-element('ep:type-id', $type-id)" />
					<?x xsl:sequence
						select="imf:create-output-element('ep:id', imvert:id)" />					
					<xsl:sequence
						select="imf:create-output-element('ep:type-id', imvert:type-id)" / x?>
					<xsl:sequence
						select="imf:create-output-element('ep:class-name', //imvert:class[imvert:id = $type-id]/imvert:name)" />					
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-rough-message-content">
							<xsl:with-param name="package-id" select="$package-id"/>
							<xsl:with-param name="proces-type"
								select="'associationsGroepCompositie'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
							mode="create-rough-message-content">
							<xsl:with-param name="package-id" select="$package-id"/>
							<xsl:with-param name="proces-type" select="'associationsRelatie'" />
							<!-- ROME: Het is de vraag of deze parameter en het checken op id 
								nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="berichtCode" select="$berichtCode" />
							<xsl:with-param name="context" select="$context" />
						</xsl:apply-templates>
				</ep:construct>
				<!-- The following 'apply-templates' initiates the processing of the 
					class which contains the attributegroups of the 'relatie' type element. -->
				<xsl:apply-templates select="imvert:association-class" mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type"
						select="'associationsGroepCompositie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id 
						nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<!-- The following 'apply-templates' initiates the processing of the 
					class which contains the associations of the 'relatie' type element. -->
				<xsl:apply-templates select="imvert:association-class" mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
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
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type"
						select="'associationsGroepCompositie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id 
						nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type" select="'associationsRelatie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id 
						nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
			</xsl:when>
			<!-- The association is a 'berichtRelatie' and it contains a 'bericht'. 
				 This situation can occur whithin the context of a 'vrij bericht'. -->
			<!-- ROME: Checken of de volgende when idd de berichtRelatie afhandelt 
				en of alle benodigde (standaard) elementen wel gegenereerd worden. Er wordt 
				geen supertype in afgehandeld, ik weet even niet meer waarom. 
				Volgens mij wordt hierin ook een class met stereotype GROEP afgehandeld 
				waarvoor geen constructRef gemaakt hoeft te worden.-->
			<xsl:when test="//imvert:class[imvert:id = $type-id]">
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type"
						select="'associationsGroepCompositie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id 
						nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-rough-message-content">
					<xsl:with-param name="package-id" select="$package-id"/>
					<xsl:with-param name="proces-type" select="'associationsRelatie'" />
					<!-- ROME: Het is de vraag of deze parameter en het checken op id 
						nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail" />
					<xsl:with-param name="berichtCode" select="$berichtCode" />
					<xsl:with-param name="context" select="$context" />
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ======= End block of templates used to create the message structure. ======= -->	
	
</xsl:stylesheet>
