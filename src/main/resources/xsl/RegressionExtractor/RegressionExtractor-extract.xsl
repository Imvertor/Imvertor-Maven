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
    xmlns:imvert-history="http://www.imvertor.org/schema/history"
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Stylesheet to filter ANY xml file found in the tst or ref folder.
         This XSL is generic, and therefore calls upon any imported XSL (or such) to process specific types of file.
         The root element of the file found is passed in a wrapper element:
         
         <cw:file 
            type="{bin or xml}" 
            path="{relative path to the root of the main folder, including name of the file}" 
            date="{integer representation of date}" 
            name="{name of the file}" 
            ishidden="{boolean}" 
            isreadonly="{boolean}" 
            ext="{extension}" 
            fullpath="{full canonical path}"/>
         
         Note that date/time attribute and size attribute typically should be removed for regression comparisons.
         The other *:file data should be passed for reporting purposes.
         
         The folder passed holds the folders/files:
         /job/*
         /work/*
         /executor.imvert.xml
      -->
    
    <xsl:include href="RegressionExtractor-imvert.xsl"/>
    <xsl:include href="RegressionExtractor-imvert-schema.xsl"/>
    <xsl:include href="RegressionExtractor-config.xsl"/>
    <xsl:include href="RegressionExtractor-history.xsl"/>
    <xsl:include href="RegressionExtractor-office-html.xsl"/>
    <xsl:include href="RegressionExtractor-xsd.xsl"/>
    <xsl:include href="RegressionExtractor-schemas.xsl"/>
    <xsl:include href="RegressionExtractor-parms.xsl"/>
    
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
    
    <xsl:template match="/"> <!-- let op! deze extractor wordt aangeroepen op cw:file root elementen! -->
        <xsl:apply-templates select="cw:file"/>
    </xsl:template>
  
    <xsl:template match="cw:file">
        <xsl:variable name="path" select="replace(@path, '\\','/')"/>
        <xsl:choose>
            <!--
              no job info is compared. 
            -->
            <xsl:when test="starts-with($path, 'job/')">
                <!-- ignore -->
            </xsl:when>
            <!-- 
                skip all XMI files 
            -->
            <xsl:when test="lower-case(@ext) = ('xmi')">
                <!-- ignore -->
            </xsl:when>
            <!-- 
                skip all binary files. 
                Assume that all differences in output can be explained by looking at the XML intermediate results. 
            -->
            <xsl:when test="@type = 'bin'">
                <!-- ignore -->
            </xsl:when>
            <!-- 
                skip this one: this file is passed when you simply copy the zip folder to the ref folder. It should not be checked.
            -->
            <xsl:when test="$path = 'executor.imvert.xml'">
                <!-- ignore -->
            </xsl:when>
            <!-- 
               No not Process XML intermediate results. 
            -->
            <xsl:when test="starts-with($path,'work/imvert/')">
                <!-- ignore -->
                <?x
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:choose>
                        <!--
                            intermediate imvert files 
                        -->
                        <xsl:when test="@type='xml' and exists((imvert:packages,imvert:package-dependencies))">
                            <xsl:apply-templates mode="mode-intermediate-imvert"/>
                        </xsl:when>
                        <!--
                            intermediate config file 
                        -->
                        <xsl:when test="@type='xml' and exists(config)">
                            <xsl:apply-templates mode="mode-intermediate-config"/>
                        </xsl:when>
                        <!--
                            intermediate validation result file; ignore the contents 
                            (imvertor.13.validate.xml imvertor.15.derive.xml )
                        -->
                        <xsl:when test="@type='xml' and exists(imvert:report)">
                            <!-- ignore -->
                        </xsl:when>
                        <!--
                           office file
                        -->
                        <xsl:when test="@ext='html'">
                            <xsl:apply-templates mode="mode-intermediate-office-html"/>
                        </xsl:when>
                        <!--
                            Check the history file
                        -->
                        <xsl:when test="@type='xml' and exists(imvert-history:versions)">
                            <xsl:apply-templates mode="mode-intermediate-history"/>
                        </xsl:when>
                        <!--
                            Check the model schema file
                        -->
                        <xsl:when test="@type='xml' and exists(imvert-result:Application)">
                            <xsl:apply-templates mode="mode-intermediate-imvert-schema"/>
                        </xsl:when>
                        <!--
                            Check the model schema file
                        -->
                        <xsl:when test="@type='xml' and exists(imvert:schemas)">
                            <xsl:apply-templates mode="mode-intermediate-schemas"/>
                        </xsl:when>
                        <!--
                            do not Check the run file
                        -->
                        <xsl:when test="@type='xml' and exists(no-output)"/>
                        
                        <xsl:otherwise>
                            <xsl:value-of select="concat('unexpected intermediate file: ', $path, ' - cannot compare')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
                x?>
            </xsl:when>
            <!-- 
                reports
            -->
            <xsl:when test="starts-with($path,'work/rep')">
                <!-- do not check -->
            </xsl:when>
            <!--
               skip etc folder; only holds stuf that is already checked in intermediate steps.
            -->
            <xsl:when test="starts-with($path, 'work/app/etc')">
                <!-- ignore -->
            </xsl:when>
            <!--
               Check the catalogue
            -->
            <xsl:when test="starts-with($path, 'work/app/cat')">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            
            <!-- process the EA profile -->
            <xsl:when test="starts-with($path, 'work/app/ea')">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            
            <!-- skip the compare XSL -->
            <xsl:when test="starts-with($path, 'work/compare')">
                <!-- ignore -->
            </xsl:when>
            
            <!-- skip the profile info -->
            <xsl:when test="starts-with($path, 'work/profile')">
                <!-- ignore -->
            </xsl:when>
            
            <!-- process the compliancy info -->
            <xsl:when test="starts-with($path, 'work/TODO')"><!-- TODO speelt dit nog? -->
                <!-- ignore -->
            </xsl:when>
            
            <!--
              documentation is not compared 
            -->
            <xsl:when test="starts-with($path, 'work/app/doc')">
                <!-- ignore -->
            </xsl:when>
            <!--
              work xsd (supporting stuff) is not compared 
            -->
            <xsl:when test="starts-with($path, 'work/app/etc/xsd')">
                <!-- ignore -->
            </xsl:when>
            <!--
              generated XSD is compared 
            -->
            <xsl:when test="starts-with($path, 'work/app/xsd')">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:apply-templates mode="mode-intermediate-xsd"/>
                </xsl:copy>
            </xsl:when>
            <!--
              parms.xml is compared 
            -->
            <xsl:when test="starts-with($path, 'work/parms.xml')">
                <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name(.) = ('date','size','fullpath'))]"/>
                    <xsl:apply-templates mode="mode-intermediate-parms"/>
                </xsl:copy>
            </xsl:when>
            <!--
              skip the tracker info 
            -->
            <xsl:when test="@name = 'track.txt'">
               <!-- ignore -->
            </xsl:when>       
            
            <xsl:otherwise>
                <error>
                    <xsl:value-of select="concat('Unexpected output file: ', $path, ' - cannot compare this resource')"/>
                </error>   
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*|text()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ignore all comments and pi's -->
    <xsl:template match="comment() | processing-instruction()" mode="#all"/>
    
    <xsl:template name="ignore">
        <xsl:value-of select="'&#10;'"/>
        <xsl:comment>IGNORED</xsl:comment>
        <xsl:value-of select="'&#10;'"/>
    </xsl:template>
    
</xsl:stylesheet>
