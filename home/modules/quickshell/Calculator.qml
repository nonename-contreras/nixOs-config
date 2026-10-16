import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var notesStore

    implicitWidth: 26
    implicitHeight: 26

    property var calculatorWindow: null
    property bool popupOpen:
        calculatorWindow !== null

    // ============================================================
    // OPEN / CLOSE
    // ============================================================

    function openCalculator() {
        if (calculatorWindow !== null)
            return

        calculatorWindow =
            calculatorComponent.createObject(root)
    }

    function closeCalculator() {
        if (calculatorWindow === null)
            return

        var windowRef =
            calculatorWindow

        calculatorWindow = null

        windowRef.destroy()
    }

    function toggleCalculator() {
        if (calculatorWindow)
            closeCalculator()
        else
            openCalculator()
    }

    // ============================================================
    // BAR BUTTON
    // ============================================================

    Rectangle {
        anchors.fill: parent

        radius: 6

        color:
            buttonMouse.pressed
            ? "#1f6feb"
            : root.popupOpen
                ? "#16324a"
                : buttonMouse.containsMouse
                    ? "#161b22"
                    : "transparent"

        border.width:
            root.popupOpen ? 1 : 0

        border.color:
            "#33ccff"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }

        Text {
            anchors.centerIn: parent

            text: ""

            color:
                root.popupOpen
                ? "#33ccff"
                : "#e6edf3"

            font.pixelSize: 13
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                root.toggleCalculator()
        }
    }

    // ============================================================
    // WINDOW
    // ============================================================

    Component {
        id: calculatorComponent

        FloatingWindow {
            id: window

            title: "QS Calculator"

            implicitWidth: 840
            implicitHeight: 620

            color: "transparent"

            property string expression: ""
            property string result: "0"

            property bool justCalculated: false

            property real historyWidth: 225
            property real outerSpacing: 14

            // ====================================================
            // CALCULATOR LOGIC
            // ====================================================

            function isOperator(value) {
                return value === "+"
                    || value === "-"
                    || value === "×"
                    || value === "÷"
            }

            function appendNumber(value) {
                if (justCalculated) {
                    expression = ""
                    result = "0"
                    justCalculated = false
                }

                expression += value
            }

            function appendOperator(value) {
                if (justCalculated) {
                    expression = result
                    justCalculated = false
                }

                if (expression.length === 0) {
                    if (value === "-")
                        expression = "-"

                    return
                }

                var last =
                    expression.charAt(
                        expression.length - 1
                    )

                if (isOperator(last)) {
                    expression =
                        expression.slice(0, -1)
                        + value

                    return
                }

                expression += value
            }

            function append(value) {
                if (isOperator(value))
                    appendOperator(value)
                else
                    appendNumber(value)
            }

            function clearAll() {
                expression = ""
                result = "0"
                justCalculated = false
            }

            function backspace() {
                if (justCalculated) {
                    clearAll()
                    return
                }

                if (expression.length > 0)
                    expression =
                        expression.slice(0, -1)
            }

            function normalizeExpression(input) {
                var value = input

                value =
                    value.replace(/×/g, "*")

                value =
                    value.replace(/÷/g, "/")

                value =
                    value.replace(/π/g, "Math.PI")

                value =
                    value.replace(
                        /sin\(/g,
                        "Math.sin("
                    )

                value =
                    value.replace(
                        /cos\(/g,
                        "Math.cos("
                    )

                value =
                    value.replace(
                        /tan\(/g,
                        "Math.tan("
                    )

                value =
                    value.replace(
                        /asin\(/g,
                        "Math.asin("
                    )

                value =
                    value.replace(
                        /acos\(/g,
                        "Math.acos("
                    )

                value =
                    value.replace(
                        /atan\(/g,
                        "Math.atan("
                    )

                value =
                    value.replace(
                        /sqrt\(/g,
                        "Math.sqrt("
                    )

                value =
                    value.replace(
                        /log\(/g,
                        "Math.log10("
                    )

                value =
                    value.replace(
                        /ln\(/g,
                        "Math.log("
                    )

                return value
            }

            function calculate() {
                if (expression.length === 0)
                    return

                try {
                    var originalExpression =
                        expression

                    var normalized =
                        normalizeExpression(
                            expression
                        )

                    var calculated =
                        eval(normalized)

                    if (
                        typeof calculated !== "number"
                        || !isFinite(calculated)
                    ) {
                        result = "Error"
                        justCalculated = true
                        return
                    }

                    var formatted =
                        Math.round(
                            calculated
                            * 10000000000
                        )
                        / 10000000000

                    result =
                        formatted.toString()

                    historyModel.insert(
                        0,
                        {
                            operation:
                                originalExpression,

                            answer:
                                result
                        }
                    )

                    justCalculated = true

                } catch (error) {
                    result = "Error"
                    justCalculated = true
                }
            }

            function square() {
                if (expression.length === 0)
                    return

                expression =
                    "("
                    + expression
                    + ")**2"

                calculate()
            }

            function percentage() {
                if (expression.length === 0)
                    return

                expression =
                    "("
                    + expression
                    + ")/100"

                calculate()
            }

            // ====================================================
            // SAVE CALCULATION TO NOTES
            // ====================================================

            function saveToNotes() {
                if (
                    expression.length === 0
                    || result === "Error"
                )
                    return

                var title =
                    noteTitle.text.trim()

                if (title.length === 0)
                    title = "Calculation"

               var content = result

                root.notesStore.createNote(
                    title,
                    content
                )

                saveMessage.text =
                    "Saved to Notes"

                saveMessage.color =
                    "#3fb950"

                saveFeedbackTimer.restart()

                noteTitle.text = ""

                keyboardArea.forceActiveFocus()
            }

            Timer {
                id: saveFeedbackTimer

                interval: 1800
                repeat: false

                onTriggered: {
                    saveMessage.text = ""
                }
            }

            // ====================================================
            // MAIN WINDOW / KEYBOARD
            // ====================================================

            Rectangle {
                id: keyboardArea

                anchors.fill: parent

                focus: true

                radius: 12

                color: "#0d1117"

                border.width: 1
                border.color: "#30363d"

                Keys.onPressed: event => {
                    if (
                        event.key
                        === Qt.Key_Escape
                    ) {
                        root.closeCalculator()

                        event.accepted = true
                        return
                    }

                    if (
                        event.key === Qt.Key_Return
                        || event.key === Qt.Key_Enter
                        || event.key === Qt.Key_Equal
                    ) {
                        window.calculate()

                        event.accepted = true
                        return
                    }

                    if (
                        event.key
                        === Qt.Key_Backspace
                    ) {
                        window.backspace()

                        event.accepted = true
                        return
                    }

                    if (
                        event.key
                        === Qt.Key_Delete
                    ) {
                        window.clearAll()

                        event.accepted = true
                        return
                    }

                    if (
                        event.text >= "0"
                        && event.text <= "9"
                    ) {
                        window.appendNumber(
                            event.text
                        )

                        event.accepted = true
                        return
                    }

                    if (event.text === "+") {
                        window.appendOperator("+")
                        event.accepted = true
                        return
                    }

                    if (event.text === "-") {
                        window.appendOperator("-")
                        event.accepted = true
                        return
                    }

                    if (event.text === "*") {
                        window.appendOperator("×")
                        event.accepted = true
                        return
                    }

                    if (event.text === "/") {
                        window.appendOperator("÷")
                        event.accepted = true
                        return
                    }

                    if (
                        event.text === "."
                        || event.text === ","
                    ) {
                        window.appendNumber(".")
                        event.accepted = true
                        return
                    }

                    if (event.text === "(") {
                        window.appendNumber("(")
                        event.accepted = true
                        return
                    }

                    if (event.text === ")") {
                        window.appendNumber(")")
                        event.accepted = true
                        return
                    }

                    if (event.text === "%") {
                        window.percentage()
                        event.accepted = true
                        return
                    }
                }

                Component.onCompleted:
                    keyboardArea.forceActiveFocus()

                Column {
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    spacing: 12

                    // =================================================
                    // HEADER
                    // =================================================

                    Row {
                        width: parent.width
                        height: 34

                        spacing: 10

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            text: ""

                            color: "#33ccff"

                            font.pixelSize: 19
                        }

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            text: "Calculator"

                            color: "#e6edf3"

                            font.pixelSize: 16
                            font.bold: true
                        }

                        Item {
                            width:
                                parent.width - 150

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

                                anchors.fill:
                                    parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    root.closeCalculator()
                            }
                        }
                    }

                    // =================================================
                    // BODY
                    // =================================================

                    Row {
                        width: parent.width

                        height:
                            parent.height - 46

                        spacing:
                            window.outerSpacing

                        // =============================================
                        // LEFT CALCULATOR
                        // =============================================

                        Column {
                            width:
                                parent.width
                                - window.historyWidth
                                - window.outerSpacing

                            height: parent.height

                            spacing: 10

                            // DISPLAY

                            Rectangle {
                                width: parent.width
                                height: 100

                                radius: 10

                                color: "#161b22"

                                border.width: 1
                                border.color: "#30363d"

                                Column {
                                    anchors {
                                        fill: parent
                                        margins: 14
                                    }

                                    spacing: 7

                                    Text {
                                        width: parent.width

                                        horizontalAlignment:
                                            Text.AlignRight

                                        elide:
                                            Text.ElideLeft

                                        text:
                                            window.expression.length
                                            ? window.expression
                                            : "0"

                                        color: "#8b949e"

                                        font.pixelSize: 17
                                    }

                                    Text {
                                        width: parent.width

                                        horizontalAlignment:
                                            Text.AlignRight

                                        elide:
                                            Text.ElideLeft

                                        text:
                                            window.result

                                        color: "#e6edf3"

                                        font.pixelSize: 30
                                        font.bold: true
                                    }
                                }
                            }

                            // SCIENTIFIC

                            GridLayout {
                                width: parent.width

                                columns: 6

                                columnSpacing: 6
                                rowSpacing: 6

                                CalcButton {
                                    label: "sin"
                                    value: "sin("
                                }

                                CalcButton {
                                    label: "cos"
                                    value: "cos("
                                }

                                CalcButton {
                                    label: "tan"
                                    value: "tan("
                                }

                                CalcButton {
                                    label: "π"
                                    value: "π"
                                }

                                CalcButton {
                                    label: "√"
                                    value: "sqrt("
                                }

                                CalcButton {
                                    label: "x²"

                                    specialAction:
                                        function() {
                                            window.square()
                                        }
                                }

                                CalcButton {
                                    label: "asin"
                                    value: "asin("
                                }

                                CalcButton {
                                    label: "acos"
                                    value: "acos("
                                }

                                CalcButton {
                                    label: "atan"
                                    value: "atan("
                                }

                                CalcButton {
                                    label: "log"
                                    value: "log("
                                }

                                CalcButton {
                                    label: "ln"
                                    value: "ln("
                                }

                                CalcButton {
                                    label: "%"

                                    specialAction:
                                        function() {
                                            window.percentage()
                                        }
                                }
                            }

                            // KEYPAD

                            GridLayout {
                                width: parent.width

                                columns: 4

                                columnSpacing: 7
                                rowSpacing: 7

                                CalcButton {
                                    label: "C"

                                    specialAction:
                                        function() {
                                            window.clearAll()
                                        }
                                }

                                CalcButton {
                                    label: "⌫"

                                    specialAction:
                                        function() {
                                            window.backspace()
                                        }
                                }

                                CalcButton {
                                    label: "("
                                    value: "("
                                }

                                CalcButton {
                                    label: ")"
                                    value: ")"
                                }

                                CalcButton {
                                    label: "7"
                                    value: "7"
                                }

                                CalcButton {
                                    label: "8"
                                    value: "8"
                                }

                                CalcButton {
                                    label: "9"
                                    value: "9"
                                }

                                CalcButton {
                                    label: "÷"
                                    value: "÷"
                                    operatorButton: true
                                }

                                CalcButton {
                                    label: "4"
                                    value: "4"
                                }

                                CalcButton {
                                    label: "5"
                                    value: "5"
                                }

                                CalcButton {
                                    label: "6"
                                    value: "6"
                                }

                                CalcButton {
                                    label: "×"
                                    value: "×"
                                    operatorButton: true
                                }

                                CalcButton {
                                    label: "1"
                                    value: "1"
                                }

                                CalcButton {
                                    label: "2"
                                    value: "2"
                                }

                                CalcButton {
                                    label: "3"
                                    value: "3"
                                }

                                CalcButton {
                                    label: "−"
                                    value: "-"
                                    operatorButton: true
                                }

                                CalcButton {
                                    label: "0"
                                    value: "0"
                                }

                                CalcButton {
                                    label: "."
                                    value: "."
                                }

                                CalcButton {
                                    label: "="
                                    equalButton: true

                                    specialAction:
                                        function() {
                                            window.calculate()
                                        }
                                }

                                CalcButton {
                                    label: "+"
                                    value: "+"
                                    operatorButton: true
                                }
                            }

                            // COPY

                            Rectangle {
                                width: parent.width
                                height: 32

                                radius: 7

                                color:
                                    copyMouse.containsMouse
                                    ? "#16324a"
                                    : "#161b22"

                                border.width: 1

                                border.color:
                                    copyMouse.containsMouse
                                    ? "#33ccff"
                                    : "#30363d"

                                Text {
                                    anchors.centerIn:
                                        parent

                                    text:
                                        "Copy result"

                                    color:
                                        copyMouse.containsMouse
                                        ? "#33ccff"
                                        : "#8b949e"

                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    id: copyMouse

                                    anchors.fill:
                                        parent

                                    hoverEnabled: true

                                    cursorShape:
                                        Qt.PointingHandCursor

                                    onClicked: {
                                        Quickshell.clipboardText =
                                            window.result

                                        keyboardArea.forceActiveFocus()
                                    }
                                }
                            }
                        }

                        // =============================================
                        // RIGHT SIDE
                        // =============================================

                        Column {
                            width:
                                window.historyWidth

                            height:
                                parent.height

                            spacing: 10

                            // =========================================
                            // HISTORY
                            // =========================================

                            Rectangle {
                                width: parent.width

                                height:
                                    parent.height * 0.58

                                radius: 10

                                color: "#161b22"

                                border.width: 1
                                border.color: "#30363d"

                                Column {
                                    anchors {
                                        fill: parent
                                        margins: 12
                                    }

                                    spacing: 8

                                    Text {
                                        text: "History"

                                        color: "#e6edf3"

                                        font.pixelSize: 14
                                        font.bold: true
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 1

                                        color: "#30363d"
                                    }

                                    ListView {
                                        width: parent.width

                                        height:
                                            parent.height - 64

                                        clip: true
                                        spacing: 4

                                        model: ListModel {
                                            id: historyModel
                                        }

                                        delegate: Rectangle {
                                            required property string operation
                                            required property string answer

                                            width:
                                                ListView.view.width

                                            height: 52

                                            radius: 7

                                            color:
                                                historyMouse.containsMouse
                                                ? "#21262d"
                                                : "transparent"

                                            Column {
                                                anchors {
                                                    fill: parent
                                                    margins: 6
                                                }

                                                Text {
                                                    width:
                                                        parent.width

                                                    text:
                                                        operation

                                                    color:
                                                        "#8b949e"

                                                    elide:
                                                        Text.ElideRight

                                                    font.pixelSize: 10
                                                }

                                                Text {
                                                    width:
                                                        parent.width

                                                    text:
                                                        answer

                                                    color:
                                                        "#e6edf3"

                                                    elide:
                                                        Text.ElideRight

                                                    font.pixelSize: 12
                                                }
                                            }

                                            MouseArea {
                                                id: historyMouse

                                                anchors.fill:
                                                    parent

                                                hoverEnabled:
                                                    true

                                                cursorShape:
                                                    Qt.PointingHandCursor

                                                onClicked: {
                                                    window.expression =
                                                        operation

                                                    window.result =
                                                        answer

                                                    window.justCalculated =
                                                        true

                                                    keyboardArea.forceActiveFocus()
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 24

                                        radius: 5

                                        color:
                                            clearHistoryMouse.containsMouse
                                            ? "#21262d"
                                            : "transparent"

                                        Text {
                                            anchors.centerIn:
                                                parent

                                            text:
                                                "Clear history"

                                            color:
                                                clearHistoryMouse.containsMouse
                                                ? "#ff7b72"
                                                : "#8b949e"

                                            font.pixelSize: 10
                                        }

                                        MouseArea {
                                            id: clearHistoryMouse

                                            anchors.fill:
                                                parent

                                            hoverEnabled:
                                                true

                                            cursorShape:
                                                Qt.PointingHandCursor

                                            onClicked: {
                                                historyModel.clear()

                                                keyboardArea.forceActiveFocus()
                                            }
                                        }
                                    }
                                }
                            }

                            // =========================================
                            // SAVE TO NOTES
                            // =========================================

                            Rectangle {
                                width: parent.width

                                height:
                                    parent.height
                                    - (parent.height * 0.58)
                                    - 10

                                radius: 10

                                color: "#161b22"

                                border.width: 1
                                border.color: "#30363d"

                                Column {
                                    anchors {
                                        fill: parent
                                        margins: 12
                                    }

                                    spacing: 8

                                    Text {
                                        text:
                                            "Save to Notes"

                                        color:
                                            "#e6edf3"

                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        text: "Title"

                                        color: "#8b949e"

                                        font.pixelSize: 10
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 32

                                        radius: 6

                                        color: "#0d1117"

                                        border.width: 1

                                        border.color:
                                            noteTitle.activeFocus
                                            ? "#33ccff"
                                            : "#30363d"

                                        TextField {
                                            id: noteTitle

                                            anchors {
                                                fill: parent
                                                margins: 2
                                            }

                                            placeholderText:
                                                "Calculation title..."

                                            color:
                                                "#e6edf3"

                                            placeholderTextColor:
                                                "#484f58"

                                            font.pixelSize: 11

                                            background: null
                                        }
                                    }

                                    Text {
                                        width: parent.width

                                        text:
                                            window.expression.length
                                            ? window.expression
                                            : "No calculation"

                                        color: "#8b949e"

                                        elide:
                                            Text.ElideRight

                                        font.pixelSize: 10
                                    }

                                    Text {
                                        width: parent.width

                                        text:
                                            "= "
                                            + window.result

                                        color:
                                            "#e6edf3"

                                        elide:
                                            Text.ElideRight

                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Item {
                                        width: 1
                                        height: 2
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 32

                                        radius: 7

                                        color:
                                            saveMouse.pressed
                                            ? "#1f6feb"
                                            : saveMouse.containsMouse
                                                ? "#16324a"
                                                : "#0d1117"

                                        border.width: 1

                                        border.color:
                                            saveMouse.containsMouse
                                            ? "#33ccff"
                                            : "#30363d"

                                        Text {
                                            anchors.centerIn:
                                                parent

                                            text:
                                                "Save result"

                                            color:
                                                saveMouse.containsMouse
                                                ? "#33ccff"
                                                : "#e6edf3"

                                            font.pixelSize: 11
                                        }

                                        MouseArea {
                                            id: saveMouse

                                            anchors.fill:
                                                parent

                                            hoverEnabled:
                                                true

                                            cursorShape:
                                                Qt.PointingHandCursor

                                            onClicked:
                                                window.saveToNotes()
                                        }
                                    }

                                    Text {
                                        id: saveMessage

                                        width: parent.width

                                        text: ""

                                        horizontalAlignment:
                                            Text.AlignHCenter

                                        color: "#3fb950"

                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Component.onCompleted: {
                Qt.callLater(function() {
                    keyboardArea.forceActiveFocus()
                })
            }

            Component.onDestruction: {
                root.calculatorWindow = null
            }
        }
    }

    // ============================================================
    // BUTTON COMPONENT
    // ============================================================

    component CalcButton: Rectangle {
        property string label: ""
        property string value: ""

        property bool operatorButton: false
        property bool equalButton: false

        property var specialAction: null

        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.preferredHeight: 47

        radius: 8

        color:
            equalButton
            ? buttonArea.pressed
                ? "#1f6feb"
                : "#33ccff"
            : buttonArea.pressed
                ? "#16324a"
                : buttonArea.containsMouse
                    ? "#21262d"
                    : operatorButton
                        ? "#12343a"
                        : "#161b22"

        border.width: 1

        border.color:
            equalButton
            ? "#33ccff"
            : buttonArea.containsMouse
                ? "#33ccff"
                : "#30363d"

        Behavior on color {
            ColorAnimation {
                duration: 90
            }
        }

        Text {
            anchors.centerIn:
                parent

            text:
                parent.label

            color:
                parent.equalButton
                ? "#0d1117"
                : "#e6edf3"

            font.pixelSize: 14
        }

        MouseArea {
            id: buttonArea

            anchors.fill:
                parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked: {
                if (parent.specialAction)
                    parent.specialAction()
                else
                    window.append(
                        parent.value
                    )

                keyboardArea.forceActiveFocus()
            }
        }
    }
}
