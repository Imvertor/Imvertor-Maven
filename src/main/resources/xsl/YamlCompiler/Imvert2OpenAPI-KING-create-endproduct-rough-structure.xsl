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

	<xsl:variable name="stylesheet" select="'Imvert2XSD-KING-create-openapi-endproduct-rough-structure'"/>
	<xsl:variable name="stylesheet-version">
		$Id: Imvert2XSD-KING-create-OpenAPI-endproduct-rough-structure.xsl
		2018-09-18 10:53:00Z Robert Melskens $
	</xsl:variable>
	<xsl:variable name="stylesheet-code" as="xs:string" select="'OAS'"/>
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean" />
	<xsl:variable name="embellish-file" select="/" />
	<xsl:variable name="packages" select="$embellish-file/imvert:packages" />
	<xsl:variable name="version" select="$packages/imvert:version" />
	<xsl:variable name="rough-messages">
		<ep:rough-messages>
			<ep:name>
				<xsl:value-of select="$packages/imvert:tagged-values/imvert:tagged-value[@id='CFG-TV-INTERFACE-NAME']/imvert:value"/>
				<!--xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($packages/imvert:packages, '##CFG-TV-INTERFACE-NAME')"/-->
			</ep:name>
			<!-- The 'Berichtstructuren' package doesn't hold the actual message classes for the interface so it's neglected in this stage. -->
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
			select="imf:create-debug-comment('debug:start A10500 /debug:start',$debugging)" />
		<xsl:sequence
			select="imf:create-debug-track(concat('Constructing the rough-messages for package: ',imvert:name),$debugging)" />
		
		<!-- The following apply-templates starts processing all classes representing a messagetype. -->
		<xsl:apply-templates
			select="imvert:class[(imvert:stereotype/@id = ('stereotype-name-getberichttype',
			'stereotype-name-patchberichttype',
			'stereotype-name-postberichttype',
			'stereotype-name-putberichttype',
			'stereotype-name-deleteberichttype'))]"
			mode="create-rough-messages" />

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<xsl:template match="imvert:class" mode="create-rough-messages">
		<!-- This template processes all classes representing a messagetype. -->
		
		<xsl:variable name="messagetype">
			<!-- Is it a get, post, put, patch or delete message? -->
			<xsl:value-of select="substring-after(substring-before(imvert:stereotype/@id,'berichttype'),'stereotype-name-')"/>
		</xsl:variable>
		<xsl:variable name="pad-id">
			<xsl:choose>
				<xsl:when test="./imvert:associations/imvert:association[imvert:stereotype/@id='stereotype-name-padrelatie']">
					<xsl:value-of select="./imvert:associations/imvert:association[imvert:stereotype/@id='stereotype-name-padrelatie']/imvert:type-id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:msg('ERROR','The messageclass [1] does not have an association to a pad class or the association has the wrong stereotype. This is neccessary to determine the name of the message.',(imvert:name/@original))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="padClass" as="element()">
			<xsl:choose>
				<xsl:when test="$packages//imvert:class[imvert:id=$pad-id]/imvert:stereotype/@id='stereotype-name-padtype'">
					<xsl:sequence select="$packages//imvert:class[imvert:id=$pad-id]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:msg('WARNING','The padclass [1] has the wrong stereotype. It should be [2].',($packages//imvert:class[imvert:id=$pad-id],'Padtype'))" />
					<xsl:sequence select="$packages//imvert:class[imvert:id=$pad-id]"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="messagename">
			<xsl:choose>
				<xsl:when test="empty($padClass)">
					<xsl:value-of select="'onbekend'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$padClass/imvert:name/@original"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="customPathFacet">
			<xsl:if test="not(empty($padClass))">
				<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($padClass, '##CFG-TV-CUSTOMPATHFACET')"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:sequence
			select="imf:create-debug-track(concat('Constructing the rough-message class for the ',$messagetype,' message: ',$messagename),$debugging)" />
		<xsl:variable name="berichtcode"
			select="imf:get-tagged-value(.,'##CFG-TV-BERICHTCODE')" />
		<xsl:if test="$berichtcode = '' or empty($berichtcode)">
			<!-- For now a berichtcode is neccessary so if it lacks or if it's empty an error message is generated. -->
			<xsl:sequence select="imf:msg('ERROR','The messageclass [1] does not have a value for the tagged value berichtcode or the tagged value lacks.',(imvert:name/@original))" />
		</xsl:if>
		<xsl:variable name="tag" select="imf:get-tagged-value(., '##CFG-TV-TAG')" />
		
		<!-- All message-classes refer to a class within the 'Berichtstructuren' package. It contains standard configuration for specific
			 messagetypes. These configurations are picked-up here. -->
		<xsl:variable name="berichtsjabloon" select="$packages//imvert:package[imvert:alias='/www.kinggemeenten.nl/BSM/Berichtstrukturen/Model']//imvert:class[.//imvert:tagged-value[@id='CFG-TV-BERICHTCODE']/imvert:value=$berichtcode]" />
		<xsl:variable name="grouping" select="imf:get-most-relevant-compiled-taggedvalue($berichtsjabloon, '##CFG-TV-GROUPING')" />
		<xsl:variable name="pagination" select="imf:get-most-relevant-compiled-taggedvalue($berichtsjabloon, '##CFG-TV-PAGE')" />
		<xsl:variable name="serialisation" select="imf:get-most-relevant-compiled-taggedvalue($berichtsjabloon, '##CFG-TV-SERIALISATION')" />
		
		<!-- The values for the fields and sort parameters are saved on the message-classes themself. They are picked-up here. -->
		<xsl:variable name="fields" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-FIELDS')" />
		<xsl:variable name="sort" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-SORT')" />
		
		<xsl:variable name="messageid" select="imvert:id" />
		<xsl:variable name="messagetypeid" select="imvert:type-id" />
		<xsl:sequence select="imf:create-debug-comment($berichtcode,$debugging)" />

		<!-- create the message but only if the class representing the message 
			 is a REST get, patch, post, put or delete message and contains at least 1 association 
			 with a stereotype 'entiteitRelatie'. This means classes only containing associations 
			 with a stereotype 'berichtRelatie' or 'padRelatie' aren't processed. -->
		<xsl:choose>
			<xsl:when test="empty(imvert:supertype) and imvert:stereotype/@id = ('stereotype-name-getberichttype',
				'stereotype-name-patchberichttype',
				'stereotype-name-postberichttype',
				'stereotype-name-putberichttype',
				'stereotype-name-deleteberichttype')">
				<!-- If the messageclass has no supertype relation to an interface which is refering to a REST berichttype class within the
					 'Berichtstructuren' package an error message is generated. -->
				<xsl:variable name="msg"
					select="concat('The messageclass &quot;',imvert:name,'&quot; has no interface to a supertype from the &quot;Berichtstructuren&quot; package.')"
					as="xs:string" />
				<xsl:sequence select="imf:msg('ERROR',$msg)" />
			</xsl:when>
			<xsl:when test="not(contains(imvert:supertype/imvert:type-name,$berichtcode))">
				<!-- If the type-name of the interface class has a value which doesn't correspondent to the 'berichtcode' of the message-class
					 (e.g. it has the value 'Gr01-Getresource' while the berichtcode has the value 'Gc01') an error message is generated. -->
				<xsl:variable name="msg"
					select="concat('The berichtcode &quot;',$berichtcode,'&quot; of the messageclass &quot;',imvert:name,'&quot; does not correspond with the superclass &quot;',imvert:supertype/imvert:type-name,'&quot; it refers to.')"
					as="xs:string" />
				<xsl:sequence select="imf:msg('ERROR',$msg)" />
			</xsl:when>
			<xsl:when test="contains($berichtcode,'Gc') or contains($berichtcode,'Gr')">
				<xsl:sequence select="imf:create-debug-comment('A11000]',$debugging)" />
				<xsl:choose>
					<xsl:when
						test="count(imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]) = 0">
						<!-- It's not allowed to have no associations of type 'entiteitrelatie'. If that's the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass &quot;',imvert:name,'&quot; no association with the stereotype &quot;entiteitrelatie&quot; occurs, only associations with that kind of stereotype or of stereotype &quot;padrelatie&quot; are processed for messages with berichttype ',$berichtcode,'.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="not(count(imvert:associations/imvert:association[imvert:name = 'response']) = 1)">
						<!-- In case of a Gr or Gc messagetype it's required to have one and not more than one association with the name 'response'. 
						     If this isn't the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass &quot;',imvert:name,'&quot; no or more than 1 association with the stereotype &quot;entiteitrelatie&quot; and the name &quot;response&quot; is present. For messages with berichttype &quot;',$berichtcode,'&quot; 1 (and only 1) has to be present.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="not(count(imvert:associations/imvert:association[imvert:name = 'request']) = 1)">
						<!-- In case of a Gr or Gc messagetype it's required to have one and not more than one association with the name 'request'. 
						     If this isn't the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass &quot;',imvert:name,'&quot; no or more than 1 association with the stereotype &quot;entiteitrelatie&quot; and the name &quot;request&quot; is present. For messages with berichttype &quot;',$berichtcode,'&quot; 1 (and only 1) has to be present.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="count(imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-padrelatie')]) = 0">
						<!-- It's not allowed to have no associations of type 'padrelatie'. If that's the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass &quot;',imvert:name,'&quot; no association with the stereotype &quot;padrelatie&quot; occurs, only associations with that kind of stereotype or of stereotype &quot;entiteitrelatie&quot; are processed for messages with berichttype ',$berichtcode,'.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="not(count(imvert:associations/imvert:association[imvert:name = 'pad']) = 1)">
						<!-- In case of a Gr or Gc messagetype it's required to have one and not more than one association with the name 'pad'. 
						     If this isn't the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass &quot;',imvert:name,'&quot; no or more than 1 association with the stereotype &quot;padrelatie&quot; and the name &quot;pad&quot; is present. For messages with berichttype &quot;',$berichtcode,'&quot; 1 (and only 1) has to be present.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="imvert:associations/imvert:association[imvert:name != 'request' and imvert:name != 'response' and imvert:name != 'pad']">
						<!-- In case the Gr or Gc messagetype has one or more associations not having the name 'response', 'request' or 'pad' an error
						     message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass &quot;',imvert:name,'&quot; one or more associations are present with a name not equal to &quot;response&quot;, &quot;request&quot; or &quot;pad&quot;. For messages with berichttype &quot;',$berichtcode,'&quot; this is not allowed.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]">
						<xsl:sequence select="imf:create-debug-comment('A11500]',$debugging)" />
						<!-- For the get messages a ep:rough-message structure representing the 'response' tree is generated but also one respresenting
							 the 'request' tree.  -->
						<xsl:for-each
							select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and imvert:name = 'response']">
							
							<xsl:sequence select="imf:create-debug-comment('A11750]',$debugging)" />
							<ep:rough-message messagetype="response" berichtcode="{$berichtcode}" tag="{$tag}" grouping="{$grouping}" pagination="{$pagination}" serialisation="{$serialisation}">
								<xsl:sequence
									select="imf:create-debug-track(concat('Constructing the rough-response-message: ',imvert:name/@original),$debugging)" />
								<xsl:sequence
									select="imf:create-output-element('ep:name', $messagename)" />
								<xsl:sequence select="imf:create-output-element('ep:id', $messageid)" />
								<xsl:sequence
									select="imf:create-output-element('ep:type-id', $messagetypeid)" />
								<xsl:apply-templates select="." mode="create-rough-message-content" />
							</ep:rough-message>
						</xsl:for-each>
						<xsl:for-each
							select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and imvert:name = 'request']">

							<xsl:sequence select="imf:create-debug-comment('A12000]',$debugging)" />
							<ep:rough-message messagetype="request"	berichtcode="{$berichtcode}" tag="{$tag}" grouping="{$grouping}" pagination="{$pagination}" serialisation="{$serialisation}">
								<xsl:if test="not(empty($fields))">
									<xsl:attribute name="fields" select="$fields"/>
								</xsl:if>
								<xsl:if test="not(empty($customPathFacet))">
									<xsl:attribute name="customPathFacet" select="$customPathFacet"/>
								</xsl:if>
								<xsl:choose>
									<xsl:when test="not(empty($sort)) and contains($berichtcode,'Gr')">
										<xsl:variable name="msg"
											select="concat('The tagged value sort is not allowed on a ',$berichtcode,' messageclass.')"
											as="xs:string" />
										<xsl:sequence select="imf:msg('ERROR',$msg)" />
									</xsl:when>
									<xsl:when test="not(empty($sort)) and contains($berichtcode,'Gc')">
										<xsl:attribute name="sort" select="$sort"/>
									</xsl:when>
								</xsl:choose>
								<xsl:if test="not(empty($sort))">
									<xsl:attribute name="fields" select="$sort"/>
								</xsl:if>
								<xsl:sequence
									select="imf:create-debug-track(concat('Constructing the rough-request-message: ',imvert:name/@original),$debugging)" />
	
								<xsl:sequence
									select="imf:create-output-element('ep:name', $messagename)" />
								<xsl:sequence select="imf:create-output-element('ep:id', $messageid)" />
								<xsl:sequence
									select="imf:create-output-element('ep:type-id', $messagetypeid)" />
									<xsl:apply-templates select="." mode="create-rough-message-content" />
							</ep:rough-message>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- This otherwise can occur when. -->
						<xsl:sequence
							select="imf:create-debug-comment('Otherwise-tak',$debugging)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="contains($berichtcode,'Pa') or contains($berichtcode,'Po') or contains($berichtcode,'Pu')">
				<xsl:sequence select="imf:create-debug-comment('A12500]',$debugging)" />
				<xsl:choose>
					<xsl:when test="count(imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]) = 0">
						<!-- It's not allowed to have no associations of type 'entiteitrelatie'. If that's the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass ',imvert:name,' no association with the stereotype &quot;entiteitrelatie&quot; occurs, only associations with that kind of stereotype are processed for messages with berichttype ',$berichtcode,'.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when test="not(count(imvert:associations/imvert:association[imvert:name = 'request']) = 1)">
						<!-- In case of a Po messagetype it's required to have one and not more than one association with the name 'request'. 
						     If this isn't the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass ',imvert:name,' 1 (and only 1) association with the stereotype &quot;entiteitrelatie&quot; and the name &quot;request&quot; has to be present.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when test="not(count(imvert:associations/imvert:association[imvert:name = 'response']) = 1)">
						<!-- In case of a Po messagetype it's required to have one and not more than one association with the name 'response'. 
						     If this isn't the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass ',imvert:name,' 1 (and only 1) association with the stereotype &quot;entiteitrelatie&quot; and the name &quot;response&quot; has to be present.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when test="not(count(imvert:associations/imvert:association[imvert:name = 'requestbody']) = 1)">
						<!-- In case of a Po messagetype it's required to have one and not more than one association with the name 'requestbody'. 
						     If this isn't the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass ',imvert:name,' 1 (and only 1) association with the stereotype &quot;entiteitrelatie&quot; and the name &quot;requestbody&quot; has to be present.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when test="count(imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-padrelatie')]) = 0">
						<!-- It's not allowed to have no associations of type padrelatie'. If that's the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass ',imvert:name,' no association with the stereotype &quot;padrelatie&quot; occurs, only associations with that kind of stereotype are processed for messages with berichttype ',$berichtcode,'.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when test="not(count(imvert:associations/imvert:association[imvert:name = 'pad']) = 1)">
						<!-- In case of a Po messagetype it's required to have one and not more than one association with the name 'pad'. 
						     If this isn't the case an error message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass ',imvert:name,' 1 (and only 1) association with the stereotype &quot;padrelatie&quot; and the name &quot;pad&quot; has to be present.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="imvert:associations/imvert:association[imvert:name != 'request' and imvert:name != 'response' and imvert:name != 'requestbody' and imvert:name != 'pad']">
						<!-- In case of a Po messagetype has one or more associations not having the name 'response', 'request','requestbody or 'pad' an error
						     message is generated. -->
						<xsl:variable name="msg"
							select="concat('Within the messageclass &quot;',imvert:name,'&quot; one or more associations with a name not equal to &quot;response&quot;, &quot;request&quot; or &quot;pad&quot;. For messages with berichttype &quot;',$berichtcode,'&quot; this is not allowed.')"
							as="xs:string" />
						<xsl:sequence select="imf:msg('ERROR',$msg)" />
					</xsl:when>
					<xsl:when
						test="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]">
						<xsl:for-each
							select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and imvert:name = 'response']">
							
							<xsl:sequence select="imf:create-debug-comment('A12750]',$debugging)" />
							<ep:rough-message messagetype="response" berichtcode="{$berichtcode}" tag="{$tag}" grouping="{$grouping}" pagination="{$pagination}" serialisation="{$serialisation}">
								<xsl:sequence
									select="imf:create-debug-track(concat('Constructing the rough-response-message: ',imvert:name/@original),$debugging)" />
								<xsl:sequence
									select="imf:create-output-element('ep:name', $messagename)" />
								<xsl:sequence select="imf:create-output-element('ep:id', $messageid)" />
								<xsl:sequence
									select="imf:create-output-element('ep:type-id', $messagetypeid)" />
								<xsl:apply-templates select="." mode="create-rough-message-content" />
							</ep:rough-message>
						</xsl:for-each>
						<xsl:for-each
							select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and imvert:name = 'requestbody']">
							<!-- For the post messages the ep:rough-message structure only represents the 'request' tree. So only that part of the message is
							     processed here. -->
							<ep:rough-message messagetype="requestbody" berichtcode="{$berichtcode}" tag="{$tag}" grouping="{$grouping}" pagination="{$pagination}" serialisation="{$serialisation}">
								<xsl:if test="not(empty($customPathFacet))">
									<xsl:attribute name="customPathFacet" select="$customPathFacet"/>
								</xsl:if>
								<xsl:sequence select="imf:create-debug-comment('A13000]',$debugging)" />
								<xsl:sequence
									select="imf:create-debug-track(concat('Constructing the rough-requestbody-message: ',imvert:name/@original),$debugging)" />
								
								<xsl:sequence
									select="imf:create-output-element('ep:name', $messagename)" />
								<xsl:sequence select="imf:create-output-element('ep:id', $messageid)" />
								<xsl:sequence
									select="imf:create-output-element('ep:type-id', $messagetypeid)" />
								<xsl:apply-templates select="."
									mode="create-rough-message-content" />
							</ep:rough-message>
						</xsl:for-each>
						<xsl:for-each
							select="imvert:associations/imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie') and imvert:name = 'request']">
							<!-- For the post messages the ep:rough-message structure only represents the 'request' tree. So only that part of the message is
							     processed here. -->
							<ep:rough-message messagetype="request" berichtcode="{$berichtcode}" tag="{$tag}" grouping="{$grouping}" pagination="{$pagination}" serialisation="{$serialisation}">
								<xsl:if test="not(empty($customPathFacet))">
									<xsl:attribute name="customPathFacet" select="$customPathFacet"/>
								</xsl:if>
								<xsl:sequence select="imf:create-debug-comment('A13000]',$debugging)" />
								<xsl:sequence
									select="imf:create-debug-track(concat('Constructing the rough-request-message: ',imvert:name/@original),$debugging)" />
								
								<xsl:sequence
									select="imf:create-output-element('ep:name', $messagename)" />
								<xsl:sequence select="imf:create-output-element('ep:id', $messageid)" />
								<xsl:sequence
									select="imf:create-output-element('ep:type-id', $messagetypeid)" />
								<xsl:apply-templates select="."
									mode="create-rough-message-content" />
							</ep:rough-message>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- This otherwise should never occur. -->
						<xsl:sequence
							select="imf:create-debug-comment('Otherwise-tak',$debugging)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template
		match="imvert:association[imvert:stereotype/@id = ('stereotype-name-entiteitrelatie')]"
		mode="create-rough-message-content">
		<!-- This template transforms an 'imvert:association' element of stereotype 
			 'entiteitrelatie' to an 'ep:construct' element.. -->
		
		<xsl:variable name="type-id" select="imvert:type-id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A13500 /debug:start',$debugging)" />
		<xsl:sequence select="imf:create-debug-comment(imvert:name,$debugging)" />
		
		<!-- The imvert:class related to the current imvert:association is processed. 
			 To be able to trace back to the refering association the id of that association (id-refering-association) is 
			 forwarded to the template. --> 
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="id-refering-association" select="imvert:id" />
			<xsl:with-param name="association-function">
				<xsl:choose>
					<xsl:when test="imvert:name = 'request'">
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

	<xsl:template match="imvert:class" mode="create-rough-message-content">
		<!-- Declaration of the content of a superclass, an 'imvert:association' 
			 and 'imvert:association-class' finaly always takes place within an 'imvert:class' 
			 element. This element is processed within this template. -->
		<xsl:param name="id-trail" />
		<xsl:param name="proces-type" select="'as-normal'" />
		<xsl:param name="type" select="'class'" />
		<xsl:param name="id-refering-association" select="''" />
		<xsl:param name="association-function" select="''" />

		<xsl:variable name="id" select="imvert:id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A14000 /debug:start',$debugging)" />
		<xsl:sequence
			select="imf:create-debug-comment(concat('Classname: ',imvert:name),$debugging)" />

		<xsl:choose>
			<xsl:when test="not(contains($id-trail, concat('#', $id, '#')))">
				<!-- The class hasn't been processed before within the current tree so it can be processed. -->
				<xsl:choose>
					<xsl:when test="$proces-type = 'as-supertype'">
						<!-- If the class in the tree is used as a supertype it will be processed as a supertype. -->
						<ep:superconstruct type="superclass">
							<xsl:sequence select="imf:create-debug-comment('A15500]',$debugging)" />
							<xsl:sequence
								select="imf:create-output-element('ep:name', imvert:name/@original)" />
							<xsl:sequence
								select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
							<xsl:sequence select="imf:create-output-element('ep:id', $id)" />
							<!-- The following takes care of processing attributes which are complex datatypes or referentie lijsten en who have
								 for that reason a deeper structure.
								 Besides that it also takes care of placing indicators indicating if the attribuut is a non-id attribuut which is
								 crucial to be able to decide if embedded types have to be created in JSON. -->
							<xsl:apply-templates select="imvert:attributes/imvert:attribute">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<!-- If the current class has a supertype that supertype has to be present too in the rough message structure. -->
							<xsl:apply-templates select="imvert:supertype"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<!-- The current class can have associations, If so they are processed here. -->
							<xsl:apply-templates select="imvert:associations/imvert:association"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
						</ep:superconstruct>
					</xsl:when>
					<xsl:when
						test="$proces-type = 'as-normal' and $packages//imvert:class[imvert:supertype/imvert:type-id = $id]">
						<xsl:sequence
							select="imf:create-debug-comment('debug:start A14250',$debugging)" />
						<!-- If a supertype is refered to from an association the related subtypes 
						 	 are placed, as a construct, within a sequence within that association. -->
						<xsl:apply-templates
							select="$packages//imvert:class[imvert:supertype/imvert:type-id = $id]"
							mode="create-rough-message-content">
							<xsl:with-param name="id-trail" select="$id-trail" />
							<xsl:with-param name="type" select="'subclass'" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="$proces-type = 'as-normal'">
						<xsl:sequence
							select="imf:create-debug-comment('debug:start A14500 /debug:start',$debugging)" />
						<ep:construct>
							<xsl:choose>
								<xsl:when test="$association-function = 'requestParameters'">
									<xsl:attribute name="type" select="'requestclass'" />
								</xsl:when>
								<xsl:when test="$id-refering-association!='' and //imvert:association[imvert:id = $id-refering-association]/imvert:stereotype/@id = 'stereotype-name-association-to-composite'">
									<xsl:attribute name="type" select="'groepCompositie'" />
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
							<xsl:sequence select="imf:create-debug-comment('A15000]',$debugging)" />
							<!-- The following takes care of processing attributes which are complex datatypes or referentie lijsten en who have
								 for that reason a deeper structure.
								 Besides that it also takes care of placing indicators indicating if the attribuut is a non-id attribuut which is
								 crucial to be able to decide if embedded types have to be created in JSON. -->
							<xsl:apply-templates select="imvert:attributes/imvert:attribute">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<!-- If the current class has a supertype that supertype has to be present too in the rough message structure. -->
							<xsl:apply-templates select="imvert:supertype"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
							<!-- The current class can have associations, If so they are processed here. -->
							<xsl:apply-templates select="imvert:associations/imvert:association"
								mode="create-rough-message-content">
								<xsl:with-param name="id-trail"
									select="concat('#', $id, '#', $id-trail)" />
							</xsl:apply-templates>
						</ep:construct>
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="imf:create-debug-comment('A16000]',$debugging)" />
						<!-- The following takes care of processing attributes which are complex datatypes or referentie lijsten en who have
							 for that reason a deeper structure.
							 Besides that it also takes care of placing indicators indicating if the attribuut is a non-id attribuut which is
							 crucial to be able to decide if embedded types have to be created in JSON. -->
						<xsl:apply-templates select="imvert:attributes/imvert:attribute">
							<xsl:with-param name="id-trail"
								select="concat('#', $id, '#', $id-trail)" />
						</xsl:apply-templates>
						<!-- If the current class has a supertype that supertype has to be present too in the rough message structure. -->
						<xsl:apply-templates select="imvert:supertype"
							mode="create-rough-message-content">
							<xsl:with-param name="id-trail"
								select="concat('#', $id, '#', $id-trail)" />
						</xsl:apply-templates>
						<!-- The current class can have associations, If so they are processed here. -->
						<xsl:apply-templates select="imvert:associations/imvert:association"
							mode="create-rough-message-content">
							<xsl:with-param name="id-trail"
								select="concat('#', $id, '#', $id-trail)" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- The class has been processed before within the current tree so processing of supertypes and association of the current class 
					 is canceled to prevent recursion. -->
				<xsl:sequence select="imf:create-debug-comment('A16250]',$debugging)" />
				<ep:construct type="class">
					<!-- The following takes care of processing attributes which are complex datatypes or referentie lijsten en who have
						 for that reason a deeper structure.
						 Besides that it also takes care of placing indicators indicating if the attribuut is a non-id attribuut which is
						 crucial to be able to decide if embedded types have to be created in JSON. -->
					<xsl:apply-templates select="imvert:attributes/imvert:attribute">
						<xsl:with-param name="id-trail"
							select="concat('#', $id, '#', $id-trail)" />
					</xsl:apply-templates>
				</ep:construct>
				<!-- TODO: Er is sprake van dat enige mate van recursion toch wordt toegestaan. 
						   Daarom is deze message bij recursion uitgeschakeld. Indien recursion toch niet 
						   gewenst is dan kan deze weer worden ingeschakeld. -->
				<?x				<xsl:variable name="msg" select="concat('De class ',imvert:name,' komt recursief voor in het BSM model. Bij een Open API koppelvlak is dat niet toegestaan. Pas het model aan.')" as="xs:string"/>
					<xsl:sequence select="imf:msg(.,'WARNING',$msg)"/>
				 ?>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<xsl:template match="imvert:supertype" mode="create-rough-message-content">
		<!-- This template takes care of processing superclasses of the class being processed. -->
		<xsl:param name="id-trail" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A16500 /debug:start',$debugging)" />

		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="id-trail" select="$id-trail" />
			<xsl:with-param name="proces-type" select="'as-supertype'" />
		</xsl:apply-templates>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<xsl:template match="imvert:association" mode="create-rough-message-content">
		<!-- This template transforms an 'imvert:association' element to an 'ep:construct' element. -->
		<xsl:param name="id-trail" />

		<xsl:variable name="type-id" select="imvert:type-id" />
		<xsl:variable name="id" select="imvert:id" />
		
		<xsl:variable name="xorAssociation">
			<xsl:if test="ancestor::imvert:package//imvert:constraints/imvert:constraint[imvert:definition = 'xor']/imvert:connectors/imvert:connector = $id"><xsl:value-of select="generate-id(ancestor::imvert:package//imvert:constraints/imvert:constraint[imvert:definition = 'xor' and imvert:connectors/imvert:connector = $id])"/></xsl:if>
		</xsl:variable>

		<xsl:variable name="orAssociation">
			<xsl:if test="ancestor::imvert:package//imvert:constraints/imvert:constraint[imvert:definition = 'or']/imvert:connectors/imvert:connector = $id"><xsl:value-of select="generate-id(ancestor::imvert:package//imvert:constraints/imvert:constraint[imvert:definition = 'xor' and imvert:connectors/imvert:connector = $id])"/></xsl:if>
		</xsl:variable>
		
		<xsl:sequence
			select="imf:create-debug-comment('debug:start A17000 /debug:start',$debugging)" />
		
		<xsl:if test="ancestor::imvert:class[imvert:stereotype/@id='stereotype-name-composite']">
			
			<!-- ROME: Aangezien nog niet duidelijk is hoe we omgaan met relatie vanuit een groep
					   Is de onderstaande waarschuwing vooralsnog uitgeschakeld. 
					   Deze zal later vervangen worden door de gewenste code. -->
