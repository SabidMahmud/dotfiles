import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control
    topPadding: 6
    bottomPadding: 6
    leftPadding: 10
    rightPadding: 10
    implicitHeight: Math.max(32, implicitContentHeight + verticalPadding)

    background: Rectangle {
        radius: 5
        color: control.highlighted ? control.palette.highlight
               : control.hovered || control.down ? control.palette.mid : control.palette.button
        border.color: !control.activeFocus ? "transparent"
                      : control.highlighted ? control.palette.highlightedText : control.palette.highlight
    }

    contentItem: Text {
        text: control.text
        textFormat: Text.PlainText
        color: control.highlighted ? control.palette.highlightedText : control.palette.buttonText
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: control.enabled ? 1 : 0.55
        elide: Text.ElideRight
    }
}
