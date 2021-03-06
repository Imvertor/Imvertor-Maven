<?xml version="1.0" encoding="UTF-8"?>
<!-- SVN: $Id: Imvert2XSD-KING-endproduct.xsl 3 2015-11-05 10:35:07Z ArjanLoeffen 
	$ This stylesheet generates the EP file structure based on the embellish 
	file of a BSM EAP file. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:UML="omg.org/UML1.3"
	xmlns:imvert="http://www.imvertor.org/schema/system"
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
	xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking"
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0">

	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-structure</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-structure.xsl 1
		2015-11-11 11:50:00Z RobertMelskens $</xsl:variable>
	
	<!-- ======= Block of templates used to create the message structure. ======= -->

	
	<!-- This template is used to start generating the ep structure for all individual messages. -->

	<!-- This template (1) only processes imvert:class elements with an imvert:stereotype 
		with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE', 
		'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE'. Those classes contain a relation to the 'Parameters' 
		group (if not removed), a relation to a class with an imvert:stereotype with 
		the value 'ENTITEITTYPE' or, in case of a 'VRIJ BERICHTTYPE', a relation 
		with one or more classes with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
		'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE'. -->
	<xsl:template match="imvert:class" mode="create-toplevel-message-structure">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1000',$debugging)"/>

		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="new-generated-id">
			<xsl:choose>
				<!-- ROME: De waarde noMessage wordt volgens mij nergens meer gezet dus de eerste when kan waarschijnlijk verwijderd worden. -->
				<!--xsl:when test="$currentMessage = 'noMessage'"/-->
				<xsl:when test="empty($generated-id)">
					<xsl:value-of select="generate-id($currentMessage/ep:rough-message[ep:id = $id])"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$generated-id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<ep:seq>
			<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:attribute' 
				elements within the supertype of imvert:class elements with an imvert:stereotype 
				with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE', 
				'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE' and those within the current class. 
				The empty value for the variable 'context' guarantee's no xml attributes are 
				generated with the attributen.
				If custom stuurgegevens and parameters are used no imvert:supertype will be available and the 
				apply-template on that element is never fired.-->
			<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="berichtName" select="$berichtName"/>
				<xsl:with-param name="generated-id" select="$new-generated-id"/>
				<xsl:with-param name="currentMessage" select="$currentMessage"/>
				<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
				<xsl:with-param name="proces-type" select="'attributes'"/>
				<xsl:with-param name="context" select="'-'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="./imvert:attributes/imvert:attribute" mode="create-message-content">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="berichtName" select="$berichtName"/>
				<xsl:with-param name="generated-id" select="$new-generated-id"/>
				<xsl:with-param name="currentMessage" select="$currentMessage"/>
				<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
				<xsl:with-param name="context" select="'-'"/>
			</xsl:apply-templates>

			<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:association' 
				elements with the stereotype 'GROEP COMPOSITIE' within the supertype 
				of imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
				'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE', 'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE' and 
				those within the current class. The first one generates the 'stuurgegevens' 
				element, the second one the 'parameters' element. 
				The empty value for the variable 'context' guarantee's no xml attributes are 
				generated with the attributen.-->
			<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="berichtName" select="$berichtName"/>
				<xsl:with-param name="generated-id" select="$new-generated-id"/>
				<xsl:with-param name="currentMessage" select="$currentMessage"/>
				<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
				<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
				<xsl:with-param name="context" select="'-'"/>
			</xsl:apply-templates>
			
			<xsl:sequence select="imf:create-debug-comment('Debuglocation 1000A',$debugging)"/>
			<xsl:apply-templates
				select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]"
				mode="create-message-content">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="berichtName" select="$berichtName"/>
				<xsl:with-param name="generated-id" select="$new-generated-id"/>
				<xsl:with-param name="currentMessage" select="$currentMessage"/>
				<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
				<xsl:with-param name="context" select="''"/>
			</xsl:apply-templates>
			<xsl:sequence select="imf:create-debug-comment('Debuglocation 1000B',$debugging)"/>
			
			<!-- At this level an association with a class having the stereotype 'ENTITEITTYPE' 
				 always has the stereotype 'ENTITEITRELATIE'. The following apply-templates 
				 initiates the processing of such an association.
				 The supertype of the current class will never contain an association with a stereotype 
				 of 'ENTITEITRELATIE'. For that reason no apply-templates on the supertype in this context 
				 is implemented. -->
			
			<xsl:choose>
				<xsl:when
					test="not(contains($berichtCode, 'Di')) and not(contains($berichtCode, 'Du'))">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1001',$debugging)"/>

					<xsl:apply-templates
						select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$new-generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
						<!--xsl:with-param name="orderingDesired" select="'no'"/-->
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<!-- ROME: Het moet mogelijk zijn om de associations in een zelf bepaalde volgorde te plaatsen. 
						 Daarvoor moet hieronder nog iets met position worden gedaan. -->
					<xsl:for-each select="./imvert:associations/imvert:association">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1002',$debugging)"/>
						
						<xsl:apply-templates
							select=".[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
							mode="create-message-content">
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="berichtName" select="concat($berichtName,'-',imvert:name)"/>
							<xsl:with-param name="generated-id" select="$new-generated-id"/>
							<xsl:with-param name="currentMessage" select="$currentMessage"/>
							<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
							<!--xsl:with-param name="orderingDesired" select="'no'"/-->
						</xsl:apply-templates>
						<!-- Associations linking from a class with a imvert:stereotype with the 
						value 'VRIJ BERICHTTYPE' need special treatment. E.g. the construct to be created must 
						contain a meta-data construct called 'functie'. For that reason those linking to a class 
						with a imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE' 
						or 'KENNISGEVINGBERICHTTYPE' and those linking to a class with a imvert:stereotype 
						with the value 'ENTITEITRELATIE' must also be processed as from toplevel-message 
						type. -->
						<xsl:apply-templates select=".[imvert:stereotype/@id != 'stereotype-name-entiteitrelatie' and imvert:name != 'stuurgegevens' and imvert:name != 'parameters']"
							mode="create-toplevel-message-structure-constructRef">
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="berichtName" select="concat($berichtName,'-',imvert:name)"/>
							<xsl:with-param name="generated-id" select="$new-generated-id"/>
							<xsl:with-param name="currentMessage" select="$currentMessage"/>
							<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
							<xsl:with-param name="context" select="'-'"/>
						</xsl:apply-templates>
						
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<ep:construct prefix="{$kv-prefix}" ismetadata="yes">
				<ep:name>patch</ep:name>
				<ep:tech-name>patch</ep:tech-name>
				<ep:min-value>0</ep:min-value>
				<ep:type-name><xsl:value-of select="concat($StUF-prefix,':','Patchnummer')"/></ep:type-name>
			</ep:construct>
		</ep:seq>
	</xsl:template>

	<!-- This template (2) takes care of processing the superclass of the class being 
		 processed. It will start processing the attributes, groups or associations of the superclass. -->
	<xsl:template match="imvert:supertype" mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		<xsl:param name="proces-type"/>
		<xsl:param name="context"/>
		<xsl:param name="useStuurgegevens" select="'yes'"/>
		<xsl:param name="fundamentalMnemonic" select="''"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1003a',$debugging)"/>
		
		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-message-content">
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="berichtName" select="$berichtName"/>
			<xsl:with-param name="generated-id" select="$generated-id"/>
			<xsl:with-param name="currentMessage" select="$currentMessage"/>
			<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="useStuurgegevens" select="$useStuurgegevens"/>
			<xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
		</xsl:apply-templates>
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1003b',$debugging)"/>
	</xsl:template>

	<xsl:template match="imvert:supertype" mode="create-message-content-constructRef">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		<xsl:param name="proces-type"/>
		<xsl:param name="context"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1004a',$debugging)"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>
		
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-message-content-constructRef">
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="berichtName" select="$berichtName"/>
			<xsl:with-param name="generated-id" select="$generated-id"/>
			<xsl:with-param name="currentMessage" select="$currentMessage"/>
			<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1004b',$debugging)"/>
	</xsl:template>
	
	<!-- Declaration of the content of a superclass, an 'imvert:association' and 'imvert:association-class' 
		finaly always takes place within an 'imvert:class' element. This element 
		is processed within this template (3). -->
	<xsl:template match="imvert:class" mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="context"/>
		<xsl:param name="useStuurgegevens" select="'yes'"/>
		<xsl:param name="fundamentalMnemonic" select="''"/>
		<xsl:param name="generateHistorieConstruct" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorieRelatie" select="'Nee'"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1005a',$debugging)"/>

		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="berichtType">
			<xsl:choose>
				<xsl:when test="$berichtCode = 'La01' or $berichtCode = 'La02'">La0102</xsl:when>
				<xsl:when test="$berichtCode = 'La03' or $berichtCode = 'La04'">La0304</xsl:when>
				<xsl:when test="$berichtCode = 'La05' or $berichtCode = 'La06'">La0506</xsl:when>
				<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">La0708</xsl:when>
				<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">La0910</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv')">Lv</xsl:when>
				<xsl:when test="contains($berichtCode,'Lk')">Lk</xsl:when>
				<xsl:otherwise><xsl:value-of select="$berichtName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-SUBSETLABEL')"/>
		
			<xsl:choose>
				<!-- The following when initiate the processing of the attributes belonging 
					to the current class. First the ones found within the superclass of the current 
					class followed by the ones within the current class. -->
				<xsl:when test="$proces-type = 'attributes'">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1006',$debugging)"/>
					
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
						<xsl:with-param name="proces-type" select="$proces-type"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="./imvert:attributes/imvert:attribute" mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
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
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1007a',$debugging)"/>
					
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="$proces-type"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
						<xsl:with-param name="useStuurgegevens" select="$useStuurgegevens"/>                                       
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1007b',$debugging)"/>
					<xsl:apply-templates
						select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
						<xsl:with-param name="useStuurgegevens" select="$useStuurgegevens"/>                                       
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1007c',$debugging)"/>
				</xsl:when>
				<!-- The following when initiates the processing of the classes refering to the current class as a superclass.
					 In this situation a choice has to be generated. -->
				<xsl:when test="$proces-type = 'associationsOrSupertypeRelatie' and $packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1008',$debugging)"/>
					

					<ep:choice>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:for-each select="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
							<xsl:variable name="class-id" select="imvert:id"/>
							<xsl:variable name="alias" select="imvert:alias"/>
							<xsl:variable name="element" select="imvert:name"/>
							<xsl:variable name="verwerkingsModusOfConstructRef">
								<xsl:choose>
									<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct/ep:construct[ep:id = $class-id and @context = $context]">
										<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct/ep:construct[ep:id = $class-id and @context = $context]/@verwerkingsModus"/>
									</xsl:when>
									<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct[ep:id = $class-id and @context = $context]">
										<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct[ep:id = $class-id and @context = $context]/@verwerkingsModus"/>
									</xsl:when>
									<xsl:otherwise/>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:sequence select="imf:create-debug-comment(concat('verwerkingsModusOfConstructRef for construct with id ',$class-id, ' and context ',$context,' and parent construct (',$currentMessage//ep:*[generate-id() = $generated-id]/ep:id,') with generated-id ',$generated-id,': ',$verwerkingsModusOfConstructRef),$debugging)"/>
							<xsl:sequence select="imf:create-debug-comment(concat('delen van de hrefnaam: ',$berichtName,',',$verwerkingsModusOfConstructRef,',',$alias,',',$element),$debugging)"/>
							
							<!-- Location: 'ep:constructRef1a'
								 Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->

							<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
								<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)" />
								<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)" />
								<xsl:sequence select="imf:create-output-element('ep:max-occurs', 1)"/>
								<xsl:sequence select="imf:create-output-element('ep:min-occurs', 1)"/>
								<xsl:sequence select="imf:create-output-element('ep:position', imvert:position)"/>

								<xsl:choose>
									<xsl:when test="not(empty($verwerkingsModusOfConstructRef)) and $verwerkingsModusOfConstructRef != ''">
										<!--xsl:sequence select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$verwerkingsModusOfConstructRef,$alias,$element))"/-->							
										<xsl:sequence select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$verwerkingsModusOfConstructRef,$alias,(),$subsetLabel))"/>							
									</xsl:when>
									<xsl:otherwise>
										<!--xsl:sequence select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,(),$alias,$element))"/-->							
										<xsl:sequence select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,(),$alias,(),$subsetLabel))"/>							
									</xsl:otherwise>
								</xsl:choose>
							</ep:construct>

						</xsl:for-each>
					</ep:choice>
					<ep:seq>
						<xsl:variable name="alias" select="imvert:alias"/>

						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1008a',$debugging)"/>
						
						<xsl:variable name="attributes"
							select="imf:createAttributes('gerelateerde', substring($berichtCode, 1, 2), 'choice', $alias, 'no', $prefix, $id, '')"/>
						<xsl:sequence select="$attributes"/>
					</ep:seq>
				</xsl:when>
				<!-- The following when initiate the processing of the associations belonging 
					to the current class. First the ones found within the superclass of the current 
					class followed by the ones within the current class. -->
				<xsl:when test="$proces-type = 'associationsRelatie' or $proces-type = 'associationsOrSupertypeRelatie'">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1009',$debugging)"/>

					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
						<xsl:with-param name="proces-type" select="$proces-type"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
					<!-- If the class hasn't been processed before it can be processed, else. 
						to prevent recursion, processing is canceled. -->
					<xsl:apply-templates select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-relatiesoort')]"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1005b',$debugging)"/>
	</xsl:template>

	<!-- This template takes care of creating the constructRef constructs form the current class but also from the supertype of the current class
		 that refer to global constructs. -->
	<xsl:template match="imvert:class" mode="create-message-content-constructRef">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="context"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1010a',$debugging)"/>
		<xsl:apply-templates select="imvert:supertype" mode="create-message-content-constructRef">
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="berichtName" select="$berichtName"/>
			<xsl:with-param name="generated-id" select="$generated-id"/>
			<xsl:with-param name="currentMessage" select="$currentMessage"/>
			<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1010b',$debugging)"/>
		<xsl:apply-templates select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-relatiesoort')]"
			mode="create-message-content-constructRef">
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="berichtName" select="$berichtName"/>
			<xsl:with-param name="generated-id" select="$generated-id"/>
			<xsl:with-param name="currentMessage" select="$currentMessage"/>
			<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1010c',$debugging)"/>
		<xsl:apply-templates select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
			mode="create-message-content-constructRef">
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="berichtName" select="$berichtName"/>
			<xsl:with-param name="generated-id" select="$generated-id"/>
			<xsl:with-param name="currentMessage" select="$currentMessage"/>
			<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- This template (4) transforms an 'imvert:association' element to a global 'ep:construct' 
		 element. -->
	<xsl:template match="imvert:association" mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		<xsl:param name="context"/>
		<xsl:param name="generateHistorieConstruct" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorieRelatie" select="'Nee'"/>
		<!--xsl:param name="orderingDesired" select="'yes'"/-->
		<xsl:param name="useStuurgegevens" select="'yes'"/>                                       
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1011',$debugging)"/>
		
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="matchgegeven" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEMATCHGEGEVEN')"/>
		
		<!-- ROME: Net als in het template voor de attributen moet ook in dit template nog een check ingebouwd worden of historie wel van toepassing is op deze association
			       Historie kan nl. wel van toepassing op de groep maar dat betekent nog niet dat deze association daarin opgenomen moet worden. -->
		
		<!-- The following construct is not created if the variable $verwerkingsModus is equal to 'matchgegevens' and the variable
		     $matchgegeven is equal to 'NEE'. So in case the $verwerkingsModus isn't equal to 'matchgegevens' and in case the $verwerkingsModus 
		     is equal to 'matchgegevens' and the variable $matchgegeven isn't equal to 'NEE' the construct is always created -->
		<xsl:if test="not($verwerkingsModus = 'matchgegevens' and ($matchgegeven = 'NEE' or empty($matchgegeven)))">
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-association-to-composite') and ($useStuurgegevens = 'no' and imvert:name = 'stuurgegevens')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1012',$debugging)"/>
				</xsl:when>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-association-to-composite')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1013',$debugging)"/>
					
					<xsl:call-template name="createRelatiePartOfAssociation">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
						<xsl:with-param name="type-id" select="$type-id"/>
					</xsl:call-template>			
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="imvert:association" mode="create-message-content-constructRef">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="context"/>
		<!--xsl:param name="orderingDesired" select="'yes'"/-->
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014',$debugging)"/>

		<!-- ROME: Als de association loopt van het berichttype naar een entiteit dan dient de variabele 'name' de naam van de entiteit te bevatten.
			 In alle andere gevallen wordt er een element niveau tussen gegenereerd met een 'gerelateerde' element en moet het de naam van de association bevatten. -->
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="construct" select="imf:get-class-construct-by-id($type-id,$packages-doc)"/>
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')">
					<xsl:value-of select="$construct/imvert:name"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and @typeCode ='toplevel']">
					<xsl:value-of select="imvert:name"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imvert:name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="tech-name">
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-relatiesoort')">
					<!--xsl:value-of
						select="imf:get-normalized-name(concat(imvert:name, imf:get-normalized-name(imvert:type-name, 'addition-relation-name')), 'element-name')"
					/-->
					<xsl:value-of
						select="imf:get-normalized-name(imvert:name, 'element-name')"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imf:get-normalized-name(imvert:name, 'element-name')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="position" select="imvert:position"/>
		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="matchgegeven" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEMATCHGEGEVEN')"/>
		<!--xsl:if test="empty($matchgegeven)">
			<xsl:sequence select="imf:msg(.,'WARNING','Unable to get the tagged value Indicatie kerngegeven. The object might not be defined in the supplier (UGM).','')"/>
		</xsl:if-->
		<xsl:variable name="alias">
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')">
					<xsl:value-of select="key('class',$type-id)/imvert:alias"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imvert:alias"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$debugging">
			<xsl:choose>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and ep:id = $id]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014a',$debugging)"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct/ep:construct[ep:id = $id and @context = $context]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014b',$debugging)"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct[ep:id = $id and @context = $context]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014c',$debugging)"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct/ep:construct[ep:id = $id]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014d',$debugging)"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct[ep:id = $id]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014e',$debugging)"/>
					<!--xsl:sequence select="imf:create-debug-comment(concat('ep:constructname: ',$currentMessage//ep:*[generate-id() = $generated-id]/ep:name,', @context :',$context,' ,id :',$id,' ,verwerkingsmodus :',$verwerkingsModus,' - ',$matchgegeven,'.'),$debugging)"/>
					<xsl:for-each select="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context and ep:construct[ep:id = $id]]">
						<xsl:sequence select="imf:create-debug-comment(concat('$receivedGenerated-id: ',$generated-id,', generatedId :',generate-id(.), ' (ep:generated-id :',$currentMessage//ep:*[generate-id() = $generated-id]/ep:generated-id,')'),$debugging)"/>
					</xsl:for-each-->
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct[ep:id = $type-id]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014f',$debugging)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1014h',$debugging)"/>
					<!--xsl:sequence select="imf:create-debug-comment(concat('ep:constructname: ',$currentMessage//ep:*[generate-id() = $generated-id]/ep:name,', @context :',$context,' ,id :',$id,' ,verwerkingsmodus :',$verwerkingsModus,' - ',$matchgegeven,'.'),$debugging)"/>
					<xsl:for-each select="$currentMessage//ep:*[@context = $context and ep:construct[ep:id = $id]]">
						<xsl:sequence select="imf:create-debug-comment(concat('$receivedGenerated-id: ',$generated-id,', generatedId :',generate-id(.), ' (ep:generated-id :',$currentMessage//ep:*[generate-id() = $generated-id]/ep:generated-id,')'),$debugging)"/>
					</xsl:for-each-->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:variable name="verwerkingsModusOfConstructRef">
			<xsl:choose>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and ep:id = $id]">
					<xsl:value-of select="$verwerkingsModus"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct/ep:construct[ep:id = $id and @context = $context]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct/ep:construct[ep:id = $id and @context = $context]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct[ep:id = $id and @context = $context]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:choice/ep:construct[ep:id = $id and @context = $context]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct/ep:construct[ep:id = $id]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct/ep:construct[ep:id = $id]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct[ep:id = $id]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct[ep:id = $id]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct[ep:id = $type-id]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id and @context = $context]/ep:construct[ep:id = $type-id]/@verwerkingsModus"/>										
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="berichtType">
			<xsl:choose>
				<xsl:when test="$berichtCode = 'La01' or $berichtCode = 'La02'">La0102</xsl:when>
				<xsl:when test="$berichtCode = 'La03' or $berichtCode = 'La04'">La0304</xsl:when>
				<xsl:when test="$berichtCode = 'La05' or $berichtCode = 'La06'">La0506</xsl:when>
				<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">La0708</xsl:when>
				<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">La0910</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv')">Lv</xsl:when>
				<xsl:when test="contains($berichtCode,'Lk')">Lk</xsl:when>
				<xsl:when test="(contains($berichtCode,'Di') or contains($berichtCode,'Du')) and $verwerkingsModusOfConstructRef = 'kennisgeving'">Lk</xsl:when>
				<xsl:when test="(contains($berichtCode,'Di') or contains($berichtCode,'Du')) and $verwerkingsModusOfConstructRef = 'antwoord'">La</xsl:when>
				<xsl:when test="(contains($berichtCode,'Di') or contains($berichtCode,'Du')) and $verwerkingsModusOfConstructRef = 'vraag'">Lv</xsl:when>
				<xsl:otherwise><xsl:value-of select="$berichtName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>
		<xsl:variable name="href">
			<xsl:choose>
				<xsl:when test="not(empty($verwerkingsModusOfConstructRef) or $verwerkingsModusOfConstructRef = '')">
					<!--xsl:value-of select="imf:create-complexTypeName($berichtType,$verwerkingsModusOfConstructRef,$alias,$name)"/-->					
					<xsl:value-of select="imf:create-complexTypeName($berichtType,$verwerkingsModusOfConstructRef,$alias,(),$subsetLabel)"/>					
				</xsl:when>
				<xsl:otherwise>
					<!--xsl:value-of select="imf:create-complexTypeName($berichtType,(),$alias,$name)"/-->					
					<xsl:value-of select="imf:create-complexTypeName($berichtType,(),$alias,(),$subsetLabel)"/>					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="suppliers" as="element(ep:suppliers)">
			<ep:suppliers>
				<xsl:copy-of select="imf:get-UGM-suppliers(.)"/>
			</ep:suppliers>
		</xsl:variable>
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DEFINITION')))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DEFINITION')"/>
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DESCRIPTION')))">
				<ep:description>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DESCRIPTION')"/>
				</ep:description>
			</xsl:if>
			<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')))">
				<ep:pattern>
					<ep:p>
						<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')"/>
					</ep:p>
				</ep:pattern>
			</xsl:if>
		</xsl:variable>
		
		<!-- The following construct is not created if the variable $verwerkingsModus is equal to 'matchgegevens' and the variable
		     $matchgegeven is equal to 'NEE'. So in case the $verwerkingsModus isn't equal to 'matchgegevens' and in case the $verwerkingsModus 
		     is equal to 'matchgegevens' and the variable $matchgegeven isn't equal to 'NEE' the construct is always created -->
		<xsl:if test="not($verwerkingsModus = 'matchgegevens' and ($matchgegeven = 'NEE' or empty($matchgegeven)))">
			<xsl:sequence select="imf:create-debug-comment('Debuglocation 1015',$debugging)"/>

			<xsl:sequence select="imf:create-debug-comment(concat('verwerkingsModusOfConstructRef: ',$verwerkingsModusOfConstructRef),$debugging)"/>
			
			<!-- Location: 'ep:constructRef1a'
								 Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-.xsl' on the location with the id 'ep:construct1'. -->
			
			<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
				<xsl:if test="$suppliers//supplier[1]/@verkorteAlias != ''">
					<xsl:attribute name="prefix" select="$suppliers//supplier[1]/@verkorteAlias"/>
					<xsl:attribute name="namespaceId" select="$suppliers//supplier[1]/@base-namespace"/>
					<xsl:attribute name="UGMlevel" select="$suppliers//supplier[1]/@level"/>
					<xsl:attribute name="version" select="$suppliers//supplier[1]/@version"/>
				</xsl:if>
				<xsl:if test="$debugging">
					<xsl:copy-of select="$suppliers"/>
				</xsl:if>
				<xsl:sequence select="imf:create-output-element('ep:name', $tech-name)"/>
				<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
				<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
				<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
				<xsl:sequence select="imf:create-output-element('ep:position', $position)"/>
				<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
				<xsl:sequence select="imf:create-output-element('ep:type-name', $href)"/>
			</ep:construct>

		</xsl:if>
	</xsl:template>

	<!-- This template (5) takes care of associations from a 'vrijbericht' type 
		to the other message types 'vraagbericht', 'antwoordbericht' and 'kennisgevingbericht'. -->
	<!-- ROME: De werking van dit template moet nog gecheckt worden zodra er 
		vrije berichten zijn. Waarschijnlijk moet er nog iets gebeuren met de context.
		Ook moet er nog voor gezorgd worden dat het 'functie' xml attribute gegenereerd wordt.-->
	<xsl:template match="imvert:association" mode="create-toplevel-message-structure">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1016',$debugging)"/>
		
		<!-- ROME: Kijken of hier nog meer ep elementen gegenereerd moeten worden. -->
		
		<ep:construct type="complexData" prefix="{$prefix}">
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
			<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
			<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
			<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1017',$debugging)"/>
					<!-- ROME: Volgende apply-templates moet het template aanschoppen 
						met als match 'imvert:association[imvert:stereotype='ENTITEITRELATIE']'en 
						als mode 'create-message-content'. -->
					<xsl:apply-templates select="." mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="'-'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-berichtrelatie')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1018',$debugging)"/>
					<xsl:variable name="type-id" select="imvert:type-id"/>
					<xsl:apply-templates
						select="
						imf:get-class-construct-by-id($type-id,$packages-doc)[imvert:stereotype = imf:get-config-stereotypes((
							'stereotype-name-vraagberichttype',
							'stereotype-name-antwoordberichttype',
							'stereotype-name-kennisgevingberichttype'))]"
						mode="create-toplevel-message-structure">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
			<ep:seq>
				<ep:construct prefix="StUF" ismetadata="yes" externalNamespace="yes">
					<xsl:sequence select="imf:create-output-element('ep:name', 'functie')"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', 'functie')"/>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', 1)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', 1)"/>
					<xsl:sequence select="imf:create-output-element('ep:enum', imvert:name/@original)"/>
				</ep:construct>
				<!-- ROME: Voor de volgende construct moet nog bepaald worden hoe het 
					zijn waarde krijgt. -->
				<!--ep:construct ismetadata="yes">
					<xsl:sequence select="imf:create-output-element('ep:tech-name', 'entiteittype')"/>
					<xsl:sequence select="imf:create-output-element('ep:enum', 'TODO')"/>
				</ep:construct-->
			</ep:seq>
		</ep:construct>
	</xsl:template>

	<xsl:template match="imvert:association" mode="create-toplevel-message-structure-constructRef">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="context"/>
		<xsl:param name="verwerkingsModus"/>

		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1019',$debugging)"/>
		
		<xsl:variable name="berichtType">
			<xsl:choose>
				<xsl:when test="$berichtCode = 'La01' or $berichtCode = 'La02'">La0102</xsl:when>
				<xsl:when test="$berichtCode = 'La03' or $berichtCode = 'La04'">La0304</xsl:when>
				<xsl:when test="$berichtCode = 'La05' or $berichtCode = 'La06'">La0506</xsl:when>
				<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">La0708</xsl:when>
				<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">La0910</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv')">Lv</xsl:when>
				<xsl:when test="contains($berichtCode,'Lk')">Lk</xsl:when>
				<xsl:otherwise><xsl:value-of select="$berichtName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="name" select="imvert:name/@original"/>
		<xsl:variable name="tech-name">
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-berichtrelatie')">
					<xsl:value-of select="imf:get-normalized-name(imvert:name, 'element-name')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imf:get-normalized-name(imvert:name, 'element-name')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="position" select="imvert:position"/>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="verwerkingsModusOfConstructRef">
			<xsl:choose>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct/ep:construct[ep:id = $type-id and @context = $context]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct/ep:construct[ep:id = $type-id and @context = $context]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct[ep:id = $type-id and @context = $context]/@verwerkingsModus"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="construct" select="imf:get-class-construct-by-id($type-id,$packages-doc)"/>
		<xsl:variable name="elementName" select="$construct/imvert:name"/>
		<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>
		<xsl:variable name="href" select="imf:create-complexTypeName($berichtType,(),(),(),$subsetLabel)"/>
		
		<!-- Location: 'ep:constructRefxxx'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructxxx'. -->
				
		<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
			<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
			<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
			<xsl:sequence select="imf:create-output-element('ep:max-occurs',$max-occurs)"/>
			<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
			<xsl:sequence select="imf:create-output-element('ep:position', $position)"/>
			<xsl:sequence select="imf:create-output-element('ep:type-name', $href)"/>
		</ep:construct>

	</xsl:template>

	<!-- This template (6) transforms an 'imvert:association' element of stereotype 'ENTITEITRELATIE' to an 'ep:construct' 
		element.. -->
	<xsl:template match="imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
		mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<!--xsl:param name="orderingDesired" select="'yes'"/-->
		<xsl:param name="generateHistorieConstruct" select="'Nee'"/>
		<xsl:param name="verwerkingsModus"/>

		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1020',$debugging)"/>
		
		<xsl:variable name="context">
			<xsl:choose>
				<xsl:when
					test="imvert:name = 'gelijk' or imvert:name = 'vanaf' or imvert:name = 'tot en met' or imvert:name = 'start' or imvert:name = 'scope'">
						<xsl:value-of select="imvert:name"/>
				</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="construct" select="imf:get-class-construct-by-id($type-id,$packages-doc)"/>
		<xsl:variable name="elementName" select="$construct/imvert:name"/>
		<xsl:variable name="verwerkingsModusOfConstructRef">
			<xsl:choose>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct/ep:construct[ep:id = $type-id and @context = $context]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct/ep:construct[ep:id = $type-id and @context = $context]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct[ep:id = $type-id and @context = $context]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct[ep:id = $type-id and @context = $context]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/@verwerkingsModus"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>

		<xsl:sequence select="imf:create-debug-comment(imvert:id,$debugging)"/>
		
		<xsl:choose>
			<xsl:when test="contains($berichtCode, 'La')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1021',$debugging)"/>

				<xsl:variable name="name" select="imvert:name"/>
				
				<xsl:if
					test="($berichtCode = 'La02' or $berichtCode = 'La04' or $berichtCode = 'La06' or $berichtCode = 'La08' or $berichtCode = 'La10') and imvert:max-occurs != '1'">
					<xsl:variable name="msg"
						select="concat('The element ', $name, ' has a maxOccurs of ', imvert:max-occurs, '. In asynchrone messages only a maxOccurs of 1 is allowed.')"/>
					<xsl:sequence select="imf:msg('ERROR', $msg)"/>
				</xsl:if>
				<!-- Location: 'ep:constructRef7'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct7'. -->
				<xsl:variable name="berichtType">
					<xsl:choose>
						<xsl:when test="$berichtCode = 'La01' or $berichtCode = 'La02'">La0102</xsl:when>
						<xsl:when test="$berichtCode = 'La03' or $berichtCode = 'La04'">La0304</xsl:when>
						<xsl:when test="$berichtCode = 'La05' or $berichtCode = 'La06'">La0506</xsl:when>
						<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">La0708</xsl:when>
						<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">La0910</xsl:when>
					</xsl:choose>
				</xsl:variable>
				
				<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
					<xsl:sequence select="imf:create-output-element('ep:name', 'antwoord')"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', 'antwoord')"/>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', 1)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', 0)"/>
					<xsl:sequence select="imf:create-output-element('ep:position', 200)"/>
					<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,'antwoord',(),$name)"/></xsl:variable>
					<!-- The prefix is added at a later stage because at this moment ti's not possible to determine the correct one. -->	
					<xsl:sequence select="imf:create-output-element('ep:type-name', concat($kv-prefix,':',$type-name))"/>
				</ep:construct>

			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lv')">
				
				<xsl:variable name="berichtType" select="'Lv'"/>
				<xsl:choose>
					<xsl:when test="$context = 'gelijk' or $context = 'vanaf' or $context = 'tot en met'">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1022',$debugging)"/>
						
						<!-- Location: 'ep:constructRefxxx'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructxxx'. -->

						<xsl:variable name="berichtType" select="'Lv'"/>
						
						<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<xsl:variable name="alias" select="key('class',$type-id)/imvert:alias"/>
							
							<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
							<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))"/>
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
							<ep:position>
								<xsl:choose>
									<xsl:when test="imvert:name = 'gelijk'">150</xsl:when>
									<xsl:when test="imvert:name = 'vanaf'">175</xsl:when>
									<xsl:when test="imvert:name = 'tot en met'">200</xsl:when>
								</xsl:choose>
							</ep:position>
							<xsl:choose>
								<xsl:when test="not(empty($alias))">
									<!--xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,'vraag',$alias,$elementName)"/></xsl:variable-->
									<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,'vraag',$alias,(),$subsetLabel)"/></xsl:variable>
									<!-- The prefix is added at a later stage because at this moment ti's not possible to determine the correct one. -->	
									<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
								</xsl:when>
								<xsl:otherwise>
									<!--xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,'vraag',(),$elementName)"/></xsl:variable-->
									<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,'vraag',(),(),$subsetLabel)"/></xsl:variable>
									<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
								</xsl:otherwise>
							</xsl:choose>
						</ep:construct>

					</xsl:when>
					<xsl:when test="$context = 'scope'">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1023',$debugging)"/>
						
						<!-- Location: 'ep:constructRef9'
							 Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct9'. -->
						
						<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
							<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', 1)"/>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', 0)"/>
							<xsl:sequence select="imf:create-output-element('ep:position', 225)"/>
							<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtName,'scope',(),'object')"/></xsl:variable>
							<!-- The prefix is added at a later stage because at this moment ti's not possible to determine the correct one. -->	
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($kv-prefix,':',$type-name))"/>
						</ep:construct>

					</xsl:when>
					<xsl:when test="$context = 'start'">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1024',$debugging)"/>
						
						<!-- Location: 'ep:constructRef8'
				 			 Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct8'. -->
						
						<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
							<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', 1)"/>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', 0)"/>
							<xsl:sequence select="imf:create-output-element('ep:position', 250)"/>
							<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtName,'scope',(),'object')"/></xsl:variable>
							<!-- The prefix is added at a later stage because at this moment ti's not possible to determine the correct one. -->	
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($kv-prefix,':',$type-name))"/>
						</ep:construct>

					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lk')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1025',$debugging)"/>
				
				<xsl:variable name="berichtType" select="'Lk'"/>
				<xsl:variable name="name" select="imvert:name"/>

				<!-- Location: 'ep:constructRef1'
								    Matches
								    with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
				<!-- ROME De volgende check moeten we n.m.m. nog ergens inbouwen. -->
				<xsl:if test="$name != 'object'">
					<xsl:variable name="msg"
						select="concat('Within a Lk messsage the element containing the entiteit must have the name object. Now it has the name ', $name, '.')"/>
					<xsl:sequence select="imf:msg('ERROR', $msg)"/>
				</xsl:if>
				<xsl:if
					test="imvert:max-occurs > 2 or imvert:max-occurs = 'unbounded'">
					<xsl:variable name="msg"
						select="concat('The element ', $name, ' has a maxOccurs of ', imvert:max-occurs, '. In Kennisgevingen only a maxOccurs of 1 and 2 is allowed.')"/>
					<xsl:sequence select="imf:msg('ERROR', $msg)"/>
				</xsl:if>
				<xsl:if test="imvert:min-occurs > 1">
					<xsl:variable name="msg"
						select="concat('The element ', $name, ' has a minOccurs of ', imvert:min-occurs, '. In Kennisgevingen only a minOccurs of 1 is allowed.')"/>
					<xsl:sequence select="imf:msg('WARNING', $msg)"/>
				</xsl:if>
				

				<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
					<xsl:variable name="alias" select="key('class',$type-id)/imvert:alias"/>
					
					<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $name)"/>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:position', 200)"/>
					<xsl:variable name="associationName" select="imvert:name"/>
					<xsl:variable name="verwerkingsModus" select="$currentMessage//ep:*[ep:id = $type-id and contains(ep:tech-name, $associationName)]/@verwerkingsModus"/>
					<!-- The prefix is added at a later stage because at this moment ti's not possible to determine the correct one. -->	
					<xsl:choose>
						<xsl:when test="not(empty($alias))">
							<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,$verwerkingsModus[1],$alias,(),$subsetLabel)"/></xsl:variable>
							<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,'kennisgeving',(),(),$subsetLabel)"/></xsl:variable>
							<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
						</xsl:otherwise>
					</xsl:choose>
				</ep:construct>

			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Sh')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1026',$debugging)"/>
				
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Sa')"> 
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1027',$debugging)"/>
				
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Di')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1028',$debugging)"/>
				
				<!-- Location: 'ep:constructRefxxx'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructxxx'. -->
				
				<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
					<xsl:variable name="alias" select="key('class',$type-id)/imvert:alias"/>

					<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:position', 200)"/>
					<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtName,(),$alias,(),$subsetLabel)"/></xsl:variable>
					<xsl:sequence select="imf:create-debug-comment(concat('berichtName: ',$berichtName,',alias: ',$alias,' elementName: ',$elementName),$debugging)"/>
					<!-- At this stage it's not possible to determine the prefix since it's not clear if the type refering to contains attributes of the KV namespace or not. -->
					<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
					<!-- ROME: In het geval van een entiteitrelatie in een vrij bericht moet in alle namen van alle onderliggende complexTtypes en dus ook de verwijzingen daarheen
							   de naam van die entiteitrelatie opgenomen worden. Dit om alle compelxTypes uniek te kunnen identificeren. 
							   Bij de aanmaak van de complexType moet die naam dan natuurlijk ook meegenomen worden. -->
				</ep:construct>

			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Du')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1029',$debugging)"/>
				
				<!-- Location: 'ep:constructRefxxx'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructxxx'. -->
				
				<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
					<xsl:variable name="alias" select="key('class',$type-id)/imvert:alias"/>

					<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:position', 200)"/>
					<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtName,(),$alias,(),$subsetLabel)"/></xsl:variable>
					<!-- At this stage it's not possible to determine the prefix since it's not clear if the type refering to contains attributes of the KV namespace or not. -->
					<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
					<!-- ROME: In het geval van een entiteitrelatie in een vrij bericht moet in alle namen van alle onderliggende complexTtypes en dus ook de verwijzingen daarheen
							   de naam van die entiteitrelatie opgenomen worden. Dit om alle compelxTypes uniek te kunnen identificeren. 
							   Bij de aanmaak van de complexType moet die naam dan natuurlijk ook meegenomen worden. -->
				</ep:construct>				

			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- This template (7) transforms an 'imvert:attribute' element to an 'ep:construct' 
		element. -->
	<xsl:template match="imvert:attribute" mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="context"/>
		<xsl:param name="generateHistorieConstruct" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="fundamentalMnemonic" select="''"/>
		<xsl:param name="verwerkingsModus"/>
		<xsl:param name="processType" select="''"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1030',$debugging)"/>

		<xsl:variable name="berichtType">
			<xsl:choose>
				<xsl:when test="$berichtCode = 'La01' or $berichtCode = 'La02'">La0102</xsl:when>
				<xsl:when test="$berichtCode = 'La03' or $berichtCode = 'La04'">La0304</xsl:when>
				<xsl:when test="$berichtCode = 'La05' or $berichtCode = 'La06'">La0506</xsl:when>
				<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">La0708</xsl:when>
				<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">La0910</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv')">Lv</xsl:when>
				<xsl:when test="contains($berichtCode,'Lk')">Lk</xsl:when>
				<xsl:otherwise><xsl:value-of select="$berichtName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="name" select="imvert:name/@original"/>
		<xsl:variable name="baretype" select="imvert:baretype"/>
		<xsl:variable name="tech-name" select="imf:get-normalized-name(imvert:name, 'element-name')"/>
		<xsl:variable name="type-name" select="imvert:type-name"/>
		<xsl:variable name="type-modifier" select="imvert:type-modifier"/>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="position" select="imvert:position"/>
		<xsl:variable name="max-length" select="imvert:max-length"/>
		<xsl:variable name="total-digits" select="imvert:total-digits"/>
		<xsl:variable name="fraction-digits" select="imvert:fraction-digits"/>
		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="onvolledigeDatum">
			<xsl:choose>
				<xsl:when test="imvert:type-modifier = '?'">yes</xsl:when>
				<xsl:otherwise>no</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DEFINITION')))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DEFINITION')"/>
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DESCRIPTION')))">
				<ep:description>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DESCRIPTION')"/>
				</ep:description>
			</xsl:if>
			<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')))">
				<ep:pattern>
					<ep:p>
						<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')"/>
					</ep:p>
				</ep:pattern>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="suppliers" as="element(ep:suppliers)">
			<ep:suppliers>
				<xsl:copy-of select="imf:get-UGM-suppliers(.)"/>
			</ep:suppliers>
		</xsl:variable>
		<xsl:variable name="tvs" as="element(ep:tagged-values)">
			<ep:tagged-values>
				<xsl:copy-of select="imf:get-compiled-tagged-values(., true())"/>
			</ep:tagged-values>
		</xsl:variable>
		<xsl:variable name="matchgegeven" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEMATCHGEGEVEN')"/>
		<!-- ROME: Met de volgende variabelen wordt bepaald of materiele en/of formele historie voor het attribute van toepassing is.
				   Indien het attribute in een groep zit waarvoor historie niet van toepassing is maar op een van de groepsattributen wel 
				   dan is in beide variabelen de eerste when tak van toepassing en wordt daarmee bepaald of de betreffende historietype  
				   van toepassing is op het attribute.
				   Indien het attribute in een groep zit waarvoor historie van toepassing op de groep zelf 
				   dan is in beide variabelen de eerste when tak van toepassing en wordt daarmee bepaald of de betreffende historietype  
				   van toepassing is op het attribute.
				   Indien het attribute niet in een groep zit dan is in beide variabelen de otherwise tak van toepassing. -->
		<xsl:variable name="materieleHistorie">
			<xsl:choose>
				<xsl:when test="$indicatieMaterieleHistorie = 'Ja op attributes' and contains(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY'),'JA')">
					<xsl:value-of select="'Ja'"/>
				</xsl:when>
				<xsl:when test="$indicatieMaterieleHistorie = 'Ja op attributes' and not(contains(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY'),'JA'))">
					<xsl:value-of select="'Nee'"/>
				</xsl:when>
				<xsl:when test="$indicatieMaterieleHistorie = 'Ja'">
					<xsl:value-of select="'Ja'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="formeleHistorie">
			<xsl:choose>
				<xsl:when test="$indicatieFormeleHistorie = 'Ja op attributes' and contains(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY'),'JA')">
					<xsl:value-of select="'Ja'"/>
				</xsl:when>
				<xsl:when test="$indicatieFormeleHistorie = 'Ja op attributes' and not(contains(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY'),'JA'))">
					<xsl:value-of select="'Nee'"/>
				</xsl:when>
				<xsl:when test="$indicatieFormeleHistorie = 'Ja'">
					<xsl:value-of select="'Ja'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="authentiek" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONAUTHENTIC')"/>
		<xsl:variable name="inOnderzoek" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEINONDERZOEK')"/>
		<xsl:variable name="min-waarde" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-MINVALUEINCLUSIVE')"/>
		<xsl:variable name="max-waarde" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-MAXVALUEINCLUSIVE')"/>
		<xsl:variable name="min-length" select="xs:integer(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-MINLENGTH'))"/>
		<xsl:variable name="patroon" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')"/>
		<xsl:variable name="formeelPatroon" select="imvert:pattern"/>		
		<xsl:variable name="compiled-name" select="imf:useable-attribute-name(imf:get-compiled-name(.),.)"/>
		<xsl:variable name="checksum-strings" select="imf:get-blackboard-simpletype-entry-info(.)"/>
		<xsl:variable name="checksum-string" select="imf:store-blackboard-simpletype-entry-info($checksum-strings)"/>
		<xsl:variable name="construct" as="element()">
			<xsl:choose>
				<xsl:when test="imvert:type-id">
					<xsl:sequence select="imf:get-class-construct-by-id(imvert:type-id,$packages-doc)"/>
				</xsl:when>
				<xsl:otherwise>
					<imvert:no-construct/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- The following construct is a.o. not created if the variable $verwerkingsModus is equal to 'matchgegevens' and the variable
		     $matchgegeven is equal to 'NEE'. So in case the $verwerkingsModus isn't equal to 'matchgegevens' and in case the $verwerkingsModus 
		     is equal to 'matchgegevens' and the variable $matchgegeven isn't equal to 'NEE' the construct is always created -->
		<xsl:if test="not(contains($verwerkingsModus, 'matchgegeven') and ($matchgegeven = 'NEE' or empty($matchgegeven))) and (($generateHistorieConstruct = 'MaterieleHistorie' and contains($materieleHistorie, 'Ja')) or ($generateHistorieConstruct = 'FormeleHistorie' and contains($formeleHistorie, 'Ja')) or ($generateHistorieConstruct = 'FormeleHistorieRelatie' and contains($formeleHistorie, 'Ja')) or $generateHistorieConstruct = 'Nee')">

			<xsl:choose>
				<xsl:when test="$processType = 'keyTabelEntiteit'">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1031',$debugging)"/>
					
					<xsl:variable name="tokens" select="tokenize($checksum-string,'\[SEP\]')"/>

					<xsl:variable name="construct-Prefix" select="$suppliers//supplier[1]/@verkorteAlias"/>
					
					<xsl:variable name="type-is-scalar-non-emptyable" select="imvert:type-name = ('scalar-integer','scalar-decimal')"/>
					<xsl:choose>
						<xsl:when test="$global-e-types-allowed = 'Ja'">
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($construct-Prefix,':',$tokens[1],'-e'))"/>							
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($construct-Prefix,':',$tokens[1]))"/>							
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="($type-is-scalar-non-emptyable) and not(ancestor::imvert:package[contains(@formal-name,'Berichtstructuren')])">
						<xsl:sequence select="imf:create-output-element('ep:voidable', 'true')"/>
					</xsl:if>						
				</xsl:when>
				<xsl:when test="imvert:type-id and $construct/imvert:stereotype/@id = ('stereotype-name-complextype')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1032',$debugging)"/>
					
					
					<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>
					<xsl:variable name="type" select="'Grp'"/>
					<xsl:variable name="name" select="//imvert:class[imvert:id = $type-id]/imvert:name/@original"/>
					
					<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
						<xsl:if test="$suppliers//supplier[1]/@verkorteAlias != ''">
							<xsl:attribute name="prefix" select="$suppliers//supplier[1]/@verkorteAlias"/>
							<xsl:attribute name="namespaceId" select="$suppliers//supplier[1]/@base-namespace"/>
							<xsl:attribute name="UGMlevel" select="$suppliers//supplier[1]/@level"/>
							<xsl:attribute name="version" select="$suppliers//supplier[1]/@version"/>
						</xsl:if>
						<xsl:if test="$debugging">
							<ep:tagged-values>
								<xsl:copy-of select="$tvs"/>
								<ep:found-tagged-values>
									<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
									<xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
									<xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
									<xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
									<xsl:sequence select="imf:create-output-element('ep:min-length', $min-length)"/>
									<xsl:sequence select="imf:create-output-element('ep:max-value', $max-waarde)"/>
									<xsl:sequence select="imf:create-output-element('ep:min-value', $min-waarde)"/>
									<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)"/>
									<xsl:sequence select="imf:create-output-element('ep:formeel-patroon', $formeelPatroon)"/>
								</ep:found-tagged-values>
							</ep:tagged-values>
						</xsl:if>
						<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
						<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
						<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
						<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
						<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
						<xsl:sequence select="imf:create-output-element('ep:position', $position)"/>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', imf:create-Grp-complexTypeName($berichtType,$type,$name,$verwerkingsModus,$subsetLabel))" />
					</ep:construct>

				</xsl:when>
				<xsl:when test="imvert:type-id and //imvert:class[imvert:id = $type-id]/imvert:stereotype/@id = ('stereotype-name-referentielijst')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1033',$debugging)"/>
					<xsl:sequence select="imf:create-debug-comment($type-id,$debugging)"/>
					
					<xsl:variable name="type" select="'Grp'"/>
					<xsl:variable name="name" select="//imvert:class[imvert:id = $type-id]/imvert:name/@original"/>
					
					<ep:construct type="complexData">
						<xsl:if test="$suppliers//supplier[1]/@verkorteAlias != ''">
							<xsl:attribute name="prefix" select="$suppliers//supplier[1]/@verkorteAlias"/>
							<xsl:attribute name="namespaceId" select="$suppliers//supplier[1]/@base-namespace"/>
							<xsl:attribute name="UGMlevel" select="$suppliers//supplier[1]/@level"/>
							<xsl:attribute name="version" select="$suppliers//supplier[1]/@version"/>
						</xsl:if>
						<xsl:if test="$debugging">
							<ep:tagged-values>
								<xsl:copy-of select="$tvs"/>
								<ep:found-tagged-values>
									<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>									
									<xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
									<xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
									<xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
									<xsl:sequence select="imf:create-output-element('ep:min-length', $min-length)"/>
									<xsl:sequence select="imf:create-output-element('ep:max-value', $max-waarde)"/>
									<xsl:sequence select="imf:create-output-element('ep:min-value', $min-waarde)"/>
									<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)"/>
									<xsl:sequence select="imf:create-output-element('ep:formeel-patroon', $formeelPatroon)"/>
								</ep:found-tagged-values>
							</ep:tagged-values>
						</xsl:if>
						<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
						<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
						<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>						
						<xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
						<xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
						<xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
						<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
						<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
						<xsl:sequence select="imf:create-output-element('ep:position', $position)"/>
						
						<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]/imvert:attributes/imvert:attribute[imvert:is-id = 'true']"  mode="create-message-content">
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="berichtName" select="$berichtName"/>
							<xsl:with-param name="generated-id" select="$generated-id"/>
							<xsl:with-param name="currentMessage" select="$currentMessage"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
							<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
							<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
							<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
							<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
							<xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
							<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
							<xsl:with-param name="processType" select="'keyTabelEntiteit'"/>
						</xsl:apply-templates>
					</ep:construct>
				</xsl:when>
				<xsl:otherwise>				
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034',$debugging)"/>

					<xsl:variable name="checksum-strings" select="imf:get-blackboard-simpletype-entry-info(.)"/>
					<xsl:variable name="checksum-string" select="imf:store-blackboard-simpletype-entry-info($checksum-strings)"/>
					<xsl:variable name="tokens" select="tokenize($checksum-string,'\[SEP\]')"/>
					<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-SUBSETLABEL')"/>
					
					<!-- ROME: Uitbecommentarieerde variabele is vervangen door de die daaronder.
                   Dit is slechts tijdelijk todat er een alternatieve constructie is voor het definieren van custom stuurgegevens en parameters. -->
					
					<!--xsl:variable name="construct-Prefix" select="$suppliers//supplier[1]/@verkorteAlias"/-->
					<xsl:variable name="construct-Prefix">
						<xsl:choose>
							<xsl:when test="$suppliers//supplier[1]/@verkorteAlias != ''">
								<xsl:value-of select="$suppliers//supplier[1]/@verkorteAlias"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'StUF'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<ep:construct type="complexData">
						<xsl:if test="$suppliers//supplier[1]/@verkorteAlias != ''">
							<xsl:attribute name="prefix" select="$suppliers//supplier[1]/@verkorteAlias"/>
							<xsl:attribute name="namespaceId" select="$suppliers//supplier[1]/@base-namespace"/>
							<xsl:attribute name="UGMlevel" select="$suppliers//supplier[1]/@level"/>
							<xsl:attribute name="version" select="$suppliers//supplier[1]/@version"/>
						</xsl:if>
						<ep:suppliers>
							<xsl:copy-of select="$suppliers"/>
						</ep:suppliers>
						<xsl:if test="$debugging">
							<ep:tagged-values>
								<xsl:copy-of select="$tvs"/>
								<ep:found-tagged-values>
									<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>									
									<xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
									<xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
									<xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
									<xsl:sequence select="imf:create-output-element('ep:min-length', $min-length)"/>
									<xsl:sequence select="imf:create-output-element('ep:max-value', $max-waarde)"/>
									<xsl:sequence select="imf:create-output-element('ep:min-value', $min-waarde)"/>
									<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)"/>
									<xsl:sequence select="imf:create-output-element('ep:formeel-patroon', $formeelPatroon)"/>
								</ep:found-tagged-values>
							</ep:tagged-values>
						</xsl:if>
						<xsl:variable name="compiled-name" select="imf:useable-attribute-name(imf:get-compiled-name(.),.)"/>
						<xsl:variable name="type-name" select="imf:capitalize($compiled-name)"/>
						<xsl:variable name="stuf-scalar" select="imf:get-stuf-scalar-attribute-type(.)"/>
						<xsl:variable name="conceptual-schema-type" select="imvert:conceptual-schema-type"/>

						<xsl:variable name="type-is-scalar-non-emptyable" select="imvert:type-name = ('scalar-integer','scalar-decimal')"/>

						<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
						<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
						
						
						<!-- ROME: nagaan of het testen op imvert:type-package='GML3' hier nog wel van toepassing is. Ten eerste omdat het de vraag is of
							 imvert:type-package nog wel de waarde 'GML3' kan hebben en ten tweede omdat ik geen idee meer heb waarom ik daar in het verleden 
							 op heb laten testen. -->
						<xsl:variable name="vraagIndicatie">
							<xsl:choose>
								<xsl:when test="contains($berichtCode,'Lv') and 
												(
													(imvert:type-package='GML3' and (empty($formeelPatroon) or $min-length = 0)) or 
													((empty($formeelPatroon) or $min-length = 0) and starts-with($checksum-string,'String'))
												)">
									<xsl:value-of select="'Vraag'"/>
								</xsl:when>
								<xsl:otherwise/>
							</xsl:choose>
						</xsl:variable>
						
						<xsl:choose> 
							<xsl:when test="not(empty($conceptual-schema-type))">
								<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-external-type-name(.,true()))"/>
							</xsl:when>
							<xsl:when test="imvert:type-package='GML3'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034a',$debugging)"/>
								<xsl:choose>
									<xsl:when test="$global-e-types-allowed = 'Ja'">
										<xsl:sequence select="imf:create-output-element('ep:type-name', concat($construct-Prefix,':',imf:capitalize(imvert:baretype),$vraagIndicatie,'-e'))"/>										
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="imf:get-external-type-name(.,true())"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$name = 'melding' and (ancestor::imvert:package/imvert:name = 'Model [Berichtstructuren]' or ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen')">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034b',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',imf:capitalize($name)))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'Berichtcode' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034c',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype,$berichtCode))"/>
							</xsl:when>
							<xsl:when test="($baretype = 'Organisatie' or $baretype = 'Applicatie' or $baretype = 'Administratie' or $baretype = 'Gebruiker') and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034d',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="($baretype = 'Refnummer' or $name = 'crossRefnummer') and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034e',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'Functie' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034f',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$name = 'tijdstipBericht' and $baretype = 'Tijdstip' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034g',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':','dateTime'))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'Sortering' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034i',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$name = 'indicatorVervolgvraag' and $baretype = 'INDIC' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034j',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-boolean')"/>
							</xsl:when>
							<xsl:when test="$baretype = 'MaximumAantal' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034k',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$name = 'indicatorAfnemerIndicatie' and $baretype = 'INDIC' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034l',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-boolean')"/>
							</xsl:when>
							<xsl:when test="$name = 'peiltijdstipMaterieel' and $baretype = 'Tijdstip' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034m',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-dateTime')"/>
							</xsl:when>
							<xsl:when test="$name = 'peiltijdstipFormeel' and $baretype = 'Tijdstip' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034n',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-dateTime')"/>
							</xsl:when>
							<xsl:when test="$name = 'indicatorAantal' and $baretype = 'INDIC' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034o',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-boolean')"/>
							</xsl:when>
							<xsl:when test="$baretype = 'IndicatorHistorie' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034p',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'AantalVoorkomens' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034q',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'Volgnummer' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034r',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$name = 'indicatorLaatsteBericht' and $baretype = 'INDIC' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034s',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-boolean')"/>
							</xsl:when>
							<!-- ROME: Volgende when voldoet voorlopig maar moet vanuit EA zo gewijzigd kunnen worden dat er slechts 1 mutatiesoort enum is. -->
							<xsl:when test="$baretype = 'Mutatiesoort' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034t',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'IndicatorOvername' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034u',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'Sectormodel' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034v',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':','Entiteittype'))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'Versienr' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034w',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$baretype))"/>
							</xsl:when>
							<xsl:when test="$baretype = 'Entiteittype' and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034x',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':','Entiteittype'))"/>
							</xsl:when>
							<xsl:when test="not(imvert:type-id) and ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen' and imf:get-most-relevant-compiled-taggedvalue(ancestor::imvert:class, '##CFG-TV-SUBSETLABEL')">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034y',$debugging)"/>
								<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(ancestor::imvert:class, '##CFG-TV-SUBSETLABEL')"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',concat(imf:capitalize($name),'-',$subsetLabel)))"/>
							</xsl:when>
							<xsl:when test="ancestor::imvert:class/imvert:alias = '/www.kinggemeenten.nl/BSM/Berichtstrukturen' and imf:get-most-relevant-compiled-taggedvalue(ancestor::imvert:class, '##CFG-TV-SUBSETLABEL')">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034z',$debugging)"/>
								<xsl:variable name="compiled-typename" select="imf:get-compiled-typename(.)"/>
								<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(ancestor::imvert:class, '##CFG-TV-SUBSETLABEL')"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',concat(imf:capitalize($compiled-typename),'-',$subsetLabel)))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-date' and $global-e-types-allowed = 'Ja'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034aa',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':Datum-e'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-date' and $global-e-types-allowed = 'Nee'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ab',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':Datum-r'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-datetime' and $global-e-types-allowed = 'Ja'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ac',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':Tijdstip-e'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-datetime' and $global-e-types-allowed = 'Nee'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ad',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':Tijdstip-r'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-year' and $global-e-types-allowed = 'Ja'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ae',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':Jaar-e'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-year' and $global-e-types-allowed = 'Nee'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034af',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':Jaar-r'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-yearmonth'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ag',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':JaarMaand-e'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-postcode'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ah',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':Postcode-e'))"/>
							</xsl:when>
							<xsl:when test="imvert:type-name = 'scalar-boolean'">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ai',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':INDIC-e'))"/>
							</xsl:when>
							<xsl:when test="starts-with(imvert:type-name,'GM_')">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034aj',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-external-type-name(.,true()))"/>
							</xsl:when>
							<xsl:when test="not(contains(imvert:type-name,'scalar'))">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034ak',$debugging)"/>
								<xsl:choose>
									<xsl:when test="$global-e-types-allowed = 'Ja'">
										<xsl:sequence select="imf:create-output-element('ep:type-name', concat($construct-Prefix,':',imf:capitalize(imvert:type-name),$vraagIndicatie,'-e'))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="imf:create-output-element('ep:type-name', concat($construct-Prefix,':',imf:capitalize(imvert:type-name)))"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1034al',$debugging)"/>
								<xsl:choose>
									<xsl:when test="$global-e-types-allowed = 'Ja'">
										<xsl:sequence select="imf:create-output-element('ep:type-name', concat($construct-Prefix,':',$tokens[1],$vraagIndicatie,'-e'))"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="imf:create-output-element('ep:type-name', concat($construct-Prefix,':',$tokens[1]))"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
						<xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
						<xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
						<xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
						<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
						<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
						<xsl:choose>
							<xsl:when test="$tech-name = 'entiteitType' and not(empty($fundamentalMnemonic))">
								<xsl:sequence select="imf:create-output-element('ep:enum', $fundamentalMnemonic)"/>
							</xsl:when>
							<xsl:when test="$tech-name = 'berichtcode'">
								<xsl:sequence select="imf:create-output-element('ep:enum', $berichtCode)"/>
							</xsl:when>
						</xsl:choose>
						<xsl:sequence select="imf:create-output-element('ep:position', $position)"/>

						<xsl:if test="$type-is-scalar-non-emptyable and
										$name != 'melding' and
										$name != 'berichtcode' and
										$name != 'organisatie' and 
										$name != 'applicatie' and 
										$name != 'administratie' and 
										$name != 'gebruiker' and
										$name != 'referentienummer' and 
										$name != 'crossRefnummer' and
										$name != 'entiteitType' and
										$name != 'sortering' and
										$name != 'indicatorVervolgvraag' and
										$name != 'maximumAantal' and
										$name != 'indicatorAfnemerIndicatie' and
										$name != 'peiltijdstipMaterieel' and
										$name != 'peiltijdstipFormeel' and
										$name != 'indicatorAantal' and
										$name != 'indicatorHistorie' and
										$name != 'aantalVoorkomens' and
										$name != 'volgnummer' and
										$name != 'indicatorLaatsteBericht' and
										$name != 'mutatiesoort' and
										$name != 'indicatorOvername'">
							<xsl:sequence select="imf:create-output-element('ep:voidable', 'true')"/>
						</xsl:if>						
					</ep:construct>
				</xsl:otherwise>
			</xsl:choose>
			<!--/xsl:if-->
		</xsl:if>
	</xsl:template>

	<!-- This template (8) generates the structure of a relatie on a relatie. -->
	<!-- ROME: De werking van dit template moet adhv van een voorbeeld gecheckt 
		en mogelijk geoptimaliseerd worden. Zo is de vraag of een association-class 
		een supertype kan hebben. Zo ja dan moeten er nog apply-templates worden 
		opgenomen voor het verwerken van de supertypes. -->
	<xsl:template match="imvert:association-class" mode="create-message-content">
		<xsl:param name="proces-type" select="'associations'"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="context"/>
		<xsl:param name="generateHistorieConstruct" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1035',$debugging)"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>
		
		<xsl:choose>
			<!-- Following when processes the attributes of the association-class. -->
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1036',$debugging)"/>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="berichtName" select="$berichtName"/>
					<xsl:with-param name="generated-id" select="$generated-id"/>
					<xsl:with-param name="currentMessage" select="$currentMessage"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
					<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
					<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
					<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
					<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
					<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- Following otherwise processes the relatie type associations and group 
				compositie associations of the association-class. -->
			<xsl:otherwise>
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1037',$debugging)"/>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="berichtName" select="$berichtName"/>
					<xsl:with-param name="generated-id" select="$generated-id"/>
					<xsl:with-param name="currentMessage" select="$currentMessage"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
					<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
					<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
					<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
					<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
					<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<!-- ROME: Aangezien een association-class alleen de attributen levert 
			van een relatie en dat relatie element al ergens anders zijn XML-attributes 
			toegekend krijgt hoeven er hier geen attributes meer toegekend te worden. -->
	</xsl:template>

	<!-- This template generates the structure of the 'gerelateerde' type element. -->
	<xsl:template name="createRelatiePartOfAssociation">
		<xsl:param name="type-id"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="context"/>
		<!-- The following parameter determines if the current construct being generated is a 'historieMaterieel', a 'historieFormeel' or 'historieFormeelRelatie' construct.
			 If the variable 'generateHistorieConstruct' has the value 'Nee' a normal construct is generated. -->
		<xsl:param name="generateHistorieConstruct" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieMaterieleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorieRelatie" select="'Nee'"/>
		<xsl:param name="verwerkingsModus"/>		

		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1038',$debugging)"/>

		<xsl:variable name="berichtType">
			<xsl:choose>
				<xsl:when test="$berichtCode = 'La01' or $berichtCode = 'La02'">La0102</xsl:when>
				<xsl:when test="$berichtCode = 'La03' or $berichtCode = 'La04'">La0304</xsl:when>
				<xsl:when test="$berichtCode = 'La05' or $berichtCode = 'La06'">La0506</xsl:when>
				<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">La0708</xsl:when>
				<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">La0910</xsl:when>
				<xsl:when test="contains($berichtCode,'Lv')">Lv</xsl:when>
				<xsl:when test="contains($berichtCode,'Lk')">Lk</xsl:when>
				<xsl:otherwise><xsl:value-of select="$berichtName"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="tech-name">
			<xsl:choose>
				<xsl:when test="imvert:name = 'zender' or imvert:name = 'ontvanger'"><xsl:value-of select="'Systeem'"/></xsl:when>
				<xsl:when test="@className"><xsl:value-of select="@className"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="imvert:name"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="verwerkingsModusOfConstructRef">
			<xsl:choose>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct/ep:construct[ep:id = $type-id and @context = $context]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct/ep:construct[ep:id = $type-id and @context = $context]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:when test="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct[ep:id = $type-id and @context = $context]">
					<xsl:value-of select="$currentMessage//ep:*[generate-id() = $generated-id]/ep:construct[ep:id = $type-id and @context = $context]/@verwerkingsModus"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$verwerkingsModus"/>
				</xsl:otherwise>				
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="suppliers" as="element(ep:suppliers)">
			<ep:suppliers>
				<xsl:copy-of select="imf:get-UGM-suppliers(.)"/>
			</ep:suppliers>
		</xsl:variable>
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DEFINITION')))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DEFINITION')"/>
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DESCRIPTION')))">
				<ep:description>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DESCRIPTION')"/>
				</ep:description>
			</xsl:if>
			<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')))">
				<ep:pattern>
					<ep:p>
						<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')"/>
					</ep:p>
				</ep:pattern>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(imf:get-association-construct-by-id(imvert:type-id,$packages-doc), '##CFG-TV-SUBSETLABEL')"/>		
		<xsl:variable name="name">
			<xsl:choose>
				<xsl:when test="imvert:name = 'stuurgegevens'">
					<xsl:value-of select="concat('Stuurgegevens',$berichtCode)"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and contains('Lv01 Lv02 Lv03 Lv04 Lv05 Lv06 Lv07 Lv08 Lv09 Lv10',$berichtCode)">
					<xsl:value-of select="'ParametersVraag'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and contains('La01 La07 La09',$berichtCode)">
					<xsl:value-of select="'ParametersAntwoordSynchroon'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and $berichtCode = 'La05'">
					<xsl:value-of select="'ParametersAntwoordSynchroonFormeel'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and $berichtCode = 'La03'">
					<xsl:value-of select="'ParametersAntwoordSynchroonMaterieel'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and contains('La02 La08 La10',$berichtCode)">
					<xsl:value-of select="'ParametersAntwoordAsynchroon'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and $berichtCode = 'La06'">
					<xsl:value-of select="'ParametersAntwoordAsynchroonFormeel'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and $berichtCode = 'La04'">
					<xsl:value-of select="'ParametersAntwoordAsynchroonMaterieel'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and $berichtCode = 'Lk01'">
					<xsl:value-of select="'ParametersLk01'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and $berichtCode = 'Lk02'">
					<xsl:value-of select="'ParametersLk02'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and contains('Lk05 Lk06',$berichtCode)">
					<xsl:value-of select="'ParametersKennisgeving'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and contains('Di01 Di02 Du01 Du02',$berichtCode) and $context = 'update'">
					<xsl:value-of select="'ParametersKennisgeving'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and contains('Di01 Di02 Du01 Du02',$berichtCode) and $context = 'selectie'">
					<xsl:value-of select="'ParametersVraag-basis'"/>
				</xsl:when>
				<xsl:when test="imvert:name = 'parameters' and contains('Di01 Di02 Du01 Du02',$berichtCode) and $context = 'antwoord'">
					<xsl:value-of select="'ParametersAntwoord'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imvert:name"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="construct" as="element()">
			<xsl:choose>
				<xsl:when test="$type-id != ''">
					<xsl:sequence select="imf:get-class-construct-by-id($type-id,$packages-doc)"/>
				</xsl:when>
				<xsl:otherwise>
					<imvert:no-construct/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		

		<!-- I.h.k.v. RM #488759 moet ik op termijn op basis van $alias een specifieke 'EntiteittypeStuurgegevens' per bericht maken. -->
		<xsl:variable name="alias" select="$currentMessage//ep:construct[@alias][1]/@alias"/>
		
			<xsl:choose>
				<xsl:when test="key('class',$type-id) and imvert:stereotype/@id = ('stereotype-name-relatiesoort')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1039',$debugging)"/>
					
					<xsl:variable name="mnemonic" select="key('class',$type-id)/imvert:alias"/>
					<xsl:variable name="elementName" select="$construct/imvert:name"/>
					<xsl:choose>
						<xsl:when test="($generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie, 'Ja')) or ($generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie, 'Ja'))">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1040',$debugging)"/>
							
						</xsl:when>
						<xsl:when test="$generateHistorieConstruct = 'FormeleHistorieRelatie' and contains($indicatieFormeleHistorieRelatie, 'Ja')">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1041',$debugging)"/>
							
							
							
							<!-- De volgende when is tijdelijk buiten gebruik gesteld zodat de huidige versie van de stylesheets uitgerold kan worden zonder dat dit invalide bestanden oplevert. -->
							
							
							
							
							<!-- The association is a 'relatie' and because no historieMaterieel or historieFormeel is generated it has to contain a 'gerelateerde' constructRef. -->
							
							<!-- Location: 'ep:constructRef1b'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
							
							<!--ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
								<ep:name>gerelateerde</ep:name>
								<ep:tech-name>gerelateerde</ep:tech-name>
								<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
								<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
								<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
								<ep:position>1</ep:position>
								<xsl:sequence select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtName,'matchgegevens',$mnemonic,$elementName))"/>							
							</ep:construct-->

						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1042',$debugging)"/>
							<!-- The association is a 'relatie' and because no historieMaterieel or historieFormeel is generated it has to contain a 'gerelateerde' constructRef. -->
							
							<!-- Location: 'ep:constructRef1b'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
							
							<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
								<ep:name>gerelateerde</ep:name>
								<ep:tech-name>gerelateerde</ep:tech-name>
								<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
								<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
								<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
								<ep:position>1</ep:position>
								<xsl:choose>
									<xsl:when test="not(empty($verwerkingsModusOfConstructRef)) and $verwerkingsModusOfConstructRef != ''">
										<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,$verwerkingsModusOfConstructRef,$mnemonic,(),$subsetLabel)"/></xsl:variable>
										<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="type-name"><xsl:value-of select="imf:create-complexTypeName($berichtType,(),$mnemonic,(),$subsetLabel)"/></xsl:variable>
										<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
									</xsl:otherwise>
								</xsl:choose>
							</ep:construct>

						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1043',$debugging)"/>
					<!-- The following 'apply-templates' initiates the processing of the 
						class which contains the attributes of the 'relatie' type element. -->
					<xsl:apply-templates select="imvert:association-class"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<!-- The following 'apply-templates' initiates the processing of the 
						class which contains the attributegroups of the 'relatie' type element. -->
					<xsl:apply-templates select="imvert:association-class"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<!-- Following element are not allowed in constructs for 'matchgegevens. -->
					<xsl:if test="not(contains(@verwerkingsModus,'matchgegevens'))">
						<xsl:if test="($generateHistorieConstruct != 'MaterieleHistorie' and not(contains($indicatieMaterieleHistorie, 'Ja'))) and 
							($generateHistorieConstruct != 'FormeleHistorie' and not(contains($indicatieFormeleHistorie, 'Ja')))">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1044',$debugging)"/>

							<!-- ep:authentiek element is used to determine if a 'authentiek' element needs to be generated in the messages in the next higher level. -->
							<!--xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/-->


							<!-- ROME: RFC0486 RFC: Metagegeven <authentiek> schrappen -->
							<!-- The next construct is neccessary in a next xslt step to be able to determine if such an element is desired. -->
							<!--ep:construct type="complexData" prefix="bg" namespaceId="http://www.stufstandaarden.nl/basisschema/bg0320">
								<ep:suppliers>
									<ep:suppliers>
										<supplier project="UGM" application="UGM BG" level="3" base-namespace="http://www.stufstandaarden.nl/basisschema/bg0320" verkorteAlias="bg"/>
									</ep:suppliers>
								</ep:suppliers>
								<ep:name>authentiek</ep:name>
								<ep:tech-name>authentiek</ep:tech-name>
								<ep:max-occurs>unbounded</ep:max-occurs>
								<ep:min-occurs>0</ep:min-occurs>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':StatusMetagegeven-basis'))"/>						
								<ep:position>145</ep:position>
							</ep:construct-->
							<!-- ep:inOnderzoek element is used to determine if a 'inOnderzoek' element needs to be generated in the messages in the next higher level. -->
							<!--xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/-->
							<!-- The next construct is neccessary in a next xslt step to be able to determine if such an element is desired. -->
							<ep:construct>
								<ep:name>inOnderzoek</ep:name>
								<ep:tech-name>inOnderzoek</ep:tech-name>
								<ep:max-occurs>unbounded</ep:max-occurs>
								<ep:min-occurs>0</ep:min-occurs>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':StatusMetagegeven-basis'))"/>						
								<ep:position>150</ep:position>
							</ep:construct>
						</xsl:if>
						<xsl:if test="($generateHistorieConstruct = 'MaterieleHistorieRelatie' and contains($indicatieMaterieleHistorieRelatie, 'Ja')) and $verwerkingsModus = 'antwoord'">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1045',$debugging)"/>

							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>tijdvakRelatie</ep:name>
								<ep:tech-name>tijdvakRelatie</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<ep:min-occurs>1</ep:min-occurs>
								<ep:position>149</ep:position>
								<ep:href>StUF:tijdvakRelatie</ep:href>
							</ep:constructRef>
						</xsl:if>
						<!-- A 'tijdvakGeldigheid' element is only allowed when the relatie has attributes. 
							 It can only be skipped if $generateHistorieConstruct isn't equal to 'MaterieleHistorie' or 'FormeleHistorie'. -->
						
						<!-- ROME: Het is de vraag of het voldoende is om te checken dat er een association-class is.
							 Wellicht moet er ook gecheckt worden of die association class ook attributes heeft. -->
						<xsl:if test="imvert:association-class and not($generateHistorieConstruct != ('MaterieleHistorie','FormeleHistorie') and $global-tijdvakGeldigheid-allowed = 'Nee')">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1046',$debugging)"/>

							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>tijdvakGeldigheid</ep:name>
								<ep:tech-name>tijdvakGeldigheid</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<ep:min-occurs>
									<xsl:choose>
										<xsl:when test="($generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie, 'Ja'))">
											<xsl:value-of select="1"/>
											<xsl:if test="$global-tijdvakGeldigheid-allowed = ('Nee','Optioneel')">
												<xsl:variable name="msg"
													select="concat('The tagged value [tijdvakGeldigheid genereren] is set to ',$global-tijdvakGeldigheid-allowed,'. However in the historieMaterieel elements within the messagetype ', $berichtCode, ' it must be required.')"/>
												<xsl:sequence select="imf:msg('WARNING', $msg)"/>
											</xsl:if>
										</xsl:when>
										<xsl:when test="($generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie, 'Ja')) or $global-tijdvakGeldigheid-allowed = 'Verplicht'">
											<xsl:value-of select="1"/>
											<xsl:if test="$global-tijdvakGeldigheid-allowed = ('Nee','Optioneel')">
												<xsl:variable name="msg"
													select="concat('The tagged value [tijdvakGeldigheid genereren] is set to ',$global-tijdvakGeldigheid-allowed,'. However in the historieFormeel elements within the messagetype ', $berichtCode, ' it must be required.')"/>
												<xsl:sequence select="imf:msg('WARNING', $msg)"/>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>							
								</ep:min-occurs>
								<ep:position>150</ep:position>
								<ep:href>StUF:tijdvakGeldigheid</ep:href>
							</ep:constructRef>
						</xsl:if>

						<!-- The tijdstipRegistratie element can only be skipped if $generateHistorieConstruct isn't equal to 'FormeleHistorie'. -->
						<xsl:if test="not($generateHistorieConstruct != 'FormeleHistorie' and $global-tijdstipRegistratie-allowed = 'Nee')">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1047',$debugging)"/>
							<!-- A 'tijdstipRegistratie' element must be created always within a relatie entiteit. -->
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>tijdstipRegistratie</ep:name>
								<ep:tech-name>tijdstipRegistratie</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<ep:min-occurs>
									<xsl:choose>
										<xsl:when test="$generateHistorieConstruct = 'FormeleHistorie' or $global-tijdstipRegistratie-allowed = 'Verplicht'">
											<xsl:value-of select="1"/>
											<xsl:if test="$global-tijdstipRegistratie-allowed = ('Nee','Optioneel')">
												<xsl:variable name="msg"
													select="concat('The tagged value [tijdstipRegistratie genereren] is set to ',$global-tijdstipRegistratie-allowed,'. However in the historieFormeel element within the messagetype ', $berichtCode, ' it must be required.')"/>
												<xsl:sequence select="imf:msg('WARNING', $msg)"/>
											</xsl:if>
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</ep:min-occurs>
								<ep:position>151</ep:position>
								<ep:href>StUF:tijdstipRegistratie</ep:href>
						</ep:constructRef>
						</xsl:if>

						<!-- Within a relatie entiteit 'extraElementen' and 'aanvullendeElementen' elementen are only allowed when the construct being created
							 itself isn't a 'historieMaterieel', 'historieFormeel' of 'historieFormeelRelatie' element. -->
						<xsl:if test="$generateHistorieConstruct != 'MaterieleHistorie' and 
							$generateHistorieConstruct != 'FormeleHistorie' and 
							$generateHistorieConstruct != 'FormeleHistorieRelatie'">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1048',$debugging)"/>

							<xsl:if test="$global-extraElementen-allowed != 'Nee'">
								<ep:constructRef prefix="StUF" externalNamespace="yes">
									<ep:name>extraElementen</ep:name>
									<ep:tech-name>extraElementen</ep:tech-name>
									<ep:max-occurs>1</ep:max-occurs>
									<ep:min-occurs>0</ep:min-occurs>
									<ep:position>152</ep:position>
									<ep:href>StUF:extraElementen</ep:href>
								</ep:constructRef>
							</xsl:if>
							<xsl:if test="$global-aanvullendeElementen-allowed != 'Nee'">
								<ep:constructRef prefix="StUF" externalNamespace="yes">
									<ep:name>aanvullendeElementen</ep:name>
									<ep:tech-name>aanvullendeElementen</ep:tech-name>
									<ep:max-occurs>1</ep:max-occurs>
									<ep:min-occurs>0</ep:min-occurs>
									<ep:position>153</ep:position>
									<ep:href>StUF:aanvullendeElementen</ep:href>
								</ep:constructRef>
							</xsl:if>
						</xsl:if>
					</xsl:if>

					<xsl:variable name="association-class-type-id" select="imvert:type-id"/>
					<!-- Only if the field 'Indicatie materiële historie' of one of the attribuutsoorten of the current Relatiesoort has the value 'Ja' at the end of the 
						 sequence a 'historieMaterieel' element has to be generated.
						 Watch out! This element isn't created if the field 'Indicatie materiële historie' on none of the attribuutsoorten of Relatiesoort has the value 
						 'Ja' while the same field on the Relatiesoort has the value 'Ja'.-->
					<xsl:variable name="materieleHistorie">
						<xsl:variable name="tv-materieleHistorie-attributes">
							<xsl:for-each select="imvert:association-class">
								<xsl:variable name="association-class-construct" select="imf:get-class-construct-by-id($association-class-type-id,$packages-doc)"/>
								<xsl:for-each select="$association-class-construct/imvert:attributes/imvert:attribute">
									<ep:tagged-value>
										<xsl:value-of
											select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY')"
										/>
									</ep:tagged-value>
								</xsl:for-each>
								<!-- ROME: Moet er ook nog gecheckt worden op de tagged values van de associations? -->
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="contains($tv-materieleHistorie-attributes//ep:tagged-value,'Ja')">
							<xsl:value-of select="'Ja'"/>
						</xsl:if>
					</xsl:variable>
					<!-- Only if the field 'Indicatie formele historie' of one of the attribuutsoorten of the current Relatiesoort has the value 'Ja' at the end of the 
						 sequence a 'historieFormeel' element has to be generated.
						 Watch out! This element isn't created if the field 'Indicatie formele historie' on none of the attribuutsoorten of Relatiesoort has the value 
						 'Ja' while the same field on the Relatiesoort has the value 'Ja'.-->
					<xsl:variable name="formeleHistorie">
						<xsl:variable name="tv-formeleHistorie-attributes">
							<xsl:for-each select="imvert:association-class">
								<xsl:variable name="association-class-construct" select="imf:get-class-construct-by-id($association-class-type-id,$packages-doc)"/>
								<xsl:for-each select="$association-class-construct/imvert:attributes/imvert:attribute">
									<ep:tagged-value>
										<xsl:value-of
											select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY')"
										/>
									</ep:tagged-value>
								</xsl:for-each>
								<!-- ROME: Moet er ook nog gecheckt worden op de tagged values van de associations? -->
							</xsl:for-each>									
						</xsl:variable>
						<xsl:if test="$tv-formeleHistorie-attributes//ep:tagged-value = 'Ja'">
							<xsl:value-of select="'Ja'"/>
						</xsl:if>
					</xsl:variable>
					<!-- Only if the field 'Indicatie formele historie' on the current Relatiesoort has the value 'Ja' at the end of the 
						 sequence a 'historieFormeelRelatie' element has to be generated. -->
					<xsl:variable name="formeleHistorieRelatie">
						<xsl:if
							test="contains(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY'), 'Ja')">
							<xsl:value-of select="'Ja'"/>
						</xsl:if>
					</xsl:variable>
			
					<xsl:variable name="mnemonic" select="imvert:alias"/>
					
					<xsl:sequence select="imf:create-debug-comment(concat('indicatieMaterieleHistorie: ',$indicatieMaterieleHistorie,', generateHistorieConstruct: ',$generateHistorieConstruct,', verwerkingsModus: ',$verwerkingsModus),$debugging)"/>
					
					<!-- If $indicatieMaterieleHistorie has the value 'Ja' and the code is creating content for an 'antwoord' type construct an 
						 'historieMaterieel' element has to be created. However it's not allowed to create such an element if the construct 
						 under construction itself is an 'historieMaterieel', 'historieFormeel' or 'historieFormeelRelatie' construct. -->
					<xsl:if test="contains($indicatieMaterieleHistorie,'Ja') and $generateHistorieConstruct!='MaterieleHistorie' and $generateHistorieConstruct!='FormeleHistorie' and $generateHistorieConstruct!='FormeleHistorieRelatie' and $verwerkingsModus = 'antwoord'">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1049',$debugging)"/>

						<!--xsl:variable name="href" select="imf:create-complexTypeName($berichtType,'HistorieMaterieel',$mnemonic,imvert:name)"/-->						
						<xsl:variable name="href" select="imf:create-complexTypeName($berichtType,'HistorieMaterieel',$mnemonic,(),$subsetLabel)"/>						
						
						<!-- Location: 'ep:constructRef10a'
				 			 Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct10'. -->			
						
						<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<ep:name>historieMaterieel</ep:name>
							<ep:tech-name>historieMaterieel</ep:tech-name>
							<ep:max-occurs>unbounded</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>154</ep:position>
							<xsl:sequence select="imf:create-output-element('ep:type-name', $href)"/>
						</ep:construct>

					</xsl:if>
					<!-- If $indicatieFormeleHistorie has the value 'Ja' and the code is creating content for an 'antwoord' type construct an 
						 'historieFormeel' element has to be created. Even if the construct under construction itself is an 'historieMaterieel', 
						 'historieFormeel' or 'historieFormeelRelatie' construct. -->
					<xsl:if test="contains($indicatieFormeleHistorie,'Ja') and $verwerkingsModus = 'antwoord'">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1050',$debugging)"/>

						<!--xsl:variable name="href" select="imf:create-complexTypeName($berichtType,'HistorieFormeel',$mnemonic,imvert:name)"/-->						
						<xsl:variable name="href" select="imf:create-complexTypeName($berichtType,'HistorieFormeel',$mnemonic,(),$subsetLabel)"/>						
						
						<!-- Location: 'ep:constructRef10b'
				 			 Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct10'. -->			
						
						<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<ep:name>historieFormeel</ep:name>
							<ep:tech-name>historieFormeel</ep:tech-name>
							<ep:max-occurs>unbounded</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>155</ep:position>
							<xsl:sequence select="imf:create-output-element('ep:type-name', $href)"/>
						</ep:construct>

					</xsl:if>
					<!-- If $indicatieFormeleHistorieRelatie has the value 'Ja' and the code is creating content for an 'antwoord' type construct an 
						 'historieFormeelRelatie' element has to be created. However it's not allowed to create such an element if the construct 
						 under construction itself is an 'historieMaterieel' or 'historieFormeel' construct. -->
					<xsl:if test="contains($indicatieFormeleHistorieRelatie,'Ja') and $generateHistorieConstruct!='MaterieleHistorie' and $generateHistorieConstruct!='FormeleHistorie' and $verwerkingsModus = 'antwoord'">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1051',$debugging)"/>

						<!--xsl:variable name="href" select="imf:create-complexTypeName($berichtType,'HistorieFormeelRelatie',$mnemonic,imvert:name)"/-->						
						<xsl:variable name="href" select="imf:create-complexTypeName($berichtType,'HistorieFormeelRelatie',$mnemonic,(),$subsetLabel)"/>						
						
						<!-- Location: 'ep:constructRef10c'
				 			 Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct10'. -->			
						
						<ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<ep:name>historieFormeelRelatie</ep:name>
							<ep:tech-name>historieFormeelRelatie</ep:tech-name>
							<ep:max-occurs>unbounded</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>155</ep:position>
							<xsl:sequence select="imf:create-output-element('ep:type-name', $href)"/>
						</ep:construct>

					</xsl:if>
					<!-- The following 'apply-templates' initiates the processing of the 
						class which contains the associations of the 'relatie' type element. -->
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1052',$debugging)"/>

					<xsl:apply-templates select="imvert:association-class" 
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associations'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
						<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
						<xsl:with-param name="indicatieMaterieleHistorieRelatie" select="$indicatieMaterieleHistorieRelatie"/>
						<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
						<xsl:with-param name="indicatieFormeleHistorieRelatie" select="$indicatieFormeleHistorieRelatie"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
				</xsl:when>
				<!-- The association is a 'groep compositie' and it has to contain a constructRef to a historieMaterieel or historieFormeel construct. -->
				<xsl:when
					test="key('class',$type-id) and imvert:stereotype/@id = ('stereotype-name-association-to-composite') and 
						  (($generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie,'Ja')) or
						  ($generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie,'Ja')))">
					
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1053',$debugging)"/>
					
					<!-- If a 'historie' construct is generated it must be determined if the current 'groep' must be part of that construct.
						 This is only the case if historie is configured for the complete 'groep' of for attributes of the 'groep'. -->
					<xsl:variable name="generateMaterieleHistorieOnAssociation">
						<xsl:choose>
							<xsl:when
								test="contains(imf:get-most-relevant-compiled-taggedvalue(key('class',$type-id), '##CFG-TV-INDICATIONMATERIALHISTORY'), 'JA')">
								<xsl:value-of select="'Ja'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tv-materieleHistorie-attributes">
									<xsl:for-each select="$construct/imvert:attributes/imvert:attribute">
										<ep:tagged-value>
											<xsl:value-of
												select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY')"
											/>
										</ep:tagged-value>
									</xsl:for-each>
								</xsl:variable>
								<xsl:choose>
									<xsl:when
										test="$tv-materieleHistorie-attributes//ep:tagged-value = 'JA' or $tv-materieleHistorie-attributes//ep:tagged-value = 'JAZIEREGELS'">
										<xsl:value-of select="'Ja op attributes'"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="generateFormeleHistorieOnAssociation">
						<xsl:choose>
							<xsl:when
								test="contains(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-INDICATIONFORMALHISTORY'), 'JA')">
								<xsl:value-of select="'Ja'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tv-formeleHistorie-attributes">
									<xsl:for-each select="$construct/imvert:attributes/imvert:attribute">
										<ep:tagged-value>
											<xsl:value-of
												select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY')"
											/>
										</ep:tagged-value>
									</xsl:for-each>
								</xsl:variable>
								<xsl:choose>
									<xsl:when
										test="$tv-formeleHistorie-attributes//ep:tagged-value = 'JA'">
										<xsl:value-of select="'Ja op attributes'"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="inOnderzoek" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEINONDERZOEK')"/>
					
					<xsl:if test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and ($generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie,'Ja'))
								  and contains($generateMaterieleHistorieOnAssociation,'Ja')">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1054',$debugging)"/>

						<!-- The ep:constructRef is temporarily provided with a 'context' attribute to be able to create global constructs later.
							 These are removed later since they aren't part of the 'ep' structure. -->
						
						<!-- Location: 'ep:constructRef4a'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct4'. -->
						
						<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<xsl:variable name="type" select="'Grp'"/>
							<!--xsl:variable name="name" select="imvert:name"/-->
							<xsl:variable name="historieType" select="'historieMaterieel'"/>

							<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>							
							<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>								
							<xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>					
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>

							<xsl:choose>
								<xsl:when
									test="imf:get-tagged-value(.,'##CFG-TV-POSITION')">
									<xsl:sequence
										select="imf:create-output-element('ep:position', imvert:position)"/>
								</xsl:when>
								<xsl:when test="imvert:position">
									<xsl:sequence select="imf:create-output-element('ep:position', 120)"/>
								</xsl:when>
								<xsl:otherwise/>
							</xsl:choose>
							<xsl:sequence select="imf:create-output-element('ep:type-name', imf:create-Grp-complexTypeName($berichtType,$type,$name,$historieType,$subsetLabel))"/>
						</ep:construct>

					</xsl:if>
					<xsl:if test="($berichtCode = 'La09' or $berichtCode = 'La10') and ($generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie,'Ja'))
								  and contains($generateFormeleHistorieOnAssociation,'Ja')">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1055',$debugging)"/>

						<!-- The ep:constructRef is temporarily provided with a 'context' attribute to be able to create global constructs later.
							 These are removed later since they aren't part of the 'ep' structure. -->
						
						<!-- Location: 'ep:constructRef4b'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct4'. -->
						
						<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<xsl:variable name="type" select="'Grp'"/>
							<!--xsl:variable name="name" select="imvert:name"/-->
							<xsl:variable name="historieType" select="'historieFormeel'"/>

							<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>							
							<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>							
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
							
							<xsl:choose>
								<xsl:when
									test="imf:get-tagged-value(.,'##CFG-TV-POSITION')">
									<xsl:sequence
										select="imf:create-output-element('ep:position', imvert:position)"/>
								</xsl:when>
								<xsl:when test="imvert:position">
									<xsl:sequence select="imf:create-output-element('ep:position', 120)"/>
								</xsl:when>
								<xsl:otherwise/>
							</xsl:choose>
							<xsl:sequence select="imf:create-output-element('ep:type-name', imf:create-Grp-complexTypeName($berichtType,$type,$name,$historieType,$subsetLabel))"/>
						</ep:construct>

					</xsl:if>
				</xsl:when>
				<!--xsl:when
					test="key('class',$type-id) and imvert:stereotype/@id = ('stereotype-name-association-to-composite') and ancestor::imvert:package[contains(imvert:alias, '/www.kinggemeenten.nl/BSM/Berichtstrukturen')] and imvert:name = 'parameters' and contains('Di01 Di02 Du01 Du02',$berichtCode) and $context = 'entiteit'">
					<xsl:sequence select="imf:report-warning(., 
						imvert:name = 'parameters' and contains('Di01 Di02 Du01 Du02',$berichtCode) and $context = 'entiteit',
						'A parameters element is not allowed within an object with a functie attributevalue of entiteit in a Dixx or Duxx message.',())"/>				
				</xsl:when-->	
				<!-- The association is a 'groep compositie' from the 'Berichtstrukturen' package and it has to contain a constructRef. -->
				<xsl:when
					test="key('class',$type-id) and imvert:stereotype/@id = ('stereotype-name-association-to-composite') and ancestor::imvert:package[contains(imvert:alias, '/www.kinggemeenten.nl/BSM/Berichtstrukturen')]">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056a',$debugging)"/>
					<!-- The ep:constructRef is temporarily provided with a 'context' attribute and a 'ep:id' element to be able to create global constructs later.
						 These are removed later since they aren't part of the 'ep' structure. -->
					
					<!-- Location: 'ep:constructRef3'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct3'. -->
					
					<xsl:if test="imvert:name = 'parameters' or imvert:name = 'stuurgegevens'">
						<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
							<xsl:attribute name="prefix" select="$kv-prefix"/>
							<xsl:attribute name="namespaceId" select="$StUF-namespaceIdentifier"/>
							
							<xsl:if test="$debugging">
								<xsl:copy-of select="$suppliers"/>
							</xsl:if>
							
							<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
							<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
							<xsl:sequence select="imf:create-output-element('ep:position', imvert:position)"/>
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056b',$debugging)"/>
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$name,$subsetLabel))"/>
						</ep:construct>
					</xsl:if>
				</xsl:when>
				<!-- The association is a 'groep compositie' and it has to contain a constructRef. -->
				<xsl:when
					test="key('class',$type-id) and imvert:stereotype/@id = ('stereotype-name-association-to-composite')">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056c',$debugging)"/>

					<xsl:variable name="type" select="'Grp'"/>
					<!--xsl:variable name="name">
						<xsl:value-of select="imvert:name"/>
					</xsl:variable-->
					<!-- The ep:constructRef is temporarily provided with a 'context' attribute and a 'ep:id' element to be able to create global constructs later.
						 These are removed later since they aren't part of the 'ep' structure. -->
					<xsl:variable name="inOnderzoek" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEINONDERZOEK')"/>
					
					<!-- Location: 'ep:constructRef3'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct3'. -->
					
					<xsl:variable name="currentPrefix">
						<xsl:choose>
							<xsl:when test="$suppliers//supplier[1]/@verkorteAlias != '' and imvert:name != 'parameters' and imvert:name != 'stuurgegevens' and imvert:name != 'ontvanger' and imvert:name != 'zender'">
								<xsl:value-of select="$suppliers//supplier[1]/@verkorteAlias"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$StUF-prefix"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<ep:construct context="{$context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
						<xsl:choose>
							<xsl:when test="$currentPrefix != $StUF-prefix">
								<xsl:attribute name="prefix" select="$currentPrefix"/>
								<xsl:attribute name="namespaceId" select="$suppliers//supplier[1]/@base-namespace"/>
								<xsl:attribute name="UGMlevel" select="$suppliers//supplier[1]/@level"/>
								<xsl:attribute name="version" select="$suppliers//supplier[1]/@version"/>
							</xsl:when>
							<xsl:when test="$currentPrefix = $StUF-prefix">
								<xsl:attribute name="prefix" select="$currentPrefix"/>
								<xsl:attribute name="namespaceId" select="$StUF-namespaceIdentifier"/>
							</xsl:when>
						</xsl:choose>
						
						<xsl:if test="$debugging">
							<xsl:copy-of select="$suppliers"/>
						</xsl:if>

						<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
						<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
						<xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
						<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
						<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
						
						<xsl:choose>
							<xsl:when
								test="imf:get-tagged-value(.,'##CFG-TV-POSITION')">
								<xsl:sequence
									select="imf:create-output-element('ep:position', imvert:position)"/>
							</xsl:when>
							<xsl:when test="imvert:position">
								<xsl:sequence select="imf:create-output-element('ep:position', 120)"/>
							</xsl:when>
							<xsl:otherwise/>
						</xsl:choose>
						<xsl:choose>
							<!-- In case of zender or ontvanger a referention to the type StUF:Systeem must be created. -->   
							<xsl:when test="(imvert:name = 'parameters' or imvert:name = 'stuurgegevens' or imvert:name = 'ontvanger' or imvert:name = 'zender') and 
								not(empty(imf:get-most-relevant-compiled-taggedvalue(imf:get-association-construct-by-id(imvert:type-id,$packages-doc), '##CFG-TV-SUBSETLABEL')))">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056da',$debugging)"/>
								<xsl:sequence
									select="imf:create-output-element('ep:type-name', imf:create-Grp-complexTypeName($berichtName,$type,$tech-name,@verwerkingsModus,$subsetLabel))" />
							</xsl:when>
							<xsl:when test="(imvert:name = 'ontvanger' or imvert:name = 'zender')">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056db',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':','Systeem'))"/>
							</xsl:when>
							<xsl:when test="(imvert:name = 'parameters' or imvert:name = 'stuurgegevens')">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056dc',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':',$name,$subsetLabel))"/>
							</xsl:when>
							<xsl:when test="(imvert:name = 'entiteittype') and 
								not(empty(imf:get-most-relevant-compiled-taggedvalue(imf:get-association-construct-by-id(imvert:type-id,$packages-doc), '##CFG-TV-SUBSETLABEL')))">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056e',$debugging)"/>
								
								
								<!-- ROME: I.h.k.v. RM #488759 zou ik op termijn op basis van $alias een specifieke 'EntiteittypeStuurgegevens' per bericht moeten maken.
										   Dit streven is echter niet verenigbaar met het hergebruiken van de stuurgegevens en parameters complexTypes van de onderlaag. -->
								<!-- Variabele 'alias' is blijkbaar niet altijd gevuld. Bij KV Prefill geeft onderstaande regel nl. een foutmelding. -->
								<!--xsl:sequence select="imf:create-debug-comment($alias,$debugging)"/-->
								
								<xsl:sequence
									select="imf:create-output-element('ep:type-name', imf:create-Grp-complexTypeName($berichtName,$type,$tech-name,@verwerkingsModus,$subsetLabel))" />
							</xsl:when>
							<xsl:when test="(imvert:name = 'entiteittype')">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056f',$debugging)"/>
								<xsl:sequence select="imf:create-output-element('ep:type-name', 'EntiteittypeStuurgegevens')"/>
							</xsl:when>
							<xsl:when test="$verwerkingsModusOfConstructRef != ''">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056g',$debugging)"/>
								<xsl:choose>
									<xsl:when test="$currentPrefix != $StUF-prefix">
										<xsl:variable name="type-name"><xsl:value-of select="imf:create-Grp-complexTypeName($berichtType,$type,$name,$verwerkingsModusOfConstructRef,$subsetLabel)"/></xsl:variable>
										<xsl:sequence select="imf:create-output-element('ep:type-name', concat($currentPrefix,':',$type-name))"/>										
									</xsl:when>
									<xsl:when test="$currentPrefix = $StUF-prefix">
										<xsl:variable name="type-name"><xsl:value-of select="imf:create-Grp-complexTypeName($berichtType,$type,$name,$verwerkingsModusOfConstructRef,$subsetLabel)"/></xsl:variable>
										<xsl:sequence select="imf:create-output-element('ep:type-name', concat($currentPrefix,':',$type-name))"/>										
									</xsl:when>
								</xsl:choose>
								<!--xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/-->
							</xsl:when>
							
							<xsl:when test="$verwerkingsModusOfConstructRef = ''">
								<xsl:sequence select="imf:create-debug-comment('Debuglocation 1056h',$debugging)"/>
								<xsl:sequence select="imf:create-debug-comment(concat('berichtType: ',$berichtType,', type: ',$type,', name: ',$name),$debugging)"/>
								<xsl:variable name="type-name"><xsl:value-of select="imf:create-Grp-complexTypeName($berichtType,$type,$name,(),$subsetLabel)"/></xsl:variable>
								<xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
							</xsl:when>
						</xsl:choose>
					</ep:construct>
					
				</xsl:when>
				<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
					 and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
					 be placed directly within the current 'ep:seq'. -->
				<xsl:when
					test="$construct[imvert:stereotype/@id = ('stereotype-name-objecttype')]">
					
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1057',$debugging)"/>
					
					<xsl:apply-templates select="key('class',$type-id)"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="key('class',$type-id)"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer 
						of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar 
						ook aan 'tijdvakRelatie', 'historieMaterieel' en 'historieFormeel'. -->
					<xsl:if test="not(contains(@verwerkingsModus,'matchgegevens'))">
						<!-- ep:inOnderzoek element is used to determine if a 'inOnderzoek' element needs to be generated in the messages in the next higher level. -->
						<!--xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/-->
						<!-- The next construct is neccessary in a next xslt step to be able to determine if such an element is desired. -->
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1057a',$debugging)"/>
						<ep:construct prefix="{$prefix}">
							<ep:name>inOnderzoek</ep:name>
							<ep:tech-name>inOnderzoek</ep:tech-name>
							<ep:max-occurs>unbounded</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':StatusMetagegeven-basis'))"/>						
							<!--ep:type-name>scalar-string</ep:type-name>
							<ep:enum>J</ep:enum>
							<ep:enum>N</ep:enum-->
							<ep:position>150</ep:position>
							<!--ep:seq>
								<xsl:variable name="attributes"
									select="imf:createAttributes('StatusMetagegeven-basis','-', '-','','no', $prefix, '', '')"/>									
								<xsl:sequence select="$attributes"/>
							</ep:seq-->
						</ep:construct>
						<xsl:if test="$global-tijdvakGeldigheid-allowed != 'Nee'">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1057b',$debugging)"/>
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>tijdvakGeldigheid</ep:name>
								<ep:tech-name>tijdvakGeldigheid</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<xsl:choose>
									<xsl:when test="$global-tijdvakGeldigheid-allowed = 'Verplicht'">
										<ep:min-occurs>1</ep:min-occurs>
									</xsl:when>
									<xsl:otherwise>
										<ep:min-occurs>0</ep:min-occurs>
									</xsl:otherwise>
								</xsl:choose>
								<ep:position>150</ep:position>
								<ep:href>StUF:tijdvakGeldigheid</ep:href>
							</ep:constructRef>
						</xsl:if>
						<xsl:if test="$global-tijdstipRegistratie-allowed != 'Nee'">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1057c',$debugging)"/>
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>tijdstipRegistratie</ep:name>
								<ep:tech-name>tijdstipRegistratie</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<xsl:choose>
									<xsl:when test="$global-tijdstipRegistratie-allowed = 'Verplicht'">
										<ep:min-occurs>1</ep:min-occurs>
									</xsl:when>
									<xsl:otherwise>
										<ep:min-occurs>0</ep:min-occurs>
									</xsl:otherwise>
								</xsl:choose>
								<ep:position>151</ep:position>
								<ep:href>StUF:tijdstipRegistratie</ep:href>
							</ep:constructRef>
						</xsl:if>
						<xsl:if test="$global-extraElementen-allowed != 'Nee'">
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>extraElementen</ep:name>
								<ep:tech-name>extraElementen</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<ep:min-occurs>0</ep:min-occurs>
								<ep:position>152</ep:position>
								<ep:href>StUF:extraElementen</ep:href>
							</ep:constructRef>
						</xsl:if>
						<xsl:if test="$global-aanvullendeElementen-allowed != 'Nee'">
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>aanvullendeElementen</ep:name>
								<ep:tech-name>aanvullendeElementen</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<ep:min-occurs>0</ep:min-occurs>
								<ep:position>153</ep:position>
								<ep:href>StUF:aanvullendeElementen</ep:href>
							</ep:constructRef>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates select="key('class',$type-id)"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:variable name="mnemonic">
						<xsl:choose>
							<xsl:when test="imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')">
								<xsl:value-of select="key('class',$type-id)/imvert:alias"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="imvert:alias"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-- The function imf:createAttributes is used to determine the XML 
						attributes neccessary for this context. It has the following parameters: 
						- typecode - berichttype - context - datumType The first 3 parameters relate 
						to columns with the same name within an Excel spreadsheet used to configure 
						a.o. XML attributes usage. The 4th parameter was used to determine the need 
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
					<xsl:sequence select="imf:create-debug-comment('Debuglocation attributes 2',$debugging)"/>
					<xsl:variable name="attributes"
						select="imf:createAttributes('toplevel', substring($berichtCode, 1, 2), $context, $mnemonic, 'no', $prefix, '', '')"/>
					<xsl:sequence select="$attributes"/>
				</xsl:when>
				<!-- The association is a 'berichtRelatie' and it contains a 'bericht'. 
					 This situation can occur whithin the context of a 'vrij bericht'. -->
				<!-- ROME: Checken of de volgende when idd de berichtRelatie afhandelt 
					en of alle benodigde (standaard) elementen wel gegenereerd worden. Er wordt 
					geen supertype in afgehandeld, ik weet even niet meer waarom. 
					Volgens mij wordt hierin ook een class met stereotype GROEP afgehandeld 
					waarvoor geen constructRef gemaakt hoeft te worden.-->
				<xsl:when test="key('class',$type-id)">
					
					<xsl:sequence select="imf:create-debug-comment('Debuglocation 1058',$debugging)"/>
					
					<xsl:apply-templates select="key('class',$type-id)"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="key('class',$type-id)"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="key('class',$type-id)"
						mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
	</xsl:template>

	<!-- ======= End block of templates used to create the message structure. ======= -->

	<!-- This template simply replicates elements. May be replaced later. -->
	<xsl:template match="*" mode="replicate-imvert-elements">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="context"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1059',$debugging)"/>
		
		<xsl:element name="{concat('ep:',local-name())}">
			<xsl:choose>
				<xsl:when test="*">
					<xsl:apply-templates select="*" mode="replicate-imvert-elements">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
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
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="context"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1060',$debugging)"/>
		
		<xsl:choose>
			<!-- The first when tackles the situation in which the datatype of an 
				attribute isn't a simpleType but a complexType. An attribute refers in that 
				case to an objectType (probably now an entitytype). This situation occurs 
				for example if within a union is refered to an entity withinn a ´Model´ package. -->
			<xsl:when test="imvert:stereotype/@id = ('stereotype-name-objecttype')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1061',$debugging)"/>
				<ep:seq>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="./imvert:attributes/imvert:attribute" mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:apply-templates
						select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:if test="not(contains(@verwerkingsModus,'matchgegevens'))">
						<!-- ep:authentiek element is used to determine if a 'authentiek' element needs to be generated in the messages in the next higher level. -->
						<!--xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/-->


						<!-- ROME: RFC0486 RFC: Metagegeven <authentiek> schrappen -->
						<!-- The next construct is neccessary in a next xslt step to be able to determine if such an element is desired. -->
						<!--ep:construct type="complexData" prefix="bg" namespaceId="http://www.stufstandaarden.nl/basisschema/bg0320">
							<ep:suppliers>
								<ep:suppliers>
									<supplier project="UGM" application="UGM BG" level="3" base-namespace="http://www.stufstandaarden.nl/basisschema/bg0320" verkorteAlias="bg"/>
								</ep:suppliers>
							</ep:suppliers>
							<ep:name>authentiek</ep:name>
							<ep:tech-name>authentiek</ep:tech-name>
							<ep:max-occurs>unbounded</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':StatusMetagegeven-basis'))"/>						
							<ep:position>145</ep:position>
						</ep:construct-->
						<!-- ep:inOnderzoek element is used to determine if a 'inOnderzoek' element needs to be generated in the messages in the next higher level. -->
						<!--xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/-->
						<!-- The next construct is neccessary in a next xslt step to be able to determine if such an element is desired. -->
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1061a',$debugging)"/>
						<ep:construct prefix="{$prefix}">
							<ep:name>inOnderzoek</ep:name>
							<ep:tech-name>inOnderzoek</ep:tech-name>
							<ep:max-occurs>unbounded</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':StatusMetagegeven-basis'))"/>						
							<ep:position>150</ep:position>
						</ep:construct>
						<xsl:if test="$global-tijdvakGeldigheid-allowed != 'Nee'">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1061b',$debugging)"/>
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>tijdvakGeldigheid</ep:name>
								<ep:tech-name>tijdvakGeldigheid</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<xsl:choose>
									<xsl:when test="$global-tijdvakGeldigheid-allowed = 'Verplicht'">
										<ep:min-occurs>1</ep:min-occurs>
									</xsl:when>
									<xsl:otherwise>
										<ep:min-occurs>0</ep:min-occurs>
									</xsl:otherwise>
								</xsl:choose>
								<ep:position>150</ep:position>
								<ep:href>StUF:tijdvakGeldigheid</ep:href>
							</ep:constructRef>
						</xsl:if>
						<xsl:if test="$global-tijdstipRegistratie-allowed != 'Nee'">
							<xsl:sequence select="imf:create-debug-comment('Debuglocation 1061c',$debugging)"/>
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>tijdstipRegistratie</ep:name>
								<ep:tech-name>tijdstipRegistratie</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<xsl:choose>
									<xsl:when test="$global-tijdstipRegistratie-allowed = 'Verplicht'">
										<ep:min-occurs>1</ep:min-occurs>
									</xsl:when>
									<xsl:otherwise>
										<ep:min-occurs>0</ep:min-occurs>
									</xsl:otherwise>
								</xsl:choose>
								<ep:position>151</ep:position>
								<ep:href>StUF:tijdstipRegistratie</ep:href>
							</ep:constructRef>
						</xsl:if>
						<xsl:if test="$global-extraElementen-allowed != 'Nee'">
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>extraElementen</ep:name>
								<ep:tech-name>extraElementen</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<ep:min-occurs>0</ep:min-occurs>
								<ep:position>152</ep:position>
								<ep:href>StUF:extraElementen</ep:href>
							</ep:constructRef>
						</xsl:if>
						<xsl:if test="$global-aanvullendeElementen-allowed != 'Nee'">
							<ep:constructRef prefix="StUF" externalNamespace="yes">
								<ep:name>aanvullendeElementen</ep:name>
								<ep:tech-name>aanvullendeElementen</ep:tech-name>
								<ep:max-occurs>1</ep:max-occurs>
								<ep:min-occurs>0</ep:min-occurs>
								<ep:position>153</ep:position>
								<ep:href>StUF:aanvullendeElementen</ep:href>
							</ep:constructRef>
						</xsl:if>
					</xsl:if>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
					<xsl:apply-templates
						select="./imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-relatiesoort')]"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
				</ep:seq>
			</xsl:when>
			<!-- If it's an 'Enumeration' class it's attributes, which represent the 
				enumeration values) processed. -->
			<xsl:when test="imvert:stereotype/@id = ('stereotype-name-enumeration')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1062',$debugging)"/>

				<xsl:apply-templates select="imvert:attributes/imvert:attribute"
					mode="create-datatype-content"/>
			</xsl:when>
			<xsl:when test="imvert:stereotype/@id = ('stereotype-name-simpletype')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1063',$debugging)"/>
				<xsl:choose>
					<!-- If the class stereotype is a Datatype and it contains 'imvert:attribute' 
						elements they are placed as constructs within a 'ep:seq' element. -->
					<xsl:when test="imvert:attributes/imvert:attribute">
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1064',$debugging)"/>
						<ep:seq>
							<xsl:apply-templates select="imvert:attributes/imvert:attribute"
								mode="create-datatype-content">
								<xsl:with-param name="berichtCode" select="$berichtCode"/>
								<xsl:with-param name="berichtName" select="$berichtName"/>
								<xsl:with-param name="generated-id" select="$generated-id"/>
								<xsl:with-param name="currentMessage" select="$currentMessage"/>
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
							</xsl:apply-templates>
						</ep:seq>
					</xsl:when>
					<!-- If the class stereotype is a Datatype and it doesn't contain 'imvert:attribute' 
						 elements an 'ep:datatype' element is generated. -->
					<xsl:otherwise>
						<xsl:sequence select="imf:create-debug-comment('Debuglocation 1065',$debugging)"/>
						<ep:datatype id="{imvert:id}">
							<xsl:apply-templates select="imvert:documentation"
								mode="replicate-imvert-elements">
								<xsl:with-param name="berichtCode" select="$berichtCode"/>
								<xsl:with-param name="berichtName" select="$berichtName"/>
								<xsl:with-param name="generated-id" select="$generated-id"/>
								<xsl:with-param name="currentMessage" select="$currentMessage"/>
								<xsl:with-param name="context" select="$context"/>
								<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
							</xsl:apply-templates>
						</ep:datatype>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- ROME: De vraag is of deze otherwise tak ooit wordt gebruikt. -->
			<xsl:otherwise>
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1066',$debugging)"/>
				<ep:seq>
					<xsl:apply-templates select="imvert:attributes/imvert:attribute"
						mode="create-datatype-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="berichtName" select="$berichtName"/>
						<xsl:with-param name="generated-id" select="$generated-id"/>
						<xsl:with-param name="currentMessage" select="$currentMessage"/>
						<xsl:with-param name="context" select="$context"/>
						<xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
					</xsl:apply-templates>
				</ep:seq>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- The following template creates the construct representing the lowest 
		level elements or the 'ep:enum' element representing one of the possible 
		values of an enumeration. -->
	<xsl:template match="imvert:attribute" mode="create-datatype-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:sequence select="imf:create-debug-comment('Debuglocation 1067',$debugging)"/>

		<xsl:variable name="name" select="imvert:name/@original"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>

		<xsl:choose>
			<xsl:when test="imvert:stereotype/@id = ('stereotype-name-enum')">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1068',$debugging)"/>

				<xsl:sequence select="imf:create-output-element('ep:enum', $name)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="imf:create-debug-comment('Debuglocation 1069',$debugging)"/>

				<ep:construct type="simpleData" prefix="{$prefix}">
					<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $name)"/>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
					<xsl:if test="imvert:type-id">
						<xsl:variable name="type-id" select="imvert:type-id"/>
						<xsl:apply-templates
							select="imf:get-class-construct-by-id($type-id,$packages-doc)"
							mode="create-datatype-content"/>
					</xsl:if>
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<?x xsl:template name="areParametersAndStuurgegevensAllowedOrRequired">
		<xsl:param name="berichtCode" as="xs:string"/>
		<xsl:param name="berichtName"/>
		<xsl:param name="generated-id"/>
		<xsl:param name="currentMessage"/>
		<xsl:param name="elements2bTested" as="document-node()"/>
		<xsl:param name="parent" as="xs:string"/>
		<xsl:param name="verwerkingsModus"/>
		
		<xsl:for-each select="$elements2bTested//imvert:name">
			<xsl:sequence select="imf:create-debug-comment('Debuglocation 1070',$debugging)"/>
			<xsl:variable name="isElementAllowed"
				select="imf:isElementAllowed($berichtCode, ., $parent)"/>
			<xsl:choose>
				<xsl:when test="$isElementAllowed = 'notAllowed'">
					<xsl:variable name="msg"
						select="concat('Within messagetype ', $berichtCode, ' element ', ., ' is not allowed within ', $parent, '.')"/>
					<xsl:sequence select="imf:msg('WARNING', $msg)"/>
				</xsl:when>
				<xsl:when test="$isElementAllowed = 'noSuchElement'">
					<xsl:variable name="msg"
						select="concat('Within messagetype ', $berichtCode, ' the ', $parent, ' element ', ., ' is not known.')"/>
					<xsl:sequence select="imf:msg('WARNING', $msg)"/>
				</xsl:when>
				<xsl:when test="$isElementAllowed = 'notInScope'"/>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each
			select="
				$enriched-endproduct-base-config-excel//sheet
				[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'Berichtcode']/data = $berichtCode]/col[upper-case(@type) = upper-case($parent) and data != '-']">
			<xsl:sequence select="imf:create-debug-comment('Debuglocation 1071',$debugging)"/>
			<xsl:variable name="colName" select="@name"/>
			<xsl:if test="count($elements2bTested//imvert:name = $colName) = 0">
				<xsl:variable name="msg"
					select="concat('Within messagetype ', $berichtCode, ' element ', @name, ' must be available within ', $parent, '.')"/>
				<xsl:sequence select="imf:msg('WARNING', $msg)"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template x?>

	<?x !-- This function checks if a parameter or stuurgegeven is allowed within 
		the current messagetype and if not if it is: * really not allowed (it can 
		not be used within the messagetype); * not applicable (the parent-type isn't 
		checked at the moment.); * or not in scope (in EA it is allowed within the 
		messagetype but it can be ignored for the berichtCode or the tagged value 
		isn't a placeholder for a parameter or stuurgegevens element and has another 
		function). -->
	<xsl:function name="imf:isElementAllowed">
		<xsl:param name="berichtCode" as="xs:string"/>
		<xsl:param name="element" as="xs:string"/>
		<xsl:param name="parent" as="xs:string"/>
		<!-- The following variable wil contain information from a spreadsheetrow 
			which is determined using the above 3 parameters. The content of the variable 
			$enriched-endproduct-base-config-excel used within the following variable 
			is generated using the XSLT stylesheet 'Imvert2XSD-KING-enrich-excel.xsl'. -->
		<xsl:variable name="attributeTypeRow"
			select="
			$enriched-endproduct-base-config-excel//sheet
			[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'Berichtcode']/data = $berichtCode]"/>
		<!-- Within the following choose the output of this function is determined. -->
		<xsl:choose>
			<xsl:when
				test="$attributeTypeRow//col[@type = $parent and @name = $element and data != '-']"
				>allowed</xsl:when>
			<xsl:when
				test="$attributeTypeRow//col[@type = $parent and @name = $element and data = '-']"
				>notAllowed</xsl:when>
			<xsl:when test="$attributeTypeRow//col[@name = $element]">notApplicable</xsl:when>
			<xsl:otherwise>notInScope</xsl:otherwise>
		</xsl:choose>
	</xsl:function x?>
	
	<!-- The function imf:createAttributes is used to determine the XML attributes 
		neccessary for a certain context. It has the following parameters: 
		- typecode 
		- berichttype 
		- context 
		- datumType
		- mnemonic
		- onvolledigeDatum
		- prefix
		- constructId"
		- dataType
		
		The first 3 parameters relate to columns 
		with the same name within an Excel spreadsheet used to configure a.o. XML 
		attributes usage. 
		The 5th
	    The 6th
	    The 7th
	    The 8th
	    The 9th -->
	
	<xsl:function name="imf:createAttributes">
		<xsl:param name="typeCode" as="xs:string"/>
		<xsl:param name="berichtType" as="xs:string"/>
		<xsl:param name="context" as="xs:string"/>
		<xsl:param name="mnemonic" as="xs:string"/>
		<xsl:param name="onvolledigeDatum" as="xs:string"/>
		<xsl:param name="prefix" as="xs:string"/>
		<xsl:param name="constructId" as="xs:string"/>
		<xsl:param name="dataType" as="xs:string"/>
		
		<!-- The following variable wil contain information from a spreadsheetrow 
			which is determined using the first 3 parameters. The variable $enriched-endproduct-base-config-excel 
			used within the following variable is generated using the XSLT stylesheet 
			'Imvert2XSD-KING-enrich-excel.xsl'. -->
		<xsl:variable name="attributeTypeRow"
			select="
				$enriched-endproduct-base-config-excel//sheet
				[name = 'XML attributes']/row[col[@name = 'typecode']/data = $typeCode and
				col[@name = 'berichttype']/data = $berichtType and
				col[@name = 'context']/data = $context]"/>
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
			test="$attributeTypeRow//col[@name = 'noValue' and data = 'O'] and $global-noValue-allowed = 'Ja'">
			<ep:construct ismetadata="yes">
				<ep:name>noValue</ep:name>
				<ep:tech-name>noValue</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'noValue' and data = 'V'] and $global-noValue-allowed = 'Ja'">
			<ep:construct ismetadata="yes">
				<ep:name>noValue</ep:name>
				<ep:tech-name>noValue</ep:tech-name>
				<ep:min-occurs>1</ep:min-occurs>
				<ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
			</ep:construct>
		</xsl:if>
		<!-- ROME: De waarde van het attribute 'StUF:entiteittype' moet m.b.v. 
			een enum constuctie worden gedefinieerd. Die waarde zal aan de functie meegegeven 
			moeten worden. Deze waarde zou uit het 'imvert:alias' element moeten komen. 
			Dat is echter niet altijd aanwezig. 
			Op dit moment wordt aan dit attribute nog geen prefix meegegeven maar dat moet uiteindelijk wel.
			Als dat geimplementeerd is moet het stylesheet dat het schema gegereerd daarop aangepast worden. -->
		<xsl:if test="$attributeTypeRow//col[@name = 'entiteittype' and data = 'O']">
			<ep:constructRef ismetadata="yes" prefix="$actualPrefix">
				<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace 
					van het koppelvlak. Later zal ik echter een restriction moeten definieren 
					in de namespace van het model waaruit de entiteit oorspronkelijk komt. -->
				<ep:name>entiteittype</ep:name>
				<ep:tech-name>entiteittype</ep:tech-name>
				<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een 
					warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:choose>
					<xsl:when test="not(empty($mnemonic))">
						<ep:min-occurs>0</ep:min-occurs>
						<ep:enum fixed="yes">
							<xsl:value-of select="$mnemonic"/>
						</ep:enum>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="msg"
							select="'No mnemonic has been supplied. Supply one with this entity using the alias field.'"/>
						<xsl:sequence select="imf:msg('WARNING', $msg)"/>
					</xsl:otherwise>
				</xsl:choose>
				<ep:href>entiteittype</ep:href>
				<!--xsl:sequence
					select="imf:create-output-element('ep:href', '$actualPrefix:entiteittype')" /-->
			</ep:constructRef>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'entiteittype' and data = 'V']">
			<ep:constructRef ismetadata="yes" prefix="$actualPrefix">
				<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace 
					van het koppelvlak. Later zal ik echter een restriction moeten definieren 
					in de namespace van het model waaruit de entiteit oorspronkelijk komt. -->
				<ep:name>entiteittype</ep:name>
				<ep:tech-name>entiteittype</ep:tech-name>
				<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een 
					warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:choose>
					<xsl:when test="not(empty($mnemonic))">
						<ep:enum fixed="yes">
							<xsl:value-of select="$mnemonic"/>
						</ep:enum>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="msg"
							select="'No mnemonic has been supplied. Supply one with this entity using the alias field.'"/>
						<xsl:sequence select="imf:msg('WARNING', $msg)"/>
					</xsl:otherwise>
				</xsl:choose>
				<ep:href>entiteittype</ep:href>
				<!--xsl:sequence
					select="imf:create-output-element('ep:href', '$actualPrefix:entiteittype')" /-->
			</ep:constructRef>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelVerzendend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelVerzendend</ep:name>
				<ep:tech-name>sleutelVerzendend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelVerzendend' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelVerzendend</ep:name>
				<ep:tech-name>sleutelVerzendend</ep:tech-name>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelOntvangend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelOntvangend</ep:name>
				<ep:tech-name>sleutelOntvangend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelOntvangend' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelOntvangend</ep:name>
				<ep:tech-name>sleutelOntvangend</ep:tech-name>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelGegevensbeheer' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelGegevensbeheer</ep:name>
				<ep:tech-name>sleutelGegevensbeheer</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelGegevensbeheer' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelGegevensbeheer</ep:name>
				<ep:tech-name>sleutelGegevensbeheer</ep:tech-name>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelSynchronisatie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelSynchronisatie</ep:name>
				<ep:tech-name>sleutelSynchronisatie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'sleutelSynchronisatie' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>sleutelSynchronisatie</ep:name>
				<ep:tech-name>sleutelSynchronisatie</ep:tech-name>
				<ep:type-name>StUF:Sleutel</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'scope' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>scope</ep:name>
				<ep:tech-name>scope</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:StUFScope</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'scope' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>scope</ep:name>
				<ep:tech-name>scope</ep:tech-name>
				<ep:type-name>StUF:StUFScope</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'verwerkingssoort' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>verwerkingssoort</ep:name>
				<ep:tech-name>verwerkingssoort</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:Verwerkingssoort</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'verwerkingssoort' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>verwerkingssoort</ep:name>
				<ep:tech-name>verwerkingssoort</ep:tech-name>
				<ep:type-name>StUF:Verwerkingssoort</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'functie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>functie</ep:name>
				<ep:tech-name>functie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:FunctieVrijBerichtElement</ep:type-name>
					<xsl:choose>
						<xsl:when test="$context != '' and $context != '-'">
							<ep:enum fixed="yes">
								<xsl:value-of select="$context"/>
							</ep:enum>
						</xsl:when>
						<xsl:when test="$context = '-'">
							<ep:enum fixed="yes">
								<xsl:value-of select="'entiteit'"/>
							</ep:enum>
						</xsl:when>
					</xsl:choose>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'functie' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>functie</ep:name>
				<ep:tech-name>functie</ep:tech-name>
				<ep:type-name>StUF:FunctieVrijBerichtElement</ep:type-name>
					<xsl:choose>
						<xsl:when test="$context != '' and $context != '-'">
							<ep:enum fixed="yes">
								<xsl:value-of select="$context"/>
							</ep:enum>
						</xsl:when>
						<xsl:when test="$context = '-'">
							<!-- A 'functie' attribute with the value 'entiteit' is always optional. -->
							<ep:min-occurs>0</ep:min-occurs>
							<ep:enum fixed="yes">
								<xsl:value-of select="'entiteit'"/>
							</ep:enum>
						</xsl:when>
					</xsl:choose>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'groepsnaam' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>groepsnaam</ep:name>
				<ep:tech-name>groepsnaam</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:Groepsnaam</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'groepsnaam' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>groepsnaam</ep:name>
				<ep:tech-name>groepsnaam</ep:tech-name>
				<ep:type-name>StUF:Groepsnaam</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'elementnaam' and data = 'O']">
			<ep:construct ismetadata="yes">
				<ep:name>elementnaam</ep:name>
				<ep:tech-name>elementnaam</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<ep:type-name>StUF:Groepsnaam</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'elementnaam' and data = 'V']">
			<ep:construct ismetadata="yes">
				<ep:name>elementnaam</ep:name>
				<ep:tech-name>elementnaam</ep:tech-name>
				<ep:type-name>StUF:Groepsnaam</ep:type-name>
			</ep:construct>
		</xsl:if>
	</xsl:function>

	<!-- This function merges all documentation from the highest layer up to the current layer. -->
	<xsl:function name="imf:merge-documentation">
		<xsl:param name="this"/>
		<xsl:param name="tv-id"/>
		
		
		<xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,false())"/>
		<xsl:variable name="vals" select="$all-tv[@id = $tv-id]"/>
		<xsl:for-each select="$vals">
			<xsl:variable name="p" select="normalize-space(imf:get-clean-documentation-string(imf:get-tv-value.local(.)))"/>
			<xsl:if test="not($p = '')">
				<ep:p subpath="{imf:get-subpath(@project,@application,@release)}">
					<xsl:value-of select="$p"/>
				</ep:p>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
</xsl:stylesheet>
