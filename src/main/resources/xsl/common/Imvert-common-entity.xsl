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
	xmlns:imf="http://www.imvertor.org/xsl/functions"
	exclude-result-prefixes="#all"
	version="2.0"
	>
		
	<!--
    replace a dangling character entity reference (form &abc;) by the correct character 
    -->
	
	<!-- sample use:
		 <imvert:doc id="{../imvert:id}">
      		<xsl:value-of select="imvert:resolve-dangling-entity-refs(.)" disable-output-escaping="yes"/>
   		 </imvert:doc>
    -->
	<xsl:variable name="entity-mapping" as="element()+">
		<e n="amp" v="&amp;amp;"/>
		<e n="apos" v="&apos;"/>
		<e n="quot" v="&quot;"/>
		<e n="lt" v="&lt;"/>
		<e n="gt" v="&gt;"/>

		<e n="acute" v="´" r="180"/>
		<!--acute accent = spacing acute-->
		<e n="cedil" v="¸" r="184"/>
		<!--cedilla = spacing cedilla-->
		<e n="circ" v="ˆ" r="710"/>
		<!--modifier letter circumflex accent-->
		<e n="macr" v="¯" r="175"/>
		<!--macron = spacing macron = overline = APL overbar-->
		<e n="middot" v="·" r="183"/>
		<!--middle dot = Georgian comma = Greek middle dot-->
		<e n="tilde" v="˜" r="732"/>
		<!--small tilde-->
		<e n="uml" v="¨" r="168"/>
		<!--diaeresis = spacing diaeresis-->

		<!---->
		<e n="Aacute" v="Á" r="193"/>
		<!--latin capital letter A with acute-->
		<e n="aacute" v="á" r="225"/>
		<!--latin small letter a with acute-->
		<e n="Acirc" v="Â" r="194"/>
		<!--latin capital letter A with circumflex-->
		<e n="acirc" v="â" r="226"/>
		<!--latin small letter a with circumflex-->
		<e n="AElig" v="Æ" r="198"/>
		<!--latin capital letter AE = latin capital ligature AE-->
		<e n="aelig" v="æ" r="230"/>
		<!--latin small letter ae = latin small ligature ae-->
		<e n="Agrave" v="À" r="192"/>
		<!--latin capital letter A with grave = latin capital letter A grave-->
		<e n="agrave" v="à" r="224"/>
		<!--latin small letter a with grave = latin small letter a grave-->
		<e n="Aring" v="Å" r="197"/>
		<!--latin capital letter A with ring above = latin capital letter A ring-->
		<e n="aring" v="å" r="229"/>
		<!--latin small letter a with ring above = latin small letter a ring-->
		<e n="Atilde" v="Ã" r="195"/>
		<!--latin capital letter A with tilde-->
		<e n="atilde" v="ã" r="227"/>
		<!--latin small letter a with tilde-->
		<e n="Auml" v="Ä" r="196"/>
		<!--latin capital letter A with diaeresis-->
		<e n="auml" v="ä" r="228"/>
		<!--latin small letter a with diaeresis-->
		<e n="Ccedil" v="Ç" r="199"/>
		<!--latin capital letter C with cedilla-->
		<e n="ccedil" v="ç" r="231"/>
		<!--latin small letter c with cedilla-->
		<e n="Eacute" v="É" r="201"/>
		<!--latin capital letter E with acute-->
		<e n="eacute" v="é" r="233"/>
		<!--latin small letter e with acute-->
		<e n="Ecirc" v="Ê" r="202"/>
		<!--latin capital letter E with circumflex-->
		<e n="ecirc" v="ê" r="234"/>
		<!--latin small letter e with circumflex-->
		<e n="Egrave" v="È" r="200"/>
		<!--latin capital letter E with grave-->
		<e n="egrave" v="è" r="232"/>
		<!--latin small letter e with grave-->
		<e n="ETH" v="Ð" r="208"/>
		<!--latin capital letter ETH-->
		<e n="eth" v="ð" r="240"/>
		<!--latin small letter eth-->
		<e n="Euml" v="Ë" r="203"/>
		<!--latin capital letter E with diaeresis-->
		<e n="euml" v="ë" r="235"/>
		<!--latin small letter e with diaeresis-->
		<e n="Iacute" v="Í" r="205"/>
		<!--latin capital letter I with acute-->
		<e n="iacute" v="í" r="237"/>
		<!--latin small letter i with acute-->
		<e n="Icirc" v="Î" r="206"/>
		<!--latin capital letter I with circumflex-->
		<e n="icirc" v="î" r="238"/>
		<!--latin small letter i with circumflex-->
		<e n="Igrave" v="Ì" r="204"/>
		<!--latin capital letter I with grave-->
		<e n="igrave" v="ì" r="236"/>
		<!--latin small letter i with grave-->
		<e n="Iuml" v="Ï" r="207"/>
		<!--latin capital letter I with diaeresis-->
		<e n="iuml" v="ï" r="239"/>
		<!--latin small letter i with diaeresis-->
		<e n="Ntilde" v="Ñ" r="209"/>
		<!--latin capital letter N with tilde-->
		<e n="ntilde" v="ñ" r="241"/>
		<!--latin small letter n with tilde-->
		<e n="Oacute" v="Ó" r="211"/>
		<!--latin capital letter O with acute-->
		<e n="oacute" v="ó" r="243"/>
		<!--latin small letter o with acute-->
		<e n="Ocirc" v="Ô" r="212"/>
		<!--latin capital letter O with circumflex-->
		<e n="ocirc" v="ô" r="244"/>
		<!--latin small letter o with circumflex-->
		<e n="OElig" v="Œ" r="338"/>
		<!--latin capital ligature OE-->
		<e n="oelig" v="œ" r="339"/>
		<!--latin small ligature oe (note)-->
		<e n="Ograve" v="Ò" r="210"/>
		<!--latin capital letter O with grave-->
		<e n="ograve" v="ò" r="242"/>
		<!--latin small letter o with grave-->
		<e n="Oslash" v="Ø" r="216"/>
		<!--latin capital letter O with stroke = latin capital letter O slash-->
		<e n="oslash" v="ø" r="248"/>
		<!--latin small letter o with stroke, = latin small letter o slash-->
		<e n="Otilde" v="Õ" r="213"/>
		<!--latin capital letter O with tilde-->
		<e n="otilde" v="õ" r="245"/>
		<!--latin small letter o with tilde-->
		<e n="Ouml" v="Ö" r="214"/>
		<!--latin capital letter O with diaeresis-->
		<e n="ouml" v="ö" r="246"/>
		<!--latin small letter o with diaeresis-->
		<e n="Scaron" v="Š" r="352"/>
		<!--latin capital letter S with caron-->
		<e n="scaron" v="š" r="353"/>
		<!--latin small letter s with caron-->
		<e n="szlig" v="ß" r="223"/>
		<!--latin small letter sharp s = ess-zed-->
		<e n="THORN" v="Þ" r="222"/>
		<!--latin capital letter THORN-->
		<e n="thorn" v="þ" r="254"/>
		<!--latin small letter thorn-->
		<e n="Uacute" v="Ú" r="218"/>
		<!--latin capital letter U with acute-->
		<e n="uacute" v="ú" r="250"/>
		<!--latin small letter u with acute-->
		<e n="Ucirc" v="Û" r="219"/>
		<!--latin capital letter U with circumflex-->
		<e n="ucirc" v="û" r="251"/>
		<!--latin small letter u with circumflex-->
		<e n="Ugrave" v="Ù" r="217"/>
		<!--latin capital letter U with grave-->
		<e n="ugrave" v="ù" r="249"/>
		<!--latin small letter u with grave-->
		<e n="Uuml" v="Ü" r="220"/>
		<!--latin capital letter U with diaeresis-->
		<e n="uuml" v="ü" r="252"/>
		<!--latin small letter u with diaeresis-->
		<e n="Yacute" v="Ý" r="221"/>
		<!--latin capital letter Y with acute-->
		<e n="yacute" v="ý" r="253"/>
		<!--latin small letter y with acute-->
		<e n="yuml" v="ÿ" r="255"/>
		<!--latin small letter y with diaeresis-->
		<e n="Yuml" v="Ÿ" r="376"/>
		<!--latin capital letter Y with diaeresis-->
		<e n="cent" v="¢" r="162"/>
		<!--cent sign-->
		<e n="curren" v="¤" r="164"/>
		<!--currency sign-->
		<e n="euro" v="€" r="8364"/>
		<!--euro sign-->
		<e n="pound" v="£" r="163"/>
		<!--pound sign-->
		<e n="yen" v="¥" r="165"/>
		<!--yen sign = yuan sign-->
		<e n="" v="" r=""/>

		<!---->
		<e n="brvbar" v="¦" r="166"/>
		<!--broken bar = broken vertical bar-->
		<e n="bull" v="•" r="8226"/>
		<!--bullet = black small circle (note)-->
		<e n="copy" v="©" r="169"/>
		<!--copyright sign-->
		<e n="dagger" v="†" r="8224"/>
		<!--dagger-->
		<e n="Dagger" v="‡" r="8225"/>
		<!--double dagger-->
		<e n="frasl" v="⁄" r="8260"/>
		<!--fraction slash-->
		<e n="hellip" v="…" r="8230"/>
		<!--horizontal ellipsis = three dot leader-->
		<e n="iexcl" v="¡" r="161"/>
		<!--inverted exclamation mark-->
		<e n="image" v="ℑ" r="8465"/>
		<!--blackletter capital I = imaginary part-->
		<e n="iquest" v="¿" r="191"/>
		<!--inverted question mark = turned question mark-->
		<e n="lrm" v="‎" r="8206"/>
		<!--left-to-right mark (for formatting only)-->
		<e n="mdash" v="—" r="8212"/>
		<!--em dash-->
		<e n="ndash" v="–" r="8211"/>
		<!--en dash-->
		<e n="not" v="¬" r="172"/>
		<!--not sign-->
		<e n="oline" v="‾" r="8254"/>
		<!--overline = spacing overscore-->
		<e n="ordf" v="ª" r="170"/>
		<!--feminine ordinal indicator-->
		<e n="ordm" v="º" r="186"/>
		<!--masculine ordinal indicator-->
		<e n="para" v="¶" r="182"/>
		<!--pilcrow sign = paragraph sign-->
		<e n="permil" v="‰" r="8240"/>
		<!--per mille sign-->
		<e n="prime" v="′" r="8242"/>
		<!--prime = minutes = feet-->
		<e n="Prime" v="″" r="8243"/>
		<!--double prime = seconds = inches-->
		<e n="real" v="ℜ" r="8476"/>
		<!--blackletter capital R = real part symbol-->
		<e n="reg" v="®" r="174"/>
		<!--registered sign = registered trade mark sign-->
		<e n="rlm" v="‏" r="8207"/>
		<!--right-to-left mark (for formatting only)-->
		<e n="sect" v="§" r="167"/>
		<!--section sign-->
		<e n="shy" v="" r="173"/>
		<!--soft hyphen = discretionary hyphen (displays incorrectly on Mac)-->
		<e n="sup1" v="¹" r="185"/>
		<!--superscript one = superscript digit one-->
		<e n="trade" v="™" r="8482"/>
		<!--trade mark sign-->
		<e n="weierp" v="℘" r="8472"/>
		<!--script capital P = power set = Weierstrass p-->

		<!---->
		<e n="bdquo" v="„" r="8222"/>
		<!--double low-9 quotation mark-->
		<e n="laquo" v="«" r="171"/>
		<!--left-pointing double angle quotation mark = left pointing guillemet-->
		<e n="ldquo" v="“" r="8220"/>
		<!--left double quotation mark-->
		<e n="lsaquo" v="‹" r="8249"/>
		<!--single left-pointing angle quotation mark (note)-->
		<e n="lsquo" v="‘" r="8216"/>
		<!--left single quotation mark-->
		<e n="raquo" v="»" r="187"/>
		<!--right-pointing double angle quotation mark = right pointing guillemet-->
		<e n="rdquo" v="”" r="8221"/>
		<!--right double quotation mark-->
		<e n="rsaquo" v="›" r="8250"/>
		<!--single right-pointing angle quotation mark (note)-->
		<e n="rsquo" v="’" r="8217"/>
		<!--right single quotation mark-->
		<e n="sbquo" v="‚" r="8218"/>
		<!--single low-9 quotation mark-->
		<e n="emsp" v=" " r="8195"/>
		<!--em space-->
		<e n="ensp" v=" " r="8194"/>
		<!--en space-->
		<e n="nbsp" v=" " r="160"/>
		<!--no-break space = non-breaking space-->
		<e n="thinsp" v=" " r="8201"/>
		<!--thin space-->
		<e n="zwj" v="‍" r="8205"/>
		<!--zero width joiner-->
		<e n="zwnj" v="‌" r="8204"/>
		<!--zero width non-joiner-->
		<e n="deg" v="°" r="176"/>
		<!--degree sign-->
		<e n="divide" v="÷" r="247"/>
		<!--division sign-->
		<e n="frac12" v="½" r="189"/>
		<!--vulgar fraction one half = fraction one half-->
		<e n="frac14" v="¼" r="188"/>
		<!--vulgar fraction one quarter = fraction one quarter-->
		<e n="frac34" v="¾" r="190"/>
		<!--vulgar fraction three quarters = fraction three quarters-->
		<e n="ge" v="≥" r="8805"/>
		<!--greater-than or equal to-->
		<e n="le" v="≤" r="8804"/>
		<!--less-than or equal to-->
		<e n="minus" v="−" r="8722"/>
		<!--minus sign-->
		<e n="sup2" v="²" r="178"/>
		<!--superscript two = superscript digit two = squared-->
		<e n="sup3" v="³" r="179"/>
		<!--superscript three = superscript digit three = cubed-->
		<e n="times" v="×" r="215"/>
		<!--multiplication sign-->

		<!---->
		<e n="alefsym" v="ℵ" r="8501"/>
		<!--alef symbol = first transfinite cardinal (note)-->
		<e n="and" v="∧" r="8743"/>
		<!--logical and = wedge-->
		<e n="ang" v="∠" r="8736"/>
		<!--angle-->
		<e n="asymp" v="≈" r="8776"/>
		<!--almost equal to = asymptotic to-->
		<e n="cap" v="∩" r="8745"/>
		<!--intersection = cap-->
		<e n="cong" v="≅" r="8773"/>
		<!--approximately equal to-->
		<e n="cup" v="∪" r="8746"/>
		<!--union = cup-->
		<e n="empty" v="∅" r="8709"/>
		<!--empty set = null set = diameter-->
		<e n="equiv" v="≡" r="8801"/>
		<!--identical to-->
		<e n="exist" v="∃" r="8707"/>
		<!--there exists-->
		<e n="fnof" v="ƒ" r="402"/>
		<!--latin small f with hook = function = florin-->
		<e n="forall" v="∀" r="8704"/>
		<!--for all-->
		<e n="infin" v="∞" r="8734"/>
		<!--infinity-->
		<e n="int" v="∫" r="8747"/>
		<!--integral-->
		<e n="isin" v="∈" r="8712"/>
		<!--element of-->
		<e n="lang" v="⟨" r="9001"/>
		<!--left-pointing angle bracket = bra (note)-->
		<e n="lceil" v="⌈" r="8968"/>
		<!--left ceiling = apl upstile-->
		<e n="lfloor" v="⌊" r="8970"/>
		<!--left floor = apl downstile-->
		<e n="lowast" v="∗" r="8727"/>
		<!--asterisk operator-->
		<e n="micro" v="µ" r="181"/>
		<!--micro sign-->
		<e n="nabla" v="∇" r="8711"/>
		<!--nabla = backward difference-->
		<e n="ne" v="≠" r="8800"/>
		<!--not equal to-->
		<e n="ni" v="∋" r="8715"/>
		<!--contains as member (note)-->
		<e n="notin" v="∉" r="8713"/>
		<!--not an element of-->
		<e n="nsub" v="⊄" r="8836"/>
		<!--not a subset of-->
		<e n="oplus" v="⊕" r="8853"/>
		<!--circled plus = direct sum-->
		<e n="or" v="∨" r="8744"/>
		<!--logical or = vee-->
		<e n="otimes" v="⊗" r="8855"/>
		<!--circled times = vector product-->
		<e n="part" v="∂" r="8706"/>
		<!--partial differential-->
		<e n="perp" v="⊥" r="8869"/>
		<!--up tack = orthogonal to = perpendicular-->
		<e n="plusmn" v="±" r="177"/>
		<!--plus-minus sign = plus-or-minus sign-->
		<e n="prod" v="∏" r="8719"/>
		<!--n-ary product = product sign (note)-->
		<e n="prop" v="∝" r="8733"/>
		<!--proportional to-->
		<e n="radic" v="√" r="8730"/>
		<!--square root = radical sign-->
		<e n="rang" v="⟩" r="9002"/>
		<!--right-pointing angle bracket = ket (note)-->
		<e n="rceil" v="⌉" r="8969"/>
		<!--right ceiling-->
		<e n="rfloor" v="⌋" r="8971"/>
		<!--right floor-->
		<e n="sdot" v="⋅" r="8901"/>
		<!--dot operator (note)-->
		<e n="sim" v="∼" r="8764"/>
		<!--tilde operator = varies with = similar to (note)-->
		<e n="sub" v="⊂" r="8834"/>
		<!--subset of-->
		<e n="sube" v="⊆" r="8838"/>
		<!--subset of or equal to-->
		<e n="sum" v="∑" r="8721"/>
		<!--n-ary sumation (note)-->
		<e n="sup" v="⊃" r="8835"/>
		<!--superset of (note)-->
		<e n="supe" v="⊇" r="8839"/>
		<!--superset of or equal to-->
		<e n="there4" v="∴" r="8756"/>
		<!--therefore-->

		<!---->
		<e n="Alpha" v="Α" r="913"/>
		<!--greek capital letter alpha-->
		<e n="alpha" v="α" r="945"/>
		<!--greek small letter alpha-->
		<e n="Beta" v="Β" r="914"/>
		<!--greek capital letter beta-->
		<e n="beta" v="β" r="946"/>
		<!--greek small letter beta-->
		<e n="Chi" v="Χ" r="935"/>
		<!--greek capital letter chi-->
		<e n="chi" v="χ" r="967"/>
		<!--greek small letter chi-->
		<e n="Delta" v="Δ" r="916"/>
		<!--greek capital letter delta-->
		<e n="delta" v="δ" r="948"/>
		<!--greek small letter delta-->
		<e n="Epsilon" v="Ε" r="917"/>
		<!--greek capital letter epsilon-->
		<e n="epsilon" v="ε" r="949"/>
		<!--greek small letter epsilon-->
		<e n="Eta" v="Η" r="919"/>
		<!--greek capital letter eta-->
		<e n="eta" v="η" r="951"/>
		<!--greek small letter eta-->
		<e n="Gamma" v="Γ" r="915"/>
		<!--greek capital letter gamma-->
		<e n="gamma" v="γ" r="947"/>
		<!--greek small letter gamma-->
		<e n="Iota" v="Ι" r="921"/>
		<!--greek capital letter iota-->
		<e n="iota" v="ι" r="953"/>
		<!--greek small letter iota-->
		<e n="Kappa" v="Κ" r="922"/>
		<!--greek capital letter kappa-->
		<e n="kappa" v="κ" r="954"/>
		<!--greek small letter kappa-->
		<e n="Lambda" v="Λ" r="923"/>
		<!--greek capital letter lambda-->
		<e n="lambda" v="λ" r="955"/>
		<!--greek small letter lambda-->
		<e n="Mu" v="Μ" r="924"/>
		<!--greek capital letter mu-->
		<e n="mu" v="μ" r="956"/>
		<!--greek small letter mu-->
		<e n="Nu" v="Ν" r="925"/>
		<!--greek capital letter nu-->
		<e n="nu" v="ν" r="957"/>
		<!--greek small letter nu-->
		<e n="Omega" v="Ω" r="937"/>
		<!--greek capital letter omega-->
		<e n="omega" v="ω" r="969"/>
		<!--greek small letter omega-->
		<e n="Omicron" v="Ο" r="927"/>
		<!--greek capital letter omicron-->
		<e n="omicron" v="ο" r="959"/>
		<!--greek small letter omicron-->
		<e n="Phi" v="Φ" r="934"/>
		<!--greek capital letter phi-->
		<e n="phi" v="φ" r="966"/>
		<!--greek small letter phi-->
		<e n="Pi" v="Π" r="928"/>
		<!--greek capital letter pi-->
		<e n="pi" v="π" r="960"/>
		<!--greek small letter pi-->
		<e n="piv" v="ϖ" r="982"/>
		<!--greek pi symbol-->
		<e n="Psi" v="Ψ" r="936"/>
		<!--greek capital letter psi-->
		<e n="psi" v="ψ" r="968"/>
		<!--greek small letter psi-->
		<e n="Rho" v="Ρ" r="929"/>
		<!--greek capital letter rho-->
		<e n="rho" v="ρ" r="961"/>
		<!--greek small letter rho-->
		<e n="Sigma" v="Σ" r="931"/>
		<!--greek capital letter sigma-->
		<e n="sigma" v="σ" r="963"/>
		<!--greek small letter sigma-->
		<e n="sigmaf" v="ς" r="962"/>
		<!--greek small letter final sigma (note)-->
		<e n="Tau" v="Τ" r="932"/>
		<!--greek capital letter tau-->
		<e n="tau" v="τ" r="964"/>
		<!--greek small letter tau-->
		<e n="Theta" v="Θ" r="920"/>
		<!--greek capital letter theta-->
		<e n="theta" v="θ" r="952"/>
		<!--greek small letter theta-->
		<e n="thetasym" v="ϑ" r="977"/>
		<!--greek small letter theta symbol-->
		<e n="upsih" v="ϒ" r="978"/>
		<!--greek upsilon with hook symbol-->
		<e n="Upsilon" v="Υ" r="933"/>
		<!--greek capital letter upsilon-->
		<e n="upsilon" v="υ" r="965"/>
		<!--greek small letter upsilon-->
		<e n="Xi" v="Ξ" r="926"/>
		<!--greek capital letter xi-->
		<e n="xi" v="ξ" r="958"/>
		<!--greek small letter xi-->
		<e n="Zeta" v="Ζ" r="918"/>
		<!--greek capital letter zeta-->
		<e n="zeta" v="ζ" r="950"/>
		<!--greek small letter zeta-->
		<e n="crarr" v="↵" r="8629"/>
		<!--downwards arrow with corner leftwards = carriage return-->
		<e n="darr" v="↓" r="8595"/>
		<!--downwards arrow-->
		<e n="dArr" v="⇓" r="8659"/>
		<!--downwards double arrow-->
		<e n="harr" v="↔" r="8596"/>
		<!--left right arrow-->
		<e n="hArr" v="⇔" r="8660"/>
		<!--left right double arrow-->
		<e n="larr" v="←" r="8592"/>
		<!--leftwards arrow-->
		<e n="lArr" v="⇐" r="8656"/>
		<!--leftwards double arrow (note)-->
		<e n="rarr" v="→" r="8594"/>
		<!--rightwards arrow-->
		<e n="rArr" v="⇒" r="8658"/>
		<!--rightwards double arrow (note)-->
		<e n="uarr" v="↑" r="8593"/>
		<!--upwards arrow-->
		<e n="uArr" v="⇑" r="8657"/>
		<!--upwards double arrow-->

		<!---->
		<e n="clubs" v="♣" r="9827"/>
		<!--black club suit = shamrock-->
		<e n="diams" v="♦" r="9830"/>
		<!--black diamond suit-->
		<e n="hearts" v="♥" r="9829"/>
		<!--black heart suit = valentine-->
		<e n="spades" v="♠" r="9824"/>
		<!--black spade suit (note)-->
		<e n="loz" v="◊" r="9674"/>
		<!--lozenge-->
	</xsl:variable>

	<xsl:variable name="entref-regex">&amp;([A-Za-z0-9]+);</xsl:variable>

	<xsl:function name="imf:resolve-dangling-entity-refs" as="xs:string">
		<xsl:param name="string" as="xs:string?"/>
		<xsl:variable name="s">
			<xsl:if test="$string">
				<xsl:analyze-string select="$string" regex="{$entref-regex}" flags="">
					<xsl:matching-substring>
						<xsl:variable name="e" select="$entity-mapping[@n=regex-group(1)]/@v"/>
						<xsl:choose>
							<xsl:when test="$e">
								<xsl:value-of select="$e"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat('{',regex-group(1),'}')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:matching-substring>
					<xsl:non-matching-substring>
						<xsl:value-of select="."/>
					</xsl:non-matching-substring>
				</xsl:analyze-string>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="$s"/>
	</xsl:function>

</xsl:stylesheet>
