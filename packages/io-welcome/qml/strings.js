// IO Welcome — externalised strings.
//
// Two locales today (de/en). Adding a third is just adding a new top-level
// key plus its translations; the QML side picks one via locale().
//
// Long-term migration target: Qt Linguist .ts files compiled to .qm and
// loaded via QTranslator. See packages/io-welcome/i18n/ for the .ts stubs
// kept in lockstep with this file. The two paths exist in parallel so
// translators can contribute today without waiting on lupdate/lrelease
// being wired through the build.

.pragma library

var strings = {
    de: {
        // Window chrome
        title: "IO Linux — Erste Schritte",

        // Welcome / intro page
        welcomeHeading: "Willkommen bei IO Linux",
        welcomeBody:
            "IO Linux ist eine souveräne europäische Linux-Distribution, " +
            "basierend auf openSUSE Kalpa, mit einer für Windows-Anwender:innen " +
            "vertrauten Oberfläche.\n\n" +
            "Dieses System ist v0.1 Alpha. Bitte nicht produktiv einsetzen.",

        // Network page
        networkHeading: "Netzwerk",
        networkOnline: "Verbunden — alles bereit.",
        networkOffline:
            "Aktuell offline. Du kannst trotzdem fortfahren; Updates und " +
            "Flatpaks holen wir später nach.",

        // Theme page
        themeHeading: "Design",
        themeBody: "Dunkles oder helles Erscheinungsbild?",
        themeDark: "Dunkel",
        themeLight: "Hell",

        // Privacy page
        privacyHeading: "Privatsphäre",
        privacyBody:
            "IO Linux sammelt keine Telemetriedaten — weder anonym noch " +
            "anders. Diese Seite hält die Versprechen explizit fest, damit " +
            "spätere Versionen nicht stillschweigend etwas einführen.",
        privacyTelemetry: "Anonyme Telemetrie senden (nicht implementiert)",
        privacyCrashReports: "Absturzberichte senden (nicht implementiert)",

        // Default-app page
        appsHeading: "Standardprogramme",
        appsBody:
            "Diese Programme öffnen Dateien und Links, bis du es änderst:",
        appsBrowserLabel: "Browser",
        appsMailLabel: "E-Mail",
        appsFilesLabel: "Dateien",
        appsTerminalLabel: "Terminal",

        // Done page
        doneHeading: "Fertig.",
        doneBody:
            "Viel Erfolg mit IO Linux. Klick unten weiter, um auf den " +
            "Desktop zu gelangen.",

        // Buttons
        next: "Weiter",
        back: "Zurück",
        finish: "Fertigstellen",
        skip: "Überspringen",

        // Footer
        dontShowAgain: "Beim nächsten Start nicht mehr anzeigen",

        // External links (kept here so forks change one place)
        linkDocumentation: "Dokumentation",
        linkContribute: "Mitwirken",
        linkRoadmap: "Roadmap",

        // Errors
        errOpenUrl: "Konnte URL nicht öffnen — kein Standardbrowser installiert?"
    },
    en: {
        title: "IO Linux — Getting Started",

        welcomeHeading: "Welcome to IO Linux",
        welcomeBody:
            "IO Linux is a sovereign European Linux distribution, based on " +
            "openSUSE Kalpa, with a desktop layout familiar to Windows users.\n\n" +
            "This system is v0.1 alpha. Please do not use in production.",

        networkHeading: "Network",
        networkOnline: "Connected — you're all set.",
        networkOffline:
            "Currently offline. You can still continue; updates and " +
            "Flatpaks will catch up later.",

        themeHeading: "Appearance",
        themeBody: "Prefer a dark or light look?",
        themeDark: "Dark",
        themeLight: "Light",

        privacyHeading: "Privacy",
        privacyBody:
            "IO Linux collects no telemetry — anonymous or otherwise. This " +
            "page records that promise explicitly so future versions can't " +
            "quietly introduce anything.",
        privacyTelemetry: "Send anonymous telemetry (not implemented)",
        privacyCrashReports: "Send crash reports (not implemented)",

        appsHeading: "Default applications",
        appsBody: "These apps open files and links until you change them:",
        appsBrowserLabel: "Browser",
        appsMailLabel: "Mail",
        appsFilesLabel: "Files",
        appsTerminalLabel: "Terminal",

        doneHeading: "All done.",
        doneBody:
            "Have fun with IO Linux. Click below to land on the desktop.",

        next: "Next",
        back: "Back",
        finish: "Finish",
        skip: "Skip",

        dontShowAgain: "Don't show on next start",

        linkDocumentation: "Documentation",
        linkContribute: "Contribute",
        linkRoadmap: "Roadmap",

        errOpenUrl: "Could not open URL — no default browser installed?"
    }
};

// Resolve a key against the active locale, falling back to English so a
// missing translation never crashes the UI.
function tr(locale, key) {
    var bundle = strings[locale] || strings.en;
    return bundle[key] !== undefined ? bundle[key] : (strings.en[key] || key);
}

// Suggested defaults for the apps page. Kept here (not in QML) so a fork
// can change the picks without touching code.
var defaultApps = {
    browser:  "firefox",
    mail:     "thunderbird",
    files:    "dolphin",
    terminal: "konsole"
};

// External links for the docs row on the welcome page.
var links = {
    documentation: "https://github.com/thrizzo/io-os",
    contribute:    "https://github.com/thrizzo/io-os/blob/main/CONTRIBUTING.md",
    roadmap:       "https://github.com/thrizzo/io-os/blob/main/docs/roadmap.md"
};
