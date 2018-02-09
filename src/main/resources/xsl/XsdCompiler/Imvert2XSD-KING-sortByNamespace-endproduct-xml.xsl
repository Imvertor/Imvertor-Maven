<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id:  Imvert2XSD-KING-endproduct-xml.xsl 7487 2016-04-02 07:27:03Z arjan $ 
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
    xmlns:xhtml="http://www.w3.org/1999/xhtml"    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>

    <xsl:import href="Imvert2XSD-KING-common.xsl"/>
      
    <xsl:output indent="yes" method="xml" encoding="UTF-8" exclude-result-prefixes="xhtml"/>
    
    <xsl:variable name="stylesheet-code" as="xs:string">SKS</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>

    <xsl:variable name="stylesheet">Imvert2XSD-KING-ordered-endproduct-xml</xsl:variable>
    <xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-ordered-endproduct-xml.xsl 7487 2016-04-02 07:27:03Z arjan $</xsl:variable> 
    
    <xsl:variable name="StUF-prefix" select="'StUF'"/>
    <xsl:variable name="kv-prefix" select="/ep:message-set/ep:namespace-prefix"/>
    
    <xsl:variable name="message-set">
        <xsl:copy-of select="."/>
    </xsl:variable>
    
    <xsl:variable name="sorted-endproduct">
        <ep:message-sets>
            <xsl:apply-templates select="/ep:message-set"/>
        </ep:message-sets>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:if test="$debugging">
            <xsl:sequence select="imf:msg('INFO','Reordering the endproduct message structure.')"/>
        </xsl:if>		
        
        <xsl:sequence select="imf:pretty-print($sorted-endproduct,false())"/>
        
    </xsl:template>
    
    <xsl:template match="ep:message-set">
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 3002',$debugging)"/>

        <xsl:variable name="namespaces">
            <ep:namespaces>
                <xsl:apply-templates select="ep:namespaces/ep:namespace"/>
                <xsl:for-each select="ep:*[@prefix != $kv-prefix and @namespaceId and @prefix != ''  and @namespaceId != '']">
                    <xsl:variable name="prefix" select="@prefix"/>
                    <xsl:if test="not($prefix = preceding-sibling::*/@prefix)">
                        <ep:namespace prefix="{$prefix}"><xsl:value-of select="@namespaceId"/></ep:namespace>
                    </xsl:if>
                </xsl:for-each>
            </ep:namespaces>
        </xsl:variable>
        <xsl:for-each-group select="ep:*[name() = 'ep:message' or name() = 'ep:construct']" group-by="@prefix">
            <xsl:sequence select="imf:create-debug-comment('Debuglocation 3003',$debugging)"/>

            <xsl:variable name="group" select="current-group()"/>
            <xsl:variable name="groupPrefix" select="current-grouping-key()"/>
            <xsl:variable name="groupNamespaceId" select="($group//ep:*[@prefix = $groupPrefix and normalize-space(@namespaceId)])[1]/@namespaceId"/>
            <xsl:variable name="groupVersion" select=" ($group//ep:*[@prefix = $groupPrefix and normalize-space(@version)])[1]/@version"/>
            <ep:message-set prefix="{$groupPrefix}">
                <xsl:choose>
                    <xsl:when test="$kv-prefix = $groupPrefix">
                        <xsl:attribute name="KV-namespace" select="'yes'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="version" select="$groupVersion"/>                        
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$groupPrefix = $kv-prefix">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 3004',$debugging)"/>

                        <xsl:sequence select="imf:create-debug-comment('Dit is de KV namespace.',$debugging)"/>                
                        <xsl:apply-templates select="../ep:*[name() != 'ep:message' and name() != 'ep:construct' and name() != 'ep:namespaces']">
                        <!--xsl:apply-templates select="../ep:*[name() != 'ep:message' and name() != 'ep:construct']"-->
                            <xsl:with-param name="actualPrefix" select="$groupPrefix"/>
                        </xsl:apply-templates>
                        <xsl:sequence select="$namespaces"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 3005',$debugging)"/>

                        <xsl:sequence select="imf:create-output-element('ep:name', upper-case($groupPrefix))"/>
                        <xsl:sequence select="imf:create-output-element('ep:namespace-prefix', $groupPrefix)"/>                       
                        <xsl:sequence select="imf:create-output-element('ep:namespace', $groupNamespaceId)"/>
                        <ep:namespaces>
                            <xsl:apply-templates select="../ep:namespaces/ep:namespace[@prefix != $kv-prefix]"/>
                            <xsl:for-each select="../ep:*[@prefix and @namespaceId and @prefix != ''  and @namespaceId != '']">
                                <xsl:variable name="prefix" select="@prefix"/>
                                <xsl:if test="not($prefix = preceding-sibling::*/@prefix)">
                                    <ep:namespace prefix="{$prefix}"><xsl:value-of select="@namespaceId"/></ep:namespace>
                                </xsl:if>
                            </xsl:for-each>
                        </ep:namespaces>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3006',$debugging)"/>
                
                <xsl:apply-templates select="current-group()"/>
                
                <xsl:if test="$groupPrefix != $StUF-prefix">
                    <ep:construct prefix="{$groupPrefix}" ismetadata="yes" type='object'>
                        <ep:name>entiteittype</ep:name>
                        <ep:tech-name>entiteittype</ep:tech-name>
                        <ep:data-type>scalar-string</ep:data-type>
                    </ep:construct>
                </xsl:if>
            </ep:message-set>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="ep:suppliers"/>
    
    <xsl:template match="ep:tagged-values"/>

    <xsl:template match="*">
        <xsl:sequence select="imf:create-debug-comment('Debuglocation 3013',$debugging)"/>
        <xsl:copy>
            <xsl:apply-templates select="*|@*[local-name()!='namespaceId' and 
                local-name()!='type' and 
                local-name()!='externalNamespace' and
                local-name()!='context' and
                local-name()!='berichtCode' and
                local-name()!='berichtName' and
                local-name()!='level']|text()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="ep:message-set/ep:construct">
        <xsl:variable name="prefix" select="@prefix"/>
        <xsl:variable name="tech-name" select="ep:tech-name"/>
        <xsl:variable name="type-name" select="concat(@prefix,':',$tech-name)"/>
        <xsl:if test="$debugging and ep:tech-name = 'StatusMetagegeven-basis'">
            <xsl:comment><xsl:value-of select="ep:tech-name"/>-1</xsl:comment>
        </xsl:if>
        
        <xsl:choose>
           <xsl:when test="count(//ep:constructRef[@prefix = $prefix and ep:tech-name = $tech-name]) > 0">
               <xsl:sequence select="imf:create-debug-comment('Debuglocation 3007',$debugging)"/>
               <xsl:copy>
                   <xsl:apply-templates select="@type[.='object']"/> 
                   <xsl:apply-templates select="*|@*[local-name()!='namespaceId' and 
                       local-name()!='type' and 
                       local-name()!='externalNamespace' and
                       local-name()!='context' and
                       local-name()!='berichtCode' and
                       local-name()!='berichtName' and
                       local-name()!='level']|text()"/>
               </xsl:copy>
           </xsl:when>
           <xsl:when test="count(//ep:superconstructRef[@prefix = $prefix and ep:tech-name = $tech-name]) > 0">
               <xsl:sequence select="imf:create-debug-comment('Debuglocation 3008',$debugging)"/>
               <xsl:copy>
                   <xsl:apply-templates select="@type[.='object']"/> 
                   <xsl:apply-templates select="*|@*[local-name()!='namespaceId' and 
                       local-name()!='type' and 
                       local-name()!='externalNamespace' and
                       local-name()!='context' and
                       local-name()!='berichtCode' and
                       local-name()!='berichtName' and
                       local-name()!='level']|text()"/>
               </xsl:copy>
           </xsl:when>
            <!--xsl:when test="@isdatatype = 'yes' and count(//ep:construct[ep:type-name = concat(@prefix,':',$tech-name)]) > 0"-->
            <xsl:when test="@isdatatype = 'yes' and count(//ep:construct[ep:type-name = $type-name]) > 0">
               <?x !-- ROME: Ik heb geen idee meer waarom de volgende variabelen en de daaropvolgende choose nodig is.
                    Je zou immers zeggen dat de bovenstaande test al voldoende checkt of replicatie van de construct nodig is. 
                    Nakijken en als er geen reden voor is deze code eenvoudiger maken. Als er wel een reden voor is documenteren. -->
               
               <!-- ROME: Voor de onderstaande variabele heb ik helaas een omslachtige methode moet gebruiken omdat
                    <xsl:variable name="construct" select="//ep:construct[ep:type-name = concat(@prefix,':',$tech-name)][1]">
                    niet werkte. Daarbij werd de variabele 'tech-nameReferingConstruct' niet goed gevuld.
                    De reden daarvoor was mij echter een raadsel. -->
               <xsl:variable name="construct">
                   <ep:construct prefix="{(//ep:construct[ep:type-name = $type-name])[1]/@prefix}">
                       <ep:tech-name><xsl:value-of select="(//ep:construct[ep:type-name = $type-name])[1]/ep:tech-name"/></ep:tech-name>
                       <!--xsl:sequence  select="//ep:construct[ep:type-name = concat(@prefix,':',$tech-name)][1]"/-->
                   </ep:construct>
               </xsl:variable>
               <!--xsl:variable name="prefixReferingConstruct" select="$construct//ep:construct[not(ancestor::ep:seq)]/@prefix"/>
               <xsl:variable name="tech-nameReferingConstruct" select="$construct//ep:construct[not(ancestor::ep:seq)]/ep:tech-name"/-->
               <xsl:variable name="prefixReferingConstruct" select="$construct//ep:construct/@prefix"/>
               <xsl:variable name="tech-nameReferingConstruct" select="$construct//ep:construct/ep:tech-name"/>
                <xsl:variable name="type-nameReferingConstruct" select="concat(@prefix,':',$tech-name)"/>
                <xsl:if test="$debugging and ep:tech-name = 'Wildcard'">
                    <ep:test>Wildcard: prefix: <xsl:value-of select="$prefix"/>, type-name: <xsl:value-of select="$type-name"/>, prefixReferingConstruct: <xsl:value-of select="prefixReferingConstruct"/>, tech-nameReferingConstruct: <xsl:value-of select="$tech-nameReferingConstruct"/>, type-nameReferingConstruct: <xsl:value-of select="$type-nameReferingConstruct"/>
                    </ep:test>
                </xsl:if>
                
                <xsl:choose>
                   <xsl:when test="count(//ep:construct[@prefix = $prefixReferingConstruct and ep:tech-name = $tech-nameReferingConstruct]) > 0">
                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 3009',$debugging)"/ x?>
                       <xsl:copy>
                           <xsl:apply-templates select="@type[.='object']"/> 
                           <xsl:apply-templates select="*|@*[local-name()!='namespaceId' and 
                               local-name()!='type' and 
                               local-name()!='externalNamespace' and
                               local-name()!='context' and
                               local-name()!='berichtCode' and
                               local-name()!='berichtName' and
                               local-name()!='level']|text()"/>
                       </xsl:copy>
                   <?x /xsl:when>
                    <xsl:when test="count(//ep:construct[ep:type-name = $type-nameReferingConstruct]) > 0">
                       <xsl:sequence select="imf:create-debug-comment('Debuglocation 3010',$debugging)"/>
                       <xsl:copy>
                           <xsl:apply-templates select="*|@*[local-name()!='namespaceId' and 
                               local-name()!='type' and 
                               local-name()!='externalNamespace' and
                               local-name()!='context' and
                               local-name()!='berichtCode' and
                               local-name()!='berichtName' and
                               local-name()!='level']|text()"/>
                       </xsl:copy>
                   </xsl:when>
               </xsl:choose x?>
           </xsl:when>
           <xsl:when test="count(//ep:construct[ep:type-name = concat($prefix,':',$tech-name) or (ep:type-name = $tech-name)]) > 0">
               <xsl:sequence select="imf:create-debug-comment('Debuglocation 3011',$debugging)"/>
               <xsl:copy>
                   <xsl:apply-templates select="@type[.='object']"/> 
                   <xsl:apply-templates select="*|@*[local-name()!='namespaceId' and 
                       local-name()!='type' and 
                       local-name()!='externalNamespace' and
                       local-name()!='context' and
                       local-name()!='berichtCode' and
                       local-name()!='berichtName' and
                       local-name()!='level']|text()"/>
               </xsl:copy>
           </xsl:when>
       </xsl:choose> 
    </xsl:template>
    
    <xsl:template match="ep:type-name">
        <xsl:variable name="type-name" select="."/>
        <xsl:choose>
            <xsl:when test="contains($type-name,':')">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3013a',$debugging)"/>
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="../@prefix = $StUF-prefix">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3012b',$debugging)"/>             
                <ep:type-name><xsl:value-of select="concat($StUF-prefix,':',.)"/></ep:type-name>
                <!--xsl:copy-of select="."/-->
            </xsl:when>
            <xsl:when test="/ep:message-set/ep:construct[ep:tech-name = $type-name and not(@level)]">
                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3012c',$debugging)"/>             
                <ep:type-name><xsl:value-of select="concat(../@prefix,':',.)"/></ep:type-name>
                <!--xsl:copy-of select="."/-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="lowestLevelPrefix">
                    <xsl:value-of select="imf:get-LowestLevelPrefix(.,2)"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$lowestLevelPrefix = 'noConstruct'">
                        <xsl:sequence select="imf:create-debug-comment('Debuglocation 3012d',$debugging)"/>             
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="ancestorPrefix" select="string(ancestor::ep:construct[parent::ep:message-set]/@prefix)"/>
                        <xsl:variable name="suppliersParentConstruct" select="ancestor::ep:construct[parent::ep:message-set]/ep:suppliers"/>

                        <xsl:sequence select="imf:create-debug-comment($ancestorPrefix,$debugging)"/>
                        
                        <!-- Following choose is necessary to prevent situations where a type-name refers to a namespace which is lower in the hierarchy. --> 
                        <xsl:choose>
                            <xsl:when test="ancestor::ep:message">
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3012e',$debugging)"/>
                                <ep:type-name><xsl:value-of select="concat($lowestLevelPrefix,':',.)"/></ep:type-name>                                
                            </xsl:when>
                            <xsl:when test="$suppliersParentConstruct//supplier[@verkorteAlias = $lowestLevelPrefix]/@level > $suppliersParentConstruct//supplier[@verkorteAlias = $ancestorPrefix]/@level">
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3012f',$debugging)"/>
                                <ep:type-name><xsl:value-of select="concat($lowestLevelPrefix,':',.)"/></ep:type-name>                                
                            </xsl:when>
                            <xsl:when test="$suppliersParentConstruct//supplier[@verkorteAlias = $lowestLevelPrefix]/@level = $suppliersParentConstruct//supplier[@verkorteAlias = $ancestorPrefix]/@level">
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3012g',$debugging)"/>
                                <ep:type-name><xsl:value-of select="concat($lowestLevelPrefix,':',.)"/></ep:type-name>                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="imf:create-debug-comment('Debuglocation 3012h',$debugging)"/>
                                <ep:type-name><xsl:value-of select="concat($ancestorPrefix,':',.)"/></ep:type-name>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="imf:get-LowestLevelPrefix" as="xs:string">
        <xsl:param name="type-name"/>
        <xsl:param name="level" as="xs:integer"/>
        
        <xsl:sequence select="imf:create-debug-track(concat('Type-name: ',$type-name,', Level: ',$level),$debugging)"/>
        
        <xsl:choose>
            <xsl:when test="not($message-set/ep:message-set/ep:construct[ep:tech-name = $type-name]) and 
                            not($message-set/ep:message-set/ep:construct[ep:tech-name = substring-after($type-name,':')])">
                <xsl:sequence select="imf:create-debug-track('get-LowestLevelPrefix-1',$debugging)"/>
                <xsl:value-of select="'noConstruct'"/>
            </xsl:when>
            <xsl:when test="count($message-set/ep:message-set/ep:construct[ep:tech-name = $type-name]) = 1">
                <xsl:sequence select="imf:create-debug-track('get-LowestLevelPrefix-2',$debugging)"/>
                <xsl:value-of select="$message-set/ep:message-set/ep:construct[ep:tech-name = $type-name]/@prefix"/>
            </xsl:when>
            <xsl:when test="count($message-set/ep:message-set/ep:construct[ep:tech-name = substring-after($type-name,':')]) = 1">
                <xsl:sequence select="imf:create-debug-track('get-LowestLevelPrefix-3',$debugging)"/>
                <xsl:value-of select="$message-set/ep:message-set/ep:construct[ep:tech-name = substring-after($type-name,':')]/@prefix"/>
            </xsl:when>
            <xsl:when test="$message-set/ep:message-set/ep:construct[ep:tech-name = $type-name and xs:integer(@level) = $level]">
                <xsl:sequence select="imf:create-debug-track('get-LowestLevelPrefix-4',$debugging)"/>
                <xsl:value-of select="$message-set/ep:message-set/ep:construct[ep:tech-name = $type-name and xs:integer(@level) = $level]/@prefix"/>
            </xsl:when>
            <xsl:when test="$message-set/ep:message-set/ep:construct[ep:tech-name = substring-after($type-name,':') and xs:integer(@level) = $level]">
                <xsl:sequence select="imf:create-debug-track('get-LowestLevelPrefix-5',$debugging)"/>
                <xsl:value-of select="$message-set/ep:message-set/ep:construct[ep:tech-name = substring-after($type-name,':') and xs:integer(@level) = $level]/@prefix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:create-debug-track('get-LowestLevelPrefix-6',$debugging)"/>
                <xsl:value-of select="imf:get-LowestLevelPrefix($type-name,$level + 1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
