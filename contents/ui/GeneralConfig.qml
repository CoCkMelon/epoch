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
    property alias cfg_customPrefixText: customPrefixText.text

    ColorDialog {
        id: colorDialog
    }

    ColumnLayout {
        spacing: 12

        GridLayout{
            columns: 2

            // Opacity
            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Opacity:")
                horizontalAlignment: Text.AlignRight
            }
            SpinBox{
                id: porcetageOpacity
                from: 0
                to: 100
                stepSize: 10
                editable: true
                validator: IntValidator { bottom: 0; top: 100 }
                onValueChanged: configRoot.configurationChanged()
            }

            // Color
            Label {
                Layout.minimumWidth: configRoot.width/2
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
            Connections {
                target: colorDialog
                function onAccepted() { configRoot.configurationChanged() }
            }

            // 12h format
            Label { Layout.minimumWidth: configRoot.width/2 }
            CheckBox { id: horsFormat; text: i18n("12 Hour Format"); onToggled: configRoot.configurationChanged() }

            // Active text
            Label { Layout.minimumWidth: configRoot.width/2 }
            CheckBox { id: activeText; text: i18n("Active Text:"); onToggled: configRoot.configurationChanged() }

            // Show rectangle
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Show background rectangle:") }
            CheckBox { id: enableRect; checked: true; onToggled: configRoot.configurationChanged() }

            // Enable glow
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Enable glow:") }
            CheckBox { id: enableGlow; checked: true; onToggled: configRoot.configurationChanged() }

            // Overflow top (px)
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Top overflow (px):") }
            SpinBox { id: overflowTop; from: -100; to: 200; stepSize: 1; onValueChanged: configRoot.configurationChanged() }

            // Overflow bottom (px)
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Bottom overflow (px):") }
            SpinBox { id: overflowBottom; from: -100; to: 200; stepSize: 1; value: 16; onValueChanged: configRoot.configurationChanged() }
            // Click command
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Command on time click:") }
            TextField { id: clickCommand; placeholderText: i18n("e.g. kalendar, gnome-calendar, thunderbird -calendar"); onEditingFinished: configRoot.configurationChanged() }

            // Custom prefix text
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Custom prefix text:") }
            TextField { id: customPrefixText; placeholderText: i18n("Leave empty to use auto-detected locale text"); onEditingFinished: configRoot.configurationChanged() }
        }
    }

}
