import QtQuick
import Quickshell.Hyprland

Row {
    id: root

    spacing: 10

    // =========================================================
    // WORKSPACES VISIBLES
    // =========================================================

    property var visibleWorkspaces: {
        let ids = [1, 2, 3, 4, 5]
        const workspaces = Hyprland.workspaces.values

        for (let i = 0; i < workspaces.length; i++) {
            const ws = workspaces[i]

            if (
                ws.id > 5
                && ws.toplevels.values.length > 0
                && !ids.includes(ws.id)
            ) {
                ids.push(ws.id)
            }
        }

        // Si estamos actualmente en uno > 5,
        // mostrarlo aunque todavía esté vacío.
        if (
            Hyprland.focusedWorkspace
            && Hyprland.focusedWorkspace.id > 5
            && !ids.includes(Hyprland.focusedWorkspace.id)
        ) {
            ids.push(Hyprland.focusedWorkspace.id)
        }

        ids.sort((a, b) => a - b)

        return ids
    }

    // =========================================================
    // BOTONES
    // =========================================================

    Repeater {
        model: root.visibleWorkspaces

        delegate: Item {
            id: workspaceItem

            required property var modelData

            property int workspaceNumber: modelData

            property var workspace: {
                const workspaces = Hyprland.workspaces.values

                for (let i = 0; i < workspaces.length; i++) {
                    if (workspaces[i].id === workspaceNumber) {
                        return workspaces[i]
                    }
                }

                return null
            }

            property bool active:
                Hyprland.focusedWorkspace
                && Hyprland.focusedWorkspace.id === workspaceNumber

            property bool occupied:
                workspace
                && workspace.toplevels.values.length > 0

            width: 24
            height: 24

            // =================================================
            // ANIMACIÓN
            // =================================================

            scale:
                workspaceMouse.pressed
                ? 0.90
                : workspaceHover.hovered
                ? 1.18
                : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            // =================================================
            // CUADRO
            // =================================================

            Rectangle {
                anchors.fill: parent

                radius: 5

                color:
                    workspaceItem.active
                    ? "transparent"
                    : workspaceItem.occupied
                    ? "#77ff4d4d"
                    : "transparent"

                border.width:
                    workspaceItem.active
                    ? 2
                    : 1

                border.color:
                    workspaceItem.active
                    ? "#33ccff"
                    : "#ff4d4d"

                Text {
                    anchors.centerIn: parent

                    text: workspaceItem.workspaceNumber

                    color:
                        workspaceItem.active
                        ? "#33ccff"
                        : "#ff6b6b"

                    font.pixelSize: 12
                }
            }

            // =================================================
            // HOVER
            // =================================================

            HoverHandler {
                id: workspaceHover
            }

            // =================================================
            // CLICK
            // =================================================

            MouseArea {
                id: workspaceMouse

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (workspaceItem.workspace) {
                        workspaceItem.workspace.activate()
                    } else {
                        Hyprland.dispatch(
                            "workspace "
                            + workspaceItem.workspaceNumber
                        )
                    }
                }
            }
        }
    }
}
