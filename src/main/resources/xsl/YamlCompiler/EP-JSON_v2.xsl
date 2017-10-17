<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="ep:message-sets">
        <xsl:value-of select="'{'"/>
        <!-- header MOETEN IN APARTE FILE (geen json)-->

        <!--paths MOETEN IN APARTE FILE (geen json)  
        <xsl:value-of select="'&quot;paths&quot;: {'"/>
        <xsl:for-each select="ep:message-set/ep:message">
            <xsl:value-of select="concat('&quot;/AAA/',ep:tech-name,'&quot;: {')"/>
            <xsl:value-of select="'&quot;get&quot;:{'"/>
            <xsl:value-of select="'&quot;tags&quot;:&quot;-AAA&quot;,'"/>
            <xsl:value-of select="'&quot;summary&quot;:&quot;&quot;,'"/>
              <xsl:value-of select="concat('&quot;operationId&quot;:&quot;/AAA/',ep:tech-name,'&quot;,')"/>
              <xsl:value-of select="'&quot;consumes&quot;:&quot;[]&quot;,'"/>
            <xsl:value-of select="'&quot;produces&quot;:&quot;-application/json,-text/json,-text/html,-application/xml,-text/xml&quot;'"/>

            <xsl:value-of select="'}'"/>
            <xsl:value-of select="'}'"/>
            <xsl:if test="position() != last()">
                <xsl:value-of select="','"/>
            </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="'},'"/>
-->
        <!--definitions -->
        <xsl:value-of select="'&quot;definitions&quot;: {'"/>

        <xsl:for-each select="ep:message-set/ep:construct[@prefix = 'bsmr'][not(@ismetadata)][not(@addedLevel)]">
            <xsl:call-template name="construct"/>
        </xsl:for-each>
        <!-- Alle types behalve superconstructs uit andere namespaces -->
        <xsl:value-of select="','"/>
        <xsl:for-each select="ep:message-set[@prefix != 'bsmr' and @prefix != 'StUF']/ep:construct[@prefix != 'bsmr' and @prefix != 'StUF'][not(@ismetadata)][not(@addedLevel)][not(@isdatatype)][not(starts-with(ep:type-name, 'StUF:'))]">
            <xsl:variable name="prefixNameSup" select="@prefix"/>
            <xsl:variable name="elementNameSup" select="ep:tech-name"/>
            <xsl:if test="not(exists(/ep:message-sets/ep:message-set[@prefix='bsmr']/ep:construct/ep:superconstructRef[@prefix=$prefixNameSup][ep:tech-name=$elementNameSup]))">
                <xsl:call-template name="construct"/>
            </xsl:if>
        </xsl:for-each>
        <!-- Voor alle metaData objecten uit andere namespaces (superconstruct data types) -->
        <xsl:value-of select="','"/>
        <xsl:for-each select="ep:message-set[@prefix != 'bsmr' and @prefix != 'StUF']/ep:construct[@prefix != 'bsmr' and @prefix != 'StUF'][@isdatatype][not(@addedLevel)]">
            <xsl:call-template name="construct"/>
        </xsl:for-each>

        <xsl:value-of select="'}'"/>
        <xsl:value-of select="'}'"/>
    </xsl:template>

    <xsl:template name="construct">
        <xsl:variable name="prefixName" select="@prefix"/>
        <xsl:variable name="elementName" select="ep:tech-name"/>


        <xsl:value-of select="concat('&quot;', $elementName,'&quot;: {' )"/>

        <xsl:choose>
            <xsl:when test="@isdatatype = 'yes'">
                <xsl:variable name="datatype">
                    <xsl:call-template name="deriveDataType">
                        <xsl:with-param name="incomingType" select="substring-after(ep:data-type, 'scalar-')"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="concat('&quot;type&quot;: &quot;',$datatype,'&quot;')"/>
            </xsl:when>
            <xsl:otherwise>


                <xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>

                <xsl:value-of select="'&quot;properties&quot;: {'"/>
                
                <!-- Waarden uit superconstruct (andere namespace) -->
                <xsl:if test="exists(ep:superconstructRef)">
                    <xsl:variable name="prefix" select="ep:superconstructRef/@prefix"/>
                    
                    <xsl:variable name="name" select="ep:superconstructRef/ep:tech-name"/>
                    <xsl:for-each select="/ep:message-sets/ep:message-set[@prefix = $prefix]/ep:construct[@prefix = $prefix][ep:tech-name = $name]/ep:seq/ep:construct[not(@ismetadata)][not(starts-with(ep:type-name, 'StUF:'))]">
                        <xsl:call-template name="property"/>
                        <xsl:value-of select="','"/>
                    </xsl:for-each>
                </xsl:if>
                
                <!-- Waarden uit eigen namespace -->
                <xsl:for-each select="ep:seq/ep:construct[@prefix = $prefixName][not(@ismetadata)][not(@addedLevel)]">
                    <xsl:call-template name="property"/>
                    <xsl:if test="position() != last()">
                        <xsl:value-of select="','"/>
                    </xsl:if>
                </xsl:for-each>
                
                <xsl:value-of select="'}'"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="'}'"/>

        <xsl:if test="position() != last()">
            <xsl:value-of select="','"/>
        </xsl:if>

    </xsl:template>
    
    <xsl:template name="property">  
        <xsl:variable name="derivedTypeName">
            <xsl:call-template name="derivePropertyTypeName">
                <xsl:with-param name="typeName" select="substring-after(ep:type-name, ':')"/>
                <xsl:with-param name="typePrefix" select="substring-before(ep:type-name, ':')"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="concat('&quot;', ep:tech-name,'&quot;: {' )"/>
        <xsl:value-of select="$derivedTypeName"/>
        <xsl:value-of select="'}'"/>
    </xsl:template>

    <xsl:template name="derivePropertyTypeName">
        <xsl:param name="typeName"/>
        <xsl:param name="typePrefix"/>
        <xsl:choose>
            <xsl:when test="exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName][@prefix=$typePrefix][exists(@addedLevel)])">
                <xsl:value-of
                    select="concat('&quot;$ref&quot;: &quot;#/definitions/', substring-after(/ep:message-sets//ep:construct[ep:tech-name = $typeName][@prefix=$typePrefix][exists(@addedLevel)]/ep:type-name, ':'), '&quot;')"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/definitions/', $typeName, '&quot;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="deriveDataType">
        <xsl:param name="incomingType"/>

        <xsl:choose>
            <xsl:when test="$incomingType = 'decimal'">
                <xsl:value-of select="'number'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'date'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$incomingType"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
