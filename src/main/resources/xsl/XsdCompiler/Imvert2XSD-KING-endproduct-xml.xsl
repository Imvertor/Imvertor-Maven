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
    <xsl:import href="Imvert2XSD-KING-create-enriched-rough-messages.xsl"/>
    <xsl:import href="Imvert2XSD-KING-create-endproduct-structure.xsl"/>
    
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:key name="class" match="imvert:class" use="imvert:id" />
    <!-- This key is used within the for-each instruction further in this code. -->
    <xsl:key name="construct-id" match="ep:construct" use="ep:id" />
    
    
    <xsl:variable name="stylesheet-code">SKS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
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
    
    <?x <xsl:variable name="berichtNaam" select="/imvert:packages/imvert:application"/> x?>

    <xsl:variable name="packages" select="/imvert:packages"/>
    
    <!-- Within this variable a rough message structure is created to be able to determine e.g. the correct global construct structures. -->
    <xsl:variable name="rough-messages">
         <xsl:sequence select="imf:create-debug-track('Constructing the rough message-structure',$debugging)"/>
        
  
        <!-- ROME: Het opvragen van het stereotype middels imf:get-config-stereotypes('stereotype-name-domain-package') levert 2 waarden op, 1 uit het metamodel van het UGM en 1 uit dat van het BSM.
                   Ik wil echter alleen de stereotype met de waarde BERICHT verwerken. Hoe kan ik dat bereiken met de onderstaande methode? -->
        <ep:rough-messages>
            <xsl:apply-templates select="$packages/imvert:package[imvert:stereotype = 'BERICHT' and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-rough-message-structure"/>
        </ep:rough-messages>
    </xsl:variable>
    
    <xsl:variable name="enriched-rough-messages">
        <xsl:sequence select="imf:create-debug-track('Constructing the enriched rough message-structure',$debugging)"/>
        
        
        <!-- ROME: Het opvragen van het stereotype middels imf:get-config-stereotypes('stereotype-name-domain-package') levert 2 waarden op, 1 uit het metamodel van het UGM en 1 uit dat van het BSM.
                   Ik wil echter alleen de stereotype met de waarde BERICHT verwerken. Hoe kan ik dat bereiken met de onderstaande methode? -->
        <xsl:apply-templates select="$rough-messages/ep:rough-messages" mode="enrich-rough-messages"/>

    </xsl:variable>

    <!-- ROME: De volgende variabele moet per package worden vastgesteld. -->
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

    <!-- Within this variable all messages defined within the BSM of the koppelvlak are placed, transformed to the imvertor endproduct format.-->
    <xsl:variable name="imvert-endproduct">
        <xsl:variable name="msg" select="'Creating the Endproduct structure'"/>
        <xsl:sequence select="imf:msg('DEBUG',$msg)"/>

        <xsl:sequence select="imf:create-debug-track('Constructing the message-set',$debugging)"/>
        
        <ep:message-set>
           <xsl:sequence select="imf:create-output-element('ep:name', /imvert:packages/imvert:project)"/>
            <xsl:sequence select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)"/>
            <xsl:sequence select="imf:create-output-element('ep:date', substring-before(/imvert:packages/imvert:generated,'T'))"/>
            <xsl:sequence select="imf:create-output-element('ep:patch-number', 'TO-DO')"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace', /imvert:packages/imvert:base-namespace)"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $prefix)"/>
            
            <!-- ROME: Volgende structuur moet, zodra we meerdere namespaces volledig ondersteunen, afgeleid worden van alle in gebruik zijnde namespaces. -->
            <ep:namespaces>
                <ep:namespace prefix="StUF">http://www.egem.nl/StUF/StUF0301</ep:namespace>
                <ep:namespace prefix="{$prefix}"><xsl:value-of select="/imvert:packages/imvert:base-namespace"/></ep:namespace>
            </ep:namespaces>
            
            <xsl:if test="$debugging">
                <xsl:sequence select="$enriched-rough-messages"/>
            </xsl:if>
           
            <xsl:sequence select="imf:create-debug-track('Constructing the message-elements',$debugging)"/>
            <xsl:variable name="messages">
               <xsl:apply-templates select="$packages/imvert:package[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-domain-package') and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-message-structure"/>
           </xsl:variable>
           <xsl:sequence select="$messages"/>

          <xsl:apply-templates select="$enriched-rough-messages//ep:rough-message"/>

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
    
    <xsl:template match="ep:rough-message">
        <xsl:variable name="berichtName" select="ep:name"/>
        <xsl:variable name="fundamentalMnemonic" select="ep:fundamentalMnemonic"/>
        <xsl:variable name="currentMessage">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="*"/>               
                </xsl:copy>
        </xsl:variable>
        <ep:currentMessage>
            <xsl:sequence select="$currentMessage"/>
        </ep:currentMessage>
        
        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs',$debugging)"/>

            <!-- The following for-each takes care of creating global construct elements for each ep:construct element present within the 'rough-messages' variable 
                having a type-id value none of the preceding ep:construct elements have. -->
        <xsl:for-each select="$currentMessage//ep:construct[ep:id and generate-id(.) = generate-id(key('construct-id',ep:id,$currentMessage)[1])]">
                    
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
               <xsl:variable name="typeCode" select="@typeCode"/>
            
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
                       
                        
    
                    <!-- The following if takes care of creating global construct elements for each ep:construct element not representing a 'relatie'. -->
                    <xsl:when test="@typeCode!='relatie'">
                       
                        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs not representing a relation',$debugging)"/>
                        
                        <xsl:choose>
                           <!-- The following when generates global constructs based on uml groups. -->
                           <xsl:when test="@type='group' and $packages//imvert:class[imvert:id = $id]">
 
                               <xsl:sequence select="imf:create-debug-track(concat('Constructing global groupconstruct: ',$packages//imvert:class[imvert:id = $id]/imvert:name),$debugging)"/>

                               <xsl:variable name="docs">
                                   <imvert:complete-documentation>
                                       <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $id])"/>
                                   </imvert:complete-documentation>
                               </xsl:variable>
                               <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                               
                               <xsl:sequence select="imf:create-debug-comment('For-each-when: @type=group and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                               
                               <ep:construct prefix="{$prefix}" type="group">
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-',$berichtName))" />
                                   <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                   <ep:seq>
                                       
                                       <!-- Within the following apply-templates parameters are used which are also used in other apply-templates in this and other stylesheets.
                                            These have the following function:
                                            
                                            proces-type: 
                                            -->
                                       
                                       <!-- The uml attributes of the uml group are placed here. -->
                                       <xsl:sequence select="imf:create-debug-comment(concat('fundamentalMnemonic: ',$fundamentalMnemonic),$debugging)"/>
 
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                           mode="create-message-content">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'attributes'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                           <xsl:with-param name="fundamentalMnemonic" select="$fundamentalMnemonic"/>
                                       </xsl:apply-templates>
                                       <!-- The uml groups of the uml group are placed here. -->
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                           mode="create-message-content">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                       </xsl:apply-templates>
                                       <!-- The uml associations of the uml group are placed here. -->
                                       <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                           mode="create-message-content">
                                           <xsl:with-param name="berichtName" select="$berichtName"/>
                                           <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                           <xsl:with-param name="berichtCode" select="$berichtCode" />
                                           <xsl:with-param name="context" select="$context" />
                                       </xsl:apply-templates>
                                   </ep:seq> 
                               </ep:construct>                       
                               
                               <xsl:sequence select="imf:create-debug-comment('For-each-when: @type=group and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               
                           </xsl:when>
                           <!-- The following when generates global constructs based on uml classes. -->
                           <xsl:when test="$packages//imvert:class[imvert:id = $id]">
 
                               <xsl:sequence select="imf:create-debug-track(concat('Constructing global construct: ',$packages//imvert:class[imvert:id = $id]/imvert:name),$debugging)"/>
 
                               <xsl:variable name="docs">
                                   <imvert:complete-documentation>
                                       <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $id])"/>
                                   </imvert:complete-documentation>
                               </xsl:variable>
                               <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                               
                               <xsl:sequence select="imf:create-debug-comment('For-each-when: $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                
                               <ep:construct prefix="{$prefix}">
                                   <!-- The value of the tech-name is dependant on the availability of an alias. -->
                                   <xsl:choose>
                                       <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias">
                                           <xsl:sequence
                                               select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-',$berichtName))" />
                                       </xsl:when>
                                       <xsl:otherwise>
                                           <xsl:sequence
                                               select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-',$berichtName))" />                                       
                                       </xsl:otherwise>
                                   </xsl:choose>
                                   <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                   <xsl:choose>
                                        
                                       <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                       <xsl:when test="$packages//imvert:class[imvert:supertype/imvert:type-id = $id]">
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                           </xsl:apply-templates>
                                       </xsl:when>
                                       <!-- Else the content of the current uml class is processed. -->
                                       <xsl:otherwise>
                                           <ep:seq>
                                               <!-- The uml attributes of the uml class are placed here. -->
                                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                   mode="create-message-content">
                                                   <xsl:with-param name="berichtName" select="$berichtName"/>
                                                   <xsl:with-param name="proces-type" select="'attributes'" />
                                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                   <xsl:with-param name="context" select="$context" />
                                               </xsl:apply-templates>
                                               <!-- The uml groups of the uml class are placed here. -->
                                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                   mode="create-message-content">
                                                   <xsl:with-param name="berichtName" select="$berichtName"/>
                                                   <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                   <xsl:with-param name="context" select="$context" />
                                                   <!-- If the class is refered to form an association which is part of an VRIJ BERICHT no stuurgegevens must be generated. -->
                                                   <xsl:with-param name="useStuurgegevens">
                                                       <xsl:choose>
                                                           <xsl:when test="$packages//imvert:association[imvert:type-id = $id]/imvert:stereotype = 'BERICHTRELATIE'">
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
                                               <xsl:if test="$packages//imvert:class[imvert:id = $id]/imvert:stereotype != 'KENNISGEVINGBERICHTTYPE' and
                                                   $packages//imvert:class[imvert:id = $id]/imvert:stereotype != 'VRAAGBERICHTTYPE' and
                                                   $packages//imvert:class[imvert:id = $id]/imvert:stereotype != 'ANTWOORDBERICHTTYPE' and
                                                   $packages//imvert:class[imvert:id = $id]/imvert:stereotype != 'SYNCHRONISATIEBERICHTTYPE'">
                                                   <!-- ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <ep:name>tijdvakObject</ep:name>
                                                       <ep:tech-name>tijdvakObject</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>150</ep:position>
                                                   </ep:constructRef -->
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <!--ep:name>tijdvakGeldigheid</ep:name-->
                                                       <ep:tech-name>tijdvakGeldigheid</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>155</ep:position>
                                                   </ep:constructRef>
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <ep:name>tijdstipRegistratie</ep:name>
                                                       <ep:tech-name>tijdstipRegistratie</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>160</ep:position>
                                                   </ep:constructRef>
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <!--ep:name>extraElementen</ep:name-->
                                                       <ep:tech-name>extraElementen</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>165</ep:position>
                                                   </ep:constructRef>
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <!--ep:name>aanvullendeElementen</ep:name-->
                                                       <ep:tech-name>aanvullendeElementen</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>170</ep:position>
                                                   </ep:constructRef>
                                               </xsl:if>
                                               <!-- ROME: Hieronder worden de construcRefs voor historieMaterieel en historieFormeel aangemaakt.
                                                    Dit moet echter gebeuren a.d.h.v. de berichtcode. Die verfijning moet nog worden aangebracht in de if statements. -->

                                               <!-- If 'Materiele historie' is applicable for the current class a constructRef to a historieMaterieel global construct based on the current class is generated. -->
                                               <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes')">
                                                   <ep:constructRef prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                       <ep:tech-name>historieMaterieel</ep:tech-name>
                                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>175</ep:position>
                                                       <xsl:choose>
                                                           <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias">
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieMaterieel','-',$berichtName))" />
                                                           </xsl:when>
                                                           <xsl:otherwise>
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieMaterieel','-',$berichtName))" />                                       
                                                           </xsl:otherwise>
                                                       </xsl:choose>
                                                   </ep:constructRef>
                                               </xsl:if>
                                               <!-- If 'Formele historie' is applicable for the current class a constructRef to a historieFormeel global construct based on the current class is generated. -->
                                               <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes')">
                                                   <ep:constructRef prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                       <ep:tech-name>historieFormeel</ep:tech-name>
                                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>180</ep:position>
                                                       <xsl:choose>
                                                           <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias">
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />
                                                           </xsl:when>
                                                           <xsl:otherwise>
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />                                       
                                                           </xsl:otherwise>
                                                       </xsl:choose>
                                                   </ep:constructRef>
                                               </xsl:if>
                                               <!-- The uml associations of the uml class are placed here. -->
                                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                   mode="create-message-content-constructRef">
                                                   <xsl:with-param name="berichtName" select="$berichtName"/>
                                                   <xsl:with-param name="proces-type" select="'associationsRelatie'" />
                                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                   <xsl:with-param name="context" select="$context" />
                                               </xsl:apply-templates>
                                               <!-- ROME: Volgende wijze van waarde bepaling voor de mnemonic moet ook op diverse plaatsen in Imvert2XSD-KING-endproduct-structure geimplementeerd worden. -->
                                               <xsl:variable name="mnemonic">
                                                   <xsl:choose>
                                                       <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias = '' or not($packages//imvert:class[imvert:id = $id]/imvert:alias)"/>
                                                       <xsl:otherwise>
                                                           <xsl:value-of select="$packages//imvert:class[imvert:id = $id]/imvert:alias"/>
                                                       </xsl:otherwise>
                                                   </xsl:choose>
                                               </xsl:variable>
                                               <!-- The function imf:createAttributes is used to determine the XML attributes 
                                    				neccessary for this context. It has the following parameters: - typecode 
                                    				- berichttype - context - datumType The first 3 parameters relate to columns 
                                    				with the same name within an Excel spreadsheet used to configure a.o. XML 
                                    				attributes usage. The last parameter is used to determine the need for the 
                                    				XML-attribute 'StUF:indOnvolledigeDatum'. -->
                                               <xsl:sequence select="imf:create-debug-comment(concat('Attributes voor ',$typeCode,', berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $mnemonic),$debugging)"/>
                                               <xsl:variable name="attributes"
                                                   select="imf:createAttributes($typeCode, substring($berichtCode,1,2), $context, 'no', $mnemonic, 'no','no')" />
                                               <xsl:sequence select="$attributes" />
                                           </ep:seq>
                                       </xsl:otherwise>
                                   </xsl:choose>
                               </ep:construct>
                               
                               <xsl:sequence select="imf:create-debug-comment('For-each-when: $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                           </xsl:when>
                       </xsl:choose>
        
        
                       <!-- There are 2 types of history parameters. The first one configures if history is applicable for the current context. History isn't applicable for example for each message type.
                            The second one is used to determine if history, if applicable for the context, is applicable for the class being processed. Not every class has attributes or associations history applies to. -->
                       
                       <!-- If 'Materiele historie' is applicable for the current class a historieMaterieel global construct based on the current class is generated. -->
                        <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes')">
                           <xsl:choose>
                               <!-- The following when generates historieMaterieel global constructs based on uml groups. -->
                               <xsl:when test="@type='group' and $packages//imvert:class[imvert:id = $id]">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global materieleHistorie groupconstruct: ',$packages//imvert:class[imvert:id = $id]/imvert:name),$debugging)"/>
                                   
                                   <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $id])"/>
                                       </imvert:complete-documentation>
                                   </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                   
                                   <ep:construct prefix="{$prefix}" type="group">
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieMaterieel','-',$berichtName))" />
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                       <ep:seq>
                                           
                                           <!-- ROME: M.b.v. het XML attribute 'indicatieMaterieleHistorie' en 'indicatieFormeleHistorie' op het huidige rough-message construct 
                                                      kan bepaald worden of binnen het ep:seq element een historieMaterieel en/of een historieFormeel constructRef moet worden gegenereerd. -->
                                           
                                           
                                           <!-- The uml attributes, of the uml group, for which historiematerieel is applicable are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                               <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                           </xsl:apply-templates>
                                           <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                               <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                           </xsl:apply-templates>
                                           <!-- Associations are never placed within historieMaterieel constructs. -->
                                       </ep:seq> 
                                   </ep:construct>                       
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               </xsl:when>
                               <!-- The following when generates historieMaterieel global constructs based on uml classes. -->
                               <xsl:when test="$packages//imvert:class[imvert:id = $id]">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global materieleHistorie construct: ',$packages//imvert:class[imvert:id = $id]/imvert:name),$debugging)"/>
                                   
                                   <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $id])"/>
                                       </imvert:complete-documentation>                           </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                   
                                   <ep:construct prefix="{$prefix}">
                                       <!-- The value of the tech-name is dependant on the availability of an alias. -->
                                       <xsl:choose>
                                           <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias">
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieMaterieel','-',$berichtName))" />
                                           </xsl:when>
                                           <xsl:otherwise>
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieMaterieel','-',$berichtName))" />                                       
                                           </xsl:otherwise>
                                       </xsl:choose>
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                       <xsl:choose>
                                           <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                           
                                            
                                           
                                           <xsl:when test="$packages//imvert:class[imvert:supertype/imvert:type-id = $id]">
                                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                   mode="create-message-content">
                                                   <xsl:with-param name="berichtName" select="$berichtName"/>
                                                   <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                   <xsl:with-param name="context" select="$context" />
                                                   <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                                   <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                                   <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                               </xsl:apply-templates>
                                           </xsl:when>
                                           <!-- Else the content of the current uml class is processed. -->
                                           <xsl:otherwise>
                                               <ep:seq>
                                                   <!-- The uml attributes of the uml class are placed here. -->
                                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                       mode="create-message-content">
                                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                                       <xsl:with-param name="proces-type" select="'attributes'" />
                                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                       <xsl:with-param name="context" select="$context" />
                                                       <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                                       <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                                   </xsl:apply-templates>
                                                   <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                       mode="create-message-content">
                                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                                       <xsl:with-param name="proces-type"
                                                           select="'associationsGroepCompositie'" />
                                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                       <xsl:with-param name="context" select="$context" />
                                                       <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                                       <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
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
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <!--ep:name>tijdvakGeldigheid</ep:name-->
                                                       <ep:tech-name>tijdvakGeldigheid</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>1</ep:min-occurs>
                                                       <ep:position>155</ep:position>
                                                   </ep:constructRef>
                                                   <!-- If 'Formele historie' is applicable for the current class a the following construct and constructRef are generated. -->
                                                   <xsl:if test="@indicatieFormeleHistorie='Ja'">
                                                       <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                           <!--ep:name>tijdstipRegistratie</ep:name-->
                                                           <ep:tech-name>tijdstipRegistratie</ep:tech-name>
                                                           <ep:max-occurs>1</ep:max-occurs>
                                                           <ep:min-occurs>0</ep:min-occurs>
                                                           <ep:position>160</ep:position>
                                                       </ep:constructRef>
                                                       <ep:constructRef prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                           <ep:tech-name>historieFormeel</ep:tech-name>
                                                           <ep:max-occurs>unbounded</ep:max-occurs>
                                                           <ep:min-occurs>0</ep:min-occurs>
                                                           <ep:position>175</ep:position>
                                                           <!-- The value of the href is dependant on the availability of an alias. -->
                                                           <xsl:choose>
                                                               <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias">
                                                                   <xsl:sequence
                                                                       select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />
                                                               </xsl:when>
                                                               <xsl:otherwise>
                                                                   <xsl:sequence
                                                                       select="imf:create-output-element('ep:href', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />                                       
                                                               </xsl:otherwise>
                                                           </xsl:choose>
                                                       </ep:constructRef>
                                                   </xsl:if>
                                                   <!-- Associations are never placed within historieMaterieel constructs. -->                                           
                                               </ep:seq> 
                                           </xsl:otherwise>
                                       </xsl:choose>
                                   </ep:construct>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               </xsl:when>
                           </xsl:choose>
                       </xsl:if>
                        <!-- If 'Formele historie' is applicable for the current class a historieFormeel global construct based on the current class is generated. -->
                        <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes')">
                           <xsl:choose>
                               <!-- The following when generates historieFormeel global constructs based on uml groups. -->
                               <xsl:when test="@type='group' and $packages//imvert:class[imvert:id = $id]">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global formeleHistorie groupconstruct: ',$packages//imvert:class[imvert:id = $id]/imvert:name),$debugging)"/>
                                   
                                   <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $id])"/>
                                       </imvert:complete-documentation>
                                   </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                   
                                   <ep:construct prefix="{$prefix}" type="group">
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                       <ep:seq>
                                           <!-- The uml attributes, of the uml group, for which historieFormeel is applicable are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type" select="'attributes'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                           </xsl:apply-templates>
                                           <!-- The uml groups, of the uml group, for which historieFormeel is applicable are placed here. -->
                                           <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                               mode="create-message-content">
                                               <xsl:with-param name="berichtName" select="$berichtName"/>
                                               <xsl:with-param name="proces-type" select="'associationsGroepCompositie'" />
                                               <xsl:with-param name="berichtCode" select="$berichtCode" />
                                               <xsl:with-param name="context" select="$context" />
                                               <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                               <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                           </xsl:apply-templates>
                                           <!-- Associations are never placed within historieFormeel constructs. -->
                                       </ep:seq> 
                                   </ep:construct>                       
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               </xsl:when>
                               <!-- The following when generates historieFormeel global constructs based on uml classes. -->
                               <xsl:when test="$packages//imvert:class[imvert:id = $id]">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global formeleHistorie construct: ',$packages//imvert:class[imvert:id = $id]/imvert:name),$debugging)"/>
                                   
                                   <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($packages//imvert:class[imvert:id = $id])"/>
                                       </imvert:complete-documentation>
                                   </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                   
                                   <ep:construct prefix="{$prefix}">
                                       <!-- The value of the tech-name is dependant on the availability of an alias. -->
                                       <xsl:choose>
                                           <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias">
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />
                                           </xsl:when>
                                           <xsl:otherwise>
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />                                       
                                           </xsl:otherwise>
                                       </xsl:choose>
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                       <xsl:choose>
                                           <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                           
                                           
                                           <xsl:when test="$packages//imvert:class[imvert:supertype/imvert:type-id = $id]">
                                               <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                   mode="create-message-content">
                                                   <xsl:with-param name="berichtName" select="$berichtName"/>
                                                   <xsl:with-param name="proces-type" select="'associationsOrSupertypeRelatie'" />
                                                   <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                   <xsl:with-param name="context" select="$context" />
                                                   <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                                   <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                               </xsl:apply-templates>
                                           </xsl:when>
                                           <!-- Else the content of the current uml class is processed. -->
                                           <xsl:otherwise>                                     
                                               <ep:seq>
                                                   <!-- The uml attributes of the uml class are placed here. -->
                                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                       mode="create-message-content">
                                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                                       <xsl:with-param name="proces-type" select="'attributes'" />
                                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                       <xsl:with-param name="context" select="$context" />
                                                       <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                                   </xsl:apply-templates>
                                                   <!-- The uml groups, of the uml group, for which historiematerieel is applicable are placed here. -->
                                                   <xsl:apply-templates select="$packages//imvert:class[imvert:id = $id]"
                                                       mode="create-message-content">
                                                       <xsl:with-param name="berichtName" select="$berichtName"/>
                                                       <xsl:with-param name="proces-type"
                                                           select="'associationsGroepCompositie'" />
                                                       <xsl:with-param name="berichtCode" select="$berichtCode" />
                                                       <xsl:with-param name="context" select="$context" />
                                                       <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                                       <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
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
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <ep:name>tijdvakGeldigheid</ep:name>
                                                       <ep:tech-name>tijdvakGeldigheid</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>1</ep:min-occurs>
                                                       <ep:position>155</ep:position>
                                                   </ep:constructRef>
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <ep:name>tijdstipRegistratie</ep:name>
                                                       <ep:tech-name>tijdstipRegistratie</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>1</ep:min-occurs>
                                                       <ep:position>160</ep:position>
                                                   </ep:constructRef>
                                                   <ep:constructRef prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                       <ep:tech-name>historieFormeel</ep:tech-name>
                                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>175</ep:position>
                                                       <!-- The value of the href is dependant on the availability of an alias. -->
                                                       <xsl:choose>
                                                           <xsl:when test="$packages//imvert:class[imvert:id = $id]/imvert:alias">
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $id]/imvert:alias,'-',imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />
                                                           </xsl:when>
                                                           <xsl:otherwise>
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $id]/@formal-name,'type-name'),'-historieFormeel','-',$berichtName))" />                                       
                                                           </xsl:otherwise>
                                                       </xsl:choose>
                                                   </ep:constructRef>
                                               </ep:seq> 
                                           </xsl:otherwise>
                                       </xsl:choose>
                                   </ep:construct>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               </xsl:when>
                           </xsl:choose>
                       </xsl:if>
                       
                    </xsl:when>
     
                    <!-- The following if takes care of creating global construct elements for each ep:construct element representing a 'relatie'. -->
                    <xsl:when test="@typeCode='relatie'">
                        
                        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs representing a relation',$debugging)"/>

                        <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @typeCode=relatie',$debugging)"/>
                        <!-- Within the schema's we want to have global constructs for relations. However for that kind of objects no uml classes are available.
                                With the following apply-templates the global ep:construct elements are created presenting the relations. -->
                        
                        <xsl:apply-templates select="$packages//imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']"
                            mode="create-message-content">
                            <xsl:with-param name="berichtCode" select="$berichtCode"/>
                            <xsl:with-param name="berichtName" select="$berichtName"/>
                            <xsl:with-param name="context" select="$context"/>
                            <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                            <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                            <xsl:with-param name="indicatieFormeleHistorieRelatie" select="@indicatieFormeleHistorieRelatie"/>
                        </xsl:apply-templates>
                        
                        
                        <!-- There are 2 types of history parameters. The first one configures if history is applicable for the current context. History isn't applicable for example for each message type.
                        The second one is used to determine if history, if applicable for the context, is applicable for the class being processed. Not every class has attributes or associations history applies to. -->
                        
                        <!-- If 'Materiele historie' is applicable for the current class and messagetype a historieMaterieel global construct based on the current class is generated. -->
                        <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes')">
                            
                            <xsl:sequence select="imf:create-debug-track(concat('Constructing the materieleHistorie constructs: ',$packages//imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']/imvert:name),$debugging)"/>

                            <xsl:apply-templates select="$packages//imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']"
                                mode="create-message-content">
                                <xsl:with-param name="berichtCode" select="$berichtCode"/>
                                <xsl:with-param name="berichtName" select="$berichtName"/>
                                <xsl:with-param name="context" select="$context"/>
                                <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                            </xsl:apply-templates>
                        </xsl:if>
                        
                        
                        <!-- If 'Formele historie' is applicable for the current class and messagetype a historieFormeel global construct based on the current class is generated. -->
                        <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes')">
                            
                            <xsl:sequence select="imf:create-debug-track(concat('Constructing the formeleHistorie constructs: ',$packages//imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']/imvert:name),$debugging)"/>
                            
                            <xsl:apply-templates select="$packages//imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']"
                                mode="create-message-content">
                                <xsl:with-param name="berichtCode" select="$berichtCode"/>
                                <xsl:with-param name="berichtName" select="$berichtName"/>
                                <xsl:with-param name="context" select="$context"/>
                                <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                            </xsl:apply-templates>
                        </xsl:if>
                        
                        <!-- If 'Formele historie' is applicable for the current class and messagetype a historieFormeel global construct based on the current class is generated. -->
                        <xsl:if test="@indicatieFormeleHistorieRelatie='Ja'">
                            
                            <xsl:sequence select="imf:create-debug-track(concat('Constructing the formeleHistorieRelatie constructs: ',$packages//imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']/imvert:name),$debugging)"/>
                            
                            <xsl:apply-templates select="$packages//imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']"
                                mode="create-message-content">
                                <xsl:with-param name="berichtCode" select="$berichtCode"/>
                                <xsl:with-param name="berichtName" select="$berichtName"/>
                                <xsl:with-param name="context" select="$context"/>
                                <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorieRelatie'"/>
                                <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorieRelatie" select="@indicatieFormeleHistorieRelatie"/>
                            </xsl:apply-templates>
                        </xsl:if>
 
                        <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @typeCode=relatie End-For-each-when',$debugging)"/>
                        
                    </xsl:when>
               </xsl:choose>
            </xsl:for-each>

            <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for antwoord constructs',$debugging)"/>
            
        <xsl:for-each select="$currentMessage//ep:rough-message[contains(ep:code, 'La')]//ep:construct[ep:name = 'antwoord']">
                <xsl:variable name="berichtName" select="ancestor::ep:rough-message/ep:name"/>
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
                <xsl:variable name="relatedObjectId" select="ep:construct/ep:origin-id"/>
                <xsl:variable name="relatedObjectTypeId" select="ep:construct/ep:id"/> 
                <ep:construct prefix="{$prefix}">
                     <!-- ep:tech-name><xsl:value-of select="concat($messageName,ep:name)"/></ep:tech-name -->
                     <xsl:choose>
                         <xsl:when test="$packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias">
                             <xsl:sequence
                                 select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',ep:name,'-',$berichtName))"
                             />
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:sequence
                                 select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',ep:name,'-',$berichtName))"
                             />
                         </xsl:otherwise>
                     </xsl:choose>
                    <ep:seq orderingDesired="no">
                        <ep:constructRef prefix="{$prefix}" context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', 'object')"/>
                            <ep:max-occurs><xsl:value-of select="$packages//imvert:association[imvert:id = $relatedObjectId]/imvert:max-occurs"/></ep:max-occurs>
                            <ep:min-occurs><xsl:value-of select="$packages//imvert:association[imvert:id = $relatedObjectId]/imvert:min-occurs"/></ep:min-occurs>
                            <ep:position>1</ep:position>
                            <xsl:choose>
                                <xsl:when test="$packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias">
                                    <xsl:sequence
                                        select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',$berichtName))"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence
                                        select="imf:create-output-element('ep:href', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',$berichtName))"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </ep:constructRef>
                    </ep:seq>
                </ep:construct>                  
           </xsl:for-each>
            
            <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for start constructs',$debugging)"/>
            
        <xsl:for-each select="$currentMessage//ep:rough-message[contains(ep:code, 'Lv')]//ep:construct[ep:name = 'start']">
                <xsl:variable name="berichtName" select="ancestor::ep:rough-message/ep:name"/>
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
                <xsl:variable name="relatedObjectId" select="ep:construct/ep:origin-id"/>
                <xsl:variable name="relatedObjectTypeId" select="ep:construct/ep:id"/> 
                <ep:construct prefix="{$prefix}">
                    <!--ep:name>
							<xsl:value-of select="$context"/>
						</ep:name-->
                    <!-- ep:tech-name><xsl:value-of select="concat($messageName,ep:name)"/></ep:tech-name -->
                    <xsl:choose>
                        <xsl:when test="$packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias">
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',ep:name,'-',$berichtName))"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',ep:name,'-',$berichtName))"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                    <ep:seq orderingDesired="no">
                        <ep:constructRef prefix="{$prefix}" context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', ep:construct/ep:name)"/>
                            <ep:max-occurs><xsl:value-of select="$packages//imvert:association[imvert:id = $relatedObjectId]/imvert:max-occurs"/></ep:max-occurs>
                            <ep:min-occurs><xsl:value-of select="$packages//imvert:association[imvert:id = $relatedObjectId]/imvert:min-occurs"/></ep:min-occurs>
                            <ep:position>1</ep:position>
                            <xsl:choose>
                                <xsl:when test="$packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias">
                                    <xsl:sequence
                                        select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',$berichtName))"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence
                                        select="imf:create-output-element('ep:href', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',$berichtName))"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </ep:constructRef>
                    </ep:seq>
                </ep:construct>
            </xsl:for-each>
            
            <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for antwoord scope',$debugging)"/>
            
        <xsl:for-each select="$currentMessage//ep:rough-message[contains(ep:code, 'Lv')]//ep:construct[ep:name = 'scope']">
                <xsl:variable name="berichtName" select="ancestor::ep:rough-message/ep:name"/>
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
                <xsl:variable name="relatedObjectId" select="ep:construct/ep:origin-id"/>
                <xsl:variable name="relatedObjectTypeId" select="ep:construct/ep:id"/> 
                <ep:construct prefix="{$prefix}">
                    <!--ep:name>
							<xsl:value-of select="$context"/>
						</ep:name-->
                    <!-- ep:tech-name><xsl:value-of select="concat($messageName,ep:name)"/></ep:tech-name -->
                    <xsl:choose>
                        <xsl:when test="$packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias">
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', concat($packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',ep:name,'-',$berichtName))"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',ep:name,'-',$berichtName))"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                    <ep:seq orderingDesired="no">
                        <ep:constructRef prefix="{$prefix}" context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', ep:construct/ep:name)"/>
                            <ep:max-occurs><xsl:value-of select="$packages//imvert:association[imvert:id = $relatedObjectId]/imvert:max-occurs"/></ep:max-occurs>
                            <ep:min-occurs><xsl:value-of select="$packages//imvert:association[imvert:id = $relatedObjectId]/imvert:min-occurs"/></ep:min-occurs>
                            <ep:position>1</ep:position>
                            <xsl:choose>
                                <xsl:when test="$packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias">
                                    <xsl:sequence
                                        select="imf:create-output-element('ep:href', concat($packages//imvert:class[imvert:id = $relatedObjectTypeId]/imvert:alias, '-', imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',$berichtName))"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence
                                        select="imf:create-output-element('ep:href', concat(imf:get-normalized-name($packages//imvert:class[imvert:id = $relatedObjectTypeId]/@formal-name, 'type-name'),'-',$berichtName))"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </ep:constructRef>
                    </ep:seq>
                </ep:construct>
            </xsl:for-each>        
    </xsl:template>
    <!-- supress the suppressXsltNamespaceCheck message -->
    <xsl:template match="/imvert:dummy"/>
    
</xsl:stylesheet>
