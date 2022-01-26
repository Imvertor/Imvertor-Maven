<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ext="http://www.imvertor.org/xsl/extensions"
  xmlns:imf="http://www.imvertor.org/xsl/functions"
  
  xmlns:re="http://www.kadaster.nl/schemas/Erfdienstbaarheden/RegistratieErfdienstbaarheden/v20150601"
  xmlns:ko-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-kadastraalobject-ref/v20150601"
  xmlns:ko="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-kadastraalobject/v20150601"
  xmlns:oz-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-onroerendezaak-ref/v20150601"
  xmlns:oz="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-onroerendezaak/v20150601"
  xmlns:r-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-recht-ref/v20150601"
  xmlns:r="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-recht/v20150601"
  xmlns:s-ref="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-stuk-ref/v20150601"
  xmlns:s="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-stuk/v20150601"
  xmlns:p="http://www.kadaster.nl/schemas/generiek/procesresultaat/v20110922"
  xmlns:t="http://www.kadaster.nl/schemas/Erfdienstbaarheden/CDMKAD-typen/v20150601"
  
  xmlns:gml="http://www.opengis.net/gml/3.2"
  
  xmlns:cw="http://www.armatiek.nl/namespace/folder-content-wrapper"
  
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  
  xmlns:xlink="http://www.w3.org/1999/xlink"
  
  >
 
  <xsl:import href="../common/Imvert-common.xsl"/>
  
  <xsl:output method="xml" indent="yes"/>
  
  <!--
  Zwolle Zoetermeer Utrecht Rotterdam Roermond Middelburg Lelystad Leeuwarden Groningen Eindhoven Breda Assen Arnhem Apeldoorn Amsterdam Alkmaar 
  
  <cw:files  role="">
    <cw:file type="bin" path="Alkmaar\RVK Objecten\AAstandaard.xls" date="1288614394000" name="AAstandaard.xls" ishidden="false" isreadonly="true" ext="xls" fullpath="D:\data\project\Erfdienstbaarheden\RVK\input\Alkmaar\RVK Objecten\AAstandaard.xls"/>
  
  -->
  <xsl:variable name="basepath" select="/bootstrap/data-folder"/>
  
  <xsl:variable name="temp-files-path" select="concat($basepath,'/work/files.xml')"/>
  <xsl:variable name="c" select="imf:serializeFolder(concat($basepath,'/input'),$temp-files-path,'')"/>
  <xsl:variable name="files" select="if (exists($c)) then imf:document($temp-files-path) else ()"/><!-- force the file listing -->
  <xsl:variable name="selected-files" select="$files/*/cw:file[not(contains(@fullpath,'Buitenblok'))]"/>
  
  <xsl:variable name="cnt" select="count($selected-files)"/>
  
  <xsl:template match="/">
    <xsl:message select="concat($cnt,' files')"/>
    <xsl:apply-templates select="$selected-files[not(contains(@fullpath,'SPEC objecten')) and contains(@fullpath,'.xls')]"/> <!-- e.g. NDP02_I_RVK.xls -->
  </xsl:template>
  
  <xsl:template match="cw:file">
    <xsl:variable name="file-id" select="generate-id(.)"/>
    
    <xsl:variable name="excel-path" select="@fullpath"/>
    <xsl:variable name="xml-path" select="concat($basepath,'/output/',@name,'.xml')"/>
    <xsl:variable name="work-path" select="concat($basepath,'/work/',@name,'.xml')"/>
  
    <xsl:message select="concat('SERIALIZING: ', position(), ' of ', $cnt, ' ', $excel-path)"></xsl:message>

    <xsl:variable name="existing-content" select="imf:document($work-path)"/>
    <xsl:variable name="created-work-path" select="imf:serializeExcel($excel-path,$work-path)"/>
    <xsl:variable name="excel-content" select="if (exists($existing-content)) then $existing-content else imf:document($created-work-path)"/>
   
    <xsl:variable name="prepared" as="element(row)*">
      <xsl:apply-templates select="$excel-content/workbook/sheet/row" mode="prepare"/>
    </xsl:variable>
    
    <xsl:variable name="info-struct" as="element(stuk)*">
      <xsl:for-each-group select="$prepared" group-by="concat(@deel,'_',@nummer,'_',@reeks)">
        <!-- stuk -->
        <xsl:variable name="stuk-row" select="current-group()[1]"/>
        <stuk id="{current-grouping-key()}">
          <deel><xsl:value-of select="$stuk-row/@deel"/></deel>
          <nummer><xsl:value-of select="$stuk-row/@nummer"/></nummer>
          <reeks><xsl:value-of select="$stuk-row/@reeks"/></reeks>
          <regdatum><xsl:value-of select="$stuk-row/@regdatum"/></regdatum>
          <xsl:for-each-group select="current-group()" group-by="@txt-deel">
            <!-- stukdeel -->
            <xsl:variable name="stukdeel-row" select="current-group()[1]"/>
            <stukdeel>
              <txt-deel><xsl:value-of select="$stukdeel-row/@txt-deel"/></txt-deel>
              <xsl:for-each-group select="current-group()" group-by="@soort">
                <!-- aantekening -->
                <xsl:variable name="aantekening-row" select="current-group()[1]"/>
                <aantekening>
                  <soort><xsl:value-of select="@soort"/></soort>
                  <xsl:for-each-group select="current-group()" group-by="concat(@gemeente,'_',@sectie,'_',@perceelnr)">
                    <!-- perceel -->
                    <xsl:variable name="perceel-row" select="current-group()[1]"/>
                    <perceel>
                      <gemeente><xsl:value-of select="@gemeente"/></gemeente>
                      <sectie><xsl:value-of select="@sectie"/></sectie>
                      <perceelnr><xsl:value-of select="@perceelnr"/></perceelnr>
                      <index><xsl:value-of select="@index"/></index>
                      <indexnr><xsl:value-of select="@indexnr"/></indexnr>
                      <kavelnr><xsl:value-of select="@kavelnr"/></kavelnr>
                    </perceel>
                  </xsl:for-each-group>
                </aantekening>
              </xsl:for-each-group>
            </stukdeel>
          </xsl:for-each-group>
        </stuk>
      </xsl:for-each-group>  
    </xsl:variable>
    
    <!-- een Stuk per file -->
    <xsl:for-each select="$info-struct">
      <xsl:variable name="stuk" select="."/>
      <xsl:variable name="stuk-id" select="generate-id($stuk)"/> 
      
      <xsl:variable name="output-file-url" select="imf:file-to-url(concat($xml-path,'/',@id,'-', $file-id, '.xml'))"/>
      
      <xsl:variable name="xml-info-raw" as="element(re:RegistratieErfdienstbaarheden)">
        <re:RegistratieErfdienstbaarheden
          xsi:schemaLocation="http://www.kadaster.nl/schemas/Erfdienstbaarheden/RegistratieErfdienstbaarheden/v20150601
          ../../Erfdienstbaarheden-model/20150601/xsd/Erfdienstbaarheden/RegistratieErfdienstbaarheden/v20150601/Erfdienstbaarheden_RegistratieErfdienstbaarheden_v1_0_0.xsd">
          <!--x
          <BRON>
            <xsl:sequence select="."/>
          </BRON>
          x-->
          <re:log>
            <p:ProcesVerwerking>
              <p:ProcesVerwerkingCode>?</p:ProcesVerwerkingCode>
              <p:SeverityCode>?</p:SeverityCode>
            </p:ProcesVerwerking>
          </re:log>
          <re:akte>
            <s-ref:TerInschrijvingAangebodenStukRef 
              xlink:href="#TerInschrijvingAangebodenStuk.{$stuk-id}"/>
          </re:akte>
          <re:aantekeningen>
            <xsl:for-each select="$stuk/stukdeel/aantekening">
              <r-ref:AantekeningRef xlink:href="#Aantekening.{generate-id(.)}"/>
            </xsl:for-each>
          </re:aantekeningen>
          <re:components>
            <re:RegistratieErfdienstbaarhedenComponents>
              <xsl:for-each select="stukdeel/aantekening/perceel">
                <xsl:variable name="perceel" select="."/>
                <xsl:variable name="perceel-id" select="generate-id($perceel)"/>
                <oz:Perceel id="Perceel.{$perceel-id}">
                  <oz:identificatie xsi:nil="true" nilReason="waardeOnbekend"/>
                  <oz:kadastraleAanduiding>
                    <oz:kadastraleGemeente>
                      <t:code><xsl:value-of select="$perceel/gemeente"/></t:code>
                    </oz:kadastraleGemeente>
                    <oz:sectie><xsl:value-of select="$perceel/sectie"/></oz:sectie>
                    <oz:perceelnummer><xsl:value-of select="$perceel/perceelnr"/></oz:perceelnummer>
                    <oz:indexletter><xsl:value-of select="$perceel/indexnr"/></oz:indexletter>
                    <oz:indexnummer><xsl:value-of select="$perceel/index"/></oz:indexnummer>
                    <oz:kavelnummer><xsl:value-of select="$perceel/kavelnr"/></oz:kavelnummer>
                  </oz:kadastraleAanduiding>
                  <xsl:for-each select="$info-struct/stukdeel[aantekening/perceel[generate-id(.) = $perceel-id]]">
                    <xsl:variable name="stukdeel" select="."/>
                    <xsl:variable name="stukdeel-id" select="generate-id($stukdeel)"/>
                    <oz:isVermeldIn>
                      <s-ref:StukdeelRef xlink:href="Stukdeel.{$stukdeel-id}"/>
                    </oz:isVermeldIn>
                    <xsl:message select="if (position() eq 2) then 'perceel keert terug in meerdere stukdelen' else ''"></xsl:message>
                  </xsl:for-each>
                </oz:Perceel>
              </xsl:for-each>
              <xsl:for-each select="stukdeel/aantekening">
                <xsl:variable name="aantekening" select="."/>
                <xsl:variable name="aantekening-id" select="generate-id($aantekening)"/>
                <r:Aantekening id="Aantekening.{$aantekening-id}">
                  <r:identificatie xsi:nil="true" nilReason="waardeOnbekend"/>
                  <r:aard>
                    <t:code>62</t:code>
                    <t:waarde>Erfdienstbaarheid</t:waarde>
                  </r:aard>
                  <r:aanduidingErfdienstbaarheid>
                    <xsl:variable name="soort" select="normalize-space($aantekening/soort)"/>
                    <xsl:choose>
                      <xsl:when test="$soort = 'DI'">
                        <t:code>1</t:code>
                        <t:waarde>Dienend</t:waarde>
                      </xsl:when>
                      <xsl:when test="$soort = 'HE'">
                        <t:code>2</t:code>
                        <t:waarde>Heersend</t:waarde>
                      </xsl:when>
                      <xsl:when test="$soort = 'HEDI'">
                        <t:code>3</t:code>
                        <t:waarde>Dienend en heersend </t:waarde>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:sequence select="imf:msg('WARNING','Soort is onbekend: [1]',$soort)"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </r:aanduidingErfdienstbaarheid>
                  <r:aantekeningKadastraalObject>
                    <xsl:for-each select="$aantekening/perceel">
                      <xsl:variable name="perceel" select="."/>
                      <oz-ref:PerceelRef xlink:href="#Perceel.{generate-id($perceel)}"/>
                    </xsl:for-each>
                  </r:aantekeningKadastraalObject>
                  <r:isGebaseerdOp>
                    <s-ref:StukdeelRef xlink:href="#Stukdeel.{generate-id($aantekening/..)}"/>
                  </r:isGebaseerdOp>
                </r:Aantekening>
              </xsl:for-each>
              <xsl:for-each select="$stuk/stukdeel">
                <xsl:variable name="stukdeel" select="."/>
                <s:Stukdeel id="Stukdeel.{generate-id($stukdeel)}">
                  <s:identificatie xsi:nil="true" nilReason="waardeOnbekend"/>
                  <s:aard>
                    <t:code>62</t:code>
                    <t:waarde>Erfdienstbaarheid</t:waarde>
                  </s:aard>
                  <s:isVerwoordIn>
                    <s:Tekstdeel>
                      <s:code>
                        <xsl:value-of select="$stukdeel/txt-deel"/>
                      </s:code>
                    </s:Tekstdeel>
                  </s:isVerwoordIn>
                </s:Stukdeel>
              </xsl:for-each>
              <s:TerInschrijvingAangebodenStuk 
                id="TerInschrijvingAangebodenStuk.{$stuk-id}">
                <s:omvat>
                  <xsl:for-each select="stukdeel">
                    <xsl:variable name="stukdeel" select="."/>
                    <xsl:variable name="stukdeel-id" select="generate-id($stukdeel)"/>
                    <s-ref:StukdeelRef xlink:href="#Stukdeel.{$stukdeel-id}"/>
                  </xsl:for-each>
                </s:omvat>
                <s:identificatie xsi:nil="true" nilReason="waardeOnbekend"/>
                <s:aard>
                  <t:code>5</t:code>
                  <t:waarde>Overig</t:waarde>
                </s:aard>
                <s:deelEnNummer>
                  <s:deel><xsl:value-of select="$stuk/deel"/></s:deel>
                  <s:nummer><xsl:value-of select="$stuk/nummer"/></s:nummer>
                  <s:reeks>
                    <t:code><xsl:value-of select="$stuk/reeks"/></t:code>
                  </s:reeks>
                  <s:registercode>
                    <t:code>2</t:code>
                    <t:waarde>HYP4</t:waarde>
                  </s:registercode>
                  <s:soortRegister>
                    <t:code>2</t:code>
                    <t:waarde>Onroerende Zaken</t:waarde>
                  </s:soortRegister>
                </s:deelEnNummer>
                <s:tijdstipAanbieding>
                  <xsl:value-of select="imf:convert-date($stuk/regdatum)"/>
                </s:tijdstipAanbieding>
                <s:bestaatUit nilReason="geenWaarde" xsi:nil="true"/>
              </s:TerInschrijvingAangebodenStuk>
            </re:RegistratieErfdienstbaarhedenComponents>
          </re:components>
        </re:RegistratieErfdienstbaarheden>
      </xsl:variable>
      
      <xsl:variable name="xml-info" as="element(re:RegistratieErfdienstbaarheden)">
        <xsl:apply-templates select="$xml-info-raw" mode="compact"/>
      </xsl:variable>

      <xsl:result-document href="{$output-file-url}">
        <xsl:comment select="concat('Excel path: ', $excel-path)"/>
        <xsl:sequence select="$xml-info"/>
      </xsl:result-document>
    </xsl:for-each>
 
  </xsl:template>
  
  <!--
        Serialize the excel 97-2003 file to the result XML file.
        Returns the (full) xml result file path.
    -->
  <xsl:function name="imf:serializeExcel" as="xs:string*">
    <xsl:param name="excelpath"/>
    <xsl:param name="xmlpath"/>
    <xsl:sequence select="ext:imvertorExcelSerializer($excelpath,$xmlpath)"/>
  </xsl:function>
  <!--
        Serialize the folder holing the Excels.
        Returns the (full) xml result file path.
    -->
  <xsl:function name="imf:serializeFolder" as="xs:string*">
    <xsl:param name="folderpath"/>
    <xsl:param name="xmlpath"/>
    <xsl:param name="constraints"/>
    <xsl:sequence select="ext:imvertorFolderSerializer($folderpath,$xmlpath,$constraints)"/>
  </xsl:function>
  
  <!-- selecteer alleen de rows die een kavelnummer hebben. -->
  <xsl:template match="row" mode="prepare">
    <xsl:if test="normalize-space(col[@number='14']/data) and not(col[@number='0']/data = ('gemeente','perceel'))">
      <row 
        gemeente="{col[@number='0']}" 
        sectie="{col[@number='1']/data}"	
        perceelnr="{col[@number='2']/data}"	
        index="{col[@number='3']/data}"	
        indexnr="{col[@number='4']/data}"	
        peildatum="{col[@number='5']/data}"	
        status="{col[@number='6']/data}"	
        register="{col[@number='7']/data}"	
        deel="{col[@number='8']/data}"	
        nummer="{col[@number='9']/data}"	
        reeks="{col[@number='10']/data}"	
        txt-deel="{col[@number='11']/data}"	
        soort="{col[@number='12']/data}"	
        regdatum="{col[@number='13']/data}"	
        kavelnr="{col[@number='14']/data}"	
      />
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dummy">
    <!-- ignore -->
  </xsl:template>
  
  <xsl:template match="*" mode="compact">
    <xsl:if test="* or normalize-space(.) or exists(@xlink:href) or exists(@xsi:nil)">
      <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates select="node()" mode="compact"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="text()" mode="compact">
      <xsl:copy/>
  </xsl:template>
  
  <xsl:function name="imf:convert-date" as="xs:string*">
    <xsl:param name="datum"/>
    <xsl:if test="matches($datum,'\d+-\d+-\d+')">
      <xsl:variable name="t" select="tokenize($datum,'-')"/>
      <xsl:value-of select="concat('19',$t[3],'-',imf:leftpad($t[2]),'-',imf:leftpad($t[1]),'T00:00:00')"/>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="imf:leftpad">
    <xsl:param name="s"/>
    <xsl:value-of select="format-number(xs:integer($s), '00')" />
  </xsl:function>
  
</xsl:stylesheet>