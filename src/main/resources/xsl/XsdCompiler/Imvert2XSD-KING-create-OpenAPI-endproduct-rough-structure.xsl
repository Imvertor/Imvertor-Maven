<?xml version="1.0" encoding="UTF-8"?>
<!-- Robert Melskens 2017-06-09 This stylesheet generates a rough EP file 
	structure based on the embellish file of a BSM EAP file. This rough structure 
	will be used in the next step for creating the final EP file structure. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:UML="omg.org/UML1.3"
	xmlns:imvert="http://www.imvertor.org/schema/system" xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
	xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">

	<xsl:import href="../common/Imvert-common.xsl" />
	<xsl:import href="../common/Imvert-common-validation.xsl" />
	<xsl:import href="../common/extension/Imvert-common-text.xsl" />
	<xsl:import href="../common/Imvert-common-derivation.xsl" />
	<xsl:import href="../XsdCompiler/Imvert2XSD-KING-common.xsl" />

	<xsl:output indent="yes" method="xml" encoding="UTF-8" />

	<xsl:key name="class" match="imvert:class" use="imvert:id" />

	<xsl:variable name="stylesheet">
		Imvert2XSD-KING-create-openapi-endproduct-rough-structure
	</xsl:variable>
	<xsl:variable name="stylesheet-version">
		$Id: Imvert2XSD-KING-create-OpenAPI-endproduct-rough-structure.xsl 1
		2018-04-16 13:32:00Z RobertMelskens $
	</xsl:variable>
	<xsl:variable name="stylesheet-code" as="xs:string">
		OAS
	</xsl:variable>
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"
		as="xs:boolean" />

	<xsl:variable name="embellish-file" select="/" />
	<xsl:variable name="packages" select="$embellish-file/imvert:packages" />

	<xsl:variable name="version" select="$packages/imvert:version" />

	<xsl:variable name="rough-messages">

		<!-- The 'Berichtstructuren' package isn't of any importance at OpenAPI 
			interface creation. -->
		<!-- TODO: Is het nog wel van belang om dan te checken op de alias van 
			de Berichtstructuren package of mogen we er gewoon vanuit gaan dat dat package 
			niet gebruikt wordt in de OAS context? -->
		<ep:rough-messages>
			<xsl:apply-templates
				select="$packages/imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package') and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]"
				mode="create-rough-message-structure" />
		</ep:rough-messages>

	</xsl:variable>


	<xsl:key name="associations" match="imvert:association"
		use="concat(imvert:type-id,ancestor::imvert:package/imvert:id)" />

	<!-- ======= Block of templates used to create the message structure. ======= -->

	<!-- This template is used to start generating a rough ep structure for 
		the individual messages. This rough ep structure is used as a base for creating 
		the final ep structure. -->

	<xsl:template match="/">
		<xsl:sequence select="imf:track('Constructing the rough message-structure')" />
		<xsl:if test="$debugging">
			<xsl:sequence
				select="imf:msg('INFO','Constructing the rough message structure.')" />
		</xsl:if>

		<xsl:sequence select="imf:pretty-print($rough-messages,false())" />

	</xsl:template>

	<xsl:template match="imvert:package" mode="create-rough-message-structure">
		<!-- This processes the package containing the interface messages. -->

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A00000 /debug:start',$debugging)" />
		<xsl:sequence
			select="imf:create-debug-track(concat('Constructing the rough-messages for package: ',imvert:name),$debugging)" />

		<!-- TODO: De vraag is of bij OpenAPI generatie nog wel het onderscheid 
			tussen de verschillende berichttypen gemaakt moet kunnen worden. -->

		<!-- The following apply-templates processes all classes representing a 
			messagetype. -->
		<!-- <xsl:variable name="OAS-messages"> <xsl:for-each select="imvert:class[(imvert:stereotype/@id 
			= 'stereotype-name-vraagberichttype')]"> <xsl:variable name="berichtcode" 
			select="imf:get-tagged-value(.,'##CFG-TV-BERICHTCODE')"/> <xsl:value-of select="concat($berichtcode,';')"/> 
			</xsl:for-each> </xsl:variable> <xsl:if test="not(contains($OAS-messages,'Gr')) 
			and not(contains($OAS-messages,'Gc'))"> <xsl:variable name="msg" select="'In 
			dit koppelvlak zijn geen OAS berichten gedefinieerd.'" as="xs:string"/> <xsl:sequence 
			select="imf:msg('WARNING',$msg)"/> </xsl:if> -->
		<xsl:apply-templates
			select="imvert:class[(imvert:stereotype/@id = ('stereotype-name-vraagberichttype',
			'stereotype-name-antwoordberichttype',
			'stereotype-name-kennisgevingberichttype',
			'stereotype-name-synchronisatieberichttype',
			'stereotype-name-vrijberichttype'))]"
			mode="create-rough-messages" />

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<xsl:template match="imvert:class" mode="create-rough-messages">

		<xsl:sequence
			select="imf:create-debug-track(concat('Constructing the rough-message class for class: ',imvert:name),$debugging)" />
		<xsl:variable name="berichtcode"
			select="imf:get-tagged-value(.,'##CFG-TV-BERICHTCODE')" />
		<xsl:variable name="servicename"
			select="imf:get-tagged-value(.,'##CFG-TV-SERVICENAME')" />
		<xsl:variable name="messagename" select="imvert:name/@original" />
		<xsl:variable name="messageid" select="imvert:id" />
		<xsl:variable name="messagetypeid" select="imvert:type-id" />
		<xsl:sequence select="imf:create-debug-comment($berichtcode,$debugging)" />
		<!-- create the message but only if the class representing the message 
			has a berichttype with the value 'Gcxx' or 'Grxx' and contains 1 association 
			with a stereotype 'entiteitRelatie'. This means classes only containing associations 
			with a stereotype 'berichtRelatie' aren't processed. -->
		<xsl:if test="contains($berichtcode,'Gc') or contains($berichtcode,'Gr')">
			<xsl:choose>
				<!-- It's not allowed to have none associations of type 'entiteitrelatie'. -->
				<xsl:when
					test="count(imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]) = 0">
					<xsl:variable name="msg"
						select="concat('In de messageclass ',imvert:name,' komt geen association voor met als stereotype &quot;entiteitrelatie&quot;, alleen associations met als stereotype &quot;entiteitrelatie&quot; worden verwerkt.')"
						as="xs:string" />
					<xsl:sequence select="imf:msg('WARNING',$msg)" />
				</xsl:when>
				<!-- Only in case of an Gr or Gc message type it's required to have one 
					than one association of the 'entiteitrelatie' type with the name 'gelijk' 
					or 'response' and allowed to have one association of the 'entiteitrelatie' 
					type with the name 'start' or 'request'. -->
				<xsl:when
					test="(contains($berichtcode,'Gr') or contains($berichtcode,'Gc')) and (not(count(imvert:associations/imvert:association[imvert:name = ('gelijk','response')]) = 1))">
					<xsl:variable name="msg"
						select="concat('In de messageclass ',imvert:name,' komt geen of meer dan 1 entiteitrelatie association voor met de naam &quot;gelijk&quot; of &quot;response&quot;. Voor Open API koppelvlakken is dat niet toegestaan.')"
						as="xs:string" />
					<xsl:sequence select="imf:msg('WARNING',$msg)" />
				</xsl:when>
				<xsl:when
					test="(contains($berichtcode,'Gr') or contains($berichtcode,'Gc')) and count(imvert:associations/imvert:association[imvert:name = ('start','request')]) > 1">
					<xsl:variable name="msg"
						select="concat('In de messageclass ',imvert:name,' komen meer dan 1 entiteitrelatie associations met de naam &quot;start&quot; of &quot;request&quot;. Voor Open API koppelvlakken is dat niet toegestaan.')"
						as="xs:string" />
					<xsl:sequence select="imf:msg('WARNING',$msg)" />
				</xsl:when>
				<xsl:when
					test="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]">
					<xsl:for-each
						select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and imvert:name = ('gelijk','response')]">
						<ep:rough-message messagetype="response"
							berichtcode="{$berichtcode}" servicename="{$servicename}">
							<xsl:sequence select="imf:create-debug-comment('A00010]',$debugging)" />
							<xsl:sequence
								select="imf:create-debug-track(concat('Constructing the rough-response-message: ',imvert:name/@original),$debugging)" />

							<xsl:sequence
								select="imf:create-output-element('ep:name', $messagename)" />
							<xsl:sequence select="imf:create-output-element('ep:id', $messageid)" />
							<xsl:sequence
								select="imf:create-output-element('ep:type-id', $messagetypeid)" />
							<!-- In case of a vraagberichttype it's decided for now only to proces 
								associations with the name 'gelijk' or 'response'. -->

							<!-- TODO: De bovenstaande beslissing is in overleg met Johan Boer 
								genomen maar moet nog geformaliseerd worden. -->
