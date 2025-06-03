<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ext="http://www.imvertor.org/xsl/extensions"
	xmlns:imvert="http://www.imvertor.org/schema/system"
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:html="http://www.w3.org/1999/xhtml"    
	xmlns:functx="http://www.functx.com"

    exclude-result-prefixes="#all"
    version="2.0">

	<!--xsl:variable name="NOT2BReportedProperties">attributeTypeDesignation, compos, conceptualSchemaType, documentation, exported, generated, generator, modified, nameAttribute, nameAssociation, nameClass, trace, tv_CFG-TV-DEFINITION, tv_CFG-TV-IMDOMAIN, tv_CFG-TV-DESCRIPTION, typeId, typePackage, typePackageId</xsl:variable-->

	<xsl:variable name="concise" select="'yes'"/>

	<xsl:template match="/cmps" mode="releasenotes">
		<tr>
			<td>
				<h2>Model</h2>
				<xsl:apply-templates select="../cmps" mode="package"/>
			</td>
		</tr>
		<tr>
			<td>
				<h2>Domein</h2>
				<xsl:apply-templates select="../cmps" mode="domain"/>
			</td>
		</tr>
		<tr>
			<td>
				<h2>Classes</h2>
				<xsl:for-each-group select="../cmps" group-by="res/cmp/@class">
					<h4>In de class <xsl:value-of select="current-grouping-key()"/> zijn de volgende wijzigingen aangebracht:</h4>
					<xsl:variable name="class" select="current-grouping-key()"/>
					<ul>
						<xsl:for-each-group select="res" group-by="@type">
							<xsl:apply-templates select="../res[@type = current-grouping-key() and cmp/@class = $class]" mode="class"/>
							
						</xsl:for-each-group>
						<xsl:if test="$concise = 'yes' and res/cmp[1][@property-stereo != '' and @class = $class]">
							<xsl:variable name="changed">
								<xsl:if test="res[@type = 'CHANGED' and cmp[1][@property-stereo != '' and @class = $class]]">yes</xsl:if>
							</xsl:variable>
							<xsl:variable name="removed">
								<xsl:if test="res[@type = 'REMOVED' and cmp[1][@property-stereo != '' and @class = $class]]">yes</xsl:if>
							</xsl:variable>
							<xsl:variable name="added">
								<xsl:if test="res[@type = 'ADDED' and cmp[1][@property-stereo != '' and @class = $class]]">yes</xsl:if>
							</xsl:variable>
							<li><xsl:text>Er zijn een of meer tagged-values op deze class, op attributes van deze class of op, met deze class gedefinieerde, associations </xsl:text>
								<xsl:sequence select="imf:changed-removed-and-added($changed,$removed,$added)"/>
							</li>
						</xsl:if>
					</ul>
				</xsl:for-each-group>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="cmps" mode="package">
		<ul>
			<xsl:for-each select="res/cmp[1][not(@domain)]" >
				<xsl:sort select="@id"/>
				
				<xsl:choose>
					<xsl:when test="$concise = 'yes' and @property-stereo != ''"/>
					<xsl:otherwise>
						<xsl:variable name="event" select="../@type"/>
						<xsl:variable name="type" select="'Model'"/>
						<xsl:variable name="property" select="@property"/>
						<xsl:variable name="property-stereo" select="@property-stereo"/>
						<xsl:variable name="domain" select="@domain"/>
						<xsl:variable name="domain-stereo" select="@domain-stereo"/>
						<xsl:variable name="class-stereo" select="@class-stereo"/>
						<xsl:variable name="attass" select="@attass"/>
						<xsl:variable name="attass-stereo" select="@attass-stereo"/>
						<xsl:variable name="currentvalue" select="@value"/>
						<xsl:variable name="newvalue" select="../cmp[2]/@value"/>
		
						<xsl:sequence select="imf:determine-releasenote($event,$type,$property,$property-stereo,$domain,$domain-stereo,$class-stereo,$attass,$attass-stereo,$currentvalue,$newvalue)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:if test="$concise = 'yes' and res[cmp[1][not(@domain) and @property-stereo != '']]">
				<xsl:variable name="changed">
					<xsl:if test="res[@type = 'CHANGED' and cmp[1][not(@domain) and @property-stereo != '']]">yes</xsl:if>
				</xsl:variable>
				<xsl:variable name="removed">
					<xsl:if test="res[@type = 'REMOVED' and cmp[1][not(@domain) and @property-stereo != '']]">yes</xsl:if>
				</xsl:variable>
				<xsl:variable name="added">
					<xsl:if test="res[@type = 'ADDED' and cmp[1][not(@domain) and @property-stereo != '']]">yes</xsl:if>
				</xsl:variable>
				<li><xsl:text>Er zijn een of meer tagged-values op dit model </xsl:text>
					<xsl:sequence select="imf:changed-removed-and-added($changed,$removed,$added)"/>
				</li>
			</xsl:if>
		</ul>
	</xsl:template>
	
	<xsl:template match="cmps" mode="domain">
		<ul>
			<xsl:for-each select="res/cmp[1][@domain and not(@class)]" >
				<xsl:sort select="@id"/>
				
				<xsl:choose>
					<xsl:when test="$concise = 'yes' and @property-stereo != ''"/>
					<xsl:otherwise>
						<xsl:variable name="event" select="../@type"/>
						<xsl:variable name="type" select="'Domain'"/>
						<xsl:variable name="property" select="@property"/>
						<xsl:variable name="property-stereo" select="@property-stereo"/>
						<xsl:variable name="domain" select="@domain"/>
						<xsl:variable name="domain-stereo" select="@domain-stereo"/>
						<xsl:variable name="class-stereo" select="@class-stereo"/>
						<xsl:variable name="attass" select="@attass"/>
						<xsl:variable name="attass-stereo" select="@attass-stereo"/>
						<xsl:variable name="currentvalue" select="@value"/>
						<xsl:variable name="newvalue" select="../cmp[2]/@value"/>
						
						<xsl:sequence select="imf:determine-releasenote($event,$type,$property,$property-stereo,$domain,$domain-stereo,$class-stereo,$attass,$attass-stereo,$currentvalue,$newvalue)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<xsl:if test="$concise = 'yes' and res[cmp[1][@domain and not(@class) and @property-stereo != '']]">
				<xsl:variable name="changed">
					<xsl:if test="res[@type = 'CHANGED' and cmp[1][@domain and not(@class) and @property-stereo != '']]">yes</xsl:if>
				</xsl:variable>
				<xsl:variable name="removed">
					<xsl:if test="res[@type = 'REMOVED' and cmp[1][@domain and not(@class) and @property-stereo != '']]">yes</xsl:if>
				</xsl:variable>
				<xsl:variable name="added">
					<xsl:if test="res[@type = 'ADDED' and cmp[1][@domain and not(@class) and @property-stereo != '']]">yes</xsl:if>
				</xsl:variable>
				<li><xsl:text>Er zijn een of meer tagged-values op dit domein </xsl:text>
					<xsl:sequence select="imf:changed-removed-and-added($changed,$removed,$added)"/>
				</li>
			</xsl:if>
		</ul>
	</xsl:template>
	
	<xsl:template match="res" mode="class">
		<xsl:for-each select="cmp[1][@class]">
			<xsl:sort select="@id"/>
			
			<xsl:choose>
				<xsl:when test="$concise = 'yes' and @property-stereo != ''"/>
				<xsl:otherwise>
					<xsl:variable name="event" select="../@type"/>
						<xsl:variable name="type" select="'Class'"/>
						<xsl:variable name="property" select="@property"/>
						<xsl:variable name="property-stereo" select="@property-stereo"/>
						<xsl:variable name="domain" select="@domain"/>
						<xsl:variable name="domain-stereo" select="@domain-stereo"/>
						<xsl:variable name="class-stereo" select="@class-stereo"/>
						<xsl:variable name="attass" select="@attass"/>
						<xsl:variable name="attass-stereo" select="@attass-stereo"/>
						<xsl:variable name="currentvalue" select="@value"/>
						<xsl:variable name="newvalue" select="../cmp[2]/@value"/>
						
						<xsl:sequence select="imf:determine-releasenote($event,$type,$property,$property-stereo,$domain,$domain-stereo,$class-stereo,$attass,$attass-stereo,$currentvalue,$newvalue)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:function name="imf:changed-removed-and-added">
		<xsl:param name="changed"/>
		<xsl:param name="removed"/>
		<xsl:param name="added"/>

		<xsl:choose>
			<xsl:when test="$changed = 'yes' and $removed = 'yes' and $added = 'yes'">
				<xsl:text>gewijzigd, verwijderd of toegevoegd.</xsl:text>			
			</xsl:when>
			<xsl:when test="$changed = 'yes' and $removed = 'yes' and $added != 'yes'">
				<xsl:text>gewijzigd of verwijderd.</xsl:text>			
			</xsl:when>
			<xsl:when test="$changed = 'yes' and $removed != 'yes' and $added = 'yes'">
				<xsl:text>gewijzigd of toegevoegd.</xsl:text>			
			</xsl:when>
			<xsl:when test="$changed = 'yes' and $removed != 'yes' and $added != 'yes'">
				<xsl:text>gewijzigd.</xsl:text>			
			</xsl:when>
			<xsl:when test="$changed != 'yes' and $removed = 'yes' and $added = 'yes'">
				<xsl:text>verwijderd of toegevoegd.</xsl:text>			
			</xsl:when>
			<xsl:when test="$changed != 'yes' and $removed = 'yes' and $added != 'yes'">
				<xsl:text>verwijderd.</xsl:text>			
			</xsl:when>
			<xsl:when test="$changed != 'yes' and $removed != 'yes' and $added = 'yes'">
				<xsl:text>toegevoegd.</xsl:text>			
			</xsl:when>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="imf:determine-releasenote">
		<xsl:param name="event"/>
		<xsl:param name="type"/>
		<xsl:param name="property"/>
		<xsl:param name="property-stereo"/>
		<xsl:param name="domain"/>
		<xsl:param name="domain-stereo"/>
		<xsl:param name="class-stereo"/>
		<xsl:param name="attass"/>
		<xsl:param name="attass-stereo"/>
		<xsl:param name="currentvalue"/>
		<xsl:param name="newvalue"/>
		
		<xsl:choose>
			<xsl:when test="$event='CHANGED'">
				<li><xsl:text>De waarde van de </xsl:text>
					<xsl:if test="$property-stereo != ''">
						<xsl:value-of select="$property-stereo"/>
					</xsl:if>
					<xsl:text> property &apos;</xsl:text><xsl:value-of select="$property"/><xsl:text>&apos; </xsl:text>
					<xsl:if test="$type = 'Model'">
						<xsl:text>van het informatiemodel </xsl:text>
					</xsl:if>
					<xsl:if test="$domain != '' and $type = 'Domain'">
						<xsl:text>van het </xsl:text><xsl:value-of select="$domain-stereo"/> &apos;<xsl:value-of select="$domain"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					<xsl:if test="$attass != ''">
						<xsl:text>van het </xsl:text><xsl:value-of select="$attass-stereo"/> &apos;<xsl:value-of select="$attass"/><xsl:text>&apos; in </xsl:text>
					</xsl:if>
					<xsl:if test="$class-stereo != '' and $attass = ''">
						<xsl:text>van </xsl:text>
					</xsl:if>
					<xsl:if test="$class-stereo != ''">
						<xsl:text>dit </xsl:text><xsl:value-of select="$class-stereo"/><xsl:text> </xsl:text>
					</xsl:if>
					is gewijzigd van<br/>&#160;&#160;&#160;&#160;&apos;<span style="color: #cc66ff"><xsl:value-of select="$currentvalue"/></span>&apos;<br/>&#160;&#160;&#160;&#160;in &apos;<span style="color: blue;"><xsl:value-of select="$newvalue"/></span>&apos;.</li>			
			</xsl:when>
			<xsl:when test="$event='REMOVED' and $property != ''">
				<li><xsl:text>De </xsl:text>
					<xsl:if test="$property-stereo != ''">
						<xsl:value-of select="$property-stereo"/>
					</xsl:if>
					<xsl:text> property &apos;</xsl:text><xsl:value-of select="$property"/><xsl:text>&apos; </xsl:text>
					<xsl:if test="$type = 'Model'">
						<xsl:text>van het informatiemodel </xsl:text>
					</xsl:if>
					<xsl:if test="$domain != '' and $type = 'Domain'">
						<xsl:text>van het </xsl:text><xsl:value-of select="$domain-stereo"/> &apos;<xsl:value-of select="$domain"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					<xsl:if test="$attass != ''">
						<xsl:text>van het </xsl:text><xsl:value-of select="$attass-stereo"/> &apos;<xsl:value-of select="$attass"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					<xsl:if test="$class-stereo != ''">
						<xsl:text>in dit </xsl:text><xsl:value-of select="$class-stereo"/><xsl:text> </xsl:text>
					</xsl:if>
					is verwijderd.</li>
			</xsl:when>
			<xsl:when test="$event='REMOVED' and $property = '' and $attass != ''">
				<li><xsl:text>Het/De </xsl:text>
					<xsl:if test="$attass != ''">
						<xsl:text></xsl:text><xsl:value-of select="$attass-stereo"/> &apos;<xsl:value-of select="$attass"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					<xsl:if test="$class-stereo != ''">
						<xsl:text>in dit </xsl:text><xsl:value-of select="$class-stereo"/><xsl:text> </xsl:text>
					</xsl:if>
					is verwijderd.</li>
			</xsl:when>
			<xsl:when test="$event='REMOVED' and $property = '' and $attass = '' and $class-stereo =''">
				<li><xsl:text>Het </xsl:text>
					<xsl:if test="$domain-stereo != ''">
						<xsl:value-of select="$domain-stereo"/> &apos;<xsl:value-of select="$domain"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					is verwijderd.</li>
			</xsl:when>
			<xsl:when test="$event='REMOVED' and $property = '' and $class-stereo != ''">
				<li>Dit <xsl:value-of select="$class-stereo"/> is verwijderd.</li>
			</xsl:when>
			<xsl:when test="$event='ADDED' and $property != ''">
				<li><xsl:text>De </xsl:text>
					<xsl:if test="$property-stereo != ''">
						<xsl:value-of select="$property-stereo"/>
					</xsl:if>
					<xsl:text> property &apos;</xsl:text><xsl:value-of select="$property"/><xsl:text>&apos; </xsl:text>
					<xsl:if test="$type = 'Model'">
						<xsl:text>van het informatiemodel </xsl:text>
					</xsl:if>
					<xsl:if test="$domain != '' and $type = 'Domain'">
						<xsl:text>van het </xsl:text><xsl:value-of select="$domain-stereo"/> &apos;<xsl:value-of select="$domain"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					<xsl:if test="$attass != ''">
						<xsl:text>van het </xsl:text><xsl:value-of select="$attass-stereo"/> &apos;<xsl:value-of select="$attass"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					<xsl:if test="$class-stereo != ''">
						<xsl:text>in dit </xsl:text><xsl:value-of select="$class-stereo"/><xsl:text> </xsl:text>
					</xsl:if>
					is toegevoegd met de waarde<br/>&#160;&#160;&#160;&#160;&apos;<span style="color: blue;"><xsl:value-of select="$currentvalue"/></span>&apos;.</li>
			</xsl:when>
			<xsl:when test="$event='ADDED' and $property = '' and $attass != ''">
				<li><xsl:text>Het/De </xsl:text>
					<xsl:if test="$attass != ''">
						<xsl:text></xsl:text><xsl:value-of select="$attass-stereo"/> &apos;<xsl:value-of select="$attass"/><xsl:text>&apos; </xsl:text>
					</xsl:if>
					<xsl:if test="$class-stereo != ''">
						<xsl:text>in dit </xsl:text><xsl:value-of select="$class-stereo"/><xsl:text> </xsl:text>
					</xsl:if>
					is toegevoegd.</li>
			</xsl:when>
			<!--xsl:when test="$event='ADDED' and $property = '' and $attass = ''"-->
			<xsl:when test="$event='ADDED' and $property = '' and $class-stereo != ''">
				<li>Dit <xsl:value-of select="$class-stereo"/> is toegevoegd.</li>
			</xsl:when>
			<!--xsl:otherwise>
				<xsl:value-of select="concat($event,'-',$type,'-',$property,'-',$property-stereo,'-',$domain,'-',$domain-stereo,'-',$class-stereo,'-',$attass,'-',$attass-stereo,'-',$currentvalue,'-',$newvalue)"/>
			</xsl:otherwise-->
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>
