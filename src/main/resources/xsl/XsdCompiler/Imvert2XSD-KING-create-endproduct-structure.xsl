<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    SVN: $Id: Imvert2XSD-KING-endproduct.xsl 3 2015-11-05 10:35:07Z ArjanLoeffen $ 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:UML="omg.org/UML1.3"
	xmlns:imvert="http://www.imvertor.org/schema/system"
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"
	xmlns:bg="http://www.egem.nl/StUF/sector/bg/0310"
	xmlns:metadata="http://www.kinggemeenten.nl/metadataVoorVerwerking"
	xmlns:ztc="http://www.kinggemeenten.nl/ztc0310" xmlns:stuf="http://www.egem.nl/StUF/StUF0301"
	xmlns:ep="http://www.imvertor.org/schema/endproduct"
	xmlns:ss="http://schemas.openxmlformats.org/spreadsheetml/2006/main" version="2.0">

	<xsl:output indent="yes" method="xml" encoding="UTF-8"/>

	<xsl:variable name="stylesheet">Imvert2XSD-KING-create-endproduct-structure</xsl:variable>
	<xsl:variable name="stylesheet-version">$Id: Imvert2XSD-KING-create-endproduct-structure.xsl 1
		2015-11-11 11:50:00Z RobertMelskens $</xsl:variable>

	<xsl:variable name="tagged-values">
		<xsl:sequence select="//imvert:package[imvert:name = 'Bericht']//imvert:class[imvert:name = 'Bericht']/imvert:tagged-values"/>
	</xsl:variable>

	<xsl:template match="/imvert:packages/imvert:package" mode="create-message-structure"> <!-- this is the koppelvlak with embedded message schema's-->
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:package[mode=create-message-structure]'"/>
		</xsl:if>
		<!-- create the bericht message -->
		<xsl:apply-templates
			select="
			imvert:class[
				imvert:stereotype = imf:get-config-stereotypes((
					'stereotype-name-vraagberichttype',
					'stereotype-name-antwoordberichttype',
					'stereotype-name-vrijberichttype',
					'stereotype-name-kennisgevingberichttype'))
				]"
			mode="create-initial-message-structure">
			<xsl:with-param name="messagePrefix" select="''"/>
		</xsl:apply-templates>
		
		<!-- TODO wat doet dit?
		<xsl:apply-templates
			select="
				imvert:class[
					imvert:stereotype = imf:get-config-stereotypes((
					'stereotype-name-vraagberichttype',
					'stereotype-name-antwoordberichttype',
					'stereotype-name-vrijberichttype',
					'stereotype-name-kennisgevingberichttype'))
				]"
			mode="create-initial-message-structure">
			<xsl:with-param name="messagePrefix" select="'KopieVan'"/>
		</xsl:apply-templates>
		-->

	</xsl:template>

	<xsl:template match="imvert:class" mode="create-initial-message-structure">
		<xsl:param name="messagePrefix" select="''"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:class[mode=create-initial-message-structure]'"/>
		</xsl:if>
		<xsl:variable name="berichtCode"
			select="imf:determineBerichtCode(imvert:name, $tagged-values)"/>
		<ep:message>
			<xsl:sequence
				select="imf:create-output-element('ep:documentation', 'TO-DO: bepalen of er geen documentatie op message niveau kan zijn. Zo ja dan dit toevoegen aan UML model van EP')"/>
			<xsl:sequence select="imf:create-output-element('ep:code', $berichtCode)"/>
			<?x xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/ x?>
			<xsl:sequence select="imf:create-output-element('ep:name', concat($messagePrefix,/imvert:packages/imvert:application))"/>
			<xsl:sequence select="imf:create-output-element('ep:package-type', ancestor::imvert:package/imvert:name)"/>
			<xsl:sequence select="imf:create-output-element('ep:release', /imvert:packages/imvert:release)"/>
			<xsl:sequence select="imf:create-output-element('ep:type', imvert:name)"/>
			<?x xsl:if test="imf:boolean($debug)">
				<xsl:sequence select="imf:create-output-element('ep:id', imvert:id)"/>
			</xsl:if x?>
			<!-- Onderstaand is een eerste aanzet om de diverse constructs op de juiste wijze te sorteren in het EP bestand.
				 Ik twijfel er echter aan of dit het meest handige is. Misschien is het handiger om een ep:position element 
				 op te nemen en pas in de laatste slag de constructs tov elkaar te sorteren. In dit stadium is het nl. erg 
				 omslachtig omdat de te sorteren componenten nog niet geresolved zijn in de embellish file. Hierdoor zou ik
				 in dit bestand veelvuldig met variabelen moeten werken. -->
			<?x xsl:variable name="constructOrder">
				<xsl:apply-templates select="imvert:supertype" mode="determineConstructOrder">
					<xsl:with-param name="proces-type" select="'attributes'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:attribute" mode="determineConstructOrder"/>
				<xsl:apply-templates select="imvert:supertype" mode="determineConstructOrder">
					<xsl:with-param name="proces-type" select="'associations'"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:association" mode="determineConstructOrder"/>			
			</xsl:variable>
			<!-- Volgende variabele is alleen vervaardigd zodat ik het resultaat tijdelijk in het EP bestand op kan nemen. -->
			<xsl:variable name="Order">
				<xsl:for-each select="$constructOrder/ep:construct">
					<xsl:sort select="ep:position" order="ascending" data-type="number"/>
					<ep:construct>
						<xsl:sequence
							select="imf:create-output-element('ep:tech-name', ep:tech-name)"/>
						<xsl:sequence
									select="imf:create-output-element('ep:position', ep:position)"/>	
						<xsl:sequence
							select="imf:create-output-element('ep:tv', ep:tv)"/>	
						<xsl:sequence
							select="imf:create-output-element('ep:stereotype', ep:stereotype)"/>	
					</ep:construct>
				</xsl:for-each>
			</xsl:variable>
			<ep:constructOrder>
				<xsl:copy-of select="$Order"/>
			</ep:constructOrder x?>
			<ep:seq>
				<?x xsl:for-each select="$constructOrder/ep:construct">
					<xsl:sort select="ep:position" order="ascending" data-type="number"/>
					<xsl:choose>
						<xsl:when test="ep:stereotype='attribute' and .//imvert">
							
						</xsl:when>
						<xsl:when test="ep:stereotype='attribute'">
							
						</xsl:when>
						<xsl:when test="ep:stereotype='association'">
							
						</xsl:when>
						<xsl:otherwise>
							
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:for-each x?>
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="resolvingEntity" select="imvert:name"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
					<xsl:with-param name="sourceEntity" select="imvert:name"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'associations'"/>
					<xsl:with-param name="resolvingEntity" select="imvert:name"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:association" mode="create-message-content">
					<xsl:with-param name="entity" select="imvert:name"/>
					<xsl:with-param name="sourceEntity" select="imvert:name"/>
					<!-- Volgende parameter is geintroduceerd om te voorkomen dat classes recursief worden verwerkt.
						 Komt het stylesheet een id tegen die al in de trail staat dan stopt de verwerking. -->
					<xsl:with-param name="id-trail" select="concat('#1#', imvert:id, '#')"/>
				</xsl:apply-templates>
			</ep:seq>
		</ep:message>
	</xsl:template>

	<!-- Wellicht komen de volgende 4 templates nog te vervallen. -->
	<xsl:template match="imvert:supertype" mode="determineConstructOrder">
		<xsl:param name="proces-type"/>
		<xsl:variable name="imvertId" select="imvert:type-id"/>
		<xsl:apply-templates select="//imvert:class[imvert:id = $imvertId]"	mode="determineConstructOrder">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="entity" select="imvert:type-name"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="imvert:attribute" mode="determineConstructOrder">
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<ep:construct>
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)"/>
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)"/>	
					<xsl:sequence
						select="imf:create-output-element('ep:tv-position', 'yes')"/>	
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)"/>					
				</xsl:when>
				<xsl:otherwise>
					<ep:position>100</ep:position>				
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence
				select="imf:create-output-element('ep:stereotype', 'attribute')"/>
		</ep:construct>
	</xsl:template>
	
	<xsl:template match="imvert:association" mode="determineConstructOrder">
		<ep:construct>
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)"/>
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)"/>					
					<xsl:sequence
						select="imf:create-output-element('ep:tv-position', 'yes')"/>	
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)"/>					
				</xsl:otherwise>
			</xsl:choose>
			<xsl:sequence
				select="imf:create-output-element('ep:stereotype', 'association')"/>
		</ep:construct>
	</xsl:template>
	
	<xsl:template match="imvert:class" mode="determineConstructOrder">
		<xsl:param name="proces-type" select="''"/>
		<xsl:choose>
			<xsl:when test="$proces-type = 'attributes'">
				<xsl:apply-templates select="imvert:supertype" mode="determineConstructOrder">
					<xsl:with-param name="proces-type" select="$proces-type"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:attribute" mode="determineConstructOrder"/>
			</xsl:when>
			<xsl:when test="$proces-type = 'associations'">
				<xsl:apply-templates select="imvert:supertype" mode="determineConstructOrder">
					<xsl:with-param name="proces-type" select="$proces-type"/>
				</xsl:apply-templates>
				<xsl:apply-templates select=".//imvert:association" mode="determineConstructOrder"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Dit template initialiseert de verwerking van de superclasses van de in bewerking zijnde class. -->
	<xsl:template match="imvert:supertype" mode="create-message-content">
		<xsl:param name="proces-type"/>
		<xsl:param name="resolvingEntity"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:supertype[mode=create-message-content]'"/>
		</xsl:if>
		<xsl:variable name="imvertId" select="imvert:type-id"/>
		<xsl:apply-templates select="//imvert:class[imvert:id = $imvertId]"	mode="create-message-content">
			<xsl:with-param name="proces-type" select="$proces-type"/>
			<xsl:with-param name="entity" select="imvert:type-name"/>
			<xsl:with-param name="resolvingEntity" select="$resolvingEntity"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="imvert:attribute" mode="create-message-content">
		<xsl:param name="sourceEntity"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-message-content]'"/>
		</xsl:if>
		<xsl:variable name="type-id" select="imvert:type-id"/>
		<!-- In de onderstaande when statements is een check opgenomen op het berichtType zodat de juiste rijen geselecteerd worden. -->
		<ep:construct>
			<xsl:attribute name="sourceEntity" select="$sourceEntity"/>
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)"/>
			<xsl:sequence select="imf:create-output-element('ep:documentation', imvert:documentation)"/>
			<!-- Onderstaande sequence zou gebruikt kunnen worden voor het ophalen van de documentatie behorende bij de class waarnaar verwezen wordt.
				 Bijvoorbeeld de class waarin het datatype wordt gedefinieerd. -->
			<!--xsl:sequence
				select="imf:create-output-element('ep:documentation', //imvert:class[imvert:id = $type-id]/imvert:documentation)"/-->
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:if test="imvert:type-id">
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id and imvert:stereotype = 'ENUMERATION']" mode="create-datatype-content"/>
			</xsl:if>
			<xsl:sequence
				select="imf:create-output-element('ep:id', imvert:id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:is-id', imvert:is-id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegevens', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:max-length', imvert:max-length)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:max-value', 'TO-DO: waar komt dit vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-length', imvert:min-length)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-value', 'TO-DO: waar komt dit vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:pattern', imvert:pattern)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:regels', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:type-name', imvert:type-name)"/>
			<!-- Ik vermoed dat onderstaande element op basis van het voidable tagged value gegenereerd moet worden.
				 Je zou zeggen dat op basis van die tagged value  echter ook de construct 'noValue' gegenereerd moet worden. 
				 Dat is echter de vraag omdat dat een XML requirement is en mogelijk geen JSON requirement.
				 De vraag is dus of we dat wel moeten doen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', 'TO-DO: waar haal ik hiervoor de waarde vandaan. Zie ook opmerking in stylesheet Imvert2XSD-KING-create-endproduct-structure.xsl')"/>
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)"/>	
					<xsl:sequence
						select="imf:create-output-element('ep:tv-position', 'yes')"/>	
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)"/>					
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<xsl:if test="imvert:name != 'melding'">
				<ep:seq>
						<ep:construct ismetadata="yes">
							<ep:tech-name>StUF:noValue</ep:tech-name>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:type-name>string</ep:type-name>
							<ep:enum>nietOndersteund</ep:enum>
							<ep:enum>nietGeautoriseerd</ep:enum>
							<ep:enum>geenWaarde</ep:enum>
							<ep:enum>waardeOnbekend</ep:enum>
							<ep:enum>vastgesteldOnbekend</ep:enum>
						</ep:construct>
					<ep:construct ismetadata="yes">
							<ep:tech-name>StUF:exact</ep:tech-name>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:type-name>boolean</ep:type-name>
						</ep:construct>
					<xsl:if test="imvert:type-name='Datetime'">
						<ep:construct ismetadata="yes">
							<ep:tech-name>StUF:indOnvolledigeDatum</ep:tech-name>
							<ep:min-occurs>0</ep:min-occurs>
							<ep:type-name>dateTime</ep:type-name>
							<ep:enum>J</ep:enum>
							<ep:enum>M</ep:enum>
							<ep:enum>D</ep:enum>
							<ep:enum>V</ep:enum>
						</ep:construct>					
					</xsl:if>
				</ep:seq>
			</xsl:if>
		</ep:construct>
	</xsl:template>

	<xsl:template match="imvert:association" mode="create-message-content">
		<xsl:param name="entity"/>
		<xsl:param name="sourceEntity"/>
		<xsl:param name="id-trail"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association[mode=create-message-content]'"/>
		</xsl:if>
		<!-- In de onderstaande when statements is een check opgenomen op het berichtType zodat de juiste rijen geselecteerd worden. -->
		<ep:construct packageType="{ancestor::imvert:package/imvert:name}">
			<xsl:attribute name="sourceEntity" select="$sourceEntity"/>
			<xsl:variable name="type-id" select="imvert:type-id"/>
			<xsl:sequence select="imf:create-output-element('ep:name', imvert:name/@original)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:tech-name', imvert:name)"/>
			<xsl:sequence select="imf:create-output-element('ep:documentation', imvert:documentation)"/>
			<!-- Onderstaande sequence zou gebruikt kunnen worden voor het ophalen van de documentatie behorende bij de class waarnaar verwezen wordt. -->
			<!--xsl:sequence
				select="imf:create-output-element('ep:documentation', //imvert:class[imvert:id = $type-id]/imvert:documentation)"/-->
			<xsl:sequence
				select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:authentiek', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:id', imvert:id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:is-id', imvert:is-id)"/>
			<xsl:sequence
				select="imf:create-output-element('ep:kerngegevens', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<xsl:sequence
				select="imf:create-output-element('ep:regels', 'TO-DO: waar haal ik hiervoor de waarde vandaan')"/>
			<!-- Ik vermoed dat onderstaande element op basis van het voidable tagged value gegenereerd moet worden.
				 Je zou zeggen dat op basis van die tagged value  echter ook de construct 'noValue' gegenereerd moet worden. 
				 Dat is echter de vraag omdat dat een XML requirement is en mogelijk geen JSON requirement.
				 De vraag is dus of we dat wel moeten doen. -->
			<xsl:sequence
				select="imf:create-output-element('ep:voidable', 'TO-DO: waar haal ik hiervoor de waarde vandaan. Zie ook opmerking in stylesheet Imvert2XSD-KING-create-endproduct-structure.xsl')"/>
			<xsl:choose>
				<xsl:when test="imvert:tagged-values/imvert:tagged-value/imvert:name='Positie'">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:tagged-values/imvert:tagged-value[imvert:name='Positie']/imvert:value)"/>	
					<xsl:sequence
						select="imf:create-output-element('ep:tv-position', 'yes')"/>	
				</xsl:when>
				<xsl:when test="imvert:position">
					<xsl:sequence
						select="imf:create-output-element('ep:position', imvert:position)"/>					
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<xsl:if test="imvert:stereotype='ENTITEITTYPE'">
				<ep:seq>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:entiteittype</ep:tech-name>
						<xsl:sequence
							select="imf:create-output-element('ep:enum', imvert:alias)"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelSynchronisatie</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:noValue</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:type-name>string</ep:type-name>
						<ep:enum>nietOndersteund</ep:enum>
						<ep:enum>nietGeautoriseerd</ep:enum>
						<ep:enum>geenWaarde</ep:enum>
						<ep:enum>waardeOnbekend</ep:enum>
						<ep:enum>vastgesteldOnbekend</ep:enum>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:scope</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:type-name>string</ep:type-name>
						<ep:enum>alles</ep:enum>
						<ep:enum>allesZonderMetagegevens</ep:enum>
						<ep:enum>allesMaarKerngegevensgerelateerden</ep:enum>
						<ep:enum>allesZonderMetagegevensMaarKerngegevensGerelateerden</ep:enum>
						<ep:enum>kerngegevens</ep:enum>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:type-name>string</ep:type-name>
						<ep:enum>T</ep:enum>
						<ep:enum>W</ep:enum>
						<ep:enum>V</ep:enum>
						<ep:enum>E</ep:enum>
						<ep:enum>I</ep:enum>
						<ep:enum>R</ep:enum>
						<ep:enum>S</ep:enum>
						<ep:enum>O</ep:enum>
					</ep:construct>
				</ep:seq>				
			</xsl:if>
			<!-- Ik ga er nu vanuit dat er maar 1 association-class is per association -->
			<ep:seq>
				<xsl:apply-templates select="imvert:association-class" mode="create-message-relations-content">
					<xsl:with-param name="proces-type" select="'associations'"/>
					<xsl:with-param name="resolvingEntity" select="$entity"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="entity" select="imvert:type-name"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
					<xsl:with-param name="proces-type" select="'attributes'"/>
					<xsl:with-param name="resolvingEntity" select="$entity"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-relations-content">
					<xsl:with-param name="proces-type" select="'associations'"/>
					<xsl:with-param name="resolvingEntity" select="$entity"/>
					<xsl:with-param name="id-trail" select="$id-trail"/>
					<xsl:with-param name="entity" select="imvert:type-name"/>
				</xsl:apply-templates>
			</ep:seq>					
		</ep:construct>
	</xsl:template>

	<xsl:template match="imvert:association-class" mode="create-message-relations-content">
		<xsl:param name="proces-type" select="'associations'"/>
		<xsl:param name="resolvingEntity"/>
		<xsl:param name="id-trail"/>
		<xsl:param name="entity"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:association-class[mode=create-message-relations-content]'"/>
		</xsl:if>
		<ep:seq>
			<ep:construct packageType="{ancestor::imvert:package/imvert:name}">
				<xsl:if test="imf:boolean($debug)">
					<xsl:attribute name="id" select="imvert:id"/>
				</xsl:if>
				<xsl:variable name="type-id" select="imvert:type-id"/>
				<ep:name>gerelateerde</ep:name>
				<ep:seq>
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="resolvingEntity" select="$entity"/>
						<xsl:with-param name="id-trail" select="$id-trail"/>
					</xsl:apply-templates>
					<!-- Voor de volgende elementen moet bepaald worden of deze gegenereerd worden danwel gedefinieerd in EAP. -->
					<!--ep:construct>
							<ep:name>StUF:tijdvakGeldigheid</ep:name>
							<ep:type-name>StUF:TijdvakGeldigheid</ep:type-name>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:tijdvakRelatie</ep:name>
							<ep:type-name>StUF:Tijdstip-e</ep:type-name>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:tijdstipRegistratie</ep:name>
							<ep:type-name>StUF:Tijdstip-e</ep:type-name>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:extraElementen</ep:name>
							<ep:type-name>StUF:ExtraElementen</ep:type-name>
						</ep:construct-->
					<xsl:apply-templates select="//imvert:class[imvert:id = $type-id]"
						mode="create-message-relations-content">
						<xsl:with-param name="proces-type" select="'associations'"/>
						<xsl:with-param name="resolvingEntity" select="$entity"/>
						<xsl:with-param name="id-trail" select="$id-trail"/>
						<xsl:with-param name="entity" select="imvert:type-name"/>
					</xsl:apply-templates>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:entiteittype</ep:tech-name>
						<xsl:sequence
							select="imf:create-output-element('ep:enum', imvert:alias)"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelVerzendend</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelOntvangend</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelGegevensbeheer</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:sleutelSynchronisatie</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<xsl:sequence
							select="imf:create-output-element('ep:type-name', 'StUF:Sleutel')"/>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:noValue</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:type-name>string</ep:type-name>
						<ep:enum>nietOndersteund</ep:enum>
						<ep:enum>nietGeautoriseerd</ep:enum>
						<ep:enum>geenWaarde</ep:enum>
						<ep:enum>waardeOnbekend</ep:enum>
						<ep:enum>vastgesteldOnbekend</ep:enum>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:scope</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:type-name>string</ep:type-name>
						<ep:enum>alles</ep:enum>
						<ep:enum>allesZonderMetagegevens</ep:enum>
						<ep:enum>allesMaarKerngegevensgerelateerden</ep:enum>
						<ep:enum>allesZonderMetagegevensMaarKerngegevensGerelateerden</ep:enum>
						<ep:enum>kerngegevens</ep:enum>
					</ep:construct>
					<ep:construct ismetadata="yes">
						<ep:tech-name>StUF:verwerkingssoort</ep:tech-name>
						<ep:min-occurs>0</ep:min-occurs>
						<ep:type-name>string</ep:type-name>
						<ep:enum>T</ep:enum>
						<ep:enum>W</ep:enum>
						<ep:enum>V</ep:enum>
						<ep:enum>E</ep:enum>
						<ep:enum>I</ep:enum>
						<ep:enum>R</ep:enum>
						<ep:enum>S</ep:enum>
						<ep:enum>O</ep:enum>
					</ep:construct>
				</ep:seq>
			</ep:construct>
		</ep:seq>
	</xsl:template>

	<xsl:template match="imvert:class" mode="create-message-content">
		<xsl:param name="resolvingEntity" select="''"/>
		<!-- Indien de bovenstaande parameter gevuld is dan wordt deze parameter gebruikt om te bepalen in welke modus dit template moet worden gebruikt. 
			 Moeten de attributes van een superclass of een gerelateerde class worden opgehaald of moeten de associations van een superclass of een gerelateerde 
			 class worden opgehaald? -->
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="entity" select="imvert:name"/>
		<!-- De volgende parameter heeft alleen een functie als dit template wordt gebruikt voor de verwerking van relaties.
			 Met deze parameter voorkomen we dat relaties recursief tot in het oneindige worden geprocessed. Indien een relatie voor de tweede keer wordt 
			 geprocessed dan moet het proces stoppen. -->
		<xsl:param name="id-trail"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:class[mode=create-message-content]'"/>
		</xsl:if>
		<!-- De packageType bepaald hoe er omgegaan moet worden met associations. Indien de packageType gelijk is aan 'Model' dan worden associations vertaald naar 
			 relaties waarbinnen gerelateerde entiteiten worden geplaatts. Is de packageType echter gelijk aan 'Bericht' dan worden associations vertaalt naar normale 
			 container elementen.-->
			<xsl:if test="imf:boolean($debug)">
				<xsl:sequence
					select="imf:create-output-element('ep:id', imvert:id)"/>
				<xsl:comment select="concat('resolvingEntity: (',$resolvingEntity,') ,proces-type: ',$proces-type)"/>
			</xsl:if>
			<xsl:choose>
				<!-- In de volgende twee when's worden de superclasses of relatieclasses van de class die gerelateerd is aan het in bewerking zijnde berichttype verwerkt,
					  de eerste in de attributes mode en de tweede in de association mode. -->
				<xsl:when test="$proces-type = 'attributes'">
					<xsl:if test="imf:boolean($debug)">
						<xsl:comment select="'$resolvingEntity = empty and $proces-type = attributes'"/>
					</xsl:if>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="$proces-type"/>
						<xsl:with-param name="resolvingEntity" select="$resolvingEntity"/>
					</xsl:apply-templates>
					<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
						<xsl:with-param name="sourceEntity" select="$entity"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="$proces-type = 'associations'">
					<xsl:if test="imf:boolean($debug)">
						<xsl:comment select="'$resolvingEntity = empty and $proces-type = associations'"/>
					</xsl:if>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="$proces-type"/>
						<xsl:with-param name="resolvingEntity" select="$resolvingEntity"/>
					</xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
							<xsl:apply-templates select=".//imvert:association" mode="create-message-content">
								<xsl:with-param name="entity" select="$resolvingEntity"/>
								<xsl:with-param name="sourceEntity" select="$entity"/>
								<xsl:with-param name="id-trail">
									<xsl:choose>
										<xsl:when
											test="contains($id-trail, concat('#1#', imvert:id, '#'))">
											<xsl:value-of
												select="concat('#2#', imvert:id, '#', $id-trail)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="concat('#1#', imvert:id, '#', $id-trail)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<!-- Indien we besluiten recursie voor mag gaan komen dan moet dit nog worden gecodeerd. -->							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- In deze otherwise wordt de class die gerelateerd is aan het in bewerking zijnde berichttype verwerkt.
					 Eigenlijk de class die niet van het stereotype 'Entiteittype' zou mogen zijn. -->
				<xsl:otherwise>
					<xsl:if test="imf:boolean($debug)">
						<xsl:comment select="'$resolvingEntity = notempty'"/>
					</xsl:if>
					<xsl:sequence select="imf:create-output-element('ep:name', $entity)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:alias', imvert:alias)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:documentation', imvert:documentation)"/>
					<ep:seq>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'attributes'"/>
							<xsl:with-param name="resolvingEntity" select="$entity"/>
						</xsl:apply-templates>
						<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
							<xsl:with-param name="sourceEntity" select="$entity"/>
						</xsl:apply-templates>
						<!-- Voor de volgende elementen moet bepaald worden of deze gegenereerd worden danwel gedefinieerd in EAP. -->
						<!--ep:construct>
							<ep:name>StUF:tijdvakGeldigheid</ep:name>
							<ep:type-name>StUF:TijdvakGeldigheid</ep:type-name>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:tijdstipRegistratie</ep:name>
							<ep:type-name>StUF:Tijdstip-e</ep:type-name>
						</ep:construct>
						<ep:construct>
							<ep:name>StUF:extraElementen</ep:name>
							<ep:type-name>StUF:ExtraElementen</ep:type-name>
						</ep:construct-->
						<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
							<xsl:with-param name="proces-type" select="'associations'"/>
							<xsl:with-param name="resolvingEntity" select="$entity"/>
						</xsl:apply-templates>
						<xsl:apply-templates select=".//imvert:association" mode="create-message-content">
							<xsl:with-param name="entity" select="$entity"/>
							<xsl:with-param name="sourceEntity" select="$entity"/>
							<xsl:with-param name="id-trail"
								select="concat('#1#', imvert:id, '#', $id-trail)"/>
						</xsl:apply-templates>
					</ep:seq>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template>

	<xsl:template match="imvert:class" mode="create-message-relations-content">
		<!-- Deze parameter wordt gebruikt om te kunnen bepalen in welk stadium de opbouw van het bericht is. Is het overkoepelende 'ep:complexType' element al aangemaakt
			  of moet dat nog gebeuren. Indien deze parameter leeg is dan is dat element nog niet aangemaakt en moet in dit template de eerste when geactiveerd worden. 

			  MISSCHIEN KUNNEN WE HIER OOK EEN TOGGLE PARAMETER VAN MAKEN MET DE WAARDE 'yes' EN 'no'. -->
		<xsl:param name="resolvingEntity" select="''"/>
		<!-- Indien de bovenstaande parameter gevuld is dan wordt deze parameter gebruikt om te bepalen in welke modus dit template moet worden gebruikt. Moeten de attributes 
			  van een superclass of een gerelateerde class worden opgehaald of moeten de associations van een superclass of een gerelateerde class worden opgehaald. -->
		<xsl:param name="proces-type" select="''"/>
		<xsl:param name="entity" select="imvert:name"/>
		<xsl:param name="id-trail"/>
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:class[mode=create-message-relations-content]'"/>
		</xsl:if>
			<xsl:if test="imf:boolean($debug)">
				<xsl:sequence
					select="imf:create-output-element('ep:id', imvert:id)"/>
			</xsl:if>
			<xsl:choose>
				<!-- In deze eerste when wordt de class die gerelateerd is aan het in bewerking zijnde berichttype verwerkt. 
						 Dit is de class waarvan de waarde van 'imvert:alias' gelijk is aan de kolom 'entiteittype' van het in bewerking zijnde berichttype. -->

				<!-- Deze when kan waarschijnlijk weg omdat dit template pas wordt aangeroepen als de relaties in bewerking zijn. -->
				<xsl:when test="$resolvingEntity = ''">
					<xsl:comment select="'LET OP: Als deze tekst toont dan klopt er iets niet. Deze when tak zou nooit geactiveerd mogen worden.'"/>
				</xsl:when>
				<!-- In de volgende twee when's worden de superclasses of relatieclasses van de class die gerelateerd is aan het in bewerking zijnde berichttype verwerkt,
						  de eerste in de attributes mode en de tweede in de association mode. -->
				<xsl:when test="
						$resolvingEntity != ''
						and $proces-type = 'attributes'">
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="$proces-type"/>
						<xsl:with-param name="resolvingEntity" select="$resolvingEntity"/>
					</xsl:apply-templates>
					<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
						<xsl:with-param name="sourceEntity" select="$entity"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when
					test="
						$resolvingEntity != ''
						and $proces-type = 'associations'">
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="$proces-type"/>
						<xsl:with-param name="resolvingEntity" select="$resolvingEntity"/>
					</xsl:apply-templates>
					<xsl:choose>
						<xsl:when test="not(contains($id-trail, concat('#2#', imvert:id, '#')))">
							<xsl:apply-templates select=".//imvert:association" mode="create-message-content">
								<xsl:with-param name="entity" select="$entity"/>
								<xsl:with-param name="sourceEntity" select="$entity"/>
								<xsl:with-param name="id-trail">
									<xsl:choose>
										<xsl:when
											test="contains($id-trail, concat('#1#', imvert:id, '#'))">
											<xsl:value-of
												select="concat('#2#', imvert:id, '#', $id-trail)"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="concat('#1#', imvert:id, '#', $id-trail)"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
							</xsl:apply-templates>
						</xsl:when>
						<xsl:otherwise>
							<!-- Indien we besluiten recursie voor mag gaan komen dan moet dit nog worden gecodeerd. -->							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
	</xsl:template>

	<!-- template voor het simpelweg repliceren van elementen. Repliceert nog geen attributes. -->
	<xsl:template match="*" mode="replicate-imvert-elements">
		<xsl:element name="{concat('ep:',local-name())}">
			<xsl:choose>
				<xsl:when test="*">
					<xsl:apply-templates select="*" mode="replicate-imvert-elements"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template match="imvert:class" mode="create-datatype-content">
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:class[mode=create-datatype-content]'"/>
		</xsl:if>
		<xsl:choose>
			<!-- De eerste when tackled de situatie waarbij het datatype van een attribute geen simpleType betreft maar toch een complexType. In feite verwijst een attribute dan naar een objectType.
				 Deze situatie doet zich bijv. voor als we in een union verwijzen naar een entiteit in de ´Model´ package. -->
			<xsl:when test="imvert:stereotype = 'ENTITEITTYPE'">
				<?x xsl:apply-templates select="*" mode="create-message-content"/ x?>
				<ep:seq>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'attributes'"/>
						<xsl:with-param name="resolvingEntity" select="imvert:name"/>
					</xsl:apply-templates>
					<xsl:apply-templates select=".//imvert:attribute" mode="create-message-content">
						<xsl:with-param name="sourceEntity" select="imvert:name"/>
					</xsl:apply-templates>
					<xsl:apply-templates select="imvert:supertype" mode="create-message-content">
						<xsl:with-param name="proces-type" select="'associations'"/>
						<xsl:with-param name="resolvingEntity" select="imvert:name"/>
					</xsl:apply-templates>
					<xsl:apply-templates select=".//imvert:association" mode="create-message-content">
						<xsl:with-param name="entity" select="imvert:name"/>
						<xsl:with-param name="sourceEntity" select="imvert:name"/>
						<?x xsl:with-param name="id-trail"
							select="concat('#1#', imvert:id, '#', $id-trail)"/ x?>
					</xsl:apply-templates>
				</ep:seq>
			</xsl:when>
			<xsl:when test="imvert:stereotype = 'ENUMERATION'">
				<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="create-datatype-content"/>
			</xsl:when>
			<xsl:when test="imvert:stereotype = 'DATATYPE'">
				<xsl:choose>
					<!-- In de when tak betreft het eigenlijk een soort van groepselement vandaar dat we hier een ep:attributes element genereren. -->
					<xsl:when test="imvert:attributes/imvert:attribute">
						<ep:seq>
							<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="create-datatype-content"/>
						</ep:seq>
					</xsl:when>
					<xsl:otherwise>
						<ep:datatype id="{imvert:id}">
							<xsl:apply-templates select="imvert:documentation" mode="replicate-imvert-elements"/>
						</ep:datatype>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<ep:seq>
					<xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="create-datatype-content"/>
				</ep:seq>	
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="imvert:attribute" mode="create-datatype-content">
		<xsl:if test="imf:boolean($debug)">
			<xsl:comment select="'imvert:attribute[mode=create-datatype-content]'"/>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="imvert:stereotype = 'ENUM'">
					<xsl:sequence select="imf:create-output-element('ep:enum', imvert:name)"/>
			</xsl:when>
			<xsl:otherwise>
				<ep:construct>
					<xsl:sequence select="imf:create-output-element('ep:name', imvert:name)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:min-occurs', imvert:min-occurs)"/>
					<xsl:sequence
						select="imf:create-output-element('ep:max-occurs', imvert:max-occurs)"/>
					<xsl:choose>
						<!--<xsl:when test="imvert:type-id and not(imvert:stereotype='attribuutsoort')">-->
						<xsl:when test="imvert:type-id">
							<xsl:apply-templates select="//imvert:class[imvert:id = current()/imvert:type-id]" mode="create-datatype-content"/>
						</xsl:when>
						<!--<xsl:otherwise>
					<xsl:apply-templates select="//imvert:class[imvert:id=current()/imvert:type-id]" mode="create-message-content"/>
				</xsl:otherwise>-->
					</xsl:choose>
				</ep:construct>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:function name="imf:determineBerichtCode">
		<xsl:param name="typeBericht" as="xs:string"/>
		<xsl:param name="tagged-values"/>
		<xsl:choose>
			<xsl:when test="$typeBericht = 'Vraagbericht'">
				<xsl:choose>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>Lv01</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>Lv02</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>Lv05</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>Lv06</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>Lv07</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>Lv08</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>Lv09</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>Lv10</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('test: ', $typeBericht)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$typeBericht = 'AntwoordBericht'">
				<xsl:choose>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>La01</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>La02</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>Lav05</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'No']"
						>La06</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>La07</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>La08</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>La09</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsFormeel']/imvert:value = 'Yes' and
							imvert:tagged-values/imvert:tagged-value[imvert:name = 'IsMaterieel']/imvert:value = 'Yes']"
						>La10</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$typeBericht = 'KennisgevingBericht'">
				<xsl:choose>
					<xsl:when
						test="$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No']"
						>Lk01</xsl:when>
					<xsl:when
						test="$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes']"
						>Lk02</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$typeBericht = 'Vrij bericht'">
				<xsl:choose>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsInkomend']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No']"
						>Di01</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsInkomend']/imvert:value = 'Yes' and
							imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes']"
						>Di02</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsInkomend']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'No']"
						>Du01</xsl:when>
					<xsl:when
						test="
							$tagged-values/imvert:tagged-values[imvert:tagged-value[imvert:name = 'IsInkomend']/imvert:value = 'No' and
							imvert:tagged-value[imvert:name = 'IsSynchroon']/imvert:value = 'Yes']"
						>Du02</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>

	</xsl:function>

</xsl:stylesheet>
