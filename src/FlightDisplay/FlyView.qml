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

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2

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


import QGroundControl.FactControls          1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.SettingsManager       1.0
import QtGraphicalEffects 1.12

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

    MouseArea { //Se a tela for clickada em qualquer posição, a tabela de cameras some.
       anchors.fill: _root
       hoverEnabled: true

       onClicked: _selecao_camera = false

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

    property bool   _informacao_central :  false //booleano que define se a camera ou o mapa fica no foco central
    property bool   _selecao_camera: false //booleano que decide se a tabela de cameras esta visivel ou não.

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




  /* Rectangle {
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

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*

             TUDO DAQUI PRA BAIXO É COISA MINHA, PRA CIMA NÃO TEVE MUITA ALTERAÇÃO QUE EU ME LEMBRE 22/03/222
             UNICA ALTERAÇÃO DESDE 22/03 NA PARTE DE CIMA FORAM OS TRÊS ULTIMOS IMPORTS PARA REALIZAR A TROCA DE CAMERA 23/05/2022

    */
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function manter_na_barra(id_seta, id_barra){
        fim_da_barra = id_barra.y + id_barra.height
        if (id_seta.y > fim_da_barra){
            id_seta.y = fim_da_barra
        }
    }





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

    Item{ //Sliders de corrente individual


        Rectangle { //area para as informações em sliders
            id: area_info_sliders
            x: area_info_right.x
            y: area_info_right.height*3/4
            z:1
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
                    height: Math.abs(2*(_activeVehicle.roll.rawValue) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                     height: Math.abs(2*(_activeVehicle.roll.rawValue) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                         height: Math.abs(2*(_activeVehicle.roll.rawValue) )//os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                             height: Math.abs(2*(_activeVehicle.roll.rawValue) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                                 height: Math.abs(2*(_activeVehicle.roll.rawValue) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                                     height: Math.abs(2*(_activeVehicle.roll.rawValue) )//os atributos que podem ser acessados estão em headers/src/vehicles.h
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



 Item{ //area do desenho do drone
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
   }

 Item{ //este item inteiro precisa ser discutido com mais detalhes com o professor.
     Text {
         x: area_info_right.x + 5
         y: monitor_motores.height + monitor_motores.height*0.25
         text: _activeVehicle.initialConnectComplete//"OFF"
         font.family: "Helvetica"
         font.pointSize: 24
         color: "#AA0000"
         visible: true
     }

     Text {
         x: area_info_right.x  + area_info_right.width/3
         y: monitor_motores.height + monitor_motores.height*0.15
         text: _activeVehicle.readyToFly//"IDLE"
         font.family: "Helvetica"
         font.pointSize: 24
         color: "#FFFF00"
         visible: true
     }

     Text {
         x: area_info_right.x  + area_info_right.width*2/3 + 5
         y: monitor_motores.height + monitor_motores.height*0.25
         text: _activeVehicle.armed//"ON"
         font.family: "Helvetica"
         font.pointSize: 24
         color: "#00FF00"
         visible: true
     }

    QGCColoredImage{
        id: knob_armed
        width: area_info_right.width/2
        height: area_info_right.height*1/5
        x: area_info_right.x + width/2
        y: area_info_right.y + monitor_motores.height*1.25
        color: _activeVehicle.initialConnectComplete ? (_activeVehicle.readyToFly ? "#00FF00":"#FFFF00") : "#AA0000"
        rotation: knob_armed.color === "#AA0000" ? 10 : (knob_armed.color === "#FFFF00" ? 45: 60) //é preciso fazer testes com o drone armado.
        source: "/res/knob_armed.png"



    }


 }

    Rectangle { //AREA ONDE O VIDEO APARECE
        id: area_mapa_camera
        x: 0
        y: 0
        width: parent.width*7/8
        height: parent.height*5/6
        color: "transparent"
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
        y: parent.height*4/5
        z:1
        width: parent.width
        height: parent.height*1/5
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
        y: area_info_bottom.y
        z: 1
        width: area_info_bottom.width*2/5
        height: area_info_bottom.height + 30
        color: "gray"

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
                    mirror: true
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


            FlyViewVideo { //video da camera
                id: videoControl
                x: 0
                y: !_informacao_central ? 0 : parent.height*4/5
                width: !_informacao_central ? area_mapa_camera.width : area_info_bottom.width*0.3
                height:!_informacao_central ? area_mapa_camera.height : area_info_bottom.height
                z: !_informacao_central ? 0 : 1



                //visible: !_informacao_central
            }
Item {
    z: videoControl.z
            Item{
                QGCColoredImage { //crosshair no centro da camera
                        id: crosshair_central
                        width: videoControl.width/12
                        height: videoControl.width/10
                        x: videoControl.width/2 - width/2
                        y: videoControl.y + videoControl.height/2 - height/2
                        color: "#00FF00"
                        source: "/res/crossHair_res.svg"
                        rotation: _activeVehicle.roll.rawValue
                }

                Rectangle{//circulo ao redor do crosshair
                    id: borda_crosshair
                    width: videoControl.width/8
                    height: videoControl.width/8
                    x: videoControl.width/2 - width/2
                    y: videoControl.y + videoControl.height/2 - height/2
                    color: "transparent"
                    border.color: crosshair_central.color
                    border.width: 2
                    radius: width*0.5
                }

                Item{ //angulos de inclinação. Tudo aqui ta um INFERNO, acho uma boa refazer a lógica de Crosshair pra deixar estático. 
                    id: angulos_inclinacao
                    x: borda_crosshair.x + borda_crosshair.width/2
                    y: crosshair_central.y + crosshair_central.height/2

                    Rectangle{
                    id: angulos_inclinacao_20p
                    width: borda_crosshair.width/2
                    height: borda_crosshair.border.width
                    x: - width/2
                    y:  - _activeVehicle.pitch.rawValue*2 -40 // +20°
                    color: "#00FF00"
                    visible: _activeVehicle.pitch.rawValue < 26 ? true : false

                    }

                    Text{ //valor 20°
                        font.family: "Helvetica"
                        font.pointSize: 12
                        color: angulos_inclinacao_20p.color
                        text: "20°"
                        x:  angulos_inclinacao_20p.x + angulos_inclinacao_20p.width
                        y:  angulos_inclinacao_20p.y - font.pointSize
                        visible: _activeVehicle.pitch.rawValue < 12 ? true : false
                    }

                    Rectangle{
                    id: angulos_inclinacao_10p
                    width: borda_crosshair.width/3
                    height: borda_crosshair.border.width
                    x: - width/2
                    y: - _activeVehicle.pitch.rawValue*2 -20// +10°
                    color: "#00FF00"
                    visible: _activeVehicle.pitch.rawValue < 39 ? true : false
                    }

                    Text{ //valor 10°
                        font.family: "Helvetica"
                        font.pointSize: 12
                        color: angulos_inclinacao_10p.color
                        text: "10°"
                        x:  angulos_inclinacao_10p.x + angulos_inclinacao_10p.width
                        y:  angulos_inclinacao_10p.y - font.pointSize
                        visible: _activeVehicle.pitch.rawValue < 30 ? true : false
                    }

                    Rectangle{
                    id: angulos_inclinacao_10n
                    width: borda_crosshair.width/3
                    height: borda_crosshair.border.width
                    x: - width/2
                    y: - _activeVehicle.pitch.rawValue*2 +20 // -10°
                    color: "#00FF00"
                    visible: _activeVehicle.pitch.rawValue > -38 ? true : false
                    }

                    Text{ //valor -10°
                        font.family: "Helvetica"
                        font.pointSize: 12
                        color: angulos_inclinacao_10n.color
                        text: "10°"
                        x:  angulos_inclinacao_10n.x + angulos_inclinacao_10n.width
                        y:  angulos_inclinacao_10n.y - font.pointSize
                        visible: _activeVehicle.pitch.rawValue > -35 ? true : false
                    }

                    Rectangle{
                    id: angulos_inclinacao_20n
                    width: borda_crosshair.width/2
                    height: borda_crosshair.border.width
                    x: - width/2
                    y: - _activeVehicle.pitch.rawValue*2 + 40 // -20°
                    color: "#00FF00"
                    visible: _activeVehicle.pitch.rawValue > -25 ? true : false
                    }

                    Text{ //valor -20°
                        font.family: "Helvetica"
                        font.pointSize: 12
                        color: angulos_inclinacao_20n.color
                        text: "20°"
                        x:  angulos_inclinacao_20n.x + angulos_inclinacao_20n.width
                        y:  angulos_inclinacao_20n.y - font.pointSize
                        visible: _activeVehicle.pitch.rawValue > -19 ? true : false
                    }

                }

                    Text{ //valor máximo permitido para o voo
                        font.family: "Helvetica"
                        font.pointSize: 12
                        color: "red"
                        text: _activeVehicle.pitch.valueString
                        x: angulos_inclinacao.x - width/2
                        y: borda_crosshair.y + borda_crosshair.height - font.pointSize*2

                    }




            }
             Item { //COLUNA ESQUERDA DO HUD
                Rectangle{
                    id: coluna_vel_vert
                    y:  borda_crosshair.y - borda_crosshair.height/2
                    x: borda_crosshair.x - borda_crosshair.width
                    width: 5
                    height: borda_crosshair.height*2
                    color: crosshair_central.color
                }
                Text{ //valor máximo permitido para o voo
                    font.family: "Helvetica"
                    font.pointSize: 12
                    color: coluna_vel_vert.color
                    text: "MAX_VEL"
                    x: coluna_vel_vert.x - 70
                    y: coluna_vel_vert.y - font.pointSize/2

                }

                Text{ //valor minimo permitido para o voo
                    font.family: "Helvetica"
                    font.pointSize: 12
                    color: coluna_vel_vert.color
                    text: "MIN_VEL"
                    x: coluna_vel_vert.x - 70
                    y: coluna_vel_vert.y + coluna_vel_vert.height - font.pointSize/2

                }

                Text{ //altitude barométrica
                    id:  pointer_velocidade_vertical
                    font.family: "Helvetica"
                    font.pointSize: 18
                    color: coluna_vel_vert.color
                    y: coluna_vel_vert.y + coluna_vel_vert.height/2 - (coluna_vel_vert.height * _activeVehicle.climbRate.rawValue/10) //assumindo MAX_VEL = 10
                    x: coluna_vel_vert.x - coluna_vel_vert.width - font.pointSize*6
                    text: _activeVehicle.climbRate.valueString + "m/s"
                    visible: _activeVehicle.climbRate.rawValue === "NaN" ? false : true
                }

                Rectangle{
                    width: 10
                    height: 5
                    x: coluna_vel_vert.x - width
                    y: pointer_velocidade_vertical.y +pointer_velocidade_vertical.font.pointSize
                    color: pointer_velocidade_vertical.color
                    visible: pointer_velocidade_vertical.visible
                }

                Rectangle{
                    width: pointer_velocidade_vertical.font.pointSize*6
                    height: pointer_velocidade_vertical.font.pointSize*2
                    x: pointer_velocidade_vertical.x -5
                    y: pointer_velocidade_vertical.y
                    color: "transparent"
                    border.color: crosshair_central.color
                    border.width: 2
                }

            }

             Item { //COLUNA DIRETA DO HUD
                Rectangle{
                    id: coluna_altitude_rel
                    y:  borda_crosshair.y - borda_crosshair.height/2
                    x: borda_crosshair.x + borda_crosshair.width*2
                    width: 5
                    height: borda_crosshair.height*2
                    color: coluna_vel_vert.color
                }
                Text{ //valor máximo permitido para o voo
                    font.family: "Helvetica"
                    font.pointSize: 12
                    color: coluna_altitude_rel.color
                    text: "MAX_ALT"
                    x: coluna_altitude_rel.x + 10
                    y: coluna_altitude_rel.y - font.pointSize/2

                }

                Text{ //valor minimo permitido para o voo
                    font.family: "Helvetica"
                    font.pointSize: 12
                    color: coluna_altitude_rel.color
                    text: "MIN_ALT"
                    x: coluna_altitude_rel.x + 10
                    y: coluna_altitude_rel.y + coluna_altitude_rel.height - font.pointSize/2

                }

                Text{ //altitude Relativa
                    id: pointer_alt_baro
                    font.family: "Helvetica"
                    font.pointSize: 18
                    color: coluna_altitude_rel.color
                    y: coluna_altitude_rel.y + coluna_altitude_rel.height - font.pointSize - (coluna_altitude_rel.height * _activeVehicle.altitudeRelative.rawValue/20) //assumindo MAX_ALT = 50
                    x: coluna_altitude_rel.x + font.pointSize
                    text: _activeVehicle.altitudeRelative.valueString + "m"
                    visible: _activeVehicle.altitudeRelative === 0 ?   false:true
                }

                Rectangle{
                    width: 10
                    height: 5
                    x: coluna_altitude_rel.x
                    y: pointer_alt_baro.y +pointer_alt_baro.font.pointSize
                    color: pointer_alt_baro.color
                    visible: pointer_alt_baro.visible
                }

                Rectangle{
                    width: pointer_alt_baro.font.pointSize*6
                    height: pointer_alt_baro.font.pointSize*2
                    x: pointer_alt_baro.x -5
                    y: pointer_alt_baro.y
                    color: "transparent"
                    border.color: crosshair_central.color
                    border.width: 2
                }

            }

             QGCColoredImage { //bussola FPV
                     id: bussola_fpv
                     width: videoControl.width/5
                     height: videoControl.width/5
                     x: videoControl.width/2 - width/2
                     y: videoControl.y + videoControl.height - height/2


                     color: "#00FF00"
                     source: "/res/bussola_fpv.png"
                     rotation: _activeVehicle.heading.rawValue


             }

             Text {

                 text: _activeVehicle.heading.rawValue
                 font.family: "Helvetica"
                 font.pointSize: 24
                 x: bussola_fpv.x + bussola_fpv.width/2 - font.pointSize
                 y: bussola_fpv.y + bussola_fpv.height/4
                 color: "#00FF00"
                 visible: true

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

    FlyViewMap { //mapa
        id:                     mapControl
        planMasterController:   _planController
       // rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
        x:0
        y: _informacao_central ? 0 : parent.height*4/5
        z: _informacao_central ? 0 : 1
        width: _informacao_central ? area_mapa_camera.width : area_info_bottom.width*0.3
        height: _informacao_central ? area_mapa_camera.height : area_info_bottom.height
        pipMode:                !_mainWindowIsMap
        //toolInsets:             customOverlay.totalToolInsets
        mapName:                "FlightDisplayView"
        visible: true
    }


        Rectangle {
                id: botao_troca_centro
                height: area_info_bottom.height/3
                width: height
                x: 0
                y: parent.height - height
                z: 2
                color: "#AA000000"
        }


        QGCColoredImage { //botão para trocar
                height: botao_troca_centro.width
                width: height
                x: botao_troca_centro.x
                y: botao_troca_centro.y
                z: botao_troca_centro.z
                color: "#AA00FF00"
                source: "/res/spin_icon.png" //"/res/crossHair_res.svg"
        }

    MouseArea { //botão_troca_centro
       id: click_trocar_centro
       z: botao_troca_centro.z
       anchors.fill: botao_troca_centro
       hoverEnabled: true


       onClicked : {
           console.log("posicao x,y do mapa: " + mapControl.x + ", " + mapControl.y)
           console.log("posicao x,y do video: " + videoControl.x + ", " + videoControl.y)
           console.log("teste: " + globals.activeVehicle.cameraManager.currentCamera)
           _informacao_central = !_informacao_central
       }
    }

    Rectangle {
            id: botao_troca_camera
            height: area_info_bottom.height/3
            width: height
            x: area_info_bottom.width*0.3 - width
            y: parent.height - height
            z:2
            color:"#AA000000"
    }

    QGCColoredImage { //botão para trocar camera
            height: botao_troca_camera.width
            width: height
            x: botao_troca_camera.x
            y: botao_troca_camera.y
            z: botao_troca_camera.z
            color: "#AA00FF00"
            source: "/res/camera.svg"
    }
        MouseArea {
           id: click_trocar_camera
           z: botao_troca_camera.z
           anchors.fill: botao_troca_camera
           hoverEnabled: true


           onClicked : {

               console.log(_activeVehicle.cameraManager.currentCamera)
               console.log(_activeVehicle.cameraManager.cameras.count)
               console.log(QGroundControl.settingsManager.videoSettings.videoSource.rawValue)
               console.log(QGroundControl.settingsManager.videoSettings.videoSource.enumString)
               _selecao_camera = !_selecao_camera

               console.log("****************")
           }
        }
    Item {
        x:botao_troca_camera.x - videoSource.width + botao_troca_camera.width
        y:botao_troca_camera.y - videoSource.height
        z:botao_troca_camera.z+1
        visible: _selecao_camera

        GridLayout {
            id:         videoGrid
            columns:    1

            FactComboBox{
                id:                     videoSource
                Layout.preferredWidth:  _comboFieldWidth
                indexModel:             false
                fact:                   QGroundControl.settingsManager.videoSettings.videoSource
            }
        }
    }

    Text {

        text: _activeVehicle.motorCount
        font.family: "Helvetica"
        font.pointSize: 24
        x: monitor_motores.x + monitor_motores.width/2 - font.pointSize/2
        y: monitor_motores.y + monitor_motores.height/2 - font.pointSize
        color: "green"
        visible: true

    }



}
