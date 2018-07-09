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
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
         Stylesheet to filter the schema file (in accordance with Imvert XSD).
    -->
    
    <xsl:template match="cw:file/imvert-result:Application" mode="mode-intermediate-imvert-schema">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
        ignore the following alltogether 
    -->
    <xsl:template match="
        imvert-result:filters |
        imvert-result:generated |
        imvert-result:generator |
        imvert-result:debug |
        imvert-result:exported |
        imvert-result:exporter |
        imvert-result:Identifiable/imvert-result:id |
        imvert-result:Released/imvert-result:created |
        imvert-result:Released/imvert-result:modified" 
        mode="mode-intermediate-imvert-schema">
        <xsl:call-template name="ignore"/>
    </xsl:template>
    
    <xsl:template match="imvert-result:TaggedValue[imvert-result:id = 'CFG-TV-VERSIONID']" mode="mode-intermediate-imvert-schema">
        <xsl:call-template name="ignore"/>
    </xsl:template>

  

</xsl:stylesheet>
