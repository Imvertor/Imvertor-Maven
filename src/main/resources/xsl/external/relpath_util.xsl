<?xml version="1.0" encoding="UTF-8"?>
<!--
	Taken from: http://www.biglist.com/lists/lists.mulberrytech.com/xsl-list/archives/200803/msg00224.html
	We changed the namespace to http://EliotKimber/functions (in stead of www.example.com)
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:local="http://EliotKimber/functions"
	exclude-result-prefixes="local xs"
	>
	
	<xsl:function name="local:getAbsolutePath" as="xs:string">
		<!-- Given a path resolves any ".." or "." terms to produce an absolute path -->
		<xsl:param name="sourcePath" as="xs:string"/>
		<xsl:variable name="pathTokens" select="tokenize($sourcePath, '/')" as="xs:string*"/>
		<xsl:variable name="baseResult"
			select="string-join(local:makePathAbsolute($pathTokens, ()), '/')" as="xs:string"/>
		<xsl:variable name="result" as="xs:string"
			select="if (starts-with($sourcePath, '/') and not(starts-with($baseResult, '/')))
			then concat('/', $baseResult)
			else $baseResult
			"
		/>
		<xsl:value-of select="$result"/>
	</xsl:function>
	
	<xsl:function name="local:makePathAbsolute" as="xs:string*">
		<xsl:param name="pathTokens" as="xs:string*"/>
		<xsl:param name="resultTokens" as="xs:string*"/>
		<xsl:sequence select="if (count($pathTokens) = 0)
			then $resultTokens
			else if ($pathTokens[1] = '.')
			then local:makePathAbsolute($pathTokens[position() > 1], $resultTokens)
			else if ($pathTokens[1] = '..')
			then local:makePathAbsolute($pathTokens[position() > 1], $resultTokens[position() lt last()])
			else local:makePathAbsolute($pathTokens[position() > 1], ($resultTokens, $pathTokens[1]))
			"/>
	</xsl:function>
	
	<xsl:function name="local:getRelativePath" as="xs:string">
		<!-- Calculate relative path that gets from from source path to target path.
			
Given:

  [1]  Target: /A/B/C
     Source: /A/B/C/X
     
Return: "X"

  [2]  Target: /A/B/C
       Source: /E/F/G/X
       
Return: "/E/F/G/X"

  [3]  Target: /A/B/C
       Source: /A/D/E/X
       
Return: "../../D/E/X"

  [4]  Target: /A/B/C
       Source: /A/X
       
Return: "../../X"


-->
		
		<xsl:param name="source" as="xs:string"/><!-- Path to get relative path *from* -->
		<xsl:param name="target" as="xs:string"/><!-- Path to get relataive path *to* -->
		<xsl:variable name="sourceTokens" select="tokenize((if (starts-with($source, '/')) then substring-after($source, '/') else $source), '/')" as="xs:string*"/>
		<xsl:variable name="targetTokens" select="tokenize((if (starts-with($target, '/')) then substring-after($target, '/') else $target), '/')" as="xs:string*"/>
		<xsl:choose>
			<xsl:when test="(count($sourceTokens) > 0 and count($targetTokens) > 0) and
				(($sourceTokens[1] != $targetTokens[1]) and
				(contains($sourceTokens[1], ':') or contains($targetTokens[1], ':')))">
				<!-- Must be absolute URLs with different schemes, cannot be relative, return target as is. -->
				<xsl:value-of select="$target"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="resultTokens"
					select="local:analyzePathTokens($sourceTokens, $targetTokens, ())" as="xs:string*"/>
				<xsl:variable name="result" select="string-join($resultTokens, '/')" as="xs:string"/>
				<xsl:value-of select="$result"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="local:analyzePathTokens" as="xs:string*">
		<xsl:param name="sourceTokens" as="xs:string*"/>
		<xsl:param name="targetTokens" as="xs:string*"/>
		<xsl:param name="resultTokens" as="xs:string*"/>
		<xsl:sequence
			select="if (count($sourceTokens) = 0 and count($targetTokens) = 0)
			then $resultTokens
			else if (count($sourceTokens) = 0)
			then ($resultTokens, $targetTokens)
			else if (string($sourceTokens[1]) != string($targetTokens[1]))
			then local:analyzePathTokens($sourceTokens[position() > 1], $targetTokens, ($resultTokens, '..'))
			else local:analyzePathTokens($sourceTokens[position() > 1], $targetTokens[position() > 1], $resultTokens)"/>
	</xsl:function>
</xsl:stylesheet>
