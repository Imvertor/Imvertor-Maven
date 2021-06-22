<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    >
    
    <xsl:function name="imf:create-datatype-property" as="node()*">
        <xsl:param name="this" as="node()"/>
        <xsl:param name="primitive-type" as="xs:string"/><!-- een xs:* qname -->
        
        <xsl:variable name="p" select="imf:get-facet-pattern($this)"/>
        <xsl:if test="$p">
            <xs:pattern value="{$p}"/><!-- toegestaan op alle constructs -->
        </xsl:if>
        
        <xsl:variable name="length" select="imf:get-facet-max-length($this)"/>
        <xsl:variable name="min-l" select="imf:convert-to-atomic(substring-before($length,'..'),'xs:integer',true())"/>
        <xsl:variable name="max-l" select="imf:convert-to-atomic(substring-after($length,'..'),'xs:integer',true())"/>
        <xsl:variable name="pre-l" select="imf:convert-to-atomic(substring-before($length,','),'xs:integer',true())"/>
        <xsl:variable name="post-l" select="imf:convert-to-atomic(substring-after($length,','),'xs:integer',true())"/>
        <xsl:variable name="total" select="imf:convert-to-atomic(imf:get-facet-total-digits($this),'xs:integer',true())"/>
        <xsl:variable name="fraction" select="imf:convert-to-atomic(imf:get-facet-fraction-digits($this),'xs:integer',true())"/>
        
        <xsl:variable name="min-v" select="imf:get-facet-min-value($this)"/>
        <xsl:variable name="max-v" select="imf:get-facet-max-value($this)"/>
        
        <xsl:sequence select="dlogger:save(imf:get-display-name($this),($min-v,$max-v))"/>
        
        <xsl:variable name="is-integer" select="$primitive-type = ('xs:integer')"/>
        <xsl:variable name="is-decimal" select="$primitive-type = ('xs:decimal')"/>
        <xsl:variable name="is-real"    select="$primitive-type = ('xs:real','xs:float')"/>
        <xsl:variable name="is-numeric" select="$is-integer or $is-decimal or $is-real"/>
        
        <!-- validaties --> <!-- zie 2.8.2.23 Metagegeven: Lengte (domein van een waarde van een gegeven) -->
        <xsl:sequence select="imf:report-error($this,
            ($length and $is-real),
            'Length [1] not allowed for XML schema type [2]',($length,$primitive-type))"/> 
        
        <xsl:sequence select="imf:report-error($this,
            ($pre-l or $post-l) and not($is-decimal),
            'Length with decimal positions [1] not allowed for XML schema type [2]',($length,$primitive-type))"/>  
        
        <?x
        <xsl:sequence select="imf:report-error($this,
            ($min-l or $max-l) and $is-real,
            'Length range [1] not allowed for XML schema type [2]',($length,$primitive-type))"/> 
        x?>
        
        <!-- genereren van de facetten --> 
        <xsl:choose>
            <xsl:when test="$min-v and $min-l and $is-numeric">
                <xs:minInclusive value="{$min-v}"/>
                <xs:minLength value="{$min-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, minimum value and length, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="$min-v and $is-numeric">
                <xs:minInclusive value="{$min-v}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, minimum value, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="$min-l and $is-integer">
                <xs:minInclusive value="{math:pow(10,$min-l - 1)}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on integer, minimum, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="$min-l">
                <xs:minLength value="{$min-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on non-integer, minimum, for [1]',$primitive-type)"/>
            </xsl:when>
        </xsl:choose> 
        <xsl:choose>
            <xsl:when test="$max-v and $max-l and $is-numeric">
                <xs:maxInclusive value="{$max-v}"/>
                <xs:maxLength value="{$max-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, maximum value and length, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="$max-v and $is-numeric">
                <xs:maxInclusive value="{$max-v}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on numeric, maximum value, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="$max-l and $is-integer">
                <xs:maxInclusive value="{math:pow(10,$max-l) - 1}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on integer, maximum, for [1]',$primitive-type)"/>
            </xsl:when>
            <xsl:when test="$max-l">
                <xs:maxLength value="{$max-l}"/>
                <xsl:sequence select="imf:create-xml-debug-comment($this,'Facet on non-integer, maximum, for [1]',$primitive-type)"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$length and not($min-l) and not($pre-l) and not($is-numeric)">
            <xs:length value="{$length}"/>
        </xsl:if>
        <xsl:if test="$post-l">
            <xs:fractionDigits value="{$post-l}"/>
        </xsl:if>
        <xsl:if test="$pre-l">
            <xs:totalDigits value="{$pre-l + $post-l}"/>
        </xsl:if>
        <xsl:if test="$fraction and not($min-l) and not($pre-l)">
            <xs:fractionDigits value="{$fraction}"/>
        </xsl:if>
        <xsl:if test="$total and not($min-l) and not($pre-l)">
            <xs:totalDigits value="{$total}"/>
        </xsl:if>
        
        <xsl:if test="empty(($p,$total)) and not($this/imvert:baretype='TXT')">
            <xsl:sequence select="imf:create-nonempty-constraint($this/imvert:type-name)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-facet-total-digits" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="$this/imvert:total-digits"/>
    </xsl:function>
    <xsl:function name="imf:get-facet-fraction-digits" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:sequence select="$this/imvert:fraction-digits"/>
    </xsl:function>
    
</xsl:stylesheet>