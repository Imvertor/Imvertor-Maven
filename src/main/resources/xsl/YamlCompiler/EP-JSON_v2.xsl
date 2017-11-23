<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ep="http://www.imvertor.org/schema/endproduct" version="2.0">
    <xsl:output method="text" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="ep:message-sets">
        
        <!-- vind de koppelvlak namespace: -->      
        <xsl:variable name="kvnamespace" select="ep:message-set[@KV-namespace = 'yes']/@prefix"></xsl:variable>
        
        <xsl:value-of select="'{'"/>
        <!--definitions -->
        <xsl:value-of select="'&quot;components&quot;: {'"/>
        <xsl:value-of select="'&quot;schemas&quot;: {'"/>

        <xsl:for-each select="ep:message-set/ep:construct[@prefix = $kvnamespace][not(@ismetadata)]">
            <xsl:call-template name="construct"/>
        </xsl:for-each>
        <!-- Alle types behalve superconstructs uit andere namespaces -->
        <xsl:value-of select="','"/>
        <xsl:for-each select="ep:message-set[@prefix != $kvnamespace]/ep:construct[@prefix != $kvnamespace][not(@ismetadata)][not(@addedLevel)][not(@isdatatype)]">
            <xsl:variable name="prefixNameSup" select="@prefix"/>
            <xsl:variable name="elementNameSup" select="ep:tech-name"/>
            <xsl:if test="not(exists(/ep:message-sets/ep:message-set[@prefix=$kvnamespace]/ep:construct/ep:superconstructRef[@prefix=$prefixNameSup][ep:tech-name=$elementNameSup]))">
                <xsl:call-template name="construct"/>
            </xsl:if>
        </xsl:for-each>
        <!-- Voor alle dataType objecten uit andere namespaces (superconstruct data types) -->
        <xsl:value-of select="','"/>
        <xsl:for-each select="ep:message-set[@prefix != $kvnamespace]/ep:construct[@prefix != $kvnamespace][@isdatatype][not(@addedLevel)]">
            <xsl:variable name="techname" select="ep:tech-name"/>
            <!-- if statement is voor het uitsluiten van dubbele types in meerdere namespaces (String10, String20) -->
            <xsl:if test="not(exists(/ep:message-sets/ep:message-set/ep:construct[@prefix = $kvnamespace][@isdatatype = 'yes'][ep:tech-name = $techname]))">
                <xsl:call-template name="construct"/>
            </xsl:if>
        </xsl:for-each>
        
        
        <!-- Toevoeging voor missend Datum  en TijdstipMogelijkOnvolledig datatype (tijdelijk)-->
        <xsl:value-of select="',&quot;Datum&quot;: {&quot;type&quot;: &quot;string&quot;}'"/>
        <xsl:value-of select="',&quot;TijdstipMogelijkOnvolledig&quot;: {&quot;type&quot;: &quot;string&quot;}'"/>

        <xsl:value-of select="'}'"/>
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
            <xsl:when test="exists(ep:choice)">
                <!-- Choise elementen -->
                <xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>
                
                <xsl:for-each select="ep:choice">
                    <xsl:value-of select="'&quot;oneOf&quot;: ['"/>
                    <xsl:for-each select="ep:construct[@prefix = $prefixName][not(@ismetadata)][not(@addedLevel)]">
                        <xsl:call-template name="choiceProperty"/>
                        <xsl:if test="position() != last()">
                            <xsl:value-of select="','"/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:value-of select="']'"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>


                <xsl:value-of select="'&quot;type&quot;: &quot;object&quot;,'"/>

                <xsl:value-of select="'&quot;properties&quot;: {'"/>
                
                <!-- Waarden uit superconstruct (andere namespace) -->
                <xsl:if test="exists(ep:superconstructRef)">
                    <xsl:variable name="prefix" select="ep:superconstructRef/@prefix"/>
                    
                    <xsl:variable name="name" select="ep:superconstructRef/ep:tech-name"/>
                    <xsl:for-each select="/ep:message-sets/ep:message-set[@prefix = $prefix]/ep:construct[@prefix = $prefix][ep:tech-name = $name]/ep:seq/ep:construct[not(@ismetadata)]">
                        <xsl:call-template name="property"/>
                        <xsl:value-of select="','"/>
                    </xsl:for-each>
                </xsl:if>
                
                <!-- Waarden uit eigen namespace -->
                <xsl:for-each select="ep:seq/ep:construct[@prefix = $prefixName][not(@ismetadata)]">
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
        
        <xsl:if test="exists(ep:type-name) or exists(ep:data-type)">
        <xsl:value-of select="concat('&quot;', ep:tech-name,'&quot;: {' )"/>
        <xsl:value-of select="$derivedTypeName"/>
        <xsl:value-of select="'}'"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="choiceProperty">  
        <xsl:variable name="derivedTypeName">
            <xsl:call-template name="derivePropertyTypeName">
                <xsl:with-param name="typeName" select="substring-after(ep:type-name, ':')"/>
                <xsl:with-param name="typePrefix" select="substring-before(ep:type-name, ':')"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="'{'"/>
        <xsl:value-of select="$derivedTypeName"/>
        <xsl:value-of select="'}'"/>
    </xsl:template>

    <xsl:template name="derivePropertyTypeName">
        <xsl:param name="typeName"/>
        <xsl:param name="typePrefix"/>
        <xsl:choose>
            <xsl:when test="exists(ep:data-type)">
                <!-- Uitzondering voor constructs die niet verwijzen naar een ander type, maar die een datatype als soort hebben -->
                <xsl:value-of select="'&quot;type&quot;: &quot;string&quot;'"></xsl:value-of>
            </xsl:when>
            <xsl:when test="exists(/ep:message-sets//ep:construct[ep:tech-name = $typeName][@prefix=$typePrefix][exists(@addedLevel)]/ep:type-name)">
                <xsl:value-of
                    select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', substring-after(/ep:message-sets//ep:construct[ep:tech-name = $typeName][@prefix=$typePrefix][exists(@addedLevel)]/ep:type-name, ':'), '&quot;')"
                />
            </xsl:when>
            <!-- Fix voor de StUF (Datum-e), Postcode-e en INDIC-e velden. Deze zouden eigenlijk met een @addedLevel moeten worden uitgerust-->
            <xsl:when test="$typePrefix = 'StUF' and ends-with($typeName, '-e')">
                <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', substring-before($typeName, '-e'), '&quot;')"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:value-of select="concat('&quot;$ref&quot;: &quot;#/components/schemas/', $typeName, '&quot;')"/>
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
            <xsl:when test="$incomingType = 'dateTime'">
                <xsl:value-of select="'string'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'nonNegativeInteger'">
                <xsl:value-of select="'number'"/>
            </xsl:when>
            <xsl:when test="$incomingType = 'positiveInteger'">
                <xsl:value-of select="'number'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$incomingType"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
