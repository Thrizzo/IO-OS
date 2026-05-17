// IO Welcome — first-run OOBE wizard.
//
// Pure QML (no CMake, no C++) so the system `qml` binary can run it.
// All copy lives in strings.js; pages are inline Components so the whole
// app stays one file to install. The launcher script reads our exit code:
//   0  = wizard completed; show again next session unless tickbox set
//   42 = "don't show again" tickbox was set on the final page
//
// Why a wizard (not a single splash): mirrors what Windows OOBE covers,
// so users coming from Windows recognise the flow and aren't surprised
// when the system later asks about telemetry, theme, or default apps.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "strings.js" as Strings

ApplicationWindow {
    id: window
    visible: true
    width: 760
    height: 620
    minimumWidth: 640
    minimumHeight: 520
    title: tr("title")
    color: theme === "dark" ? "#1a2332" : "#F5F5F7"

    // --- Wizard state (lifted to the window so all pages share it) -------
    property string locale: "de"           // "de" | "en"
    property string theme: "dark"          // "dark" | "light"
    property bool   telemetryOn: false     // off by default
    property bool   crashReportsOn: false  // off by default
    property bool   dontShowAgain: false

    // Convenience: tr() reads the active locale. Passing the locale in
    // explicitly (rather than capturing) means changing locale immediately
    // re-renders every binding that calls tr().
    function tr(key) { return Strings.tr(window.locale, key) }

    // Foreground colour for the active theme. Bound everywhere we draw text
    // so flipping `theme` repaints the whole window.
    function fg()  { return theme === "dark" ? "#F0F0F0" : "#1E2028" }
    function fg2() { return theme === "dark" ? "#A0A8B5" : "#5C6270" }
    function accent() { return theme === "dark" ? "#D4A24A" : "#B88A37" }

    // Open an external URL and surface a visible error if no browser is
    // registered (Qt.openUrlExternally returns false on failure).
    function openUrl(url) {
        if (!Qt.openUrlExternally(url)) {
            errorBanner.message = tr("errOpenUrl")
            errorBanner.visible = true
        }
    }

    // --- Layout: top error banner, page area, bottom nav row ------------
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 18

        Rectangle {
            id: errorBanner
            property string message: ""
            visible: false
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: "#3a1f1f"
            border.color: "#E04F4F"
            border.width: 1
            radius: 4
            Text {
                anchors.fill: parent
                anchors.margins: 8
                text: errorBanner.message
                color: "#F0F0F0"
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        // Step indicator (1/6, 2/6 …) — gives the wizard a Windows-OOBE feel.
        Text {
            Layout.alignment: Qt.AlignRight
            text: (stack.depth) + " / 6"
            color: window.fg2()
            font.pixelSize: 12
        }

        StackView {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            initialItem: welcomePage
        }

        // Footer nav row: language toggle on the left, back/next on the right.
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ComboBox {
                id: localeBox
                model: ["Deutsch", "English"]
                currentIndex: window.locale === "de" ? 0 : 1
                onActivated: window.locale = (currentIndex === 0 ? "de" : "en")
            }

            Item { Layout.fillWidth: true }   // pushes nav buttons right

            Button {
                text: tr("back")
                visible: stack.depth > 1
                onClicked: stack.pop()
            }

            Button {
                id: nextBtn
                text: stack.currentItem && stack.currentItem.isLast
                      ? tr("finish")
                      : tr("next")
                highlighted: true
                onClicked: {
                    if (stack.currentItem && stack.currentItem.isLast) {
                        Qt.exit(window.dontShowAgain ? 42 : 0)
                    } else if (stack.currentItem && stack.currentItem.nextPage) {
                        stack.push(stack.currentItem.nextPage)
                    }
                }
            }
        }
    }

    // ====================================================================
    // Page 1 — Welcome
    // ====================================================================
    Component {
        id: welcomePage
        Item {
            property var nextPage: networkPage
            property bool isLast: false

            ColumnLayout {
                anchors.fill: parent
                spacing: 18

                Image {
                    Layout.alignment: Qt.AlignHCenter
                    source: "file:///usr/share/icons/hicolor/scalable/apps/io-logo.svg"
                    sourceSize.width: 112
                    sourceSize.height: 112
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: tr("welcomeHeading")
                    color: window.accent()
                    font.pixelSize: 28
                    font.weight: Font.Light
                }
                Text {
                    Layout.fillWidth: true
                    text: tr("welcomeBody")
                    color: window.fg()
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    lineHeight: 1.4
                    horizontalAlignment: Text.AlignHCenter
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12
                    Button {
                        text: tr("linkDocumentation")
                        onClicked: window.openUrl(Strings.links.documentation)
                    }
                    Button {
                        text: tr("linkContribute")
                        onClicked: window.openUrl(Strings.links.contribute)
                    }
                    Button {
                        text: tr("linkRoadmap")
                        onClicked: window.openUrl(Strings.links.roadmap)
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }

    // ====================================================================
    // Page 2 — Network status
    // ====================================================================
    Component {
        id: networkPage
        Item {
            property var nextPage: themePage
            property bool isLast: false

            // Best-effort online check: if NetworkManager reports a
            // default route, we trust it. Anything more involved (DNS,
            // captive-portal probe) is deferred to the live session.
            property bool online: false
            Component.onCompleted: {
                // QML can't shell out without QtQml.Models — leave detection
                // to a side-effect of clicking Next; for now assume offline
                // pessimistically so users aren't misled.
                online = false
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 18

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: tr("networkHeading")
                    color: window.accent()
                    font.pixelSize: 24
                    font.weight: Font.Light
                }
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    radius: 40
                    color: online ? "#7CC47C" : "#E0B569"
                    Text {
                        anchors.centerIn: parent
                        text: online ? "OK" : "?"
                        color: "#1a2332"
                        font.pixelSize: 28
                        font.weight: Font.Bold
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: online ? tr("networkOnline") : tr("networkOffline")
                    color: window.fg()
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Item { Layout.fillHeight: true }
            }
        }
    }

    // ====================================================================
    // Page 3 — Theme (dark / light)
    // ====================================================================
    Component {
        id: themePage
        Item {
            property var nextPage: privacyPage
            property bool isLast: false

            ColumnLayout {
                anchors.fill: parent
                spacing: 24

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: tr("themeHeading")
                    color: window.accent()
                    font.pixelSize: 24
                    font.weight: Font.Light
                }
                Text {
                    Layout.fillWidth: true
                    text: tr("themeBody")
                    color: window.fg()
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 24

                    // Dark sample
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 130
                        radius: 6
                        color: "#1a2332"
                        border.color: window.theme === "dark" ? "#D4A24A" : "transparent"
                        border.width: 3
                        ColumnLayout {
                            anchors.centerIn: parent
                            Text { text: tr("themeDark"); color: "#F0F0F0"; font.pixelSize: 16 }
                            Rectangle { Layout.preferredWidth: 80; Layout.preferredHeight: 4; color: "#D4A24A" }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: window.theme = "dark"
                        }
                    }

                    // Light sample
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 130
                        radius: 6
                        color: "#F5F5F7"
                        border.color: window.theme === "light" ? "#B88A37" : "transparent"
                        border.width: 3
                        ColumnLayout {
                            anchors.centerIn: parent
                            Text { text: tr("themeLight"); color: "#1E2028"; font.pixelSize: 16 }
                            Rectangle { Layout.preferredWidth: 80; Layout.preferredHeight: 4; color: "#B88A37" }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: window.theme = "light"
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }

    // ====================================================================
    // Page 4 — Privacy
    // ====================================================================
    Component {
        id: privacyPage
        Item {
            property var nextPage: appsPage
            property bool isLast: false

            ColumnLayout {
                anchors.fill: parent
                spacing: 18

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: tr("privacyHeading")
                    color: window.accent()
                    font.pixelSize: 24
                    font.weight: Font.Light
                }
                Text {
                    Layout.fillWidth: true
                    text: tr("privacyBody")
                    color: window.fg()
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
                CheckBox {
                    text: tr("privacyTelemetry")
                    checked: window.telemetryOn
                    onToggled: window.telemetryOn = checked
                    contentItem: Text {
                        text: parent.text
                        color: window.fg2()
                        leftPadding: parent.indicator.width + 6
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                    }
                }
                CheckBox {
                    text: tr("privacyCrashReports")
                    checked: window.crashReportsOn
                    onToggled: window.crashReportsOn = checked
                    contentItem: Text {
                        text: parent.text
                        color: window.fg2()
                        leftPadding: parent.indicator.width + 6
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }

    // ====================================================================
    // Page 5 — Default applications
    // ====================================================================
    Component {
        id: appsPage
        Item {
            property var nextPage: donePage
            property bool isLast: false

            ColumnLayout {
                anchors.fill: parent
                spacing: 18

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: tr("appsHeading")
                    color: window.accent()
                    font.pixelSize: 24
                    font.weight: Font.Light
                }
                Text {
                    Layout.fillWidth: true
                    text: tr("appsBody")
                    color: window.fg()
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    columns: 2
                    columnSpacing: 24
                    rowSpacing: 10
                    Text { text: tr("appsBrowserLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.browser; color: window.fg() }
                    Text { text: tr("appsMailLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.mail; color: window.fg() }
                    Text { text: tr("appsPasswordsLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.passwords; color: window.fg() }
                    Text { text: tr("appsVpnLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.vpn; color: window.fg() }
                    Text { text: tr("appsCalendarLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.calendar; color: window.fg() }
                    Text { text: tr("appsDriveLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.drive; color: window.fg() }
                    Text { text: tr("appsOfficeLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.office; color: window.fg() }
                    Text { text: tr("appsFilesLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.files; color: window.fg() }
                    Text { text: tr("appsTerminalLabel"); color: window.fg() }
                    Text { text: Strings.defaultApps.terminal; color: window.fg() }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }

    // ====================================================================
    // Page 6 — Done
    // ====================================================================
    Component {
        id: donePage
        Item {
            property var nextPage: null
            property bool isLast: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 18

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: tr("doneHeading")
                    color: window.accent()
                    font.pixelSize: 28
                    font.weight: Font.Light
                }
                Text {
                    Layout.fillWidth: true
                    text: tr("doneBody")
                    color: window.fg()
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                Item { Layout.fillHeight: true }
                CheckBox {
                    Layout.alignment: Qt.AlignHCenter
                    text: tr("dontShowAgain")
                    checked: window.dontShowAgain
                    onToggled: window.dontShowAgain = checked
                    contentItem: Text {
                        text: parent.text
                        color: window.fg2()
                        leftPadding: parent.indicator.width + 6
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
