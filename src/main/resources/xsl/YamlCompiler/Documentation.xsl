<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	xmlns:html="http://www.w3.org/1999/xhtml"
	version="2.0">
	
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
	
	<xsl:variable name="stylesheet-code" as="xs:string">YAMLB</xsl:variable>
	
	<!-- The first variable is meant for the server environment, the second one is used during development in XML-Spy. -->
	<xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)" as="xs:boolean"/>
	<!--<xsl:variable name="debugging" select="true()" as="xs:boolean"/>-->
	
<?x	<xsl:function name="imf:createDocumentation()">
		<xsl:param name="documentationNode"/>
		
		<xsl:variable name="value-format" select="lower-case($configuration-notesrules-file//notes-format)"/>

				
	</xsl:function> ?>
	
	<xsl:template match="ep:documentation">
		<xsl:param name="definition" select="'yes'"/>
		<xsl:param name="description" select="'yes'"/>
		<xsl:param name="pattern" select="'yes'"/>
		
		<xsl:if test="$definition = 'yes'">
			<xsl:apply-templates select="ep:definition"/>
		</xsl:if>
		<xsl:if test="$description = 'yes'">
			<xsl:apply-templates select="ep:description"/>
		</xsl:if>
		<xsl:if test="$pattern = 'yes'">
			<xsl:apply-templates select="ep:pattern"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ep:definition">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:description">
		<!--xsl:sequence select="imf:msg(.,'WARNING','Verwerking ep:description.',())" /-->
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:pattern">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:p">
		<!--xsl:sequence select="imf:msg(.,'WARNING','Verwerking ep:p.',())" /-->
		<xsl:choose>
			<xsl:when test="@format = 'plain'">
				<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
				<xsl:if test="following-sibling::ep:p">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="@format = 'markdown'">
				<xsl:apply-templates select="html:body" mode="test"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
				<xsl:if test="following-sibling::ep:p">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:body" mode="test">
		<xsl:apply-templates select="html:*" mode="test"/>
	</xsl:template>

	<xsl:template match="html:h1" mode="test">
		<xsl:value-of select="concat('# ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>
			
		</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h2" mode="test">
		<xsl:value-of select="concat('## ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>
			
		</xsl:text>
	</xsl:template>

	<xsl:template match="html:h3" mode="test">
		<xsl:value-of select="concat('### ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>
			
		</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h4" mode="test">
		<xsl:value-of select="concat('#### ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>
			
		</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h5" mode="test">
		<xsl:value-of select="concat('##### ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>
			
		</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h6" mode="test">
		<xsl:value-of select="concat('###### ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>
			
		</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:p" mode="test">
		<xsl:apply-templates select="html:*|text()" mode="test"/>
	</xsl:template>
	
	<xsl:template match="text()" mode="test">
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
	</xsl:template>
		
	<xsl:template match="html:ul" mode="test">
		<xsl:text>
			
		</xsl:text><xsl:apply-templates select="html:li" mode="test"/>
	</xsl:template>
	
	<xsl:template match="html:ol" mode="test">
		<xsl:text>
			
		</xsl:text><xsl:apply-templates select="html:li" mode="test"/>
	</xsl:template>
	
	<xsl:template match="html:li" mode="test">
		<xsl:value-of select="concat('* ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>
			
		</xsl:text>
	</xsl:template>

</xsl:stylesheet>
