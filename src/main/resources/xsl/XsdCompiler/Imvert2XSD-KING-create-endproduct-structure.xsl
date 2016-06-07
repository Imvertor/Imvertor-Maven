<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct.xsl 3 2015-11-05 10:35:07Z ArjanLoeffen $ 
-->
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

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-structure</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-structure.xsl 1
		2015-11-11 11:50:00Z RobertMelskens $</xsl:variable>

	<!-- This template is used to start generating the ep structure for an individual message. -->
	<xsl:template match="/imvert:packages/imvert:package" mode="create-message-structure"> <!-- this is an embedded message schema within the koppelvlak-->
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:package[mode=create-message-structure]'"/>
		</xsl:if>
		<xsl:variable name="tagged-values">
			<xsl:sequence select="imvert:tagged-values"/>
		</xsl:variable>
		<xsl:variable name="berichtType">
			<xsl:choose>
				<xsl:when test="imvert:class[imvert:stereotype = 'VRAAGBERICHTTYPE']">Vraagbericht</xsl:when>
				<xsl:when test="imvert:class[imvert:stereotype = 'ANTWOORDBERICHTTYPE']">Antwoordbericht</xsl:when>
				<xsl:when test="imvert:class[imvert:stereotype = 'KENNISGEVINGBERICHTTYPE']">Kennisgevingbericht</xsl:when>
				<xsl:when test="imvert:class[imvert:stereotype = 'VRIJBERICHTTYPE']">Vrij bericht</xsl:when>
			</xsl:choose>
			
		</xsl:variable>
		<!-- create the bericht message -->
		<xsl:variable name="berichtCode" select="imf:determineBerichtCode(imvert:name)"/>
		<ep:message>
			<xsl:sequence
				select="imf:create-output-element('ep:documentation', 'TO-DO: bepalen of er geen documentatie op message niveau kan zijn. Zo ja dan dit toevoegen aan UML model van EP')"/>
			<xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)"/>
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
			<xsl:sequence select="imf:create-output-element('ep:package-type', imvert:stereotype)"/>
			<xsl:sequence select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)"/>
			<xsl:sequence select="imf:create-output-element('ep:type', $berichtType)"/>
			<!-- Start of the message is always a class with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 
				'KENNISGEVINGBERICHTTYPE'.
				 Since the toplever structure of a message complies to different rules then the entiteiten structure this template is initialized within the 
				 'create-initial-message-structure' mode. -->
			<xsl:apply-templates select="imvert:class[imvert:stereotype = imf:get-config-stereotypes((
																			'stereotype-name-vraagberichttype',
																			'stereotype-name-antwoordberichttype',
																			'stereotype-name-vrijberichttype',
																			'stereotype-name-kennisgevingberichttype'))]" mode="create-toplevel-message-structure">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
			</xsl:apply-templates>
		</ep:message>
	</xsl:template>

	<!-- This template only processes imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 
		 'KENNISGEVINGBERICHTTYPE'. Those classes contain a relation to the 'Parameters' group (if not removed), a relation to a class with an imvert:stereotype with 
		 the value 'ENTITEITTYPE' or, in case of a ''VRIJBERICHTTYPE', a relation with one or more classes with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
		 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE'.
		 These classes also have a supertype with an imvert:stereotype with the value 'BERICHTTYPE' which contain a 'melding' attribuut and have a relation to the 
		 'Stuurgegevens' group. This supertype is also processed here. -->
	<xsl:template match="imvert:class" mode="create-toplevel-message-structure">
		<xsl:param name="messagePrefix" select="''"/>
		<xsl:param name="berichtCode"/>
		
<!-- ROME: De bedoeling van deze parameter is dat daarmee kan worden nagegaan of het element 'stuurgegevens' nu wel of niet moet worden gegenereerd. 
		   Een kennisgevings- , vraag- of antwoordbericht in de context van een vrijbericht mag immers geen stuurgegevens bevatten. -->		
		<xsl:param name="stuurgegevens" select="'yes'"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:class[mode=create-initial-message-structure]'"/>
		</xsl:if>
			<ep:seq>
				<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:attribute' elements within the supertype of imvert:class elements with an 
					 imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE' and those within the 
					 current class. -->
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:association' elements with the stereotype 'GROEP COMPOSITIE' within the 
					 supertype of imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 
					 'KENNISGEVINGBERICHTTYPE' and those within the current class. The first one generates the 'stuurgegevens' element, the second one the 'parameters' 
					 element. -->
				<!-- In some occasions, when the variable $stuurgegevens has the value 'no' no 'stuurgegevens' element must be generated. -->
				<xsl:if test="$stuurgegevens='yes'">
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
					</xsl:apply-templates>
				</xsl:if>
<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 'GEGEVENSGROEP COMPOSITIE' wordt gebruikt ipv 'GROEP COMPOSITIE'.
		   De uitbecommentarieerde apply-templates kan met de eerste vorm omgaan maar moet tzt (zodra imvertor daarop checkt) worden verwijdert. -->
				<!--xsl:apply-templates select=".//imvert:association[contains(imvert:stereotype,'GROEP COMPOSITIE')]" mode="create-message-content"-->
				<xsl:apply-templates select=".//imvert:association[imvert:stereotype='GROEP COMPOSITIE']" mode="create-message-content">
					<!-- The 'id-trail' parameter has been introduced to be able to prevent recursive processing of classes.
						 If the parser runs into an id already present within the trail (so the related object has already been processed) processing stops. -->
					
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				
<!-- ROME: De volgende apply template is volgens mij niet nodig. In een supertype op dit niveau wordt immers alleen een relatie gelegd met de Stuurgegevens en 
		   die heeft geen stereotype die gelijk is aan 'RELATIE' en mag die ook niet hebben. 
		   Deze apply-template kan dus waarschijnlijk worden verwijderd en is voor nu uitbecommentarieerd.-->
				<!--xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates-->
				
				<!-- At this level an association with a class having the stereotype 'ENTITEITTYPE' always has the stereotype 'ENTITEITRELATIE'. The following
					 apply-templates initiates the processing of such an association. -->
				<xsl:apply-templates select=".//imvert:association[imvert:stereotype='ENTITEITRELATIE' and not(contains($berichtCode, 'Di')) and not(contains($berichtCode, 'Du'))]" mode="create-message-content">
					<!-- The 'id-trail' parameter has been introduced to be able to prevent recursive processing of classes.
						 If the parser runs into an id already present within the trail (so the related object has already been processed) processing stops. -->
					
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
<!-- ROME: De waardetoekenning van de volgende parameter gaat er vanuit dat in een vraagbericht of in een vrijbericht van het type selectie de associations van het stereotype 
		   'ENTITEITRELATIE' altijd de waardes 'gelijk', 'vanaf', 'totEnMet', 'start' of 'scope' hebben. -->		
					<xsl:with-param name="orderingDesired" select="'no'"/>
				</xsl:apply-templates>
				<!-- Associations linking from a class with a imvert:stereotype with the value 'VRIJBERICHTTYPE' need special treatment.
					 Those linking to a class with a imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE' and
					 those linking to a class with a imvert:stereotype with the value 'ENTITEITRELATIE' must also be processed as from toplevel-message type. -->				
				<xsl:apply-templates select=".//imvert:association[contains($berichtCode, 'Di') and contains($berichtCode, 'Du')]" mode="create-toplevel-message-structure">
					<!-- The 'id-trail' parameter has been introduced to be able to prevent recursive processing of classes.
						 If the parser runs into an id already present within the trail (so teh related object has already been processed) processing stops. -->
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
			</ep:seq>
	</xsl:template>
	
	<!-- This template takes care of associations from a 'vrijbericht' type to the other message types 'vraagbericht', 'antwoordbericht' and 'kennisgevingsbericht'. -->
