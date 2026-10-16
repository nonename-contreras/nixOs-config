import QtQuick
import Quickshell.Services.Pipewire

Item {
    implicitWidth: volumeRow.implicitWidth
    implicitHeight: volumeRow.implicitHeight

    property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: sink ? [sink] : []
    }

    Row {
        id: volumeRow
        spacing: 4

        Text {
            text: {
                if (!sink || !sink.audio)
                    return ""

                if (sink.audio.muted)
                    return "󰖁"

                return ""
            }

            color: "#e6edf3"
        }

        Text {
            text: {
                if (!sink || !sink.audio)
                    return "--"

                return Math.round(sink.audio.volume * 100) + "%"
            }

            color: "#e6edf3"
        }
    }
}
