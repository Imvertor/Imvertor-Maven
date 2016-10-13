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
	xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0">

	<xsl:import href="../common/Imvert-common-derivation.xsl"/>

	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-structure</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-structure.xsl 1
		2015-11-11 11:50:00Z RobertMelskens $</xsl:variable>

	<!-- ======= Block of templates used to create the message structure. ======= -->

	<!-- This template is used to start generating the ep structure for all individual messages. -->

	<xsl:template match="/imvert:packages/imvert:package[not(contains(imvert:alias, '/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]"
		mode="create-message-structure">
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template: /imvert:packages/imvert:package[mode=create-message-structure]'"/>
		</xsl:if>

		<xsl:for-each
			select="imvert:class[imvert:stereotype = 'VRAAGBERICHTTYPE' or imvert:stereotype = 'ANTWOORDBERICHTTYPE' or imvert:stereotype = 'KENNISGEVINGBERICHTTYPE' or imvert:stereotype = 'VRIJBERICHTTYPE']">
			<xsl:variable name="berichtSoort">
				<xsl:choose>
					<xsl:when test="imvert:stereotype = 'VRAAGBERICHTTYPE'">Vraagbericht</xsl:when>
					<xsl:when test="imvert:stereotype = 'ANTWOORDBERICHTTYPE'"
						>Antwoordbericht</xsl:when>
					<xsl:when test="imvert:stereotype = 'KENNISGEVINGBERICHTTYPE'"
						>Kennisgevingbericht</xsl:when>
					<xsl:when test="imvert:stereotype = 'VRIJBERICHTTYPE'">Vrij bericht</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="berichtstereotype">
				<xsl:value-of select="imvert:stereotype"/>
			</xsl:variable>
			<xsl:variable name="berichtCode">
				<xsl:value-of
					select="imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode']/imvert:value"
				/>
			</xsl:variable>
			<xsl:variable name="docs">
				<imvert:complete-documentation>
					<xsl:copy-of select="imf:get-compiled-documentation(.)"/>
				</imvert:complete-documentation>
			</xsl:variable>
			<xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
			<xsl:variable name="name" select="imvert:name/@original"/>
			<xsl:variable name="tech-name" select="imf:get-normalized-name(imvert:name, 'element-name')"/>
			<xsl:variable name="package-type" select="../imvert:stereotype"/>
			<xsl:variable name="release" select="/imvert:packages/imvert:release"/>


			<xsl:if test="$berichtCode = ''">
				<xsl:message
					select="concat('ERROR ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The berichtcode can not be determined. To be able to generate correct messages this is neccessary. Check your model for missing tagged values. (', $berichtstereotype,')')"
				/>
			</xsl:if>
			<!-- create a message -->
			<ep:message>
				<xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)"/>
				<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
				<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
				<xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
				<xsl:sequence select="imf:create-output-element('ep:package-type', $package-type)"/>
				<xsl:sequence select="imf:create-output-element('ep:release', $release)"/>
				<xsl:sequence select="imf:create-output-element('ep:type', $berichtSoort)"/>
				<!-- Start of the message is always a class with an imvert:stereotype 
					with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE', 
					'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE'. Since the toplevel structure of a message 
					complies to different rules in comparison with the entiteiten structure this 
					template is initialized within the 'create-initial-message-structure' mode. -->
				<xsl:apply-templates
					select="
						.[imvert:stereotype = imf:get-config-stereotypes((
						'stereotype-name-vraagberichttype',
						'stereotype-name-antwoordberichttype',
						'stereotype-name-vrijberichttype',
						'stereotype-name-kennisgevingberichttype',
						'stereotype-name-synchronisatieberichttype'))]"
					mode="create-toplevel-message-structure">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="useStuurgegevens" select="'yes'"/>
				</xsl:apply-templates>
			</ep:message>
		</xsl:for-each>
	</xsl:template>

	<!-- This template (1) only processes imvert:class elements with an imvert:stereotype 
		with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE', 
		'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE'. Those classes contain a relation to the 'Parameters' 
		group (if not removed), a relation to a class with an imvert:stereotype with 
		the value 'ENTITEITTYPE' or, in case of a ''VRIJBERICHTTYPE', a relation 
		with one or more classes with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
		'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE' or 'KENNISGEVINGBERICHTTYPE'. -->
	<xsl:template match="imvert:class" mode="create-toplevel-message-structure">
		<xsl:param name="messagePrefix" select="''"/>
		<xsl:param name="berichtCode"/>

		<!-- The purpose of this parameter is to determine if the element 'stuurgegevens' 
			 must be generated or not. This is important because the 'kennisgevingbericht' , 
			 'vraagbericht' or 'antwoordbericht' objects within the context of a 'vrijbericht' 
			 object aren't allowed to contain 'stuurgegevens'. -->
		<xsl:param name="useStuurgegevens" select="'yes'"/>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template: imvert:class[mode=create-initial-message-structure]'"/>
		</xsl:if>

		<ep:seq>
			<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:attribute' 
				elements within the supertype of imvert:class elements with an imvert:stereotype 
				with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE', 
				'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE' and those within the current class. 
				The empty value for the variable 'context' guarantee's not xml attributes are 
				generated with the attributen.-->
			<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
				<xsl:with-param name="proces-type" select="'attributes'"/>
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="context" select="''"/>
			</xsl:apply-templates>
			<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="context" select="''"/>
			</xsl:apply-templates>

			<!-- The folowing 2 apply-templates initiate the processing of the 'imvert:association' 
				elements with the stereotype 'GROEP COMPOSITIE' within the supertype 
				of imvert:class elements with an imvert:stereotype with the value 'VRAAGBERICHTTYPE', 
				'ANTWOORDBERICHTTYPE', 'VRIJBERICHTTYPE', 'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE' and 
				those within the current class. The first one generates the 'stuurgegevens' 
				element, the second one the 'parameters' element. 
				The empty value for the variable 'context' guarantee's not xml attributes are 
				generated with the attributen.-->
			<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
				<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="context" select="''"/>
			</xsl:apply-templates>
			<xsl:apply-templates
				select=".//imvert:association[imvert:stereotype = 'GROEP COMPOSITIE']"
				mode="create-message-content">
				<xsl:with-param name="berichtCode" select="$berichtCode"/>
				<xsl:with-param name="context" select="''"/>
			</xsl:apply-templates>

			<!-- At this level an association with a class having the stereotype 'ENTITEITTYPE' 
				 always has the stereotype 'ENTITEITRELATIE'. The following apply-templates 
				 initiates the processing of such an association.
				 The supertype of the current class will never contain an association with a stereotype 
				 of 'ENTITEITRELATIE'. For that reason no apply-templates on the supertype in this context 
				 is implemented. -->
			
			<xsl:choose>
				<xsl:when
					test="not(contains($berichtCode, 'Di')) and not(contains($berichtCode, 'Du'))">
					<xsl:apply-templates
						select=".//imvert:association[imvert:stereotype = 'ENTITEITRELATIE']"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="orderingDesired" select="'no'"/>
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
					<xsl:apply-templates select=".//imvert:association"
						mode="create-toplevel-message-structure">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</ep:seq>
	</xsl:template>

	<!-- This template (2) takes care of processing the superclass of the class being 
		 processed. It will start processing the attributes, groups or associations of the superclass. -->
	<xsl:template match="imvert:supertype" mode="create-message-content">
		<xsl:param name="proces-type"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="historyApplies" select="'no'"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template: imvert:supertype[mode=create-message-content]'"/>
		</xsl:if>

		<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
			mode="create-message-content">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
			<xsl:with-param name="historyApplies" select="$historyApplies"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- Declaration of the content of a superclass, an 'imvert:association' and 'imvert:association-class' 
		finaly always takes place within an 'imvert:class' element. This element 
		is processed within this template (3). -->
	<xsl:template match="imvert:class" mode="create-message-content">
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="historyApplies" select="'no'"/>
		<xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>

		<xsl:variable name="id" select="imvert:id"/>
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template: imvert:class[mode=create-message-content]'"/>
		</xsl:if>

		<xsl:choose>
			<!-- The following when initiate the processing of the attributes belonging 
				to the current class. First the ones found within the superclass of the current 
				class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="historyApplies" select="$historyApplies"/>
					<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
					<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="historyApplies" select="$historyApplies"/>
					<xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
					<xsl:with-param name="indicatieFormeleHistorie" select="$indicatieFormeleHistorie"/>
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
				<xsl:if
					test="upper-case(imvert:name) = 'STUURGEGEVENS' or upper-case(imvert:name) = 'PARAMETERS'">
					<xsl:call-template name="areParametersAndStuurgegevensAllowedOrRequired">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="elements2bTested">
							<imvert:attributesAndAssociations>
								<xsl:for-each select=".//imvert:attribute">
									<imvert:attribute>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', imvert:name)"
										/>
									</imvert:attribute>
								</xsl:for-each>
								<xsl:for-each select=".//imvert:association">
									<imvert:association>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', imvert:name)"
										/>
									</imvert:association>
								</xsl:for-each>
							</imvert:attributesAndAssociations>
						</xsl:with-param>
						<xsl:with-param name="parent" select="imvert:name"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="imvert:name = 'Stuurgegevens'">
						<xsl:for-each select=".//imvert:attribute">
							<xsl:variable name="isElementAllowed"
								select="imf:isElementAllowed($berichtCode, imvert:name, 'Stuurgegevens')"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:variable name="msg"
									select="concat('Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within stuurgegevens.')"/>
								<xsl:sequence select="imf:msg('WARN', $msg)"/>
							</xsl:if>
						</xsl:for-each>
						<xsl:for-each select=".//imvert:association">
							<xsl:variable name="isElementAllowed"
								select="imf:isElementAllowed($berichtCode, imvert:name, 'Stuurgegevens')"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:variable name="msg"
									select="concat('Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within stuurgegevens.')"/>
								<xsl:sequence select="imf:msg('WARN', $msg)"/>
							</xsl:if>
						</xsl:for-each>
						<xsl:variable name="availableStuurgegevens">
							<imvert:attributesAndAssociations>
								<xsl:for-each select=".//imvert:attribute">
									<imvert:attribute>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', imvert:name)"
										/>
									</imvert:attribute>
								</xsl:for-each>
								<xsl:for-each select=".//imvert:association">
									<imvert:association>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', imvert:name)"
										/>
									</imvert:association>
								</xsl:for-each>
							</imvert:attributesAndAssociations>
						</xsl:variable>
						<xsl:for-each
							select="$enriched-endproduct-base-config-excel//sheet[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data = $berichtCode]/col[@number > 2 and @number &lt; 11 and data != '-']">
							<xsl:if test="count($availableStuurgegevens//imvert:name = @name) = 0">
								<xsl:variable name="msg"
									select="concat('Within messagetype ', $berichtCode, ' element ', @name, ' must be available within stuurgegevens.')"/>
								<xsl:sequence select="imf:msg('WARN', $msg)"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="imvert:name = 'Parameters'">
						<xsl:for-each select=".//imvert:attribute">
							<xsl:variable name="isElementAllowed"
								select="imf:isElementAllowed($berichtCode, imvert:name, 'Parameters')"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:variable name="msg"
									select="concat('Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within parameters.')"/>
								<xsl:sequence select="imf:msg('WARN', $msg)"/>
							</xsl:if>
						</xsl:for-each>
						<xsl:for-each select=".//imvert:association">
							<xsl:variable name="isElementAllowed"
								select="imf:isElementAllowed($berichtCode, imvert:name, 'Parameters')"/>
							<xsl:if test="$isElementAllowed = 'no'">
								<xsl:variable name="msg"
									select="concat('Within messagetype ', $berichtCode, ' element ', imvert:name, ' is not allowed within parameters.')"/>
								<xsl:sequence select="imf:msg('WARN', $msg)"/>
							</xsl:if>
						</xsl:for-each>
						<xsl:variable name="availableParameters">
							<imvert:attributesAndAssociations>
								<xsl:for-each select=".//imvert:attribute">
									<imvert:attribute>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', imvert:name)"
										/>
									</imvert:attribute>
								</xsl:for-each>
								<xsl:for-each select=".//imvert:association">
									<imvert:association>
										<xsl:sequence
											select="imf:create-output-element('imvert:name', imvert:name)"
										/>
									</imvert:association>
								</xsl:for-each>
							</imvert:attributesAndAssociations>
						</xsl:variable>
						<xsl:for-each
							select="$enriched-endproduct-base-config-excel//sheet[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data = $berichtCode]/col[@number > 11 and data != '-']">
							<xsl:if test="count($availableParameters//imvert:name = @name) = 0">
								<xsl:variable name="msg"
									select="concat('Within messagetype ', $berichtCode, ' element ', @name, ' must be available within parameters.')"/>
								<xsl:sequence select="imf:msg('WARN', $msg)"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="historyApplies" select="$historyApplies"/>
				</xsl:apply-templates>
				<xsl:apply-templates
					select=".//imvert:association[imvert:stereotype = 'GROEP COMPOSITIE']"
					mode="create-message-content">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="historyApplies" select="$historyApplies"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- The following when initiates the processing of the classes refering to the current class as a superclass.
				 In this situation a choice has to be generated. -->
			<xsl:when test="$proces-type = 'associationsOrSupertypeRelatie' and //imvert:class[imvert:supertype/imvert:type-id = $id]">
				<ep:choice>
					<!--xsl:sequence select="imf:create-output-element('ep:mnemonic', imvert:alias)"/-->
					<xsl:for-each select="//imvert:class[imvert:supertype/imvert:type-id = $id]">
						<xsl:variable name="mnemonic">
							<xsl:value-of select="imvert:alias"/>
						</xsl:variable>
						<xsl:variable name="href">
							<xsl:variable name="mnemonicPartOfName">
								<xsl:choose>
									<xsl:when test="$mnemonic != ''">
										<xsl:value-of select="concat($mnemonic, '-')"/>
									</xsl:when>
								</xsl:choose>
							</xsl:variable>
							<xsl:value-of select="concat($mnemonicPartOfName, imf:get-normalized-name(@formal-name, 'type-name'))"/>
						</xsl:variable>
						
						<ep:constructRef>
							<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', 1)"/>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', 1)"/>
							<xsl:sequence select="imf:create-output-element('ep:href', $href)"/>
						</ep:constructRef>
					</xsl:for-each>
				</ep:choice>
				<ep:seq>
					<xsl:variable name="mnemonic">
						<xsl:value-of select="imvert:alias"/>
					</xsl:variable>
					<xsl:if test="imf:boolean($debug)">
						<xsl:comment select="concat('Attributes voor gerelateerde met een choice, berichtcode: ', substring($berichtCode, 1, 2), ', context: choice en mnemonic: ', $mnemonic)"/>
					</xsl:if>
					<xsl:variable name="attributes"
						select="imf:createAttributes('gerelateerde', substring($berichtCode, 1, 2), 'choice', 'no', $mnemonic, 'no', 'no')"/>
					<xsl:sequence select="$attributes"/>
				</ep:seq>
			</xsl:when>
			<!-- The following when initiate the processing of the associations belonging 
				to the current class. First the ones found within the superclass of the current 
				class followed by the ones within the current class. -->
			<xsl:when test="$proces-type = 'associationsRelatie' or $proces-type = 'associationsOrSupertypeRelatie'">
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- If the class hasn't been processed before it can be processed, else. 
					to prevent recursion, processing is canceled. -->
				<xsl:apply-templates select=".//imvert:association[imvert:stereotype = 'RELATIE']"
					mode="create-message-content">
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- This template takes care of creating the constructRef constructs form the current class but also from the supertype of the current class
		 that refer to global constructs. -->
	<xsl:template match="imvert:class" mode="create-message-content-constructRef">
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="historyApplies" select="'no'"/>
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template: imvert:class[mode=create-message-content-constructRef]'"/>
		</xsl:if>
		<xsl:apply-templates select="imvert:supertype" mode="create-message-content-constructRef">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
		<xsl:apply-templates select=".//imvert:association[imvert:stereotype = 'RELATIE']"
			mode="create-message-content-constructRef">
			<xsl:with-param name="berichtCode" select="$berichtCode"/>
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:template>

	<!-- This template (4) transforms an 'imvert:association' element to a global 'ep:construct' 
		 element. -->
	<xsl:template match="imvert:association" mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="orderingDesired" select="'yes'"/>
		<xsl:param name="historyApplies" select="'no'"/>

		<xsl:variable name="type-id" select="imvert:type-id"/>
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template: imvert:association[mode=create-message-content]'"/>
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="imvert:stereotype = 'GROEP COMPOSITIE'">
				<xsl:call-template name="createRelatiePartOfAssociation">
					<xsl:with-param name="type-id" select="$type-id"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
					<xsl:with-param name="historyApplies" select="$historyApplies"/>
				</xsl:call-template>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="mnemonic">
					<xsl:choose>
						<xsl:when test="imvert:stereotype = 'ENTITEITRELATIE'">
							<xsl:value-of select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="imvert:alias"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="name" select="imvert:name/@original"/>
				<xsl:variable name="tech-name">
					<xsl:choose>
						<xsl:when
							test="imvert:stereotype = 'RELATIE' and //imvert:class[imvert:id = $type-id]/imvert:alias">
							<xsl:value-of
								select="concat($mnemonic, '-', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
							/>
						</xsl:when>
						<xsl:when test="imvert:stereotype = 'RELATIE'">
							<xsl:value-of
								select="imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name')"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="imf:get-normalized-name(imvert:name, 'element-name')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="max-occurs" select="imvert:max-occurs"/>
				<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
				<xsl:variable name="id" select="imvert:id"/>
				<xsl:variable name="kerngegeven" select="imvert:is-id"/>
				<xsl:variable name="docs">
					<imvert:complete-documentation>
						<xsl:copy-of select="imf:get-compiled-documentation(.)"/>
					</imvert:complete-documentation>
				</xsl:variable>
				<xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
				<xsl:variable name="tvs">
					<ep:tagged-values>
						<xsl:copy-of select="imf:get-compiled-tagged-values(., true())"/>
					</ep:tagged-values>
				</xsl:variable>
				<?x xsl:variable name="stuf-scalar" select="imf:get-stuf-scalar-attribute-type(.)"/ x?>
		
				<!-- ROME: De vraag is nog of de volgende twee variabelen ('materieleHistorie' en 'formeleHistorie') wel nodig zijn op dit niveau. -->
				<xsl:variable name="materieleHistorie"
					select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie materiële historie')"/>
				<xsl:variable name="formeleHistorie"
					select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie formele historie')"/>
		
				<xsl:variable name="mogelijkGeenWaarde"
					select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Mogelijk geen waarde')"/>
		
				<ep:construct>
					<xsl:if test="imf:boolean($debug)">
						<ep:tagged-values>
							<xsl:copy-of select="$tvs"/>
							<ep:found-tagged-values>
								<xsl:sequence
									select="imf:create-output-element('ep:kerngegeven', $kerngegeven)"/>
								<xsl:sequence
									select="imf:create-output-element('ep:materieleHistorie', $materieleHistorie)"/>
								<xsl:sequence
									select="imf:create-output-element('ep:formeleHistorie', $formeleHistorie)"/>
								<xsl:sequence
									select="imf:create-output-element('ep:mogelijkGeenWaarde', $mogelijkGeenWaarde)"
								/>
							</ep:found-tagged-values>
						</ep:tagged-values>
					</xsl:if>
					<xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
					<xsl:sequence select="imf:create-output-element('ep:mnemonic', $mnemonic)"/>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
					<!--xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/-->
		
					<xsl:sequence
						select="imf:create-output-element('ep:authentiek', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie authentiek']/imvert:value)"/>
		
					<!--xsl:sequence select="imf:create-output-element('ep:id', $id)"/-->
		
					<!-- When a tagged-value 'Positie' exists this is used to assign a value to 'ep:position' if not the value of the element 'imvert:position' is used. -->
					<xsl:choose>
						<xsl:when
							test="imvert:stereotype != 'RELATIE' and imvert:tagged-values/imvert:tagged-value/imvert:name = 'Positie'">
							<xsl:sequence
								select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Positie']/imvert:value)"/>
							<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')"/>
						</xsl:when>
						<xsl:when test="imvert:stereotype != 'RELATIE' and imvert:position">
							<xsl:sequence select="imf:create-output-element('ep:position', imvert:position)"/>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
					<!-- An 'ep:construct' based on an 'imvert:association' element can contain 
				several other 'ep:construct' elements (e.g. 'ep:constructs' for the attributes 
				of the association itself or for the associations of the association) therefore 
				an 'ep:seq' element is generated here. -->
					<ep:seq>
						<!-- ROME: De test op de variabele $oderingDesired is hier wellicht niet 
					meer nodig omdat er nu een separaat template is voor het afhandelen het 'imvert:association' 
					element met het stereotype 'ENTITEITRELATIE'. -->
						<xsl:if test="$orderingDesired = 'no'">
							<xsl:attribute name="orderingDesired" select="'no'"/>
						</xsl:if>
						<xsl:call-template name="createRelatiePartOfAssociation">
							<xsl:with-param name="type-id" select="$type-id"/>
							<xsl:with-param name="berichtCode" select="$berichtCode"/>
							<xsl:with-param name="context" select="$context"/>
						</xsl:call-template>
						<!-- Only in case of an association representing a 'relatie' and containing 
					a 'gerelateerde' construct (within the above choose the first 'when' XML 
					Attributes for the 'relatie' type element have to be generated. Because these 
					has to be placed outside the 'gerelateerde' element it has to be done here. -->
						<xsl:if test="imvert:stereotype = 'RELATIE'">
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
							<xsl:if test="imf:boolean($debug)">
								<xsl:comment select="concat('Attributes voor relatie, berichtcode: ', substring($berichtCode, 1, 2), ', context: ', $context, ' en mnemonic: ', $mnemonic)"/>
							</xsl:if>
							<xsl:variable name="attributes"
								select="imf:createAttributes('relatie', substring($berichtCode, 1, 2), $context, 'no', $mnemonic, $mogelijkGeenWaarde, 'no')"/>
							<xsl:sequence select="$attributes"/>
						</xsl:if>
					</ep:seq>
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="imvert:association" mode="create-message-content-constructRef">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="orderingDesired" select="'yes'"/>
		<xsl:param name="historyApplies" select="'no'"/>

		<xsl:variable name="name" select="imvert:name"/>
		<xsl:variable name="tech-name">
			<xsl:choose>
				<xsl:when test="imvert:stereotype = 'RELATIE'">
					<xsl:value-of
						select="imf:get-normalized-name(concat(imvert:name, imf:get-normalized-name(imvert:type-name, 'addition-relation-name')), 'element-name')"
					/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imf:get-normalized-name(imvert:name, 'element-name')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="mnemonic">
			<xsl:choose>
				<xsl:when test="imvert:stereotype = 'ENTITEITRELATIE'">
					<xsl:value-of select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imvert:alias"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="href">
			<xsl:variable name="mnemonicPartOfName">
				<xsl:choose>
					<xsl:when test="$mnemonic != ''">
						<xsl:value-of select="concat($mnemonic, '-')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of
				select="concat($mnemonicPartOfName, imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
			/>
		</xsl:variable>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association[mode=create-message-content-constructRef]'"/>
		</xsl:if>

		<ep:constructRef>
			<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
			<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
			<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
			<!-- When a tagged-value 'Positie' exists this is used to assign a value 
		to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Positie']/imvert:value)"/>
					<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')"/>
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence select="imf:create-output-element('ep:position', imvert:position)"
					/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<!--xsl:sequence
				select="imf:create-output-element('ep:id', $type-id)" /-->
			<xsl:sequence select="imf:create-output-element('ep:href', $href)"/>
		</ep:constructRef>
	</xsl:template>

	<!-- This template (5) takes care of associations from a 'vrijbericht' type 
		to the other message types 'vraagbericht', 'antwoordbericht' and 'kennisgevingbericht'. -->
	<!-- ROME: De werking van dit template moet nog gecheckt worden zodra er 
		vrije berichten zijn. Waarschijnlijk moet er nog iets gebeuren met de context.
		Ook moet er nog voor gezorgd worden dat het 'functie' xml attribute gegenereerd wordt.-->
	<xsl:template match="imvert:association" mode="create-toplevel-message-structure">
		<xsl:param name="berichtCode"/>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'Template: imvert:association[mode=create-toplevel-message-structure]'"/>
		</xsl:if>

		<ep:construct>
			<!--xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/-->
			<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
			<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
			<xsl:choose>
				<xsl:when test="imvert:stereotype = 'ENTITEITRELATIE'">
					<!-- ROME: Volgende apply-templates moet natuurlijk het template aanschoppen 
						met als match 'imvert:association[imvert:stereotype='ENTITEITRELATIE']'en 
						als mode 'create-message-content'. -->
					<xsl:apply-templates select="." mode="create-message-content">
						<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="'-'"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="imvert:stereotype = 'BERICHTRELATIE'">
					<xsl:variable name="type-id" select="imvert:type-id"/>
					<xsl:apply-templates
						select="
							imvert:class[imvert:id = $type-id and imvert:stereotype = imf:get-config-stereotypes((
							'stereotype-name-vraagberichttype',
							'stereotype-name-antwoordberichttype',
							'stereotype-name-kennisgevingberichttype'))]"
						mode="create-toplevel-message-structure">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="stuurgegevens" select="'no'"/>
					</xsl:apply-templates>
				</xsl:when>
			</xsl:choose>
			<ep:seq>
				<ep:construct ismetadata="yes">
					<xsl:sequence select="imf:create-output-element('ep:tech-name', 'StUF:functie')"/>
					<xsl:sequence
						select="imf:create-output-element('ep:enum', imvert:name/@original)"/>
				</ep:construct>
				<!-- ROME: Voor de volgende construct moet nog bepaald worden hoe het 
					zijn waarde krijgt. -->
				<ep:construct ismetadata="yes">
					<xsl:sequence select="imf:create-output-element('ep:tech-name', 'StUF:entiteittype')"/>
					<xsl:sequence select="imf:create-output-element('ep:enum', 'TODO')"/>
				</ep:construct>
			</ep:seq>
		</ep:construct>
	</xsl:template>

	<!-- This template (6) transforms an 'imvert:association' element of stereotype 'ENTITEITRELATIE' to an 'ep:construct' 
		element.. -->
	<xsl:template match="imvert:association[imvert:stereotype = 'ENTITEITRELATIE']"
		mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="orderingDesired" select="'yes'"/>
		<xsl:param name="historyApplies" select="'no'"/>

		<xsl:variable name="context">
			<xsl:choose>
				<xsl:when
					test="imvert:name = 'gelijk' or imvert:name = 'vanaf' or imvert:name = 'totEnMet'"
					>selectie</xsl:when>
				<xsl:when test="imvert:name = 'start'">start</xsl:when>
				<xsl:when test="imvert:name = 'scope'">scope</xsl:when>
				<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="type-id" select="imvert:type-id"/>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association[imvert:stereotype = ENTITEITRELATIE and mode=create-message-content]'"/>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="contains($berichtCode, 'La')">
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
					<!--ep:name>antwoord</ep:name-->
					<ep:tech-name>antwoord</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>200</ep:position>
					<ep:seq orderingDesired="no">
						<ep:constructRef context="{$context}">
							<xsl:sequence
								select="imf:create-output-element('ep:tech-name', imvert:name)"/>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>1</ep:min-occurs>
							<ep:position>1</ep:position>
							<xsl:choose>
								<xsl:when test="//imvert:class[imvert:id = $type-id]/imvert:alias">
									<xsl:sequence
										select="imf:create-output-element('ep:href', concat(//imvert:class[imvert:id = $type-id]/imvert:alias, '-', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name')))"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence
										select="imf:create-output-element('ep:href', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
									/>
								</xsl:otherwise>
							</xsl:choose>
						</ep:constructRef>
					</ep:seq>
				</ep:construct>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lv')">
				<xsl:choose>
					<xsl:when test="$context = 'selectie'">
						<ep:constructRef context="{$context}">
							<xsl:sequence
								select="imf:create-output-element('ep:tech-name', imvert:name)"/>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>
								<xsl:choose>
									<xsl:when test="imvert:name = 'gelijk'">100</xsl:when>
									<xsl:when test="imvert:name = 'vanaf'">125</xsl:when>
									<xsl:when test="imvert:name = 'totEnMet'">150</xsl:when>
								</xsl:choose>
							</ep:position>
							<xsl:choose>
								<xsl:when test="//imvert:class[imvert:id = $type-id]/imvert:alias">
									<xsl:sequence
										select="imf:create-output-element('ep:href', concat(//imvert:class[imvert:id = $type-id]/imvert:alias, '-', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name')))"
									/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence
										select="imf:create-output-element('ep:href', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
									/>
								</xsl:otherwise>
							</xsl:choose>
						</ep:constructRef>
					</xsl:when>
					<xsl:when test="$context = 'scope'">
						<ep:construct>
							<!--ep:name>
								<xsl:value-of select="$context"/>
							</ep:name-->
							<ep:tech-name>
								<xsl:value-of select="$context"/>
							</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>175</ep:position>
							<ep:seq orderingDesired="no">
								<ep:constructRef context="{$context}">
									<xsl:sequence
										select="imf:create-output-element('ep:tech-name', imvert:name)"/>
									<ep:max-occurs>1</ep:max-occurs>
									<ep:min-occurs>1</ep:min-occurs>
									<ep:position>1</ep:position>
									<xsl:choose>
										<xsl:when
											test="//imvert:class[imvert:id = $type-id]/imvert:alias">
											<xsl:sequence
												select="imf:create-output-element('ep:href', concat(//imvert:class[imvert:id = $type-id]/imvert:alias, '-', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name')))"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:sequence
												select="imf:create-output-element('ep:href', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
											/>
										</xsl:otherwise>
									</xsl:choose>
								</ep:constructRef>
							</ep:seq>
						</ep:construct>
					</xsl:when>
					<xsl:when test="$context = 'start'">
						<ep:construct>
							<!--ep:name>
								<xsl:value-of select="$context"/>
							</ep:name-->
							<ep:tech-name>
								<xsl:value-of select="$context"/>
							</ep:tech-name>
							<ep:max-occurs>1</ep:max-occurs>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:position>200</ep:position>
							<ep:seq orderingDesired="no">
								<ep:constructRef context="{$context}">
									<xsl:sequence
										select="imf:create-output-element('ep:tech-name', imvert:name)"/>
									<ep:max-occurs>1</ep:max-occurs>
									<ep:min-occurs>1</ep:min-occurs>
									<ep:position>1</ep:position>
									<xsl:choose>
										<xsl:when
											test="//imvert:class[imvert:id = $type-id]/imvert:alias">
											<xsl:sequence
												select="imf:create-output-element('ep:href', concat(//imvert:class[imvert:id = $type-id]/imvert:alias, '-', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name')))"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:sequence
												select="imf:create-output-element('ep:href', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
											/>
										</xsl:otherwise>
									</xsl:choose>
								</ep:constructRef>
							</ep:seq>
						</ep:construct>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Lk')">
				<ep:constructRef context="{$context}">
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
					<ep:max-occurs>2</ep:max-occurs>
					<ep:min-occurs>1</ep:min-occurs>
					<ep:position>200</ep:position>
					<xsl:choose>
						<xsl:when test="//imvert:class[imvert:id = $type-id]/imvert:alias">
							<xsl:sequence
								select="imf:create-output-element('ep:href', concat(//imvert:class[imvert:id = $type-id]/imvert:alias, '-', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name')))"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence
								select="imf:create-output-element('ep:href', imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</ep:constructRef>
			</xsl:when>
			<xsl:when test="contains($berichtCode, 'Sh')"> </xsl:when>
			<xsl:when test="contains($berichtCode, 'Sa')"> </xsl:when>
			<xsl:when test="contains($berichtCode, 'Di')"> </xsl:when>
			<xsl:when test="contains($berichtCode, 'Du')"> </xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- This template (7) transforms an 'imvert:attribute' element to an 'ep:construct' 
		element. -->
	<xsl:template match="imvert:attribute" mode="create-message-content">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="historyApplies" select="'no'"/>
		<xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
		<xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-message-content]'"/>
		</xsl:if>

		<xsl:variable name="name" select="imvert:name/@original"/>
		<xsl:variable name="tech-name" select="imf:get-normalized-name(imvert:name, 'element-name')"/>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="max-length" select="imvert:max-length"/>
		<xsl:variable name="total-digits" select="imvert:total-digits"/>
		<xsl:variable name="fraction-digits" select="imvert:fraction-digits"/>
		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="kerngegeven" select="imvert:is-id"/>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:variable name="onvolledigeDatum">
			<xsl:choose>
				<xsl:when test="imvert:type-modifier = '?'">yes</xsl:when>
				<xsl:otherwise>no</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="docs">
			<imvert:complete-documentation>
				<xsl:copy-of select="imf:get-compiled-documentation(.)"/>
			</imvert:complete-documentation>
		</xsl:variable>
		<xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
		<xsl:variable name="tvs">
			<ep:tagged-values>
				<xsl:copy-of select="imf:get-compiled-tagged-values(., true())"/>
			</ep:tagged-values>
		</xsl:variable>
		<?x xsl:variable name="stuf-scalar" select="imf:get-stuf-scalar-attribute-type(.)"/ x?>
		<!-- Nee, Ja, Ja zie regels, Zie groep, n.v.t.-->
		<xsl:variable name="materieleHistorie">
			<xsl:choose>
				<xsl:when test="$indicatieMaterieleHistorie = 'Ja' and (imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie materiële historie') = 'Nee' or imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie materiële historie') = 'N.v.t.')">
					<xsl:value-of select="'Nee'"/>
				</xsl:when>
				<xsl:when test="$indicatieMaterieleHistorie = 'Ja'">
					<xsl:value-of select="'Ja'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie materiële historie')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="formeleHistorie">
			<xsl:choose>
				<xsl:when test="$indicatieFormeleHistorie = 'Ja' and (imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie formele historie') = 'Nee' or imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie formele historie') = 'N.v.t.')">
					<xsl:value-of select="'Nee'"/>
				</xsl:when>
				<xsl:when test="$indicatieFormeleHistorie = 'Ja'">
					<xsl:value-of select="'Ja'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie formele historie')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="mogelijkGeenWaarde"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Mogelijk geen waarde')"/>
		<xsl:variable name="min-waarde"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Minimum waarde (inclusief)')"/>
		<xsl:variable name="max-waarde"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Maximum waarde (inclusief)')"/>
		<xsl:variable name="min-length"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Minimum lengte')"/>
		<xsl:variable name="formeelPatroon"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Formeel patroon')"/>
		<xsl:variable name="patroon"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Patroon')"/>
		<xsl:if
			test="($historyApplies = 'yes-Materieel' and contains($materieleHistorie, 'Ja')) or ($historyApplies = 'yes' and contains($formeleHistorie, 'Ja')) or $historyApplies = 'no'">
			<ep:construct>
				<xsl:if test="imf:boolean($debug)">
					<ep:tagged-values>
						<xsl:copy-of select="$tvs"/>
						<ep:found-tagged-values>
							<?x xsl:sequence
								select="imf:create-output-element('ep:stuf-scalar', $stuf-scalar)" / x?>
							<xsl:sequence
								select="imf:create-output-element('ep:kerngegeven', $kerngegeven)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:materieleHistorie', $materieleHistorie)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:formeleHistorie', $formeleHistorie)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:mogelijkGeenWaarde', $mogelijkGeenWaarde)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:min-waarde', $min-waarde)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:max-waarde', $max-waarde)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:min-length', $min-length)"/>
							<xsl:sequence
								select="imf:create-output-element('ep:formeelPatroon', $formeelPatroon)"/>
							<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)"
							/>
						</ep:found-tagged-values>
					</ep:tagged-values>
				</xsl:if>
				<!--xsl:sequence select="imf:create-output-element('ep:name', $name)"/-->
				<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
				<xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
				<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
				<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>

				<xsl:sequence
					select="imf:create-output-element('ep:authentiek', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie authentiek']/imvert:value)"/>


				<xsl:sequence select="imf:create-output-element('ep:length', $total-digits)"/>
				<xsl:sequence
					select="imf:create-output-element('ep:fraction-digits', $fraction-digits)"/>
				<xsl:sequence select="imf:create-output-element('ep:max-length', $max-length)"/>
				<xsl:sequence select="imf:create-output-element('ep:min-length', $min-length)"/>
				<xsl:sequence select="imf:create-output-element('ep:min-value', $min-waarde)"/>
				<xsl:sequence select="imf:create-output-element('ep:max-value', $max-waarde)"/>
				<xsl:sequence select="imf:create-output-element('ep:patroon', $patroon)"/>
				<xsl:sequence select="imf:create-output-element('ep:regels', $formeelPatroon)"/>
				<xsl:sequence select="imf:create-output-element('ep:type-name', imvert:type-name)"/>
				<xsl:if test="imvert:type-id">
					<xsl:apply-templates
						select="//imvert:class[imvert:id = $type-id and imvert:stereotype = 'ENUMERATION']"
						mode="create-datatype-content"/>
				</xsl:if>
				<!--xsl:sequence select="imf:create-output-element('ep:id', $id)"/-->
				<!-- When a tagged-value 'Positie' exists this is used to assign a value 
					to 'ep:position' if not the value of the element 'imvert:position' is used. -->
				<xsl:choose>
					<xsl:when
						test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'Positie'">
						<xsl:sequence
							select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Positie']/imvert:value)"/>
						<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')"/>
					</xsl:when>
					<xsl:when test="imvert:position">
						<xsl:sequence
							select="imf:create-output-element('ep:position', imvert:position)"/>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
				<!-- Attributes with the name 'melding' or which are descendants of a 
					class with the name 'Stuurgegevens', 'Systeem' or 'Parameters' mustn't get 
					XML attributes. -->
				<xsl:if
					test="imvert:name != 'melding' and ancestor::imvert:class[imvert:name != 'Stuurgegevens'] and ancestor::imvert:class[imvert:name != 'Systeem'] and ancestor::imvert:class[imvert:name != 'Parameters']">
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
								<xsl:when test="imvert:type-name = 'datetime'">yes</xsl:when>
								<xsl:when test="imvert:type-name = 'scalar-date'">yes</xsl:when>
								<xsl:otherwise>no</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="attributes"
							select="imf:createAttributes('bottomlevel', '-', '-', $datumType, '', $mogelijkGeenWaarde, $onvolledigeDatum)"/>
						<xsl:sequence select="$attributes"/>
					</ep:seq>
				</xsl:if>
			</ep:construct>
		</xsl:if>
	</xsl:template>

	<!-- This template (8) generates the structure of a relatie on a relatie. -->
	<!-- ROME: De werking van dit template moet adhv van een voorbeeld gecheckt 
		en mogelijk geoptimaliseerd worden. Zo is de vraag of een association-class 
		een supertype kan hebben. Zo ja dan moeten er nog apply-templates worden 
		opgenomen voor het verwerken van de supertypes. -->
	<xsl:template match="imvert:association-class">
		<xsl:param name="proces-type" select="'associations'"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association-class'"/>
		</xsl:if>

		<xsl:variable name="type-id" select="imvert:type-id"/>
		<xsl:choose>
			<!-- Following when processes the attributes of the association-class. -->
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- Following otherwise processes the relatie type associations and group 
				compositie associations of the association-class. -->
			<xsl:otherwise>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="$proces-type"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<!-- ROME: Aangezien een association-class alleen de attributen levert 
			van een relatie en dat relatie element al ergens anders zijn XML-attributes 
			toegekend krijgt hoeven er hier geen attributes meer toegekend te worden. -->
	</xsl:template>

	<xsl:template name="createEntityConstruct">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="orderingDesired" select="'yes'"/>
		<xsl:param name="type-id"/>
		<xsl:param name="historyApplies"/>

		<xsl:variable name="name" select="imvert:name/@original"/>
		<xsl:variable name="tech-name" select="imf:get-normalized-name(imvert:name, 'element-name')"/>
		<xsl:variable name="max-occurs">
			<xsl:choose>
				<xsl:when
					test="contains($berichtCode, 'Lk') and (imvert:max-occurs > 2 or imvert:max-occurs = 'unbounded')">
					<xsl:variable name="msg"
						select="concat('The element ', $name, ' has a maxOccurs of ', imvert:max-occurs, '. In Kennisgevingen only a maxOccurs between 1 and 2 is allowed.')"/>
					<xsl:sequence select="imf:msg('ERROR', $msg)"/>
					<!--xsl:message
						select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The element ', $name, ' has a maxOccurs of ', imvert:max-occurs, '. In Kennisgevingen only a maxOccurs between 1 and 2 is allowed.')" /-->
				</xsl:when>
				<xsl:when
					test="($berichtCode = 'La02' or $berichtCode = 'La04' or $berichtCode = 'La06' or $berichtCode = 'La08' or $berichtCode = 'La10') and imvert:max-occurs != '1'">
					<xsl:variable name="msg"
						select="concat('The element ', $name, ' has a maxOccurs of ', imvert:max-occurs, '. In asynchrone messages only a maxOccurs of 1 is allowed.')"/>
					<xsl:sequence select="imf:msg('ERROR', $msg)"/>
					<!--xsl:message
						select="concat('ERROR ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The element ', $name, ' has a maxOccurs of ', imvert:max-occurs, '. In asynchrone messages only a maxOccurs of 1 is allowed.')" /-->
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="imvert:max-occurs"/>
		</xsl:variable>
		<xsl:variable name="min-occurs">
			<xsl:if test="contains($berichtCode, 'Lk') and imvert:min-occurs > 1">
				<xsl:variable name="msg"
					select="concat('The element ', $name, ' has a minOccurs of ', imvert:min-occurs, '. In Kennisgevingen only a minOccurs of 1 is allowed.')"/>
				<xsl:sequence select="imf:msg('WARN', $msg)"/>
				<!--xsl:message
					select="concat('WARN   ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The element ', $name, ' has a minOccurs of ', imvert:min-occurs, '. In Kennisgevingen only a minOccurs of 1 is allowed.')" /-->
			</xsl:if>
			<xsl:value-of select="imvert:min-occurs"/>
		</xsl:variable>
		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="kerngegeven" select="imvert:is-id"/>
		<xsl:variable name="docs">
			<imvert:complete-documentation>
				<xsl:copy-of select="imf:get-compiled-documentation(.)"/>
			</imvert:complete-documentation>
		</xsl:variable>
		<xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
		<xsl:variable name="tvs">
			<ep:tagged-values>
				<xsl:copy-of select="imf:get-compiled-tagged-values(., true())"/>
			</ep:tagged-values>
		</xsl:variable>
		<?x xsl:variable name="stuf-scalar" select="imf:get-stuf-scalar-attribute-type(.)"/ x?>

		<!-- ROME: De vraag is nog of de volgende twee variabelen ('materieleHistorie' en 'formeleHistorie') wel nodig zijn op dit niveau. -->
		<xsl:variable name="materieleHistorie"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie materiële historie')"/>
		<xsl:variable name="formeleHistorie"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Indicatie formele historie')"/>

		<xsl:variable name="mogelijkGeenWaarde"
			select="imf:get-most-relevant-compiled-taggedvalue($tvs, 'Mogelijk geen waarde')"/>
		<xsl:variable name="mnemonic">
			<xsl:choose>
				<xsl:when test="imvert:stereotype = 'ENTITEITRELATIE'">
					<xsl:value-of select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="imvert:alias"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'createEntityConstruct'"/>
		</xsl:if>
		
		<ep:construct>
			<xsl:if test="imf:boolean($debug)">
				<ep:tagged-values>
					<xsl:copy-of select="$tvs"/>
					<ep:found-tagged-values>
						<?x xsl:sequence
							select="imf:create-output-element('ep:stuf-scalar', $stuf-scalar)" / x?>
						<xsl:sequence
							select="imf:create-output-element('ep:kerngegeven', $kerngegeven)"/>
						<xsl:sequence
							select="imf:create-output-element('ep:materieleHistorie', $materieleHistorie)"/>
						<xsl:sequence
							select="imf:create-output-element('ep:formeleHistorie', $formeleHistorie)"/>
						<xsl:sequence
							select="imf:create-output-element('ep:mogelijkGeenWaarde', $mogelijkGeenWaarde)"
						/>
					</ep:found-tagged-values>
				</ep:tagged-values>
			</xsl:if>
			<!--xsl:sequence select="imf:create-output-element('ep:name', $name)"/-->
			<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
			<xsl:sequence select="imf:create-output-element('ep:mnemonic', $mnemonic)"/>
			<xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
			<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
			<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>

			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Indicatie authentiek']/imvert:value)"/>

			<!--xsl:sequence select="imf:create-output-element('ep:id', $id)"/-->
			<!-- When a tagged-value 'Positie' exists this is used to assign a value 
				to 'ep:position' if not the value of the element 'imvert:position' is used. -->
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Positie']/imvert:value)"/>
					<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')"/>
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence select="imf:create-output-element('ep:position', imvert:position)"
					/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<!-- An 'ep:construct' based on an 'imvert:association' element can contain 
				several other 'ep:construct' elements (e.g. 'ep:constructs' for the attributes 
				of the association itself of for the associations of the association) therefore 
				an 'ep:seq' element is generated here. -->
			<ep:seq>
				<xsl:if test="$orderingDesired = 'no'">
					<xsl:attribute name="orderingDesired" select="'no'"/>
				</xsl:if>
				<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
					and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
					be placed directly within the current 'ep:seq'. -->
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
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
					<!--ep:name>StUF:tijdvakGeldigheid</ep:name-->
					<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>150</ep:position>
				</ep:construct>
				<ep:construct>
					<!--ep:name>StUF:tijdstipRegistratie</ep:name-->
					<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>151</ep:position>
				</ep:construct>
				<ep:construct>
					<!--ep:name>StUF:extraElementen</ep:name-->
					<ep:tech-name>StUF:extraElementen</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>152</ep:position>
				</ep:construct>
				<ep:construct>
					<!--ep:name>StUF:aanvullendeElementen</ep:name-->
					<ep:tech-name>StUF:aanvullendeElementen</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>153</ep:position>
				</ep:construct>
				<xsl:if test="imf:boolean($debug)">
					<xsl:message select="concat('$historyApplies ', $historyApplies)"/>
				</xsl:if>
				<xsl:if test="$materieleHistorie = 'Ja'">
					<ep:constructRef>
						<ep:tech-name>historieMaterieel</ep:tech-name>
						<ep:max-occurs>unbounded</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>154</ep:position>
						<xsl:choose>
							<xsl:when
								test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
								<xsl:sequence
									select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'), '-historieMaterieel'))"
								/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence
									select="imf:create-output-element('ep:href', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'), '-historieMaterieel')"
								/>
							</xsl:otherwise>
						</xsl:choose>
					</ep:constructRef>
				</xsl:if>
				<xsl:if test="$formeleHistorie = 'Ja'">
					<ep:constructRef>
						<ep:tech-name>historieFormeel</ep:tech-name>
						<ep:max-occurs>unbounded</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>155</ep:position>
						<xsl:choose>
							<xsl:when
								test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
								<xsl:sequence
									select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'), '-historieFormeel'))"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence
									select="imf:create-output-element('ep:href', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'), '-historieFormeel')"
								/>
							</xsl:otherwise>
						</xsl:choose>
					</ep:constructRef>
				</xsl:if>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
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
				<xsl:if test="imf:boolean($debug)">
					<xsl:comment select="concat('Attributes voor toplevel, berichtcode: ', substring($berichtCode, 1, 2), ' context: ', $context, ' en mnemonic: ', $mnemonic)"/>
				</xsl:if>
				<xsl:variable name="attributes"
					select="imf:createAttributes('toplevel', substring($berichtCode, 1, 2), $context, 'no', $mnemonic, 'no', 'no')"/>
				<xsl:sequence select="$attributes"/>
			</ep:seq>
		</ep:construct>

	</xsl:template>

	<!-- This template generates the structure of the 'gerelateerde' type element. -->
	<xsl:template name="createRelatiePartOfAssociation">
		<xsl:param name="type-id"/>
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		<xsl:param name="historyApplies" select="'no'"/>
		
		<xsl:variable name="docs">
			<imvert:complete-documentation>
				<xsl:copy-of select="imf:get-compiled-documentation(//imvert:class[imvert:id = $type-id])"/>
			</imvert:complete-documentation>
		</xsl:variable>
		<xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
		<xsl:variable name="mnemonic" select="//imvert:class[imvert:id = $type-id]/imvert:alias"/>
		<xsl:variable name="href">
			<xsl:variable name="mnemonicPartOfName">
				<xsl:choose>
					<xsl:when test="$mnemonic != ''">
						<xsl:value-of select="concat($mnemonic, '-')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of
				select="concat($mnemonicPartOfName, imf:get-normalized-name(//imvert:class[imvert:id = $type-id]/@formal-name, 'type-name'))"
			/>
		</xsl:variable>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'createRelatiePartOfAssociation'"/>
		</xsl:if>
		
		<xsl:choose>
			<!-- The association is a 'relatie' and it has to contain a 'gerelateerde' constructRef. -->
			<xsl:when
			test="//imvert:class[imvert:id = $type-id] and imvert:stereotype = 'RELATIE'">
				<ep:constructRef context="{$context}">
					<ep:tech-name>gerelateerde</ep:tech-name>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>1</ep:position>
					<xsl:sequence select="imf:create-output-element('ep:href', $href)"/>
				</ep:constructRef>
				<!-- The following 'apply-templates' initiates the processing of the 
					class which contains the attributes of the 'relatie' type element. -->
				<xsl:apply-templates select="imvert:association-class"
					mode="create-simple-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- The following 'apply-templates' initiates the processing of the 
					class which contains the attributegroups of the 'relatie' type element. -->
				<xsl:apply-templates select="imvert:association-class"
					mode="create-simple-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<ep:construct>
					<!--ep:name>StUF:tijdvakGeldigheid</ep:name-->
					<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>150</ep:position>
				</ep:construct>
				<ep:construct>
					<!--ep:name>StUF:tijdstipRegistratie</ep:name-->
					<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>151</ep:position>
				</ep:construct>
				<ep:construct>
					<!--ep:name>StUF:extraElementen</ep:name-->
					<ep:tech-name>StUF:extraElementen</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>152</ep:position>
				</ep:construct>
				<!-- The following 'apply-templates' initiates the processing of the 
					class which contains the associations of the 'relatie' type element. -->
				<xsl:apply-templates select="imvert:association-class">
					<xsl:with-param name="proces-type" select="'associations'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- The association is a 'groep compositie' and it has to contain a constructRef. -->
			<xsl:when
				test="//imvert:class[imvert:id = $type-id] and imvert:stereotype = 'GROEP COMPOSITIE' and contains($historyApplies,'yes')">
				<!-- The ep:constructRef is temporarily provided with a 'context' attribute and a 'ep:id' element to be able to create global constructs later.
					 These are removed later since they aren't part of the 'ep' structure. -->
				<ep:constructRef context="{$context}">
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>							
					<xsl:sequence
						select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
					<xsl:choose>
						<xsl:when
							test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'Positie'">
							<xsl:sequence
								select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Positie']/imvert:value)"/>
							<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')"/>
						</xsl:when>
						<xsl:when test="imvert:position">
							<xsl:sequence select="imf:create-output-element('ep:position', 120)"/>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$historyApplies = 'yes-Materieel'">
							<xsl:sequence select="imf:create-output-element('ep:href', concat($href,'-historieMaterieel'))"/>						
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:href', concat($href,'-historieFormeel'))"/>							
						</xsl:otherwise>
					</xsl:choose>					
				</ep:constructRef>
			</xsl:when>			<!-- The association is a 'groep compositie' and it has to contain a constructRef. -->
			<xsl:when
				test="//imvert:class[imvert:id = $type-id] and imvert:stereotype = 'GROEP COMPOSITIE'">
				<!-- The ep:constructRef is temporarily provided with a 'context' attribute and a 'ep:id' element to be able to create global constructs later.
					 These are removed later since they aren't part of the 'ep' structure. -->
				<ep:constructRef context="{$context}">
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imvert:name)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
					<xsl:choose>
						<xsl:when
							test="imvert:tagged-values/imvert:tagged-value/imvert:name = 'Positie'">
							<xsl:sequence
								select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name = 'Positie']/imvert:value)"/>
							<xsl:sequence select="imf:create-output-element('ep:tv-position', 'yes')"/>
						</xsl:when>
						<xsl:when test="imvert:position">
							<xsl:sequence select="imf:create-output-element('ep:position', 120)"/>
						</xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:href', $href)"/>
				</ep:constructRef>
			</xsl:when>
			<!-- The association is a 'entiteitRelatie' (the toplevel 'entiteit') 
				 and it contains a 'entiteit'. The attributes of the 'entiteit' class can 
				 be placed directly within the current 'ep:seq'. -->
			<xsl:when
				test="//imvert:class[imvert:id = $type-id and imvert:stereotype = 'ENTITEITTYPE']">
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<!-- ROME: Waarschijnlijk moet er hier afhankelijk van de context meer 
					of juist minder elementen gegenereerd worden. Denk aan 'inOnderzoek' maar 
					ook aan 'tijdvakRelatie', 'historieMaterieel' en 'historieFormeel'. -->
				<ep:construct>
					<!--ep:name>StUF:tijdvakGeldigheid</ep:name-->
					<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>150</ep:position>
				</ep:construct>
				<ep:construct>
					<!--ep:name>StUF:tijdstipRegistratie</ep:name-->
					<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>151</ep:position>
				</ep:construct>
				<ep:construct>
					<!--ep:name>StUF:extraElementen</ep:name-->
					<ep:tech-name>StUF:extraElementen</ep:tech-name>
					<ep:max-occurs>1</ep:max-occurs>
					<ep:min-occurs>0</ep:min-occurs>
					<ep:position>152</ep:position>
				</ep:construct>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:variable name="mnemonic">
					<xsl:choose>
						<xsl:when test="imvert:stereotype = 'ENTITEITRELATIE'">
							<xsl:value-of select="//imvert:class[imvert:id = $type-id]/imvert:alias"
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
				<xsl:if test="imf:boolean($debug)">
					<xsl:comment select="concat('Attributes voor toplevel, berichtcode: ', substring($berichtCode, 1, 2), ' context: ', $context, ' en mnemonic: ', $mnemonic)"/>
				</xsl:if>
				<xsl:variable name="attributes"
					select="imf:createAttributes('toplevel', substring($berichtCode, 1, 2), $context, 'no', $mnemonic, 'no', 'no')"/>
				<xsl:sequence select="$attributes"/>
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
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsGroepCompositie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
					mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associationsRelatie'"/>
					<xsl:with-param name="berichtCode" select="$berichtCode"/>
					<xsl:with-param name="context" select="$context"/>
				</xsl:apply-templates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ======= End block of templates used to create the message structure. ======= -->

	<!-- This template simply replicates elements. May be replaced later. -->
	<xsl:template match="*" mode="replicate-imvert-elements">
		<xsl:param name="berichtCode"/>
		<xsl:param name="context"/>
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'*[mode=replicate-imvert-elements]'"/>
		</xsl:if>
		
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
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:class[mode=create-datatype-content]'"/>
		</xsl:if>
				
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
					<!-- ROME: Er bestaat nog steeds de mogelijkheid dat de stereotype 'GEGEVENSGROEP 
						COMPOSITIE' wordt gebruikt ipv 'GROEP COMPOSITIE'. De uitbecommentarieerde 
						apply-templates kan met de eerste vorm omgaan maar moet tzt (zodra imvertor 
						daarop checkt) worden verwijdert. -->
					<xsl:apply-templates
						select=".//imvert:association[imvert:stereotype = 'GROEP COMPOSITIE']"
						mode="create-message-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
					<ep:construct>
						<!--ep:name>StUF:tijdvakGeldigheid</ep:name-->
						<ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
						<ep:max-occurs>1</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>150</ep:position>
					</ep:construct>
					<ep:construct>
						<!--ep:name>StUF:tijdstipRegistratie</ep:name-->
						<ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
						<ep:max-occurs>1</ep:max-occurs>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:position>151</ep:position>
					</ep:construct>
					<ep:construct>
						<!--ep:name>StUF:extraElementen</ep:name-->
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
					<xsl:apply-templates
						select=".//imvert:association[imvert:stereotype = 'RELATIE']"
						mode="create-message-content">
						<?x xsl:with-param name="id-trail"
							select="concat('#1#', imvert:id, '#', $id-trail)"/ x?>
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
					</xsl:apply-templates>
				</ep:seq>
			</xsl:when>
			<!-- If it's an 'Enumeration' class it's attributes, which represent the 
				enumeration values) processed. -->
			<xsl:when test="imvert:stereotype = 'ENUMERATION'">
				<xsl:apply-templates select="imvert:attributes/imvert:attribute"
					mode="create-datatype-content"/>
			</xsl:when>
			<xsl:when test="imvert:stereotype = 'DATATYPE'">
				<xsl:choose>
					<!-- If the class stereotype is a Datatype and it contains 'imvert:attribute' 
						elements they are placed as constructs within a 'ep:seq' element. -->
					<xsl:when test="imvert:attributes/imvert:attribute">
						<ep:seq>
							<xsl:apply-templates select="imvert:attributes/imvert:attribute"
								mode="create-datatype-content">
								<xsl:with-param name="berichtCode" select="$berichtCode"/>
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</ep:seq>
					</xsl:when>
					<!-- If not an 'ep:datatype' element is generated. -->
					<xsl:otherwise>
						<ep:datatype id="{imvert:id}">
							<xsl:apply-templates select="imvert:documentation"
								mode="replicate-imvert-elements">
								<xsl:with-param name="berichtCode" select="$berichtCode"/>
								<xsl:with-param name="context" select="$context"/>
							</xsl:apply-templates>
						</ep:datatype>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- ROME: De vraag is of deze otherwise tak ooit wordt gebruikt. -->
			<xsl:otherwise>
				<ep:seq>
					<xsl:apply-templates select="imvert:attributes/imvert:attribute"
						mode="create-datatype-content">
						<xsl:with-param name="berichtCode" select="$berichtCode"/>
						<xsl:with-param name="context" select="$context"/>
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

		<xsl:variable name="name" select="imvert:name"/>
		<xsl:variable name="min-occurs" select="imvert:min-occurs"/>
		<xsl:variable name="max-occurs" select="imvert:max-occurs"/>

		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-datatype-content]'"/>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="imvert:stereotype = 'ENUM'">
				<xsl:sequence select="imf:create-output-element('ep:enum', $name)"/>
			</xsl:when>
			<xsl:otherwise>
				<ep:construct>
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $name)"/>
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
					<xsl:if test="imvert:type-id">
						<xsl:apply-templates
							select="//imvert:class[imvert:id = current()/imvert:type-id]"
							mode="create-datatype-content"/>
					</xsl:if>
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="areParametersAndStuurgegevensAllowedOrRequired">
		<xsl:param name="berichtCode" as="xs:string"/>
		<xsl:param name="elements2bTested" as="document-node()"/>
		<xsl:param name="parent" as="xs:string"/>
		<!-- The following variable wil contain information from a spreadsheetrow which is determined using the first 3 parameters. 
		 The variable $enriched-endproduct-base-config-excel used within the following variable is generated using the XSLT stylesheet 
		 'Imvert2XSD-KING-enrich-excel.xsl'. -->
		<!--xsl:variable name="attributeTypeRow" select="$enriched-endproduct-base-config-excel//sheet
			[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data = $berichtCode]"/>
		<xsl:if test="$attributeTypeRow//col[@name = $element and data = '-']">no</xsl:if-->
		
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'areParametersAndStuurgegevensAllowedOrRequired'"/>
		</xsl:if>
		
		<xsl:for-each select="$elements2bTested//imvert:name">
			<xsl:variable name="isElementAllowed"
				select="imf:isElementAllowed($berichtCode, ., $parent)"/>
			<xsl:choose>
				<xsl:when test="$isElementAllowed = 'notAllowed'">
					<xsl:variable name="msg"
						select="concat('Within messagetype ', $berichtCode, ' element ', ., ' is not allowed within ', $parent, '.')"/>
					<xsl:sequence select="imf:msg('WARN', $msg)"/>
					<!--xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', ., ' is not allowed within ', $parent, '.')"/-->
				</xsl:when>
				<xsl:when test="$isElementAllowed = 'noSuchElement'">
					<xsl:variable name="msg"
						select="concat('Within messagetype ', $berichtCode, ' the ', $parent, ' element ', ., ' is not known.')"/>
					<xsl:sequence select="imf:msg('WARN', $msg)"/>
					<!--xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' the ', $parent, ' element ', ., ' is not known.')"/-->
				</xsl:when>
				<xsl:when test="$isElementAllowed = 'notInScope'"/>
			</xsl:choose>
		</xsl:for-each>
		<!--xsl:choose>
			<xsl:when test="$parent='Stuurgegevens'"-->
		<xsl:for-each
			select="
				$enriched-endproduct-base-config-excel//sheet
				[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data = $berichtCode]/col[upper-case(@type) = upper-case($parent) and data != '-']">
			<xsl:variable name="colName" select="@name"/>
			<xsl:if test="imf:boolean($debug)">
				<xsl:message
					select="concat('Type: ', @type, ' = Parent: ', $parent, '? (', @name, ') , (', $elements2bTested//imvert:attribute[imvert:name = $colName]/imvert:name, ')')"
				/>
			</xsl:if>
			<xsl:if test="count($elements2bTested//imvert:name = $colName) = 0">
				<xsl:variable name="msg"
					select="concat('Within messagetype ', $berichtCode, ' element ', @name, ' must be available within ', $parent, '.')"/>
				<xsl:sequence select="imf:msg('WARN', $msg)"/>
				<!--xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', @name, ' must be available within ', $parent, '.')"/-->
			</xsl:if>
		</xsl:for-each>
		<!--/xsl:when>
			<xsl:when test="$parent='Parameters'">
				<xsl:for-each select="$enriched-endproduct-base-config-excel//sheet
					[name = 'Berichtgerelateerde gegevens']/row[col[@name = 'berichtcode']/data = $berichtCode]/col[@type = 'parameters' and data != '-']">
					<xsl:if test="count($elements2bTested//imvert:name = @name) = 0">
						<xsl:message select="concat('WARN  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : Within messagetype ', $berichtCode, ' element ', @name, ' must be available within parameters.')"/>
					</xsl:if>		
				</xsl:for-each>
			</xsl:when>
		</xsl:choose-->
	</xsl:template>

	<!-- This function checks if a parameter or stuurgegeven is allowed within 
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
		<!-- Within the following choose the output of this function is detremined. -->
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
	</xsl:function>
	
	<!-- The function imf:createAttributes is used to determine the XML attributes 
		neccessary for a certain context. It has the following parameters: - typecode 
		- berichttype - context - datumType The first 3 parameters relate to columns 
		with the same name within an Excel spreadsheet used to configure a.o. XML 
		attributes usage. The last parameter is used to determine the need for the 
		XML-attribute 'StUF:indOnvolledigeDatum'. -->
	<xsl:function name="imf:createAttributes">
		<xsl:param name="typeCode" as="xs:string"/>
		<xsl:param name="berichtType" as="xs:string"/>
		<xsl:param name="context" as="xs:string"/>
		<xsl:param name="datumType" as="xs:string"/>
		<xsl:param name="mnemonic" as="xs:string"/>
		<xsl:param name="MogelijkGeenWaarde" as="xs:string"/>
		<xsl:param name="onvolledigeDatum" as="xs:string"/>
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
		<xsl:if test="imf:boolean($debug)">
			<xsl:message>attributeTypeRow: <xsl:value-of select="$attributeTypeRow/@number"
					/>(<xsl:value-of select="$typeCode"/>,<xsl:value-of select="$berichtType"
					/>,<xsl:value-of select="$context"/>,<xsl:value-of select="$datumType"
				/>)</xsl:message>
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
				<!--ep:name>StUF:noValue</ep:name-->
				<ep:tech-name>StUF:noValue</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<!-- ROME: Deze enumeration en name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-string</ep:type-name>
				<ep:enum>nietOndersteund</ep:enum>
				<ep:enum>nietGeautoriseerd</ep:enum>
				<ep:enum>geenWaarde</ep:enum>
				<ep:enum>waardeOnbekend</ep:enum>
				<ep:enum>vastgesteldOnbekend</ep:enum>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:noValue' and data = 'V'] and $MogelijkGeenWaarde = 'yes'">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:noValue</ep:name-->
				<ep:tech-name>StUF:noValue</ep:tech-name>
				<!-- ROME: Deze enumeration en name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-string</ep:type-name>
				<ep:enum>nietOndersteund</ep:enum>
				<ep:enum>nietGeautoriseerd</ep:enum>
				<ep:enum>geenWaarde</ep:enum>
				<ep:enum>waardeOnbekend</ep:enum>
				<ep:enum>vastgesteldOnbekend</ep:enum>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:noValue' and data = 'V'] and $MogelijkGeenWaarde = 'no'">
			<xsl:variable name="msg"
				select="concat('The StUF:noValue attribute is required in the context ', $context, '. Provide for it within EA.')"/>
			<xsl:sequence select="imf:msg('WARN', $msg)"/>
			<!--xsl:message select="concat('WARN   ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The StUF:noValue attribute is required in the context ',$context,'. Provide for it within EA.')" /-->
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:exact' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:exact</ep:name-->
				<ep:tech-name>StUF:exact</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<!-- ROME: Deze name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-boolean</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:exact' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:exact</ep:name-->
				<ep:tech-name>StUF:exact</ep:tech-name>
				<!-- ROME: Deze name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-boolean</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:metagegeven' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:metagegeven</ep:name-->
				<ep:tech-name>StUF:metagegeven</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<!-- ROME: Deze name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-boolean</ep:type-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:metagegeven' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:metagegeven</ep:name-->
				<ep:tech-name>StUF:metagegeven</ep:tech-name>
				<!-- ROME: Deze name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-boolean</ep:type-name>
			</ep:construct>
		</xsl:if>
		<!-- ROME: De vraag is of ik het gebruik van het XML attribute 'StUF:indOnvolledigeDatum' 
			wel in het spreadsheet moet configureren. Moeten niet gewoon alle elementen 
			van het datumType dit XML attribute krijgen? -->
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:indOnvolledigeDatum' and data = 'O'] and $datumType = 'yes' and $onvolledigeDatum = 'yes'">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:indOnvolledigeDatum</ep:name-->
				<ep:tech-name>StUF:indOnvolledigeDatum</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
				<!-- ROME: Deze enumeration en name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-string</ep:type-name>
				<ep:enum>J</ep:enum>
				<ep:enum>M</ep:enum>
				<ep:enum>D</ep:enum>
				<ep:enum>V</ep:enum>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:indOnvolledigeDatum' and data = 'V'] and $datumType = 'yes' and $onvolledigeDatum = 'yes'">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:indOnvolledigeDatum</ep:name-->
				<ep:tech-name>StUF:indOnvolledigeDatum</ep:tech-name>
				<!-- ROME: Deze enumeration en name-type is alleen nodig voor de test templates. 
						   In het schema wordt immer verwezen naar een complexType in het schema voor de StUF onderlaag.
						   Op een later moment wordt dit geconfigureerd. -->
				<ep:type-name>scalar-string</ep:type-name>
				<ep:enum>J</ep:enum>
				<ep:enum>M</ep:enum>
				<ep:enum>D</ep:enum>
				<ep:enum>V</ep:enum>
			</ep:construct>
		</xsl:if>
		<xsl:if
			test="$attributeTypeRow//col[@name = 'StUF:indOnvolledigeDatum' and data = 'V'] and $datumType = 'yes' and $onvolledigeDatum = 'no'">
			<xsl:variable name="msg"
				select="concat('The StUF:indOnvolledigeDatum attribute is required in the context ', $context, '. Provide for it within EA.')"/>
			<xsl:sequence select="imf:msg('WARN', $msg)"/>
			<!--xsl:message select="concat('WARN   ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The StUF:indOnvolledigeDatum attribute is required in the context ',$context,'. Provide for it within EA.')" /-->
		</xsl:if>
		<!-- ROME: De waarde van het attribute 'StUF:entiteittype' moet m.b.v. 
			een enum constuctie worden gedefinieerd. Die waarde zal aan de functie meegegeven 
			moeten worden. Deze waarde zou uit het 'imvert:alias' element moeten komen. 
			Dat is echter niet altijd aanwezig. -->
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:entiteittype' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace 
					van het koppelvlak. Later zal ik echter een restriction moeten definieren 
					in de namespace van de StUF onderlaag. -->
				<!--ep:name>StUF:entiteittype</ep:name-->
				<!--ep:tech-name>StUF:entiteittype</ep:tech-name -->
				<ep:tech-name>entiteittype</ep:tech-name>
				<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een 
					warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:choose>
					<xsl:when test="$mnemonic != ''">
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'scalar-string')"/>
						<xsl:sequence select="imf:create-output-element('ep:enum', $mnemonic)"/>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:defaultWaarde', $mnemonic)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="msg"
							select="'No mnemonic has been supplied. Supply one with this entity using the alias field.'"/>
						<xsl:sequence select="imf:msg('WARN', $msg)"/>
						<!--xsl:message select="concat('WARN   ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : No mnemonic has been supplied. Suplly one with this entity using the alias field.')" /-->
					</xsl:otherwise>
				</xsl:choose>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:entiteittype' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!-- ROME: Voor nu definieer ik het attribute entiteittype in de namespace 
					van het koppelvlak. Later zal ik echter een restriction moeten definieren 
					in de namespace van de StUF onderlaag. -->
				<!--ep:name>StUF:entiteittype</ep:name-->
				<!--ep:tech-name>StUF:entiteittype</ep:tech-name -->
				<ep:tech-name>entiteittype</ep:tech-name>
				<!-- ROME: Indien de variabele 'mnemonic' geen waarde heeft zal er een 
					warning gegenereerd moeten worden. Dit moet nog geimplementeerd worden. -->
				<xsl:choose>
					<xsl:when test="$mnemonic != ''">
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'scalar-string')"/>
						<xsl:sequence select="imf:create-output-element('ep:enum', $mnemonic)"/>
						<xsl:sequence
							select="imf:create-output-element('ep:defaultWaarde', $mnemonic)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="msg"
							select="'No mnemonic has been supplied. Supply one with this entity using the alias field.'"/>
						<xsl:sequence select="imf:msg('WARN', $msg)"/>
						<!--xsl:message select="concat('WARN   ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : No mnemonic has been supplied. Suplly one with this entity using the alias field.')" /-->
					</xsl:otherwise>
				</xsl:choose>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelVerzendend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelVerzendend</ep:name-->
				<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelVerzendend' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelVerzendend</ep:name-->
				<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelOntvangend' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelOntvangend</ep:name-->
				<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelOntvangend' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelOntvangend</ep:name-->
				<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelGegevensbeheer' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelGegevensbeheer</ep:name-->
				<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelGegevensbeheer' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelGegevensbeheer</ep:name-->
				<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelSynchronisatie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelSynchronisatie</ep:name-->
				<ep:tech-name>StUF:sleutelSynchronisatie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:sleutelSynchronisatie' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:sleutelSynchronisatie</ep:name-->
				<ep:tech-name>StUF:sleutelSynchronisatie</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:scope' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:scope</ep:name-->
				<ep:tech-name>StUF:scope</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:scope' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:scope</ep:name-->
				<ep:tech-name>StUF:scope</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:verwerkingssoort' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:verwerkingssoort</ep:name-->
				<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:verwerkingssoort' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:verwerkingssoort</ep:name-->
				<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:functie' and data = 'O']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:functie</ep:name-->
				<ep:tech-name>StUF:functie</ep:tech-name>
				<ep:min-occurs>0</ep:min-occurs>
			</ep:construct>
		</xsl:if>
		<xsl:if test="$attributeTypeRow//col[@name = 'StUF:functie' and data = 'V']">
			<ep:construct ismetadata="yes">
				<!--ep:name>StUF:functie</ep:name-->
				<ep:tech-name>StUF:functie</ep:tech-name>
			</ep:construct>
		</xsl:if>
	</xsl:function>

	<xsl:function name="imf:determineBerichtCode">
		<xsl:param name="Stereotype" as="xs:string"/>
		<xsl:param name="Inkomend" as="xs:string"/>
		<xsl:param name="AanduidingActualiteit" as="xs:string"/>
		<xsl:param name="Synchroon" as="xs:string"/>
		<xsl:param name="AanduidingToekomstmutaties" as="xs:string"/>
		<xsl:param name="Samengesteld" as="xs:string"/>
		<xsl:choose>
			<xsl:when test="$Stereotype = 'VRIJBERICHTTYPE'">
				<xsl:choose>
					<xsl:when test="$Inkomend = 'Ja' and $Synchroon = 'Ja'">Di01</xsl:when>
					<xsl:when test="$Inkomend = 'Ja' and $Synchroon = 'Nee'">Di02</xsl:when>
					<xsl:when test="$Inkomend = 'Nee' and $Synchroon = 'Ja'">Di03</xsl:when>
					<xsl:when test="$Inkomend = 'Nee' and $Synchroon = 'Nee'">Di04</xsl:when>
					<xsl:otherwise>Niet te bepalen</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$Stereotype = 'VRAAGBERICHTTYPE'">
				<xsl:choose>
					<xsl:when test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Ja'"
						>Lv01</xsl:when>
					<xsl:when test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Nee'"
						>Lv02</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Ja'"
						>Lv03</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Nee'"
						>Lv04</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Ja'"
						>Lv05</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Nee'"
						>Lv06</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Ja'"
						>Lv07</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Nee'"
						>Lv08</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Ja'"
						>Lv09</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Nee'"
						>Lv10</xsl:when>
					<xsl:otherwise>Niet te bepalen</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$Stereotype = 'ANTWOORDBERICHTTYPE'">
				<xsl:choose>
					<xsl:when test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Ja'"
						>La01</xsl:when>
					<xsl:when test="$AanduidingActualiteit = 'Actueel' and $Synchroon = 'Nee'"
						>La02</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Ja'"
						>La03</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip materieel' and $Synchroon = 'Nee'"
						>La04</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Ja'"
						>La05</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Op peiltijdstip formeel' and $Synchroon = 'Nee'"
						>La06</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Ja'"
						>La07</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële historie' and $Synchroon = 'Nee'"
						>La08</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Ja'"
						>La09</xsl:when>
					<xsl:when
						test="$AanduidingActualiteit = 'Materiële en formeleHistorie' and $Synchroon = 'Nee'"
						>La10</xsl:when>
					<xsl:otherwise>Niet te bepalen</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$Stereotype = 'KENNISGEVINGBERICHTTYPE'">
				<xsl:choose>
					<xsl:when
						test="$Synchroon = 'Ja' and $AanduidingToekomstmutaties = 'Zonder toekomstmutaties' and $Samengesteld = 'Nee'"
						>Lk01</xsl:when>
					<xsl:when
						test="$Synchroon = 'Nee' and $AanduidingToekomstmutaties = 'Zonder toekomstmutaties' and $Samengesteld = 'Nee'"
						>Lk02</xsl:when>
					<xsl:when test="$Synchroon = 'Ja' and $Samengesteld = 'Ja'">Lk03</xsl:when>
					<xsl:when test="$Synchroon = 'Nee' and $Samengesteld = 'Ja'">Lk04</xsl:when>
					<xsl:when
						test="$Synchroon = 'Ja' and $AanduidingToekomstmutaties = 'Met toekomstmutaties' and $Samengesteld = 'Nee'"
						>Lk05</xsl:when>
					<xsl:when
						test="$Synchroon = 'Nee' and $AanduidingToekomstmutaties = 'Met toekomstmutaties' and $Samengesteld = 'Nee'"
						>Lk06</xsl:when>
					<xsl:otherwise>Niet te bepalen</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- ROME: Voor de onderstaande situaties moet deze functie nog aangevuld 
				worden. -->
			<xsl:when test="$Stereotype = 'SYNCHRONISATIEBERICHTTYPE'">
				<?x xsl:choose><
					xsl:when test="contains($name,'Sa01')">Sa01</xsl:when>
					<xsl:when test="contains($name,'Sa02')">Sa02</xsl:when>
					<xsl:when test="contains($name,'Sa03')">Sa03</xsl:when>
					<xsl:when test="contains($name,'Sa04')">Sa04</xsl:when>
					<xsl:when test="contains($name,'Sh01')">Sh01</xsl:when>
					<xsl:when test="contains($name,'Sh02')">Sh02</xsl:when>
					<xsl:when test="contains($name,'Sh03')">Sh03</xsl:when>
					<xsl:when test="contains($name,'Sh04')">Sh04</xsl:when>
				</xsl:choose x?>
			</xsl:when>
		</xsl:choose>

	</xsl:function>

	<!-- This function merges all documentation form the highest layer up to the current layer. -->
	<xsl:function name="imf:merge-documentation">
		<xsl:param name="this"/>
		<xsl:for-each select="$this//imvert:documentation">
			<xsl:sort select="@level" data-type="number" order="descending"/>
			<xsl:copy-of select="xhtml:p"/>
		</xsl:for-each>
	</xsl:function>


</xsl:stylesheet>
