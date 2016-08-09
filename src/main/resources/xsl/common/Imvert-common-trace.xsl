<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:function name="imf:get-construct-formal-trace-name" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="package-name" select="$this/ancestor-or-self::imvert:package[imvert:stereotype = $traceable-package-stereotypes][1]/imvert:name"/>
        <xsl:variable name="supplier-package-name" select="(($this/ancestor-or-self::imvert:package)/imvert:supplier/imvert:supplier-package-name)[1]"/>
        <xsl:variable name="effective-package-name" select="($supplier-package-name,$package-name)[1]"/>
        <!-- note that for classes and properties we do not support alternative names (yet) -->
        <xsl:variable name="effective-class-name" select="$this/ancestor-or-self::imvert:class[1]/imvert:name"/>
        <xsl:variable name="effective-prop-name" select="$this[self::imvert:attribute | self::association]/imvert:name"/> 
        <xsl:sequence select="imf:compile-construct-formal-name($effective-package-name,$effective-class-name,$effective-prop-name)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-supplier-system-subpath" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="suppliers" select="($this/ancestor-or-self::imvert:*)/imvert:supplier"/>
        <xsl:if test="exists($suppliers)">
            <xsl:variable name="supplier-project" select="($suppliers/imvert:supplier-project)[1]"/>
            <xsl:variable name="supplier-name" select="($suppliers/imvert:supplier-name)[1]"/>
            <xsl:variable name="supplier-release" select="($suppliers/imvert:supplier-release)[1]"/>
            <!--
            <xsl:variable name="supplier-project-norm" select="imf:get-normalized-name($supplier-project,'system-name')"/>
            <xsl:variable name="supplier-name-norm" select="imf:get-normalized-name($supplier-name,'package-name')"/>
            <xsl:variable name="supplier-release-norm" select="imf:get-normalized-name($supplier-release,'system-name')"/>
            -->
            <xsl:value-of select="string-join(($supplier-project,$supplier-name,$supplier-release),'/')"/>
        </xsl:if>
    </xsl:function>
   
    <xsl:function name="imf:get-supplier" as="element()?">
        <xsl:param name="supplier-doc" as="document-node()?"/>
        <xsl:param name="formal-name" as="xs:string?"/>
        <xsl:sequence select="$supplier-doc//imvert:*[@formal-name = $formal-name][1]"/>
    </xsl:function>
</xsl:stylesheet>