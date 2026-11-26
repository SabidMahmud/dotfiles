import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    id: control
    spacing: 3

    required property color warningColor
    readonly property string helper: Quickshell.env("HOME") + "/.local/bin/brightness-step"
    property string devicePath: ""
    property int maximum: 0
    property int rawLevel: -1
    property int pendingLevel: -1
    property int requestedLevel: -1
    property int dragLevel: -1
    property string message: ""
    readonly property bool available: maximum > 0 && rawLevel >= 0
    readonly property int actualPercent: available ? Math.round(rawLevel * 100 / maximum) : 0

    function request(percent) {
        if (!available) return;
        pendingLevel = Math.max(1, Math.round(percent * maximum / 100));
        requestedLevel = percent;
        message = "";
        applyRequest();
    }

    function applyRequest() {
        if (change.running || pendingLevel < 0) return;
        const raw = pendingLevel;
        pendingLevel = -1;
        change.exec([helper, String(raw)]);
    }

    Process {
        command: [control.helper, "--device"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: control.devicePath = text.trim()
        }
    }

    FileView {
        path: control.devicePath ? control.devicePath + "/max_brightness" : ""
        printErrors: false
        onLoaded: control.maximum = Number(text().trim()) || 0
        onLoadFailed: control.maximum = 0
    }

    FileView {
        id: levelFile
        path: control.devicePath ? control.devicePath + "/brightness" : ""
        printErrors: false
        onLoaded: {
            const value = parseInt(text().trim(), 10);
            control.rawLevel = Number.isFinite(value) ? value : -1;
            if (!change.running && control.pendingLevel === -1) control.requestedLevel = -1;
        }
        onLoadFailed: control.rawLevel = -1
    }

    Timer {
        interval: 1000
        running: control.devicePath.length > 0
        repeat: true
        onTriggered: levelFile.reload()
    }

    Process {
        id: change
        onExited: exitCode => {
            if (exitCode !== 0) {
                control.requestedLevel = -1;
                control.message = "Brightness could not be changed.";
            }
            levelFile.reload();
            if (control.pendingLevel >= 0) Qt.callLater(control.applyRequest);
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: "Display brightness"
            font.weight: Font.DemiBold
        }
        Label {
            text: control.available ? Math.round(slider.pressed ? slider.value
                  : control.requestedLevel >= 0 ? control.requestedLevel
                  : control.actualPercent) + "%" : "—"
        }
    }

    ControlSlider {
        id: slider
        Layout.fillWidth: true
        from: 1
        to: 100
        stepSize: 1
        enabled: control.available
        Accessible.name: "Display brightness"
        onMoved: {
            if (pressed) control.dragLevel = value;
            else control.request(value);
        }
        onPressedChanged: {
            if (pressed) {
                control.dragLevel = -1;
            } else if (control.dragLevel >= 0) {
                const selected = control.dragLevel;
                control.dragLevel = -1;
                control.request(selected);
            }
        }

        Binding {
            target: slider
            property: "value"
            value: control.requestedLevel >= 0 ? control.requestedLevel : control.actualPercent
            when: !slider.pressed
        }
    }

    Label {
        Layout.fillWidth: true
        visible: !control.available || control.message.length > 0
        text: control.message || "No display backlight available."
        color: control.message ? control.warningColor : palette.placeholderText
        wrapMode: Text.WordWrap
    }
}
