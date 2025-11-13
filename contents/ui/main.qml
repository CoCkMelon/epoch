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

PlasmoidItem {
    id: root

    property string codeleng: ((Qt.locale().name)[0]+(Qt.locale().name)[1])
    property bool formato12Hour: plasmoid.configuration.hourFormat
    property bool visibleTxt: Plasmoid.configuration.activeText

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    function desktoptext(languageCode) {
        const translations = {
            "es": "son las",         // Spanish
            "en": "it is",           // English
            "hi": "यह",              // Hindi
            "fr": "il est",          // French
            "de": "es ist",          // German
            "it": "sono le",         // Italian
            "pt": "são",             // Portuguese
            "ru": "сейчас",          // Russian
            "zh": "现在是",           // Chinese (Mandarin)
            "ja": "今",              // Japanese
            "ko": "지금은",           // Korean
            "nl": "het is"           // Dutch
        };

        // Return the translation for the language code or default to English if not found
        return translations[languageCode] || translations["en"];
    }

    FontLoader {
        id: milk
        source: "../fonts/Milkshake.ttf"
    }
    FontLoader {
        id: metro
        source: "../fonts/Metropolis-Black.ttf"
    }

    fullRepresentation: Item {
        id: mainContainer
        width: plasmoid.width
        height: plasmoid.height
        // Request enough width to fit content, so panel pushes neighbors
        implicitWidth: timeContainer.width + base.pad * 2
        // Also tell the panel via Layout hints
        Layout.preferredWidth: base.width
        Layout.minimumWidth: base.width
        property bool smallPanel: height <= 22
        
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
            width: timeContainer.width + pad * 2 // based on content; panel will allocate width
            // Height and position include user-configured overflow
            height: mainContainer.height + plasmoid.configuration.overflowTop + plasmoid.configuration.overflowBottom
            radius: height/10
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -plasmoid.configuration.overflowTop
            // Background rectangle visibility
            color: plasmoid.configuration.enableRect ? "#00001B" : "transparent"
            border.color: "#9747c7"
            border.width: (!plasmoid.configuration.enableRect && plasmoid.configuration.enableGlow) ? 1 : 0
            
            // Glow
            layer.enabled: plasmoid.configuration.enableGlow
            layer.effect: Glow {
                radius: Math.max(6, Math.round(height * 0.30))
                samples: Math.floor(height/2)
                color: "#9747c7"
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

            // Keep width animation in sync with text width change
            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.InOutBack }
            }
            
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

                // Optional localized prefix text ("it is", "son las", etc.)
                Text {
                    id: prefixText
                    width: plasmoid.configuration.activeText ? implicitWidth : 0
                    height: plasmoid.configuration.activeText ? implicitHeight : 0
                    visible: plasmoid.configuration.activeText
                    text: root.desktoptext(root.codeleng)
                    font.pixelSize: hora.font.pixelSize * 0.35
                    font.family: hora.font.family
                    color: "#AAAAAA"
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
                            GradientStop { position: 0.0; color: "#78C3FB" }  // Light blue
                            GradientStop { position: 1.0; color: "#3A66F9" }  // Darker blue
                        }
                    }
                }
                
                // Colon separator
                Text {
                    text: ":"
                    font.pixelSize: hora.font.pixelSize
                    font.family: hora.font.family
                    font.weight: Font.Bold
                    color: "#DDDDDD"
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
                            GradientStop { position: 0.0; color: "#F9A55A" }  // Orange
                            GradientStop { position: 1.0; color: "#F25576" }  // Pink
                        }
                    }
                }
            }
            
            // Seconds as superscript
            Text {
                id: segundos
                property var currentDate: hora.currentDate
                // Bounce/rotation state
                property real bounceOffset: 0
                property int rotSign: 1
                text: Qt.formatDateTime(currentDate, "ss")
                font.pixelSize: hora.font.pixelSize * 0.44
                font.family: hora.font.family
                font.weight: Font.Bold
                color: "#4DD8C8"  // Teal
                transformOrigin: Item.TopLeft
                rotation: 0
                anchors.left: timeRow.right
                // Keep seconds inside rect without cross-parent anchors
                anchors.top: timeRow.top
                anchors.topMargin: Math.round(mainContainer.height * 0.10) + bounceOffset

                // Spring animations
                SpringAnimation {
                    id: bounceAnim
                    target: segundos
                    property: "bounceOffset"
                    to: 0
                    spring: 4
                    damping: 0.26
                }
                SpringAnimation {
                    id: rotAnim
                    target: segundos
                    property: "rotation"
                    to: 0
                    spring: 4
                    damping: 0.26
                }

                onTextChanged: {
                    // Alternate sign for subtle wobble
                    var s = parseInt(text)
                    rotSign = (s % 2 === 0) ? 1 : -1
                    // Kick values
                    bounceOffset = -Math.round(hora.font.pixelSize * 0.16)
                    rotation = rotSign * 10
                    // Start springs
                    bounceAnim.start()
                    rotAnim.start()
                }
            }
        }
        
        // Date display centered below time
        Text {
            id: dateText
            width: base.width
            horizontalAlignment: Text.AlignLeft
            property var currentDate: hora.currentDate
            text: Qt.formatDateTime(currentDate, "ddd d M yy")
            font.pixelSize: mainContainer.height * 0.32
            font.family: hora.font.family
            color: "#CC73E1"  // Light purple
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

        // Force layout update when activeText toggles
        Connections {
            target: plasmoid.configuration
            function onActiveTextChanged() {
                timeContainer.width = Qt.binding(function() { return timeContainer.childrenRect.width })
            }
        }
    }
}
