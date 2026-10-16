import QtQuick
import Quickshell.Networking

Item {
    implicitWidth: networkRow.implicitWidth
    implicitHeight: networkRow.implicitHeight

    property var connectedDevice: {
        for (let i = 0; i < Networking.devices.values.length; i++) {
            let device = Networking.devices.values[i]

            if (device.connected)
                return device
        }

        return null
    }

    Row {
        id: networkRow
        spacing: 4

        Text {
            text: connectedDevice ? "󰈀" : "󰖪"
            color: "#e6edf3"
        }

        Text {
            text: connectedDevice ? "Connected" : "Disconnected"
            color: "#e6edf3"
        }
    }
}
