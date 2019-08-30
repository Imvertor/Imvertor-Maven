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
     Reporting stylesheet for Xslt analysis.
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <!-- 
        context document is the parms.xml file. 
    -->
    <xsl:template match="/config">
        <report>
            <step-display-name>MsWord Transfomer</step-display-name>
            <summary>
                <info label="my label">My value</info>
            </summary>
            <page>
                <title>MsWord Transformer report</title>
                <intro>
                    Introduction text here...
                </intro>
                <content>
                    <p>The results of the transformation are listed here. Clicking on a report opens it in a separate browser window.</p>
                    <ul>
                        <xsl:for-each select="imf:get-xparm('appinfo/msword-transformation-result')">
                            <li>
                                Respec report: <a href="../../msword/{.}" target="respec"><xsl:value-of select="."/></a>.
                            </li>
                        </xsl:for-each>
                    </ul>
                </content>
            </page>
        </report>
    </xsl:template>
   
</xsl:stylesheet>
