<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:cw="http://www.armatiek.nl/namespace/zip-content-wrapper"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="all-shared-strings" as="element()*">
        <xsl:sequence select="/cw:files/cw:file[@path='xl\sharedStrings.xml']/*:sst/*:si"/>
    </xsl:variable>
    
    <xsl:variable name="all-worksheets" as="element()*">
        <xsl:sequence select="/cw:files/cw:file[starts-with(@path,'xl\worksheets')]"/>
    </xsl:variable>
    <xsl:variable name="all-sheets" as="element()*">
        <xsl:sequence select="//*:sheet"/>
    </xsl:variable>
    <xsl:variable name="all-relationships" as="element()*">
        <xsl:sequence select="//*:Relationships/*:Relationship"/>
    </xsl:variable>
    
    <xsl:function name="imf:get-sheet-name">
        <xsl:param name="sheet-xml-name"/><!-- e.g. sheet8.xml -->
        <xsl:variable name="rid" select="$all-relationships[tokenize(@*:Target,'(\\|/)')[last()] = $sheet-xml-name]/@*:Id"/>
        <xsl:variable name="name" select="$all-sheets[@*:id = $rid]/@name"/>
        <xsl:value-of select="$name"/>
    </xsl:function>
  
    <xsl:template match="/">
        <worksheets>
            <!-- e.g. xl\worksheets\sheet1.xml -->
            <xsl:for-each select="$all-worksheets">
                <xsl:variable name="name" select="imf:get-sheet-name(tokenize(@path,'(\\|/)')[last()])"/>
                <worksheet name="{$name}" file-name="{tokenize(@path,'(\\|/)')[last()]}" file-path="{@path}">
                    <xsl:apply-templates select="*:worksheet/*:sheetData/*:row"/>
                </worksheet>
            </xsl:for-each>
        </worksheets>
    </xsl:template>
    
    <xsl:template match="*:row">
        <xsl:variable name="c" as="element()*">
            <xsl:apply-templates select="*:c"/>
        </xsl:variable>
        <xsl:if test="exists($c)">
            <row nr="{position()}">
                <xsl:sequence select="$c"/>
            </row>
        </xsl:if> 

    </xsl:template>
    
    <xsl:template match="*:c">
        <xsl:variable name="c" select="imf:get-string(.)"/>
        <xsl:if test="normalize-space($c)">
            <xsl:variable name="col-letter" select="tokenize(@r,'\d+')[1]"/>
            <cell nr="{string-length(substring-before('ABCDEFGHIJKLMNOPQRSTUVWXYZ',$col-letter)) + 1}" ch="{$col-letter}">
                <xsl:sequence select="$c"/>
            </cell>
        </xsl:if> 
    </xsl:template>
    
    <!-- 
        get the string from the shared strings section 
    -->
    <xsl:function name="imf:get-string" as="xs:string">
        <xsl:param name="c"/>
        <xsl:value-of select="if ($c/@t='s') then $all-shared-strings[xs:integer($c/*:v) + 1] else string-join($c/*:v,'')"/>
    </xsl:function>
    
    <xsl:template match="node()">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
</xsl:stylesheet>