<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ekf="http://EliotKimber/functions"
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/> 
    
    <xsl:param name="output-folder-path"/>
    
    <xsl:variable name="output-folder-url" select="imf:file-to-url($output-folder-path)"/>
   
    <xsl:template match="/analysis">
        
        <root/>
        
        <!-- create frameset -->
        <xsl:result-document href="{$output-folder-url}/index.html" method="html">
            <html>
                <xsl:sequence select="imf:create-html-head(.,'XsltAnalysis')"/>
                <frameset cols="30%,70%" title="Xslt Analysis">
                    <frame src="toc.html" name="toc" title="Table of contents"/>
                    <frame src="content.html" name="contents" title="Contents"/>
                    <noframes>
                        <h2>Frame Alert</h2>
                        <p>This document is designed to be viewed using the frames feature. If you see this message, you are using a non-frame-capable web client.</p>
                    </noframes>
                </frameset>
            </html>      
        </xsl:result-document> 
        
        <xsl:result-document href="{$output-folder-url}/toc.html" method="html">
            <html>
                <xsl:sequence select="imf:create-html-head(.,'XsltAnalysis TOC')"/>
                <body>
                    <xsl:apply-templates select="." mode="toc"/>
                </body>
            </html>
        </xsl:result-document> 
        
        <xsl:result-document href="{$output-folder-url}/content.html" method="html">
            <html>
                <xsl:sequence select="imf:create-html-head(.,'XsltAnalysis CONTENT')"/>
                <body>
                    <xsl:apply-templates/>
                </body>
            </html>
        </xsl:result-document> 
        
    </xsl:template>
   
    <!-- == TOC ORIENTED == -->
    
    <xsl:template match="/analysis" mode="toc">
        <ul>
            <xsl:for-each select="stylesheet">
                <xsl:sort select="path"/>
                <li>
                    <a href="content.html#STYLESHEET_{path}" target="contents">
                        <xsl:variable name="toks" select="tokenize(path,'/')"/>
                        <xsl:value-of select="string-join(subsequence($toks,1,count($toks) - 1),'/')"/>
                        /
                        <b>
                            <xsl:value-of select="$toks[last()]"/>
                        </b>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>   
    
    <xsl:template match="node()" mode="toc">
        <!-- skip -->
    </xsl:template>   
    
    
    <!-- == CONTENT ORIENTED == -->
    <xsl:template match="stylesheet">
        <div id="STYLESHEET_{path}">
            <h1>
                Stylesheet: <xsl:value-of select="path"/>
            </h1>
            <table>
                <col style="width:30%"/>
                <col style="width:30%"/>
                <col style="width:40%"/>
                <thead>
                    <tr>
                        <th>Imports</th>
                        <th>Params and variables</th>
                        <th>Functions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <xsl:apply-templates select="imports"/>   
                        <td>
                            <xsl:apply-templates select="params/param"/>   
                            <hr/>
                            <xsl:apply-templates select="variables/variable"/>   
                        </td>
                        <xsl:apply-templates select="functions"/>
                    </tr>
                </tbody>   
            </table>
            
            <xsl:apply-templates select="functions" mode="detail"/>
            
        </div>
    </xsl:template>   
    
    <xsl:template match="imports">
        <td>
            <xsl:apply-templates select="import"/>
            <hr/>
            <xsl:apply-templates select="imported-by"/>
        </td>
    </xsl:template>

    <xsl:template match="import">
        <xsl:variable name="path" select="path"/>
        <p>
            Imports<br/>
            <b>
                <a href="#STYLESHEET_{$path}">
                    <xsl:value-of select="$path"/>
                </a>
            </b>
            <xsl:variable name="c" select="count(/analysis/stylesheet[path = $path]/imports/import)"/>
            <xsl:if test="$c != 0">
                <br/>
                <xsl:value-of select="concat('Which imports ',$c)"/>
            </xsl:if>
        </p>
    </xsl:template>
    
    <xsl:template match="imported-by">
        <xsl:variable name="path" select="path"/>
        <p>
            <xsl:variable name="c">
                <a href="#STYLESHEET_{$path}">
                    <xsl:value-of select="$path"/>
                </a>
            </xsl:variable>
            <xsl:sequence select="imf:create-entry('Imported by',$c)"></xsl:sequence>
        </p>
    </xsl:template>
    
    <xsl:template match="params">
        <td>
            <xsl:apply-templates select="param"/>
        </td>
    </xsl:template>
    
    <xsl:template match="function/params/param">
        <p id="VARIABLE_{name}" class="fparam">
            <xsl:sequence select="imf:create-entry('Declares param',concat('D$',name))"></xsl:sequence>
        </p>
    </xsl:template>
    
    <xsl:template match="stylesheet/params/param">
        <p id="VARIABLE_{name}">
            <xsl:sequence select="imf:create-entry('Declares param',concat('D$',name))"></xsl:sequence>
        </p>
    </xsl:template>
    
    <xsl:template match="variable-calls">
        <td>
            <xsl:for-each-group select="variable-call" group-by="name">
                <xsl:sort select="name"/>
                <xsl:apply-templates select="current-group()[1]"/>
            </xsl:for-each-group>
        </td>
    </xsl:template>
    
    <xsl:template match="variable-call">
        <p class="{if (@local = 'true') then 'local-call' else 'global-call'}">
            <a href="#VARIABLE_{name}">
                <xsl:sequence select="imf:create-entry('Calls variable',concat('C$',name))"/>
            </a>
        </p>
    </xsl:template>
    
    <xsl:template match="function-calls">
        <td>
            <xsl:for-each-group select="function-call" group-by="name">
                <xsl:sort select="name"/>
                <xsl:apply-templates select="current-group()[1]"/>
            </xsl:for-each-group>
        </td>
    </xsl:template>

    <xsl:template match="function-call">
        <p class="{if (@local = 'true') then 'local-call' else 'global-call'}">
            <a href="#FUNCTION_{name}">
                <xsl:sequence select="imf:create-entry('Calls function',concat('C%',name))"/>
            </a>
        </p>
    </xsl:template>
    
    <xsl:template match="variables">
        <td>
            <xsl:apply-templates select="variable"/>
        </td>
    </xsl:template>
    
    <xsl:template match="variable">
        <xsl:variable name="stylesheet" select="ancestor::stylesheet"/>
        <xsl:variable name="name" select="name"/>
        
        <xsl:variable name="declarations" as="element()*">
            <xsl:for-each select="/analysis/stylesheet[not(. is $stylesheet) and (variables/variable/name,params/param/name) = $name]">
                <xsl:variable name="path" select="path"/>
                <a href="#STYLESHEET_{$path}">
                    <xsl:value-of select="$path"/>
                </a>
            </xsl:for-each>
        </xsl:variable>
        
        <p id="VARIABLE_{$name}">
            <xsl:variable name="c">
                <xsl:value-of select="concat('D$',$name)"/>   
                <xsl:if test="$declarations">
                    <br/>
                    <span class="warning">
                        #WARNING Also declared in: 
                        <xsl:for-each select="$declarations">
                            <br/>
                            <xsl:sequence select="."/>
                        </xsl:for-each>
                    </span>
                </xsl:if>
            </xsl:variable>
            <xsl:sequence select="imf:create-entry('Declares variable',$c)"/>
        </p>
    </xsl:template>
    
    <xsl:template match="functions">
        <td>
            <xsl:apply-templates select="function"/>
        </td>
    </xsl:template>
    
    <xsl:template match="function">
        <p>
            <xsl:variable name="c">
                <a href="#FUNCTION_{name}">
                    <xsl:value-of select="concat('D%',template)"/>
                </a>
            </xsl:variable>
            <xsl:sequence select="imf:create-entry('Declares function',$c)"/>
        </p>
    </xsl:template>
    
    <xsl:template match="function" mode="detail">
        <h2 id="FUNCTION_{name}">
            Function: <xsl:value-of select="template"/>
        </h2>
        <xsl:variable name="stylesheet" select="ancestor::stylesheet"/>
        <p>In stylesheet: 
            <a href="#STYLESHEET_{$stylesheet/path}">
                <xsl:variable name="toks" select="tokenize($stylesheet/path,'/')"/>
                <xsl:value-of select="string-join(subsequence($toks,1,count($toks) - 1),'/')"/>
                /
                <b>
                    <xsl:value-of select="$toks[last()]"/>
                </b>
            </a>
        </p>
        <table>
            <col style="width:30%"/>
            <col style="width:30%"/>
            <col style="width:40%"/>
            <thead>
                <tr>
                    <th>Params</th>
                    <th>Variable calls</th>
                    <th>Function calls</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <xsl:apply-templates select="params"/> 
                    <xsl:apply-templates select="variable-calls"/> 
                    <xsl:apply-templates select="function-calls"/> 
                </tr>
            </tbody>   
        </table>


    </xsl:template>
    
    <xsl:function name="imf:create-html-head">
        <xsl:param name="this"/>
        <xsl:param name="title"/>
        <head>
            <title><xsl:value-of select="$title"/></title>
            <style>
                body {font-family: 'Courier New', Courier, monospace;}
                h1,h2,h3,h4,h5 {color:blue;}
                .fparam {color:lightgray;}
                .local-call {color:lightgray;}
                .global-call {color:inherit;}
                a {color: inherit; text-decoration: inherit;}
                a:hover {color: blue; text-decoration: underline;}
                table {border-collapse: collapse; border: #dcdcdc 1px solid; width: 100%;}
                th {text-align: left; background-color: gray; color: white;}
                td {text-align: left; vertical-align: top; border: #dcdcdc 1px solid;}
                .error {color: red; }
                .warning {color: red;}
            </style>
        </head>
    </xsl:function>
 
    <xsl:function name="imf:create-entry">
        <xsl:param name="label"/>
        <xsl:param name="content"/>
        <xsl:value-of select="concat($label, ':')"/>
        <br/>
        <b>
            <xsl:sequence select="$content"/>
        </b>
    </xsl:function>
</xsl:stylesheet>