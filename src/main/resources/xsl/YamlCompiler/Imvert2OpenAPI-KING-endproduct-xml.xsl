<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $ 
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:UML="omg.org/UML1.3"

	xmlns:imvert="http://www.imvertor.org/schema/system" 
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
	xmlns:ep="http://www.imvertor.org/schema/endproduct" 
	xmlns:math="http://exslt.org/math"
	xmlns:html="http://www.w3.org/1999/xhtml"
	
	version="2.0">

	<xsl:import href="../common/Imvert-common.xsl" />
	
	<!--TODO: Kijken of de volgende imports en include nog wel nodig zijn. -->
	<xsl:import href="../common/Imvert-common-validation.xsl" />
	<xsl:import href="../common/extension/Imvert-common-text.xsl" />
	<xsl:import href="../common/Imvert-common-derivation.xsl" />
	<xsl:import href="../common/Imvert-common-external.xsl"/>
	<xsl:import href="../XsdCompiler/Imvert2XSD-KING-common.xsl" />

	<xsl:include href="../XsdCompiler/Imvert2XSD-KING-common-checksum.xsl" />

	<xsl:param name="processable-base-file"/> <!-- this is embellish, or any derived (optimized) variant thereof -->
	
	<xsl:output indent="yes" method="xml" encoding="UTF-8" />

	<xsl:key name="enumerationClass" match="imvert:class[imvert:stereotype/@id='stereotype-name-enumeration']" use="imvert:name" />
	<xsl:key name="dataTypeClass" match="imvert:class[imvert:stereotype/@id='stereotype-name-simpletype']" use="imvert:name"/>
	
	<xsl:variable name="stylesheet-code" as="xs:string">OAS</xsl:variable>
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean" />

	<xsl:variable name="stylesheet" as="xs:string">Imvert2XSD-KING-OpenAPI-endproduct-xml</xsl:variable>
	<xsl:variable name="stylesheet-version" as="xs:string">
			$Id: Imvert2XSD-KING-OpenAPI-endproduct-xml.xsl 
			2025-03-27 10:14:00Z Robert Melskens $</xsl:variable>

	<xsl:variable name="messages" select="imf:document($processable-base-file)" />
	<xsl:variable name="packages" select="$messages/imvert:packages" />
	<xsl:variable name="kv-prefix" select="imf:get-tagged-value($packages,'##CFG-TV-VERKORTEALIAS')"/>
	<xsl:variable name="kv-definition">
		<xsl:if test="not(empty(imf:get-tagged-value($packages,'##CFG-TV-DEFINITION')))">
			<ep:definition>
				<xsl:for-each select="$packages/imvert:tagged-values/imvert:tagged-value[@id='CFG-TV-DEFINITION']/imvert:value/html:body/html:p">
					<ep:p format="{$packages/imvert:tagged-values/imvert:tagged-value[@id='CFG-TV-DEFINITION']/imvert:value/@format}" level="BSM">
						<xsl:value-of select="."/>
					</ep:p>
					<xsl:if test="following-sibling::html:p">
						<ep:p format="{$packages/imvert:tagged-values/imvert:tagged-value[@id='CFG-TV-DEFINITION']/imvert:value/@format}" level="BSM"/>
					</xsl:if>
				</xsl:for-each>
			</ep:definition>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="project-url">
		<xsl:choose>
			<xsl:when test="not($packages/imvert:stereotype/@id = ('stereotype-name-application-package'))">
				<xsl:sequence select="imf:msg(.,'ERROR', 'Unable to create endproduct for a package that is not stereotyped as &quot;[1]&quot;.', (imf:string-group(imf:get-config-name-by-id('stereotype-name-application-package'))))" />
				<!-- test only applies to koppelvlak-->	
			</xsl:when>
			<xsl:when test="string-length(imf:get-tagged-value($packages,'##CFG-TV-PROJECT-URL')) != 0">
				<xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-PROJECT-URL')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="imf:msg(.,'WARNING', 'No tagged value project_url has been defined on the interface, define one.')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="kv-administrator-e-mail" select="imf:get-tagged-value($packages,'##CFG-TV-E-MAIL-KV-ADMINISTRATOR')"/>
	<xsl:variable name="kv-serialisation">
		<xsl:choose>
			<xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-SERIALISATION'))">
				<xsl:sequence select="imf:msg(.,'WARNING','For an Open API interface a serialisation must be defined. Define one using the tv Serialisatie.')" />
				<xsl:value-of select="'hal+json'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-SERIALISATION')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="description-level">
		<xsl:choose>
			<xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-INSERTDESCRIPTIONFROM'))">
				<xsl:value-of select="'SIM'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-INSERTDESCRIPTIONFROM')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="version" select="$packages/imvert:version"/>
	
	<xsl:variable name="imvert-document" select="if (exists($messages/imvert:packages)) then $messages else ()" />

	<!-- needed for disambiguation of duplicate attribute names -->
	<xsl:variable name="all-simpletype-attributes" select="$packages//imvert:attribute[empty(imvert:type)]" />

	<xsl:variable name="endproduct">
		<xsl:apply-templates select="/ep:rough-messages" />
	</xsl:variable>
	
	<xsl:variable name="expandconfigurations">
		<!-- Within this variable for each message it's determined if the expand paramater is applicable. -->
		<ep:expandconfiguration>
			<xsl:for-each select="/ep:rough-messages/ep:rough-message[@messagetype='response']">
				<ep:message messagetype="{@messagetype}" berichtcode="{@berichtcode}">
					<ep:name><xsl:value-of select="ep:name"/></ep:name>
					<xsl:choose>
						<xsl:when test=".//ep:construct[@type = 'association']//ep:contains-non-id-attributes = 'true' and $kv-serialisation = 'hal+json'">
							<ep:expand>true</ep:expand>
						</xsl:when>
						<xsl:otherwise>
							<ep:expand>false</ep:expand>
						</xsl:otherwise>
					</xsl:choose>
				</ep:message>
			</xsl:for-each>
		</ep:expandconfiguration>
	</xsl:variable>
	
	<xsl:template match="ep:rough-messages">
		<!-- This template starts the creation of the message constructs and the constructs related to those message constructs. -->
		<xsl:sequence select="imf:set-config-string('appinfo','OpenAPI-schema-name',concat($kv-prefix,$version))"/>

		<xsl:if test="$debugging">
			<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/message/expandconfiguration.xml')}" method="xml">
				<xsl:copy-of select="$expandconfigurations" />
			</xsl:result-document>
		</xsl:if>
		
		<xsl:for-each select="//ep:construct[@xor]">
			<xsl:variable name="xorId" select="@xor"/>
			<xsl:variable name="naam" select="ep:name"/>
			<xsl:variable name="id" select="ep:id"/>
			<xsl:variable name="this" select="$packages//imvert:association[imvert:id = $id]"/>
			<xsl:variable name="minOccurs" select="$this/imvert:min-occurs"/>
			<xsl:variable name="maxOccurs" select="$this/imvert:max-occurs"/>
			<xsl:for-each select="following-sibling::ep:construct[@xor = $xorId]">
				<xsl:if test="ep:name != $naam">
					<xsl:sequence select="imf:msg($this,'WARNING','The associations name [1] is not equal to the name of the other association(s) within the related xor constraint.', ($naam))" />
				</xsl:if>
				<xsl:variable name="idNextConstruct" select="ep:id"/>
				<xsl:variable name="nextConstruct" select="$packages//imvert:association[imvert:id = $idNextConstruct]"/>
				<xsl:variable name="minOccursNextConstruct" select="$nextConstruct/imvert:min-occurs"/>
				<xsl:variable name="maxOccursNextConstruct" select="$nextConstruct/imvert:max-occurs"/>
				<xsl:if test="$minOccurs != $minOccursNextConstruct or $maxOccurs != $maxOccursNextConstruct">
					<xsl:sequence select="imf:msg($this,'WARNING','The cardinality of the association [1] is not equal to the cardinality of other association(s) within the related xor constraint.', ($naam))" />
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
		
		<ep:message-sets>
			<!-- The ep:message-sets element contains the metadata for the complete interface and of-course the actual message-set. -->
			<ep:parameters>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'project-url')" />
					<xsl:sequence select="imf:create-output-element('ep:value', $project-url)" />
				</ep:parameter>
				<xsl:if test="$kv-administrator-e-mail!=''">
					<ep:parameter>
						<xsl:sequence select="imf:create-output-element('ep:name', 'administrator-e-mail')" />
						<xsl:sequence select="imf:create-output-element('ep:value', $kv-administrator-e-mail)" />
					</ep:parameter>
				</xsl:if>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'serialisation')" />
					<xsl:sequence select="imf:create-output-element('ep:value', $kv-serialisation)" />
				</ep:parameter>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'imvertor-generator-version')" />
					<xsl:sequence select="imf:create-output-element('ep:value', ep:imvertor-generator-version)" />
				</ep:parameter>
			</ep:parameters>
			<ep:name><xsl:value-of select="ep:name"/></ep:name>
			<ep:message-set>
				<!-- The ep:message-set element contains the messages of the interface. 
					 It's possible to have more than one ep:message-set elements but for Open API interfaces only one ep:message-set 
					 element is present. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS00500',$debugging,.)" />

				<xsl:sequence select="imf:create-output-element('ep:name', $packages/imvert:application)" />
				<xsl:sequence select="imf:create-output-element('ep:release', $packages/imvert:release)" />
				<xsl:sequence select="imf:create-output-element('ep:date', substring-before($packages/imvert:generated,'T'))" />
				<xsl:sequence select="imf:create-output-element('ep:patch-number', $version)" />
				<xsl:sequence select="imf:create-output-element('ep:documentation', $kv-definition,'',false(),false())" />

				<xsl:sequence select="imf:track('Constructing the OpenAPI message constructs')" />

				<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS01000',$debugging,.)" />
				<!-- Start the processing of each ep:rough-message element. -->
				<xsl:apply-templates select="ep:rough-message" />

				<xsl:sequence select="imf:track('Constructing the constructs related to the OpenAPI messages')" />
				<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS01500',$debugging,.)" />

				<!-- CREATING GLOBAL CONSTRUCTS
					 Each class can be refered to several times and so appear on more than one location within the rough-message structure.
					 However each class must only appear once as a global ep:construct. 
					 This is achieved by processing these classes (type by type) with the following for-each-group instructions. -->
				<xsl:for-each-group 
					select="//ep:superconstruct"
					group-by="ep:name">
					<!-- This for-each-group processes al superconstructs within the rough-message structure. -->
					<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS02000',$debugging,.)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('Berichtcode=',$berichtcode),$debugging,.)" />
					<xsl:apply-templates select="current-group()[1]" mode="as-global-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS02250',$debugging,.)" />
				<xsl:for-each-group 
					select="//ep:construct[@type!='complex-datatype' and @type!='groep' and @type!='table-datatype' and @type!='groepCompositieAssociation']"
					group-by="ep:name">
					<!-- This for-each-group processes al constructs within the rough-message structure which are not of 'complex-datatype', 'groep'
						 'table-datatype' or 'groepCompositieAssociation' type. Those type of constructs, except the groepCompositieAssociation' 
						 type which doesn't lead to global constructs at all, are processed after this for-each-group. -->
					<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS02500',$debugging,.)" />
					<xsl:sequence select="imf:create-debug-comment(concat('Groupname: ',ep:name),$debugging)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<xsl:apply-templates select="current-group()[1]" mode="as-global-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS03000',$debugging,.)" />
				<xsl:for-each-group 
					select="//ep:construct[@type='complex-datatype' or @type='groep']"
					group-by="ep:type-id">
					<!-- This for-each-group processes al constructs within the rough-message structure which are of 'complex-datatype' or 'groep' type. -->
					<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS035000',$debugging,.)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<xsl:apply-templates select="current-group()[1]" mode="as-global-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS03500',$debugging,.)" />
				<xsl:for-each-group 
					select="//ep:construct[@type='table-datatype']"
					group-by="ep:type-id">
					<!-- This for-each-group processes al constructs within the rough-message structure which are of 'table-datatype' type. -->
					<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS035500',$debugging,.)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<xsl:apply-templates select="current-group()[1]" mode="as-global-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
				
				<!-- Following apply creates all global ep:constructs elements containing enumeration lists. -->
				<xsl:apply-templates select="$packages//imvert:package[not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]/
                                             imvert:class[imf:get-stereotype(.) = ('stereotype-name-enumeration') and generate-id(.) = 
                                             generate-id(key('enumerationClass',imvert:name,$packages)[1])]" mode="as-global-enumeration" />
				<!-- Following apply creates all global ep:constructs elements being a local datatype. -->
				<xsl:apply-templates select="$packages//imvert:package[not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]/
					imvert:class[imf:get-stereotype(.) = ('stereotype-name-simpletype') and generate-id(.) = 
					generate-id(key('dataTypeClass',imvert:name,$packages)[1])]" mode="as-global-dataType" />
			</ep:message-set>
		</ep:message-sets>
	</xsl:template>

	<!-- Takes care of processing individual ep:rough-message elements to ep:message elements. -->
	<xsl:template match="ep:rough-message">
		<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS04000',$debugging,.)" />

		<xsl:variable name="id" select="ep:id" as="xs:string" />

		<!-- TODO: De eerste variabele geeft om de eoa reden geen resultaat daarom is de tweede variabele geintroduceerd. 
				   Nagaan waarom dat zo is en de werking van de eerste herstellen zodat de tweede kan komen te vervallen. -->
		<xsl:variable name="message-construct" select="imf:get-class-construct-by-id($id,$packages)" />
		<xsl:variable name="this-construct" select="$packages//imvert:*[imvert:id = $id]" />
		<xsl:variable name="doc">
			<xsl:if
				test="not(empty(imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DEFINITION',$description-level)))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DEFINITION',$description-level)" />
				</ep:definition>
			</xsl:if>
			<xsl:if
				test="not(empty(imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DESCRIPTION',$description-level)))">
				<ep:description>
					<xsl:if test="$debugging">
						<xsl:attribute name="level" select="$description-level"/>
					</xsl:if>
					<xsl:sequence select="imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DESCRIPTION',$description-level)" />
				</ep:description>
			</xsl:if>
			<xsl:if
				test="not(empty(imf:get-most-relevant-compiled-taggedvalue($this-construct, '##CFG-TV-PATTERN')))">
				<ep:pattern>
					<ep:p>
						<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($this-construct, '##CFG-TV-PATTERN')" />
					</ep:p>
				</ep:pattern>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="berichtcode" select="@berichtcode" />
		<xsl:variable name="messageCategory" select="substring($berichtcode,1,2)"/>
		<xsl:variable name="messagetype" select="@messagetype" />
		<xsl:sequence select="imf:create-debug-comment($berichtcode,$debugging)" />

		<xsl:variable name="name" select="ep:name" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(ep:name, 'element-name')" as="xs:string" />
		<xsl:variable name="expand">
			<xsl:value-of select="$expandconfigurations//ep:message[ep:name=$name and @berichtcode=$berichtcode]/ep:expand"/>
		</xsl:variable>
		
		<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS04500',$debugging,.)" />

		<ep:message>
			<xsl:choose>
				<xsl:when test="(contains($berichtcode,'Gr') or contains($berichtcode,'Gc'))">
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messageCategory')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messageCategory)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" />
						</ep:parameter>
						<xsl:if test="$messagetype = 'request'">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'tag')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @tag)" />
							</ep:parameter>
						</xsl:if>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'expand')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $expand)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'grouping')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @grouping)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'pagination')" />
							<xsl:choose>
								<xsl:when test="@pagination = 'true' and $kv-serialisation = 'hal+json'">
									<xsl:sequence select="imf:create-output-element('ep:value', @pagination)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
								</xsl:otherwise>
							</xsl:choose>
						</ep:parameter>
						<xsl:if test="$messagetype = 'request' and @fields">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'fields')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @fields)" />
							</ep:parameter>
						</xsl:if>
						<xsl:if test="$messagetype = 'request' and @sort">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'sort')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @sort)" />
							</ep:parameter>
						</xsl:if>
						<xsl:if test="@customPathFacet and @customPathFacet!=''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'customPathFacet')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @customPathFacet)" />
							</ep:parameter>
						</xsl:if>
						<ep:parameter> 
							<xsl:sequence select="imf:create-output-element('ep:name', 'operationId')" />
							<xsl:choose>
								<xsl:when test="@operationId = '' and $messageCategory = 'Gr'"><xsl:sequence select="imf:create-output-element('ep:value', concat('getresource',$tech-name))" /></xsl:when>
								<xsl:when test="@operationId = '' and $messageCategory = 'Gc'"><xsl:sequence select="imf:create-output-element('ep:value', concat('getcollection',$tech-name))" /></xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="imf:create-output-element('ep:value', @operationId)" />
								</xsl:otherwise>
							</xsl:choose>
						</ep:parameter>
					</ep:parameters>
				</xsl:when>
				<!-- ROME: Zijn er nog meer attributen van toepassing op een POST bericht. -->
				<xsl:when test="contains($berichtcode,'Pa') or contains($berichtcode,'Po') or contains($berichtcode,'Pu')">
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messageCategory')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messageCategory)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" />
						</ep:parameter>
						<xsl:if test="$messagetype = 'request'">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'tag')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @tag)" />
							</ep:parameter>
						</xsl:if>
						<xsl:if test="@customPathFacet and @customPathFacet!=''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'customPathFacet')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @customPathFacet)" />
							</ep:parameter>
						</xsl:if>
						<ep:parameter> 
							<xsl:sequence select="imf:create-output-element('ep:name', 'operationId')" />
							<xsl:choose>
								<xsl:when test="@operationId = '' and $messageCategory = 'Pa'"><xsl:sequence select="imf:create-output-element('ep:value', concat('patch',$tech-name))" /></xsl:when>
								<xsl:when test="@operationId = '' and $messageCategory = 'Po'"><xsl:sequence select="imf:create-output-element('ep:value', concat('post',$tech-name))" /></xsl:when>
								<xsl:when test="@operationId = '' and $messageCategory = 'Pu'"><xsl:sequence select="imf:create-output-element('ep:value', concat('put',$tech-name))" /></xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="imf:create-output-element('ep:value', @operationId)" />
								</xsl:otherwise>
							</xsl:choose>
						</ep:parameter>
					</ep:parameters>
				</xsl:when>
				<xsl:when test="contains($berichtcode,'De')">
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messageCategory')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messageCategory)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" />
						</ep:parameter>
						<xsl:if test="$messagetype = 'request'">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'tag')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @tag)" />
							</ep:parameter>
						</xsl:if>
						<xsl:if test="@customPathFacet and @customPathFacet!=''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'customPathFacet')" />
								<xsl:sequence select="imf:create-output-element('ep:value', @customPathFacet)" />
							</ep:parameter>
						</xsl:if>
						<ep:parameter> 
							<xsl:sequence select="imf:create-output-element('ep:name', 'operationId')" />
							<xsl:choose>
								<xsl:when test="@operationId = '' and $messageCategory = 'De'"><xsl:sequence select="imf:create-output-element('ep:value', concat('delete',$tech-name))" /></xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="imf:create-output-element('ep:value', @operationId)" />
								</xsl:otherwise>
							</xsl:choose>
						</ep:parameter>
					</ep:parameters>
				</xsl:when>
			</xsl:choose>
			<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
			<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
			<xsl:choose>
				<xsl:when test="(empty($doc) or $doc='') and $debugging">
					<xsl:call-template name="documentationUnknown"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test=".//ep:construct">
				<!-- If the rough-message has an ep:construct element, which actually should always be the case, the following template 
					 will be applied. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS05000',$debugging,.)" />
				<ep:seq>
					<!-- Within the template call the cardinality params get the value '-' to express cardinality is of no importance 
						 in this situation. -->
					<xsl:apply-templates select="ep:construct" mode="as-local-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
						<xsl:with-param name="minOccurs" select="'-'" />
						<xsl:with-param name="maxOccurs" select="'-'" />
					</xsl:apply-templates>
				</ep:seq>
			</xsl:if>
		</ep:message>
	</xsl:template>

	<xsl:template match="ep:construct" mode="as-local-type">
		<!-- This template is applicable if the ep:construct element has to be processed as content of another ep:construct element 
			 not if it has to processed as a global ep:construct element. -->
		<xsl:param name="berichtcode" />
		<xsl:param name="messagetype"/>
		<xsl:param name="minOccurs" />
		<xsl:param name="maxOccurs" />

		<xsl:sequence select="imf:create-debug-comment-with-xpath('Debuglocation OAS05500',$debugging,.)" />

		<xsl:variable name="name" select="ep:name" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(ep:tech-name, 'element-name')" as="xs:string" />

		<!-- Sometimes we like to process the imvert construct which has a reference to a class and sometime the class itself. 
			 For that reason the 'id' variable sometimes gets the value of the imvert:id element of the association, sometimes of the attribute 
			 and sometimes of the class. -->
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="ep:id and @type = ('association','groepCompositie','association-class')">
					<xsl:value-of select="ep:id" />
				</xsl:when>
				<xsl:when test="ep:id-refering-association and @type = 'class'">
					<xsl:value-of select="ep:id-refering-association" />
				</xsl:when>
				<xsl:when test="ep:id-refering-association and @type = 'requestclass'">
					<xsl:value-of select="ep:id-refering-association" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'class'">
					<xsl:variable name="id" select="ep:id" />
					<xsl:value-of select="$packages//imvert:association[imvert:type-id = $id][1]/imvert:id" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'subclass'">
					<xsl:value-of select="ep:id" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'attribute'">
					<xsl:variable name="id" select="ep:id" />
					<xsl:value-of select="$packages//imvert:attribute[imvert:type-id = $id][1]/imvert:id" />
				</xsl:when>
				<xsl:when test="ep:type-id and (@type = 'complex-datatype' or @type = 'groep' or @type = 'table-datatype')">
					<xsl:variable name="type-id" select="ep:type-id" />
					<xsl:value-of select="$packages//imvert:attribute[imvert:name = $name and imvert:type-id = $type-id][not(following::imvert:attribute[imvert:name = $name and imvert:type-id = $type-id])]/imvert:id" />				
				</xsl:when>
				<xsl:when test="ep:type-id">
					<xsl:variable name="type-id" select="ep:type-id" />
					<xsl:value-of select="$packages//imvert:association[imvert:type-id = $type-id]/imvert:id" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- It's not possible to get debug information which is set into a variable into the output so we do this outside the variable. 
			 The 'when' statements catch the same situations as the when statements in the variable above. -->
		<xsl:if test="$debugging">
			<xsl:choose>
				<xsl:when test="ep:id and @type = 'association'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS06000, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'groepCompositie'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS06500, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'association-class'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS07000, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:id-refering-association and @type = 'class'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS07500, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:id-refering-association and @type = 'requestclass'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS08000, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'class'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS08500, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'subclass'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS09000, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'attribute'">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS09500, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:type-id and (@type = 'complex-datatype' or @type = 'table-datatype')">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS10000, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:when test="ep:type-id">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS10500, id: ',$id),$debugging,.)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS10700, id: ',$id),$debugging,.)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<!-- The construct variable holds the imvert construct which has an imvert:id equal to the 'id' variable. 
			 So sometimes it's an attribute, sometimes an association and sometimes a class. -->
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
        <xsl:variable name="doc">
        	<xsl:if test="not(empty($construct))">
        		<xsl:if test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)))">
	            	<!-- Contains the textual content of the 'notes' field. -->
	                <ep:definition>
	                    <xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)"/>
	                </ep:definition>
	            </xsl:if>
        		<xsl:if test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)))">
        			<!-- Contains the textual content of the tagged value 'Toelichting'. -->
        			<ep:description>
	                	<xsl:if test="$debugging">
	                		<xsl:attribute name="level" select="$description-level"/>
	                	</xsl:if>
	                	<xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)"/>
	                </ep:description>
	            </xsl:if>
	            <xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')))">
	            	<!-- Contains the textual content of the tagged value 'Patroon'. -->
	            	<ep:pattern>
	                    <ep:p>
	                        <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')"/>
	                    </ep:p>
	                </ep:pattern>
	            </xsl:if>
        	</xsl:if>
        </xsl:variable>

		<xsl:choose>
			<xsl:when test="@type='association-class'">
				<!-- If the current ep:construct is an association-class no ep:construct element is generated. All attributes of that 
					 related class are directly placed within the current ep:construct. Also the child ep:superconstructs and 
					 ep:constructs (if present) are processed. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11010, id: ',$id),$debugging,.)" />
				<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
				<xsl:apply-templates select="ep:superconstruct" mode="as-ref" />
				<xsl:apply-templates select="ep:construct" mode="as-local-type">
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
			</xsl:when>
