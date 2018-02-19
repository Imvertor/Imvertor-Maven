<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id:  Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $ 
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    
    xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" 
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/extension/Imvert-common-text.xsl"/>   
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-enrich-excel.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-create-endproduct-structure.xsl"/>

    <xsl:include href="Imvert2XSD-KING-common-checksum.xsl"/>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:key name="class" match="imvert:class" use="imvert:id" />
    <xsl:key name="enumerationClass" match="imvert:class" use="imvert:name" />
    <!-- This key is used within the for-each instruction further in this code. -->
    <xsl:key name="construct-id" match="ep:construct" use="concat(ep:id,@verwerkingsModus)" />
    <xsl:key name="construct-id-in-vrijbericht" match="ep:construct" use="concat(ep:id,@verwerkingsModus,@entiteitOrBerichtRelatie)" />
    <!--xsl:key name="construct-id-and-name" match="ep:construct" use="concat(ep:id,ep:name)" /-->
    
    
    <xsl:variable name="stylesheet-code" as="xs:string">SKS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
    
    <xsl:variable name="stylesheet" as="xs:string">Imvert2XSD-KING-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version" as="xs:string">$Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $</xsl:variable>  

    <xsl:variable name="StUF-prefix" select="'StUF'"/>   
    <xsl:variable name="StUF-namespaceIdentifier" select="'http://www.stufstandaarden.nl/onderlaag/stuf0302'"/>
    <xsl:variable name="GML-prefix" select="'gml'"/>
    
    <xsl:variable name="config-schemarules">
        <xsl:sequence select="imf:get-config-schemarules()"/>
    </xsl:variable> 
    <xsl:variable name="config-tagged-values">
        <xsl:sequence select="imf:get-config-tagged-values()"/>
    </xsl:variable> 

    <!-- Within the next variable the configurations defined within the Base-configuration spreadsheet are placed in a processed XML format.
         With this configuration the attributes to be used on each location within the XML schemas are determined. -->
    <xsl:variable name="enriched-endproduct-base-config-excel">
        <result>
            <xsl:if test="empty($endproduct-base-config-excel)">
                <xsl:message select="concat('ERROR  ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The variable $endproduct-base-config-excel is empty so the Excel with the base configuration can not be found.')"/>								
            </xsl:if>
             <xsl:choose> 
                <xsl:when test="ends-with(lower-case($endproduct-base-config-excel),'.xlsx')">
                    <!-- excel based on OO-XML -->
                    <xsl:for-each select="$content-doc/files/file/ss:worksheet">
                        <xsl:variable name="worksheet">
                            <xsl:apply-templates select="." mode="resolve-strings"/>
                        </xsl:variable>
                        <!-- OO-XML is an XML format. Preproces that format if needed. -->
                        <xsl:sequence select="$worksheet"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="ends-with(lower-case($endproduct-base-config-excel),'.xls')">
                    <!-- excel 97-2003 --> 
                    <xsl:variable name="xml-path" select="imf:serializeExcel($endproduct-base-config-excel,concat($workfolder-path,'/excel.xml'))"/>
                    <xsl:variable name="xml-doc" select="imf:document($xml-path, true())"/>
                    
                    <!-- excel 97-2003 is'nt an XML format. Using the above variables the format is translated to XML.
                         The XML format then is processed to be able to use it. -->
                    <xsl:apply-templates select="$xml-doc/workbook"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg('WARNING','No or not a known endproduct base configuration excel file: [1] ', ($endproduct-base-config-excel))"/>
                </xsl:otherwise>
            </xsl:choose>
        </result>
    </xsl:variable>
    
    <xsl:variable name="packages-doc" select="/"/>
    <xsl:variable name="packages" select="$packages-doc/imvert:packages"/>
    
    <!-- needed for disambiguation of duplicate attribute names -->
    <xsl:variable name="all-simpletype-attributes" select="//imvert:attribute[empty(imvert:type)]"/> 

    <!-- ROME: Het betreft hier de verkorte alias van het koppelvlak. Eerste variabele moet nog vervangen worden door de tweede. -->
    <xsl:variable name="verkorteAlias" select="imf:get-tagged-value($packages,'##CFG-TV-VERKORTEALIAS')"/>
    <xsl:variable name="kv-prefix" select="imf:get-tagged-value($packages,'##CFG-TV-VERKORTEALIAS')"/>
    <xsl:variable name="global-empty-enumeration-allowed">
        <xsl:choose>
            <xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-EMPTYENUMERATIONALLOWED'))">
                <xsl:value-of select="'Ja'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-EMPTYENUMERATIONALLOWED')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="global-noValue-allowed">
        <xsl:choose>
            <xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-NOVALUEALLOWED'))">
                <xsl:value-of select="'Ja'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-NOVALUEALLOWED')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="global-e-types-allowed">
        <xsl:choose>
            <xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-E-TYPESALLOWED'))">
                <xsl:value-of select="'Ja'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-E-TYPESALLOWED')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="global-tijdvakGeldigheid-allowed">
        <xsl:choose>
            <xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-TIJDVAKGELDIGHEIDALLOWED'))">
                <xsl:value-of select="'Leeg'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-TIJDVAKGELDIGHEIDALLOWED')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="global-tijdstipRegistratie-allowed">
        <xsl:choose>
            <xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-TIJDSTIPREGISTRATIEALLOWED'))">
                <xsl:value-of select="'Leeg'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-TIJDSTIPREGISTRATIEALLOWED')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="global-extraElementen-allowed">
        <xsl:choose>
            <xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-EXTRAELEMENTENALLOWED'))">
                <xsl:value-of select="'Ja'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-EXTRAELEMENTENALLOWED')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="global-aanvullendeElementen-allowed">
        <xsl:choose>
            <xsl:when test="empty(imf:get-tagged-value($packages,'##CFG-TV-AANVULLENDEELEMENTENALLOWED'))">
                <xsl:value-of select="'Ja'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-tagged-value($packages,'##CFG-TV-AANVULLENDEELEMENTENALLOWED')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="enriched-rough-messages" select="imf:document(imf:get-config-string('properties','ENRICHED_ROUGH_ENDPRODUCT_XML_FILE_PATH'))"/>  
    
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

    <xsl:variable name="namespaceIdentifier" select="$packages/imvert:base-namespace"/>
    
    <xsl:variable name="version" select="$packages/imvert:version"/>
    
    <xsl:variable name="ep-onderlaag-path" select="imf:get-config-string('properties','KINGBSM_EPFORMAAT_XMLPATH')"/>
    <xsl:variable name="ep-onderlaag" select="imf:document($ep-onderlaag-path,true())/ep:message-set"/>

    <!-- Within this variable all messages defined within the BSM of the koppelvlak are transformed to the imvertor endproduct (ep) format.-->
    <xsl:variable name="constructs-ep-onderlaag">
        <xsl:apply-templates select="$ep-onderlaag/ep:construct" mode="replicate-ep-structure"/>
    </xsl:variable>
    
    <xsl:variable name="endproduct">
        <ep:message-set global-empty-enumeration-allowed="{$global-empty-enumeration-allowed}">
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 1',$debugging)"/>
            
            <xsl:sequence select="imf:create-output-element('ep:name', $packages/imvert:application)"/>
            <xsl:sequence select="imf:create-output-element('ep:release', $packages/imvert:release)"/>
            <xsl:sequence select="imf:create-output-element('ep:date', substring-before($packages/imvert:generated,'T'))"/>
            <xsl:sequence select="imf:create-output-element('ep:patch-number', 'TO-DO')"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace', $packages/imvert:base-namespace)"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $prefix)"/>
            <xsl:sequence  select="imf:create-output-element('ep:version', $version)"/>
            
            <!-- ROME: Volgende structuur moet, zodra we meerdere namespaces volledig ondersteunen, afgeleid worden van alle in gebruik zijnde namespaces.
                       Ik vraag me dus af of ook de $prefix variabele meerdere prefixes moet kunnen omvatten. 
                       Ik denk van niet, eerder zal de onderstaande lijst met namespaces uitgebreid moeten worden door per package deze op te halen. -->
            <ep:namespaces>
                <ep:namespace prefix="StUF">http://www.stufstandaarden.nl/onderlaag/stuf0302</ep:namespace>
                <ep:namespace prefix="xsi">http://www.w3.org/2001/XMLSchema-instance</ep:namespace>
                <ep:namespace prefix="{$prefix}"><xsl:value-of select="$packages/imvert:base-namespace"/></ep:namespace>
            </ep:namespaces>
            
            <xsl:if test="$debugging">
                <xsl:sequence select="imf:debug-document($config-schemarules,'imvert-schema-rules.xml',true(),false())"/>
                <xsl:sequence select="imf:debug-document($config-tagged-values,'imvert-tagged-values.xml',true(),false())"/>
                <xsl:sequence select="imf:debug-document($enriched-endproduct-base-config-excel,'enriched-endproduct-base-config-excel.xml',true(),false())"/>
            </xsl:if>
            
            <xsl:sequence select="imf:track('Constructing the messages')"/>
            
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 1a',$debugging)"/>
            <xsl:sequence select="$constructs-ep-onderlaag"/>
            
            <xsl:for-each select="$enriched-rough-messages/ep:rough-messages/ep:rough-message">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2',$debugging)"/>
                
                <xsl:variable name="currentMessage" select="."/>
                <xsl:variable name="id" select="ep:id" as="xs:string"/>
                <xsl:variable name="message-construct" select="imf:get-class-construct-by-id($id,$packages-doc)"/>
                <xsl:variable name="berichtstereotype" select="$message-construct/imvert:stereotype"/>
                <xsl:variable name="berichtSoort" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$berichtstereotype/@id = ('stereotype-name-vraagberichttype')">Vraagbericht</xsl:when>
                        <xsl:when test="$berichtstereotype/@id = ('stereotype-name-antwoordberichttype')">Antwoordbericht</xsl:when>
                        <xsl:when test="$berichtstereotype/@id = ('stereotype-name-kennisgevingberichttype')">Kennisgevingbericht</xsl:when>
                        <xsl:when test="$berichtstereotype/@id = ('stereotype-name-vrijberichttype')">Vrij bericht</xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="berichtCode" select="imf:get-tagged-value($message-construct,'##CFG-TV-BERICHTCODE')" as="xs:string"/>
                <xsl:variable name="serviceName" select="imf:get-tagged-value($message-construct,'##CFG-TV-SERVICENAME')" as="xs:string"/>
                <xsl:variable name="messageType" select="imf:get-tagged-value($message-construct,'##CFG-TV-MESSAGETYPE')" as="xs:string"/>
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
                <xsl:variable name="name" select="$message-construct/imvert:name/@original" as="xs:string"/>
                <xsl:variable name="tech-name" select="imf:get-normalized-name($message-construct/imvert:name, 'element-name')" as="xs:string"/>
                <xsl:variable name="package-type" select="$packages/imvert:package[imvert:class[imvert:id = $id]]/imvert:stereotype"/>
                <xsl:variable name="release" select="$packages/imvert:release" as="xs:string"/>
                
                <xsl:if test="not(string($berichtCode))">
                    <xsl:message 
                        select="concat('ERROR ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The berichtcode can not be determined. To be able to generate correct messages this is neccessary. Check your model for missing tagged values. (', $berichtstereotype,')')"
                    />
                </xsl:if>
                
                <ep:message prefix="{$prefix}">
                    <xsl:choose>
                        <xsl:when test="not(empty($serviceName))">
                            <xsl:attribute name="servicename" select="$serviceName"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="msg"
                                select="concat('The tagged value [servicename] is not set for the message ',$tech-name,'. If you want to create correct Open API documentation you need to set it.')"/>
                            <xsl:sequence select="imf:msg('WARNING', $msg)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="not(empty($messageType))">
                            <xsl:attribute name="messagetype" select="$messageType"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="msg"
                                select="concat('The tagged value [messagetype] is not set for the message ',$tech-name,'. If you want to create correct Open API documentation you need to set it.')"/>
                            <xsl:sequence select="imf:msg('WARNING', $msg)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)"/>
                    <xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
                    <xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
                    <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                    <xsl:sequence select="imf:create-output-element('ep:package-type', $package-type)"/><!--TODO-->
                    <xsl:sequence select="imf:create-output-element('ep:release', $release)"/>
                    <xsl:sequence select="imf:create-output-element('ep:type', $berichtSoort)"/>
                    <!-- Start of the message is always a class with an imvert:stereotype 
				with the value 'VRAAGBERICHTTYPE', 'ANTWOORDBERICHTTYPE', 'VRIJ BERICHTTYPE', 
				'KENNISGEVINGBERICHTTYPE' or 'SYNCHRONISATIEBERICHTTYPE'. Since the toplevel structure of a message 
				complies to different rules in comparison with the entiteiten structure this 
				template is initialized within the 'create-initial-message-structure' mode. -->
                    <xsl:apply-templates
                        select="$message-construct"
                        mode="create-toplevel-message-structure">
                        <xsl:with-param name="berichtCode" select="$berichtCode"/>
                        <xsl:with-param name="berichtName" select="$name"/>
                        <xsl:with-param name="generated-id" select="generate-id(.)"/>
                        <xsl:with-param name="currentMessage" select="$currentMessage"/>
                    </xsl:apply-templates>
                </ep:message>
            </xsl:for-each>
            
            <xsl:apply-templates select="$enriched-rough-messages/ep:rough-messages/ep:rough-message"/>
            
            <xsl:for-each select="$enriched-rough-messages//ep:construct[@typeCode='tabelEntiteit' and generate-id(.) = generate-id(key('construct-id',ep:id,$enriched-rough-messages)[1])]">                   
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3',$debugging)"/>
                
                <xsl:call-template name="processMainConstructs"/>
            </xsl:for-each>
            
            <xsl:for-each-group 
                select="//imvert:attribute[empty(imvert:type-id)]" 
                group-by="imf:useable-attribute-name(imf:get-compiled-name(.),.)">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 4a',$debugging)"/>
                <xsl:sequence select="imf:create-debug-comment(imvert:name,$debugging)"/>
                
                <xsl:apply-templates select="current-group()[1]" mode="mode-global-attribute-simpletype"/>
            </xsl:for-each-group>
            
            <xsl:for-each-group 
                select="//imvert:attribute[imvert:type-package='GML3']" 
                group-by="imvert:conceptual-schema-type">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 4b',$debugging)"/>
                
                <xsl:apply-templates select="current-group()[1]" mode="mode-global-attribute-simpletype"/>
            </xsl:for-each-group>
            
            
            <!-- ROME: Mogelijk dat deze later kan komen te vervalllen als baretype 'PuntOfVlak' of 'VlakOfMultivlak' niet meer bestaan.
                       Deze moeten nmm nl. vervangen worden door GML3 types. -->
            <xsl:for-each-group 
                select="//imvert:attribute[imvert:baretype = 'PuntOfVlak' or imvert:baretype = 'VlakOfMultivlak']" 
                group-by="imvert:baretype">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 4c',$debugging)"/>
                
                <xsl:apply-templates select="current-group()[1]" mode="mode-global-attribute-simpletype"/>
            </xsl:for-each-group>
            
            <xsl:apply-templates select="//imvert:class[imf:get-stereotype(.) = ('stereotype-name-enumeration') and generate-id(.) = generate-id(key('enumerationClass',imvert:name,$packages)[1])]" mode="mode-global-enumeration"/>
            
        </ep:message-set>
                
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:if test="$debugging">
            <xsl:sequence select="imf:msg('INFO','Constructing the endproduct message structure.')"/>
        </xsl:if>		
        
        <xsl:sequence select="imf:pretty-print($endproduct,false())"/>
        
    </xsl:template>
    
    <xsl:template match="*" mode="replicate-ep-structure">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="*|@*|text()" mode="replicate-ep-structure"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*" mode="replicate-ep-structure">
        <xsl:copy-of select="." copy-namespaces="no"/>
    </xsl:template>
    
    <?x xsl:template match="/">
        <!-- This template is used to place the content of the variable '$imvert-endproduct' within the ep file. -->
        <xsl:if test="$debugging">
            <xsl:result-document href="file:/c:/temp/imvert-schema-rules.xml">
                <xsl:sequence select="$config-schemarules"/>
            </xsl:result-document> 
            <xsl:result-document href="file:/c:/temp/imvert-tagged-values.xml">
                <xsl:sequence select="$config-tagged-values"/>
            </xsl:result-document> 
            <xsl:result-document href="file:/c:/temp/imvert-endproduct.xml">
                <xsl:sequence select="$enriched-endproduct-base-config-excel"/>
                
                <!-- xsl:sequence select="$imvert-endproduct/*"/ -->
            </xsl:result-document> 
            <xsl:result-document href="file:/c:/temp/rough-messages.xml">
                <xsl:sequence select="$rough-messages"/>
            </xsl:result-document>
            <xsl:result-document href="file:/c:/temp/enriched-rough-messages.xml">
                <xsl:sequence select="$enriched-rough-messages"/>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:sequence select="$imvert-endproduct/*"/>
    </xsl:template x?>
    
    <xsl:template match="ep:rough-message">
        <xsl:variable name="fundamentalMnemonic" select="ep:fundamentalMnemonic" as="xs:string"/>
        <!-- ROME: Er is een verschil tussen de uitbecommentarieerde variabele en de actieve want het levert een ander resultaat op.
                   Bij de uitbecommentarieerde variabele levert een generate-id() op een node uit deze tree een ander id op dan een 
                   generate-id() op de node-tree waaruit deze variabele is voortgekomen.
                   Arjan stelt voor om i.p.v. het gebruik van generate-id() node comparison te gebruiken 
                   (Zie https://www.w3.org/TR/xpath-functions/#func-is-same-node) --> 
        <xsl:variable name="currentMessage">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="*"/>
                </xsl:copy>
        </xsl:variable>
        <xsl:variable name="berichtCode" select="ep:code"/>
        
        <?x xsl:if test="$debugging">
            <ep:currentMessage>
                <xsl:sequence select="$currentMessage"/>
            </ep:currentMessage>
        </xsl:if x?>
        
        <xsl:sequence select="imf:track('Constructing the global constructs',$debugging)"/>

        <!-- The first for-each takes care of creating global construct elements for each ep:construct element present within the current 'rough-messages' variable 
             (which isn't a 'vrij bericht') having a type-id, verwerkingsModus combinationvalue none of the preceding ep:construct elements within the processed message 
             have. 
             The second for-each takes does the same for each ep:construct element present within the current 'rough-messages' variable 
             (which is 'vrij bericht') having a type-id, verwerkingsModus, entiteitOrBerichtRelatie combinationvalue none of the preceding ep:construct elements within the 
             processed message have.
             
             These two variant are neccessary because within a standard message you don't want ep:constructs with the same type-id, verwerkingsModus combinationvalue to be 
             processed more than once.
             Within a 'vrij bericht' however such an ep:construct is allowed to be processed more than once as long as ep:constructs with the same type-id, verwerkingsModus, 
             entiteitOrBerichtRelatie combinationvalue aren't be processed more than once.
             
             ep:construct elements with the name 'gelijk', 'vanaf', 'totEnMet', 'start' en 'scope' aren't processed here since they need special treatment.  -->
       
        <xsl:for-each select="$currentMessage/ep:rough-message[not(contains(ep:code,'Di')) and not(contains(ep:code,'Du'))]//ep:construct[@typeCode!='tabelEntiteit' and ep:id and generate-id(.) = generate-id(key('construct-id',concat(ep:id,@verwerkingsModus),$currentMessage)[1])]">                   
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 5',$debugging)"/>

            <xsl:call-template name="processMainConstructs">
                <xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
                <xsl:with-param name="currentMessage" select="$currentMessage"/>
            </xsl:call-template> 
        </xsl:for-each>
        
        <xsl:for-each select="$currentMessage/ep:rough-message[contains(ep:code,'Di') or contains(ep:code,'Du')]//ep:construct[@typeCode!='tabelEntiteit' and ep:id and generate-id(.) = generate-id(key('construct-id-in-vrijbericht',concat(ep:id,@verwerkingsModus,@entiteitOrBerichtRelatie),$currentMessage)[1])]">
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 6',$debugging)"/>

            <xsl:call-template name="processMainConstructs">
                <xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
                <xsl:with-param name="currentMessage" select="$currentMessage"/>
            </xsl:call-template> 
        </xsl:for-each>
        
       <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for antwoord constructs',$debugging)"/>
            
        <xsl:for-each select="$currentMessage/ep:rough-message[contains(ep:code, 'La')]//ep:construct[@typeCode='toplevel']">

            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, La)]//ep:construct[ep:tech-name = antwoord]',$debugging)"/>
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 7',$debugging)"/>
            
            <xsl:variable name="berichtName" select="ancestor::ep:rough-message/ep:name"/>
            <xsl:variable name="berichtType">
                <xsl:choose>
                    <xsl:when test="$berichtCode = 'La01' or $berichtCode = 'La02'">La0102</xsl:when>
                    <xsl:when test="$berichtCode = 'La03' or $berichtCode = 'La04'">La0304</xsl:when>
                    <xsl:when test="$berichtCode = 'La05' or $berichtCode = 'La06'">La0506</xsl:when>
                    <xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">La0708</xsl:when>
                    <xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">La0910</xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="berichtCode">
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::ep:construct[@berichtCode]">
                        <xsl:value-of select="ancestor-or-self::ep:construct[@berichtCode][last()]/@berichtCode"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::ep:rough-message/ep:code"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="generated-id" select="generate-id(.)"/>
            <xsl:variable name="relatedObjectId" select="ep:id"/>
            <xsl:variable name="id" select="ep:origin-id"/>
            <xsl:variable name="verwerkingsModus" select="'antwoord'"/>
            <xsl:variable name="construct" select="imf:get-class-construct-by-id($relatedObjectId,$packages-doc)"/>


            <!--xsl:if test="$debugging and name($construct) = 'imvert:class'">
                <xsl:sequence select="imf:debug-document($construct,'class.xml',true(),false())"/>
            </xsl:if>
            <xsl:if test="$debugging and not(name($construct) = 'imvert:class')">
                <xsl:sequence select="imf:debug-document($construct,'notclass.xml',true(),false())"/>
            </xsl:if-->


            <xsl:variable name="alias">
                <xsl:choose>
                    <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="$construct/imvert:alias"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="association" select="imf:get-association-construct-by-id($id,$packages-doc)"/>
            <xsl:variable name="elementName" select="$association/imvert:name"/>           
            <xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>
            
            <!-- Location: 'ep:construct7'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef7'. -->
            
            <ep:construct type="complexData">
                <xsl:attribute name="prefix" select="$prefix"/>
                <xsl:attribute name="namespaceId" select="$namespaceIdentifier"/>
                <xsl:sequence
                    select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,'antwoord',(),$elementName))" />
                <xsl:sequence
                    select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,'antwoord',(),$elementName))" />
                <xsl:sequence
                    select="imf:create-output-element('ep:prefix', $prefix)" />
                
                <ep:seq orderingDesired="no">
                    
                    <!-- Location: 'ep:constructRef1'
							    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
                    
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 8',$debugging)"/>

                    <ep:construct context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}" addedLevel="yes">
                         <xsl:sequence
                             select="imf:create-output-element('ep:name', $elementName)" />
                        <xsl:sequence
                            select="imf:create-output-element('ep:tech-name', $elementName)" />
                        <xsl:sequence
                            select="imf:create-output-element('ep:max-occurs', $association/imvert:max-occurs)" />
                        <xsl:sequence
                            select="imf:create-output-element('ep:min-occurs', $association/imvert:min-occurs)" />
                        <ep:position>1</ep:position>
                        <xsl:sequence
                            select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,(),$subsetLabel))" />
                    </ep:construct>

                </ep:seq>
            </ep:construct>                  
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, La)]//ep:construct[ep:tech-name = antwoord] End-for-each',$debugging)"/>
            
        </xsl:for-each>
            
        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for start constructs',$debugging)"/>
            
        <xsl:for-each select="$currentMessage/ep:rough-message[contains(ep:code, 'Lv')]//ep:construct[ep:tech-name = 'start']">
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 9',$debugging)"/>
            
            <xsl:variable name="berichtName" select="ancestor::ep:rough-message/ep:name"/>
            <xsl:variable name="berichtType" select="'Lv'"/>
            <xsl:variable name="berichtCode">
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::ep:construct[@berichtCode]">
                        <xsl:value-of select="ancestor-or-self::ep:construct[@berichtCode][last()]/@berichtCode"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::ep:rough-message/ep:code"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="generated-id" select="generate-id(.)"/>
            <xsl:variable name="relatedObjectId" select="ep:id"/>
            <xsl:variable name="id" select="ep:origin-id"/>
            <xsl:variable name="verwerkingsModus" select="'vraag'"/>
            <xsl:variable name="construct" select="imf:get-class-construct-by-id($relatedObjectId,$packages-doc)"/>
            <xsl:variable name="alias">
                <xsl:choose>
                    <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="$construct/imvert:alias"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="association" select="imf:get-association-construct-by-id($id,$packages-doc)"/>
            <xsl:variable name="elementName" select="$construct/imvert:name"/>
            <xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:tech-name = start]',$debugging)"/>

            <!-- Location: 'ep:construct8'
				 Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef8'. -->
            
            <ep:construct type="complexData">
                <xsl:attribute name="prefix" select="$prefix"/>
                <xsl:attribute name="namespaceId" select="$namespaceIdentifier"/>
                <xsl:sequence
                    select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtName,'start',(),'object'))" />
                <xsl:sequence
                    select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtName,'start',(),'object'))" />
                <xsl:sequence
                    select="imf:create-output-element('ep:prefix', $prefix)" />
                <ep:seq orderingDesired="no">
                        
                        <!-- Location: 'ep:constructRef1'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
                        
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 10',$debugging)"/>

                    <ep:construct context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}" addedLevel="yes">
                        <ep:name>object</ep:name>
                        <ep:tech-name>object</ep:tech-name>
                        <xsl:sequence
                            select="imf:create-output-element('ep:max-occurs', $association/imvert:max-occurs)" />
                        <xsl:sequence
                            select="imf:create-output-element('ep:min-occurs', $association/imvert:min-occurs)" />
                        <ep:position>1</ep:position>
                        <!--xsl:sequence
                            select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,$elementName))" /-->
                        <xsl:sequence
                            select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,(),$subsetLabel))" />
                    </ep:construct>

                </ep:seq>
            </ep:construct>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:tech-name = start] End-for-each',$debugging)"/>
            
        </xsl:for-each>
            
        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for antwoord scope',$debugging)"/>
            
        <xsl:for-each select="$currentMessage/ep:rough-message[contains(ep:code, 'Lv')]//ep:construct[ep:tech-name = 'scope']">
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 11',$debugging)"/>
            
            <xsl:variable name="berichtName" select="ancestor::ep:rough-message/ep:name"/>
            <xsl:variable name="berichtType" select="'Lv'"/>
            <xsl:variable name="berichtCode">
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::ep:construct[@berichtCode]">
                        <xsl:value-of select="ancestor-or-self::ep:construct[@berichtCode][last()]/@berichtCode"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::ep:rough-message/ep:code"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="generated-id" select="generate-id(.)"/>
            <xsl:variable name="relatedObjectId" select="ep:id"/>
            <xsl:variable name="id" select="ep:origin-id"/>
            <xsl:variable name="verwerkingsModus" select="'vraag'"/>
            <xsl:variable name="construct" select="imf:get-class-construct-by-id($relatedObjectId,$packages-doc)"/>
            <xsl:variable name="alias">
                <xsl:choose>
                    <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="$construct/imvert:alias"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="association" select="imf:get-association-construct-by-id($id,$packages-doc)"/>
            <xsl:variable name="elementName" select="$construct/imvert:name"/>
            <xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:tech-name = scope]',$debugging)"/>
                        
            <!-- Location: 'ep:construct9'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef9'. -->
            
            <ep:construct type="complexData">
                <xsl:attribute name="prefix" select="$prefix"/>
                <xsl:attribute name="namespaceId" select="$namespaceIdentifier"/>
                <xsl:sequence select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtName,'scope',(),'object'))" />
                <xsl:sequence select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtName,'scope',(),'object'))" />
                <xsl:sequence
                    select="imf:create-output-element('ep:prefix', $prefix)" />
                <ep:seq orderingDesired="no">
 
                        <!-- Location: 'ep:constructRef1'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
                        
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 12',$debugging)"/>

                    <ep:construct context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}" addedLevel="yes">
                        <ep:name>object</ep:name>
                        <ep:tech-name>object</ep:tech-name>
                        <xsl:sequence
                            select="imf:create-output-element('ep:max-occurs', $association/imvert:max-occurs)" />
                        <xsl:sequence
                            select="imf:create-output-element('ep:min-occurs', $association/imvert:min-occurs)" />
                        <ep:position>1</ep:position>
                        <!--xsl:sequence
                            select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,$elementName))" /-->                           
                        <xsl:sequence
                            select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,(),$subsetLabel))" />                           
                    </ep:construct>

                </ep:seq>
            </ep:construct>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:tech-name = scope] End-for-each',$debugging)"/>
            
        </xsl:for-each>        
    </xsl:template>
    
    <xsl:template name="processMainConstructs">
        <xsl:param name="fundamentalMnemonic" select="''"/>
        <xsl:param name="currentMessage" select="''"/>

        <xsl:sequence select="imf:create-debug-comment('Debuglocation 13',$debugging)"/>
        
        <xsl:variable name="berichtName" as="xs:string">
            <xsl:choose>
                <xsl:when test="(contains(ancestor::ep:rough-message/ep:code,'Di') or contains(ancestor::ep:rough-message/ep:code,'Du')) and ancestor-or-self::ep:construct/@typeCode = 'entiteitrelatie'">
                    <xsl:value-of select="concat(ancestor::ep:rough-message/ep:name,'-',ancestor-or-self::ep:construct[@typeCode = 'entiteitrelatie']/ep:tech-name)"/>
                </xsl:when>
                <xsl:when test="(contains(ancestor::ep:rough-message/ep:code,'Di') or contains(ancestor::ep:rough-message/ep:code,'Du')) and ancestor-or-self::ep:construct/@typeCode = 'berichtrelatie'">
                    <xsl:value-of select="concat(ancestor::ep:rough-message/ep:name,'-',ancestor-or-self::ep:construct[@typeCode = 'berichtrelatie']/ep:tech-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::ep:rough-message/ep:name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="berichtCode" as="xs:string">
           <xsl:choose>
               <!-- Within a 'vrij bericht' the ancestor tree can contain more than one berichtCode, the 'berichtCode' of the 'vrij bericht' 
                    (e.g. 'Di02' or 'Du01') and the 'berichtCode' of the embedded message. In that case the lowest level 'berichtCode'must be used. -->
               <xsl:when test="ancestor-or-self::ep:construct[@berichtCode]">
                   <xsl:value-of select="ancestor-or-self::ep:construct[@berichtCode][last()]/@berichtCode"/>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:value-of select="ancestor::ep:rough-message/ep:code"/>
               </xsl:otherwise>
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
                <xsl:otherwise><xsl:value-of select="$berichtName"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="context" as="xs:string">
           <xsl:choose>
               <xsl:when test="empty(@context)">
                   <xsl:value-of select="'-'"/>
               </xsl:when>
               <xsl:when test="@context = ''">
                   <xsl:value-of select="'-'"/>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:value-of select="@context"/>
               </xsl:otherwise>
           </xsl:choose>
        </xsl:variable>
        <xsl:variable name="id" select="ep:id" as="xs:string"/>
        <xsl:variable name="generated-id" select="generate-id(.)" as="xs:string"/>
        <xsl:variable name="typeCode" select="@typeCode" as="xs:string"/>
        <xsl:variable name="verwerkingsModus" select="@verwerkingsModus"/>
        <xsl:variable name="construct" select="imf:get-class-construct-by-id($id,$packages-doc)"/>
        <xsl:variable name="alias">
           <xsl:choose>
               <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
               <xsl:otherwise>
                   <xsl:value-of select="$construct/imvert:alias"/>
               </xsl:otherwise>
           </xsl:choose>
       </xsl:variable>
        <xsl:variable name="elementName" select="$construct/imvert:name"/>
        <xsl:variable name="suppliers" as="element(ep:suppliers)">
            <ep:suppliers>
                <xsl:copy-of select="imf:get-UGM-suppliers($construct)"/>
            </ep:suppliers>
        </xsl:variable>
        <xsl:variable name="authentiek" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-INDICATIONAUTHENTIC')"/>
        <xsl:variable name="inOnderzoek" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-INDICATIEINONDERZOEK')"/>
        <xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue($construct, '##CFG-TV-SUBSETLABEL')"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('generated-id ',$generated-id),$debugging)"/>
        <xsl:sequence select="imf:create-debug-comment(concat('verwerkingsModus ',$verwerkingsModus),$debugging)"/>
        
        <xsl:choose>
            <!-- LET OP! We moeten bij het bepalen van de globale complexTypes niet alleen kijken of ze hergebruikt worden over de berichten 
                maar ook of ze over die berichten heen wel hetzelfde moeten blijven. Het ene bericht heeft een hele ander type complexType nodig dan het andere.
                Ik moet dus hier indien nodig meerdere ep:constructs aanmaken voor elke situatie. Zie ook RM-488140.
                Voor elke relevante context moet er per construct een globale ep:construct en ep:constructRef gegenereerd worden.
            
                Let o.a. ook op de noodzaak om globale constructs of constructRefs te creeren voor historieMaterieel en historieFormeel.
                Uitleg: 
                   Elk construct (met zijn unieke ep:id) kan meerdere keren voorkomen in de rough-message structuur. Zo kan het dus ook voorkomen in een messagetype waarin
                   historie van belang is maar ook in een messagetype waarin historie niet van belang is. In principe verwerk ik elk uniek construct (op basis van het ep:id)
                   maar 1 keer. Als ik nu net het construct verwerk in de context van een messagetype waarin geen historie speelt zou ik dus geen historieMaterieel en
                   historieFormeel constructs en constructRefs maken terwijl dat in sommige contexten wel van belang is.-->
               
                
            <xsl:when test="$currentMessage = ''">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 14',$debugging)"/>
                
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
                
                <!-- Location: 'ep:construct1'
						    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-structure.xsl' on the location with the id 'ep:constructRef1'. -->
                
                <ep:construct type="complexData">
                    <xsl:choose>
                        <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                            <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                            <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                            <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                            <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                            <xsl:attribute name="version" select="ep:version"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!--xsl:if test="$debugging"-->
                    <ep:suppliers>
                        <xsl:copy-of select="$suppliers"/>
                    </ep:suppliers>
                    <!--/xsl:if-->
                    <!-- The value of the tech-name is dependant on the availability of an alias. -->
                    <xsl:choose>
                        <xsl:when test="not(empty($alias)) and $alias != ''">
                            <xsl:sequence
                                select="imf:create-output-element('ep:name', concat($alias,'-basis'))" />
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', concat($alias,'-basis'))" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence
                                select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,(),(),(),$subsetLabel))" />
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,(),(),(),$subsetLabel))" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                    <xsl:choose>
                        
                        <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                        <xsl:when test="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
                            <xsl:sequence select="imf:create-debug-comment('Debuglocation 14a',$debugging)"/>
                            <xsl:apply-templates select="$construct"
                                mode="create-message-content">
                                <xsl:with-param name="berichtName" select="$berichtName"/>
                                <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                <xsl:with-param name="berichtCode" select="$berichtCode" />
                                <xsl:with-param name="generated-id" select="$generated-id"/>
                                <xsl:with-param name="currentMessage" select="''"/>
                                <xsl:with-param name="context" select="''" />
                                <xsl:with-param name="verwerkingsModus" select="''"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <!-- Else the content of the current uml class is processed. -->
                        <xsl:otherwise>
                            <ep:seq>
                                <xsl:sequence
                                    select="imf:create-output-element('ep:min-occurs', 0)" />
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 14b',$debugging)"/>
                                <!-- The uml attributes of the uml class are placed here. -->
                                <xsl:apply-templates select="$construct"
                                    mode="create-message-content">
                                    <xsl:with-param name="berichtName" select="$berichtName"/>
                                    <xsl:with-param name="proces-type" select="'attributes'" />
                                    <xsl:with-param name="berichtCode" select="$berichtCode" />
                                    <xsl:with-param name="generated-id" select="$generated-id"/>
                                    <xsl:with-param name="currentMessage" select="''"/>
                                    <xsl:with-param name="context" select="''" />
                                    <xsl:with-param name="verwerkingsModus" select="''"/>
                                </xsl:apply-templates>
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 14c',$debugging)"/>
                                <!-- The uml groups of the uml class are placed here. -->
                                <xsl:apply-templates select="$construct"
                                    mode="create-message-content">
                                    <xsl:with-param name="berichtName" select="$berichtName"/>
                                    <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                    <xsl:with-param name="berichtCode" select="$berichtCode" />
                                    <xsl:with-param name="generated-id" select="$generated-id"/>
                                    <xsl:with-param name="currentMessage" select="''"/>
                                    <xsl:with-param name="context" select="''" />
                                    <!-- If the class is refered to form an association which is part of an VRIJ BERICHT no stuurgegevens must be generated. -->
                                    <xsl:with-param name="useStuurgegevens" select="'yes'"/>
                                    <xsl:with-param name="verwerkingsModus" select="''"/>
                                </xsl:apply-templates>
                                <!-- ep:authentiek element is used to determine if a 'authentiek' element needs to be generated in the messages in the next higher level. -->
                                <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>


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
                                <xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
                                <!-- The next construct is neccessary in a next xslt step to be able to determine if such an element is desired. -->
                                <ep:construct>
                                    <ep:name>inOnderzoek</ep:name>
                                    <ep:tech-name>inOnderzoek</ep:tech-name>
                                    <ep:max-occurs>unbounded</ep:max-occurs>
                                    <ep:min-occurs>0</ep:min-occurs>
                                    <xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':StatusMetagegeven-basis'))"/>						
                                    <ep:position>150</ep:position>
                                </ep:construct>
                                <!-- ROME:   Waarschijnlijk moet er hier afhankelijk van de context meer 
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
                                <xsl:if test="not($construct/imvert:stereotype/@id = ((
                                    'stereotype-name-vraagberichttype',
                                    'stereotype-name-antwoordberichttype',
                                    'stereotype-name-kennisgevingberichttype',
                                    'stereotype-name-synchronisatieberichttype'))) and not(contains(@verwerkingsModus,'matchgegevens'))">
                                    <xsl:if test="$global-tijdvakGeldigheid-allowed != 'Nee'">
                                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 14d',$debugging)"/>
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
                                            <ep:position>155</ep:position>
                                            <ep:href>StUF:tijdvakGeldigheid</ep:href>
                                        </ep:constructRef>
                                    </xsl:if>
                                    <xsl:if test="$global-tijdstipRegistratie-allowed != 'Nee'">
                                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 14e',$debugging)"/>
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
                                            <ep:position>160</ep:position>
                                            <ep:href>StUF:tijdstipRegistratie</ep:href>
                                        </ep:constructRef>
                                    </xsl:if>
                                    <xsl:if test="$global-extraElementen-allowed != 'Nee'">
                                        <ep:constructRef prefix="StUF" externalNamespace="yes">
                                            <ep:name>extraElementen</ep:name>
                                            <ep:tech-name>extraElementen</ep:tech-name>
                                            <ep:max-occurs>1</ep:max-occurs>
                                            <ep:min-occurs>0</ep:min-occurs>
                                            <ep:position>165</ep:position>
                                            <ep:href>StUF:extraElementen</ep:href>
                                        </ep:constructRef>
                                    </xsl:if>
                                    <xsl:if test="$global-aanvullendeElementen-allowed != 'Nee'">
                                        <ep:constructRef prefix="StUF" externalNamespace="yes">
                                            <ep:name>aanvullendeElementen</ep:name>
                                            <ep:tech-name>aanvullendeElementen</ep:tech-name>
                                            <ep:max-occurs>1</ep:max-occurs>
                                            <ep:min-occurs>0</ep:min-occurs>
                                            <ep:position>170</ep:position>
                                            <ep:href>StUF:aanvullendeElementen</ep:href>
                                        </ep:constructRef>
                                    </xsl:if>
                                </xsl:if>
                                <!-- ROME: Hieronder worden de construcRefs voor historieMaterieel en historieFormeel aangemaakt.
                                            Dit moet echter gebeuren a.d.h.v. de berichtcode. Die verfijning moet nog worden aangebracht in de if statements. -->
                                
                                <!-- If 'Materiele historie' is applicable for the current class a constructRef to a historieMaterieel global construct based on the current class is generated. -->
                                <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">
                                    
                                    <!-- Location: 'ep:constructRef2'
						                        Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct2'. -->
                                    
                                    <xsl:variable name="historieType" select="'historieMaterieel'"/>
                                    
                                    <ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}" prefix="{$prefix}">
                                        <ep:name>historieMaterieel</ep:name>
                                        <ep:tech-name>historieMaterieel</ep:tech-name>
                                        <ep:max-occurs>unbounded</ep:max-occurs>
                                        <ep:min-occurs>0</ep:min-occurs>
                                        <ep:position>175</ep:position>
                                        <xsl:choose>
                                            <xsl:when test="not(empty($alias)) and $alias != ''">
                                                <!--xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))"/-->
                                                <xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!--xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))"/-->
                                                <xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </ep:construct>

                                </xsl:if>
                                <!-- If 'Formele historie' is applicable for the current class a constructRef to a historieFormeel global construct based on the current class is generated. -->
                                <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">
                                    
                                    <xsl:variable name="historieType" select="'historieFormeel'"/>
                                    
                                    <!-- Location: 'ep:constructRef5'
						                        Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef5'. -->
                                    
                                    <ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}" prefix="{$prefix}">
                                        <ep:name>historieFormeel</ep:name>
                                        <ep:tech-name>historieFormeel</ep:tech-name>
                                        <ep:max-occurs>1</ep:max-occurs>
                                        <ep:min-occurs>0</ep:min-occurs>
                                        <ep:position>180</ep:position>
                                        <xsl:choose>
                                            <xsl:when test="not(empty($alias)) and $alias != ''">
                                                <!--xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))"/-->
                                                <xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <!--xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))"/-->
                                                <xsl:sequence
                                                    select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </ep:construct>

                                </xsl:if>
                                <!-- The uml associations of the uml class are placed here. -->
                                <xsl:apply-templates select="$construct"
                                    mode="create-message-content-constructRef">
                                    <xsl:with-param name="berichtName" select="$berichtName"/>
                                    <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                    <xsl:with-param name="berichtCode" select="$berichtCode" />
                                    <xsl:with-param name="generated-id" select="$generated-id"/>
                                    <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                    <xsl:with-param name="context" select="$context" />
                                    <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                </xsl:apply-templates>
                                <!-- The function imf:createAttributes is used to determine the XML attributes 
                                    		neccessary for this context. It has the following parameters: - typecode 
                                    		- berichttype - context - datumType The first 3 parameters relate to columns 
                                    		with the same name within an Excel spreadsheet used to configure a.o. XML 
                                    		attributes usage. The last parameter is used to determine the need for the 
                                    		XML-attribute 'StUF:indOnvolledigeDatum'. -->
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 14a',$debugging)"/>
                                <xsl:sequence select="imf:create-debug-comment(concat('Attributes voor ',$typeCode,', berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $alias),$debugging)"/>
                                <xsl:variable name="attributes"
                                    select="imf:createAttributes($typeCode, substring($berichtCode,1,2), $context, $alias,'no', $prefix, $id, '')" />
                                <xsl:sequence select="$attributes" />
                            </ep:seq>
                        </xsl:otherwise>
                    </xsl:choose>
                </ep:construct>
                
                
            </xsl:when>
            <!-- The following if takes care of creating global construct elements for each ep:construct element not representing a 'relatie'. -->
            <xsl:when test="@typeCode!='relatie' and @typeCode!='toplevel-relatie'">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 15',$debugging)"/>
                
                <xsl:choose>
                    <!-- If the name of the group is 'zender' or 'ontvanger' and its defined in the berichtstrukturen package nothing has to be generated. -->
                    <xsl:when test="ep:verkorteAlias = $StUF-prefix and @type=('group','complex datatype') and (ep:tech-name = 'zender' or ep:tech-name = 'ontvanger') and exists($construct)"/>
                    <!-- The following when generates global constructs based on uml groups. -->
                    <xsl:when test="@type=('group','complex datatype') and exists($construct)">

                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 16',$debugging)"/>
                        
                       <xsl:variable name="type" select="'Grp'"/>
                       <xsl:variable name="tech-name">
                           <xsl:choose>
                               <xsl:when test="ep:tech-name = 'zender' or ep:tech-name = 'ontvanger'"><xsl:value-of select="'Systeem'"/></xsl:when>
                               <xsl:when test="@className"><xsl:value-of select="@className"/></xsl:when>
                               <xsl:otherwise><xsl:value-of select="ep:tech-name"/></xsl:otherwise>
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
                        
                       <!-- Location: 'ep:construct3'
						    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef3'. -->
 
                        <!-- Only if the ancestor package isn't the 'Berichtstructuren' package a construct is generated. -->
                        <xsl:if test="ancestor-or-self::ep:construct/@package != 'Model [Berichtstructuren]'">
                            <ep:construct type="group">
                               <xsl:choose>
                                   <xsl:when test="ep:tech-name = 'parameters' or ep:tech-name = 'stuurgegevens' or ep:tech-name = 'zender' or ep:tech-name = 'ontvanger' or ep:tech-name = 'entiteittype'">
                                       <xsl:attribute name="prefix" select="$StUF-prefix"/>
                                       <xsl:attribute name="namespaceId" select="$StUF-namespaceIdentifier"/>
                                       <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                                   </xsl:when>
                                   <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                                       <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                                       <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                                       <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                                       <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                                       <xsl:attribute name="version" select="ep:version"/>
                                   </xsl:otherwise>
                               </xsl:choose>
                                <ep:suppliers>
                                    <xsl:copy-of select="$suppliers"/>
                                </ep:suppliers>
                                <xsl:choose>
                                    <xsl:when test="ep:tech-name = 'parameters' or ep:tech-name = 'stuurgegevens' or ep:tech-name = 'zender' or ep:tech-name = 'ontvanger' or ep:tech-name = 'entiteittype'">
                                        <xsl:sequence
                                            select="imf:create-output-element('ep:name', imf:create-Grp-complexTypeName($berichtName,$type,$tech-name,$verwerkingsModus,$subsetLabel))" />
                                        <xsl:sequence
                                            select="imf:create-output-element('ep:tech-name', imf:create-Grp-complexTypeName($berichtName,$type,$tech-name,$verwerkingsModus,$subsetLabel))" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence
                                            select="imf:create-output-element('ep:name', imf:create-Grp-complexTypeName($berichtType,$type,$tech-name,$verwerkingsModus,$subsetLabel))" />
                                        <xsl:sequence
                                            select="imf:create-output-element('ep:tech-name', imf:create-Grp-complexTypeName($berichtType,$type,$tech-name,$verwerkingsModus,$subsetLabel))" />
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                               <!-- ep:authentiek element is used to determine if a 'authentiek' element needs to be generated in the messages in the next higher level. -->
                               <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
                               <!-- ep:inOnderzoek element is used to determine if a 'inOnderzoek' element needs to be generated in the messages in the next higher level. -->
                               <xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
                               <ep:seq>
                                   
                                   <!-- Within the following apply-templates parameters are used which are also used in other apply-templates in this and other stylesheets.
                                        These have the following function:
                                        
                                        proces-type: 
                                        -->
                                   
                                   <!-- The uml attributes of the uml group are placed here. -->
                                   <xsl:sequence select="imf:create-debug-comment(concat('fundamentalMnemonic: ',$fundamentalMnemonic),$debugging)"/>
    
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'attributes'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                                   <!-- The uml groups of the uml group are placed here. -->
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                                    <!-- The uml associations of the uml group are placed here. -->
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                                   <xsl:if test="@type='complex datatype'">
                                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 16a',$debugging)"/>
                                       <ep:construct ismetadata="yes">
                                           <ep:name>noValue</ep:name>
                                           <ep:tech-name>noValue</ep:tech-name>
                                           <ep:min-occurs>0</ep:min-occurs>
                                           <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                       </ep:construct>
                                   </xsl:if>
                               </ep:seq> 
                           </ep:construct>                       
                        </xsl:if>
                   </xsl:when>
                    <!-- The following when generates global constructs based on uml classes. -->
                    <xsl:when test="exists($construct)">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 17',$debugging)"/>
                        
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
                        
                       <!-- Location: 'ep:construct1'
						    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-structure.xsl' on the location with the id 'ep:constructRef1'. -->
                       
                        <ep:construct type="complexData">
                            <xsl:choose>
                                <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                                    <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                                    <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                                    <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                                    <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                                    <xsl:attribute name="version" select="ep:version"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <ep:suppliers>
                                <xsl:copy-of select="$suppliers"/>
                            </ep:suppliers>
                            <!-- The value of the tech-name is dependant on the availability of an alias. -->
                            <!--xsl:sequence select="imf:create-debug-comment($elementName,$debugging)"/-->
                            <xsl:choose>
                               <xsl:when test="not(empty($alias)) and $alias != ''">
                                   <!--xsl:sequence
                                       select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,$elementName))" />
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,$elementName))" /-->
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,(),$subsetLabel))" />
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,$alias,(),$subsetLabel))" />
                               </xsl:when>
                               <xsl:otherwise>
                                   <!--xsl:sequence
                                       select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$verwerkingsModus,(),$elementName))" />
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,(),$elementName))" /-->
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$verwerkingsModus,(),(),$subsetLabel))" />
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$verwerkingsModus,(),(),$subsetLabel))" />
                               </xsl:otherwise>
                           </xsl:choose>
                            <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                           <xsl:choose>
                                
                               <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                               <xsl:when test="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
                                   <xsl:sequence select="imf:create-debug-comment('Debuglocation 17a',$debugging)"/>
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                               </xsl:when>
                               <!-- Else the content of the current uml class is processed. -->
                               <xsl:otherwise>
                                   <xsl:sequence select="imf:create-debug-comment('Debuglocation 17b',$debugging)"/>
                                   <ep:seq>
                                       <!-- Onderstaande min-Occurs is verwijdert nadat bleek dat de complexType 
                                            'NPS.Natuurlijkpersoon-selecteerPersoonResponse-antwoord' daardoor niet overeen kwam met
                                            'NPS-basis'. -->
                                       <!--xsl:sequence
                                           select="imf:create-output-element('ep:min-occurs', 0)" /-->
                                       <!-- The uml attributes of the uml class are placed here. -->
                                       <xsl:apply-templates select="$construct"
                                           mode="create-message-content">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'attributes'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="generated-id" select="$generated-id"/>
                                           <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                           <xsl:with-param name="context" select="$context" />
                                           <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                       </xsl:apply-templates>
                                       <!-- The uml groups of the uml class are placed here. -->
                                       <xsl:apply-templates select="$construct"
                                           mode="create-message-content">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="generated-id" select="$generated-id"/>
                                           <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                           <xsl:with-param name="context" select="$context" />
                                           <!-- If the class is refered to form an association which is part of an VRIJ BERICHT no stuurgegevens must be generated. -->
                                           <xsl:with-param name="useStuurgegevens">
                                               <xsl:choose>
                                                   <xsl:when test="$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:type-id = $id]/imvert:stereotype/@id = ('stereotype-name-berichtrelatie')">
                                                      <xsl:value-of select="'no'"/>
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <xsl:value-of select="'yes'"/>
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </xsl:with-param>                                      
                                           <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                       </xsl:apply-templates>
                                       <!-- ep:authentiek element is used to determine if a 'authentiek' element needs to be generated in the messages in the next higher level. -->
                                       <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>

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
                                       <xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
                                       <!-- The next construct is neccessary in a next xslt step to be able to determine if such an element is desired. -->
                                       <!--ep:construct>
                                           <xsl:choose>
                                               <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                                                   <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                                                   <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                                               </xsl:when>
                                               <xsl:otherwise>
                                                   <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                                                   <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                                               </xsl:otherwise>
                                           </xsl:choose>
                                           <ep:name>inOnderzoek</ep:name>
                                           <ep:tech-name>inOnderzoek</ep:tech-name>
                                           <ep:max-occurs>unbounded</ep:max-occurs>
                                           <ep:min-occurs>0</ep:min-occurs>
                                           <ep:type-name>scalar-string</ep:type-name>
                                           <ep:enum>J</ep:enum>
                                           <ep:enum>N</ep:enum>
                                           <ep:position>150</ep:position>
                                           <ep:seq>
                                               <xsl:variable name="attributes"
                                                   select="imf:createAttributes('StatusMetagegeven-basis','-', '-','','no', $prefix, $id, '')"/>									
                                               <xsl:sequence select="$attributes"/>
                                           </ep:seq>
                                       </ep:construct-->
                                       <ep:construct>
                                           <ep:name>inOnderzoek</ep:name>
                                           <ep:tech-name>inOnderzoek</ep:tech-name>
                                           <ep:max-occurs>unbounded</ep:max-occurs>
                                           <ep:min-occurs>0</ep:min-occurs>
                                           <xsl:sequence select="imf:create-output-element('ep:type-name', concat($StUF-prefix,':StatusMetagegeven-basis'))"/>						
                                           <ep:position>150</ep:position>
                                       </ep:construct>
                                       <!-- ROME:   Waarschijnlijk moet er hier afhankelijk van de context meer 
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
                                       <xsl:if test="not($construct/imvert:stereotype/@id = ((
                                           'stereotype-name-vraagberichttype',
                                           'stereotype-name-antwoordberichttype',
                                           'stereotype-name-kennisgevingberichttype',
                                           'stereotype-name-synchronisatieberichttype'))) and not(contains(@verwerkingsModus,'matchgegevens'))">
                                           <xsl:if test="$global-tijdvakGeldigheid-allowed != 'Nee'">
                                               <xsl:sequence select="imf:create-debug-comment('Debuglocation 17d',$debugging)"/>
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
                                                   <ep:position>155</ep:position>
                                                   <ep:href>StUF:tijdvakGeldigheid</ep:href>
                                               </ep:constructRef>
                                           </xsl:if>
                                           <xsl:if test="$global-tijdstipRegistratie-allowed != 'Nee'">
                                               <xsl:sequence select="imf:create-debug-comment('Debuglocation 17e',$debugging)"/>
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
                                                   <ep:position>160</ep:position>
                                                   <ep:href>StUF:tijdstipRegistratie</ep:href>
                                               </ep:constructRef>
                                           </xsl:if>
                                           <xsl:if test="$global-extraElementen-allowed != 'Nee'">
                                               <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                   <ep:name>extraElementen</ep:name>
                                                   <ep:tech-name>extraElementen</ep:tech-name>
                                                   <ep:max-occurs>1</ep:max-occurs>
                                                   <ep:min-occurs>0</ep:min-occurs>
                                                   <ep:position>165</ep:position>
                                                   <ep:href>StUF:extraElementen</ep:href>
                                               </ep:constructRef>
                                           </xsl:if>
                                           <xsl:if test="$global-aanvullendeElementen-allowed != 'Nee'">
                                               <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                   <ep:name>aanvullendeElementen</ep:name>
                                                   <ep:tech-name>aanvullendeElementen</ep:tech-name>
                                                   <ep:max-occurs>1</ep:max-occurs>
                                                   <ep:min-occurs>0</ep:min-occurs>
                                                   <ep:position>170</ep:position>
                                                   <ep:href>StUF:aanvullendeElementen</ep:href>
                                               </ep:constructRef>
                                           </xsl:if>
                                       </xsl:if>
                                       <!-- ROME: Hieronder worden de construcRefs voor historieMaterieel en historieFormeel aangemaakt.
                                            Dit moet echter gebeuren a.d.h.v. de berichtcode. Die verfijning moet nog worden aangebracht in de if statements. -->

                                       <!-- If 'Materiele historie' is applicable for the current class a constructRef to a historieMaterieel global construct based on the current class is generated. -->
                                       <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">

                                           <!-- Location: 'ep:constructRef2'
						                        Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct2'. -->

                                           <xsl:variable name="historieType" select="'historieMaterieel'"/>
                                           
                                           <ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}" prefix="{$prefix}">
                                               <ep:name>historieMaterieel</ep:name>
                                               <ep:tech-name>historieMaterieel</ep:tech-name>
                                               <ep:max-occurs>unbounded</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>175</ep:position>
                                               <xsl:choose>
                                                   <xsl:when test="not(empty($alias)) and $alias != ''">
                                                       <!--xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))"/-->
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))"/>
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <!--xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))"/-->
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))"/>
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </ep:construct>

                                       </xsl:if>
                                       <!-- If 'Formele historie' is applicable for the current class a constructRef to a historieFormeel global construct based on the current class is generated. -->
                                       <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">

                                           <xsl:variable name="historieType" select="'historieFormeel'"/>

                                           <!-- Location: 'ep:constructRef5'
						                        Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef5'. -->
                                           
                                           <ep:construct berichtCode="{$berichtCode}" berichtName="{$berichtName}" prefix="{$prefix}">
                                               <ep:name>historieFormeel</ep:name>
                                               <ep:tech-name>historieFormeel</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>180</ep:position>
                                               <xsl:choose>
                                                   <xsl:when test="not(empty($alias)) and $alias != ''">
                                                       <!--xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))"/-->
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))"/>
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <!--xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))"/-->
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))"/>
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </ep:construct>

                                       </xsl:if>
                                       <!-- The uml associations of the uml class are placed here. -->
                                       <xsl:apply-templates select="$construct"
                                           mode="create-message-content-constructRef">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="generated-id" select="$generated-id"/>
                                           <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                           <xsl:with-param name="context" select="$context" />
                                           <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                       </xsl:apply-templates>
                                       <!-- The function imf:createAttributes is used to determine the XML attributes 
                                    		neccessary for this context. It has the following parameters: - typecode 
                                    		- berichttype - context - datumType The first 3 parameters relate to columns 
                                    		with the same name within an Excel spreadsheet used to configure a.o. XML 
                                    		attributes usage. The last parameter is used to determine the need for the 
                                    		XML-attribute 'StUF:indOnvolledigeDatum'. -->
                                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 17ba',$debugging)"/>
                                       <xsl:sequence select="imf:create-debug-comment(concat('Attributes voor ',$typeCode,', berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ', mnemonic: ', $alias,' en prefix: ', $prefix,' voor id:',$id),$debugging)"/>
                                       <xsl:variable name="attributes"
                                           select="imf:createAttributes($typeCode, substring($berichtCode,1,2), $context, $alias,'no', $prefix, $id, '')" />
                                       <xsl:sequence select="$attributes" />
                                   </ep:seq>
                               </xsl:otherwise>
                           </xsl:choose>
                       </ep:construct>
                       
                   </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 17c',$debugging)"/>
                        <xsl:sequence select="imf:create-debug-comment(imvert:name,$debugging)"/>
                    </xsl:otherwise>
                </xsl:choose>


               <!-- There are 2 types of history parameters. The first one configures if history is applicable for the current context. History isn't applicable for example for each message type.
                    The second one is used to determine if history, if applicable for the context, is applicable for the class being processed. Not every class has attributes or associations history applies to. -->
               
               <!-- If 'Materiele historie' is applicable for the current class a historieMaterieel global construct based on the current class is generated. -->
                <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 18',$debugging)"/>
 
                    <xsl:variable name="historieType" select="'historieMaterieel'"/>
                    <xsl:choose>
                       <!-- The following when generates historieMaterieel global constructs based on uml groups. -->
                        <xsl:when test="@type=('group','complex datatype') and exists($construct)">
                           
                           <xsl:sequence select="imf:create-debug-track(concat('Constructing global materieleHistorie groupconstruct: ',$construct/imvert:name),$debugging)"/>
                            <xsl:sequence select="imf:create-debug-comment('Debuglocation 19',$debugging)"/>
                            
                           <xsl:variable name="type" select="'Grp'"/>
                           <xsl:variable name="tech-name" select="ep:tech-name"/>
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
                            
                           <!-- Location: 'ep:construct4'
						    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef4'. -->
                           
                            <ep:construct type="group">
                                <xsl:choose>
                                    <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                                        <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                                        <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                                        <xsl:attribute name="version" select="ep:version"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:sequence
                                    select="imf:create-output-element('ep:name', imf:create-Grp-complexTypeName($berichtType,$type,$tech-name,$historieType,$subsetLabel))" />
                                <xsl:sequence
                                   select="imf:create-output-element('ep:tech-name', imf:create-Grp-complexTypeName($berichtType,$type,$tech-name,$historieType,$subsetLabel))" />
                                <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                               <ep:seq>
                                   
                                   <!-- ROME: M.b.v. het XML attribute 'indicatieMaterieleHistorie' en 'indicatieFormeleHistorie' op het huidige rough-message construct 
                                              kan bepaald worden of binnen het ep:seq element een historieMaterieel en/of een historieFormeel constructRef moet worden gegenereerd. -->
                                   
                                   
                                   <!-- The uml attributes, of the uml group, for which historiematerieel is applicable are placed here. -->
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'attributes'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                       <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                                   <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                       <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                                   <!-- Associations are never placed within historieMaterieel constructs. -->
                                   <xsl:if test="@type='complex datatype'">
                                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 19a',$debugging)"/>
                                       <ep:construct ismetadata="yes">
                                           <ep:name>noValue</ep:name>
                                           <ep:tech-name>noValue</ep:tech-name>
                                           <ep:min-occurs>0</ep:min-occurs>
                                           <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                       </ep:construct>
                                   </xsl:if>
                               </ep:seq> 
                           </ep:construct>                       
                           
                       </xsl:when>
                       <!-- The following when generates historieMaterieel global constructs based on uml classes. -->
                        <xsl:when test="exists($construct)">
                           
                           <xsl:sequence select="imf:create-debug-track(concat('Constructing global materieleHistorie construct: ',$construct/imvert:name),$debugging)"/>
                            <xsl:sequence select="imf:create-debug-comment('Debuglocation 20',$debugging)"/>
                            
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
                            
                           
                           <!-- Location: 'ep:construct2'
						    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef2'. -->
                           
                            <ep:construct type="complexData">
                                <xsl:choose>
                                    <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                                        <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                                        <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                                        <xsl:attribute name="version" select="ep:version"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                               <!-- The value of the tech-name is dependant on the availability of an alias. -->
                               <xsl:choose>
                                   <xsl:when test="not(empty($alias)) and $alias != ''">
                                       <!--xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))" /-->
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))" />
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <!--xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))" /-->
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))" />
                                   </xsl:otherwise>
                               </xsl:choose>
                                <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                               <xsl:choose>
                                   <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                   
                                    
                                   
                                   <xsl:when test="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
                                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 20a',$debugging)"/>
                                       <xsl:apply-templates select="$construct"
                                           mode="create-message-content">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="generated-id" select="$generated-id"/>
                                           <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                           <xsl:with-param name="context" select="$context" />
                                           <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                           <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                           <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                           <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                       </xsl:apply-templates>
                                   </xsl:when>
                                   <!-- Else the content of the current uml class is processed. -->
                                   <xsl:otherwise>
                                       <ep:seq>
                                           <xsl:sequence select="imf:create-debug-comment('Debuglocation 20b',$debugging)"/>
                                           <!-- The uml attributes of the uml class are placed here. -->
                                           <xsl:apply-templates select="$construct"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="generated-id" select="$generated-id"/>
                                               <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                               <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                               <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                           </xsl:apply-templates>
                                           <xsl:sequence select="imf:create-debug-comment('Debuglocation 20c',$debugging)"/>
                                           <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                           <xsl:apply-templates select="$construct"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generated-id" select="$generated-id"/>
                                               <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                               <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                               <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                               <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
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
                                           <!-- ep:constructRef prefix="StUF" externalNamespace="yes">
                                               <ep:name>tijdvakObject</ep:name>
                                               <ep:tech-name>StUF:tijdvakObject</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>150</ep:position>
                                           </ep:constructRef -->
                                           <xsl:if test="$global-tijdvakGeldigheid-allowed = ('Nee','Optioneel')">
                                               <xsl:variable name="msg"
                                                   select="concat('The tagged value [tijdvakGeldigheid genereren] is set to ',$global-tijdvakGeldigheid-allowed,'. However in the historieMaterieel elements within the messagetype ', $berichtCode, ' it must be required.')"/>
                                               <xsl:sequence select="imf:msg('WARNING', $msg)"/>
                                           </xsl:if>
                                           <xsl:sequence select="imf:create-debug-comment('Debuglocation 20d',$debugging)"/>
                                           <!-- ROME: Het Kadaster wil het genereren van tijdvakGeldigheid kunnen uitschakelen.
                                                      In deze situatie is het echter verplicht. Wat doen we er dan mee? -->
                                           <ep:constructRef prefix="StUF" externalNamespace="yes">
                                               <ep:name>tijdvakGeldigheid</ep:name>
                                               <ep:tech-name>tijdvakGeldigheid</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>1</ep:min-occurs>
                                               <ep:position>155</ep:position>
                                               <ep:href>StUF:tijdvakGeldigheid</ep:href>
                                           </ep:constructRef>
                                           
                                           <!-- If 'Formele historie' is applicable for the current class a the following construct and constructRef are generated. -->
                                           <xsl:if test="@indicatieFormeleHistorie='Ja'">
                                               <xsl:if test="$global-tijdstipRegistratie-allowed = 'Nee'">
                                                   <xsl:variable name="msg"
                                                       select="concat('The tagged value [tijdstipRegistratie genereren] is set to ',$global-tijdstipRegistratie-allowed,'. However in the historieMaterieel elements within the messagetype ', $berichtCode, ' it must be at least optional.')"/>
                                                   <xsl:sequence select="imf:msg('WARNING', $msg)"/>
                                               </xsl:if>
                                               <xsl:sequence select="imf:create-debug-comment('Debuglocation 20e',$debugging)"/>
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
                                                   <ep:position>160</ep:position>
                                                   <ep:href>StUF:tijdstipRegistratie</ep:href>
                                               </ep:constructRef>

                                               <ep:construct prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                   <ep:name>historieFormeel</ep:name>
                                                   <ep:tech-name>historieFormeel</ep:tech-name>
                                                   <ep:max-occurs>1</ep:max-occurs>
                                                   <ep:min-occurs>0</ep:min-occurs>
                                                   <ep:position>175</ep:position>
                                                   <!-- The value of the type-name is dependant on the availability of an alias. -->
                                                  <xsl:choose>
                                                      <xsl:when test="not(empty($alias)) and $alias != ''">
                                                          <!--xsl:sequence
                                                               select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,'historieFormeel',$alias,$elementName))" /-->
                                                          <xsl:sequence
                                                              select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,'historieFormeel',$alias,(),$subsetLabel))" />
                                                      </xsl:when>
                                                       <xsl:otherwise>
                                                           <!--xsl:sequence
                                                               select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,'historieFormeel',(),$elementName))" /-->
                                                           <xsl:sequence
                                                               select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,'historieFormeel',(),(),$subsetLabel))" />
                                                       </xsl:otherwise>
                                                   </xsl:choose>
                                               </ep:construct>

                                           </xsl:if>
                                           <!-- Associations are never placed within historieMaterieel constructs. -->                                           
                                       </ep:seq> 
                                   </xsl:otherwise>
                               </xsl:choose>
                           </ep:construct>
                           
                       </xsl:when>
                   </xsl:choose>
               </xsl:if>
                <!-- If 'Formele historie' is applicable for the current class a historieFormeel global construct based on the current class is generated. -->
                <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 21',$debugging)"/>

                    <xsl:variable name="historieType" select="'historieFormeel'"/>
                    <xsl:choose>
                       <!-- The following when generates historieFormeel global constructs based on uml groups. -->
                        <xsl:when test="@type=('group','complex datatype') and exists($construct)">
                           
                           <xsl:sequence select="imf:create-debug-track(concat('Constructing global formeleHistorie groupconstruct: ',$construct/imvert:name),$debugging)"/>
                            <xsl:sequence select="imf:create-debug-comment('Debuglocation 22',$debugging)"/>
                            
                            <xsl:variable name="type" select="'Grp'"/>
                           <xsl:variable name="tech-name" select="ep:tech-name"/>
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
                            
                           <!-- Location: 'ep:construct5'
						    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef5'. -->
                           
                            <ep:construct type="group">
                                <xsl:choose>
                                    <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                                        <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                                        <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                                        <xsl:attribute name="version" select="ep:version"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:sequence
                                    select="imf:create-output-element('ep:name', imf:create-Grp-complexTypeName($berichtType,$type,$tech-name,$historieType,$subsetLabel))" />
                                <xsl:sequence
                                   select="imf:create-output-element('ep:tech-name', imf:create-Grp-complexTypeName($berichtType,$type,$tech-name,$historieType,$subsetLabel))" />
                                <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                               <ep:seq>
                                   <!-- The uml attributes, of the uml group, for which historieFormeel is applicable are placed here. -->
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'attributes'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                                   <!-- The uml groups, of the uml group, for which historieFormeel is applicable are placed here. -->
                                   <xsl:apply-templates select="$construct"
                                       mode="create-message-content">
                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                       <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="generated-id" select="$generated-id"/>
                                       <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                       <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                   </xsl:apply-templates>
                                   <!-- Associations are never placed within historieFormeel constructs. -->
                                   <xsl:if test="@type='complex datatype'">
                                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 22a',$debugging)"/>
                                       <ep:construct ismetadata="yes">
                                           <ep:name>noValue</ep:name>
                                           <ep:tech-name>noValue</ep:tech-name>
                                           <ep:min-occurs>0</ep:min-occurs>
                                           <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                       </ep:construct>
                                   </xsl:if>
                               </ep:seq> 
                           </ep:construct>                       
                           
                       </xsl:when>
                       <!-- The following when generates historieFormeel global constructs based on uml classes. -->
                        <xsl:when test="exists($construct)">
                           
                           <xsl:sequence select="imf:create-debug-track(concat('Constructing global formeleHistorie construct: ',$construct/imvert:name),$debugging)"/>
                            <xsl:sequence select="imf:create-debug-comment('Debuglocation 23',$debugging)"/>
                            
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

                            <!-- Location: 'ep:construct6'
						    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef6'. -->
                           
                            <ep:construct type="complexData">
                                <xsl:choose>
                                    <xsl:when test="ep:verkorteAliasGerelateerdeEntiteit">
                                        <xsl:attribute name="prefix" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                                        <xsl:attribute name="version" select="ep:UGMversionGerelateerdeEntiteit"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="prefix" select="ep:verkorteAlias"/>
                                        <xsl:attribute name="namespaceId" select="ep:namespaceIdentifier"/>
                                        <xsl:attribute name="version" select="ep:version"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <!-- The value of the tech-name is dependant on the availability of an alias. -->
                               <xsl:choose>
                                   <xsl:when test="not(empty($alias)) and $alias != ''">
                                       <!--xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))" /-->
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))" />
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <!--xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))" /-->
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))" />
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))" />
                                   </xsl:otherwise>
                               </xsl:choose>
                                <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                               <xsl:choose>
                                   <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                   
                                   
                                   <xsl:when test="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
                                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 23a',$debugging)"/>
                                       <xsl:apply-templates select="$construct"
                                           mode="create-message-content">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="generated-id" select="$generated-id"/>
                                           <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                           <xsl:with-param name="context" select="$context" />
                                           <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                           <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                           <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                       </xsl:apply-templates>
                                   </xsl:when>
                                   <!-- Else the content of the current uml class is processed. -->
                                   <xsl:otherwise>                                     
                                       <ep:seq>
                                           <xsl:sequence select="imf:create-debug-comment('Debuglocation 23b',$debugging)"/>
                                           <!-- The uml attributes of the uml class are placed here. -->
                                           <xsl:apply-templates select="$construct"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="generated-id" select="$generated-id"/>
                                               <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                               <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                                           </xsl:apply-templates>
                                           <xsl:sequence select="imf:create-debug-comment('Debuglocation 23c',$debugging)"/>
                                           <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                           <xsl:apply-templates select="$construct"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="generated-id" select="$generated-id"/>
                                               <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                               <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
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
                                           <!-- ep:constructRef externalNamespace="yes">
                                               <ep:name>tijdvakObject</ep:name>
                                               <ep:tech-name>tijdvakObject</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>150</ep:position>
                                           </ep:constructRef -->
                                           <xsl:if test="$global-tijdvakGeldigheid-allowed = ('Nee','Optioneel')">
                                               <xsl:variable name="msg"
                                                   select="concat('The tagged value [tijdvakGeldigheid genereren] is set to ',$global-tijdvakGeldigheid-allowed,'. However in the historieFormeel element within the messagetype ', $berichtCode, ' it must be required.')"/>
                                               <xsl:sequence select="imf:msg('WARNING', $msg)"/>
                                           </xsl:if>
                                           <xsl:sequence select="imf:create-debug-comment('Debuglocation 23d',$debugging)"/>
                                           <ep:constructRef prefix="StUF" externalNamespace="yes">
                                               <ep:name>tijdvakGeldigheid</ep:name>
                                               <ep:tech-name>tijdvakGeldigheid</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>1</ep:min-occurs>
                                               <ep:position>155</ep:position>
                                               <ep:href>StUF:tijdvakGeldigheid</ep:href>
                                           </ep:constructRef>
                                           <xsl:if test="$global-tijdstipRegistratie-allowed = ('Nee','Optioneel')">
                                               <xsl:variable name="msg"
                                                   select="concat('The tagged value [tijdstipRegistratie genereren] is set to ',$global-tijdstipRegistratie-allowed,'. However in the historieFormeel element within the messagetype ', $berichtCode, ' it must be required.')"/>
                                               <xsl:sequence select="imf:msg('WARNING', $msg)"/>
                                           </xsl:if>
                                           <xsl:sequence select="imf:create-debug-comment('Debuglocation 23e',$debugging)"/>
                                           <ep:constructRef prefix="StUF" externalNamespace="yes">
                                               <ep:name>tijdstipRegistratie</ep:name>
                                               <ep:tech-name>tijdstipRegistratie</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>1</ep:min-occurs>
                                               <ep:position>160</ep:position>
                                               <ep:href>StUF:tijdstipRegistratie</ep:href>
                                           </ep:constructRef>

                                           <ep:construct prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                               <ep:name>historieFormeel</ep:name>
                                               <ep:tech-name>historieFormeel</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>175</ep:position>
                                               <!-- The value of the type-name is dependant on the availability of an alias. -->
                                               <xsl:choose>
                                                   <xsl:when test="not(empty($alias)) and $alias != ''">
                                                       <!--xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,$elementName))" /-->
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,$alias,(),$subsetLabel))" />
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <!--xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),$elementName))" /-->
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:type-name', imf:create-complexTypeName($berichtType,$historieType,(),(),$subsetLabel))" />
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </ep:construct>

                                       </ep:seq> 
                                   </xsl:otherwise>
                               </xsl:choose>
                           </ep:construct>
                           
                       </xsl:when>
                   </xsl:choose>
               </xsl:if>
                <!-- If 'Formele historie' is applicable for the current class a historieFormeel global construct based on the current class is generated. -->
            </xsl:when>

            <!-- The following when takes care of creating global construct elements for each ep:construct element representing a 'relatie'. -->
            <xsl:when test="@typeCode='relatie' or @typeCode='toplevel-relatie'">
                 
                <xsl:sequence select="imf:create-debug-track(concat('Constructing the global constructs representing a relation with the name ',ep:tech-name),$debugging)"/>
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 24',$debugging)"/>

                <!-- Within the schema's we want to have global constructs for relations. However for that kind of objects no uml classes are available.
                        With the following apply-templates the global ep:construct elements are created presenting the relations. -->
                
                <xsl:variable name="association" select="$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:id = $id and imvert:stereotype/@id = ('stereotype-name-relatiesoort')]"/>
                
                <xsl:apply-templates select="$association"
                    mode="create-global-construct">
                    <xsl:with-param name="berichtCode" select="$berichtCode"/>
                    <xsl:with-param name="berichtName" select="$berichtName"/>
                    <xsl:with-param name="generated-id" select="$generated-id"/>
                    <xsl:with-param name="currentMessage" select="$currentMessage"/>
                    <xsl:with-param name="context" select="$context"/>
                    <xsl:with-param name="typeCode" select="@typeCode"/>
                    <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                    <xsl:with-param name="indicatieMaterieleHistorieRelatie" select="@indicatieMaterieleHistorieRelatie"/>
                    <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                    <xsl:with-param name="indicatieFormeleHistorieRelatie" select="@indicatieFormeleHistorieRelatie"/>
                    <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                    <xsl:with-param name="verkorteAliasGerelateerdeEntiteit" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                    <xsl:with-param name="namespaceIdentifierGerelateerdeEntiteit" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                    <xsl:with-param name="UGMversionGerelateerdeEntiteit" select="ep:UGMversionGerelateerdeEntiteit"/>
                </xsl:apply-templates>

                <!-- There are 2 types of history parameters. The first one configures if history is applicable for the current context. History isn't applicable for example for each message type.
                The second one is used to determine if history, if applicable for the context, is applicable for the class being processed. Not every class has attributes or associations history applies to. -->
                
                <!-- If 'Materiele historie' is applicable for the current class and messagetype a historieMaterieel global construct based on the current class is generated. -->
                <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes')">
                    
                    <xsl:sequence select="imf:create-debug-track(concat('Constructing the materieleHistorie constructs: ',$association/imvert:name),$debugging)"/>
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 25',$debugging)"/>
                    
                    <xsl:apply-templates select="$association"
                        mode="create-global-construct">
                        <xsl:with-param name="berichtCode" select="$berichtCode"/>
                        <xsl:with-param name="berichtName" select="$berichtName"/>
                        <xsl:with-param name="generated-id" select="$generated-id"/>
                        <xsl:with-param name="currentMessage" select="$currentMessage"/>
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="typeCode" select="@typeCode"/>
                        <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                        <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                        <xsl:with-param name="indicatieMaterieleHistorieRelatie" select="@indicatieMaterieleHistorieRelatie"/>
                        <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                        <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                        <xsl:with-param name="verkorteAliasGerelateerdeEntiteit" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                        <xsl:with-param name="namespaceIdentifierGerelateerdeEntiteit" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                        <xsl:with-param name="UGMversionGerelateerdeEntiteit" select="ep:UGMversionGerelateerdeEntiteit"/>
                    </xsl:apply-templates>
                </xsl:if>
                
                
                <!-- If 'Formele historie' is applicable for the current class and messagetype a historieFormeel global construct based on the current class is generated. -->
                <!-- ROME: checken of de parameter 'indicatieMaterieleHistorie' wel doorgegeven moeten worden.
                           Volgens mij hoeft er nl. in een 'historieFormeel' helemaal geen 'historieMaterieel' element gegenereerd te worden. --> 
                <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes')">
                    
                    <xsl:sequence select="imf:create-debug-track(concat('Constructing the formeleHistorie constructs: ',$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:id = $id and imvert:stereotype/@id = ('stereotype-name-relatiesoort')]/imvert:name),$debugging)"/>
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 26',$debugging)"/>
                    
                    <xsl:apply-templates select="$association"
                        mode="create-global-construct">
                        <xsl:with-param name="berichtCode" select="$berichtCode"/>
                        <xsl:with-param name="berichtName" select="$berichtName"/>
                        <xsl:with-param name="generated-id" select="$generated-id"/>
                        <xsl:with-param name="currentMessage" select="$currentMessage"/>
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="typeCode" select="@typeCode"/>
                        <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                        <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                        <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                        <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                        <xsl:with-param name="verkorteAliasGerelateerdeEntiteit" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                        <xsl:with-param name="namespaceIdentifierGerelateerdeEntiteit" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                        <xsl:with-param name="UGMversionGerelateerdeEntiteit" select="ep:UGMversionGerelateerdeEntiteit"/>
                    </xsl:apply-templates>
                </xsl:if>
                
                <!-- If 'Formele historie' is applicable for the current class and messagetype a historieFormeel global construct based on the current class is generated. -->
                <!-- ROME: checken of de parameters 'indicatieMaterieleHistorieRelatie' en 'indicatieMaterieleHistorie' wel doorgegeven moeten worden.
                           Volgens mij hoeft er nl. in een 'historieFormeelRelatie' helemaal geen 'historieMaterieel' of 'historieMaterieelRelatie' element gegenereerd
                           te worden. --> 
                <xsl:if test="@indicatieFormeleHistorieRelatie='Ja'">
                    
                    <xsl:sequence select="imf:create-debug-track(concat('Constructing the formeleHistorieRelatie constructs: ',$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:id = $id and imvert:stereotype/@id = ('stereotype-name-relatiesoort')]/imvert:name),$debugging)"/>
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 27',$debugging)"/>
                    
                    <xsl:apply-templates select="$association"
                        mode="create-global-construct">
                        <xsl:with-param name="berichtCode" select="$berichtCode"/>
                        <xsl:with-param name="berichtName" select="$berichtName"/>
                        <xsl:with-param name="generated-id" select="$generated-id"/>
                        <xsl:with-param name="currentMessage" select="$currentMessage"/>
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="typeCode" select="@typeCode"/>
                        <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorieRelatie'"/>
                        <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                        <xsl:with-param name="indicatieMaterieleHistorieRelatie" select="@indicatieMaterieleHistorieRelatie"/>
                        <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                        <xsl:with-param name="indicatieFormeleHistorieRelatie" select="@indicatieFormeleHistorieRelatie"/>
                        <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                        <xsl:with-param name="verkorteAliasGerelateerdeEntiteit" select="ep:verkorteAliasGerelateerdeEntiteit"/>
                        <xsl:with-param name="namespaceIdentifierGerelateerdeEntiteit" select="ep:namespaceIdentifierGerelateerdeEntiteit"/>
                        <xsl:with-param name="UGMversionGerelateerdeEntiteit" select="ep:UGMversionGerelateerdeEntiteit"/>
                    </xsl:apply-templates>
                </xsl:if>

                
            </xsl:when>
       </xsl:choose>
    </xsl:template>
  
    <!-- supress the suppressXsltNamespaceCheck message -->
    <xsl:template match="/imvert:dummy"/>
    
    <xsl:template match="imvert:class" mode="mode-global-enumeration">
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 28',$debugging)"/>
        <xsl:variable name="compiled-name" select="imf:get-compiled-name(.)"/>
        <xsl:variable name="local-empty-enumeration-allowed">
            <xsl:choose>
                <xsl:when test="empty(imf:get-tagged-value(.,'##CFG-TV-EMPTYENUMERATIONALLOWED'))">
                    <xsl:value-of select="$global-empty-enumeration-allowed"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="imf:get-tagged-value(.,'##CFG-TV-EMPTYENUMERATIONALLOWED')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="suppliers" as="element(ep:suppliers)">
            <ep:suppliers>
                <xsl:copy-of select="imf:get-UGM-suppliers(.)"/>
            </ep:suppliers>
        </xsl:variable>
        
        <!-- ROME: Uitbecommentarieerde variabele is vervangen door de die daaronder.
                   Dit is slechts tijdelijk todat er een alternatieve constructie is voor het definieren van custom stuurgegevens en parameters. -->
        
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

        <xsl:comment select="concat('ROME: ',parent::imvert:*/imvert:name)"/>

        <!-- In case of a enumeration class a subset label only is available if it concerns a custom datatype for de berichtstructuren
             (stuurgegevens and parameters). -->
        <xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-SUBSETLABEL')"/>
        
        <xsl:choose>
            <xsl:when test="not(empty($subsetLabel))">
                <ep:construct type="simpleData" prefix="{$construct-Prefix}" isdatatype="yes">
                    <xsl:sequence select="imf:create-output-element('ep:name', concat(imf:capitalize($compiled-name),'-',$subsetLabel))"/>
                    <xsl:sequence select="imf:create-output-element('ep:tech-name', concat(imf:capitalize($compiled-name),'-',$subsetLabel))"/>
                    <xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-string')"/>
                    <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-enum"/>
                </ep:construct>
            </xsl:when>
            <xsl:when test="not(imf:capitalize($compiled-name) = 'Berichtcode' or imf:capitalize($compiled-name) = 'IndicatorOvername')">
                <xsl:if test="$global-e-types-allowed = 'Ja'">
                    <ep:construct type="simpleContentcomplexData" prefix="{$construct-Prefix}" addedLevel="yes">
                        <xsl:sequence select="imf:create-output-element('ep:name', concat(imf:capitalize($compiled-name),'-e'))"/>
                        <xsl:sequence select="imf:create-output-element('ep:tech-name', concat(imf:capitalize($compiled-name),'-e'))"/>
                        <ep:type-name>
                            <xsl:value-of select="concat($construct-Prefix,':',imf:capitalize($compiled-name))"/>
                        </ep:type-name>
                        <xsl:if test="$global-noValue-allowed = 'Ja'">                        
                            <ep:seq>
                                <ep:construct ismetadata="yes">
                                    <xsl:sequence select="imf:create-output-element('ep:name', 'noValue')"/>
                                    <xsl:sequence select="imf:create-output-element('ep:tech-name', 'noValue')"/>
                                    <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                    <ep:min-occurs>0</ep:min-occurs>
                                </ep:construct>                     
                            </ep:seq>
                        </xsl:if>
                    </ep:construct>
                </xsl:if>
                <ep:construct type="simpleData" prefix="{$construct-Prefix}" isdatatype="yes">
                    <xsl:sequence select="imf:create-output-element('ep:name', imf:capitalize($compiled-name))"/>
                    <xsl:sequence select="imf:create-output-element('ep:tech-name', imf:capitalize($compiled-name))"/>
                    <xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-string')"/>
                    <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-enum"/>
                    <xsl:if test="$local-empty-enumeration-allowed = 'Ja'">
                        <ep:enum></ep:enum>
                    </xsl:if>
                </ep:construct>
            </xsl:when>
        </xsl:choose>
        <!--xsl:if test="not(imf:capitalize($compiled-name) = 'Berichtcode' or imf:capitalize($compiled-name) = 'IndicatorOvername')">
            <ep:construct type="simpleContentcomplexData" prefix="{$construct-Prefix}">
                <xsl:sequence select="imf:create-output-element('ep:name', concat(imf:capitalize($compiled-name),'-e'))"/>
                <xsl:sequence select="imf:create-output-element('ep:tech-name', concat(imf:capitalize($compiled-name),'-e'))"/>
                <ep:type-name>
                    <xsl:value-of select="concat($construct-Prefix,':',imf:capitalize($compiled-name))"/>
                </ep:type-name>
                <ep:seq>
                    <ep:construct ismetadata="yes">
                        <xsl:sequence select="imf:create-output-element('ep:name', 'noValue')"/>
                        <xsl:sequence select="imf:create-output-element('ep:tech-name', 'noValue')"/>
                        <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                        <ep:min-occurs>0</ep:min-occurs>
                    </ep:construct>                     
                </ep:seq>
            </ep:construct>
            <ep:construct type="simpleData" prefix="{$construct-Prefix}" isdatatype="yes">
                <xsl:sequence select="imf:create-output-element('ep:name', imf:capitalize($compiled-name))"/>
                <xsl:sequence select="imf:create-output-element('ep:tech-name', imf:capitalize($compiled-name))"/>
                <xsl:sequence select="imf:create-output-element('ep:data-type', 'scalar-string')"/>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="mode-local-enum"/>
                <ep:enum></ep:enum>
            </ep:construct>
        </xsl:if-->
    </xsl:template>

    <xsl:template match="imvert:attribute" mode="mode-local-enum">
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 29',$debugging)"/>
        
        <!-- STUB De naam van een enumeratie is die overgenomen uit SIM. Niet camelcase. Vooralsnog ook daar ophalen. -->
        
        <xsl:variable name="supplier" select="imf:get-trace-suppliers-for-construct(.,1)[@project='SIM'][1]"/>
        <xsl:variable name="construct" select="if ($supplier) then imf:get-trace-construct-by-supplier($supplier,$imvert-document) else ()"/>
        <xsl:variable name="SIM-name" select="($construct/imvert:name, imvert:name)[1]"/>
        
        <ep:enum><xsl:value-of select="$SIM-name"/></ep:enum>
        
    </xsl:template>
    
    <!-- This template (4) transforms an 'imvert:association' element to a global 'ep:construct' 
		 element. -->
    <xsl:template match="imvert:association" mode="create-global-construct">
        <xsl:param name="berichtCode"/>
        <xsl:param name="berichtName"/>
        <xsl:param name="generated-id"/>
        <xsl:param name="currentMessage"/>
        <xsl:param name="context"/>
        <xsl:param name="typeCode"/>
        <xsl:param name="orderingDesired" select="'yes'"/>
        <xsl:param name="generateHistorieConstruct" select="'Nee'"/>
        <xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
        <xsl:param name="indicatieMaterieleHistorieRelatie" select="'Nee'"/>
        <xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
        <xsl:param name="indicatieFormeleHistorieRelatie" select="'Nee'"/>
        <xsl:param name="useStuurgegevens" select="'yes'"/>                                       
        <xsl:param name="verwerkingsModus"/>
        <xsl:param name="verkorteAliasGerelateerdeEntiteit"/>
        <xsl:param name="namespaceIdentifierGerelateerdeEntiteit"/>
        <xsl:param name="UGMversionGerelateerdeEntiteit"/>
        
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 30',$debugging)"/>

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
        <xsl:variable name="type-id" select="imvert:type-id"/>
        <xsl:variable name="verwerkingsModusOfConstructRef" select="$verwerkingsModus"/>        
        <xsl:variable name="type-id" select="imvert:type-id"/>
        <xsl:variable name="typering">
            <xsl:choose>
                <xsl:when test="$generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie,'Ja') and ($context != '-' and not(empty($context)))">historieMaterieel<xsl:value-of select="$context"/></xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie,'Ja')">historieMaterieel</xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie,'Ja') and ($context != '-' and not(empty($context)))">historieFormeel<xsl:value-of select="$context"/></xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie,'Ja')">historieFormeel</xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorieRelatie' and contains($indicatieFormeleHistorieRelatie,'Ja') and ($context != '-' and not(empty($context)))">historieFormeelRelatie<xsl:value-of select="$context"/></xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorieRelatie' and contains($indicatieFormeleHistorieRelatie,'Ja')">historieFormeelRelatie</xsl:when>
                <xsl:otherwise><xsl:value-of select="$verwerkingsModusOfConstructRef"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="historyName">
            <xsl:choose>
                <xsl:when test="$generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie,'Ja')">-historieMaterieel</xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie,'Ja')">-historieFormeel</xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorieRelatie' and contains($indicatieFormeleHistorieRelatie,'Ja')">-historieFormeelRelatie</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        
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
        <xsl:variable name="name" select="imvert:name/@original"/>
        <xsl:variable name="elementName" select="imvert:name"/>
        <xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-SUBSETLABEL')"/>
        <xsl:variable name="tech-name">
            <xsl:choose>
                <xsl:when
                    test="imvert:stereotype/@id = ('stereotype-name-relatiesoort') and key('class',$type-id)/imvert:alias and not(empty($typering) or $typering = '')">
                    <!--xsl:value-of
                        select="imf:create-complexTypeName($berichtType,$typering,$alias,$elementName)"/-->
                    <xsl:value-of
                        select="imf:create-complexTypeName($berichtType,$typering,$alias,(),$subsetLabel)"/>
                </xsl:when>
                <xsl:when
                    test="imvert:stereotype/@id = ('stereotype-name-relatiesoort') and key('class',$type-id)/imvert:alias">
                    <!--xsl:value-of
                        select="imf:create-complexTypeName($berichtType,(),$alias,$elementName)"/-->
                    <xsl:value-of
                        select="imf:create-complexTypeName($berichtType,(),$alias,(),$subsetLabel)"/>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-relatiesoort') and not(empty($typering))">
                    <!--xsl:value-of
                        select="imf:create-complexTypeName($berichtType,$typering,(),$elementName)"/-->
                    <xsl:value-of
                        select="imf:create-complexTypeName($berichtType,$typering,(),(),$subsetLabel)"/>
                </xsl:when>
                <xsl:when test="imvert:stereotype/@id = ('stereotype-name-relatiesoort')">
                    <!--xsl:value-of
                        select="imf:create-complexTypeName($berichtType,(),(),$elementName)"/>
                    <xsl:value-of
                        select="imf:create-complexTypeName($berichtType,(),(),$elementName)"/-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="imf:create-complexTypeName($berichtType,$historyName,(),(),$subsetLabel)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="type-name" select="imvert:type-name"/>
        <xsl:variable name="max-occurs" select="imvert:max-occurs-source"/>
        <xsl:variable name="min-occurs" select="imvert:min-occurs-source"/>
        <xsl:variable name="position" select="imvert:position"/>
        <xsl:variable name="id" select="imvert:id"/>
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
        <xsl:variable name="tvs" as="element(ep:tagged-values)">
            <ep:tagged-values>
                <xsl:copy-of select="imf:get-compiled-tagged-values(., true())"/>
            </ep:tagged-values>
        </xsl:variable>
        <xsl:variable name="suppliers" as="element(ep:suppliers)">
            <ep:suppliers>
                <xsl:copy-of select="imf:get-UGM-suppliers(.)"/>
            </ep:suppliers>
        </xsl:variable>
        <xsl:variable name="matchgegeven" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEMATCHGEGEVEN')"/>
        <xsl:variable name="authentiek" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONAUTHENTIC')"/>
        <xsl:variable name="inOnderzoek" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIEINONDERZOEK')"/>

        <xsl:choose>
            <xsl:when test="not(contains($verwerkingsModus, 'matchgegevens') and $matchgegeven = 'JA')">
                 <xsl:sequence select="imf:create-debug-comment('Debuglocation 31a',$debugging)"/>
                    
                    <!-- Location: 'ep:construct10'
				 Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-structure.xsl' on the location with the id 'ep:constructRef10'. -->			
                    
                    <ep:construct type="complexData" prefix="{$verkorteAliasGerelateerdeEntiteit}" namespaceId="{$namespaceIdentifierGerelateerdeEntiteit}" version="{$UGMversionGerelateerdeEntiteit}">
                        <ep:suppliers>
                            <xsl:copy-of select="$suppliers"/>
                        </ep:suppliers>
                        <xsl:if test="$debugging">
                            <xsl:variable name="materieleHistorie" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY')"/>
                            <xsl:variable name="formeleHistorie" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY')"/>
                            <ep:tagged-values>
                                <xsl:copy-of select="$tvs"/>
                                <ep:found-tagged-values>
                                    <xsl:sequence select="imf:create-output-element('ep:materieleHistorie', $materieleHistorie)"/>
                                    <xsl:sequence select="imf:create-output-element('ep:formeleHistorie', $formeleHistorie)"/>
                                    <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
                                    <xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
                                    <xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
                                </ep:found-tagged-values>
                                <xsl:sequence select="imf:create-output-element('indicatieMaterieleHistorie', $indicatieMaterieleHistorie)"/>
                                <xsl:sequence select="imf:create-output-element('indicatieMaterieleHistorieRelatie', $indicatieMaterieleHistorieRelatie)"/>
                                <xsl:sequence select="imf:create-output-element('indicatieFormeleHistorie', $indicatieFormeleHistorie)"/>
                                <xsl:sequence select="imf:create-output-element('indicatieFormeleHistorieRelatie', $indicatieFormeleHistorieRelatie)"/>
                                
                            </ep:tagged-values>
                        </xsl:if>
                        <xsl:sequence select="imf:create-output-element('ep:name', $tech-name)"/>
                        <xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
                        <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                        
                        <!-- ROME: Het is de vraag of een relatie als authentiek bestempelt kan worden. Zo niet dan moet onderstaande sequence verwijderd worden. -->
                        <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
                        <xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
                        <xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
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
                            <xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
                            <xsl:call-template name="createRelatiePartOfAssociation">
                                <xsl:with-param name="type-id" select="$type-id"/>
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
                                
                                <xsl:if test="$generateHistorieConstruct = 'Nee'">
                                    <xsl:sequence select="imf:create-debug-comment('Debuglocation attributes 3',$debugging)"/>
                                    <xsl:sequence select="imf:create-debug-comment(concat('typeCode: relatie, berichtType: ',substring($berichtCode, 1, 2),', context: ',$context,', datumType: no, mnemonic: ',$alias,', onvolledigeDatum: no, prefix: ',$prefix,', constructId: ',$id,', dataType: -'),$debugging)"/>
                                    <xsl:variable name="attributes"
                                        select="imf:createAttributes($typeCode, substring($berichtCode, 1, 2), $context, $alias, 'no', $prefix, $id, '')"/>
                                    <xsl:sequence select="$attributes"/>
                                </xsl:if> 
                            </xsl:if>
                        </ep:seq>
                    </ep:construct>
            </xsl:when>
            <xsl:when test="contains($verwerkingsModus, 'matchgegevens') and $matchgegeven = 'JA'">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 31b',$debugging)"/>
                
                <!-- Location: 'ep:construct10'
				 Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-structure.xsl' on the location with the id 'ep:constructRef10'. -->			
                
                <ep:construct type="complexData" prefix="{$verkorteAliasGerelateerdeEntiteit}" namespaceId="{$namespaceIdentifierGerelateerdeEntiteit}" version="{$UGMversionGerelateerdeEntiteit}">
                    <ep:suppliers>
                        <xsl:copy-of select="$suppliers"/>
                    </ep:suppliers>
                    <xsl:if test="$debugging">
                        <xsl:variable name="materieleHistorie" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONMATERIALHISTORY')"/>
                        <xsl:variable name="formeleHistorie" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-INDICATIONFORMALHISTORY')"/>
                        <ep:tagged-values>
                            <xsl:copy-of select="$tvs"/>
                            <ep:found-tagged-values>
                                <xsl:sequence select="imf:create-output-element('ep:materieleHistorie', $materieleHistorie)"/>
                                <xsl:sequence select="imf:create-output-element('ep:formeleHistorie', $formeleHistorie)"/>
                                <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
                                <xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
                                <xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
                            </ep:found-tagged-values>
                            
                            <xsl:sequence select="imf:create-output-element('indicatieMaterieleHistorie', $indicatieMaterieleHistorie)"/>
                            <xsl:sequence select="imf:create-output-element('indicatieMaterieleHistorieRelatie', $indicatieMaterieleHistorieRelatie)"/>
                            <xsl:sequence select="imf:create-output-element('indicatieFormeleHistorie', $indicatieFormeleHistorie)"/>
                            <xsl:sequence select="imf:create-output-element('indicatieFormeleHistorieRelatie', $indicatieFormeleHistorieRelatie)"/>
                            
                        </ep:tagged-values>
                    </xsl:if>
                    <xsl:sequence select="imf:create-output-element('ep:name', $tech-name)"/>
                    <xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
                    <xsl:sequence select="imf:create-output-element('ep:documentation', $doc,'',false(),false())"/>
                    
                    <!-- ROME: Het is de vraag of een relatie als authentiek bestempelt kan worden. Zo niet dan moet onderstaande sequence verwijderd worden. -->
                    <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
                    <xsl:sequence select="imf:create-output-element('ep:inOnderzoek', $inOnderzoek)"/>
                    <xsl:sequence select="imf:create-output-element('ep:kerngegeven', $matchgegeven)"/>
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
                        <xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
                        <xsl:call-template name="createRelatiePartOfAssociation">
                            <xsl:with-param name="type-id" select="$type-id"/>
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
                        </xsl:call-template>
                        <!-- Only in case of an association representing a 'relatie' and containing 
				a 'gerelateerde' construct (within the above choose the first 'when' XML 
				Attributes for the 'relatie' type element have to be generated. Because these 
				has to be placed outside the 'gerelateerde' element it has to be done here. -->
                        <xsl:if test="imvert:stereotype/@id = ('stereotype-name-relatiesoort')">
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
                            <xsl:if test="$generateHistorieConstruct = 'Nee'">
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation attributes 4',$debugging)"/>
                                <xsl:variable name="attributes"
                                    select="imf:createAttributes($typeCode, substring($berichtCode, 1, 2), $context, $alias, 'no', $prefix, $id, '')"/>
                                <xsl:sequence select="$attributes"/>
                            </xsl:if> 
                        </xsl:if>
                    </ep:seq>
                </ep:construct>
            </xsl:when>
        </xsl:choose>
   </xsl:template>

    <!-- called only with attributes that have no type-id -->
    <xsl:template match="imvert:attribute" mode="mode-global-attribute-simpletype">
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 32',$debugging)"/>
        
        <xsl:variable name="suppliers" as="element(ep:suppliers)">
            <ep:suppliers>
                <xsl:copy-of select="imf:get-UGM-suppliers(.)"/>
            </ep:suppliers>
        </xsl:variable>

        <xsl:variable name="stuf-scalar" select="imf:get-stuf-scalar-attribute-type(.)"/>
        
        <xsl:variable name="max-length" select="imvert:max-length"/>
        <xsl:variable name="total-digits" select="imvert:total-digits"/>
        <xsl:variable name="fraction-digits" select="imvert:fraction-digits"/>
        
        <xsl:variable name="min-waarde" select="imf:get-tagged-value(.,'##CFG-TV-MINVALUEINCLUSIVE')"/>
        <xsl:variable name="max-waarde" select="imf:get-tagged-value(.,'##CFG-TV-MAXVALUEINCLUSIVE')"/>
        <xsl:variable name="min-length" select="xs:integer(imf:get-tagged-value(.,'##CFG-TV-MINLENGTH'))"/>
        <xsl:variable name="patroon" select="imvert:pattern"/>
        
        <xsl:variable name="nillable-patroon" select="if (normalize-space($patroon)) then concat('(', $patroon,')?') else ()"/>

        <xsl:variable name="facetten">
            <xsl:sequence select="imf:create-facet('ep:formeel-patroon',$nillable-patroon)"/>
            <xsl:sequence select="imf:create-facet('ep:min-value',$min-waarde)"/>
            <xsl:sequence select="imf:create-facet('ep:max-value',$max-waarde)"/>
            <xsl:sequence select="imf:create-facet('ep:min-length',string($min-length))"/>
            <xsl:sequence select="imf:create-facet('ep:max-length',$max-length)"/>
            <xsl:sequence select="imf:create-facet('ep:length',$total-digits)"/>
            <xsl:sequence select="imf:create-facet('ep:fraction-digits',$fraction-digits)"/>
        </xsl:variable>
        <xsl:variable name="compiled-name" select="imf:useable-attribute-name(imf:get-compiled-name(.),.)"/>
        
        <xsl:variable name="name" select="imf:capitalize($compiled-name)"/>
        <xsl:variable name="subsetLabel" select="imf:get-most-relevant-compiled-taggedvalue(., '##CFG-TV-SUBSETLABEL')"/>
        
        <xsl:choose>
            <xsl:when test="imvert:type-package='GML3'">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 32a',$debugging)"/>

                <xsl:variable name="construct-Prefix" select="$suppliers//supplier[1]/@verkorteAlias"/>
                
                <xsl:if test="$global-e-types-allowed = 'Ja'">
                    <ep:construct type="simpleContentcomplexData" prefix="{$construct-Prefix}" addedLevel="yes">
                        <xsl:sequence select="imf:create-output-element('ep:name', concat(imf:capitalize(imvert:baretype),'-e'))"/>
                        <xsl:sequence select="imf:create-output-element('ep:tech-name', concat(imf:capitalize(imvert:baretype),'-e'))"/>
                        <ep:type-name>
                            <xsl:value-of select="imf:get-external-type-name(.,true())"/>
                        </ep:type-name>
                        <xsl:if test="$global-noValue-allowed = 'Ja'">
                            <ep:seq>
                                <ep:construct ismetadata="yes">
                                    <xsl:sequence select="imf:create-output-element('ep:name', 'noValue')"/>
                                    <xsl:sequence select="imf:create-output-element('ep:tech-name', 'noValue')"/>
                                    <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                    <ep:min-occurs>0</ep:min-occurs>
                                </ep:construct>
                            </ep:seq>
                        </xsl:if>
                    </ep:construct>
                    <!-- ROME: Onderzoeken hoe we kunnen bepalen of er een apart type met wildcard bij GML types opgenomen moet worden.
                               Een wildcard mag immers alleen bij een stringtype opgenomen worden en alleen binnen selecties.
                               Nog geen idee hoe ik kan bepalen of een GML type String based is.-->
                    <xsl:if test="(empty($nillable-patroon) or $min-length = 0)">
                        <ep:construct type="simpleContentcomplexData" prefix="{$construct-Prefix}" addedLevel="yes">
                            <xsl:sequence select="imf:create-output-element('ep:name', concat(imf:capitalize(imvert:baretype),'Vraag-e'))"/>
                            <xsl:sequence select="imf:create-output-element('ep:tech-name', concat(imf:capitalize(imvert:baretype),'Vraag-e'))"/>
                            <ep:type-name>
                                <xsl:value-of select="imf:get-external-type-name(.,true())"/>
                            </ep:type-name>
                            <ep:seq>
                                <xsl:if test="$global-noValue-allowed = 'Ja'">
                                    <ep:construct ismetadata="yes">
                                        <xsl:sequence select="imf:create-output-element('ep:name', 'noValue')"/>
                                        <xsl:sequence select="imf:create-output-element('ep:tech-name', 'noValue')"/>
                                        <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                        <ep:min-occurs>0</ep:min-occurs>
                                    </ep:construct>
                                </xsl:if>
                                <ep:construct ismetadata="yes">
                                    <xsl:sequence select="imf:create-output-element('ep:name', 'wildcard')"/>
                                    <xsl:sequence select="imf:create-output-element('ep:tech-name', 'wildcard')"/>
                                    <ep:type-name><xsl:value-of select="concat($StUF-prefix,':Wildcard')"/></ep:type-name>
                                    <ep:min-occurs>0</ep:min-occurs>
                                </ep:construct>                     
                            </ep:seq>
                        </ep:construct>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <!-- The only situation in which imvert:attribute elements have the tagged value 'Subset label' is when they're part of the custom 'parameters',
                 'stuurgegevens' or 'systeem' groep. In that case the construct always has to be placed within the StUF namespace and no -e complextype is neccessary. -->
            <xsl:when test="not(empty($subsetLabel))">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 32b',$debugging)"/>
                <xsl:variable name="attributeName" select="imvert:name/@original"/>
                <ep:construct type="simpleData" prefix="{$StUF-prefix}" isdatatype="yes">
                    <xsl:sequence select="imf:create-output-element('ep:name', concat(imf:capitalize($attributeName),'-',$subsetLabel))"/>
                    <xsl:sequence select="imf:create-output-element('ep:tech-name', concat(imf:capitalize($attributeName),'-',$subsetLabel))"/>
                    <xsl:choose>
                        <xsl:when test="imvert:type-name = 'scalar-integer'">
                            <ep:data-type>scalar-integer</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-string'">
                            <ep:data-type>scalar-string</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-decimal'">
                            <ep:data-type>scalar-decimal</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-boolean'">
                            <ep:data-type>scalar-boolean</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-date'">
                            <ep:data-type>scalar-date</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-txt'">
                            <ep:data-type>scalar-string</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>    
                        <xsl:when test="imvert:type-name = 'scalar-uri'">
                            <ep:data-type>xs:anyURI</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-postcode'">
                            <ep:data-type>scalar-postcode</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-year'">
                            <ep:data-type>xs:gYear</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-month'">
                            <ep:data-type>xs:gMonth</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:when test="imvert:type-name = 'scalar-day'">
                            <ep:data-type>xs:gDay</ep:data-type>
                            <xsl:sequence select="$facetten"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the simple attribute type: [1]', imvert:type-name)"/>
                        </xsl:otherwise>                
                    </xsl:choose>
                </ep:construct>
                
            </xsl:when>
            <xsl:when test="exists($stuf-scalar)">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 32c',$debugging)"/>
                <!-- gedefinieerd in onderlaag -->
            </xsl:when>
            <!-- ROME: Ik vraag me af of het type 'Melding' wel ergens voorkomt. Checken!. -->
            <xsl:when test="exists(imvert:type-name) and not($name = 'Melding' or $name = 'AantalVoorkomens' or $name = 'Sortering' or $name = 'Functie' or $name = 'Volgnummer')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 32d',$debugging)"/>

                <xsl:variable name="checksum-strings" select="imf:get-blackboard-simpletype-entry-info(.)"/>
                <xsl:variable name="checksum-string" select="imf:store-blackboard-simpletype-entry-info($checksum-strings)"/>
                <xsl:variable name="tokens" select="tokenize($checksum-string,'\[SEP\]')"/>
                
                <xsl:variable name="v" select="$suppliers//supplier[1]"/>
               
                <xsl:variable name="construct-Prefix" as="xs:string?">
                    <xsl:choose>
                        <xsl:when test="contains(ancestor::imvert:class/imvert:alias, '/www.kinggemeenten.nl/BSM/Berichtstrukturen')">
                            <xsl:value-of select="$StUF-prefix"/>
                        </xsl:when>
                        <xsl:when test="empty($v)">
                            <xsl:sequence select="imf:msg(.,'ERROR', 'No suppliers found.',())"/>
                        </xsl:when>
                        <xsl:when test="exists($v/@verkorteAlias)">
                            <xsl:value-of select="$v/@verkorteAlias"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="imf:msg(.,'ERROR', 'Supplier does not supply [1].',('Verkorte alias'))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="exists($construct-Prefix)">
                        <xsl:if test="$global-e-types-allowed = 'Ja'">
                            <ep:construct type="simpleContentcomplexData" prefix="{$construct-Prefix}" imvert:checksum="{concat($checksum-string,'-simpleContentcomplexData')}" addedLevel="yes">
                                <xsl:if test="$debugging">
                                    <xsl:copy-of select="$suppliers"/>
                                </xsl:if>
                                <xsl:sequence select="imf:create-output-element('ep:name', concat($tokens[1],'-e'))"/>
                                <xsl:sequence select="imf:create-output-element('ep:tech-name', concat($tokens[1],'-e'))"/>
                                <ep:type-name imvert:checksum="{$checksum-string}">
                                    <xsl:value-of select="concat($construct-Prefix,':',$tokens[1])"/>
                                </ep:type-name>
                                <xsl:if test="$global-noValue-allowed = 'Ja'">
                                    <ep:seq>
                                        <ep:construct ismetadata="yes">
                                            <xsl:sequence select="imf:create-output-element('ep:name', 'noValue')"/>
                                            <xsl:sequence select="imf:create-output-element('ep:tech-name', 'noValue')"/>
                                            <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                            <ep:min-occurs>0</ep:min-occurs>
                                        </ep:construct>                     
                                    </ep:seq>
                                </xsl:if>
                            </ep:construct>
                            <xsl:if test="(empty($nillable-patroon) or $min-length = 0) and starts-with($checksum-string,'String')">
                                <ep:construct type="simpleContentcomplexData" prefix="{$construct-Prefix}" imvert:checksum="{concat($checksum-string,'-Vraag-simpleContentcomplexData')}">
                                    <xsl:sequence select="imf:create-output-element('ep:name', concat($tokens[1],'Vraag-e'))"/>
                                    <xsl:sequence select="imf:create-output-element('ep:tech-name', concat($tokens[1],'Vraag-e'))"/>
                                    <ep:type-name imvert:checksum="{$checksum-string}">
                                        <xsl:value-of select="concat($construct-Prefix,':',$tokens[1])"/>
                                    </ep:type-name>
                                    <ep:seq>
                                        <xsl:if test="$global-noValue-allowed = 'Ja'">
                                            <ep:construct ismetadata="yes">
                                                <xsl:sequence select="imf:create-output-element('ep:name', 'noValue')"/>
                                                <xsl:sequence select="imf:create-output-element('ep:tech-name', 'noValue')"/>
                                                <ep:type-name><xsl:value-of select="concat($StUF-prefix,':NoValue')"/></ep:type-name>
                                                <ep:min-occurs>0</ep:min-occurs>
                                            </ep:construct>
                                        </xsl:if>
                                        <ep:construct ismetadata="yes">
                                            <xsl:sequence select="imf:create-output-element('ep:name', 'wildcard')"/>
                                            <xsl:sequence select="imf:create-output-element('ep:tech-name', 'wildcard')"/>
                                            <ep:type-name><xsl:value-of select="concat($StUF-prefix,':Wildcard')"/></ep:type-name>
                                            <ep:min-occurs>0</ep:min-occurs>
                                        </ep:construct>                     
                                    </ep:seq>
                                </ep:construct>
                            </xsl:if>
                        </xsl:if>
                        <ep:construct type="simpleData" prefix="{$construct-Prefix}" isdatatype="yes" imvert:checksum="{concat($checksum-string,'-simpleData')}">
                            <xsl:sequence select="imf:create-output-element('ep:name', $tokens[1])"/>
                            <xsl:sequence select="imf:create-output-element('ep:tech-name', $tokens[1])"/>
                            <xsl:choose>
                                <xsl:when test="imvert:type-name = 'scalar-integer'">
                                    <ep:data-type>scalar-integer</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>
                                <xsl:when test="imvert:type-name = 'scalar-string'">
                                    <ep:data-type>scalar-string</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>
                                <xsl:when test="imvert:type-name = 'scalar-decimal'">
                                    <ep:data-type>scalar-decimal</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>
                                <xsl:when test="imvert:type-name = 'scalar-boolean'">
                                    <ep:data-type>scalar-boolean</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>
                                <xsl:when test="imvert:type-name = 'scalar-date'">
                                    <ep:data-type>scalar-date</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>
                                <xsl:when test="imvert:type-name = 'scalar-txt'">
                                    <ep:data-type>scalar-string</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>    
                                <xsl:when test="imvert:type-name = 'scalar-uri'">
                                    <ep:data-type>xs:anyURI</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>
                                <xsl:when test="imvert:type-name = 'scalar-postcode'">
                                    <ep:data-type>scalar-postcode</ep:data-type>
                                    <xsl:sequence select="$facetten"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the simple attribute type: [1]', imvert:type-name)"/>
                                </xsl:otherwise>                
                            </xsl:choose>
                        </ep:construct>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- skip error situation -->
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="imf:create-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>

        <xsl:value-of select="imf:create-complexTypeName($berichtName,$typering,())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>
        <xsl:param name="alias"/>
        
         <xsl:value-of select="imf:create-complexTypeName($berichtName,$typering,$alias,())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>
        <xsl:param name="alias"/>
        <xsl:param name="elementName"/>
        
        <xsl:value-of select="imf:create-complexTypeName($berichtName,$typering,$alias,$elementName,())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>
        <xsl:param name="alias"/>
        <xsl:param name="elementName"/>
        <xsl:param name="subsetLabel"/>
        <xsl:choose>
            <xsl:when test="empty($typering)">
                <xsl:sequence select="imf:create-debug-track(concat('LET OP: typering is empty: ',$typering),$debugging)"/>            
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-track(concat('LET OP: typering is NIET empty: ',$typering),$debugging)"/>            
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:sequence select="imf:create-debug-track(concat('berichtName: ',$berichtName,', typering: ',$typering,', alias: ',$alias,', element: ',$elementName),$debugging)"/>
        <xsl:variable name="complexTypeName">
            <xsl:choose>
                <xsl:when test="not(empty($alias)) and not(empty($typering))">
                    <xsl:value-of select="concat($alias,'-')"/>
                </xsl:when>
                <xsl:when test="not(empty($alias))">
                    <xsl:value-of select="$alias"/>
                </xsl:when>
                <xsl:when test="empty($alias) and not(empty($typering)) and not(empty($elementName)) ">
                    <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)),'-')"/>
                </xsl:when>
                <xsl:when test="empty($alias) and not(empty($elementName))">
                    <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)))"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="not(empty($typering))">
                    <xsl:value-of select="concat(upper-case(substring($typering,1,1)),lower-case(substring($typering,2)))"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:if test="not(empty($alias)) and not(empty($elementName))">
                <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)))"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:sequence select="imf:create-debug-track(concat('complexTypeName: ',$complexTypeName),$debugging)"/>
        
        <xsl:choose>
            <xsl:when test="empty($alias) and not(empty($elementName))">
                <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/>-<xsl:value-of select="$berichtName"/>
                <xsl:if test="not(empty($subsetLabel))">
                    <xsl:value-of select="concat('-',$subsetLabel)"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="empty($typering) and empty($alias) and empty($elementName)">
                <xsl:value-of select="$berichtName"/>
                <xsl:if test="not(empty($subsetLabel))">
                    <xsl:value-of select="concat('-',$subsetLabel)"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/>-<xsl:value-of select="$berichtName"/>
                <xsl:if test="not(empty($subsetLabel))">
                    <xsl:value-of select="concat('-',$subsetLabel)"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <?x xsl:function name="imf:create-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>
        <xsl:param name="alias"/>
        <xsl:param name="elementName"/>
        <xsl:param name="subsetLabel"/>
        <xsl:choose>
            <xsl:when test="empty($typering)">
                <xsl:sequence select="imf:create-debug-track(concat('LET OP: typering is empty: ',$typering),$debugging)"/>            
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-track(concat('LET OP: typering is NIET empty: ',$typering),$debugging)"/>            
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:sequence select="imf:create-debug-track(concat('berichtName: ',$berichtName,', typering: ',$typering,', alias: ',$alias,', element: ',$elementName),$debugging)"/>
        <xsl:variable name="complexTypeName">
            <xsl:choose>
                <xsl:when test="not(empty($alias)) and not(empty($typering))">
                    <xsl:value-of select="concat('Robert1',$alias,'-')"/>
                </xsl:when>
                <xsl:when test="not(empty($alias))">
                    <xsl:value-of select="concat('Robert2',$alias)"/>
                </xsl:when>
                <xsl:when test="empty($alias) and not(empty($typering)) and not(empty($elementName)) ">
                    <xsl:value-of select="concat('Robert3',upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)),'-')"/>
                </xsl:when>
                <xsl:when test="empty($alias) and not(empty($elementName))">
                    <xsl:value-of select="concat('Robert4',upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Robert5'"/>                    
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="not(empty($typering))">
                    <xsl:value-of select="concat('Robert6',upper-case(substring($typering,1,1)),lower-case(substring($typering,2)),'.')"/>
                </xsl:when>
                <xsl:otherwise>Robert7.</xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(empty($alias)) and not(empty($elementName))">
                <xsl:value-of select="concat('Robert8',upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)))"/>
            </xsl:if>
        </xsl:variable>
        
        <xsl:sequence select="imf:create-debug-track(concat('complexTypeName: ',$complexTypeName),$debugging)"/>
        
        <xsl:choose>
            <xsl:when test="empty($alias) and not(empty($elementName))">
                <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/><xsl:value-of select="$berichtName"/>
                <xsl:if test="not(empty($subsetLabel))">
                    <xsl:value-of select="concat('-Robert9',$subsetLabel)"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/>-<xsl:value-of select="$berichtName"/>
                <xsl:if test="not(empty($subsetLabel))">
                    <xsl:value-of select="concat('-Robert9',$subsetLabel)"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function x?>

    <xsl:function name="imf:create-Grp-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="type"/>
        <xsl:param name="elementName"/>      
        
        <xsl:value-of select="imf:create-Grp-complexTypeName($berichtName,$type,$elementName,())"/>
    </xsl:function>

    <xsl:function name="imf:create-Grp-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="type"/>
        <xsl:param name="elementName"/>      
        <xsl:param name="typering"/>
        
        <xsl:value-of select="imf:create-Grp-complexTypeName($berichtName,$type,$elementName,$typering,())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-Grp-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="type"/>
        <xsl:param name="elementName"/>      
        <xsl:param name="typering"/>
        <xsl:param name="subsetLabel"/>
        
        <xsl:sequence select="imf:create-debug-track(concat('berichtName: ',$berichtName,', type: ',$type,', element: ',$elementName,', typering: ',$typering),$debugging)"/>
        
        <xsl:variable name="complexTypeName">
            <xsl:value-of select="concat(upper-case(substring($type,1,1)),lower-case(substring($type,2)),'-')"/>
            <xsl:choose>
                <xsl:when test="not(empty($typering))">
                    <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)),'-')"/>
                    <xsl:value-of select="concat(upper-case(substring($typering,1,1)),lower-case(substring($typering,2)))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="imf:create-debug-track(concat('complexTypeName: ',$complexTypeName),$debugging)"/>
        
        <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/>-<xsl:value-of select="$berichtName"/>
            <xsl:if test="not(empty($subsetLabel))">
                <xsl:value-of select="concat('-',$subsetLabel)"/>
            </xsl:if>
    </xsl:function>

    <?x xsl:function name="imf:create-Grp-complexTypeName">
        <xsl:param name="berichtName"/>
        <xsl:param name="type"/>
        <xsl:param name="elementName"/>      
        <xsl:param name="typering"/>
        <xsl:param name="subsetLabel"/>
        
        <xsl:sequence select="imf:create-debug-track(concat('berichtName: ',$berichtName,', type: ',$type,', element: ',$elementName,', typering: ',$typering),$debugging)"/>
        
        <xsl:variable name="complexTypeName">
            <xsl:value-of select="concat(upper-case(substring($type,1,1)),lower-case(substring($type,2)),'-')"/>
            <xsl:choose>
                <xsl:when test="not(empty($typering))">
                    <xsl:value-of select="concat('Robert10',upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)),'-')"/>
                    <xsl:value-of select="concat(upper-case(substring($typering,1,1)),lower-case(substring($typering,2)),'.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('Robert11',upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)),'.')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="imf:create-debug-track(concat('complexTypeName: ',$complexTypeName),$debugging)"/>
        
        <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/><xsl:value-of select="$berichtName"/>
        <xsl:if test="not(empty($subsetLabel))">
            <xsl:value-of select="concat('-Robert12',$subsetLabel)"/>
        </xsl:if>
        
    </xsl:function x?>
    
    <xsl:function name="imf:useable-attribute-name">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="attribute" as="element(imvert:attribute)"/>
        <xsl:choose>
            <xsl:when test="empty($attribute/imvert:type-id) and exists($attribute/imvert:baretype) and count($all-simpletype-attributes[imvert:name = $attribute/imvert:name]) gt 1">
                <!--xx <xsl:message select="concat($attribute/imvert:name, ';', $attribute/@display-name)"/> xx-->
                <xsl:value-of select="concat($name,$attribute/../../imvert:alias)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:create-facet" as="element()?">
        <xsl:param name="elementname"/>
        <xsl:param name="content"/>
        <xsl:if test="normalize-space($content)">
            <xsl:element name="{$elementname}">
                <xsl:value-of select="$content"/>
            </xsl:element>
        </xsl:if>
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
            <xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-composite')">
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
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-enumeration')">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:when test="$type = 'class' and $stereotype = ('stereotype-name-union')">
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
            <!-- TODO meer soorten namen uitwerken? -->
            <xsl:otherwise>
                <xsl:sequence select="imf:msg($this,'ERROR','Unknown type [1] with stereo [2]', ($type, string-join($stereotype,', ')))"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="imf:get-stuf-scalar-attribute-type" as="xs:string?">
        <xsl:param name="attribute"/>
        
        <xsl:choose>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-date' and $attribute/imvert:type-modifier = '?' and $global-e-types-allowed = 'Ja'">
                <xsl:value-of select="concat($StUF-prefix,':DatumMogelijkOnvolledig-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-date' and $attribute/imvert:type-modifier = '?' and $global-e-types-allowed = 'Nee'">
                <xsl:value-of select="concat($StUF-prefix,':DatumMogelijkOnvolledig-r')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-date' and $global-e-types-allowed = 'Ja'">
                <xsl:value-of select="concat($StUF-prefix,':Datum-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-date' and $global-e-types-allowed = 'Nee'">
                <xsl:value-of select="concat($StUF-prefix,':Datum-r')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-datetime' and $attribute/imvert:type-modifier = '?' and $global-e-types-allowed = 'Ja'">
                <xsl:value-of select="concat($StUF-prefix,':TijdstipMogelijkOnvolledig-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-datetime' and $attribute/imvert:type-modifier = '?' and $global-e-types-allowed = 'Nee'">
                <xsl:value-of select="concat($StUF-prefix,':TijdstipMogelijkOnvolledig-r')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-datetime' and $global-e-types-allowed = 'Ja'">
                <xsl:value-of select="concat($StUF-prefix,':Tijdstip-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-datetime' and $global-e-types-allowed = 'Nee'">
                <xsl:value-of select="concat($StUF-prefix,':Tijdstip-r')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-year' and $global-e-types-allowed = 'Ja'">
                <xsl:value-of select="concat($StUF-prefix,':Jaar-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-year' and $global-e-types-allowed = 'Nee'">
                <xsl:value-of select="concat($StUF-prefix,':Jaar-r')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-yearmonth'">
                <xsl:value-of select="concat($StUF-prefix,':JaarMaand-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-postcode'">
                <xsl:value-of select="concat($StUF-prefix,':Postcode-e')"/>
            </xsl:when>
            <xsl:when test="$attribute/imvert:type-name = 'scalar-boolean'">
                <xsl:value-of select="concat($StUF-prefix,':INDIC-e')"/>
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="imf:capitalize">
        <xsl:param name="name"/>
        <xsl:value-of select="concat(upper-case(substring($name,1,1)),substring($name,2))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-stereotype">
        <xsl:param name="this"/>
        <xsl:sequence select="$this/imvert:stereotype/@id"/>
    </xsl:function>
    
    <xsl:function name="imf:get-external-type-name">
        <xsl:param name="attribute"/>
        <xsl:param name="as-type" as="xs:boolean"/>
        <!-- determine the name; hard koderen -->
        <xsl:for-each select="$attribute"> <!-- singleton -->
            <xsl:choose>
                <xsl:when test="imvert:type-package='Geography Markup Language 3'">
                    <xsl:variable name="type-suffix" select="if ($as-type) then 'Type' else ''"/>
                    <xsl:variable name="type-prefix">
                        <xsl:choose>
                            <xsl:when test="empty(imvert:conceptual-schema-type)">
                                <xsl:sequence select="imf:msg(.,'ERROR','No conceptual schema type specified',())"/>
                            </xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Point'">gml:Point</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Curve'">gml:Curve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Surface'">gml:Surface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiPoint'">gml:MultiPoint</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiSurface'">gml:MultiSurface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiCurve'">gml:MultiCurve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Geometry'">gml:Geometry</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiGeometry'">gml:MultiGeometry</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_ArcString'">gml:ArcString</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_LineString'">gml:LineString</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Polygon'">gml:Polygon</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Object'">gml:GeometryProperty</xsl:when><!-- see http://www.geonovum.nl/onderwerpen/geography-markup-language-gml/documenten/handreiking-geometrie-model-en-gml-10 -->
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Primitive'">gml:Primitive</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Position'">gml:Position</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_PointArray'">gml:PointArray</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Solid'">gml:Solid</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_OrientableCurve'">gml:OrientableCurve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_OrientableSurface'">gml:OrientableSurface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_CompositePoint'">gml:CompositePoint</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiSolid'">gml:MultiSolid</xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the [1] type [2]', (imvert:type-package,imvert:conceptual-schema-type))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="concat($type-prefix,$type-suffix)"/>
                </xsl:when>
                <xsl:when test="empty(imvert:type-package)">
                    <!-- TODO -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- geen andere externe packages bekend -->
                    <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the external package [1]', imvert:type-package)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:function>
    
</xsl:stylesheet>