<!-- ROME: De werking van dit template moet nog gecheckt worden zodra er vrije berichten zijn. Waarschijnlijk moet er nog iets gebeuren met de context. -->
	<xsl:template match="imvert:association" mode="create-toplevel-message-structure">
		<xsl:param name="berichtCode"/>
			<ep:construct>
				<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
				<xsl:sequence
					select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
				<xsl:sequence
					select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>					
				<xsl:choose>
					<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
<!-- ROME: Volgende apply-templates moet natuurlijk het template aanschoppen met als match 'imvert:association[imvert:stereotype='ENTITEITRELATIE']'en als mode 
		   'create-message-content'. -->
						<xsl:apply-templates select="." mode="create-message-content">
							<!-- The 'id-trail' parameter has been introduced to be able to prevent recursive processing of classes.
								 If the parser runs into an id already present within the trail (so the related object has already been processed) processing stops. -->
							
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="'-'"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="imvert:stereotype='BERICHTRELATIE'">
						<xsl:variable name="type-id" select="imvert:type-id"/>
						<xsl:apply-templates select="imvert:class[imvert:id = $type-id and imvert:stereotype = imf:get-config-stereotypes((
																						'stereotype-name-vraagberichttype',
																						'stereotype-name-antwoordberichttype',
																						'stereotype-name-kennisgevingberichttype'))]" mode="create-toplevel-message-structure">
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="stuurgegevens" select="'no'"/>
						</xsl:apply-templates>
					</xsl:when>
				</xsl:choose>
				<ep:seq>
					<ep:construct ismetadata="yes">
						<xsl:sequence select="imf:create-output-element('ep:name', 'StUF:functie')"/>
						<xsl:sequence select="imf:create-output-element('ep:enum', imvert:name/@original)"/>
					</ep:construct>
<!-- ROME: Voor de volgende construct moet nog bepaald worden hoe het zijn waarde krijgt. -->
					<ep:construct ismetadata="yes">
						<xsl:sequence select="imf:create-output-element('ep:name', 'StUF:entiteittype')"/>
						<xsl:sequence select="imf:create-output-element('ep:enum', 'TODO')"/>
					</ep:construct>
				</ep:seq>					
			</ep:construct>		
	</xsl:template>
	

	<!-- This template takes care of processing superclasses of the class being processed. -->
	<xsl:template match="imvert:supertype" mode="create-message-content">
		<xsl:param name="proces-type"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:supertype[mode=create-message-content]'"/>
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"	mode="create-message-content">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- This template transforms an 'imvert:attribute' element to an 'ep:construct' element.. -->
	<xsl:template match="imvert:attribute" mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-message-content]'"/>
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<ep:construct>
<!-- ROME: Samen met Arjan bepalen hoe we enkele elementen hieronder kunnen vullen. -->
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)"/>
			<xsl:sequence select="imf:create-output-element('ep:documentation', imvert:documentation)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:if test="imvert:type-id">
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id and imvert:stereotype = 'ENUMERATION']" mode="create-datatype-content"/>
			</xsl:if>
			<xsl:sequence
				select="imf:create-output-element('ep:id', imvert:id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:is-id', imvert:is-id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegeven', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
<!-- ROME: Wellicht overwegen om het volgende element toch maar 'total-digits' te noemen aangezien het ook zo heet in XSD.
		   De vraag is of ep:length dan nog wel nodig is? -->
			<xsl:sequence
				select="imf:create-output-element('ep:length', imvert:total-digits)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:max-length', imvert:max-length)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:max-value', 'TO-DO: waar komt dit vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-length', imvert:min-length)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-value', 'TO-DO: waar komt dit vandaan')"/>
<!-- ROME: pattern kan een xml fragment bevatten wat geheel moet worden overgenomen. Tenminste als dat de bedoeling is. -->
			<xsl:sequence
				select="imf:create-output-element('ep:pattern', imvert:pattern)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:regels', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
<!-- ROME: Wat kunnen we met een type-modifier? --> 
			<xsl:sequence
				select="imf:create-output-element('ep:type-modifier', 'imvert:type-modifier')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:type-name', imvert:type-name)"/>
<!-- ROME: Ik vermoed dat onderstaande element op basis van het voidable tagged value gegenereerd moet worden.
		   Je zou zeggen dat op basis van die tagged value  echter ook de construct 'noValue' gegenereerd moet worden. 
		   Dat is echter de vraag omdat dat een XML requirement is en mogelijk geen JSON requirement.
		   De vraag is dus of we dat wel moeten doen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', 'TO-DO: waar haal ik hiervoor de waarde vandaan. Zie ook opmerking in stylesheet Imvert2XSD-KING-create-endproduct-structure.xsl')"/>
			<!-- When a tagged-value 'Positie' exists this is used to assign a value to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)"/>	
					<xsl:sequence
						select="imf:create-output-element('ep:tv-position', 'yes')"/>	
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)"/>					
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<!-- Attributes with the name 'melding' or which are descendants of a class with the name 'Stuurgegevens', 'Systeem' or 'Parameters' mustn't get 
				 XML attributes.-->				  
			<xsl:if test="imvert:name != 'melding' and ancestor::imvert:class[imvert:name!='Stuurgegevens'] and ancestor::imvert:class[imvert:name!='Systeem'] and ancestor::imvert:class[imvert:name!='Parameters']">
				<ep:seq>
					<!-- The function imf:createAttributes is used to determine the XML attributes neccessary for this context.
						 It has the following parameters:
						 - typecode
						 - berichttype
						 - context
						 - datumType
						 
						 The first 3 parameters relate to columns with the same name within an Excel spreadsheet used to configure a.o. XML attributes usage.
						 The last parameter is used to determine the need for the XML-attribute 'StUF:indOnvolledigeDatum'. -->
						 
