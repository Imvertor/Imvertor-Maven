<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:imf="http://www.imvertor.org/xsl/functions" 
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	xmlns:html="http://www.w3.org/1999/xhtml"
	version="2.0">
	
	<xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>
	
<?x	<xsl:function name="imf:createDocumentation()">
		<xsl:param name="documentationNode"/>
		
		<xsl:variable name="value-format" select="lower-case($configuration-notesrules-file//notes-format)"/>

				
	</xsl:function> ?>
	
	<xsl:template match="ep:documentation">
		<xsl:param name="definition" select="'yes'"/>
		<xsl:param name="description" select="'yes'"/>
		<xsl:param name="pattern" select="'yes'"/>

		<!--xsl:if test="not(//ep:p/@format = 'markdown')">
			<xsl:value-of select="'&quot;'"/>
		</xsl:if-->
		<xsl:if test="$definition = 'yes'">
			<xsl:apply-templates select="ep:definition"/>
		</xsl:if>
		<xsl:if test="$description = 'yes'">
			<xsl:apply-templates select="ep:description"/>
		</xsl:if>
		<xsl:if test="$pattern = 'yes'">
			<xsl:apply-templates select="ep:pattern"/>
		</xsl:if>
		<!--xsl:if test="not(//ep:p/@format = 'markdown')">
			<xsl:value-of select="'&quot;'"/>
		</xsl:if-->
	</xsl:template>
	
	<xsl:template match="ep:definition">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:description">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
	<xsl:template match="ep:pattern">
		<xsl:apply-templates select="ep:p"/>
	</xsl:template>
	
<?x <xsl:template match="ep:p">
		<!-- In een document waarin een van de ep:p elementen het @format 'markdown' heeft worden alle ep:p elementen als markdown verwerkt. -->
	
		<xsl:choose>
			<xsl:when test="//ep:p/@format = 'markdown'">
				<!--xsl:if test="not(../preceding-sibling::ep:definition) and not(../preceding-sibling::ep:description) and not(../preceding-sibling::ep:pattern)"><xsl:text>|\\n\\n</xsl:text></xsl:if-->
				<xsl:choose>
					<xsl:when test="@format = 'markdown'">
						<xsl:apply-templates select="html:body" mode="markdown"/>
					</xsl:when>
					<xsl:when test="@format = 'plain'">
<xsl:text>        </xsl:text><xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
						<xsl:if test="following-sibling::ep:p"><xsl:text>\\n\\n</xsl:text></xsl:if>
					</xsl:when>
					<xsl:otherwise>
<xsl:text>        </xsl:text><xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
						<xsl:if test="following-sibling::ep:p"><xsl:text>\\n\\n</xsl:text></xsl:if>
					</xsl:otherwise>
				</xsl:choose>
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
	</xsl:template> ?>
	
<xsl:template match="ep:p">
	
		<xsl:choose>
			<!-- In een document waarin één van de ep:p elementen het @format 'markdown' heeft worden alle ep:p elementen als markdown verwerkt. -->
			<xsl:when test="//ep:p/@format = 'markdown'">
				<xsl:text>&lt;body&gt;</xsl:text>
					<xsl:choose>
						<xsl:when test="@format = 'markdown'">
							<xsl:apply-templates select="html:body" mode="markdown"/>
						</xsl:when>
						<xsl:when test="@format = 'plain'">
							<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>
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
		<!--<xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/>-->
		<!--<xsl:choose>
			<xsl:when test="parent::html:ul and ancestor::html:li">
<xsl:text>           </xsl:text><xsl:value-of select="concat('* ',normalize-space(translate(.,'&quot;','&#96;')))"/><xsl:text>\\n\\n</xsl:text>
			</xsl:when>
			<xsl:when test="parent::html:ol and ancestor::html:li">
<xsl:text>           </xsl:text><xsl:number value="position()" format="1" />. <xsl:value-of select="normalize-space(translate(.,'&quot;','&#96;'))"/><xsl:text>\\n\\n</xsl:text>
			</xsl:when>
			<xsl:when test="parent::html:ul">
<xsl:text>        </xsl:text>* <xsl:apply-templates select="html:*|text()" mode="markdown"/><xsl:text>\\n\\n</xsl:text>
			</xsl:when>
			<xsl:when test="parent::html:ol">
<xsl:text>        </xsl:text><xsl:number value="position()" format="1" />. <xsl:apply-templates select="html:*|text()" mode="markdown"/><xsl:text>\\n\\n</xsl:text>
			</xsl:when>
		</xsl:choose>-->
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
