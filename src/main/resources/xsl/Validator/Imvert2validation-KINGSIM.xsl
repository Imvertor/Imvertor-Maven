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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    >
    
    <!-- 
        Validation of KING/VNGR SIM models.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
   
    <!-- TODO what special validations for KING SIM? -->
    <xsl:template match="imvert:class">
        <!-- setup -->
        <xsl:variable name="prec-alias" select="preceding::imvert:class[imvert:alias = current()/imvert:alias][1]"/>
        
        <!-- validate -->
       <!--<xsl:sequence select="imf:report-error(., 
            exists(imvert:alias) and $prec-alias, 
            'Duplicate alias [1] not allowed, already occurs on [2]', (imvert:alias,$prec-alias))"/>-->
        
        <xsl:next-match/>
    </xsl:template>    
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
