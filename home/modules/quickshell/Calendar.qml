import QtQuick
import Quickshell

Item {
    id: root

    implicitWidth: dateButton.width
    implicitHeight: 28

    property bool popupOpen: false
    property var popupWindow: null

    Rectangle {
        id: dateButton

        anchors.verticalCenter: parent.verticalCenter

        width: dateText.implicitWidth + 16
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
            id: dateText

            anchors.centerIn: parent

            text: Qt.locale("es_MX").toString(
                new Date(),
                "dd MMMM yyyy"
            )

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
                    root.popupWindow =
                        calendarPopup.createObject(root)

                    root.popupOpen = true
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true

        onTriggered: {
            dateText.text =
                Qt.locale("es_MX").toString(
                    new Date(),
                    "dd MMMM yyyy"
                )
        }
    }

    Component {
        id: calendarPopup

        PanelWindow {
            id: window

            implicitWidth: 360
            implicitHeight: 370

            anchors {
                top: true
            }

            margins {
                top: 40
            }

            color: "transparent"

            exclusiveZone: 0

            property date today: new Date()

            property int selectedMonth:
                today.getMonth()

            property int selectedYear:
                today.getFullYear()

            property var monthNames: [
                "enero",
                "febrero",
                "marzo",
                "abril",
                "mayo",
                "junio",
                "julio",
                "agosto",
                "septiembre",
                "octubre",
                "noviembre",
                "diciembre"
            ]

            function previousMonth() {
                selectedMonth--

                if (selectedMonth < 0) {
                    selectedMonth = 11
                    selectedYear--
                }
            }

            function nextMonth() {
                selectedMonth++

                if (selectedMonth > 11) {
                    selectedMonth = 0
                    selectedYear++
                }
            }

            function daysInMonth(month, year) {
                return new Date(
                    year,
                    month + 1,
                    0
                ).getDate()
            }

            function firstDay(month, year) {
                let day =
                    new Date(
                        year,
                        month,
                        1
                    ).getDay()

                return (day + 6) % 7
            }

            function isToday(day) {
                return day === today.getDate()
                    && selectedMonth === today.getMonth()
                    && selectedYear === today.getFullYear()
            }

            Rectangle {
                anchors.fill: parent

                radius: 14

                color: "#161b22"

                border.width: 1
                border.color: "#30363d"

                Column {
                    anchors {
                        fill: parent
                        margins: 18
                    }

                    spacing: 14

                    Row {
                        width: parent.width
                        height: 32

                        Rectangle {
                            width: 32
                            height: 32

                            radius: 6

                            color:
                                previousMouse.containsMouse
                                ? "#21262d"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "‹"

                                color: "#e6edf3"

                                font.pixelSize: 22
                            }

                            MouseArea {
                                id: previousMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    window.previousMonth()
                                }
                            }
                        }

                        Item {
                            width:
                                parent.width - 128

                            height: 32

                            Text {
                                anchors.centerIn: parent

                                text:
                                    window.monthNames[
                                        window.selectedMonth
                                    ]
                                    + " "
                                    + window.selectedYear

                                color: "#e6edf3"

                                font.pixelSize: 16

                                font.bold: true
                            }
                        }

                        Rectangle {
                            width: 32
                            height: 32

                            radius: 6

                            color:
                                nextMouse.containsMouse
                                ? "#21262d"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "›"

                                color: "#e6edf3"

                                font.pixelSize: 22
                            }

                            MouseArea {
                                id: nextMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    window.nextMonth()
                                }
                            }
                        }

                        Rectangle {
                            width: 32
                            height: 32

                            radius: 6

                            color:
                                todayMouse.containsMouse
                                ? "#16324a"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "●"

                                color: "#33ccff"

                                font.pixelSize: 10
                            }

                            MouseArea {
                                id: todayMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    window.selectedMonth =
                                        window.today.getMonth()

                                    window.selectedYear =
                                        window.today.getFullYear()
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width

                        Repeater {
                            model: [
                                "Lu",
                                "Ma",
                                "Mi",
                                "Ju",
                                "Vi",
                                "Sá",
                                "Do"
                            ]

                            Text {
                                required property string modelData

                                width: parent.width / 7

                                horizontalAlignment:
                                    Text.AlignHCenter

                                text: modelData

                                color: "#8b949e"

                                font.pixelSize: 12
                            }
                        }
                    }

                    Grid {
                        width: parent.width

                        columns: 7

                        rowSpacing: 6
                        columnSpacing: 2

                        Repeater {
                            model: 42

                            Rectangle {
                                required property int index

                                property int firstDay:
                                    window.firstDay(
                                        window.selectedMonth,
                                        window.selectedYear
                                    )

                                property int day:
                                    index - firstDay + 1

                                property int maxDay:
                                    window.daysInMonth(
                                        window.selectedMonth,
                                        window.selectedYear
                                    )

                                property bool valid:
                                    day > 0
                                    && day <= maxDay

                                width:
                                    (parent.width - 12) / 7

                                height: 36

                                radius: 8

                                color:
                                    valid
                                    && window.isToday(day)
                                    ? "#1f6feb"
                                    : dayMouse.containsMouse
                                        && valid
                                        ? "#21262d"
                                        : "transparent"

                                Text {
                                    anchors.centerIn: parent

                                    text:
                                        parent.valid
                                        ? parent.day
                                        : ""

                                    color:
                                        parent.valid
                                        && window.isToday(
                                            parent.day
                                        )
                                        ? "#ffffff"
                                        : "#e6edf3"

                                    font.pixelSize: 13
                                }

                                MouseArea {
                                    id: dayMouse

                                    anchors.fill: parent

                                    enabled: parent.valid

                                    hoverEnabled: true

                                    cursorShape:
                                        parent.valid
                                        ? Qt.PointingHandCursor
                                        : Qt.ArrowCursor
                                }
                            }
                        }
                    }

                    Item {
                        width: 1
                        height: 4
                    }

                    Row {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        spacing: 18

                        Rectangle {
                            width: 36
                            height: 28

                            radius: 6

                            color:
                                prevYearMouse.containsMouse
                                ? "#21262d"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "«"

                                color: "#8b949e"

                                font.pixelSize: 18
                            }

                            MouseArea {
                                id: prevYearMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    window.selectedYear--
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            text:
                                window.selectedYear

                            color: "#8b949e"

                            font.pixelSize: 13
                        }

                        Rectangle {
                            width: 36
                            height: 28

                            radius: 6

                            color:
                                nextYearMouse.containsMouse
                                ? "#21262d"
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "»"

                                color: "#8b949e"

                                font.pixelSize: 18
                            }

                            MouseArea {
                                id: nextYearMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    window.selectedYear++
                                }
                            }
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
