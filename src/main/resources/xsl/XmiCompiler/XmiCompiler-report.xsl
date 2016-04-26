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
         Reporting stylesheet for the reporting step itself.
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:template match="/config">
        <report>
            <step-display-name>XMI compiler</step-display-name>
            <summary>
                <!-- general -->
                <info label="Invertor version">
                    <xsl:sequence select="imf:report-key-label('Version', 'run','version')"/>
                    <xsl:sequence select="imf:report-key-label('Release', 'run','release')"/>
                </info>
                <info label="Run">
                    <xsl:sequence select="imf:report-key-label('Start', 'run','start')"/>
                </info>
                <info label="Task">
                    <xsl:sequence select="imf:report-key-label('Task', 'cli','task')"/>
                    <xsl:sequence select="imf:report-key-label('Debug', 'cli','debug')"/>
                    <xsl:sequence select="imf:report-key-label('Forced compilation', 'cli','forcecompile')"/>
                </info>
                <info label="Application">
                    <xsl:sequence select="imf:report-key-label('Application', 'cli','application')"/>
                    <xsl:sequence select="imf:report-key-label('Owner', 'cli','owner')"/>
                    <xsl:sequence select="imf:report-key-label('Project', 'cli','project')"/>
                </info>
                <info label="Model">
                    <xsl:sequence select="imf:report-key-label('Metamodel', 'cli','metamodel')"/>
                    <xsl:sequence select="imf:report-key-label('Language', 'cli','language')"/>
                </info>
                
                <!-- specific -->
                <info label="Input file">
                    <xsl:sequence select="imf:report-key-label('UML file', 'cli','umlfile')"/>
                </info>
            </summary>
        </report>
    </xsl:template>

    
</xsl:stylesheet>