<!-- ROME: De berichtcode is niet als globale variabele aanwezig en kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig verkregen worden 
		   aangezien het element op basis waarvan de berichtcode kan worden gegenereerd geen ancestor is van het huidige element.
		   Er zijn 2 opties:
			 * De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven.
			 * De attributes pas aan de EP structuur toevoegen in een aparte slag nadat de EP structuur al gegenereerd is.
			   Het message element dat de berichtcode bevat is dan nl. wel altijd de ancestor van het element dat het nodig heeft. 
					
		   Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook nog herleid en doorgegeven worden.-->
					<xsl:variable name="datumType">
						<xsl:choose>
							<xsl:when test="imvert:type-name='datetime'">yes</xsl:when>
							<xsl:otherwise>no</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:comment select="concat('Attributes voor bottemlevel, berichtcode: -, context: - met datumtype?: ', $datumType)"/>
					<xsl:variable name="attributes" select="imf:createAttributes('bottomlevel', '-', '-', $datumType, '')"/>
					<xsl:sequence select="$attributes"/>
				</ep:seq>
			</xsl:if>
		</ep:construct>
	</xsl:template>

	<!-- This template transforms an 'imvert:association' element to an 'ep:construct' element.. -->
	<xsl:template match="imvert:association[imvert:stereotype='ENTITEITRELATIE']" mode="create-message-content">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="orderingDesired" select="'yes'"/>
		<xsl:variable name="context">
			<xsl:choose>
				<xsl:when test="imvert:name = 'gelijk' or imvert:name = 'vanaf' or imvert:name = 'totEnMet'">selectie</xsl:when>
				<xsl:when test="imvert:name = 'start'">start</xsl:when>
				<xsl:when test="imvert:name = 'scope'">scope</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association[mode=create-message-content]'"/>
		</xsl:if>
		<xsl:comment select="concat('berichtCode: ', $berichtCode, ', context: ', $context)"/>
		<xsl:choose>
			<xsl:when test="contains($berichtCode,'La')">
