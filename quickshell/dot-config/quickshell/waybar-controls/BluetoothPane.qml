import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell.Bluetooth

ColumnLayout {
    id: pane
    spacing: 5

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: (adapter?.devices.values || []).filter(device => device.paired)
        .sort((a, b) => Number(b.connected) - Number(a.connected) || a.name.localeCompare(b.name))
    property var pendingDevice: null
    property string message: ""

    Connections {
        target: pane.pendingDevice
        function onConnectedChanged() { pane.pendingDevice = null; }
    }

    Timer {
        running: pane.pendingDevice !== null
        interval: 12000
        onTriggered: {
            pane.pendingDevice = null;
            pane.message = "The device did not respond. Check that it is nearby and try again.";
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label { Layout.fillWidth: true; text: "Paired devices" }
        ControlButton {
            text: pane.adapter?.enabled ? "Turn Bluetooth off" : "Turn Bluetooth on"
            enabled: pane.adapter !== null
            onClicked: {
                pane.pendingDevice = null;
                pane.message = "";
                pane.adapter.enabled = !pane.adapter.enabled;
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: pane.message.length > 0 || !pane.adapter?.enabled || pane.devices.length === 0
        text: pane.message || (!pane.adapter ? "No Bluetooth adapter available."
              : !pane.adapter.enabled ? "Bluetooth is off." : "No paired devices.")
        color: palette.placeholderText
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: pane.adapter?.enabled ? pane.devices : []
        DeviceRow {
            required property var modelData
            readonly property bool changing: pane.pendingDevice === modelData
                || modelData.state === BluetoothDeviceState.Connecting
                || modelData.state === BluetoothDeviceState.Disconnecting
            Layout.fillWidth: true
            text: modelData.name
            detail: modelData.connected ? "Connected" : "Paired"
            actionLabel: changing ? "Working…" : modelData.connected ? "Disconnect" : "Connect"
            enabled: !pane.pendingDevice && !changing
            current: modelData.connected
            onClicked: {
                pane.message = "";
                pane.pendingDevice = modelData;
                modelData.connected = !modelData.connected;
            }
        }
    }
}