<?x			<xsl:when test="((@type='complex-datatype' or @type='groep') and $construct//imvert:name != 'NEN3610ID')">
				<!-- If the current ep:construct is a complex-datatype or groep type a ep:construct element is generated 
					 with all necessary properties, except when its name is NEN3610ID. In that case no reference to a complex-datatype or groep is created. -->
				<xsl:variable name="type-id" select="ep:type-id" />
				<xsl:variable name="id" select="ep:id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="attributeconstruct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				<xsl:variable name="is-id" select="$attributeconstruct/imvert:is-id"/>
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11020, id: ',$id),$debugging,.)" />
				<ep:construct>
					<ep:parameters>
						<xsl:choose>
							<xsl:when test="$is-id = 'true'">
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
									<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
								</ep:parameter>
							</xsl:when>
							<xsl:otherwise>
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
									<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
								</ep:parameter>
							</xsl:otherwise>
						</xsl:choose>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
					</ep:parameters>
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11500, id: ',$id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($type-name,'type-name'))" />
				</ep:construct>
			</xsl:when> ?>
			
			<!-- Als de volgende 2 when takken het probleem oplossen waarbij er teveel gegevensgroepen worden verwerkt dan mag de bovenstaande 
				 when (in de processing instruction) worden verwijderd. -->
			<xsl:when test="@type='groep'"/>
			<xsl:when test="@type='complex-datatype' and $construct//imvert:name != 'NEN3610ID'">
				<!-- If the current ep:construct is a complex-datatype or groep type a ep:construct element is generated 
					 with all necessary properties, except when its name is NEN3610ID. In that case no reference to a complex-datatype or groep is created. -->
				<xsl:variable name="type-id" select="ep:type-id" />
				<xsl:variable name="id" select="ep:id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="attributeconstruct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				<xsl:variable name="is-id" select="$attributeconstruct/imvert:is-id"/>
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11020, id: ',$id),$debugging,.)" />
				<ep:construct>
					<ep:parameters>
						<xsl:choose>
							<xsl:when test="$is-id = 'true'">
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
									<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
								</ep:parameter>
							</xsl:when>
							<xsl:otherwise>
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
									<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
								</ep:parameter>
							</xsl:otherwise>
						</xsl:choose>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
					</ep:parameters>
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11500, id: ',$id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($type-name,'type-name'))" />
				</ep:construct>
			</xsl:when>
			<xsl:when test="@type='table-datatype'">
				<!-- If the current ep:construct is a table-datatype an ep:construct element is generated 
					 with all necessary properties. -->
				<xsl:variable name="type-id" select="ep:type-id" />
				<xsl:variable name="id" select="ep:id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="attributeconstruct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				<xsl:variable name="is-id" select="$attributeconstruct/imvert:is-id"/>
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11030, id: ',$id),$debugging,.)" />
				<ep:construct>
					<ep:parameters>
						<xsl:choose>
							<xsl:when test="$is-id = 'true'">
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
									<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
								</ep:parameter>
							</xsl:when>
							<xsl:otherwise>
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
									<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
								</ep:parameter>
							</xsl:otherwise>
						</xsl:choose>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" />
						</ep:parameter>
						<xsl:choose>
							<xsl:when test="count($classconstruct//imvert:attribute) = 1">
								<xsl:apply-templates select="$classconstruct//imvert:attributes/imvert:attribute"  mode="onlyParameters"/>
							</xsl:when>
							<xsl:otherwise>
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
									<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
								</ep:parameter>
							</xsl:otherwise>
						</xsl:choose>
					</ep:parameters>
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11550, id: ',$id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
					<xsl:choose>
						<xsl:when test="count($classconstruct//imvert:attribute) = 1">
							<xsl:apply-templates select="$classconstruct//imvert:attributes/imvert:attribute"  mode="onlyFacets">
								<xsl:with-param name="min-Occurs" select="$construct/imvert:min-occurs"/>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($type-name,'type-name'))" />
						</xsl:otherwise>
					</xsl:choose>
				</ep:construct>
			</xsl:when>
			<xsl:when test="@type='association'">

				<xsl:variable name="SIM-supplier" select="imf:get-trace-suppliers-for-construct($construct,1)[@project='SIM'][1]" />
				<xsl:variable name="SIM-construct" select="if ($SIM-supplier) then imf:get-trace-construct-by-supplier($SIM-supplier,$imvert-document) else ()" />
				<xsl:variable name="SIM-name" select="($SIM-construct/imvert:name, imvert:name)[1]" />
				
				<!-- If the current ep:construct is an association an ep:construct element is generated with all necessary properties. 
					 This when statement differs from the one above by the value of the ep:name and ep:tech-name. -->
				<xsl:variable name="type-id" select="ep:type-id" />
				<!-- If the current construct is an association it is linked to a class. In that case that class is put within the variable 
					 'classconstruct'.  -->
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="type-name">
					<xsl:choose>
						<xsl:when test="ep:construct[@type='subclass']">
							<xsl:value-of select="concat($classconstruct/imvert:name,'-association')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$classconstruct/imvert:name"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="meervoudigeNaam">
					<xsl:sequence select="imf:getMeervoudigeNaam($construct,'association',ancestor::ep:rough-message/ep:name)"/>
				</xsl:variable> 
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11040, id: ',$id),$debugging,.)" />
				<xsl:sequence select="imf:create-debug-comment('At this level the expand attribute is neccessary to determine if an _embedded property has to be created. This is only the case if the attribute has the value true.',$debugging)" />
				<xsl:sequence select="imf:create-debug-comment(concat('Meervoudige naam: ',$meervoudigeNaam),$debugging)" />

				<ep:construct>
					<xsl:variable name="contains-non-id-attributes">
						<xsl:if test="ep:construct[@type='subclass']">
							<xsl:for-each select="ep:construct[@type='subclass']">
								<xsl:choose>
									<xsl:when test="ep:contains-non-id-attributes = 'true'">
										<xsl:text>#true</xsl:text>
									</xsl:when>
									<xsl:when test="contains(imf:checkSuperclassesOnId(./ep:superconstruct[@type='superclass']),'#true')">
										<xsl:text>#true</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>#false</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:sequence select="imf:checkSuperclassesOnId(./ep:superconstruct[@type='superclass'])"/>
							</xsl:for-each>
						</xsl:if>
						<xsl:for-each select="ep:construct[@type='class']">
							<xsl:choose>
								<xsl:when test="ep:contains-non-id-attributes = 'true'">
									<xsl:text>#true</xsl:text>
								</xsl:when>
								<xsl:when test="ep:superconstruct[@type='superclass' and ep:contains-non-id-attributes='true']">
									<xsl:text>#true</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>#false</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:variable>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:choose>
								<xsl:when test="ep:construct[@type='subclass']">
									<xsl:sequence select="imf:create-output-element('ep:value', concat('supertype-',@type))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
								</xsl:otherwise>
							</xsl:choose>
						</ep:parameter>
						<xsl:if test="contains($contains-non-id-attributes,'#true')">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'contains-non-id-attributes')" />
								<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
							</ep:parameter>
						</xsl:if>
						<xsl:if test="$meervoudigeNaam!=''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'meervoudigeNaam')" />
								<xsl:sequence select="imf:create-output-element('ep:value', $meervoudigeNaam)" />
							</ep:parameter>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$SIM-name != ''">
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'SIM-name')" />
									<xsl:sequence select="imf:create-output-element('ep:value', $SIM-name)" />
								</ep:parameter>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="imf:msg(.,'WARNING','It wasn&quot;t possible to retrieve the SIM-name of the construct [1].', ($construct/imvert:name))" />
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if
							test="imf:get-tagged-value($construct,'##CFG-TV-POSITION')">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'position')" />
								<xsl:sequence select="imf:create-output-element('ep:value', $construct/imvert:position)" />
							</ep:parameter>
						</xsl:if>
					</ep:parameters>
					
					<xsl:sequence select="imf:create-debug-comment(concat('Result check on id attributes: ',$contains-non-id-attributes),$debugging)" />
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS12000, id: ',$id),$debugging,.)" />

					<xsl:sequence select="imf:create-output-element('ep:name', $construct/imvert:name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($construct/imvert:name, 'element-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($type-name, 'type-name'))" />
				</ep:construct>
			</xsl:when>
			<xsl:when test="@type='groepCompositieAssociation'">
				<!-- If the current ep:construct is an association to a groepcompositie the groepcompositie construct is processed.  -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11050, id: ',$id),$debugging,.)" />
				<xsl:apply-templates select="ep:construct" mode="as-local-type">
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="@type='groepCompositie'">
				<!-- If the current ep:construct is a groepcompositie an ep:construct element is generated with a reference to a type and
					 as its name the name of the refering groep compositie relation.  -->
				<xsl:variable name="id" select="ep:id" />
				<xsl:variable name="id-refering-association" select="ep:id-refering-association" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="refering-associationclassconstruct" select="imf:get-construct-by-id($id-refering-association,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />


				<xsl:variable name="groupname">
					<xsl:choose>
						<xsl:when test="string-length(imf:get-most-relevant-compiled-taggedvalue($classconstruct, '##CFG-TV-GROUPNAME')) != 0">
							<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-GROUPNAME')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="../ep:tech-name"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11060, id: ',$id),$debugging,.)" />
				<ep:construct>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
					</ep:parameters>
					
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS12500, id: ',$id),$debugging,.)" />
					
					<xsl:sequence select="imf:create-output-element('ep:name', ../ep:name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $groupname)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $refering-associationclassconstruct/imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $refering-associationclassconstruct/imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($type-name,'type-name'))" />
				</ep:construct>
			</xsl:when>
			<xsl:when test="@type = 'subclass'">
				<!-- If the current ep:construct is a subclass an ep:construct element is generated with all neccessary properties.  -->
				<xsl:variable name="meervoudigeNaam">
					<xsl:sequence select="imf:getMeervoudigeNaam($construct,'entiteit',ancestor::ep:rough-message/ep:name)"/>
				</xsl:variable> 
				
				<xsl:variable name="type-id" select="ep:id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				<xsl:variable name="abstract">
					<xsl:choose>
						<xsl:when test="$classconstruct/imvert:abstract = 'true'">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="SIM-supplier" select="imf:get-trace-suppliers-for-construct($construct,1)[@project='SIM'][1]" />
				<xsl:variable name="SIM-construct" select="if ($SIM-supplier) then imf:get-trace-construct-by-supplier($SIM-supplier,$imvert-document) else ()" />
				<xsl:variable name="SIM-name" select="($SIM-construct/imvert:name, imvert:name)[1]" />
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11070, id: ',$id),$debugging,.)" />
				<ep:construct>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
						<xsl:if test="$meervoudigeNaam!=''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'meervoudigeNaam')" />
								<xsl:sequence select="imf:create-output-element('ep:value', $meervoudigeNaam)" />
							</ep:parameter>
						</xsl:if>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'abstract')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $abstract)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'SIM-name')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $SIM-name)" />
						</ep:parameter>
					</ep:parameters>

					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS13000, id: ',$id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($type-name,'type-name'))" />
				</ep:construct>
			</xsl:when>
			<xsl:when test="parent::ep:rough-message">
				<!-- If the construct is the top-level construct within a message (so it's the highest level entiteiten class within the message) 
					 all neccessary properties are generated but no meervoudigeNaam attribute. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11080, id: ',$id),$debugging,.)" />
				<xsl:variable name="typeid" select="$construct/imvert:type-id" />
				<ep:construct>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
					</ep:parameters>

					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS132500, id: ',$id),$debugging,.)" />

					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					
					<!-- ROME: Het lijkt er op dat de eerste when altijd van toepassing is. Indien dat het geval is 
							   kan de choose worden verwijderd. Voor nu is hij uitgeschakeld. -->
<?x					<xsl:choose>
						<xsl:when test="$construct//imvert:name = 'response' or $construct//imvert:name = 'request'">
							<ep:tst1/>
						</xsl:when>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<ep:tst2/>
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<ep:tst3/>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose> ?>
					<!-- Depending on the type the min- and max-occurs are set or aren't set at all. -->
					<!-- ROME: Het lijkt er op dat de eerste when altijd van toepassing is. Indien dat het geval is 
							   kan de choose worden verwijderd. Voor nu is hiij uitgeschakeld. -->
<?x					<xsl:choose>
						<xsl:when test="$minOccurs = '-'">
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS14000, id: ',$id),$debugging,.)" />
						</xsl:when>
						<xsl:when test="not($minOccurs = '')">
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS14500, id: ',$id),$debugging,.)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $minOccurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $maxOccurs)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS15000, id: ',$id),$debugging,.)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
						</xsl:otherwise>
					</xsl:choose> ?>
					<xsl:variable name="type-id" select="ep:id" />
					<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
					<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
					
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($classconstruct/imvert:name,'type-name'))" />
				</ep:construct>
			</xsl:when>
			<xsl:otherwise>
				<!-- In all other cases this option applies. -->
				<xsl:variable name="typeid" select="$construct/imvert:type-id" />
				<xsl:variable name="meervoudigeNaam">
					<xsl:sequence select="imf:getMeervoudigeNaam($construct,'entiteit',ancestor::ep:rough-message/ep:name)"/>
				</xsl:variable> 
				<xsl:variable name="abstract">
					<xsl:choose>
						<xsl:when test="$construct/imvert:abstract = 'true'">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS11090, id: ',$id),$debugging,.)" />
				<ep:construct>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
						<xsl:if test="$meervoudigeNaam!=''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'meervoudigeNaam')" />
								<xsl:sequence select="imf:create-output-element('ep:value', $meervoudigeNaam)" />
							</ep:parameter>
						</xsl:if>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'abstract')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $abstract)" />
						</ep:parameter>
					</ep:parameters>
					
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS16000, id: ',$id),$debugging,.)" />
					
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<!-- Depending on the type the min- and max-occurs are set or aren't set at all. -->
					<!-- ROME: Het lijkt er op dat de eerste when altijd van toepassing is. Indien dat het geval is 
							   kan de choose worden verwijderd. Voor nu is hij uitgeschakeld. -->
