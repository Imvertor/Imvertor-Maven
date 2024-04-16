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
         Reporting stylesheet for MIM compiler
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
   
    <xsl:template match="/config">
        <report>
            <step-display-name>MIM compiler</step-display-name>
            <status/>
            <summary>
                <info label="Status">
                    <xsl:sequence select="imf:report-key-label('Format created succesfully','system','mim-compiler-format-created')"/>
                    <xsl:sequence select="imf:report-key-label('MIM version','system','mim-compiler-mim-version')"/>
                    <xsl:sequence select="imf:report-key-label('Formattype','system','mim-compiler-format-type')"/>
                    <xsl:sequence select="imf:report-key-label('Formatter version','system','mim-compiler-format-version')"/>
                    <xsl:sequence select="imf:report-key-label('Model typering','system','mim-compiler-model-typering')"/>
                </info>
            </summary>
       </report>
    </xsl:template>
        
</xsl:stylesheet>
