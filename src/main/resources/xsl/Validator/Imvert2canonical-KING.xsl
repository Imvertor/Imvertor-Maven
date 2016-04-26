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
          This canonization stylesheet is imported by sopecific UGM or SIM stylesheets.
    -->
    
    <xsl:import href="Imvert2canonical-KING-common.xsl"/>
     
    <?x 
        CHECK OF DIT ALLEMAAL NOG STEEDS GELDT VOOR DE NIEUWE KING IMVERTOR EAP'S
          
    <xsl:variable name="project-package" select="(//imvert:package[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-project-package')])[1]"/>
    
    <!-- KING for now only uses base packages; later possibly also application packages. -->
    <xsl:variable name="base-packages" select="($project-package//imvert:package[imvert:stereotype=imf:get-config-stereotypes('stereotype-name-base-package')])"/>
    <xsl:variable name="base-package" select="($base-packages[imvert:found-name = $application-package-name])[1]"/>
    <xsl:variable name="external-package" select="$project-package/imvert:package[not(. = $base-packages)]"/>
    
    <xsl:variable name="version-raw" select="if (exists($base-package/imvert:version)) then $base-package/imvert:version else $imvertor-configuration-by-owner/imvert:version"/>
    <xsl:variable name="version" select="if (count(tokenize($version-raw,'\.')) = 2) then concat($version-raw,'.0') else $version-raw"/>
    
    <xsl:variable name="phase" select="if (exists($base-package/imvert:phase)) then $base-package/imvert:phase else $imvertor-configuration-by-owner/current-phase"/>
    <xsl:variable name="release" select="if (exists($base-package/imvert:release)) then $base-package/imvert:release else $imvertor-configuration-by-owner/current-release"/>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="$project-package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- <<project>> package -->
    <xsl:template match="imvert:package[.=$project-package]">
        <imvert:package>
            <xsl:apply-templates select="*[not(self::imvert:package)]"/>
            <xsl:comment>[base packages go here]</xsl:comment>
            <xsl:apply-templates select="$base-package"/>
            <xsl:comment>[external packages go here]</xsl:comment>
            <xsl:apply-templates select="$external-package"/>
        </imvert:package>
    </xsl:template>
    
    <!-- <<base>> package -->
    <xsl:template match="imvert:package[.=$base-package]">
        <imvert:package>
            <xsl:apply-templates select="*"/>
            <imvert:namespace>
                <xsl:value-of select="concat('http://www.KING.nl/schemas/', encode-for-uri(imvert:found-name))"/>
            </imvert:namespace>
            <imvert:release>
                <xsl:value-of select="$release"/>
            </imvert:release>
            <xsl:variable name="s" as="element()+">
                <imvert:stereotype>
                    <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-base-package')"/>
                </imvert:stereotype>
            </xsl:variable>
            <xsl:sequence select="imf:create-when-missing(.,$s)"/>
      </imvert:package>
    </xsl:template>
    
    <!-- <<domain>> package can be recognized by any package that holds any <<objectype>> -->
    <xsl:template match="imvert:package[.. = $base-package]">
        <xsl:choose>
            <xsl:when test=".//imvert:stereotype=imf:get-config-stereotypes(('stereotype-name-objecttype','stereotype-name-referentielijst','stereotype-name-choice'))">
                <imvert:package>
                    <xsl:apply-templates select="*"/>
                    <imvert:namespace>
                        <xsl:value-of select="concat('http://www.KING.nl/schemas/', encode-for-uri(../imvert:found-name),'/',encode-for-uri(imvert:found-name))"/>
                    </imvert:namespace>
                    <xsl:variable name="v" as="element()+">
                        <imvert:stereotype>
                            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-domain-package')"/>
                        </imvert:stereotype>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-when-missing(.,$v)"/>
                    <xsl:variable name="v" as="element()+">
                        <imvert:release>
                            <xsl:value-of select="$release"/>
                        </imvert:release>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-when-missing(.,$v)"/>
                </imvert:package>
            </xsl:when>
            <xsl:otherwise>
                <!-- remove this package, is diagram container or the like -->
            </xsl:otherwise>
        </xsl:choose>
       
    </xsl:template>
    
    <xsl:template match="imvert:package[(parent::*,self::*) = $base-package]/imvert:version">
        <imvert:version>
            <xsl:value-of select="$version"/>
        </imvert:version>
    </xsl:template>
    <xsl:template match="imvert:package[parent::* = $base-package]/imvert:phase">
        <imvert:phase>
            <xsl:value-of select="$phase"/>
        </imvert:phase>
    </xsl:template>
    
    <!-- TOTO check: Een relatie waarop een association class is gedefinieerd behoort niet type relatieklasse, maar gewoon relatiesoort te hebben. -->
    <xsl:template match="imvert:association/imvert:stereotype[. = 'relatieklasse']">
        <imvert:stereotype>
            <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-relatiesoort')"/>
        </imvert:stereotype>
    </xsl:template>
    
  
    
    <!-- 
        duplicaten 
        voorbeeld: ZKT-basis.heeftRelevant->ZaakObjecttype wordt: ZKT-basis.heeftRelevantZaakObjecttype->ZaakObjecttype
    -->
    <xsl:template match="imvert:association[count(../imvert:association[imvert:found-name = current()/imvert:found-name]) gt 1]">
        <xsl:variable name="typename" select="imf:create-element-name(imvert:type-name,'C')[2]"/>
        <xsl:variable name="n" select="imf:create-element-name(imvert:found-name,'R')"/>
        <imvert:association>
            <imvert:name original="{$n[1]} {$typename}">
                <xsl:value-of select="concat($n[2],imf:compile-name($typename,'C',true()))"/>
            </imvert:name>
            <xsl:apply-templates select="* except imvert:found-name"/>
        </imvert:association>
    </xsl:template>
   
    <!-- generate the correct name here -->
    <xsl:template match="imvert:found-name">
        <xsl:variable name="n" select="imf:create-element-name(.,
            if (parent::imvert:package) then 'P' else 
            if (parent::imvert:attribute) then 'R' else
            if (parent::imvert:association) then 'R' else 'C'
        )"/>
        <imvert:name original="{$n[1]}">
            <xsl:value-of select="$n[2]"/>
        </imvert:name>
    </xsl:template>
    
    <!-- generate the correct name for types specified, but only when the type is declared as a class (i.e. no system types) -->
    <xsl:template match="imvert:*[imvert:type-id]/imvert:type-name">
        <imvert:type-name original="{.}">
            <xsl:value-of select="imf:compile-name(.,'C',if (imf:boolean($normalize-names)) then true() else false())"/>
        </imvert:type-name>
    </xsl:template>
    
    <!-- generate the correct name for packages of types specified -->
    <xsl:template match="imvert:type-package">
        <imvert:type-package original="{.}">
            <xsl:value-of select="imf:compile-name(.,'P',if (imf:boolean($normalize-names)) then true() else false())"/>
        </imvert:type-package>
    </xsl:template>
   
    <!-- 
        When composite relation, assign a name for an unnamed relation.
        This is the name of the target object, starting with lower case letter. 
        
        Note that validation checks if more than one outgoing compositie relation to same object type, 
        and if at most one such association has no name.  
     -->
    <xsl:template match="imvert:association[imvert:aggregation = 'composite' and empty(imvert:found-name)]">
        <xsl:variable name="typename" select="imf:create-element-name(imvert:type-name,'R')[2]"/>
        <imvert:association>
            <imvert:name original="">
                <xsl:value-of select="imf:compile-name($typename,'R',true())"/>
            </imvert:name>
            <xsl:apply-templates/>
        </imvert:association>
    </xsl:template>
    
     <!-- 
        Return a Normalized name    
        This is extended to always return a XML useable name.
    -->
    <xsl:function name="imf:compile-name" as="xs:string">
        <xsl:param name="name-as-found" as="xs:string"/>
        <xsl:param name="name-type" as="xs:string"/> <!-- P(ackage), C(lass), p(R)operty) -->
        <xsl:param name="metamodel-based" as="xs:boolean"/> <!-- when metamodel, then stricter rules; otherwise return an XML schema valid form -->
        <xsl:variable name="metamodel-form">
            <xsl:variable name="parts" select="tokenize(lower-case($name-as-found),'[^_a-z0-9]+')"/>
            <xsl:variable name="frags" as="xs:string*">
                <xsl:for-each select="$parts">
                    <xsl:choose>
                        <xsl:when test="position() = 1 and starts-with(.,'_')"> <!-- only for classes -->
                            <xsl:value-of select="concat('_',upper-case(substring(.,2,1)),substring(.,3))"/>
                        </xsl:when>
                        <xsl:when test="position() = 1 and $name-type=('P','C')">
                            <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2))"/>
                        </xsl:when>
                        <xsl:when test="position() = 1 and $name-type=('R')">
                            <xsl:value-of select="concat(lower-case(substring(.,1,1)),substring(.,2))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(.,2))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="string-join($frags,'')"/>
        </xsl:variable>
        <xsl:value-of select="imf:extract(if ($metamodel-based) then $metamodel-form else $name-as-found,'[A-Za-z0-9_\-\.]+')"/>
    </xsl:function>
    
    <xsl:function name="imf:create-when-missing">
        <xsl:param name="this"/>
        <xsl:param name="new-elements" as="element()+"/>
        <xsl:for-each select="$new-elements">
            <xsl:variable name="name" select="name(.)"/>
            <xsl:if test="empty($this/*[name()=$name])">
                <xsl:sequence select="."/>
            </xsl:if>        
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="imf:create-element-name" as="xs:string+">
        <xsl:param name="found-name"/>
        <xsl:param name="type"/>
        <xsl:value-of select="$found-name"/>
        <xsl:value-of select="imf:compile-name($found-name,$type,if (imf:boolean($normalize-names)) then true() else false())"/>
    </xsl:function>

    ?>
    
    <xsl:template match="/imvert:packages">
        <imvert:packages>
            <xsl:sequence select="imf:compile-imvert-header(.)"/>
            <xsl:apply-templates select="imvert:package"/>
        </imvert:packages>
    </xsl:template>
    
    <!-- Rule: remove all empty packages where applicable. --> 
    <xsl:template match="imvert:package[empty(imvert:stereotype)]">
        <xsl:variable name="parent-package" select=".."/>
        <xsl:choose>
            <!-- skip some types of empty packages -->
            <xsl:when test="$parent-package/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-base-package')"/>
            <xsl:when test="$parent-package/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-application-package')"/>
            <xsl:when test="$parent-package/imvert:stereotype = imf:get-config-stereotypes('stereotype-name-project-package')"/>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
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
    
    <!-- when composition, and no name, generate name of the target class on that composition relation -->
    <!-- when composition, and no stereotype, put the composition stereotype there -->
    <xsl:template match="imvert:association[imvert:aggregation='composite']">
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
                    <imvert:stereotype>
                        <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-association-to-composite')"/>
                    </imvert:stereotype>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="imvert:stereotype"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[not(self::imvert:stereotype or self::imvert:found-name)]"/>
        </imvert:association>
    </xsl:template>
    
    <!-- assume any datatype to be steroetyped as datatype, when no stereotype is provided. -->
    <xsl:template match="imvert:class[imvert:designation = 'datatype' and empty(imvert:stereotype)]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <imvert:stereotype origin="canon">
                <xsl:value-of select="imf:get-config-stereotypes('stereotype-name-datatype')"/>
            </imvert:stereotype>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="imvert:association[imvert:stereotype = imf:get-config-stereotypes('stereotype-name-tekentechnisch')]">
        <!-- remove -->
    </xsl:template>

</xsl:stylesheet>
