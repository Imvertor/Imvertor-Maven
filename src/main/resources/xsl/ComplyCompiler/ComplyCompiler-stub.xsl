<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:cp="http://www.imvertor.org/schema/comply-excel"
    >
   
    <!-- 
        This stylesheet aadpts the EP format in accordance with last minute requirements.
        It also tests for unforeseen constructs (technical validation)
    -->

    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-validation.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:variable name="ep-onderlaag-path" select="imf:get-config-string('properties','IMVERTOR_COMPLY_EPFORMAAT_XMLPATH')"/>
    <xsl:variable name="ep-onderlaag" select="imf:document($ep-onderlaag-path,true())/ep:message-set"/>
    
    <xsl:template match="/ep:message-sets">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <!-- and append the onderlaag -->
            <xsl:sequence select="$ep-onderlaag"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ep:seq | ep:choice">
        <xsl:sequence select="imf:report-error(.., 
            exists(ancestor::ep:choice), 
            'Sequence or choice may not occur within choice')"/>   
      
        <xsl:next-match/>
    </xsl:template>
    
    <!--xx
    <xsl:template match="ep:patroon">
        <xsl:next-match/>
        <ep:patroon-beschrijving>
            BESCHRIJVING VOLGT NOG
        </ep:patroon-beschrijving>
    </xsl:template>
    xx-->
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
       
</xsl:stylesheet>