<?x					<xsl:choose>
						<xsl:when test="$minOccurs = '-'">
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS16500, id: ',$id),$debugging,.)" />
						</xsl:when>
						<xsl:when test="not($minOccurs = '')">
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS17000, id: ',$id),$debugging,.)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $minOccurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $maxOccurs)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS17500, id: ',$id),$debugging,.)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
						</xsl:otherwise>
					</xsl:choose> ?>
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($tech-name,'type-name'))" />
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ep:superconstruct" mode="as-ref">
		<!-- This template is applicable if the ep:superconstruct element has to be processed as content of another ep:construct element. 
			 In that case a siimple construct is generated with an ep:ref element refering to the global construct representing the 
			 superconstruct. -->
		
		<xsl:variable name="id" select="ep:id" />
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name($construct/imvert:name, 'type-name')" as="xs:string" />
		
		<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS18000, id: ',$id),$debugging,.)" />

		<ep:construct>
			<ep:name><xsl:value-of select="$construct/imvert:name/@original"/></ep:name>
			<ep:tech-name><xsl:value-of select="$construct/imvert:name"/></ep:tech-name>
			<ep:ref><xsl:value-of select="$tech-name"/></ep:ref>
		</ep:construct>

	</xsl:template>

	<xsl:template match="ep:superconstruct" mode="as-global-type">
		<!-- This template is applicable if the ep:superconstruct element has to be processed as a global ep:construct element. -->
		<xsl:param name="berichtcode"/>
		<xsl:param name="messagetype"/>
		
		<xsl:variable name="id" select="ep:id" />
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name($construct/imvert:name, 'type-name')" as="xs:string" />
		<xsl:variable name="abstract">
			<xsl:choose>
				<xsl:when test="$construct/imvert:abstract = 'true'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)"/>
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)))">
				<ep:description>
					<xsl:if test="$debugging">
						<xsl:attribute name="level" select="$description-level"/>
					</xsl:if>
					<xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)"/>
				</ep:description>
			</xsl:if>
			<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')))">
				<ep:pattern>
					<ep:p>
						<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')"/>
					</ep:p>
				</ep:pattern>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="name" select="ancestor::ep:rough-message/ep:name"/>
		<xsl:variable name="expand">
			<xsl:value-of select="$expandconfigurations//ep:message[ep:name=$name and @berichtcode=$berichtcode and @messagetype=$messagetype]/ep:expand"/>
		</xsl:variable>

		<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS18500, id: ',$id,', ',$name),$debugging,.)" />
		
		<ep:construct>
			<ep:parameters>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
					<xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" />
				</ep:parameter>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
					<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
				</ep:parameter>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
					<xsl:sequence select="imf:create-output-element('ep:value', 'superclass')" />
				</ep:parameter>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'expand')" />
					<xsl:sequence select="imf:create-output-element('ep:value', $expand)" />
				</ep:parameter>
				<xsl:if test="$construct/imvert:abstract='true'">
					<ep:parameter>
						<xsl:sequence select="imf:create-output-element('ep:name', 'abstract')" />
						<xsl:sequence select="imf:create-output-element('ep:value', ' true')" />
					</ep:parameter>
				</xsl:if>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'abstract')" />
					<xsl:sequence select="imf:create-output-element('ep:value', $abstract)" />
				</ep:parameter>
			</ep:parameters>
			
			<ep:name><xsl:value-of select="$construct/imvert:name/@original"/></ep:name>
			<ep:tech-name><xsl:value-of select="$tech-name"/></ep:tech-name>
			<xsl:choose>
				<xsl:when test="(empty($doc) or $doc='') and $debugging">
					<xsl:call-template name="documentationUnknown"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
				</xsl:otherwise>
			</xsl:choose>
			<ep:seq>
				<!-- Superconstructs can contain attributes, can themself be derived from a supercontruct and can have association constructs.
					 They are processed here. -->
				<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
				<xsl:apply-templates select="ep:superconstruct" mode="as-ref">
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
				
				<xsl:for-each-group select="ep:construct[@xor]" group-by="@xor">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS18520, tech-name: ',ep:tech-name),$debugging,.)" />
					<xsl:call-template name="constraint">
						<xsl:with-param name="constraintType" select="'xor'"/>
					</xsl:call-template>
				</xsl:for-each-group>
				<xsl:for-each-group select="ep:construct[@or]" group-by="@or">
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS18540, tech-name: ',ep:tech-name),$debugging,.)" />
					<xsl:call-template name="constraint">
						<xsl:with-param name="constraintType" select="'or'"/>
					</xsl:call-template>
				</xsl:for-each-group>
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS18560, tech-name: ',ep:tech-name),$debugging,.)" />
				<xsl:apply-templates select="ep:construct[empty(@xor) and empty(@or)]" mode="as-local-type" >
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
			</ep:seq>
		</ep:construct>
	</xsl:template>
	
	<xsl:template name="constraint">
		<xsl:param name="constraintType"/>
		<ep:choice>
			<ep:parameters>
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'constraintType')" />
					<xsl:sequence select="imf:create-output-element('ep:value', $constraintType)" />					
				</ep:parameter>
			</ep:parameters>
			<xsl:apply-templates select="current-group()" mode="as-local-type"/>
		</ep:choice>
	</xsl:template>
	
	<xsl:template match="ep:construct" mode="as-global-type">
		<!-- This template is applicable if the ep:construct element has to be processed as a global ep:construct element. -->
		<xsl:param name="berichtcode"/>
		<xsl:param name="messagetype"/>

		<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS19000, tech-name: ',ep:tech-name),$debugging,.)" />
		
		<xsl:variable name="name" select="ep:name" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(ep:tech-name, 'element-name')" as="xs:string" />
		<xsl:variable name="id" select="ep:id" />
		<xsl:variable name="type-id" select="ep:type-id" />
		<xsl:variable name="construct" as="element()">
			<xsl:choose>
				<xsl:when test="not(empty($type-id))">
					<xsl:sequence select="imf:get-construct-by-id($type-id,$packages)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:get-construct-by-id($id,$packages)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="empty($id) and empty($type-id)">
				<xsl:sequence select="imf:msg(.,'WARNING','The construct [1] doesn&quot;t have an id and type-id.', ($name))" />
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
		<xsl:variable name="doc">
			<xsl:choose>
				<xsl:when test="not(empty($type-id))">
					<xsl:variable name="this-construct" select="$packages//imvert:*[imvert:id = $type-id]" />
					<xsl:if test="not(empty(imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DEFINITION',$description-level)))">
						<ep:definition>
							<xsl:sequence select="imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DEFINITION',$description-level)" />
						</ep:definition>
					</xsl:if>
					<xsl:if test="not(empty(imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DESCRIPTION',$description-level)))">
						<ep:description>
							<xsl:if test="$debugging">
								<xsl:attribute name="max-level" select="$description-level"/>
							</xsl:if>
							<xsl:sequence select="imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DESCRIPTION',$description-level)" />
						</ep:description>
					</xsl:if>
					<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue($this-construct, '##CFG-TV-PATTERN')))">
						<ep:pattern>
							<ep:p>
								<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($this-construct, '##CFG-TV-PATTERN')" />
							</ep:p>
						</ep:pattern>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="this-construct" select="$packages//imvert:*[imvert:id = $id]" />
					<xsl:if test="not(empty(imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DEFINITION',$description-level)))">
						<ep:definition>
							<xsl:sequence select="imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DEFINITION',$description-level)" />
						</ep:definition>
					</xsl:if>
					<xsl:if test="not(empty(imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DESCRIPTION',$description-level)))">
						<ep:description>
							<xsl:if test="$debugging">
								<xsl:attribute name="level" select="$description-level"/>
							</xsl:if>
							<xsl:sequence select="imf:merge-documentation-up-to-level($this-construct,'CFG-TV-DESCRIPTION',$description-level)" />
						</ep:description>
					</xsl:if>
					<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue($this-construct, '##CFG-TV-PATTERN')))">
						<ep:pattern>
							<ep:p>
								<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($this-construct, '##CFG-TV-PATTERN')" />
							</ep:p>
						</ep:pattern>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@type='association-class'">
				<!-- ep:constructs of type 'association-class' aren't processed at all. 
				 The content of that kind of constructs will be embedded within its parents constructs in another template. -->
			</xsl:when>
			<xsl:when test="@type='association' and ep:construct[@type='subclass']">
				<!-- When an association refers to a supertype its subtypes will be part of a choice.
					 This construction is taken care of here. This construction might become invalid in the near future.
					 Because of that this when might be disabled. -->
				<xsl:variable name="type-id" select="ep:type-id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				<xsl:variable name="messagename" select="ancestor::ep:rough-message/ep:name"/>
				<xsl:variable name="expand">
					<xsl:value-of select="$expandconfigurations//ep:message[ep:name=$messagename and @berichtcode=$berichtcode and @messagetype=$messagetype]/ep:expand"/>
				</xsl:variable>
				
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS19250, id: ',$id),$debugging,.)" />
				<ep:construct>
					<xsl:variable name="meervoudigeNaam">
						<xsl:sequence select="imf:getMeervoudigeNaam($construct,'entiteit',$messagename)"/>
					</xsl:variable> 
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							
							<xsl:variable name="berichtcodes" select="//ep:rough-message[@messagetype = $messagetype and .//ep:construct/ep:name=$name]/@berichtcode"/>
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcodes)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
						<xsl:if test="$meervoudigeNaam != ''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'meervoudigeNaam')" />
								<xsl:sequence select="imf:create-output-element('ep:value', $meervoudigeNaam)" />
							</ep:parameter>
						</xsl:if>
					</ep:parameters>
					<xsl:sequence select="imf:create-output-element('ep:name', $type-name/@original)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(concat($type-name,'-association'), 'type-name'))" />
					
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:choice>
						<ep:parameters>
							<ep:parameter>
								<ep:name>constraintType</ep:name>
								<ep:value>xor</ep:value>
							</ep:parameter>
						</ep:parameters>
						<xsl:apply-templates select="ep:construct" mode="as-local-type" />
					</ep:choice>
				</ep:construct>
				
			</xsl:when>
			<xsl:when test="@type='association'">
					<!-- The association construct refering to a class construct doesn't have to be reproduced itself
					 since in most cases (relations to groups are the exception) relation aren't represented within json. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS20000, id: ',$id),$debugging,.)" />
			</xsl:when>
			<xsl:when test="@type = 'groepCompositie'">
				<!-- if the ep:constructs is of 'groepCompositie' a global construct is generated. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS22500, id: ',$id),$debugging,.)" />
				<xsl:variable name="type" select="@type" />
				<xsl:variable name="complex-datatype-tech-name" select="$construct/imvert:name" />
				<xsl:copy>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />

							<xsl:variable name="berichtcodes" select="//ep:rough-message[@messagetype = $messagetype and .//ep:construct/ep:name=$name]/@berichtcode"/>
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcodes)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', @type)" />
						</ep:parameter>
					</ep:parameters>
					<xsl:sequence select="imf:create-output-element('ep:name', $complex-datatype-tech-name/@original)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($complex-datatype-tech-name,'type-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:seq>
						<!-- Within the groep all its attributes are adopted.
							 Also eventual associated constructs are processed. -->
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS23000, id: ',$id),$debugging,.)" />
						<xsl:sequence select="imf:create-debug-comment(concat('Type-id: ',$type-id),$debugging)" />
						<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS23500, id: ',$id),$debugging,.)" />
						<xsl:apply-templates select="ep:construct[@type!='class']" mode="as-local-type" >
							<xsl:with-param name="berichtcode" select="$berichtcode"/>
							<xsl:with-param name="messagetype" select="$messagetype"/>
						</xsl:apply-templates>
						
						<!-- TODO: Nagaan of er in een complex-datatype type ep:construct geen associations voor kunnen komen. 
							 Indien dat wel het geval is dan moet hier ook een apply-templates komen op een ep:construct en moet ook het rough-messages stylesheets 
							 daar rekening mee houden. -->
					</ep:seq>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="@type = 'complex-datatype' and $construct/imvert:name = 'NEN3610ID'">
				<!-- if the ep:constructs is of 'complex-datatype' type and it's type-name is 'NEN3610ID' it's ignored and
					 doesn't have to be reproduced. There will be refered to a standard json component. -->
			</xsl:when>
			<xsl:when test="@type = 'complex-datatype' or @type = 'groep'">
				<!-- if the ep:constructs is of 'complex-datatype' or 'groep' type its name differs from the one in the 5th when above. 
					 It's name isn't based on the attribute using the type since it is more generic and used by more than one ep:construct.
					 Also it's attributes and -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS27000, id: ',$id),$debugging,.)" />
				<xsl:variable name="type" select="@type" />
				<xsl:variable name="complex-datatype-tech-name" select="$construct/imvert:name" />
				<xsl:copy>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />

							<xsl:variable name="berichtcodes" select="//ep:rough-message[@messagetype = $messagetype and .//ep:construct/ep:name=$name]/@berichtcode"/>
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcodes)" />

							<!--xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" /-->
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $type)" />
						</ep:parameter>
					</ep:parameters>
					<xsl:sequence select="imf:create-output-element('ep:name', $complex-datatype-tech-name/@original)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($complex-datatype-tech-name,'type-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:seq>
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS27500, id: ',$id),$debugging,.)" />
						<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS27700, id: ',$id),$debugging,.)" />
						<xsl:apply-templates select="ep:construct" mode="as-local-type" />
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS28000, id: ',$id),$debugging,.)" />
						<xsl:apply-templates select="ep:superconstruct" mode="as-ref" />

						<!-- TODO: Nagaan of er in een complex-datatype en groep types ep:construct associations voor kunnen komen. 
							 Indien dat wel het geval is dan moet hier ook een apply-templates komen op een ep:construct en moet ook het 
							 rough-messages stylesheets daar rekening mee houden. Ook is de vraag of complex-datatypes en groep types supertypes kunnen hebben. 
							 Indien dit beide niet het geval is en hetzelfde geldt voor table-datatypes dan kunnen beide when's samengevoegd worden. -->
					</ep:seq>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="@type = 'table-datatype'">
				<!-- if the ep:constructs is of 'table-datatype' type its name differs from the one in the when above. 
					 It's name isn't based on the attribute using the type since it is more generic and used by more than one ep:construct. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS28100, id: ',$id),$debugging,.)" />
				<xsl:variable name="type" select="@type" />
				<xsl:variable name="complex-datatype-tech-name" select="$construct/imvert:name" />
				<xsl:copy>
					<ep:parameters>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />

							<xsl:variable name="berichtcodes" select="//ep:rough-message[@messagetype = $messagetype and .//ep:construct/ep:name=$name]/@berichtcode"/>
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcodes)" />

							<!--xsl:sequence select="imf:create-output-element('ep:value', $berichtcode)" /-->
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $type)" />
						</ep:parameter>
					</ep:parameters>
					<xsl:sequence select="imf:create-output-element('ep:name', $complex-datatype-tech-name/@original)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($complex-datatype-tech-name,'type-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:seq>
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS28200, id: ',$id),$debugging,.)" />
						<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
						
						<!-- TODO: Nagaan of er in een table-datatype type ep:construct associations voor kunnen komen. 
							 Indien dat wel het geval is dan moet hier ook een apply-templates komen op een ep:construct en moet ook het 
							 rough-messages stylesheets daar rekening mee houden. Ook is de vraag of table-datatypes supertypes kunnen hebben. 
							 Indien dit beide niet het geval is en hetzelfde geldt voor complex-datatypes dan kunnen beide when's samengevoegd worden. -->
					</ep:seq>
				</xsl:copy>
			</xsl:when>
			<xsl:when test="ep:construct or ep:superconstruct or @type='class' or @type='requestclass'">
				<!-- if the ep:constructs itself has a ep:construct or ep:superconstruct or if it is of type 'class' or 'requestclass' 
					 it is processed here. 
					 The ep:construct is replicated and in case of 'class','requestclass' type ep:constructs for imvert:attributes related to 
					 that construct are placed. 
					 Also the child ep:superconstructs and ep:constructs (if present) are processed. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS24500, id: ',$id),$debugging,.)" />
				<xsl:variable name="classconstruct">
					<xsl:if test="$type-id != ''">
						<xsl:sequence select="imf:get-construct-by-id($type-id,$packages)"/>
					</xsl:if>
				</xsl:variable>
				<xsl:variable name="abstract">
					<xsl:choose>
						<xsl:when test="$classconstruct/imvert:abstract = 'true'">true</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="type">
					<xsl:choose>
						<xsl:when test="@type = 'subclass'">
							<xsl:value-of select="'class'" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@type" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="messagename" select="ancestor::ep:rough-message/ep:name"/>
				<xsl:variable name="expand">
					<xsl:value-of select="$expandconfigurations//ep:message[ep:name=$messagename and @berichtcode=$berichtcode and @messagetype=$messagetype]/ep:expand"/>
				</xsl:variable>
				<xsl:variable name="id">
					<xsl:value-of select="ep:id"/>
				</xsl:variable>
				<xsl:variable name="node-id">
					<xsl:value-of select="generate-id()"/>
				</xsl:variable>
				
				<xsl:copy>
					<!-- Wellicht kan de onderstaande variabele weg. $construct wordt immers al eerder gegenereerd. Enige verschil is dat deze daar mogelijk ook gevuld kan worden
						 op basis van type-id en hier altijd op basis van id. -->
					<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
					<!-- the variable 'endpointavailable' is important when serialisation is 'json'. In that case only Entiteittype classes result in a schema component when they are a fundamental of an endpoint.
						 If an Entiteittype class is only present as the target of an association no schema component is generated. 
						 To be sure no Entiteitype class which is a fundamental of an endpoint is excluded in plain json because it is also present as the target of an association the first when clause is created. -->
					<xsl:variable name="endpointavailable">
						<xsl:choose>
							<xsl:when test="$kv-serialisation = 'json' and (parent::ep:rough-message or //ep:construct[generate-id()!=$node-id and parent::ep:rough-message and ep:id=$id])">
								<xsl:value-of select="'Ja'"/>								
							</xsl:when>
							<xsl:when test="$kv-serialisation = 'json'">
								<xsl:value-of select="'Nee'"/>								
							</xsl:when>
							<xsl:when test="not(empty(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-ENDPOINTAVAILABLE')))">
								<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-ENDPOINTAVAILABLE')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'Ja'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<ep:parameters>
						<xsl:if test="ep:superconstruct[@type='superclass' and ep:contains-non-id-attributes='true']">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'contains-non-id-attributes')" />
								<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
							</ep:parameter>
						</xsl:if>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'berichtcode')" />
							
							<xsl:variable name="berichtcodes" select="//ep:rough-message[@messagetype = $messagetype and .//ep:construct/ep:name=$name]/@berichtcode"/>
							<xsl:sequence select="imf:create-output-element('ep:value', $berichtcodes)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'messagetype')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $messagetype)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $type)" />
						</ep:parameter>
						<xsl:if test="$expand != ''">
							<ep:parameter>
								<xsl:sequence select="imf:create-output-element('ep:name', 'expand')" />
								<xsl:sequence select="imf:create-output-element('ep:value', $expand)" />
							</ep:parameter>
						</xsl:if>
						<xsl:if test="not(@type='groepCompositie') and not(ancestor::ep:*[@type='groepCompositie'])">
							<xsl:variable name="meervoudigeNaam">
								<xsl:sequence select="imf:getMeervoudigeNaam($construct,'entiteit',$messagename)"/>
							</xsl:variable> 
							<xsl:if test="$meervoudigeNaam != ''">
								<ep:parameter>
									<xsl:sequence select="imf:create-output-element('ep:name', 'meervoudigeNaam')" />
									<xsl:sequence select="imf:create-output-element('ep:value', $meervoudigeNaam)" />
								</ep:parameter>
							</xsl:if>
						</xsl:if>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'abstract')" />
							<xsl:sequence select="imf:create-output-element('ep:value', $abstract)" />
						</ep:parameter>
						<ep:parameter>
							<xsl:variable name="tvs">
								<xsl:sequence select="imf:get-compiled-tagged-values($construct,false())"/>
							</xsl:variable>
							<ep:name>endpointavailable</ep:name>
							<xsl:sequence select="imf:create-output-element('ep:value', $endpointavailable)" />
						</ep:parameter>
					</ep:parameters>
					
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<!--xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($classconstruct/imvert:name, 'type-name'))" /-->
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($construct/imvert:name, 'type-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:seq>
						<xsl:if test="$type=('class','requestclass')">
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS25000, id: ',$id),$debugging,.)" />
							<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
						</xsl:if>
						<xsl:if test="$type='groep'">
							<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS25250, id: ',$id),$debugging,.)" />
							<xsl:apply-templates select="$classconstruct//imvert:attributes/imvert:attribute" />
						</xsl:if>
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS25500, id: ',$id),$debugging,.)" />
						<xsl:apply-templates select="ep:superconstruct" mode="as-ref" />
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS26000, id: ',$id),$debugging,.)" />
						<xsl:for-each-group select="ep:construct[@xor and @type!='class']" group-by="@xor">
							<xsl:call-template name="constraint">
								<xsl:with-param name="constraintType" select="'xor'"/>
							</xsl:call-template>
						</xsl:for-each-group>
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS26150, id: ',$id),$debugging,.)" />
						<xsl:for-each-group select="ep:construct[@or and @type!='class']" group-by="@or">
							<xsl:call-template name="constraint">
								<xsl:with-param name="constraintType" select="'or'"/>
							</xsl:call-template>
						</xsl:for-each-group>
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS26300, id: ',$id),$debugging,.)" />
						<xsl:apply-templates select="ep:construct[empty(@xor) and empty(@or) and @type!='class']" mode="as-local-type" >
							<xsl:with-param name="berichtcode" select="$berichtcode"/>
							<xsl:with-param name="messagetype" select="$messagetype"/>
						</xsl:apply-templates>
						<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS26500, id: ',$id),$debugging,.)" />
					</ep:seq>
				</xsl:copy>
			</xsl:when>
			
		</xsl:choose>
	</xsl:template>

	<xsl:template match="imvert:attribute">
		<!-- Some of the imvert:attribute elements found in the classes refered to are processed here.
			 Not all because imvert:attribute elements having a stereotype of 'stereotype-name-complextype' and 
			 'stereotype-name-referentielijst' are processed in the ep:construct template with mode="as-local-type". -->
		<xsl:variable name="name" select="imvert:name/@original" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(imvert:name, 'element-name')" as="xs:string" />
		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
		<xsl:variable name="type-is-GM-external" select="(exists(imvert:conceptual-schema-type) and contains(imvert:conceptual-schema-type,'GM_')) or contains(imvert:baretype,'GM_')"/>		
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)" />
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)))">
				<ep:description>
					<xsl:if test="$debugging">
						<xsl:attribute name="level" select="$description-level"/>
					</xsl:if>
					<xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)" />
				</ep:description>
			</xsl:if>
			<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')))">
				<ep:pattern>
					<ep:p>
						<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')" />
					</ep:p>
				</ep:pattern>
			</xsl:if>
		</xsl:variable>

		<xsl:if test="$debugging">
			<xsl:if test="not(empty($construct))">
				<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/message/Attribute-',$tech-name,'-',generate-id(),'.xml')}" method="xml">
					<vals>
						<xsl:if
							test="not(empty(imf:get-specific-compiled-tagged-values-up-to-level-debug($construct,'CFG-TV-DEFINITION',$description-level)))">
							<definition>
								<xsl:sequence select="imf:get-specific-compiled-tagged-values-up-to-level-debug($construct,'CFG-TV-DEFINITION',$description-level)" />
							</definition>
						</xsl:if>
						<xsl:if
							test="not(empty(imf:get-specific-compiled-tagged-values-up-to-level-debug($construct,'CFG-TV-DESCRIPTION',$description-level)))">
							<description>
								<xsl:sequence select="imf:get-specific-compiled-tagged-values-up-to-level-debug($construct,'CFG-TV-DESCRIPTION',$description-level)" />
							</description>
						</xsl:if>
					</vals>
				</xsl:result-document>
			</xsl:if>
		</xsl:if>
		
		
		<!-- ROME: T.b.v. foutdetectie. -->
		<!--xsl:variable name="example" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-EXAMPLE')" /-->

		<!--xsl:variable name="SIM-supplier" select="imf:get-trace-suppliers-for-construct(.,1)[@project='SIM'][1]" />
		<xsl:variable name="SIM-construct" select="if ($SIM-supplier) then imf:get-trace-construct-by-supplier($SIM-supplier,$imvert-document) else ()" />
		<xsl:variable name="SIM-name" select="($SIM-construct/imvert:name, imvert:name)[1]" /-->
		

		<!--xsl:variable name="suppliers" as="element(ep:suppliers)">
			<ep:suppliers>
				<xsl:copy-of select="imf:get-UGM-suppliers(.)" />
			</ep:suppliers>
		</xsl:variable>
		<xsl:variable name="tvs" as="element(ep:tagged-values)">
			<ep:tagged-values>
				<xsl:copy-of select="imf:get-compiled-tagged-values(., true())" />
			</ep:tagged-values>
		</xsl:variable-->

		<xsl:choose>
			<xsl:when test="imvert:type-package = ('VNGR','VNG-GENERIEK')">
				<ep:construct>
					<ep:parameters>
						<xsl:call-template name="attributeParameters"/>
					</ep:parameters>
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name(imvert:type-name-oas,'type-name'))" />
					<xsl:sequence select="imf:create-output-element('ep:outside-ref', imvert:type-package)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
				</ep:construct>
			</xsl:when>
			<xsl:when test="imvert:type-name = 'NEN3610ID'">
				<ep:construct>
					<ep:parameters>
						<xsl:call-template name="attributeParameters"/>
					</ep:parameters>
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS28300, id: ',imvert:id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:call-template name="attributeFacets">
						<xsl:with-param name="min-Occurs" select="imvert:min-occurs"/>
					</xsl:call-template>
				</ep:construct>
			</xsl:when>
			<xsl:when test="$type-is-GM-external">
				<!-- If the attribute is a gml type attribute no reference to a type is neccessary since all these types are processed 
					 the same way. -->
				<ep:construct>
					<ep:parameters>
						<xsl:call-template name="attributeParameters"/>
					</ep:parameters>
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS28500, id: ',imvert:id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					
					<!-- ROME: Ik vraag me af of de volgende choose nog wel noodzakelijk is. In het geval van GMtypes wordt er nu immers een $ref geplaatst naar 
						 'https://raw.githubusercontent.com/VNG-Realisatie/Bevragingen-ingeschreven-personen/master/api-specificatie/geojson.yaml#/GeoJSONGeometry'.
						 De documentatie die hier gegenereerd wordt heeft dus geen toepassing volgens mij. -->
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:call-template name="attributeFacets">
						<xsl:with-param name="min-Occurs" select="imvert:min-occurs"/>
						<xsl:with-param name="type-is-GM-external" select="$type-is-GM-external"/>
					</xsl:call-template>
				</ep:construct>
			</xsl:when>
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]/imvert:id">
				<!-- Attributes of complex datatype type are not resolved within this template but with one of the ep:construct templates since 
					 they are present within the rough message structure. -->
				<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS29000, id: ',imvert:id),$debugging,.)" />
			</xsl:when>
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]/imvert:id">
				<ep:construct>
					<ep:parameters>
						<xsl:call-template name="attributeParameters"/>
					</ep:parameters>
					
					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS29500, id: ',imvert:id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:call-template name="attributeFacets">
						<xsl:with-param name="min-Occurs" select="imvert:min-occurs"/>
					</xsl:call-template>
				</ep:construct>
			</xsl:when>
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]/imvert:id">
				<!-- The content of ep:constructs based on attributes which refer to a tabelentiteit is determined by the imvert:attribute in 
					 that tabelentiteit class which serves as a unique key. So it gets all properties of the table entity with that unique key. -->
			</xsl:when>
			<xsl:when test="imvert:type-id">
				<!-- imvert:attributes having an imvert:type-id result in an ep:construct which refers to a global ep:construct. This is for 
					 example the case when it's an attribute with a enumeration type. -->
				<ep:construct>
					<ep:parameters>
						<xsl:call-template name="attributeParameters"/>
					</ep:parameters>

					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS30000, id: ',imvert:id),$debugging,.)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:call-template name="attributeFacets">
						<xsl:with-param name="min-Occurs" select="imvert:min-occurs"/>
					</xsl:call-template>
				</ep:construct>
			</xsl:when>
			<xsl:otherwise>
				<!-- In all other cases the imvert:attribute itself and its properties are processed. -->
				<ep:construct>
					<ep:parameters>
						<xsl:call-template name="attributeParameters"/>
					</ep:parameters>

					<xsl:sequence select="imf:create-debug-comment-with-xpath(concat('OAS30500, id: ',imvert:id),$debugging,.)" />
