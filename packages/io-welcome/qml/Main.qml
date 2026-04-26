// IO Welcome — first-run greeting.
//
// Pure QML so we can run it via the `qml` binary that ships with the
// Plasma 6 Qt6 stack — no CMake, no C++, no RPM spec required for v0.1.
// Persisting the "don't show again" preference is delegated to the
// launcher script via process exit code (42 = user opted out).

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    visible: true
    width: 720
    height: 580
    minimumWidth: 600
    minimumHeight: 480
    title: "IO Welcome"
    color: "#1a2332"

    property bool german: true
    function t(de, en) { return german ? de : en }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 36
        spacing: 24

        // --- Header: logo + title ---
        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "file:///usr/share/icons/hicolor/scalable/apps/io-logo.svg"
            sourceSize.width: 128
            sourceSize.height: 128
            fillMode: Image.PreserveAspectFit
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: window.t("Willkommen bei IO Linux", "Welcome to IO Linux")
            color: "#D4A24A"
            font.pixelSize: 30
            font.weight: Font.Light
        }

        // --- Body copy ---
        Text {
            Layout.fillWidth: true
            text: window.t(
                "IO Linux ist eine souveräne europäische Linux-Distribution, " +
                "basierend auf openSUSE Kalpa, mit einer für Windows-Anwender:innen " +
                "vertrauten Oberfläche.\n\n" +
                "Dieses System ist v0.1 Alpha. Bitte nicht produktiv einsetzen.",
                "IO Linux is a sovereign European Linux distribution, based on " +
                "openSUSE Kalpa, with a desktop layout familiar to Windows users.\n\n" +
                "This system is v0.1 alpha. Please do not use in production."
            )
            color: "#F0F0F0"
            wrapMode: Text.WordWrap
            font.pixelSize: 14
            lineHeight: 1.4
            horizontalAlignment: Text.AlignHCenter
        }

        // --- Action buttons: documentation links ---
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Button {
                text: window.t("Dokumentation", "Documentation")
                onClicked: Qt.openUrlExternally("https://github.com/thrizzo/io-os")
            }
            Button {
                text: window.t("Mitwirken", "Contribute")
                onClicked: Qt.openUrlExternally(
                    "https://github.com/thrizzo/io-os/blob/main/CONTRIBUTING.md")
            }
            Button {
                text: window.t("Roadmap", "Roadmap")
                onClicked: Qt.openUrlExternally(
                    "https://github.com/thrizzo/io-os/blob/main/docs/roadmap.md")
            }
        }

        Item { Layout.fillHeight: true }   // spacer pushes footer to bottom

        // --- Footer: don't-show-again + language toggle + close ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            CheckBox {
                id: dontShow
                Layout.alignment: Qt.AlignHCenter
                text: window.t(
                    "Beim nächsten Start nicht mehr anzeigen",
                    "Don't show on next start")
                contentItem: Text {
                    text: dontShow.text
                    color: "#A0A8B5"
                    font.pixelSize: 13
                    leftPadding: dontShow.indicator.width + 6
                    verticalAlignment: Text.AlignVCenter
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Button {
                    text: "Deutsch"
                    checkable: true
                    checked: window.german
                    onClicked: window.german = true
                }
                Button {
                    text: "English"
                    checkable: true
                    checked: !window.german
                    onClicked: window.german = false
                }
                Button {
                    text: window.t("Schließen", "Close")
                    highlighted: true
                    // Exit code 42 tells the launcher to record the opt-out.
                    onClicked: Qt.exit(dontShow.checked ? 42 : 0)
                }
            }
        }
    }
}
