<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:imf="http://www.imvertor.org/xsl/functions" xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:variable name="stylesheet-code" as="xs:string">OAS</xsl:variable>
	
	<!-- The first variable is meant for the server environment, the second one is used during development in XML-Spy. -->
<!--	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>-->
	<xsl:variable name="debugging" select="true()" as="xs:boolean"/>
	
	<!-- This parameter defines which version of JSON has to be generated, it can take the next values:
		 * 2.0
		 * 3.0	
		 The default value is 3.0. -->
	<xsl:param name="json-version" select="'2.0'"/>
	
	<!-- This variabele defines the type of output and can take the next values:
		 * json
		 * hal+json
		 * geojson	-->
	<xsl:variable name="serialisation">
		<xsl:choose>
			<xsl:when test="empty(/ep:message-sets/ep:parameters/ep:parameter[ep:name='serialisation'])">
				<xsl:value-of select="'hal+json'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="/ep:message-sets/ep:parameters/ep:parameter[ep:name='serialisation']/ep:value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- This variabele defines if pagination applies to at least one message, it can take the next values:
		 * true()
		 * false()	-->
	<xsl:variable name="pagination">
		<xsl:choose>
			<xsl:when test="//ep:message[ep:parameters/ep:parameter[ep:name='pagination']/ep:value='true']">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- The json topstructure depends on its version:
		 * if its version 2.0 the topstructure is #/definitions
		 * if its 3.0 the topstructure is #/components/schemas	-->
	<xsl:variable name="json-topstructure">
		<xsl:choose>
			<xsl:when test="$json-version = '2.0'">
				<xsl:value-of select="'#/definitions'"/>
			</xsl:when>
			<xsl:when test="$json-version = '3.0'">
				<xsl:value-of select="'#/components/schemas'"/>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	
	<!-- This variabele defines if the json file must be preceded with a json schemaversion declaration. 
		 It can have the following values and is only applicable with json schema 2.0:
		 * true()
		 * false()	-->
		 
	<xsl:variable name="json-schemadeclaration" select="true()"/>
	
	<xsl:template match="ep:message-sets">
		<!-- First the JSON top-level structure is generated. -->
		<xsl:value-of select="'{'"/>
		<xsl:choose>
			<xsl:when test="$json-version = '2.0'">
				<xsl:if test="$json-schemadeclaration = true()">
					"$schema": "http://json-schema.org/draft-04/schema#",
					"description": "Comment describing your JSON Schema",
				</xsl:if>
				<xsl:value-of select="'&quot;definitions&quot;: {'"/>
			</xsl:when>
			<xsl:when test="$json-version = '3.0'">
				<xsl:value-of select="'&quot;components&quot;: {'"/>
				<xsl:value-of select="'&quot;schemas&quot;: {'"/>
			</xsl:when>
		</xsl:choose>

		<!-- For each global construct a component is generated. -->

		<!-- Loop over global constructs which are refered to from constructs directly within the (collection) ep:message 
			 elements but aren't enumeration constructs. -->
		<xsl:for-each select="ep:message-set/ep:construct
								 [ 
								   ep:tech-name = //ep:message
								   [
								     (
								       (
								         (
								           contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
										   or 
										   contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
										 ) 
										 and 
										 ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
									   )
									   or 
									   (							
										 contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po' ) 
										 and 
										 ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'request'
									   )
									 )
								   ]
								   /ep:*/ep:construct/ep:type-name 
								   and 
								   not( ep:enum )
								]">
			<xsl:variable name="type-name" select="ep:type-name"/>
			<!-- The regular constructs are generated here. -->
			<xsl:if test="$debugging">
				"--------------Debuglocatie-01000-<xsl:value-of select="generate-id()"/>": {
					"Debug": "OAS01000"
				},
			</xsl:if>
			<xsl:call-template name="construct"/>
			<xsl:if test="position() != last()">
				<!-- As long as the current construct isn't the last constructs that's refered to from the constructs within the messages 
					 a comma separator has to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="$debugging">
			,"--------------Debuglocatie-02000-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS02000"
			}
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<!-- If the for each after this if is relevant a comma separator has to be generated here. -->
				<xsl:if test="ep:message-set/ep:construct
								[ 
								  ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name 
								  and 
								  not(
									   ep:tech-name = //ep:message
									   [
										 ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
									   ]
									   /ep:*/ep:construct/ep:type-name
								  ) 
								  and 
								  not(ep:enum) 
								  and 
								  (
									( 
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'request'
									) 
									or 
									(
									  (
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
										or 	
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
									  ) 
									  and 
									  ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
									)
								  )
								  and 
								  not(
									   ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
									   and 
									   ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
								  )
								  and
								  not(
										ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
										[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
										/ep:type-name
								  )
								  and
								  (
									(
									  ep:parameters/ep:parameter[ep:name='type']/ep:value != '' 
									  and 
									  ep:parameters/ep:parameter[ep:name='expand']/ep:value = 'true'
									) 
									or 
									(
									  ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groepCompositie','table-datatype')
									)
								  )
								  and
								  not(
									  ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groepCompositie'])] 
									  and 
									  ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
									  and 
									  not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
								  )
								]">,</xsl:if>
				<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't enumeration and superclass constructs.
					 This is only applicable when the serialisation is hal+json. -->
				<xsl:for-each select="ep:message-set/ep:construct
								[ 
									(
										ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name
										or
										ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:choice/ep:construct/ep:type-name
									) 
									and 
									not(
									   ep:tech-name = //ep:message
									   [
										 ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
									   ]
									   /ep:*/ep:construct/ep:type-name
									) 
									and 
									not(ep:enum) 
									and 
									(
									  (
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'request'
									  ) 
									  or 
									  (
										( 
										  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
										  or 	
										  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
										) 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
									  )
									)
									and 
									not(
									   ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
									   and 
									   ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
									)
									and
									not(
										ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
										[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
										/ep:type-name
									)
									and
									(
									  (
										ep:parameters/ep:parameter[ep:name='type']/ep:value != '' 
										and 
										ep:parameters/ep:parameter[ep:name='expand']/ep:value = 'true'
									  ) 
									  or 
									  (
										ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groepCompositie','table-datatype')
									  )
									)
									and
									not(
										ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groepCompositie'])] 
										and 
										ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
										and 
										not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
									)
								]">
					<!-- Only regular constructs are generated. -->
					<xsl:if test="$debugging">
						"--------------Debuglocatie-03000-<xsl:value-of select="generate-id()"/>": {
							"Debug": "OAS03000"
						},
					</xsl:if>
					<xsl:call-template name="construct"/>
					<xsl:if test="position() != last()">
						<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs a 
							 comma separator has to be generated. -->
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
				<!-- If the for each after this if is relevant a comma separator has to be generated here. -->
				<xsl:if test="ep:message-set/ep:construct
								[ 
								  ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name 
								  and 
								  not(
									   ep:tech-name = //ep:message
									   [
										 ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
									   ]
									   /ep:*/ep:construct/ep:type-name
								  ) 
								  and 
								  not(ep:enum) 
								  and 
								  (
									( 
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'request'
									) 
									or 
									(
									  (
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
										or 	
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
									  ) 
									  and 
									  ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
									)
								  )
								  and 
								  not(
									   ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
									   and 
									   ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
								  )
								  and
								  not(
										ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
										[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
										/ep:type-name
								  )
								  and
									ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groepCompositie','table-datatype')
								  and
								  not(
									  ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groepCompositie'])] 
									  and 
									  ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
									  and 
									  not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
								  )
								]">,</xsl:if>
				<!-- Loop over global constructs which are refered to from constructs within global constructs but aren't enumeration and superclass constructs.
					 This is only applicable when the serialisation is hal+json. -->
				<xsl:for-each select="ep:message-set/ep:construct
								[ 
									(
										ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:type-name
										or
										ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:choice/ep:construct/ep:type-name
									) 
									and 
									not(
									   ep:tech-name = //ep:message
									   [
										 ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response' 
									   ]
									   /ep:*/ep:construct/ep:type-name
									) 
									and 
									not(ep:enum) 
									and 
									(
									  (
										contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'request'
									  ) 
									  or 
									  (
										( 
										  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
										  or 	
										  contains( ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
										) 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value = 'response'
									  )
									)
									and 
									not(
									   ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
									   and 
									   ep:tech-name = //ep:message-set/ep:construct/ep:*/ep:construct/ep:ref
									)
									and
									not(
										ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
										[ ep:parameters/ep:parameter[ep:name='type']/ep:value = 'subclass']
										/ep:type-name
									)
									and
										ep:parameters/ep:parameter[ep:name='type']/ep:value = ('complex-datatype','groepCompositie','table-datatype')
									and
									not(
										ep:parameters[not(ep:parameter[ep:name='type' and ep:value='groepCompositie'])] 
										and 
										ep:parameters[not(ep:parameter[ep:name='type' and ep:value='requestclass'])] 
										and 
										not(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]])
									)
								]">
					<!-- Only regular constructs are generated. -->
					<xsl:if test="$debugging">
						"--------------Debuglocatie-03000-<xsl:value-of select="generate-id()"/>": {
							"Debug": "OAS03000"
						},
					</xsl:if>
					<xsl:call-template name="construct"/>
					<xsl:if test="position() != last()">
						<!-- As long as the current construct isn't the last constructs that's refered to from constructs within global constructs a 
							 comma separator has to be generated. -->
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>

		<xsl:if test="$debugging">
			,"--------------Debuglocatie-02500-<xsl:value-of select="generate-id()"/>": {
				"Einde Debug": "OAS02500"
			}
		</xsl:if>
		<!-- If the for each after this if is relevant a comma separator has to be generated here. -->
		<xsl:if test="ep:message-set/ep:construct
						[
						  ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
						  and 
						  not(
							   ep:tech-name = //ep:message-set/ep:construct
							   [
							     ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
											   [ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
											   /ep:type-name
							   ]
							   /ep:*/ep:construct/ep:ref
						  )
						]">,</xsl:if>
		<!-- Loop over global superclass constructs which are refered to from constructs within the messages. -->
		<xsl:for-each select="ep:message-set/ep:construct
								[
								  ep:parameters/ep:parameter[ep:name='type']/ep:value='superclass' 
								  and 
								  not(
									   ep:tech-name = //ep:message-set/ep:construct
									   [
									     ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
													    [ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
													    /ep:type-name
									   ]
									   /ep:*/ep:construct/ep:ref
								  )
								]">
			<!-- Only regular constructs are generated. -->
			<xsl:if test="$debugging">
				"--------------Debuglocatie-04000-<xsl:value-of select="generate-id()"/>": {
					"Debug": "OAS04000"
				},
			</xsl:if>
			<xsl:call-template name="construct"/>
			<xsl:if test="position() != last()">
				<!-- As long as the current construct isn't the last constructs that's refered to from the global constructs a comma separator 
					 has to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<!-- Only if hal+json applies this when is relevant -->
				<!-- If the for each after this if is relevant a comma separator has to be generated here. -->
				<xsl:if test="ep:message-set/ep:construct
								[
									not(
										 ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
														[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
														/ep:type-name
									) 
									and 
									(
										empty(
											 ep:parameters/ep:parameter[ep:name='abstract']
											) 
										or
										ep:parameters/ep:parameter[ep:name='abstract']/ep:value = 'false'
									)
									and 
									(
									  (
									    contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
									    and 
									    ep:parameters/ep:parameter[ep:name='messagetype']/ep:value='request'
									  ) 
									  or 
									  (
									    (
											contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
											or 
											contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
										) 
										and 
										ep:parameters/ep:parameter[ep:name='messagetype']/ep:value='response'
									  )
									) 
									and 
									ep:parameters/ep:parameter[ep:name='type']/ep:value!='complex-datatype' 
									and 
									ep:parameters/ep:parameter[ep:name='type']/ep:value!='table-datatype' 
									and 
									ep:parameters/ep:parameter[ep:name='type']/ep:value!='groepCompositie' 
									and 
									ep:parameters/ep:parameter[ep:name='type']/ep:value!='groepCompositieAssociation' 
									and 
									ep:parameters/ep:parameter[ep:name='type']/ep:value != '' 
									and 
									(
									  ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
									  or 
									  .//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='association'] 
									  or 
									  ep:tech-name = //ep:message/ep:seq/ep:construct/ep:type-name
									)
									and (
									.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]]
									or
									empty(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id']]])
									)
									and ep:seq/ep:*
								]">,</xsl:if>
				<!-- Loop over global constructs which 
					 * aren't reffered to from ep:construct elements of type 'subclass' which are child of an ep:choice;
					 * aren't abstract;
					 * are part of the requesttree of a Po message or in the responsetree of an Gc or Gr message;
					 * aren't of type 'complex-datatype';
					 * aren't of type 'table-datatype';
					 * aren't of type 'groepCompositie';
					 * aren't of type 'groepCompositieAssociation';
					 * do have a type;
					 * are part of a message which must be expanded or do have themself an ep:construct of 'association' type  or are reffered to from a 
					   top-level ep:construct within an ep:message;
					 * has attributes which aren't part of the id of the ep:construct.
					 in those case a global _link types (and under certain circumstances global _embedded types) are generated. -->
				<xsl:for-each select="ep:message-set/ep:construct
										[
										  	not(
												 ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
															    [ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
															    /ep:type-name
												) 
											and 
											(
												empty(
													 ep:parameters/ep:parameter[ep:name='abstract']
													) 
												or
												ep:parameters/ep:parameter[ep:name='abstract']/ep:value = 'false'
											)
											and 
											(
											  (
												contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Po') 
												and 
												ep:parameters/ep:parameter[ep:name='messagetype']/ep:value='request'
											  ) 
											  or 
											  (
											    (
													contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
													or 
													contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
												) 
												and 
												ep:parameters/ep:parameter[ep:name='messagetype']/ep:value='response'
											  )
											) 
											and 
											ep:parameters/ep:parameter[ep:name='type']/ep:value!='complex-datatype' 
											and 
											ep:parameters/ep:parameter[ep:name='type']/ep:value!='table-datatype' 
											and 
											ep:parameters/ep:parameter[ep:name='type']/ep:value!='groepCompositie' 
											and 
											ep:parameters/ep:parameter[ep:name='type']/ep:value!='groepCompositieAssociation' 
											and 
											ep:parameters/ep:parameter[ep:name='type']/ep:value != '' 
											and 
											(
											  ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
											  or 
											  .//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='association'] 
											  or 
											  ep:tech-name = //ep:message/ep:seq/ep:construct/ep:type-name
											)
											and (
											.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id' and ep:value='false']]]
											or
											empty(.//ep:construct[ep:parameters[ep:parameter[ep:name='is-id']]])
											)
											and ep:seq/ep:*
										]">
						<xsl:if test="$debugging">
							"--------------Debuglocatie-05000-<xsl:value-of select="generate-id()"/>": {
								"Debug": "OAS05000"
							},
						</xsl:if>
						<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_links&quot;: {' )"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
						<xsl:value-of select="'&quot;properties&quot;: {'"/>
						<xsl:if test="empty(ep:parameters/ep:parameter[ep:name = 'abstract']) or ep:parameters/ep:parameter[ep:name = 'abstract']/ep:value = 'false'">
							<xsl:value-of select="'&quot;self&quot;: {'"/>
							<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/Link&quot;')"/>
							<xsl:value-of select="'}'"/>
							<xsl:if test=".//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association') and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]">,</xsl:if>
						</xsl:if>
						<xsl:for-each select="ep:seq/ep:choice">
							<xsl:apply-templates select="ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')  and ep:type-name = //ep:message-set/ep:construct/ep:tech-name][1]" mode="_links"/>
						</xsl:for-each>
						<xsl:apply-templates select=".//ep:seq/ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')  and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="_links"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
						<xsl:if test="$debugging">
							,"--------------Einde-05500-<xsl:value-of select="generate-id()"/>": {
								"Debug": "OAS05500"
							}
		
						</xsl:if>
						<xsl:if test="position() != last()">
							<!-- As long as the current construct isn't the last global constructs (that has itself a construct of 'association' type) 
								 a comma separator as to be generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
				</xsl:for-each>
				<!-- When expand applies in one or more messages the following if is relevant. -->
				<xsl:if test="ep:message-set/ep:message[ep:parameters/ep:parameter[ep:name='expand']/ep:value = 'true']">
					<!-- If the for each after this if is relevant a comma separator has to be generated. -->
					<xsl:if test="ep:message-set/ep:construct
									[
										ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
										and 
										not(
											 ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
														    [ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
														    /ep:type-name
										) 
										and 
										.//ep:construct
										[
										  (
										    ep:parameters/ep:parameter[ep:name='type']/ep:value='association' 
										    or 
										    ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association'
										  ) 
										  and 
										  ep:parameters/ep:parameter[ep:name='contains-non-id-attributes']/ep:value = 'true'
										]
									]">,
										<xsl:if test="$debugging">
											"--------------Debuglocatie-06000-<xsl:value-of select="generate-id()"/>": {
												"Debug": "OAS06000"
											},						
										</xsl:if>
					</xsl:if>
					<!-- For all global constructs who have at least one association or supertype-association construct a global embedded version has to 
						 be generated. -->
					<xsl:for-each select="ep:message-set/ep:construct
										    [
												ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
												and
												not(
													 ep:tech-name = //ep:message-set/ep:construct/ep:choice/ep:construct
																    [ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']
																    /ep:type-name
												) 
												and 
												.//ep:construct
												[
												  (
												    ep:parameters/ep:parameter[ep:name='type']/ep:value='association' 
												    or 
												    ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association'
												  )  
												  and 
												  ep:parameters/ep:parameter[ep:name='contains-non-id-attributes']/ep:value = 'true'
												]
											]">
						<xsl:variable name="typeName" select="ep:type-name"/>
						<!-- The embedded component must only be generated when the apply-template of the ep:seq element results in content.
							 That is determined here. For now this is only determined for one _embedded level. If this isn't enough I have to implement a more thorough solution.  -->
						<xsl:variable name="content">
							<xsl:apply-templates select="ep:seq">
								<xsl:with-param name="typeName" select="$typeName"/>
							</xsl:apply-templates>
						</xsl:variable>
						
						<xsl:if test="contains($content,'{')">
							<xsl:if test="$debugging">
								"--------------Debuglocatie-07000-<xsl:value-of select="generate-id()"/>": {
									"Debug": "OAS07000"
								},
							</xsl:if>
							<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_embedded&quot;: {' )"/>
							<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
							<xsl:value-of select="'&quot;properties&quot;: {'"/>
	
							<xsl:apply-templates select="ep:seq">
								<xsl:with-param name="typeName" select="$typeName"/>
							</xsl:apply-templates>
	<?x						<xsl:for-each select="ep:seq/ep:choice">
								<xsl:variable name="firstChoice" select=".//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
															 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name][1]"/>
								<xsl:variable name="elementName">
									<xsl:choose>
										<xsl:when test="not(empty($firstChoice/ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value))">
											<xsl:value-of select="$firstChoice/ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
										</xsl:when>
										<xsl:when test="not(empty($firstChoice/ep:parameters/ep:parameter[ep:name='targetrole']/ep:value))">
											<xsl:value-of select="$firstChoice/ep:parameters/ep:parameter[ep:name='targetrole']/ep:value"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="translate($firstChoice/ep:tech-name,'.','_')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="maxOccurs" select="$firstChoice/ep:max-occurs"/>
								<xsl:variable name="minOccurs" select="$firstChoice/ep:min-occurs"/>
								<xsl:variable name="occurence-type">
									<xsl:choose>
										<xsl:when test="$maxOccurs = 'unbounded' or $maxOccurs > 1">array</xsl:when>
										<xsl:otherwise>object</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="typeName" select="$firstChoice/ep:type-name"/>
								<xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>
								
								<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
								<xsl:variable name="documentation">
									<xsl:value-of select="$firstChoice/ep:documentation//ep:p"/>
								</xsl:variable>
								<xsl:choose>
									<!-- Depending on the occurence-type and the type of construct content is generated. -->
									<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
										<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
										<!-- Double quotes in documentation text is replaced by a  grave accent. -->
										<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
										<xsl:value-of select="'&quot;,'"/>
										<xsl:if test="$maxOccurs != 'unbounded'">
											<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
										</xsl:if>
										<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
											<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="$occurence-type = 'array'">
												<xsl:value-of select="'&quot;items&quot;: {'"/>
												<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
												<xsl:apply-templates select=".//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																			 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
												<xsl:value-of select="']'"/>
												<xsl:value-of select="'}'"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
												<xsl:apply-templates select=".//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																			 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
												<xsl:value-of select="']'"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
										<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
										<!-- Double quotes in documentation text is replaced by a  grave accent. -->
										<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
										<xsl:value-of select="'&quot;,'"/>
										<xsl:if test="$maxOccurs != 'unbounded'">
											<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
										</xsl:if>
										<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
											<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="$occurence-type = 'array'">
												<xsl:value-of select="'&quot;items&quot;: {'"/>
												<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
												<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
												<xsl:value-of select="']'"/>
												<xsl:value-of select="'}'"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
												<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
												<xsl:value-of select="']'"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
								</xsl:choose>
								<xsl:value-of select="'}'"/>
								<xsl:choose>
									<xsl:when test="following-sibling::ep:choice">
										<!-- As long as the current construct isn't the last global constructs (that has at least one association construct) a comma separator as 
											 to be generated. -->
										<xsl:value-of select="','"/>
									</xsl:when>
									<xsl:when test=".//ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
												  and $typeName = //ep:message-set/ep:construct/ep:tech-name]">
										<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
										<xsl:value-of select="','"/>
									</xsl:when>
								</xsl:choose>
								,"test": "test",
							</xsl:for-each>
								<!-- Only for the association constructs properties have to be generated. This is not applicable for supertype-association 
									 constructs. -->
							<xsl:apply-templates select="ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
														 and $typeName = //ep:message-set/ep:construct/ep:tech-name]" mode="embedded"/> ?>
							<xsl:value-of select="'}'"/>
							<xsl:value-of select="'}'"/>
							<xsl:if test="$debugging">
								,"--------------Einde-07500-<xsl:value-of select="generate-id()"/>": {
									"Debug": "OAS07500"
								}
							</xsl:if>
							<xsl:if test="position() != last()">
								<!-- As long as the current construct isn't the last global constructs (that has at least one association construct) a comma separator as 
									 to be generated. -->
								<xsl:value-of select="','"/>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
					<!-- ROME: Ik twijfel er aan of de volgende if en for-each sowieso ooit afgevuurd zullen worden.
							   In de huidge modellen (19-9-2018)  gebeurd dat i.i.g niet. 
							   Wellicht kunnen ze dus verwijderd worden. -->
					<!-- If the for each after this if is relevant a comma separator has to be generated. -->
					<xsl:if test="ep:message-set/ep:construct
							    [
							      ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
							      and 
							      ep:tech-name = //ep:message
												 [
												   ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
												   and 
												   (
												     ep:parameters/ep:parameter[ep:name='messagetype']/ep:value != 'request' 
												     and 
												     (
												       contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
												       or 
												       contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
												     )
												   )
												 ]
												 //ep:construct
												 [ep:parameters/ep:parameter[ep:name='type']/ep:value='association']/ep:type-name
								]">
						,
						<xsl:if test="$debugging">
							"--------------Debuglocatie-08000-<xsl:value-of select="generate-id()"/>": {
								"Debug": "OAS08000"
							},						
						</xsl:if>
					</xsl:if>
					<!-- For all global constructs who are refered to from an association construct within a message construct
						 a global embedded version has to be generated. -->
					<xsl:for-each select="ep:message-set/ep:construct
								  [
								    ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
								    and 
								    ep:tech-name = //ep:message
												   [
												     ep:parameters/ep:parameter[ep:name='expand']/ep:value='true' 
												     and 
												     (
												       ep:parameters/ep:parameter[ep:name='messagetype']/ep:value != 'request' 
												       and 
												       (
												         contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gc') 
												         or 
												         contains(ep:parameters/ep:parameter[ep:name='berichtcode']/ep:value,'Gr')
												       )
												     )
												   ]
												   //ep:construct
												   [ep:parameters/ep:parameter[ep:name='type']/ep:value='association']/ep:type-name
								  ]">
						<xsl:if test="$debugging">
							"--------------Debuglocatie-09000-<xsl:value-of select="generate-id()"/>": {
							"Debug": "OAS09000"
							},
						</xsl:if>
						<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'_embedded&quot;: {' )"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
						<xsl:value-of select="'&quot;properties&quot;: {'"/>
						<xsl:apply-templates select=".//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association') and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embedded"/>
						<xsl:value-of select="'}'"/>
						<xsl:value-of select="'}'"/>
						<xsl:if test="$debugging">
							,"--------------Einde-09500-<xsl:value-of select="generate-id()"/>": {
							"Debug": "OAS09500"
							}
						</xsl:if>
						<xsl:if test="position() != last()">
							<!-- As long as the current construct isn't the last global constructs 
								(that has at least one association construct) a comma separator as to be 
								generated. -->
							<xsl:value-of select="','"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
				<!-- Since hal+json applies the following properties are generated. -->    
				,
				<!-- If pagination is desired, collections apply, the following properties are generated. -->
				<xsl:if test="$pagination = true()">
				  "Pagineerlinks" : {
					"allOf" : [ {
					  "$ref" : "#/components/schemas/Collectionlinks"
					}, {
					  "type" : "object",
					  "properties" : {
						"first" : {
						  "type" : "object",
						  "description" : "uri voor het opvragen van de eerste pagina van deze collectie",
						  "properties" : {
							"href" : {
							  "type" : "string",
							  "format" : "uri",
							  "example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=1"
							},
							"title" : {
							  "type" : "string",
							  "example" : "Eerste pagina"
							}
						  }
						},
						"previous" : {
						  "type" : "object",
						  "description" : "uri voor het opvragen van de vorige pagina van deze collectie",
						  "properties" : {
							"href" : {
							  "type" : "string",
							  "format" : "uri",
							  "example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=3"
							},
							"title" : {
							  "type" : "string",
							  "example" : "Vorige pagina"
							}
						  }
						},
						"next" : {
						  "type" : "object",
						  "description" : "uri voor het opvragen van de volgende pagina van deze collectie",
						  "properties" : {
							"href" : {
							  "type" : "string",
							  "format" : "uri",
							  "example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=5"
							},
							"title" : {
							  "type" : "string",
							  "example" : "Volgende pagina"
							}
						  }
						},
						"last" : {
						  "type" : "object",
						  "description" : "uri voor het opvragen van de laatste pagina van deze collectie",
						  "properties" : {
							"href" : {
							  "type" : "string",
							  "format" : "uri",
							  "example" : "https://datapunt.voorbeeldgemeente.nl/service/api/v1/resourcenaam?page=8"
							},
							"title" : {
							  "type" : "string",
							  "example" : "Laatste pagina"
							}
						  }
						}
					  }
					} ]
				  },
				</xsl:if>
				<!-- If at least on eof the messages is a Gc-type message the 'Collectionslinks' component is generated. -->
				"Href" : {
				  "type" : "string",
				  "format" : "uri"
				},
				"Link" : {
				  "type" : "object",
				  "properties" : {
					"href" : {
					  "$ref" : "#/components/schemas/Href"
					}
				  }
				},
				<xsl:if test="//ep:message[contains(ep:parameters/ep:parameter[ep:name = 'berichtcode']/ep:value,'Gc')]">
				  "Collectionlinks" : {
					  "type" : "object",
					  "properties" : {
					    "self" : {
						  "type" : "object",
						  "description" : "uri van de api aanroep die tot dit resultaat heeft geleid",
						  "properties" : {
						    "href" : {
						      "$ref" : "#/components/schemas/Href"
						    }
						  }
					    }
					  }
				  }
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- If serialisation isn't hal+json no _links en _embedded components have to be generated, only a comma. -->
			</xsl:otherwise>
		</xsl:choose>
        <!-- If for each after this if is relevant a comma separator has to be generated. -->
		<xsl:if test="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:enum]">,</xsl:if>
		<!-- Loop over all enumeration constructs. -->
		<xsl:for-each select="ep:message-set/ep:construct[ep:tech-name = //ep:message-set/ep:construct/ep:seq/ep:construct/ep:type-name and ep:enum]">
			<xsl:variable name="type-name" select="ep:type-name"/>
			<!-- An enummeration property is generated. -->
			<xsl:call-template name="enumeration"/>
			<xsl:if test="position() != last()">
				<!-- As long as the current construct isn't the last enumeration construct a comma separator has to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="$json-version = '2.0'"/>
			<xsl:when test="$json-version = '3.0'">
				<xsl:value-of select="'}'"/>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="$json-version = '3.0'">
			<xsl:text>,
  "headers": {
    "api_version": {
	  "schema": {
	    "type": "integer",
	    "description": "Geeft een specifieke API-versie aan in de context van een specifieke aanroep.",
	    "example": "1.0.1"
        }
    },
    "warning": {
      "schema": {
        "type": "string", 
        "description": "zie RFC 7234. In het geval een major versie wordt uitgefaseerd, gebruiken we warn-code 299 ('Miscellaneous Persistent Warning') en het API end-point (inclusief versienummer) als de warn-agent van de warning, gevolgd door de warn-text met de human-readable waarschuwing",
        "example": "299 https://service.../api/.../v1 'Deze versie van de API is verouderd en zal uit dienst worden genomen op 2018-02-01. Raadpleeg voor meer informatie hier de documentatie: https://omgevingswet.../api/.../v1'."
        }
    },</xsl:text>
			<xsl:if test="//ep:message[ep:parameters/ep:parameter[ep:name='grouping']/ep:value='collection']">
				<xsl:text>
    "X_Total_Count": {
      "schema": {
        "type": "integer",
        "description": "Totaal aantal paginas.",
        "example": "163"
        }
    },</xsl:text>
				<xsl:if test="$pagination = true()">
					<xsl:text>
    "X_Pagination_Count": {
	  "schema": {
	    "type": "integer",
	    "description": "Totaal aantal paginas.",
	    "example": "16"
	    }
    },
    "X_Pagination_Page":  { 
      "required": true,
	  "schema": { 
	    "type": "integer",
	    "description": "Huidige pagina.",
	    "example": "3"
	    }
    },
    "X_Pagination_Limit": {
      "required": true,
	  "schema": {
	    "type": "integer",
	    "description": "Aantal resultaten per pagina.",
	    "example": "20"
	    }
    },</xsl:text>
				</xsl:if>
			</xsl:if>
			<xsl:text>
    "X_Rate_Limit_Limit": {
	  "schema": {
	    "type": "integer"
	    }
    },
    "X_Rate_Limit_Remaining": {
	  "schema": {
	    "type": "integer"
	    }
    },
    "X_Rate_Limit_Reset": {
	  "schema": {
	    "type": "integer"
	    }
    }
  }</xsl:text>
		</xsl:if>
		<xsl:value-of select="'}'"/>
		<xsl:value-of select="'}'"/>
	</xsl:template>
	
	<xsl:template match="ep:seq">
		<xsl:param name="typeName"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-12000-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS12000"
			},
		</xsl:if>
		<xsl:apply-templates select="ep:choice">
			<xsl:with-param name="typeName" select="$typeName"/>
		</xsl:apply-templates>
		<xsl:if test="$debugging">
			"--------------Debuglocatie-13000-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS13000"
			},
		</xsl:if>
			<!-- Only for the association constructs properties have to be generated. This is not applicable for supertype-association 
				 constructs. -->
		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
				<xsl:variable name="indicatorNonIdProperties">
					<xsl:choose>
						<xsl:when test="ep:construct/ep:parameters[ep:parameter[ep:name='type']/ep:value ='association' and
													 ep:parameter[ep:name='contains-non-id-attributes']/ep:value ='true']">
							<xsl:value-of select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:if test="$indicatorNonIdProperties">
					<xsl:if test="ep:choice and ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association']">,##</xsl:if>
					<xsl:apply-templates select="ep:construct[ep:parameters[ep:parameter[ep:name='type']/ep:value ='association' and
																			ep:parameter[ep:name='contains-non-id-attributes']/ep:value ='true']]" mode="embedded"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
				<xsl:if test="ep:choice and (ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'] or ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'])">,</xsl:if>
				<xsl:apply-templates select="ep:construct[ep:parameters[ep:parameter[ep:name='type']/ep:value ='association' or ep:parameter[ep:name='type']/ep:value ='supertype-association']]" mode="embedded"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="ep:choice">
			<xsl:param name="typeName"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-14000-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS14000"
			},
		</xsl:if>

			<xsl:variable name="firstChoice" select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
										 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name][1]"/>
			<xsl:variable name="elementName">
				<xsl:choose>
					<xsl:when test="not(empty($firstChoice/ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value))">
						<xsl:value-of select="$firstChoice/ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
					</xsl:when>
					<xsl:when test="not(empty($firstChoice/ep:parameters/ep:parameter[ep:name='targetrole']/ep:value))">
						<xsl:value-of select="$firstChoice/ep:parameters/ep:parameter[ep:name='targetrole']/ep:value"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="translate($firstChoice/ep:tech-name,'.','_')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="maxOccurs" select="$firstChoice/ep:max-occurs"/>
			<xsl:variable name="minOccurs" select="$firstChoice/ep:min-occurs"/>
			<xsl:variable name="occurence-type">
				<xsl:choose>
					<xsl:when test="$maxOccurs = 'unbounded' or $maxOccurs > 1">array</xsl:when>
					<xsl:otherwise>object</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="typeName" select="$firstChoice/ep:type-name"/>
			
			<xsl:if test="$serialisation = 'json'">,</xsl:if>
			
			<xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>	
			<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
			<xsl:variable name="documentation">
				<xsl:value-of select="$firstChoice/ep:documentation//ep:p"/>
			</xsl:variable>
			<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
			<!-- Double quotes in documentation text is replaced by a  grave accent. -->
			<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
			<xsl:value-of select="'&quot;,'"/>
			<xsl:if test="$occurence-type = 'array'">
				<xsl:if test="$maxOccurs != 'unbounded'">
					<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
				</xsl:if>
				<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
					<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
				</xsl:if>
				<xsl:if test="$maxOccurs != 'unbounded'">
					<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
				</xsl:if>
				<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
					<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
				</xsl:if>
			</xsl:if>
			<xsl:choose>
				<!-- Depending on the occurence-type and the type of construct content is generated. -->
				<xsl:when test="$serialisation = 'json'">
					<xsl:value-of select="'&quot;enum&quot;: [&quot;string&quot;]'"/>
				</xsl:when>
				<xsl:when test="$serialisation = 'hal+json'">
					<xsl:choose>
						<xsl:when test="$occurence-type = 'array'">
							<xsl:value-of select="'&quot;items&quot;: {'"/>
							<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
							<xsl:choose>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
									<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
								</xsl:when>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
									<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="']'"/>
							<xsl:value-of select="'}'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'&quot;oneOf&quot;: ['"/>
							<xsl:choose>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
									<xsl:apply-templates select="ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' 
																 and ep:type-name = //ep:message-set/ep:construct/ep:tech-name]" mode="embeddedchoices"/>
								</xsl:when>
								<xsl:when test="$firstChoice/ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
									<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="']'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="'}'"/>
			<xsl:if test="following-sibling::ep:choice">
				<!-- As long as the current construct isn't the last global constructs (that has at least one association construct) a comma separator as 
					 to be generated. -->
				<xsl:value-of select="','"/>
			</xsl:if>
	</xsl:template>

	<xsl:template name="construct">
		<!-- With this template global properties are generated.  -->
		<xsl:param name="grouping" select="''"/>
		<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
		<xsl:variable name="expand" select="ep:parameters/ep:parameter[ep:name='expand']/ep:value"/>
		<xsl:if test="$debugging">
			"--------------Debuglocatie-15000-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS15000"
			},
		</xsl:if>
		<xsl:if test="$grouping != 'resource'">
			<!-- RM: Bepalen waarom dit noodzakelijk is. Ik twijfel er niet aan dat het nodig is maar ik wil weten waarom zodat ik het kan documenteren. -->
			<xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
		</xsl:if>
		<xsl:if test="ep:seq/ep:construct[ep:ref]">
			<!-- If the current construct has a construct with a ref (it has a supertype) an 'allOf' s generated. -->
			<xsl:variable name="ref" select="ep:seq/ep:construct/ep:ref"/>
			<xsl:value-of select="'&quot;allOf&quot;: ['"/>
			<xsl:value-of select="concat('{&quot;$ref&quot;: &quot;',$json-topstructure,'/',$ref,'&quot;},')"/>
			<xsl:value-of select="'{'"/>
		</xsl:if>
		<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
		<xsl:variable name="documentation">
			<xsl:value-of select="ep:documentation//ep:p"/>
		</xsl:variable>
		<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
		<!-- Double quotes in documentation text is replaced by a  grave accent. -->
		<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
		<xsl:value-of select="'&quot;'"/>
		<xsl:variable name="requiredproperties" as="xs:boolean">
			<!-- The variable requiredproperties confirms if at least one of the properties of the current construct is required. -->
			<xsl:choose>
				<xsl:when test="ep:seq/ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value != 'association' or empty(ep:parameters/ep:parameter[ep:name='type']/ep:value)) and not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
					<xsl:value-of select="true()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$requiredproperties">
			<!-- Only if the variable requiredproperties is true a 'required' section has to be generated. -->
			<xsl:value-of select="',&quot;required&quot;: ['"/>
			<xsl:for-each select="ep:seq/ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value != 'association' or empty(ep:parameters/ep:parameter[ep:name='type']/ep:value)) and not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
				<!-- Loops over requred constructs, which are required, are no associations and have no ep:seq. -->
				<xsl:value-of select="'&quot;'"/>
				<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
				<xsl:value-of select="'&quot;'"/>
				<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last required construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:for-each>
			<xsl:value-of select="']'"/>
		</xsl:if>
		
		<xsl:variable name="properties">
			<xsl:value-of select="',&quot;properties&quot;: {'"/>
			<!-- Loop over all constructs (that don't have association type, supertype-association type and superclass type constructs) 
				 within the current construct. -->
			<xsl:if test="$serialisation = 'json'">
				<xsl:value-of select="'&quot;url&quot; : {'"/>
				<xsl:value-of select="'&quot;title&quot; : &quot;Url&quot;,'"/>
				<xsl:value-of select="'&quot;type&quot; : &quot;string&quot;,'"/>
				<xsl:value-of select="'&quot;format&quot; : &quot;uri&quot;,'"/>
				<xsl:value-of select="'&quot;readOnly&quot; : true'"/>
				<xsl:value-of select="'}'"/>
				<xsl:if test="ep:seq/ep:construct[not(ep:seq) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association') and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'supertype-association') 
					and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'superclass') and not(ep:ref)]">,</xsl:if>
			</xsl:if>
			<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association') and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'supertype-association') 
				and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'superclass') and not(ep:ref)]">
				<xsl:call-template name="property"/>
				<xsl:if test="(position() != last()) and following-sibling::ep:construct[not(ep:seq) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association') 
					and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'supertype-association') and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'superclass') and not(ep:ref)]">
					<!-- As long as the current construct isn't the last non association type construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="$serialisation = 'hal+json'">
					<xsl:if test="(empty(ep:parameters/ep:parameter[ep:name='abstract']) or ep:parameters/ep:parameter[ep:name='abstract']/ep:value = 'false') and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'complex-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'table-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'groepCompositie' 
						and ep:seq/ep:construct[not(ep:seq) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association') and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'superclass') and not(ep:ref)]">
						<!-- If the current construct:
							 * isn't abstract, 
							 * isn't of type 'complex-datatype' or 'table-datatype' or 'groepCompositie' 
							 * doesn't have an ep:seq with an ep:construct:
							   - containing an ep:seq
							   - being an association
							   - being a superclass
							   - containing an ep:ref. 
							 generate a comma.-->
						<xsl:value-of select="','"/>
					</xsl:if>
					<xsl:if test="(empty(ep:parameters/ep:parameter[ep:name='abstract']) or ep:parameters/ep:parameter[ep:name='abstract']/ep:value = 'false') and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'complex-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'table-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'groepCompositie'">
						<!-- If the current construct isn't a complex-datatype, table-datatype, groupscomposition and not abstract a 
							 _links component variant of the current construct has to be generated.
							 At this place only a reference to such a componenttype is generated. -->
						<xsl:value-of select="'&quot;_links&quot;: {'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_links&quot;}')"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$serialisation = 'json'">
					<xsl:if test="(empty(ep:parameters/ep:parameter[ep:name='abstract']) or ep:parameters/ep:parameter[ep:name='abstract']/ep:value = 'false') and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'complex-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'table-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value != 'groepCompositie' 
						and ep:seq/ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association']">
						<!-- If the current construct:
							 * isn't abstract, 
							 * isn't of type 'complex-datatype' or 'table-datatype' or 'groepCompositie' 
							 * does have an ep:seq with an ep:construct:
							   - being an association
							 generate a comma.-->
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			
			<!-- The reference to the embedded component must only be generated when the related embedded component is generated. That is only the case if that component has content.
				 That is determined here. For now this is only determined for one _embedded level. If this must be determined for more levels or even recursive a more thorough solution has to be implemented. -->
			<xsl:choose>
				<xsl:when test="$serialisation = 'hal+json'">
					<xsl:variable name="contentRelatedEmbeddedConstruct">
						<xsl:variable name="relatedGlobalConstruct">
							<xsl:copy-of select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$elementName]"/>
						</xsl:variable>
						<xsl:variable name="typeName" select="$relatedGlobalConstruct/ep:type-name"/>
						<xsl:apply-templates select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$elementName]/ep:seq">
							<xsl:with-param name="typeName" select="$typeName"/>
						</xsl:apply-templates>
					</xsl:variable>
		
					<xsl:if test=".[ep:parameters/ep:parameter[ep:name='type']/ep:value!='complex-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value!='table-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value!='groepCompositie']//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value='association' 
						or ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association') and ep:parameters/ep:parameter[ep:name='contains-non-id-attributes']/ep:value = 'true'] and contains($contentRelatedEmbeddedConstruct,'{')">
						<!-- When expand applies in the interface also an embedded variant of the current construct has to be generated..
							 At this place only a reference to such a componenttype is generated. -->
						<xsl:value-of select="',&quot;_embedded&quot;: {'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_embedded&quot;}')"/>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$serialisation = 'json'">
					<xsl:if test=".[ep:parameters/ep:parameter[ep:name='type']/ep:value!='complex-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value!='table-datatype' and ep:parameters/ep:parameter[ep:name='type']/ep:value!='groepCompositie']//ep:construct[(ep:parameters/ep:parameter[ep:name='type']/ep:value='association' 
						or ep:parameters/ep:parameter[ep:name='type']/ep:value='supertype-association')]">
						<xsl:variable name="typeName" select="ep:type-name"/>
						<xsl:apply-templates select="ep:seq">
							<xsl:with-param name="typeName" select="$typeName"/>
						</xsl:apply-templates>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="'}'"/>
		</xsl:variable>

		<xsl:if test="$debugging and $serialisation = 'hal+json'">
			<xsl:variable name="relatedGlobalConstruct">
				<xsl:copy-of select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$elementName]"/>
			</xsl:variable>
			<xsl:variable name="typeName" select="$relatedGlobalConstruct/ep:type-name"/>
			<xsl:variable name="contentRelatedEmbeddedConstruct">
				<xsl:apply-templates select="/ep:message-sets/ep:message-set/ep:construct[ep:tech-name=$elementName]/ep:seq">
					<xsl:with-param name="typeName" select="$typeName"/>
				</xsl:apply-templates>
			</xsl:variable>

			<xsl:result-document href="{concat('file:/c:/temp/contentRelatedEmbeddedConstruct/',$elementName,'.json')}" method="text">
				<xsl:copy-of select="$contentRelatedEmbeddedConstruct" />
			</xsl:result-document>
		</xsl:if>

		
		<xsl:if test="$properties != ',&quot;properties&quot;: {}'">
			<xsl:sequence select="$properties"/>
		</xsl:if>
		
		<xsl:if test="ep:seq/ep:construct[ep:ref]">
			<xsl:value-of select="'}'"/>
			<xsl:value-of select="']'"/>
		</xsl:if>
		<xsl:if test="$grouping != 'resource'">
			<xsl:value-of select="'}'"/>
			<xsl:if test="$debugging">
				,"--------------Einde-15500-<xsl:value-of select="generate-id()"/>": {
					"Debug": "OAS15500"
				}
			</xsl:if>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="enumeration">
		<!-- Enummeration constructs are processed here. -->
		<xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>
		<xsl:if test="$debugging">
			"--------------Debuglocatie-16000-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS16000"
			},
		</xsl:if>
		<xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>
		<xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
		
		<?x xsl:choose>
			<xsl:when test="$json-version = '2.0'" ?>
				<xsl:value-of select="'&quot;description&quot; : &quot;'"/>
				<xsl:variable name="enumeration-documentation">
					<xsl:if test="ep:documentation">
						<xsl:apply-templates select="ep:documentation"/><xsl:text>:</xsl:text>
					</xsl:if>
					<xsl:for-each select="ep:enum">
						<xsl:value-of select="concat('\n* ',ep:alias,' - ',ep:name)"/>
					</xsl:for-each>
					<xsl:value-of select="'&quot;,'"/>
				</xsl:variable>
				<xsl:sequence select="$enumeration-documentation"/>
				<xsl:value-of select="'&quot;enum&quot;: ['"/>
				<xsl:for-each select="ep:enum">
					<!-- Loop over all enum elements. -->
					<xsl:value-of select="concat('&quot;',ep:alias,'&quot;')"/>
					<xsl:if test="position() != last()">
						<!-- As long as the current construct isn't the last construct a comma separator has to be generated. -->
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:value-of select="']'"/>
			<?x /xsl:when>
			<xsl:otherwise>

				<xsl:if test="ep:documentation">
					<xsl:value-of select="'&quot;description&quot; : &quot;'"/>
					<xsl:apply-templates select="ep:documentation"/>
					<xsl:value-of select="'&quot;,'"/>
				</xsl:if>
				<xsl:value-of select="'&quot;enum&quot;: ['"/>
				<xsl:for-each select="ep:enum">
					<!-- Loop over all enum elements. -->
					<xsl:value-of select="concat('{&quot;const&quot; : &quot;',ep:alias,'&quot;,')"/>
					<xsl:value-of select="concat('&quot;description&quot; : &quot;',ep:name,'&quot;}')"/>
					<xsl:if test="position() != last()">
						<!-- As long as the current construct isn't the last construct a comma separator has to be generated. -->
						<xsl:value-of select="','"/>
					</xsl:if>
				</xsl:for-each>
				<xsl:value-of select="']'"/>
			</xsl:otherwise>
		</xsl:choose ?>
		<xsl:value-of select="'}'"/>
		<xsl:if test="$debugging">
			,"--------------Einde-16500-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS16500"
			}
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:documentation">
		<xsl:apply-templates select="ep:description"/>
		<xsl:apply-templates select="ep:definition"/>
	</xsl:template>
	
	<xsl:template match="ep:description">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:definition">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:p">
		<xsl:value-of select="."/>
		<xsl:if test="following-sibling::ep:p">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<!-- TODO: Het onderstaande template en ook de aanroep daarvan zijn is op dit moment onnodig omdat we er nu vanuit gaan dat er altijd hal+json 
			   gegenereerd moet worden.
			   Alleen als we later besluiten dat er ook af en toe geen json_hal gegenereerd moet worden kan deze if weer opportuun worden. 
			   Voor nu is het template uitgeschakeld. -->
	<!-- A HAL type is generated here. -->
	<?x <xsl:template name="construct_jsonHAL">
        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:if test="$debugging">
			"--------------Debuglocatie-17000-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS17000"
			},
		</xsl:if>
 
        <xsl:value-of select="concat('&quot;', $elementName,'_HAL&quot;: {' )"/>
		<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>

        <xsl:variable name="elementName" select="translate(ep:tech-name,'.','_')"/>

		<xsl:variable name="documentation">
			<xsl:value-of select="ep:documentation//ep:p"/>
		</xsl:variable>
		<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
		<!-- Double quotes in documentation text is replaced by a  grave accent. -->
		<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
		<xsl:value-of select="'&quot;,'"/>

		<!-- The variable requiredproperties confirms if at least one of the properties of the current construct is required. -->
		<xsl:variable name="requiredproperties" as="xs:boolean">
			<xsl:choose>
				<xsl:when test="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
					<xsl:value-of select="true()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- Only if the variable requiredproperties is true a 'required' section has to be generated. -->
		<xsl:if test="$requiredproperties">
			<xsl:value-of select="'&quot;required&quot;: ['"/>
			
			<!--Only constructs which aren't optional are processed here. -->
			<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(empty(ep:min-occurs)) and ep:min-occurs > 0]">
				<xsl:value-of select="'&quot;'"/><xsl:value-of select="translate(ep:tech-name,'.','_')"/><xsl:value-of select="'&quot;'"/>
				<!-- As long as the current construct isn't the last required construct a comma separator has to be generated. -->
				<xsl:if test="position() != last()">
					<xsl:value-of select="','"/> 
				</xsl:if>
			</xsl:for-each>
			
			<xsl:value-of select="'],'"/>
		</xsl:if>

		<xsl:value-of select="'&quot;properties&quot;: {'"/>
		
