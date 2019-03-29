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
         Canonization of the input, common to all metamodels.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/extension/extension-parse-wiki.xsl"/>
    
    <xsl:variable name="chop" select="imf:boolean(imf:get-config-string('cli','chop','no'))"/>
    
    <xsl:template match="/imvert:packages">
        <xsl:variable name="step1">
            <imvert:packages>
                <xsl:sequence select="imf:compile-imvert-header(.)"/>
                <xsl:apply-templates select="imvert:package"/>
            </imvert:packages>
        </xsl:variable>
        <xsl:variable name="step2">
            <xsl:apply-templates select="$step1" mode="mode-tv"/>
        </xsl:variable>
        <xsl:sequence select="$step2"/>
    </xsl:template>
    
    <!-- assign the <<group>> stereo to all subpacks without stereo -->
    <xsl:template match="imvert:package[empty(imvert:stereotype)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <imvert:stereotype id="stereotype-name-folder-package" origin="system">
                <xsl:value-of select="imf:get-config-name-by-id('stereotype-name-folder-package')"/>
            </imvert:stereotype>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- generate the correct name here -->
    <xsl:template match="imvert:found-name">
        <xsl:variable name="type" select="
            if (parent::imvert:package) then 'package-name' else 
            if (parent::imvert:attribute) then 'property-name' else
            if (parent::imvert:association) then 'property-name' else 'class-name'"/>
        <imvert:name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,$type)"/>
        </imvert:name>
    </xsl:template>
    
    <xsl:template match="imvert:role">
        <imvert:role original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'property-name')"/>
        </imvert:role>
    </xsl:template>

    <xsl:template match="imvert:supplier-packagename">
        <imvert:supplier-package-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:supplier-package-name>
    </xsl:template>
    
    <!-- generate the correct name for types specified, but only when the type is declared as a class (i.e. no system types) -->
    <xsl:template match="imvert:*[imvert:type-id]/imvert:type-name">
        <imvert:type-name original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'class-name')"/>
        </imvert:type-name>
    </xsl:template>
    
    <!-- generate the correct name for packages of types specified -->
    <xsl:template match="imvert:type-package">
        <imvert:type-package original="{.}">
            <xsl:value-of select="imf:get-normalized-name(.,'package-name')"/>
        </imvert:type-package>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation = 'datatype' and empty(imvert:stereotype)]">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <imvert:stereotype origin="system" id="stereotype-name-simpletype">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-simpletype')[1]"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation = 'enumeration' and imvert:stereotype/@id = ('stereotype-name-codelist')]/imvert:stereotype[@id = ('stereotype-name-enumeration')]">
        <!-- remove this stereotype: <<enumeration>> is implied by <<codelist>> -->
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:supertype">
        <xsl:choose>
            <xsl:when test="exists(imvert:type-id) and empty(imf:get-construct-by-id(imvert:type-id)) and $chop">
                <xsl:comment select="concat('Chopped supertype: ', imvert:type-name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:designation = 'enumeration']/imvert:attributes/imvert:attribute">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <xsl:if test="not(imvert:stereotype/@id = 'stereotype-name-enum')">
                <imvert:stereotype origin="system" id="stereotype-name-enum">
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-enum')"/>
                </imvert:stereotype>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:designation = 'enumeration']">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <xsl:if test="not(imvert:stereotype/@id = 'stereotype-name-enumeration')">
                <imvert:stereotype origin="system" id="stereotype-name-enumeration">
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-enumeration')"/>
                </imvert:stereotype>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:association">
        <xsl:choose>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-trace')">
                <!-- remove explicit trace relations; traces are recorded as imvert:trace (client to supplier) -->
            </xsl:when>
            <xsl:when test="exists(imvert:type-id) and empty(imf:get-construct-by-id(imvert:type-id)) and $chop">
                <xsl:comment select="concat('Chopped association: ', imvert:name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:attribute">
        <xsl:choose>
            <xsl:when test="exists(imvert:type-id) and empty(imf:get-construct-by-id(imvert:type-id)) and $chop">
                <xsl:comment select="concat('Chopped attribute: ', imvert:name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        when composition to gegevensgroeptype, and no name, 
        generate name of the target class on that composition relation,
        and when no stereotype, put the composition stereotype there 
    -->
    <!-- TODO https://github.com/Imvertor/Imvertor-Maven/issues/47 -->
    <xsl:template match="imvert:association[imvert:aggregation='composite']">
        <xsl:variable name="defining-class" select="imf:get-construct-by-id(imvert:type-id)"/>
        <xsl:choose>
            <xsl:when test="$defining-class/imvert:stereotype/@id = ('stereotype-name-composite','stereotype-name-grp-proxy')">
                <imvert:association>
                    <xsl:choose>
                        <xsl:when test="empty(imvert:found-name)">
                            <imvert:name original="{imvert:type-name}" origin="system">
                                <xsl:value-of select="imf:get-normalized-name(imvert:type-name,'property-name')"/>
                            </imvert:name>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="imvert:found-name"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="empty(imvert:stereotype)">
                            <imvert:stereotype id="stereotype-name-association-to-composite" origin="system">
                                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-association-to-composite')"/>
                            </imvert:stereotype>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="imvert:stereotype"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[not(self::imvert:stereotype or self::imvert:found-name)]"/>
                </imvert:association>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        IM-445
        remove references to a type ID when no type name could be determined 
        This happens when references occur to parts of the EA that are not in scope
    -->
    <xsl:template match="imvert:type-id[empty(../imvert:type-name)]">
        <imvert:type-id>OUT-OF-SCOPE</imvert:type-id>
        <imvert:type-name>OUT-OF-SCOPE</imvert:type-name>
    </xsl:template>
    
    <!-- 
        IM-457
        Replace the position by the taggd value "position" when supplied; otherwise leave unchanged.
    -->
    <xsl:template match="imvert:position">
        <imvert:position>
            <xsl:variable name="tv-pos" select="imf:get-tagged-value(..,'##CFG-TV-POSITION')"/>
            <xsl:value-of select="if (exists($tv-pos)) then $tv-pos else ."/>
        </imvert:position>
    </xsl:template>
    
    <!-- add an @original attibute to maintain original value before canonization -->
    <xsl:template match="imvert:phase">
        <xsl:copy>
            <xsl:attribute name="original" select="."/>
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        transform INSPIRE like structured notes fields to tagged values 
    -->
    <xsl:template match="imvert:tagged-values" mode="mode-tv">
        <xsl:copy>
            <!-- first copy all existing; only when a value is specified  -->
            <xsl:apply-templates select="imvert:tagged-value[normalize-space(imvert:value)]"/>
            
            <!-- then add the tvs extracted from notes -->
            <xsl:variable name="construct" select=".."/> 
            <!-- construct may be a class, attribute, package, ... but also a source or target (within association) -->
            <xsl:for-each select="$construct[exists(imvert:stereotype)]/imvert:documentation/section"> <!-- only for constructs with stereotyes; no rules are defined for other constructs -->
                <xsl:variable name="title" select="title"/>
                <xsl:variable name="norm-title" select="upper-case($title)"/>
                <xsl:variable name="body" select="body"/>
                
                <xsl:variable name="target-tv" select="$configuration-notesrules-file/notes-rule[@lang=$language]/section[upper-case(@title) = $norm-title]"/>
                <xsl:variable name="target-tv-id" select="$target-tv/@tagged-value"/>
                <xsl:variable name="target-tv-process" select="$target-tv/@process"/>
                
                <xsl:variable name="current-tv" select="imf:get-tagged-value-by-id($construct,$target-tv-id)/imvert:value"/> <!-- the current tagged value if any -->
                
                <xsl:choose>
                    <xsl:when test="not(normalize-space($title))">
                        <xsl:sequence select="imf:msg($construct,'WARNING','Notes field has invalid format',())"/>
                    </xsl:when>
                    <xsl:when test="empty($target-tv-id)">
                        <xsl:sequence select="imf:msg($construct,'WARNING','Notes field [1] not recognized, and skipped',$title)"/>
                    </xsl:when>
                    <xsl:when test="normalize-space($body) and normalize-space($current-tv)">
                        <xsl:sequence select="imf:msg($construct,'WARNING','Tagged value [1] in notes field [2] already specified',($norm-title,$title))"/>
                    </xsl:when>
                    <xsl:when test="normalize-space($body)">
                        <xsl:variable name="lines" as="xs:string*">
                            <xsl:for-each select="$body/*/*">
                                <xsl:value-of select="imf:strip-ea-html(.)"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="b" as="xs:string*">
                            <xsl:choose>
                                <xsl:when test="$target-tv-process = 'lines'"> <!-- when the body of the section possibly identifies several tagged values, e.g. Concept -->
                                    <xsl:sequence select="$lines"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="string-join($lines,'&#10;')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:for-each select="$b">
                            <imvert:tagged-value origin="notes" id="{$target-tv-id}">
                                <imvert:name original="{$title}"><!-- Natural name -->
                                    <xsl:value-of select="$norm-title"/> 
                                </imvert:name>
                                <xsl:variable name="value-normalization" select="imf:get-config-tagged-values()[@id = $target-tv-id]/@norm"/>
                                <xsl:variable name="value-format" select="lower-case($configuration-notesrules-file//notes-format)"/>
                                <imvert:value>
                                    <xsl:choose>
                                        <xsl:when test="$value-normalization = 'note' and $value-format = 'plain'">
                                            <xsl:attribute name="format" select="$value-format"/>
                                            <xsl:value-of select="."/>
                                        </xsl:when>
                                        <xsl:when test="$value-normalization = 'note'">
                                            <xsl:attribute name="format" select="$value-format"/>
                                            <xsl:sequence select="imf:parse-wiki(.,$value-format)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="format">unknown</xsl:attribute>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </imvert:value>
                            </imvert:tagged-value>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- none -->
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="#default mode-tv">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
   
    <!-- === functions === -->
    
    <xsl:function name="imf:strip-ea-html">
        <xsl:param name="text"/>
        <xsl:value-of select="imf:replace-inet-references($text)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-by-id" as="element(imvert:tagged-value)*">
        <xsl:param name="construct"/>
        <xsl:param name="tv-id"/>
        <xsl:sequence select="$construct/imvert:tagged-values/imvert:tagged-value[@id = $tv-id]"/>
    </xsl:function>
    
</xsl:stylesheet>
