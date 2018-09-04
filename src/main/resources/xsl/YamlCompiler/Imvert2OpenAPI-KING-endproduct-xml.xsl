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
	
	version="2.0">

	<!--TODO: Kijken of de volgende imports en include nog wel nodig zijn. -->
	<xsl:import href="../common/Imvert-common.xsl" />
	<xsl:import href="../common/Imvert-common-validation.xsl" />
	<xsl:import href="../common/extension/Imvert-common-text.xsl" />
	<xsl:import href="../common/Imvert-common-derivation.xsl" />
	<xsl:import href="../common/Imvert-common-external.xsl"/>
	<xsl:import href="../XsdCompiler/Imvert2XSD-KING-common.xsl" />

	<xsl:include href="../XsdCompiler/Imvert2XSD-KING-common-checksum.xsl" />

	<xsl:output indent="yes" method="xml" encoding="UTF-8" />

	<!-- TODO: Kijken of de volgende key's wel nodig zijn. -->
	<xsl:key name="class" match="imvert:class" use="imvert:id" />
	<xsl:key name="enumerationClass" match="imvert:class" use="imvert:name" />

	<xsl:variable name="stylesheet-code" as="xs:string">OAS</xsl:variable>
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean" />

	<xsl:variable name="stylesheet" as="xs:string">Imvert2XSD-KING-OpenAPI-endproduct-xml</xsl:variable>
	<xsl:variable name="stylesheet-version" as="xs:string">$Id: Imvert2XSD-KING-OpenAPI-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $</xsl:variable>

	<!-- TODO: Kijken welke van de volgende variabeles nog nodig zijn. -->
	<xsl:variable name="GML-prefix" select="'gml'" />

	<xsl:variable name="config-schemarules">
		<xsl:sequence select="imf:get-config-schemarules()" />
	</xsl:variable>
	<xsl:variable name="config-tagged-values">
		<xsl:sequence select="imf:get-config-tagged-values()" />
	</xsl:variable>

	<xsl:variable name="messages" select="imf:document(imf:get-config-string('properties','RESULT_METAMODEL_KINGBSM_OPENAPI_MIGRATE'))" />
	<xsl:variable name="packages" select="$messages/imvert:packages" />

	<xsl:variable name="kv-prefix" select="imf:get-tagged-value($packages,'##CFG-TV-VERKORTEALIAS')"/>
	<xsl:variable name="kv-description">
		<xsl:if test="not(empty(imf:get-tagged-value($packages,'##CFG-TV-DESCRIPTION')))">
			<ep:description>
				<ep:p>
					<xsl:sequence select="imf:get-tagged-value($packages,'##CFG-TV-DESCRIPTION')" />
				</ep:p>
			</ep:description>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="version" select="$packages/imvert:version"/>
	
	<xsl:variable name="imvert-document" select="if (exists($messages/imvert:packages)) then $messages else ()" />

	<!-- needed for disambiguation of duplicate attribute names -->
	<xsl:variable name="all-simpletype-attributes" select="$packages//imvert:attribute[empty(imvert:type)]" />

	<xsl:variable name="endproduct">
		<xsl:apply-templates select="/ep:rough-messages" />
	</xsl:variable>

	<!-- Starts the creation of the rough-message constructs and the constructs relates to those message constructs. -->
	<xsl:template match="ep:rough-messages">
		<xsl:sequence select="imf:set-config-string('appinfo','kv-yaml-schema-name',concat($kv-prefix,$version))"/>
		
		<ep:message-sets>
			<ep:message-set KV-namespace="yes">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS00500',$debugging)" />

				<xsl:sequence select="imf:create-output-element('ep:name', $packages/imvert:application)" />
				<xsl:sequence select="imf:create-output-element('ep:release', $packages/imvert:release)" />
				<xsl:sequence select="imf:create-output-element('ep:date', substring-before($packages/imvert:generated,'T'))" />
				<xsl:sequence select="imf:create-output-element('ep:patch-number', $version)" />
				<!--xsl:sequence  select="imf:create-output-element('ep:documentation', $kv-description)" /-->
				<xsl:sequence select="imf:create-output-element('ep:documentation', $kv-description,'',false(),false())" />
				
				<xsl:if test="$debugging">
					<xsl:sequence select="imf:debug-document($config-schemarules,'imvert-schema-rules.xml',true(),false())" />
					<xsl:sequence select="imf:debug-document($config-tagged-values,'imvert-tagged-values.xml',true(),false())" />
				</xsl:if>

				<xsl:sequence select="imf:track('Constructing the OpenAPI message constructs')" />

				<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS01000',$debugging)" />
				<xsl:apply-templates select="ep:rough-message" />

				<xsl:sequence select="imf:track('Constructing the constructs related to the OpenAPI messages')" />

				<!-- xxxxx -->
				<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS01500',$debugging)" />

				<xsl:for-each-group 
					select="//ep:superconstruct"
					group-by="ep:name">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS02000',$debugging)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<xsl:sequence select="imf:create-debug-comment(concat('Berichtcode=',$berichtcode),$debugging)" />
					<xsl:apply-templates select="current-group()[1]" mode="as-content">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
				<xsl:for-each-group 
					select="//ep:construct[@type!='complex-datatype' and @type!='groepCompositieAssociation']"
					group-by="ep:name">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS02500',$debugging)" />
					<xsl:sequence select="imf:create-debug-comment(concat('Groupname: ',ep:name),$debugging)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<xsl:apply-templates select="current-group()[1]" mode="as-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
				<?x xsl:for-each-group 
					select="//ep:construct[@type='association' and ep:construct[@type='subclass']]"
					group-by="ep:name">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS02500',$debugging)" />
					<xsl:sequence select="imf:create-debug-comment(concat('Groupname: ',ep:name),$debugging)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<xsl:apply-templates select="current-group()[1]" mode="as-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group ?>
				
				<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS03000',$debugging)" />
				<xsl:for-each-group 
					select="//ep:construct[@type='complex-datatype']"
					group-by="ep:type-id">
					<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS035000',$debugging)" />
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:variable name="berichtcode" select="ancestor::ep:rough-message/@berichtcode"/>
					<xsl:variable name="messagetype" select="ancestor::ep:rough-message/@messagetype"/>
					<!-- All global constructs need to be provided with the berichtcode and messagetype they apply to, 
						 to be able to decide how to proces them in a following step. -->
					<xsl:apply-templates select="current-group()[1]" mode="as-type">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
					</xsl:apply-templates>
				</xsl:for-each-group>
				<!-- Following apply creates all global ep:constructs containing enumeration lists. -->
				<xsl:apply-templates select="$packages//imvert:package[not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]/
                                             imvert:class[imf:get-stereotype(.) = ('stereotype-name-enumeration') and generate-id(.) = 
                                             generate-id(key('enumerationClass',imvert:name,$packages)[1])]" mode="mode-global-enumeration" />
			</ep:message-set>
		</ep:message-sets>
	</xsl:template>

	<!-- Takes care of processing individual ep:rough-message elements to ep:message elements. -->
	<xsl:template match="ep:rough-message">
		<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS04000',$debugging)" />

		<xsl:variable name="id" select="ep:id" as="xs:string" />

		<!-- TODO: De eerste variabele geeft om de eoa reden geen resultaat daarom is de tweede variabele geintroduceerd. 
				   Nagaan waarom dat zo is en de werking van de eerste herstellen zodat de tweede kan komen te vervallen. -->
		<xsl:variable name="message-construct" select="imf:get-class-construct-by-id($id,$packages)" />
		<xsl:variable name="this-construct" select="$packages//imvert:*[imvert:id = $id]" />

		<!-- TODO: UItzoeken of documentation gewenst is. -->
		<xsl:variable name="doc">
			<xsl:if
				test="not(empty(imf:merge-documentation($this-construct,'CFG-TV-DEFINITION')))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation($this-construct,'CFG-TV-DEFINITION')" />
				</ep:definition>
			</xsl:if>
			<xsl:if
				test="not(empty(imf:merge-documentation($this-construct,'CFG-TV-DESCRIPTION')))">
				<ep:description>
					<xsl:sequence select="imf:merge-documentation($this-construct,'CFG-TV-DESCRIPTION')" />
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
		<xsl:variable name="messagetype" select="@messagetype" />
		<xsl:sequence select="imf:create-debug-comment($berichtcode,$debugging)" />

