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
    
    <xsl:template match="/">      
        <xsl:apply-templates select="ep:message-set"/>
   </xsl:template>
    
    <xsl:template match="ep:message-set">
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
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2000',$debugging)"/>

        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
            </xsl:apply-templates>
            <xsl:choose>
                <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2001',$debugging)"/>
                    
                    <xsl:sequence select="imf:create-debug-comment(concat('procesType: ',$procesType),$debugging)"/>                
                    <xsl:apply-templates select="*">
                        <xsl:with-param name="procesType" select="$procesType"/>
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2002',$debugging)"/>
                    
                    <xsl:sequence select="imf:create-debug-comment(concat('procesType: ',$procesType),$debugging)"/>                
                    <xsl:apply-templates select="*">
                        <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                        <xsl:with-param name="procesType" select="$procesType"/>
                        <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
                    </xsl:apply-templates>              
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <!-- The following template takes care of replicating the 'ep:constructRef' element removing the 'ep:id' element. -->
    <xsl:template match="ep:constructRef">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2003',$debugging)"/>

        <xsl:choose>
            <xsl:when test="@ismetadata='yes' and (($procesType='splitting' and $kv-prefix = $actualPrefix) or $procesType!='splitting')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2004',$debugging)"/>
                
                <!-- ROME: Op de eoa wijze krijgt de parameter 'actualPrefix' van dit template niet de correcte waarde mee.
                           Vandaar dat ik hieronder een nieuwe variabele aanmaak. -->
                <xsl:variable name="actualPrefix2" select="ancestor::ep:construct[parent::ep:message-set]/@prefix"/>
 
                <ep:constructRef>
                    <xsl:apply-templates select="@prefix">
                        <xsl:with-param name="actualPrefix" select="$actualPrefix2"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates select="*|@*[not(name()='prefix')]"/>
                </ep:constructRef>
            </xsl:when>
            <xsl:when test="not(@ismetadata='yes') and $procesType='splitting' and (@prefix = $actualPrefix or @prefix = '$actualPrefix')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2005',$debugging)"/>

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
            <xsl:when test="not(@ismetadata='yes') and (($procesType='splitting' and ($kv-prefix = $actualPrefix and (@prefix = $StUF-prefix  or not(@prefix)))) or $procesType != 'splitting')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2006',$debugging)"/>

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
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2007',$debugging)"/>

        <xsl:choose>
            <xsl:when test="@ismetadata='yes' and (($procesType='splitting' and $kv-prefix = $actualPrefix) or $procesType!='splitting')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2008',$debugging)"/>

                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="not(@ismetadata='yes') and (($procesType='splitting' and @prefix = $actualPrefix) or $procesType!='splitting')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2009',$debugging)"/>

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
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct[parent::ep:message-set]">
        <xsl:param name="actualPrefix"/>

        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2010',$debugging)"/>

        <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
        <xsl:variable name="construct" select="."/>
        <xsl:variable name="prefix" select="@prefix"/>
        <xsl:variable name="uniquePrefixes" as="element(ep:prefixes)">
           <xsl:variable name="listOfPrefixes">
                <ep:prefixes>
                    <xsl:for-each select=".//ep:suppliers/supplier">
                        <xsl:variable name="descendant-prefix" select="@verkorteAlias" as="attribute(verkorteAlias)"/>
                        <xsl:if test="not(preceding-sibling::supplier[@prefix = $descendant-prefix])">
                            <ep:prefix>
                                <xsl:attribute name="namespaceId" select="@base-namespace"/>
                                <xsl:attribute name="level" select="@level"/>
                                <xsl:value-of select="$descendant-prefix"/>
                            </ep:prefix>
                        </xsl:if>
                    </xsl:for-each>
                </ep:prefixes>
            </xsl:variable>
            <ep:prefixes>
                <ep:test/>
                <xsl:for-each select="$listOfPrefixes//ep:prefix">
                    <xsl:variable name="current-prefix" select="."/>
                    <xsl:if test="not(preceding-sibling::ep:prefix = $current-prefix)">
                        <ep:prefix>
                            <xsl:attribute name="namespaceId" select="@namespaceId"/>
                            <xsl:attribute name="level" select="@level"/>
                            <xsl:value-of select="$current-prefix"/>
                        </ep:prefix>
                    </xsl:if>
                </xsl:for-each>
            </ep:prefixes>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@ismetadata">
                <xsl:copy-of select="."/>
            </xsl:when>
            <!-- Following when's are used to split a construct if it contains subconstructs originated in more than one namespace.
                 The first one if the prefix of the current construct isn't yet determined and the second if it has been determined.
                 The construct is created for every namespace for which a subconstruct is present containing only those subconstruct
                 belonging to that namespace.
                 This type of processing is reported to the subsequent templates by the 'procesType' parameter with the value 'splitting'. -->
            <xsl:when test="(@prefix = '$actualPrefix' and .//ep:construct/@prefix != $actualPrefix and .//ep:construct/@prefix != $StUF-prefix) and (ep:seq/* | ep:choice/*)">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2011',$debugging)"/>

                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:attribute name="prefix" select="$actualPrefix"/>
                    <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    <xsl:if test="$debugging">
                        <xsl:copy-of select="$uniquePrefixes"/>
                    </xsl:if>
                    <ep:superconstructRef>
                        <xsl:attribute name="prefix" select="$uniquePrefixes//ep:prefix[xs:integer(@level) = 3]"/>
                        <xsl:sequence select="imf:create-output-element('ep:name', ep:tech-name)"/>
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

                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2011a',$debugging)"/>
                    
                    <xsl:element name="{name($construct)}">
                        <xsl:apply-templates select="$construct/@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                        <xsl:attribute name="prefix" select="$uniquePrefix"/>
                        <xsl:attribute name="namespaceId" select="$uniqueNamespace"/>
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
            <xsl:when test=".//ep:construct/@prefix != $prefix and .//ep:construct/@prefix != $StUF-prefix and (ep:seq/* | ep:choice/*)">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012',$debugging)"/>

                <xsl:element name="{name(.)}">
                    <xsl:apply-templates select="@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                    <xsl:attribute name="prefix" select="$prefix"/>
                    <xsl:attribute name="namespaceId" select="@namespaceId"/>
                    <xsl:if test="$debugging">
                        <xsl:copy-of select="$uniquePrefixes"/>
                    </xsl:if>
                    <ep:superconstructRef>
                        <xsl:attribute name="prefix" select="$uniquePrefixes//ep:prefix[xs:integer(@level) = 3]"/>
                        <xsl:sequence select="imf:create-output-element('ep:name', ep:tech-name)"/>
                        <xsl:sequence select="imf:create-output-element('ep:tech-name', ep:tech-name)"/>
                    </ep:superconstructRef>
                    <xsl:choose>
                        <xsl:when test="@orderingDesired = 'no' or ancestor::ep:seq[@orderingDesired = 'no']">
                            <xsl:apply-templates select="*">
                                <xsl:with-param name="procesType" select="'splitting'"/>
                                <xsl:with-param name="actualPrefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*">
                                <xsl:sort select="ep:position" order="ascending" data-type="number"/>
                                <xsl:with-param name="procesType" select="'splitting'"/>
                                <xsl:with-param name="actualPrefix" select="$prefix"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <xsl:for-each select="$uniquePrefixes//ep:prefix[. != $prefix]">
                    <xsl:sequence select="imf:create-debug-comment('Debuglocation 2012a',$debugging)"/>

                    <xsl:variable name="uniquePrefix" select="."/>
                    <xsl:variable name="uniquePrefixLevel" select="@level"/>
                    <xsl:variable name="uniqueNamespace" select="@namespaceId"/>
                    <xsl:sequence select="imf:create-debug-comment(concat('process uniquePrefix: ',$uniquePrefix),$debugging)"/>
                    <xsl:element name="{name($construct)}">
                        <xsl:apply-templates select="$construct/@*[local-name()!='prefix' and local-name()!='namespaceId']"/>
                        <xsl:attribute name="prefix" select="$uniquePrefix"/>
                        <xsl:attribute name="namespaceId" select="$uniqueNamespace"/>
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
            <!-- Following when is used if the current construct doesn't contains subconstructs originated in more than one namespace. -->           
            <xsl:when test="ep:seq/* | ep:choice/*">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2013',$debugging)"/>

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
            <xsl:when test="@prefix = '$actualPrefix' and ep:seq/* | ep:choice/*">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2014',$debugging)"/>

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
            <!-- This construct is only used for metadata constructs. -->
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2015',$debugging)"/>

                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct[ep:tech-name = 'authentiek']">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2016',$debugging)"/>

        <xsl:variable name="authentiek">
            <xsl:copy-of select="."/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$procesType='splitting' and $kv-prefix = $actualPrefix">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2017',$debugging)"/>

                <xsl:choose>
                    <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:authentiek and ep:authentiek != '']]">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2018',$debugging)"/>

                        <xsl:sequence select="$authentiek"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2019',$debugging)"/>

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
            <xsl:when test="$procesType!='splitting'">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2020',$debugging)"/>
                <xsl:choose>
                    <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:authentiek and ep:authentiek != '']]">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2021',$debugging)"/>

                        <xsl:sequence select="$authentiek"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2022',$debugging)"/>

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
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ep:construct[ep:tech-name = 'inOnderzoek']">
        <xsl:param name="procesType" select="''"/>
        <xsl:param name="actualPrefix"/>
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2023',$debugging)"/>

        <!-- Following if takes care of removing al ep:constructs whithout content within their ep:seq or ep:choice element. -->
        <xsl:variable name="inOnderzoek">
            <xsl:copy-of select="."/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$procesType='splitting' and $kv-prefix = $actualPrefix">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2024',$debugging)"/>

                <xsl:choose>
                    <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:inOnderzoek and ep:inOnderzoek != '']]">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2025',$debugging)"/>

                        <xsl:sequence select="$inOnderzoek"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2026',$debugging)"/>

                        <xsl:variable name="inOnderzoekValid">
                            <xsl:for-each select="ep:constructRef[starts-with(ep:href,'Grp')]">
                                <xsl:variable name="href" select="ep:href"/>
                                <xsl:if test="//ep:construct[ep:tech-name = $href and .//ep:construct[ep:inOnderzoek and ep:inOnderzoek != '']]">
                                    <xsl:value-of select="'yes'"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:if test="contains($inOnderzoekValid,'yes')">
                            <xsl:sequence select="$inOnderzoek"/>                        
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$procesType!='splitting'">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 2027',$debugging)"/>

                <xsl:choose>
                    <xsl:when test="ancestor::ep:construct[.//ep:construct[ep:inOnderzoek and ep:inOnderzoek != '']]">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2028',$debugging)"/>

                        <xsl:sequence select="$inOnderzoek"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2029',$debugging)"/>

                        <xsl:variable name="inOnderzoekValid">
                            <xsl:for-each select="ep:constructRef[starts-with(ep:href,'Grp')]">
                                <xsl:variable name="href" select="ep:href"/>
                                <xsl:if test="//ep:construct[ep:tech-name = $href and .//ep:construct[ep:inOnderzoek and ep:inOnderzoek != '']]">
                                    <xsl:value-of select="'yes'"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:if test="contains($inOnderzoekValid,'yes')">
                            <xsl:sequence select="$inOnderzoek"/>                        
                        </xsl:if>
                    </xsl:otherwise>
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
        <xsl:choose>
            <xsl:when test="parent::ep:namespace">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test=". = '$actualPrefix'">
                <!--xsl:attribute name="prefix" select="$actualPrefix"/-->
                <xsl:variable name="prefix" select="ancestor::ep:construct[parent::ep:message-set]/@prefix"/>
                <xsl:attribute name="prefix" select="$prefix"/>
            </xsl:when>
            <xsl:when test=". != '$actualPrefix' and . != $actualPrefix">
                <xsl:attribute name="prefix" select="$actualPrefix"/>
            </xsl:when>
            <xsl:when test=". != '$actualPrefix'">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="prefix" select="$actualPrefix"/>
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
        <xsl:sequence
            select="imf:create-output-element(name(.), .)"/>	
    </xsl:template>
    
    <xsl:template match="ep:namespace">
        <xsl:param name="actualPrefix"/>
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 2030',$debugging)"/>
 
        <xsl:element name="{name(.)}">
            <xsl:apply-templates select="@*">
                <xsl:with-param name="actualPrefix" select="$actualPrefix"/>
            </xsl:apply-templates>
            <xsl:value-of select="."/>
        </xsl:element>       
    </xsl:template>
    
</xsl:stylesheet>
