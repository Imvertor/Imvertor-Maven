<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 

    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
          Transform KING UML constructs to canonical UML constructs.
          This applies to the UGM.
    -->
    
    <xsl:import href="Imvert2canonical-KING-common.xsl"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- TODO what special canonizations for SIM ? -->
    
    <!-- onderstaande is oude aanpak -->
    
    <?xxxxx
    
    <xsl:variable name="application-package" select="$document-packages[imvert:name/@original = $application-package-name and imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-application-package','stereotype-name-base-package'))][1]"/>
    <xsl:variable name="application-domain-packages" select="$application-package//imvert:package[imvert:stereotype= imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))]"/>
    <xsl:variable name="application-classes" select="$application-domain-packages//imvert:class"/>
    
    <xsl:variable name="all-copy-up-attributes" as="element()*">
        <xsl:for-each select="$application-classes/imvert:attributes/imvert:attribute">
            
            <xsl:variable name="my-class" select="../.."/>
            <xsl:variable name="my-pack" select="$my-class/.."/>
            
            <xsl:variable name="tv-kopieer" select="imf:get-tv-kopieer(.)" as="xs:string*"/>
            <xsl:variable name="target-class-name" select="$tv-kopieer[1]"/>
            <xsl:variable name="attribute-prefix" select="$tv-kopieer[2]"/>
            <xsl:variable name="attribute-name" select="$tv-kopieer[3]"/>
            <xsl:choose>
                <xsl:when test="exists($target-class-name)">
                    <imvert:attribute merge-target="{$target-class-name}">
                        <imvert:merged>
                            <imvert:original-id>
                                <xsl:value-of select="imvert:id"/>
                            </imvert:original-id>
                        </imvert:merged>
                        <imvert:name original="{imvert:name/@original}">
                            <xsl:variable name="prefix" select="if ($attribute-prefix = '*') then '' else concat($attribute-prefix,'_')"/>
                            <xsl:variable name="name" select="if ($attribute-name = '*') then imf:get-normalized-name(imvert:name/@original,'package-name') else $attribute-name"/>
                            <xsl:value-of select="concat($prefix,$name)"/>
                        </imvert:name>
                        <imvert:id>
                            <xsl:value-of select="concat('{MERGED-PROPERTY-',generate-id(.),'}')"/>
                        </imvert:id>
                        <xsl:apply-templates select="*[not(local-name(.) = ('name','id'))]"/>
                    </imvert:attribute>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
    
    <!-- 
        Merge information based on <<merge>> stereotype 
        These templates in mode merger work on the primary canonization, so found names are resolved.
    -->
    
    <xsl:template match="imvert:class[. = $application-classes]">
        <xsl:param name="required-properties"/>
        
        <xsl:variable name="this" select="."/>
        <xsl:variable name="immediate-merged-subclasses" select="root($this)//imvert:class[imvert:supertype/imvert:type-id = $this/imvert:id and imf:is-merged(.)]"/>
        <xsl:variable name="is-merged" select="imf:is-merged($this)"/>
        
        <xsl:choose>
            <xsl:when test="$is-merged and $required-properties = 'attributes'">
                <xsl:apply-templates select="*/imvert:attribute" mode="merger-copy"/>
                <xsl:apply-templates select="$immediate-merged-subclasses">
                    <xsl:with-param name="required-properties">attributes</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            
            <xsl:when test="$is-merged and $required-properties = 'associations'">
                <xsl:apply-templates select="*/imvert:association" mode="merger-copy"/>
                <xsl:apply-templates select="$immediate-merged-subclasses">
                    <xsl:with-param name="required-properties">associations</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            
            <xsl:when test="$is-merged">
                <!-- Merged classes are not part of the schema's. Skip this class. -->
            </xsl:when>
           
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="*[empty(self::imvert:associations) and empty(self::imvert:attributes)]"/>
                    <imvert:attributes>
                        <xsl:apply-templates select="*/imvert:attribute"/>
                        <!-- 
                            Wanneer ergens een attribuut is opgenomen waarvan in een verstuffing tagged value is vastgesteld dat het naar een andere klasse moet worden doorgekopieerd (KOPIEER-NAAR), dan voegen we die attributen hier in. 
                        -->
                        <xsl:sequence select="imf:kopieer-attributen-naar-objecttype($this)"/>
                        <xsl:apply-templates select="$immediate-merged-subclasses">
                            <xsl:with-param name="required-properties">attributes</xsl:with-param>
                        </xsl:apply-templates>
                    </imvert:attributes>
                    <imvert:associations>
                        <xsl:apply-templates select="*/imvert:association"/>
                        <xsl:sequence select="imf:kopieer-associations-naar-objecttype($this)"/>
                        <xsl:apply-templates select="$immediate-merged-subclasses">
                            <xsl:with-param name="required-properties">associations</xsl:with-param>
                        </xsl:apply-templates>
                    </imvert:associations>
                </xsl:copy>
            </xsl:otherwise>
          
        </xsl:choose>
              
    </xsl:template>
    
    <xsl:template match="imvert:attribute | imvert:association" mode="merger-copy">
        <xsl:copy>
            <imvert:merged>
                <imvert:original-id>
                    <xsl:value-of select="imvert:id"/>
                </imvert:original-id>
            </imvert:merged>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:attribute">
        <xsl:sequence select="."/>    
    </xsl:template>
    
    <!-- if association to a merged class, redirect to the merging class. -->
    <xsl:template match="imvert:association">
        <xsl:variable name="target-class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:variable name="merging-class" select="imf:get-merging-class($target-class)"/>
        <xsl:variable name="domain-pack" select="imf:get-domain-package($merging-class)"/>
        <xsl:choose>
            <xsl:when test="imf:is-merged($target-class) and exists($merging-class)">
                <xsl:copy>
                    <imvert:type-name original="{$merging-class/imvert:name/@original}">
                        <xsl:value-of select="$merging-class/imvert:name"/>
                    </imvert:type-name>
                    <imvert:type-id>
                        <xsl:value-of select="$merging-class/imvert:id"/>
                    </imvert:type-id>
                    <imvert:type-package original="{$domain-pack/imvert:name/@original}">
                        <xsl:value-of select="$domain-pack/imvert:name"/>                
                    </imvert:type-package>
                    <xsl:apply-templates select="*[empty((self::imvert:type-name,self::imvert:type-id,self::imvert:type-package))]"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="imf:is-merged($target-class)">
                <xsl:sequence select="imf:msg('ERROR','Merged class must have a non-merged supertype: [1]', $target-class/imvert:name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="merger-copy"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
       identity transform
    -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>  
    
    <!-- Return the class into which this class is merged. Empty when none. -->
    <xsl:function name="imf:get-merging-class">
        <xsl:param name="this" as="element(imvert:class)"/>
        <xsl:sequence select="imf:get-supers($this)[not(imf:is-merged(.))][1]"/>
    </xsl:function>
    
    <xsl:function name="imf:is-merged" as="xs:boolean">
        <xsl:param name="this" as="element(imvert:class)"/>
        <xsl:sequence select="$this/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-merged')"/>   
    </xsl:function>
    
    <!-- Return the domain package for the contruct. -->
    <xsl:function name="imf:get-domain-package">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="$this/ancestor::imvert:package[imvert:stereotype = imf:get-config-stereotypes(('stereotype-name-domain-package','stereotype-name-view-package'))]"/>
    </xsl:function>
    
    <xsl:function name="imf:get-supers">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/imvert:supertype">
            <xsl:variable name="super" select="imf:get-construct-by-id(imvert:type-id)"/>
            <xsl:sequence select="($super,imf:get-supers($super))"/>
        </xsl:for-each> 
    </xsl:function>
    
    <xsl:function name="imf:kopieer-attributen-naar-objecttype">
        <xsl:param name="class"/>
        <xsl:variable name="my-name" select="$class/imvert:name/@original"/>
        <xsl:sequence select="$all-copy-up-attributes[@merge-target = $my-name]"/>
    </xsl:function>
    
    <xsl:function name="imf:kopieer-associations-naar-objecttype">
        <xsl:param name="class"/>
        <!-- TODO -->
    </xsl:function>
    
    <!-- geef de target class naam + nieuwe relatie prefix + relatie naam as als [1..3] 
    
    tv format is  
    KOPIEER-NAAR: SUBJECT aoa huisnummer
    -->
    <xsl:function name="imf:get-tv-kopieer" as="xs:string*">
        <xsl:param name="property"/>
        <xsl:variable name="v" select="imf:get-tv-lines(imf:get-tagged-value($property,'verstuffing'))"/>
        <xsl:for-each select="$v[self::line]">
            <xsl:choose>
                <xsl:when test="starts-with(.,'KOPIEER-NAAR')">
                    <xsl:analyze-string select="." regex="^KOPIEER\-NAAR:\s*(\S*?)\s*(\S*?)\s*(\S*?)\s*$">
                        <xsl:matching-substring>
                            <xsl:sequence select="(regex-group(1),regex-group(2),regex-group(3))"/>  <!-- voorbeeld: ( SUBJECT,  aoa,  huisnummer) -->
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:sequence select="imf:local-error($property,'Geen correct KOPIEER-NAAR opdracht: [1]', .)"/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:local-error($property,'Geen bekende opdracht: [1]', .)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-tv-lines" as="element()*">
        <xsl:param name="tv-value"/>
        
        <!-- herken notitieregels. -->
        <xsl:analyze-string select="concat($tv-value,'[newline]')" regex="(.*?)\[newline\]">
            <xsl:matching-substring>
                <xsl:variable name="line" select="normalize-space(regex-group(1))"/>
                <xsl:choose>
                    <xsl:when test="$line=''">
                        <!-- skip -->
                    </xsl:when>
                    <xsl:when test="starts-with($line,'#')">
                        <note>
                            <xsl:value-of select="normalize-space(substring-after($line,'#'))"/>
                        </note>
                    </xsl:when>
                    <xsl:otherwise>
                        <line>
                            <xsl:value-of select="$line"/>
                        </line>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
        
    </xsl:function>    
    
    <xsl:function name="imf:local-error" as="element(error)?">
        <xsl:param name="this"/>
        <xsl:param name="msg"/>
        <xsl:param name="info"/>
        <xsl:if test="normalize-space($msg)">
            <xsl:sequence select="imf:msg($this,'ERROR',imf:msg-insert-parms($msg,$info),())"/>
            <error>
                <xsl:value-of select="imf:msg-insert-parms(concat('[1] - ', $msg),imf:get-construct-name($this))"/>
            </error>
        </xsl:if>
    </xsl:function>
    
    xxx?>
</xsl:stylesheet>
