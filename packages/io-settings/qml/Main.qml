// IO Settings — Win11-Settings-shaped front-end over Plasma KCM modules.
//
// The point of this app is not to reimplement Plasma's System Settings,
// but to give Windows migrants a familiar two-pane layout:
//   - left:  category list (System, Devices, Network, Personalization,
//            Apps, Accounts, Privacy & Security, Update & Recovery)
//   - right: a grid of module tiles that open the underlying KCM via
//            `kcmshell6` (or the kcm:// URL handler).
//
// Categories + modules are defined entirely in categories.js so adding
// a new entry is a one-line edit. No QML changes required.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "categories.js" as Cats

ApplicationWindow {
    id: window
    visible: true
    width: 1080
    height: 720
    minimumWidth: 880
    minimumHeight: 600
    title: locale === "de" ? "IO Einstellungen" : "IO Settings"
    color: "#1a2332"

    property string locale: Qt.locale().name.indexOf("de") === 0 ? "de" : "en"
    property int activeCategory: 0
    property string filter: ""

    function fg()  { return "#F0F0F0" }
    function fg2() { return "#A0A8B5" }
    function accent() { return "#D4A24A" }
    function surface() { return "#243047" }
    function surfaceHi() { return "#2e3d56" }

    // Run a KCM in its own window. Prefer kcmshell6; fall back to
    // kcm:// which Plasma's URL handler resolves.
    function runKcm(kcm) {
        var ok = Qt.openUrlExternally("file:///usr/bin/kcmshell6")  // dummy
        // Real invocation: spawn kcmshell6 via Qt.openUrlExternally
        // with the kcm:// scheme. KIO routes that through systemsettings.
        Qt.openUrlExternally("kcm://" + kcm)
    }

    function localized(m, field) {
        return locale === "de" ? m["de"] : m["en"]
    }

    function categoryLabel(c) { return locale === "de" ? c.labelDe : c.labelEn }
    function categoryDesc(c)  { return locale === "de" ? c.descDe  : c.descEn  }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // ---------- Left pane: category list ----------
        Rectangle {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: window.surface()

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text {
                    text: locale === "de" ? "Einstellungen" : "Settings"
                    color: window.accent()
                    font.pixelSize: 22
                    font.weight: Font.Light
                    Layout.bottomMargin: 12
                }

                TextField {
                    Layout.fillWidth: true
                    placeholderText: locale === "de" ? "Suchen…" : "Search…"
                    color: window.fg()
                    onTextChanged: window.filter = text.toLowerCase()
                    background: Rectangle {
                        color: window.surfaceHi()
                        radius: 4
                        border.color: parent.activeFocus ? window.accent() : "transparent"
                        border.width: 1
                    }
                }

                ListView {
                    id: catList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 12
                    spacing: 2
                    clip: true
                    model: Cats.categories
                    currentIndex: window.activeCategory

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 56
                        radius: 4
                        color: index === window.activeCategory
                               ? window.surfaceHi()
                               : (hovered.containsMouse ? Qt.rgba(1,1,1,0.04) : "transparent")
                        MouseArea {
                            id: hovered
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: window.activeCategory = index
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12
                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 4
                                color: index === window.activeCategory ? window.accent() : "transparent"
                                border.color: window.accent()
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: window.categoryLabel(modelData).charAt(0)
                                    color: index === window.activeCategory ? "#1a2332" : window.accent()
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }
                            ColumnLayout {
                                spacing: 2
                                Text {
                                    text: window.categoryLabel(modelData)
                                    color: window.fg()
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: window.categoryDesc(modelData)
                                    color: window.fg2()
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---------- Right pane: module tiles ----------
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                Text {
                    text: Cats.categories[window.activeCategory]
                          ? window.categoryLabel(Cats.categories[window.activeCategory])
                          : ""
                    color: window.accent()
                    font.pixelSize: 28
                    font.weight: Font.Light
                }
                Text {
                    text: Cats.categories[window.activeCategory]
                          ? window.categoryDesc(Cats.categories[window.activeCategory])
                          : ""
                    color: window.fg2()
                    font.pixelSize: 13
                    Layout.bottomMargin: 8
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: tileGrid.height
                    clip: true

                    GridLayout {
                        id: tileGrid
                        width: parent.width
                        columns: Math.max(1, Math.floor(parent.width / 280))
                        columnSpacing: 16
                        rowSpacing: 16

                        Repeater {
                            model: {
                                var c = Cats.categories[window.activeCategory]
                                if (!c) return []
                                if (!window.filter) return c.modules
                                return c.modules.filter(function(m) {
                                    var label = window.localized(m).toLowerCase()
                                    return label.indexOf(window.filter) !== -1
                                })
                            }

                            Rectangle {
                                Layout.preferredWidth: 260
                                Layout.preferredHeight: 88
                                Layout.fillWidth: true
                                radius: 6
                                color: tileHover.containsMouse
                                       ? window.surfaceHi()
                                       : window.surface()
                                border.color: tileHover.containsMouse ? window.accent() : "transparent"
                                border.width: 1

                                MouseArea {
                                    id: tileHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: window.runKcm(modelData.kcm)
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 14
                                    Rectangle {
                                        Layout.preferredWidth: 44
                                        Layout.preferredHeight: 44
                                        radius: 22
                                        color: window.accent()
                                        Text {
                                            anchors.centerIn: parent
                                            text: window.localized(modelData).charAt(0)
                                            color: "#1a2332"
                                            font.pixelSize: 20
                                            font.weight: Font.Bold
                                        }
                                    }
                                    ColumnLayout {
                                        spacing: 4
                                        Text {
                                            text: window.localized(modelData)
                                            color: window.fg()
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: "kcm:" + modelData.kcm.replace("kcm_", "")
                                            color: window.fg2()
                                            font.pixelSize: 10
                                            font.family: "JetBrains Mono"
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