<?x							<xsl:apply-templates
								select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and 
								not(imvert:name = ('scope','vanaf','tot en met'))]"
								mode="create-rough-message-content"/>	?>
							<xsl:apply-templates select="."
								mode="create-rough-message-content" />
						</ep:rough-message>
						<ep:rough-message messagetype="request"
							berichtcode="{$berichtcode}" servicename="{$servicename}">
							<xsl:sequence select="imf:create-debug-comment('A00015]',$debugging)" />
							<xsl:sequence
								select="imf:create-debug-track(concat('Constructing the rough-request-message: ',imvert:name/@original),$debugging)" />

							<xsl:sequence
								select="imf:create-output-element('ep:name', $messagename)" />
							<xsl:sequence select="imf:create-output-element('ep:id', $messageid)" />
							<xsl:sequence
								select="imf:create-output-element('ep:type-id', $messagetypeid)" />
							<xsl:for-each
								select="../../imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and imvert:name = ('start','request')]">
								<!-- In case of a vraagberichttype it's decided for now only to proces 
									associations with the name 'gelijk' or 'response'. -->

								<!-- TODO: De bovenstaande beslissing is in overleg met Johan Boer 
									genomen maar moet nog geformaliseerd worden. -->
									<?x							<xsl:apply-templates
										select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and 
										not(imvert:name = ('scope','vanaf','tot en met'))]"
										mode="create-rough-message-content"/>	?>
								<xsl:apply-templates select="."
									mode="create-rough-message-content" />
							</xsl:for-each>
						</ep:rough-message>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-debug-comment('Otherwise-tak',$debugging)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

	</xsl:template>

	<!-- This template transforms an 'imvert:association' element of stereotype 
		'entiteitrelatie' to an 'ep:construct' element.. -->
	<xsl:template
		match="imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
		mode="create-rough-message-content">
		<xsl:param name="id-trail" />

		<xsl:variable name="type-id" select="imvert:type-id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A00020 /debug:start',$debugging)" />
		<xsl:sequence select="imf:create-debug-comment(imvert:name,$debugging)" />

		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="id-refering-association" select="imvert:id" />
			<xsl:with-param name="association-function">
				<xsl:choose>
					<xsl:when test="imvert:name = 'start' or imvert:name = 'request'">
						<xsl:value-of select="'requestParameters'" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'content'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<!-- Declaration of the content of a superclass, an 'imvert:association' 
		and 'imvert:association-class' finaly always takes place within an 'imvert:class' 
		element. This element is processed within this template. -->
	<xsl:template match="imvert:class" mode="create-rough-message-content">
		<xsl:param name="id-trail" />
		<xsl:param name="proces-type" select="'as-normal'" />
		<xsl:param name="type" select="'class'" />
		<xsl:param name="id-refering-association" select="''" />
		<xsl:param name="association-function" select="''" />

		<xsl:variable name="id" select="imvert:id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A00030 /debug:start',$debugging)" />
		<xsl:sequence
			select="imf:create-debug-comment(concat('Classname: ',imvert:name),$debugging)" />

		<!-- If the class hasn't been processed before it can be processed, else 
			processing is canceled to prevent recursion and a Warning is generated. Recursion 
			should be prevented in the model. -->

		<!-- TODO: Er is sprake van dat enige mate van recursion toch wordt toegestaan. 
			Daarom is de message bij recursion uitgeschakeld. Indien recursion toch niet 
			gewenst is dan kan deze weer wordn ingeschakeld. -->
		<xsl:choose>
			<xsl:when test="not(contains($id-trail, concat('#', $id, '#')))">
				<xsl:choose>
					<!-- If a supertype is refered to as an association the related subtypes 
						are placed as a construct in a sequence within that relation. -->
					<xsl:when
						test="$proces-type = 'as-normal' and $packages//imvert:class[imvert:supertype/imvert:type-id = $id]">
						<xsl:apply-templates
							select="$packages//imvert:class[imvert:supertype/imvert:type-id = $id]"
							mode="create-rough-message-content">
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="type" select="'subclass'" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$proces-type = 'as-normal'">
						<xsl:sequence
							select="imf:create-debug-comment('debug:start A00030a /debug:start',$debugging)" />
						<ep:construct>
							<xsl:choose>
								<xsl:when test="$association-function = 'requestParameters'">
									<xsl:attribute name="type" select="'requestclass'" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="type" select="$type" />
								</xsl:otherwise>
							</xsl:choose>
							<xsl:sequence
								select="imf:create-output-element('ep:name', imvert:name/@original)" />
							<xsl:sequence
								select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
							<xsl:sequence select="imf:create-output-element('ep:id', $id)" />
							<xsl:sequence
								select="imf:create-output-element('ep:id-refering-association', $id-refering-association)" />

							<!-- TODO: Klopt onderstaande nog wel. Attributes worden nu volgens 
								mij ook geprocessed als het om een attribute gaat dat verwijst naar een tabel 
								entiteit. -->

							<!-- The following takes care of ignoring the processing of the attributes 
								belonging to the current class. Attributes aren't important for the rough 
								structure but need to be processed here to determine the processtype of the 
								classes containing the attributes. -->
							<xsl:sequence select="imf:create-debug-comment('A00040]',$debugging)" />
							<xsl:apply-templates select="imvert:attributes/imvert:attribute">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<xsl:apply-templates select="imvert:supertype"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<xsl:apply-templates select="imvert:associations/imvert:association"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
						</ep:construct>
					</xsl:when>
					<xsl:when test="$proces-type = 'as-supertype'">
						<ep:superconstruct type="superclass">
							<xsl:sequence
								select="imf:create-output-element('ep:name', imvert:name/@original)" />
							<xsl:sequence
								select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
							<xsl:sequence select="imf:create-output-element('ep:id', $id)" />

							<!-- TODO: Klopt onderstaande nog wel. Attributes worden nu volgens 
								mij ook geprocessed als het om een attribute gaat dat verwijst naar een tabel 
								entiteit. -->

							<!-- The following takes care of ignoring the processing of the attributes 
								belonging to the current class. Attributes aren't important for the rough 
								structure but need to be processed here to determine the processtype of the 
								classes containing the attributes. -->
							<xsl:sequence select="imf:create-debug-comment('A00050]',$debugging)" />
							<xsl:apply-templates select="imvert:attributes/imvert:attribute">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<xsl:apply-templates select="imvert:supertype"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<xsl:apply-templates select="imvert:associations/imvert:association"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
						</ep:superconstruct>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="imf:create-debug-comment('A00060]',$debugging)" />
						<xsl:apply-templates select="imvert:attributes/imvert:attribute">
							<xsl:with-param name="id-trail"
								select="concat('#', $id, '#', $id-trail)" />
						</xsl:apply-templates>
						<xsl:apply-templates select="imvert:supertype"
							mode="create-rough-message-content">
							<xsl:with-param name="id-trail"
								select="concat('#', $id, '#', $id-trail)" />
						</xsl:apply-templates>
						<xsl:apply-templates select="imvert:associations/imvert:association"
							mode="create-rough-message-content">
							<xsl:with-param name="id-trail"
								select="concat('#', $id, '#', $id-trail)" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise />
