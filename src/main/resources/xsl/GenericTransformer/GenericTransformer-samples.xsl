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
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
        Introduce wrappers to the extension functions
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="/*">
    
        <result>
            <messaging>
                <!-- 
                    Messages are passed through to a special messenger object. 
                    This checks the contents of the message and acts accordingly:
                    * if a string, this is displayed directly.
                    * if an xml element structure, it is appended as a message to the XML configuration, and is thus available for (postponed) processing.  
                -->    
                
                <!-- A regular message, passed to the screen directly --> 
                <xsl:message select="'hello, world!'"/>
                
                <!-- A message that should be handeled as a true signal of error, warning or the like -->
                <xsl:message>
                    <xsl:sequence select="imf:create-output-element('src',$xml-stylesheet-name)"/>
                    <xsl:sequence select="imf:create-output-element('type','ERROR')"/>
                    <xsl:sequence select="imf:create-output-element('name','name1')"/>
                    <xsl:sequence select="imf:create-output-element('text','text1')"/>
                    <xsl:sequence select="imf:create-output-element('info','info1')"/>
                </xsl:message>
                
                <!-- 
                    Such messages are however created by the decidated function imf:msg(). This function returns the empty sequence.
                    Note that the types are based on log4j message types, zee 
                    https://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/Level.html
                -->
                <xsl:sequence select="imf:msg('TRACE','trace text')"/>
                <xsl:sequence select="imf:msg('INFO','info text')"/>
                <xsl:sequence select="imf:msg('DEBUG','debug text')"/>
                <xsl:sequence select="imf:msg('WARN','warning text')"/>
                
                <!-- parameters are represented as [n] in de error text; pass a sequence of objects to be inserted into the text -->
                <xsl:sequence select="imf:msg('ERROR','error text [1]','parm')"/>
                
                <!-- 
                    provide an element as first parameter, which is registered as the context of the error, and represented by display name.
                    Display names for Imvertor elements are based on the Package::Class.property format.
                    Dispaly names for other elements are based on xpath format such as /e/e[1].
                -->
                <xsl:sequence select="imf:msg(.//XMI.documentation[1],'ERROR','error text [1], [2]',('parm1','parm2'))"/>
                
                <!-- 
                    This message will be fatal and immediately cancels the application:
                -->
                <!--<xsl:sequence select="imf:msg('FATAL','infotext')"/>-->
                
                <!-- A message which content cannot be processed by the messenger; it is written but not displayed or logged. -->
                <xsl:message>
                    <testField1>testvalue1</testField1>
                    <testField2>testvalue2</testField2>
                </xsl:message>
                
            </messaging>
            <!-- 
                Information on type, path, availability of files are essential for processing. Imvertor provides an extension function for this.
            -->
            
            <!-- get a sequence of file specification info -->
            <filespec>
                <xsl:sequence select="string-join(imf:filespec('c:/temp'),'|')"/>
            </filespec>
            
            <!--
                Access to the configuration file takes the form of 
                * access to the $configuration parameter
                * Extension function for reading, adding, removing a parameter, and saving the configuration  
            -->
            <configuration-by-xpath>
                <xsl:value-of select="$configuration/config/run/start"/>
            </configuration-by-xpath>        
            <configuration-by-function>
                <get>
                    <xsl:sequence select="imf:get-config-string('run','start')"/>
                </get>
                <create>
                    <simple>
                        <xsl:sequence select="imf:set-config-string('configuration-by-function','simple-variable','value')"/>
                        <xsl:sequence select="imf:get-config-string('configuration-by-function','simple-variable')"/>
                    </simple>
                    <complex>
                        <xsl:sequence select="imf:set-config-string('configuration-by-function','subpath/complex-variable','value')"/>
                        <xsl:sequence select="imf:get-config-string('configuration-by-function','subpath/complex-variable')"/>
                    </complex>
                </create>
                <duplicate>
                    <simple>
                        <xsl:sequence select="imf:set-config-string('configuration-by-function','simple-variable','value2')"/>
                        <regular>
                            <xsl:sequence select="imf:get-config-string('configuration-by-function','simple-variable')"/>
                        </regular>
                        <indexed>
                            <xsl:sequence select="imf:get-config-string('configuration-by-function','simple-variable[2]')"/>
                        </indexed>
                        <last>
                            <xsl:sequence select="imf:get-config-string('configuration-by-function','simple-variable[last()]')"/>
                        </last>
                    </simple>
                    <complex>
                        <xsl:sequence select="imf:set-config-string('configuration-by-function','subpath/complex-variable','value2')"/>
                        <path>
                            <xsl:sequence select="imf:get-config-string('configuration-by-function','subpath/*[2]')"/>
                        </path>
                    </complex>
                </duplicate>
                <remove>
                    <xsl:sequence select="imf:remove-config('configuration-by-function','simple-variable')"/>
                    <xsl:sequence select="imf:get-config-string('configuration-by-function','simple-variable')"/> <!-- returns empty sequence -->
                </remove>
                <save-the-file>
                    <xsl:sequence select="imf:save-config-file()"/>
                </save-the-file>
            </configuration-by-function>
            
            <extension-functions>
                <excel-processing>
                    <xsl:variable name="inexcelfile" select="imf:get-config-string('cli','inexcelfile')"/>
                    <xsl:variable name="outexcelfile" select="imf:get-config-string('cli','outexcelfile')"/>
                    <xsl:variable name="workfolder" select="concat(imf:get-config-string('properties','TESTER_SERIALIZER_WORK_PATH'),'/temp-folder')"/>
                    <xsl:variable name="folder" select="imf:serializeFromZip($inexcelfile,$workfolder)"/>
                    <xsl:variable name="file" select="imf:deserializeToZip($folder,$outexcelfile)"/>
                    <xsl:message select="$folder"/>
                    <xsl:message select="$file"/>
                </excel-processing>
            </extension-functions>
        </result>
        
        
    </xsl:template>
    
</xsl:stylesheet>