<?x					<xsl:if test="$debugging">
						<ep:suppliers>
							<xsl:copy-of select="$suppliers" />
						</ep:suppliers>
						<ep:tagged-values>
							<xsl:copy-of select="$tvs" />
							<ep:found-tagged-values>
								<xsl:choose>
									<xsl:when test="(empty($doc) or $doc='') and $debugging">
										<xsl:call-template name="documentationUnknown"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
									</xsl:otherwise>
								</xsl:choose>
							</ep:found-tagged-values>
						</ep:tagged-values>
					</xsl:if> ?>


					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:call-template name="documentationUnknown"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:call-template name="attributeFacets">
						<xsl:with-param name="min-Occurs" select="imvert:min-occurs"/>
					</xsl:call-template>
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="imvert:attribute" mode="onlyParameters">
		<!-- If a table, refered to by an attribute, only has 1 attribute the facets of that attribute are used to build the properties of the attribute refering.
			 In that case no ref to a table is generated and ep:parameters have to be generated based on the tables attribute. -->
		
		<xsl:call-template name="attributeParameters"/>
	</xsl:template>
	
	<xsl:template name="attributeParameters">
		
		<xsl:variable name="is-id" select="imvert:is-id"/>
		<xsl:variable name="SIM-supplier" select="imf:get-trace-suppliers-for-construct(.,1)[@project='SIM'][1]" />
		<xsl:variable name="SIM-construct" select="if ($SIM-supplier) then imf:get-trace-construct-by-supplier($SIM-supplier,$imvert-document) else ()" />
		<xsl:variable name="SIM-name" select="($SIM-construct/imvert:name, imvert:name)[1]" />
		<xsl:variable name="type-is-GM-external" select="(exists(imvert:conceptual-schema-type) and contains(imvert:conceptual-schema-type,'GM_')) or contains(imvert:baretype,'GM_')"/>		
		
		<xsl:choose>
			<xsl:when test="imvert:type-name = 'NEN3610ID'">
				<xsl:choose>
					<xsl:when test="$is-id = 'true'">
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
						</ep:parameter>
					</xsl:when>
					<xsl:otherwise>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
						</ep:parameter>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$SIM-name != ''">
					<ep:parameter>
						<xsl:sequence select="imf:create-output-element('ep:name', 'SIM-name')" />
						<xsl:sequence select="imf:create-output-element('ep:value', $SIM-name)" />
					</ep:parameter>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$type-is-GM-external">
				<!-- If the attribute is a gml type attribute no reference to a type is neccessary since all these types are processed 
					 the same way. -->
				<ep:parameter>
					<xsl:sequence select="imf:create-output-element('ep:name', 'type')" />
					<xsl:sequence select="imf:create-output-element('ep:value', 'GM-external')" />
				</ep:parameter>
				<xsl:choose>
					<xsl:when test="$is-id = 'true'">
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
						</ep:parameter>
					</xsl:when>
					<xsl:otherwise>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
						</ep:parameter>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$SIM-name != ''">
					<ep:parameter>
						<xsl:sequence select="imf:create-output-element('ep:name', 'SIM-name')" />
						<xsl:sequence select="imf:create-output-element('ep:value', $SIM-name)" />
					</ep:parameter>
				</xsl:if>
			</xsl:when>
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]/imvert:id"/>
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]/imvert:id"/>
			<xsl:when test="imvert:type-id">
				<!-- imvert:attributes having an imvert:type-id result in an ep:construct which refers to a global ep:construct. This is for 
					 example the case when it's an attribute with a enumeration type. -->
				<xsl:choose>
					<xsl:when test="$is-id = 'true'">
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
						</ep:parameter>
					</xsl:when>
					<xsl:otherwise>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
						</ep:parameter>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$SIM-name != ''">
					<ep:parameter>
						<xsl:sequence select="imf:create-output-element('ep:name', 'SIM-name')" />
						<xsl:sequence select="imf:create-output-element('ep:value', $SIM-name)" />
					</ep:parameter>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- In all other cases the imvert:attribute itself and its properties are processed. -->
				<xsl:choose>
					<xsl:when test="$is-id = 'true'">
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'true')" />
						</ep:parameter>
					</xsl:when>
					<xsl:otherwise>
						<ep:parameter>
							<xsl:sequence select="imf:create-output-element('ep:name', 'is-id')" />
							<xsl:sequence select="imf:create-output-element('ep:value', 'false')" />
						</ep:parameter>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$SIM-name != ''">
					<ep:parameter>
						<xsl:sequence select="imf:create-output-element('ep:name', 'SIM-name')" />
						<xsl:sequence select="imf:create-output-element('ep:value', $SIM-name)" />
					</ep:parameter>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if
			test="imf:get-tagged-value(.,'##CFG-TV-POSITION')">
			<ep:parameter>
				<xsl:sequence select="imf:create-output-element('ep:name', 'position')" />
				<xsl:sequence select="imf:create-output-element('ep:value', imvert:position)" />
			</ep:parameter>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="imvert:attribute" mode="onlyFacets">
		<xsl:param name="min-Occurs"/>
		<!-- If a table, refered to by an attribute, only has 1 attribute the facets of that attribute are used to build the properties of the attribute refering.
			 In that case no ref to a table is generated. -->
		
		<xsl:call-template name="attributeFacets">
			<xsl:with-param name="min-Occurs" select="$min-Occurs"/>
		</xsl:call-template>
	</xsl:template>
	

	<xsl:template name="attributeFacets">
		<xsl:param name="min-Occurs"/>
		<xsl:param name="type-is-GM-external" select="false()"/>
		
		
		<xsl:choose>
			<xsl:when test="imvert:type-name = 'NEN3610ID'">
				<xsl:variable name="id" select="imvert:id"/>
				<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="example" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-EXAMPLE')" />
				
				<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
				<xsl:sequence select="imf:create-output-element('ep:type-name', 'NEN3610ID')" />
			</xsl:when>
			<xsl:when test="$type-is-GM-external">
				<xsl:variable name="id" select="imvert:id"/>
				<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="example" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-EXAMPLE')" />
				
				<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
				<xsl:if test="imvert:type-name-oas">
					<xsl:sequence select="imf:create-output-element('ep:data-type', imvert:type-name-oas)" />
				</xsl:if>
			</xsl:when>
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]/imvert:id"/>
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]/imvert:id"/>
			<xsl:when test="imvert:type-id and  not(imvert:primitive-oas)">
				<xsl:variable name="id" select="imvert:id"/>
				<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="example" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-EXAMPLE')" />
				
				<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name(imvert:type-name,'type-name'))" />
				<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="imvert:supertype/imvert:type-name-oas">
						<xsl:sequence select="imf:create-output-element('ep:data-type', imvert:supertype/imvert:type-name-oas)" />
					</xsl:when>
					<xsl:when test="imvert:supertype"/>
					<xsl:otherwise>
						<xsl:sequence select="imf:create-output-element('ep:data-type', imvert:type-name-oas)" />
					</xsl:otherwise>
				</xsl:choose>
				
				<xsl:variable name="total-digits" select="imvert:total-digits" />
				<xsl:variable name="fraction-digits" select="imvert:fraction-digits" />
				<xsl:variable name="min-value" select="imf:get-tagged-value(.,'##CFG-TV-MINVALUEINCLUSIVE')" />
				<xsl:variable name="max-value">
					<xsl:choose>
						<xsl:when test="not(empty(imf:get-tagged-value(.,'##CFG-TV-MAXVALUEINCLUSIVE')))">
							<xsl:value-of select="imf:get-tagged-value(.,'##CFG-TV-MAXVALUEINCLUSIVE')"/>
						</xsl:when>
						<xsl:when test="imvert:total-digits">
							<xsl:variable name="power" select="imvert:total-digits" />
							<xsl:value-of select="imf:power($power,10,0)-1" />
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="min-length">
					<xsl:choose>
						<xsl:when test="$min-Occurs > 0 and (empty(xs:integer(imf:get-tagged-value(.,'##CFG-TV-MINLENGTH'))) or xs:integer(imf:get-tagged-value(.,'##CFG-TV-MINLENGTH')) = 1)">
							<xsl:value-of select="1"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="xs:integer(imf:get-tagged-value(.,'##CFG-TV-MINLENGTH'))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="max-length">
					<xsl:value-of select="xs:string(imf:get-tagged-value(.,'##CFG-TV-MAXLENGTH'))"/>
				</xsl:variable>
				<xsl:variable name="pattern" select="imvert:pattern" />
				
				<xsl:if test="$max-length != ''">
					<xsl:sequence select="imf:create-output-element('ep:max-length', $max-length)" />
				</xsl:if>
				<xsl:sequence select="imf:create-output-element('ep:min-value', $min-value)" />
				<xsl:if test="$max-value != ''">
					<xsl:sequence select="imf:create-output-element('ep:max-value', $max-value)" />
				</xsl:if>
				<xsl:if test="$min-length != ''">
					<xsl:sequence select="imf:create-output-element('ep:min-length', $min-length)" />
				</xsl:if>
				<xsl:sequence select="imf:create-output-element('ep:pattern', $pattern)" />
				<xsl:if test="imvert:id">
					<xsl:variable name="id" select="imvert:id"/>
					<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
					<xsl:variable name="example" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-EXAMPLE')" />
					
					<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- TODO: Op dit moment worden alle enumerations, ook al worden ze niet gebruikt, omgezet naar ep:constructs. 
			   Hoewel de niet gebruikte er in de volgdende stap uitgefilterd worden zou het netjes zijn ze al niet in het EP bestand te genereren. 
			   Die taak moet nog een keer worden uitgevoerd. -->
	<xsl:template match="imvert:class" mode="as-global-enumeration">
		<!-- Following template creates global ep:constructs for enumeration/ -->
		<xsl:sequence select="imf:create-debug-comment-with-xpath('OAS31000',$debugging,.)" />
		<xsl:variable name="compiled-name" select="imf:get-compiled-name(.)" />
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation-up-to-level(.,'CFG-TV-DEFINITION',$description-level)))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation-up-to-level(.,'CFG-TV-DEFINITION',$description-level)" />
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation-up-to-level(.,'CFG-TV-DESCRIPTION',$description-level)))">
				<ep:description>
					<xsl:if test="$debugging">
						<xsl:attribute name="level" select="$description-level"/>
					</xsl:if>
					<xsl:sequence select="imf:merge-documentation-up-to-level(.,'CFG-TV-DESCRIPTION',$description-level)" />
				</ep:description>
			</xsl:if>
			<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')))">
				<ep:pattern>
					<ep:p>
						<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')" />
					</ep:p>
				</ep:pattern>
			</xsl:if>
		</xsl:variable>

		<ep:construct>
			<xsl:sequence select="imf:create-output-element('ep:name', imf:capitalize($compiled-name))" />
			<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:capitalize($compiled-name))" />
			<xsl:choose>
				<xsl:when test="(empty($doc) or $doc='') and $debugging">
					<xsl:call-template name="documentationUnknown"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-string')" />
			<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="as-local-enumeration" />
		</ep:construct>
	</xsl:template>
	
		<!-- TODO: Op dit moment worden alle datatypes, ook al worden ze niet gebruikt, omgezet naar ep:constructs. 
			   Hoewel de niet gebruikte er in de volgdende stap uitgefilterd worden zou het netjes zijn ze al niet in het EP bestand te genereren. 
			   Die taak moet nog een keer worden uitgevoerd. -->
	<xsl:template match="imvert:class" mode="as-global-dataType">
		<xsl:param name="as-supertype" select="false()"/>
		<!-- Following template creates global ep:constructs for enumeration or for local datatypes. -->
		<xsl:sequence select="imf:create-debug-comment-with-xpath('OAS31500',$debugging,.)" />
		<xsl:variable name="compiled-name" select="imf:get-compiled-name(.)" />
		<xsl:choose>
			<xsl:when test="count($packages//imvert:package[not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]/
				imvert:class[imf:get-stereotype(.) = ('stereotype-name-simpletype') and imf:get-compiled-name(.) = $compiled-name]) > 1">
				<xsl:sequence select="imf:msg(.,'ERROR','Two or more DataType or PrimitiveType classes share the same name (case insensitive).',())" />			
			</xsl:when>
			<xsl:when test="$as-supertype and not(imvert:supertype)">
				<xsl:call-template name="attributeFacets">
					<xsl:with-param name="min-Occurs" select="0"/>
				</xsl:call-template>				
			</xsl:when>
			<xsl:when test="$as-supertype and imvert:supertype">
				<xsl:variable name="type-id" select="imvert:supertype/imvert:type-id"/>
				<xsl:apply-templates select="//imvert:class[imvert:id=$type-id]" mode="as-global-dataType">
					<xsl:with-param name="as-supertype" select="true()"/>
				</xsl:apply-templates>
				<xsl:call-template name="attributeFacets">
					<xsl:with-param name="min-Occurs" select="0"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="compiled-name" select="imf:get-compiled-name(.)" />
				<xsl:variable name="doc">
					<xsl:if test="not(empty(imf:merge-documentation-up-to-level(.,'CFG-TV-DEFINITION',$description-level)))">
						<ep:definition>
							<xsl:sequence select="imf:merge-documentation-up-to-level(.,'CFG-TV-DEFINITION',$description-level)" />
						</ep:definition>
					</xsl:if>
					<xsl:if test="not(empty(imf:merge-documentation-up-to-level(.,'CFG-TV-DESCRIPTION',$description-level)))">
						<ep:description>
							<xsl:if test="$debugging">
								<xsl:attribute name="level" select="$description-level"/>
							</xsl:if>
							<xsl:sequence select="imf:merge-documentation-up-to-level(.,'CFG-TV-DESCRIPTION',$description-level)" />
						</ep:description>
					</xsl:if>
					<xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')))">
						<ep:pattern>
							<ep:p>
								<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-PATTERN')" />
							</ep:p>
						</ep:pattern>
					</xsl:if>
				</xsl:variable>
				
					<xsl:choose>
						<xsl:when test="imvert:supertype[imvert:conceptual-schema-type]">
							<ep:construct>
								<ep:parameters>
									<ep:parameter>
										<ep:name>type</ep:name>
										<ep:value>simpletype-class</ep:value>
									</ep:parameter>
								</ep:parameters>
								<xsl:sequence select="imf:create-output-element('ep:name', imf:capitalize($compiled-name))" />
								<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:capitalize($compiled-name))" />
								<xsl:choose>
									<xsl:when test="(empty($doc) or $doc='') and $debugging">
										<xsl:call-template name="documentationUnknown"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
									</xsl:otherwise>
								</xsl:choose>
								<xsl:call-template name="attributeFacets">
									<xsl:with-param name="min-Occurs" select="0"/>
								</xsl:call-template>
							</ep:construct>
						</xsl:when>
						<xsl:when test="imvert:supertype[imvert:type-id]">
							<!-- Deze when is voor het afhandelen van request parameters die gebruik maken van lokale datatypen. -->
							<xsl:variable name="type-id" select="imvert:supertype/imvert:type-id"/>
							<ep:construct>
								<ep:parameters>
									<ep:parameter>
										<ep:name>type</ep:name>
										<ep:value>simpletype-class</ep:value>
									</ep:parameter>
								</ep:parameters>
								<xsl:sequence select="imf:create-output-element('ep:name', imf:capitalize($compiled-name))" />
								<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:capitalize($compiled-name))" />
								<xsl:choose>
									<xsl:when test="(empty($doc) or $doc='') and $debugging">
										<xsl:call-template name="documentationUnknown"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
									</xsl:otherwise>
								</xsl:choose>
								<xsl:apply-templates select="//imvert:class[imvert:id=$type-id]" mode="as-global-dataType">
									<xsl:with-param name="as-supertype" select="true()"/>
								</xsl:apply-templates>
								<xsl:call-template name="attributeFacets">
									<xsl:with-param name="min-Occurs" select="0"/>
								</xsl:call-template>
							</ep:construct>
						</xsl:when>
					</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="imvert:attribute" mode="as-local-enumeration">
		<xsl:sequence select="imf:create-debug-comment-with-xpath('OAS32000',$debugging,.)" />

		<xsl:variable name="supplier" select="imf:get-trace-suppliers-for-construct(.,1)[@project='SIM'][1]" />
		<xsl:variable name="construct" select="if ($supplier) then imf:get-trace-construct-by-supplier($supplier,$imvert-document) else ()" />
		<!--xsl:variable name="name" select="($construct/imvert:name, imvert:name)[1]" />
		<xsl:variable name="alias" select="($construct/imvert:alias, imvert:alias)[1]" /-->
		<xsl:variable name="name" select="imvert:name" />
		<xsl:variable name="alias" select="imvert:alias" />
		<xsl:variable name="doc">
			<xsl:if test="not(empty($construct))">
				<xsl:if
					test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)))">
					<ep:definition>
						<xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION',$description-level)" />
						<!--xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DEFINITION','BSM')" /-->
					</ep:definition>
				</xsl:if>
				<xsl:if
					test="not(empty(imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)))">
					<ep:description>
						<xsl:if test="$debugging">
							<xsl:attribute name="level" select="$description-level"/>
						</xsl:if>
						<xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION',$description-level)" />
						<!--xsl:sequence select="imf:merge-documentation-up-to-level($construct,'CFG-TV-DESCRIPTION','BSM')" /-->
					</ep:description>
				</xsl:if>
			</xsl:if>
		</xsl:variable>

		<xsl:if test="$debugging">
			<xsl:if test="not(empty($construct))">
				<xsl:result-document href="{concat('file:/',imf:get-xparm('system/work-imvert-folder-path'),'/../../../imvertor_dev/temp/message/Enumeration-',$name,'-',generate-id(),'.xml')}" method="xml">
					<xsl:variable name="id" select="imvert:id"/>
					<xsl:variable name="construct2" select="imf:get-construct-by-id($id,$packages)" />
					<vals>
						<xsl:if test="not(empty($supplier))">
							<construct>
								<xsl:sequence select="$construct2"/>
							</construct>
						</xsl:if>
						<xsl:if
							test="not(empty(imf:get-specific-compiled-tagged-values-up-to-level-debug($construct2,'CFG-TV-DEFINITION',$description-level)))">
							<definition>
								<xsl:sequence select="imf:get-specific-compiled-tagged-values-up-to-level-debug($construct2,'CFG-TV-DEFINITION',$description-level)" />
							</definition>
						</xsl:if>
						<xsl:if
							test="not(empty(imf:get-specific-compiled-tagged-values-up-to-level-debug($construct2,'CFG-TV-DESCRIPTION',$description-level)))">
							<description>
								<xsl:sequence select="imf:get-specific-compiled-tagged-values-up-to-level-debug($construct2,'CFG-TV-DESCRIPTION',$description-level)" />
							</description>
						</xsl:if>
					</vals>
				</xsl:result-document>
			</xsl:if>
		</xsl:if>
		

		<ep:enum>
			<xsl:choose>
				<xsl:when test="empty($alias)">
					<xsl:variable name="strippedFromAccents-name" select="replace(normalize-unicode($name,'NFKD'),'\P{IsBasicLatin}','')"/>
					<xsl:variable name="chars2bTranslated" select="translate(normalize-space($strippedFromAccents-name),'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890%','')">
						<!-- Contains all characters which need to be translated which are all characters except the a to z, the A to Z, 0 to 9, the underscore and the %. -->
					</xsl:variable>
					<xsl:variable name="chars2bTranslated2">
						<!-- Within the translate function for each char to be translated there has to be an underscore. Since the amount of special 
								 chars is variable we have to determine the amount of underscores to be used within the translate function. -->
						<xsl:variable name="lengthChars2bTranslated" select="string-length($chars2bTranslated)" as="xs:integer"/>
						<xsl:sequence select="imf:determineAmountOfUnderscores($lengthChars2bTranslated)"/>
					</xsl:variable>
					<xsl:variable name="normalizedName">
						<!-- The normalized name of the interface is equal to the name of the interface except that all characters other 
							 than a to z, the A to Z, 0 to 9 and the % are translated to underscores. -->
						<!-- Finally the string is actually translated using the variable. -->
						<xsl:value-of select="translate(normalize-space($strippedFromAccents-name),$chars2bTranslated,$chars2bTranslated2)"/>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$name != $normalizedName">
							<!-- If the normalized-name isn't equal to the SIM-name a warning has to be generated. The goal of this warning is to point the attention of the messagedeveloper only to the enumeration and ask him to check it. -->
							<xsl:sequence select="imf:msg($construct,'WARNING','No alias defined for enumeration value [1] in the enumeration [2], it has been generated from its description. Check if the resulting description is as desired and correct it if not.',(imvert:name,../../imvert:name))"/>						
						</xsl:when>
						<xsl:otherwise>
							<!-- If the normalized-name is equal to the SIM-name also a warning has to be generated. The goal of this warning is to point the attention of the messagedeveloper to the enumeration and ask him to cehck it. -->
							<xsl:sequence select="imf:msg($construct,'WARNING','No alias defined for enumeration value [1] in the enumeration [2], it has been generated from its description.',(imvert:name,../../imvert:name))"/>						
						</xsl:otherwise>
					</xsl:choose>
					<ep:name><xsl:value-of select="$name" /></ep:name>
					<ep:alias generated="true"><xsl:value-of select="$normalizedName" /></ep:alias>
					<xsl:sequence select="imf:create-output-element('ep:documentation', normalize-space($doc),'',false(),false())" />
				</xsl:when>
				<xsl:otherwise>
					<ep:name><xsl:value-of select="$name" /></ep:name>
					<ep:alias><xsl:value-of select="$alias" /></ep:alias>
					<xsl:sequence select="imf:create-output-element('ep:documentation', normalize-space($doc),'',false(),false())" />
				</xsl:otherwise>
			</xsl:choose>
		</ep:enum>

	</xsl:template>
	
	<xsl:template name="documentationUnknown">
		<ep:documentation>
			<ep:description>
				<xsl:sequence select="imf:create-output-element('ep:p', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
			</ep:description>
		</ep:documentation>
	</xsl:template>

	<xsl:function name="imf:checkSuperclassesOnId">
		<!-- This function checks if within a superclass attributes are present which are not id type attributes.
			 Neccessary for supporting determining the neccessity of embedded types. -->
		<xsl:param name="superclass"/>
		
		<xsl:choose>
			<xsl:when test="$superclass/ep:contains-non-id-attributes = 'true'">
				<xsl:text>#true</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>#false</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$superclass/ep:superconstruct/@type='superclass'">
			<xsl:variable name="nextLevelSuperclass" select="$superclass/ep:superconstruct[@type='superclass']"/>
			<xsl:sequence select="imf:checkSuperclassesOnId($nextLevelSuperclass)"/>
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="imf:getMeervoudigeNaam">
		<xsl:param name="construct"/>
		<xsl:param name="type"/>
		<xsl:param name="messagename"/>
		
		<xsl:choose>
			<xsl:when test="string-length(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-TARGETROLEPLURAL')) != 0">
				<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-TARGETROLEPLURAL')"/>
			</xsl:when>
			<xsl:when test="string-length(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-NAMEPLURAL')) != 0">
				<xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-NAMEPLURAL')"/>
			</xsl:when>
			<xsl:when test="$type = 'association'">
				<xsl:sequence select="imf:msg($construct,'WARNING','The construct [1] within message [2] does not have a tagged value target role in meervoud, define one.',($construct/imvert:name,$messagename))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="imf:msg($construct,'WARNING','The construct [1] within message [2] does not have a tagged value naam in meervoud, define one.',($construct/imvert:name,$messagename))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- This function merges all documentation from the highest layer up to the current layer. -->
	<xsl:function name="imf:merge-documentation">
		<xsl:param name="this" />
		<xsl:param name="tv-id" />

		<xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,false())" />
		<xsl:variable name="vals" select="$all-tv[@id = $tv-id]" />
		<xsl:for-each select="$vals">
			<xsl:variable name="p" select="normalize-space(imf:get-clean-documentation-string(imf:get-tv-value.local(.)))" />
			<xsl:if test="not($p = '')">
				<ep:p>
					<xsl:if test="$debugging">
						<xsl:attribute name="subpath" select="imf:get-subpath(@project,@application,@release)"/>
						<xsl:attribute name="val-level" select="@level"/>
						<xsl:attribute name="level" select="@project"/>
					</xsl:if>
					<xsl:value-of select="$p" />
				</ep:p>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
	<xsl:template match="html:*">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="local-name()='a'">
					<xsl:text>[</xsl:text><xsl:value-of select="."/><xsl:text>](</xsl:text><xsl:value-of select="./@href"/><xsl:text>)</xsl:text>
				</xsl:when>
				<xsl:when test="html:*">
					<xsl:apply-templates select="html:*|text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:function name="imf:get-specific-compiled-tagged-values-up-to-level-debug">
		<xsl:param name="this" />
		<xsl:param name="tv-id" />
		<xsl:param name="level"/>

		<xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,true())" />
		<xsl:variable name="vals" select="$all-tv[@id = $tv-id]" />

		<xsl:sequence select="$vals" />

	</xsl:function>

	<!-- This function merges all documentation from the provided layer up to the current layer. -->
	<xsl:function name="imf:merge-documentation-up-to-level">
		<xsl:param name="this" />
		<xsl:param name="tv-id" />
		<xsl:param name="level"/>
		
		<xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,false())" />
		<xsl:variable name="vals" select="$all-tv[@id = $tv-id]" />
		<xsl:for-each select="$vals">
			<xsl:variable name="p">
				<xsl:choose>
					<xsl:when test=".//html:body">
						<xsl:apply-templates select="html:*"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text></xsl:text><xsl:value-of select="normalize-space(imf:get-clean-documentation-string(imf:get-tv-value.local(.)))"/><xsl:text></xsl:text>
						<!--xsl:text></xsl:text><xsl:value-of select="normalize-space(imf:get-clean-documentation-string(.))"/><xsl:text></xsl:text-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$level = 'SIM' and not($p = '')">
					<ep:p format="{$vals[1]/@format}" level="{@project}">
						<xsl:if test="$debugging">
							<xsl:attribute name="subpath" select="imf:get-subpath(@project,@application,@release)"/>
							<xsl:attribute name="val-level" select="@level"/>
						</xsl:if>
						<xsl:sequence select="$p" />
					</ep:p>
				</xsl:when>
				<xsl:when test="$level = 'UGM' and (@project = 'UGM' or @project = 'BSM') and not($p = '')">
					<ep:p format="{$vals[1]/@format}" level="{@project}">
						<xsl:if test="$debugging">
							<xsl:attribute name="subpath" select="imf:get-subpath(@project,@application,@release)"/>
							<xsl:attribute name="val-level" select="@level"/>
						</xsl:if>
						<xsl:sequence select="$p" />
					</ep:p>
				</xsl:when>
				<xsl:when test="$level = 'BSM' and @project = 'BSM' and not($p = '')">
					<ep:p format="{$vals[1]/@format}" level="{@project}">
						<xsl:if test="$debugging">
							<xsl:attribute name="subpath" select="imf:get-subpath(@project,@application,@release)"/>
							<xsl:attribute name="val-level" select="@level"/>
						</xsl:if>
						<xsl:sequence select="$p" />
					</ep:p>
				</xsl:when>
			</xsl:choose>
			<?x			<xsl:if test="not($p = '')">
				<ep:p>
					<xsl:if test="$debugging">
						<xsl:attribute name="subpath" select="imf:get-subpath(@project,@application,@release)"/>
						<xsl:attribute name="val-level" select="@level"/>
						<xsl:attribute name="level" select="$level"/>
					</xsl:if>
					<xsl:value-of select="$p" />
				</ep:p>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$vals[not(@level &lt; $level)]">
			<xsl:variable name="p" select="normalize-space(imf:get-clean-documentation-string(imf:get-tv-value.local(.)))" />
			<xsl:if test="not($p = '') and $debugging">
				<ep:p2>
					<xsl:attribute name="subpath" select="imf:get-subpath(@project,@application,@release)"/>
					<xsl:attribute name="val-level" select="@level"/>
					<xsl:attribute name="level" select="$level"/>
					<xsl:value-of select="$p" />
				</ep:p2>
			</xsl:if> ?>
		</xsl:for-each> 
		
	</xsl:function>
	
	<xsl:function name="imf:capitalize">
		<xsl:param name="name" />
		<xsl:value-of select="concat(upper-case(substring($name,1,1)),substring($name,2))" />
	</xsl:function>

	<xsl:function name="imf:get-stereotype">
		<xsl:param name="this" />
		<xsl:sequence select="$this/imvert:stereotype/@id" />
	</xsl:function>

	<xsl:function name="imf:get-compiled-name">
		<xsl:param name="this" as="element()"/>
		<xsl:variable name="type" select="local-name($this)"/>
		<xsl:variable name="stereotype" select="imf:get-stereotype($this)"/>
		<xsl:variable name="alias" select="$this/imvert:alias"/>
		<xsl:variable name="name-raw" select="$this/imvert:name"/>
		<xsl:variable name="name-form" select="replace(imf:strip-accents($name-raw),'[^\p{L}0-9.\-]+','_')"/>

		<xsl:variable name="name" select="$name-form"/>

		<xsl:choose>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-simpletype')">
				<xsl:value-of select="$name"/>
			</xsl:when>