<!-- ROME: bij een antwoordbericht wordt er een niveau tussen gegenereerd. Waarom we dat daar wel doen en bij een vraag- en kennisgevingbericht niet vraag ik me af. -->
				<ep:construct>
					<ep:name>antwoord</ep:name>
					<ep:tech-name>antwoord</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>200</ep:position>
					<ep:seq orderingDesired="no">
						<xsl:call-template name="createEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="constructName" select="'-'"/>							
						</xsl:call-template>
					</ep:seq>
				</ep:construct>
			</xsl:when>
			<xsl:when test="contains($berichtCode,'Lv')">
				<xsl:choose>
					<xsl:when test="$context = 'selectie'">
						<xsl:message select="'INFO: Dit is een selectie entiteit.'"/>
						<xsl:call-template name="createEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>							
							<xsl:with-param name="constructName" select="'-'"/>							
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$context = 'start'">
						<ep:construct>
							<ep:name>start</ep:name>
							<ep:tech-name>start</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>200</ep:position>
							<ep:seq orderingDesired="no">
								<xsl:call-template name="createEntityConstruct">
									<xsl:with-param name="id-trail" select="$id-trail"/>
									<xsl:with-param name="berichtCode" select="$berichtCode"/>
									<xsl:with-param name="context" select="$context"/>
									<xsl:with-param name="type-id" select="$type-id"/>							
									<xsl:with-param name="constructName" select="'start'"/>							
								</xsl:call-template>
							</ep:seq>
						</ep:construct>
					</xsl:when>
					<xsl:when test="$context = 'scope'">
						<ep:construct>
							<ep:name>scope</ep:name>
							<ep:tech-name>scope</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>200</ep:position>
							<ep:seq orderingDesired="no">
								<xsl:call-template name="createEntityConstruct">
									<xsl:with-param name="id-trail" select="$id-trail"/>
									<xsl:with-param name="berichtCode" select="$berichtCode"/>
									<xsl:with-param name="context" select="$context"/>
									<xsl:with-param name="type-id" select="$type-id"/>							
									<xsl:with-param name="constructName" select="'scope'"/>							
								</xsl:call-template>
							</ep:seq>
						</ep:construct>
					</xsl:when>
				</xsl:choose>
				
			</xsl:when>
			<xsl:when test="contains($berichtCode,'Lk')">
				
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
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="orderingDesired" select="'yes'"/>
		<xsl:param name="type-id"/>
		<xsl:param name="constructName"/>
		<ep:construct>
			<xsl:choose>
				<xsl:when test="$constructName='-'">
					<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imvert:name)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:name', $constructName)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', $constructName)"/>
				</xsl:otherwise>					
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', //imvert:class[imvert:id = $type-id]/imvert:alias)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', imvert:alias)"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence select="imf:create-output-element('ep:documentation', imvert:documentation)"/>
			<!-- Onderstaande sequence zou gebruikt kunnen worden voor het ophalen van de documentatie behorende bij de class waarnaar verwezen wordt. -->
			<!--xsl:sequence
								select="imf:create-output-element('ep:documentation', //imvert:class[imvert:id = $type-id]/imvert:documentation)"/-->
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:id', imvert:id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:is-id', imvert:is-id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegeven', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:regels', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<!-- Ik vermoed dat onderstaande element op basis van het voidable tagged value gegenereerd moet worden.
								 Je zou zeggen dat op basis van die tagged value  echter ook de construct 'noValue' gegenereerd moet worden. 
								 Dat is echter de vraag omdat dat een XML requirement is en mogelijk geen JSON requirement.
								 De vraag is dus of we dat wel moeten doen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', 'TO-DO: waar haal ik hiervoor de waarde vandaan. Zie ook opmerking in stylesheet Imvert2XSD-KING-create-endproduct-structure.xsl')"/>
			<!-- When a tagged-value 'Positie' exists this is used to assign a value to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)"/>	
					<xsl:sequence
						select="imf:create-output-element('ep:tv-position', 'yes')"/>	
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)"/>					
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<!-- An 'ep:construct' based on an 'imvert:association' element can contain several other 'ep:construct' elements (e.g. 'ep:constructs' for the attributes of 
								 the association itself of for the associations of the association) therefore an 'ep:seq' element is generated here. -->
			<ep:seq>
				<xsl:if test="$orderingDesired='no'">
					<xsl:attribute name="orderingDesired" select="'no'"/>
				</xsl:if>
				<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') and it contains a 'entiteit'. The attributes of the 'entiteit' class can be 
									 placed directly within the current 'ep:seq'. -->
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>					
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar ook aan 'tijdvakRelatie',
		   'historieMaterieel' en 'historieFormeel'. Onderstaande elementen 'StUF:tijdvakGeldigheid' en 'StUF:tijdstipRegistratie' mogen trouwens alleen voorkomen als
		   voor een van de attributen van het huidige object historie is gedefinieerd. De vraag is echter of daarbij alleen gekeken moet worden naar de attributen waarvan
		   de elementen op hetzelfde niveau als onderstaande elementen worden gegenereerd of dat deze elementen ook al gegenereerd moeten worden als er ergens dieper onder
		   het huidige niveau een element voorkomt waarbij op het gerelateerde attribuut historie is gedefinieerd. Dit geldt voor alle locaties waar onderstaande elementen
		   worden gedefinieerd. -->
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
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:variable name="mnemonic">
					<xsl:choose>
						<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
							<xsl:value-of
								select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="imvert:alias"/>
						</xsl:otherwise>
					</xsl:choose>				
				</xsl:variable>
				<!-- The function imf:createAttributes is used to determine the XML attributes neccessary for this context.
								 It has the following parameters:
								 - typecode
								 - berichttype
								 - context
								 - datumType
								 
								 The first 3 parameters relate to columns with the same name within an Excel spreadsheet used to configure a.o. XML attributes usage.
								 The last parameter is used to determine the need for the XML-attribute 'StUF:indOnvolledigeDatum'. -->
				
				<!-- ROME: De berichtcode is niet als globale variabele aanwezig en kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig verkregen worden 
		   aangezien het element op basis waarvan de berichtcode kan worden gegenereerd geen ancestor is van het huidige element.
		   Er zijn 2 opties:
			 * De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven.
			 * De attributes pas aan de EP structuur toevoegen in een aparte slag nadat de EP structuur al gegenereerd is.
			   Het message element dat de berichtcode bevat is dan wel altijd de ancestor van het element dat het nodig heeft. 
					
		   Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook nog herleid en doorgegeven worden.-->
				<xsl:comment select="concat('Attributes voor toplevel, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)"/>
				<xsl:variable name="attributes" select="imf:createAttributes('toplevel', substring($berichtCode,1,2), $context, 'no', $mnemonic)"/>
				<xsl:sequence select="$attributes"/>
			</ep:seq>					
		</ep:construct>
		
	</xsl:template>

	<!-- This template transforms an 'imvert:association' element to an 'ep:construct' element.. -->
	<xsl:template match="imvert:association" mode="create-message-content">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="orderingDesired" select="'yes'"/>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association[mode=create-message-content]'"/>
		</xsl:if>
		<ep:construct>
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)"/>
			<xsl:choose>
				<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', //imvert:class[imvert:id = $type-id]/imvert:alias)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-output-element('ep:mnemonic', imvert:alias)"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence select="imf:create-output-element('ep:documentation', imvert:documentation)"/>
			<!-- Onderstaande sequence zou gebruikt kunnen worden voor het ophalen van de documentatie behorende bij de class waarnaar verwezen wordt. -->
			<!--xsl:sequence
				select="imf:create-output-element('ep:documentation', //imvert:class[imvert:id = $type-id]/imvert:documentation)"/-->
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:id', imvert:id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:is-id', imvert:is-id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegeven', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:regels', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<!-- Ik vermoed dat onderstaande element op basis van het voidable tagged value gegenereerd moet worden.
				 Je zou zeggen dat op basis van die tagged value  echter ook de construct 'noValue' gegenereerd moet worden. 
				 Dat is echter de vraag omdat dat een XML requirement is en mogelijk geen JSON requirement.
				 De vraag is dus of we dat wel moeten doen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', 'TO-DO: waar haal ik hiervoor de waarde vandaan. Zie ook opmerking in stylesheet Imvert2XSD-KING-create-endproduct-structure.xsl')"/>
			<!-- When a tagged-value 'Positie' exists this is used to assign a value to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)"/>	
					<xsl:sequence
						select="imf:create-output-element('ep:tv-position', 'yes')"/>	
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)"/>					
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<!-- An 'ep:construct' based on an 'imvert:association' element can contain several other 'ep:construct' elements (e.g. 'ep:constructs' for the attributes of 
				 the association itself of for the associations of the association) therefore an 'ep:seq' element is generated here. -->
			<ep:seq>
<!-- ROME: De test op de variabele $oderingDesired is hier wellicht niet meer nodig omdat er nu een separaat template is voor het afhandelen het 'imvert:association'
		   element met het stereotype 'ENTITEITRELATIE'. -->
				<xsl:if test="$orderingDesired='no'">
					<xsl:attribute name="orderingDesired" select="'no'"/>
				</xsl:if>
				<!-- The following choose processes the 3 situations an association can represent. -->
				<xsl:choose>
					<!-- The association is a 'relatie' and it has to contain a 'gerelateerde' construct. -->
					<xsl:when test="//imvert:class[imvert:id = $type-id] and imvert:stereotype='RELATIE'">
						<ep:construct>
							<ep:name>gerelateerde</ep:name>
							<ep:tech-name>gerelateerde</ep:tech-name>
							<xsl:sequence
								select="imf:create-output-element('ep:mnemonic', //imvert:class[imvert:id = $type-id]/imvert:alias)"/>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>1</ep:position>
							<ep:seq>
<!-- ROME: Waarschijnlijk moeten afhankelijk van de context (mag de gerelateerde alleen de kerngegevens bevatten of wel meer) de volgende apply-templates van extra 
		   parameters worden voorzien zodat de te genereren structuur aangescherpt kan worden. -->									
								<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
									<xsl:with-param name="proces-type" select="'attributes'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
									<xsl:with-param name="id-trail" select="$id-trail"/>
									<xsl:with-param name="berichtCode" select="$berichtCode"/>
									<xsl:with-param name="context" select="$context"/>
								</xsl:apply-templates>
								<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
									<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
									<xsl:with-param name="id-trail" select="$id-trail"/>
									<xsl:with-param name="berichtCode" select="$berichtCode"/>
									<xsl:with-param name="context" select="$context"/>
								</xsl:apply-templates>
