import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Button {
    id: row
    property string detail
    property string actionLabel
    property bool current
    leftPadding: 10
    rightPadding: 10
    topPadding: 6
    bottomPadding: 6
    implicitHeight: Math.max(34, implicitContentHeight + verticalPadding)
    Accessible.name: [text, detail, actionLabel].filter(Boolean).join(", ")

    background: Rectangle {
        radius: 5
        color: row.hovered || row.down ? row.palette.mid
               : row.current ? row.palette.button : "transparent"
        border.color: row.activeFocus ? row.palette.highlight : "transparent"
    }

    contentItem: RowLayout {
        spacing: 12
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Label {
                Layout.fillWidth: true
                text: row.text
                textFormat: Text.PlainText
                elide: Text.ElideRight
            }
            Label {
                Layout.fillWidth: true
                visible: row.detail.length > 0
                text: row.detail
                textFormat: Text.PlainText
                color: row.palette.placeholderText
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
        Label {
            text: row.actionLabel
            color: row.enabled ? row.palette.highlight : row.palette.placeholderText
            font.pixelSize: 12
        }
    }
}
