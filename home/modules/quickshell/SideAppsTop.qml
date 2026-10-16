import Quickshell
import QtQuick

Column {
    spacing: 14

    Item {
        width: 36
        height: 36

        HoverHandler {
            id: vscodeHover
        }

        Text {
            anchors.centerIn: parent

            text: "󰨞"
            color: vscodeHover.hovered ? "#33ccff" : "#e6edf3"

            font.pixelSize: 20

            scale:
                vscodeMouse.pressed
                ? 0.9
                : vscodeHover.hovered
                ? 1.2
                : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 90
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: vscodeMouse

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                Quickshell.execDetached(["code"])
            }
        }
    }
}