<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar ook aan 'tijdvakRelatie',
		   'historieMaterieel' en 'historieFormeel'. -->
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
								<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
									<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
									<xsl:with-param name="id-trail" select="$id-trail"/>
									<xsl:with-param name="berichtCode" select="$berichtCode"/>
									<xsl:with-param name="context" select="$context"/>
								</xsl:apply-templates>
								<xsl:variable name="mnemonic">
									<xsl:value-of
										select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
								</xsl:variable>
								<!-- The function imf:createAttributes is used to determine the XML attributes neccessary for this context.
									 It has the following parameters:
									 - typecode
									 - berichttype
									 - context
									 - datumType
									 
									 The first 3 parameters relate to columns with the same name within an Excel spreadsheet used to configure a.o. XML attributes usage.
									 The last parameter is used to determine the need for the XML-attribute 'StUF:indOnvolledigeDatum'. -->
								
<!-- ROME: De berichtcode is niet als globale variabele aanwezig en kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig verkregen worden 
		   aangezien het element op basis waarvan de berichtcode kan worden gegenereerd geen ancestor is van het huidige element.
		   Er zijn 2 opties:
			 * De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven.
			 * De attributes pas aan de EP structuur toevoegen in een aparte slag nadat de EP structuur al gegenereerd is.
			   Het message element dat de berichtcode bevat is dan wel altijd de ancestor van het element dat het nodig heeft. 
					
		   Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook nog herleid en doorgegeven worden.-->
								<xsl:comment select="concat('Attributes voor gerelateerde, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)"/>
								<xsl:variable name="attributes" select="imf:createAttributes('gerelateerde', substring($berichtCode,1,2), $context, 'no', $mnemonic)"/>
								<xsl:sequence select="$attributes"/>
							</ep:seq>
						</ep:construct>						
						<!-- The following 'apply-templates' initiates the processing of the class which contains the attributes of the 'relatie' type element. -->
						<xsl:apply-templates select="imvert:association-class">
							<xsl:with-param name="proces-type" select="'attributes'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
						<!-- The following 'apply-templates' initiates the processing of the class which contains the attributegroups of the 'relatie' type element. -->
						<xsl:apply-templates select="imvert:association-class">
							<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
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
						<!-- The following 'apply-templates' initiates the processing of the class which contains the associations of the 'relatie' type element. -->
						<xsl:apply-templates select="imvert:association-class">
							<xsl:with-param name="proces-type" select="'associations'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
					</xsl:when>
					<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') and it contains a 'entiteit'. The attributes of the 'entiteit' class can be 
						 placed directly within the current 'ep:seq'. -->
					<xsl:when test="//imvert:class[imvert:id = $type-id and imvert:stereotype='ENTITEITTYPE']">
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'attributes'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar ook aan 'tijdvakRelatie',
		   'historieMaterieel' en 'historieFormeel'. -->
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
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
						<xsl:variable name="mnemonic">
							<xsl:choose>
								<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
									<xsl:value-of
										select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="imvert:alias"/>
								</xsl:otherwise>
							</xsl:choose>				
						</xsl:variable>
						<!-- The function imf:createAttributes is used to determine the XML attributes neccessary for this context.
						 It has the following parameters:
						 - typecode
						 - berichttype
						 - context
						 - datumType
						 
						 The first 3 parameters relate to columns with the same name within an Excel spreadsheet used to configure a.o. XML attributes usage.
						 The last parameter is used to determine the need for the XML-attribute 'StUF:indOnvolledigeDatum'. -->
						
<!-- ROME: De berichtcode is niet als globale variabele aanwezig en kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig verkregen worden 
		   aangezien het element op basis waarvan de berichtcode kan worden gegenereerd geen ancestor is van het huidige element.
		   Er zijn 2 opties:
			 * De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven.
			 * De attributes pas aan de EP structuur toevoegen in een aparte slag nadat de EP structuur al gegenereerd is.
			   Het message element dat de berichtcode bevat is dan wel altijd de ancestor van het element dat het nodig heeft. 
					
		   Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook nog herleid en doorgegeven worden.-->
						<xsl:comment select="concat('Attributes voor toplevel, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)"/>
						<xsl:variable name="attributes" select="imf:createAttributes('toplevel', substring($berichtCode,1,2), $context, 'no', $mnemonic)"/>
						<xsl:sequence select="$attributes"/>
					</xsl:when>
					<!-- The association is a 'berichtRelatie' and it contains a 'bericht'. This situation can occur whithin the context of a 'vrij bericht'. -->
