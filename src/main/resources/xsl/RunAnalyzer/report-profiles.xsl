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
      Report on the profile generated (if any).
    -->
    
    <xsl:decimal-format name="us" decimal-separator='.' grouping-separator=',' />
    
    <xsl:template match="/profiles" mode="doc-profiles">
        
        <xsl:variable name="total-xsl" select="sum(file/trace/@t-total) * 1000"/>
        <xsl:variable name="total-run" select="xs:float(@total) * 1000000"/>
        <page>
            <title>Profile info</title>
            <content>
                <div>
                    <h1>Introduction</h1>
                    <div class="intro">
                        <p>
                            This is the complete listing of all profile info on the selected stylesheets.
                            The profile selected as a CLI parameter is: <xsl:value-of select="imf:get-config-string('cli','profilemode')"/>.
                        </p>
                        <p>
                            Total time for all transformations registered by profiler is: 
                            <xsl:value-of select="imf:format($total-xsl)"/>  milliseconds
                            of an overall runtime of 
                            <xsl:value-of select="imf:format($total-run)"/> milliseconds (excluding windup).
                        </p>
                        <p>
                            All times are in msec.
                        </p>
                        <p>
                            In order to understand the most time consuming parts of the transformation process, look at the number of calls to a routine, in combination with the net time for that routine.
                            For example, a routine that is reasonably fast but called a huge number of times will slow down. It may be sensible to improve that code.
                            A routine that is slow but called a few times, may not have great impact on the total run time.
                            
                        </p>
                        <p>
                            Columns are:
                            <ul>
                                <li>Routine - name of the routine and the file from which it is called</li>
                                <li>In files - number of files fromw hich it is called</li>
                                <li>Count - total number of calls</li>
                                <li>Average time (gross) - Mean time including all subroutines</li>
                                <li>Total time (gross) - Total time including all subroutines</li>
                                <li>Average time (net) - Mean time excluding all subroutines</li>
                                <li>Total time (net) - Total time excluding all subroutines</li>
                            </ul>
                        </p>
                    </div> 
                </div>
                <div>
                    <h1>Overall profile</h1>
                    <table class="tablesorter"> 
                        <xsl:variable name="rows" select="imf:create-rows(file/trace/fn)" as="element(tr)*"/>
                        <xsl:sequence select="imf:create-result-table-by-tr($rows,'routine:40,in files:10, count:10,average time (gross):10,total time (gross):10,average time (net):10,total time (net):10','table-meta')"/>
                    </table>
                </div>
                <xsl:for-each select="/profiles/file">
                    <xsl:sort select="number(trace/@t-total)" order="descending"/>
                    <div>
                        <h1><xsl:value-of select="concat(imf:get-display-file-name(.),' - ', number(trace/@t-total), ' msecs')"/></h1>
                        <table class="tablesorter"> 
                            <xsl:variable name="rows" select="imf:create-rows(trace/fn)" as="element(tr)*"/>
                            <xsl:sequence select="imf:create-result-table-by-tr($rows,'routine:40,in files:10, count:10,average time (gross):10,total time (gross):10,average time (net):10,total time (net):10','table-meta')"/>
                        </table>
                    </div>
                </xsl:for-each>
            </content>
        </page>
    </xsl:template>
         
    <!-- pass nanoseconds, return milliseconds with 3 decimals -->
    <xsl:function name="imf:format">
        <xsl:param name="n"/>
        <xsl:value-of select="format-number($n div 1000000,'######.###','us')"/>
    </xsl:function>
    
    <xsl:function name="imf:get-display-file-name">
        <xsl:param name="f" as="element()"/>
        <xsl:value-of select="tokenize($f/@path,'[\\/]')[last()]"/>
    </xsl:function>
    
    <xsl:function name="imf:create-rows">
        <xsl:param name="fn-sequence"/>
        <xsl:for-each-group select="$fn-sequence" group-by="concat(@construct,': ', @name)">
            <xsl:sort select="sum(current-group()/@t-sum-net)" order="descending"/>
            
            <xsl:variable name="group" select="current-group()"/>
            <xsl:variable name="count" select="sum($group/@count)"/>
            <xsl:variable name="t-sum" select="sum($group/@t-sum)"/>
            <xsl:variable name="t-sum-net" select="sum($group/@t-sum-net)"/>
            <xsl:variable name="in-files" select="current-group()/../.."/>
            <tr>
                <td>
                    <xsl:value-of select="current-grouping-key()"/> 
                    <br/>
                    <span class="tid">
                        <xsl:value-of select="string-join(for $f in $in-files return imf:get-display-file-name($f),', ')"/>
                    </span>
                </td>
                <td>
                    <xsl:value-of select="count($in-files)"/> 
                </td>
                <td>
                    <xsl:value-of select="$count"/> 
                </td>
                <td>
                    <xsl:value-of select="imf:format($t-sum div $count)"/> 
                </td>
                <td>
                    <xsl:value-of select="imf:format($t-sum)"/> 
                </td>
                <td>
                    <xsl:value-of select="imf:format($t-sum-net div $count)"/> 
                </td>
                <td>
                    <xsl:value-of select="imf:format($t-sum-net)"/> 
                </td>
            </tr>
        </xsl:for-each-group>
    </xsl:function>
</xsl:stylesheet>
