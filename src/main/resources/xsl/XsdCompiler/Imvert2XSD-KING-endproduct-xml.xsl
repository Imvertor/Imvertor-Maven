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
    
    xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310" 
    xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
    xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" 
    xmlns:stuf="http://www.egem.nl/StUF/StUF0301" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" 
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="Imvert2XSD-KING-enrich-excel.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
    
    <xsl:import href="Imvert2XSD-KING-create-endproduct-rough-structure.xsl"/>
    <xsl:import href="Imvert2XSD-KING-create-endproduct-structure.xsl"/>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="stylesheet">Imvert2XSD-KING-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $</xsl:variable>  
    
<!-- ROME: Heel vreemd maar de volgende twee (uitbecommentarieerde) variabelen zijn toch anders dan de daarop volgende 2 variabelen (waarbij de functie
           'buildParametersAndStuurgegevens' wel werkt. -->
    <?x xsl:variable name="config-schemarules" select="imf:get-config-schemarules()"/>
    <xsl:variable name="config-tagged-values" select="imf:get-config-tagged-values()"/ x?>
    
    <xsl:variable name="config-schemarules">
        <xsl:sequence select="imf:get-config-schemarules()"/>
    </xsl:variable> 
    <xsl:variable name="config-tagged-values">
        <xsl:sequence select="imf:get-config-tagged-values()"/>
    </xsl:variable> 
    
    <!-- set the processing parameters of the stylesheets. -->
    <xsl:variable name="debug" select="'yes'"/>
    
    <!-- Within the next variable the configurations defined within the Base-configuration spreadsheet are placed in a processed XML format.
         With this configuration the attributes to be used on each location within the XML schemas are determined. -->
    <xsl:variable name="enriched-endproduct-base-config-excel">
        <result>
            <xsl:if test="$endproduct-base-config-excel = ''">
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
                    <xsl:variable name="xml-path" select="imf:serializeExcel($endproduct-base-config-excel,concat($workfolder-path,'/excel.xml'),$excel-97-dtd-path)"/>
                    <xsl:variable name="xml-doc" select="imf:document(imf:file-to-url($xml-path))"/>
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
    
    <xsl:variable name="berichtNaam" select="/imvert:packages/imvert:application"/>

    <xsl:variable name="packages" select="/imvert:packages"/>
    
    <!-- Within this variable a rough message structure is created to be able to determine e.g. the correct global construct structures. -->
    <xsl:variable name="rough-messages">
        <ep:rough-messages>
            <xsl:apply-templates select="$packages/imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package') and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-rough-message-structure"/>
        </ep:rough-messages>
    </xsl:variable>
    
    <!-- This key is used within the for-each instruction further in this code. -->
    <xsl:key name="construct-id" match="ep:construct" use="ep:type-id" />
    
    <!-- Within this variable all messages defined within the BSM of the koppelvlak are placed, transformed to the imvertor endproduct format.-->
    <xsl:variable name="imvert-endproduct">
        <xsl:variable name="prefix">
            <xsl:choose>
                <xsl:when test="/imvert:packages/imvert:tagged-values/imvert:tagged-value[imvert:name/@original='Verkorte alias']">
                    <xsl:value-of select="/imvert:packages/imvert:tagged-values/imvert:tagged-value[imvert:name/@original='Verkorte alias']/imvert:value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="TODO"/>
                    <xsl:variable name="msg" select="'You have not provided a short alias. Define the tagged value &quot;Verkorte alias&quot; on the package with the stereotyp &quot;Koppelvlak&quot;.'"/>
                    <xsl:sequence select="imf:msg('WARN',$msg)"/>
                    <!--xsl:message
                           select="concat('WARNING ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : You have not provided a short alias. Define the tagged value &quot;Verkorte alias&quot; on the package with the stereotyp &quot;Koppelvlak&quot;.')" /-->
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="msg" select="'Creating the Endproduct structure'"/>
        <xsl:sequence select="imf:msg('DEBUG',$msg)"/>

        <ep:message-set>
           <xsl:sequence select="imf:create-output-element('ep:date', substring-before(/imvert:packages/imvert:generated,'T'))"/>
           <xsl:sequence select="imf:create-output-element('ep:name', /imvert:packages/imvert:project)"/>
           <xsl:sequence select="imf:create-output-element('ep:namespace', /imvert:packages/imvert:base-namespace)"/>
           <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $prefix)"/>
           <xsl:sequence select="imf:create-output-element('ep:patch-number', 'TO-DO')"/>
           <xsl:sequence select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)"/>
            
           <xsl:sequence select="$rough-messages"/>
           
           <xsl:variable name="messages">
               <xsl:apply-templates select="$packages/imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package') and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-message-structure"/>
           </xsl:variable>
           <xsl:sequence select="$messages"/>
           
           
           <!-- The following for-each takes care of creating global construct elements for each ep:construct element present within the 'rough-messages' variable 
                having a type-id value none of the preceding ep:construct elements have. -->
           <xsl:for-each select="$rough-messages//ep:construct[ep:type-id and generate-id(.) = generate-id(key('construct-id',ep:type-id,$rough-messages)[1])]">
               <!--xsl:variable name="berichtCode" select="ancestor::ep:rough-message/ep:code"-->
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
               <xsl:variable name="context">
                   <xsl:choose>
                       <xsl:when test="@context=''">
                           <xsl:value-of select="'-'"/>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:value-of select="@context"/>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:variable>
               <xsl:variable name="id" select="ep:id"/>
               <xsl:variable name="type-id" select="ep:type-id"/>
               <xsl:variable name="typeCode" select="@typeCode"/>
               <xsl:variable name="historyApplies">
                   <xsl:choose>
                       <xsl:when test="$berichtCode = 'La07' or $berichtCode = 'La08'">yes-Materieel</xsl:when>
                       <xsl:when test="$berichtCode = 'La09' or $berichtCode = 'La10'">yes</xsl:when>
                       <xsl:otherwise>no</xsl:otherwise>
                   </xsl:choose>
               </xsl:variable>
               
               <!-- LET OP! We moeten bij het bepalen van de globale complexTypes niet alleen kijken of ze hergebruikt worden over de berichten 
                    maar ook of ze over die berichten heen wel hetzelfde moeten blijven. Het ene bericht heeft een hele ander type complexType nodig dan het andere.
                    Ik moet dus hier indien nodig meerdere ep:constructs aanmaken voor elke situatie. Zie ook RM-488140-->
               
               
               <xsl:choose>
                   <!-- The following when generates global constructs based on uml groups. -->
                   <xsl:when test="@type='group' and $packages//imvert:class[imvert:id = $type-id]">
                       <xsl:variable name="docs">
                           <imvert:complete-documentation>
                               <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $type-id])"/>
                           </imvert:complete-documentation>
                       </xsl:variable>
                       <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                       
                       <xsl:if test="imf:boolean($debug)">
                           <xsl:comment select="'For-each-when: @type=group and $packages//imvert:class[imvert:id = $type-id]'"/>
                       </xsl:if>
                       
                       <ep:construct type="group">
                           <xsl:sequence
                               select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'))" />
                           <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                           <ep:seq>
                               
                               <!-- Within the following apply-templates parameters are used which are also used in other apply-templates in this and other stylesheets.
                                    These have the following function:
                                    
                                    proces-type: 
                                    -->
                               
                               <!-- The uml attributes of the uml group are placed here. -->
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="proces-type" select="'attributes'" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <!-- The uml groups of the uml group are placed here. -->
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                               <!-- The uml associations of the uml group are placed here. -->
                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                   mode="create-message-content">
                                   <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                   <xsl:with-param name="context" select="$context" />
                               </xsl:apply-templates>
                           </ep:seq> 
                       </ep:construct>                       
                       
                       <xsl:if test="imf:boolean($debug)">
                           <xsl:comment select="' For-each-when: @type=group and $packages//imvert:class[imvert:id = $type-id] End-For-each-when'"/>
                       </xsl:if>
                   </xsl:when>
                   <!-- The following when generates global constructs based on uml classes. -->
                   <xsl:when test="$packages//imvert:class[imvert:id = $type-id]">
                       <xsl:variable name="docs">
                           <imvert:complete-documentation>
                               <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $type-id])"/>
                           </imvert:complete-documentation>
                       </xsl:variable>
                       <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                       
                       <xsl:if test="imf:boolean($debug)">
                           <xsl:comment select="'For-each-when: $packages//imvert:class[imvert:id = $type-id]'"/>
                       </xsl:if>
                       
                       <ep:construct>
                           <!-- The value of the tech-name is dependant on the availability of an alias. -->
                           <xsl:choose>
                               <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name')))" />
                               </xsl:when>
                               <xsl:otherwise>
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'))" />                                       
                               </xsl:otherwise>
                           </xsl:choose>
                           <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                           <xsl:choose>
                               <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                               <xsl:when test="$packages//imvert:class[imvert:supertype/imvert:type-id = $type-id]">
                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                       mode="create-message-content">
                                       <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="context" select="$context" />
                                   </xsl:apply-templates>
                               </xsl:when>
                               <!-- Else the content of the current uml class is processed. -->
                               <xsl:otherwise>
                                   <ep:seq>
                                       <!-- The uml attributes of the uml class are placed here. -->
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                           mode="create-message-content">
                                           <xsl:with-param name="proces-type" select="'attributes'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                       </xsl:apply-templates>
                                       <!-- The uml groups of the uml class are placed here. -->
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                           mode="create-message-content">
                                           <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                           <!-- If the class is refered to form an association which is part of an VRIJ BERICHT no stuurgegevens must be generated. -->
                                           <xsl:with-param name="useStuurgegevens">
                                               <xsl:choose>
                                                   <xsl:when test="$packages//imvert:association[imvert:type-id = $type-id]/imvert:stereotype = 'BERICHTRELATIE'">
                                                      <xsl:value-of select="'no'"/>
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <xsl:value-of select="'yes'"/>
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </xsl:with-param>                                      
                                       </xsl:apply-templates>
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
                                       <xsl:if test="$packages//imvert:class[imvert:id = $type-id]/imvert:stereotype != 'KENNISGEVINGBERICHTTYPE' and
                                           $packages//imvert:class[imvert:id = $type-id]/imvert:stereotype != 'VRAAGBERICHTTYPE' and
                                           $packages//imvert:class[imvert:id = $type-id]/imvert:stereotype != 'ANTWOORDBERICHTTYPE' and
                                           $packages//imvert:class[imvert:id = $type-id]/imvert:stereotype != 'SYNCHRONISATIEBERICHTTYPE'">
                                           <?x ep:construct>
                                               <!--ep:name>StUF:tijdvakObject</ep:name-->
                                               <ep:tech-name>StUF:tijdvakObject</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>150</ep:position>
                                           </ep:construct x?>
                                           <ep:construct>
                                               <!--ep:name>StUF:tijdvakGeldigheid</ep:name-->
                                               <ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>155</ep:position>
                                           </ep:construct>
                                           <ep:construct>
                                               <!--ep:name>StUF:tijdstipRegistratie</ep:name-->
                                               <ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>160</ep:position>
                                           </ep:construct>
                                           <ep:construct>
                                               <!--ep:name>StUF:extraElementen</ep:name-->
                                               <ep:tech-name>StUF:extraElementen</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>165</ep:position>
                                           </ep:construct>
                                           <ep:construct>
                                               <!--ep:name>StUF:aanvullendeElementen</ep:name-->
                                               <ep:tech-name>StUF:aanvullendeElementen</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>170</ep:position>
                                           </ep:construct>
                                       </xsl:if>
                                       <!-- If 'Materiele historie' or 'Formele historie' is applicable for the current class a constructRef to a historieMaterieel global construct based on the current class is generated. -->
                                       <xsl:if test="@indicatieMaterieleHistorie='Ja' or @indicatieFormeleHistorie='Ja'">
                                           <ep:constructRef>
                                               <ep:tech-name>historieMaterieel</ep:tech-name>
                                               <ep:max-occurs>unbounded</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>175</ep:position>
                                               <xsl:choose>
                                                   <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieMaterieel'))" />
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:href', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieMaterieel')" />                                       
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </ep:constructRef>
                                       </xsl:if>
                                       <!-- If 'Formele historie' is applicable for the current class a constructRef to a historieFormeel global construct based on the current class is generated. -->
                                       <xsl:if test="@indicatieFormeleHistorie='Ja'">
                                           <ep:constructRef>
                                               <ep:tech-name>historieFormeel</ep:tech-name>
                                               <ep:max-occurs>unbounded</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>180</ep:position>
                                               <xsl:choose>
                                                   <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel'))" />
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:href', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel')" />                                       
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </ep:constructRef>
                                       </xsl:if>
                                       <!-- The uml associations of the uml class are placed here. -->
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                           mode="create-message-content-constructRef">
                                           <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                       </xsl:apply-templates>
                                       <!-- ROME: Volgende wijze van waarde bepaling voor de mnemonic moet ook op diverse plaatsen in Imvert2XSD-KING-endproduct-structure geimplementeerd worden. -->
                                       <xsl:variable name="mnemonic">
                                           <xsl:choose>
                                               <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias = '' or not($packages//imvert:class[imvert:id = $type-id]/imvert:alias)"/>
                                               <xsl:otherwise>
                                                   <xsl:value-of select="$packages//imvert:class[imvert:id = $type-id]/imvert:alias"/>
                                               </xsl:otherwise>
                                           </xsl:choose>
                                       </xsl:variable>
                                       <!-- The function imf:createAttributes is used to determine the XML attributes 
                            				neccessary for this context. It has the following parameters: - typecode 
                            				- berichttype - context - datumType The first 3 parameters relate to columns 
                            				with the same name within an Excel spreadsheet used to configure a.o. XML 
                            				attributes usage. The last parameter is used to determine the need for the 
                            				XML-attribute 'StUF:indOnvolledigeDatum'. -->
                                       <xsl:if test="imf:boolean($debug)">	
                                           <xsl:comment select="concat('Attributes voor ',$typeCode,', berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic)" />
                                       </xsl:if>
                                       <xsl:variable name="attributes"
                                           select="imf:createAttributes($typeCode, substring($berichtCode,1,2), $context, 'no', $mnemonic, 'no','no')" />
                                       <xsl:sequence select="$attributes" />
                                   </ep:seq>
                               </xsl:otherwise>
                           </xsl:choose>
                       </ep:construct>
                       <!-- Within the schema's we want to have global constructs for relations. However for that kind of objects no uml classes are available.
                            With the following apply-templates the global ep:construct elements are created presenting the relations. -->
                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                           mode="create-message-content">
                           <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                           <xsl:with-param name="context" select="$context" />
                       </xsl:apply-templates>
                       
                       <xsl:if test="imf:boolean($debug)">
                           <xsl:comment select="' For-each-when: $packages//imvert:class[imvert:id = $type-id] End-For-each-when'"/>
                       </xsl:if>
                   </xsl:when>
               </xsl:choose>
               <!-- There are 2 types of history parameters. The first one configures if history is applicable for the current context. History isn't applicable for example for each message type.
                    The second one is used to determine if history, if applicable for the context, is applicable for the class being processed. Not every class has attributes or associations history applies to. -->
               
               <!-- If 'Materiele historie' or 'Formele historie' is applicable for the current class a historieMaterieel global construct based on the current class is generated. -->
               <xsl:if test="@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes'">
                   <xsl:choose>
                       <!-- The following when generates historieMaterieel global constructs based on uml groups. -->
                       <xsl:when test="@type='group' and $packages//imvert:class[imvert:id = $type-id]">
                           <xsl:variable name="docs">
                               <imvert:complete-documentation>
                                   <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $type-id])"/>
                               </imvert:complete-documentation>
                           </xsl:variable>
                           <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="'For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $type-id]'"/>
                           </xsl:if>
                           
                           <ep:construct type="group">
                               <xsl:sequence
                                   select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieMaterieel'))" />
                               <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                               <ep:seq>
                                   <!-- The uml attributes, of the uml group, for which historiematerieel is applicable are placed here. -->
                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                       mode="create-message-content">
                                       <xsl:with-param name="proces-type" select="'attributes'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="historyApplies" select="'yes-Materieel'"/>
                                       <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                   </xsl:apply-templates>
                                   <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                       mode="create-message-content">
                                       <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="historyApplies" select="'yes-Materieel'"/>
                                       <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                   </xsl:apply-templates>
                                   <!-- Associations are never placed within historieMaterieel constructs. -->
                               </ep:seq> 
                           </ep:construct>                       
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="' For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $type-id] End-For-each-when'"/>
                           </xsl:if>
                       </xsl:when>
                       <!-- The following when generates historieMaterieel global constructs based on uml classes. -->
                       <xsl:when test="$packages//imvert:class[imvert:id = $type-id]">
                           <xsl:variable name="docs">
                               <imvert:complete-documentation>
                                   <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $type-id])"/>
                               </imvert:complete-documentation>                           </xsl:variable>
                           <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="'For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $type-id]'"/>
                           </xsl:if>
                           
                           <ep:construct>
                               <!-- The value of the tech-name is dependant on the availability of an alias. -->
                               <xsl:choose>
                                   <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieMaterieel'))" />
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieMaterieel')" />                                       
                                   </xsl:otherwise>
                               </xsl:choose>
                               <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                               <xsl:choose>
                                   <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                   
                                   <!-- ROME: Het templates waar de volgende apply templates naar verwijzen moeten nog ingericht worden op historieMaterieel.
                                              Dit is ook de reden dat er in de aanroep van deze apply templates de parameter 'indicatieMaterieleHistorie' nog niet voorkomt. -->
                                   
                                   
                                   <xsl:when test="$packages//imvert:class[imvert:supertype/imvert:type-id = $type-id]">
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                           mode="create-message-content">
                                           <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                           <xsl:with-param name="historyApplies" select="'yes-Materieel'"/>
                                       </xsl:apply-templates>
                                   </xsl:when>
                                   <!-- Else the content of the current uml class is processed. -->
                                   <xsl:otherwise>
                                       <ep:seq>
                                           <!-- The uml attributes of the uml class are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="'yes-Materieel'"/>
                                           </xsl:apply-templates>
                                           <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="'yes-Materieel'"/>
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
                                           <?x ep:construct>
                                               <!--ep:name>StUF:tijdvakObject</ep:name-->
                                               <ep:tech-name>StUF:tijdvakObject</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>150</ep:position>
                                           </ep:construct x?>
                                           <ep:construct>
                                               <!--ep:name>StUF:tijdvakGeldigheid</ep:name-->
                                               <ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>1</ep:min-occurs>
                                               <ep:position>155</ep:position>
                                           </ep:construct>
                                           <!-- If 'Formele historie' is applicable for the current class a the following construct and constructRef are generated. -->
                                           <xsl:if test="@indicatieFormeleHistorie='Ja'">
                                               <ep:construct>
                                                   <!--ep:name>StUF:tijdstipRegistratie</ep:name-->
                                                   <ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
                                                   <ep:max-occurs>1</ep:max-occurs>
                                                   <ep:min-occurs>1</ep:min-occurs>
                                                   <ep:position>160</ep:position>
                                               </ep:construct>
                                               <ep:constructRef>
                                                   <ep:tech-name>historieFormeel</ep:tech-name>
                                                   <ep:max-occurs>unbounded</ep:max-occurs>
                                                   <ep:min-occurs>0</ep:min-occurs>
                                                   <ep:position>175</ep:position>
                                                   <!-- The value of the href is dependant on the availability of an alias. -->
                                                   <xsl:choose>
                                                       <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
                                                           <xsl:sequence
                                                               select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel'))" />
                                                       </xsl:when>
                                                       <xsl:otherwise>
                                                           <xsl:sequence
                                                               select="imf:create-output-element('ep:href', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel')" />                                       
                                                       </xsl:otherwise>
                                                   </xsl:choose>
                                               </ep:constructRef>
                                           </xsl:if>
                                           <!-- Associations are never placed within historieMaterieel constructs. -->                                           
                                       </ep:seq> 
                                   </xsl:otherwise>
                               </xsl:choose>
                           </ep:construct>
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="' For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $type-id] End-For-each-when'"/>
                           </xsl:if>
                       </xsl:when>
                   </xsl:choose>
               </xsl:if>
               <!-- If 'Formele historie' is applicable for the current class a historieFormeel global construct based on the current class is generated. -->
               <xsl:if test="@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes'">
                   <xsl:choose>
                       <!-- The following when generates historieFormeel global constructs based on uml groups. -->
                       <xsl:when test="@type='group' and $packages//imvert:class[imvert:id = $type-id]">
                           <xsl:variable name="docs">
                               <imvert:complete-documentation>
                                   <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $type-id])"/>
                               </imvert:complete-documentation>
                           </xsl:variable>
                           <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="'For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $type-id]'"/>
                           </xsl:if>
                           
                           <ep:construct type="group">
                               <xsl:sequence
                                   select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel'))" />
                               <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                               <ep:seq>
                                   <!-- The uml attributes, of the uml group, for which historieFormeel is applicable are placed here. -->
                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                       mode="create-message-content">
                                       <xsl:with-param name="proces-type" select="'attributes'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="historyApplies" select="'yes'"/>
                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                   </xsl:apply-templates>
                                   <!-- The uml groups, of the uml group, for which historieFormeel is applicable are placed here. -->
                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                       mode="create-message-content">
                                       <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                       <xsl:with-param name="context" select="$context" />
                                       <xsl:with-param name="historyApplies" select="'yes'"/>
                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                   </xsl:apply-templates>
                                   <!-- Associations are never placed within historieFormeel constructs. -->
                               </ep:seq> 
                           </ep:construct>                       
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="' For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $type-id] End-For-each-when'"/>
                           </xsl:if>
                       </xsl:when>
                       <!-- The following when generates historieFormeel global constructs based on uml classes. -->
                       <xsl:when test="$packages//imvert:class[imvert:id = $type-id]">
                           <xsl:variable name="docs">
                               <imvert:complete-documentation>
                                   <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $type-id])"/>
                               </imvert:complete-documentation>
                           </xsl:variable>
                           <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="'For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $type-id]'"/>
                           </xsl:if>
                           
                           <ep:construct>
                               <!-- The value of the tech-name is dependant on the availability of an alias. -->
                               <xsl:choose>
                                   <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel'))" />
                                   </xsl:when>
                                   <xsl:otherwise>
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel')" />                                       
                                   </xsl:otherwise>
                               </xsl:choose>
                               <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                               <xsl:choose>
                                   <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                   
                                   <!-- ROME: Het template waar het volgende apply templates naar verwijst moet nog ingericht worden op historieFormeel.
                                              Dit is ook de reden dat er in de aanroep van deze apply templates de parameter 'indicatieFormeleHistorie' nog niet voorkomt. -->
                                   
                                   
                                   <xsl:when test="$packages//imvert:class[imvert:supertype/imvert:type-id = $type-id]">
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                           mode="create-message-content">
                                           <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                           <xsl:with-param name="historyApplies" select="'yes'"/>
                                       </xsl:apply-templates>
                                   </xsl:when>
                                   <!-- Else the content of the current uml class is processed. -->
                                   <xsl:otherwise>                                     
                                       <ep:seq>
                                           <!-- The uml attributes of the uml class are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="'yes'"/>
                                           </xsl:apply-templates>
                                           <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $type-id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="proces-type"
                                                   select="'associationsGroepCompositie'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="historyApplies" select="'yes'"/>
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
                                           <?x ep:construct>
                                               <!--ep:name>StUF:tijdvakObject</ep:name-->
                                               <ep:tech-name>StUF:tijdvakObject</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>150</ep:position>
                                           </ep:construct x?>
                                           <ep:construct>
                                               <!--ep:name>StUF:tijdvakGeldigheid</ep:name-->
                                               <ep:tech-name>StUF:tijdvakGeldigheid</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>1</ep:min-occurs>
                                               <ep:position>155</ep:position>
                                           </ep:construct>
                                           <ep:construct>
                                               <!--ep:name>StUF:tijdstipRegistratie</ep:name-->
                                               <ep:tech-name>StUF:tijdstipRegistratie</ep:tech-name>
                                               <ep:max-occurs>1</ep:max-occurs>
                                               <ep:min-occurs>1</ep:min-occurs>
                                               <ep:position>160</ep:position>
                                           </ep:construct>
                                           <ep:constructRef>
                                               <ep:tech-name>historieFormeel</ep:tech-name>
                                               <ep:max-occurs>unbounded</ep:max-occurs>
                                               <ep:min-occurs>0</ep:min-occurs>
                                               <ep:position>175</ep:position>
                                               <!-- The value of the href is dependant on the availability of an alias. -->
                                               <xsl:choose>
                                                   <xsl:when test="$packages//imvert:class[imvert:id = $type-id]/imvert:alias">
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $type-id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel'))" />
                                                   </xsl:when>
                                                   <xsl:otherwise>
                                                       <xsl:sequence
                                                           select="imf:create-output-element('ep:href', imf:get-normalized-name($packages//imvert:class[imvert:id = $type-id]/@formal-name,'type-name'),'-historieFormeel')" />                                       
                                                   </xsl:otherwise>
                                               </xsl:choose>
                                           </ep:constructRef>
                                       </ep:seq> 
                                   </xsl:otherwise>
                               </xsl:choose>
                           </ep:construct>
                           
                           <xsl:if test="imf:boolean($debug)">
                               <xsl:comment select="' For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $type-id] End-For-each-when'"/>
                           </xsl:if>
                       </xsl:when>
                   </xsl:choose>
               </xsl:if>
           </xsl:for-each>
       </ep:message-set>
     </xsl:variable>
    
    <xsl:template match="/">
        <!-- This template is used to place the content of the variable '$imvert-endproduct' within the ep file. -->
        <?x xsl:result-document href="file:/c:/temp/imvert-schema-rules.xml">
            <xsl:sequence select="$config-schemarules"/>
        </xsl:result-document x?> 
        <?x xsl:result-document href="file:/c:/temp/imvert-tagged-values.xml">
            <xsl:sequence select="$config-tagged-values"/>
        </xsl:result-document x?> 
        <?x xsl:result-document href="file:/c:/temp/imvert-endproduct.xml">
            <xsl:sequence select="$enriched-endproduct-base-config-excel"/>
            
            <!-- xsl:sequence select="$imvert-endproduct/*"/ -->
        </xsl:result-document x?> 
        
        <xsl:sequence select="$imvert-endproduct/*"/>
    </xsl:template>
    
    <!-- supress the suppressXsltNamespaceCheck message -->
    <xsl:template match="/imvert:dummy"/>
    
</xsl:stylesheet>
