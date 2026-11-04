// Carousel geometry and mask treatment adapted from Omarchy (MIT). See OMARCHY-LICENSE.
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property string mode: Quickshell.env("THEME_PICKER_MODE") || "themes"
    readonly property string backend: Quickshell.env("THEME_PICKER_BACKEND") || ""
    property var sourceItems: []
    property int selectedIndex: -1
    property bool neighboursEnabled: false
    onSelectedIndexChanged: neighboursEnabled = false
    property var palette: ({
        base: "#1e1e2e", mantle: "#181825", surface0: "#313244",
        surface1: "#45475a", text: "#cdd6f4", subtext0: "#a6adc8", accent: "#cba6f7"
    })
    property string currentTheme: ""
    property string currentLabel: ""
    property string monitor: ""
    property bool loading: true
    property bool loadFailed: false
    property string message: ""
    property bool messageIsError: false
    property bool closeAfterApply: false
    property var applyResult: ({})
    property var pendingCache: []
    readonly property bool busy: applyProcess.running
    readonly property var selectedItem: root.selectedIndex >= 0 && root.selectedIndex < rows.count
        ? rows.get(root.selectedIndex) : null

    function dismiss() {
        if (busy) closeAfterApply = true;
        else Qt.quit();
    }

    function rebuild() {
        const previousId = selectedItem ? selectedItem.id : "";
        const query = search.text.trim().toLowerCase();
        rows.clear();
        let selected = -1;
        let active = -1;
        for (const entry of sourceItems) {
            if (query && !(entry.label + " " + entry.subtitle + " " + entry.id).toLowerCase().includes(query)) continue;
            if (entry.id === previousId) selected = rows.count;
            if (entry.isActive) active = rows.count;
            rows.append(entry);
        }
        root.selectedIndex = selected >= 0 ? selected : active >= 0 ? active : rows.count ? 0 : -1;
    }

    function startCache() {
        if (!pendingCache.length) return;
        cacheProcess.command = pendingCache;
        pendingCache = [];
        cacheProcess.running = true;
    }

    function refresh() {
        if (loadProcess.running) return;
        loading = true;
        loadFailed = false;
        loadProcess.command = ["python3", backend, mode, "--list"];
        loadProcess.running = true;
    }

    function changeMode(next) {
        if (!["themes", "wallpapers", "all-wallpapers"].includes(next)) return;
        if (mode === next || busy || loading) return;
        mode = next;
        sourceItems = [];
        rows.clear();
        message = "";
        search.text = "";
        refresh();
        search.forceActiveFocus();
    }

    function selectAdjacent(direction) {
        if (!rows.count) return;
        selectedIndex = (selectedIndex + direction + rows.count) % rows.count;
    }

    function activate() {
        if (!selectedItem || busy || loading) return;
        applyResult = {};
        message = "Applying " + selectedItem.label
            + (mode === "all-wallpapers" ? " with " + selectedItem.presetLabel : "") + "…";
        messageIsError = false;
        applyProcess.command = ["python3", backend, mode, "--apply", selectedItem.id];
        applyProcess.running = true;
    }

    Component.onCompleted: refresh()

    IpcHandler {
        target: "appearance"
        function setMode(view: string): void { root.changeMode(view); }
        function close(): void { root.dismiss(); }
        function status(): string {
            return JSON.stringify({ mode: root.mode, loading: root.loading, busy: root.busy,
                count: rows.count, currentTheme: root.currentTheme,
                selected: root.selectedItem ? root.selectedItem.id : "", message: root.message });
        }
    }

    ListModel { id: rows }

    Process {
        id: loadProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data.error) throw new Error(data.error);
                    root.currentTheme = data.currentTheme;
                    root.currentLabel = data.currentLabel;
                    root.palette = data.palette;
                    root.monitor = data.monitor;
                    root.sourceItems = data.items;
                    root.rebuild();
                    root.pendingCache = ["python3", root.backend, root.mode, "--cache"];
                    if (cacheProcess.running) cacheProcess.running = false;
                    else root.startCache();
                } catch (error) {
                    root.loadFailed = true;
                    root.message = "Could not load the gallery. " + error.message;
                    root.messageIsError = true;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.loading = false;
            if (exitCode !== 0 && !root.loadFailed) {
                root.loadFailed = true;
                root.message = "Could not load the gallery. Close it and try again.";
                root.messageIsError = true;
            }
        }
    }

    Process {
        id: cacheProcess
        stdout: SplitParser {
            onRead: line => {
                try {
                    const update = JSON.parse(line);
                    for (let i = 0; i < root.sourceItems.length; ++i) {
                        if (root.sourceItems[i].id === update.id) root.sourceItems[i].image = update.image;
                    }
                    for (let i = 0; i < rows.count; ++i) {
                        if (rows.get(i).id === update.id) rows.setProperty(i, "image", update.image);
                    }
                } catch (error) { console.warn("Thumbnail unavailable:", error.message); }
            }
        }
        onExited: root.startCache()
    }

    Process {
        id: applyProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.applyResult = JSON.parse(text); }
                catch (error) { root.applyResult = { error: "Could not apply the selection. Try again." }; }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.applyResult.ok) {
                root.message = "Applied. Choose another to compare.";
                root.messageIsError = false;
                root.refresh();
            } else {
                root.message = root.applyResult.error || "Could not apply the selection. Try again.";
                root.messageIsError = true;
            }
            if (root.closeAfterApply) Qt.quit();
        }
    }

    PanelWindow {
        id: window
        visible: true
        screen: Quickshell.screens.find(screen => screen.name === root.monitor) || Quickshell.screens[0]
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "dotfiles-theme-picker"

        // Match Omarchy's 768 x 475 preview and 108 x 432 angled neighbours.
        readonly property real scaleFactor: Math.min(1, (width - 64) / 1000, (height - 220) / 475)
        readonly property real expandedWidth: 768 * scaleFactor
        readonly property real expandedHeight: 475 * scaleFactor
        readonly property real sliceWidth: 108 * scaleFactor
        readonly property real sliceHeight: 432 * scaleFactor
        readonly property real overlap: 30 * scaleFactor
        readonly property real step: sliceWidth - overlap
        readonly property int previewRadius: Math.max(1, Math.ceil((width - expandedWidth) / (2 * step)))
        readonly property bool animate: !root.loading && Quickshell.env("THEME_PICKER_REDUCED_MOTION") !== "1"

        Shortcut { sequence: "Ctrl+1"; onActivated: root.changeMode("themes") }
        Shortcut { sequence: "Ctrl+2"; onActivated: root.changeMode("wallpapers") }
        Shortcut { sequence: "Ctrl+3"; onActivated: root.changeMode("all-wallpapers") }
        Shortcut { sequence: "Ctrl+f"; onActivated: search.forceActiveFocus() }
        Shortcut { sequence: "Escape"; onActivated: root.dismiss() }

        MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

        Item {
            id: card
            anchors.centerIn: parent
            width: parent.width - 64
            height: window.expandedHeight + 170
            MouseArea { anchors.fill: parent }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: carousel.top
                anchors.bottomMargin: 26
                spacing: 28
                Repeater {
                    model: ["themes", "wallpapers", "all-wallpapers"]
                    Text {
                        id: modeLabel
                        required property string modelData
                        text: modelData === "themes" ? "Themes" : modelData === "wallpapers" ? "Wallpapers" : "All wallpapers"
                        font.family: "monospace"
                        font.pixelSize: 15
                        font.weight: root.mode === modelData ? Font.Bold : Font.Normal
                        color: root.mode === modelData ? root.palette.accent : root.palette.text
                        style: Text.Outline
                        styleColor: root.palette.base
                        opacity: modeMouse.containsMouse || root.mode === modelData ? 1 : 0.8
                        Accessible.role: Accessible.Button
                        Accessible.name: "Browse " + text
                        Accessible.onPressAction: root.changeMode(modelData)
                        Rectangle {
                            anchors.top: parent.bottom
                            anchors.topMargin: 6
                            width: parent.width
                            height: 2
                            color: root.palette.accent
                            visible: root.mode === modeLabel.modelData
                        }
                        MouseArea {
                            id: modeMouse
                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.changeMode(modeLabel.modelData)
                        }
                    }
                }
            }

            Item {
                id: carousel
                width: parent.width
                height: window.expandedHeight
                anchors.top: parent.top
                anchors.topMargin: 20
                readonly property real previewX: (width - window.expandedWidth) / 2

                Repeater {
                    model: rows
                    delegate: Item {
                        id: slice
                        required property int index
                        required property var model
                        readonly property int relative: index - root.selectedIndex
                        readonly property bool selected: index === root.selectedIndex
                        readonly property real skew: 28 * window.scaleFactor
                        visible: Math.abs(relative) <= window.previewRadius
                        x: selected ? carousel.previewX : relative < 0
                            ? carousel.previewX + relative * window.step
                            : carousel.previewX + window.expandedWidth - window.overlap + (relative - 1) * window.step
                        y: selected ? 0 : (window.expandedHeight - window.sliceHeight) / 2
                        width: selected ? window.expandedWidth : window.sliceWidth
                        height: selected ? window.expandedHeight : window.sliceHeight
                        z: selected ? 100 : 50 - Math.abs(relative)
                        Behavior on x { enabled: window.animate; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        Behavior on y { enabled: window.animate; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        Behavior on width { enabled: window.animate; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        Behavior on height { enabled: window.animate; NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                        Loader {
                            anchors.fill: parent
                            active: slice.visible
                            sourceComponent: Item {
                                Item {
                                    id: maskShape
                                    anchors.fill: parent
                                    visible: false
                                    layer.enabled: true
                                    Shape {
                                        anchors.fill: parent
                                        antialiasing: true
                                        preferredRendererType: Shape.CurveRenderer
                                        ShapePath {
                                            fillColor: "white"
                                            strokeColor: "transparent"
                                            startX: slice.skew; startY: 0
                                            PathLine { x: slice.width; y: 0 }
                                            PathLine { x: slice.width - slice.skew; y: slice.height }
                                            PathLine { x: 0; y: slice.height }
                                            PathLine { x: slice.skew; y: 0 }
                                        }
                                    }
                                }
                                Item {
                                    anchors.fill: parent
                                    layer.enabled: true
                                    layer.smooth: true
                                    layer.effect: MultiEffect {
                                        maskEnabled: true
                                        maskSource: maskShape
                                        maskThresholdMin: 0.3
                                        maskSpreadAtMin: 0.3
                                    }
                                    Rectangle { anchors.fill: parent; color: root.palette.base }
                                    Image {
                                        id: previewImage
                                        anchors.fill: parent
                                        // Decode the selected image first so neighbours cannot
                                        // queue a large original ahead of the main preview.
                                        source: (slice.selected || root.neighboursEnabled) && slice.model.image
                                            ? slice.model.image : ""
                                        sourceSize: Qt.size(960, 600)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: false
                                        smooth: true
                                        onStatusChanged: {
                                            if (slice.selected && (status === Image.Ready || status === Image.Error))
                                                root.neighboursEnabled = true;
                                        }
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        visible: slice.selected && (!slice.model.image || previewImage.status === Image.Error)
                                        text: "Preview unavailable"
                                        font.family: "monospace"
                                        font.pixelSize: 16
                                        color: root.palette.text
                                    }
                                    Rectangle {
                                        anchors.fill: parent
                                        color: root.palette.base
                                        opacity: slice.selected ? 0 : 0.42
                                    }
                                }
                                Shape {
                                    anchors.fill: parent
                                    antialiasing: true
                                    preferredRendererType: Shape.CurveRenderer
                                    ShapePath {
                                        fillColor: "transparent"
                                        strokeColor: slice.selected ? root.palette.accent : root.palette.surface1
                                        strokeWidth: slice.selected ? 3 : 1
                                        startX: slice.skew; startY: 0
                                        PathLine { x: slice.width; y: 0 }
                                        PathLine { x: slice.width - slice.skew; y: slice.height }
                                        PathLine { x: 0; y: slice.height }
                                        PathLine { x: slice.skew; y: 0 }
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    enabled: !root.loading
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (slice.selected) root.activate();
                                        else root.selectedIndex = slice.index;
                                        search.forceActiveFocus();
                                    }
                                }
                            }
                        }
                        Accessible.role: Accessible.Button
                        Accessible.name: model.label
                            + (root.mode === "all-wallpapers" ? ", " + model.presetLabel : "")
                            + (model.isActive ? ", current" : "")
                        Accessible.description: root.mode === "all-wallpapers"
                            ? "Select to preview, then press Enter to apply the wallpaper and matching theme."
                            : "Select to preview, then press Enter to apply."
                        Accessible.onPressAction: {
                            if (selected) root.activate();
                            else root.selectedIndex = index;
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    width: window.expandedWidth
                    visible: rows.count === 0
                    text: root.loading ? "Loading previews…" : root.loadFailed ? "Gallery unavailable"
                        : search.text ? "No matches. Try another search."
                        : root.mode === "all-wallpapers" ? "No wallpapers found in the theme collection."
                        : root.mode === "wallpapers" && !root.currentTheme ? "Choose a theme to see its wallpapers."
                        : "No wallpapers found for this theme."
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "monospace"
                    font.pixelSize: 18
                    color: root.palette.text
                    style: Text.Outline
                    styleColor: root.palette.base
                }
            }

            Column {
                anchors.top: carousel.bottom
                anchors.topMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                width: window.expandedWidth
                spacing: 10
                Text {
                    width: parent.width
                    text: root.selectedItem ? root.selectedItem.label : ""
                    font.family: "monospace"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    color: root.palette.text
                    style: Text.Outline
                    styleColor: root.palette.base
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: root.selectedItem ? (root.mode === "all-wallpapers" ? root.selectedItem.presetLabel + " · " : "")
                        + (root.selectedItem.isActive ? "Current · " : "")
                        + (root.selectedIndex + 1) + " / " + rows.count : ""
                    font.family: "monospace"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    color: root.palette.text
                    style: Text.Outline
                    styleColor: root.palette.base
                    elide: Text.ElideRight
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(380, parent.width)
                    height: 32
                    radius: 4
                    color: root.palette.base
                    border.width: search.text ? 1 : 0
                    border.color: root.palette.surface1
                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.margins: 6
                        focus: true
                        font.family: "monospace"
                        font.pixelSize: 14
                        color: root.palette.text
                        selectionColor: root.palette.accent
                        selectedTextColor: root.palette.base
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        Accessible.name: root.mode === "themes" ? "Filter themes"
                            : root.mode === "all-wallpapers" ? "Filter wallpapers or matching themes" : "Filter wallpapers"
                        onTextChanged: root.rebuild()
                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Left || event.key === Qt.Key_Up
                                || event.key === Qt.Key_Backtab) {
                                root.selectAdjacent(-1); event.accepted = true;
                            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                root.selectAdjacent(1); event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.activate(); event.accepted = true;
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: !search.text && !search.preeditText
                        text: root.mode === "themes" ? "Type to filter themes"
                            : root.mode === "all-wallpapers" ? "Filter by wallpaper or theme" : "Type to filter wallpapers"
                        font.family: "monospace"
                        font.pixelSize: 13
                        color: root.palette.subtext0
                    }
                }
                Text {
                    width: parent.width
                    text: root.message || "Left / Right to browse · Enter to apply · Esc to close"
                    font.family: "monospace"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    color: root.messageIsError ? root.palette.text : root.palette.text
                    style: Text.Outline
                    styleColor: root.palette.base
                    wrapMode: Text.WordWrap
                    Accessible.role: Accessible.AlertMessage
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20
                    Repeater {
                        model: root.loadFailed ? ["Retry", "Close"] : [root.busy ? "Applying…"
                            : root.mode === "all-wallpapers" ? "Apply wallpaper + theme" : "Apply", "Close"]
                        Text {
                            id: action
                            required property string modelData
                            text: modelData
                            font.family: "monospace"
                            font.pixelSize: 13
                            font.underline: actionMouse.containsMouse
                            color: root.palette.text
                            style: Text.Outline
                            styleColor: root.palette.base
                            Accessible.role: Accessible.Button
                            Accessible.name: modelData
                            Accessible.onPressAction: actionMouse.clicked(null)
                            MouseArea {
                                id: actionMouse
                                anchors.fill: parent
                                anchors.margins: -6
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: action.modelData === "Close" || (!root.busy && !root.loading)
                                onClicked: {
                                    if (action.modelData === "Close") root.dismiss();
                                    else if (action.modelData === "Retry") root.refresh();
                                    else root.activate();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
