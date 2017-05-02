<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ext="http://www.imvertor.org/xsl/extensions"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  
  >
 
  <xsl:output method="html" indent="yes" omit-xml-declaration="yes"/>
  
  <xsl:variable name="reusable" select="//*[exists(@uuid)]"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <meta charset="UTF-8"/> 
        <style type="text/css">
          body {
          font-family:"Calibri","Verdana",sans-serif;
          font-size:11.0pt;
          }
          h1, h2, h3, h4,h5 {
          color:#003359;
          }
          h1 {
          page-break-before:always;
          font-size:16.0pt;
          }
          h2 {
          font-size:12.0pt;
          }
          h3 {
          font-size:12.0pt;
          }
          h4 {
          font-size:12.0pt;
          }
          h5 {
          font-size:12.0pt;
          }
          .listing {
            font-weight: bold;
          }
          .label {
            font-weight: normal;
          }
          .id {
            font-style: italic;
            color: gray;
          }
          .ref {
            font-style: italic;
            color: red;
          }
        </style>
      </head>
      <body>
        <xsl:apply-templates select="*:terInschrijvingAangebodenStuk"/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="*:terInschrijvingAangebodenStuk">
    <h1>
      Ter inschrijving aangeboden stuk
    </h1>
    <h2>
      <ul>
        <xsl:apply-templates select="*:tijdstipAanbieding"/>
        <xsl:apply-templates select="*:tijdstipAanbieding"/>
        <xsl:apply-templates select="*:wijzeVanAanbieding"/>
      </ul>
    </h2>
    <div class="listing">
      <xsl:apply-templates select="*:omvat"/>
    </div>
  </xsl:template>
  
  <xsl:template match="*">
      <li>
        <xsl:sequence select="imf:fetch-label(.)"/>
        <xsl:choose>
          <xsl:when test="*">
            <ul>
              <xsl:apply-templates/>
            </ul>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </li>
  </xsl:template>
   
  <!-- waarden uit een waardenlijst -->
  <xsl:template match="*[*:code | *:waarde]">
    <li>
      <xsl:sequence select="imf:fetch-label(.)"/>
      <xsl:value-of select="(*:waarde,*:code)[1]"/>
    </li>
  </xsl:template>
  
  <!-- vervang de referentie naar een object door dat object; maar alleen als het de eerste keer is dat het getoond wordt. -->
  <xsl:template match="*[empty(*) and starts-with(.,'_')]">
    <xsl:choose>
      <xsl:when test="preceding::* = .">
          <li>
            <xsl:sequence select="imf:fetch-label(.)"/>
            <span class="ref">
              ZIE <xsl:value-of select="$reusable[@uuid = string(current())]/@identificatie"/>
            </span>
          </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$reusable[@uuid = string(current())]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:function name="imf:fetch-label">
    <xsl:param name="element"/>
    <xsl:variable name="id" select="$element/@identificatie"/>
    <span class="label">
      <xsl:value-of select="local-name($element)"/>
    </span>: 
    <xsl:if test="exists($id)">
      <span class="id">
        <xsl:value-of select="$id"/>
      </span>
    </xsl:if>
  </xsl:function>
  
</xsl:stylesheet>