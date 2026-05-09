// IO Linux SDDM login theme.
// Minimum-viable: backdrop, user dropdown, password field, session selector,
// language toggle, login button. Validated against Plasma 6 / SDDM 0.21 API.
//
// Locale-switch caveat: SDDM 0.21 does not expose a public API for a theme
// to change the *user session's* locale (LANG / LC_*). What we can do is
// re-render the greeter strings live; the actual session locale is decided
// at install time by Calamares and at runtime by the user's `~/.dmrc` /
// `~/.config/plasma-localerc`. When SDDM exposes a locale API upstream
// we'll wire this combo to it; for now the toggle is honest about its
// scope (login screen text only).

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.PrimaryColor || "#1a2332"

    // "de" or "en". Defaults to whichever ships first in the locale list.
    property string locale: "de"

    // Tiny helper so every translated string lives in one place. Keeps the
    // signature symmetric with packages/io-welcome (window.tr()).
    function tr(de, en) { return locale === "de" ? de : en }

    // Backdrop wallpaper.
    Image {
        anchors.fill: parent
        source: config.background || "background.svg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Subtle dark veil so text stays legible over the wallpaper.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#001a2332" }
            GradientStop { position: 1.0; color: "#cc1a2332" }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 18
        width: 360

        Text {
            text: "IO Linux"
            color: config.AccentColor || "#D4A24A"
            font.pixelSize: 56
            font.weight: Font.Light
            Layout.alignment: Qt.AlignHCenter
        }

        ComboBox {
            id: userBox
            Layout.fillWidth: true
            model: userModel
            textRole: "name"
            currentIndex: userModel.lastIndex
        }

        TextField {
            id: passwordBox
            Layout.fillWidth: true
            echoMode: TextInput.Password
            placeholderText: tr("Passwort", "Password")
            color: config.TextColor || "#F0F0F0"
            Keys.onReturnPressed: tryLogin()
        }

        ComboBox {
            id: sessionBox
            Layout.fillWidth: true
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ComboBox {
                id: langBox
                visible: config.ShowLanguages !== "false"
                Layout.fillWidth: true
                model: ["Deutsch", "English"]
                currentIndex: root.locale === "de" ? 0 : 1
                // Live-switch every translated string in the greeter.
                onActivated: root.locale = (currentIndex === 0 ? "de" : "en")
            }

            Button {
                id: loginButton
                text: tr("Anmelden", "Sign in")
                Layout.fillWidth: true
                onClicked: tryLogin()
            }
        }

        Text {
            id: errorText
            color: "#E04F4F"
            text: ""
            font.pixelSize: 13
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            visible: text.length > 0
        }
    }

    function tryLogin() {
        sddm.login(userBox.currentText, passwordBox.text, sessionBox.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passwordBox.text = ""
            errorText.text = tr("Anmeldung fehlgeschlagen", "Login failed")
        }
        function onLoginSucceeded() {
            errorText.text = ""
        }
    }
}
