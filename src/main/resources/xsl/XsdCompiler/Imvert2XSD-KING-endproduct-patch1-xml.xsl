<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct-xml.xsl 7481 2016-03-28 08:40:41Z arjan $ 
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
    xmlns:imvert-ep="http://www.imvertor.org/schema/endproduct"
           xmlns:ep="http://www.imvertor.org/schema/endproduct"
    
    xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310" 
    xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking" 
    xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" 
    xmlns:stuf="http://www.egem.nl/StUF/StUF0301" 
    
    xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    
    version="2.0">
    
    <!-- TODO verwijderen. Patch1 is een patch op output formaat van robert; tijdelijk! Robert gaat dit zelf genereren -->
    
    <!-- <xsl:import href="../common/Imvert-common.xsl"/> -->
    <xsl:output method="xml" indent="yes"/>
  
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="ep:construct">
        <xsl:variable name="is-message-element" select="exists(../../self::ep:message)"/>
        <xsl:variable name="is-complex-type" select="exists(*/ep:construct)"/>
        <xsl:variable name="is-attribute" select="empty((ep:seq,ep:choice)) and exists(ep:type-name)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="is-message-element" select="$is-message-element"/>
            <xsl:attribute name="is-complex-type" select="$is-complex-type"/>
            <xsl:attribute name="is-attribute" select="$is-attribute"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- default: copy -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <?x niet meer nodig
    <xsl:template match="/imvert-ep:endproduct-structures">
        <message-set>
            <xsl:sequence select="imf:create-output-element('name','TODO')"/>
            <xsl:sequence select="imf:create-output-element('namespace','TODO')"/>
            <xsl:sequence select="imf:create-output-element('namespace-prefix','TODO')"/>
            <xsl:sequence select="imf:create-output-element('release','99999999')"/>
            <xsl:sequence select="imf:create-output-element('date',format-dateTime(current-dateTime(),'[MNn] [D], [Y0001] at [H2]:[m2]'))"/>
            <xsl:sequence select="imf:create-output-element('patch-number',0)"/>
            <xsl:apply-templates select="imvert-ep:message"/>
        </message-set>
    </xsl:template>
    
    <xsl:template match="imvert-ep:message">
        <message>
            <xsl:sequence select="imf:create-output-element('name',@name)"/>
            <xsl:sequence select="imf:create-output-element('type',@typeBericht)"/>
            <xsl:sequence select="imf:create-output-element('code',@berichtCode)"/>
            <xsl:sequence select="imf:create-output-element('package-type',@packageType)"/>
            <xsl:sequence select="imf:create-output-element('release','99999999')"/>
            <seq>
                <xsl:apply-templates select="imvert-ep:attributes/imvert-ep:attribute"/>
                <xsl:apply-templates select="imvert-ep:associations/imvert-ep:association"/>
            </seq>
        </message>
    </xsl:template>
    
    <xsl:template match="imvert-ep:attribute">
        <construct>
            <xsl:sequence select="imf:create-output-element('min-occurs',imvert-ep:min-occurs)"/>
            <xsl:sequence select="imf:create-output-element('max-occurs',imvert-ep:max-occurs)"/>
            <xsl:sequence select="imf:create-output-element('documentation',imvert-ep:documentation)"/>
         
            <xsl:sequence select="imf:create-output-element('id',imvert-ep:id)"/>
            <xsl:sequence select="imf:create-output-element('name',concat('SIMNAAM:', imvert-ep:name))"/>
            <xsl:sequence select="imf:create-output-element('tech-name',imvert-ep:name)"/>
            <xsl:sequence select="imf:create-output-element('is-id',imvert-ep:is-id)"/>
            <xsl:sequence select="imf:create-output-element('type-name',imvert-ep:type-name)"/>
            <xsl:sequence select="imf:create-output-element('min-length',imvert-ep:min-length)"/>
            <xsl:sequence select="imf:create-output-element('max-length',imvert-ep:max-length)"/>
            <xsl:sequence select="imf:create-output-element('pattern',imvert-ep:pattern)"/>
            <xsl:sequence select="imf:create-output-element('stereotype',imvert-ep:stereotype)"/>
            <xsl:sequence select="imf:create-output-element('voidable','TODO')"/>
            <xsl:sequence select="imf:create-output-element('kerngegeven','TODO')"/>
            <xsl:sequence select="imf:create-output-element('authentiek','TODO')"/>
            <xsl:sequence select="imf:create-output-element('regels','TODO')"/>
            <xsl:sequence select="imf:create-output-element('enum','TODO')"/>
            <xsl:sequence select="imf:create-output-element('min-value','TODO')"/>
            <xsl:sequence select="imf:create-output-element('max-value','TODO')"/>
            
        </construct>
    </xsl:template>
    <xsl:template match="imvert-ep:association">
        <construct>
            <xsl:comment select="imvert-ep:associationName"/>
            <xsl:sequence select="imf:create-output-element('min-occurs',imvert-ep:min-occurs)"/>
            <xsl:sequence select="imf:create-output-element('max-occurs',imvert-ep:max-occurs)"/>
            <xsl:sequence select="imf:create-output-element('documentation',imvert-ep:documentation)"/>
            <xsl:sequence select="imf:create-output-element('id',imvert-ep:id)"/>
            <xsl:sequence select="imf:create-output-element('name',concat('SIMNAAM:',imvert-ep:name))"/>
            <xsl:sequence select="imf:create-output-element('tech-name',imvert-ep:name)"/>
            <xsl:sequence select="imf:create-output-element('stereotype',imvert-ep:stereotype)"/>
            <xsl:sequence select="imf:create-output-element('voidable','TODO')"/>
            <xsl:sequence select="imf:create-output-element('authentiek','TODO')"/>
            <xsl:sequence select="imf:create-output-element('regels','TODO')"/>
            
            <seq>
                <xsl:apply-templates select="imvert-ep:attributes/imvert-ep:attribute"/>
                <xsl:apply-templates select="imvert-ep:associations/imvert-ep:association"/>
            </seq>
        </construct>
    </xsl:template>
    
    <xsl:template match="node()|@*"/>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="default" as="item()*"/>
        <xsl:param name="as-string" as="xs:boolean"/>
        <xsl:param name="allow-empty" as="xs:boolean"/>
        <xsl:variable name="computed-content" select="if ($content[1]) then $content else if (normalize-space(string($content))) then string($content) else $default" as="item()*"/>
        <xsl:if test="$computed-content[1] or $allow-empty">
            <xsl:element name="{$name}">
                <xsl:choose>
                    <xsl:when test="$as-string">
                        <xsl:value-of select="$computed-content"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="$computed-content"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="default" as="item()*"/>
        <xsl:param name="as-string" as="xs:boolean"/>
        <xsl:sequence select="imf:create-output-element($name,$content,$default,$as-string,false())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:param name="default" as="item()*"/>
        <xsl:sequence select="imf:create-output-element($name,$content,$default,true(),false())"/>
    </xsl:function>
    
    <xsl:function name="imf:create-output-element" as="element()?">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="content" as="item()*"/>
        <xsl:sequence select="imf:create-output-element($name,$content,'',true(),false())"/>
    </xsl:function>
    
    ?>
    
</xsl:stylesheet>