<?x		<xsl:variable name="berichtsjabloon" select="$packages//imvert:package[imvert:alias='/www.kinggemeenten.nl/BSM/Berichtstrukturen/Model']//imvert:class[.//imvert:tagged-value[@id='CFG-TV-BERICHTCODE']/imvert:value=$berichtcode]" />

		<xsl:if test="$debugging">
			<xsl:result-document href="{concat('file:/c:/temp/message/construct-',$id,'-',generate-id(),'.xml')}">
				<xsl:copy-of select="$berichtsjabloon" />
			</xsl:result-document>
		</xsl:if> ?>
        
<?x        <xsl:variable name="expand" select="imf:get-most-relevant-compiled-taggedvalue($berichtsjabloon, '##CFG-TV-EXPAND')"/>  ?>
		<xsl:variable name="expand">
			<xsl:choose>
				<xsl:when test=".//ep:construct[@type = 'association']//ep:contains-non-id-attributes = 'true'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
<?x		<xsl:variable name="fields" select="@fields" />
		<xsl:variable name="grouping" select="imf:get-most-relevant-compiled-taggedvalue($berichtsjabloon, '##CFG-TV-GROUPING')" />
		<xsl:variable name="pagination" select="imf:get-most-relevant-compiled-taggedvalue($berichtsjabloon, '##CFG-TV-PAGE')" />
		<xsl:variable name="serialisation" select="imf:get-most-relevant-compiled-taggedvalue($berichtsjabloon, '##CFG-TV-SERIALISATION')" />
		<xsl:variable name="sort" select="@sort" /> ?>

<?x		<xsl:variable name="name" select="$message-construct/imvert:name/@original" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name($message-construct/imvert:name, 'element-name')" as="xs:string" /> ?>
		<xsl:variable name="name" select="ep:name" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(ep:name, 'element-name')" as="xs:string" />
		
		<!-- TODO: Nagaan of het wel noodzakelijk is om over de min- en maxoccurs van de entiteitrelaties te kunnen beschikken. -->
		<xsl:variable name="minOccursAssociation">
			<xsl:choose>
				<xsl:when test="count($message-construct//imvert:associations/imvert:association[not(imvert:name = 'stuurgegevens') and not(imvert:name = 'parameters') and not(imvert:name = 'start') and not(imvert:name = 'scope') and not(imvert:name = 'vanaf') and not(imvert:name = 'tot en met')]) = 0">
					<xsl:variable name="msg" select="concat('The class ',ep:name,' (id ',ep:id,') does not have an association with a min-occurs.')" />
					<xsl:sequence select="imf:msg('WARNING', $msg)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$message-construct//imvert:associations/imvert:association[not(imvert:name = 'stuurgegevens') and not(imvert:name = 'parameters') and not(imvert:name = 'start') and not(imvert:name = 'scope') and not(imvert:name = 'vanaf') and not(imvert:name = 'tot en met')]/imvert:min-occurs" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="maxOccursAssociation">
			<xsl:choose>
				<xsl:when test="count($message-construct//imvert:associations/imvert:association[not(imvert:name = 'stuurgegevens') and not(imvert:name = 'parameters') and not(imvert:name = 'start') and not(imvert:name = 'scope') and not(imvert:name = 'vanaf') and not(imvert:name = 'tot en met')]) = 0">
					<xsl:variable name="msg" select="concat('The class ',ep:name,' (id ',ep:id,')does not have an association with a max-occurs.')" />
					<xsl:sequence select="imf:msg('WARNING', $msg)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$message-construct//imvert:associations/imvert:association[not(imvert:name = 'stuurgegevens') and not(imvert:name = 'parameters') and not(imvert:name = 'start') and not(imvert:name = 'scope') and not(imvert:name = 'vanaf') and not(imvert:name = 'tot en met')]/imvert:max-occurs" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS04500',$debugging)" />

		<ep:message>
			<xsl:choose>
				<xsl:when test="(contains($berichtcode,'Gr') or contains($berichtcode,'Gc')) and $messagetype = 'response'">
					<xsl:attribute name="messagetype" select="@messagetype" />
					<xsl:attribute name="servicename" select="@servicename" />
					<xsl:attribute name="expand" select="$expand" />
					<xsl:attribute name="grouping" select="@grouping" />
					<xsl:attribute name="pagination" select="@pagination" />
					<xsl:attribute name="serialisation" select="@serialisation" />
					<xsl:attribute name="berichtcode" select="$berichtcode" />
				</xsl:when>
				<xsl:when test="(contains($berichtcode,'Gr') or contains($berichtcode,'Gc')) and $messagetype = 'request'">
					<xsl:attribute name="messagetype" select="@messagetype" />
					<xsl:attribute name="servicename" select="@servicename" />
					<xsl:attribute name="expand" select="$expand" />
					<xsl:attribute name="grouping" select="@grouping" />
					<xsl:attribute name="pagination" select="@pagination" />
					<xsl:attribute name="serialisation" select="@serialisation" />
					<xsl:if test="@fields">
						<xsl:attribute name="fields" select="@fields" />
					</xsl:if>
					<xsl:if test="@sort">
						<xsl:attribute name="sort" select="@sort" />
					</xsl:if>
					<xsl:attribute name="berichtcode" select="$berichtcode" />
<?x					<xsl:variable name="meervoudigeNaam">
						<xsl:variable name="messageName" select="ep:name"/>
						<xsl:variable name="id" select="//ep:rough-message[@messagetype='response' and ep:name = $messageName]/ep:construct/ep:id"/>
						<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
						<xsl:choose>
							<xsl:when test="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-NAMEPLURAL') = ''">
								<xsl:sequence select="imf:msg(.,'WARNING','The construct [1] does not have a tagged value naam in meervoud, define one.',$construct/imvert:name)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-NAMEPLURAL')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable> 
					<xsl:if test="$meervoudigeNaam != ''">
						<xsl:attribute name="meervoudigeNaam" select="$meervoudigeNaam" />
					</xsl:if> ?>
				</xsl:when>
				<!-- ROME: Welke attributen zijn van toepassing op een POST bericht. -->
				<xsl:when test="contains($berichtcode,'Po') and $messagetype = 'request'">
					<xsl:attribute name="messagetype" select="@messagetype" />
					<xsl:attribute name="servicename" select="@servicename" />
					<xsl:attribute name="berichtcode" select="$berichtcode" />
				</xsl:when>
			</xsl:choose>
			<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
			<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
			<xsl:choose>
				<xsl:when test="(empty($doc) or $doc='') and $debugging">
					<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test=".//ep:construct">
				<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS05000',$debugging)" />
				<ep:seq>
					<!-- TODO: Zolang niet duidelijk is of min- en maxoccurs noodzakelijk zijn. Geven we in de aanroep naar het construct template de waarde '-' 
						 mee als teken dat deze niet gegenereerd hoeven te worden. -->
