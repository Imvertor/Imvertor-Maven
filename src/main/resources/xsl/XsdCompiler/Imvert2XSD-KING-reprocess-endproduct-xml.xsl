<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct-xml.xsl 7487 2016-04-02 07:27:03Z arjan $ 
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
    xmlns:stuf="http://www.stufstandaarden.nl/onderlaag/stuf0302" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>

    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
      
    <xsl:output indent="yes" method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="stylesheet-code" as="xs:string">SKS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>

    <xsl:variable name="stylesheet">Imvert2XSD-KING-ordered-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-ordered-endproduct-xml.xsl 7487 2016-04-02 07:27:03Z arjan $</xsl:variable> 
    
    <xsl:variable name="StUF-prefix" select="'StUF'"/>
    <xsl:variable name="kv-prefix" select="/ep:message-set/ep:namespace-prefix"/>
    
    <xsl:variable name="reprocessed-endproduct">

        <xsl:apply-templates select="/ep:message-set"/>
        
    </xsl:variable>
    
    <xsl:template match="/">
        
        <xsl:sequence select="imf:pretty-print($reprocessed-endproduct,false())"/>
        
    </xsl:template>
    
    <xsl:template match="ep:message-set">
        <xsl:sequence select="imf:track('reprocessing the message-set')"/>
        <ep:message-set>
            <xsl:apply-templates select="*">
                <xsl:with-param name="actualPrefix" select="$kv-prefix"/>
            </xsl:apply-templates>
        </ep:message-set>
    </xsl:template>

    <xsl:template match="ep:tv-position"/>
    
    <xsl:template match="*">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <xsl:param name="prefix4metadataConstructs"/>
        
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2000',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2000',$debugging)"/>
        

        <xsl:element name="{name(.)}">
            <xsl:if test="@prefix">
                <xsl:variable name="prefix">
                    <xsl:apply-templates select="@prefix">
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:attribute name="prefix" select="$prefix"/>
            </xsl:if>
            <xsl:apply-templates select="@*[not(name()='prefix')]"/>
            <xsl:choose>
                <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2001',$debugging)"/>
                    <xsl:sequence select="imf:create-debug-track('Debuglocation 2001',$debugging)"/>
                    
                    <xsl:sequence select="imf:create-debug-comment(concat('procesType: ',$procesType),$debugging)"/>                
                    <xsl:apply-templates select="*">
                        <xsl:with-param name="procesType" select="$procesType"/>
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                        <xsl:with-param name="prefix4metadataConstructs" select="$prefix4metadataConstructs"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2002',$debugging)"/>
                    <xsl:sequence select="imf:create-debug-track('Debuglocation 2002',$debugging)"/>
                    
                    <xsl:sequence select="imf:create-debug-comment(concat('procesType: ',$procesType),$debugging)"/>                
                    <xsl:apply-templates select="*">
                        <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                        <xsl:with-param name="procesType" select="$procesType"/>
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                        <xsl:with-param name="prefix4metadataConstructs" select="$prefix4metadataConstructs"/>
                    </xsl:apply-templates>              
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <!-- The following template takes care of replicating the 'ep:constructRef' element removing the 'ep:id' element. -->
    <xsl:template match="ep:constructRef">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <xsl:param name="prefix4metadataConstructs"/>

        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2003',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2003',$debugging)"/>
        
        <xsl:choose>
            <xsl:when test="@ismetadata='yes' and 
                            (
                                (
                                    $procesType='splitting' and $prefix4metadataConstructs = $actualPrefix             
                                ) 
                            or $procesType!='splitting'
                            )">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2004',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2004',$debugging)"/>
                
                <!-- ROME: Op de eoa wijze krijgt de parameter 'actualPrefix' van dit template niet de correcte waarde mee.
                           Vandaar dat ik hieronder een nieuwe variabele aanmaak. -->
                <xsl:variable name="actualPrefix2" select="ancestor::ep:construct[parent::ep:message-set]/@prefix"/>
 
                <ep:constructRef>
                    <xsl:variable name="prefix">
                        <xsl:apply-templates select="@prefix">
                            <xsl:with-param name="actualPrefix" select="$actualPrefix2"/>
                            <xsl:with-param name="prefix4metadataConstructs">
                                <xsl:choose>
                                    <xsl:when test="ep:tech-name = 'entiteittype'">
                                        <xsl:value-of select="$prefix4metadataConstructs"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="''"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:attribute name="prefix" select="$prefix"/>
                    <xsl:apply-templates select="*[not(name()='ep:href')]|@*[not(name()='prefix')]"/>
                    <xsl:sequence select="imf:create-output-element('ep:href', concat($prefix,':',ep:href))"/>
                </ep:constructRef>
            </xsl:when>
            <xsl:when test="not(@ismetadata='yes') and $procesType='splitting' and (@prefix = $actualPrefix or @prefix = '$actualPrefix')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2005',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2005',$debugging)"/>
                
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:if test="@prefix">
                        <xsl:attribute name="prefix" select="$actualPrefix"/>
                    </xsl:if>
                    <xsl:if test="@namespaceId">
                        <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    </xsl:if>
                    <xsl:apply-templates select="*[name() != 'ep:id']"/>
                </xsl:element>  
            </xsl:when>
            <xsl:when test="not(@ismetadata='yes') and (($procesType='splitting' and ($prefix4metadataConstructs = $actualPrefix and (@prefix = $StUF-prefix  or not(@prefix)))) or $procesType != 'splitting')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2006',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2006',$debugging)"/>
                
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:if test="@prefix">
                        <xsl:attribute name="prefix" select="@prefix"/>
                    </xsl:if>
                    <xsl:if test="@namespaceId">
                        <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    </xsl:if>
                    <xsl:apply-templates select="*[name() != 'ep:id']"/>
                </xsl:element>  
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <xsl:param name="prefix4metadataConstructs"/>

        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2007',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2007',$debugging)"/>
        <xsl:sequence select="imf:create-debug-comment(concat('prefix4metadataConstructs: ',$prefix4metadataConstructs),$debugging)"/>
        <xsl:sequence select="imf:create-debug-comment(concat('actualPrefix: ',$actualPrefix),$debugging)"/>
        
        <xsl:variable name="prefix" select="@prefix"/>

        <xsl:choose>
            <xsl:when test="@ismetadata='yes' and 
                            (
                                (
                                    $procesType='splitting' and $prefix4metadataConstructs = $actualPrefix             
                                ) 
                            or $procesType!='splitting'
                            )">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2007a',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2007a',$debugging)"/>
                
                <xsl:copy-of select="."/>
            </xsl:when>
            <!-- Following when removes constructs refering to global constructs with empty ep:seq or ep:choice.
                 Those global constructs will be removed, since they have no content, so constructs refering to them must be removed too. -->
            <xsl:when test="not(@ismetadata='yes') and ep:type-name = //ep:message-set/ep:construct[@prefix = $prefix and ((ep:seq and not(ep:seq/*)) or (ep:choice and not(ep:choice/*)))]/ep:tech-name"/>
            <xsl:when test="not(@ismetadata='yes') and substring-after(ep:type-name,':') = //ep:message-set/ep:construct[@prefix = $prefix and ((ep:seq and not(ep:seq/*)) or (ep:choice and not(ep:choice/*)))]/ep:tech-name"/>
            <!-- Following when splits the constructs within the current construct over one or more copies of the 
                 current constructs based on the amount of different prefixes the child constructs belong to. -->
            <xsl:when test="not(@ismetadata='yes') and 
                            (
                                (
                                    $procesType='splitting' and @prefix = $actualPrefix
                                ) 
                            or $procesType!='splitting'
                            )">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2007b',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2007b',$debugging)"/>
                
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:attribute name="prefix">
                        <xsl:choose>
                            <xsl:when test="@prefix = $StUF-prefix">
                                <xsl:value-of select="$StUF-prefix"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$actualPrefix"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    <xsl:choose>
                        <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                            <xsl:apply-templates select="*">
                                <!--xsl:with-param name="actualPrefix" select="$actualPrefix"/-->
                                <xsl:with-param name="actualPrefix">
                                    <xsl:choose>
                                        <xsl:when test="@prefix = $StUF-prefix">
                                            <xsl:value-of select="$StUF-prefix"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$actualPrefix"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*">
                                <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                <!--xsl:with-param name="actualPrefix" select="$actualPrefix"/-->
                                <xsl:with-param name="actualPrefix">
                                    <xsl:choose>
                                        <xsl:when test="@prefix = $StUF-prefix">
                                            <xsl:value-of select="$StUF-prefix"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$actualPrefix"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:apply-templates>              
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2007c',$debugging)"/>       
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2007c',$debugging)"/>
                <xsl:sequence select="imf:create-debug-comment(concat('ep:tech-name :',ep:tech-name,' ,$actualPrefix : ',$actualPrefix),$debugging)"/>       
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct[@type != 'simpleContentcomplexData' and @type != 'simpleData' and parent::ep:message-set]">
        <xsl:param name="actualPrefix"/>
        
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2010',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2010',$debugging)"/>
        
        <xsl:variable name="construct" select="."/>
        <xsl:variable name="prefix" select="@prefix"/>
        <xsl:variable name="suppliers" select=".//ep:suppliers"/>
        <xsl:variable name="uniquePrefixes" as="element(ep:prefixes)">
            <xsl:variable name="listOfPrefixes">
                <ep:prefixes>
                    <xsl:for-each select="$suppliers/supplier">
                        <xsl:variable name="descendant-prefix" select="@verkorteAlias" as="attribute(verkorteAlias)"/>
                        <xsl:if test="not(preceding-sibling::supplier[@prefix = $descendant-prefix])">
                            <ep:prefix>
                                <xsl:attribute name="namespaceId" select="@base-namespace"/>
                                <xsl:attribute name="level" select="@level"/>
                                <xsl:attribute name="version" select="@version"/>
                                <xsl:value-of select="$descendant-prefix"/>
                            </ep:prefix>
                        </xsl:if>
                    </xsl:for-each>
                </ep:prefixes>
            </xsl:variable>
            <ep:prefixes>
                <xsl:for-each select="$listOfPrefixes//ep:prefix">
                    <xsl:variable name="current-prefix" select="."/>
                    <xsl:if test="not(preceding-sibling::ep:prefix = $current-prefix)">
                        <ep:prefix>
                            <xsl:attribute name="namespaceId" select="@namespaceId"/>
                            <xsl:attribute name="level" select="@level"/>
                            <xsl:attribute name="version" select="@version"/>
                            <xsl:value-of select="$current-prefix"/>
                        </ep:prefix>
                    </xsl:if>
                </xsl:for-each>
            </ep:prefixes>
        </xsl:variable>
        <xsl:variable name="tech-name" select="ep:tech-name"/>
        <xsl:choose>
            <xsl:when test="preceding-sibling::ep:construct[ep:tech-name = $tech-name]"/>
            <xsl:when test="@ismetadata">
                <xsl:copy-of select="."/>
            </xsl:when>
            <!-- Following when's are used to split a construct if it contains subconstructs originated in more than one namespace.
                 The first one if the prefix of the current construct isn't yet determined and the second if it has been determined.
                 The construct is created for every namespace for which a subconstruct is present containing only those subconstruct
                 belonging to that namespace.
                 This type of processing is reported to the subsequent templates by the 'procesType' parameter with the value 'splitting'. -->
            <xsl:when test="(@prefix = '$actualPrefix' and .//ep:construct[ep:tech-name != 'authentiek' and @prefix != $actualPrefix and @prefix != $StUF-prefix]) and (ep:seq/* | ep:choice/*)">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2011',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2011',$debugging)"/>
                
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:attribute name="prefix" select="$actualPrefix"/>
                    <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    <xsl:if test="$debugging">
                        <xsl:copy-of select="$uniquePrefixes"/>
                    </xsl:if>
                    <ep:superconstructRef>
                        <xsl:attribute name="prefix" select="$uniquePrefixes//ep:prefix[xs:integer(@level) = 3]"/>
                        <xsl:sequence select="imf:create-output-element('ep:name', ep:name)"/>
                        <xsl:sequence select="imf:create-output-element('ep:tech-name', ep:tech-name)"/>
                    </ep:superconstructRef>
                    <xsl:choose>
                        <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                            <xsl:apply-templates select="*">
                                <xsl:with-param name="procesType" select="'splitting'"/>
                                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*">
                                <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                <xsl:with-param name="procesType" select="'splitting'"/>
                                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:for-each select="$uniquePrefixes//ep:prefix[. != $actualPrefix]">
                    <xsl:variable name="uniquePrefix" select="."/>
                    <xsl:variable name="uniquePrefixLevel" select="@level"/>
                    <xsl:variable name="uniqueNamespace" select="@namespaceId"/>
                    <xsl:variable name="version" select="@version"/>
                    
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2011a',$debugging)"/>
                    <xsl:sequence select="imf:create-debug-track('Debuglocation 2011a',$debugging)"/>
                    
                    <xsl:element name="{name($construct)}">
                        <xsl:apply-templates select="$construct/@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                        <xsl:attribute name="prefix" select="$uniquePrefix"/>
                        <xsl:attribute name="namespaceId" select="$uniqueNamespace"/>
                        <xsl:attribute name="version" select="$version"/>
                        <xsl:choose>
                            <xsl:when test="$construct/@orderingDesired = 'no' or $construct/ancestor::ep:seq[@orderingDesired = 'no']">
                                <xsl:apply-templates select="$construct/*">
                                    <xsl:with-param name="procesType" select="'splitting'"/>
                                    <xsl:with-param name="actualPrefix" select="$uniquePrefix"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$construct/*">
                                    <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                    <xsl:with-param name="procesType" select="'splitting'"/>
                                    <xsl:with-param name="actualPrefix" select="$uniquePrefix"/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>                  
                </xsl:for-each>                
            </xsl:when>
            <xsl:when test=".//ep:construct[ep:tech-name != 'authentiek' and @prefix != $prefix and @prefix != $StUF-prefix] and (ep:seq/* | ep:choice/*)">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2012',$debugging)"/>
                
                <!--xsl:if test="$debugging">
                    <xsl:copy-of select="$uniquePrefixes"/>
                </xsl:if-->

                <!-- The construct element within the kv-namespace must only be created if there are descendant construct elements which belong to the kv-namespace. -->
                <xsl:if test=".//ep:construct[@prefix = $prefix and not(@ismetadata = 'yes')]">
                    <xsl:element name="{name(.)}">
                        <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                        <xsl:attribute name="prefix" select="$prefix"/>
                        <xsl:attribute name="level">
                            <xsl:choose>
                                <xsl:when test="$uniquePrefixes//ep:prefix[. = $prefix]">
                                    <xsl:value-of select="$uniquePrefixes//ep:prefix[. = $prefix]/@level"/>
                                </xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="version" select="$uniquePrefixes//ep:prefix[. = $prefix]/@version"/>
                        <xsl:attribute name="namespaceId" select="@namespaceId"/>
                        <xsl:if test="$prefix != $uniquePrefixes//ep:prefix[xs:integer(@level) = 3]">
                            <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012a',$debugging)"/>
                            <ep:superconstructRef>
                                <xsl:attribute name="prefix" select="$uniquePrefixes//ep:prefix[xs:integer(@level) = 3]"/>
                                <xsl:sequence select="imf:create-output-element('ep:name', ep:name)"/>
                                <xsl:sequence select="imf:create-output-element('ep:tech-name', ep:tech-name)"/>
                            </ep:superconstructRef>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                                <xsl:apply-templates select="*">
                                    <xsl:with-param name="procesType" select="'splitting'"/>
                                    <xsl:with-param name="actualPrefix" select="$prefix"/>
                                    <xsl:with-param name="prefix4metadataConstructs">
                                        <xsl:value-of select="imf:get-prefix-4-metadataConstructs($construct, $uniquePrefixes, $prefix)"/>
                                    </xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="*">
                                    <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                    <xsl:with-param name="procesType" select="'splitting'"/>
                                    <xsl:with-param name="actualPrefix" select="$prefix"/>
                                    <xsl:with-param name="prefix4metadataConstructs">
                                        <xsl:value-of select="imf:get-prefix-4-metadataConstructs($construct, $uniquePrefixes, $prefix)"/>
                                    </xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:if>
                <xsl:for-each select="$uniquePrefixes//ep:prefix[. != $prefix]">
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012b',$debugging)"/>
                    <xsl:sequence select="imf:create-debug-track('Debuglocation 2012b',$debugging)"/>
                    
                    <xsl:variable name="currentPrefix" select="."/>
                    <xsl:variable name="currentPrefixLevel" select="xs:integer(@level)" as="xs:integer"/>
                    <xsl:variable name="currentNamespace" select="@namespaceId"/>
                    <xsl:variable name="currentVersion" select="@version"/>
                    <xsl:sequence select="imf:create-debug-comment(concat('process uniquePrefix: ',$currentPrefix),$debugging)"/>
                    <!-- The construct element within the namespace related to the current prefix must only be created if there are descendant construct elements 
                         which belong to that namespace. -->
                    <xsl:if test="$construct//ep:construct[@prefix = $currentPrefix and not(@ismetadata = 'yes')]">
                        <xsl:element name="{name($construct)}">
                            <xsl:apply-templates select="$construct/@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                            <xsl:attribute name="prefix" select="$currentPrefix"/>
                            <xsl:attribute name="level" select="$currentPrefixLevel"/>
                            <xsl:attribute name="namespaceId" select="$currentNamespace"/>
                            <xsl:attribute name="version" select="$currentVersion"/>
                            <xsl:sequence select="imf:create-debug-track('Debuglocation 2012c',$debugging)"/>
                            <xsl:if test="$uniquePrefixes//ep:prefix[@level = $currentPrefixLevel + 1]">
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012d',$debugging)"/>
                                <ep:superconstructRef>
                                    <xsl:attribute name="prefix" select="$uniquePrefixes//ep:prefix[xs:integer(@level) = $currentPrefixLevel + 1]"/>
                                    <xsl:sequence select="imf:create-output-element('ep:name', $construct/ep:name)"/>
                                    <xsl:sequence select="imf:create-output-element('ep:tech-name', $construct/ep:tech-name)"/>
                                </ep:superconstructRef>
                            </xsl:if>
                            <xsl:if test="$debugging">
                                <xsl:copy-of select="$uniquePrefixes"/><xsl:text>
                                </xsl:text><xsl:value-of select="$prefix"/><xsl:text>
                                </xsl:text><xsl:value-of select="concat('prefix4metadataConstructs: ',imf:get-prefix-4-metadataConstructs($construct, $uniquePrefixes, $prefix))"/>
                            </xsl:if> 
                            <xsl:choose>
                                <xsl:when test="$construct/@orderingDesired = 'no' or $construct/ancestor::ep:seq[@orderingDesired = 'no']">
                                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012e',$debugging)"/>
                                    <xsl:sequence select="imf:create-debug-track('Debuglocation 2012e',$debugging)"/>
                                    <xsl:apply-templates select="$construct/*">
                                        <xsl:with-param name="procesType" select="'splitting'"/>
                                        <xsl:with-param name="actualPrefix" select="$currentPrefix"/>
                                        <xsl:with-param name="prefix4metadataConstructs">
                                            <xsl:value-of select="imf:get-prefix-4-metadataConstructs($construct, $uniquePrefixes, $prefix)"/>
                                        </xsl:with-param>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012f',$debugging)"/>
                                    <xsl:sequence select="imf:create-debug-track('Debuglocation 2012f',$debugging)"/>
                                    <xsl:apply-templates select="$construct/*">
                                        <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                        <xsl:with-param name="procesType" select="'splitting'"/>
                                        <xsl:with-param name="actualPrefix" select="$currentPrefix"/>
                                        <xsl:with-param name="prefix4metadataConstructs">
                                            <xsl:value-of select="imf:get-prefix-4-metadataConstructs($construct, $uniquePrefixes, $prefix)"/>
                                        </xsl:with-param>
                                    </xsl:apply-templates>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>   
                    </xsl:if>
                </xsl:for-each>                
            </xsl:when>
            <xsl:when test="@prefix = '$actualPrefix' and (ep:seq/* | ep:choice/*)">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2014',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2014',$debugging)"/>
                
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:attribute name="prefix" select="@prefix"/>
                    <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    <xsl:choose>
                        <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                            <xsl:apply-templates select="*">
                                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*">
                                <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>              
            <xsl:when test="ep:seq/* | ep:choice/*">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2013',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2013',$debugging)"/>
                
                <xsl:variable name="currentConstruct"><xsl:copy-of select="."/></xsl:variable>
                <xsl:variable name="lowestLevelPrefixOfPresentConstructs">
                    <ep:prefixes>
                        <xsl:for-each select="$suppliers//supplier">
                            <xsl:if test="count($currentConstruct//ep:construct/@prefix = current()/@verkorteAlias) > 0">
                                <ep:prefix level="{@level}" prefix="{@verkorteAlias}"/>
                            </xsl:if>
                        </xsl:for-each>
                    </ep:prefixes>
                </xsl:variable>
                <xsl:variable name="evaluatedPrefix" select="$lowestLevelPrefixOfPresentConstructs//ep:prefix[last]/@prefix"/>
                <!--xsl:result-document href="file:/c:/temp/currentConstruct.xml">
                    <xsl:sequence select="$currentConstruct"/>
                </xsl:result-document-->
                <xsl:sequence select="imf:create-debug-comment(concat('evaluatedPrefix: ',$evaluatedPrefix),$debugging)"/>
                
                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:attribute name="prefix" select="$prefix"/>
                    <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    <xsl:choose>
                        <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                            <xsl:apply-templates select="*">
                                <xsl:with-param name="actualPrefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*">
                                <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                <xsl:with-param name="actualPrefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>                
            <!-- This construct is only used for metadata constructs. -->
            <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
            <xsl:when test="(ep:seq and not(ep:seq/*)) or (ep:choice and not(ep:choice/*))"/>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2015',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2015',$debugging)"/>
                
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct[ep:tech-name = 'authentiek']">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <xsl:param name="prefix4metadataConstructs"/>

        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2016',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2016',$debugging)"/>
        
        <xsl:variable name="authentiek">
            <xsl:copy-of select="."/>
        </xsl:variable>
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2017',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2017',$debugging)"/>
        
        <!-- If this construct is the only construct with the prefix 'bg' it doesn't have to be replicated. -->
        <xsl:choose>
            <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:tech-name != 'authentiek' and @prefix = 'bg']]">
                <xsl:choose>
                    <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:authentiek != '']]">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2017a',$debugging)"/>
                        <xsl:sequence select="imf:create-debug-track('Debuglocation 2017a',$debugging)"/>
                        
                        <xsl:sequence select="$authentiek"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2017b',$debugging)"/>
                        <xsl:sequence select="imf:create-debug-track('Debuglocation 2017b',$debugging)"/>
                        
                        <xsl:variable name="authentiekValid">
                            <xsl:for-each select="ep:constructRef[starts-with(ep:href,'Grp')]">
                                <xsl:variable name="href" select="ep:href"/>
                                <xsl:if test="//ep:construct[ep:tech-name = $href and .//ep:construct[ep:authentiek and ep:authentiek != '']]">
                                    <xsl:value-of select="'yes'"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:if test="contains($authentiekValid,'yes')">
                            <xsl:sequence select="$authentiek"/>                        
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2017c',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2017c',$debugging)"/>
                <xsl:sequence select="imf:create-debug-comment(ancestor::ep:construct/ep:tech-name,$debugging)"/>             
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    
    <xsl:template match="ep:construct[ep:tech-name = 'inOnderzoek']">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <xsl:param name="prefix4metadataConstructs"/>

        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2023',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2023',$debugging)"/>
        
        <xsl:variable name="inOnderzoek">
            <xsl:copy-of select="."/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="($procesType='splitting' and $prefix4metadataConstructs = $actualPrefix) or $procesType!='splitting'">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2024',$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2024',$debugging)"/>
                <xsl:choose>
                    <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:inOnderzoek = 'Ja']]">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2025',$debugging)"/>
                        <xsl:sequence select="imf:create-debug-track('Debuglocation 2025',$debugging)"/>
                        
                        <xsl:sequence select="$inOnderzoek"/>
                    </xsl:when>
                    <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:inOnderzoek = 'Zie groep']]">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2026',$debugging)"/>
                        <xsl:sequence select="imf:create-debug-track('Debuglocation 2026',$debugging)"/>
                        
                        <xsl:variable name="inOnderzoekValid">
                            <xsl:for-each select="ep:constructRef[starts-with(ep:href,'Grp')]">
                                <xsl:variable name="href" select="ep:href"/>
                                <xsl:if test="//ep:construct[ep:tech-name = $href and .//ep:construct[ep:inOnderzoek and ep:inOnderzoek = 'Ja']]">
                                    <xsl:value-of select="'yes'"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:if test="contains($inOnderzoekValid,'yes')">
                            <xsl:sequence select="$inOnderzoek"/>                        
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:if test="not(local-name()='orderingDesired')">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@prefix">
        <xsl:param name="actualPrefix"/>
        <xsl:param name="prefix4metadataConstructs" select="''"/>
        <xsl:choose>
            <xsl:when test="$prefix4metadataConstructs != ''">
                <!--xsl:attribute name="prefix" select="$prefix4metadataConstructs"/-->
                <xsl:value-of select="$prefix4metadataConstructs"/>
            </xsl:when>
            <xsl:when test="parent::ep:namespace">
                <!--xsl:copy-of select="."/-->
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test=". = '$actualPrefix'">
                 <xsl:variable name="prefix" select="ancestor::ep:construct[parent::ep:message-set]/@prefix"/>
                <!--xsl:attribute name="prefix" select="$prefix"/-->
                <xsl:value-of select="$prefix"/>
            </xsl:when>
            <xsl:when test=". != '$actualPrefix' and . != $actualPrefix">
                <!--xsl:attribute name="prefix" select="$actualPrefix"/-->
                <xsl:value-of select="$actualPrefix"/>
            </xsl:when>
            <xsl:when test=". != '$actualPrefix'">
                <!--xsl:copy-of select="."/-->
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <!--xsl:attribute name="prefix" select="$actualPrefix"/-->
                <xsl:value-of select="$actualPrefix"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@namespaceId">
        <xsl:param name="actualNamespaceId"/>
        <xsl:choose>
            <xsl:when test="parent::ep:namespace">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="namespaceId" select="$actualNamespaceId"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[not(*) and not(name() = 'ep:tv-position') and not(name() = 'ep:namespace')]">
        <xsl:param name="actualPrefix"/>
        <xsl:copy-of select="."/>
        <!--xsl:sequence
            select="imf:create-output-element(name(.), .)"/-->	
    </xsl:template>
    
    <xsl:template match="ep:suppliers">
        <xsl:variable name="suppliers">
            <xsl:copy-of select="."/>
        </xsl:variable>
        <xsl:sequence select="$suppliers"/>
    </xsl:template>
    
    <xsl:template match="ep:namespaces">
        <xsl:param name="actualPrefix"/>
        <ep:namespaces>
            <xsl:apply-templates select="ep:namespace">
                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>                
            </xsl:apply-templates>
            <xsl:if test="//ep:type-name[contains(.,'gml:')]">
                <ep:namespace prefix="gml">http://www.opengis.net/gml</ep:namespace>
            </xsl:if>
        </ep:namespaces>
    </xsl:template>
    
    <xsl:template match="ep:namespace">
        <xsl:param name="actualPrefix"/>
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2030',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2030',$debugging)"/>
        
        <xsl:element name="{name(.)}">
            <xsl:if test="@prefix">
                <xsl:variable name="prefix">
                    <xsl:apply-templates select="@prefix">
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:attribute name="prefix" select="$prefix"/>
            </xsl:if>
            <xsl:apply-templates select="@*[not(name()='prefix')]"/>
            <xsl:value-of select="."/>
        </xsl:element>       
    </xsl:template>
    
    <xsl:template match="ep:construct[(@type = 'simpleContentcomplexData' or @type = 'simpleData') and parent::ep:message-set]">
        
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2040',$debugging)"/>
        <xsl:sequence select="imf:create-debug-track('Debuglocation 2040',$debugging)"/>
        <xsl:variable name="checksum" select="@imvert:checksum"/>
        <xsl:variable name="prefix" select="@prefix"/>
        
        <xsl:if test="not(preceding-sibling::ep:construct[(@type = 'simpleContentcomplexData' or @type = 'simpleData') and @prefix = $prefix and parent::ep:message-set and @imvert:checksum = $checksum])">
            <xsl:copy-of select="."/>
        </xsl:if>
        
    </xsl:template>
    
    <!-- This function returns the namespaceprefix in which the xml-attributes like 'verwerkingssoort' must be defined.
         This should be the namespace which is the nearest to the 'Koppelvlak'-namespace if not the 'Koppelvlak'-namespace
         itself.
         This function must be renamed later so it can be used for elements like 'tijdvakGeldigheid'. -->
    <xsl:function name="imf:get-prefix-4-metadataConstructs" as="xs:string">
        <xsl:param name="construct"/>
        <xsl:param name="uniquePrefixes"/>
        <xsl:param name="currentPrefix"/>
        
        <xsl:sequence select="imf:get-prefix-4-metadataConstructs($construct, $uniquePrefixes, $currentPrefix, 1)"/>
    </xsl:function>
 
    <xsl:function name="imf:get-prefix-4-metadataConstructs" as="xs:string">
        <xsl:param name="construct"/>
        <xsl:param name="uniquePrefixes"/>
        <xsl:param name="currentPrefix"/>
        <xsl:param name="currentPrefixLevel"/>
        
        <xsl:variable name="prefixLevel">
            <xsl:choose>
                <xsl:when test="empty($uniquePrefixes//ep:prefix[. = $currentPrefix])">
                    <xsl:value-of select="$currentPrefixLevel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="xs:integer($uniquePrefixes//ep:prefix[. = $currentPrefix]/@level)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$construct//ep:construct[@prefix = $currentPrefix and not(@ismetadata = 'yes')]">
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2050a',$debugging)"/>
                <xsl:value-of select="$currentPrefix"/>
            </xsl:when>
            <xsl:when test="$uniquePrefixes//ep:prefix[@level = $prefixLevel]">
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2050b',$debugging)"/>
                <xsl:variable name="nextPrefix" select="$uniquePrefixes//ep:prefix[@level = $prefixLevel + 1]"/>
                <xsl:sequence select="imf:get-prefix-4-metadataConstructs($construct, $uniquePrefixes, $nextPrefix, $prefixLevel + 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-track($uniquePrefixes,$debugging)"/>
                <xsl:sequence select="imf:create-debug-track('Debuglocation 2050c',$debugging)"/>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
