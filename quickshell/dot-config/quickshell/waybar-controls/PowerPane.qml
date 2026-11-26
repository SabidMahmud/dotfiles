import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower

ColumnLayout {
    id: pane
    spacing: 5

    required property color warningColor
    property bool available: false
    property int requestedProfile: -1
    property string message: ""

    readonly property var profiles: [
        { value: PowerProfile.PowerSaver, name: "Power Saver", detail: "Uses less power" },
        { value: PowerProfile.Balanced, name: "Balanced", detail: "Balances speed and battery life" },
        { value: PowerProfile.Performance, name: "Performance", detail: "Prioritizes speed" }
    ].filter(profile => profile.value !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    Process {
        id: checkService
        command: ["busctl", "--system", "--timeout=3s", "get-property",
                  "org.freedesktop.UPower.PowerProfiles", "/org/freedesktop/UPower/PowerProfiles",
                  "org.freedesktop.UPower.PowerProfiles", "ActiveProfile"]
        running: true
        onExited: exitCode => pane.available = exitCode === 0
    }

    Connections {
        target: PowerProfiles
        function onProfileChanged() {
            if (PowerProfiles.profile === pane.requestedProfile) pane.requestedProfile = -1;
        }
    }

    Timer {
        running: pane.requestedProfile !== -1
        interval: 4000
        onTriggered: {
            pane.requestedProfile = -1;
            pane.message = "The profile did not change. Try again.";
        }
    }

    Label {
        Layout.fillWidth: true
        visible: !pane.available || pane.message.length > 0
        text: pane.message || (checkService.running ? "Loading power profiles…"
                                                    : "The power profiles service is unavailable.")
        color: pane.message ? pane.warningColor : palette.placeholderText
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: pane.available ? pane.profiles : []
        DeviceRow {
            required property var modelData
            Layout.fillWidth: true
            text: modelData.name
            detail: modelData.detail
            current: PowerProfiles.profile === modelData.value
            actionLabel: current ? "Active" : pane.requestedProfile === modelData.value
                                    ? "Switching…" : "Select"
            enabled: !current && pane.requestedProfile === -1
            onClicked: {
                pane.message = "";
                pane.requestedProfile = modelData.value;
                PowerProfiles.profile = modelData.value;
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: pane.available && PowerProfiles.profile === PowerProfile.Performance
                 && PowerProfiles.degradationReason !== PerformanceDegradationReason.None
        text: PowerProfiles.degradationReason === PerformanceDegradationReason.LapDetected
              ? "Performance is limited while the laptop is on your lap."
              : "Performance is limited while the laptop cools down."
        color: pane.warningColor
        wrapMode: Text.WordWrap
    }
}