<?x                    <xsl:apply-templates select="ep:construct" mode="as-content">
                        <xsl:with-param name="minOccurs" select="$minOccursAssociation"/>
                        <xsl:with-param name="maxOccurs" select="$maxOccursAssociation"/>
                    </xsl:apply-templates> ?>
					<xsl:apply-templates select="ep:construct" mode="as-content">
						<xsl:with-param name="berichtcode" select="$berichtcode"/>
						<xsl:with-param name="messagetype" select="$messagetype"/>
						<xsl:with-param name="minOccurs" select="'-'" />
						<xsl:with-param name="maxOccurs" select="'-'" />
					</xsl:apply-templates>
				</ep:seq>
			</xsl:if>
		</ep:message>
	</xsl:template>

	<xsl:template match="ep:construct" mode="as-content">
		<xsl:param name="berichtcode" />
		<xsl:param name="messagetype"/>
		<xsl:param name="minOccurs" />
		<xsl:param name="maxOccurs" />

		<xsl:sequence select="imf:create-debug-comment('Debuglocation OAS05500',$debugging)" />
		
		<xsl:variable name="name" select="ep:name" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(ep:tech-name, 'element-name')" as="xs:string" />
		<!-- Sometime we like to process the imvert construct which has a reference to a class and sometime the class. 
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
				<?x <xsl:when test="ep:type-id and @type = 'complex-datatype'">
					<xsl:variable name="type-id" select="ep:type-id" />
					<xsl:value-of select="$packages//imvert:attribute[imvert:type-id = $type-id][1]/imvert:id" />
				</xsl:when> ?>
				<xsl:when test="ep:type-id and @type = 'complex-datatype'">
					<xsl:variable name="type-id" select="ep:type-id" />
					<!--xsl:value-of select="$packages//imvert:attribute[imvert:name = $name and imvert:type-id = $type-id][1]/imvert:id" /-->
					<xsl:value-of select="$packages//imvert:attribute[imvert:name = $name and imvert:type-id = $type-id][not(following::imvert:attribute[imvert:name = $name and imvert:type-id = $type-id])]/imvert:id" />				
				</xsl:when>
				<xsl:when test="ep:type-id">
					<xsl:variable name="type-id" select="ep:type-id" />
					<xsl:value-of select="$packages//imvert:association[imvert:type-id = $type-id]/imvert:id" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<!-- It's not possible to get debug information which is set into a variable into the output we do this outside the variable. 
			 The 'when' statements catch all situation as the when statements in the variable above. -->
		<xsl:if test="$debugging">
			<xsl:choose>
				<xsl:when test="ep:id and @type = 'association'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS06000, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'groepCompositie'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS06500, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'association-class'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS07000, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:id-refering-association and @type = 'class'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS07500, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:id-refering-association and @type = 'requestclass'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS08000, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'class'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS08500, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'subclass'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS09000, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:id and @type = 'attribute'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS09500, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:type-id and @type = 'complex-datatype'">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS10000, id: ',$id),$debugging)" />
				</xsl:when>
				<xsl:when test="ep:type-id">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS10500, id: ',$id),$debugging)" />
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<!-- The construct variable holds the imvert construct which has an imvert:id equal to the 'id' variable. 
			 So sometimes it's an attribute, sometimes an association amd sometimes a class. -->
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
        
        <xsl:variable name="doc">
        	<xsl:if test="not(empty($construct))">
	            <xsl:if test="not(empty(imf:merge-documentation($construct,'CFG-TV-DEFINITION')))">
	                <ep:definition>
	                    <xsl:sequence select="imf:merge-documentation($construct,'CFG-TV-DEFINITION')"/>
	                </ep:definition>
	            </xsl:if>
	            <xsl:if test="not(empty(imf:merge-documentation($construct,'CFG-TV-DESCRIPTION')))">
	                <ep:description>
	                    <xsl:sequence select="imf:merge-documentation($construct,'CFG-TV-DESCRIPTION')"/>
	                </ep:description>
	            </xsl:if>
	            <xsl:if test="not(empty(imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')))">
	                <ep:pattern>
	                    <ep:p>
	                        <xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-PATTERN')"/>
	                    </ep:p>
	                </ep:pattern>
	            </xsl:if>
        	</xsl:if>
        </xsl:variable>

		<xsl:choose>
			<!-- If the current ep:construct is an association-class no ep:construct element is generated. All attributes of that related class are directly placed 
				 within the current ep:construct. Also the child ep:superconstructs and ep:constructs (if present) are processed. -->
			<xsl:when test="@type='association-class'">
				<xsl:sequence select="imf:create-debug-comment(concat('OAS11000, id: ',$id),$debugging)" />
				<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
				<xsl:apply-templates select="ep:superconstruct" mode="as-ref" />
				<xsl:apply-templates select="ep:construct" mode="as-content">
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- If the current ep:construct is an complex-datatype a ep:construct element is generated with all necessary properties. -->
			<xsl:when test="@type='complex-datatype'">
				<xsl:variable name="type-id" select="ep:type-id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				<ep:construct type="{@type}" berichtcode="{$berichtcode}" messagetype="{$messagetype}">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS11500, id: ',$id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
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
			<!-- If the current ep:construct is an association a ep:construct element is generated with all necessary properties. 
				 This when statement differs from the one above by the value of the ep:name and ep:tech-name. -->
			<xsl:when test="@type='association'">
				<xsl:variable name="type-id" select="ep:type-id" />
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
					<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-TARGETROLEPLURAL')" />
				</xsl:variable>
				<xsl:variable name="targetrole">
					<xsl:sequence select="$construct/imvert:target/imvert:role" />
				</xsl:variable>
				<xsl:variable name="messagename" select="ancestor::ep:rough-message/ep:name"/>
				
				<xsl:sequence select="imf:create-debug-comment('At this level the expand attribute is neccessary to determine if an _embedded property has to be created. This is only the case if the attribute has the value true.',$debugging)" />
				<ep:construct>
					<xsl:choose>
						<xsl:when test="ep:construct[@type='subclass']">
							<xsl:attribute name="type" select="concat('supertype-',@type)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="type" select="@type"/>
						</xsl:otherwise>
					</xsl:choose>
					
					<xsl:variable name="contains-non-id-attributes">
						<xsl:if test="ep:construct[@type='subclass']">
							<xsl:for-each select="ep:construct[@type='subclass']">
								<xsl:choose>
									<xsl:when test="ep:contains-non-id-attributes = 'true'">
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
								<xsl:otherwise>
									<xsl:text>#false</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:variable>
					<xsl:if test="contains($contains-non-id-attributes,'#true')">
						<xsl:attribute name="contains-non-id-attributes" select="'true'" />
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$meervoudigeNaam=''">
							<xsl:if test="not($targetrole='')">
								<xsl:attribute name="targetrole" select="$targetrole" />
							</xsl:if>
							<xsl:sequence select="imf:msg(.,'WARNING','The construct [1] within message [2] does not have a tagged value Target role in meervoud, define one.',(ep:name,$messagename))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="meervoudigeNaam" select="$meervoudigeNaam" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-debug-comment(concat('Result check on id attributes: ',$contains-non-id-attributes),$debugging)" />
					<xsl:sequence select="imf:create-debug-comment(concat('OAS12000, id: ',$id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $construct/imvert:name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($construct/imvert:name, 'element-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
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
			<!-- If the current ep:construct is an association to a groepcompositie the groepcompositie construct is processed.  -->
			<xsl:when test="@type='groepCompositieAssociation'">
				<xsl:apply-templates select="ep:construct" mode="as-content">
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
			</xsl:when>
			<!-- If the current ep:construct is a groepcompositie an ep:construct element is generated with a reference to a type.  -->
			<xsl:when test="@type='groepCompositie'">
				<xsl:variable name="id" select="ep:id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				<!-- <xsl:variable name="meervoudigeNaam">
					<xsl:sequence
						select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-TARGETROLEPLURAL')" />
				</xsl:variable> -->
				<ep:construct type="{@type}">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS12500, id: ',$id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $type-name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $type-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
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
			<!-- If the current ep:construct is a subclass an ep:construct element is generated with all necessary properties.  -->
			<xsl:when test="@type = 'subclass'">
				<!-- TODO: Uitzoeken waarom '$construct/imvert:class/imvert:type-id' en 
						   '$construct//imvert:class/imvert:type-id' niet werken. -->
				<xsl:variable name="meervoudigeNaam">
					<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-NAMEPLURAL')" />
				</xsl:variable>
				
				<xsl:variable name="type-id" select="ep:id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				
				<ep:construct type="{@type}">
					<xsl:choose>
						<xsl:when test="$meervoudigeNaam=''">
							<xsl:sequence select="imf:msg(.,'WARNING','The construct [1] does not have a tagged value naam in meervoud, define one.',ep:name)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="meervoudigeNaam" select="$meervoudigeNaam" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-debug-comment(concat('OAS13000, id: ',$id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name1', imf:get-normalized-name($tech-name,'type-name'))" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($type-name,'type-name'))" />
				</ep:construct>
			</xsl:when>
			<!-- If the construct is the top-level construct within a message no meervoudigeNaam attribute has to be generated. -->
			<xsl:when test="parent::ep:rough-message">
				<xsl:result-document href="{concat('file:/c:/temp/construct-20180622-b-',$name,'-',generate-id(),'.xml')}">
		            <xsl:copy-of select="$construct"/>
		        </xsl:result-document>
				
				<!-- TODO: Uitzoeken waarom '$construct/imvert:class/imvert:type-id' en
						   '$construct//imvert:class/imvert:type-id' niet werken. -->
				<xsl:variable name="typeid" select="$construct/imvert:type-id" />
				<xsl:variable name="relatedconstruct" select="imf:get-construct-by-id($typeid,$packages)" />
				<!-- <xsl:variable name="meervoudigeNaam">
					<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($relatedconstruct, '##CFG-TV-NAMEPLURAL')" />
				</xsl:variable> -->
				<ep:construct type="{@type}">
					<xsl:sequence select="imf:create-debug-comment(concat('OAS132500, id: ',$id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="$construct//imvert:name = 'response' or $construct//imvert:name = 'request'"/>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<!-- Depending on the type the min- and max-occurs are set or aren't set at all. -->
					<xsl:choose>
						<xsl:when test="$minOccurs = '-'">
							<xsl:sequence select="imf:create-debug-comment(concat('OAS14000, id: ',$id),$debugging)" />
						</xsl:when>
						<xsl:when test="not($minOccurs = '')">
							<xsl:sequence select="imf:create-debug-comment(concat('OAS14500, id: ',$id),$debugging)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $minOccurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $maxOccurs)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-debug-comment(concat('OAS15000, id: ',$id),$debugging)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:variable name="type-id" select="ep:id" />
					<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
					<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
					
					<xsl:sequence select="imf:create-output-element('ep:type-name1', imf:get-normalized-name($tech-name,'type-name'))" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($classconstruct/imvert:name,'type-name'))" />
				</ep:construct>
			</xsl:when>
			<xsl:otherwise>
				<!-- TODO: Uitzoeken waarom '$construct/imvert:class/imvert:type-id' en
						   '$construct//imvert:class/imvert:type-id' niet werken. -->
				<xsl:variable name="typeid" select="$construct/imvert:type-id" />
				<xsl:variable name="relatedconstruct" select="imf:get-construct-by-id($typeid,$packages)" />
				<xsl:variable name="meervoudigeNaam">
					<xsl:sequence select="imf:get-most-relevant-compiled-taggedvalue($relatedconstruct, '##CFG-TV-NAMEPLURAL')" />
				</xsl:variable>
				<ep:construct type="{@type}">
					<xsl:choose>
						<xsl:when test="$meervoudigeNaam=''">
							<xsl:sequence select="imf:msg(.,'WARNING','The construct [1] does not have a tagged value naam in meervoud, define one.',ep:name)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="meervoudigeNaam" select="$meervoudigeNaam" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-debug-comment(concat('OAS16000, id: ',$id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<!-- Depending on the type the min- and max-occurs are set or aren't set at all. -->
					<xsl:choose>
						<xsl:when test="$minOccurs = '-'">
							<xsl:sequence select="imf:create-debug-comment(concat('OAS16500, id: ',$id),$debugging)" />
						</xsl:when>
						<xsl:when test="not($minOccurs = '')">
							<xsl:sequence select="imf:create-debug-comment(concat('OAS17000, id: ',$id),$debugging)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $minOccurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $maxOccurs)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-debug-comment(concat('OAS17500, id: ',$id),$debugging)" />
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', $construct/imvert:min-occurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', $construct/imvert:max-occurs)" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name($tech-name,'type-name'))" />
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:function name="imf:checkSuperclassesOnId">
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

	<!-- Processing of an ep:superconstruct means all attributes of that related class are directly placed 
		 within the current ep:construct. Also the child ep:superconstructs and ep:constructs (if present) are processed. -->
	<xsl:template match="ep:superconstruct" mode="as-ref">

		<xsl:variable name="id" select="ep:id" />
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name($construct/imvert:name, 'type-name')" as="xs:string" />
		
		<xsl:sequence select="imf:create-debug-comment(concat('OAS18000, id: ',$id),$debugging)" />

		<ep:construct>
			<ep:name><xsl:value-of select="$construct/imvert:name/@original"/></ep:name>
			<ep:ref><xsl:value-of select="$tech-name"/></ep:ref>
		</ep:construct>

	</xsl:template>

	<xsl:template match="ep:superconstruct" mode="as-content">
		<xsl:param name="berichtcode"/>
		<xsl:param name="messagetype"/>
		
		<xsl:variable name="id" select="ep:id" />
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name($construct/imvert:name, 'type-name')" as="xs:string" />


		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation($construct,'CFG-TV-DEFINITION')))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation($construct,'CFG-TV-DEFINITION')"/>
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation($construct,'CFG-TV-DESCRIPTION')))">
				<ep:description>
					<xsl:sequence select="imf:merge-documentation($construct,'CFG-TV-DESCRIPTION')"/>
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

		<xsl:sequence select="imf:create-debug-comment(concat('OAS18500, id: ',$id),$debugging)" />
		
		<ep:construct  type="superclass" berichtcode="{$berichtcode}" messagetype="{$messagetype}">
			<ep:name><xsl:value-of select="$construct/imvert:name/@original"/></ep:name>
			<ep:tech-name><xsl:value-of select="$tech-name"/></ep:tech-name>
			<xsl:choose>
				<xsl:when test="(empty($doc) or $doc='') and $debugging">
					<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
				</xsl:otherwise>
			</xsl:choose>
			<ep:seq>
				<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
				<xsl:apply-templates select="ep:superconstruct" mode="as-ref">
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="ep:construct" mode="as-content" >
					<xsl:with-param name="berichtcode" select="$berichtcode"/>
					<xsl:with-param name="messagetype" select="$messagetype"/>
				</xsl:apply-templates>
			</ep:seq>
		</ep:construct>
		
	</xsl:template>
	
	<!-- This template processes al ep:constructs refered to from the ep:message constructs and refered to from these constructs itself. -->
	<xsl:template match="ep:construct" mode="as-type">
		<xsl:param name="berichtcode"/>
		<xsl:param name="messagetype"/>

		<xsl:sequence select="imf:create-debug-comment(concat('OAS19000, tech-name: ',ep:tech-name),$debugging)" />
		
		<xsl:variable name="name" select="ep:name" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(ep:tech-name, 'element-name')" as="xs:string" />
		<xsl:variable name="id" select="ep:id" />
		<xsl:variable name="type-id" select="ep:type-id" />
		<xsl:variable name="construct">
			<xsl:choose>
				<xsl:when test="not(empty($type-id))">
					<xsl:variable name="this-construct" select="imf:get-construct-by-id($type-id,$packages)" />
					<xsl:sequence select="$this-construct" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="this-construct" select="imf:get-construct-by-id($id,$packages)" />
					<xsl:sequence select="$this-construct" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="empty($id) and empty($type-id)">
				<xsl:variable name="msg" select="concat('Het construct ',$name,' heeft geen id en geen type-id.')" as="xs:string" />
				<xsl:sequence select="imf:msg('WARNING',$msg)" />
			</xsl:when>
			<xsl:otherwise>