<!--			
			<xsl:variable name="class-name" select="ancestor::imvert:class/imvert:name/@original"/>
			<xsl:variable name="association-name" select="imvert:name/@original"/>
			<xsl:sequence select="imf:msg(.,'WARNING','The association [1] within the class [2] is not allowed since the class is a group composite.',($association-name,$class-name))"/>  -->
		</xsl:if>
		
		<ep:construct>
			<xsl:if test="$debugging">
				<xsl:attribute name="package"
					select="ancestor::imvert:package/imvert:name" />
			</xsl:if>
			<xsl:if test="not(empty($xorAssociation)) and $xorAssociation!=''">
				<xsl:attribute name="xor" select="$xorAssociation"/>
			</xsl:if>
			<xsl:if test="not(empty($orAssociation)) and $orAssociation!=''">
				<xsl:attribute name="or" select="$orAssociation"/>
			</xsl:if>
			<xsl:choose>
				<xsl:when
					test="imvert:stereotype/@id = 'stereotype-name-association-to-composite'">
					<!-- If the association refers to a group composite class part of it is processed here. -->
					<xsl:attribute name="type" select="'groepCompositieAssociation'" />
					<xsl:sequence select="imf:create-debug-comment('A17500]',$debugging)" />
					<xsl:sequence
						select="imf:create-output-element('ep:name', imvert:name/@original)" />
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
				</xsl:when>
				<xsl:when test="imvert:stereotype/@id = 'stereotype-name-relatiesoort'">
					<!-- In other cases part of it is processed here. -->
					<xsl:attribute name="type" select="'association'" />
					<xsl:sequence select="imf:create-debug-comment('A18000]',$debugging)" />
					<xsl:sequence
						select="imf:create-output-element('ep:name', imvert:name/@original)" />
					<xsl:sequence
						select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
				</xsl:when>
			</xsl:choose>

			<xsl:sequence select="imf:create-output-element('ep:type-id', $type-id)" />
			<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)" />

			<xsl:sequence select="imf:create-debug-comment('A18250]',$debugging)" />
			<!-- The association can have an association-class connected to it. This is processed here. -->
			<xsl:apply-templates select="imvert:association-class"
				mode="create-rough-message-content">
				<xsl:with-param name="id-trail" select="$id-trail" />
			</xsl:apply-templates>
			<xsl:sequence select="imf:create-debug-comment('A18500]',$debugging)" />
			<!-- The class the association refers to is processed here. -->
			<xsl:apply-templates select="key('class',$type-id)"
				mode="create-rough-message-content">
				<xsl:with-param name="id-trail" select="$id-trail" />
				<xsl:with-param name="proces-type" select="'as-normal'" />
				<!-- Within the construct refering to a class we need to be able to trace 
					 which association refered to that class since more than one association can refer to the class and each association 
					 has it's own characteristics. -->
				<xsl:with-param name="id-refering-association"
					select="imvert:id" />
			</xsl:apply-templates>
		</ep:construct>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<xsl:template match="imvert:association-class" mode="create-rough-message-content">
		<!-- This template generates the structure of an associationconstruct on 
			 an associationconstruct. -->
		<xsl:param name="id-trail" />

		<xsl:variable name="type-id" select="imvert:type-id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A18500 /debug:start',$debugging)" />

		<xsl:apply-templates select="key('class',$type-id)"
			mode="create-rough-message-content">
			<xsl:with-param name="id-trail" select="$id-trail" />
			<xsl:with-param name="type" select="'association-class'" />
		</xsl:apply-templates>

		<xsl:sequence select="imf:create-debug-comment('debug:end',$debugging)" />
	</xsl:template>

	<xsl:template match="imvert:attribute">
		<!-- This template processes imvert:attribute elements. -->
		
		<xsl:variable name="type-id" select="imvert:type-id" />

		<xsl:sequence
			select="imf:create-debug-comment('debug:start A19000 /debug:start',$debugging)" />
		<xsl:sequence
			select="imf:create-debug-comment(concat('type-id: ',$type-id),$debugging)" />
		
		<!-- To be able to determine if embedded types are neccessary within JSON it must be clear if, within a class, also non-id type 
			 attributes are present. In that case the followng indcator is created. -->
		<xsl:if test="empty(imvert:is-id)">
			<ep:contains-non-id-attributes>true</ep:contains-non-id-attributes>
		</xsl:if>

		<xsl:if
			test="imvert:type-id and //imvert:class[imvert:id = $type-id]/imvert:stereotype[@id = 'stereotype-name-complextype' or @id = 'stereotype-name-referentielijst']">
			<!-- Only if the imvert:attribute is a complextype or referentielijst type (it has a deeper structure) it is processed further. -->
			<xsl:sequence select="imf:create-debug-comment('A19500]',$debugging)" />
			<xsl:variable name="type">
				<xsl:choose>
					<xsl:when test="//imvert:class[imvert:id = $type-id]/imvert:stereotype/@id = 'stereotype-name-complextype'">complex-datatype</xsl:when>
					<xsl:when test="//imvert:class[imvert:id = $type-id]/imvert:stereotype/@id = 'stereotype-name-referentielijst'">table-datatype</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<ep:construct type="{$type}">
				<xsl:sequence
					select="imf:create-output-element('ep:name', imvert:name/@original)" />
				<xsl:sequence
					select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(imvert:name, 'element-name'))" />
				<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)" />
				<xsl:sequence
					select="imf:create-output-element('ep:type-id', imvert:type-id)" />
				
				<xsl:sequence select="imf:create-debug-comment('A10000]',$debugging)" />

				<!-- Since the imvert:attribute has a deeper structure it's related to an imvert:class. That class s processed here. -->
				<xsl:variable name="gerelateerde"
					select="imf:get-class-construct-by-id($type-id,$embellish-file)" />
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
