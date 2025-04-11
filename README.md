# Imvertor-Maven
Imvertor is developed by Dutch Cadastre, and made available under GPL (https://nl.wikipedia.org/wiki/GNU_General_Public_License).

Imvertor may be compiled as a Java application. It will not run "out of the box". You need to add configuration files.

Because of a dependency with a 3rd party library that is not part of any public Maven repository the build process involves two steps:
1. `mvn validate`
2. `mvn clean install`