# Imvertor-Maven
Imvertor is developed by Dutch Cadastre, and made available under GPL (https://nl.wikipedia.org/wiki/GNU_General_Public_License).

Imvertor may be compiled as a Java application. It will not run "out of the box". You need to add configuration files.

Let's suppose you installed imvertor at 
<pre> %installdir% = D:\projects\gitprojects\Imvertor-Maven </pre>

So your pom.xml is at:
<pre> %installdir%\pom.xml </pre>

You need to create a data folder:
<pre>%datadir% = D:\projects\validprojects\Kadaster-Imvertor</pre>

Here you need to create the following folders:
<pre>
%datadir%\Imvertor-output - standard output folder
%datadir%\Imvertor-work  - standard work folder
%datadir%\Imvertor-input - standard input folder
</pre>

Within Eclipse, you can compile and run using the following application setting:
<pre>
Project: Imvertor-Chains
Main class: nl.imvertor.ChainTranslateAndReport
</pre>
Program arguments are:
<pre>
-arguments "%installdir%\src\main\resources\example\SampleBase.1.properties"
-umlfile "%installdir%\src\main\resources\example\SampleBase.1.xmi"
-application "SampleApplicationBase"
</pre>
VM arguments are:
<pre>
-Dlog4j.configuration=file:%installdir%\src\main\resources\cfg\log4j.properties
-Dinstall.dir=%installdir%\src\main\resources
-Doutput.dir=%datadir%\Imvertor-OS-output
-Dwork.dir=%datadir%\Imvertor-OS-work\default
-Djava.library.path=c:\java\EnterpriseArchitect\Java-API
-Downer.name=Kadaster
</pre>
Note: If you want to access Enterprise Architect from within Imvertor, you need to install EA, and install some files as described on http://www.sparxsystems.com/enterprise_architect_user_guide/10/automation_and_scripting/setup.html
Place the files in an accessible location, e.g.
<pre>c:/tools/ImvertorOS-M/Imvertor-bin/bin/EA</pre>
And set in setings.xml of the Maven user folder, e.g.:
```xml
<settings>
   <profiles>
     <profile>
     <id>eapath</id> 
     <properties>
  		<eapath>c:/tools/ImvertorOS-M/Imvertor-bin/bin/EA</eapath> 
     </properties>
    </profile>
   </profiles>
   <activeProfiles>
    <activeProfile>eapath</activeProfile> 
   </activeProfiles>
</settings>
```

You should be able to run imvertor from within Eclipse now.

If you want to run Imvertor from the command line follow these steps:

Create a folder for the program to run, say:
<pre>c:\tools\ImvertorOS-M</pre>

Create the subfolders 
<pre>
c:\tools\ImvertorOS-M\Imvertor-bin - standard program folder
c:\tools\ImvertorOS-M\Imvertor-output - standard output folder
c:\tools\ImvertorOS-M\Imvertor-work  - standard work folder
c:\tools\ImvertorOS-M\Imvertor-input - standard input folder
</pre>
Compile to the binary folder/file
<pre>
c:\tools\ImvertorOS-M\Imvertor-bin\bin\*.jar
</pre>
The jar name depends on your choice of chain (Chain*.java) and naming preferences. 

Extract the resources folders within the jar file to the folder:
<pre>
c:\tools\ImvertorOS-M\Imvertor-bin
</pre>
so you get 
<pre>
c:\tools\ImvertorOS-M\Imvertor-bin\*
</pre>
where * is: cfg, etc, example, deploy, xsd, xsl, and gpl.txt
copy the deploy files to the same root, so you get:
<pre>
c:\tools\ImvertorOS-M\Imvertor-bin\*.bat
</pre>

Now go to the example folder, and run the file
example\SampleBase.1.bat 

This should produce the same result as your Eclipse result.

