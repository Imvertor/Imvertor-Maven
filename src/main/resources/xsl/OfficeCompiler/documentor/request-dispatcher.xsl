<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"  
  xmlns:req="http://www.armatiek.com/xslweb/request"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:pipeline="http://www.armatiek.com/xslweb/pipeline"
  xmlns:config="http://www.armatiek.com/xslweb/configuration"
  xmlns:webapp="http://www.armatiek.com/xslweb/functions/webapp"
  
  exclude-result-prefixes="#all"
  version="3.0">
    
  <xsl:variable name="path-toks" select="subsequence(tokenize(/req:request/req:path,'/'),2)"/>
  
  <xsl:variable name="module" select="$path-toks[1]"/> <!-- respec, leapinlist, wikisolr, file, .. -->
  <xsl:variable name="mode" select="$path-toks[2]"/> <!-- nu nog alleen mogelijk: primer --> 
  
  <xsl:template match="/">
    <pipeline:pipeline> 
      
      <xsl:if test="$module ne 'file'">
        <xsl:sequence select="webapp:set-attribute('module',$module)"/> <!-- naar webapp, want deze info delen óver requests heen -->
        <xsl:sequence select="webapp:set-attribute('mode',$mode)"/>
      </xsl:if>
      
      <xsl:choose>
        
        <xsl:when test="$module =  'respec'">
          <pipeline:pipeline>
            <pipeline:transformer name="prepare"                xsl-path="core/prepare.xsl" log="false"/> 
            <pipeline:transformer name="prepare-respec"         xsl-path="respec/prepare-respec.xsl" log="false"/> 
            <pipeline:transformer name="scanner"                xsl-path="core/scanner.xsl" log="false"/> <!-- scanner start op elk file de /file pipeline -->
            <pipeline:transformer name="modes"                  xsl-path="core/modes.xsl" log="false"/> 
            <pipeline:transformer name="xhtml-to-respec"        xsl-path="respec/xhtml-to-respec.xsl" log="false"/> 
            <pipeline:transformer name="windup-respec"          xsl-path="respec/windup-respec.xsl" log="false"/> 
          </pipeline:pipeline>
        </xsl:when>
        
        <xsl:when test="$module =  'leapinlist'">
          <pipeline:pipeline>
            <pipeline:transformer name="prepare"                xsl-path="core/prepare.xsl" log="false"/> 
            <pipeline:transformer name="prepare-leapinlist"     xsl-path="leapinlist/prepare-leapinlist.xsl" log="false"/> 
            <pipeline:transformer name="scanner"                xsl-path="core/scanner.xsl" log="false"/> <!-- scanner start op elk file de /file pipeline -->
            <pipeline:transformer name="modes"                  xsl-path="core/modes.xsl" log="false"/> 
            <pipeline:transformer name="xhtml-to-leapinlist"    xsl-path="leapinlist/xhtml-to-leapinlist.xsl" log="false"/>
            <pipeline:transformer name="windup-leapinlist"      xsl-path="leapinlist/windup-leapinlist.xsl" log="false"/> 
          </pipeline:pipeline>
        </xsl:when>
        
        <xsl:when test="$module =  'wikisolr'"> 
          <pipeline:pipeline>
            <pipeline:transformer name="prepare"                xsl-path="core/prepare.xsl" log="false"/> 
            <pipeline:transformer name="prepare-wikisolr"       xsl-path="wikisolr/prepare-wikisolr.xsl" log="false"/> 
            <pipeline:transformer name="scanner"                xsl-path="core/scanner.xsl" log="false"/> 
            <pipeline:transformer name="modes"                  xsl-path="core/modes.xsl" log="false"/> 
            <pipeline:transformer name="xhtml-to-wikisolr"      xsl-path="wikisolr/xhtml-to-wikisolr.xsl" log="false"/> 
            <pipeline:transformer name="windup-wikisolr"        xsl-path="wikisolr/windup-wikisolr.xsl" log="false"/> 
          </pipeline:pipeline>
        </xsl:when>
        
        <!--
          Zet een individeel MsWord document om.
        -->
        <xsl:when test="$module =  'file'">
          <pipeline:pipeline>
            <!-- fix eerste wat problemen met MsWord -->
            <pipeline:transformer name="documentor-fixes" xsl-path="core/file-fixes.xsl" log="false"/> 
            <!-- zet om naar XHTML; hierna wordt de XHTML/XML doorgegeven totaal eindresultaat -->
            <pipeline:transformer name="documentor-pandoc" xsl-path="core/file-pandoc.xsl" log="false"/> 
            <!-- zet HTML constructies om naar betekenisvolle elementen, en breng metadata in -->
            <pipeline:transformer name="documentor-prepare" xsl-path="core/file-prepare.xsl" log="false"/> 
            <!-- finaliseer zodat uitvoerkanaal kan worden aangesproken  -->
            <pipeline:transformer name="documentor-finalize" xsl-path="core/file-finalize.xsl" log="false"/> 
          </pipeline:pipeline>
        </xsl:when>
      </xsl:choose>

    </pipeline:pipeline>
  </xsl:template>
  
</xsl:stylesheet>