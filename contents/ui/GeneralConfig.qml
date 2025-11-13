import QtQuick
import Qt.labs.platform
import QtQuick.Controls
import QtQuick.Layouts 1.11

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_opacity: porcetageOpacity.value
    property alias cfg_customColor: colorDialog.color
    property alias cfg_hourFormat: horsFormat.checked
    property alias cfg_activeText: activeText.checked

    // New config bindings
    property alias cfg_enableGlow: enableGlow.checked
    property alias cfg_enableRect: enableRect.checked
    property alias cfg_overflowTop: overflowTop.value
    property alias cfg_overflowBottom: overflowBottom.value
    property alias cfg_clickCommand: clickCommand.text

    ColorDialog {
        id: colorDialog
    }

    ColumnLayout {
        spacing: units.smallSpacing * 2

        GridLayout{
            columns: 2

            // Opacity
            Label {
                Layout.minimumWidth: root.width/2
                text: i18n("Opacity:")
                horizontalAlignment: Text.AlignRight
            }
            SpinBox{
                id: porcetageOpacity
                from: 30
                to: 100
                stepSize: 10
            }

            // Color
            Label {
                Layout.minimumWidth: root.width/2
                horizontalAlignment: Label.AlignRight
                text: i18n("Color:")
            }
            Rectangle {
                id: colorhex
                color: colorDialog.color
                border.color: "#B3FFFFFF"
                border.width: 1
                width: 64
                radius: 4
                height: 24
                MouseArea {
                    anchors.fill: parent
                    onClicked: colorDialog.open()
                }
            }

            // 12h format
            Label { Layout.minimumWidth: root.width/2 }
            CheckBox { id: horsFormat; text: i18n("12 Hour Format") }

            // Active text
            Label { Layout.minimumWidth: root.width/2 }
            CheckBox { id: activeText; text: i18n("Active Text:") }

            // Show rectangle
            Label { Layout.minimumWidth: root.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Show background rectangle:") }
            CheckBox { id: enableRect; checked: true }

            // Enable glow
            Label { Layout.minimumWidth: root.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Enable glow:") }
            CheckBox { id: enableGlow; checked: true }

            // Overflow top (px)
            Label { Layout.minimumWidth: root.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Top overflow (px):") }
            SpinBox { id: overflowTop; from: -100; to: 200; stepSize: 1 }

            // Overflow bottom (px)
            Label { Layout.minimumWidth: root.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Bottom overflow (px):") }
            SpinBox { id: overflowBottom; from: -100; to: 200; stepSize: 1; value: 16 }

            // Click command
            Label { Layout.minimumWidth: root.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Command on time click:") }
            TextField { id: clickCommand; placeholderText: i18n("e.g. kalendar, gnome-calendar, thunderbird -calendar") }
        }
    }

}

}
