import QtQuick
import QtQuick.Controls
import Quickshell

Item {
    id: root

    required property var notesStore

    implicitWidth: 26
    implicitHeight: 26

    property var notesWindow: null
    property bool popupOpen: notesWindow !== null

    // ============================================================
    // OPEN / CLOSE
    // ============================================================

    function openNotes() {
        if (notesWindow !== null)
            return

        notesWindow =
            notesComponent.createObject(root)
    }

    function closeNotes() {
        if (notesWindow === null)
            return

        notesWindow.saveCurrentNote()
        notesStore.flush()

        var windowRef = notesWindow

        notesWindow = null
        windowRef.destroy()
    }

    function toggleNotes() {
        if (notesWindow)
            closeNotes()
        else
            openNotes()
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

            text: "󰎚"

            color:
                root.popupOpen
                ? "#33ccff"
                : "#e6edf3"

            font.pixelSize: 14
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                root.toggleNotes()
        }
    }

    // ============================================================
    // NOTES WINDOW
    // ============================================================

    Component {
        id: notesComponent

        FloatingWindow {
            id: window

            title: "QS Notes"

            implicitWidth: 900
            implicitHeight: 650

            color: "transparent"

            property int currentIndex: -1
            property bool loadingNote: false
            property string searchText: ""

            // ====================================================
            // NOTES MODEL
            // ====================================================

            ListModel {
                id: notesModel
            }

            // ====================================================
            // FUNCTIONS
            // ====================================================

            function rebuildModel() {
                notesModel.clear()

                var data =
                    root.notesStore.allNotes()

                var query =
                    searchText.toLowerCase()

                for (
                    var i = 0;
                    i < data.length;
                    i++
                ) {
                    var title =
                        data[i].title || ""

                    var content =
                        data[i].content || ""

                    if (
                        query.length === 0
                        || title
                            .toLowerCase()
                            .includes(query)
                        || content
                            .toLowerCase()
                            .includes(query)
                    ) {
                        notesModel.append({
                            realIndex: i,
                            noteTitle: title,
                            noteContent: content
                        })
                    }
                }
            }

            function openNote(index) {
                if (
                    index < 0
                    || index >= root.notesStore.noteCount()
                )
                    return

                saveCurrentNote()

                loadingNote = true
                currentIndex = index

                var note =
                    root.notesStore.noteAt(index)

                titleInput.text =
                    note.title || ""

                editor.text =
                    note.content || ""

                loadingNote = false
            }

            function saveCurrentNote() {
                if (
                    loadingNote
                    || currentIndex < 0
                    || currentIndex >= root.notesStore.noteCount()
                )
                    return

                root.notesStore.saveNote(
                    currentIndex,
                    titleInput.text,
                    editor.text
                )
            }

            function createNote() {
                saveCurrentNote()

                var index =
                    root.notesStore.createNote(
                        "New note",
                        ""
                    )

                searchField.text = ""

                rebuildModel()
                openNote(index)

                titleInput.selectAll()
                titleInput.forceActiveFocus()
            }

            function deleteCurrentNote() {
                if (currentIndex < 0)
                    return

                var oldIndex =
                    currentIndex

                root.notesStore.deleteNote(
                    currentIndex
                )

                currentIndex = -1

                searchField.text = ""

                rebuildModel()

                var newIndex =
                    Math.min(
                        oldIndex,
                        root.notesStore.noteCount() - 1
                    )

                openNote(newIndex)
            }

            function wordCount() {
                var cleaned =
                    editor.text.trim()

                if (cleaned.length === 0)
                    return 0

                return cleaned
                    .split(/\s+/)
                    .length
            }

            // ====================================================
            // STORAGE CHANGED FROM OUTSIDE
            // ====================================================

            Connections {
                target: root.notesStore

                function onStoreChanged() {
                    if (!window.loadingNote)
                        window.rebuildModel()
                }
            }

            // ====================================================
            // AUTOSAVE
            // ====================================================

            Timer {
                id: autosaveTimer

                interval: 350
                repeat: false

                onTriggered: {
                    window.saveCurrentNote()
                }
            }

            // ====================================================
            // ESC
            // ====================================================

            Shortcut {
                sequence: "Escape"

                onActivated:
                    root.closeNotes()
            }

            // ====================================================
            // BACKGROUND
            // ====================================================

            Rectangle {
                anchors.fill: parent

                radius: 12

                color: "#0d1117"

                border.width: 1
                border.color: "#30363d"

                Column {
                    anchors.fill: parent

                    // =================================================
                    // HEADER
                    // =================================================

                    Rectangle {
                        width: parent.width
                        height: 48

                        color: "#0d1117"

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 16
                                rightMargin: 10
                            }

                            spacing: 10

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "󰎚"

                                color: "#33ccff"

                                font.pixelSize: 19
                            }

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "Notes"

                                color: "#e6edf3"

                                font.pixelSize: 16
                                font.bold: true
                            }

                            Item {
                                width:
                                    parent.width - 128

                                height: 1
                            }

                            Rectangle {
                                anchors.verticalCenter:
                                    parent.verticalCenter

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
                                        root.closeNotes()
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1

                        color: "#30363d"
                    }

                    // =================================================
                    // BODY
                    // =================================================

                    Row {
                        width: parent.width

                        height:
                            parent.height - 49

                        // =============================================
                        // SIDEBAR
                        // =============================================

                        Rectangle {
                            width: 240
                            height: parent.height

                            color: "#0d1117"

                            Column {
                                anchors {
                                    fill: parent
                                    margins: 12
                                }

                                spacing: 10

                                // NEW NOTE

                                Rectangle {
                                    width: parent.width
                                    height: 38

                                    radius: 7

                                    color:
                                        newMouse.containsMouse
                                        ? "#16324a"
                                        : "#161b22"

                                    border.width: 1

                                    border.color:
                                        newMouse.containsMouse
                                        ? "#33ccff"
                                        : "#30363d"

                                    Text {
                                        anchors.centerIn:
                                            parent

                                        text:
                                            "+  New Note"

                                        color:
                                            newMouse.containsMouse
                                            ? "#33ccff"
                                            : "#e6edf3"

                                        font.pixelSize: 13
                                    }

                                    MouseArea {
                                        id: newMouse

                                        anchors.fill: parent

                                        hoverEnabled: true

                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked:
                                            window.createNote()
                                    }
                                }

                                // SEARCH

                                Rectangle {
                                    width: parent.width
                                    height: 36

                                    radius: 7

                                    color: "#161b22"

                                    border.width: 1

                                    border.color:
                                        searchField.activeFocus
                                        ? "#33ccff"
                                        : "#30363d"

                                    TextField {
                                        id: searchField

                                        anchors {
                                            fill: parent
                                            margins: 2
                                        }

                                        placeholderText:
                                            "Search notes..."

                                        color: "#e6edf3"

                                        placeholderTextColor:
                                            "#8b949e"

                                        background: null

                                        onTextChanged: {
                                            window.searchText =
                                                text

                                            window.rebuildModel()
                                        }
                                    }
                                }

                                // NOTE LIST

                                ListView {
                                    width: parent.width

                                    height:
                                        parent.height - 150

                                    clip: true
                                    spacing: 4

                                    model: notesModel

                                    delegate: Rectangle {
                                        required property int realIndex
                                        required property string noteTitle
                                        required property string noteContent

                                        width:
                                            ListView.view.width

                                        height: 48

                                        radius: 7

                                        color:
                                            window.currentIndex
                                            === realIndex
                                            ? "#16324a"
                                            : itemMouse.containsMouse
                                                ? "#161b22"
                                                : "transparent"

                                        border.width:
                                            window.currentIndex
                                            === realIndex
                                            ? 1
                                            : 0

                                        border.color:
                                            "#33ccff"

                                        Column {
                                            anchors {
                                                fill: parent
                                                margins: 7
                                            }

                                            spacing: 2

                                            Text {
                                                width: parent.width

                                                text:
                                                    noteTitle

                                                color:
                                                    window.currentIndex
                                                    === realIndex
                                                    ? "#33ccff"
                                                    : "#e6edf3"

                                                font.pixelSize: 12
                                                font.bold: true

                                                elide:
                                                    Text.ElideRight
                                            }

                                            Text {
                                                width: parent.width

                                                text:
                                                    noteContent.replace(
                                                        /\n/g,
                                                        " "
                                                    )

                                                color:
                                                    "#8b949e"

                                                font.pixelSize: 10

                                                elide:
                                                    Text.ElideRight
                                            }
                                        }

                                        MouseArea {
                                            id: itemMouse

                                            anchors.fill:
                                                parent

                                            hoverEnabled: true

                                            cursorShape:
                                                Qt.PointingHandCursor

                                            onClicked:
                                                window.openNote(
                                                    realIndex
                                                )
                                        }
                                    }
                                }

                                // DELETE

                                Rectangle {
                                    width: parent.width
                                    height: 32

                                    radius: 7

                                    color:
                                        deleteMouse.containsMouse
                                        ? "#3a1718"
                                        : "transparent"

                                    Text {
                                        anchors.centerIn:
                                            parent

                                        text:
                                            "Delete note"

                                        color:
                                            deleteMouse.containsMouse
                                            ? "#ff7b72"
                                            : "#8b949e"

                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        id: deleteMouse

                                        anchors.fill:
                                            parent

                                        hoverEnabled: true

                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked:
                                            window.deleteCurrentNote()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 1
                            height: parent.height

                            color: "#30363d"
                        }

                        // =============================================
                        // EDITOR
                        // =============================================

                        Column {
                            width:
                                parent.width - 241

                            height:
                                parent.height

                            // TITLE

                            Rectangle {
                                width: parent.width
                                height: 54

                                color: "#0d1117"

                                Row {
                                    anchors {
                                        fill: parent
                                        leftMargin: 14
                                        rightMargin: 14
                                    }

                                    spacing: 10

                                    TextField {
                                        id: titleInput

                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        width:
                                            parent.width - 150

                                        font.pixelSize: 17
                                        font.bold: true

                                        color: "#e6edf3"

                                        placeholderText:
                                            "Note title"

                                        placeholderTextColor:
                                            "#8b949e"

                                        background: null

                                        onTextChanged: {
                                            if (!window.loadingNote)
                                                autosaveTimer.restart()
                                        }
                                    }

                                    Rectangle {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        width: 55
                                        height: 30

                                        radius: 6

                                        color:
                                            copyMouse.containsMouse
                                            ? "#16324a"
                                            : "transparent"

                                        Text {
                                            anchors.centerIn:
                                                parent

                                            text: "Copy"

                                            color:
                                                copyMouse.containsMouse
                                                ? "#33ccff"
                                                : "#8b949e"

                                            font.pixelSize: 11
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
                                                    editor.text
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1

                                color: "#30363d"
                            }

                            // EDITOR

                            ScrollView {
                                width: parent.width

                                height:
                                    parent.height - 88

                                clip: true

                                TextArea {
                                    id: editor

                                    padding: 18

                                    wrapMode:
                                        TextEdit.Wrap

                                    color: "#e6edf3"

                                    selectionColor:
                                        "#1f6feb"

                                    selectedTextColor:
                                        "#ffffff"

                                    placeholderText:
                                        "Start writing..."

                                    placeholderTextColor:
                                        "#484f58"

                                    font.pixelSize: 14

                                    background: Rectangle {
                                        color: "#0d1117"
                                    }

                                    onTextChanged: {
                                        if (!window.loadingNote)
                                            autosaveTimer.restart()
                                    }
                                }
                            }

                            // STATUS

                            Rectangle {
                                width: parent.width
                                height: 32

                                color: "#0d1117"

                                Row {
                                    anchors {
                                        fill: parent
                                        leftMargin: 14
                                        rightMargin: 14
                                    }

                                    Text {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        text: "Autosave"

                                        color: "#8b949e"

                                        font.pixelSize: 10
                                    }

                                    Item {
                                        width:
                                            parent.width - 240

                                        height: 1
                                    }

                                    Text {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        text:
                                            window.wordCount()
                                            + " words"

                                        color: "#8b949e"

                                        font.pixelSize: 10
                                    }

                                    Item {
                                        width: 14
                                        height: 1
                                    }

                                    Text {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        text:
                                            editor.text.length
                                            + " characters"

                                        color: "#8b949e"

                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ====================================================
            // START
            // ====================================================

            Component.onCompleted: {
                window.rebuildModel()

                Qt.callLater(function() {
                    if (
                        root.notesStore.noteCount() > 0
                    )
                        window.openNote(0)
                })
            }

            Component.onDestruction: {
                root.notesWindow = null
            }
        }
    }
}
