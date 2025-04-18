var organisationConfig = {
    
    nl_organisationName: "Armatiek",
    
    nl_organisationStylesURL: "https://gitdocumentatie.logius.nl/publicatie/respec/style/",
    
    nl_organisationPublishURL: "https://armatiek.nl/doc",
    
    // Het hier gedefinieerde logo wordt helemaal bovenaan het Respec document aan de rechterzijde geplaatst.
    // Er is voor gekozen de 'width' property niet te gebruiken waardoor het logo automatisch in de juiste verhoudingen wordt geplaatst.
    
    logos: [{
        src: "documentor/img/logo.png",
        alt: "Logo-Armatiek",
        id: "Logo-Armatiek",
        height: 40,
        url: "https://armatiek.nl",
    }],

   // De hier gedefinieerde variabelen kunnen door ze nogmaals in de config.js te plaatsen overruled worden.  
   shortName: "noname",
   pubDomain: "report", // publicatie domein, zoals "imvertor", "whitepaper" etc.
   publishVersion: "0.01",
   //previousPublishVersion: "0.001",
   	
   //this: "this", <-- Zo kun je dus eigen variabelen introduceren die je ergens anders kunt gebruiken.
   // Zoals bijv. hier --> 'thisVersion: ["nl_organisationPublishURL", "this", "/", "shortName"],'

   latestVersion: ["nl_organisationPublishURL", "pubDomain", "/", "shortName"],
   thisVersion: ["nl_organisationPublishURL", "pubDomain", "/", "shortName", "/", "publishVersion"],
   prevVersion: ["nl_organisationPublishURL", "pubDomain", "/", "shortName", "/", "previousPublishVersion"],

    useLogo: true,
    useLabel: true,
    // noTOC: true,
    maxTocLevel: 4,

    license: "eupl",
    addSectionLinks: true,

    localizationStrings: {
        nl: {
            // Specificatie-statussen	
            cv: "Consultatieversie",
            vv: "Ter vaststelling",
	        ig: "In gebruik",
	        io: "In ontwikkeling",
 	        // Specificatie-types
            im: "Informatiemodel",
            hl: "Handleiding",
            rp: "Rapport",
        },
        en: {
            // Specificatie-statussen	
            cv: "Consultation",
            vv: "Proposed recommendation",
            ig: "In use",
	        io: "In development",
            // Specificatie-types
            im: "Information model",
            hl: "Guideline",
            rp: "Report",
        },
    },

    sotdText: {
        nl: {
            sotd: "Status van dit document",
            cv: `Dit is een goedgekeurde consultatieversie. Commentaar over dit document kan gestuurd worden naar `,
            vv: `Dit is een definitief concept van de nieuwe versie van dit document. Wijzigingen naar aanleiding van consultaties zijn doorgevoerd.`,
	        ig: "Dit document is 'In Gebruik'.",
	        io: "Dit document is nog 'In Ontwikkeling'.",
        },
        en: {
            sotd: "Status of This Document",
            cv: `This is a proposed recommendation approved by TO. Comments regarding this document may be sent to `,
            vv: `This is the definitive concept of this document. Edits resulting from consultations have been applied.`,
	        ig: "This document is 'In Use'.",
            io: "This document is is still 'Under Development'.",
        },
    },

    labelColor: {
       cv: "#154273",
       vv: "#39870c",
	   ig: "#A569BD",
	   io: "#DC7633"
    },
	
    licenses: {
        "cc0": {
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
    
    lint: {
	    "a11y": true,
	    "check-punctuation": false,
	    "informative-dfn": false,
	    "local-refs-exist": true,
	    "no-captionless-tables": true,
	    "no-headingless-sections": true,
	    "no-http-props": true,
	    "no-unused-dfns": true,
	    "no-unused-vars": true,
	    "privsec-section": false,
	    "wpt-tests-exist": false
	}
}