<?x                <xsl:result-document href="{concat('file:/c:/temp/construct-',$name,'-',generate-id(),'.xml')}">
                    <xsl:sequence select="$construct"/>
                </xsl:result-document> ?>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="doc">
			<xsl:choose>
				<xsl:when test="not(empty($type-id))">
					<xsl:variable name="this-construct" select="$packages//imvert:*[imvert:id = $type-id]" />
					<xsl:if test="not(empty(imf:merge-documentation($this-construct,'CFG-TV-DEFINITION')))">
						<ep:definition>
							<xsl:sequence select="imf:merge-documentation($this-construct,'CFG-TV-DEFINITION')" />
						</ep:definition>
					</xsl:if>
					<xsl:if test="not(empty(imf:merge-documentation($this-construct,'CFG-TV-DESCRIPTION')))">
						<ep:description>
							<xsl:sequence select="imf:merge-documentation($this-construct,'CFG-TV-DESCRIPTION')" />
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
					<xsl:if test="not(empty(imf:merge-documentation($this-construct,'CFG-TV-DEFINITION')))">
						<ep:definition>
							<xsl:sequence select="imf:merge-documentation($this-construct,'CFG-TV-DEFINITION')" />
						</ep:definition>
					</xsl:if>
					<xsl:if test="not(empty(imf:merge-documentation($this-construct,'CFG-TV-DESCRIPTION')))">
						<ep:description>
							<xsl:sequence select="imf:merge-documentation($this-construct,'CFG-TV-DESCRIPTION')" />
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
			<!-- ep:constructs of type 'association-class' aren't processed at all. 
				The content of that kind of constructs is already embedded within its parents constructs. -->
			<xsl:when test="@type='association-class'" />
			<xsl:when test="@type='association' and ep:construct[@type='subclass']">
				<xsl:variable name="type-id" select="ep:type-id" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($type-id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				
				<xsl:sequence select="imf:create-debug-comment(concat('OAS19250, id: ',$id),$debugging)" />
				<ep:construct>
					<xsl:attribute name="type" select="@type" />
					<xsl:attribute name="berichtcode" select="$berichtcode" />
					<xsl:attribute name="messagetype" select="$messagetype" />
					<xsl:sequence select="imf:create-output-element('ep:name', $type-name/@original)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name(concat($type-name,'-association'), 'type-name'))" />
					
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:choice>
						<xsl:apply-templates select="ep:construct" mode="as-content" />
					</ep:choice>
				</ep:construct>
				
			</xsl:when>
			<!-- TODO: Nagaan of er situaties zijn dat een association terecht geen attributes en associations heeft. -->
			<xsl:when test="@type='association' and not($construct//imvert:attributes/imvert:attribute) and not($construct//imvert:associations/imvert:association)">
				<xsl:sequence select="imf:create-debug-comment(concat('OAS19500, id: ',$id),$debugging)" />
				<xsl:variable name="class-name" select="$construct/imvert:class/imvert:name/@original"/>
				<xsl:sequence select="imf:msg($construct,'WARNING','The construct [1] does not have attributes or associations.',($class-name))"/>
			</xsl:when>

			<!-- TODO: De naam van associations moet waarschijnlijk vervangen worden door de source en/of target role naam in meervoud. 
				 Op deze wijze levert onderstaande when echter geen goed resultaat op. -->
			<xsl:when test="@type='association' and $construct//imvert:attributes/imvert:attribute">
				<xsl:sequence select="imf:create-debug-comment(concat('OAS20000, id: ',$id),$debugging)" />
<?x                <xsl:copy>
                    <xsl:attribute name="type" select="@type"/>
                    <xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
                    <xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($tech-name,'type-name'))"/>      
                    <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                    <ep:seq>
                        <xsl:sequence select="imf:create-debug-comment(concat('OAS20500, id: ',$id),$debugging)"/>
                        <xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute"/>
                        <xsl:sequence select="imf:create-debug-comment(concat('OAS21000, id: ',$id),$debugging)"/>                   
                        <xsl:apply-templates select="ep:superconstruct" mode="as-content"/>
                        <xsl:sequence select="imf:create-debug-comment(concat('OAS21500, id: ',$id),$debugging)"/>
                        <xsl:apply-templates select="ep:construct[@type!='class']" mode="as-content"/>
                        <xsl:sequence select="imf:create-debug-comment(concat('OAS22000, id: ',$id),$debugging)"/>
                    </ep:seq>
                </xsl:copy> ?>
			</xsl:when>
			<!-- if the ep:constructs is of 'groepCompositie' ..... -->
			<xsl:when test="@type = 'groepCompositie'">
				<xsl:sequence select="imf:create-debug-comment(concat('OAS22500, id: ',$id),$debugging)" />
				<xsl:variable name="type" select="@type" />
				<xsl:variable name="complex-datatype-tech-name" select="$construct/imvert:class/imvert:name" />
				<xsl:copy>
					<xsl:attribute name="type" select="$type" />
					<xsl:attribute name="berichtcode" select="$berichtcode" />
					<xsl:attribute name="messagetype" select="$messagetype" />
					<xsl:sequence select="imf:create-output-element('ep:name', $complex-datatype-tech-name/@original)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($complex-datatype-tech-name,'type-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:seq>
						<xsl:sequence select="imf:create-debug-comment(concat('OAS23000, id: ',$id),$debugging)" />
						<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
						<xsl:sequence select="imf:create-debug-comment(concat('OAS23500, id: ',$id),$debugging)" />
						<xsl:apply-templates select="ep:superconstruct" mode="as-ref" />
						<xsl:sequence select="imf:create-debug-comment(concat('OAS24000, id: ',$id),$debugging)" />
						<xsl:apply-templates select="ep:construct[@type!='class']" mode="as-content" >
							<xsl:with-param name="berichtcode" select="$berichtcode"/>
							<xsl:with-param name="messagetype" select="$messagetype"/>
						</xsl:apply-templates>
						
						<!-- TODO: Nagaan of er in een complex-datatype type ep:construct geen associations voor kunnen komen. 
							 Indien dat wel het geval is dan moet hier ook een apply-templates komen op een ep:construct en moet ook het rough-messages stylesheets 
							 daar rekening mee houden. -->
					</ep:seq>
				</xsl:copy>
			</xsl:when>
			<!-- if the ep:constructs itself has a ep:construct or ep:superconstruct or if it is of type 'class' and that class has attributes it is processed here. 
				 The ep:construct is replicated and ep:constructs for imvert:attributes related to that construct are placed. 
				 Also the child ep:superconstructs and ep:constructs (if present) are processed. -->
			<!--xsl:when test="ep:construct or ep:superconstruct or ((@type='class' or @type='requestclass') and $construct//imvert:attributes/imvert:attribute)"-->
			<xsl:when test="ep:construct or ep:superconstruct or @type='class' or @type='requestclass'">
				<xsl:sequence select="imf:create-debug-comment(concat('OAS24500, id: ',$id),$debugging)" />
				<xsl:variable name="classconstruct" select="imf:get-construct-by-id($id,$packages)" />
				<xsl:variable name="type-name" select="$classconstruct/imvert:name" />
				

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
				<xsl:copy>
					<xsl:attribute name="type" select="$type" />
					<xsl:attribute name="berichtcode" select="$berichtcode" />
					<xsl:attribute name="messagetype" select="$messagetype" />
					<xsl:variable name="messagename" select="ancestor::ep:rough-message/ep:name"/>
					
					<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
					<xsl:if test="not(ep:superconstruct) and not(@type='groepCompositie') and not(ancestor::ep:*[@type='groepCompositie'])">
						<xsl:variable name="meervoudigeNaam">
							<xsl:variable name="tvMeervoudigeNaam" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-NAMEPLURAL')"/>
							<xsl:choose>
								<xsl:when test="string-length($tvMeervoudigeNaam) = 0">
									<xsl:sequence select="imf:msg(.,'WARNING','The construct [1] within message [2] does not have a tagged value naam in meervoud, define one.',($construct/imvert:name,$messagename))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="$tvMeervoudigeNaam"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable> 
						<xsl:if test="$meervoudigeNaam != ''">
							<xsl:attribute name="meervoudigeNaam" select="$meervoudigeNaam" />
						</xsl:if>
					</xsl:if>					
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name1', imf:get-normalized-name($tech-name,'type-name'))" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($classconstruct/imvert:name, 'type-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:seq>
						<!--xsl:result-document href="{concat('file:/c:/temp/construct-',$name,'-',generate-id(),'.xml')}"> 
							<xsl:copy-of select="$construct"/> 
						</xsl:result-document -->
						<xsl:if test="@type=('class','requestclass')">
							<xsl:sequence select="imf:create-debug-comment(concat('OAS25000, id: ',$id),$debugging)" />
							<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
						</xsl:if>
						<xsl:sequence select="imf:create-debug-comment(concat('OAS25500, id: ',$id),$debugging)" />
						<xsl:apply-templates select="ep:superconstruct" mode="as-ref" />
						<xsl:sequence select="imf:create-debug-comment(concat('OAS26000, id: ',$id),$debugging)" />
						<xsl:apply-templates select="ep:construct[@type!='class']" mode="as-content" >
							<xsl:with-param name="berichtcode" select="$berichtcode"/>
							<xsl:with-param name="messagetype" select="$messagetype"/>
						</xsl:apply-templates>
						
						
						
						
						
						
						<!--xsl:apply-templates select="ep:construct[@type='class']" mode="as-content" >
							<xsl:with-param name="berichtcode" select="$berichtcode"/>
							<xsl:with-param name="messagetype" select="$messagetype"/>
						</xsl:apply-templates-->
						
						
						
						
						
						<xsl:sequence select="imf:create-debug-comment(concat('OAS26500, id: ',$id),$debugging)" />
					</ep:seq>
				</xsl:copy>
			</xsl:when>
			<!-- if the ep:constructs is of 'complex-datatype' type its name differs from the one in the when above. 
				 It's name isn't based on the attribute using the type since it is more generic and used by more than one ep:construct. -->
			<xsl:when test="@type = 'complex-datatype'">
				<xsl:sequence select="imf:create-debug-comment(concat('OAS27000, id: ',$id),$debugging)" />
				<xsl:variable name="type" select="@type" />
				<xsl:variable name="complex-datatype-tech-name" select="$construct/imvert:class/imvert:name" />
				<xsl:copy>
					<xsl:attribute name="type" select="$type" />
					<xsl:attribute name="berichtcode" select="$berichtcode" />
					<xsl:attribute name="messagetype" select="$messagetype" />
					<xsl:sequence select="imf:create-output-element('ep:name', $construct/imvert:class/imvert:name/@original)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($complex-datatype-tech-name,'type-name'))" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<ep:seq>
						<xsl:sequence select="imf:create-debug-comment(concat('OAS27500, id: ',$id),$debugging)" />
						<xsl:apply-templates select="$construct//imvert:attributes/imvert:attribute" />
						<xsl:sequence select="imf:create-debug-comment(concat('OAS28000, id: ',$id),$debugging)" />
						<xsl:apply-templates select="ep:superconstruct" mode="as-ref" />

						<!-- TODO: Nagaan of er in een complex-datatype type ep:construct geen associations voor kunnen komen. 
							 Indien dat wel het geval is dan moet hier ook een apply-templates komen op een ep:construct en moet ook het rough-messages stylesheets 
							 daar rekening mee houden. -->
					</ep:seq>
				</xsl:copy>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- All imvert:attribute elements found in the classes refered to are processed here. -->
	<xsl:template match="imvert:attribute">
		<xsl:variable name="name" select="imvert:name/@original" as="xs:string" />
		<xsl:variable name="tech-name" select="imf:get-normalized-name(imvert:name, 'element-name')" as="xs:string" />
		<xsl:variable name="id" select="imvert:id"/>
		<xsl:variable name="is-id" select="imvert:is-id"/>
		<xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)" />
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation($construct,'CFG-TV-DEFINITION')))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation($construct,'CFG-TV-DEFINITION')" />
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation($construct,'CFG-TV-DESCRIPTION')))">
				<ep:description>
					<xsl:sequence select="imf:merge-documentation($construct,'CFG-TV-DESCRIPTION')" />
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
		<xsl:variable name="example" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-EXAMPLE')" />

		<xsl:variable name="suppliers" as="element(ep:suppliers)">
			<ep:suppliers>
				<xsl:copy-of select="imf:get-UGM-suppliers(.)" />
			</ep:suppliers>
		</xsl:variable>
		<xsl:variable name="tvs" as="element(ep:tagged-values)">
			<ep:tagged-values>
				<xsl:copy-of select="imf:get-compiled-tagged-values(., true())" />
			</ep:tagged-values>
		</xsl:variable>

		<xsl:variable name="type-is-GM-external" select="exists(imvert:conceptual-schema-type) and contains(imvert:conceptual-schema-type,'GM_')"/>		

		<xsl:choose>
			<xsl:when test="$type-is-GM-external">
				<ep:construct>
					<xsl:attribute name="type" select="'GM-external'"/>
					<xsl:sequence select="imf:create-debug-comment(concat('OAS28500, id: ',imvert:id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
				</ep:construct>
			</xsl:when>
			<!-- Attributes of complex datatype type are not resolved within this template but with one of the ep:construct templates since they are present 
				 within the rough message structure. -->
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]/imvert:id">
				<xsl:sequence select="imf:create-debug-comment(concat('OAS29000, id: ',imvert:id),$debugging)" />
			</xsl:when>
			<!-- The content of ep:constructs based on attributes which refer to a tabelentiteit is determined by the imvert:attribute in that tabelentiteit class 
				 which serves as a unique key. So it get all properties of that unique key. -->
			<xsl:when test="imvert:type-id and imvert:type-id = $packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]/imvert:id">
				<xsl:variable name="type-id" select="imvert:type-id" />
				<xsl:variable name="tabelEntiteit">
					<xsl:sequence select="$packages//imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst') and imvert:id = $type-id]" />
				</xsl:variable>
				<!--ep:construct type="attribute" -->
				<xsl:choose>
					<xsl:when test="not($tabelEntiteit//imvert:attribute[imvert:is-id = 'true'])">
						<xsl:variable name="msg" select="concat('The &quot;tabelenitiet&quot; ',$tabelEntiteit/imvert:name,'does not have an attribute defined as an id.')" />
						<xsl:sequence select="imf:msg('WARNING', $msg)" />
					</xsl:when>
					<xsl:otherwise>
						<ep:construct>
							<xsl:if test="$is-id = 'true'">
								<xsl:attribute name="is-id" select="'true'"/>
							</xsl:if>
							<xsl:sequence select="imf:create-debug-comment(concat('OAS29500, id: ',imvert:id),$debugging)" />
							<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
							<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
							<xsl:choose>
								<xsl:when test="(empty($doc) or $doc='') and $debugging">
									<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
								</xsl:otherwise>
							</xsl:choose>
							<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
							<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
							<xsl:sequence select="imf:create-output-element('ep:data-type', $tabelEntiteit//imvert:attribute[imvert:is-id = 'true']/imvert:type-name)" />

							<xsl:variable name="max-length" select="$tabelEntiteit//imvert:attribute[imvert:is-id = 'true']/imvert:max-length" />
							<xsl:variable name="total-digits" select="$tabelEntiteit//imvert:attribute[imvert:is-id = 'true']/imvert:total-digits" />
							<xsl:variable name="fraction-digits" select="$tabelEntiteit//imvert:attribute[imvert:is-id = 'true']/imvert:fraction-digits" />
							<xsl:variable name="min-waarde" select="imf:get-tagged-value($tabelEntiteit//imvert:attribute[imvert:is-id = 'true'],'##CFG-TV-MINVALUEINCLUSIVE')" />
							<xsl:variable name="max-waarde" select="imf:get-tagged-value($tabelEntiteit//imvert:attribute[imvert:is-id = 'true'],'##CFG-TV-MAXVALUEINCLUSIVE')" />
							<xsl:variable name="min-length" select="xs:integer(imf:get-tagged-value($tabelEntiteit//imvert:attribute[imvert:is-id = 'true'],'##CFG-TV-MINLENGTH'))" />
							<xsl:variable name="pattern" select="$tabelEntiteit//imvert:attribute[imvert:is-id = 'true']/imvert:pattern" />

							<xsl:sequence select="imf:create-output-element('ep:max-length', $max-length)" />
							<!--xsl:sequence select="imf:create-output-element('ep:total-digits', $total-digits)"/> 
							<xsl:sequence select="imf:create-output-element('ep:fraction-digits', $fraction-digits)"/ -->
							<xsl:sequence select="imf:create-output-element('ep:min-value', $min-waarde)" />
							<xsl:sequence select="imf:create-output-element('ep:max-value', $max-waarde)" />
							<!--xsl:sequence select="imf:create-output-element('ep:min-length', $min-length)"/ -->
							<xsl:sequence select="imf:create-output-element('ep:pattern', $pattern)" />
							<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
						</ep:construct>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- imvert:attribute having an imvert:type-id result in an ep:construct which refers to a global ep:construct. This is for example the case 
				 when it's an attribute with a enumeration type. -->
			<xsl:when test="imvert:type-id">
				<!--ep:construct type="attribute" -->
				<ep:construct>
					<xsl:if test="$is-id = 'true'">
						<xsl:attribute name="is-id" select="'true'"/>
					</xsl:if>
					<xsl:sequence select="imf:create-debug-comment(concat('OAS30000, id: ',imvert:id),$debugging)" />
					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:type-name', imf:get-normalized-name(imvert:type-name,'type-name'))" />
					<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
				</ep:construct>
			</xsl:when>
			<!-- In all other cases the imvert:attribute itself and its properties are processed. -->
			<xsl:otherwise>
				<!--ep:construct type="attribute" -->
				<ep:construct>
					<xsl:if test="$is-id = 'true'">
						<xsl:attribute name="is-id" select="'true'"/>
					</xsl:if>
					<xsl:sequence select="imf:create-debug-comment(concat('OAS30500, id: ',imvert:id),$debugging)" />
					<xsl:if test="$debugging">
						<ep:suppliers>
							<xsl:copy-of select="$suppliers" />
						</ep:suppliers>
						<ep:tagged-values>
							<xsl:copy-of select="$tvs" />
							<ep:found-tagged-values>
								<xsl:choose>
									<xsl:when test="(empty($doc) or $doc='') and $debugging">
										<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
									</xsl:otherwise>
								</xsl:choose>
							</ep:found-tagged-values>
						</ep:tagged-values>
					</xsl:if>


					<xsl:sequence select="imf:create-output-element('ep:name', $name)" />
					<xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)" />
					<xsl:choose>
						<xsl:when test="(empty($doc) or $doc='') and $debugging">
							<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:sequence select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)" />
					<xsl:sequence select="imf:create-output-element('ep:data-type', imvert:type-name)" />

					<xsl:variable name="max-length" select="imvert:max-length" />
					<xsl:variable name="total-digits" select="imvert:total-digits" />
					<xsl:variable name="fraction-digits" select="imvert:fraction-digits" />
					<xsl:variable name="min-value" select="imf:get-tagged-value(.,'##CFG-TV-MINVALUEINCLUSIVE')" />
					<xsl:variable name="max-value" select="imf:get-tagged-value(.,'##CFG-TV-MAXVALUEINCLUSIVE')" />
					<xsl:variable name="min-length" select="xs:integer(imf:get-tagged-value(.,'##CFG-TV-MINLENGTH'))" />
					<xsl:variable name="pattern" select="imvert:pattern" />

					<xsl:sequence select="imf:create-output-element('ep:max-length', $max-length)" />
					<!--xsl:sequence select="imf:create-output-element('ep:total-digits', $total-digits)" />
					<xsl:sequence select="imf:create-output-element('ep:fraction-digits', $fraction-digits)" /-->
					<xsl:sequence select="imf:create-output-element('ep:min-value', $min-value)" />
					<xsl:sequence select="imf:create-output-element('ep:max-value', $max-value)" />
					<!--xsl:sequence select="imf:create-output-element('ep:min-length', $min-length)" /-->
					<xsl:sequence select="imf:create-output-element('ep:pattern', $pattern)" />
					<xsl:sequence select="imf:create-output-element('ep:example', $example)" />
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Following template creates global ep:constructs for enumeration/ -->
	<!-- TODO: Op dit moment worden alle enumerations, ook al worden ze niet gebruikt, omgezet naar ep:constructs. 
			   Hoewel de niet gebruikte er in de volgdende stap uitgefilterd worden zou het netjes zijn ze al niet in het EP bestand te genereren. 
			   Die taak moet nog een keer worden uitgevoerd. -->
	<xsl:template match="imvert:class" mode="mode-global-enumeration">
		<xsl:sequence select="imf:create-debug-comment('OAS31000',$debugging)" />
		<xsl:variable name="compiled-name" select="imf:get-compiled-name(.)" />
		<xsl:variable name="doc">
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DEFINITION')))">
				<ep:definition>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DEFINITION')" />
				</ep:definition>
			</xsl:if>
			<xsl:if test="not(empty(imf:merge-documentation(.,'CFG-TV-DESCRIPTION')))">
				<ep:description>
					<xsl:sequence select="imf:merge-documentation(.,'CFG-TV-DESCRIPTION')" />
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
					<xsl:sequence select="imf:create-output-element('ep:documentation', 'Documentatie (nog) niet kunnen achterhalen.','',false(),false())" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())" />
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-string')" />
			<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-enum" />
		</ep:construct>
	</xsl:template>

	<xsl:template match="imvert:attribute" mode="mode-local-enum">
		<xsl:sequence select="imf:create-debug-comment('OAS32000',$debugging)" />

		<!-- STUB De naam van een enumeratie is die overgenomen uit SIM. Niet camelcase. Vooralsnog ook daar ophalen. -->

		<xsl:variable name="supplier" select="imf:get-trace-suppliers-for-construct(.,1)[@project='SIM'][1]" />
		<xsl:variable name="construct" select="if ($supplier) then imf:get-trace-construct-by-supplier($supplier,$imvert-document) else ()" />
		<xsl:variable name="SIM-name" select="($construct/imvert:name, imvert:name)[1]" />
		<xsl:variable name="SIM-alias" select="($construct/imvert:alias, imvert:alias)[1]" />

		<ep:enum>
			<!-- ROME: I.v.m. het project Zaak- Document Services is besloten om de waarde in een enumeration te plaatsen en niet de codes.
					   Voor het geval daarop wordt teruggekomen is de XSLT-code voor het opnemen van de code bewaard. -->
			<xsl:value-of select="$SIM-name" />
			<!--xsl:choose>
				<xsl:when test="empty($SIM-alias)">
					<xsl:value-of select="$SIM-name" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$SIM-alias" />
				</xsl:otherwise>
			</xsl:choose-->
		</ep:enum>

	</xsl:template>

	<!-- This function merges all documentation from the highest layer up to the current layer. -->
	<xsl:function name="imf:merge-documentation">
		<xsl:param name="this" />
		<xsl:param name="tv-id" />


		<xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,false())" />
		<xsl:variable name="vals" select="$all-tv[@id = $tv-id]" />
		<xsl:for-each select="$vals">
			<xsl:variable name="p" select="normalize-space(imf:get-clean-documentation-string(imf:get-tv-value.local(.)))" />
			<xsl:if test="not($p = '')">
				<ep:p subpath="{imf:get-subpath(@project,@application,@nrelease)}">
					<xsl:value-of select="$p" />
				</ep:p>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="imf:get-tv-value.local">
		<xsl:param name="tv-element" as="element(tv)?" />
		<xsl:value-of select="if (normalize-space($tv-element/@original-value)) then $tv-element/@original-value else $tv-element/@value" />
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
		<xsl:param name="this" as="element()" />
		<xsl:variable name="type" select="local-name($this)" />
		<xsl:variable name="stereotype" select="imf:get-stereotype($this)" />
		<xsl:variable name="alias" select="$this/imvert:alias" />
		<xsl:variable name="name-raw" select="$this/imvert:name" />
		<xsl:variable name="name-form" select="replace(imf:strip-accents($name-raw),'[^\p{L}0-9.\-]+','_')" />

		<xsl:variable name="name" select="$name-form" />

		<xsl:choose>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-composite')">
				<xsl:value-of select="concat(imf:capitalize($name),'Grp')" />
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-objecttype')">
				<xsl:value-of select="$alias" />
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-relatieklasse')">
				<xsl:value-of select="$alias" />
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-referentielijst')">
				<xsl:value-of select="$alias" />
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-complextype')">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-enumeration')">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-union')">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-interface')">
				<!-- this must be an external -->
				<xsl:variable name="external-name" select="imf:get-external-type-name($this,true())" />
				<xsl:value-of select="$external-name" />
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-attribute')">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-referentie-element')">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-data-element')">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-enum')">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'attribute' and $stereotype = ('stereotype-name-union-element')">
				<xsl:value-of select="imf:useable-attribute-name($name,$this)" />
			</xsl:when>
			<xsl:when test="$type = 'association' and $stereotype = ('stereotype-name-relatiesoort') and normalize-space($alias)">
				<!-- if this relation occurs multiple times, add the alias of the target object -->
				<xsl:value-of select="$alias" />
			</xsl:when>
			<xsl:when test="$type = 'association' and $this/imvert:aggregation = 'composite'">
				<xsl:value-of select="$name" />
			</xsl:when>
			<xsl:when test="$type = 'association' and $stereotype = ('stereotype-name-relatiesoort')">
				<xsl:sequence select="imf:msg($this,'ERROR','No alias',())" />
				<xsl:value-of select="lower-case($name)" />
			</xsl:when>
			<xsl:when test="$type = 'association' and normalize-space($alias)"> <!-- composite -->
				<xsl:value-of select="$alias" />
			</xsl:when>
			<xsl:when test="$type = 'association'">
				<xsl:sequence select="imf:msg($this,'ERROR','No alias',())" />
				<xsl:value-of select="lower-case($name)" />
			</xsl:when>
			<!-- TODO meer soorten namen uitwerken? -->
			<xsl:otherwise>
				<xsl:sequence select="imf:msg($this,'ERROR','Unknown type [1] with stereo [2]', ($type, string-join($stereotype,', ')))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="imf:useable-attribute-name">
		<xsl:param name="name" as="xs:string" />
		<xsl:param name="attribute" as="element(imvert:attribute)" />
		<xsl:choose>
			<xsl:when test="empty($attribute/imvert:type-id) and exists($attribute/imvert:baretype) and count($all-simpletype-attributes[imvert:name = $attribute/imvert:name]) gt 1">
				<!--xx <xsl:message select="concat($attribute/imvert:name, ';', $attribute/@display-name)"/> xx -->
				<xsl:value-of select="concat($name,$attribute/../../imvert:alias)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
