import Quickshell
import QtQuick

Column {
    spacing: 14

    // =========================================================
    // BRAVE
    // =========================================================

    Item {
        width: 36
        height: 36
    
        HoverHandler {
            id: braveHover
        }
    
        Text {
            anchors.centerIn: parent
    
            text: ""
            color:
                braveHover.hovered
                ? "#33ccff"
                : "#e6edf3"
    
            font.pixelSize: 20
    
            scale:
                braveMouse.pressed
                ? 0.9
                : braveHover.hovered
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
            id: braveMouse
    
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
    
            onClicked: {
                Quickshell.execDetached(["brave"])
            }
        }
    }

    // =========================================================
    // STEAM
    // =========================================================

    Item {
        width: 36
        height: 36

        HoverHandler {
            id: steamHover
        }

        Text {
            anchors.centerIn: parent

            text: ""
            color:
                steamHover.hovered
                ? "#33ccff"
                : "#e6edf3"

            font.pixelSize: 20

            scale:
                    steamMouse.pressed
                    ? 0.9
                    : steamHover.hovered
                        ? 1.2
                        : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: steamMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                Quickshell.execDetached(["steam"])
            }
        }
    }

    // =========================================================
    // DISCORD
    // =========================================================

    Item {
        width: 36
        height: 36

        HoverHandler {
            id: discordHover
        }

        Text {
            anchors.centerIn: parent

            text: "󰙯"
            color:
                discordHover.hovered
                ? "#33ccff"
                : "#e6edf3"

            font.pixelSize: 20

            scale:
                   discordMouse.pressed
                   ? 0.9
                   : discordHover.hovered
                     ? 1.2
                     : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: discordMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                Quickshell.execDetached(["discord"])
            }
        }
    }
}
