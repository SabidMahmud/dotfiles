import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell.Services.Pipewire

ColumnLayout {
    id: pane
    spacing: 9

    readonly property var outputs: Pipewire.nodes.values.filter(
        node => node.audio && node.isSink && !node.isStream)

    PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] }

    LevelControl {
        Layout.fillWidth: true
        title: "Output volume"
        audio: Pipewire.defaultAudioSink?.audio ?? null
        description: Pipewire.defaultAudioSink?.description || "No output device"
    }

    LevelControl {
        Layout.fillWidth: true
        title: "Microphone"
        audio: Pipewire.defaultAudioSource?.audio ?? null
        description: Pipewire.defaultAudioSource?.description || "No microphone"
    }

    Rectangle {
        Layout.fillWidth: true
        visible: pane.outputs.length > 1
        height: 1
        color: palette.button
    }

    Label { visible: pane.outputs.length > 1; text: "Output device" }

    Repeater {
        model: pane.outputs.length > 1 ? pane.outputs : []
        DeviceRow {
            required property var modelData
            Layout.fillWidth: true
            text: modelData.description || modelData.nickname || modelData.name
            actionLabel: current ? "Selected" : "Select"
            current: Pipewire.defaultAudioSink === modelData
            enabled: !current
            onClicked: Pipewire.preferredDefaultAudioSink = modelData
        }
    }

    component LevelControl: ColumnLayout {
        id: level
        required property string title
        required property string description
        required property var audio
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: level.title
                font.weight: Font.DemiBold
            }
            Label { text: level.audio ? Math.round(level.audio.volume * 100) + "%" : "—" }
        }
        Label {
            Layout.fillWidth: true
            text: level.description
            textFormat: Text.PlainText
            color: palette.placeholderText
            font.pixelSize: 12
            elide: Text.ElideRight
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            ControlSlider {
                id: slider
                Layout.fillWidth: true
                to: 1
                stepSize: 0.01
                enabled: level.audio !== null
                Accessible.name: level.title
                onMoved: if (level.audio) level.audio.volume = value

                Binding {
                    target: slider
                    property: "value"
                    value: level.audio?.volume ?? 0
                    when: !slider.pressed
                }
            }
            ControlButton {
                text: level.audio?.muted ? "Unmute" : "Mute"
                Accessible.name: text + " " + level.title
                enabled: level.audio !== null
                onClicked: level.audio.muted = !level.audio.muted
            }
        }
    }
}
