/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                      2.12
import QtQuick.Layouts              1.12

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0

Rectangle { //retangulo principal da barra de telemetria
    id:                 telemetryPanel
    height:             telemetryLayout.height + (_toolsMargin * 2)
    width:              telemetryLayout.width + (_toolsMargin * 4) //valor padrão: 2
    color:              qgcPal.window
    radius:             ScreenTools.defaultFontPixelWidth /2 // valor padrão /2
    visible: false
    property bool       bottomMode: false //agora que bottomMode = false, o default é a barra de telemetria na esquerda da tela

    DeadMouseArea { anchors.fill: parent }

    ColumnLayout {
        id:                 telemetryLayout
        anchors.margins:    _toolsMargin
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left

         RowLayout {
            visible: mouseArea.containsMouse || valueArea.settingsUnlocked

            QGCColoredImage { //barrinha de mudar posicao da barra de telemetria : ESQUERDA
                source:             "/res/layout-bottom.svg"
                mipmap:             true
                width:              ScreenTools.minTouchPixels * 0.75
                height:             width
                sourceSize.width:   width
                color:              qgcPal.text
                fillMode:           Image.PreserveAspectFit
                visible:            !bottomMode

                QGCMouseArea {
                    fillItem:   parent
                    onClicked:  bottomMode = true
                }
            }

            QGCColoredImage { //barrinha de mudar posicao da barra de telemetria : MEIO DA TELA
                source:             "/res/layout-right.svg"
                mipmap:             true
                width:              ScreenTools.minTouchPixels * 0.75
                height:             width
                sourceSize.width:   width
                color:              qgcPal.text
                fillMode:           Image.PreserveAspectFit
                visible:            bottomMode

                QGCMouseArea {
                    fillItem:   parent
                    onClicked:  bottomMode = false
                }
            }

            QGCColoredImage { //lápis e cadeado da barra de telemetria
                source:             valueArea.settingsUnlocked ? "/res/LockOpen.svg" : "/res/pencil.svg"
                mipmap:             true
                width:              ScreenTools.minTouchPixels * 0.75
                height:             width
                sourceSize.width:   width
                color:              red
                fillMode:           Image.PreserveAspectFit

                QGCMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    valueArea.settingsUnlocked = !valueArea.settingsUnlocked
                }
            }
        }

        QGCMouseArea {
            id:                         mouseArea
            x:                          telemetryLayout.x
            y:                          telemetryLayout.y
            width:                      telemetryLayout.width
            height:                     telemetryLayout.height
            hoverEnabled:               true
            propagateComposedEvents:    true
        }

        HorizontalFactValueGrid {
            id:                     valueArea
            userSettingsGroup:      telemetryBarUserSettingsGroup
            defaultSettingsGroup:   telemetryBarDefaultSettingsGroup
        }

        GuidedActionConfirm {
            Layout.fillWidth:   true
            guidedController:   _guidedController
            altitudeSlider:     _guidedAltSlider
        }
    }
}
