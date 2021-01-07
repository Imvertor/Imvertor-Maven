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
    
    xmlns:cs="http://www.imvertor.org/metamodels/conceptualschemas/model/v20181210"
    xmlns:cs-ref="http://www.imvertor.org/metamodels/conceptualschemas/model-ref/v20181210"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
        Pick up any stubs and translate these to the external or internal packages they are defined in.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-conceptual-map.xsl"/>
       
  
    <!-- 
        outside mapped classes  are classes that are referenced but not defined. 
        They are considered to be configured using the conceptual schemas configuration.
        Typical example are GML constructs.
    -->
    <xsl:variable name="outside-mapped-classes" as="element(imvert:class)*">
        
        <xsl:for-each select="$document-packages[imvert:id = 'OUTSIDE']/imvert:class"> <!-- all stubs -->
            <xsl:variable name="id" select="imvert:id"/>
            <xsl:variable name="name" select="imvert:name"/>
            <xsl:variable name="constructs" select="$conceptual-schema-mapping//cs:Construct[cs:name = $name]" as="element(cs:Construct)*"/>
            <xsl:variable name="identified-construct" select="$constructs[cs:managedID = $id][1]"/><!-- een construct in de conceptual schemas -->
            <xsl:variable name="referencing-constructs" select="$document-classes/descendant-or-self::*[imvert:type-id = $id]/ancestor-or-self::*[imvert:id][1]"/><!-- construct in dit document van dat type -->
            <xsl:variable name="construct" as="element(cs:Construct)?">
                <xsl:choose>
                    <xsl:when test="$constructs[2] and empty($identified-construct)">
                        <xsl:for-each select="$referencing-constructs">
                            <xsl:sequence select="imf:msg(.,'ERROR','Reference to [1] in outside model is not identified, but should be, as duplicates occur using mapping [2]',(imf:string-group($name),$conceptual-schema-mapping-name))"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$constructs[2]">
                        <xsl:sequence select="$identified-construct"/>
                    </xsl:when>
                    <xsl:when test="$constructs[1]">
                        <xsl:sequence select="$constructs"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="$referencing-constructs">
                            <xsl:sequence select="imf:msg(.,'ERROR','Reference to [1] in outside model could not be resolved when using mapping [2]',(imf:string-group($name),$conceptual-schema-mapping-name))"/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        
            <xsl:sequence select="dlogger:save('outside name',$name)"/>
            <xsl:sequence select="dlogger:save('outside constructs',$constructs)"/>
            <!-- 
                We have drilled down to single construct (or none if error) 
                Get the URL of the conceptual schema this is part of.
            -->
            <xsl:if test="exists($construct)">
                <xsl:variable name="schema" select="imf:get-schema-for-construct($construct)"/>
                <xsl:variable name="map" select="$construct/../.."/>
                
                <xsl:variable name="cs" select="($schema/cs:url)[1]"/>
                <xsl:variable name="cn" select="($schema/cs:id)[1]"/>
                <xsl:variable name="sn" select="($schema/cs:shortName)[1]"/>
                
                <xsl:variable name="ve" select="($map/cs:version)[1]"/>
                <xsl:variable name="ph" select="($map/cs:phase)[1]"/>
                
                <imvert:class origin="system" cs="{$cs}" cn="{$cn}" sn="{$sn}" ve="{$ve}" ph="{$ph}">
                    <imvert:name original="{$name}">
                        <xsl:value-of select="$name"/>
                    </imvert:name>
                    <xsl:sequence select="$id"/>
                    <xsl:if test="exists($construct/cs:catalogEntries/cs:CatalogEntry) ">
                        <imvert:catalog>
                            <xsl:sequence select="imf:create-catalog-url($construct)"/>     
                        </imvert:catalog>
                    </xsl:if>
                    <xsl:if test="imf:boolean($construct/cs:sentinel)">
                        <imvert:sentinel>true</imvert:sentinel>
                    </xsl:if> 
                    <imvert:stereotype id="stereotype-name-interface">
                        <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-interface')"/>
                    </imvert:stereotype>
                </imvert:class>
            </xsl:if> 
      
        </xsl:for-each>
    </xsl:variable>    
    
    <xsl:template match="/imvert:packages">
     
        <xsl:sequence select="dlogger:save('mapping',$document-packages[imvert:id = 'OUTSIDE']/imvert:class)"/>
        
        <!-- set info on this model here (as early as possible!) -->
        <xsl:variable name="application-package" select=".//imvert:package[imf:boolean(imvert:is-root-package)]"/>
        
        <xsl:variable name="application-package-release" select="$application-package/imvert:release"/>
        <xsl:variable name="application-package-version" select="$application-package/imvert:version"/>
        <xsl:variable name="application-package-phase" select="$application-package/imvert:phase"/>
        
        <xsl:variable name="release" select="if ($application-package-release) then $application-package-release else '00000000'"/>
        <xsl:variable name="version" select="if ($application-package-version) then $application-package-version else '0.0.0'"/>
        <xsl:variable name="phase" select="if ($application-package-phase) then $application-package-phase else '0'"/>
        
        <xsl:sequence select="imf:set-config-string('appinfo','project-name',$project-name)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','application-name',$application-package-name)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','version',$version)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','phase',$phase)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','release',$release)"/>
        <xsl:sequence select="imf:set-config-string('appinfo','subpath',imf:get-subpath($project-name,$application-package-name,$release))"/>
            
        <!-- then process -->
        <xsl:copy>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:package[imvert:id = 'OUTSIDE']">
        <!--
           we now have a set of maps; must group them together and build external packages from these.
        -->
        <xsl:for-each-group select="$outside-mapped-classes" group-by="@cs">
            <imvert:package origin="system">
                <!-- check if some class is a sentinel class; in that case this external package is relevant for this application -->
                <xsl:if test="current-group()/imvert:sentinel = 'true'">
                    <imvert:sentinel>true</imvert:sentinel>
                </xsl:if>
                <imvert:id>
                    <xsl:value-of select="concat('OUTSIDE-',position())"/>
                </imvert:id>
                <imvert:version>
                    <xsl:value-of select="current-group()[1]/@ve"/>
                </imvert:version>
                <imvert:phase original="final">
                    <xsl:value-of select="current-group()[1]/@ph"/>
                </imvert:phase>
                <imvert:name original="{current-group()[1]/@cn}">
                    <xsl:value-of select="current-group()[1]/@cn"/>
                </imvert:name>
                <imvert:short-name>
                    <xsl:value-of select="current-group()[1]/@sn"/>
                </imvert:short-name>
                <imvert:alias>
                    <xsl:value-of select="current-grouping-key()"/>
                </imvert:alias>
                <imvert:namespace>
                    <xsl:value-of select="current-grouping-key()"/>
                </imvert:namespace>
                <imvert:stereotype id="stereotype-name-external-package">
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-external-package')"/>
                </imvert:stereotype>
                <!-- and list all classes -->
                <xsl:sequence select="for $c in current-group() return if ($c/@type = 'sentinel') then () else $c"/>
            </imvert:package>
        </xsl:for-each-group>
    </xsl:template>
        
    <xsl:template match="imvert:type-package[. = 'OUTSIDE']">
        <!-- replace this package name by the mapped name -->    
        <xsl:variable name="type-id" select="../imvert:type-id"/>
        <xsl:variable name="outside-class" select="$outside-mapped-classes[imvert:id = $type-id]"/>
        <xsl:variable name="outside-package-name" select="$outside-class/@cn"/>
        <imvert:type-package original="{$outside-package-name}" origin="OUTSIDE">
            <xsl:value-of select="$outside-package-name"/>
        </imvert:type-package>
    </xsl:template>
    <xsl:template match="imvert:supplier-package[. = 'OUTSIDE']">
        <!-- replace this package name by the mapped name -->    
        <xsl:variable name="type-id" select="../imvert:supplier-id"/>
        <xsl:variable name="outside-class" select="$outside-mapped-classes[imvert:id = $type-id]"/>
        <xsl:variable name="outside-package-name" select="$outside-class/@cn"/>
        <imvert:supplier-package original="{$outside-package-name}" origin="OUTSIDE">
            <xsl:value-of select="$outside-package-name"/>
        </imvert:supplier-package>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
