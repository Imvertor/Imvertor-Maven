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
    
    >
    
    <!-- 
        Validation of Kadaster MIM 1.0 models. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    
    <xsl:template match="imvert:class">
        
        <!-- setup -->
        <xsl:variable name="this-id" select="imvert:id"/>
        <xsl:variable name="is-associationclass" select="$document-classes//imvert:association-class/imvert:type-id = $this-id"/>
        
        <!-- only allow association classes; do not allow on regular classes -->
        <xsl:sequence select="imf:report-error(., 
            $is-associationclass and not(imvert:stereotype/@id = ('stereotype-name-relatieklasse')), 
            'Association class must be stereotyped as [1]',imf:get-config-stereotypes('stereotype-name-relatieklasse'))"/>
        <xsl:sequence select="imf:report-error(., 
            not($is-associationclass) and imvert:stereotype/@id = ('stereotype-name-relatieklasse'), 
            'Class that is not an association class may not be stereotyped as [1]',imf:get-config-stereotypes('stereotype-name-relatieklasse'))"/>
        
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="node()"> 
        <xsl:apply-templates/>
    </xsl:template> 
    
</xsl:stylesheet>
