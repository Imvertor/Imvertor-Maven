<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    >
    
    <!-- 
        Validation of MIM 1.1 models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:variable name="context-signaltype" select="'ERROR'"/><!-- TODO configureerbaar maken? -->
    
    <xsl:variable name="datatype-stereos" select="
        ('stereotype-name-simpletype',
        'stereotype-name-complextype',
        'stereotype-name-union',
        'stereotype-name-referentielijst',
        'stereotype-name-codelist',
        'stereotype-name-interface',
        'stereotype-name-enumeration')"/>
    
    <xsl:variable name="root-package" select="/*/imvert:package[imf:boolean(imvert:is-root-package)]"/>
    <xsl:variable name="is-role-based" select="imf:get-tagged-value($root-package,'##CFG-TV-IMRELATIONMODELINGTYPE') = 'Relatierol leidend'"/>
    <!-- 
        Document validation; this validates the root (application-)package.
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
            <!-- process the application package -->
            <xsl:apply-templates select="$root-package"/>
        </imvert:report>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-union-for-attributes']">
        <!--setup-->
        <xsl:sequence select="imf:report-error(., 
            (imvert:min-occurs ne '1' or imvert:max-occurs ne '1'), 
            'Attribute with stereotype [1] must have cardinality of 1..1', imf:get-config-name-by-id('stereotype-name-union'))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:association">
        <!--setup-->
        <xsl:variable name="stereotypes" select="imvert:stereotype"/>
        <xsl:variable name="parent-stereotypes" select="../../imvert:stereotype"/>
        <xsl:variable name="allowed-parent-stereotypes" select="$configuration-metamodel-file/stereotypes/stereo[@id = $stereotypes/@id]/context/parent-stereo" as="xs:string*"/>
        
        <xsl:sequence select="imf:report-validation(., 
            exists($allowed-parent-stereotypes) and not($parent-stereotypes/@id = $allowed-parent-stereotypes), 
            $context-signaltype,
            'Association with stereotype [1] must not appear here, expecting (any of) [2]', (imf:string-group($stereotypes),imf:string-group(for $s in $allowed-parent-stereotypes return imf:get-config-name-by-id($s))))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!-- generalisatie kan alleen betrekking hebben op gelijke stereotypen (objecttype generalisayie betreft objecttype etc.) -->
    
    <xsl:template match="imvert:*[imvert:supertype]">
        
        <xsl:variable name="stereotypes" select="imvert:stereotype"/>
        <xsl:variable name="super-stereotypes" select="(for $s in imvert:supertype/imvert:type-id return imf:get-construct-by-id($s))/imvert:stereotype"/>
        <xsl:variable name="allowed-super-stereotypes" select="$configuration-metamodel-file/stereotypes/stereo[@id = $stereotypes/@id]/context/super-stereo" as="xs:string*"/>
        
        <xsl:sequence select="imf:report-validation(., 
            not($super-stereotypes/@id = 'stereotype-name-interface') 
            and
            exists($allowed-super-stereotypes) and not($super-stereotypes/@id = $allowed-super-stereotypes), 
            $context-signaltype,
            'Unexpected stereotype [1] for supertype. My stereotype is [2]', (imf:string-group($super-stereotypes),imf:string-group($stereotypes)))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Stel vast dat alleen bepaalde stereotypen attribuutsoorten kunnen hebben. 
        
        Aan MIM 1.1 validatie toegevoegd bij de implementatie van MIM 1.1.1
    -->
    <xsl:template match="imvert:attribute" priority="10">
        <xsl:variable name="stereotypes" select="imvert:stereotype"/>
        <xsl:variable name="parent-stereotypes" select="../../imvert:stereotype"/>
        <xsl:variable name="allowed-parent-stereotypes" select="$configuration-metamodel-file/stereotypes/stereo[@id = $stereotypes/@id]/context/parent-stereo" as="xs:string*"/>
        
        <xsl:variable name="defining-class" select="if (imvert:type-id) then imf:get-construct-by-id(imvert:type-id) else ()"/>
        
        <xsl:sequence select="imf:report-validation(., 
            exists($allowed-parent-stereotypes) and not($parent-stereotypes/@id = $allowed-parent-stereotypes), 
            $context-signaltype,
            'Attribute with stereotype [1] must not appear here, but as attribute of (any of) [2]', (imf:string-group($stereotypes),imf:string-group(for $s in $allowed-parent-stereotypes return imf:get-config-name-by-id($s))))"/>
        
        <!-- #400 -->
        <xsl:sequence select="imf:report-validation(., 
            ($stereotypes/@id = 'stereotype-name-attribute') and $defining-class and not($defining-class/imvert:stereotype/@id = $datatype-stereos), 
            $context-signaltype,
            'Attribute type is not a datatype. Expected any of [1]', imf:string-group(imf:get-config-stereotypes($datatype-stereos)))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        MIM: Foutmelding als enumeratie geen waarden heeft 
        #312
    -->
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-enumeration']" priority="10">
        <xsl:variable name="enums" select="imvert:attributes/imvert:attribute[imvert:stereotype/@id = 'stereotype-name-enum']"/>
        
        <xsl:sequence select="imf:report-validation(., 
            empty($enums), 
            $context-signaltype,
            'Empty enumeration [1] is not allowed', imf:get-config-name-by-id('stereotype-name-enumeration'))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class" priority="20">

        <xsl:variable name="properties" select="(
            imvert:attributes/imvert:attribute,
            imvert:associations/imvert:association[not($is-role-based)],
            imvert:associations/imvert:association[$is-role-based]/imvert:source/imvert:role,
            imvert:associations/imvert:association[$is-role-based]/imvert:target/imvert:role
            )"/>
        <xsl:variable name="properties-dups" select="imf:find-duplicate-strings($properties/imvert:name/@original)"/>
        
        <xsl:sequence select="imf:report-validation(., 
            exists($properties-dups), 
            $context-signaltype,
            'Several properties with same name found: [1]', imf:string-group($properties-dups))"/>
        
        <xsl:next-match/>
    </xsl:template>     
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
