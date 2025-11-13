import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.11
import QtQuick.Dialogs

Item {
    id: configRoot

    signal configurationChanged

    property string cfg_hourColorTop: "#78C3FB"
    property string cfg_hourColorBottom: "#3A66F9"
    property string cfg_colonColor: "#DDDDDD"
    property string cfg_minuteColorTop: "#F9A55A"
    property string cfg_minuteColorBottom: "#F25576"
    property string cfg_secondsColor: "#4DD8C8"
    property string cfg_dateColor: "#CC73E1"
    property string cfg_prefixColor: "#AAAAAA"
    property string cfg_rectColor: "#00001B"
    property string cfg_glowColor: "#9747c7"
    property alias cfg_hourFormat: horsFormat.checked
    property alias cfg_activeText: activeText.checked

    // New config bindings
    property alias cfg_enableGlow: enableGlow.checked
    property alias cfg_enableRect: enableRect.checked
    property alias cfg_overflowTop: overflowTop.value
    property alias cfg_overflowBottom: overflowBottom.value
    property alias cfg_clickCommand: clickCommand.text
    property alias cfg_customPrefixText: customPrefixText.text

    component ColorButton: Rectangle {
        property string configProp
        property var dialog
        
        // Bind button color to config value
        color: configRoot["cfg_" + configProp]
        border.color: "#B3FFFFFF"
        border.width: 1
        width: 64
        radius: 4
        height: 24
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                // Set dialog color before opening
                parent.dialog.selectedColor = parent.color
                parent.dialog.open()
            }
        }
        
        Component.onCompleted: {
            dialog = Qt.createQmlObject('
                import QtQuick
                import QtQuick.Dialogs
                ColorDialog { options: ColorDialog.ShowAlphaChannel }
            ', parent)
            dialog.accepted.connect(function() {
                // Update config property
                configRoot["cfg_" + parent.configProp] = dialog.selectedColor.toString()
                configRoot.configurationChanged()
                // Force button to update
                parent.color = Qt.binding(function() { return configRoot["cfg_" + parent.configProp] })
            })
        }
    }

    ColumnLayout {
        spacing: 12

        GridLayout{
            columns: 2

            // Time colors
            Label { text: i18n("Hour (top):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: hourTop; configProp: "hourColorTop" }
            
            Label { text: i18n("Hour (bottom):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: hourBottom; configProp: "hourColorBottom" }
            
            Label { text: i18n("Colon:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: colon; configProp: "colonColor" }
            
            Label { text: i18n("Minute (top):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: minuteTop; configProp: "minuteColorTop" }
            
            Label { text: i18n("Minute (bottom):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: minuteBottom; configProp: "minuteColorBottom" }
            
            Label { text: i18n("Seconds:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: seconds; configProp: "secondsColor" }
            
            Label { text: i18n("Date:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: date; configProp: "dateColor" }
            
            Label { text: i18n("Prefix text:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: prefix; configProp: "prefixColor" }
            
            Label { text: i18n("Background rect:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: rect; configProp: "rectColor" }
            
            Label { text: i18n("Glow:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { id: glow; configProp: "glowColor" }

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
