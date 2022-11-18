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
    expand-text="yes"
    version="3.0">
    
    <!-- 
        Create simple metamodel representation from the config file
    -->
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-report.xsl"/>
    
    <xsl:variable name="relatiesoort-leidend" select="true()"/>

    <xsl:template match="/config">
        <xsl:variable name="metamodel" select="metamodel"/>
        <xsl:variable name="visuals" select="visuals"/>
        <xsl:variable name="tagged-values" select="tagset/tagged-values"/>
        
        <metamodel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="./xsd/metamodel/metamodel.xsd">
            <modelelementen>
                <xsl:apply-templates select="metamodel/stereotypes/stereo">
                    <xsl:sort select="name"/>
                </xsl:apply-templates>    
            </modelelementen>
            <metagegevens>
                <xsl:apply-templates select="tagset/tagged-values/tv">
                    <xsl:sort select="name"/>
                </xsl:apply-templates> 
            </metagegevens>
        </metamodel>
    </xsl:template>
    
    <xsl:template match="stereo">
        <xsl:variable name="id" select="@id"/>
        <modelelement>
            <naam>
                <xsl:variable name="name" select="imf:start-upper-case(name/@original)"/>
                <xsl:choose>
                    <xsl:when test="@id = 'stereotype-name-relatiesoort' and $relatiesoort-leidend">{$name} - Relatiesoort leidend</xsl:when>
                    <xsl:when test="@id = 'stereotype-name-relatiesoort' and not($relatiesoort-leidend)">{$name} - Relatierol leidend</xsl:when>
                    <xsl:when test="@id = 'stereotype-name-relation-role' and $relatiesoort-leidend">{$name} - Relatiesoort leidend</xsl:when>
                    <xsl:when test="@id = 'stereotype-name-relation-role' and not($relatiesoort-leidend)">{$name} - Relatierol leidend</xsl:when>
                    <xsl:otherwise>{$name}</xsl:otherwise>
                </xsl:choose>
            </naam>
            <xsl:for-each select="/config/tagset/tagged-values/tv">
                <xsl:sort select="name"/>
                <xsl:variable name="tv" select="."/>
                <xsl:for-each select="stereotypes/stereo[@id = $id]">
                    <metagegeven kardinaliteit="{imf:correct-minmax(@minmax)}">
                        <xsl:value-of select="imf:start-upper-case($tv/name)"/>
                    </metagegeven>
                </xsl:for-each>
            </xsl:for-each>
        </modelelement>
    </xsl:template> 
    
    <xsl:template match="tv">
        <metagegeven>
            <naam>
                <xsl:value-of select="imf:start-upper-case(name)"/>
            </naam>
            <xsl:for-each select="stereotypes/stereo">
                <xsl:sort select="name"/>
                <modelelement kardinaliteit="{imf:correct-minmax(@minmax)}">
                    <xsl:variable name="id" select="@id"/>
                    <xsl:variable name="name" select="imf:start-upper-case($configuration-file//*[@id=$id]/name/@original)"/>
                    <xsl:choose>
                        <xsl:when test="@id = 'stereotype-name-relatiesoort' and $relatiesoort-leidend">{$name} - Relatiesoort leidend</xsl:when>
                        <xsl:when test="@id = 'stereotype-name-relatiesoort' and not($relatiesoort-leidend)">{$name} - Relatierol leidend</xsl:when>
                        <xsl:when test="@id = 'stereotype-name-relation-role' and $relatiesoort-leidend">{$name} - Relatiesoort leidend</xsl:when>
                        <xsl:when test="@id = 'stereotype-name-relation-role' and not($relatiesoort-leidend)">{$name} - Relatierol leidend</xsl:when>
                        <xsl:otherwise>{$name}</xsl:otherwise>
                    </xsl:choose>
                </modelelement>
            </xsl:for-each>
        </metagegeven>
    </xsl:template> 
    
    <xsl:function name="imf:start-upper-case">
        <xsl:param name="name"/>
        <xsl:value-of select="upper-case(substring($name,1,1)) || substring($name,2)"/>
    </xsl:function>
    
    <xsl:function name="imf:correct-minmax">
        <xsl:param name="minmax"/>
        <xsl:value-of select="if ($minmax = '1..1') then '1' else $minmax"/>
    </xsl:function>
    
</xsl:stylesheet>
