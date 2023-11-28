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
       
       Eerste stap:      
         - Omzetten van associatieklassen naar gewone objecttypen, zie https://geonovum.github.io/uml2json/document.html#toc40
         - Verwijderen van tweede jsonPrimaryInterval attribuut
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="relatierol-leidend" select="/mim:Informatiemodel/mim:relatiemodelleringtype = 'Relatierol leidend'"/>
    
    <xsl:variable name="requirement-levels" select="('bp-basic-encodings','bp-by-reference-encodings','bp-code-list-encodings','bp-union-encodings','bp-additional-requirements-classes')" as="xs:string+"/>
    
    <xsl:variable name="bp-req-basic-encodings" select="$configuration-jsonschemarules-file//parameter[@name = 'bp-basic-encodings']"/> 
    
    <xsl:template match="/">
        
        <xsl:variable name="bp-reqs" select="$configuration-jsonschemarules-file//parameter[@name = $requirement-levels]"/> 
        <xsl:choose>
            <xsl:when test="count($bp-reqs) eq 5">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg(.,'ERROR','Incomplete Json schema configuration, please supply alle of [1]',imf:string-group($requirement-levels))"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="mim:Domein/mim:objecttypen">
        <mim:objecttypen>
            <xsl:apply-templates select="*"/>
            <xsl:apply-templates select="mim:Objecttype/mim:relatiesoorten/mim:Relatiesoort/mim:relatieklasse/mim:Relatieklasse"/>
        </mim:objecttypen>
    </xsl:template>
    
    <xsl:template match="mim:relatieklasse">
        <!-- wordt in andere context verwerkt -->
    </xsl:template>
    
    <xsl:template match="mim:Relatiesoort[mim:relatieklasse]">
        <xsl:variable name="relatie" select="."/>
        <xsl:variable name="relatieklasse" select="mim:relatieklasse/mim:Relatieklasse"/>
        <xsl:variable name="relatie-naam" select="if ($relatierol-leidend) then $relatie/mim:relatierollen/mim:Doel/mim:naam else $relatie/mim:naam"/>
        <mim:Relatiesoort>
            <mim:naam>{$relatie/mim:naam}</mim:naam>
            <mim:doel>
                <mim-ref:ObjecttypeRef index="{$relatie/@index}"
                    label="{$relatie-naam}"
                    xlink:href="#{$relatieklasse/@id}">{$relatieklasse/mim:naam}</mim-ref:ObjecttypeRef>
            </mim:doel>
            <mim:relatierollen>
                <mim:Bron>
                    <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Bron/*[not(name() = ('mim:kardinaliteit'))]"/>
                    <mim:kardinaliteit>1</mim:kardinaliteit>
                </mim:Bron>
                <mim:Doel>
                    <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Doel/*[not(name() = ('mim:kardinaliteit'))]"/>
                    <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Doel/mim:kardinaliteit"/>
                </mim:Doel>
            </mim:relatierollen>
        </mim:Relatiesoort>
    </xsl:template>
    
    <!-- maak een objecttype voor de associatieklasse waarbij deze één in-gaande en één uitgaande relatie heeft -->
    <xsl:template match="mim:Relatieklasse">
        <xsl:variable name="relatie" select="../.."/>
        <xsl:variable name="relatieklasse" select="."/>
        <xsl:variable name="relatie-naam" select="if ($relatierol-leidend) then $relatie/mim:relatierollen/mim:Doel/mim:naam else $relatie/mim:naam"/>
        <mim:Objecttype>
            <xsl:apply-templates select="$relatieklasse/@*"/>
            <xsl:apply-templates select="$relatieklasse/*[not(name() = ('mim:relatiesoorten','mim:kardinaliteit'))]"/>
            <mim:relatiesoorten>
                <xsl:apply-templates select="$relatieklasse/mim:relatiesoorten/mim:Relatiesoort"/>
                <mim:Relatiesoort>
                    <xsl:apply-templates select="$relatie-naam"/><!-- herhaling van dezelfde naam -->
                    <xsl:apply-templates select="$relatie/mim:doel"/>
                    <mim:relatierollen>
                        <mim:Bron>
                            <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Bron/mim:naam"/>
                            <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Bron/mim:kardinaliteit"/>
                        </mim:Bron>
                        <mim:Doel>
                            <xsl:apply-templates select="$relatie/mim:relatierollen/mim:Doel/mim:naam"/>
                            <mim:kardinaliteit>1<!--staat vast--></mim:kardinaliteit>
                        </mim:Doel>
                    </mim:relatierollen>
                </mim:Relatiesoort>
            </mim:relatiesoorten>
        </mim:Objecttype>
    </xsl:template>
    
    <xsl:template match="mim:Attribuutsoort">
        <xsl:choose>
            <xsl:when test="$bp-req-basic-encodings = '/req/jsonfg' and mim-ext:kenmerken/mim-ext:Kenmerk[@naam = 'jsonPrimaryInterval'] = 'end'">
                <!-- remove, see https://github.com/Geonovum/shapeChangeTest/issues/27 -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>