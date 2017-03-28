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

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-rough-structure</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-rough-structure.xsl 1
		2016-12-01 13:32:00Z RobertMelskens $</xsl:variable>

	<xsl:variable name="verkorteAlias" select="/imvert:packages/imvert:tagged-values/imvert:tagged-value[imvert:name/@original='Verkorte alias']"/>
	<xsl:variable name="namespaceIdentifier" select="/imvert:packages/imvert:base-namespace"/>
	
	<xsl:variable name="prefix" as="xs:string">
		<xsl:choose>
			<xsl:when test="not(empty($verkorteAlias))">
				<xsl:value-of select="$verkorteAlias/imvert:value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$prefix"/>
				<!--xsl:value-of select="TODO"/>
				<xsl:variable name="msg" select="'You have not provided a short alias. Define the tagged value &quot;Verkorte alias&quot; on the package with the stereotyp &quot;Koppelvlak&quot;.'" as="xs:string"/>
				<xsl:sequence select="imf:msg('WARN',$msg)"/-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:key name="associations" match="imvert:association" use="imvert:type-id"/>
	
	<!-- ======= Block of templates used to create the message structure. ======= -->

	<!-- This template is used to start generating the ep structure for an individual message. -->

	<xsl:template
		match="/imvert:packages/imvert:package[not(contains(imvert:alias, '/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]"
		mode="create-rough-message-structure">
		<!-- this is an embedded message schema within the koppelvlak -->

		<xsl:sequence select="imf:create-debug-comment('Template 1: imvert:package[mode=create-rough-message-structure]',$debugging)"/>
		
		<xsl:sequence select="imf:create-debug-track(concat('Constructing the rough-messages for package: ',imvert:name),$debugging)"/>

		<xsl:for-each
			select="imvert:class[(imvert:stereotype = 'VRAAGBERICHTTYPE' or imvert:stereotype = 'ANTWOORDBERICHTTYPE' or imvert:stereotype = 'KENNISGEVINGBERICHTTYPE' or imvert:stereotype = 'VRIJ BERICHTTYPE') and not(key('associations',imvert:id))]"> 
			
			<xsl:sequence select="imf:create-debug-comment(concat('imvert:id: ',imvert:id),$debugging)"/>
				
			<xsl:variable name="associationClassId" select="imvert:associations/imvert:association/imvert:type-id"/>
			<xsl:variable name="fundamentalMnemonic">
				<xsl:choose>
					<xsl:when test="imvert:stereotype = imf:get-config-stereotypes((
						'stereotype-name-vraagberichttype',
						'stereotype-name-antwoordberichttype',
						'stereotype-name-kennisgevingberichttype',
						'stereotype-name-synchronisatieberichttype'))">
						<xsl:value-of select="key('class',$associationClassId)/imvert:alias"/>
					</xsl:when>
					<xsl:when test="imvert:stereotype = imf:get-config-stereotypes((
						'stereotype-name-vrijberichttype'))">
						<xsl:value-of select="''"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="berichtType">
				<xsl:choose>
					<xsl:when test="imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-vraagberichttype'))">Vraagbericht</xsl:when>
					<xsl:when test="imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-antwoordberichttype'))">Antwoordbericht</xsl:when>
					<xsl:when test="imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-kennisgevingberichttype'))">kennisgevingbericht</xsl:when>
					<xsl:when test="imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-synchronisatieberichttype'))">synchronisatiebericht</xsl:when>
					<xsl:when test="imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-vrijberichttype'))">Vrij bericht</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="berichtstereotype" select="imvert:stereotype"/>
			<xsl:variable name="berichtCode" select="imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode']/imvert:value"/>
			<xsl:if test="$berichtCode = ''">
				<xsl:message
					select="concat('ERROR ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The berichtcode can not be determined. To be able to generate correct messages this is neccessary. Check your model for missing tagged values. (', $berichtstereotype)"
				/>
			</xsl:if>
			<!-- create the message -->
			<ep:rough-message>
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
						.[imvert:stereotype = imf:get-config-stereotypes((
						'stereotype-name-vraagberichttype',
						'stereotype-name-antwoordberichttype',
						'stereotype-name-kennisgevingberichttype',
						'stereotype-name-synchronisatieberichttype',
						'stereotype-name-vrijberichttype'))]"
					mode="create-toplevel-rough-message-structure">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="useStuurgegevens" select="'yes'"/>
				</xsl:apply-templates>
			</ep:rough-message>
		</xsl:for-each>
		
		<xsl:sequence select="imf:create-debug-comment('Template 1: imvert:package[mode=create-rough-message-structure] End',$debugging)"/>
	</xsl:template>

	<!-- This template (1) only processes imvert:class elements with an imvert:stereotype 
		with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'KENNISGEVINGBERICHTTYPE',
		'SYNCHRONISATIEBERICHTTYPE'	or 'VRIJ BERICHTTYPE'. Those classes contain a relation 
		to the 'Parameters' group (if not removed), a relation to a class with an imvert:stereotype 
		with the value 'ENTITEITTYPE' or, in case of a ''VRIJ BERICHTTYPE', a relation 
		with one or more classes with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
		'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE'. These 
		classes also have a supertype with an imvert:stereotype with the value 'BERICHTTYPE' 
		which contain a 'melding' attribuut and have a relation to the 'Stuurgegevens' 
		group. This supertype is also processed here. -->
	<xsl:template match="imvert:class" mode="create-toplevel-rough-message-structure">
		<xsl:param name="berichtCode"/>
		<xsl:param name="embeddedBerichtCode"/>
		
		<!-- The purpose of this parameter is to determine if the element 'stuurgegevens' 
			must be generated or not. This is important because the 'kennisgevingbericht' , 
			'vraagbericht' or 'antwoordbericht' objects within the context of a 'vrijbericht' 
			object aren't allowed to contain 'stuurgegevens'. -->
		<xsl:param name="useStuurgegevens" select="'yes'"/>

		<xsl:sequence select="imf:create-debug-comment('Template 2: imvert:class[mode=create-toplevel-rough-message-structure]',$debugging)"/>
		
		<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:association' 
				elements with the stereotype 'GROEP COMPOSITIE' within the supertype 
				of imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
				'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE' and 
				those within the current class. The first one generates the 'stuurgegevens' 
				element, the second one the 'parameters' element. 
				The empty value for the variable 'context' guarantee's not xml attributes are 
				generated with the attributen.-->
		<xsl:apply-templates select="imvert:supertype" mode="create-rough-message-content">
			<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="'-'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="imvert:associations/imvert:association[imvert:stereotype = 'GROEP COMPOSITIE']"
			mode="create-rough-message-content">
			<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so the related object has already been processed) processing 
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
				<xsl:apply-templates
					select="imvert:associations/imvert:association[imvert:stereotype = 'ENTITEITRELATIE']"
					mode="create-rough-message-content">
					<!-- The 'id-trail' parameter has been introduced to be able to prevent 
					recursive processing of classes. If the parser runs into an id already present 
					within the trail (so the related object has already been processed) processing 
					stops. -->
					<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				
				<xsl:sequence select="imf:create-debug-comment('Attribute1',$debugging)"/>
				<xsl:apply-templates select="imvert:attributes/imvert:attribute">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates
					select="imvert:associations/imvert:association[imvert:stereotype = 'ENTITEITRELATIE']"
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
				<xsl:apply-templates
					select="imvert:associations/imvert:association[imvert:stereotype != 'ENTITEITRELATIE']"
					mode="create-toplevel-rough-message-structure">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				
				<xsl:sequence select="imf:create-debug-comment('Attribute2',$debugging)"/>
				<xsl:apply-templates select="imvert:attributes/imvert:attribute">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
				</xsl:apply-templates>
				
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:sequence select="imf:create-debug-comment('Template 2: imvert:class[mode=create-toplevel-rough-message-structure] End',$debugging)"/>
	</xsl:template>

	<!-- This template (2) takes care of processing superclasses of the class being 
		processed. -->
	<xsl:template match="imvert:supertype" mode="create-rough-message-content">
		<xsl:param name="proces-type"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<xsl:sequence select="imf:create-debug-comment('Template 3: imvert:supertype[mode=create-rough-message-content]',$debugging)"/>
		
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		
		<xsl:sequence select="imf:create-debug-comment('Template 3: imvert:supertype[mode=create-rough-message-content] End',$debugging)"/>
	</xsl:template>

	<!-- Declaration of the content of a superclass, an 'imvert:association' and 'imvert:association-class' 
		finaly always takes place within an 'imvert:class' element. This element 
		is processed within this template (3). -->
	<xsl:template match="imvert:class" mode="create-rough-message-content">
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="historyApplies" select="'no'"/>
		<xsl:variable name="id" select="imvert:id"/>

		<xsl:sequence select="imf:create-debug-comment('Template 4: imvert:class[mode=create-rough-message-content]',$debugging)"/>
		
		<xsl:choose>
			<!-- The following takes care of ignoring the processing of the attributes 
				 belonging to the current class. Attributes aren't important for the rough structure. -->
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:sequence select="imf:create-debug-comment('Attribute5',$debugging)"/>
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
				<xsl:apply-templates select="imvert:supertype" mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:if test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
					<xsl:sequence select="imf:create-debug-comment('imvert:class mode=create-rough-message-content and not(contains($id-trail, concat(#2#, imvert:id, #)))',$debugging)"/>
			
					<xsl:variable name="associationsOfBerichtrelatieType" select="$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:stereotype = 'BERICHTRELATIE']"/>
					<xsl:variable name="classRelated2Association" select="$packages/imvert:package/imvert:class[imvert:id = $associationsOfBerichtrelatieType/imvert:type-id]"/>
					<xsl:apply-templates
						select="imvert:associations/imvert:association[imvert:stereotype = 'GROEP COMPOSITIE']"
						mode="create-rough-message-content">
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
			</xsl:when>
			<!-- The following when initiates the processing of the associations refering to the current class as a superclass.
				 In this situation a choice has to be generated. -->
			<xsl:when
				test="$proces-type = 'associationsOrSupertypeRelatie' and $packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
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

							<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>

							<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

							<xsl:sequence
								select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
							<xsl:sequence
								select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
							

							<xsl:apply-templates select=".[name() != 'imvert:attributes']" mode="create-rough-message-content">
								<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
								<xsl:with-param name="id-trail" select="$id-trail"/>
								<xsl:with-param name="berichtCode" select="$berichtCode"/>
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
							
							<xsl:sequence select="imf:create-debug-comment('Attribute4',$debugging)"/>
							
						</ep:construct>
					</xsl:for-each>
				</ep:choice>
			</xsl:when>
			<!-- The following when initiates the processing of the associations belonging 
				to the current class. First the ones found within the superclass of the current 
				class followed by the ones within the current class. -->
			<xsl:when
				test="$proces-type = 'associationsRelatie' or $proces-type = 'associationsOrSupertypeRelatie'">
				<xsl:apply-templates select="imvert:supertype" mode="create-rough-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:choose>
					<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
						<xsl:apply-templates
							select="imvert:associations/imvert:association[imvert:stereotype = 'RELATIE']"
							mode="create-rough-message-content">
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
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		
		<xsl:sequence select="imf:create-debug-comment('Template 4: imvert:class[mode=create-rough-message-content] End',$debugging)"/>
	</xsl:template>

	<!-- This template (5) transforms an 'imvert:association' element to an 'ep:construct' element. -->
	<xsl:template match="imvert:association" mode="create-rough-message-content">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="historyApplies" select="'no'"/>
		<xsl:param name="useStuurgegevens" select="'yes'"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="MogelijkGeenWaarde">
			<xsl:choose>
				<xsl:when
					test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'MogelijkGeenWaarde'"
					>yes</xsl:when>
				<xsl:otherwise>no</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:sequence select="imf:create-debug-comment('Template 5: imvert:association[mode=create-rough-message-content]',$debugging)"/>
		
		<xsl:if test="not($useStuurgegevens = 'no' and imvert:name = 'stuurgegevens')">		
			<ep:construct package="{ancestor::imvert:package/imvert:name}">
				<xsl:attribute name="typeCode">
					<xsl:choose>
						<xsl:when test="imvert:name = 'stuurgegevens' or imvert:name = 'parameters' or imvert:name = 'zender' or imvert:name = 'ontvanger'"/>
						<xsl:when test="imvert:stereotype = 'GROEP COMPOSITIE'">groep</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'relatie'"/>
						</xsl:otherwise>						
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="(imvert:name = 'zender' or imvert:name = 'ontvanger') and contains(ancestor::imvert:package/@display-name,'www.kinggemeenten.nl/BSM/Berichtstrukturen')">
					<xsl:attribute name="className" select="imf:get-construct-by-id($type-id,$packages-doc)/imvert:name"/>
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
						<xsl:when test="imvert:stereotype = 'GROEP COMPOSITIE'">group</xsl:when>
						<xsl:otherwise>association</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="imvert:stereotype != 'GROEP COMPOSITIE'">
						<xsl:variable name="tv-materieleHistorie-attributes">
							<xsl:for-each select="imvert:association-class">
								<xsl:variable name="association-class-type-id" select="imvert:type-id"/>
								<xsl:for-each select="imf:get-construct-by-id($association-class-type-id,$packages-doc)/imvert:attributes/imvert:attribute">
									<ep:tagged-value>
										<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie materiële historie')"/>
									</ep:tagged-value>
								</xsl:for-each>
							</xsl:for-each>									
						</xsl:variable>
						<xsl:if
							test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and $tv-materieleHistorie-attributes//ep:tagged-value = 'JA' or $tv-materieleHistorie-attributes//ep:tagged-value = 'JAZIEREGELS'">
							<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja op attributes'"/>
						</xsl:if>
						<xsl:if
							test="($berichtCode = 'La09' or $berichtCode = 'La10') and contains(imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie formele historie'), 'JA')">
							<xsl:attribute name="indicatieFormeleHistorieRelatie" select="'Ja'"/>
						</xsl:if>
						<xsl:variable name="tv-formeleHistorie-attributes">
							<xsl:for-each select="imvert:association-class">
								<xsl:variable name="association-class-type-id" select="imvert:type-id"/>
								<xsl:for-each select="imf:get-construct-by-id($association-class-type-id,$packages-doc)/imvert:attributes/imvert:attribute">
									<ep:tagged-value>
										<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie formele historie')"/>
									</ep:tagged-value>
								</xsl:for-each>
							</xsl:for-each>									
						</xsl:variable>
						<xsl:if
							test="($berichtCode = 'La09' or $berichtCode = 'La10') and $tv-formeleHistorie-attributes//ep:tagged-value = 'JA'">
							<xsl:attribute name="indicatieFormeleHistorie" select="'Ja op attributes'"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when
								test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and contains(imf:get-most-relevant-compiled-taggedvalue(key('class',$type-id), 'Indicatie materiële historie'), 'JA')">
								<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tv-materieleHistorie-attributes">
									<xsl:for-each select="key('class',$type-id)/imvert:attributes/imvert:attribute">
										<ep:tagged-value>
											<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie materiële historie')"/>
										</ep:tagged-value>
									</xsl:for-each>
								</xsl:variable>
								<xsl:choose>
									<xsl:when
										test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and $tv-materieleHistorie-attributes//ep:tagged-value = 'JA' or $tv-materieleHistorie-attributes//ep:tagged-value = 'JAZIEREGELS'">
										<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja op attributes'"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when
								test="($berichtCode = 'La09' or $berichtCode = 'La10') and contains(imf:get-most-relevant-compiled-taggedvalue(key('class',$type-id), 'Indicatie formele historie'), 'JA')">
								<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="tv-formeleHistorie-attributes">
									<xsl:for-each select="key('class',$type-id)/imvert:attributes/imvert:attribute">
										<ep:tagged-value>
											<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie formele historie')"/>
										</ep:tagged-value>
									</xsl:for-each>
								</xsl:variable>
								<xsl:choose>
									<xsl:when
										test="($berichtCode = 'La09' or $berichtCode = 'La10') and $tv-formeleHistorie-attributes//ep:tagged-value = 'JA'">
										<xsl:attribute name="indicatieFormeleHistorie" select="'Ja op attributes'"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
				<xsl:sequence
					select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))"/>
				<!-- De volgende elementen moeten alleengevuld worden als de relatie gekoppeld is aan een association-class. 
					 De realtie heeft dan zelf attributen waarop historie van toepassing kan zijn. -->
				<xsl:choose>
					<!-- In het geval van een associationgroup wordt er geen 'gerelateerde' elementen tussen gegenereerd en mag het id en type-id gewoon op het huidige element worden gegenereerd. -->
					<xsl:when test="imvert:stereotype != 'RELATIE'">
						<xsl:sequence select="imf:create-output-element('ep:origin-id', imvert:id)"/>
						<xsl:sequence select="imf:create-output-element('ep:id', imvert:type-id)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
				<xsl:variable name="subpath" select="$supplier/@subpath"/>

				<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>

				<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

				<xsl:sequence
					select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
				<xsl:sequence
					select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
				
				<xsl:variable name="gerelateerde" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
				<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct($gerelateerde,'UGM')"/>
				<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>

				<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpathGerelateerde),$debugging)"/>

				<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

				<xsl:sequence
					select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
				<xsl:sequence
					select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
				
				
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
		<xsl:sequence select="imf:create-debug-comment('Template 5: imvert:association[mode=create-rough-message-content] End',$debugging)"/>
	</xsl:template>

	<!-- This template (5) takes care of associations from a 'vrijbericht' type 
		to the other message types 'vraagbericht', 'antwoordbericht' and 'kennisgevingbericht'. -->
	<!-- ROME: De werking van dit template moet nog gecheckt worden zodra er 
		vrije berichten zijn. Waarschijnlijk moet er nog iets gebeuren met de context.
		Ook moet er nog voor gezorgd worden dat het 'functie' xml attribute gegenereerd wordt.-->
	<xsl:template match="imvert:association" mode="create-toplevel-rough-message-structure">
		<xsl:param name="berichtCode"/>
		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:sequence select="imf:create-debug-comment('Template 6: imvert:association[mode=create-toplevel-rough-message-structure]',$debugging)"/>
		
		<xsl:variable name="construct" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
		
		<!-- If the association has a stereotype of 'BERICHTRELATIE' and it's part of a 'vrij bericht' it must refer to an embedded message
			 of another type. In that case the following variable get's a value equal to the value of the 'berichtCode' of the embedded message.
			 This variable is forwarded to be able to proces the content of the embedded message conforming its type later. -->
		<xsl:variable name="embeddedBerichtCode">
			<xsl:choose>
				<xsl:when test="imvert:stereotype = 'BERICHTRELATIE' and contains($berichtCode, 'Di')">
					<xsl:value-of select="key('class',$type-id)//imvert:tagged-value[imvert:name = 'Berichtcode']/imvert:value"/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>

		<ep:construct package="{ancestor::imvert:package/imvert:name}">
			<xsl:attribute name="typeCode">
				<xsl:choose>
					<xsl:when test="imvert:stereotype = 'BERICHTRELATIE'">
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
			<xsl:sequence select="imf:create-output-element('ep:origin-id', imvert:id)"/>
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:type-id)"/>
			
			<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
			<xsl:variable name="subpath" select="$supplier/@subpath"/>

			<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>

			<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

			<xsl:sequence
				select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
			<xsl:sequence
				select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
			
			<xsl:choose>
				<xsl:when test="imvert:stereotype = 'ENTITEITRELATIE'">
					
					<xsl:variable name="gerelateerde" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>

					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpathGerelateerde),$debugging)"/>

					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					

					<xsl:apply-templates select="." mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'-'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="imvert:stereotype = 'BERICHTRELATIE'">
					
					<xsl:variable name="gerelateerde" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>

					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpathGerelateerde),$debugging)"/>

					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					
					<xsl:apply-templates
						select="$construct[imvert:stereotype = imf:get-config-stereotypes((
							'stereotype-name-vraagberichttype',
							'stereotype-name-antwoordberichttype',
							'stereotype-name-kennisgevingberichttype'))]"
						mode="create-toplevel-rough-message-structure">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="embeddedBerichtCode" select="$embeddedBerichtCode"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
		</ep:construct>
		
		<xsl:sequence select="imf:create-debug-comment('Template 6: imvert:association[mode=create-toplevel-rough-message-structure] End',$debugging)"/>
	</xsl:template>

	<!-- This template (6) transforms an 'imvert:association' element of stereotype 'ENTITEITRELATIE' to an 'ep:construct' 
		element.. -->
	<xsl:template match="imvert:association[imvert:stereotype = 'ENTITEITRELATIE']"
		mode="create-rough-message-content">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="historyApplies" select="'no'"/>
		<xsl:param name="embeddedBerichtCode"/>
		
		<xsl:variable name="context">
			<xsl:choose>
				<xsl:when
					test="imvert:name = 'gelijk' or imvert:name = 'vanaf' or imvert:name = 'totEnMet'">
					<xsl:value-of select="'selectie'"/>
				</xsl:when>
				<xsl:when
					test="imvert:name = 'start' or imvert:name = 'scope'">
					<xsl:value-of select="imvert:name"/>
				</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:sequence select="imf:create-debug-comment('Template 7: imvert:association[imvert:stereotype=ENTITEITRELATIE and mode=create-rough-message-content]',$debugging)"/>
		
		<xsl:choose>
			<xsl:when test="contains($berichtCode, 'La') or contains($embeddedBerichtCode, 'La')">
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
					<xsl:with-param name="historyApplies">
						<xsl:choose>
							<xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'"
								>yes-Materieel</xsl:when>
							<xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'"
								>yes</xsl:when>
							<xsl:otherwise>no</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lv') or contains($embeddedBerichtCode, 'Lv')">
				<xsl:choose>
					<!--xsl:when test="$context = 'gelijk' or $context = 'vanaf' or $context = 'totEnMet'"-->
					<xsl:when test="$context = 'selectie'">
						<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="constructName" select="'-'"/>
							<xsl:with-param name="historyApplies" select="'no'"/>
							<xsl:with-param name="typeCode" select="'toplevel'"/>					
							<xsl:with-param name="embeddedBerichtCode" select="$embeddedBerichtCode"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$context = 'start'">
						<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="constructName" select="'-'"/>
							<xsl:with-param name="historyApplies" select="'no'"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$context = 'scope'">
						<xsl:call-template name="createRoughEntityConstruct">
							<xsl:with-param name="id-trail" select="$id-trail"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="constructName" select="'-'"/>
							<xsl:with-param name="historyApplies" select="'no'"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>

			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lk') or contains($embeddedBerichtCode, 'Lk')">
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
					<xsl:with-param name="historyApplies" select="'no'"/>
					<xsl:with-param name="typeCode" select="'toplevel'"/>					
					<xsl:with-param name="embeddedBerichtCode" select="$embeddedBerichtCode"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Sh')"> </xsl:when>
			<xsl:when test="contains($berichtCode, 'Sa')"> </xsl:when>
			<xsl:when test="contains($berichtCode, 'Di')">
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
					<xsl:with-param name="historyApplies" select="'no'"/>
					<xsl:with-param name="typeCode" select="'entiteitrelatie'"/>					
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Du')">
				<xsl:call-template name="createRoughEntityConstruct">
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="constructName" select="'-'"/>
					<xsl:with-param name="historyApplies" select="'no'"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
		
		<xsl:sequence select="imf:create-debug-comment('Template 7: imvert:association[imvert:stereotype=ENTITEITRELATIE and mode=create-rough-message-content] End',$debugging)"/>
	</xsl:template>

	<!-- This template (8) generates the structure of a relatie on a relatie. -->
	<!-- ROME: De werking van dit template moet adhv van een voorbeeld gecheckt 
		en mogelijk geoptimaliseerd worden. Zo is de vraag of een association-class 
		een supertype kan hebben. Zo ja dan moeten er nog apply-templates worden 
		opgenomen voor het verwerken van de supertypes. -->
	<xsl:template match="imvert:association-class" mode="create-rough-message-content">
		<xsl:param name="proces-type" select="'associations'"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>
		
		<xsl:sequence select="imf:create-debug-comment('Template8: imvert:association-class[mode=create-rough-message-content]',$debugging)"/>
		
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="id-trail" select="$id-trail"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		<!-- ROME: Aangezien een association-class alleen de attributen levert 
			van een relatie en dat relatie element al ergens anders zijn XML-attributes 
			toegekend krijgt hoeven er hier geen attributes meer toegekend te worden. -->
		
		<xsl:sequence select="imf:create-debug-comment('Template8: imvert:association-class[mode=create-rough-message-content] End',$debugging)"/>
	</xsl:template>

	<xsl:template match="imvert:attribute">
		<xsl:param name="proces-type"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context" select="'-'"/>
		
		<xsl:variable name="type-id" select="imvert:type-id"/>
		
		<xsl:choose>
			<xsl:when test="imvert:type-id and //imvert:class[imvert:id = $type-id]/imvert:stereotype = 'COMPLEX DATATYPE'">
				<xsl:sequence select="imf:create-debug-comment(concat('Class: ',$type-id),$debugging)"/>
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
					<xsl:attribute name="type" select="'group'"/>
					<xsl:if
						test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and 
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1) or
						(count(key('class',$type-id)/imvert:associations/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1))">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:if
						test="($berichtCode = 'La09' or $berichtCode = 'La10') and
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1) or
						(count(key('class',$type-id)/imvert:associations/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1))">
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
					
					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>
					
					<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
					
					<xsl:variable name="gerelateerde" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
					
					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpathGerelateerde),$debugging)"/>
					
					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					
					<xsl:variable name="class-id" select="imvert:type-id"/>
					<xsl:sequence
						select="imf:create-output-element('ep:class-name', imf:get-construct-by-id($class-id,$packages-doc)/ep:name)"/>
					
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
				</ep:construct>
			</xsl:when>
			<xsl:when test="imvert:type-id and //imvert:class[imvert:id = $type-id]/imvert:stereotype = 'TABEL-ENTITEIT'">
				<xsl:sequence select="imf:create-debug-comment(concat('Class: ',$type-id),$debugging)"/>
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
						test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and 
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1) or
						(count(key('class',$type-id)/imvert:associations/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1))">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:if
						test="($berichtCode = 'La09' or $berichtCode = 'La10') and
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1) or
						(count(key('class',$type-id)/imvert:associations/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1))">
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
					
					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>
					
					<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
					
					<xsl:variable name="gerelateerde" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>
					
					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpathGerelateerde),$debugging)"/>
					
					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>
					
					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					
					<xsl:variable name="class-id" select="imvert:type-id"/>
					<xsl:sequence
						select="imf:create-output-element('ep:class-name', imf:get-construct-by-id($class-id,$packages-doc)/ep:name)"/>
					
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-rough-message-content">
						<!-- The 'id-trail' parameter has been introduced to be able to prevent 
							recursive processing of classes. If the parser runs into an id already present 
							within the trail (so the related object has already been processed) processing 
							stops. -->
						<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
						<xsl:with-param name="id-trail" select="''"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'attribute'"/>
					</xsl:apply-templates>
				</ep:construct>
			</xsl:when>
		</xsl:choose>
		
		<!--ep:attribute>
			<xsl:sequence
				select="imf:create-output-element('ep:name', imvert:name/@original)"/>
			
			<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
			<xsl:variable name="subpath" select="$supplier/@subpath"/>

			<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>

			<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

			<xsl:sequence
				select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
			<xsl:sequence
				select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
			
		</ep:attribute-->
	</xsl:template>

	<xsl:template name="createRoughEntityConstruct">
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="type-id"/>
		<xsl:param name="constructName"/>
		<xsl:param name="historyApplies"/>
		<xsl:param name="typeCode" select="''"/>					
		<xsl:param name="embeddedBerichtCode"/>
		
		<xsl:sequence select="imf:create-debug-comment('Template9: createRoughEntityConstruct',$debugging)"/>

		<xsl:sequence select="imf:create-debug-comment(concat('berichtCode: ',$berichtCode),$debugging)"/>
		
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
				test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and 
				((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1) or
				(count(key('class',$type-id)/imvert:associations/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1))">
				<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
			</xsl:if>
			<xsl:if
				test="($berichtCode = 'La09' or $berichtCode = 'La10') and
				((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1) or
				(count(key('class',$type-id)/imvert:associations/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1))">
				<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
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

			<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>

			<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

			<xsl:sequence
				select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
			<xsl:sequence
				select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
			
			<xsl:if test="$typeCode = 'entiteitrelatie' or $typeCode = 'berichtrelatie' or $typeCode = 'toplevel' or $typeCode = ''">
				<xsl:variable name="gerelateerde" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
				<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
				<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>

				<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpathGerelateerde),$debugging)"/>
				
				<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

				<xsl:sequence
					select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
				<xsl:sequence
					select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>

			</xsl:if>
			
			<xsl:variable name="class-id" select="imvert:type-id"/>
			<xsl:sequence
				select="imf:create-output-element('ep:class-name', imf:get-construct-by-id($class-id,$packages-doc)/ep:name)"/>
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
		
		<xsl:sequence select="imf:create-debug-comment('Template9: createRoughEntityConstruct End',$debugging)"/>
	</xsl:template>

	<!-- This template generates the structure of the 'gerelateerde' type element. -->
	<xsl:template name="createRoughRelatiePartOfAssociation">
		<xsl:param name="type-id"/>
		<xsl:param name="id"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<xsl:sequence select="imf:create-debug-comment('Template10: createRoughRelatiePartOfAssociation',$debugging)"/>
		
		<!-- The following choose processes the 3 situations an association can 
			represent. -->
		<xsl:choose>
			<!-- The association is a 'relatie' and it has to contain a 'gerelateerde' 
				 construct. -->
			<xsl:when test="key('class',$type-id) and imvert:stereotype = 'RELATIE'">
				<xsl:sequence select="imf:create-debug-comment(concat('key(class,$type-id) and imvert:stereotype = RELATIE, met type-id: ',$type-id),$debugging)"/>
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
						test="($berichtCode = 'La07' or $berichtCode = 'La08' or $berichtCode = 'La09' or $berichtCode = 'La10') and
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1) or
						(count(key('class',$type-id)/imvert:attributes/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie materiële historie' and (imvert:value = 'JA' or imvert:value = 'JAZIEREGELS')]) >= 1))">
						<xsl:attribute name="indicatieMaterieleHistorie" select="'Ja'"/>
					</xsl:if>
					<xsl:if
						test="($berichtCode = 'La09' or $berichtCode = 'La10') and
						((count(key('class',$type-id)/imvert:attributes/imvert:attribute/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1) or
						(count(key('class',$type-id)/imvert:attributes/imvert:association/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie formele historie' and imvert:value = 'JA']) >= 1))">
						<xsl:attribute name="indicatieFormeleHistorie" select="'Ja'"/>
					</xsl:if>
					<ep:name>gerelateerde</ep:name>
					<ep:tech-name>gerelateerde</ep:tech-name>
					<xsl:sequence select="imf:create-output-element('ep:origin-id', $id)"/>
					<xsl:sequence select="imf:create-output-element('ep:id', $type-id)"/>
					
					<xsl:variable name="supplier" select="imf:get-trace-supplier-for-construct(.,'UGM')"/>
					<xsl:variable name="subpath" select="$supplier/@subpath"/>

					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpath),$debugging)"/>

					<xsl:variable name="UGM" select="imf:get-imvert-system-doc($subpath)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAlias', imf:getVerkorteAlias($UGM))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifier', imf:getNamespaceIdentifier($UGM))"/>
					

					<xsl:variable name="gerelateerde" select="imf:get-construct-by-id($type-id,$packages-doc)"/>
					<xsl:variable name="supplierGerelateerde" select="imf:get-trace-supplier-for-construct($gerelateerde,'UGM')"/>
					<xsl:variable name="subpathGerelateerde" select="$supplierGerelateerde/@subpath"/>

					<xsl:sequence select="imf:create-debug-comment(concat('Subpath: ',$subpathGerelateerde),$debugging)"/>

					<xsl:variable name="UGMgerelateerde" select="imf:get-imvert-system-doc($subpathGerelateerde)"/>

					<xsl:sequence
						select="imf:create-output-element('ep:verkorteAliasGerelateerdeEntiteit', imf:getVerkorteAlias($UGMgerelateerde))"/>
					<xsl:sequence
						select="imf:create-output-element('ep:namespaceIdentifierGerelateerdeEntiteit', imf:getNamespaceIdentifier($UGMgerelateerde))"/>
					
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
						<!-- ROME: Het is de vraag of deze parameter en het checken op id 
							nog wel noodzakelijk is. -->
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
				test="imf:get-construct-by-id($type-id,$packages-doc)[imvert:stereotype = 'ENTITEITTYPE']">
				<xsl:sequence select="imf:create-debug-comment('//imvert:class[imvert:id = $type-id and imvert:stereotype = ENTITEITTYPE]',$debugging)"/>
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
			<!-- ROME: Checken of de volgende when idd de berichtRelatie afhandelt 
				en of alle benodigde (standaard) elementen wel gegenereerd worden. Er wordt 
				geen supertype in afgehandeld, ik weet even niet meer waarom. 
				Volgens mij wordt hierin ook een class met stereotype GROEP afgehandeld 
				waarvoor geen constructRef gemaakt hoeft te worden.-->
			<xsl:when test="key('class',$type-id)">
				<xsl:sequence select="imf:create-debug-comment('key(class,$type-id)',$debugging)"/>
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
		
		<xsl:sequence select="imf:create-debug-comment('Template10: createRoughRelatiePartOfAssociation End',$debugging)"/>
	</xsl:template>

	<!-- ======= End block of templates used to create the message structure. ======= -->

	<xsl:function name="imf:getVerkorteAlias" as="xs:string">
		<xsl:param name="UGM"/>

		<xsl:variable name="verkorteAlias" select="$UGM/imvert:packages/imvert:tagged-values/imvert:tagged-value[imvert:name/@original='Verkorte alias']"/>
		<xsl:choose>
			<xsl:when test="not(empty($verkorteAlias))">
				<xsl:value-of select="$verkorteAlias/imvert:value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$prefix"/>
				<!--xsl:value-of select="TODO"/>
									<xsl:variable name="msg" select="concat('You have not provided a short alias for the UGM application: ',$supplier/@application,'. Define the tagged value &quot;Verkorte alias&quot; on the package with the stereotyp &quot;Koppelvlak&quot;.')" as="xs:string"/>
									<xsl:sequence select="imf:msg('WARN',$msg)"/-->
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
				<!--xsl:value-of select="TODO"/>
									<xsl:variable name="msg" select="concat('You have not provided a short alias for the UGM application: ',$supplier/@application,'. Define the tagged value &quot;Verkorte alias&quot; on the package with the stereotyp &quot;Koppelvlak&quot;.')" as="xs:string"/>
									<xsl:sequence select="imf:msg('WARN',$msg)"/-->
			</xsl:otherwise>
		</xsl:choose>

		
	</xsl:function>
</xsl:stylesheet>
