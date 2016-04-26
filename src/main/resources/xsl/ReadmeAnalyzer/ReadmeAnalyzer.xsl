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
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <!--
        This stylesheet grabs processing information on some (attempted) release from the readme file. 
        It stores this info to the config file as appinfo parameters, all starting with "previous-".
        
        This is a poor solution and should be replace by a robust way of passing run info to future imvertor runs.
    -->
    
    <!-- TODO Improve the readme analyzer; mut be a separate doument (signature file) that holds this info. -->
    
    <xsl:template match="/|*">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="i[@class='appinfo']">
        <xsl:analyze-string select="." regex="(#.+?):([^#]+)">
            <xsl:matching-substring>
                <!-- example: #ph:2#ts:release#er:8#re:20150601#dt:2015-07-08 16:50:35# -->
                <xsl:choose>
                    <xsl:when test="regex-group(1)='ph'">
                        <xsl:sequence select="imf:set-config-string('appinfo','previous-phase',regex-group(2))"/>
                    </xsl:when>
                    <xsl:when test="regex-group(1)='ts'">
                        <xsl:sequence select="imf:set-config-string('appinfo','previous-task',regex-group(2))"/>
                    </xsl:when>
                    <xsl:when test="regex-group(1)='er'">
                        <xsl:sequence select="imf:set-config-string('appinfo','previous-errors',regex-group(2))"/>
                    </xsl:when>
                    <xsl:when test="regex-group(1)='re'">
                        <xsl:sequence select="imf:set-config-string('appinfo','previous-release',regex-group(2))"/>
                    </xsl:when>
                    <xsl:when test="regex-group(1)='dt'">
                        <xsl:sequence select="imf:set-config-string('appinfo','previous-date',regex-group(2))"/>
                    </xsl:when>
                    <xsl:when test="regex-group(1)='id'">
                        <xsl:sequence select="imf:set-config-string('appinfo','previous-id',regex-group(2))"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
</xsl:stylesheet>