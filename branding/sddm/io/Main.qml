// IO Linux SDDM login theme.
// Minimum-viable: backdrop, user dropdown, password field, session selector,
// language toggle, login button. Validated against Plasma 6 / SDDM 0.21 API.
//
// Known gap: this is alpha QML. Expect to iterate after first boot — there
// is no substitute for testing against a real SDDM greeter session.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.PrimaryColor || "#1a2332"

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
            placeholderText: qsTr("Passwort / Password")
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
                currentIndex: 0
            }

            Button {
                id: loginButton
                text: qsTr("Anmelden / Sign in")
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
            errorText.text = qsTr("Anmeldung fehlgeschlagen / Login failed")
        }
        function onLoginSucceeded() {
            errorText.text = ""
        }
    }
}