<!--		<xsl:if test="$debugging">
			"//<xsl:value-of select="concat('OAS00500: ',generate-id())"/>": "",
		</xsl:if>-->

		<!-- All constructs (that don't have association type constructs) within the current construct are processed here. -->
		<xsl:for-each select="ep:seq/ep:construct[not(ep:seq) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association')]">
			<xsl:variable name="name" select="substring-after(ep:type-name, ':')"/>

<!--			<xsl:if test="$debugging">
				"//<xsl:value-of select="concat('OAS00600: ',generate-id())"/>": "",
			</xsl:if>
-->
			<xsl:call-template name="property"/>

			<!-- As long as the current construct isn't the last non association type construct a comma separator has to be generated. -->
			<xsl:if test="(position() != last()) and following-sibling::ep:construct[not(ep:parameters/ep:parameter[ep:name='type']/ep:value = 'association')]">
				<xsl:value-of select="','"/> 
			</xsl:if>
		</xsl:for-each>
		

		<!-- If the construct has association constructs a reference to a '_links' property is generated based on the same elementname. -->
		<xsl:if test=".//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='association']">
			<xsl:value-of select="','"/>
			<xsl:value-of select="'&quot;properties&quot;: {'"/>
			<xsl:value-of select="'&quot;_links&quot;: {'"/>
			<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_links&quot;}')"/>
			
			<!-- When the construct also had attributes which are not id-type attributes in the interface also an embedded version has to be generated.
				 At this place only a reference to such a type is generated. -->
			<xsl:if test="$contains-non-id-attributes">
				<xsl:value-of select="',&quot;_embedded&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$elementName,'_embedded&quot;}')"/>
			</xsl:if>
			<xsl:value-of select="'}'"/>
		</xsl:if>

		<xsl:value-of select="'}'"/>
		<xsl:value-of select="'}'"/>

		<xsl:if test="$debugging">
			,"--------------Einde-17500-<xsl:value-of select="generate-id()"/>": {
				"Debug": "OAS17500"
			}
		</xsl:if>
   </xsl:template> ?>
   
	<xsl:template name="property">
		<!-- The properties representing an uml attribute are generated here.
			 To be able to do that it uses the derivePropertyContent template which on its turn uses the deriveDataType, deriveFormat and deriveFacets 
			 templates. -->
		<xsl:variable name="derivedPropertyContent">
			<xsl:call-template name="derivePropertyContent">
				<xsl:with-param name="typeName" select="ep:type-name"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- The following if only applies if the current construct has an ep:type-name or a ep:data-type and if it isn't an association type construct
			 or if it is a gml type. -->
		<xsl:if test="((exists(ep:type-name) or exists(ep:data-type)) and not(ep:parameters/ep:parameter[ep:name='type']/ep:value='association') or ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external')">
			<xsl:value-of select="concat('&quot;', translate(ep:tech-name,'.','_'),'&quot;: {' )"/>
			<xsl:value-of select="$derivedPropertyContent"/>
			<xsl:value-of select="'}'"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="derivePropertyContent">
		<!-- This template builds the content of the properties representing an uml attribute. -->
		<xsl:param name="typeName"/>
		<xsl:param name="typePrefix"/>
		<xsl:choose>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value = 'GM-external'">
				<!-- If the property is a gml type this when applies. In all these case a standard content (except the documentation)
					 is generated. -->
				<xsl:variable name="documentation">
					<xsl:value-of select="ep:documentation//ep:p"/>
				</xsl:variable>
				<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value,'&quot;,')"/>
				<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
				<!-- Double quotes in documentation text is replaced by a  grave accent. -->
				<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
				<xsl:value-of select="' Conform geojson, zie http://geojson.org.'"/>
				<xsl:value-of select="'&quot;,'"/>
				<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;'"/>
			</xsl:when>
			<xsl:when test="exists(ep:data-type)">
				<!-- If the construct has a ep:data-type element, a description, an optional format and, also optional, some facets have to be generated. -->
				<xsl:variable name="datatype">
					<xsl:call-template name="deriveDataType">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="format">
					<xsl:call-template name="deriveFormat">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="facets">
					<xsl:call-template name="deriveFacets">
						<xsl:with-param name="incomingType">
							<xsl:value-of select="substring-after(ep:data-type, 'scalar-')"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="example">
					<xsl:call-template name="deriveExample"/>
				</xsl:variable>
				<xsl:value-of select="concat('&quot;type&quot;: &quot;',$datatype,'&quot;')"/>
				<xsl:value-of select="concat(',&quot;title&quot;: &quot;',ep:parameters/ep:parameter[ep:name='SIM-name']/ep:value,'&quot;')"/>
				<xsl:variable name="documentation">
					<xsl:value-of select="ep:documentation//ep:p"/>
				</xsl:variable>
				<xsl:value-of select="',&quot;description&quot;: &quot;'"/>
				<!-- Double quotes in documentation text is replaced by a  grave accent. -->
				<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
				<xsl:value-of select="'&quot;'"/>
				<xsl:value-of select="$format"/>
				<xsl:value-of select="$facets"/>
				<xsl:value-of select="$example"/>
			</xsl:when>
			<xsl:when test="exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name)">
				<!-- If a construct [B] exists which has a type-name and which tech-name is equal to the type-name of the current construct [A] 
					 a $ref to the construct B has to be generated using the B-type-name. -->
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', /ep:message-sets//ep:construct[ep:tech-name = $typeName]/ep:type-name, '&quot;')"/>
			</xsl:when>
			<!-- In all othert cases a $ref to the type-name of the current construct has to be generated. -->
			<xsl:when test="ep:max-occurs = 'unbounded' or ep:max-occurs > 1">
				<xsl:value-of select="'&quot;type&quot;: &quot;array&quot;,'"/>
				<xsl:value-of select="'&quot;items&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', $typeName, '&quot;')"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/', $typeName, '&quot;')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveDataType">
		<xsl:param name="incomingType"/>
		<xsl:choose>
			<!-- Each scalar type resolves to a type 'string', 'integer', 'number' or 'boolean'. -->
			<xsl:when test="$incomingType = 'date'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'yearmonth'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'dateTime'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'postcode'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'boolean'">
				<xsl:value-of select="'boolean'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'string'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'integer'">
				<xsl:value-of select="'integer'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'decimal'">
				<xsl:value-of select="'number'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'uri'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'txt'">
				<xsl:value-of select="'string'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'string'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveFormat">
		<xsl:param name="incomingType"/>
		<xsl:choose>
			<!-- Some scalar typse resolve to a format and/or pattern. -->
			<xsl:when test="$incomingType = 'date'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date_fullyear&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'yearmonth'">
				<xsl:value-of select="',&quot;format&quot;: &quot;jaarmaand&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'dateTime'">
				<xsl:value-of select="',&quot;format&quot;: &quot;date-time&quot;'"/>
			</xsl:when>
			<xsl:when test="$incomingType = 'uri'">
				<xsl:value-of select="',&quot;format&quot;: &quot;uri&quot;'"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveFacets">
		<xsl:param name="incomingType"/>
		<xsl:choose>
			<!-- Some scalar typse can have one or more facets which restrict the allowed value. -->
			<xsl:when test="$incomingType = 'string'">
				<xsl:if test="ep:pattern and $json-version != '2.0'">
					<xsl:value-of select="concat(',&quot;pattern&quot;: &quot;^',ep:pattern,'$&quot;')"/>
				</xsl:if>
				<xsl:if test="ep:max-length">
					<xsl:value-of select="concat(',&quot;maxLength&quot;: ',ep:max-length)"/>
				</xsl:if>
				<xsl:if test="ep:min-length">
					<xsl:value-of select="concat(',&quot;minLength&quot;: ',ep:min-length)"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$incomingType = 'integer'">
				<xsl:if test="ep:min-value">
					<xsl:value-of select="concat(',&quot;minimum&quot;: ',ep:min-value)"/>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<xsl:value-of select="concat(',&quot;maximum&quot;: ',ep:max-value)"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$incomingType = 'decimal'">
				<xsl:if test="ep:min-value">
					<xsl:value-of select="concat(',&quot;minimum&quot;: ',ep:min-value)"/>
				</xsl:if>
				<xsl:if test="ep:max-value">
					<xsl:value-of select="concat(',&quot;maximum&quot;: ',ep:max-value)"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$incomingType = 'year'">
				<xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-2]{1}[0-9]{3}$&quot;'"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$incomingType = 'yearmonth'">
				<xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-2]{1}[0-9]{3}-^[0-1]{1}[0-9]{1}$&quot;'"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$incomingType = 'postcode'">
				<xsl:if test="$json-version != '2.0'">
					<xsl:value-of select="',&quot;pattern&quot;: &quot;^[1-9]{1}[0-9]{3}[A-Z]{2}$&quot;'"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="deriveExample">
		<xsl:choose>
			<!-- Some scalar typse can have one or more facets which restrict the allowed value. -->
			<xsl:when test="ep:example != ''">
				<xsl:value-of select="concat(',&quot;example&quot;: &quot;',ep:example,'&quot;')"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="_links">
		<!-- This template generates for each association a links properties with a reference to a link type. -->
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value))">
					<xsl:value-of select="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
				</xsl:when>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='targetrole']/ep:value))">
					<xsl:value-of select="ep:parameters/ep:parameter[ep:name='targetrole']/ep:value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="maxOccurs" select="ep:max-occurs"/>
		<xsl:variable name="minOccurs" select="ep:min-occurs"/>
		<xsl:variable name="occurence-type">
			<xsl:choose>
				<xsl:when test="$maxOccurs = 'unbounded' or $maxOccurs > 1">array</xsl:when>
				<xsl:otherwise>object</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>


		<!-- ROME: Deze toevoeging (nav #490159) geeft een warning in Swaggerhub. -->
		<xsl:if test="empty(parent::ep:choice)">
			<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:name,'&quot;,')"/>
		</xsl:if>


		<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
		<xsl:variable name="documentation">
			<xsl:value-of select="ep:documentation//ep:p"/>
			<xsl:if test="$debugging">
				<xsl:value-of select="ep:name"/>
			</xsl:if>
			<xsl:if test="parent::ep:choice">
				<xsl:text>\nLink naar een van de volgende mogelijke typen </xsl:text><xsl:value-of select="$elementName"/><xsl:text>:</xsl:text>
				<xsl:for-each select="../ep:construct">
					<xsl:text>\n* </xsl:text><xsl:value-of select="ep:type-name"/>
				</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="type-name" select="ep:type-name"/>
		<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
		<!-- Double quotes in documentation text is replaced by a  grave accent. -->
		<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
		<xsl:value-of select="'&quot;,'"/>
		<xsl:choose>
			<!-- Depending on the occurence-type and the type of construct content is generated. -->
			<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
				<xsl:if test="$maxOccurs != 'unbounded'">
					<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
				</xsl:if>
				<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
					<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
				</xsl:if>
				<xsl:value-of select="'&quot;items&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/Link&quot;')"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
			<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
				<xsl:value-of select="'&quot;properties&quot;: {'"/>
				<xsl:value-of select="'&quot;href&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/Href&quot;')"/>
				<xsl:value-of select="'}'"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
			<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
				<xsl:if test="$maxOccurs != 'unbounded'">
					<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
				</xsl:if>
				<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
					<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
				</xsl:if>
				<xsl:value-of select="'&quot;items&quot;: {'"/>
				<xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
				<xsl:value-of select="'&quot;description&quot;: &quot;uri van een van de volgende mogelijke typen ',$elementName,': '"/>
				<xsl:apply-templates select="//ep:construct[ep:tech-name = $type-name]" mode="supertype-association-in-links"/>
				<xsl:value-of select="'&quot;,'"/>
				<xsl:value-of select="'&quot;properties&quot;: {'"/>
				<xsl:value-of select="'&quot;href&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/Href&quot;')"/>
				<xsl:value-of select="'}'"/>
				<xsl:value-of select="'}'"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
			<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
				<xsl:value-of select="'&quot;properties&quot;: {'"/>
				<xsl:value-of select="'&quot;href&quot;: {'"/>
				<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/Href&quot;')"/>
				<xsl:value-of select="'}'"/>
				<xsl:value-of select="'}'"/>
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="'}'"/>
		<xsl:if test="position() != last()">
			<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
			<xsl:value-of select="','"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="//ep:construct" mode="supertype-association-in-links">
		<xsl:apply-templates select="ep:choice" mode="supertype-association-in-links"/>
	</xsl:template>
	
	<xsl:template match="ep:choice" mode="supertype-association-in-links">
		<xsl:apply-templates select="//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']" mode="subclass"/>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="subclass">
		<xsl:value-of select="concat('* ',ep:type-name)"/>
		<xsl:if test="position() != last()">
			<xsl:value-of select="' '"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="embedded">
		<!-- This template generates for each association an embedded properties with a reference to an embedded type. -->
		<xsl:variable name="elementName">
			<xsl:choose>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value))">
					<xsl:value-of select="ep:parameters/ep:parameter[ep:name='meervoudigeNaam']/ep:value"/>
				</xsl:when>
				<xsl:when test="not(empty(ep:parameters/ep:parameter[ep:name='targetrole']/ep:value))">
					<xsl:value-of select="ep:parameters/ep:parameter[ep:name='targetrole']/ep:value"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate(ep:tech-name,'.','_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="maxOccurs" select="ep:max-occurs"/>
		<xsl:variable name="minOccurs" select="ep:min-occurs"/>
		<xsl:variable name="occurence-type">
			<xsl:choose>
				<xsl:when test="$maxOccurs = 'unbounded' or $maxOccurs > 1">array</xsl:when>
				<xsl:otherwise>object</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="typeName" select="ep:type-name"/>
		<xsl:value-of select="concat('&quot;',$elementName,'&quot;: {')"/>
		
		<xsl:choose>
			<xsl:when test="$serialisation = 'hal+json'">
		
				<!-- ROME: Deze toevoeging (nav #490159) geeft een warning in Swaggerhub. -->
				<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
					<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:name,'&quot;,')"/>
				</xsl:if>
				
				
				<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
					<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
				</xsl:if>
				<xsl:variable name="documentation">
					<xsl:value-of select="ep:documentation//ep:p"/>
				</xsl:variable>
				<xsl:choose>
					<!-- Depending on the occurence-type and the type of construct content is generated. -->
					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'&quot;')"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
						<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'&quot;')"/>
					</xsl:when>
					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$serialisation = 'json'">
		
				<!-- ROME: Deze toevoeging (nav #490159) geeft een warning in Swaggerhub. -->
				<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
					<xsl:value-of select="concat('&quot;title&quot;: &quot;',ep:name,'&quot;,')"/>
				</xsl:if>
				
				<xsl:if test="not($occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='association')">
					<xsl:value-of select="concat('&quot;type&quot;: &quot;',$occurence-type,'&quot;,')"/>
				</xsl:if>
				<xsl:variable name="documentation">
					<xsl:value-of select="ep:documentation//ep:p"/>
				</xsl:variable>
				<xsl:choose>
					<!-- Depending on the occurence-type and the type of construct content is generated. -->
					<xsl:when test="$occurence-type = 'array' and (ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
						<xsl:value-of select="'&quot;format&quot;: &quot;uri&quot;'"/>
						<xsl:value-of select="'},'"/>
						<xsl:value-of select="'&quot;readOnly&quot;: true,'"/>
						<xsl:value-of select="'&quot;uniqueItems&quot;: true'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and (ep:parameters/ep:parameter[ep:name='type']/ep:value ='association' or ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association')">
						<xsl:value-of select="'&quot;type&quot;: &quot;string&quot;,'"/>
						<xsl:value-of select="'&quot;format&quot;: &quot;uri&quot;,'"/>
						<xsl:value-of select="'&quot;readOnly&quot;: true'"/>
					</xsl:when>
<?x					<xsl:when test="$occurence-type = 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:if test="$maxOccurs != 'unbounded'">
							<xsl:value-of select="concat('&quot;maxItems&quot;: ',$maxOccurs,',')"/>
						</xsl:if>
						<xsl:if test="not(empty($minOccurs)) and $minOccurs != 0 ">
							<xsl:value-of select="concat('&quot;minItems&quot;: ',$minOccurs,',')"/>
						</xsl:if>
						<xsl:value-of select="'&quot;items&quot;: {'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
						<xsl:value-of select="'}'"/>
					</xsl:when>
					<xsl:when test="$occurence-type != 'array' and ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
						<xsl:value-of select="'&quot;description&quot;: &quot;'"/>
						<!-- Double quotes in documentation text is replaced by a  grave accent. -->
						<xsl:value-of select="normalize-space(translate($documentation,'&quot;','&#96;'))"/>
						<xsl:value-of select="'&quot;,'"/>
						<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
					</xsl:when> ?>
				</xsl:choose>
					
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="'}'"/>
		<xsl:if test="position() != last()">
			<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
			<xsl:value-of select="','"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ep:construct" mode="embeddedchoices">
		<!-- This template generates for each association an embedded properties with a reference to an embedded type. -->
		<xsl:variable name="typeName" select="ep:type-name"/>
		<xsl:choose>
			<!-- Depending on the occurence-type and the type of construct content is generated. -->
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value ='association'">
				<xsl:value-of select="'{'"/>
					<xsl:value-of select="concat('&quot;$ref&quot;: &quot;',$json-topstructure,'/',$typeName,'&quot;')"/>
				<xsl:value-of select="'}'"/>
				<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="ep:parameters/ep:parameter[ep:name='type']/ep:value ='supertype-association'">
				<xsl:value-of select="'{'"/>
					<xsl:apply-templates select="//ep:construct[ep:tech-name = $typeName]" mode="supertype-association-in-embedded"/>
				<xsl:value-of select="'}'"/>
				<xsl:if test="position() != last()">
					<!-- As long as the current construct isn't the last association type construct a comma separator has to be generated. -->
					<xsl:value-of select="','"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="//ep:construct" mode="supertype-association-in-embedded">
		<xsl:apply-templates select="ep:choice" mode="supertype-association-in-embedded"/>
	</xsl:template>
	
	<xsl:template match="ep:choice" mode="supertype-association-in-embedded">
		<xsl:value-of select="'&quot;oneOf&quot; : ['"/>
		<xsl:apply-templates select="//ep:construct[ep:parameters/ep:parameter[ep:name='type']/ep:value='subclass']" mode="subclass-embedded"/>
		<xsl:value-of select="']'"/>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="subclass-embedded">
		<xsl:value-of select="concat('{ &quot;$ref&quot; : &quot;',$json-topstructure,'/',ep:type-name,'&quot; }')"/>
		<xsl:if test="position() != last()">
			<xsl:value-of select="','"/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
