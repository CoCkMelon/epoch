/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

PlasmoidItem {
    id: root

    property bool formato12Hour: plasmoid.configuration.hourFormat
    property bool visibleTxt: Plasmoid.configuration.activeText

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    // Format a date, optionally counting years from another era.
    function formatDate(d, format) {
        var fmt = format || plasmoid.configuration.customDateFormat || "ddd d M yy"
        var offset = plasmoid.configuration.yearOffset || 0
        var label = plasmoid.configuration.showEraLabel ? (plasmoid.configuration.eraLabel || "") : ""
        if (offset === 0) {
            var plain = d.toLocaleString(Qt.locale(), fmt)
            return label ? plain + " " + label : plain
        }
        var match = /y{1,4}/.exec(fmt)
        if (!match) {
            var plain2 = d.toLocaleString(Qt.locale(), fmt)
            return label ? plain2 + " " + label : plain2
        }
        var pre = fmt.slice(0, match.index)
        var post = fmt.slice(match.index + match[0].length)
        var eraYear = d.getFullYear() + offset
        var yearText
        if (match[0].length === 2) {
            var last = Math.abs(eraYear) % 100
            yearText = (last < 10 ? "0" : "") + last
            if (eraYear < 0) {
                yearText = "-" + yearText
            }
        } else {
            yearText = String(eraYear)
        }
        var result = (pre ? d.toLocaleString(Qt.locale(), pre) : "") + yearText
                + (post ? d.toLocaleString(Qt.locale(), post) : "")
        return label ? result + " " + label : result
    }

    FontLoader {
        id: milk
        source: "../fonts/Milkshake.ttf"
    }
    FontLoader {
        id: metro
        source: "../fonts/Metropolis-Black.ttf"
    }


    property var currentTime: new Date()

    // Clipboard helper from KQuickControlsAddons
    KQuickAddons.Clipboard {
        id: clipboard
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = new Date()
    }
    Plasma5Support.DataSource {
        id: rootExec
        engine: "executable"
        onNewData: function(source, data) {
            disconnectSource(source)
        }
    }
    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Open Date && Time Settings")
            icon.name: "preferences-system-time"
            onTriggered: rootExec.connectSource("systemsettings kcm_clock")
        },
        PlasmaCore.Action {
            isSeparator: true
        },
        PlasmaCore.Action {
            text: i18n("Copy Time (HH:MM:SS)")
            icon.name: "edit-copy"
            onTriggered: clipboard.content = Qt.formatTime(currentTime, "hh:mm:ss")
        },
        PlasmaCore.Action {
            text: i18n("Copy Time (HH:MM)")
            icon.name: "edit-copy"
            onTriggered: clipboard.content = Qt.formatTime(currentTime, "hh:mm")
        },
        PlasmaCore.Action {
            text: i18n("Copy Unix Timestamp")
            icon.name: "edit-copy"
            onTriggered: clipboard.content = Math.floor(currentTime.getTime() / 1000).toString()
        },
        PlasmaCore.Action {
            text: i18n("Copy Date")
            icon.name: "edit-copy"
            onTriggered: clipboard.content = root.formatDate(currentTime, plasmoid.configuration.customDateFormat || "d M yy")
        },
        PlasmaCore.Action {
            text: i18n("Copy ISO Date")
            icon.name: "edit-copy"
            onTriggered: clipboard.content = currentTime.toISOString()
        }
    ]


    fullRepresentation: Item {
        id: mainContainer
        width: plasmoid.width
        height: plasmoid.height
        // Request enough width to fit content, so panel pushes neighbors
        implicitWidth: timeRow.width + secondsContainer.width + base.pad * 2
        // Also tell the panel via Layout hints
        Layout.preferredWidth: base.width
        Layout.minimumWidth: base.width
        property bool smallPanel: height <= 22

        // For public access
        property alias pubDateText: dateText
        
        // Allow glow to overflow outside plasmoid
        clip: false

        // Executable runner for click actions
        Plasma5Support.DataSource {
            id: exec
            engine: "executable"
        }
        
        // Main rectangle with glow - this is now the only box
        Rectangle {
            id: base
            property int pad: 1
            // Width accounts for the fixed seconds slot and date, use whichever is wider
            width: Math.max(timeRow.width + secondsContainer.width, dateText.implicitWidth) + pad * 2
            // Height and position include user-configured overflow
            height: mainContainer.height + plasmoid.configuration.overflowTop + plasmoid.configuration.overflowBottom
            radius: height/10
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -plasmoid.configuration.overflowTop
            // Background rectangle visibility
            color: plasmoid.configuration.enableRect ? plasmoid.configuration.rectColor : "transparent"
            border.color: plasmoid.configuration.glowColor
            border.width: (!plasmoid.configuration.enableRect && plasmoid.configuration.enableGlow) ? 1 : 0
            
            // Glow
            layer.enabled: plasmoid.configuration.enableGlow
            layer.effect: Glow {
                radius: Math.max(6, Math.round(height * 0.30))
                samples: Math.floor(height/2)
                color: plasmoid.configuration.glowColor
                spread: 0.30
            }
        }
        

        // Time display (16:20)
        Item {
            id: timeContainer
            width: childrenRect.width
            height: childrenRect.height
            anchors.left: base.left
            anchors.leftMargin: base.pad
            anchors.verticalCenter: mainContainer.verticalCenter
            // Raise time a bit across all sizes (branch-free)
            anchors.verticalCenterOffset: -Math.round(mainContainer.height * 0.10)

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (plasmoid.configuration.clickCommand && plasmoid.configuration.clickCommand.length > 0) {
                        exec.connectSource(plasmoid.configuration.clickCommand)
                    }
                }
            }

            Row {
                id: timeRow
                spacing: Math.round(mainContainer.height * 0.08)
                anchors.left: parent.left

                // Optional prefix text (localized or custom)
                Text {
                    visible: plasmoid.configuration.activeText
                    text: plasmoid.configuration.customPrefixText || i18n("now")
                    font.pixelSize: hora.font.pixelSize * 0.35
                    font.family: hora.font.family
                    color: plasmoid.configuration.prefixColor
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                // Hours with blue gradient
                Text {
                    id: hora
                    property var currentDate: new Date()
                    text: formato12Hour
                    ? (currentDate.getHours() === 0
                    ? "12"
                    : (currentDate.getHours() <= 12
                    ? String(currentDate.getHours())
                    : String(currentDate.getHours() - 12)))
                    : Qt.formatDateTime(currentDate, "HH")
                    font.pixelSize: mainContainer.height * 0.65
                    font.family: metro.name
                    font.weight: Font.Bold
                    
                    LinearGradient {
                        anchors.fill: parent
                        source: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: plasmoid.configuration.hourColorTop }
                            GradientStop { position: 1.0; color: plasmoid.configuration.hourColorBottom }
                        }
                    }
                }
                
                // Colon separator
                Text {
                    id: colonText
                    text: ":"
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    color: plasmoid.configuration.colonColor
                    opacity: 1.0
                    
                    SequentialAnimation {
                        id: blinkAnim
                        running: false
                        property var easingTypes: [Easing.InOutQuad, Easing.Linear, Easing.InQuad, Easing.OutQuad, Easing.InOutCubic, Easing.InOutSine, Easing.InOutExpo]
                        property int currentEasing: easingTypes[plasmoid.configuration.colonBlinkEasing] || Easing.InOutQuad
                        property bool isInstant: plasmoid.configuration.colonBlinkEasing === 7
                        NumberAnimation { target: colonText; property: "opacity"; to: 0.0; duration: blinkAnim.isInstant ? 0 : 250; easing.type: blinkAnim.currentEasing }
                        PauseAnimation { duration: blinkAnim.isInstant ? 500 : 0 }
                        NumberAnimation { target: colonText; property: "opacity"; to: 1.0; duration: blinkAnim.isInstant ? 0 : 250; easing.type: blinkAnim.currentEasing }
                    }
                    
                    Connections {
                        target: segundos
                        function onTextChanged() {
                            if (!plasmoid.configuration.disableColonBlink) {
                                blinkAnim.restart()
                            }
                        }
                    }
                }
                
                // Minutes with orange-pink gradient
                Text {
                    id: minutos
                    property var currentDate: hora.currentDate
                    text: Qt.formatDateTime(currentDate, "mm")
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    
                    LinearGradient {
                        anchors.fill: parent
                        source: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(0, parent.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: plasmoid.configuration.minuteColorTop }
                            GradientStop { position: 1.0; color: plasmoid.configuration.minuteColorBottom }
                        }
                    }
                }
            }
        }
        
        // Seconds as superscript in a fixed-width slot: changing digits never resizes the clock
        Item {
            id: secondsContainer
            x: timeContainer.x + timeRow.width
            y: timeContainer.y
            // FontMetrics gives the width of the widest two-digit value without a dummy Text item
            width: secondsMetrics.advanceWidth("88") + Math.round(hora.font.pixelSize * 0.08)
            height: segundos.height

            FontMetrics {
                id: secondsMetrics
                font: segundos.font
            }

            Text {
                id: segundos
                property var currentDate: hora.currentDate
                // Bounce/rotation state
                property real bounceOffset: 0
                property int rotSign: 1
                property int transformOriginValue: Item.TopLeft
                text: Qt.formatDateTime(currentDate, "ss")
                font.pixelSize: hora.font.pixelSize * 0.44
                font.family: hora.font.family
                font.weight: Font.Bold
                color: plasmoid.configuration.secondsColor
                transformOrigin: transformOriginValue
                rotation: 0
                anchors.left: parent.left
                y: bounceOffset

                // Spring animations
                SpringAnimation {
                    id: bounceAnim
                    target: segundos
                    property: "bounceOffset"
                    to: 0
                    spring: 20
                    damping: 10.0
                }
                SpringAnimation {
                    id: rotAnim
                    target: segundos
                    property: "rotation"
                    to: 0
                    spring: 6
                    damping: 0.1
                }

                onTextChanged: {
                    if (!plasmoid.configuration.disableAnimations) {
                        // Random rotation direction and amount
                        rotSign *= -1
                        // Random transform origin for more variety
                        var origins = [Item.TopLeft, Item.Top, Item.TopRight, Item.Left, Item.Center, Item.Right, Item.BottomLeft, Item.Bottom, Item.BottomRight]
                        transformOriginValue = origins[Math.floor(Math.random() * origins.length)]
                        // Random kick values for variety
                        var bounceBase = hora.font.pixelSize * 0.4
                        var rotBase = 60
                        var randval = Math.random()-0.2
                        bounceOffset = -Math.round(bounceBase * (0.5+4*randval*randval*randval*randval*randval*randval*randval))
                        rotation = rotSign * (rotBase * (0.5+4*randval*randval*randval*randval*randval*randval*randval))
                        // Start springs
                        bounceAnim.start()
                        rotAnim.start()
                    }
                }
            }
        }
        
        // Date display centered below time
        Text {
            id: dateText
            width: base.width - base.pad * 2
            horizontalAlignment: Text.AlignLeft
            property var currentDate: hora.currentDate
            text: root.formatDate(currentDate)
            font.pixelSize: mainContainer.height * 0.32
            font.family: hora.font.family
            color: plasmoid.configuration.dateColor
            anchors.left: mainContainer.left
            anchors.leftMargin: base.pad
            anchors.top: timeContainer.bottom
            anchors.topMargin: 0
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                hora.currentDate = new Date()
                minutos.currentDate = hora.currentDate
                segundos.currentDate = hora.currentDate
                dateText.currentDate = hora.currentDate
            }
        }

    }
}
