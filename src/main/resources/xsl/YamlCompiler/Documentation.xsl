<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	xmlns:html="http://www.w3.org/1999/xhtml"
	version="2.0">
	
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
	
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
		<xsl:apply-templates select="ep:p[@level='SIM']"/>
		<xsl:apply-templates select="ep:p[@level='UGM']"/>
		<xsl:apply-templates select="ep:p[@level='BSM']"/>
	</xsl:template>
	
	<xsl:template match="ep:description">
		<xsl:apply-templates select="ep:p[@level='SIM']"/>
		<xsl:apply-templates select="ep:p[@level='UGM']"/>
		<xsl:apply-templates select="ep:p[@level='BSM']"/>
	</xsl:template>
	
	<xsl:template match="ep:pattern">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:p">
		<xsl:choose>
			<!-- In een document waarin één van de ep:p elementen het @format 'markdown' heeft worden alle ep:p elementen als markdown verwerkt. -->
			<xsl:when test="$message-sets//ep:p/@format = 'markdown'">
				<xsl:text>&lt;body&gt;</xsl:text>
					<xsl:choose>
						<xsl:when test="@format = 'markdown'">
							<xsl:choose>
								<xsl:when test="html:body">
									<xsl:apply-templates select="html:body" mode="markdown"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>&lt;p&gt;</xsl:text>
										<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
									<xsl:text>&lt;/p&gt;</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="@format = 'plain'">
							<xsl:text>&lt;p&gt;</xsl:text>
								<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
							<xsl:text>&lt;/p&gt;</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>&lt;p&gt;</xsl:text>
								<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
							<xsl:text>&lt;/p&gt;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				<xsl:text>&lt;/body&gt;</xsl:text>
			</xsl:when>
			<xsl:when test="@format = 'plain'">
				<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
				<xsl:if test="following-sibling::ep:p">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
				<xsl:if test="following-sibling::ep:p">
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="html:body" mode="markdown">
		<xsl:apply-templates select="html:*" mode="markdown"/>
	</xsl:template>

	<xsl:template match="html:h1" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h2" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h3" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h4" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h5" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:h6" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:p" mode="markdown">
		<xsl:choose>
			<!-- p elementen die alleen een '|' bevatten worden verwijderd. -->
			<xsl:when test=". = '|'"/>
			<xsl:otherwise>
				<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
				<xsl:apply-templates select="html:*|text()" mode="markdown"/>
				<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="text()" mode="markdown">
		<xsl:choose>
			<xsl:when test="parent::html:li and position() = 1"><xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/></xsl:when>
			<xsl:when test="parent::html:li and position() != 1"> <xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/></xsl:when>
			<xsl:when test="position() = 1"><xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/></xsl:when>
			<xsl:when test="position() != 1"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/></xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="html:ul" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:apply-templates select="html:*" mode="markdown"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:ol" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:apply-templates select="html:*" mode="markdown"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:li" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:apply-templates select="*|text()" mode="markdown"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:em" mode="markdown">
		<xsl:choose>
			<xsl:when test="position() = 1"/>
			<xsl:when test="position() != 1"><xsl:text> </xsl:text></xsl:when>
		</xsl:choose>
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:strong|html:b" mode="markdown">
		<xsl:choose>
			<xsl:when test="position() = 1"/>
			<xsl:when test="position() != 1"><xsl:text> </xsl:text></xsl:when>
		</xsl:choose>
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:a" mode="markdown">
		<xsl:choose>
			<xsl:when test="position() = 1"/>
			<xsl:when test="position() != 1"><xsl:text> </xsl:text></xsl:when>
		</xsl:choose>
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="markdown"/>		
		<xsl:text>&gt;</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="@href" mode="markdown">
		<xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"
	</xsl:template>
	
	<xsl:template match="@shape" mode="markdown"/>
	
	<xsl:template match="@title" mode="markdown">
		<xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"
	</xsl:template>
	
	<xsl:template match="html:img" mode="markdown">
		<xsl:choose>
			<xsl:when test="position() = 1"/>
			<xsl:when test="position() != 1"><xsl:text> </xsl:text></xsl:when>
		</xsl:choose>
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/>
		<xsl:apply-templates select="@*" mode="markdown"/>		
		<xsl:text>&gt;</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="@alt" mode="markdown">
		<xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"
	</xsl:template>
	
	<xsl:template match="@border" mode="markdown">
		<xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"
	</xsl:template>
	
	<xsl:template match="@src" mode="markdown">
		<xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"
	</xsl:template>
	
	<xsl:template match="@title" mode="markdown">
		<xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"
	</xsl:template>
	
	<xsl:template match="html:pre" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:apply-templates select="html:*" mode="markdown"/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:code" mode="markdown">
		<xsl:choose>
			<xsl:when test="position() = 1"/>
			<xsl:when test="position() != 1"><xsl:text> </xsl:text></xsl:when>
		</xsl:choose>
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:hr" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>/&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template match="html:br" mode="markdown">
		<xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text>/&gt;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
