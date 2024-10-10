var organisationConfig = {
    
    nl_organisationName: "EIGENAAR",
    
    nl_organisationStylesURL: "https://gitdocumentatie.logius.nl/publicatie/respec/style/",
    
    nl_organisationPublishURL: "https://vng-realisatie.github.io/publicatie",
    
    // Het hier gedefinieerde logo wordt helemaal bovenaan het Respec document aan de rechterzijde geplaatst.
    // Er is voor gekozen de 'width' property niet te gebruiken waardoor het logo automatisch in de juiste verhoudingen wordt geplaatst.
    
    logos: [{
        src: "https://vng-realisatie.github.io/VNG-R-Respec-Organization-configurations/media/logo-VNG-Realisatie.jpg",
        alt: "VNG-Realisatie",
        id: "VNG-Realisatie",
        height: 77,
        url: "https://www.vng.nl",
    }],

   // Mermaid is een eenvoudige notatie-wijze voor het definieren van  diverse soorten diagrammen. Onderstaande 'postProcess' maakt van die eenvoudige notatie een grafiek.
   //VERWIJDEREN? postProcess: [window.respecMermaid.createFigures],

   // De hier gedefinieerde variabelen kunnen door ze nogmaals in de config.js te plaatsen overruled worden.  

   pubDomain: "cim",
   	
   //this: "this", <-- Zo kun je dus eigen variabelen introduceren die je ergens anders kunt gebruiken.
   // Zoals bijv. hier --> 'thisVersion: ["nl_organisationPublishURL", "this", "/", "shortName"],'

   latestVersion: ["nl_organisationPublishURL", "pubDomain", "/", "shortName"],
   thisVersion: ["nl_organisationPublishURL", "pubDomain", "/", "shortName", "/", "publishVersion"],
   prevVersion: ["nl_organisationPublishURL", "pubDomain", "/", "shortName", "/", "previousPublishVersion"],

    useLogo: true,
    useLabel: true,
//    noTOC: true,
    maxTocLevel: 4,

    license: "eupl",
    addSectionLinks: true,

    localizationStrings: {
        nl: {
            // Specificatie-statussen	
            cv: "Consultatieversie",
            vv: "Versie ter vaststelling",
	    ig: "In Gebruik versie",
	    io: "In Ontwikkeling versie",
 //           tg: "Teruggetrokken versie",
	    // Specificatie-types
            im: "Informatiemodel",
            hl: "Handleiding",
//            basis: "Document",
//            no: "Norm",
            st: "Standaard",
//            pr: "Praktijkrichtlijn",
//            wa: "Werkafspraak",
//            al: "Algemeen",
//            bd: "Beheerdocumentatie",
//            bp: "Best practice",
        },
//        en: {
            // Specificatie-statussen	
//            cv: "Recommendation",
//            vv: "Proposed recommendation",
//            eo: "Outdated version",
//            tg: "Rescinded version",
	    // Specificatie-types
//            basis: "Document",
//            no: "Norm",
//            st: "Standard",
//            im: "Information model",
//            pr: "Guideline",
//            hr: "Guide",
//            wa: "Proposed recommendation",
//            al: "General",
//            bd: "Governance documentation",
//            bp: "Best practice",
//        },
    },

    sotdText: {
        nl: {
            sotd: "Status van dit document",
            cv: `Dit is een door het TO goedgekeurde consultatieversie. Commentaar over dit document kan gestuurd worden naar `,
            vv: `Dit is een definitief concept van de nieuwe versie van dit document. Wijzigingen naar aanleiding van consultaties zijn doorgevoerd.`,
	    ig: "Dit document is 'In Gebruik'.",
	    io: "Dit document is nog 'In Ontwikkeling'.",
        },
//      en: {
//          sotd: "Status of This Document",
//          def: `This is the definitive version of this document. Edits resulting from consultations have been applied.`,
//          wv: `This is a draft that could be altered, removed or replaced by other documents. It is not a recommendation approved by TO.`,
//          cv: `This is a proposed recommendation approved by TO. Comments regarding this document may be sent to `,
//          vv: `This is the definitive concept of this document. Edits resulting from consultations have been applied.`,
//          basis: "This document has no official standing.",
//	    ig: "This document is 'In Use'.",
//	    io: "This document is is still 'Under Development'.",
//        },
    },

    labelColor: {
//        def: "#154273",
//        wv: "#39870c",
	ig: "#A569BD",
	io: "#DC7633"
    },
	
    licenses: {
        cc0: {
            name: "Creative Commons 0 Public Domain Dedication",
            short: "CC0",
            url: "https://creativecommons.org/publicdomain/zero/1.0/",
            image: "https://gitdocumentatie.logius.nl/publicatie/respec/media/logos/cc-zero.svg",
        },
        "cc-by": {
            name: "Creative Commons Attribution 4.0 International Public License",
            short: "CC-BY",
            url: "https://creativecommons.org/licenses/by/4.0/legalcode",
            image: "https://gitdocumentatie.logius.nl/publicatie/respec/media/logos/cc-by.svg",
        },
        "cc-by-nd": {
            name: "Creative Commons Naamsvermelding-GeenAfgeleideWerken 4.0 Internationaal",
            short: "CC-BY-ND",
            url: "https://creativecommons.org/licenses/by-nd/4.0/legalcode.nl",
            image: "https://gitdocumentatie.logius.nl/publicatie/respec/media/logos/cc-by-nd.svg",
        },
        "eupl": {
            name: "EUROPEAN UNION PUBLIC LICENCE v. 1.2",
            short: "EUPL",
            url: "https://eupl.eu/",
            image: "https://eupl.eu/eu.png",
        },
    },

    localBiblio: {
        "ORICODE": {
           "href": "https://www.unicode.org/versions/latest/",
           "publisher": "Unicode Consortium",
           "title": "The Unicode Standard",
            date: "June 2013",
            rawDate: "2021"
        },
        "SemVer": {
            href: "https://semver.org",
            title: "Semantic Versioning 2.0.0",
            authors: ["T. Preston-Werner"],
            date: "June 2013"
        },
    },
}