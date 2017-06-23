<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:variable name="output-folder" select="imf:get-config-string('system','managedoutputfolder')"/>
    <xsl:variable name="owner" select="imf:get-config-string('cli','owner')"/>
    <xsl:variable name="local-constructs" select="('attributes', 'associations', 'name', 'id')"/>
    <xsl:variable name="allow-multiple-suppliers" select="imf:boolean(imf:get-config-string('cli','allowmultiplesuppliers','no'))"/>
    <xsl:variable name="all-traced-construct-names" select="('class','attribute','association')"/>

    <xsl:variable name="application-package-subpath" select="imf:get-trace-supplier-subpath($project-name,$application-package-name,$application-package-release)"/>
    
    <xsl:variable name="all-derived-models" select="$all-derived-models-doc/imvert:package-dependencies/imvert:supplier-contents"/>
    
    <xsl:function name="imf:get-construct-formal-trace-name" as="xs:string">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="type-name" select="local-name($this)"/>
        <xsl:variable name="package-name" select="$this/ancestor-or-self::imvert:package[imvert:stereotype = $traceable-package-stereotypes][1]/imvert:name"/>
        <xsl:variable name="supplier-package-name" select="(($this/ancestor-or-self::imvert:package)/imvert:supplier/imvert:supplier-package-name)[1]"/>
        <xsl:variable name="effective-package-name" select="($supplier-package-name,$package-name)[1]"/>
        <!-- note that for classes and properties we do not support alternative names (yet) -->
        <xsl:variable name="effective-class-name" select="$this/ancestor-or-self::imvert:class[1]/imvert:name"/>
        <xsl:variable name="effective-prop-name" select="$this[self::imvert:attribute | self::association]/imvert:name"/> 
        <xsl:sequence select="imf:compile-construct-formal-name($type-name,$effective-package-name,$effective-class-name,$effective-prop-name)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-supplier-system-subpaths" as="xs:string*">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="suppliers" select="($this/ancestor-or-self::imvert:*)/imvert:supplier"/>
        <xsl:for-each select="$suppliers">
            <xsl:variable name="supplier-project" select="imvert:supplier-project"/>
            <xsl:variable name="supplier-name" select="imvert:supplier-name"/>
            <xsl:variable name="supplier-release" select="imvert:supplier-release"/>
            <xsl:variable name="subpath" select="imf:get-subpath($supplier-project,$supplier-name,$supplier-release)"/>
            <xsl:value-of select="$subpath"/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- TODO uitfaseren!! -->
    <xsl:function name="imf:get-construct-supplier-system-subpath" as="xs:string?">
        <xsl:param name="this" as="element()"/>
        <xsl:variable name="suppliers" select="($this/ancestor-or-self::imvert:*)/imvert:supplier"/>
        <xsl:if test="exists($suppliers)">
            <xsl:variable name="supplier-project" select="($suppliers/imvert:supplier-project)[1]"/>
            <xsl:variable name="supplier-name" select="($suppliers/imvert:supplier-name)[1]"/>
            <xsl:variable name="supplier-release" select="($suppliers/imvert:supplier-release)[1]"/>
            <xsl:variable name="subpath" select="imf:get-subpath($supplier-project,$supplier-name,$supplier-release)"/>
            <xsl:if test="empty(imf:get-config-string('appinfo','supplier-etc-model-imvert-path',()))">
                <xsl:sequence select="imf:set-config-string('appinfo','supplier-etc-model-imvert-subpath',$subpath)"/>
            </xsl:if>
            <xsl:value-of select="$subpath"/>
        </xsl:if>
    </xsl:function>
    
    <!--
        Return a sequence of supplier elements, each holding a single construct, that is traced from the construct passed 
        
        Pass any construct that may be traced: imvert:class, imvert:attribute, imvert:relation.
        
        A supplier is included only once, when when doubles occur.
    -->
    <xsl:function name="imf:get-trace-suppliers-for-construct" as="element(supplier)*">
        <xsl:param name="client-construct" as="element()"/>
        <xsl:param name="level" as="xs:integer"/>
        
        <xsl:variable name="suppliers" as="element(supplier)*">
            <xsl:for-each-group select="imf:get-trace-suppliers-for-construct-depth-first($client-construct,1,())" group-by="@id">
                <xsl:sequence select="current-group()[1]"/>
            </xsl:for-each-group>
        </xsl:variable>
        <!--<xsl:sequence select="imf:create-file(concat('c:\temp\data\',local-name($client-construct),'-',$client-construct/imvert:id,'-',generate-id($client-construct),'.xml'),($level, $suppliers,$client-construct))"/>-->
        <xsl:sequence select="$suppliers"/>
    </xsl:function>
    <!--
        This returns all suppliers found in depth first fashion, therefore not undoubled.
    -->
    <xsl:function name="imf:get-trace-suppliers-for-construct-depth-first" as="element(supplier)*">
        <xsl:param name="client-construct" as="element()"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:param name="passed-hits" as="xs:string*"/>
        
        <xsl:variable name="hits" select="($passed-hits,$client-construct/imvert:id)"/>
      
        <xsl:sequence select="imf:get-client-info($client-construct,$level)"/>
        
        <!-- 
            there may be multiple suppliers; if so, trace all though the supplier hierarchy to find the traced construct by ID 
        -->
        <xsl:variable name="suppliers" select="($client-construct/ancestor-or-self::imvert:*)/imvert:supplier"/> 
        
        <xsl:for-each select="$suppliers">
            
            <xsl:variable name="supplier-project" select="imvert:supplier-project"/>
            <xsl:variable name="supplier-name" select="imvert:supplier-name"/>
            <xsl:variable name="supplier-release" select="imvert:supplier-release"/>
            
            <xsl:variable name="subpath" select="imf:get-trace-supplier-subpath($supplier-project,$supplier-name,$supplier-release)"/>
            <xsl:variable name="supplier-application" select="imf:get-trace-supplier-application($subpath)"/>
          
            <xsl:choose>
                <xsl:when test="empty($supplier-project)">
                    <xsl:sequence select="imf:msg(..,'ERROR','No supplier project specified')"/>
                </xsl:when>
                <xsl:when test="empty($supplier-name)">
                    <xsl:sequence select="imf:msg(..,'ERROR','No supplier name specified')"/>
                </xsl:when>
                <xsl:when test="empty($supplier-release)">
                    <xsl:sequence select="imf:msg(..,'ERROR','No supplier release specified')"/>
                </xsl:when>
                <xsl:when test="empty($supplier-application)">
                    <xsl:sequence select="imf:msg(..,'ERROR','No supplier document found for project [1], application [2] at release [3]',($supplier-project,$supplier-name,$supplier-release))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$client-construct/imvert:trace">
                        
                        <xsl:variable name="trace-id" select="string(.)"/>   
                        <xsl:if test="not($trace-id = $hits)">
                            <xsl:variable name="supplier-constructs" select="imf:get-trace-construct-by-id(..,$trace-id,$all-derived-models-doc)"/>
                            <!-- several constructs with same ID are copy-down constructs: assume for trace purposes all are the same -->
                            <xsl:variable name="supplier-construct" select="$supplier-constructs[1]"/>
                            
                            <xsl:choose>
                                <xsl:when test="exists($supplier-construct)">
                                    <xsl:sequence select="imf:get-trace-suppliers-for-construct-depth-first($supplier-construct,$level + 1,$hits)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- doesnt exists there -->
                                    <xsl:sequence select="imf:msg(..,'ERROR','Trace cannot be resolved: [1]', $trace-id)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            
         </xsl:for-each>
            
    </xsl:function>
    
    <!-- return a wrapper <supplier> for the construct passed -->
    
    <xsl:function name="imf:get-client-info" as="element(supplier)">
        <xsl:param name="client-construct" as="element()"/>
        <xsl:param name="level" as="xs:integer"/>
        
        <!-- return at least the info on this construct -->
        <xsl:variable name="client-application" select="$client-construct/ancestor::imvert:packages[1]"/>
        <xsl:variable name="client-project" select="$client-application/imvert:project"/>
        <xsl:variable name="client-name" select="$client-application/imvert:application"/>
        <xsl:variable name="client-release" select="$client-application/imvert:release"/>
        
        <xsl:variable name="client-subpath" select="imf:get-subpath($client-project,$client-name,$client-release)"/>
        
        <xsl:variable name="type" select="
            if ($client-construct/../../imvert:designation = 'enumeration') then 'enumeration'
            else 
            if ($client-construct/imvert:aggregation = 'composite') then 'composition'
            else local-name($client-construct)
            "/>
        <xsl:variable name="display-name" select="$client-construct/(@display-name,imvert:name)[1]"/>
        
        <supplier>
            <xsl:attribute name="id" select="$client-construct/imvert:id"/>
            <xsl:attribute name="project" select="$client-project"/>
            <xsl:attribute name="application" select="$client-name"/>
            <xsl:attribute name="release" select="$client-release"/>
            <xsl:attribute name="level" select="$level"/>
            <xsl:attribute name="subpath" select="$client-subpath"/>
            <xsl:attribute name="type" select="$type"/>
            <xsl:attribute name="display-name" select="$display-name"/>
            <xsl:attribute name="base-namespace" select="$client-construct/ancestor::imvert:packages/imvert:base-namespace"/>
            <xsl:attribute name="verkorteAlias" select="imf:get-tagged-value($client-construct/ancestor::imvert:packages,'##CFG-TV-VERKORTEALIAS')"/>
        </supplier>
        
    </xsl:function>
    
    <!-- 
        pass a supplier element, and return the construct taken from the tree identified by that supplier.
        A supplier may be taken from the current application (first in trace sequence) and so: check if the supplier is in current tree. 
    -->
    <xsl:function name="imf:get-trace-construct-by-supplier" as="element()?">
        <xsl:param name="supplier" as="element(supplier)"/>
        <xsl:param name="imvert-document" as="document-node()"/>
        <!-- 
            When suppler is the current applicaton, do not load from file. 
            Else get the application document in the managed output folder
        -->
        <xsl:variable name="supplier-subpath" select="imf:get-trace-supplier-subpath($supplier/@project,$supplier/@application,$supplier/@release)"/>
        <xsl:variable name="supplier-packages" select="if ($supplier-subpath eq $application-package-subpath) then $imvert-document/* else imf:get-trace-supplier-application($supplier-subpath)"/>
        <xsl:variable name="construct" select="imf:get-construct-by-id($supplier/@id,root($supplier-packages))"/>
        <?x <xsl:variable name="construct" select="imf:get-construct-by-id($supplier/@id,$supplier-doc)"/>  x?>
        <!--TODO copy-down introduces two identical ID's, should not occur! -->
        <xsl:sequence select="$construct[1]"/>
    </xsl:function>
    
    <!--
        Return the supplier document for the supplier subpath passed.
        Returns () when some info is missing.
    -->
    <xsl:function name="imf:get-trace-supplier-application" as="element(imvert:packages)?">
        <xsl:param name="supplier-subpath" as="xs:string?"/>
        <xsl:sequence select="$all-derived-models[@subpath=$supplier-subpath]/imvert:packages"/>
    </xsl:function>
    
    <xsl:function name="imf:get-trace-supplier-subpath" as="xs:string">
        <xsl:param name="supplier" as="element(imvert:supplier)"/>
        <xsl:sequence select="imf:get-trace-supplier-subpath($supplier/imvert:supplier-project,$supplier/imvert:supplier-name,$supplier/imvert:supplier-release)"/>
    </xsl:function>
    
    <xsl:function name="imf:get-trace-supplier-subpath" as="xs:string">
        <xsl:param name="supplier-project" as="xs:string?"/>
        <xsl:param name="supplier-name" as="xs:string?"/>
        <xsl:param name="supplier-release" as="xs:string?"/>
        <xsl:sequence select="imf:get-subpath($supplier-project,$supplier-name,$supplier-release)"/>
    </xsl:function>
    
    <!-- 
        Determine all involved suppliers in depth-first order.
        Return the subpaths e.g.  ('SIM/RM-487811 (2) tweede supplier/20140401','SIM/RM-487811 (1) eerste supplier/20140401')
    -->
    <xsl:function name="imf:get-trace-all-supplier-subpaths" as="xs:string*">
        <xsl:param name="application" as="element(imvert:packages)?"/>
        <xsl:variable name="subpaths" as="xs:string*">
            <!-- first myself -->
            <xsl:sequence select="imf:get-trace-supplier-subpath($application/imvert:project,$application/imvert:application,$application/imvert:release)"/>
            <!-- then my suppliers -->
            <xsl:for-each select="$application/imvert:supplier">
                <!-- more than one when for this application there are multiple supplier packages --> 
                <!-- get the supplier, and see it that has supplier  itself -->
                <xsl:variable name="subpath" select="imf:get-trace-supplier-subpath(imvert:supplier-project,imvert:supplier-name,imvert:supplier-release)"/>
                <xsl:variable name="supplier-application" select="imf:get-trace-supplier-application($subpath)"/>
                <xsl:sequence select="imf:get-trace-all-supplier-subpaths($supplier-application)"/>               
            </xsl:for-each>
        </xsl:variable>
        <!-- avoid duplicates -->
        <xsl:sequence select="distinct-values($subpaths)"/>
    </xsl:function>
   
    <xsl:function name="imf:get-imvert-system-doc" as="document-node()?">
        <xsl:param name="subpath"/>
        <xsl:sequence select="imf:document(concat($output-folder,'/applications/',$subpath,'/etc/system.imvert.xml'),false())"/>
    </xsl:function>
    <xsl:function name="imf:get-imvert-supplier-doc" as="document-node()?">
        <xsl:param name="subpath"/>
        <?x
            <!-- migration issue: when no supplier doc available yet, use the system doc, though this is a too rich representation. -->
            <xsl:variable name="doc" select="imf:document(concat($output-folder,'/applications/',$subpath,'/etc/supplier.imvert.xml'),false())"/>
            <xsl:sequence select="if (exists($doc)) then $doc else imf:get-imvert-system-doc($subpath)"/>
        ?>
        <xsl:sequence select="imf:get-imvert-system-doc($subpath)"/>
        
    </xsl:function>
    
    <!--
        https://kinggemeenten.plan.io/issues/488594 
        
        Deze functie bepaalt per entiteit, relatie of attribuut wat zijn UGM van oorsprong is. 
        Dat is dus de meest veraf gelegen supplier in de afleidingsketen. 

    -->
    <xsl:function name="imf:get-trace-supplier-for-construct" as="element(supplier)?">
        <xsl:param name="client-construct" as="element()"/>
        <xsl:param name="project-name" as="xs:string"/>
        <xsl:variable name="suppliers" select="imf:get-trace-suppliers-for-construct-depth-first($client-construct,1,())"/>
        <xsl:variable name="project-suppliers" as="element(supplier)*">
            <xsl:for-each select="$suppliers[@project = $project-name]">
                <xsl:sort select="@level" order="descending"/>
                <xsl:sequence select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$project-suppliers[1]"/>
    </xsl:function>
    
</xsl:stylesheet>