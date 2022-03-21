/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

Item {
    id: _root

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedAltSlider:       guidedAltSlider
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property bool   _informacao_central :  false

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeBottomInset:    _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
        bottomEdgeLeftInset:    _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
    }

    FlyViewWidgetLayer {
        id:                     widgetLayer
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.left:           parent.left
        anchors.right:          guidedAltSlider.visible ? guidedAltSlider.left : parent.right
        z:                      _fullItemZorder + 1
        parentToolInsets:       _toolInsets
        mapControl:             _mapControl
        visible:                !QGroundControl.videoManager.fullScreen
    }

    FlyViewCustomLayer {
        id:                 customOverlay
        anchors.fill:       widgetLayer
        z:                  _fullItemZorder + 2
        parentToolInsets:   widgetLayer.totalToolInsets
        mapControl:         _mapControl
        visible:            false
    }

    GuidedActionsController {
        id:                 guidedActionsController
        missionController:  _missionController
        actionList:         _guidedActionList
        altitudeSlider:     _guidedAltSlider
    }

    /*GuidedActionConfirm {
        id:                         guidedActionConfirm
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        altitudeSlider:             _guidedAltSlider
    }*/

    GuidedActionList {
        id:                         guidedActionList
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
    }

    //-- Altitude slider
    GuidedAltitudeSlider {
        id:                 guidedAltSlider
        anchors.margins:    _toolsMargin
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        z:                  QGroundControl.zOrderTopMost
        radius:             ScreenTools.defaultFontPixelWidth / 2
        width:              ScreenTools.defaultFontPixelWidth * 10
        color:              qgcPal.window
        visible:            false
    }




  /* Rectangle { //Circulo de exemplo pra evento de hover
         id: motores
         width: parent.width/10
         height: parent.width/10
         x: parent.width/2
         y: parent.height/2
         color: teste.containsMouse ? "green" : "red"
         border.color: "black"
         border.width: 1
         radius: width*0.5



         MouseArea {
            id: teste
            anchors.fill: motores
            hoverEnabled: true
         }

    }*/

    Text{
        x: 500
        y: 400
        //text: _activeVehicle.pitch.rawValue //isso funciona. pra acessar deve ser então _activeVehicle.(atributo).rawValue
        text: _activeVehicle.pitch.rawValue
        font.family: "Helvetica"
        font.pointSize: 24
        color: "red"
    }



    Rectangle{ //area pras informações na direita da tela
        id: area_info_right
        x: parent.width*7/8
        y: 0
        width: parent.width*1/8
        height: parent.height*5/6
        color: "#0A283F"


    }
        Rectangle { //area para as informações em sliders
            id: area_info_sliders
            x: area_info_right.x
            y: area_info_right.height*3/4
            color: "transparent"
            width: area_info_right.width
            height: area_info_right.height/4
        }

            Rectangle { // exemplo de slide, pitch não é um valor relevante para um slider mas é um fácil de se testar em laboratório
                id: slider_pitch
                x: area_info_sliders.x + area_info_sliders.width*1/11
                y: area_info_sliders.y + area_info_sliders.width*1/11
                width: area_info_sliders.width/11 //estou usando isso como tamanho e espaçamento dos sliders
                height: area_info_sliders.height - 20
                color: _activeVehicle.pitch.rawValue < 45 ? "green" : "red"

            }

               Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                    x: slider_pitch.x
                    y: slider_pitch.y
                    width: slider_pitch.width
                    height: 2*(_activeVehicle.pitch.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                    color: "black"

                }

            Rectangle {
                id: slider_roll
                anchors.top: slider_pitch.top
                anchors.left: slider_pitch.right
                anchors.leftMargin: area_info_sliders.width/11
                width: slider_pitch.width
                height: slider_pitch.height
                color: "red"
            }

                Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                     x: slider_roll.x
                     y: slider_roll.y
                     width: slider_roll.width
                     height: 2*(_activeVehicle.roll.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                     color: "black"

                 }

       Text {
           anchors.horizontalCenter: slider_pitch.horizontalCenter
           y:slider_pitch.y + slider_pitch.height - 1
           text: "Pitch"
           font.family: "Helvetica"
           font.pointSize: 11
           color: "white"
       }





    QGCColoredImage {
            id: monitor_motores
            //x: (parent.width * 4)/5
            anchors.right : parent.right
            y: 160
            width: 983 * 0.15
            height: 857 * 0.15
            color: white
            source: "/res/QGCLogoWhite"

            Rectangle {
                id: motor1
                x: monitor_motores.width * 0.8
                y: monitor_motores.height * 0.44
                width: monitor_motores.width/10
                height: monitor_motores.width/10
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor2
                x: monitor_motores.width * 0.1
                y: monitor_motores.height * 0.44
                width: monitor_motores.width/10
                height: monitor_motores.width/10
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor3
                x: monitor_motores.width * 0.28
                y: monitor_motores.height * 0.1
                width: monitor_motores.width/10
                height: monitor_motores.width/10
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor4
                x: monitor_motores.width * 0.63
                y: monitor_motores.height * 0.8
                width: monitor_motores.width/10
                height: monitor_motores.width/10
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor5
                x: monitor_motores.width * 0.63
                y: monitor_motores.height * 0.1
                width: monitor_motores.width/10
                height: monitor_motores.width/10
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor6
                x: monitor_motores.width * 0.28
                y: monitor_motores.height * 0.8
                width: monitor_motores.width/10
                height: monitor_motores.width/10
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }
        }

    Rectangle {
        id: area_mapa_camera
        x: 0
        y: 0
        width: parent.width*7/8
        height: parent.height*5/6
        color: "transparent"
    }

    MouseArea {
       id: teste
       anchors.fill: area_info_right
       hoverEnabled: true
       onClicked: _informacao_central = !_informacao_central
    }

    FlyViewMap {
        id:                     mapControl
        planMasterController:   _planController
       // rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
        x: area_mapa_camera.x
        y: area_mapa_camera.y
        width: area_mapa_camera.width
        height: area_mapa_camera.height
        pipMode:                !_mainWindowIsMap
        //toolInsets:             customOverlay.totalToolInsets
        mapName:                "FlightDisplayView"
        visible: _informacao_central
    }

    FlyViewVideo {
        id: videoControl
        x: area_mapa_camera.x
        y: area_mapa_camera.y
        width: area_mapa_camera.width
        height: area_mapa_camera.height
        visible: !_informacao_central

    }

    Text {
        x: mapControl.x
        y: mapControl.y
        text: "MOUSE NA AREA"
        font.family: "Helvetica"
        font.pointSize: 24
        color: "red"
        visible: teste.containsMouse ? false : true
    }

    /*QGCPipOverlay { //Retangulo da camera ou mapa, depende quem está centralizado (descobrir onde mexe em quem esta centralizado)
        id:                     _pipOverlay
       anchors.left:           parent.left
       anchors.bottom:         parent.bottom
       anchors.margins:        _toolsMargin
       item1IsFullSettingsKey: "MainFlyWindowIsMap"
        item1:                  mapControl
        item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
        fullZOrder:             _fullItemZorder
        pipZOrder:              _pipItemZorder
       }*/

    Rectangle{ //area pras informações na parte de baixo da tela
        id: area_info_bottom
        x: 0
        y: parent.height*5/6
        width: parent.width
        height: parent.height*1/6
        color: "#0A283F"
    }


}