<?x			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-composite')">
				<xsl:value-of select="concat(imf:capitalize($name),'Grp')"/>
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-objecttype')">
				<xsl:value-of select="$alias"/>
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-relatieklasse')">
				<xsl:value-of select="$alias"/>
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-referentielijst')">
				<xsl:value-of select="$alias"/>
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-complextype')">
				<xsl:value-of select="$name"/>
			</xsl:when> ?>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-enumeration')">
				<xsl:value-of select="$name"/>
			</xsl:when>
<?x			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-union')">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-interface')">
				<!-- this must be an external -->
				<xsl:variable name="external-name" select="imf:get-external-type-name($this,true())"/>
				<xsl:value-of select="$external-name"/>
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-attribute')">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-referentie-element')">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-data-element')">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-enum')">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-union-element')">
				<xsl:value-of select="imf:useable-attribute-name($name,$this)"/>
			</xsl:when>
			<xsl:when test="$type = 'association' and $stereotype = ('stereotype-name-relatiesoort') and normalize-space($alias)">
				<!-- if this relation occurs multiple times, add the alias of the target object -->
				<xsl:value-of select="$alias"/>
			</xsl:when>
			<xsl:when test="$type = 'association' and $this/imvert:aggregation = 'composite'">
				<xsl:value-of select="$name"/>
			</xsl:when>
			<xsl:when test="$type = 'association' and $stereotype = ('stereotype-name-relatiesoort')">
				<xsl:sequence select="imf:msg($this,'ERROR','No alias',())"/>
				<xsl:value-of select="lower-case($name)"/>
			</xsl:when>
			<xsl:when test="$type = 'association' and normalize-space($alias)"> <!-- composite -->
				<xsl:value-of select="$alias"/>
			</xsl:when>
			<xsl:when test="$type = 'association'">
				<xsl:sequence select="imf:msg($this,'ERROR','No alias',())"/>
				<xsl:value-of select="lower-case($name)"/>
			</xsl:when>
			<!-- TODO meer soorten namen uitwerken? --> ?>
			<xsl:otherwise>
				<xsl:sequence select="imf:msg($this,'ERROR','The class [1] with the stereotype [3] has the unknown type [2].', ($this/imvert:name,string-join(string-join($stereotype,', '),$type)))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="imf:useable-attribute-name">
		<xsl:param name="name" as="xs:string" />
		<xsl:param name="attribute" as="element(imvert:attribute)" />
		<xsl:choose>
			<xsl:when test="empty($attribute/imvert:type-id) and exists($attribute/imvert:baretype) and count($all-simpletype-attributes[imvert:name = $attribute/imvert:name]) gt 1">
				<xsl:value-of select="concat($name,$attribute/../../imvert:alias)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="imf:determineAmountOfUnderscores">
		<xsl:param name="length"/>
		<xsl:if test="$length > 0">
			<xsl:value-of select="'_'"/>
			<xsl:sequence select="imf:determineAmountOfUnderscores($length - 1)"/>
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="imf:power">
		<xsl:param name="power"/>
		<xsl:param name="num"/>
		<xsl:param name="value"/>
		
		<xsl:choose>
			<xsl:when test="$value = 0 and $power = 0">
				<xsl:value-of select="0"/>
			</xsl:when>
			<xsl:when test="$value = 0 and $power = 1">
				<xsl:value-of select="$num"/>
			</xsl:when>
			<xsl:when test="$value = 0">
				<xsl:value-of select="imf:power($power - 1,$num,$num)"/>
			</xsl:when>
			<xsl:when test="$power > 1">
				<xsl:variable name="product" select="$value * $num"/>
				<xsl:value-of select="imf:power($power - 1,$num,$product)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value * $num"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>
