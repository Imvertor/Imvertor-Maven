<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:ep="http://www.imvertor.org/schema/endproduct" >

<xsl:output indent="yes" method="xml" encoding="UTF-8" exclude-result-prefixes="ep fo xs fn"/>

<xsl:variable name="used-constructs">
	<message-set>
		<xsl:apply-templates select="//ep:message" mode="preprocess"/>
	</message-set>
</xsl:variable>

<xsl:template match="/" exclude-result-prefixes="ep fo xs fn">
	<xsl:apply-templates select="ep:message-sets"/>
</xsl:template>

<xsl:template match="ep:message" exclude-result-prefixes="ep fo xs fn" mode="preprocess">
	<message name="{ep:tech-name}" id="{generate-id()}">
		<xsl:apply-templates select=".//ep:construct" mode="preprocess-local-constructs"/>
		<xsl:apply-templates select=".//ep:constructRef" mode="preprocess-local-constructs"/>
	</message>
</xsl:template>

<xsl:template match="ep:construct" exclude-result-prefixes="ep fo xs fn" mode="preprocess-local-constructs">
	<xsl:param name="id-trail" select="''"/>

	<xsl:variable name="type-name" select="ep:type-name"/>
	<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = fn:substring-after($type-name,':') and 
																  @prefix = fn:substring-before($type-name,':')]"  mode="preprocess-global-constructs">
		<xsl:with-param name="id-trail" select="$id-trail"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="ep:constructRef" exclude-result-prefixes="ep fo xs fn" mode="preprocess-local-constructs">
	<xsl:param name="id-trail"/>

	<xsl:variable name="href" select="ep:href"/>
	<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = fn:substring-after($href,':') and 
																  @prefix = fn:substring-before($href,':')]"  mode="preprocess-global-constructs">
		<xsl:with-param name="id-trail" select="$id-trail"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="ep:superconstructRef" exclude-result-prefixes="ep fo xs fn" mode="preprocess-local-constructs">
	<xsl:param name="id-trail"/>

	<xsl:variable name="href" select="ep:tech-name"/>
	<xsl:variable name="prefix" select="@prefix"/>
	<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = $href and 
																  @prefix = $prefix]"  mode="preprocess-global-constructs">
		<xsl:with-param name="id-trail" select="$id-trail"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="ep:construct" exclude-result-prefixes="ep fo xs fn" mode="preprocess-global-constructs">
	<xsl:param name="id-trail"/>
	
	<xsl:variable name="id" select="generate-id()"/>

	<xsl:choose>
		<xsl:when test="contains($id-trail,$id)"/>
		<xsl:otherwise>
			<xsl:variable name="type-name" select="ep:type-name"/>
		
			<construct prefix="{@prefix}" name="{ep:tech-name}" id="{generate-id()}">
				<xsl:if test="$type-name != ''">
					<xsl:attribute name="type" select="$type-name"/>
					<xsl:apply-templates select="//ep:message-set/ep:construct[ep:tech-name = fn:substring-after($type-name,':') and 
																			  @prefix = fn:substring-before($type-name,':')]" mode="preprocess-global-constructs">
						<xsl:with-param name="id-trail" select="concat($id,'##',$id-trail)"/>
					</xsl:apply-templates>
				</xsl:if>	
				<xsl:apply-templates select=".//ep:superconstructRef" mode="preprocess-local-constructs">
					<xsl:with-param name="id-trail" select="concat($id,'##',$id-trail)"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//ep:construct" mode="preprocess-local-constructs">
					<xsl:with-param name="id-trail" select="concat($id,'##',$id-trail)"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//ep:constructRef" mode="preprocess-local-constructs">
					<xsl:with-param name="id-trail" select="concat($id,'##',$id-trail)"/>
				</xsl:apply-templates>
			</construct>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ep:message-sets">
	<xsl:copy>
		<xsl:apply-templates select="ep:message-set"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="ep:message-set" exclude-result-prefixes="ep fo xs fn">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates select="*[not(*)]"/>
		<xsl:apply-templates select="ep:namespaces"/>
		<xsl:apply-templates select="ep:construct|ep:message" mode="replicate-used-construct"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="ep:namespaces" exclude-result-prefixes="ep fo xs fn">
	<xsl:copy>
		<xsl:apply-templates select="ep:namespace"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="ep:namespace" exclude-result-prefixes="ep fo xs fn" mode="mode">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:value-of select="."/>
	</xsl:copy>
</xsl:template>

<xsl:template match="ep:message" exclude-result-prefixes="ep fo xs fn" mode="replicate-used-construct">
		<xsl:copy>
			<xsl:apply-templates select="*|@*"/>
		</xsl:copy>
</xsl:template>

<xsl:template match="ep:construct" exclude-result-prefixes="ep fo xs fn" mode="replicate-used-construct">
	<xsl:variable name="id" select="fn:generate-id()"/>
	<xsl:if test="$used-constructs//construct/@id = $id">
		<xsl:copy>
			<xsl:apply-templates select="*|@*"/>
		</xsl:copy>
	</xsl:if>
</xsl:template>

<xsl:template match="@*">
	<xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="*">
	<xsl:copy-of select="."/>
</xsl:template>

</xsl:stylesheet>