<!-- ROME: Checken of de volgende when idd de berichtRelatie afhandelt en of alle benodigde (standaard) elementen wel gegenereerd worden. Er wordt geen supertype in 
		   afgehandeld, ik weet even niet meer waarom. -->
					<xsl:when test="//imvert:class[imvert:id = $type-id]">
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'attributes'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>					
					</xsl:when>
				</xsl:choose>
				<!-- Only in case of an association representing a 'relatie' and containing a 'gerelateerde' construct (within the above choose the first 'when'
					 XML Attributes for the 'relatie' type element have to be generated. Because these has to be placed outside the 'gerelateerde' element it has
					 to be done here. -->
				<xsl:if test="imvert:stereotype='RELATIE'">
				<!-- The function imf:createAttributes is used to determine the XML attributes neccessary for this context.
					 It has the following parameters:
					 - typecode
					 - berichttype
					 - context
					 - datumType
					 
					 The first 3 parameters relate to columns with the same name within an Excel spreadsheet used to configure a.o. XML attributes usage.
					 The last parameter is used to determine the need for the XML-attribute 'StUF:indOnvolledigeDatum'.-->
					
<!-- ROME: De berichtcode is niet als globale variabele aanwezig en kan dus niet zomaar opgeroepen worden. Hij kan helaas ook niet eenvoudig verkregen worden 
		   aangezien het element op basis waarvan de berichtcode kan worden gegenereerd geen ancestor is van het huidige element.
		   Er zijn 2 opties:
			 * De berichtcode als parameter aan alle templates toevoegen en steeds doorgeven.
			 * De attributes pas aan de EP structuur toevoegen in een aparte slag nadat de EP structuur al gegenereerd is.
			   Het message element dat de berichtcode bevat is dan wel altijd de ancestor van het element dat het nodig heeft. 
					
		   Voor nu heb ik gekozen voor de eerste optie. Overigens moet de context ook nog herleid en doorgegeven worden.-->
					<xsl:variable name="mnemonic">
						<xsl:choose>
							<xsl:when test="imvert:stereotype='ENTITEITRELATIE'">
								<xsl:value-of
									select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="imvert:alias"/>
							</xsl:otherwise>
						</xsl:choose>				
					</xsl:variable>
					<xsl:comment select="concat('Attributes voor relatie, berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)"/>
					<xsl:variable name="attributes" select="imf:createAttributes('relatie', substring($berichtCode,1,2), $context, 'no', $mnemonic)"/>
					<xsl:sequence select="$attributes"/>
				</xsl:if>
			</ep:seq>					
		</ep:construct>
	</xsl:template>

	<!-- This template generates the structure of the 'relatie' type element excluding the 'gerelateerde' element. -->
<!-- ROME: De werking van dit template moet adhv van een voorbeeld gecheckt en mogelijk geoptimaliseerd worden.
		   Zo is de vraag of een association-class een supertype kan hebben. Zo ja dan moeten er nog apply-templates worden opgenomen voor het verwerken van de
		   supertypes. -->
	<xsl:template match="imvert:association-class">
		<xsl:param name="proces-type" select="'associations'"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association-class[mode=create-message-relations-content]'"/>
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:choose>
			<!-- Following when processes the attributes of the association-class. -->
			<xsl:when test="$proces-type='attributes'">
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- Following otherwise processes the relatie type associations and group compositie associations of the association-class. -->
			<xsl:otherwise>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"	mode="create-message-content">
						<xsl:with-param name="proces-type" select="$proces-type"/>
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
<!-- ROME: Aangezien een association-class alleen de attributen levert van een relatie en dat relatie element al ergens anders zijn XML-attributes toegekend
		   krijgt hoeven er hier geen attributes meer toegekend te worden.-->
	</xsl:template>

	<!-- Declaration of the content of an 'imvert:association' and 'imvert:association-class' finaly always takes place within an 'imvert:class' element. This element
		 is processed within this template. -->
	<xsl:template match="imvert:class" mode="create-message-content">
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:choose>
			<!-- The following when initiate the processing of the attributes belonging to the current class. First the ones found within the superclass of the 
				 current class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- The following when initiate the processing of the attributegroups belonging to the current class. First the ones found within the superclass of the 
				 current class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsGroepCompositie'">
				<!-- If the class is about the 'stuurgegevens' or 'parameters' one of the following when's is activated to check if all children of the stuurgegevens 
					 are allowed within the current berichttype. If not a warning is generated. -->
<!-- ROME: Er wordt nu alleen gecheckt of de elementen die gedefinieerd worden wel voor mogen komen. De vraag is of ook gecheckt moet worden of de elementen die niet zijn
		   gedefinieerd wel weggelaten mogen worden. -->		
				<xsl:choose>
					<xsl:when test="imvert:name='Stuurgegevens'">
						<xsl:for-each select=".//imvert:attribute">
							<xsl:variable name="isElementAllowed" select="imf:isElementAllowed($berichtCode, imvert:name)"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within stuurgegevens.')"/>
							</xsl:if>		
						</xsl:for-each>
						<xsl:for-each select=".//imvert:association">
							<xsl:variable name="isElementAllowed" select="imf:isElementAllowed($berichtCode, imvert:name)"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within stuurgegevens.')"/>
							</xsl:if>										
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="imvert:name='Parameters'">
						<xsl:for-each select=".//imvert:attribute">
							<xsl:variable name="isElementAllowed" select="imf:isElementAllowed($berichtCode, imvert:name)"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within parameters.')"/>
							</xsl:if>		
						</xsl:for-each>
						<xsl:for-each select=".//imvert:association">
							<xsl:variable name="isElementAllowed" select="imf:isElementAllowed($berichtCode, imvert:name)"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within parameters.')"/>
							</xsl:if>										
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 'GEGEVENSGROEP COMPOSITIE' wordt gebruikt ipv 'GROEP COMPOSITIE'.
	   De uitbecommentarieerde apply-templates kan met de eerste vorm omgaan maar moet tzt (zodra imvertor daarop checkt) worden verwijdert. -->
						<xsl:apply-templates select=".//imvert:association[imvert:stereotype='GROEP COMPOSITIE']" mode="create-message-content">
						<!--xsl:apply-templates select=".//imvert:association[contains(imvert:stereotype,'GROEP COMPOSITIE')]" mode="create-message-content"-->
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail">
								<xsl:choose>
									<xsl:when
										test="contains($id-trail, concat('#1#', imvert:id, '#'))">
										<xsl:value-of
											select="concat('#2#', imvert:id, '#', $id-trail)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('#1#', imvert:id, '#', $id-trail)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<!-- Indien we besluiten recursie voor mag gaan komen dan moet dit nog worden gecodeerd. -->							
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- The following when initiate the processing of the associations belonging to the current class. First the ones found within the superclass of the 
				 current class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsRelatie'">
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
						<xsl:apply-templates select=".//imvert:association[imvert:stereotype='RELATIE']" mode="create-message-content">
<!-- ROME: Het is de vraag of deze parameter en het checken op id nog wel noodzakelijk is. -->
							<xsl:with-param name="id-trail">
								<xsl:choose>
									<xsl:when
										test="contains($id-trail, concat('#1#', imvert:id, '#'))">
										<xsl:value-of
											select="concat('#2#', imvert:id, '#', $id-trail)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('#1#', imvert:id, '#', $id-trail)"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<!-- Indien we besluiten recursie voor mag gaan komen dan moet dit nog worden gecodeerd. -->							
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- This template simply replicates elements. May be replaced later. -->
	<xsl:template match="*" mode="replicate-imvert-elements">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:element name="{concat('ep:',local-name())}">
			<xsl:choose>
				<xsl:when test="*">
					<xsl:apply-templates select="*" mode="replicate-imvert-elements">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>						
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

<!-- ROME: Checken of alle takken van dit template wel worden gebruikt. -->
	<!-- This template creates the constructs on datatype level. -->
	<xsl:template match="imvert:class" mode="create-datatype-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:choose>
			<!-- The first when tackles the situation in which the datatype of an attribute isn't a simpleType but a complexType. 
				 An attribute refers in that case to an objectType (probably now an entitytype).
				 This situation occurs for example if within a union is refered to an entity withinn a ´Model´ package. -->
<!-- ROME: Dit template moet wellicht later aangepast of verwijderd worden afhankelijk van of unions gebruikt blijven worden of de wijze waarop we die gebruiken. -->
			<xsl:when test="imvert:stereotype = 'ENTITEITTYPE'">
				<ep:seq>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
					<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 'GEGEVENSGROEP COMPOSITIE' wordt gebruikt ipv 'GROEP COMPOSITIE'.
		   De uitbecommentarieerde apply-templates kan met de eerste vorm omgaan maar moet tzt (zodra imvertor daarop checkt) worden verwijdert. -->
					<xsl:apply-templates select=".//imvert:association[imvert:stereotype='GROEP COMPOSITIE']" mode="create-message-content">
					<!--xsl:apply-templates select=".//imvert:association[contains(imvert:stereotype,'GROEP COMPOSITIE')]" mode="create-message-content"-->							
						<?x xsl:with-param name="id-trail"
							select="concat('#1#', imvert:id, '#', $id-trail)"/ x?>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
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
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
					<xsl:apply-templates select=".//imvert:association[imvert:stereotype='RELATIE']" mode="create-message-content">
						<?x xsl:with-param name="id-trail"
							select="concat('#1#', imvert:id, '#', $id-trail)"/ x?>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</ep:seq>
			</xsl:when>
			<!-- If it's an 'Enumeration' class it's attributes, which represent the enumeration values) processed. -->
			<xsl:when test="imvert:stereotype = 'ENUMERATION'">
				<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="create-datatype-content"/>
			</xsl:when>
			<xsl:when test="imvert:stereotype = 'DATATYPE'">
				<xsl:choose>
					<!-- If the class stereotype is a Datatype and it contains 'imvert:attribute' elements they are placed as constructs within a 'ep:seq' element. -->
					<xsl:when test="imvert:attributes/imvert:attribute">
						<ep:seq>
							<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="create-datatype-content">
								<xsl:with-param name="berichtCode" select="$berichtCode"/>								
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</ep:seq>
					</xsl:when>
					<!-- If not an 'ep:datatype' element is generated. -->
					<xsl:otherwise>
						<ep:datatype id="{imvert:id}">
							<xsl:apply-templates select="imvert:documentation" mode="replicate-imvert-elements">
								<xsl:with-param name="berichtCode" select="$berichtCode"/>								
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</ep:datatype>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
<!-- ROME: De vraag is of deze otherwise tak ooit wordt gebruikt. -->
			<xsl:otherwise>
				<xsl:comment select="'De otherwise tak wordt gebruikt.'"/>
				<ep:seq>
					<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="create-datatype-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>						
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</ep:seq>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- The following template creates the construct representing the lowest level elements or the 'ep:enum' element representing one of the 
		 possible values of an enumeration. -->
	<xsl:template match="imvert:attribute" mode="create-datatype-content">
		<xsl:param name="berichtCode"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-datatype-content]'"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="imvert:stereotype = 'ENUM'">
					<xsl:sequence select="imf:create-output-element('ep:enum', imvert:name)"/>
			</xsl:when>
			<xsl:otherwise>
				<ep:construct>
					<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
					<xsl:if test="imvert:type-id">
						<xsl:apply-templates select="//imvert:class[imvert:id = current()/imvert:type-id]" mode="create-datatype-content"/>
					</xsl:if>
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
		
	<xsl:function name="imf:isElementAllowed">
		<xsl:param name="berichtCode" as="xs:string"/>
		<xsl:param name="element" as="xs:string"/>
		<!-- The following variable wil contain information from a spreadsheetrow which is determined using the first 3 parameters. 
			 The variable $enriched-endproduct-base-config-excel used within the following variable is generated using the XSLT stylesheet 
			 'Imvert2XSD-KING-enrich-excel.xsl'. -->
		<xsl:variable name="attributeTypeRow" select="$enriched-endproduct-base-config-excel//sheet
			[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data = $berichtCode]"/>
		<xsl:if test="$attributeTypeRow//col[@name = $element and data = '-']">no</xsl:if>		
	</xsl:function>
	
	<!-- The function imf:createAttributes is used to determine the XML attributes neccessary for a certain context.
		 It has the following parameters:
		 - typecode
		 - berichttype
		 - context
		 - datumType
		 
		 The first 3 parameters relate to columns with the same name within an Excel spreadsheet used to configure a.o. XML attributes usage.
		 The last parameter is used to determine the need for the XML-attribute 'StUF:indOnvolledigeDatum'. -->
	<xsl:function name="imf:createAttributes">
		<xsl:param name="typeCode" as="xs:string"/>
		<xsl:param name="berichtType" as="xs:string"/>
		<xsl:param name="context" as="xs:string"/>
		<xsl:param name="datumType" as="xs:string"/>
		<xsl:param name="mnemonic" as="xs:string"/>
		<!-- The following variable wil contain information from a spreadsheetrow which is determined using the first 3 parameters. 
			 The variable $enriched-endproduct-base-config-excel used within the following variable is generated using the XSLT stylesheet 
			 'Imvert2XSD-KING-enrich-excel.xsl'. -->
		<xsl:variable name="attributeTypeRow" select="$enriched-endproduct-base-config-excel//sheet
													  [name = 'XML attributes']/row[col[@name = 'typecode']/data = $typeCode and 
																			  	          col[@name = 'berichttype']/data = $berichtType and 
																				          col[@name = 'context']/data = $context]"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:message>attributeTypeRow: <xsl:value-of select="$attributeTypeRow/@number"/> (<xsl:value-of select="$typeCode"/>, <xsl:value-of select="$berichtType"/>, <xsl:value-of select="$context"/>, <xsl:value-of select="$datumType"/>)</xsl:message>
		</xsl:if>
		<!-- The following if statements checks if a specific column in the spreadsheetrow in the 'attributeTypeRow' variable contains an 'O' or an 'R'.
			 If this is the case the related XML-Attribute is generated (required if the 'attributeTypeRow' variable contains an 'R' and optional if the variable contains 
			 an 'O'). Since these are all XML-Attributes which are defined within de so-called 'StUF-onderlaag'
			 (they all have the prefix 'StUF') we only have to generate the name and occurence. For attributes generated in other namespaces which must be used within
		 	 the koppelvlak namespace counts the same. XML-attributes to be defined within the koppelvlak namespace will need a type-name, enum or other format defining
			 element. -->
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:noValue' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:noValue</ep:name>
				<ep:tech-name>StUF:noValue</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:noValue' and data = 'R']">
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
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:exact' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:exact</ep:name>
				<ep:tech-name>StUF:exact</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:metagegeven' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:metagegeven</ep:name>
				<ep:tech-name>StUF:metagegeven</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:metagegeven' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:metagegeven</ep:name>
				<ep:tech-name>StUF:metagegeven</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<!-- ROME: De vraag is of ik het gebruik van het XML attribute 'StUF:indOnvolledigeDatum' wel in het spreadsheet moet configureren.
		   Moeten niet gewoon alle elementen van het datumType dit XML attribute krijgen? -->
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:indOnvolledigeDatum' and data = 'O'] and $datumType = 'yes'">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:indOnvolledigeDatum</ep:name>
				<ep:tech-name>StUF:indOnvolledigeDatum</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>					
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:indOnvolledigeDatum' and data = 'R'] and $datumType = 'yes'">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:indOnvolledigeDatum</ep:name>
				<ep:tech-name>StUF:indOnvolledigeDatum</ep:tech-name>
			</ep:construct>					
		</xsl:if>
		<!-- ROME: De waarde van het attribute 'StUF:entiteittype' moet m.b.v. een enum constuctie worden gedefinieerd. Die waarde zal aan de functie meegegeven moeten worden. 
	       Deze waarde zou uit het 'imvert:alias' element moeten komen. Dat is echter niet altijd aanwezig. -->
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:entiteittype' and data = 'O']">
			<ep:construct ismetadata="yes">
