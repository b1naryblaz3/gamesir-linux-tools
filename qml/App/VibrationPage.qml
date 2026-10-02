import QtQuick
import QtQuick.Layouts

// Vibration strength (L/R) (+ the G7 Pro's trigger motors), staged through the
// config pending/save queue, plus a live rumble test (fires immediately).
// Poll rate used to live here; it's now the dropdown in the tab row (Main.qml).
Item {
    id: page
    property int trigL: 0
    property int trigR: 0
    property bool forceL: false
    property bool syncL: false
    property bool forceR: false
    property bool syncR: false

    function seed() {
        var c = bridge.config
        if (c.vib_l === undefined) return
        vibL.value = c.vib_l; vibR.value = c.vib_r
        if (bridge.isG7Pro) {
            trigL = c.vib_trigger_l; trigR = c.vib_trigger_r
            trigLSlider.value = c.vib_trigger_l; trigRSlider.value = c.vib_trigger_r
            forceL = c.vib_force_l; syncL = c.vib_sync_l
            forceR = c.vib_force_r; syncR = c.vib_sync_r
        }
    }
    Component.onCompleted: seed()
    Connections { target: bridge; function onConfigLoaded() { page.seed() } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        anchors.bottomMargin: pbar.height + 30   // reserve bar space always (no reflow)
        spacing: 14

        Card {
            visible: !bridge.profile
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 460
            title: "No profile selected"
            Text {
                width: parent.width; wrapMode: Text.WordWrap
                text: "Pick a profile (1–4) in the top bar to read and edit its settings."
                color: Theme.textDim; font.family: Theme.fontFamily; font.pixelSize: Theme.fontM
            }
        }

        ColumnLayout {
            visible: bridge.profile > 0
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.preferredWidth: 460
            spacing: 16

            Card {
                title: "Vibration strength"; Layout.fillWidth: true
                Row {
                    width: parent.width
                    Text { text: "Left"; color: Theme.textDim
                           font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                    Item { width: parent.width - 70; height: 1 }
                    Text { text: vibL.value + "%"; color: Theme.text
                           font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                }
                AccentSlider {
                    id: vibL; width: parent.width; from: 0; to: 100
                    onMoved: bridge.setScalar("vib_l", value)
                }
                Row {
                    width: parent.width
                    Text { text: "Right"; color: Theme.textDim
                           font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                    Item { width: parent.width - 70; height: 1 }
                    Text { text: vibR.value + "%"; color: Theme.text
                           font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                }
                AccentSlider {
                    id: vibR; width: parent.width; from: 0; to: 100
                    onMoved: bridge.setScalar("vib_r", value)
                }
                PillButton {
                    label: "Test rumble"
                    onClicked: bridge.rumbleTest()
                }
            }

            Card {
                visible: bridge.isG7Pro; title: "Trigger motors"; Layout.fillWidth: true
                // Sliders, like the grip motors above and every other controller's
                // vibration. These were 0/25/50/75/100 pills; the pad stores any
                // 0-100 value (60 written, read back and kept, 2026-10-01).
                Column {
                    width: parent.width; spacing: 6
                    Row {
                        width: parent.width
                        Text { text: "Left trigger"; color: Theme.textDim
                               font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                        Item { width: parent.width - 130; height: 1 }
                        Text { text: trigLSlider.value + "%"; color: Theme.text
                               font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                    }
                    AccentSlider {
                        id: trigLSlider; width: parent.width; from: 0; to: 100
                        onMoved: { page.trigL = value; bridge.setG7Extra("vib_trigger_l", value) }
                    }
                    Row {
                        spacing: 16
                        Row { spacing: 6; Text { text: "Force"; color: Theme.textDim }
                            ToggleSwitch { checked: page.forceL
                                onToggled: { page.forceL = checked
                                             bridge.setG7Extra("vib_force_l", checked ? 1 : 0) } } }
                        Row { spacing: 6; Text { text: "Sync"; color: Theme.textDim }
                            ToggleSwitch { checked: page.syncL
                                onToggled: { page.syncL = checked
                                             bridge.setG7Extra("vib_sync_l", checked ? 1 : 0) } } }
                    }
                }
                Column {
                    width: parent.width; spacing: 6
                    Row {
                        width: parent.width
                        Text { text: "Right trigger"; color: Theme.textDim
                               font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                        Item { width: parent.width - 130; height: 1 }
                        Text { text: trigRSlider.value + "%"; color: Theme.text
                               font.family: Theme.fontFamily; font.pixelSize: Theme.fontS }
                    }
                    AccentSlider {
                        id: trigRSlider; width: parent.width; from: 0; to: 100
                        onMoved: { page.trigR = value; bridge.setG7Extra("vib_trigger_r", value) }
                    }
                    Row {
                        spacing: 16
                        Row { spacing: 6; Text { text: "Force"; color: Theme.textDim }
                            ToggleSwitch { checked: page.forceR
                                onToggled: { page.forceR = checked
                                             bridge.setG7Extra("vib_force_r", checked ? 1 : 0) } } }
                        Row { spacing: 6; Text { text: "Sync"; color: Theme.textDim }
                            ToggleSwitch { checked: page.syncR
                                onToggled: { page.syncR = checked
                                             bridge.setG7Extra("vib_sync_r", checked ? 1 : 0) } } }
                    }
                }
            }

        }
        Item { Layout.fillHeight: true }
    }

    PendingBar {
        id: pbar
        anchors.left: parent.left; anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20; anchors.rightMargin: 20; anchors.bottomMargin: 20
    }
}
