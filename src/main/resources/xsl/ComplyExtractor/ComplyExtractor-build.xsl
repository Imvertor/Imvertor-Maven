<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 VNG/KING
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
  
    xmlns:ws="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/zip-content-wrapper"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-entity.xsl"/>
    <xsl:import href="../common/Imvert-common-compact.xsl"/>

    <xsl:variable name="testset" select="/testset"/>
    
    <xsl:variable name="all-test-values" select="$testset/variables/variable"/>
    <xsl:variable name="all-namespaces" select="$testset/namespaces/ns"/>
    <xsl:variable name="all-parameters" select="$testset/parameters/parm"/>
    
    <!-- 
        Read all info from the 5th (Metadata) tab (parameters).
        Use this for:
        
        1/ Compile a schema path that can be used to validate the resulting XML document 
    -->
    
    <xsl:variable name="frags" as="element(frag)*">
        <!-- passed as part of the excel. -->
        <frag 
            key="job" value="{$all-parameters[@name='job-id']}" 
            explain="Excel metadata parameter 'job-id'"/> <!-- 2017-07-13-16-17-43-473 -->
        <frag 
            key="subpath" value="{$all-parameters[@name='schema-subpath']}"
            explain="Excel metadata parameter 'schema-subpath'"/> <!-- bsmr0320/bsmr0320_bg0320.xsd -->
        
        <!-- passed as command line parameter -->
        <frag 
            key="executor" value="{imf:get-config-string('cli','executor')}"
            explain="command line parameter 'executor'"/>
        
        <!-- needed? -->
        <frag 
            key="project" value="{$all-parameters[@name='project-name']}"
            explain="Excel metadata parameter 'project-name'"/>
        <frag 
            key="model" value="{$all-parameters[@name='model-name']}"
            explain="Excel metadata parameter 'model-name'"/>
        <frag 
            key="release" value="{$all-parameters[@name='model-release']}"
            explain="Excel metadata parameter 'model-release'"/>
       
    </xsl:variable>
    
    <xsl:variable name="schema-path" select="concat('../../app/xsd/',imf:get-config-string('appinfo','schema-subpath'))"/>
    
    <xsl:template match="/">
        <xsl:variable name="root" select="*"/>
        
        <!-- test if all fragments are available -->
        <xsl:for-each select="$frags">
            <xsl:if test="not(normalize-space(@value))">
                 <xsl:sequence select="imf:msg($root,'WARN','May not be able to compile. Missing: [1]',@explain)"/>  
            </xsl:if>
        </xsl:for-each>
       
        <message-collection>
            <!--<xsl:apply-templates select="//*" mode="testje"/>-->
          
            <!-- first define all used namespaces -->
            <xsl:for-each-group select="//cell" group-by="@name">
                <xsl:variable name="parse" select="imf:ns-parse(current-grouping-key())"/>
                <xsl:if test="normalize-space($parse[3])">
                    <xsl:namespace name="{$parse[3]}" select="$parse[4]"/>
                </xsl:if> 
            </xsl:for-each-group>
            <xsl:for-each-group select="//group" group-by="@type">
                <xsl:variable name="parse" select="imf:ns-parse(current-grouping-key())"/>
                <xsl:if test="normalize-space($parse[3])">
                    <xsl:namespace name="{$parse[3]}" select="$parse[4]"/>
                </xsl:if> 
            </xsl:for-each-group>
            
            <!-- next compile the messages -->
            <xsl:sequence select="imf:debug($testset,'Generating [1] using excel version [2]', ($testset/@generated, $testset/@excel-app-version))"/>
            <xsl:variable name="messages" as="node()*">
                <xsl:for-each-group select="$testset/groups[@part = '1']/group" group-by="@type">
                    <xsl:apply-templates select="current-group()" mode="message-column"/>
                </xsl:for-each-group>
            </xsl:variable>
            
            <!-- the remove all "blanks" -->
            <xsl:apply-templates select="$messages" mode="common-compact"/>
            <!-- done -->
        </message-collection>
    </xsl:template>
    
    <!-- sheet1, each next column -->
    <xsl:template match="group" mode="message-column">
        <xsl:sequence select="imf:debug(.,'Group label [1]', (@label))"/>
        <message file-name="{@label}">
            <xsl:variable name="parse" select="imf:ns-parse(@type)"/>
            <xsl:element name="{imf:get-name-with-prefix($parse)}" namespace="{$parse[4]}">
                
                <xsl:variable name="following-attributes" select="imf:get-subattributes(cell[1])"/>
                <xsl:if test="exists($following-attributes)">
                    <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
                </xsl:if>
                
                <!-- set the imports -->
                <xsl:variable name="subpath" select="$all-parameters[@name = 'schema-subpath']"/>
                <xsl:variable name="fullpath" select="$schema-path"/>
                <xsl:variable name="top-ns" select="$parse[4]"/>
                <xsl:attribute name="xsi:schemaLocation" select="concat($top-ns,' ', $fullpath)"/>
                
                <xsl:apply-templates select="cell" mode="message-cell"/>
            </xsl:element>
        </message>
    </xsl:template>
    
    <!-- sheet1, each next cell in column: a link  -->
    <xsl:template match="cell[exists(@link)]" mode="message-cell">
        <xsl:sequence select="imf:debug(.,'message-cell Cell value [1]', (@value))"/>
        <xsl:variable name="following-attributes" select="imf:get-attributes(.)"/>
      
        <!-- determine which group is linked to -->
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="label" select="@value"/>
        <xsl:variable name="link" select="@link"/>
        <xsl:variable name="linked-group" select="/testset/groups[@part = '2']/group[@label = $label and @id = $link]"/>
        
        <xsl:choose>
            <xsl:when test="empty($label)">
                <!-- skip, this is a link but no link group selected -->
            </xsl:when>
            <xsl:when test="count($linked-group) eq 1">
                <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
                <xsl:element name="{imf:get-name-with-prefix($parse)}" namespace="{$parse[4]}">
                    <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
                    <xsl:apply-templates select="$linked-group" mode="data-column"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="exists($following-attributes)">
                <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
                <xsl:element name="{imf:get-name-with-prefix($parse)}" namespace="{$parse[4]}">
                    <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
                    <!-- no content -->
                </xsl:element>
            </xsl:when>
            <xsl:when test="count($linked-group) lt 1">
                <xsl:sequence select="imf:msg(.,'ERROR','Cannot find group following link [1]', ($link))"/>
            </xsl:when>
            <xsl:when test="count($linked-group) gt 1">
                <xsl:sequence select="imf:msg(.,'ERROR','Too many group types [1], column name [2]', ($linked-group[1]/@name,$linked-group[1]/@value))"/>
            </xsl:when>
        </xsl:choose>
       
    </xsl:template>

    <xsl:template match="cell[starts-with(@name,'@')]"  mode="message-cell" priority="100">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="cell[starts-with(@name,'@')]"  mode="data-cell" priority="100">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="cell[starts-with(@name,'@')]"  mode="attribute-cell">
        <xsl:if test="normalize-space(@value)">
            <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
            <xsl:attribute name="{imf:get-name-with-prefix($parse)}" namespace="{$parse[4]}" select="@value"/>
        </xsl:if>
    </xsl:template>
    
    <!-- a group in the sheet 2 (data) -->
    <xsl:template match="group" mode="data-column">
        <xsl:sequence select="imf:debug(.,'data-column Group in data', ())"/>
        <xsl:apply-templates select="cell" mode="data-cell"/>
    </xsl:template>
    
    <!-- sheet2, each next cell in column: a link  -->
    <xsl:template match="cell[exists(@link)]" mode="data-cell">
        <xsl:sequence select="imf:debug(.,'data-cell Cell link value - type [1] label [2] link [3]', (@name, @value,@link))"/>
        
        <xsl:variable name="label" select="@value"/>
        <xsl:variable name="link" select="@link"/>
        <xsl:variable name="linked-group" select="$testset/groups[@part = '2']/group[@label = $label and @id = $link]"/>
        
        <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
        <xsl:element name="{imf:get-name-with-prefix($parse)}" namespace="{$parse[4]}">
            <xsl:variable name="following-attributes" select="imf:get-attributes(.)"/>
            <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
            <xsl:choose>
                <xsl:when test="empty($label)">
                    <!-- skip a link cell when no value specified. -->
                </xsl:when>
                <xsl:when test="exists($linked-group)">
                    <xsl:apply-templates select="$linked-group" mode="data-column"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:debug(.,'ERROR', ())"/>
                    <xsl:sequence select="imf:msg(.,'ERROR','Cannot resolve link to [1] as defined on [2]',($link,$label))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element> 
        
    </xsl:template>
    
    <!-- sheet 1 and 2, each next cell in column: a value  -->
    <xsl:template match="cell[empty(@link)]" mode="data-cell message-cell">
        <xsl:variable name="name" select="@name"/>
        <xsl:sequence select="imf:debug(.,'data-cell Cell text [1]', ($name))"/>
        <xsl:variable name="parse" select="imf:ns-parse(@name)"/>
        <xsl:element name="{imf:get-name-with-prefix($parse)}" namespace="{$parse[4]}"> <!--StUF:noValue -->
            <xsl:variable name="following-attributes" select="imf:get-attributes(.)"/>
            <xsl:apply-templates select="$following-attributes" mode="attribute-cell"/>
            <xsl:value-of select="@value"/>
            <!-- add a processing instruction that holds the test value if any -->
            <xsl:variable name="test-value" select="$all-test-values[@name=current()/@value]"/>
            <xsl:if test="exists($test-value)">
                <xsl:processing-instruction name="test-value" select="$test-value"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="imf:debug">
        <xsl:param name="element"/>
        <xsl:param name="text"/>
        <xsl:param name="info"/>
        <xsl:choose>
            <xsl:when test="$debugging">
                <xsl:variable name="ctext" select="imf:msg-insert-parms($text,$info)"/>
                <xsl:comment select="concat(name($element),': ', $ctext)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
        get all subsequent attributes, starting at the attribute cell passed 
    -->
    <xsl:function name="imf:get-subattributes" as="element()*">
        <xsl:param name="cell"/>
        <xsl:if test="imf:fetch-test($cell)">
            <xsl:sequence select="($cell,imf:fetch($cell,()))"/>
        </xsl:if>
    </xsl:function>
    
    <!-- 
        get all subsequent attributes, starting at the element cell passed 
    -->
    <xsl:function name="imf:get-attributes" as="element()*">
        <xsl:param name="cell"/>
        <xsl:sequence select="imf:fetch($cell,())"/>
    </xsl:function>
    
    <xsl:function name="imf:fetch" as="element(cell)*">
        <xsl:param name="anchor" as="element(cell)"/>
        <xsl:param name="fetched" as="element(cell)*"/>
        <xsl:for-each select="($anchor,$fetched)[last()]"> <!-- singleton -->
            <xsl:variable name="next" select="following-sibling::*[1]"/>
            <xsl:sequence select=" if (imf:fetch-test($next)) then imf:fetch($anchor,($fetched,$next)) else $fetched"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:fetch-test" as="xs:boolean">
        <xsl:param name="cell"/>
        <xsl:sequence select="starts-with($cell/@name,'@')"/>
    </xsl:function>
        
    <!--
        parse the name, returning 
        1 indication is attribute (true) or element (false)
        2 the unqualified name
        3 the prefix, or empty string.
        4 the namespace, or /unknown
    -->    
    <xsl:function name="imf:ns-parse" as="xs:string+">
        <xsl:param name="passed-name"/>
        <xsl:variable name="is-att" select="starts-with($passed-name,'@')"/>
        <xsl:variable name="parse" select="tokenize($passed-name,':')"/>
        <xsl:choose>
            <xsl:when test="$parse[2]">
                <!-- format: @abc:def or abc:def-->
                <xsl:variable name="prefix" select="if ($is-att) then substring($parse[1],2) else $parse[1]"/>
                <xsl:variable name="name" select="$parse[2]"/>
                <xsl:variable name="ns" select="$all-namespaces[@prefix=$prefix]"/>
           
                <xsl:sequence select="if (empty($ns)) then imf:msg('ERROR','No namespace for prefix [1]',$prefix) else ()"/>
                
                <xsl:value-of select="$is-att"/>
                <xsl:value-of select="$name"/>
                <xsl:value-of select="$prefix"/>
                <xsl:value-of select="($ns,'/unknown')[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- format: @def or def -->
                <xsl:variable name="name" select="if ($is-att) then substring($parse[1],2) else $parse[1]"/>
               
                <xsl:value-of select="$is-att"/>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="group|groups" mode="testje">
        <xsl:element name="a:{local-name(.)}" namespace="/n">
            <xsl:apply-templates select="*" mode="testje"></xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="imf:get-name-with-prefix">
        <xsl:param name="parse"/>
        <xsl:value-of select="if ($parse[3]) then concat($parse[3],':',$parse[2]) else $parse[2]"/>
    </xsl:function>
    
</xsl:stylesheet>