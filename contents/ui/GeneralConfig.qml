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
    property alias cfg_customDateFormat: customDateFormat.text
    property alias cfg_disableAnimations: disableAnimations.checked
    property alias cfg_disableColonBlink: disableColonBlink.checked
    property alias cfg_colonBlinkEasing: colonBlinkEasing.currentIndex

    component ColorButton: Row {
        property string configProp
        property string defaultColor
        property var dialog
        spacing: 4
        
        Rectangle {
            id: colorPreview
            color: configRoot["cfg_" + configProp]
            border.color: "#B3FFFFFF"
            border.width: 1
            width: 64
            radius: 4
            height: 24
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    parent.parent.dialog.selectedColor = colorPreview.color
                    parent.parent.dialog.open()
                }
            }
        }
        
        Button {
            text: "\u{1F50D}"  // 🔍 magnifying glass
            width: 28
            height: 24
            ToolTip.visible: hovered
            ToolTip.text: i18n("Pick color from screen")
            onClicked: {
                var prop = configProp
                // Use kcolorchooser if available for reliable screen picking
                var process = Qt.createQmlObject('
                    import QtQuick
                    import org.kde.plasma.plasma5support as Plasma5Support
                    Plasma5Support.DataSource { engine: "executable" }
                ', parent)
                process.connectedSources = ["kcolorchooser --pick"]
                process.newData.connect(function(sourceName, data) {
                    if (data["exit code"] === 0) {
                        var output = data.stdout.trim()
                        if (output) {
                            configRoot["cfg_" + prop] = output
                            configRoot.configurationChanged()
                        }
                    }
                })
            }
        }
        
        Button {
            text: "\u{21BA}"  // ↺ reset/undo arrow
            width: 28
            height: 24
            ToolTip.visible: hovered
            ToolTip.text: i18n("Reset to default")
            onClicked: {
                configRoot["cfg_" + configProp] = defaultColor
                configRoot.configurationChanged()
            }
        }
        
        Component.onCompleted: {
            var prop = configProp  // Capture in local scope
            dialog = Qt.createQmlObject('
                import QtQuick
                import QtQuick.Dialogs
                ColorDialog { options: ColorDialog.ShowAlphaChannel }
            ', this)
            dialog.accepted.connect(function() {
                var propName = "cfg_" + prop
                var colorStr = dialog.selectedColor.toString()
                console.log("Setting", propName, "to", colorStr)
                configRoot[propName] = colorStr
                configRoot.configurationChanged()
            })
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 12

            GridLayout{
                Layout.fillWidth: true
                columns: 2

            // Time colors
            Label { text: i18n("Hour (top):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "hourColorTop"; defaultColor: "#78C3FB" }
            
            Label { text: i18n("Hour (bottom):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "hourColorBottom"; defaultColor: "#3A66F9" }
            
            Label { text: i18n("Colon:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "colonColor"; defaultColor: "#DDDDDD" }
            
            Label { text: i18n("Minute (top):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "minuteColorTop"; defaultColor: "#F9A55A" }
            
            Label { text: i18n("Minute (bottom):"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "minuteColorBottom"; defaultColor: "#F25576" }
            
            Label { text: i18n("Seconds:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "secondsColor"; defaultColor: "#4DD8C8" }
            
            Label { text: i18n("Date:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "dateColor"; defaultColor: "#CC73E1" }
            
            Label { text: i18n("Prefix text:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "prefixColor"; defaultColor: "#AAAAAA" }
            
            Label { text: i18n("Background rect:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "rectColor"; defaultColor: "#00001B" }
            
            Label { text: i18n("Glow:"); Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight }
            ColorButton { configProp: "glowColor"; defaultColor: "#9747c7" }

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

            // Custom date format
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Date format:") }
            TextField { id: customDateFormat; placeholderText: i18n("Qt date format (e.g., ddd d M yy, dd/MM/yyyy)"); onEditingFinished: configRoot.configurationChanged() }

            // Disable animations
            Label { Layout.minimumWidth: configRoot.width/2 }
            CheckBox { id: disableAnimations; text: i18n("Disable animations"); onToggled: configRoot.configurationChanged() }

            // Disable colon blink
            Label { Layout.minimumWidth: configRoot.width/2 }
            CheckBox { id: disableColonBlink; text: i18n("Disable colon blink"); onToggled: configRoot.configurationChanged() }

            // Colon blink easing type
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Colon blink easing:") }
            ComboBox {
                id: colonBlinkEasing
                model: ["InOutQuad (smooth)", "Linear", "InQuad", "OutQuad", "InOutCubic", "InOutSine", "InOutExpo (dramatic)", "Instant"]
                onCurrentIndexChanged: configRoot.configurationChanged()
            }
            }
        }
    }

}
