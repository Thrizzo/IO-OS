// IO Settings — category map.
//
// Each entry is one Win11-Settings-shaped row. The KCM module name is
// what `kcmshell6` accepts as its argument; the icon is a freedesktop
// icon name (Breeze ships them all). Adding a new row is a one-line
// edit — no QML change required.
//
// Grouping mirrors Windows 11 Settings categories so users find things
// where they expect.

.pragma library

var categories = [
    {
        id: "system",
        icon: "preferences-system",
        labelDe: "System",
        labelEn: "System",
        descDe: "Display, Ton, Benachrichtigungen, Energie, Speicher",
        descEn: "Display, sound, notifications, power, storage",
        modules: [
            { kcm: "kcm_kscreen",            iconHint: "video-display",       de: "Anzeige",          en: "Display" },
            { kcm: "kcm_pulseaudio",         iconHint: "audio-volume-high",   de: "Ton",              en: "Sound" },
            { kcm: "kcm_notifications",      iconHint: "preferences-desktop-notification", de: "Benachrichtigungen", en: "Notifications" },
            { kcm: "kcm_powerdevilprofilesconfig", iconHint: "battery",       de: "Energie",          en: "Power" },
            { kcm: "kcm_filetypes",          iconHint: "preferences-desktop-filetype-association", de: "Dateitypen", en: "File associations" }
        ]
    },
    {
        id: "devices",
        icon: "preferences-desktop-peripherals",
        labelDe: "Geräte",
        labelEn: "Devices",
        descDe: "Bluetooth, Drucker, Maus, Tastatur, Touchpad",
        descEn: "Bluetooth, printers, mouse, keyboard, touchpad",
        modules: [
            { kcm: "kcm_bluetooth",          iconHint: "preferences-system-bluetooth", de: "Bluetooth", en: "Bluetooth" },
            { kcm: "kcm_printer_manager",    iconHint: "preferences-system-printer",   de: "Drucker",   en: "Printers" },
            { kcm: "kcm_mouse",              iconHint: "input-mouse",                  de: "Maus",      en: "Mouse" },
            { kcm: "kcm_keyboard",           iconHint: "input-keyboard",               de: "Tastatur",  en: "Keyboard" },
            { kcm: "kcm_touchpad",           iconHint: "input-touchpad",               de: "Touchpad",  en: "Touchpad" }
        ]
    },
    {
        id: "network",
        icon: "preferences-system-network",
        labelDe: "Netzwerk & Internet",
        labelEn: "Network & Internet",
        descDe: "WLAN, Ethernet, VPN, Proxy, DNS",
        descEn: "Wi-Fi, Ethernet, VPN, proxy, DNS",
        modules: [
            { kcm: "kcm_networkmanagement",  iconHint: "preferences-system-network",   de: "Netzwerkverbindungen", en: "Network connections" },
            { kcm: "kcm_proxy",              iconHint: "preferences-system-network",   de: "Proxy",                en: "Proxy" }
        ]
    },
    {
        id: "personalization",
        icon: "preferences-desktop-theme",
        labelDe: "Personalisierung",
        labelEn: "Personalization",
        descDe: "Hintergrund, Farbschemen, Schriftarten, Anwendungs-Stil",
        descEn: "Background, color schemes, fonts, application style",
        modules: [
            { kcm: "kcm_lookandfeel",        iconHint: "preferences-desktop-theme",    de: "Global Theme",  en: "Global Theme" },
            { kcm: "kcm_colors",             iconHint: "preferences-desktop-color",    de: "Farben",        en: "Colors" },
            { kcm: "kcm_wallpaper",          iconHint: "preferences-desktop-wallpaper", de: "Hintergrund",   en: "Wallpaper" },
            { kcm: "kcm_fonts",              iconHint: "preferences-desktop-font",     de: "Schriften",     en: "Fonts" },
            { kcm: "kcm_style",              iconHint: "preferences-desktop-theme",    de: "Anwendungs-Stil", en: "Application Style" }
        ]
    },
    {
        id: "apps",
        icon: "applications-other",
        labelDe: "Anwendungen",
        labelEn: "Apps",
        descDe: "Standardprogramme, Autostart, Installierte Software",
        descEn: "Default apps, startup, installed software",
        modules: [
            { kcm: "kcm_componentchooser",   iconHint: "applications-other",           de: "Standardprogramme", en: "Default applications" },
            { kcm: "kcm_autostart",          iconHint: "system-run",                   de: "Autostart",         en: "Startup" }
        ]
    },
    {
        id: "accounts",
        icon: "user-identity",
        labelDe: "Konten",
        labelEn: "Accounts",
        descDe: "Benutzer, SDDM, Anmeldung",
        descEn: "Users, SDDM, sign-in",
        modules: [
            { kcm: "kcm_users",              iconHint: "user-identity",                de: "Benutzer",    en: "Users" },
            { kcm: "kcm_sddm",               iconHint: "preferences-desktop-display",  de: "Anmeldebildschirm", en: "Login screen" }
        ]
    },
    {
        id: "privacy",
        icon: "security-high",
        labelDe: "Datenschutz & Sicherheit",
        labelEn: "Privacy & Security",
        descDe: "Sperrbildschirm, Firewall, AppArmor, Berechtigungen",
        descEn: "Lock screen, firewall, AppArmor, permissions",
        modules: [
            { kcm: "kcm_screenlocker",       iconHint: "system-lock-screen",           de: "Sperrbildschirm",  en: "Lock screen" },
            { kcm: "kcm_activities",         iconHint: "preferences-activities",        de: "Aktivitäten",      en: "Activities" },
            { kcm: "kcm_clipboard",          iconHint: "edit-paste",                    de: "Zwischenablage",   en: "Clipboard" }
        ]
    },
    {
        id: "update",
        icon: "system-software-update",
        labelDe: "Update & Wiederherstellung",
        labelEn: "Update & Recovery",
        descDe: "Snapshots (Snapper), transaktionale Updates",
        descEn: "Snapshots (Snapper), transactional updates",
        modules: [
            { kcm: "kcm_snapshots",          iconHint: "system-software-update",        de: "Snapshots",          en: "Snapshots" },
            { kcm: "kcm_about-distro",       iconHint: "help-about",                    de: "Über das System",    en: "About this system" }
        ]
    }
];

function launchKcm(kcmName) {
    Qt.openUrlExternally("kcm://" + kcmName);
}
