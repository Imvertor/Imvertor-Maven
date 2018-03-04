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
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Stylesheet to filter parameter file.
    -->
    
    <xsl:template match="cw:file/config" mode="mode-intermediate-parms">
        <xsl:copy>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ignore the following: -->
    <xsl:template match="
        config/run/start |
        config/run/time |
        config/system/generation-id |
        config/system/zip-release-filepath |
        config/appinfo/release-name |
        config/appinfo/generation-id |
        config/appinfo/*[starts-with(.,'previous-')] |
        config/test |
        config/step" 
        mode="mode-intermediate-parms">
        <xsl:call-template name="ignore"/>
    </xsl:template>
    
    <!-- avoid warnings on different IDs in:
        
         <message>
            ...
            <steptext>The supplier "regression/SampleBase/20130318" is in phase "2". Are you sure you want to derive from that model?</steptext>
            <id>regression-SampleBase-1.0.0-2-20130318-20170520-132141</id>
         
         This is a brute force approach.
     -->
    <xsl:template match="config/messages/message/id" mode="mode-intermediate-parms">
        <xsl:call-template name="ignore"/>
    </xsl:template>
    
</xsl:stylesheet>
