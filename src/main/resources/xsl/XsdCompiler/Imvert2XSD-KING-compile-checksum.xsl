<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    version="2.0">
    
    <!-- ==== compile the checksum: #488785 redmine ==== -->
    
    <!-- 
        context document is parms.xml.
        
        this reads the input file (parms.xml) and stores the checksum entries in the blackboard position 
    -->
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/config/simpletype-checksum">
        <simpletype-checksum 
            date="{current-date()}" 
            subpath="{/config/appinfo/release-name}" 
            version="{/config/run/version}"
            jobid="{/config/cli/jobid}"
            >
            <xsl:variable name="entries" as="element(entry)*">
                <xsl:apply-templates select="entry"/>
            </xsl:variable> 
            <!-- remove duplicates -->
            <xsl:variable name="single" as="element(entry)*">
                <xsl:for-each-group select="$entries" group-by="concat(@base,@facet)">
                    <xsl:sequence select="current-group()[1]"/>
                </xsl:for-each-group>
            </xsl:variable>
            <!-- sort by name -->
            <xsl:for-each select="$single">
                <xsl:sort select="@name"/>
                <xsl:sequence select="."/>
            </xsl:for-each>
        </simpletype-checksum>
    </xsl:template>
    
    <xsl:template match="entry">
        <xsl:variable name="tokens" select="tokenize(.,'\[SEP\]')"/>
        <entry name="{$tokens[1]}" base="{$tokens[2]}" facet="{$tokens[3]}" state="{$tokens[4]}"/>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>