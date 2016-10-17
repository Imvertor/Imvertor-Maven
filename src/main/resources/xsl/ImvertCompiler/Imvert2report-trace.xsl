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

    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!-- 
        Compile Tracing info. This is:
        type | client-name+link | client-package | client-class | client-property | supplier-name+link |supplier-package | supplier-class | supplier-property 
        
    -->
    
    <xsl:template match="imvert:packages" mode="trace">
        
        <xsl:variable name="supplier-subpaths" select="imf:get-trace-all-supplier-subpaths(.)" as="xs:string*"/>
      
        <!-- 
            return a trace documentation page only when deriving; this is the case when any trace has been set. 
        -->
        <xsl:if test=".//imvert:trace[1]">
            <!--TODO how to represent proxy? -->
            <page>
                <title>Derivation Traces</title>
                <content>
                    <div>
                        <div class="intro">
                            <p>
                                This is a technical overview of all traces explicitly created between classes, attributes and associations. 
                            </p>
                            <p>
                                The full name of the construct is shown (Package::Class.property), along with the ID. 
                                Each construct in a column on the right represents a supplier for some construct in a column on the left.
                            </p>
                        </div>
                        <xsl:variable name="rows" as="element(tr)*">
                            <xsl:for-each select=".//*[local-name() = $all-traced-construct-names]">
                                <!-- fetch the suppliers -->
                                <xsl:variable name="suppliers" select="imf:get-trace-suppliers-for-construct(.,1)"/>
                                <xsl:for-each select="$suppliers[1]"><!-- singleton, start at client and process columns by all suppliers -->
                                    <xsl:choose>
                                        <xsl:when test="@type = 'class'">
                                            <tr>
                                                <td>
                                                    <xsl:value-of select="@type"/>
                                                </td>
                                                <xsl:sequence select="imf:get-trace-documentation-columns($suppliers,$supplier-subpaths)"/>
                                            </tr>
                                        </xsl:when>
                                        <xsl:when test="@type = ('attribute','enumeration')">
                                            <tr>
                                                <td>&#160;&#8212;<xsl:value-of select="@type"/></td>
                                                <xsl:sequence select="imf:get-trace-documentation-columns($suppliers,$supplier-subpaths)"/>
                                            </tr>
                                        </xsl:when>
                                        <xsl:when test="@type = ('association','composition')">
                                            <tr>
                                                <td>&#160;&#8212;<xsl:value-of select="@type"/></td>
                                                <xsl:sequence select="imf:get-trace-documentation-columns($suppliers,$supplier-subpaths)"/>
                                            </tr>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:variable>
                        <!-- 
                            When no suppliers, a single supplier is returned. 
                            This must be shown as it clearly indicates that a construct is *not* traced. 
                        -->
                        <xsl:variable name="cols" select="count($supplier-subpaths)"/>
                        <xsl:variable name="colwidth" select="90 div (if ($cols = 0) then 1 else $cols)"/>
                        <xsl:variable name="h2" select="string-join(($supplier-subpaths,''),concat(':',$colwidth,','))"/>
                        <xsl:variable name="h3" select="concat('type:10,',$h2)"/>
                            
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,$h3,'table-trace')"/>
                    </div>
                </content>
            </page>
        </xsl:if>
    </xsl:template>
 
    <xsl:function name="imf:get-trace-documentation-columns">
        <xsl:param name="suppliers" as="element(supplier)*"/>
        <xsl:param name="supplier-subpaths" as="xs:string*"/>
        
        <!-- use the number of subpaths as the number of columns to fill -->
        <xsl:for-each select="$supplier-subpaths">
            <xsl:variable name="current-subpath" select="."/>
            <xsl:variable name="suppliers-for-this-subpath" select="$suppliers[@subpath = $current-subpath]"/>
            <!-- go through all suppliers, any group may have 1..n suppliers (multiple supplier issue) -->
            <xsl:choose>
                <xsl:when test="exists($suppliers-for-this-subpath)">
                    <xsl:for-each-group select="$suppliers-for-this-subpath" group-by="@subpath">
                        <td>
                            <xsl:for-each select="current-group()">
                                <xsl:choose>
                                    <xsl:when test="self::error">
                                        <span class="error">
                                            <xsl:value-of select="@type"/>
                                        </span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@display-name"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <span class="tid">
                                    <xsl:value-of select="@id"/>
                                </span>
                            </xsl:for-each>
                        </td>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <td></td>
                </xsl:otherwise>
              </xsl:choose>
           </xsl:for-each>
      </xsl:function>
     
</xsl:stylesheet>
