<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:cp="http://www.imvertor.org/schema/comply-excel"
    >
   
    <!-- TODO stub nodig voor opvangen van onvoorziene veranderingen in EP formaat, later verwijderen. -->

<?xx
    <xsl:template match="/ep:message-set/ep:message/ep:seq/ep:construct[ep:seq/ep:constructRef]">
        <xsl:apply-templates select="ep:seq/ep:constructRef"/>
    </xsl:template>
xx?>
    
    <xsl:template match="ep:patroon">
        <ep:pattern>
            <xsl:apply-templates/>
        </ep:pattern>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
       
</xsl:stylesheet>