<xsl:stylesheet 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    version="3.0"
    expand-text="yes"
    >
    <xsl:import href="imvert-common-prettyprint.xsl"/>
    
    <xsl:variable name="xml-indented" as="element()">
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="xml"/>
            <output:version value="1.0"/>
            <output:indent value="yes"/>
        </output:serialization-parameters>
    </xsl:variable>
  
    <xsl:variable name="xml-not-indented" as="element()">
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:method value="xml"/>
            <output:version value="1.0"/>
            <output:indent value="no"/>
        </output:serialization-parameters>
    </xsl:variable>
    
    <!-- write sequence to file, specify if pretty printed or assuming mixed content occurs --> 
    <xsl:function name="imf:debug-document">
        <xsl:param name="sequence" as="item()*"/>
        <xsl:param name="filename" as="xs:string"/>
        <xsl:param name="prettyprint" as="xs:boolean"/>
        <xsl:param name="prettyprint-with-mixed-content" as="xs:boolean"/>
        
        <xsl:message>REPLACE ME BY DLOGGER ({$filename})</xsl:message>
        
        
        <?x    
        <xsl:variable name="path" select="concat('c:/temp/', $filename)"/>
        
        <xsl:variable name="sequence-with-wrapper">
            <DEBUG-DOCUMENT>
                <xsl:sequence select="$sequence"/>
            </DEBUG-DOCUMENT>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$debugging">
                <xsl:sequence select="imf:msg('DEBUG','Writing [1] debug document to [2]',((if ($prettyprint) then 'pretty printed' else 'straight printed'), $path))"/>
                <xsl:variable name="doc">
                    <xsl:choose>
                        <xsl:when test="$prettyprint">
                            <xsl:sequence select="imf:pretty-print($sequence-with-wrapper,$prettyprint-with-mixed-content)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$sequence-with-wrapper"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:sequence select="imf:expath-write($path,$doc,if ($prettyprint) then $xml-indented else $xml-not-indented)"/>
            </xsl:when>
        </xsl:choose>
        x?>
    </xsl:function>
    
    <!-- write sequence to file, not pretty printed and assuming mixed content occurs --> 
    <xsl:function name="imf:debug-document">
        <xsl:param name="sequence" as="item()*"/>
        <xsl:param name="filename" as="xs:string"/>
        <xsl:sequence select="imf:debug-document($sequence,$filename,false(),true())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-xml-debug-comment" as="comment()?">
        <xsl:param name="info-node" as="node()?"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="parms" as="item()*"/>
        <xsl:if test="$debugging">
            <xsl:comment select="concat(if ($info-node) then imf:get-display-name($info-node) else concat('&quot;',$info-node,'&quot;'),' - ',imf:insert-fragments-by-index($text,$parms))"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-xml-debug-comment" as="comment()?">
        <xsl:param name="info-node" as="node()?"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:sequence select="imf:create-xml-debug-comment($info-node,$text,())"/>
    </xsl:function>
    
</xsl:stylesheet>