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
    xmlns:uml="http://schema.omg.org/spec/UML/2.1"
    xmlns:UML="omg.org/UML1.3"
    xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
    xmlns:EAUML="http://www.sparxsystems.com/profiles/EAUML/1.0"
    xmlns:xmi="http://schema.omg.org/spec/XMI/2.1"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    xmlns:local="urn:local"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
   
    <xsl:variable name="stylesheet-code">CNF</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <!-- 
      Fetch some info from raw XMI and store to parms.xml 
    
      Fiks aangepast op basis van de discussie #503
    -->
 
    <xsl:template match="/">
      
      <!-- 
        Als MIM model, bewaar dan de versie zoals opgegeven in het model. 
        Dit is een signaal dat het een MIM model betreft.
      -->
      <xsl:variable name="mim-version" select="local:value((//UML:TaggedValue[lower-case(@tag) = ('mim versie','mim version')])[1]/@value)"/>
      
      <!-- 
        de MIM metamodel versie en extensie is opgegeven als tagged value, of meegeleverd als cli
      -->
      <xsl:variable name="metamodel-owner" select="imf:get-xparm('cli/owner')"/>
      <xsl:variable name="metamodel-version" select="local:value(($mim-version,imf:get-xparm('cli/metamodelversion')))"/>
      <xsl:variable name="metamodel-extension" select="local:value(((//UML:TaggedValue[lower-case(@tag) = ('mim extensie','mim extension')])[1]/@value,imf:get-xparm('cli/metamodelextension')))"/>
      <xsl:variable name="metamodel-extension-version" select="local:value(((//UML:TaggedValue[lower-case(@tag) = ('mim extensie versie','mim extension version')])[1]/@value,imf:get-xparm('cli/metamodelextensionversion')))"/>
      <xsl:variable name="metamodel-name" select="if (exists($mim-version)) then 'MIM' else imf:get-xparm('cli/metamodelname')"/>
      
      <!-- 
        metamodel naam is:
        metamodel naam + metamodel versie + extensie naam + extensie versie
        
        Bij validatie, forceer dat als het metamodel MIM versie 1.* is, dat e.e.a. dan verwerkt wordt met MIM 1.2 (de meest recente minor versie) -->
      -->
      <xsl:variable name="toks" select="tokenize($metamodel-version,'\.')"/>
      <xsl:variable name="minor-version" select="if ($toks[2]) then $toks[1] || '.' || $toks[2] else $metamodel-version"/>
      <xsl:variable name="major-version" select="if ($toks[2]) then $toks[1] else $metamodel-version"/>
      
      <xsl:variable name="metamodel-name-and-version" select="if ($metamodel-name) then local:compact((
        $metamodel-owner,
        $metamodel-name, 
        $minor-version,
        $metamodel-extension, 
        $metamodel-extension-version
        )) else ()"/>
      
      <xsl:variable name="validation-name-and-version" select="if ($metamodel-name) then local:compact((
        $metamodel-owner,
        $metamodel-name, 
        $major-version,
        $metamodel-extension, 
        $metamodel-extension-version
        )) else ()"/>
      
      <!-- 
        Bewaar deze uitgelezen waarden als appinfo 
      -->
      <xsl:sequence select="imf:set-config-string('appinfo','metamodel-name',$metamodel-name)"/>
      <xsl:sequence select="imf:set-config-string('appinfo','metamodel-version',$minor-version)"/>
      <xsl:sequence select="imf:set-config-string('appinfo','metamodel-validation-version',$major-version)"/>
      <xsl:sequence select="imf:set-config-string('appinfo','metamodel-extension',$metamodel-extension)"/>
      <xsl:sequence select="imf:set-config-string('appinfo','metamodel-name-and-version',$metamodel-name-and-version)"/>
      
      <!--
        De namen van de volgende input config files kunnen worden opgegeven. 
        Deze bepalen de keuze voor de configuratie bestanden.
        Als mogelijk dan gebruiken we de formele naam+versie zoals gelezen vanuit het aangeboden model.
        
        Zie #503
      -->
      <xsl:sequence select="imf:set-xparm('appinfo/metamodel',($validation-name-and-version, imf:get-xparm('cli/metamodel'))[1])"/>
      <xsl:sequence select="imf:set-xparm('appinfo/tvset',($validation-name-and-version, imf:get-xparm('cli/tvset'))[1])"/>
      <xsl:sequence select="imf:set-xparm('appinfo/visuals',($metamodel-name-and-version, imf:get-xparm('cli/visuals'))[1])"/>
      <xsl:sequence select="imf:set-xparm('appinfo/notesrules',($metamodel-name-and-version, imf:get-xparm('cli/notesrules'))[1])"/>
      <xsl:sequence select="imf:set-xparm('appinfo/docrules',($metamodel-name-and-version, imf:get-xparm('cli/docrules'))[1])"/>
      
    </xsl:template>
    
    <!-- geef een naam als Kadaster-MIM-11 terug -->
  
    <xsl:function name="local:compact" as="xs:string">
      <xsl:param name="values" as="xs:string*"/>
      <xsl:value-of select="string-join(for $v in $values return imf:normalize-space(imf:extract($v,'[A-Za-z0-9]+')),'-')"/>
    </xsl:function>
    
    <xsl:function name="local:value" as="xs:string?">
      <xsl:param name="values" as="xs:string*"/>
      <xsl:sequence select="(for $v in $values return imf:normalize-space(tokenize($v,'#')[1]))[1]"/>
    </xsl:function>
    
    <!-- Geef de genormaliseerde string af als het niet de lege string is. Anders niks. -->
    <xsl:function name="imf:normalize-space" as="xs:string?">
      <xsl:param name="string" as="xs:string?"/>
      <xsl:variable name="ns" select="normalize-space($string)"/>
      <xsl:if test="$ns">
        <xsl:value-of select="$ns"/>
      </xsl:if>
    </xsl:function>
  
</xsl:stylesheet>
