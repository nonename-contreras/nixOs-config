import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property var alarmStore

    implicitWidth: 26
    implicitHeight: 26

    property var alarmWindow: null
    property var alertWindow: null

    property bool editorOpen: alarmWindow !== null
    property bool alertOpen: alertWindow !== null

    // ============================================================
    // ALARM SOUND PATH
    // ============================================================

    readonly property string alarmSoundPath:
        "/home/nonename/nixos-config/home/modules/quickshell/alarm.wav"

    // ============================================================
    // OPEN EDITOR
    // ============================================================

    function openAlarmEditor() {
        if (alarmWindow !== null)
            return

        alarmWindow =
            alarmEditorComponent.createObject(root)
    }

    function closeAlarmEditor() {
        if (alarmWindow === null)
            return

        var windowRef = alarmWindow

        alarmWindow = null
        windowRef.destroy()
    }

    function toggleAlarmEditor() {
        if (alarmWindow)
            closeAlarmEditor()
        else
            openAlarmEditor()
    }

    // ============================================================
    // ALERT
    // ============================================================

    function showAlert(
        index,
        title,
        triggerTime
    ) {
        if (alertWindow !== null)
            return

        alertWindow =
            alarmAlertComponent.createObject(
                root,
                {
                    alarmIndex: index,
                    alarmTitle: title,
                    triggerTime: triggerTime
                }
            )
    }

    function closeAlert(alarmIndex) {
        if (alertWindow === null)
            return

        // Stop sound before destroying window
        alertWindow.stopAlarmSound()

        root.alarmStore.dismissAlarm(
            alarmIndex
        )

        var windowRef = alertWindow

        alertWindow = null
        windowRef.destroy()
    }

    // ============================================================
    // STORE SIGNAL
    // ============================================================

    Connections {
        target: root.alarmStore

        function onAlarmTriggered(
            alarmIndex,
            title,
            triggerTime
        ) {
            root.showAlert(
                alarmIndex,
                title,
                triggerTime
            )
        }
    }

    // ============================================================
    // BAR BUTTON
    // ============================================================

    Rectangle {
        anchors.fill: parent

        radius: 6

        color:
            alarmMouse.pressed
            ? "#1f6feb"
            : root.editorOpen
                ? "#16324a"
                : alarmMouse.containsMouse
                    ? "#161b22"
                    : "transparent"

        border.width:
            root.editorOpen
            ? 1
            : 0

        border.color: "#33ccff"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Text {
            anchors.centerIn: parent

            text: "󰀠"

            color:
                root.editorOpen
                ? "#33ccff"
                : "#e6edf3"

            font.pixelSize: 14
        }

        MouseArea {
            id: alarmMouse

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                root.toggleAlarmEditor()
        }
    }

    // ============================================================
    // ALARM EDITOR
    // ============================================================

    Component {
        id: alarmEditorComponent

        FloatingWindow {
            id: editorWindow

            title: "QS Alarm"

            implicitWidth: 440
            implicitHeight: 470

            color: "transparent"

            property bool timerMode: true

            // ====================================================
            // TIMER MODE
            // ====================================================

            function createTimerAlarm() {
                var hours =
                    parseInt(timerHours.text)

                var minutes =
                    parseInt(timerMinutes.text)

                if (isNaN(hours))
                    hours = 0

                if (isNaN(minutes))
                    minutes = 0

                var totalMilliseconds =
                    (
                        hours * 60 * 60
                        + minutes * 60
                    ) * 1000

                if (totalMilliseconds <= 0) {
                    statusText.text =
                        "Enter a valid duration"

                    statusText.color =
                        "#ff7b72"

                    return
                }

                var triggerTime =
                    Date.now()
                    + totalMilliseconds

                root.alarmStore.createAlarm(
                    alarmTitle.text.trim(),
                    triggerTime
                )

                statusText.text =
                    "Alarm created"

                statusText.color =
                    "#3fb950"

                alarmTitle.text = ""
                timerHours.text = ""
                timerMinutes.text = ""

                alarmsList.refresh()
            }

            // ====================================================
            // CLOCK MODE
            // ====================================================

            function createClockAlarm() {
                var hours =
                    parseInt(clockHours.text)

                var minutes =
                    parseInt(clockMinutes.text)

                if (
                    isNaN(hours)
                    || isNaN(minutes)
                    || hours < 0
                    || hours > 23
                    || minutes < 0
                    || minutes > 59
                ) {
                    statusText.text =
                        "Enter a valid time"

                    statusText.color =
                        "#ff7b72"

                    return
                }

                var now = new Date()
                var target = new Date()

                target.setHours(
                    hours,
                    minutes,
                    0,
                    0
                )

                if (
                    target.getTime()
                    <= now.getTime()
                ) {
                    target.setDate(
                        target.getDate() + 1
                    )
                }

                root.alarmStore.createAlarm(
                    alarmTitle.text.trim(),
                    target.getTime()
                )

                statusText.text =
                    "Alarm created"

                statusText.color =
                    "#3fb950"

                alarmTitle.text = ""
                clockHours.text = ""
                clockMinutes.text = ""

                alarmsList.refresh()
            }

            function createAlarm() {
                if (timerMode)
                    createTimerAlarm()
                else
                    createClockAlarm()
            }

            // ====================================================
            // ESC
            // ====================================================

            Shortcut {
                sequence: "Escape"

                onActivated:
                    root.closeAlarmEditor()
            }

            // ====================================================
            // WINDOW
            // ====================================================

            Rectangle {
                anchors.fill: parent

                radius: 12

                color: "#0d1117"

                border.width: 1
                border.color: "#30363d"

                Column {
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    spacing: 14

                    // =============================================
                    // HEADER
                    // =============================================

                    Row {
                        width: parent.width
                        height: 32

                        spacing: 10

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            text: "󰀠"

                            color: "#33ccff"

                            font.pixelSize: 18
                        }

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            text: "Alarm"

                            color: "#e6edf3"

                            font.pixelSize: 16
                            font.bold: true
                        }

                        Item {
                            width:
                                parent.width - 125

                            height: 1
                        }

                        Rectangle {
                            width: 28
                            height: 28

                            radius: 6

                            color:
                                closeMouse.containsMouse
                                ? "#da3633"
                                : "transparent"

                            Text {
                                anchors.centerIn:
                                    parent

                                text: "×"

                                color: "#e6edf3"

                                font.pixelSize: 20
                            }

                            MouseArea {
                                id: closeMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    root.closeAlarmEditor()
                            }
                        }
                    }

                    // =============================================
                    // TITLE
                    // =============================================

                    Text {
                        text: "Title"

                        color: "#8b949e"

                        font.pixelSize: 11
                    }

                    Rectangle {
                        width: parent.width
                        height: 38

                        radius: 7

                        color: "#161b22"

                        border.width: 1

                        border.color:
                            alarmTitle.activeFocus
                            ? "#33ccff"
                            : "#30363d"

                        TextField {
                            id: alarmTitle

                            anchors {
                                fill: parent
                                margins: 2
                            }

                            placeholderText:
                                "Example: Go to the doctor"

                            color: "#e6edf3"

                            placeholderTextColor:
                                "#484f58"

                            background: null
                        }
                    }

                    // =============================================
                    // MODE BUTTONS
                    // =============================================

                    Row {
                        width: parent.width
                        height: 36

                        spacing: 8

                        Rectangle {
                            width:
                                (parent.width - 8) / 2

                            height: 36

                            radius: 7

                            color:
                                editorWindow.timerMode
                                ? "#16324a"
                                : timerModeMouse.containsMouse
                                    ? "#161b22"
                                    : "transparent"

                            border.width:
                                editorWindow.timerMode
                                ? 1
                                : 0

                            border.color: "#33ccff"

                            Text {
                                anchors.centerIn:
                                    parent

                                text: "In..."

                                color:
                                    editorWindow.timerMode
                                    ? "#33ccff"
                                    : "#e6edf3"

                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: timerModeMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    editorWindow.timerMode =
                                        true
                            }
                        }

                        Rectangle {
                            width:
                                (parent.width - 8) / 2

                            height: 36

                            radius: 7

                            color:
                                !editorWindow.timerMode
                                ? "#16324a"
                                : clockModeMouse.containsMouse
                                    ? "#161b22"
                                    : "transparent"

                            border.width:
                                !editorWindow.timerMode
                                ? 1
                                : 0

                            border.color: "#33ccff"

                            Text {
                                anchors.centerIn:
                                    parent

                                text: "At time"

                                color:
                                    !editorWindow.timerMode
                                    ? "#33ccff"
                                    : "#e6edf3"

                                font.pixelSize: 12
                            }

                            MouseArea {
                                id: clockModeMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    editorWindow.timerMode =
                                        false
                            }
                        }
                    }

                    // =============================================
                    // TIMER INPUT
                    // =============================================

                    Row {
                        visible:
                            editorWindow.timerMode

                        width: parent.width
                        height: 45

                        spacing: 10

                        TimeField {
                            id: timerHours

                            fieldWidth:
                                (parent.width - 10) / 2

                            placeholder: "Hours"
                        }

                        TimeField {
                            id: timerMinutes

                            fieldWidth:
                                (parent.width - 10) / 2

                            placeholder: "Minutes"
                        }
                    }

                    // =============================================
                    // CLOCK INPUT
                    // =============================================

                    Row {
                        visible:
                            !editorWindow.timerMode

                        width: parent.width
                        height: 45

                        spacing: 10

                        TimeField {
                            id: clockHours

                            fieldWidth:
                                (parent.width - 10) / 2

                            placeholder:
                                "Hour 0-23"
                        }

                        TimeField {
                            id: clockMinutes

                            fieldWidth:
                                (parent.width - 10) / 2

                            placeholder:
                                "Minutes"
                        }
                    }

                    // =============================================
                    // CREATE BUTTON
                    // =============================================

                    Rectangle {
                        width: parent.width
                        height: 38

                        radius: 7

                        color:
                            createMouse.pressed
                            ? "#1f6feb"
                            : createMouse.containsMouse
                                ? "#16324a"
                                : "#161b22"

                        border.width: 1

                        border.color:
                            createMouse.containsMouse
                            ? "#33ccff"
                            : "#30363d"

                        Text {
                            anchors.centerIn:
                                parent

                            text: "Create alarm"

                            color:
                                createMouse.containsMouse
                                ? "#33ccff"
                                : "#e6edf3"

                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: createMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                editorWindow.createAlarm()
                        }
                    }

                    Text {
                        id: statusText

                        width: parent.width

                        text: ""

                        horizontalAlignment:
                            Text.AlignHCenter

                        color: "#3fb950"

                        font.pixelSize: 10
                    }

                    // =============================================
                    // ACTIVE ALARMS
                    // =============================================

                    Text {
                        text: "Active alarms"

                        color: "#e6edf3"

                        font.pixelSize: 12
                        font.bold: true
                    }

                    ListView {
                        id: alarmsList

                        width: parent.width
                        height: 110

                        clip: true
                        spacing: 4

                        model: ListModel {
                            id: alarmsModel
                        }

                        function refresh() {
                            alarmsModel.clear()

                            var alarms =
                                root.alarmStore.allAlarms()

                            for (
                                var i = 0;
                                i < alarms.length;
                                i++
                            ) {
                                alarmsModel.append({
                                    realIndex: i,

                                    alarmTitle:
                                        alarms[i].title,

                                    triggerTime:
                                        alarms[i].triggerTime
                                })
                            }
                        }

                        delegate: Rectangle {
                            required property int realIndex
                            required property string alarmTitle
                            required property double triggerTime

                            width:
                                ListView.view.width

                            height: 42

                            radius: 6

                            color:
                                alarmItemMouse.containsMouse
                                ? "#161b22"
                                : "transparent"

                            Row {
                                anchors {
                                    fill: parent
                                    leftMargin: 8
                                    rightMargin: 8
                                }

                                Text {
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    width:
                                        parent.width - 70

                                    text:
                                        alarmTitle
                                        + "  ·  "
                                        + Qt.formatDateTime(
                                            new Date(triggerTime),
                                            "dd/MM HH:mm"
                                        )

                                    color: "#e6edf3"

                                    elide:
                                        Text.ElideRight

                                    font.pixelSize: 10
                                }

                                Rectangle {
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    width: 50
                                    height: 26

                                    radius: 5

                                    color:
                                        deleteMouse.containsMouse
                                        ? "#3a1718"
                                        : "transparent"

                                    Text {
                                        anchors.centerIn:
                                            parent

                                        text: "Delete"

                                        color:
                                            deleteMouse.containsMouse
                                            ? "#ff7b72"
                                            : "#8b949e"

                                        font.pixelSize: 9
                                    }

                                    MouseArea {
                                        id: deleteMouse

                                        anchors.fill: parent

                                        hoverEnabled: true

                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked: {
                                            root.alarmStore.deleteAlarm(
                                                realIndex
                                            )

                                            alarmsList.refresh()
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: alarmItemMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                acceptedButtons:
                                    Qt.NoButton
                            }
                        }

                        Component.onCompleted:
                            refresh()
                    }
                }
            }

            Connections {
                target: root.alarmStore

                function onAlarmsChanged() {
                    alarmsList.refresh()
                }
            }

            Component.onDestruction:
                root.alarmWindow = null
        }
    }

    // ============================================================
    // ALARM ALERT
    // ============================================================

    Component {
        id: alarmAlertComponent

        FloatingWindow {
            id: alert

            required property int alarmIndex
            required property string alarmTitle
            required property double triggerTime

            title: "QS Alarm Alert"

            implicitWidth: 320
            implicitHeight: 150

            color: "transparent"

            // ====================================================
            // SOUND
            // ====================================================

            Process {
                id: alarmSound

                command: [
                    "pw-play",
                    root.alarmSoundPath
                ]
            }

            function playAlarmSound() {
                if (alarmSound.running)
                    alarmSound.running = false

                alarmSound.running = true
            }

            function stopAlarmSound() {
                soundRepeatTimer.stop()

                if (alarmSound.running)
                    alarmSound.running = false
            }

            // Play again every 2 seconds
            Timer {
                id: soundRepeatTimer

                interval: 2000
                repeat: true

                onTriggered:
                    alert.playAlarmSound()
            }

            Component.onCompleted: {
                // First sound immediately
                playAlarmSound()

                // Then every 2 seconds
                soundRepeatTimer.start()
            }

            // ====================================================
            // ESC DISMISSES ALARM
            // ====================================================

            Shortcut {
                sequence: "Escape"

                onActivated:
                    root.closeAlert(
                        alert.alarmIndex
                    )
            }

            // ====================================================
            // ALERT UI
            // ====================================================

            Rectangle {
                anchors.fill: parent

                radius: 12

                color: "#0d1117"

                border.width: 1
                border.color: "#33ccff"

                Column {
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    spacing: 10

                    Row {
                        width: parent.width

                        spacing: 10

                        Text {
                            text: "󰀠"

                            color: "#33ccff"

                            font.pixelSize: 20
                        }

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            text: "Alarm"

                            color: "#e6edf3"

                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    Text {
                        width: parent.width

                        text:
                            alert.alarmTitle

                        color: "#e6edf3"

                        font.pixelSize: 17
                        font.bold: true

                        wrapMode:
                            Text.Wrap
                    }

                    Rectangle {
                        width: parent.width
                        height: 30

                        radius: 6

                        color:
                            dismissMouse.containsMouse
                            ? "#16324a"
                            : "#161b22"

                        border.width: 1

                        border.color:
                            dismissMouse.containsMouse
                            ? "#33ccff"
                            : "#30363d"

                        Text {
                            anchors.centerIn: parent

                            text: "Dismiss"

                            color:
                                dismissMouse.containsMouse
                                ? "#33ccff"
                                : "#e6edf3"

                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: dismissMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                root.closeAlert(
                                    alert.alarmIndex
                                )
                        }
                    }
                }
            }

            Component.onDestruction: {
                stopAlarmSound()
                root.alertWindow = null
            }
        }
    }

    // ============================================================
    // TIME FIELD
    // ============================================================

    component TimeField: Rectangle {
        property real fieldWidth: 100
        property string placeholder: ""

        property alias text: input.text

        width: fieldWidth
        height: 42

        radius: 7

        color: "#161b22"

        border.width: 1

        border.color:
            input.activeFocus
            ? "#33ccff"
            : "#30363d"

        TextField {
            id: input

            anchors {
                fill: parent
                margins: 2
            }

            placeholderText:
                parent.placeholder

            color: "#e6edf3"

            placeholderTextColor:
                "#484f58"

            inputMethodHints:
                Qt.ImhDigitsOnly

            background: null
        }
    }
}
