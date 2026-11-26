import QtQuick
import QtQuick.Controls.Basic

Slider {
    id: slider

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + (slider.availableHeight - height) / 2
        width: slider.availableWidth
        height: 5
        radius: 3
        color: slider.palette.button
        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: slider.palette.highlight
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + (slider.availableHeight - height) / 2
        width: 14
        height: 14
        radius: 7
        color: slider.activeFocus ? slider.palette.text : slider.palette.highlight
        opacity: slider.enabled ? 1 : 0.45
    }
}