<?x				<xsl:variable name="msg" select="concat('De class ',imvert:name,' komt recursief voor in het BSM model. Bij een Open API koppelvlak is dat niet toegestaan. Pas het model aan.')" as="xs:string"/>
				<xsl:sequence select="imf:msg('WARNING',$msg)"/>
			</xsl:otherwise> ?>
		</xsl:choose>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<!-- This template takes care of processing superclasses of the class being 
		processed. -->
	<xsl:template match="imvert:supertype" mode="create-rough-message-content">
		<xsl:param name="id-trail" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A00070 /debug:start',$debugging)" />

		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="id-trail" select="$id-trail" />
			<xsl:with-param name="proces-type" select="'as-supertype'" />
		</xsl:apply-templates>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<!-- This template transforms an 'imvert:association' element to an 'ep:construct' 
		element. -->
	<xsl:template match="imvert:association" mode="create-rough-message-content">
		<xsl:param name="id-trail" />

		<xsl:variable name="type-id" select="imvert:type-id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A00080 /debug:start',$debugging)" />

		<ep:construct type="association">
			<xsl:choose>
				<xsl:when
					test="imvert:stereotype/@id = 'stereotype-name-association-to-composite'">
					<xsl:attribute name="type" select="'groepCompositie'" />
				</xsl:when>
				<xsl:when test="imvert:stereotype/@id = 'stereotype-name-relatiesoort'">
					<xsl:attribute name="type" select="'association'" />
				</xsl:when>
			</xsl:choose>
			<xsl:if test="$debugging">
				<xsl:attribute name="package"
					select="ancestor::imvert:package/imvert:name" />
			</xsl:if>
			<xsl:sequence select="imf:create-debug-comment('A00090]',$debugging)" />

			<xsl:sequence
				select="imf:create-output-element('ep:name', imvert:name/@original)" />
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
			<xsl:sequence select="imf:create-debug-comment('A00100]',$debugging)" />
			<xsl:sequence select="imf:create-output-element('ep:type-id', $type-id)" />
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)" />

			<xsl:apply-templates select="imvert:association-class"
				mode="create-rough-message-content">
				<xsl:with-param name="id-trail" select="$id-trail" />
			</xsl:apply-templates>
			<xsl:apply-templates select="key('class',$type-id)"
				mode="create-rough-message-content">
				<xsl:with-param name="id-trail" select="$id-trail" />
				<!-- Within the construct refering to a class we need to be able to trace 
					which association refered to that class since more than one association can. -->
				<xsl:with-param name="id-refering-association"
					select="imvert:id" />
			</xsl:apply-templates>
		</ep:construct>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<!-- This template generates the structure of an associationconstruct on 
		an associationconstruct. -->
	<xsl:template match="imvert:association-class" mode="create-rough-message-content">
		<xsl:param name="id-trail" />

		<xsl:variable name="type-id" select="imvert:type-id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A00120 /debug:start',$debugging)" />

		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="id-trail" select="$id-trail" />
			<xsl:with-param name="type" select="'association-class'" />
		</xsl:apply-templates>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<xsl:template match="imvert:attribute">

		<xsl:variable name="type-id" select="imvert:type-id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A00130 /debug:start',$debugging)" />

		<xsl:if test="empty(imvert:is-id)">
			<ep:expand>true</ep:expand>
		</xsl:if>

		<xsl:if
			test="imvert:type-id and //imvert:class[imvert:id = $type-id]/imvert:stereotype[@id = 'stereotype-name-complextype']">
			<xsl:sequence select="imf:create-debug-comment('A00140]',$debugging)" />
			<ep:construct type="complex-datatype">
				<xsl:sequence
					select="imf:create-output-element('ep:name', imvert:name/@original)" />
				<xsl:sequence
					select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
				<xsl:sequence
					select="imf:create-output-element('ep:type-id', imvert:type-id)" />

				<xsl:variable name="gerelateerde"
					select="imf:get-class-construct-by-id($type-id,$embellish-file)" />

				<xsl:sequence select="imf:create-debug-comment('A00150]',$debugging)" />
				<xsl:apply-templates select="$gerelateerde"
					mode="create-rough-message-content">
					<!-- The 'id-trail' parameter has been introduced to be able to prevent 
						recursive processing of classes. If the parser runs into an id already present 
						class within the trail (so the related object has already been processed) 
						processing stops. -->
					<xsl:with-param name="id-trail" select="''" />
					<xsl:with-param name="proces-type" select="'attribute'" />
				</xsl:apply-templates>
			</ep:construct>
		</xsl:if>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

</xsl:stylesheet>
