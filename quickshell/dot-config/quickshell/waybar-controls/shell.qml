import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property var sections: [
        { key: "network", title: "Network", page: network,
          settings: ["Network settings", "nm-connection-editor"] },
        { key: "sound", title: "Sound", page: sound,
          settings: ["Sound mixer", "pavucontrol"] },
        { key: "bluetooth", title: "Bluetooth", page: bluetooth,
          settings: ["Pair & manage devices", "blueman-manager"] },
        { key: "device", title: "Device", page: device }
    ]
    readonly property string requestedSection: Quickshell.env("WAYBAR_CONTROL_SECTION") || "network"
    property int section: Math.max(0, sections.findIndex(tab => tab.key ===
        (["brightness", "power"].includes(requestedSection) ? "device" : requestedSection)))
    readonly property var currentSection: sections[section]
    property var colors: ({ base: "#1e1e2e", surface: "#313244", text: "#cdd6f4",
                            secondary: "#a6adc8", accent: "#89b4fa", warning: "#f9e2af" })

    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config")
              + "/waybar/theme.css"
        onLoaded: {
            const names = { base: "base", surface: "surface0", text: "text",
                            secondary: "subtext0", accent: "blue", warning: "yellow" };
            const next = Object.assign({}, root.colors);
            const css = text();
            for (const key of Object.keys(names)) {
                const match = css.match(new RegExp("@define-color\\s+" + names[key]
                                                    + "\\s+(#[0-9a-fA-F]{6})\\s*;"));
                if (match) next[key] = match[1];
            }
            root.colors = next;
        }
    }

    PanelWindow {
        id: window
        screen: Quickshell.screens.find(screen => screen.name === I3.focusedMonitor?.name)
                || Quickshell.screens[0]
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "dotfiles-waybar-controls"

        Shortcut { sequence: "Escape"; onActivated: Qt.quit() }
        MouseArea { anchors.fill: parent; onClicked: Qt.quit() }

        Pane {
            id: panel
            anchors { top: parent.top; right: parent.right; topMargin: 36; rightMargin: 8 }
            width: Math.min(390, window.width - 16)
            height: Math.min(432, window.height - 44,
                             Math.max(188, (body.item?.implicitHeight || 0) + tabs.implicitHeight
                                      + 2 * padding + 21 + (settings.visible ? settings.implicitHeight + 10 : 0)))
            padding: 12
            font.pixelSize: 14

            palette {
                window: root.colors.base
                base: root.colors.base
                text: root.colors.text
                windowText: root.colors.text
                button: root.colors.surface
                buttonText: root.colors.text
                placeholderText: root.colors.secondary
                highlight: root.colors.accent
                highlightedText: root.colors.base
                mid: Qt.tint(root.colors.surface, Qt.alpha(root.colors.text, 0.12))
            }

            background: Rectangle {
                color: panel.palette.window
                border.color: panel.palette.mid
                radius: 8
                MouseArea { anchors.fill: parent }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    id: tabs
                    spacing: 5
                    Repeater {
                        model: root.sections
                        ControlButton {
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            text: modelData.title
                            highlighted: root.section === index
                            onClicked: root.section = index
                            Component.onCompleted: if (highlighted) forceActiveFocus()
                        }
                    }
                    ControlButton {
                        text: "×"
                        Accessible.name: "Close"
                        onClicked: Qt.quit()
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: panel.palette.button }

                ScrollView {
                    id: scroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    Loader {
                        id: body
                        width: scroll.availableWidth
                        sourceComponent: root.currentSection.page
                    }
                }

                ControlButton {
                    id: settings
                    Layout.alignment: Qt.AlignRight
                    visible: !!root.currentSection.settings
                    text: root.currentSection.settings?.[0] || ""
                    onClicked: {
                        Quickshell.execDetached([root.currentSection.settings[1]]);
                        Qt.quit();
                    }
                }
            }
        }
    }

    Component { id: network; NetworkPane { warningColor: root.colors.warning } }
    Component { id: sound; SoundPane {} }
    Component { id: bluetooth; BluetoothPane {} }
    Component {
        id: device
        ColumnLayout {
            spacing: 8
            BrightnessControl { Layout.fillWidth: true; warningColor: root.colors.warning }
            Rectangle { Layout.fillWidth: true; height: 1; color: palette.button }
            PowerPane { Layout.fillWidth: true; warningColor: root.colors.warning }
        }
    }
}
