import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Shapes

Scope {
    id: root

    // =========================================================
    // CONFIGURACIÓN
    // =========================================================

    property bool showOnHover: true
    property bool menuOpen: false

    property int edgeWidth: 4
    property int innerWidth: 64
    property int menuHeight: 190
    property int curveSize: 12

    property color menuColor: "#99161b22"

    // Hyprland:
    // active_border   = rgba(33ccffee)
    // inactive_border = rgba(595959aa)
    //
    // QML usa #AARRGGBB
    property color activeBorderColor: "#ee33ccff"
    property color inactiveBorderColor: "#aa595959"

    // =========================================================
    // MONITOR
    // =========================================================

    property var targetScreen: Quickshell.screens.find(
        screen => screen.name === "HDMI-A-1"
    )

    property var targetMonitor:
        targetScreen
        ? Hyprland.monitorFor(targetScreen)
        : null

    property bool borderActive:
        targetMonitor
        ? targetMonitor.focused
        : false

    // =========================================================
    // CIERRE
    // =========================================================

    Timer {
        id: closeTimer

        interval: 180
        repeat: false

        onTriggered: {
            if (!edgeMouse.containsMouse && !menuHover.hovered) {
                root.menuOpen = false
            }
        }
    }

    // =========================================================
    // HOT EDGE
    // =========================================================

    PanelWindow {
        id: edgeTrigger

        screen: root.targetScreen

        anchors {
            top: true
            bottom: true
            right: true
        }

        implicitWidth: root.edgeWidth
        color: "transparent"
        exclusiveZone: 0

        mask: Region {
                   item: edgeMouse
               }       

        MouseArea {
            id: edgeMouse

            width: root.edgeWidth
            height: root.menuHeight

            anchors {
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 80
            }

            hoverEnabled: true

            onEntered: {
                if (root.showOnHover) {
                    closeTimer.stop()
                    root.menuOpen = true
                }
            }

            onExited: {
                closeTimer.restart()
            }
        }
    }

    // =========================================================
    // SUPERFICIE DEL MENÚ
    // =========================================================

    PanelWindow {
        id: sideMenu

        screen: root.targetScreen

        anchors {
            top: true
            bottom: true
            right: true
        }

        implicitWidth:
            root.innerWidth
            + root.curveSize
            + 10

        visible: true
        color: "transparent"
        exclusiveZone: 0

        // =====================================================
        // MÁSCARA DE ENTRADA
        // =====================================================

        mask: Region {
            item: root.menuOpen ? menu : null
        }

        // =====================================================
        // MENÚ
        // =====================================================

        Item {
            id: menu

            width: sideMenu.implicitWidth
            height: root.menuHeight

            anchors {
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 80
            }

            property real morph:
                root.menuOpen
                ? 1.0
                : 0.0

            property real bodyX:
                width
                - (root.innerWidth * morph)

            property real neckX:
                width
                - (
                    (root.innerWidth - root.curveSize)
                    * morph
                )

            Behavior on morph {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            // =================================================
            // FORMA
            // =================================================

            Shape {
                anchors.fill: parent

                // =============================================
                // FONDO
                // =============================================

                ShapePath {
                    fillColor: root.menuColor
                    strokeWidth: 0

                    startX: menu.width + 2
                    startY: 0

                    PathLine {
                        x: menu.neckX
                        y: 0
                    }

                    PathCubic {
                        x: menu.bodyX
                        y: root.curveSize

                        control1X:
                            menu.neckX
                            - (
                                root.curveSize
                                * 0.55
                                * menu.morph
                            )

                        control1Y: 0

                        control2X: menu.bodyX
                        control2Y:
                            root.curveSize * 0.45
                    }

                    PathLine {
                        x: menu.bodyX

                        y:
                            root.menuHeight
                            - root.curveSize
                    }

                    PathCubic {
                        x: menu.neckX
                        y: root.menuHeight

                        control1X: menu.bodyX

                        control1Y:
                            root.menuHeight
                            - (
                                root.curveSize
                                * 0.45
                            )

                        control2X:
                            menu.neckX
                            - (
                                root.curveSize
                                * 0.55
                                * menu.morph
                            )

                        control2Y:
                            root.menuHeight
                    }

                    PathLine {
                        x: menu.width + 2
                        y: root.menuHeight
                    }

                    PathLine {
                        x: menu.width + 2
                        y: 0
                    }
                }

                // =============================================
                // BORDE
                // =============================================

                ShapePath {
                    fillColor: "transparent"

                    strokeColor:
                        root.borderActive
                        ? root.activeBorderColor
                        : root.inactiveBorderColor

                    strokeWidth: 1

                    startX: menu.width
                    startY: 0

                    PathLine {
                        x: menu.neckX
                        y: 0
                    }

                    PathCubic {
                        x: menu.bodyX
                        y: root.curveSize

                        control1X:
                            menu.neckX
                            - (
                                root.curveSize
                                * 0.55
                                * menu.morph
                            )

                        control1Y: 0

                        control2X: menu.bodyX
                        control2Y:
                            root.curveSize * 0.45
                    }

                    PathLine {
                        x: menu.bodyX

                        y:
                            root.menuHeight
                            - root.curveSize
                    }

                    PathCubic {
                        x: menu.neckX
                        y: root.menuHeight

                        control1X: menu.bodyX

                        control1Y:
                            root.menuHeight
                            - (
                                root.curveSize
                                * 0.45
                            )

                        control2X:
                            menu.neckX
                            - (
                                root.curveSize
                                * 0.55
                                * menu.morph
                            )

                        control2Y:
                            root.menuHeight
                    }

                    PathLine {
                        x: menu.width
                        y: root.menuHeight
                    }
                }
            }

            // =================================================
            // CONTENIDO
            // =================================================

            Item {
                id: menuContent

                width:
                    root.innerWidth - 12

                height:
                    root.menuHeight - 30

                anchors {
                    right: parent.right
                    rightMargin: 6
                    verticalCenter: parent.verticalCenter
                }

                SideApps {
                    anchors.centerIn: parent
                }

                opacity: menu.morph

                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                    }
                }
            }

            // =================================================
            // HOVER DEL MENÚ
            // =================================================

            HoverHandler {
                id: menuHover

                enabled: root.menuOpen

                onHoveredChanged: {
                    if (hovered) {
                        closeTimer.stop()
                    } else {
                        closeTimer.restart()
                    }
                }
            }
        }
    }
}
