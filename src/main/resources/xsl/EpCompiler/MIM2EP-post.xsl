<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mim="http://www.geostandaarden.nl/mim/mim-core/1.1"
    xmlns:mim-ext="http://www.geostandaarden.nl/mim/mim-ext/1.0"
    xmlns:mim-ref="http://www.geostandaarden.nl/mim/mim-ref/1.0"
    
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    xmlns:dlogger="http://www.armatiek.nl/functions/dlogger-proxy"
    
    xmlns:pack="http://www.armatiek.nl/packs"
    
    expand-text="yes"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>

    <xsl:variable name="bp-req-basic-encodings" select="imf:get-ep-parameter(/ep:group,'bp-req-basic-encodings')"/>
    <xsl:variable name="bp-req-by-reference-encodings" select="imf:get-ep-parameter(/ep:group,'bp-req-by-reference-encodings')"/>
    <xsl:variable name="bp-req-code-list-encodings" select="imf:get-ep-parameter(/ep:group,'bp-req-code-list-encodings')"/>
    <xsl:variable name="bp-req-additional-requirements-classes" select="imf:get-ep-parameter(/ep:group,'bp-req-additional-requirements-classes')"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- sorteer de constructs op naam; dit is ook zo in de spec -->
    <xsl:template match="ep:group[imf:get-ep-parameter(.,'use') = 'domein']">
        <xsl:copy>
            <xsl:apply-templates select="ep:parameters | ep:name"/>
            <ep:seq>
                <xsl:apply-templates select="ep:seq/ep:construct">
                    <xsl:sort select="ep:name"/>
                </xsl:apply-templates>
            </ep:seq>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ep:construct/ep:name">
        <ep:name>
            <xsl:choose>
                <xsl:when test="$bp-req-basic-encodings = ('/req/geojson','/req/jsonfg') and imf:boolean(imf:get-ep-parameter(..,'is-pga'))">geometry</xsl:when>
                <xsl:when test="$bp-req-basic-encodings = ('/req/jsonfg') and imf:boolean(imf:get-ep-parameter(..,'is-ppa'))">place</xsl:when>
                <xsl:when test="$bp-req-basic-encodings = ('/req/jsonfg') and imf:boolean(imf:get-ep-parameter(..,'is-pia'))">time</xsl:when><!-- req. 28 -->
                <xsl:when test="$bp-req-basic-encodings = ('/req/jsonfg') and imf:boolean(imf:get-ep-parameter(..,'is-pva'))">time</xsl:when>
                <xsl:otherwise>{.}</xsl:otherwise>
            </xsl:choose>    
        </ep:name>
    </xsl:template>
    
    <xsl:template match="ep:ref">
        
        <xsl:variable name="has-identity" select="imf:get-ep-parameter(..,'use') = ('objecttyperef')"/>
        <xsl:variable name="is-choice" select="imf:get-ep-parameter(..,'use') = ('keuzeref')"/><!-- keuze tussen objecttypen in relatie -->
        
        <!-- haal de waarde van de tagged value op het element, of de default, Voor relaties (met identity), een niveau hoger. -->
        <xsl:variable name="ibr" select="
            if ($has-identity or $is-choice) 
            then imf:get-ep-parameter(../../..,'inlineorbyreference')
            else imf:get-ep-parameter(..,'inlineorbyreference')"/>
          
        <xsl:variable name="inline-form">
            <xsl:next-match/>
        </xsl:variable>
        
        <xsl:variable name="by-reference-form">
            <ep:ref href="/known/byreference">ByReference</ep:ref>
        </xsl:variable>
      
        <xsl:variable name="link-object-form">
            <ep:ref href="/known/linkobject">LinkObject</ep:ref>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$bp-req-by-reference-encodings = '/req/by-reference-uri' and $ibr = 'byReference'">
                <xsl:sequence select="$by-reference-form"/>
            </xsl:when>                    
            <xsl:when test="$bp-req-by-reference-encodings = '/req/by-reference-uri' and $ibr = 'inlineOrByReference' and $has-identity">
                <ep:choice>
                    <xsl:sequence select="$inline-form"/>
                    <xsl:sequence select="$by-reference-form"/>
                </ep:choice>
            </xsl:when>                    
            <xsl:when test="$bp-req-by-reference-encodings = '/req/by-reference-uri'"><!-- inline -->
                <xsl:sequence select="$inline-form"/>
            </xsl:when>                    
            <xsl:when test="$bp-req-by-reference-encodings = '/req/by-reference-link-object' and $ibr = 'byReference'">
                <xsl:sequence select="$link-object-form"/>
            </xsl:when>                    
            <xsl:when test="$bp-req-by-reference-encodings = '/req/by-reference-link-object' and $ibr = 'inlineOrByReference' and $has-identity">
                <ep:choice>
                    <xsl:sequence select="$inline-form"/>
                    <xsl:sequence select="$link-object-form"/>
                </ep:choice>
            </xsl:when>                    
            <xsl:when test="$bp-req-by-reference-encodings = '/req/by-reference-link-object'"><!-- inline -->
                <xsl:sequence select="$inline-form"/>
            </xsl:when>                    
            <xsl:otherwise>
                <xsl:comment>Unknown ref requirement for {$bp-req-by-reference-encodings}</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
       
    </xsl:template>
    
    <!-- 
        nested properties, see /req/geojson-formats/nesting-feature-type-properties 
    -->
    <xsl:template match="ep:construct[imf:get-ep-parameter(.,'is-featuretype')]/ep:seq">
        <xsl:choose>
            <xsl:when test="$bp-req-basic-encodings = ('/req/geojson','/req/jsonfg')">
                <xsl:variable name="not-pconstructs" select="ep:construct[not(imf:boolean(imf:get-ep-parameter(.,'is-pga')) or imf:boolean(imf:get-ep-parameter(.,'is-ppa')) or imf:boolean(imf:get-ep-parameter(.,'is-pia')) or imf:boolean(imf:get-ep-parameter(.,'is-pva')))]"/>
                <xsl:variable name="pconstructs" select="ep:construct[imf:boolean(imf:get-ep-parameter(.,'is-pga')) or imf:boolean(imf:get-ep-parameter(.,'is-ppa')) or imf:boolean(imf:get-ep-parameter(.,'is-pia')) or imf:boolean(imf:get-ep-parameter(.,'is-pva'))]"/>
                <ep:seq>
                    <xsl:apply-templates select="$pconstructs"/>
                    <xsl:if test="$not-pconstructs">
                        <ep:construct>
                            <ep:parameters>
                                <ep:parameter name="use">added-properties</ep:parameter>
                            </ep:parameters>
                            <ep:name>properties</ep:name>
                            <ep:seq>
                                <xsl:apply-templates select="$not-pconstructs"/>
                            </ep:seq>
                        </ep:construct>
                    </xsl:if>
                </ep:seq>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
        Wanneer meerdere keuze objecten, en effectief alle by reference, dan deze terugbrengen tot één keuzeobject. 
        Check https://github.com/Geonovum/shapeChangeTest/issues/52 
    -->
    <xsl:template match="ep:construct[imf:get-ep-parameter(.,'use') = 'keuze' and imf:get-ep-parameter(ep:seq/ep:construct,'use') = 'objecttype']">
        <xsl:sequence select="dlogger:save('keuze',.)"></xsl:sequence>
        <xsl:choose>
            <xsl:when test="$bp-req-by-reference-encodings = '/req/by-reference-link-object'">
                <!-- breng construct terug tot een sequence van één target object -->
                <ep:construct>
                    <xsl:sequence select="*[empty(self::ep:choice)]"/>
                    <xsl:apply-templates select="ep:choice/ep:construct[1]/ep:ref"/>
                </ep:construct>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

     <xsl:function name="imf:get-ep-parameter" as="xs:string*">
        <xsl:param name="this"/>
        <xsl:param name="parameter-name"/>
        <xsl:sequence select="$this/ep:parameters/ep:parameter[@name = $parameter-name]"/>
    </xsl:function>
    
</xsl:stylesheet>