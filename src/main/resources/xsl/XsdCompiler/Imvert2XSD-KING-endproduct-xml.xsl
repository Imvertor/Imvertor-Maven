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
    <xsl:key name="construct-id" match="ep:construct" use="concat(ep:id,@verwerkingsModus)" />
    <!--xsl:key name="construct-id-and-name" match="ep:construct" use="concat(ep:id,ep:name)" /-->
    
    
    <xsl:variable name="stylesheet-code" as="xs:string">SKS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
    
    <xsl:variable name="stylesheet" as="xs:string">Imvert2XSD-KING-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version" as="xs:string">$Id: Imvert2XSD-KING-endproduct-xml.xsl 7509 2016-04-25 13:30:29Z arjan $</xsl:variable>  
    
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
    
    <xsl:variable name="packages" select="/imvert:packages"/>
    
    <!-- Within this variable a rough message structure is created to be able to determine e.g. the correct global construct structures. -->
    <xsl:variable name="rough-messages">
         <xsl:sequence select="imf:track('Constructing the rough message-structure')"/>
        
        <ep:rough-messages>
            <xsl:apply-templates select="$packages/imvert:package[imvert:stereotype = 'BERICHT' and not(contains(imvert:alias,'/www.kinggemeenten.nl/BSM/Berichtstrukturen'))]" mode="create-rough-message-structure"/>
        </ep:rough-messages>
    </xsl:variable>
    
    <xsl:variable name="enriched-rough-messages">
        <xsl:sequence select="imf:track('Constructing the enriched rough message-structure')"/>
        
        <xsl:apply-templates select="$rough-messages/ep:rough-messages" mode="enrich-rough-messages"/>

    </xsl:variable>

    <!-- ROME: Moet het per package bepalen van de prefix hier gebeuren? Ik vermoed van niet. -->
    <xsl:variable name="verkorteAlias" select="/imvert:packages/imvert:tagged-values/imvert:tagged-value[imvert:name/@original='Verkorte alias']"/>
    
    <xsl:variable name="prefix" as="xs:string">
        <xsl:choose>
            <xsl:when test="not(empty($verkorteAlias))">
                <xsl:value-of select="$verkorteAlias/imvert:value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="TODO"/>
                <xsl:variable name="msg" select="'You have not provided a short alias. Define the tagged value &quot;Verkorte alias&quot; on the package with the stereotyp &quot;Koppelvlak&quot;.'" as="xs:string"/>
                <xsl:sequence select="imf:msg('WARN',$msg)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Within this variable all messages defined within the BSM of the koppelvlak are placed, transformed to the imvertor endproduct (ep) format.-->
    <xsl:variable name="imvert-endproduct">
        
        <ep:message-set>
           <xsl:sequence select="imf:create-output-element('ep:name', /imvert:packages/imvert:project)"/>
            <xsl:sequence select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)"/>
            <xsl:sequence select="imf:create-output-element('ep:date', substring-before(/imvert:packages/imvert:generated,'T'))"/>
            <xsl:sequence select="imf:create-output-element('ep:patch-number', 'TO-DO')"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace', /imvert:packages/imvert:base-namespace)"/>
            <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $prefix)"/>
            
            <!-- ROME: Volgende structuur moet, zodra we meerdere namespaces volledig ondersteunen, afgeleid worden van alle in gebruik zijnde namespaces.
                       Ik vraag me dus af of ook de $prefix variabele meerdere prefixes moet kunnen omvatten. 
                       Ik denk van niet, eerder zal de onderstaande lijst met namespaces uitgebreid moeten worden door per package deze op te halen. -->
            <ep:namespaces>
                <ep:namespace prefix="StUF">http://www.egem.nl/StUF/StUF0301</ep:namespace>
                <ep:namespace prefix="{$prefix}"><xsl:value-of select="/imvert:packages/imvert:base-namespace"/></ep:namespace>
            </ep:namespaces>
            
            <xsl:if test="$debugging">
                <xsl:sequence select="$rough-messages"/>
                <xsl:sequence select="$enriched-rough-messages"/>
            </xsl:if>
           
            <xsl:sequence select="imf:track('Constructing the messages')"/>
            
                <xsl:for-each select="$enriched-rough-messages/ep:rough-messages/ep:rough-message">
                    <xsl:variable name="currentMessage" select=".">
                    </xsl:variable>
                    <xsl:variable name="id" select="ep:id" as="xs:string"/>
                    <xsl:variable name="message-construct" select="imf:get-construct-by-id($id,$packages)"/>
                    <xsl:variable name="berichtstereotype" select="$message-construct/imvert:stereotype" as="xs:string"/>
                    <xsl:variable name="berichtSoort" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="$berichtstereotype = 'VRAAGBERICHTTYPE'">Vraagbericht</xsl:when>
                            <xsl:when test="$berichtstereotype = 'ANTWOORDBERICHTTYPE'">Antwoordbericht</xsl:when>
                            <xsl:when test="$berichtstereotype = 'KENNISGEVINGBERICHTTYPE'">Kennisgevingbericht</xsl:when>
                            <xsl:when test="$berichtstereotype = 'VRIJ BERICHTTYPE'">Vrij bericht</xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="berichtCode" select="$message-construct/imvert:tagged-values/imvert:tagged-value[imvert:name = 'Berichtcode']/imvert:value" as="xs:string"/>
                    <xsl:variable name="docs">
                        <imvert:complete-documentation>
                            <xsl:copy-of select="imf:get-compiled-documentation($message-construct)"/>
                        </imvert:complete-documentation>
                    </xsl:variable>
                    <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                    <xsl:variable name="name" select="$message-construct/imvert:name/@original" as="xs:string"/>
                    <xsl:variable name="tech-name" select="imf:get-normalized-name($message-construct/imvert:name, 'element-name')" as="xs:string"/>
                    <xsl:variable name="package-type" select="$packages/imvert:package[imvert:class[imvert:id = $id]]/imvert:stereotype" as="xs:string"/>
                    <xsl:variable name="release" select="$packages/imvert:release" as="xs:string"/>
                    
                    <xsl:if test="not(string($berichtCode))">
                        <xsl:message 
                            select="concat('ERROR ', substring-before(string(current-date()), '+'), ' ', substring-before(string(current-time()), '+'), ' : The berichtcode can not be determined. To be able to generate correct messages this is neccessary. Check your model for missing tagged values. (', $berichtstereotype,')')"
                        />
                    </xsl:if>
                    
                    <ep:message prefix="{$prefix}">
                        <xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)"/>
                        <xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
                        <xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
                        <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                        <xsl:sequence select="imf:create-output-element('ep:package-type', $package-type)"/>
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
        <xsl:variable name="berichtName" select="ep:name" as="xs:string"/>
        <xsl:variable name="fundamentalMnemonic" select="ep:fundamentalMnemonic" as="xs:string"/>
        <xsl:variable name="currentMessage">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="*"/>               
                </xsl:copy>
        </xsl:variable>
        
        <xsl:if test="$debugging">
            <ep:currentMessage>
                <xsl:sequence select="$currentMessage"/>
            </ep:currentMessage>
        </xsl:if>
        
        <xsl:sequence select="imf:track('Constructing the global constructs',$debugging)"/>

        <!-- The following for-each takes care of creating global construct elements for each ep:construct element present within the current 'rough-messages' variable 
             having a type-id value none of the preceding ep:construct elements within the processed message have. 
             ep:construct elements with the name 'gelijk', 'vanaf', 'totEnMet', 'start' en 'scope' aren't processed here since they need special treatment.  -->
        <xsl:for-each select="$currentMessage//ep:construct[ep:id and generate-id(.) = generate-id(key('construct-id',concat(ep:id,@verwerkingsModus),$currentMessage)[1])]">
                    
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
            <xsl:variable name="packageName" select="@package"/> 
            <xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)"/>
            <!--xsl:variable name="alias" select="$construct/imvert:alias"/-->
            <xsl:variable name="alias">
               <xsl:choose>
                   <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                   <xsl:otherwise>
                       <xsl:value-of select="$construct/imvert:alias"/>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:variable>
            <xsl:variable name="elementName" select="$construct/imvert:name"/>
            
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
                       
                        
    
                    <!-- The following if takes care of creating global construct elements for each ep:construct element not representing a 'relatie'. -->
                    <xsl:when test="@typeCode!='relatie'">
                       
                        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs not representing a relation',$debugging)"/>
                        
                        <xsl:choose>
                           <!-- The following when generates global constructs based on uml groups. -->
                            <xsl:when test="@type='group' and exists(imf:get-construct-by-id($id,$packages))">
 
                               <xsl:sequence select="imf:create-debug-track(concat('Constructing global groupconstruct: ',$construct/imvert:name),$debugging)"/>

                               <!--xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)"/-->
                               <xsl:variable name="type" select="'Grp'"/>
                               <xsl:variable name="name">
                                   <xsl:choose>
                                       <xsl:when test="@className"><xsl:value-of select="@className"/></xsl:when>
                                       <xsl:otherwise><xsl:value-of select="ep:name"/></xsl:otherwise>
                                   </xsl:choose>
                               </xsl:variable>
                               <xsl:variable name="docs">
                                   <imvert:complete-documentation>
                                       <xsl:copy-of select="imf:get-compiled-documentation($construct)"/>
                                   </imvert:complete-documentation>
                               </xsl:variable>
                               <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                               
                               <xsl:sequence select="imf:create-debug-comment('For-each-when: @type=group and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                               
                               <!-- Location: 'ep:construct3'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef3'. -->
                               
                               <ep:construct prefix="{$prefix}" type="group">
                                   <xsl:sequence
                                       select="imf:create-output-element('ep:tech-name', imf:create-Grp-complexTypeName($packageName,$berichtName,$type,$name,$verwerkingsModus))" />
                                   <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
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
                                   </ep:seq> 
                               </ep:construct>                       
                               
                               <xsl:sequence select="imf:create-debug-comment('For-each-when: @type=group and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               
                           </xsl:when>
                           <!-- The following when generates global constructs based on uml classes. -->
                            <xsl:when test="exists(imf:get-construct-by-id($id,$packages))">

                                <!--xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)"/-->                                

                                <xsl:sequence select="imf:create-debug-track(concat('Constructing global construct: ',$construct/imvert:name),$debugging)"/>
                               <xsl:sequence select="imf:create-debug-comment('@typeCode!=relatie and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                
                                <xsl:variable name="docs">
                                   <imvert:complete-documentation>
                                       <xsl:copy-of select="imf:get-compiled-documentation($construct)"/>
                                   </imvert:complete-documentation>
                               </xsl:variable>
                               <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                               
                               <!-- Location: 'ep:construct1'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-structure.xsl' on the location with the id 'ep:constructRef1'. -->
                               
                               <ep:construct prefix="{$prefix}">
                                   <!-- The value of the tech-name is dependant on the availability of an alias. -->
                                   <xsl:choose>
                                       <xsl:when test="not(empty($alias)) and $alias != ''">
                                           <xsl:sequence select="imf:create-debug-comment('xsl:when test=$packages//imvert:class[imvert:id = $id]/imvert:alias',$debugging)"/>
                                           <xsl:sequence
                                               select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,$verwerkingsModus,$alias,$elementName))" />
                                       </xsl:when>
                                       <xsl:otherwise>
                                           <xsl:sequence select="imf:create-debug-comment('xsl:otherwise',$debugging)"/>
                                           <xsl:sequence
                                               select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,$verwerkingsModus,(),$elementName))" />
                                       </xsl:otherwise>
                                   </xsl:choose>
                                   <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                   <xsl:choose>
                                        
                                       <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                       <xsl:when test="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
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
                                           <ep:seq>
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
                                                           <xsl:when test="$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:type-id = $id]/imvert:stereotype = 'BERICHTRELATIE'">
                                                              <xsl:value-of select="'no'"/>
                                                           </xsl:when>
                                                           <xsl:otherwise>
                                                               <xsl:value-of select="'yes'"/>
                                                           </xsl:otherwise>
                                                       </xsl:choose>
                                                   </xsl:with-param>                                      
                                                   <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
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
                                               <xsl:if test="$construct/imvert:stereotype != 'KENNISGEVINGBERICHTTYPE' and
                                                   $construct/imvert:stereotype != 'VRAAGBERICHTTYPE' and
                                                   $construct/imvert:stereotype != 'ANTWOORDBERICHTTYPE' and
                                                   $construct/imvert:stereotype != 'SYNCHRONISATIEBERICHTTYPE' and not(contains(@verwerkingsModus,'kerngegevens'))">
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <ep:name>tijdvakGeldigheid</ep:name>
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
                                                       <ep:name>extraElementen</ep:name>
                                                       <ep:tech-name>extraElementen</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>165</ep:position>
                                                   </ep:constructRef>
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <ep:name>aanvullendeElementen</ep:name>
                                                       <ep:tech-name>aanvullendeElementen</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>170</ep:position>
                                                   </ep:constructRef>
                                               </xsl:if>
                                               <!-- ROME: Hieronder worden de construcRefs voor historieMaterieel en historieFormeel aangemaakt.
                                                    Dit moet echter gebeuren a.d.h.v. de berichtcode. Die verfijning moet nog worden aangebracht in de if statements. -->

                                               <!-- If 'Materiele historie' is applicable for the current class a constructRef to a historieMaterieel global construct based on the current class is generated. -->
                                               <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">

                                                   <!-- Location: 'ep:constructRef2'
								                        Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct2'. -->

                                                   <xsl:variable name="historieType" select="'historieMaterieel'"/>
                                                   
                                                   <ep:constructRef prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                       <ep:tech-name>historieMaterieel</ep:tech-name>
                                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>175</ep:position>
                                                       <xsl:choose>
                                                           <xsl:when test="not(empty($alias)) and $alias != ''">
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,$alias,$elementName))"/>
                                                           </xsl:when>
                                                           <xsl:otherwise>
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,(),$elementName))"/>
                                                           </xsl:otherwise>
                                                       </xsl:choose>
                                                   </ep:constructRef>
                                               </xsl:if>
                                               <!-- If 'Formele historie' is applicable for the current class a constructRef to a historieFormeel global construct based on the current class is generated. -->
                                               <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">

                                                   <xsl:variable name="historieType" select="'historieFormeel'"/>

                                                   <!-- Location: 'ep:constructRef5'
								                        Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef5'. -->
                                                   
                                                   <ep:constructRef prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                       <ep:tech-name>historieFormeel</ep:tech-name>
                                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>180</ep:position>
                                                       <xsl:choose>
                                                           <xsl:when test="not(empty($alias)) and $alias != ''">
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,$alias,$elementName))"/>
                                                           </xsl:when>
                                                           <xsl:otherwise>
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,(),$elementName))"/>
                                                           </xsl:otherwise>
                                                       </xsl:choose>
                                                   </ep:constructRef>
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
                                               <!-- ROME: Volgende wijze van waarde bepaling voor de mnemonic moet ook op diverse plaatsen in Imvert2XSD-KING-endproduct-structure geimplementeerd worden. -->
                                               <!--xsl:variable name="mnemonic">
                                                   <xsl:choose>
                                                       <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                                                       <xsl:otherwise>
                                                           <xsl:value-of select="$construct/imvert:alias"/>
                                                       </xsl:otherwise>
                                                   </xsl:choose>
                                               </xsl:variable-->
                                               <!-- The function imf:createAttributes is used to determine the XML attributes 
                                    				neccessary for this context. It has the following parameters: - typecode 
                                    				- berichttype - context - datumType The first 3 parameters relate to columns 
                                    				with the same name within an Excel spreadsheet used to configure a.o. XML 
                                    				attributes usage. The last parameter is used to determine the need for the 
                                    				XML-attribute 'StUF:indOnvolledigeDatum'. -->
                                               <xsl:sequence select="imf:create-debug-comment(concat('Attributes voor ',$typeCode,', berichtcode: ', substring($berichtCode,1,2) ,' context: ', $context, ' en mnemonic: ', $alias),$debugging)"/>
                                               <xsl:variable name="attributes"
                                                   select="imf:createAttributes($typeCode, substring($berichtCode,1,2), $context, 'no', $alias, 'no','no')" />
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
                        <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">
                            <xsl:variable name="historieType" select="'historieMaterieel'"/>
                            <xsl:choose>
                               <!-- The following when generates historieMaterieel global constructs based on uml groups. -->
                                <xsl:when test="@type='group' and exists(imf:get-construct-by-id($id,$packages))">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global materieleHistorie groupconstruct: ',$construct/imvert:name),$debugging)"/>
                                   
                                   <!--xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)"/-->
                                   <xsl:variable name="type" select="'Grp'"/>
                                   <xsl:variable name="name" select="ep:name"/>
                                   <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($construct)"/>
                                       </imvert:complete-documentation>
                                   </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id]',$debugging)"/>

                                   <!-- Location: 'ep:construct4'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef4'. -->
                                   
                                   <ep:construct prefix="{$prefix}" type="group">
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-Grp-complexTypeName($packageName,$berichtName,$type,$name,$historieType))" />
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
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
                                       </ep:seq> 
                                   </ep:construct>                       
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               </xsl:when>
                               <!-- The following when generates historieMaterieel global constructs based on uml classes. -->
                                <xsl:when test="exists(imf:get-construct-by-id($id,$packages))">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global materieleHistorie construct: ',$construct/imvert:name),$debugging)"/>
                                   
                                    <!--xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)"/-->
                                    <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($construct)"/>
                                       </imvert:complete-documentation>                           </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieMaterieleHistorie=Ja or @indicatieMaterieleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                   
                                   <!-- Location: 'ep:construct2'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef2'. -->
                                   
                                   <ep:construct prefix="{$prefix}">
                                       <!-- The value of the tech-name is dependant on the availability of an alias. -->
                                       <xsl:choose>
                                           <xsl:when test="not(empty($alias)) and $alias != ''">
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,$historieType,$alias,$elementName))" />
                                           </xsl:when>
                                           <xsl:otherwise>
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,$historieType,(),$elementName))" />
                                           </xsl:otherwise>
                                       </xsl:choose>
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                       <xsl:choose>
                                           <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                           
                                            
                                           
                                           <xsl:when test="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
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
                                                   <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                       <ep:name>tijdvakGeldigheid</ep:name>
                                                       <ep:tech-name>tijdvakGeldigheid</ep:tech-name>
                                                       <ep:max-occurs>1</ep:max-occurs>
                                                       <ep:min-occurs>1</ep:min-occurs>
                                                       <ep:position>155</ep:position>
                                                   </ep:constructRef>
                                                   <!-- If 'Formele historie' is applicable for the current class a the following construct and constructRef are generated. -->
                                                   <xsl:if test="@indicatieFormeleHistorie='Ja'">
                                                       <ep:constructRef prefix="StUF" externalNamespace="yes">
                                                           <ep:name>tijdstipRegistratie</ep:name>
                                                           <ep:tech-name>tijdstipRegistratie</ep:tech-name>
                                                           <ep:max-occurs>1</ep:max-occurs>
                                                           <ep:min-occurs>0</ep:min-occurs>
                                                           <ep:position>160</ep:position>
                                                       </ep:constructRef>
                                                       <ep:constructRef prefix="{$prefix}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                                                           <ep:name>historieFormeel</ep:name>
                                                           <ep:tech-name>historieFormeel</ep:tech-name>
                                                           <ep:max-occurs>unbounded</ep:max-occurs>
                                                           <ep:min-occurs>0</ep:min-occurs>
                                                           <ep:position>175</ep:position>
                                                           <!-- The value of the href is dependant on the availability of an alias. -->
                                                          <xsl:choose>
                                                              <xsl:when test="not(empty($alias)) and $alias != ''">
                                                                   <xsl:sequence
                                                                       select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,$alias,$elementName))" />
                                                               </xsl:when>
                                                               <xsl:otherwise>
                                                                   <xsl:sequence
                                                                       select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,(),$elementName))" />
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
                        <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes') and @verwerkingsModus = 'antwoord'">
                            <xsl:variable name="historieType" select="'historieFormeel'"/>
                            <xsl:choose>
                               <!-- The following when generates historieFormeel global constructs based on uml groups. -->
                                <xsl:when test="@type='group' and exists(imf:get-construct-by-id($id,$packages))">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global formeleHistorie groupconstruct: ',$construct/imvert:name),$debugging)"/>
                                   
                                    <!--xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)"/-->
                                    <xsl:variable name="type" select="'Grp'"/>
                                   <xsl:variable name="name" select="ep:name"/>
                                   <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($construct)"/>
                                       </imvert:complete-documentation>
                                   </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                   
                                   <!-- Location: 'ep:construct5'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef5'. -->
                                   
                                   <ep:construct prefix="{$prefix}" type="group">
                                       <xsl:sequence
                                           select="imf:create-output-element('ep:tech-name', imf:create-Grp-complexTypeName($packageName,$berichtName,$type,$name,$historieType))" />
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
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
                                       </ep:seq> 
                                   </ep:construct>                       
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @type=group and $packages//imvert:class[imvert:id = $id] End-For-each-when',$debugging)"/>
                               </xsl:when>
                               <!-- The following when generates historieFormeel global constructs based on uml classes. -->
                                <xsl:when test="exists(imf:get-construct-by-id($id,$packages))">
                                   
                                   <xsl:sequence select="imf:create-debug-track(concat('Constructing global formeleHistorie construct: ',$construct/imvert:name),$debugging)"/>
                                   
                                    <!--xsl:variable name="construct" select="imf:get-construct-by-id($id,$packages)"/-->
                                    <xsl:variable name="docs">
                                       <imvert:complete-documentation>
                                           <xsl:copy-of select="imf:get-compiled-documentation($construct)"/>
                                       </imvert:complete-documentation>
                                   </xsl:variable>
                                   <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
                                   
                                   <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and $packages//imvert:class[imvert:id = $id]',$debugging)"/>
                                   
                                   <!-- Location: 'ep:construct6'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef6'. -->
                                   
                                   <ep:construct prefix="{$prefix}">
                                       <!-- The value of the tech-name is dependant on the availability of an alias. -->
                                       <xsl:choose>
                                           <xsl:when test="not(empty($alias)) and $alias != ''">
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,$historieType,$alias,$elementName))" />
                                           </xsl:when>
                                           <xsl:otherwise>
                                               <xsl:sequence
                                                   select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,$historieType,(),$elementName))" />
                                           </xsl:otherwise>
                                       </xsl:choose>
                                       <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                                       <xsl:choose>
                                           <!-- When the uml class is a superclass of other uml classes it's content is determined by processing the subclasses. -->
                                           
                                           
                                           <xsl:when test="$packages/imvert:package/imvert:class[imvert:supertype/imvert:type-id = $id]">
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
                                                       <ep:name>historieFormeel</ep:name>
                                                       <ep:tech-name>historieFormeel</ep:tech-name>
                                                       <ep:max-occurs>unbounded</ep:max-occurs>
                                                       <ep:min-occurs>0</ep:min-occurs>
                                                       <ep:position>175</ep:position>
                                                       <!-- The value of the href is dependant on the availability of an alias. -->
                                                       <xsl:choose>
                                                           <xsl:when test="not(empty($alias)) and $alias != ''">
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,$alias,$elementName))" />
                                                           </xsl:when>
                                                           <xsl:otherwise>
                                                               <xsl:sequence
                                                                   select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$historieType,(),$elementName))" />
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
                        
                        <xsl:variable name="association" select="$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']"/>
                        
                        <xsl:apply-templates select="$association"
                            mode="create-global-construct">
                            <xsl:with-param name="berichtCode" select="$berichtCode"/>
                            <xsl:with-param name="berichtName" select="$berichtName"/>
                            <xsl:with-param name="generated-id" select="$generated-id"/>
                            <xsl:with-param name="currentMessage" select="$currentMessage"/>
                            <xsl:with-param name="context" select="$context"/>
                            <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                            <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                            <xsl:with-param name="indicatieFormeleHistorieRelatie" select="@indicatieFormeleHistorieRelatie"/>
                            <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                        </xsl:apply-templates>

                        <!-- There are 2 types of history parameters. The first one configures if history is applicable for the current context. History isn't applicable for example for each message type.
                        The second one is used to determine if history, if applicable for the context, is applicable for the class being processed. Not every class has attributes or associations history applies to. -->
                        
                        <!-- If 'Materiele historie' is applicable for the current class and messagetype a historieMaterieel global construct based on the current class is generated. -->
                        <xsl:if test="(@indicatieMaterieleHistorie='Ja' or @indicatieMaterieleHistorie='Ja op attributes')">
                            
                            <xsl:sequence select="imf:create-debug-track(concat('Constructing the materieleHistorie constructs: ',$association/imvert:name),$debugging)"/>

                            <xsl:apply-templates select="$association"
                                mode="create-global-construct">
                                <xsl:with-param name="berichtCode" select="$berichtCode"/>
                                <xsl:with-param name="berichtName" select="$berichtName"/>
                                <xsl:with-param name="generated-id" select="$generated-id"/>
                                <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                <xsl:with-param name="context" select="$context"/>
                                <xsl:with-param name="generateHistorieConstruct" select="'MaterieleHistorie'"/>
                                <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                            </xsl:apply-templates>
                        </xsl:if>
                        
                        
                        <!-- If 'Formele historie' is applicable for the current class and messagetype a historieFormeel global construct based on the current class is generated. -->
                        <xsl:if test="(@indicatieFormeleHistorie='Ja' or @indicatieFormeleHistorie='Ja op attributes')">
                            
                            <xsl:sequence select="imf:create-debug-track(concat('Constructing the formeleHistorie constructs: ',$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']/imvert:name),$debugging)"/>
                            
                            <xsl:apply-templates select="$association"
                                mode="create-global-construct">
                                <xsl:with-param name="berichtCode" select="$berichtCode"/>
                                <xsl:with-param name="berichtName" select="$berichtName"/>
                                <xsl:with-param name="generated-id" select="$generated-id"/>
                                <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                <xsl:with-param name="context" select="$context"/>
                                <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorie'"/>
                                <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                            </xsl:apply-templates>
                        </xsl:if>
                        
                        <!-- If 'Formele historie' is applicable for the current class and messagetype a historieFormeel global construct based on the current class is generated. -->
                        <xsl:if test="@indicatieFormeleHistorieRelatie='Ja'">
                            
                            <xsl:sequence select="imf:create-debug-track(concat('Constructing the formeleHistorieRelatie constructs: ',$packages/imvert:package/imvert:class/imvert:associations/imvert:association[imvert:id = $id and imvert:stereotype = 'RELATIE']/imvert:name),$debugging)"/>
                            
                            <xsl:apply-templates select="$association"
                                mode="create-global-construct">
                                <xsl:with-param name="berichtCode" select="$berichtCode"/>
                                <xsl:with-param name="berichtName" select="$berichtName"/>
                                <xsl:with-param name="generated-id" select="$generated-id"/>
                                <xsl:with-param name="currentMessage" select="$currentMessage"/>
                                <xsl:with-param name="context" select="$context"/>
                                <xsl:with-param name="generateHistorieConstruct" select="'FormeleHistorieRelatie'"/>
                                <xsl:with-param name="indicatieMaterieleHistorie" select="@indicatieMaterieleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorie" select="@indicatieFormeleHistorie"/>
                                <xsl:with-param name="indicatieFormeleHistorieRelatie" select="@indicatieFormeleHistorieRelatie"/>
                                <xsl:with-param name="verwerkingsModus" select="$verwerkingsModus"/>
                            </xsl:apply-templates>
                        </xsl:if>
 
                        <xsl:sequence select="imf:create-debug-comment('For-each-when: @indicatieFormeleHistorie=Ja or @indicatieFormeleHistorie=Ja op attributes and @typeCode=relatie End-For-each-when',$debugging)"/>
                        
                    </xsl:when>
               </xsl:choose>
            </xsl:for-each>
        
       <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for antwoord constructs',$debugging)"/>
            
        <xsl:for-each select="$currentMessage/ep:rough-message[contains(ep:code, 'La')]//ep:construct[ep:name = 'antwoord']">

            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, La)]//ep:construct[ep:name = antwoord]',$debugging)"/>
            <xsl:sequence select="imf:create-debug-comment('$currentMessage/ep:rough-message[contains(ep:code, La)]//ep:construct[ep:name = antwoord]',$debugging)"/>
            
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
            <xsl:variable name="generated-id" select="generate-id(.)"/>
            <xsl:variable name="relatedObjectId" select="ep:id"/>
            <xsl:variable name="id" select="ep:origin-id"/>
            <!--xsl:variable name="relatedObjectTypeId" select="ep:construct/ep:id"/--> 
            <xsl:variable name="verwerkingsModus" select="'antwoord'"/>
            <xsl:variable name="packageName" select="@package"/> 
            <xsl:variable name="construct" select="imf:get-construct-by-id($relatedObjectId,$packages)"/>
            <!--xsl:variable name="alias" select="$construct/imvert:alias"/--> 
            <xsl:variable name="alias">
                <xsl:choose>
                    <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="$construct/imvert:alias"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="association" select="imf:get-construct-by-id($id,$packages)"/>
            <xsl:variable name="elementName" select="$construct/imvert:name"/>
            
            <!-- Location: 'ep:construct7'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef7'. -->
            
            <ep:construct prefix="{$prefix}">
                 <xsl:sequence
                     select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,'antwoord',(),'object'))" />
                <ep:seq orderingDesired="no">
                    
                    <!-- Location: 'ep:constructRef1'
							    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
                    
                    <ep:constructRef prefix="{$prefix}" context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                        <xsl:variable name="packageName" select="@package"/> 

                        <ep:tech-name>object</ep:tech-name>
                        <xsl:sequence
                            select="imf:create-output-element('ep:max-occurs', $association/imvert:max-occurs)" />
                        <xsl:sequence
                            select="imf:create-output-element('ep:min-occurs', $association/imvert:min-occurs)" />
                        <ep:position>1</ep:position>
                        <xsl:sequence select="imf:create-debug-comment('xsl:when test=$packages//imvert:class[imvert:id = $id]/imvert:alias',$debugging)"/>
                        <xsl:sequence
                            select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$verwerkingsModus,$alias,$elementName))" />
                    </ep:constructRef>
                </ep:seq>
            </ep:construct>                  
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, La)]//ep:construct[ep:name = antwoord] End-for-each',$debugging)"/>
            
        </xsl:for-each>
            
        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for start constructs',$debugging)"/>
            
        <xsl:for-each select="$currentMessage/ep:rough-message[contains(ep:code, 'Lv')]//ep:construct[ep:name = 'start']">
            <xsl:sequence select="imf:create-debug-comment('$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:name = start]',$debugging)"/>
            
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
            <xsl:variable name="generated-id" select="generate-id(.)"/>
            <xsl:variable name="relatedObjectId" select="ep:id"/>
            <xsl:variable name="id" select="ep:origin-id"/>
            <!--xsl:variable name="relatedObjectTypeId" select="ep:construct/ep:id"/--> 
            <xsl:variable name="verwerkingsModus" select="'vraag'"/>
            <!--xsl:variable name="verwerkingsModus" select="'antwoord'"/-->
            <xsl:variable name="packageName" select="@package"/> 
            <xsl:variable name="construct" select="imf:get-construct-by-id($relatedObjectId,$packages)"/>
            <!--xsl:variable name="alias" select="$construct/imvert:alias"/--> 
            <xsl:variable name="alias">
                <xsl:choose>
                    <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="$construct/imvert:alias"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="association" select="imf:get-construct-by-id($id,$packages)"/>
            <xsl:variable name="elementName" select="$construct/imvert:name"/>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:name = start]',$debugging)"/>

            <!-- Location: 'ep:construct8'
				 Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef8'. -->
            
            <ep:construct prefix="{$prefix}">
                            <xsl:sequence
                                select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,'start',(),'object'))" />
                     <ep:seq orderingDesired="no">
                        
                        <!-- Location: 'ep:constructRef1'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
                        
                        <ep:constructRef prefix="{$prefix}" context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                            <xsl:variable name="packageName" select="@package"/> 

                            <ep:tech-name>object</ep:tech-name>
                            <!-- ROME: Moeten deze min- en max-occurs niet beide altijd de waarde '1' hebben? -->
                            <xsl:sequence
                                select="imf:create-output-element('ep:max-occurs', $association/imvert:max-occurs)" />
                            <xsl:sequence
                                select="imf:create-output-element('ep:min-occurs', $association/imvert:min-occurs)" />
                            <ep:position>1</ep:position>
                            <xsl:sequence select="imf:create-debug-comment('xsl:when test=$packages//imvert:class[imvert:id = $id]/imvert:alias',$debugging)"/>
                            <xsl:sequence
                                select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$verwerkingsModus,$alias,$elementName))" />
                         </ep:constructRef>
                    </ep:seq>
                </ep:construct>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:name = start] End-for-each',$debugging)"/>
            
        </xsl:for-each>
            
        <xsl:sequence select="imf:create-debug-track('Constructing the global constructs for antwoord scope',$debugging)"/>
            
        <xsl:for-each select="$currentMessage/ep:rough-message[contains(ep:code, 'Lv')]//ep:construct[ep:name = 'scope']">
 
            <xsl:sequence select="imf:create-debug-comment('$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:name = scope]',$debugging)"/>
            
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
            <xsl:variable name="generated-id" select="generate-id(.)"/>
            <xsl:variable name="relatedObjectId" select="ep:id"/>
            <xsl:variable name="id" select="ep:origin-id"/>
            <!--xsl:variable name="relatedObjectTypeId" select="ep:construct/ep:id"/--> 
            <xsl:variable name="verwerkingsModus" select="'vraag'"/>
            <!--xsl:variable name="verwerkingsModus" select="'scope'"/-->
            <xsl:variable name="packageName" select="@package"/> 
            <xsl:variable name="construct" select="imf:get-construct-by-id($relatedObjectId,$packages)"/>
            <!--xsl:variable name="alias" select="$construct/imvert:alias"/--> 
            <xsl:variable name="alias">
                <xsl:choose>
                    <xsl:when test="empty($construct/imvert:alias) or not($construct/imvert:alias)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="$construct/imvert:alias"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="association" select="imf:get-construct-by-id($id,$packages)"/>
            <xsl:variable name="elementName" select="$construct/imvert:name"/>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:name = scope]',$debugging)"/>
                        
            <!-- Location: 'ep:construct9'
								    Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:constructRef9'. -->
            
            <ep:construct prefix="{$prefix}">
                <xsl:sequence select="imf:create-output-element('ep:tech-name', imf:create-complexTypeName($packageName,$berichtName,'scope',(),'object'))" />
                    <ep:seq orderingDesired="no">
 
                        <!-- Location: 'ep:constructRef1'
								    Matches with ep:construct created in 'Imvert2XSD-KING-endproduct-xml.xsl' on the location with the id 'ep:construct1'. -->
                        
                        <ep:constructRef prefix="{$prefix}" context="{@context}" berichtCode="{$berichtCode}" berichtName="{$berichtName}">
                            <xsl:variable name="packageName" select="@package"/> 
                            
                            <ep:tech-name>object</ep:tech-name>
                            <!-- ROME: Moeten deze min- en max-occurs niet beide altijd de waarde '1' hebben? -->
                            <xsl:sequence
                                select="imf:create-output-element('ep:max-occurs', $association/imvert:max-occurs)" />
                            <xsl:sequence
                                select="imf:create-output-element('ep:min-occurs', $association/imvert:min-occurs)" />
                            <ep:position>1</ep:position>
                            <xsl:sequence select="imf:create-debug-comment('xsl:when test=$packages//imvert:class[imvert:id = $id]/imvert:alias',$debugging)"/>

                            <xsl:sequence
                                select="imf:create-output-element('ep:href', imf:create-complexTypeName($packageName,$berichtName,$verwerkingsModus,$alias,$elementName))" />
                        </ep:constructRef>
                    </ep:seq>
                </ep:construct>
            
            <xsl:sequence select="imf:create-debug-track('for-each select=$currentMessage/ep:rough-message[contains(ep:code, Lv)]//ep:construct[ep:name = scope] End-for-each',$debugging)"/>
            
        </xsl:for-each>        
    </xsl:template>
  
    <!-- supress the suppressXsltNamespaceCheck message -->
    <xsl:template match="/imvert:dummy"/>
    
    <!-- This template (4) transforms an 'imvert:association' element to a global 'ep:construct' 
		 element. -->
    <xsl:template match="imvert:association" mode="create-global-construct">
        <xsl:param name="berichtCode"/>
        <xsl:param name="berichtName"/>
        <xsl:param name="generated-id"/>
        <xsl:param name="currentMessage"/>
        <xsl:param name="context"/>
        <xsl:param name="orderingDesired" select="'yes'"/>
        <xsl:param name="generateHistorieConstruct" select="'Nee'"/>
        <xsl:param name="indicatieMaterieleHistorie" select="'Nee'"/>
        <xsl:param name="indicatieFormeleHistorie" select="'Nee'"/>
        <xsl:param name="indicatieFormeleHistorieRelatie" select="'Nee'"/>
        <xsl:param name="useStuurgegevens" select="'yes'"/>                                       
        <xsl:param name="verwerkingsModus"/>
 
        <xsl:variable name="type-id" select="imvert:type-id"/>
        <xsl:variable name="verwerkingsModusOfConstructRef" select="$verwerkingsModus"/>        
        <xsl:variable name="packageName" select="ancestor::imvert:package/imvert:name"/> 
        
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
        <xsl:sequence select="imf:create-debug-comment(concat('Typering: ',$typering,' verwerkingsModus: ',$verwerkingsModus,' verwerkingsModusOfConstructRef: ',$verwerkingsModusOfConstructRef),$debugging)"/>
        
        
        <xsl:variable name="historyName">
            <xsl:choose>
                <xsl:when test="$generateHistorieConstruct = 'MaterieleHistorie' and contains($indicatieMaterieleHistorie,'Ja')">-historieMaterieel</xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorie' and contains($indicatieFormeleHistorie,'Ja')">-historieFormeel</xsl:when>
                <xsl:when test="$generateHistorieConstruct = 'FormeleHistorieRelatie' and contains($indicatieFormeleHistorieRelatie,'Ja')">-historieFormeelRelatie</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="imf:create-debug-comment('Template: imvert:association[mode=create-global-construct]',$debugging)"/>
        
        <xsl:variable name="alias">
            <xsl:choose>
                <xsl:when test="imvert:stereotype = 'ENTITEITRELATIE'">
                    <xsl:value-of select="key('class',$type-id)/imvert:alias"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="imvert:alias"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="name" select="imvert:name/@original"/>
        <xsl:variable name="elementName" select="imvert:name"/>
        
        <xsl:sequence select="imf:create-debug-comment(concat('typering for construct with id ',$type-id, ' and parent construct (',$currentMessage//ep:*[generate-id() = $generated-id]/ep:id,') with generated-id ',$generated-id,': ',$typering),$debugging)"/>
        
        <xsl:variable name="tech-name">
            <xsl:choose>
                <xsl:when
                    test="imvert:stereotype = 'RELATIE' and key('class',$type-id)/imvert:alias and not(empty($typering))">
                    <xsl:value-of
                        select="imf:create-complexTypeName($packageName,$berichtName,$typering,$alias,$elementName)"/>
                </xsl:when>
                <xsl:when
                    test="imvert:stereotype = 'RELATIE' and key('class',$type-id)/imvert:alias">
                    <xsl:value-of
                        select="imf:create-complexTypeName($packageName,$berichtName,(),$alias,$elementName)"/>
                </xsl:when>
                <xsl:when test="imvert:stereotype = 'RELATIE' and not(empty($typering))">
                    <xsl:value-of
                        select="imf:create-complexTypeName($packageName,$berichtName,$typering,(),$elementName)"/>
                </xsl:when>
                <xsl:when test="imvert:stereotype = 'RELATIE'">
                    <xsl:value-of
                        select="imf:create-complexTypeName($packageName,$berichtName,(),(),$elementName)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="imf:create-complexTypeName($packageName,$berichtName,$historyName,(),$elementName)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="type-name" select="imvert:type-name"/>
        <xsl:variable name="max-occurs" select="imvert:max-occurs"/>
        <xsl:variable name="min-occurs" select="imvert:min-occurs"/>
        <xsl:variable name="id" select="imvert:id"/>
        <xsl:variable name="docs">
            <imvert:complete-documentation>
                <xsl:copy-of select="imf:get-compiled-documentation(.)"/>
            </imvert:complete-documentation>
        </xsl:variable>
        <xsl:variable name="doc" select="imf:merge-documentation($docs)"/>
        <xsl:variable name="tvs" as="element(ep:tagged-values)">
            <ep:tagged-values>
                <xsl:copy-of select="imf:get-compiled-tagged-values(., true())"/>
            </ep:tagged-values>
        </xsl:variable>
        <xsl:variable name="kerngegeven" select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie kerngegeven')"/>
        <xsl:variable name="authentiek" select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie authentiek')"/>
        <xsl:variable name="mogelijkGeenWaarde" select="imf:get-most-relevant-compiled-taggedvalue(., 'Mogelijk geen waarde')"/>
        <xsl:variable name="regels" select="imf:get-most-relevant-compiled-taggedvalue(., 'Regels')"/>
        
        <xsl:if test="not(contains($verwerkingsModus, 'kerngegeven') and $kerngegeven = 'Ja')">
            
            <!-- Location: 'ep:construct10'
				 Matches with ep:constructRef created in 'Imvert2XSD-KING-endproduct-structure.xsl' on the location with the id 'ep:constructRef10'. -->			
            
            <ep:construct prefix="{$prefix}">
                <xsl:if test="$debugging">
                    <xsl:variable name="materieleHistorie" select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie materiële historie')"/>
                    <xsl:variable name="formeleHistorie" select="imf:get-most-relevant-compiled-taggedvalue(., 'Indicatie formele historie')"/>
                    <ep:tagged-values>
                        <xsl:copy-of select="$tvs"/>
                        <ep:found-tagged-values>
                            <xsl:sequence select="imf:create-output-element('ep:materieleHistorie', $materieleHistorie)"/>
                            <xsl:sequence select="imf:create-output-element('ep:formeleHistorie', $formeleHistorie)"/>
                            <xsl:sequence select="imf:create-output-element('ep:mogelijkGeenWaarde', $mogelijkGeenWaarde)"/>
                            <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
                            <xsl:sequence select="imf:create-output-element('ep:kerngegeven', $kerngegeven)"/>
                            <xsl:sequence select="imf:create-output-element('ep:regels', $regels)"/>
                        </ep:found-tagged-values>
                    </ep:tagged-values>
                </xsl:if>
                <xsl:sequence select="imf:create-output-element('ep:name', $name)"/>
                <xsl:sequence select="imf:create-output-element('ep:tech-name', $tech-name)"/>
                <xsl:sequence select="imf:create-output-element('ep:type-name', $type-name)"/>
                <xsl:sequence select="imf:create-output-element('ep:documentation', $doc)"/>
                
                <!-- ROME: Het is de vraag of een relatie als authentiek bestempelt kan worden. Zo niet dan moet onderstaande sequence verwijderd worden. -->
                <xsl:sequence select="imf:create-output-element('ep:authentiek', $authentiek)"/>
                <xsl:sequence select="imf:create-output-element('ep:kerngegeven', $kerngegeven)"/>
                <xsl:sequence select="imf:create-output-element('ep:max-occurs', $max-occurs)"/>
                <xsl:sequence select="imf:create-output-element('ep:min-occurs', $min-occurs)"/>
                <xsl:sequence select="imf:create-output-element('ep:regels', $regels)"/>
                <xsl:sequence select="imf:create-output-element('ep:mogelijk-geen-waarde', $mogelijkGeenWaarde)"/>
                
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
                        <xsl:with-param name="berichtName" select="$berichtName"/>
                        <xsl:with-param name="generated-id" select="$generated-id"/>
                        <xsl:with-param name="currentMessage" select="$currentMessage"/>
                        <xsl:with-param name="context" select="$context"/>
                        <xsl:with-param name="generateHistorieConstruct" select="$generateHistorieConstruct"/>
                        <xsl:with-param name="indicatieMaterieleHistorie" select="$indicatieMaterieleHistorie"/>
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
                        <xsl:variable name="attributes"
                            select="imf:createAttributes('relatie', substring($berichtCode, 1, 2), $context, 'no', $alias, $mogelijkGeenWaarde, 'no')"/>
                        <xsl:sequence select="$attributes"/>
                    </xsl:if>
                </ep:seq>
            </ep:construct>
        </xsl:if>
        
        <xsl:sequence select="imf:create-debug-comment('Template: imvert:association[mode=create-global-construct] End',$debugging)"/>
    </xsl:template>
    
    <xsl:function name="imf:create-complexTypeName">
        <xsl:param name="packageName"/>
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>

        <xsl:value-of select="imf:create-complexTypeName($packageName,$berichtName,$typering,())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-complexTypeName">
        <xsl:param name="packageName"/>
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>
        <xsl:param name="alias"/>

         <xsl:value-of select="imf:create-complexTypeName($packageName,$berichtName,$typering,$alias,())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-complexTypeName">
        <xsl:param name="packageName"/>
        <xsl:param name="berichtName"/>
        <xsl:param name="typering"/>
        <xsl:param name="alias"/>
        <xsl:param name="elementName"/>
        
        <xsl:sequence select="imf:create-debug-track(concat('packageName: ',$packageName,', berichtName: ',$berichtName,', typering: ',$typering,', alias: ',$alias,', element: ',$elementName),$debugging)"/>
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
                    <xsl:value-of select="concat(upper-case(substring($typering,1,1)),lower-case(substring($typering,2)),'.')"/>
                </xsl:when>
                <xsl:otherwise>.</xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(empty($alias)) and not(empty($elementName))">
                <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)))"/>
            </xsl:if>
            <!--xsl:value-of select="concat(upper-case(substring($packageName,1,1)),lower-case(substring($packageName,2)))"/-->           
        </xsl:variable>
        
        <xsl:sequence select="imf:create-debug-track(concat('complexTypeName: ',$complexTypeName),$debugging)"/>
        
        <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/>-<xsl:value-of select="$berichtName"/>
    </xsl:function>
    
    <xsl:function name="imf:create-Grp-complexTypeName">
        <xsl:param name="packageName"/>
        <xsl:param name="berichtName"/>
        <xsl:param name="type"/>
        <xsl:param name="elementName"/>      
        
        <xsl:value-of select="imf:create-Grp-complexTypeName($packageName,$berichtName,$type,$elementName,())"/>
    </xsl:function>

    <xsl:function name="imf:create-Grp-complexTypeName">
        <xsl:param name="packageName"/>
        <xsl:param name="berichtName"/>
        <xsl:param name="type"/>
        <xsl:param name="elementName"/>      
        <xsl:param name="typering"/>
        
        <xsl:sequence select="imf:create-debug-track(concat('packageName: ',$packageName,', berichtName: ',$berichtName,', type: ',$type,', element: ',$elementName,', typering: ',$typering),$debugging)"/>
        
        <xsl:variable name="complexTypeName">
            <xsl:value-of select="concat(upper-case(substring($type,1,1)),lower-case(substring($type,2)),'-')"/>
            <xsl:choose>
                <xsl:when test="not(empty($typering))">
                    <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)),'-')"/>
                    <xsl:value-of select="concat(upper-case(substring($typering,1,1)),lower-case(substring($typering,2)),'.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(upper-case(substring($elementName,1,1)),lower-case(substring($elementName,2)),'.')"/>
                </xsl:otherwise>
            </xsl:choose>
             <!--xsl:value-of select="concat(upper-case(substring($packageName,1,1)),lower-case(substring($packageName,2)))"/-->           
        </xsl:variable>
        
        <xsl:sequence select="imf:create-debug-track(concat('complexTypeName: ',$complexTypeName),$debugging)"/>
        
        <xsl:value-of select="imf:get-normalized-name($complexTypeName,'type-name')"/><xsl:value-of select="$berichtName"/>
    </xsl:function>
</xsl:stylesheet>
