<?xml version="1.0" encoding="UTF-8"?>
<!-- Robert Melskens	2017-06-09	This stylesheet generates a rough EP file structure based on the embellish 
									file of a BSM EAP file. This rough structure will be enriched in the next step
									and the result of that step serves as a base for creating the final EP file structure. -->
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

	<xsl:key name="class" match="imvert:class" use="imvert:id" />

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-rough-structure</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-rough-structure.xsl 1
		2016-12-01 13:32:00Z RobertMelskens $</xsl:variable>
	<xsl:variable name="stylesheet-code" as="xs:string">SKS</xsl:variable>
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
	
	<xsl:variable name="embellish-file" select="/"/>
	<xsl:variable name="packages" select="$embellish-file/imvert:packages"/>
	<xsl:variable name="verkorteAlias" select="imf:get-tagged-value($packages,'##CFG-TV-VERKORTEALIAS')"/>
	<xsl:variable name="namespaceIdentifier" select="$packages/imvert:base-namespace"/>
	
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
				<xsl:sequence select="imf:msg('WARNING',$msg)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="version" select="$packages/imvert:version"/>
	
	<xsl:variable name="rough-messages">
		<xsl:sequence select="imf:track('Constructing the rough message-structure')"/>
		
		<ep:rough-messages>
			<xsl:apply-templates select="$packages/imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-message-package') and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-rough-message-structure"/>
		</ep:rough-messages>
		
	</xsl:variable>
	
	
	<xsl:key name="associations" match="imvert:association" use="concat(imvert:type-id,ancestor::imvert:package/imvert:id)"/>
	
	<!-- ======= Block of templates used to create the message structure. ======= -->

	<!-- This template is used to start generating a rough ep structure for the individual messages.
		 This rough ep structure is used as a base for creating the final ep structure. -->

	<xsl:template match="/">
		<xsl:sequence select="imf:track('Constructing the rough message-structure')"/>
		<xsl:if test="$debugging">
			<xsl:sequence select="imf:msg('INFO','Constructing the rough message structure.')"/>
		</xsl:if>		
		
		<xsl:sequence select="imf:pretty-print($rough-messages,false())"/>

	</xsl:template>
	
	<xsl:template
		match="imvert:package[not(contains(imvert:alias, '/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]"
		mode="create-rough-message-structure">
		<!-- This processes the package containing the koppelvlak messages. -->

		<xsl:sequence select="imf:create-debug-comment('debug:start A00000 /debug:start',$debugging)"/>
		<xsl:sequence select="imf:create-debug-track(concat('Constructing the rough-messages for package: ',imvert:name),$debugging)"/>

		<!-- The following for-each processes all classes representing a messagetype except the classes representing the SYNCHRONISATIEBERICHTTYPE.
			 That messagetype wil be added here too but at a later moment. The 'not(key('associations',imvert:id))' statement in the selection is used 
			 to be sure the class doesn't represent an association within another class. Since synchronisation messages contain kennisgeving messages 
			 this selection might be adapted or another solution must be found. -->
		<xsl:for-each
			select="imvert:class[(imvert:stereotype/@id = ('stereotype-name-vraagberichttype',
														   'stereotype-name-antwoordberichttype',
														   'stereotype-name-kennisgevingberichttype',
														   'stereotype-name-vrijberichttype')) 
														   and not(key('associations',concat(imvert:id,ancestor::imvert:package/imvert:id)))]"> 
				
			<xsl:variable name="associationClassId" select="imvert:associations/imvert:association/imvert:type-id"/>
			<xsl:variable name="fundamentalMnemonic">
				<xsl:choose>
					<xsl:when test="imvert:stereotype/@id = (
						'stereotype-name-vraagberichttype',
						'stereotype-name-antwoordberichttype',
						'stereotype-name-kennisgevingberichttype',
						'stereotype-name-synchronisatieberichttype')">
						<xsl:value-of select="key('class',$associationClassId)/imvert:alias"/>
					</xsl:when>
					<xsl:when test="imvert:stereotype/@id = (
						'stereotype-name-vrijberichttype')">
						<xsl:value-of select="''"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<!-- ROME deze tagged-value met en id ophalen. CFG-TV-BERICHTCODE-->
			<xsl:variable name="berichtCode" select="imf:get-tagged-value(.,'##CFG-TV-BERICHTCODE')"/>
			
			<xsl:if test="$berichtCode = ''">
				<xsl:message
					select="concat('ERROR ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The berichtcode can not be determined. To be able to generate correct messages this is neccessary. Check if your model contains the tagged value Berichtcode. (', imvert:stereotype)"
				/>
			</xsl:if>
			<!-- ROME: De volgende xsl:if wrapper kan verwijderd worden zodra duidelijk is hoe een Du02 bericht vertaald moet worden. -->
			<!-- create the message. Messages with a berichtCode value of 'Du02' aren't processed yet since the StUF standard doesn't specify how it should look like. -->
			<xsl:if test="$berichtCode != 'Du02'">
				<ep:rough-message>
					<xsl:sequence select="imf:create-debug-comment('A00010]',$debugging)"/>
					<xsl:sequence select="imf:create-debug-track(concat('Constructing the rough-message: ',imvert:name/@original),$debugging)"/>
	
					<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
					<xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)"/>
					<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)"/>
					<xsl:sequence select="imf:create-output-element('ep:fundamentalMnemonic', $fundamentalMnemonic)"/>
	
					<xsl:sequence select="imf:create-output-element('ep:verkorteAlias', $prefix)"/>
					<!-- Start of the message is always a class with an imvert:stereotype 
						with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'KENNISGEVINGBERICHTTYPE', 'SYNCHRONISATIEBERICHTTYPE'
						or 'VRIJ BERICHTTYPE'. Since the toplevel structure of a message complies to different rules in comparison with 
						the entiteiten structure this template is initialized within the 'create-toplevel-rough-message-structure' mode. -->
					<xsl:apply-templates
						select="
							.[imvert:stereotype/@id = (
							'stereotype-name-vraagberichttype',
							'stereotype-name-antwoordberichttype',
							'stereotype-name-kennisgevingberichttype',
							'stereotype-name-synchronisatieberichttype',
							'stereotype-name-vrijberichttype')]"
						mode="create-toplevel-rough-message-structure">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="useStuurgegevens" select="'yes'"/>
					</xsl:apply-templates>
				</ep:rough-message>
			</xsl:if>
		</xsl:for-each>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template only processes imvert:class elements with an imvert:stereotype 
		with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'KENNISGEVINGBERICHTTYPE',
		'SYNCHRONISATIEBERICHTTYPE'	or 'VRIJ BERICHTTYPE'. Those classes contain a relation 
		to a class with an imvert:stereotype 
		with the value 'ENTITEITTYPE' or, in case of a ''VRIJ BERICHTTYPE', a relation 
		with one or more classes with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
		'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE'. These 
		classes also have a supertype with an imvert:stereotype with the value 'BERICHTTYPE' 
		which contain a 'melding' attribuut and have a relation to the 'Stuurgegevens' 
		group a relation to the 'Parameters' group (if not removed). 
		This supertype is also processed here. -->
	<xsl:template match="imvert:class" mode="create-toplevel-rough-message-structure">
		<xsl:param name="berichtCode"/>
		<xsl:param name="embeddedBerichtCode"/>
		
		<xsl:sequence select="imf:create-debug-comment('debug:start A01000 /debug:start',$debugging)"/>
		
		<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:association' 
				elements with the stereotype 'GROEP COMPOSITIE' within the supertype 
				of imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
				'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE' and 
				those within the current class. The first one generates the 'stuurgegevens' 
				element, the second one the 'parameters' element. 
				The value '-' for the variable 'context' guarantee's no xml attributes are 
				generated with the attributen.-->
		<xsl:sequence select="imf:create-debug-comment('debug:start A01000a /debug:start',$debugging)"/>
		<xsl:apply-templates select="imvert:supertype" mode="create-rough-message-content">
			<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="'-'"/>
		</xsl:apply-templates>
		<xsl:sequence select="imf:create-debug-comment('debug:start A01000b /debug:start',$debugging)"/>
		<xsl:apply-templates select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]"
			mode="create-rough-message-content">
			<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					class within the trail (so the related object has already been processed) processing 
					stops. -->
			<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="'-'"/>
		</xsl:apply-templates>

		<!-- At this level an association with a class having the stereotype 'ENTITEITTYPE' 
				always has the stereotype 'ENTITEITRELATIE'. The following apply-templates 
				initiates the processing of such an association.
				The supertype of the current class will never contain an association with a stereotype 
				of 'ENTITEITRELATIE'. For that reason no apply-templates on the supertype in this context 
				is implemented. -->
		<xsl:choose> 
			<xsl:when test="not(contains($berichtCode, 'Di')) and not(contains($berichtCode, 'Du'))">
				<xsl:sequence select="imf:create-debug-comment('A01010]',$debugging)"/>
				<xsl:apply-templates
					select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
					mode="create-rough-message-content">
					<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					class within the trail (so the related object has already been processed) processing 
					stops. -->
					<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="imvert:attributes/imvert:attribute">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="imf:create-debug-comment('A01020a]',$debugging)"/>
				<xsl:apply-templates
					select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
					mode="create-rough-message-content">
					<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so the related object has already been processed) processing 
					stops. -->
					<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="embeddedBerichtCode" select="$embeddedBerichtCode"/>
				</xsl:apply-templates>
				<!-- Associations linking from a class with a imvert:stereotype with the 
					value 'VRIJ BERICHTTYPE' need special treatment. E.g. the construct to be created must 
					contain a meta-data construct called 'functie'. For that reason those linking to a class 
					with a imvert:stereotype with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE' 
					or 'KENNISGEVINGBERICHTTYPE' and those linking to a class with a imvert:stereotype 
					with the value 'ENTITEITRELATIE' must also be processed as from toplevel-message 
					type. -->
				<xsl:sequence select="imf:create-debug-comment('A01020b]',$debugging)"/>
				<xsl:apply-templates
					select="imvert:associations/imvert:association[imvert:stereotype/@id != 'stereotype-name-entiteitrelatie' and imvert:name != 'stuurgegevens' and imvert:name != 'parameters']"
					mode="create-toplevel-rough-message-structure">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="imvert:attributes/imvert:attribute">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template takes care of processing superclasses of the class being 
		processed. -->
	<xsl:template match="imvert:supertype" mode="create-rough-message-content">
		<xsl:param name="proces-type"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start A02000 /debug:start',$debugging)"/>
		
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- Declaration of the content of a superclass, an 'imvert:association' and 'imvert:association-class' 
		finaly always takes place within an 'imvert:class' element. This element 
		is processed within this template. -->
	<xsl:template match="imvert:class" mode="create-rough-message-content">
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:variable name="id" select="imvert:id"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start A03000 /debug:start',$debugging)"/>
		<xsl:sequence select="imf:create-debug-comment(concat('Classname: ',imvert:name),$debugging)"/>
		
		<xsl:choose>
			<!-- The following takes care of ignoring the processing of the attributes 
				 belonging to the current class. Attributes aren't important for the rough structure. -->
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:sequence select="imf:create-debug-comment('A03010]',$debugging)"/>
				<xsl:apply-templates select="imvert:attributes/imvert:attribute">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="'-'"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- The following when initiates the processing of the attributegroups 
				 belonging to the current class. First the ones found within the superclass 
				 of the current class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsGroepCompositie'">
				<xsl:sequence select="imf:create-debug-comment('A03020]',$debugging)"/>
				<xsl:apply-templates select="imvert:supertype" mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else 
					 processing is canceled to prevent recursion. -->
				<xsl:if test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
			
					<xsl:variable name="associationsOfBerichtrelatieType" select="$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-berichtrelatie')]"/>
					<xsl:variable name="classRelated2Association" select="$packages/imvert:package/imvert:class[imvert:id = $associationsOfBerichtrelatieType/imvert:type-id]"/>
					<xsl:apply-templates
						select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]"
						mode="create-rough-message-content">
						<xsl:with-param name="id-trail">
							<xsl:choose>
								<xsl:when
									test="contains($id-trail, concat('#2#', imvert:id, '#'))">
									<xsl:value-of
										select="concat('#3#', imvert:id, '#', $id-trail)"/>
								</xsl:when>
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
						<xsl:with-param name="useStuurgegevens">
							<xsl:choose>
								<xsl:when test="imvert:id = $classRelated2Association/imvert:supertype/imvert:type-id and contains($berichtCode,'Di')">
									<xsl:value-of select="'no'"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'yes'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>                                      						
					</xsl:apply-templates>
					
				</xsl:if>
				<xsl:sequence select="imf:create-debug-comment('End A03020]',$debugging)"/>
			</xsl:when>
			<!-- The following when initiates the processing of the associations refering to the current class as a superclass.
				 In this situation a choice has to be generated. -->
			<xsl:when
				test="$proces-type = 'associationsOrSupertypeRelatie' and $packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
				<xsl:sequence select="imf:create-debug-comment('A03030]',$debugging)"/>
				<ep:choice>
					<xsl:for-each select="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
						<ep:construct typeCode="gerelateerde" context="{$context}" type="entity" package="{ancestor::imvert:package/imvert:name}">
							<xsl:sequence
								select="imf:create-output-element('ep:name', imvert:name/@original)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:tech-name', imvert:name)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:id', imvert:id)"/>

							<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
							<xsl:variable name="subpath" select="$supplier/@subpath"/>
							<!-- If the current construct has a trace to a construct within a UGM model The following variable must get the value of the path to that UGM model
								 however if the current construct is from the 'Berichtstructuren' package it must stay empty. In that case the elements 'ep:verkorteAlias' and
								 'ep:namespaceIdentifier' wil get the related values from the StUF namespace. -->
							<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

							<xsl:sequence
								select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
							<xsl:sequence
								select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
							<xsl:sequence
								select="imf:create-output-element('ep:version', imf:getVersion($UGM))"/>
							

							<xsl:apply-templates select=".[name() != 'imvert:attributes']" mode="create-rough-message-content">
								<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
								<xsl:with-param name="id-trail" select="$id-trail"/>
								<xsl:with-param name="berichtCode" select="$berichtCode"/>
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
							
						</ep:construct>
					</xsl:for-each>
				</ep:choice>
			</xsl:when>
			<!-- The following when initiates the processing of the associations belonging 
				to the current class. First the ones found within the superclass of the current 
				class followed by the ones within the current class. -->
			<xsl:when
				test="$proces-type = ('associationsRelatie','associationsOrSupertypeRelatie')">
				<xsl:sequence select="imf:create-debug-comment('A03040]',$debugging)"/>
				<xsl:apply-templates select="imvert:supertype" mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#3#', imvert:id, '#')))">
						<xsl:apply-templates
							select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-relatiesoort')]"
							mode="create-rough-message-content">
							<xsl:with-param name="id-trail">
								<xsl:choose>
									<xsl:when
										test="contains($id-trail, concat('#2#', imvert:id, '#'))">
										<xsl:value-of
											select="concat('#3#', imvert:id, '#', $id-trail)"/>
									</xsl:when>
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
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template transforms an 'imvert:association' element to an 'ep:construct' element. -->
	<xsl:template match="imvert:association" mode="create-rough-message-content">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<!-- The purpose of this parameter is to determine if the element 'stuurgegevens' 
			must be generated or not. This is important because the 'kennisgevingbericht' , 
			'vraagbericht' or 'antwoordbericht' objects within the context of a 'vrijbericht' 
			object aren't allowed to contain 'stuurgegevens'. -->
		
		<xsl:param name="useStuurgegevens" select="'yes'"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start A04000 /debug:start',$debugging)"/>
		
		<xsl:if test="not($useStuurgegevens = 'no' and imvert:name = 'stuurgegevens')">		
			<ep:construct package="{ancestor::imvert:package/imvert:name}">
				<xsl:attribute name="typeCode">
					<xsl:choose>
						<xsl:when test="imvert:name = ('stuurgegevens','parameters','zender','ontvanger')"/>
						<xsl:when test="imvert:stereotype/@id = ('stereotype-name-association-to-composite')">groep</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'relatie'"/>
						</xsl:otherwise>						
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="(imvert:name = ('zender','ontvanger')) and contains(ancestor::imvert:package/@display-name,'www.kinggemeenten.nl/BSM/Berichtstrukturen')">
					<xsl:attribute name="className" select="imf:get-class-construct-by-id($type-id,$embellish-file)/imvert:name"/>
				</xsl:if>
				<xsl:attribute name="context">
					<xsl:choose>
						<xsl:when test="empty($context)">-</xsl:when>
						<xsl:when test="$context = ''">-</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$context"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:choose>
						<xsl:when test="imvert:stereotype/@id = ('stereotype-name-association-to-composite')">group</xsl:when>
						<xsl:otherwise>association</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="imvert:stereotype/@id != 'stereotype-name-association-to-composite'">
						<xsl:variable name="tv-materieleHistorie-attributes">
							<xsl:for-each select="imvert:association-class">
								<xsl:variable name="association-class-type-id" select="imvert:type-id"/>
								<xsl:for-each select="imf:get-class-construct-by-id($association-class-type-id,$embellish-file)/imvert:attributes/imvert:attribute">
									<ep:tagged-value>
										<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY')"/>
									</ep:tagged-value>
								</xsl:for-each>
							</xsl:for-each>									
						</xsl:variable>
						<xsl:if
							test="($berichtCode = ('La07','La08','La09','La10')) and $tv-materieleHistorie-attributes//ep:tagged-value = ('JA','JAZIEREGELS')">
							<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja op attributes'"/>
						</xsl:if>
						<xsl:if
							test="($berichtCode = ('La07','La08','La09','La10')) and contains(imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie materiele historie'), 'JA')">
							<xsl:attribute name="indicatieMaterieleHistorieRelatie" select="'Ja op attributes'"/>
						</xsl:if>
						<xsl:variable name="tv-formeleHistorie-attributes">
							<xsl:for-each select="imvert:association-class">
								<xsl:variable name="association-class-type-id" select="imvert:type-id"/>
								<xsl:for-each select="imf:get-class-construct-by-id($association-class-type-id,$embellish-file)/imvert:attributes/imvert:attribute">
									<ep:tagged-value>
										<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY')"/>
									</ep:tagged-value>
								</xsl:for-each>
							</xsl:for-each>									
						</xsl:variable>
						<xsl:if
							test="($berichtCode = ('La09','La10')) and $tv-formeleHistorie-attributes//ep:tagged-value = 'JA'">
							<xsl:attribute name="indicatieFormeleHistorie" select="'Ja op attributes'"/>
						</xsl:if>
						<xsl:if
							test="($berichtCode = ('La09','La10')) and contains(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY'), 'JA')">
							<xsl:attribute name="indicatieFormeleHistorieRelatie" select="'Ja'"/>
						</xsl:if>
						<xsl:sequence select="imf:create-debug-comment('A04010]',$debugging)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when
								test="($berichtCode = ('La07','La08','La09','La10')) and contains(imf:get-most-relevant-compiled-taggedvalue(key('class',$type-id), '##CFG-TV-INDICATIONMATERIALHISTORY'), 'JA')">
								<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tv-materieleHistorie-attributes">
									<xsl:for-each select="key('class',$type-id)/imvert:attributes/imvert:attribute">
										<ep:tagged-value>
											<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY')"/>
										</ep:tagged-value>
									</xsl:for-each>
								</xsl:variable>
								<xsl:if test="($berichtCode = ('La07','La08','La09','La10')) and $tv-materieleHistorie-attributes//ep:tagged-value = ('JA','JAZIEREGELS')">
									<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja op attributes'"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when
								test="($berichtCode = ('La09','La10')) and contains(imf:get-most-relevant-compiled-taggedvalue(key('class',$type-id), '##CFG-TV-INDICATIONFORMALHISTORY'), 'JA')">
								<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tv-formeleHistorie-attributes">
									<xsl:for-each select="key('class',$type-id)/imvert:attributes/imvert:attribute">
										<ep:tagged-value>
											<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY')"/>
										</ep:tagged-value>
									</xsl:for-each>
								</xsl:variable>
								<xsl:if test="($berichtCode = ('La09','La10')) and $tv-formeleHistorie-attributes//ep:tagged-value = 'JA'">
									<xsl:attribute name="indicatieFormeleHistorie" select="'Ja op attributes'"/>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:sequence select="imf:create-debug-comment('A04020]',$debugging)"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:sequence select="imf:create-debug-comment('A04030]',$debugging)"/>

				<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
				<xsl:sequence
					select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))"/>
				<!-- De volgende elementen moeten alleengevuld worden als de relatie gekoppeld is aan een association-class. 
					 De relatie heeft dan zelf attributen waarop historie van toepassing kan zijn. -->
				<xsl:choose>
					<!-- In het geval van een associationgroup wordt er geen 'gerelateerde' elementen tussen gegenereerd en mag het id en type-id gewoon 
						 op het huidige element worden gegenereerd. -->
					<xsl:when test="imvert:stereotype/@id != 'stereotype-name-relatiesoort'">
						<xsl:sequence select="imf:create-output-element('ep:origin-id', imvert:id)"/>
						<xsl:sequence select="imf:create-output-element('ep:id', imvert:type-id)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:variable name="relatie" select="."/>
				
				<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct($relatie,'UGM')"/>
				<xsl:variable name="subpath" select="$supplier/@subpath"/>
				<!-- If the current construct has a trace to a construct within a UGM model The following variable must get the value of the path to that UGM model
					 however if the current construct is from the 'Berichtstructuren' package it must stay empty. In that case the elements 'ep:verkorteAlias' and
					 'ep:namespaceIdentifier' wil get the related values from the StUF namespace. -->
				<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

				<xsl:choose>
					<xsl:when test="ancestor::imvert:package[contains(imvert:alias, '/www.kinggemeenten.nl/BSM/Berichtstrukturen')]">
						<xsl:sequence
							select="imf:create-output-element('ep:verkorteAlias', $StUF-prefix)"/>
						<xsl:sequence
							select="imf:create-output-element('ep:namespaceIdentifier', $StUF-namespaceIdentifier)"/>
						<xsl:sequence
							select="imf:create-output-element('ep:version', $version)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence
							select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
						<xsl:sequence
							select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
						<xsl:sequence
							select="imf:create-output-element('ep:version', imf:getVersion($UGM))"/>
						
						<xsl:variable name="gerelateerde" select="imf:get-class-construct-by-id($type-id,$embellish-file)"/>
						<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct($gerelateerde,'UGM')"/>
						<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
						<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>
						
						<xsl:sequence
							select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
						<xsl:sequence
							select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
						<xsl:sequence
							select="imf:create-output-element('ep:UGMversionGerelateerdeEntiteit', imf:getVersion($UGMgerelateerde))"/>
					</xsl:otherwise>
				</xsl:choose>
				
				
				
				<xsl:call-template name="createRoughRelatiePartOfAssociation">
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="id" select="imvert:id"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:call-template>
				<!-- Only in case of an association representing a 'relatie' and containing 
				a 'gerelateerde' construct (within the above choose the first 'when' XML 
				Attributes for the 'relatie' type element have to be generated. Because these 
				has to be placed outside the 'gerelateerde' element it has to be done here. -->
			</ep:construct>
		</xsl:if> 		

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template takes care of associations from a 'vrijbericht' type 
		 to the other message types 'vraagbericht', 'antwoordbericht' and 'kennisgevingbericht'. -->
	<xsl:template match="imvert:association" mode="create-toplevel-rough-message-structure">
		<xsl:param name="berichtCode"/>
		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start A05000 /debug:start',$debugging)"/>
		
		<xsl:variable name="gerelateerdeConstruct" select="imf:get-class-construct-by-id($type-id,$embellish-file)"/>
		
		<!-- If the association has a stereotype of 'BERICHTRELATIE' and it's part of a 'vrij bericht' it must refer to an embedded message
			 of another type. In that case the following variable get's a value equal to the value of the 'berichtCode' of the embedded message.
			 This variable is forwarded to be able to proces the content of the embedded message conforming its type later. -->
		<xsl:variable name="embeddedBerichtCode">
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-berichtrelatie') and contains($berichtCode, 'Di')">
					<xsl:value-of select="imf:get-tagged-value(key('class',$type-id),'##CFG-TV-BERICHTCODE')"/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>

		<ep:construct package="{ancestor::imvert:package/imvert:name}">
			<xsl:attribute name="typeCode">
				<xsl:choose>
					<xsl:when test="imvert:stereotype/@id = ('stereotype-name-berichtrelatie')">
						<xsl:value-of select="'berichtrelatie'"/>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="context">
				<xsl:choose>
					<xsl:when test="contains($embeddedBerichtCode,'Lk')">
						<xsl:value-of select="'update'"/>
					</xsl:when>
					<xsl:when test="contains($embeddedBerichtCode,'Lv')">
						<xsl:value-of select="'selectie'"/>
					</xsl:when>
					<xsl:when test="contains($embeddedBerichtCode,'La')">
						<xsl:value-of select="'antwoord'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'-'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="type" select="'association'"/>
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
			<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))"/>
			<xsl:sequence select="imf:create-output-element('ep:origin-id', imvert:id)"/>
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:type-id)"/>
			
			<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
			<xsl:variable name="subpath" select="$supplier/@subpath"/>
			<!-- If the current construct has a trace to a construct within a UGM model The following variable must get the value of the path to that UGM model
				 however if the current construct is from the 'Berichtstructuren' package it must stay empty. In that case the elements 'ep:verkorteAlias' and
				 'ep:namespaceIdentifier' wil get the related values from the StUF namespace. -->
			<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

			<xsl:sequence
				select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
			<xsl:sequence
				select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
			<xsl:sequence
				select="imf:create-output-element('ep:version', imf:getVersion($UGM))"/>
			
			<xsl:choose>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')">

					<xsl:sequence select="imf:create-debug-comment('A05010]',$debugging)"/>
					
					<xsl:variable name="gerelateerde" select="."/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct($gerelateerde,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:UGMversionGerelateerdeEntiteit', imf:getVersion($UGMgerelateerde))"/>
					

					<xsl:apply-templates select="." mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							class within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'-'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="imvert:stereotype/@id = ('stereotype-name-berichtrelatie')">
					
					<xsl:sequence select="imf:create-debug-comment('A05020]',$debugging)"/>

					<xsl:variable name="gerelateerde" select="."/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct($gerelateerde,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:UGMversionGerelateerdeEntiteit', imf:getVersion($UGMgerelateerde))"/>
					
					<xsl:apply-templates
						select="$gerelateerdeConstruct[imvert:stereotype/@id = (
							'stereotype-name-vraagberichttype',
							'stereotype-name-antwoordberichttype',
							'stereotype-name-kennisgevingberichttype')]"
						mode="create-toplevel-rough-message-structure">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="embeddedBerichtCode" select="$embeddedBerichtCode"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</ep:construct>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template transforms an 'imvert:association' element of stereotype 'ENTITEITRELATIE' to an 'ep:construct' 
		element.. -->
	<xsl:template match="imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
		mode="create-rough-message-content">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="embeddedBerichtCode"/>
		
		<xsl:variable name="context">
			<xsl:choose>
				<xsl:when
					test="imvert:name = ('gelijk','vanaf','tot en met')">
					<xsl:value-of select="'selectie'"/>
				</xsl:when>
				<xsl:when
					test="imvert:name = ('start','scope')">
					<xsl:value-of select="imvert:name"/>
				</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start A06000 /debug:start',$debugging)"/>
		
		<xsl:choose>
			<xsl:when test="contains($berichtCode, 'La') or contains($embeddedBerichtCode, 'La')">
				<xsl:sequence select="imf:create-debug-comment('A06010]',$debugging)"/>

				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lv') or contains($embeddedBerichtCode, 'Lv')">
				<xsl:choose>
					<xsl:when test="$context = 'selectie'">
						<xsl:sequence select="imf:create-debug-comment('A06020]',$debugging)"/>
						<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="constructName" select="'-'"/>
							<xsl:with-param name="typeCode" select="'toplevel'"/>					
							<xsl:with-param name="embeddedBerichtCode" select="$embeddedBerichtCode"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$context = 'start'">
						<xsl:sequence select="imf:create-debug-comment('A06030]',$debugging)"/>
						<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="constructName" select="'-'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$context = 'scope'">
						<xsl:sequence select="imf:create-debug-comment('A06040]',$debugging)"/>
						<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="constructName" select="'-'"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>

			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lk') or contains($embeddedBerichtCode, 'Lk')">
				<xsl:sequence select="imf:create-debug-comment('A06050]',$debugging)"/>
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
					<xsl:with-param name="typeCode" select="'toplevel'"/>					
					<xsl:with-param name="embeddedBerichtCode" select="$embeddedBerichtCode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Sh')"> </xsl:when>
			<xsl:when test="contains($berichtCode, 'Sa')"> </xsl:when>
			<xsl:when test="contains($berichtCode, 'Di')">
				<xsl:sequence select="imf:create-debug-comment('A06080]',$debugging)"/>
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
					<xsl:with-param name="typeCode" select="'entiteitrelatie'"/>					
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Du')">
				<xsl:sequence select="imf:create-debug-comment('A06090]',$debugging)"/>
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
					<xsl:with-param name="typeCode" select="'entiteitrelatie'"/>					
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template generates the structure of a relatie on a relatie. -->
	<xsl:template match="imvert:association-class" mode="create-rough-message-content">
		<xsl:param name="proces-type" select="'associations'"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>
		
		<xsl:sequence select="imf:create-debug-comment('debug:start A07000 /debug:start',$debugging)"/>
		
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="id-trail" select="$id-trail"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<xsl:template match="imvert:attribute">
		<xsl:param name="proces-type"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context" select="'-'"/>
		
		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start A08000 /debug:start',$debugging)"/>
		
		<xsl:choose>
			<xsl:when test="imvert:type-id and //imvert:class[imvert:id = $type-id]/imvert:stereotype/@id = ('stereotype-name-complextype')">
				<xsl:sequence select="imf:create-debug-comment('A08010]',$debugging)"/>
				<ep:construct typeCode="groep">
					<xsl:attribute name="context">
						<xsl:choose>
							<xsl:when test="empty($context)">-</xsl:when>
							<xsl:when test="$context = ''">-</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$context"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="type" select="'complex datatype'"/>
					<xsl:if
						test="($berichtCode = ('La07','La08','La09','La10')) and
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1)
						or
						(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1))">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:if
						test="($berichtCode = ('La09','La10')) and 
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1)
						or
						(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1))">
						<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:attribute name="className" select="//imvert:class[imvert:id = $type-id]/imvert:name"/>
					<xsl:sequence
						select="imf:create-output-element('ep:name', imvert:name/@original)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))"
					/>
					<xsl:sequence select="imf:create-output-element('ep:origin-id', imvert:id)"/>
					<xsl:sequence select="imf:create-output-element('ep:id', imvert:type-id)"/>
					
					<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpath" select="$supplier/@subpath"/>
					<!-- If the current construct has a trace to a construct within a UGM model The following variable must get the value of the path to that UGM model
					 	 however if the current construct is from the 'Berichtstructuren' package it must stay empty. In that case the elements 'ep:verkorteAlias' and
					 	 'ep:namespaceIdentifier' wil get the related values from the StUF namespace. -->
					<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:version', imf:getVersion($UGM))"/>
					
					<xsl:variable name="gerelateerde" select="imf:get-class-construct-by-id($type-id,$embellish-file)"/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:UGMversionGerelateerdeEntiteit', imf:getVersion($UGMgerelateerde))"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:class-name', $gerelateerde/ep:name)"/>
					
					<xsl:apply-templates select="$gerelateerde" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							class within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="$gerelateerde" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							class within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="$gerelateerde" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							class within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
				</ep:construct>
			</xsl:when>
			<xsl:when test="imvert:type-id and //imvert:class[imvert:id = $type-id]/imvert:stereotype/@id = ('stereotype-name-referentielijst')">
				<xsl:sequence select="imf:create-debug-comment('A08020]',$debugging)"/>
				<ep:construct typeCode="tabelEntiteit">
					<xsl:attribute name="context">
						<xsl:choose>
							<xsl:when test="empty($context)">-</xsl:when>
							<xsl:when test="$context = ''">-</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$context"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="type" select="'entity'"/>
					<xsl:if
						test="($berichtCode = ('La07','La08','La09','La10')) and
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1)
						or
						(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1))">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:if
						test="($berichtCode = ('La09','La10')) and 
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1)
						or
						(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1))">
						<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:attribute name="className" select="//imvert:class[imvert:id = $type-id]/imvert:name"/>
					<xsl:sequence
						select="imf:create-output-element('ep:name', imvert:name/@original)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))"
					/>
					<xsl:sequence select="imf:create-output-element('ep:origin-id', imvert:id)"/>
					<xsl:sequence select="imf:create-output-element('ep:id', imvert:type-id)"/>
					
					<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpath" select="$supplier/@subpath"/>
					<!-- If the current construct has a trace to a construct within a UGM model The following variable must get the value of the path to that UGM model
						 however if the current construct is from the 'Berichtstructuren' package it must stay empty. In that case the elements 'ep:verkorteAlias' and
						 'ep:namespaceIdentifier' wil get the related values from the StUF namespace. -->
					<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:version', imf:getVersion($UGM))"/>
					
					<xsl:variable name="gerelateerde" select="imf:get-class-construct-by-id($type-id,$embellish-file)"/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:UGMversionGerelateerdeEntiteit', imf:getVersion($UGMgerelateerde))"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:class-name', $gerelateerde/ep:name)"/>
					
					<xsl:apply-templates select="$gerelateerde" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							class within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="$gerelateerde" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							class within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="$gerelateerde" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							class within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
				</ep:construct>
			</xsl:when>
		</xsl:choose>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<xsl:template name="createRoughEntityConstruct">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="type-id"/>
		<xsl:param name="constructName"/>
		<xsl:param name="typeCode" select="''"/>					
		<xsl:param name="embeddedBerichtCode"/>
		
		<xsl:sequence select="imf:create-debug-comment('debug:start A09000 /debug:start',$debugging)"/>
		
		<ep:construct package="{ancestor::imvert:package/imvert:name}">
			<xsl:if test="$embeddedBerichtCode != ''">
				<xsl:attribute name="berichtCode" select="$embeddedBerichtCode"/>
			</xsl:if>
			<xsl:attribute name="typeCode">
				<xsl:choose>
					<xsl:when test="$typeCode != ''">
						<xsl:value-of select="$typeCode"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'toplevel'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="context">
				<xsl:choose>
					<xsl:when test="empty($context)">-</xsl:when>
					<xsl:when test="$context = ''">-</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$context"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="type" select="'entity'"/>
			<xsl:if
				test="($berichtCode = ('La07','La08','La09','La10')) and
				((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1)
				or
				(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1))">
				<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
			</xsl:if>
			<xsl:if
				test="($berichtCode = ('La09','La10')) and 
				((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1)
				or
				(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1))">
				<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
			</xsl:if>
			


			<!-- I.h.k.v. RM #488759 moet ik op termijn op basis van $alias een specifieke 'EntiteittypeStuurgegevens' per bericht maken. -->
			<xsl:if test="not($berichtCode = ('Di01','Di02','Du01','Du02'))">
				<xsl:attribute name="alias" select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="$constructName = '-'">
					<xsl:sequence
						select="imf:create-output-element('ep:name', imvert:name/@original)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:name', $constructName)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($constructName, 'element-name'))"
					/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence select="imf:create-output-element('ep:origin-id', imvert:id)"/>
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:type-id)"/>
			
			<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
			<xsl:variable name="subpath" select="$supplier/@subpath"/>
			<!-- If the current construct has a trace to a construct within a UGM model The following variable must get the value of the path to that UGM model
				 however if the current construct is from the 'Berichtstructuren' package it must stay empty. In that case the elements 'ep:verkorteAlias' and
				 'ep:namespaceIdentifier' wil get the related values from the StUF namespace. -->
			<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

			<xsl:sequence
				select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
			<xsl:sequence
				select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
			<xsl:sequence
				select="imf:create-output-element('ep:version', imf:getVersion($UGM))"/>
			
			<xsl:if test="$typeCode = 'entiteitrelatie' or $typeCode = ('berichtrelatie','toplevel','')">
				<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
				<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
				<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

				<xsl:sequence
					select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
				<xsl:sequence
					select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
				<xsl:sequence
					select="imf:create-output-element('ep:UGMversionGerelateerdeEntiteit', imf:getVersion($UGMgerelateerde))"/>
				
			</xsl:if>
			
			<xsl:variable name="class-id" select="imvert:type-id"/>
			<xsl:sequence
				select="imf:create-output-element('ep:class-name', imf:get-class-construct-by-id($class-id,$embellish-file)/ep:name)"/>
			<xsl:apply-templates select="key('class',$type-id)"
				mode="create-rough-message-content">
				<xsl:with-param name="proces-type" select="'attributes'"/>
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="key('class',$type-id)"
				mode="create-rough-message-content">
				<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
				<xsl:with-param name="id-trail" select="$id-trail"/>
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="key('class',$type-id)"
				mode="create-rough-message-content">
				<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
				<xsl:with-param name="id-trail" select="$id-trail"/>
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</ep:construct>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- This template generates the structure of the 'gerelateerde' type element. -->
	<xsl:template name="createRoughRelatiePartOfAssociation">
		<xsl:param name="type-id"/>
		<xsl:param name="id"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<xsl:sequence select="imf:create-debug-comment('debug:start A10000 /debug:start',$debugging)"/>
		
		<!-- The following choose processes the 3 situations an association can 
			represent. -->
		<xsl:choose>
			<!-- The association is a 'relatie' and it has to contain a 'gerelateerde' 
				 construct. -->
			<xsl:when test="key('class',$type-id) and imvert:stereotype/@id = ('stereotype-name-relatiesoort')">
				<xsl:sequence select="imf:create-debug-comment('A10010]',$debugging)"/>
				<ep:construct typeCode="gerelateerde" package="{ancestor::imvert:package/imvert:name}">
					<xsl:attribute name="context">
						<xsl:choose>
							<xsl:when test="empty($context)">-</xsl:when>
							<xsl:when test="$context = ''">-</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$context"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:choose>
						<xsl:when test="count($packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $type-id]) >= 1">
							<xsl:attribute name="type" select="'supertype'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="type" select="'entity'"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="count($packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $type-id]) >= 1">
						<xsl:attribute name="type" select="'supertype'"/>
					</xsl:if>
					<xsl:if
						test="($berichtCode = ('La07','La08','La09','La10')) and
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1)
						or
						(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONMATERIALHISTORY') = ('JA','JAZIEREGELS')]) >= 1))">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:if
						test="($berichtCode = ('La09','La10')) and 
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1)
						or
						(count(key('class',$type-id)/imvert:associations/imvert:association[imf:get-tagged-value(.,'##CFG-TV-INDICATIONFORMALHISTORY') ='JA']) >= 1))">
						<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:sequence select="imf:create-output-element('ep:name', 'gerelateerde')"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', 'gerelateerde')"/>
					<xsl:sequence select="imf:create-output-element('ep:origin-id', $id)"/>
					<xsl:sequence select="imf:create-output-element('ep:id', $type-id)"/>
					
					<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpath" select="$supplier/@subpath"/>
					<!-- If the current construct has a trace to a construct within a UGM model The following variable must get the value of the path to that UGM model
						 however if the current construct is from the 'Berichtstructuren' package it must stay empty. In that case the elements 'ep:verkorteAlias' and
						 'ep:namespaceIdentifier' wil get the related values from the StUF namespace. -->
					<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:version', imf:getVersion($UGM))"/>
					

					<xsl:variable name="relatie" select="imf:get-association-construct-by-id($type-id,$embellish-file)"/>
					<xsl:variable name="supplierRelatie" select="imf:get-trace-supplier-for-construct($relatie,'UGM')"/>
					<xsl:variable name="subpathRelatie" select="$supplierRelatie/@subpath"/>
					<xsl:variable name="UGMRelatie" select="imf:get-imvert-system-doc($subpathRelatie)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMRelatie))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMRelatie))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:UGMversionGerelateerdeEntiteit', imf:getVersion($UGMRelatie))"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:class-name', key('class',$type-id)/imvert:name)"/>

					<xsl:apply-templates select="key('class',$type-id)" mode="create-rough-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="key('class',$type-id)" mode="create-rough-message-content">
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="key('class',$type-id)" mode="create-rough-message-content">
						<xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'"/>
						<xsl:with-param name="id-trail" select="$id-trail"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</ep:construct>
				<!-- The following 'apply-templates' initiates the processing of the 
					class which contains the attributegroups of the 'relatie' type element. -->
				<xsl:apply-templates select="imvert:association-class"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- The following 'apply-templates' initiates the processing of the 
					class which contains the associations of the 'relatie' type element. -->
				<xsl:apply-templates select="imvert:association-class"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associations'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
				 and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
				 be placed directly within the current 'ep:seq'. -->
			<xsl:when
				test="imf:get-association-construct-by-id($type-id,$embellish-file)[imvert:stereotype/@id = ('stereotype-name-objecttype')]">
				<xsl:sequence select="imf:create-debug-comment('A10020]',$debugging)"/>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- The association is a 'berichtRelatie' and it contains a 'bericht'. 
				 This situation can occur whithin the context of a 'vrij bericht'. -->
			<xsl:when test="key('class',$type-id)">
				<xsl:sequence select="imf:create-debug-comment('A10030]',$debugging)"/>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="key('class',$type-id)"
					mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
		
		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)"/>
	</xsl:template>

	<!-- ======= End block of templates used to create the message structure. ======= -->

	<xsl:function name="imf:getVerkorteAlias" as="xs:string">
		<xsl:param name="UGM"/>


		<xsl:choose>
			<xsl:when test="$UGM/imvert:packages">
				<xsl:variable name="verkorteAlias" select="imf:get-tagged-value($UGM/imvert:packages,'##CFG-TV-VERKORTEALIAS')"></xsl:variable>
				<xsl:value-of select="$verkorteAlias"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$prefix"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>

	<xsl:function name="imf:getNamespaceIdentifier" as="xs:string">
		<xsl:param name="UGM"/>
		
		<xsl:variable name="namespaceId" select="$UGM/imvert:packages/imvert:base-namespace"/>
		<xsl:choose>
			<xsl:when test="not(empty($namespaceId))">
				<xsl:value-of select="$namespaceId"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$namespaceIdentifier"/>
			</xsl:otherwise>
		</xsl:choose>

		
	</xsl:function>

	<xsl:function name="imf:getVersion" as="xs:string">
		<xsl:param name="UGM"/>
		
		
		<xsl:choose>
			<xsl:when test="$UGM/imvert:packages">
				<xsl:variable name="UGMversion" select="$UGM/imvert:packages/imvert:version"></xsl:variable>
				<xsl:value-of select="$UGMversion"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$version"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
</xsl:stylesheet>
