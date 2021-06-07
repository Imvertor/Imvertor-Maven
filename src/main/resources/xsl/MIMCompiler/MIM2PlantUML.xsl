<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  xmlns:mim="http://www.geonovum.nl/schemas/MIMFORMAT/model/v20210522" 
  xmlns:mim-ref="http://www.geonovum.nl/schemas/MIMFORMAT/model-ref/v20210522"
  xmlns:http="http://expath.org/ns/http-client"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  xmlns:svg="http://www.w3.org/2000/svg"
  exclude-result-prefixes="#all"
  expand-text="yes"
  version="3.0">
  
  <xsl:output method="html" version="5" indent="yes" cdata-section-elements="style"/>
  
  <xsl:param name="debug" select="true()" as="xs:boolean"/>
  
  <xsl:mode on-no-match="shallow-skip"/>
  <xsl:mode name="id" on-no-match="shallow-copy"/>
  <xsl:mode name="svg" on-no-match="shallow-copy"/>
  <xsl:mode name="modal" on-no-match="shallow-skip"/>
  
  <xsl:variable name="lf" select="'&#xa;'" as="xs:string"/>
  <xsl:variable name="tb" select="'  '" as="xs:string"/>
  
  <xsl:variable name="mim-with-added-ids" as="document-node()">
    <xsl:apply-templates select="/" mode="id"/>
  </xsl:variable>
  
  <xsl:variable name="root" select="$mim-with-added-ids" as="document-node()"/>
  
  <xsl:key name="element-by-id" match="mim:*[@id]" use="@id"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <style type="text/css">
          .error {{color: red}}
          td:first-child {{
            width: 10%;
            white-space: nowrap;
          }}
          {unparsed-text('w3.css')}
        </style>
      </head>
      <body>
        <div class="w3-container">
          <h2>Model: {*/mim:naam}</h2>
          <xsl:where-populated>
            <p>{*/mim:definitie}</p>  
          </xsl:where-populated>
          <ul class="w3-ul w3-border" style="width:40%">
            <xsl:for-each select="$mim-with-added-ids/mim:Informatiemodel/*/mim:Domein">
              <xsl:if test="position() = 1">
                <li><h3>Domeinen</h3></li>  
              </xsl:if>
              <li><a href="{'#' || @id}">{mim:naam}</a></li>
            </xsl:for-each>
            <xsl:for-each select="$mim-with-added-ids/mim:Informatiemodel/*/mim:View">
              <xsl:if test="position() = 1">
                <li><h3>Views</h3></li>  
              </xsl:if>
              <li><a href="{'#' || @id}">{mim:naam}</a></li>
            </xsl:for-each>
            <xsl:for-each select="$mim-with-added-ids/mim:Informatiemodel/*/mim:Extern">
              <xsl:if test="position() = 1">
                <li><h3>Extern</h3></li>  
              </xsl:if>
              <li><a href="{'#' || @id}">{mim:naam}</a></li>
            </xsl:for-each>
          </ul>
          <xsl:apply-templates select="$mim-with-added-ids/mim:Informatiemodel/*/(mim:Domein|mim:View|mim:Extern)"/>
          <xsl:apply-templates select="$mim-with-added-ids//mim:*[@id]" mode="modal"/>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="mim:Domein|mim:View|mim:Extern">
    
    <xsl:variable name="puml-lines" as="element(line)+">
      <xsl:sequence select="imf:line(0, 1, '@startuml')"/>
      <xsl:sequence select="imf:line(0, 1, '!define primitiefdatatype(x) class x &lt;&lt;(D,#FF7700) Primitief datatype&gt;&gt;')"/>
      <xsl:sequence select="imf:line(0, 1, '!define gestructureerddatatype(x) class x &lt;&lt;(D,#FF7700) Gestructureerd datatype&gt;&gt;')"/>
      <xsl:sequence select="imf:line(0, 1, '!define codelijst(x) class x &lt;&lt;(D,#FF7700) Codelijst&gt;&gt;')"/>
      <xsl:sequence select="imf:line(0, 2, '!define referentielijst(x) class x &lt;&lt;(D,#FF7700) Referentielijst&gt;&gt;')"/>
      <!-- <xsl:sequence select="imf:line(0, 2, 'skinparam linetype ortho')"/> -->
      <xsl:sequence select="imf:line(0, 2, 'hide empty members')"/>
      <xsl:sequence select="imf:line(0, 2, 'skinparam svgLinkTarget _self')"/>
      <xsl:sequence select="imf:line(0, 2, 'package &quot;' || mim:naam || '&quot; &lt;&lt;' || local-name() || '&gt;&gt; {')"/>
      <xsl:variable name="ref-elements" select="mim:*/mim-ref:*[@xlink:href]" as="element()*"/>
      <xsl:variable name="refs" select="$ref-elements/@xlink:href" as="xs:string*"/>
      <xsl:variable name="constructs" select="for $a in $ref-elements return imf:element-by-ref-elem($a)" as="element()*"/>
      <xsl:apply-templates select="$constructs"/>
      
      <!-- Stubs voor constructies die gedefinieerd zijn in andere domeinen of views: -->
      <xsl:variable name="stub-refs" select="distinct-values($constructs//*[@xlink:href and not(@xlink:href = $refs)]/@xlink:href)" as="xs:string*"/>
      <xsl:apply-templates select="for $a in $stub-refs return imf:element-by-xlink-href($a)">
        <xsl:with-param name="generate-stub" select="true()" as="xs:boolean"/>
      </xsl:apply-templates>
      
      <!-- Relatie definities voor Relatiesoorten: -->
      <xsl:apply-templates select="for $a in mim:bevat__objecttype/* return imf:element-by-ref-elem($a)/mim:bezit/mim:Relatiesoort"/>
      
      <!-- Relatie definities voor Relatieklassen: -->
      <xsl:apply-templates select="for $a in mim:bevat__objecttype/* return imf:element-by-ref-elem($a)/mim:bezit/mim:Relatieklasse"/>
      <xsl:apply-templates select="for $a in mim:bevat__objecttype/* return imf:element-by-ref-elem($a)/mim:bezit/mim:Relatieklasse" mode="rk"/>
      
      <xsl:sequence select="imf:line(0, 2, '}')"/>
      <xsl:sequence select="imf:line(0, 1, '@enduml')"/>
    </xsl:variable>
    <xsl:variable name="puml" select="string-join($puml-lines/text(), '')" as="xs:string"/>
   
    <xsl:if test="$debug">
      <xsl:result-document href="puml/{mim:naam}.puml" method="text">{$puml}</xsl:result-document>  
    </xsl:if>
    
    <xsl:variable name="http-request" as="element(http:request)">
      <xsl:variable name="href" select="'http://plantuml-service.herokuapp.com/svg'" as="xs:string"/>
      <http:request href="{$href}" method="POST">
        <http:header name="Content-Type" value="text/plain"/>
        <http:body media-type="text/plain">{$puml}</http:body>
      </http:request>
    </xsl:variable>
    
    <xsl:try>
      <xsl:variable name="http-response" select="http:send-request($http-request)" as="item()*"/>
      <xsl:choose>
        <xsl:when test="$http-response[1]/xs:integer(@status) ne 200">
          <div class="error">
            <xsl:sequence select="$http-response[1]"/>  
          </div>
        </xsl:when>
        <xsl:otherwise>
          <!--
          <xsl:if test="$debug">
            <xsl:result-document href="svg/{mim:naam}.svg" method="xml" version="1.0" indent="yes">
              <xsl:sequence select="$http-response[2]"/>
            </xsl:result-document>  
          </xsl:if>
          -->
          <h3 id="{@id}">{local-name() || ': ' || mim:naam}</h3>
          <p>{mim:definitie}</p>
          <xsl:apply-templates select="$http-response[2]" mode="svg"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:catch>
        <div class="error">
          <xsl:value-of select="'Error getting SVG document: ' || $err:description || ' (' || $err:code || ' line: ' || $err:line-number || ', column: ' || $err:column-number || ')'"/>
        </div>
      </xsl:catch>
    </xsl:try>
    
  </xsl:template>
  
  <xsl:template match="mim:Objecttype|mim:Relatieklasse|mim:Gegevensgroeptype" as="element(line)*">
    <xsl:param name="generate-stub" select="false()" as="xs:boolean?"/>
    <xsl:sequence select="imf:line(1, 1, (if (mim:indicatieAbstractObject = 'Ja') then 'abstract ' else ()) || 'class ' || mim:naam || ' &lt;&lt;' || local-name() || '&gt;&gt;' || imf:generate-link($generate-stub, .))"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">
        <xsl:call-template name="generate-stub-contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="imf:line(1, 1, '{')"/>
        <xsl:sequence select="imf:line(2, 1, '&lt;&lt;Attribuutsoort&gt;&gt;')"/>
        <xsl:sequence select="imf:line(2, 1, '..')"/>
        <xsl:apply-templates select="mim:gebruikt__attribuutsoort"/>
        <xsl:sequence select="imf:line(1, 2, '}')"/>
        <xsl:apply-templates select="mim:supertype"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mim:supertype/mim:Generalisatie/*/mim-ref:*" as="element(line)*">
    <xsl:sequence select="imf:line(1, 2, imf:element-by-ref-elem(.)[1]/mim:naam || ' &lt;|-- ' || ancestor::*[mim:supertype/mim:Generalisatie]/mim:naam)"/>
  </xsl:template>

  <xsl:template match="mim:Attribuutsoort|mim:DataElement|mim:ReferentieElement" as="element(line)*">
    <xsl:variable name="kardinaliteit" select="if (mim:kardinaliteit[normalize-space() and not(. = '1')]) then ' [' || mim:kardinaliteit || ']' else ()" as="xs:string?"/>
    <xsl:sequence select="imf:line(2, 1, '+' || mim:naam || ' : ' || imf:element-by-ref-elem((mim:heeft|mim:heeft__datatype|mim:heeft__keuze)/mim-ref:*[@xlink:href])/mim:naam || $kardinaliteit || imf:generate-link(false(), .))"/>
  </xsl:template>
  
  <xsl:template match="mim:Relatiesoort">
    <xsl:variable name="target" select="imf:element-by-ref-elem(mim:verwijstNaar__objecttype/mim-ref:ObjecttypeRef)" as="element()?"/>
    <xsl:if test="$target[self::mim:Objecttype]"> <!-- TODO, Keuze implementeren -->
      <xsl:variable name="relation-symbol" as="xs:string">
        <xsl:choose>
          <xsl:when test="mim:typeAggregatie = 'Compositie'">*--&gt;</xsl:when>
          <xsl:when test="mim:typeAggregatie = 'Gedeeld'">o--&gt;</xsl:when>
          <xsl:otherwise>--&gt;</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="relation-role" select="if (mim:naam) then ' : &quot;' || mim:naam || '&quot;' else ()" as="xs:string"/>   
      <xsl:variable name="kardinaliteit-source" select="('?', '1')[1]" as="xs:string"/>
      <xsl:variable name="kardinaliteit-target" select="(mim:kardinaliteit, '1')[1]" as="xs:string"/>
      <xsl:sequence select="imf:line(0, 1, ancestor::mim:Objecttype/mim:naam || ' &quot;' || $kardinaliteit-source || '&quot; ' || $relation-symbol || ' &quot;' || $kardinaliteit-target || '&quot; ' || $target/mim:naam || $relation-role)"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="mim:Relatieklasse" mode="rk">
    <xsl:variable name="source" select="ancestor::mim:Objecttype" as="element()?"/>
    <xsl:variable name="target" select="imf:element-by-ref-elem(mim:verwijstNaar__objecttype/mim-ref:ObjecttypeRef)" as="element()?"/>
    <xsl:if test="$source and $target">
      <xsl:sequence select="imf:line(0, 1, '(' || $source/mim:naam || ', ' || $target/mim:naam || ') . ' || mim:naam)"/>  
    </xsl:if>
  </xsl:template>  
    
  <xsl:template match="mim:PrimitiefDatatype">
    <xsl:param name="generate-stub" select="false()" as="xs:boolean?"/>
    <xsl:sequence select="imf:line(1, 1, 'primitiefdatatype(' || mim:naam || ')' || imf:generate-link($generate-stub, .))"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">
        <xsl:call-template name="generate-stub-contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="mim:supertype"/>      
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mim:GestructureerdDatatype">
    <xsl:param name="generate-stub" select="false()" as="xs:boolean?"/>
    <xsl:sequence select="imf:line(1, 1, 'gestructureerddatatype(' || mim:naam || ')'  || imf:generate-link($generate-stub, .))"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">
        <xsl:call-template name="generate-stub-contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="imf:line(1, 1, '{')"/>
        <xsl:apply-templates select="mim:bevat/mim:DataElement"/>
        <xsl:sequence select="imf:line(1, 2, '}')"/>
        <xsl:apply-templates select="mim:supertype"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mim:Enumeratie">    
    <xsl:param name="generate-stub" select="false()" as="xs:boolean?"/>
    <xsl:sequence select="imf:line(1, 1, 'enum ' || mim:naam || ' &lt;&lt;' || local-name() || '&gt;&gt;'  || imf:generate-link($generate-stub, .))"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">
        <xsl:call-template name="generate-stub-contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="imf:line(1, 1, '{')"/>
        <xsl:sequence select="imf:line(2, 1, '&lt;&lt;Enumeratiewaarde&gt;&gt;')"/>
        <xsl:sequence select="imf:line(2, 1, '..')"/>
        <xsl:for-each select="mim:bevat/mim:Enumeratiewaarde">
          <xsl:sequence select="imf:line(2, 1, '+' || mim:naam)"/>
        </xsl:for-each>
        <xsl:sequence select="imf:line(1, 2, '}')"/>
        <xsl:apply-templates select="mim:supertype"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mim:Codelijst">
    <xsl:param name="generate-stub" select="false()" as="xs:boolean?"/>
    <xsl:sequence select="imf:line(1, 1, 'codelijst(' || mim:naam || ')' || imf:generate-link($generate-stub, .))"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">
        <xsl:call-template name="generate-stub-contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="imf:line(1, 1, '{')"/>
        <!--
        <xsl:sequence select="imf:line(2, 1, mim:locatie)"/>
        -->
        <xsl:sequence select="imf:line(1, 2, '}')"/>
        <xsl:apply-templates select="mim:supertype"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mim:Referentielijst">
    <xsl:param name="generate-stub" select="false()" as="xs:boolean?"/>
    <xsl:sequence select="imf:line(1, 1, 'referentielijst(' || mim:naam || ')' || imf:generate-link($generate-stub, .))"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">
        <xsl:call-template name="generate-stub-contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="imf:line(1, 1, '{')"/>
        <xsl:sequence select="imf:line(2, 1, '&lt;&lt;Referentie element&gt;&gt;')"/>
        <xsl:sequence select="imf:line(2, 1, '..')"/>
        <xsl:apply-templates select="mim:bevat/mim:ReferentieElement"/>
        <xsl:sequence select="imf:line(1, 2, '}')"/>
        <xsl:apply-templates select="mim:supertype"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mim:Interface">
    <xsl:param name="generate-stub" select="false()" as="xs:boolean?"/>
    <xsl:sequence select="imf:line(1, 1, 'interface ' || mim:naam || ' &lt;&lt;' || local-name() || '&gt;&gt;' || imf:generate-link($generate-stub, .))"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">
        <xsl:call-template name="generate-stub-contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="mim:supertype"/>    
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="generate-stub-contents">
    <xsl:variable name="id" select="@id" as="xs:string?"/>
    <xsl:variable name="container" select="/mim:Informatiemodel/(mim:bevat|mim:maaktGebruikVan)/*[.//*[@xlink:href = '#' || $id]]" as="element()?"/>
    <xsl:sequence select="imf:line(1, 1, '{')"/>
    <xsl:sequence select="imf:line(2, 1, '{abstract} (from ' || '&lt;&lt;' || local-name($container) || '&gt;&gt;' || (if (string-length($container/mim:naam) ge 10) then $lf else ()) || ' &quot;' || $container/mim:naam || '&quot;)')"/>
    <xsl:sequence select="imf:line(1, 2, '}')"/>
  </xsl:template>
  
  <xsl:function name="imf:element-by-ref-elem" as="element()*">
    <xsl:param name="ref-elem" as="element()?"/>
    <xsl:sequence select="if ($ref-elem/@xlink:href) then key('element-by-id', substring-after($ref-elem/@xlink:href, '#'), $root) else ()"/>
  </xsl:function>
  
  <xsl:function name="imf:element-by-xlink-href" as="element()*">
    <xsl:param name="ref-id" as="xs:string?"/>
    <xsl:sequence select="if ($ref-id) then key('element-by-id', substring-after($ref-id, '#'), $root) else ()"/>
  </xsl:function>
  
  <xsl:function name="imf:line" as="element(line)">
    <xsl:param name="n-tbs" as="xs:integer"/>
    <xsl:param name="n-lfs" as="xs:integer"/>
    <xsl:param name="text" as="xs:string?"/>
    <line>{string-join((for $a in 1 to $n-tbs return $tb, $text, for $a in 1 to $n-lfs return $lf), '')}</line>
  </xsl:function>
  
  <xsl:function name="imf:generate-link" as="xs:string?">
    <xsl:param name="generate-stub" as="xs:boolean"/>
    <xsl:param name="element" as="element()"/>
    <xsl:choose>
      <xsl:when test="$generate-stub">{' [[#' || encode-for-uri($element/mim:naam) || ']]'}</xsl:when>
      <xsl:when test="$element/(self::mim:Attribuutsoort|self::mim:DataElement|self::mim:ReferentieElement)"> [[[_{$element/@id}]]]</xsl:when>
      <xsl:otherwise> [[_{$element/@id}]]</xsl:otherwise>
    </xsl:choose>  
  </xsl:function>
  
  <!-- Mode: id -->
  <xsl:template match="*[not(@id) and mim:naam]" mode="id">
    <xsl:copy>
      <xsl:attribute name="id" select="generate-id()"/>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Mode: svg -->
  <xsl:template match="svg:*[@id and parent::svg:a[starts-with(@xlink:href, '#')]]" mode="svg">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'id')]|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="svg:*[starts-with(@xlink:href, '_')]" mode="svg">
    <xsl:copy>
      <xsl:attribute name="onclick">document.getElementById('{substring(@xlink:href, 2)}').style.display='block'</xsl:attribute>
      <xsl:attribute name="cursor">pointer</xsl:attribute>
      <xsl:apply-templates select="@*[not(local-name() = 'href')]|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Mode: modal -->
  <xsl:template match="mim:*[@id]" mode="modal">
    <div id="{@id}" class="w3-modal">
      <div class="w3-modal-content">
        <header class="w3-container w3-light-grey">
          <span onclick="document.getElementById('{@id}').style.display='none'" class="w3-button w3-display-topright">&#215;</span>
          <h3>{local-name() || ': ' || mim:naam}</h3>
        </header>
        <div class="w3-container w3-padding">
          <table class="w3-table w3-striped w3-bordered w3-border">
            <xsl:apply-templates select="*[not(*)]" mode="#current"/>
          </table>
        </div>
        <div class="w3-container w3-light-grey w3-padding">
          <button class="w3-button w3-right w3-white w3-border" onclick="document.getElementById('{@id}').style.display='none'">Sluiten</button>
        </div>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="mim:*[parent::mim:*/@id and not(*)]" mode="modal">
    <tr>
      <td><strong>{local-name()}</strong></td>
      <td>{.}</td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>