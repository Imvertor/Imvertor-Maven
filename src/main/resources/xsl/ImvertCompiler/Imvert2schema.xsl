<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:html="http://www.w3.org/1999/xhtml"  
    
    xmlns:imvert-result="http://www.imvertor.org/schema/imvertor/application/v20160201"

    exclude-result-prefixes="#all"
    version="2.0">
    
    <!-- 
       Transform the embellish file to an XML document that is conformant to the XML schema for Imvertor. 
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    
    <xsl:variable name="imvertor-application-location-url" select="imf:get-config-string('properties','IMVERTOR_APPLICATION_LOCATION_URL')"/>
    
    <xsl:template match="/imvert:packages">
        <imvert-result:Application
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            >
            <xsl:attribute name="xsi:schemaLocation" select="concat('http://www.imvertor.org/schema/imvertor/application/v20160201', ' ', $imvertor-application-location-url)"/>
            <xsl:apply-templates select="imvert:project"/>
            <xsl:apply-templates select="imvert:generated"/>
            <xsl:apply-templates select="imvert:generator"/>
            <xsl:apply-templates select="imvert:exported"/>
            <xsl:apply-templates select="imvert:exporter"/>
            <xsl:apply-templates select="imvert:local-schema-svn-id"/>
            <xsl:apply-templates select="imvert:conceptual-schema-svn-id"/>
            
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:filter">
                    <xsl:sort select="imvert:date"/>
                </xsl:apply-templates><!-- ... -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('filters',$group)"/>
            
            <xsl:call-template name="_Identifiable">
                <xsl:with-param name="name" select="imvert:application"/>
            </xsl:call-template>
            
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:package">
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates><!-- ... -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('packages',$group)"/>
        
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:local-schema">
                    <xsl:sort select="."/>
                </xsl:apply-templates><!-- ... -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('localSchemas',$group)"/>
            
            <xsl:call-template name="_Svn"/>
            <xsl:call-template name="_Derivable"/>
            <xsl:call-template name="_Tagged"/>
            
        </imvert-result:Application>
    </xsl:template>
    
    <xsl:template match="imvert:package">
        <imvert-result:Package>
            
            <xsl:call-template name="_Identifiable">
                <xsl:with-param name="name" select="imvert:name"/>
            </xsl:call-template>
            <xsl:call-template name="_Released"/>
            <xsl:call-template name="_Svn"/>
            <xsl:call-template name="_Debuggable"/>
            <xsl:call-template name="_Derivable"/>
            <xsl:call-template name="_Referencing"/>
            <xsl:call-template name="_Conceptual"/>
            <xsl:call-template name="_Tagged"/>
           
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:class">
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:sequence select="imf:create-group('classes',$group)"/>
            
        </imvert-result:Package>
    </xsl:template>
   
    <xsl:template match="imvert:class">
        <imvert-result:Class>
            <xsl:apply-templates select="imvert:abstract"/>
            <xsl:apply-templates select="imvert:designation"/>
            <xsl:apply-templates select="imvert:origin"/>
            <xsl:apply-templates select="imvert:pattern"/>
            <xsl:apply-templates select="imvert:union"/>
            <xsl:apply-templates select="imvert:primitive"/>
            <xsl:apply-templates select="imvert:ref-master"/>
            <xsl:apply-templates select="imvert:conceptual-schema-class-name"/>
            <xsl:apply-templates select="imvert:subpackage"/>
            
            <xsl:call-template name="_Identifiable">
                <xsl:with-param name="name" select="imvert:name"/>
            </xsl:call-template>
            <xsl:call-template name="_Released"/>
            <xsl:call-template name="_Debuggable"/>
            <xsl:call-template name="_Tagged"/>
            
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:supertype">
                    <xsl:sort select="imvert:type-name"/>
                </xsl:apply-templates><!-- .. -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('supertypes',$group)"/>
            
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:attributes/imvert:attribute[not(imvert:stereotype = 'ENUMERATION')]">
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates><!-- .. -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('attributes',$group)"/>
            
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:associations/imvert:association">
                    <xsl:sort select="imvert:name"/>
                </xsl:apply-templates><!-- .. -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('associations',$group)"/>
            
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:attributes/imvert:attribute[imvert:stereotype = 'ENUMERATION']">
                    <xsl:sort select="."/>
                </xsl:apply-templates><!-- .. -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('enumeration',$group)"/>
            
            <xsl:apply-templates select="imvert:association-class">
                <xsl:sort select="imvert:type-name"/>
            </xsl:apply-templates><!-- .. -->
            <xsl:apply-templates select="imvert:substitution">
                <xsl:sort select="imvert:supplier"/>
            </xsl:apply-templates><!-- ... -->
            
        </imvert-result:Class>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:type-name][not(imvert:stereotype = 'ENUMERATION')]">
        <imvert-result:Attribute>
           
            <xsl:apply-templates select="imvert:max-length"/>
            <xsl:apply-templates select="imvert:fraction-digits"/>
            <xsl:apply-templates select="imvert:total-digits"/>
            
            <xsl:apply-templates select="imvert:data-location"/>
            <xsl:apply-templates select="imvert:position"/>
            
            <xsl:apply-templates select="imvert:attribute-type-name"/>
            <xsl:apply-templates select="imvert:attribute-type-designation"/>
            <xsl:apply-templates select="imvert:attribute-type-hasnilreason"/>
            <xsl:apply-templates select="imvert:copy-down-type-id"/>
            <xsl:apply-templates select="imvert:conceptual-schema-type"/>
            
            <xsl:call-template name="_Identifiable">
                <xsl:with-param name="name" select="imvert:name"/>
            </xsl:call-template>
            <xsl:call-template name="_Released"/>
            <xsl:call-template name="_Debuggable"/>
            <xsl:call-template name="_Tagged"/>

            <xsl:call-template name="_Type"/>
            <xsl:call-template name="_Cardinality"/>
                        
        </imvert-result:Attribute>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:type-name][imvert:stereotype = 'ENUMERATION']">
        <imvert-result:Attribute>
            
            <xsl:apply-templates select="imvert:data-location"/>
            <xsl:apply-templates select="imvert:position"/>
            
            <xsl:call-template name="_Identifiable">
                <xsl:with-param name="name" select="imvert:name"/>
            </xsl:call-template>
            <xsl:call-template name="_Released"/>
            <xsl:call-template name="_Debuggable"/>
            <xsl:call-template name="_Tagged"/>
            
            <xsl:call-template name="_Type"/>
            <xsl:call-template name="_Cardinality"/>
            
        </imvert-result:Attribute>
    </xsl:template>
   
    <xsl:template match="imvert:association">
        <imvert-result:Association>
            <xsl:apply-templates select="imvert:aggregation"/>
            <xsl:apply-templates select="imvert:position"/>
            <xsl:apply-templates select="imvert:copy-down-type-id"/>
            
            <xsl:apply-templates select="imvert:source-name"/>
            <xsl:apply-templates select="imvert:source-alias"/>
            <xsl:apply-templates select="imvert:target-name"/>
            <xsl:apply-templates select="imvert:target-alias"/>
            
            <xsl:call-template name="_Identifiable">
                <xsl:with-param name="name" select="imvert:name"/>
            </xsl:call-template>
            <xsl:call-template name="_Released"/>
            <xsl:call-template name="_Debuggable"/>
            <xsl:call-template name="_Tagged"/>

            <xsl:call-template name="_Type"/>
            <xsl:call-template name="_Cardinality"/>
            
            <xsl:apply-templates select="imvert:association-class" mode="association-class-reference"/>
            
        </imvert-result:Association>
    </xsl:template>
    
    <xsl:template match="imvert:supertype">
        <imvert-result:Type>
            <xsl:apply-templates select="imvert:type-name"/>
            <xsl:apply-templates select="imvert:type-id"/>
            <xsl:apply-templates select="imvert:type-package"/>
            <xsl:apply-templates select="imvert:stereotype"/>
        </imvert-result:Type>
    </xsl:template>
    
    <xsl:template match="imvert:substitution">
        <imvert-result:Substitution>
            <xsl:apply-templates select="imvert:supplier"/>
            <xsl:apply-templates select="imvert:supplier-id"/>
            <xsl:apply-templates select="imvert:supplier-package"/>
            <xsl:apply-templates select="imvert:stereotype"/>
        </imvert-result:Substitution>
    </xsl:template>
    
    <xsl:template match="imvert:local-schema">
        <imvert-result:LocalSchema>
            <imvert-result:id>
                <xsl:value-of select="."/>
            </imvert-result:id>
        </imvert-result:LocalSchema>
    </xsl:template>
    
    <xsl:template match="imvert:filter">
        <imvert-result:Filter>
            <xsl:sequence select="imf:create-names(imvert:name)"/>
            <xsl:apply-templates select="imvert:date"/>
            <xsl:apply-templates select="imvert:version"/>
        </imvert-result:Filter>
    </xsl:template>
  
    <xsl:template match="imvert:tagged-values">
        <xsl:variable name="group" as="element()*">
            <xsl:apply-templates select="imvert:tagged-value">
                <xsl:sort select="imvert:name"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('tags',$group)"/>
    </xsl:template>
    <xsl:template match="imvert:tagged-value">
        <xsl:variable name="group" as="element()*">
            <xsl:sequence select="imf:create-names(imvert:name)"/>
            <xsl:apply-templates select="imvert:value"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('TaggedValue',$group)"/>
    </xsl:template>
    
    <xsl:template match="imvert:concepts">
        <xsl:variable name="group" as="element()*">
            <xsl:apply-templates select="imvert:concept">
                <xsl:sort select="imvert:uri"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('concepts',$group)"/>
    </xsl:template>
    <xsl:template match="imvert:concept">
        <xsl:variable name="group" as="element()*">
            <xsl:apply-templates select="imvert:uri"/>
            <xsl:apply-templates select="imvert:info"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('Concept',$group)"/>
    </xsl:template>

    <xsl:template match="imvert:association-class">
        <xsl:variable name="group" as="element()*">
            <xsl:apply-templates select="imvert:type-name"/>
            <xsl:apply-templates select="imvert:type-id"/>
            <xsl:apply-templates select="imvert:type-package"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('AssociationClass',$group)"/>
    </xsl:template>
    
    <xsl:template match="imvert:association-class" mode="association-class-reference">
        <xsl:variable name="group" as="element()*">
            <xsl:apply-templates select="imvert:type-name"/>
            <xsl:apply-templates select="imvert:type-id"/>
            <xsl:apply-templates select="imvert:type-package"/>
            <xsl:apply-templates select="imvert:source-navigable"/>
            <xsl:apply-templates select="imvert:target-navigable"/>
        </xsl:variable>
        <imvert-result:associationClass>
            <xsl:sequence select="imf:create-group('AssociationClassReference',$group)"/>
        </imvert-result:associationClass>
    </xsl:template>
    
    <xsl:template match="imvert:enum">
        <imvert-result:Enum>
            <imvert-result:value>
                <xsl:value-of select="."/>
            </imvert-result:value>
        </imvert-result:Enum>
    </xsl:template>
    
    <xsl:template match="imvert:*">
        <xsl:variable name="group" as="item()*">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group(imf:correct-name(local-name(.)),$group)"/>
    </xsl:template>
    
    <!-- copy HTML elements to result -->
    <xsl:template match="html:*">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="node()">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*">
        <!-- suppress -->
    </xsl:template>
    
    <xsl:template name="_Debuggable">
        <xsl:variable name="group" as="element()*">
            <xsl:apply-templates select="imvert:debug"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('debug',$group)"/>
    </xsl:template>

    <xsl:template name="_Identifiable">
        <xsl:param name="name"/>
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:id"/>
                <xsl:sequence select="imf:create-names($name)"/>
                <xsl:apply-templates select="imvert:short-name"/>
                <xsl:apply-templates select="imvert:alias"/>
                <xsl:apply-templates select="imvert:namespace"/>
                <xsl:apply-templates select="imvert:stereotype"/>
                <xsl:apply-templates select="imvert:trace"/>
                <xsl:apply-templates select="imvert:dependency"/>
                <xsl:apply-templates select="imvert:static"/>
                <xsl:apply-templates select="imvert:scope"/>
                <xsl:apply-templates select="imvert:visibility"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Identifiable',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('identification',$group)"/>
    </xsl:template>
  
    <xsl:template name="_Released">
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:documentation"/>
                <xsl:apply-templates select="imvert:author"/>
                <xsl:apply-templates select="imvert:created"/>
                <xsl:apply-templates select="imvert:modified"/>
                <xsl:apply-templates select="imvert:version"/>
                <xsl:apply-templates select="imvert:phase"/>
                <xsl:apply-templates select="imvert:release"/>
                <xsl:apply-templates select="imvert:web-location"/>
                <xsl:apply-templates select="imvert:location"/>
                <xsl:apply-templates select="imvert:concepts"/><!-- ... -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Released',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('release',$group)"/>
        
    </xsl:template>
    
    <xsl:template name="_Derivable">
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:derived"/>
                <xsl:apply-templates select="imvert:metamodel"/>
                <xsl:apply-templates select="imvert:supplier"/>
                <!--
                imvert:supplier-name
                imvert:supplier-project
                imvert:supplier-release
                imvert:supplier-package-release
                -->
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Derivable',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('derivation',$group)"/>
    </xsl:template>

    <xsl:template name="_Svn">
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:svn-author"/>
                <xsl:apply-templates select="imvert:svn-file"/>
                <xsl:apply-templates select="imvert:svn-revision"/>
                <xsl:apply-templates select="imvert:svn-date"/>
                <xsl:apply-templates select="imvert:svn-time"/>
                <xsl:apply-templates select="imvert:svn-user"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Svn',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('version',$group)"/>
    </xsl:template>    
    
    <xsl:template name="_Conceptual">
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:conceptual-schema-namespace"/>
                <xsl:apply-templates select="imvert:conceptual-schema-version"/>
                <xsl:apply-templates select="imvert:conceptual-schema-phase"/>
                <xsl:apply-templates select="imvert:conceptual-schema-author"/>
                <xsl:apply-templates select="imvert:conceptual-schema-svn-string"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Conceptual',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('conceptual',$group)"/>      
    </xsl:template>
    
    <xsl:template name="_Referencing">
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:ref-version"/>
                <xsl:apply-templates select="imvert:ref-release"/>
                <xsl:apply-templates select="imvert:ref-master"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Referencing',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('reference',$group)"/>
      
    </xsl:template>

    <xsl:template name="_Tagged">
        <xsl:apply-templates select="imvert:tagged-values"/>
    </xsl:template>
    
    <xsl:template name="_Type">
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:type-name"/>
                <xsl:apply-templates select="imvert:type-id"/>
                <xsl:apply-templates select="imvert:type-package"/>
                <xsl:apply-templates select="imvert:type-package-id"/>
                <xsl:apply-templates select="imvert:baretype"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Type',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('type',$group)"/>
    </xsl:template>

    <xsl:template name="_Cardinality">
        <xsl:variable name="group" as="element()*">
            <xsl:variable name="group" as="element()*">
                <xsl:apply-templates select="imvert:min-occurs"/>
                <xsl:apply-templates select="imvert:max-occurs"/>
                <xsl:apply-templates select="imvert:min-occurs-source"/>
                <xsl:apply-templates select="imvert:max-occurs-source"/>
            </xsl:variable>
            <xsl:sequence select="imf:create-group('Cardinal',$group)"/>
        </xsl:variable>
        <xsl:sequence select="imf:create-group('cardinality',$group)"/>
    </xsl:template>
    
    <xsl:function name="imf:create-group" as="element()*">
        <xsl:param name="element-name"/>
        <xsl:param name="content"/>
        <xsl:if test="exists($content)">
            <xsl:element name="{concat('imvert-result:',$element-name)}">
                <xsl:sequence select="$content"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
        
    <xsl:function name="imf:correct-name" as="xs:string">
        <xsl:param name="element-name"/>
        <xsl:variable name="r">
            <xsl:analyze-string select="$element-name" regex="\-(.)">
                <xsl:matching-substring>
                    <xsl:value-of select="upper-case(regex-group(1))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="$r"/>
    </xsl:function>
    
    <xsl:function name="imf:create-names">
        <xsl:param name="name" as="element()?"/>
        <imvert-result:name>
            <xsl:value-of select="$name"/>
        </imvert-result:name>
        <xsl:if test="normalize-space($name/@original)">
            <imvert-result:originalName>
                <xsl:value-of select="$name/@original"/>
            </imvert-result:originalName>
        </xsl:if>
        
    </xsl:function>
    
</xsl:stylesheet>
