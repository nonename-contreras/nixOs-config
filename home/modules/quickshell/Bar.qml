import Quickshell
import QtQuick

PanelWindow {
    id: root

    required property var modelData

    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 32

    // ============================================================
    // SHARED STORAGE
    // ============================================================

    NotesStore {
        id: sharedNotesStore
    }

    AlarmStore {
        id: sharedAlarmStore
    }

    // ============================================================
    // BAR
    // ============================================================

    Rectangle {
        anchors.fill: parent

        color: "#0d1117"

        // ========================================================
        // LEFT
        // ========================================================

        Workspaces {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 12
            }
        }

        // ========================================================
        // CENTER
        // ========================================================

        Row {
            anchors.centerIn: parent

            spacing: 8

            Clock {
                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Calendar {
                anchors.verticalCenter:
                    parent.verticalCenter
            }
        }

        // ========================================================
        // RIGHT
        // ========================================================

        Row {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 12
            }

            spacing: 14

            BackgroundApps {
                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Calculator {
                notesStore:
                    sharedNotesStore

                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Notes {
                notesStore:
                    sharedNotesStore

                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Alarm {
                alarmStore:
                    sharedAlarmStore

                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Network {
                anchors.verticalCenter:
                    parent.verticalCenter
            }

            Volume {
                anchors.verticalCenter:
                    parent.verticalCenter
            }
        }
    }
}
