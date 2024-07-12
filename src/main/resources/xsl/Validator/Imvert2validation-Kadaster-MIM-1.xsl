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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    >
    
    <!-- 
        Validation of Kadaster models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <!-- follow guidelines for Kadaster and KING (KK) -->
    
    <xsl:include href="Imvert2validation-KK.xsl"/>
    
    <xsl:variable name="application-package" select="//imvert:package[imf:boolean(imvert:is-root-package)]"/>
    <xsl:variable name="domain-package" select="$application-package//imvert:package[imvert:stereotype/@id = (('stereotype-name-domain-package','stereotype-name-view-package'))]"/>
    
    <!-- All possible application-level top-packages -->
    <xsl:variable name="top-package-stereotypes" select="
        ('stereotype-name-informatiemodel-package',
        'stereotype-name-base-package',
        'stereotype-name-variant-package',
        'stereotype-name-application-package')"/>
    
    <!-- all service packages are packages that have the tv service=yes, or end with Messsages or Resultaat -->
    <xsl:variable name="all-service-base-packages" select="$domain-package[imf:boolean(imf:get-tagged-value(.,'##CFG-TV-SERVICE'))]"/>
    <xsl:variable name="all-service-packages" select="$domain-package[imf:member-of(.,$all-service-base-packages) or ends-with(imvert:name,'Messages') or ends-with(imvert:name,'Resultaat') ]"/>
    
    <xsl:variable name="datatype-stereos" 
        select="('stereotype-name-simpletype','stereotype-name-complextype','stereotype-name-union','stereotype-name-referentielijst','stereotype-name-codelist','stereotype-name-interface','stereotype-name-enumeration')"/>
  
    <xsl:variable name="use-identifier-domains" select="imf:boolean(imf:get-xparm('cli/identifierdomains','no'))"/>
    <xsl:variable name="id-domain-values" select="for $a in //imvert:attribute[imf:boolean(imvert:is-id)] return imf:get-tagged-value($a,'##CFG-TV-DOMAIN')"/>
    
    <xsl:variable name="is-basemodel" select="$application-package/imvert:stereotype/@id = ('stereotype-name-informatiemodel-package','stereotype-name-base-package')"/>
    
    <!-- 
        Document validation; this validates the root (application-)package.
    -->
    <xsl:template match="/imvert:packages">
        <imvert:report>
            <!-- info used to determine report location are set here -->
            <xsl:variable name="application-package-release" select="$application-package/imvert:release"/>
            <xsl:variable name="application-package-version" select="$application-package/imvert:version"/>
            <xsl:variable name="application-package-phase" select="$application-package/imvert:phase"/>
            
            <xsl:attribute name="release" select="if ($application-package-release) then $application-package-release else '00000000'"/>
            <xsl:attribute name="version" select="if ($application-package-version) then $application-package-version else '0.0.0'"/>
            <xsl:attribute name="phase" select="if ($application-package-phase) then $application-package-phase else '0'"/>
            
            <xsl:sequence select="imf:report-error(., not($application-package), 'No such application package found: [1]', ($application-package-name))"/>
         
            <xsl:sequence select="imf:report-error(., 
                ($document-classes/imvert:stereotype/@id = ('stereotype-name-objecttype') and not($document-packages/imvert:name=('xlinks','Xlinks'))), 
                'The model uses shared classes but the xlink package is not included (properly).')"/>
            
            <!-- process the application package -->
            <xsl:apply-templates select="imvert:package"/>
        </imvert:report>
    </xsl:template>
      
    <xsl:template match="imvert:package[imf:member-of(.,$application-package)]">
        <!--setup-->
        <xsl:variable name="this-package" select="."/>
        <xsl:variable name="root-release" select="imvert:release" as="xs:string?"/>
        <xsl:variable name="subpackage-releases" select="imvert:package/imvert:release[not(.=('99999999','00000000'))]" as="xs:string*"/>
        <xsl:variable name="collections" select="imvert:class[imvert:stereotype/@id = ('stereotype-name-collection')]"/>  
        <xsl:sequence select="imf:report-error(., 
            ($document-classes/imvert:stereotype/@id = ('stereotype-name-objecttype') and not($document-packages/imvert:name=('xlinks','Xlinks'))), 
            'The model uses shared classes but the xlink package is not included (properly).')"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class">
        <xsl:variable name="package" select=".."/>
        
        <xsl:variable name="is-external" select="$package/imvert:stereotype/@id = ('stereotype-name-external-package')"/>
        
        <xsl:variable name="package-is-service" select="imf:member-of($package,$all-service-packages)"/>
        <xsl:variable name="class-is-service" select="imvert:stereotype/@id = (('stereotype-name-service','stereotype-name-process'))"/>
        
        <!--
            Only Abstract classes start with _underscore        
        -->
        <xsl:sequence select="imf:report-warning(., 
            not($is-external) and imf:boolean(imvert:abstract) and not(starts-with(imvert:name,'_')), 
            'Abstract class name should start with underscore.')"/>
        <xsl:sequence select="imf:report-warning(., 
            not($is-external) and not(imf:boolean(imvert:abstract)) and starts-with(imvert:name,'_'), 
            'Concrete class name should not start with underscore.')"/>
        
        <!-- services and processes should only occur within service packages -->
        <xsl:sequence select="imf:report-warning(., 
            $class-is-service and not($package-is-service),
            'Service class [1] found outside a service package',imf:string-group(imvert:stereotype))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
        attribute validation 
    -->
    <xsl:template match="imvert:attribute">
        <!-- setup -->
        <xsl:variable name="this" select="."/>
        <xsl:variable name="class" select="../.."/>
        
        <xsl:variable name="is-object-attribute" select="imvert:stereotype/@id = ('stereotype-name-attribute')"/>
        
        <xsl:sequence select="imf:report-error(., 
            ($is-object-attribute and (imvert:name = imf:get-config-parameter('fixed-identification-attribute-name')) and not(imvert:is-id = 'true')), 
            'Identification attribute is not marked as ID')"/>
        
        <?x
            Identification stereotype is not required. 
        
        <xsl:sequence select="imf:report-warning(., 
            (imvert:is-id = 'true' and not(imvert:stereotype/@id = ('stereotype-name-identification'))), 
            'Attribute is marked as ID but is not stereotyped as [1]', imf:get-config-stereotypes('stereotype-name-identification'))"/>
        x?>
        
        <?x
        <!-- als érgens in dit model een domein is gezet op een is-id attribute, dan moet dat overal gebeuren waar een is-id voorkomt -->
        <xsl:sequence select="imf:report-warning(., 
            (exists($id-domain-values) and imf:boolean(imvert:is-id) and empty(imf:get-tagged-value(.,'##CFG-TV-DOMAIN'))), 
            'Attribute is marked as ID but has no tagged value [1]', imf:get-config-name-by-id('CFG-TV-DOMAIN'))"/>
        x?>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class | imvert:attribute |imvert:association" priority="10">
        <xsl:variable name="is-tv-voidable" select="imf:boolean(imf:get-tagged-value(.,'##CFG-TV-VOIDABLE'))"/>
            
        <xsl:sequence select="imf:report-warning(., 
            imvert:stereotype/@id = ('stereotype-name-voidable') and not($is-tv-voidable), 
            'Stereotype is [1], but tagged value [2] is not true',(imf:get-config-stereotypes('stereotype-name-voidable'), imf:get-config-tagged-values('CFG-TV-VOIDABLE')))"/>
        
        <?x
            Voidable stereotype is not required. 
            
        <xsl:sequence select="imf:report-warning(., 
            not(imvert:stereotype/@id = ('stereotype-name-voidable')) and $is-tv-voidable, 
            'Tagged value [2] set to true, but not stereotyped as [1]',(imf:get-config-stereotypes('stereotype-name-voidable'), imf:get-config-tagged-values('CFG-TV-VOIDABLE')))"/>
        x?>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!-- IM-269 -->
    <xsl:template match="imvert:attribute |imvert:association" priority="20">
        
        <?x decided not to signal this 
        <xsl:variable name="found-name" select="imvert:name/@original"/>
        <xsl:sequence select="imf:report-warning(., 
            matches($found-name,'^[A-Z]{2}'), 
            'UML property name [1] starts with multiple capital letters. The adapted name may be invalid.', $found-name)"/>
        ?>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:class/imvert:supertype[imvert:stereotype/@id = ('stereotype-name-static-generalization')]" priority="1">
        <!--setup-->
        <!--validation-->
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[../../imvert:stereotype/@id = ('stereotype-name-composite','stereotype-name-complextype')]">
        <!--setup-->
        <xsl:variable name="class" select="../.."/>
        
        <!--validation-->
        <xsl:sequence select="imf:report-error(., 
            imvert:is-id = 'true', 
            'A class stereotyped as [1] may not have an identifying attribute',$class/imvert:stereotype[@id = ('stereotype-name-composite','stereotype-name-complextype')])"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <!--
        Rules for the domain packages
    -->
    <xsl:template match="imvert:package[imf:member-of(.,$domain-package)]" priority="50">
        <!--setup-->
        <xsl:variable name="is-schema-package" select="if (imvert:stereotype/@id = ('stereotype-name-domain-package','stereotype-name-view-package')) then true() else false()"/>
        <xsl:variable name="classnames" select="distinct-values(imf:get-duplicates(imvert:class/imvert:name))" as="xs:string*"/>
        <xsl:variable name="application" select="ancestor::imvert:package[imvert:stereotype/@id = $top-package-stereotypes][1]"/>
        <!--validation -->
        <xsl:sequence select="imf:report-error(., 
            $is-schema-package and not(imvert:namespace), 
            'Package has no alias (i.e. namespace).')"/>
        <xsl:sequence select="imf:report-error(., 
            imvert:namespace = $application/imvert:namespace,
            'Namespace of the domain package is the same as the application namespace [1].',(../imvert:namespace))"/>
        <xsl:sequence select="imf:report-error(., 
            not(starts-with(imvert:namespace,concat($application/imvert:namespace,'/'))),
            'Namespace [1] of the domain package does not start with the application namespace [2].',(string(imvert:namespace), string(../imvert:namespace)))"/>
        <xsl:sequence select="imf:report-error(., 
            (matches(substring-after(imvert:namespace,$application/imvert:namespace),'.*?//')),
            'Namespace of the domain package holds empty path: [1]',imvert:namespace)"/>
    
        <!-- validate the version chain -->
        <xsl:if test="exists(ancestor-or-self::imvert:package[not(imf:boolean(imvert:derived))])">
            <xsl:apply-templates select="." mode="version-chain"/>
        </xsl:if>
    
        <!-- De namespace (alias) van een domein package met naam *Messages moet eindigen op /service. -->
        <xsl:sequence select="imf:report-warning(., 
            ends-with(imvert:name,'Messages') and not(ends-with(imvert:alias,'/service')),
            'Namespace [1] should end with [2]',(imvert:alias,'/service'))"/>
        
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
    
    <!-- a service base package requires two other packages to be available --> 
    <xsl:template match="imvert:package[imf:member-of(.,$all-service-base-packages)]" priority="40">
        
        <xsl:variable name="name" select="imvert:name"/>
        <xsl:variable name="msg-name" select="concat($name,'Messages')"/>
        <xsl:variable name="res-name" select="concat($name,'Resultaat')"/>
        <xsl:variable name="msg-package" select="../imvert:package[imvert:name = $msg-name]"/>
        <xsl:variable name="res-package" select="../imvert:package[imvert:name = $res-name]"/>
        
        <xsl:sequence select="imf:report-warning(., 
            empty($msg-package),
            'No message package [1] found for service package [2]',($msg-name,$name))"/>
        <xsl:sequence select="imf:report-warning(., 
            empty($res-package),
            'No result package [1] found for service package [2]',($res-name,$name))"/>
        
        <!-- check as regular package -->
        <xsl:next-match/>
    </xsl:template>
   
   
    <xsl:template match="imvert:attribute[$use-identifier-domains and imf:get-tagged-value(.,'##CFG-TV-DOMAIN')]">
        
        <xsl:variable name="domain-value" select="imf:get-tagged-value(.,'##CFG-TV-DOMAIN')"/>
        
        <?x Domein tagged value nu ook toegestaan op attributen die verwijzen naar een class met een ID attribuut, zie #267 
        
        <!-- Metadata Domein zit altijd en alleen bij een objecttype die een {id} heeft (in EA is dit isID=true) -->
        <xsl:sequence select="imf:report-error(., 
            not(imf:boolean(imvert:is-id)),
            'Tagged value [1] only allowed on ID attributes',(imf:get-config-name-by-id('CFG-TV-DOMAIN')))"/>
        x?>
        
        <!-- Het is niet toegestaan dat een waarde die is opgenomen in ‘domein’ meer dan 1x voorkomt in het model. 
            Dit blijft vooralsnog beperkt tot basismodellen. -->
        <xsl:sequence select="imf:report-warning(., 
            $is-basemodel and count(index-of($id-domain-values,$domain-value)) gt 1,
            'Duplicate [1] tagged value: [2]',(imf:get-config-name-by-id('CFG-TV-DOMAIN'),$domain-value))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
