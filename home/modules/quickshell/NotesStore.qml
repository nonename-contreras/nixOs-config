import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    visible: false
    width: 0
    height: 0

    signal storeChanged()

    // ============================================================
    // PERSISTENT STORAGE
    // ============================================================

    FileView {
        id: notesFile

        path: Quickshell.dataPath("notes.json")

        atomicWrites: true
        blockWrites: true
        watchChanges: false
        printErrors: true

        JsonAdapter {
            id: notesAdapter

            property var notes: [
                {
                    title: "Welcome",
                    content:
                        "Welcome to Notes.\n\n"
                        + "Your notes are saved automatically."
                }
            ]
        }
    }

    // ============================================================
    // READ
    // ============================================================

    function allNotes() {
        return notesAdapter.notes
    }

    function noteCount() {
        return notesAdapter.notes.length
    }

    function noteAt(index) {
        if (
            index < 0
            || index >= notesAdapter.notes.length
        )
            return null

        return notesAdapter.notes[index]
    }

    // ============================================================
    // SAVE EXISTING NOTE
    // ============================================================

    function saveNote(index, title, content) {
        if (
            index < 0
            || index >= notesAdapter.notes.length
        )
            return

        var data = notesAdapter.notes.slice()

        data[index] = {
            title:
                title.length > 0
                ? title
                : "Untitled",

            content: content
        }

        notesAdapter.notes = data

        notesFile.writeAdapter()
        root.storeChanged()
    }

    // ============================================================
    // CREATE NOTE
    // ============================================================

    function createNote(title, content) {
        var data = notesAdapter.notes.slice()

        data.push({
            title:
                title.length > 0
                ? title
                : "Untitled",

            content: content
        })

        notesAdapter.notes = data

        notesFile.writeAdapter()
        root.storeChanged()

        return data.length - 1
    }

    // ============================================================
    // DELETE NOTE
    // ============================================================

    function deleteNote(index) {
        if (
            index < 0
            || index >= notesAdapter.notes.length
        )
            return

        var data = notesAdapter.notes.slice()

        data.splice(index, 1)

        if (data.length === 0) {
            data.push({
                title: "New note",
                content: ""
            })
        }

        notesAdapter.notes = data

        notesFile.writeAdapter()
        root.storeChanged()
    }

    // ============================================================
    // FORCE WRITE
    // ============================================================

    function flush() {
        notesFile.writeAdapter()
    }
}
