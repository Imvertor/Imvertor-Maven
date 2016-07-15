<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:cp="http://www.imvertor.org/schema/comply-excel"
    >
    
    <!--
       Maak de struktuur van sheets als een "platte" xml struktuur.
       
       Voorbeeld van sheet2:
       <sheet>
            <block>
                <head>stuurgegevens</head>>
                <prop>
                    <element>berichtcode</element>
                    <cardinal>1:1</cardinal>
                    <waarde>LA01</waarde>
                </prop>
                <prop ref="Systeem">
                    <element>zender</element>
                    <cardinal>0..1</cardinal>
                </prop>
                <prop ref="Systeem">
                    <element>onvanger</element>
                    <cardinal>0..1</cardinal>
                </prop>
                <prop>
                    <element>referentienummer</element>
                    <cardinal>0..1</cardinal>
                </prop>
                <prop>
                    <element>tijdstipoBericht</element>
                    <cardinal>0..1</cardinal>
                    <comment>
                        type-name: string
                        pattern: [0-9]{8,17}
                    </comment>
                </prop>
                <foot/>
            </block>
            <block>
                <head>Systeem</head>
                <prop>
                    <element>organisatie</element>
                    <cardinal>0..1</cardinal>
                </prop>
                ...etc...
            </Systeem>
        </sheet>
    -->
   
    <xsl:template match="ep:message-set" mode="prepare-flat">
        <cp:sheets>
            <cp:sheet>
                <xsl:apply-templates select="ep:message" mode="prepare-flat-block"/> 
            </cp:sheet>
            <cp:sheet>
                <xsl:for-each select="ep:message/ep:seq//ep:construct[imf:is-complextype(.)]">
                    <xsl:apply-templates select="." mode="prepare-flat-block"/> <!--TODO may be seq or choice embedded -->
                </xsl:for-each>
            </cp:sheet>
        </cp:sheets>
    </xsl:template>
    
    <xsl:template match="ep:message" mode="prepare-flat-block"> <!-- for sheet 1 -->
        <cp:block sheet="1">
            <cp:prop type="header">
                <xsl:value-of select="ep:name"/>
            </cp:prop>
            <xsl:apply-templates select="ep:seq/ep:construct" mode="prepare-flat"/>
            <cp:prop type="empty"/>
        </cp:block>
    </xsl:template>
    
    <xsl:template match="ep:construct" mode="prepare-flat-block"> <!-- for sheet 2 -->
        <xsl:variable name="tech-name" select="ep:tech-name"/>
        <cp:block sheet="2">
            <xsl:sequence select="imf:create-element('cp:id',imf:get-id(.))"/>
            <cp:prop type="header">
                <xsl:value-of select="$tech-name"/>
            </cp:prop>
            <xsl:apply-templates select="ep:seq/ep:construct" mode="prepare-flat"/>
            <cp:prop type="empty"/>
        </cp:block>
    </xsl:template>
    
    <xsl:template match="ep:construct" mode="prepare-flat">
        <xsl:param name="as-attribute" select="false()"/>
        
        <xsl:variable name="id" select="imf:get-id(.)"/>
        <cp:prop type="spec">
            <xsl:if test="imf:is-complextype(.)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:sequence select="imf:create-element('cp:element',ep:tech-name)"/>
            <xsl:sequence select="imf:create-element('cp:cardinal',imf:format-cardinality(ep:min-occurs,ep:max-occurs))"/>
            <xsl:sequence select="imf:create-element('cp:comment',ep:documentation)"/>
            <xsl:sequence select="imf:create-element('cp:attribute',string($as-attribute))"/>
            <xsl:sequence select="imf:create-element('cp:fixed',if (ep:enum[2]) then () else ep:enum[1])"/>
            <xsl:sequence select="imf:create-element('cp:enum',string-join(ep:enum,', '))"/>
            <xsl:sequence select="imf:create-element('cp:type',ep:type-name)"/>  <!-- TODO types die Frank noemt zijn: int integer nonNegativeInteger positiveInteger decimal -->
            <xsl:sequence select="imf:create-element('cp:totaldigits',())"/>
            <xsl:sequence select="imf:create-element('cp:mininclusive',())"/>
            <xsl:sequence select="imf:create-element('cp:maxinclusive',())"/>
            <xsl:sequence select="imf:create-element('cp:minlength',())"/>
            <xsl:sequence select="imf:create-element('cp:maxlength',())"/>
        </cp:prop>
        <xsl:apply-templates select="ep:seq/ep:construct[@ismetadata = 'yes']" mode="prepare-flat">
            <xsl:with-param name="as-attribute" select="true()"/>
        </xsl:apply-templates>
        
    </xsl:template>
    
  
    
    
    
    
    
    
    
    
    
    <xsl:template match="node()|@*" mode="prepare-flat">
        <!-- remove -->
    </xsl:template>
   
    <xsl:function name="imf:create-range">
        <xsl:param name="range"/>
        <xsl:value-of select="concat($range/@sl,$range/@sn,':',$range/@el,$range/@en)"/>
    </xsl:function>
    
    <xsl:function name="imf:format-cardinality">
        <xsl:param name="min-occurs"/>
        <xsl:param name="max-occurs"/>
        <xsl:value-of select="concat($min-occurs,'..',if ($max-occurs = 'unbounded') then 'n' else $max-occurs)"/>
    </xsl:function>
    
    <!-- 
        een complex type is een seq met daarin minimaal één embedded construct die niet metadata is 
    -->
    <xsl:function name="imf:is-complextype" as="xs:boolean">
        <xsl:param name="construct"/>
        <xsl:variable name="embedded-constructs" select="$construct/descendant::ep:construct"/>
        <xsl:variable name="metadata-constructs" select="$embedded-constructs[@ismetadata = 'yes']"/>
        <xsl:sequence select="count($embedded-constructs) ne count($metadata-constructs)"/>
    </xsl:function>
    
    <xsl:function name="imf:create-element">
        <xsl:param name="name"/>
        <xsl:param name="content"/>
        <xsl:if test="normalize-space($content)">
            <xsl:element name="{$name}">
                <xsl:value-of select="$content"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-id">
        <xsl:param name="this"/>
        <xsl:variable name="id" select="if ($this/ep:id) then $this/ep:id else generate-id($this)"/>
        <xsl:value-of select="replace($id,'[\{\}]','_')"/>
    </xsl:function>
    
</xsl:stylesheet>