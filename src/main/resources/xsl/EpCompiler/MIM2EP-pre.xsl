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
    
    <!-- 
       Deze stylesheet wwrkt op MIM serialisatie formaat en produceert MIM.
       
       Eerste stap:      Omzetten van associatieklassen naar gewone objecttypen, zie https://geonovum.github.io/uml2json/document.html#toc40
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:template match="/">
        <xsl:apply-templates mode="assoc-class"/>
    </xsl:template>
    
    <xsl:template match="mim:Domein/mim:objecttypen" mode="assoc-class">
        <mim:objecttypen>
            <xsl:apply-templates select="*" mode="#current"/>
            <xsl:apply-templates select="mim:Objecttype/mim:relatiesoorten/mim:Relatiesoort/mim:relatieklasse/mim:Relatieklasse" mode="#current"/>
        </mim:objecttypen>
    </xsl:template>
    
    <xsl:template match="mim:relatieklasse" mode="assoc-class">
        <!-- wodrt in andere context verwerkt -->
    </xsl:template>
    
    <xsl:template match="mim:Relatiesoort[mim:relatieklasse]" mode="assoc-class">
        <xsl:variable name="relatie" select="."/>
        <xsl:variable name="relatieklasse" select="mim:relatieklasse/mim:Relatieklasse"/>
        <mim:Relatiesoort>
            <mim:naam>{$relatie/mim:naam}</mim:naam>
            <mim:doel>
                <mim-ref:ObjecttypeRef index="{$relatie/@index}"
                    label="TODO1"
                    xlink:href="#{$relatieklasse/@id}">{$relatieklasse/mim:naam}</mim-ref:ObjecttypeRef>
            </mim:doel>
            <mim:relatierollen>
                <mim:Bron>
                    <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Bron/*[not(name() = ('mim:kardinaliteit'))]" mode="#current"/>
                    <mim:kardinaliteit>1</mim:kardinaliteit>
                </mim:Bron>
                <mim:Doel>
                    <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Doel/*[not(name() = ('mim:kardinaliteit'))]" mode="#current"/>
                    <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Doel/mim:kardinaliteit" mode="#current"/>
                </mim:Doel>
            </mim:relatierollen>
        </mim:Relatiesoort>
    </xsl:template>
    
    <!-- maak een objecttype voor de associatieklasse waarbij deze één in-gaande en één uitgaande relatie heeft -->
    <xsl:template match="mim:Relatieklasse" mode="assoc-class">
        <xsl:variable name="relatie" select="../.."/>
        <xsl:variable name="relatieklasse" select="."/>
        <mim:Objecttype>
            <xsl:apply-templates select="$relatieklasse/@*" mode="#current"/>
            <xsl:apply-templates select="$relatieklasse/*[not(name() = ('mim:relatiesoorten','mim:kardinaliteit'))]" mode="#current"/>
            <mim:relatiesoorten>
                <xsl:apply-templates select="$relatieklasse/mim:relatiesoorten/mim:Relatiesoort" mode="#current"/>
                <mim:Relatiesoort>
                    <xsl:apply-templates select="$relatie/mim:naam" mode="#current"/><!-- herhaling van dezelfde naam -->
                    <xsl:apply-templates select="$relatie/mim:doel" mode="#current"/>
                    <mim:relatierollen>
                        <mim:Bron>
                            <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Bron/mim:naam" mode="#current"/>
                            <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Bron/mim:kardinaliteit" mode="#current"/>
                        </mim:Bron>
                        <mim:Doel>
                            <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Doel/mim:naam" mode="#current"/>
                            <mim:kardinaliteit>1<!--fixed--></mim:kardinaliteit>
                        </mim:Doel>
                    </mim:relatierollen>
                </mim:Relatiesoort>
            </mim:relatiesoorten>
        </mim:Objecttype>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="assoc-class">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>