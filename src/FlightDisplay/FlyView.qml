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

    FlyViewCustomLayer {    //
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

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*

             TUDO DAQUI PRA BAIXO É COISA MINHA, PRA CIMA NÃO TEVE MUITA ALTERAÇÃO QUE EU ME LEMBRE 22/03/222

    */
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Text{
        x: 500
        y: 400
        //text: _activeVehicle.pitch.rawValue //isso funciona. pra acessar deve ser então _activeVehicle.(atributo).rawValue (nem sempre rawValue, olhar no header)
       // text: _activeVehicle.pitch.rawValue
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

    Text {
        x: area_info_right.x + 30
        y: area_info_right.y + 400
        text: "AREA PARA MAIS INFO"
        font.family: "Helvetica"
        font.pointSize: 12
        color: "white"
    }

    Item{


        Rectangle { //area para as informações em sliders
            id: area_info_sliders
            x: area_info_right.x
            y: area_info_right.height*3/4
            color: "transparent"
            width: area_info_right.width
            height: area_info_right.height/4
        }

            Rectangle { // exemplo de slide, pitch não é um valor relevante para um slider mas é um fácil de se testar em laboratório
                id: slider_0
                x: area_info_sliders.x + area_info_sliders.width*1/14
                y: area_info_sliders.y + area_info_sliders.width*1/11
                width: area_info_sliders.width/14 //estou usando isso como tamanho e espaçamento dos sliders
                height: area_info_sliders.height - 20
                color: _activeVehicle.pitch.rawValue < 45 ? "green" : "red"

            }

               Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                    x: slider_0.x
                    y: slider_0.y
                    width: slider_pitch.width
                    height: 2*(_activeVehicle.pitch.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                    color: "black"

                }

            Rectangle {
                id: slider_1
                anchors.top: slider_0.top
                anchors.left: slider_0.right
                anchors.leftMargin: area_info_sliders.width/11
                width: slider_0.width
                height: slider_0.height
                color: "Green"
            }

                Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                     x: slider_1.x
                     y: slider_1.y
                     width: slider_1.width
                     height: 2*(_activeVehicle.roll.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                     color: "black"

                 }

                Rectangle {
                    id: slider_2
                    anchors.top: slider_1.top
                    anchors.left: slider_1.right
                    anchors.leftMargin: area_info_sliders.width/11
                    width: slider_1.width
                    height: slider_1.height
                    color: "Green"
                }

                    Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                         x: slider_2.x
                         y: slider_2.y
                         width: slider_2.width
                         height: 2*(_activeVehicle.roll.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                         color: "black"

                     }
                    Rectangle {
                        id: slider_3
                        anchors.top: slider_2.top
                        anchors.left: slider_2.right
                        anchors.leftMargin: area_info_sliders.width/11
                        width: slider_2.width
                        height: slider_2.height
                        color: "Green"
                    }

                        Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                             x: slider_3.x
                             y: slider_3.y
                             width: slider_3.width
                             height: 2*(_activeVehicle.roll.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                             color: "black"

                         }

                        Rectangle {
                            id: slider_4
                            anchors.top: slider_3.top
                            anchors.left: slider_3.right
                            anchors.leftMargin: area_info_sliders.width/11
                            width: slider_3.width
                            height: slider_3.height
                            color: "Green"
                        }

                            Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                                 x: slider_4.x
                                 y: slider_4.y
                                 width: slider_4.width
                                 height: 2*(_activeVehicle.roll.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                                 color: "black"

                             }
                            Rectangle {
                                id: slider_5
                                anchors.top: slider_4.top
                                anchors.left: slider_4.right
                                anchors.leftMargin: area_info_sliders.width/11
                                width: slider_4.width
                                height: slider_4.height
                                color: "Green"
                            }

                                Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                                     x: slider_5.x
                                     y: slider_5.y
                                     width: slider_5.width
                                     height: 2*(_activeVehicle.roll.rawValue) //os atributos que podem ser acessados estão em headers/src/vehicles.h
                                     color: "black"

                                 }

                                Text{
                                    text: "CORRENTE EM CADA MOTOR"
                                    font.family: "Helvetica"
                                    font.pointSize: 12
                                    color: "white"
                                    x: slider_0.x
                                    y: slider_0.y + slider_0.height/2 - font.pointSize
                                   // text: _activeVehicle.pitch.rawValue //isso funciona. pra acessar deve ser então _activeVehicle.(atributo).rawValue (nem sempre rawValue, olhar no header)
                                   // text: _activeVehicle.pitch.rawValue

                                }
              }
/*
       Text {
           anchors.horizontalCenter: slider_pitch.horizontalCenter
           y:slider_pitch.y + slider_pitch.height - 1
           text: "Pitch"
           font.family: "Helvetica"
           font.pointSize: 11
           color: "white"
       }
*/




    QGCColoredImage { //imagem do drone com os rotores
            id: monitor_motores
            x: area_info_right.x
            y: area_info_right.y
            width: area_info_right.width
            height: area_info_right.height*1/5
            color: white
            source: "/res/QGCLogoWhite"

            Rectangle {
                id: motor1
                x: monitor_motores.width * 0.73
                y: monitor_motores.height * 0.44
                width: monitor_motores.width/15
                height: monitor_motores.width/15
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor2
                x: monitor_motores.width * 0.2
                y: monitor_motores.height * 0.44
                width: monitor_motores.width/15
                height: monitor_motores.width/15
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor3
                x: monitor_motores.width * 0.33
                y: monitor_motores.height * 0.1
                width: monitor_motores.width/15
                height: monitor_motores.width/15
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor4
                x: monitor_motores.width * 0.6
                y: monitor_motores.height * 0.8
                width: monitor_motores.width/15
                height: monitor_motores.width/15
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor5
                x: monitor_motores.width * 0.6
                y: monitor_motores.height * 0.1
                width: monitor_motores.width/15
                height: monitor_motores.width/15
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }

            Rectangle {
                id: motor6
                x: monitor_motores.width * 0.33
                y: monitor_motores.height * 0.8
                width: monitor_motores.width/15
                height: monitor_motores.width/15
                radius: width* 0.5
                border.color: monitor_motores.color
                border.width: 1
                color: "green"
            }
        }

    Rectangle { //AREA ONDE O MAPA OU O VIDEO APARECE
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
           onClicked: _informacao_central = !_informacao_central // console.log(_activeVehicle.escStatus.currentFirst.valueString)
        }


Item{
    visible: !_informacao_central

        FlyViewVideo { //video
            id: videoControl
            x: area_mapa_camera.x
            y: area_mapa_camera.y
            width: area_mapa_camera.width
            height: area_mapa_camera.height
            visible: !_informacao_central
        }

        Item{
            QGCColoredImage { //crosshair no centro da camera
                    id: crosshair_central
                    width: area_mapa_camera.width/10
                    height: area_mapa_camera.width/10
                    x: area_mapa_camera.width/2 - width/2
                    y: area_mapa_camera.height/2 -height/2 + _activeVehicle.pitch.rawValue/2
                    color: "#A0009900"
                    source: "/res/crossHair_res.svg"
                    rotation: _activeVehicle.roll.rawValue
            }

            Rectangle{//circulo ao redor do crosshair
                id: borda_crosshair
                width: area_mapa_camera.width/8
                height: area_mapa_camera.width/8
                x: area_mapa_camera.width/2 - width/2
                y: area_mapa_camera.height/2 - height/2
                color: "transparent"
                border.color: "#A0007700"
                border.width: 2
                radius: width*0.5
            }

            Text{ //valor máximo permitido para o voo
                font.family: "Helvetica"
                font.pointSize: 24
                color: "#A0007700"
                text: _activeVehicle.throttlePct.rawValue
                x: borda_crosshair.x + 200
                y: coluna_altitude_baro.y - font.pointSize/2

            }

        }
         Item { //COLUNA DIREITA DO HUD
            Rectangle{
                id: coluna_altitude_baro
                y:  borda_crosshair.y - borda_crosshair.height/2
                x: borda_crosshair.x - borda_crosshair.width/4
                width: 3
                height: borda_crosshair.height*2
                color: "#A0007700"
            }
            Text{ //valor máximo permitido para o voo
                font.family: "Helvetica"
                font.pointSize: 12
                color: "#A0007700"
                text: "MAX_ALT"
                x: coluna_altitude_baro.x - 70
                y: coluna_altitude_baro.y - font.pointSize/2

            }

            Text{ //valor minimo permitido para o voo
                font.family: "Helvetica"
                font.pointSize: 12
                color: "#A0007700"
                text: "MIN_ALT"
                x: coluna_altitude_baro.x - 70
                y: coluna_altitude_baro.y + coluna_altitude_baro.height - font.pointSize/2

            }

            Text{ //altitude barométrica
                id: pointer_alt_baro
                font.family: "Helvetica"
                font.pointSize: 18
                color: "#A0007700"
                y: borda_crosshair.y + borda_crosshair.height - (borda_crosshair.height * _activeVehicle.altitudeAMSL.rawValue/50) //assumindo MAX_ALT = 50
                x: borda_crosshair.x - borda_crosshair.width*0.66
                text: _activeVehicle.altitudeAMSL.valueString + "m"
                visible: true
            }

            Rectangle{
                width: 10
                height: 5
                x: coluna_altitude_baro.x - width
                y: pointer_alt_baro.y +pointer_alt_baro.font.pointSize
                color: pointer_alt_baro.color
            }

        }

         Item { //COLUNA ESQUERDA DO HUD
            Rectangle{
                id: coluna_velocidade_vertical
                y:  borda_crosshair.y - borda_crosshair.height/2
                x: borda_crosshair.x + borda_crosshair.width*1.25
                width: 3
                height: borda_crosshair.height*2
                color: "#A0007700"
            }
            Text{ //valor máximo permitido para o voo
                font.family: "Helvetica"
                font.pointSize: 12
                color: "#A0007700"
                text: "MAX_VEL"
                x: coluna_velocidade_vertical.x + 10
                y: coluna_velocidade_vertical.y - font.pointSize/2

            }

            Text{ //valor minimo permitido para o voo
                font.family: "Helvetica"
                font.pointSize: 12
                color: "#A0007700"
                text: "MIN_VEL"
                x: coluna_velocidade_vertical.x + 10
                y: coluna_velocidade_vertical.y + coluna_velocidade_vertical.height - font.pointSize/2

            }

            Text{ //altitude barométrica
                id: pointer_velocidade_vertical
                font.family: "Helvetica"
                font.pointSize: 18
                color: "#A0007700"
                y: borda_crosshair.y + borda_crosshair.height - (borda_crosshair.height * _activeVehicle.climbRate.rawValue/50) //assumindo MAX_VEL = 10
                x: borda_crosshair.x + borda_crosshair.width*1.33
                text: _activeVehicle.climbRate.valueString + "m/s"
                visible: true
            }

            Rectangle{
                width: 10
                height: 5
                x: coluna_altitude_baro.x - width
                y: pointer_alt_baro.y +pointer_alt_baro.font.pointSize
                color: pointer_alt_baro.color
            }

        }



       /* Rectangle{
            width:50
            height:50
            x: area_mapa_camera.width/2 -width/2
            y: area_mapa_camera.height/2 -height/2
            color: "#A0007700"
            rotation: _activeVehicle.roll.rawValue
        }*/


 }


        Text {
            x: mapControl.x +300
            y: mapControl.y
           // text: _activeVehicle.heading.rawValue //"MOUSE NA AREA" //(_activeVehicle.batteries.get(0).percentRemaining.valueString) assim que consigo acesso as baterias, .valueString pega FACT e transforma em string [ver FactControls]
            font.family: "Helvetica"
            font.pointSize: 24
            color: "#80FF0000"
            visible: true

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

    Text {
        x: area_info_bottom.width - 450
        y: area_info_bottom.y + 50
        text: "AREA PARA MAIS INFO"
        font.family: "Helvetica"
        font.pointSize: 24
        color: "white"
    }

    Rectangle{
        id: area_info_bottom_central
        x: area_info_bottom.width/2 - area_info_bottom.width/5
        y: area_info_bottom.y - 30
        width: area_info_bottom.width*2/5
        height: area_info_bottom.height + 30
        color: "gray"
        border.color: area_info_bottom.color
        border.width: 5
    }
    Item {
        Rectangle {
            id: circulo_1
            width: area_info_bottom_central.height*5/6
            height: area_info_bottom_central.height*5/6
            x: area_info_bottom_central.x + area_info_bottom_central.width/2 - circulo_1.width/2
            y: area_info_bottom_central.y + area_info_bottom_central.height/8
            color: "black"
            border.color: area_info_bottom_central.color
            border.width: 1
            radius: width*0.5
        }

        Item{
            QGCColoredImage { //imagem do drone com os rotores
                    id: bussola_geral
                    x: area_info_bottom_central.x
                    y: area_info_bottom_central.y + area_info_bottom_central.height/8
                    width: area_info_bottom_central.width
                    height: area_info_bottom_central.height*5/6
                    rotation: _activeVehicle.heading.rawValue
                    color: "white"
                    source: "/res/Compass_360.svg"
                    }
            QGCColoredImage {
                    id: ponteiro_bussola
                    /*anchors.horizontalCenter: bussola_geral.horizontalCenter
                    anchors.verticalCenter: bussola_geral.verticalCenter*/
                    width: bussola_geral.height/2
                    height: bussola_geral.height/2
                    x: bussola_geral.x + bussola_geral.width/2 - ponteiro_bussola.width/2
                    y: bussola_geral.y + bussola_geral.height/2 - ponteiro_bussola.width/2
                    color: "white"
                    source: "/res/airplane_compass.svg"
                    }
        }

    }

    FlyViewMap { //mapa
        id:                     mapControl
        planMasterController:   _planController
       // rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: area_info_bottom.width*0.3
        height: area_info_bottom.height*7/3
        pipMode:                !_mainWindowIsMap
        //toolInsets:             customOverlay.totalToolInsets
        mapName:                "FlightDisplayView"
        visible: true
    }




}
