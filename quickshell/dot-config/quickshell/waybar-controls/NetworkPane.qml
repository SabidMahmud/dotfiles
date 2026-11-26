import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

ColumnLayout {
    id: pane
    spacing: 5

    required property color warningColor
    readonly property var wifiDevices: Networking.devices.values.filter(
        device => device.type === DeviceType.Wifi && device.nmManaged)
    readonly property var wifi: wifiDevices.find(device => device.connected) || wifiDevices[0] || null
    readonly property var networks: (wifi?.networks.values || []).filter(network => network.name)
        .sort((a, b) => Number(b.connected) - Number(a.connected)
                      || Number(b.known) - Number(a.known) || a.name.localeCompare(b.name))
    readonly property bool wired: Networking.devices.values.some(
        device => device.type === DeviceType.Wired && device.connected)
    property var pendingNetwork: null
    property var passwordNetwork: null
    property string message: ""

    function needsPassword(network) {
        return [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae]
               .includes(network.security);
    }

    function select(network) {
        message = "";
        if (!network.connected && !network.known && needsPassword(network)) {
            passwordNetwork = network;
            return;
        }
        if (!network.connected && !network.known
            && ![WifiSecurityType.Open, WifiSecurityType.Owe].includes(network.security)) {
            Quickshell.execDetached(["nm-connection-editor"]);
            Qt.quit();
            return;
        }
        pendingNetwork = network;
        if (network.connected) network.disconnect();
        else network.connect();
    }

    function submitPassword() {
        if (!passwordNetwork || !password.text.length) return;
        pendingNetwork = passwordNetwork;
        passwordNetwork.connectWithPsk(password.text);
        password.clear();
        passwordNetwork = null;
    }

    Binding {
        target: pane.wifi
        property: "scannerEnabled"
        value: Networking.wifiEnabled && Networking.wifiHardwareEnabled
        when: pane.wifi !== null
    }

    Connections {
        target: pane.pendingNetwork
        function onConnectedChanged() { pane.pendingNetwork = null; }
        function onConnectionFailed(reason) {
            const network = pane.pendingNetwork;
            pane.pendingNetwork = null;
            if (reason === ConnectionFailReason.NoSecrets && pane.needsPassword(network)) {
                pane.message = "Enter the Wi-Fi password to connect.";
                pane.passwordNetwork = network;
            } else {
                pane.message = "Could not connect. Try again or open Network settings.";
            }
        }
    }

    Timer {
        running: pane.pendingNetwork !== null
        interval: 18000
        onTriggered: {
            pane.pendingNetwork = null;
            pane.message = "NetworkManager has not finished. Check Network settings.";
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: pane.wired ? "Ethernet connected" : "Wi-Fi"
        }
        ControlButton {
            text: Networking.wifiEnabled ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
            enabled: pane.wifi !== null && Networking.wifiHardwareEnabled
            onClicked: {
                pane.pendingNetwork = null;
                pane.passwordNetwork = null;
                pane.message = "";
                password.clear();
                Networking.wifiEnabled = !Networking.wifiEnabled;
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: pane.message.length > 0
        text: pane.message
        color: pane.warningColor
        wrapMode: Text.WordWrap
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: pane.passwordNetwork !== null
        onVisibleChanged: if (visible) password.forceActiveFocus()
        Label {
            Layout.fillWidth: true
            text: pane.passwordNetwork ? "Password for " + pane.passwordNetwork.name : ""
            textFormat: Text.PlainText
            elide: Text.ElideRight
        }
        TextField {
            id: password
            Layout.fillWidth: true
            placeholderText: "Wi-Fi password"
            Accessible.name: "Wi-Fi password"
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            onAccepted: pane.submitPassword()
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            ControlButton {
                text: "Cancel"
                onClicked: {
                    password.clear();
                    pane.message = "";
                    pane.passwordNetwork = null;
                }
            }
            ControlButton {
                text: "Connect"
                highlighted: true
                enabled: password.text.length > 0
                onClicked: pane.submitPassword()
            }
        }
    }

    Label {
        Layout.fillWidth: true
        visible: pane.passwordNetwork === null && (!Networking.wifiEnabled
                 || pane.wifi === null || pane.networks.length === 0)
        text: pane.wifi === null ? "No Wi-Fi adapter available."
              : !Networking.wifiHardwareEnabled ? "Wi-Fi is blocked by the hardware switch."
              : !Networking.wifiEnabled ? "Wi-Fi is off."
              : "Looking for nearby networks…"
        color: palette.placeholderText
        wrapMode: Text.WordWrap
    }

    Repeater {
        model: pane.passwordNetwork === null && Networking.wifiEnabled ? pane.networks : []
        DeviceRow {
            required property var modelData
            Layout.fillWidth: true
            text: modelData.name
            detail: (modelData.connected ? "Connected" : modelData.known ? "Saved"
                    : modelData.security === WifiSecurityType.Open ? "Open" : "Secured")
                    + " · " + Math.round(modelData.signalStrength * 100) + "% signal"
            actionLabel: modelData.stateChanging || pane.pendingNetwork === modelData
                         ? "Working…" : modelData.connected ? "Disconnect" : "Connect"
            enabled: !pane.pendingNetwork && !modelData.stateChanging
            current: modelData.connected
            onClicked: pane.select(modelData)
        }
    }
}
