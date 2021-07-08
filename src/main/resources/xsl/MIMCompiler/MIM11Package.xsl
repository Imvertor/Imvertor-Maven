<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:imvert="http://www.imvertor.org/schema/system"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:variable name="mim11-package" as="element(imvert:package)">
    <imvert:package display-name="MIM11:: = http://www.geonovum.nl/conceptual-schemas/MIM11" formal-name="package">
      <imvert:id>OUTSIDE-1</imvert:id>
      <imvert:conceptual-schema-version>1.0.0</imvert:conceptual-schema-version>
      <imvert:version>1.0.0</imvert:version>
      <imvert:conceptual-schema-phase>3</imvert:conceptual-schema-phase>
      <imvert:phase>3</imvert:phase>
      <imvert:name original="MIM11">MIM11</imvert:name>
      <imvert:short-name>mim11</imvert:short-name>
      <imvert:alias>http://www.geonovum.nl/conceptual-schemas/MIM11</imvert:alias>
      <imvert:conceptual-schema-name>MIM11</imvert:conceptual-schema-name>
      <imvert:conceptual-schema-namespace>http://www.geonovum.nl/conceptual-schemas/MIM11</imvert:conceptual-schema-namespace>
      <imvert:namespace>http://www.geonovum.nl/MIM11</imvert:namespace>
      <imvert:location>http://schemas.geonovum.nl/mim11.xsd</imvert:location>
      <imvert:release>20200820</imvert:release>
      <imvert:stereotype id="stereotype-name-external-package">EXTERN</imvert:stereotype>
      <imvert:class display-name="MIM11::Date" formal-name="class_xsdate">
        <imvert:conceptual-schema-class-name>Date</imvert:conceptual-schema-class-name>
        <imvert:name original="Date">xs:date</imvert:name>
        <imvert:id>EAID_3E6F5023_BF71_4da0_8747_0B8D334A8D04</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::Day" formal-name="class_xsgDay">
        <imvert:conceptual-schema-class-name>Day</imvert:conceptual-schema-class-name>
        <imvert:name original="Day">xs:gDay</imvert:name>
        <imvert:id>EAID_427C0973_E12D_47f8_A326_AACBADEE5AE6</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::Year" formal-name="class_xsgYear">
        <imvert:conceptual-schema-class-name>Year</imvert:conceptual-schema-class-name>
        <imvert:name original="Year">xs:gYear</imvert:name>
        <imvert:id>EAID_4DA242C6_3972_4f1e_86F0_BBB8046F4BC9</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::Decimal" formal-name="class_xsdecimal">
        <imvert:conceptual-schema-class-name>Decimal</imvert:conceptual-schema-class-name>
        <imvert:name original="Decimal">xs:decimal</imvert:name>
        <imvert:id>EAID_4B14AA67_7035_465b_B4A5_AACAB944175E</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::DateTime" formal-name="class_xsdateTime">
        <imvert:conceptual-schema-class-name>DateTime</imvert:conceptual-schema-class-name>
        <imvert:name original="DateTime">xs:dateTime</imvert:name>
        <imvert:id>EAID_366435A3_6E41_4add_A833_21873B97D7C7</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::Month" formal-name="class_xsgMonth">
        <imvert:conceptual-schema-class-name>Month</imvert:conceptual-schema-class-name>
        <imvert:name original="Month">xs:gMonth</imvert:name>
        <imvert:id>EAID_FC8CFD1F_45A2_4507_90DA_82453E61834B</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::Real" formal-name="class_xsfloat">
        <imvert:conceptual-schema-class-name>Real</imvert:conceptual-schema-class-name>
        <imvert:name original="Real">xs:float</imvert:name>
        <imvert:id>EAID_3C4BBF7A_20EC_4a62_A172_F00A6D73FD5E</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::CharacterString" formal-name="class_xsstring">
        <imvert:conceptual-schema-class-name>CharacterString</imvert:conceptual-schema-class-name>
        <imvert:name original="CharacterString">xs:string</imvert:name>
        <imvert:id>EAID_18BFBA8D_E3F4_4d8c_9A8F_4429FA54B041</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::URI" formal-name="class_xsanyURI">
        <imvert:conceptual-schema-class-name>URI</imvert:conceptual-schema-class-name>
        <imvert:name original="URI">xs:anyURI</imvert:name>
        <imvert:id>EAID_DAB6A78C_1FE9_4ecf_9DB3_45B541679D62</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::Integer" formal-name="class_xsinteger">
        <imvert:conceptual-schema-class-name>Integer</imvert:conceptual-schema-class-name>
        <imvert:name original="Integer">xs:integer</imvert:name>
        <imvert:id>EAID_F38912FB_7856_4a9d_AF96_CB2238371C04</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
      <imvert:class display-name="MIM11::Boolean" formal-name="class_xsboolean">
        <imvert:conceptual-schema-class-name>Boolean</imvert:conceptual-schema-class-name>
        <imvert:name original="Boolean">xs:boolean</imvert:name>
        <imvert:id>EAID_70FBDB70_4B81_46ab_97BB_058195812ECB</imvert:id>
        <imvert:catalog>https://geonovum.github.io/MIM-Werkomgeving/#primitive-datatypes</imvert:catalog>
        <imvert:stereotype id="stereotype-name-interface">INTERFACE</imvert:stereotype>
        <imvert:subpackage>MIM11</imvert:subpackage>
      </imvert:class>
    </imvert:package>
  </xsl:variable>
  
</xsl:stylesheet>