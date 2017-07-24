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
                <head>stuurgegevens</head>
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

    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="ep:message-sets" mode="prepare-flat"/>
    </xsl:template>
    
    <xsl:template match="ep:message-sets" mode="prepare-flat">
        <cp:sheets>
            <cp:sheet>
                <xsl:apply-templates select="ep:message-set/ep:message" mode="prepare-flat-block"/> 
            </cp:sheet>
            <cp:sheet>
                <!-- alle constructs waarnaar gerefereerd wordt vereist predicate [ep:tech-name = //*/ep:href] -->
                <xsl:for-each select="ep:message-set/ep:construct">
                    <xsl:apply-templates select="." mode="prepare-flat-block"/> 
                </xsl:for-each>
            </cp:sheet>
            <cp:sheet>
                <!-- de namespace declaraties -->
                <xsl:for-each-group select="ep:message-set/ep:namespaces/ep:namespace" group-by="@prefix">
                    <cp:ns prefix="{current-group()[1]/@prefix}">
                        <xsl:value-of select="current-group()[1]"/>
                    </cp:ns>
                </xsl:for-each-group>
            </cp:sheet>
        </cp:sheets>
    </xsl:template>
    
    <xsl:template match="ep:message" mode="prepare-flat-block"> <!-- for sheet 1 -->
        <cp:block sheet="1">
            <cp:prop type="header">
                <xsl:sequence select="imf:create-element('cp:name',imf:get-qualified-name(.))"/>
            </cp:prop>
            <xsl:apply-templates select="(ep:seq|ep:choice)" mode="prepare-flat"/>
            <cp:prop type="empty"/>
        </cp:block>
    </xsl:template>
    
    <xsl:template match="ep:construct" mode="prepare-flat-block"> <!-- for sheet 2 -->
       
        <cp:block sheet="2">
            <xsl:sequence select="imf:create-element('cp:id',imf:get-id(.))"/>
            <cp:prop type="header">
                <xsl:sequence select="imf:create-element('cp:name',concat(imf:get-qualified-name(.), if (ep:tip-1) then ' (ETC)' else ''))"/>
                <xsl:sequence select="imf:create-element('cp:tip',concat('Let op! Meerdere referenties met verschillende namen naar dit element: ', ep:tip-1))"/>
            </cp:prop>
            <xsl:apply-templates select="(ep:seq|ep:choice)" mode="prepare-flat"/>
            <cp:prop type="empty"/>
        </cp:block>
    </xsl:template>
    
    <xsl:template match="ep:seq" mode="prepare-flat">
        <xsl:apply-templates select="ep:construct | ep:constructRef" mode="prepare-flat">
            <xsl:with-param name="group-type">seq</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="ep:choice" mode="prepare-flat">
        <cp:prop type="choice">
            <xsl:sequence select="imf:create-element('cp:cardinal',imf:format-cardinality(ep:min-occurs,ep:max-occurs))"/>
        </cp:prop>
        <xsl:apply-templates select="ep:construct | ep:constructRef" mode="prepare-flat">
            <xsl:with-param name="group-type">choice</xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="ep:construct | ep:constructRef" mode="prepare-flat">
        <xsl:param name="as-attribute" select="@ismetadata = 'yes'"/>
        <xsl:param name="group-type"/> <!-- choice or seq -->
        
        <xsl:variable name="digit-before" select="ep:length - 1 - ep:fraction-digits"/>
        <xsl:variable name="digit-after" select="ep:fraction-digits"/>
        <xsl:variable name="digit-pattern" select="concat('[+\-]?\d{', $digit-before, '},\d{', $digit-after, '}')"/> 
        <xsl:variable name="type-name" select="ep:type-name"/>

        <xsl:variable name="reference-id" as="xs:string?">
            <xsl:variable name="construct" select="root(.)//ep:construct[(ep:tech-name, ep:name) = current()/ep:href]"/>
            <xsl:if test="exists($construct)">
                <xsl:value-of select="imf:get-id($construct)"/>
            </xsl:if>        </xsl:variable>
        
        <cp:prop type="spec" group="{$group-type}">
            <xsl:if test="$reference-id">
                <xsl:attribute name="ref">
                    <xsl:value-of select="$reference-id"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:sequence select="imf:create-element('cp:name',imf:get-qualified-name(.))"/>
            <xsl:sequence select="imf:create-element('cp:cardinal',imf:format-cardinality(ep:min-occurs,ep:max-occurs))"/>
            <xsl:sequence select="imf:create-element('cp:documentation',ep:documentation)"/>
            <xsl:sequence select="imf:create-element('cp:attribute',string($as-attribute))"/>
            <xsl:sequence select="imf:create-element('cp:fixed',if (ep:enum[2]) then () else ep:enum[1])"/>
            <xsl:sequence select="imf:create-element('cp:enum',string-join(ep:enum,', '))"/>
            <xsl:sequence select="imf:create-element('cp:type',ep:data-type)"/>  <!-- TODO types die Frank noemt zijn: int integer nonNegativeInteger positiveInteger decimal -->
            <xsl:sequence select="imf:create-element('cp:pattern',if (exists(ep:formeel-patroon)) then ep:formeel-patroon else if (ep:fraction-digits) then $digit-pattern else ())"/>
            <xsl:sequence select="imf:create-element('cp:patterndesc',ep:patroon)"/>
            <xsl:sequence select="imf:create-element('cp:mininclusive',ep:min-value)"/>
            <xsl:sequence select="imf:create-element('cp:maxinclusive',ep:max-value)"/>
            <xsl:sequence select="imf:create-element('cp:minlength',ep:min-length)"/>
            <xsl:sequence select="imf:create-element('cp:maxlength',(ep:length,ep:max-length)[1])"/>
           
            <xsl:sequence select="imf:create-element('cp:regels',ep:regels)"/>
   
            <xsl:sequence select="imf:create-element('cp:kerngegeven',if (.//ep:kerngegeven = 'Ja') then 'Ja' else ())"/>
            <xsl:sequence select="imf:create-element('cp:voidable',.//ep:mogelijk-geen-waarde)"/>
            <xsl:sequence select="imf:create-element('cp:authentiek',.//ep:authentiek)"/>
           
        </cp:prop>
      
        <!-- subconstructs may occur, always in sequence and attributes -->
        <xsl:apply-templates select="ep:seq" mode="prepare-flat"/>
        
    </xsl:template>
    
  
    
    
    
    
    
    
    
    
    
    <xsl:template match="node()|@*" mode="prepare-flat">
        <!-- remove -->
    </xsl:template>
   
    <xsl:function name="imf:format-cardinality">
        <xsl:param name="min-occurs"/>
        <xsl:param name="max-occurs"/>
        <xsl:variable name="min-occurs-use" select="if (normalize-space($min-occurs)) then $min-occurs else '1'"/>
        <xsl:variable name="max-occurs-use" select="if (normalize-space($max-occurs)) then $max-occurs else '1'"/>
        <xsl:value-of select="concat($min-occurs-use,'..',if ($max-occurs-use = 'unbounded') then 'n' else $max-occurs-use)"/>
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
        <xsl:if test="normalize-space($content) and not(starts-with($content,'TO-DO'))">
            <xsl:element name="{$name}">
                <xsl:value-of select="$content"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-id">
        <xsl:param name="this" as="element()"/>
        <xsl:value-of select="generate-id($this)"/>
    </xsl:function>
  
    <xsl:function name="imf:get-qualified-name">
        <xsl:param name="this"/>
        <xsl:value-of select="$this/ep:name"/>
        <!--x
            <xsl:variable name="my-prefix" select="$this/@prefix"/>
        <xsl:variable name="is-attribute" select="$this/@ismetadata = 'yes'"/>
        <xsl:variable name="prefix" select="if (exists($my-prefix)) then $my-prefix else if ($is-attribute) then '' else ($this/ancestor-or-self::*/@prefix)[1]"/>
        <xsl:value-of select="concat(if ($prefix != '') then concat($prefix,':') else '',$this/ep:tech-name)"/>
        x-->
    </xsl:function>
    
  
</xsl:stylesheet>