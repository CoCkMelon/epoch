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
    property real cfg_yearOffset: 0
    property alias cfg_eraLabel: eraLabel.text
    property alias cfg_showEraLabel: showEraLabel.checked

    // Ready-made era presets. Add your own { name, label, offset } entries here:
    // "offset" is added to the Gregorian year, "label" is shown after the date.
    // offset: null means "Custom" (use whatever offset/label are typed below).
    property var eraPresets: [
        { name: i18n("Anno Domini"), label: "AD", offset: 0 },
        { name: i18n("Ab urbe condita (Rome)"), label: "AUC", offset: 753 },
        { name: i18n("Byzantine era"), label: "AM", offset: 5508 },
        { name: i18n("Reiwa era"), label: "R", offset: -2018 },
        { name: i18n("Hebrew calendar"), label: "HE", offset: 3760 },
        { name: i18n("Islamic calendar (Hijri)"), label: "AH", offset: -579 },
        { name: i18n("Persian calendar (Solar Hijri)"), label: "SH", offset: -622 },
        { name: i18n("Buddhist calendar (Thai)"), label: "BE", offset: 543 },
        { name: i18n("Ethiopian calendar"), label: "EC", offset: -8 },
        { name: i18n("Coptic calendar"), label: "Coptic", offset: -284 },
        { name: i18n("Bahá'í calendar"), label: "B.E.", offset: -1844 },
        { name: i18n("Vikram Samvat"), label: "VS", offset: 57 },
        { name: i18n("Saka era"), label: "Saka", offset: -78 },
        { name: i18n("Kali Yuga"), label: "KY", offset: 3102 },
        { name: i18n("Nanakshahi calendar"), label: "NS", offset: -1468 },
        { name: i18n("Seleucid era"), label: "SE", offset: 311 },
        { name: i18n("Armenian calendar"), label: "AMT", offset: -551 },
        { name: i18n("French Republican calendar"), label: "An", offset: -1792 },
        { name: i18n("Masonic era (Anno Lucis)"), label: "AL", offset: 4000 },
        { name: i18n("Dangi calendar"), label: "Dangi", offset: 2333 },
        { name: i18n("Minguo calendar"), label: "Minguo", offset: -1911 },
        { name: i18n("Juche era"), label: "Juche", offset: -1911 },
        { name: i18n("Bengali calendar"), label: "BS", offset: -594 },
        { name: i18n("Malayalam calendar (Kollam)"), label: "KE", offset: -825 },
        { name: i18n("Burmese calendar"), label: "ME", offset: -638 },
        { name: i18n("Holocene calendar"), label: "Holo", offset: 10000 },
        { name: i18n("Unix epoch"), label: "Unix", offset: -1970 },
        { name: i18n("Discordian calendar (YOLD)"), label: "YOLD", offset: 1166 },
        { name: i18n("Assyrian calendar"), label: "AE", offset: 4750 },
        { name: i18n("First Olympiad (776 BC)"), label: "Olympiad", offset: 776 },
        { name: i18n("Roman Republic (509 BC)"), label: "Republic", offset: 509 },
        { name: i18n("Fall of the Western Roman Empire"), label: "Rome", offset: -476 },
        { name: i18n("Big Bang"), label: "BB", offset: 13787000000 },
        { name: i18n("Formation of the Solar System"), label: "SS", offset: 4567000000 },
        { name: i18n("Formation of Earth"), label: "Earth", offset: 4540000000 },
        { name: i18n("Formation of the Moon"), label: "Moon", offset: 4510000000 },
        { name: i18n("Cambrian explosion"), label: "Cambrian", offset: 538800000 },
        { name: i18n("Permian–Triassic extinction"), label: "P-T", offset: 251900000 },
        { name: i18n("Chicxulub impact (K-Pg)"), label: "K-Pg", offset: 66043000 },
        { name: i18n("Tunguska event"), label: "Tunguska", offset: -1908 },
        { name: i18n("Supernova 1054 (Crab Nebula)"), label: "SN1054", offset: -1054 },
        { name: i18n("Supernova 1572 (Tycho)"), label: "SN1572", offset: -1572 },
        { name: i18n("Supernova 1604 (Kepler)"), label: "SN1604", offset: -1604 },
        { name: i18n("Custom"), label: "", offset: null }
    ]

    function syncEraPreset() {
        if (!eraPreset || !eraPresets || !eraLabel) return
        for (var i = 0; i < eraPresets.length; i++) {
            if (eraPresets[i].offset !== null && eraPresets[i].offset === cfg_yearOffset
                    && eraPresets[i].label === eraLabel.text) {
                eraPreset.currentIndex = i
                return
            }
        }
        eraPreset.currentIndex = eraPresets.length - 1
    }

    function formatOffset(v) {
        return String(Math.trunc(Number(v)))
    }

    function parseOffset(t) {
        var cleaned = String(t).replace(/[^0-9-]/g, "")
        var v = Number(cleaned)
        return isNaN(v) ? 0 : v
    }

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

            // Era preset
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Era:") }
            ComboBox {
                id: eraPreset
                Layout.fillWidth: true
                textRole: "name"
                model: configRoot.eraPresets
                Component.onCompleted: configRoot.syncEraPreset()
                onActivated: function(index) {
                    var p = configRoot.eraPresets[index]
                    if (p && p.offset !== null) {
                        configRoot.cfg_yearOffset = p.offset
                        yearOffset.text = configRoot.formatOffset(p.offset)
                        eraLabel.text = p.label
                    }
                    eraPreset.currentIndex = index
                    configRoot.configurationChanged()
                }
            }

            // Year offset
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Year offset:") }
            TextField {
                id: yearOffset
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegularExpressionValidator { regularExpression: /^-?[0-9\s\u00A0\u202F]{1,24}$/ }
                Component.onCompleted: text = configRoot.formatOffset(configRoot.cfg_yearOffset)
                onEditingFinished: {
                    configRoot.cfg_yearOffset = configRoot.parseOffset(text)
                    text = configRoot.formatOffset(configRoot.cfg_yearOffset)
                    configRoot.syncEraPreset()
                    configRoot.configurationChanged()
                }
            }

            // Era label
            Label { Layout.minimumWidth: configRoot.width/2; horizontalAlignment: Text.AlignRight; text: i18n("Era label:") }
            TextField {
                id: eraLabel
                Layout.fillWidth: true
                placeholderText: i18n("e.g. AUC, AD")
                onEditingFinished: {
                    configRoot.configurationChanged()
                    configRoot.syncEraPreset()
                }
            }

            // Show era label
            Label { Layout.minimumWidth: configRoot.width/2 }
            CheckBox {
                id: showEraLabel
                text: i18n("Show era label")
                onToggled: configRoot.configurationChanged()
            }

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
