<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:re="http://www.kadaster.nl/schemas/Erfdienstbaarheden/RegistratieErfdienstbaarheden/v20150601"
    xmlns:ko-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-kadastraalobject-ref/v20150601"
    xmlns:ko="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-kadastraalobject/v20150601"
    xmlns:oz-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-onroerendezaak-ref/v20150601"
    xmlns:oz="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-onroerendezaak/v20150601"
    xmlns:r-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-recht-ref/v20150601"
    xmlns:r="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-recht/v20150601"
    xmlns:s-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-stuk-ref/v20150601"
    xmlns:s="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-stuk/v20150601"
    xmlns:p="http://www.kadaster.nl/schemas/generiek/procesresultaat/v20110922"
    xmlns:t="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-typen/v20150601"
    
    xmlns:gml="http://www.opengis.net/gml/3.2"
    
    xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
    
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    
    xmlns:xlink="http://www.w3.org/1999/xlink"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/compare/file">
        <xsl:variable name="doc" select="imf:document(@path)"/>
        <xsl:message select="@path"/>
        <xsl:result-document href="{imf:file-to-url(concat(@path,'-clean.xml'))}">
            <xsl:apply-templates select="$doc/*:model"/>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="/*:model">
        <xsl:next-match/>
    </xsl:template>
 
    <xsl:template match="*:elements | *:relationships | *:propertydefs | *:views">
        <xsl:copy>
            <xsl:apply-templates select="*">
                <xsl:sort select="@identifier"/>
            </xsl:apply-templates>
        </xsl:copy>    
    </xsl:template>
    
    <xsl:template match="*:properties">
        <xsl:copy>
            <xsl:apply-templates select="*:property">
                <xsl:sort select="@identifierref"/>
            </xsl:apply-templates>
        </xsl:copy>    
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>