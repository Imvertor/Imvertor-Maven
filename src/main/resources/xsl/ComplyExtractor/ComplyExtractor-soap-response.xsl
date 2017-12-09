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
  
    xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:stp="http://www.jnc.nl/svs/service/schemas/1.0"
    
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:param name="xmlfile-name">UNKNOWN-FILE</xsl:param>
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:variable name="nl" select="'[nl]'"/>
    <!--
       process the soap response, returns a set of message lines.
    -->    
    <xsl:template match="/soapenv:Envelope/soapenv:Body">
        
        <xsl:variable name="SoapFault" select="soapenv:Fault/detail"/>   
        <xsl:choose>
            <xsl:when test="normalize-space($SoapFault)">
                <xsl:value-of select="concat('(',$xmlfile-name,')F:SOAPFAULT:E:',$SoapFault,$nl)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="ValidationStatus" select=".//stp:ValidationStatus"/>    
                <xsl:variable name="ReportReference" select=".//stp:ReportReference"/>    
                <xsl:variable name="Description" select=".//stp:Description"/>    
                <xsl:variable name="ExecutionStatus" select=".//stp:ExecutionStatus"/>
                
                <!-- S succeeds without warnings, W succeeds with warings, E errors found -->
                <xsl:variable name="status" select="if ($ValidationStatus = 'S') then (if (.//stp:ValidationRule/stp:Status = 'W') then 'W' else 'S') else 'E'"/>
                
                <xsl:for-each select=".//stp:ValidationRule">
                    <xsl:value-of select="concat('STP:(',$xmlfile-name,')',$status,':',stp:Code,':',stp:Status,':',stp:Message,$nl)"/>
                </xsl:for-each>   
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
