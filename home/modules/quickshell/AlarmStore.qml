import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    signal alarmTriggered(
        int alarmIndex,
        string title,
        double triggerTime
    )

    signal alarmsChanged()

    // ============================================================
    // STORAGE
    // ============================================================

    FileView {
        id: alarmFile

        path: Quickshell.dataPath("alarms.json")

        atomicWrites: true
        blockWrites: true
        watchChanges: false
        printErrors: true

        JsonAdapter {
            id: adapter

            property var alarms: []
        }
    }

    // ============================================================
    // ACCESS
    // ============================================================

    function allAlarms() {
        return adapter.alarms
    }

    function alarmCount() {
        return adapter.alarms.length
    }

    function alarmAt(index) {
        if (
            index < 0
            || index >= adapter.alarms.length
        )
            return null

        return adapter.alarms[index]
    }

    // ============================================================
    // CREATE
    // ============================================================

    function createAlarm(
        title,
        triggerTime
    ) {
        var data =
            adapter.alarms.slice()

        data.push({
            title:
                title.length > 0
                ? title
                : "Alarm",

            triggerTime:
                triggerTime,

            active:
                true
        })

        adapter.alarms = data

        alarmFile.writeAdapter()

        root.alarmsChanged()
    }

    // ============================================================
    // DELETE
    // ============================================================

    function deleteAlarm(index) {
        if (
            index < 0
            || index >= adapter.alarms.length
        )
            return

        var data =
            adapter.alarms.slice()

        data.splice(index, 1)

        adapter.alarms = data

        alarmFile.writeAdapter()

        root.alarmsChanged()
    }

    // ============================================================
    // DISMISS AFTER TRIGGER
    // ============================================================

    function dismissAlarm(index) {
        deleteAlarm(index)
    }

    // ============================================================
    // CHECK ALARMS
    // ============================================================

    function checkAlarms() {
        var now =
            Date.now()

        var data =
            adapter.alarms

        for (
            var i = 0;
            i < data.length;
            i++
        ) {
            var alarm =
                data[i]

            if (
                alarm.active
                && now >= alarm.triggerTime
            ) {
                root.alarmTriggered(
                    i,
                    alarm.title,
                    alarm.triggerTime
                )

                break
            }
        }
    }

    // ============================================================
    // TIMER
    // ============================================================

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered:
            root.checkAlarms()
    }
}
