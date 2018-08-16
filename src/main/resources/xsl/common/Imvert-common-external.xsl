<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    
    version="2.0">
    
    <xsl:function name="imf:get-external-type-name">
        <xsl:param name="attribute"/>
        <xsl:param name="as-type" as="xs:boolean"/>
        <!-- determine the name; hard koderen -->
        <xsl:for-each select="$attribute"> <!-- singleton -->
            <xsl:choose>
                <xsl:when test="imvert:type-package='Geography Markup Language 3'">
                    <xsl:variable name="type-suffix" select="if ($as-type) then 'Type' else ''"/>
                    <xsl:variable name="type-prefix">
                        <xsl:choose>
                            <xsl:when test="empty(imvert:conceptual-schema-type)">
                                <xsl:sequence select="imf:msg(.,'ERROR','No conceptual schema type specified',())"/>
                            </xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Point'">gml:Point</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Curve'">gml:Curve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Surface'">gml:Surface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiPoint'">gml:MultiPoint</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiSurface'">gml:MultiSurface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiCurve'">gml:MultiCurve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Geometry'">gml:Geometry</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiGeometry'">gml:MultiGeometry</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_ArcString'">gml:ArcString</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_LineString'">gml:LineString</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Polygon'">gml:Polygon</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Object'">gml:GeometryProperty</xsl:when><!-- see http://www.geonovum.nl/onderwerpen/geography-markup-language-gml/documenten/handreiking-geometrie-model-en-gml-10 -->
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Primitive'">gml:Primitive</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Position'">gml:Position</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_PointArray'">gml:PointArray</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_Solid'">gml:Solid</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_OrientableCurve'">gml:OrientableCurve</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_OrientableSurface'">gml:OrientableSurface</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_CompositePoint'">gml:CompositePoint</xsl:when>
                            <xsl:when test="imvert:conceptual-schema-type = 'GM_MultiSolid'">gml:MultiSolid</xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the [1] type [2]', (imvert:type-package,imvert:conceptual-schema-type))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="concat($type-prefix,$type-suffix)"/>
                </xsl:when>
                <xsl:when test="empty(imvert:type-package)">
                    <!-- TODO -->
                </xsl:when>
                <xsl:otherwise>
                    <!-- geen andere externe packages bekend -->
                    <xsl:sequence select="imf:msg(.,'ERROR','Cannot handle the external package [1]', imvert:type-package)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:function>
        
</xsl:stylesheet>