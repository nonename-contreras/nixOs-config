import QtQuick
import Quickshell

Item {
    id: root

    implicitWidth: clockButton.width
    implicitHeight: 28

    property bool popupOpen: false
    property var popupWindow: null

    Rectangle {
        id: clockButton

        anchors.verticalCenter: parent.verticalCenter

        width: clockText.implicitWidth + 16
        height: 26

        radius: 6

        color: mouseArea.pressed
            ? "#1f6feb"
            : popupOpen
                ? "#16324a"
                : mouseArea.containsMouse
                    ? "#161b22"
                    : "transparent"

        border.width: popupOpen ? 1 : 0
        border.color: "#33ccff"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Text {
            id: clockText

            anchors.centerIn: parent

            text: Qt.formatDateTime(new Date(), "HH:mm")

            color: popupOpen
                ? "#33ccff"
                : "#e6edf3"

            font.pixelSize: 13
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (root.popupWindow) {
                    root.popupWindow.destroy()
                    root.popupWindow = null
                    root.popupOpen = false
                } else {
                    root.popupWindow = clockPopup.createObject(root)
                    root.popupOpen = true
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    Component {
        id: clockPopup

        PanelWindow {
            id: window

            implicitWidth: 270
            implicitHeight: 270

            anchors {
                top: true
            }

            margins {
                top: 40
            }

            color: "transparent"

            exclusiveZone: 0

            Rectangle {
                anchors.fill: parent

                radius: 14

                color: "#161b22"

                border.width: 1
                border.color: "#30363d"

                Rectangle {
                    id: clockFace

                    width: 220
                    height: 220

                    anchors.centerIn: parent

                    radius: width / 2

                    color: "#0d1117"

                    border.width: 2
                    border.color: "#30363d"

                    property date currentTime: new Date()

                    Repeater {
                        model: 12

                        Text {
                            required property int index

                            property real angle: index * 30

                            property real radiusDistance: 88

                            x: clockFace.width / 2
                               + Math.sin(angle * Math.PI / 180)
                               * radiusDistance
                               - width / 2

                            y: clockFace.height / 2
                               - Math.cos(angle * Math.PI / 180)
                               * radiusDistance
                               - height / 2

                            text: index === 0 ? "12" : index

                            color: "#8b949e"

                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        id: hourHand

                        width: 4
                        height: 55

                        radius: 2

                        color: "#e6edf3"

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.verticalCenter
                        }

                        transformOrigin: Item.Bottom

                        rotation:
                            (clockFace.currentTime.getHours() % 12) * 30
                            + clockFace.currentTime.getMinutes() * 0.5
                    }

                    Rectangle {
                        id: minuteHand

                        width: 3
                        height: 76

                        radius: 2

                        color: "#33ccff"

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.verticalCenter
                        }

                        transformOrigin: Item.Bottom

                        rotation:
                            clockFace.currentTime.getMinutes() * 6
                    }

                    Rectangle {
                        id: secondHand

                        width: 1
                        height: 82

                        color: "#58a6ff"

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.verticalCenter
                        }

                        transformOrigin: Item.Bottom

                        rotation:
                            clockFace.currentTime.getSeconds() * 6
                    }

                    Rectangle {
                        width: 10
                        height: 10

                        radius: 5

                        anchors.centerIn: parent

                        color: "#33ccff"
                    }

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true

                        onTriggered: {
                            clockFace.currentTime = new Date()
                        }
                    }
                }
            }

            Component.onDestruction: {
                root.popupOpen = false
                root.popupWindow = null
            }
        }
    }
}
