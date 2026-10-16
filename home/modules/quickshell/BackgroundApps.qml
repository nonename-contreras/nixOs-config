import QtQuick
import Quickshell

Item {
    implicitWidth: button.width
    implicitHeight: button.height

    Rectangle {
        id: button

        width: 32
        height: 24
        radius: 4

        color: mouseArea.pressed
            ? "#16343d"
            : mouseArea.containsMouse
                ? "#102a30"
                : "transparent"

        border.width: mouseArea.containsMouse ? 1 : 0
        border.color: "#33ccff"

        Text {
            anchors.centerIn: parent

            text: "󰣇"
            color: mouseArea.containsMouse
                ? "#66d9ff"
                : "#e6edf3"
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                Quickshell.execDetached([
                    "kitty",
                    "--class",
                    "background-apps",
                    "/home/nonename/.local/bin/background-apps"
                ])
            }
        }
    }
}