<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace van het koppelvlak. 
	 	   Later zal ik echter een restriction moeten definieren in de namespace van de StUF onderlaag. -->
				<ep:name>StUF:entiteittype</ep:name>
				<!--ep:tech-name>StUF:entiteittype</ep:tech-name-->
				<ep:tech-name>entiteittype</ep:tech-name>
<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:if test="$mnemonic!=''">
					<xsl:sequence
						select="imf:create-output-element('ep:type-name', 'char')"/>					
					<xsl:sequence
						select="imf:create-output-element('ep:enum', $mnemonic)"/>
				</xsl:if>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:entiteittype' and data = 'R']">
			<ep:construct ismetadata="yes">
				<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace van het koppelvlak. 
	 	   Later zal ik echter een restriction moeten definieren in de namespace van de StUF onderlaag. -->
				<ep:name>StUF:entiteittype</ep:name>
				<!--ep:tech-name>StUF:entiteittype</ep:tech-name-->
				<ep:tech-name>entiteittype</ep:tech-name>
				<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:if test="$mnemonic!=''">
					<xsl:sequence
						select="imf:create-output-element('ep:type-name', 'char')"/>					
					<xsl:sequence
						select="imf:create-output-element('ep:enum', $mnemonic)"/>
				</xsl:if>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelVerzendend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelVerzendend</ep:name>
				<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelVerzendend' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelVerzendend</ep:name>
				<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelOntvangend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelOntvangend</ep:name>
				<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelOntvangend' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelOntvangend</ep:name>
				<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelGegevensbeheer' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelGegevensbeheer</ep:name>
				<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelGegevensbeheer' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelGegevensbeheer</ep:name>
				<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelSynchronisatie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:sleutelSynchronisatie</ep:name>
				<ep:tech-name>StUF:sleutelSynchronisatie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelSynchronisatie' and data = 'R']">
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
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:scope' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:scope</ep:name>
				<ep:tech-name>StUF:scope</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:verwerkingssoort' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:verwerkingssoort</ep:name>
				<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:verwerkingssoort' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:verwerkingssoort</ep:name>
				<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:functie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:functie</ep:name>
				<ep:tech-name>StUF:functie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:functie' and data = 'R']">
			<ep:construct ismetadata="yes">
				<ep:name>StUF:functie</ep:name>
				<ep:tech-name>StUF:functie</ep:tech-name>
			</ep:construct>
		</xsl:if>
	</xsl:function>

	<xsl:function name="imf:determineBerichtCode">
		<xsl:param name="name" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="contains($name,'Di01')">Di01</xsl:when>
			<xsl:when test="contains($name,'Di02')">Di02</xsl:when>
			<xsl:when test="contains($name,'Du01')">Du01</xsl:when>
			<xsl:when test="contains($name,'Du02')">Du02</xsl:when>
			<xsl:when test="contains($name,'La01')">La01</xsl:when>
			<xsl:when test="contains($name,'La02')">La02</xsl:when>
			<xsl:when test="contains($name,'La03')">La03</xsl:when>
			<xsl:when test="contains($name,'La04')">La04</xsl:when>
			<xsl:when test="contains($name,'La05')">La05</xsl:when>
			<xsl:when test="contains($name,'La06')">La06</xsl:when>
			<xsl:when test="contains($name,'La07')">La07</xsl:when>
			<xsl:when test="contains($name,'La08')">La08</xsl:when>
			<xsl:when test="contains($name,'La09')">La09</xsl:when>
			<xsl:when test="contains($name,'La10')">La10</xsl:when>
			<xsl:when test="contains($name,'La11')">La11</xsl:when>
			<xsl:when test="contains($name,'La12')">La12</xsl:when>
			<xsl:when test="contains($name,'La13')">La13</xsl:when>
			<xsl:when test="contains($name,'La14')">La14</xsl:when>
			<xsl:when test="contains($name,'Lk01')">Lk01</xsl:when>
			<xsl:when test="contains($name,'Lk02')">Lk02</xsl:when>
			<xsl:when test="contains($name,'Lk03')">Lk03</xsl:when>
			<xsl:when test="contains($name,'Lk04')">Lk04</xsl:when>
			<xsl:when test="contains($name,'Lk05')">Lk05</xsl:when>
			<xsl:when test="contains($name,'Lk06')">Lk06</xsl:when>
			<xsl:when test="contains($name,'Lv01')">Lv01</xsl:when>
			<xsl:when test="contains($name,'Lv02')">Lv02</xsl:when>
			<xsl:when test="contains($name,'Lv03')">Lv03</xsl:when>
			<xsl:when test="contains($name,'Lv04')">Lv04</xsl:when>
			<xsl:when test="contains($name,'Lv05')">Lv05</xsl:when>
			<xsl:when test="contains($name,'Lv06')">Lv06</xsl:when>
			<xsl:when test="contains($name,'Lv07')">Lv07</xsl:when>
			<xsl:when test="contains($name,'Lv08')">Lv08</xsl:when>
			<xsl:when test="contains($name,'Lv09')">Lv09</xsl:when>
			<xsl:when test="contains($name,'Lv10')">Lv10</xsl:when>
			<xsl:when test="contains($name,'Lv11')">Lv11</xsl:when>
			<xsl:when test="contains($name,'Lv12')">Lv12</xsl:when>
			<xsl:when test="contains($name,'Lv13')">Lv13</xsl:when>
			<xsl:when test="contains($name,'Lv14')">Lv14</xsl:when>
			<xsl:when test="contains($name,'Sa01')">Sa01</xsl:when>
			<xsl:when test="contains($name,'Sa02')">Sa02</xsl:when>
			<xsl:when test="contains($name,'Sa03')">Sa03</xsl:when>
			<xsl:when test="contains($name,'Sa04')">Sa04</xsl:when>
			<xsl:when test="contains($name,'Sh01')">Sh01</xsl:when>
			<xsl:when test="contains($name,'Sh02')">Sh02</xsl:when>
			<xsl:when test="contains($name,'Sh03')">Sh03</xsl:when>
			<xsl:when test="contains($name,'Sh04')">Sh04</xsl:when>
		</xsl:choose>
		
	</xsl:function>
	
</xsl:stylesheet>
