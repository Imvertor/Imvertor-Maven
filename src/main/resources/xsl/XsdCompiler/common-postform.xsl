<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ekf="http://EliotKimber/functions"
    
    exclude-result-prefixes="#all"
    version="3.0">
    
    <xsl:function name="imf:normalize-xsd-name" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="c">(\s)|(&amp;)|(&lt;)|(&gt;)|(&apos;)|(&quot;)</xsl:variable>
        <xsl:value-of select="string-join(for $n in tokenize($name,':') return replace($n,$c,'_'),':')"/>
    </xsl:function>
    
</xsl:stylesheet>