# Imvertor

[![Build master](https://github.com/Imvertor/Imvertor-Maven/actions/workflows/build-package-master.yml/badge.svg?branch=master)](https://github.com/Imvertor/Imvertor-Maven/actions/workflows/build-package-master.yml)
[![Build Development](https://github.com/Imvertor/Imvertor-Maven/actions/workflows/build-package-development.yml/badge.svg?branch=Development)](https://github.com/Imvertor/Imvertor-Maven/actions/workflows/build-package-development.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](src/main/resources/gpl.txt)

Imvertor zet UML-informatiemodellen (uit Enterprise Architect of als XMI) om naar
technische en documentaire eindproducten, zoals XML Schema, JSON Schema, OpenAPI,
SHACL, SKOS, Linked Data, MIM-serialisaties, YAML, broncode en (Respec-)documentatie.
Daarbij valideert Imvertor het model tegen een metamodel (o.a. MIM, NEN 3610, Kadaster
en GML) en maakt het rapportages en releases.

Imvertor is oorspronkelijk ontwikkeld door het Kadaster en wordt beschikbaar gesteld
onder de [GNU General Public License v3](src/main/resources/gpl.txt) (of later).

Website: <http://www.imvertor.org/>

---

## Inhoud

- [Hoe werkt het](#hoe-werkt-het)
- [Vereisten](#vereisten)
- [Bouwen](#bouwen)
- [Saxon-edities](#saxon-edities)
- [Configuratie](#configuratie)
- [Uitvoeren](#uitvoeren)
- [Projectstructuur](#projectstructuur)
- [Branches en releases](#branches-en-releases)
- [Bijdragen](#bijdragen)
- [Licentie](#licentie)

## Hoe werkt het

Imvertor is opgebouwd als een *chain* van stappen. Elke stap is een Java-klasse
(meestal een dunne schil om een reeks XSLT-transformaties, uitgevoerd met Saxon) met
een eigen configuratie in `src/main/resources/cfg/<Stap>/parms.xml`.

De hoofdchain is [`ChainTranslateAndReport`](src/main/java/nl/imvertor/ChainTranslateAndReport.java)
en doorloopt globaal:

1. **Inlezen** – `XmiCompiler` haalt het model op (een EA-project via de Enterprise Architect API, of XMI).
2. **Configureren** – `ConfigCompiler` bouwt de configuratie voor de opgegeven metamodel/owner-combinatie.
3. **Vertalen** – `XmiTranslator` of `MimTranslator` zet het model om naar het interne *Imvert*-formaat.
4. **Valideren** – `Validator` controleert het model tegen de regels van het metamodel.
5. **Genereren** – afhankelijk van de parameters o.a. `XsdCompiler`, `JsonSchemaCompiler`,
   `ShaclCompiler`, `SkosCompiler`, `LDCompiler`, `YamlCompiler`, `OfficeCompiler`,
   `SourcecodeGenerator`, `MIMCompiler`.
6. **Rapporteren en releasen** – `Reporter`, `ReadmeCompiler`, `ReleaseCompiler`.

Naast de hoofdchain zijn er gespecialiseerde chains, zoals `ChainCompliancy`,
`ChainRegression`, `ChainMsWordTransformer`, `ChainGenericTransformer`,
`ChainXsltAnalyzer` en `ChainKING`.

## Vereisten

- **Java 17** (JDK om te bouwen, JRE om uit te voeren)
- **Apache Maven 3.x**
- Toegang tot de Maven-repositories die in de [`pom.xml`](pom.xml) staan
  (Maven Central, de Armatiek-repository voor de Saxon-extensies en – voor PE/EE –
  de Saxonica-repository)
- Optioneel: **Enterprise Architect** (Windows) om EA-projectbestanden (zoals `.eap`)
  direct in te lezen. Zonder EA kun je werken met XMI-invoer.

## Bouwen

De Enterprise Architect Java API (`lib/eaapi.jar`) staat niet in een publieke
Maven-repository. Daarom gaat het bouwen in twee stappen:

```bash
mvn validate
```

```bash
mvn clean install
```

`mvn validate` installeert `lib/eaapi.jar` in je lokale Maven-repository; die stap is
eenmalig per machine nodig. `mvn clean install` levert daarna een *shaded* (fat) jar
op in `target/`, bijvoorbeeld `target/imvertor-0.9.9.jar`, met
`nl.imvertor.ChainTranslateAndReport` als main class.

## Saxon-edities

Imvertor gebruikt Saxon 10. Met Maven-profielen kies je de editie:

| Profiel                 | Editie                  | Licentie nodig |
|-------------------------|-------------------------|----------------|
| `Saxon-HE` (standaard)  | Home Edition            | Nee            |
| `Saxon-PE`              | Professional Edition    | Ja             |
| `Saxon-EE`              | Enterprise Edition      | Ja             |

```bash
mvn clean install -P Saxon-EE
```

Voor PE en EE moet er een geldig `saxon-license.lic` beschikbaar zijn (bijvoorbeeld in
`src/main/resources/`). Dit bestand staat in `.gitignore` en hoort **niet** in de
repository. Bij het opstarten logt Imvertor welke Saxon-editie actief is en of de
PE/EE-licentie herkend wordt.

## Configuratie

Imvertor werkt niet "out of the box": er is configuratie nodig voor de omgeving en
voor het model dat je verwerkt.

**Systeemeigenschappen** (via `-D…` bij het starten van de JVM):

| Eigenschap    | Betekenis                                                          |
|---------------|--------------------------------------------------------------------|
| `install.dir` | Installatiemap van Imvertor (bevat o.a. `input/`, `xsl/`, `cfg/`)  |
| `job.id`      | Unieke naam voor deze run; bepaalt de werkmap                       |
| `owner.name`  | Eigenaar van het model, bijvoorbeeld `Kadaster` of `Geonovum`       |
| `run.mode`    | `development` (standaard) of `deployed`                             |

**`server.properties`** bevat de omgevingsinstellingen, zoals `work.dir`, `output.dir`,
`managed.dir.reg` en `ea.enabled`. In development-modus wordt dit bestand in de
huidige werkmap gezocht; in deployed-modus in de map uit de omgevingsvariabele
`imvertor_os_basefolder`. Ook dit bestand staat in `.gitignore`.

**Owner-configuratie** staat in `src/main/resources/input/<owner>/`, met daarin:

- `props/` – `.properties`-bestanden met de run-parameters per model of product
- `cfg/` – metamodellen, documentatie-, schema-, vergelijkings- en rapportageregels
- eventueel `xsd/`, `eap/` en andere owner-specifieke bronnen

Een overzicht van alle parameters per stap staat in de `parms.xml`-bestanden onder
`src/main/resources/cfg/`. Je kunt ze ook opvragen met `-help program`.

## Uitvoeren

Een minimale aanroep van de hoofdchain ziet er ongeveer zo uit:

```bash
java -Xmx1024m -Dfile.encoding=UTF-8 -Dinstall.dir=/pad/naar/imvertor -Djob.id=mijnrun -Downer.name=Kadaster -jar target/imvertor-0.9.9.jar -arguments /pad/naar/model.properties -umlfile /pad/naar/model.eap -owner Kadaster
```

Parameters kun je op de commandoregel meegeven (`-naam waarde`) of verzamelen in een
properties-bestand dat je met `-arguments` doorgeeft.

Kant-en-klare startscripts voor Windows en Linux staan in
[`src/main/resources/deploy/`](src/main/resources/deploy/)
(`ImvertorOS.bat`, `ImvertorOS.server.bat`, `ImvertorOS.server.sh`).

## Projectstructuur

```
.
├── lib/                     Enterprise Architect Java API (eaapi.jar)
├── src/main/java/nl/imvertor/
│   ├── Chain*.java          Startpunten (chains)
│   ├── <Stap>/              Java-klassen per chain-stap
│   └── common/              Gedeelde infrastructuur (Configurator, Transformer, …)
└── src/main/resources/
    ├── cfg/<Stap>/          Parameterdefinities per stap
    ├── xsl/                 XSLT-stylesheets per stap
    ├── input/<owner>/       Owner-specifieke configuratie en metamodellen
    ├── etc/                 Gedeelde schema's, DTD's, Respec-, SKOS- en TTL-bronnen
    ├── static/              Statische releasebestanden
    ├── deploy/              Startscripts
    └── tests/               Testbestanden
```

## Branches en releases

- **`master`** – stabiele versie
- **`Development`** – ontwikkelbranch; feature branches worden hierin gemerged

Bij elke push naar `master` of `Development` bouwt GitHub Actions het project en
publiceert het het artefact `nl.imvertor:imvertor` naar
[GitHub Packages](https://github.com/Imvertor/Imvertor-Maven/packages).

## Bijdragen

Issues en pull requests zijn welkom via
[GitHub](https://github.com/Imvertor/Imvertor-Maven). Maak een feature branch vanaf
`Development` en richt je pull request ook op `Development`. Controleer voor je een
pull request maakt dat `mvn clean install` slaagt.

## Licentie

Copyright © Dienst voor het kadaster en de openbare registers en bijdragers.

Imvertor is vrije software: je mag het verspreiden en/of wijzigen onder de voorwaarden
van de [GNU General Public License](src/main/resources/gpl.txt), zoals gepubliceerd
door de Free Software Foundation, versie 3 of (naar keuze) een latere versie.
Afhankelijkheden vallen onder hun eigen licenties; `mvn install` downloadt die via de
`license-maven-plugin` naar `target/`.
