<?xml version="1.0" encoding="UTF-8"?>
<!-- 
	Functions taken from functx: 
	http://www.xsltfunctions.com/xsl/ 
-->
<xsl:stylesheet 
	version="2.0" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:functx="http://www.functx.com">
	
	<xsl:function name="functx:index-of-string" as="xs:integer*" >
		<xsl:param name="arg" as="xs:string?"/> 
		<xsl:param name="substring" as="xs:string"/> 
		
		<xsl:sequence select=" 
			if (contains($arg, $substring))
			then (string-length(substring-before($arg, $substring))+1,
			for $other in
			functx:index-of-string(substring-after($arg, $substring),
			$substring)
			return
			$other +
			string-length(substring-before($arg, $substring)) +
			string-length($substring))
			else ()
			"/>
		
	</xsl:function>
	
	<!-- adapted from http://www.xsltfunctions.com/xsl/functx_atomic-type.html -->
	<xsl:function name="functx:type-of" as="xs:string*">
		<xsl:param name="values" as="item()*"/> 
		<!-- cf. http://www.w3.org/TR/xpath20/#doc-xpath-KindTest -->
		<xsl:sequence select=" 
			for $val in $values
			return (
			     if ($val instance of element()) then 'element'
			else if ($val instance of text()) then 'text'
			else if ($val instance of processing-instruction()) then 'processing-instruction'
			else if ($val instance of document-node()) then 'document'
			else if ($val instance of comment()) then 'comment'
			else if ($val instance of attribute()) then 'attribute'
			else if ($val instance of node()) then 'node'
			else if ($val instance of xs:untypedAtomic) then 'xs:anyURI'
			else if ($val instance of xs:anyURI) then 'xs:anyURI'
			else if ($val instance of xs:string) then 'xs:string'
			else if ($val instance of xs:QName) then 'xs:QName'
			else if ($val instance of xs:boolean) then 'xs:boolean'
			else if ($val instance of xs:base64Binary) then 'xs:base64Binary'
			else if ($val instance of xs:hexBinary) then 'xs:hexBinary'
			else if ($val instance of xs:integer) then 'xs:integer'
			else if ($val instance of xs:decimal) then 'xs:decimal'
			else if ($val instance of xs:float) then 'xs:float'
			else if ($val instance of xs:double) then 'xs:double'
			else if ($val instance of xs:date) then 'xs:date'
			else if ($val instance of xs:time) then 'xs:time'
			else if ($val instance of xs:dateTime) then 'xs:dateTime'
			else if ($val instance of xs:dayTimeDuration)
			then 'xs:dayTimeDuration'
			else if ($val instance of xs:yearMonthDuration)
			then 'xs:yearMonthDuration'
			else if ($val instance of xs:duration) then 'xs:duration'
			else if ($val instance of xs:gMonth) then 'xs:gMonth'
			else if ($val instance of xs:gYear) then 'xs:gYear'
			else if ($val instance of xs:gYearMonth) then 'xs:gYearMonth'
			else if ($val instance of xs:gDay) then 'xs:gDay'
			else if ($val instance of xs:gMonthDay) then 'xs:gMonthDay'
			else '')
			"/>
		
	</xsl:function>
	
	<xsl:function name="functx:left-trim" as="xs:string">
		<xsl:param name="arg" as="xs:string?"/>
		<xsl:sequence select="
			replace($arg,'^\s+','')
			"/>
	</xsl:function>
</xsl:stylesheet>