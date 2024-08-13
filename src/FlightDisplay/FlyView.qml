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

import QtWebSockets 1.1

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

    property bool   _informacao_central :  false //booleano que define se a camera ou o mapa fica no foco central
    property bool   _selecao_camera: false //booleano que decide se a tabela de cameras esta visivel ou não.
    property bool   _conexaoinicial: _activeVehicle.initialConnectComplete //retorna se a conexão inicial com o drone foi realizada
    property bool   _idle: _activeVehicle.healthAndArmingCheckReport.canArm//retorna se o veículo esta pronto para voar
    property bool  _armed: _activeVehicle.armed //retorna se o veículo esta armado
    property bool  _flying: _activeVehicle.flying //autoexplicativo
    property bool _wasFlying: false //indica se ele estava voando até o momento de checagem. Usado pra indicar quando pousou.
    property var _pct_bateria: _activeVehicle.batteries.get(0).percentRemaining.rawValue
    property int _tamanho_fonte_FPV: 12* (Screen.width/Screen.height)/1.88 //valor padrão pra fonte na FPV dimensionada pro monitor do laboratório
    property int _tamanho_fonte_dados_legenda: 14* (Screen.width/Screen.height)/1.88
    property int _tamanho_fonte_dados_numero: 20* (Screen.width/Screen.height)/1.88
    property int _tamanho_fonte_terminal_alertas: 14 * (Screen.width/Screen.height)/1.88
    property int _communication_lost: _activeVehicle.vehicleLinkManager.communicationLost
    property bool _recording_report: false


    property int valor_teste: 0
    property real _pitch: Math.round(_activeVehicle.pitch.value * 10) / 10 //operação matemática para arredondar o número para 1 casa decimal...
    property real _roll:  Math.round(_activeVehicle.roll.rawValue * 10) / 10 //... provavelmente melhora desempenho poupando a CPU de calcular posição de itens na tela com 10 casas decimais de subpixel
    property real _heading: Math.round(_activeVehicle.heading.value)
    property real _altitude_relative: Math.round(_activeVehicle.altitudeRelative.value* 10) / 10
    property real _climb_rate : Math.round(_activeVehicle.climbRate.value* 10) / 10
    property real _parametro_custom_1: controller3.activeSystem.messages.get(0).name //vai ser algo assim, com aquelas coisas de separar por virgula e conversão binária também
    property real _gasolina: _activeVehicle.batteries.get(1).percentRemaining.rawValue //Provavelmente vai ser isso aqui pra GASOLINA 11/06/2024


    property real _temperatura_motor: _pitch //PLACEHOLDER
    property real _temperatura_bateria: _pitch //PLACEHOLDER
    property real _temperatura_motor_eletrico_1 : _pitch //PLACEHOLDER

    property real _tensao_cell_1: 50 //PLACEHOLDER
    property real _tensao_cell_2: 45 //PLACEHOLDER
    property real _tensao_cell_3: 70 //PLACEHOLDER
    property real _tensao_cell_4: 20 //PLACEHOLDER
    property real _tensao_cell_5: 80 //PLACEHOLDER
    property real _tensao_cell_6: 50 //PLACEHOLDER
    property real _tensao_cell_7: 60 //PLACEHOLDER
    property real _tensao_cell_8: 28 //PLACEHOLDER
    property real _tensao_cell_9: 100 //PLACEHOLDER
    property real _tensao_cell_10: 130 //PLACEHOLDER
    property real _tensao_cell_11: 40 //PLACEHOLDER
    property real _tensao_cell_12: 90 //PLACEHOLDER


    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets
   // property real    min_tamanho_tela: Screen.devicePixelRatio

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

    function _resize_fonts(){//essa função deve ajustar os tamanho das fonts de texto de acordo com o tamanho da tela.
        //console.log("x da tela: " + mainWindow.width);
        //console.log("y da tela: " + mainWindow.height);
        return 12 * (mainWindow.width/mainWindow.height)/1.88 //atualiza valor da fonte para 1 * (razão atual da tela/razão da tela do laboratório)
    }

    function _terminal_de_alertas(){
        //socketHandler.connectToServer()
        if(!_flying && _wasFlying){
            console.log("Pousou");
            _wasFlying = false;
        }
        if(_flying && !_wasFlying){
            console.log("Levantou Voo");
            _wasFlying = true;
        }
        var retorno = "";
        //talvez fazer um contador pra cada alerta e se tiver mais de x alertas, retorno = "POUSE IMEDIATAMENTE. CONDIÇÕES PERIGOSAS PARA VOO"
        if(_activeVehicle.gps.hdop.rawValue >= 1){
            console.log("GPS_LOW_PRECISION",_activeVehicle.coordinate)
            retorno = retorno + "- ATENÇÃO: GPS COM BAIXA PRECISÃO\n";
        }
        if(_activeVehicle.rcRSSI > 115){
            console.log("RC_LOW_SIGNAL")
            retorno = retorno + "- ATENÇÃO: SINAL FRACO DE RADIOCONTROLE\n";
        }
        if(_pct_bateria < 15){
            console.log("LOW_BATTERY_POWER")
            retorno = retorno + "- ATENÇÃO: BATERIA BAIXA\n";
        }
        //espaço para alertas futuros. se necessário, fazer função para reajustar tamanho da fonte de acordo com o numero de alertas simultâneos.

        return  retorno;
    }

    function getStatusText() {
        var resposta;
            if (_conexaoinicial && _activeVehicle != null) {
                if (_idle) {
                    _armed=_activeVehicle.armed
                    if(_activeVehicle===null){
                        _conexaoinicial = false;
                    }
                    if (_armed) {
                        resposta = "ARMED";
                    } else {
                        resposta = "READY TO FLY";
                    }
                    if(_flying){
                        resposta = "FLYING"
                    }
                } else {
                    resposta = "PRE-FLIGHT CHECK";
                }
            } else {
                resposta = "DISCONNECTED";

            }
        return resposta;
        }

    function getStatuscolor() {
        var resposta;
            if (_conexaoinicial && _activeVehicle != null) {
                if (_idle) {
                    _armed=_activeVehicle.armed
                    if(_activeVehicle===null){
                        _conexaoinicial = false;
                    }
                    if (_armed) {
                        resposta = "green";
                    } else {
                        resposta = "darkgreen";
                    }
                    if(_flying){
                        resposta = "lime"
                    }
                } else {
                    resposta = "yellow";
                }
            } else {
                resposta = "black";

            }


        return resposta;
        }
   /* MouseArea { //Se a tela for clickada em qualquer posição, a tabela de cameras some.
       anchors.fill: _root
       hoverEnabled: true
       onClicked: {
           _selecao_camera = false;
           _tamanho_fonte_FPV = _resize_fonts()}
    }*/


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
        guidedValueSlider:     _guidedAltSlider
        visible:            false
    }

    GuidedActionConfirm {
        id:                         guidedActionConfirm
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        guidedValueSlider:             _guidedAltSlider
        visible: false
    }

    GuidedActionList {
        id:                         guidedActionList
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        visible: false
    }

    //-- Altitude slider (preciso pra debugar o simulador)
    GuidedValueSlider {
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
             MAIS ALTERAÇÕES: MOUSEAREA NA LINHA 57 26/05/2022
             FUNÇÃO "_terminal_de_alertas" 23/06/2022
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
        //text: _pitch //isso funciona. pra acessar deve ser então _activeVehicle.(atributo).rawValue (nem sempre rawValue, olhar no header)
       // text: _pitch
        font.family: "Helvetica"
        font.pointSize: 24
        color: qgcPal.colorRed//"red"
    }



    Rectangle{ //area pras informações na direita da tela
        id: area_info_right
        x: parent.width*7/8
        y: 0
        width: parent.width*1/8
        height: parent.height*5/6
        color: qgcPal.window //"#0A283F"
    }



    Item{ //Sliders de corrente individual e tensão de barramento


        Rectangle { //area para as informações em sliders
            id: area_info_sliders
            x: area_info_right.x
            y: area_info_right.height*0.7
            z:1
            color: "transparent"
            border.color: "black"
            border.width: 2
            width: area_info_right.width
            height: area_info_right.height/3
        }

            Rectangle { // exemplo de slide, pitch não é um valor relevante para um slider mas é um fácil de se testar em laboratório
                id: slider_0
                x: area_info_sliders.x + area_info_sliders.width*1/14
                y: area_info_sliders.y + area_info_sliders.width*1/11
                width: area_info_sliders.width/14 //estou usando isso como tamanho e espaçamento dos sliders
                height: area_info_sliders.height * 0.65
                color: _pitch < 45 ? "green" : "red"

            }

               Rectangle { // cresce ou diminui conforme o valor do slider acima para fazer a barra diminuir ou aumentar
                    x: slider_0.x
                    y: slider_0.y
                    width: slider_pitch.width
                    height: Math.abs(2*(_roll) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                     height: Math.abs(2*(_roll) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                         height: Math.abs(2*(_roll) )//os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                             height: Math.abs(2*(_roll) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                                 height: Math.abs(2*(_roll) ) //os atributos que podem ser acessados estão em headers/src/vehicles.h
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
                                     height: Math.abs(2*(_roll) )//os atributos que podem ser acessados estão em headers/src/vehicles.h
                                     color: "black"

                                 }

                                Text{
                                    text: "TEMPERATURA EM CADA MOTOR"
                                    font.family: "Helvetica"
                                    font.pointSize: _tamanho_fonte_dados_legenda * 0.8
                                    color: "white"
                                    x: slider_0.x
                                    y: slider_0.y + slider_0.height/2 - font.pointSize
                                   // text: _pitch //isso funciona. pra acessar deve ser então _activeVehicle.(atributo).rawValue (nem sempre rawValue, olhar no header)
                                   // text: _pitch

                                }




              }

Item{
    Rectangle { //area para as informações em sliders
        id: area_slider_tensão
        x: area_info_sliders.x
        y: area_info_sliders.y - height
        z:11
        color: "transparent"
        border.color: "black"
        border.width: 2
        width: area_info_right.width
        height: area_info_right.height/8

        Button {
                visible: _activeVehicle && !_recording_report
                text: "Start Report"
                anchors.centerIn: parent
                onClicked: {
                    console.log("COMEÇAR_RELATÓRIO", _activeVehicle.coordinate)
                    _recording_report = true
                }
        }
        Button {
                visible: _activeVehicle && _recording_report
                text: "End Report"
                anchors.centerIn: parent
                onClicked: {
                    console.log("FINALIZAR_RELATÓRIO", _activeVehicle.coordinate)
                    _recording_report = false
                }
        }

       /* Rectangle{
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width*0.9
            height: parent.height/5
            color: "green"
        }*/

    }
    /*Text {
        x: area_info_sliders.x + 30
        y: area_info_sliders.y - 40
        text: "TENSÃO DE BARRAMENTO"
        font.family: "Clearview"
        font.pointSize: _tamanho_fonte_dados_legenda * 0.8
        color: "white"
    }*/

}

Item{
    Rectangle{
        id:area_temperaturas
        x:area_info_right.x
        y:area_slider_tensão.y - height
        z:area_slider_tensão.z+1
        color: "transparent"
        border.color: "black"
        border.width: 2
        width: area_info_right.width
        height: area_info_right.height/3
        //visible: _activeVehicle? true: false
    }

        QGCColoredImage { //Icone para tensão da bateria
                id: icon_temp_motor
                x: area_temperaturas.x
                y: area_temperaturas.y
                width: area_temperaturas.width/2
                height: area_temperaturas.height/2
                color: white
                source: "/res/motor_temperature_icon"
                z: area_temperaturas.z+10
        }

        QGCColoredImage { //Icone para tensão da bateria
                id: icon_temp_elec_motors
                x: area_temperaturas.x
                y: area_temperaturas.y + icon_temp_motor.height
                width: area_temperaturas.width/2
                height: area_temperaturas.height/2
                color: white
                source: "/res/eletric_motor_temperature_icon"
                z: area_temperaturas.z+10
        }



        /*Text{

           text: "ESTIMATIVA DE VOO"
           font.family: "Clearview"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.verticalCenter: parent.verticalCenter
           verticalAlignment: Text.AlignVCenter
        }*/
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
            source: "/res/Quadrotor_layout"

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

            Text{

               text: getStatusText()
               font.family: "Helvetica"
               font.pointSize: _tamanho_fonte_dados_legenda
               color: "#FFFFFF"
               anchors.horizontalCenter: parent.horizontalCenter
               anchors.top: parent.bottom
               verticalAlignment: Text.AlignVCenter
            }

            Rectangle{
               id: vehicle_status_bar
               width: parent.width/10
               height: parent.width/10
               //x: parent.width/2 - width/2
               anchors.horizontalCenter: parent.horizontalCenter
               y: parent.height/2 - height/2
               z: parent.z +1
               radius: width* 0.5
               border.color: "white"//parent.color
               border.width: 1
               color: getStatuscolor()
            }
        }
   }


    Rectangle { //AREA ONDE O VIDEO APARECE
        id: area_mapa_camera
        x: 0
        y: 0
        width: parent.width*7/8
        height: parent.height - area_info_bottom.height
        color: "transparent"
    }



       /* Text {
            x: 600
            y:600
            z:1000
            text: (_activeVehicle.batteries.get(0).percentRemaining.valueString)
            font.family: "Helvetica"
            font.pointSize: 80
            color: "#80FF0000"
            visible: true
        }*/



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
        color: qgcPal.window //"#0A283F"
    }
    Rectangle{ //area para alertas e informações. Estilo painel de carro
            id: area_alertas
            x: parent.width*0.3
            y: parent.height*4/5
            width: parent.width*0.4
            height: parent.height*1/5
            color: qgcPal.window //"#0A283F"
            z: area_info_bottom.z +3
        }

    Rectangle{
        id: terminal_alertas
        x: parent.width*0.7
        y: parent.height*4/5
        width: parent.width*0.3
        height: parent.height*1/5
        color: "black"//"#0A283F"
        z: area_info_bottom.z +2

        Text{
            id: alerta_textual
            text: _activeVehicle ? _terminal_de_alertas() : " "//chama função que retorna todos os alertas em forma textual.
            font.family: "Clearview"
            font.pointSize: _tamanho_fonte_terminal_alertas
            color: "#FFFFFF"
            z: parent.z+1
            anchors.top: parent.top
            anchors.left: parent.left

        }
    }

    Rectangle{
        id: alerta_bateria
        x: area_alertas.x
        y: area_alertas.y
        z: area_alertas.z+1
        width: area_alertas.width/2
        height: area_alertas.height
        color: "transparent"
        border.width: 1
        border.color: "black"



        /*Text{

           text: "BATTERY"
           font.family: "Clearview"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.verticalCenter: parent.verticalCenter
           verticalAlignment: Text.AlignVCenter
        }*/

        Text{

           property real valor_antigo : _pct_bateria
           text: _pct_bateria
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_numero
           color: "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.bottom: parent.bottom
           verticalAlignment: Text.AlignVCenter
        }

    }
    QGCColoredImage { //Icone para carga da bateria
            id: icon_bateria
            x: alerta_bateria.x - icon_bateria.width/5
            y: alerta_bateria.y + alerta_bateria.height*0.1
            width: alerta_bateria.width/3
            height: alerta_bateria.height/2
            color: white
            source: "/qmlimages/Battery.svg"
            z: alerta_bateria.z+10
    }

    QGCColoredImage { //Icone para tensão da bateria
            id: icon_tensao
            x: icon_bateria.x + icon_bateria.width*(2/3)
            y: icon_bateria.y
            width: alerta_bateria.width/3
            height: alerta_bateria.height/2
            color: white
            source: "/res/lighting_icon"
            z: alerta_bateria.z+10
    }

    Rectangle { //Espaço para barras de tensão de células de bateria
        id: area_slider_tensão_celulas
        x: icon_tensao.x + icon_tensao.width/4 + icon_bateria.width*(2/3)
        y: icon_tensao.y
        z:11
        color: "black"
        border.color: "black"
        border.width: 2
        width: alerta_bateria.width/2
        height: alerta_bateria.height*0.8

        Rectangle{
            x: 0
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_1
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width/12
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_2
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(2/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_3
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(3/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_4
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(4/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_5
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(5/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_6
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(6/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_7
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(7/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_8
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(8/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_9
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(9/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_10
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(10/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_11
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }
        Rectangle{
            x: parent.width*(11/12)
            anchors.bottom: parent.bottom
            width: parent.width/12
            height:  _tensao_cell_12
            z:parent.z+1
            color:"green"
            border.color: "black"
            border.width: 1
        }

        }

    Rectangle{
        id: alertas_misc
        x: area_alertas.x+area_alertas.width/2
        y: area_alertas.y
        z: area_alertas.z+1
        width: area_alertas.width/2
        height: area_alertas.height
        color: "transparent"
        border.width: 1
        border.color: "black"

    }

    QGCColoredImage { //Icone para carga da bateria
            id: icon_gasolina
            x: alertas_misc.x
            y: alertas_misc.y + alertas_misc.height*0.1
            width: alertas_misc.width/3
            height: alertas_misc.height/2
            color: white
            source: "/res/gas_can_icon"
            z: alertas_misc.z+10
    }

    QGCColoredImage { //Icone para tensão da bateria
            id: icon_satelite
            x: icon_gasolina.x + icon_gasolina.width//*(2/3)
            y: icon_gasolina.y
            width: alertas_misc.width/3
            height: alertas_misc.height/2
            color: white
            source: "/qmlimages/Gps.svg"
            z: alertas_misc.z+10
    }

    QGCColoredImage { //Icone para tensão da bateria
            id: icon_RC
            x: icon_satelite.x + icon_gasolina.width//*(2/3)
            y: icon_gasolina.y
            width: alertas_misc.width/3
            height: alertas_misc.height/2
            color: white
            source: "/qmlimages/RC.svg"
            z: alertas_misc.z+10
    }



    /*Rectangle{
        id: alerta_gps
        x: area_alertas.x + area_alertas.width/4
        y: area_alertas.y
        z: area_alertas.z+1
        width: area_alertas.width/4
        height: area_alertas.height
        color: "transparent"
        border.width: 1
        border.color: "black"

        Text{

           text: "GPS"
           font.family: "Clearview"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: _activeVehicle.gps.count.rawValue <=15 ? (_activeVehicle.gps.count.rawValue <10 ? "red" : "yellow"): "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.verticalCenter: parent.verticalCenter
           verticalAlignment: Text.AlignVCenter
        }

        Text{

           text: _activeVehicle.gps.count.rawValue //"num_satelites"
           font.family: "Clearview"
           font.pointSize: _tamanho_fonte_dados_numero
           color: "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.bottom: parent.bottom
           verticalAlignment: Text.AlignVCenter
        }

    }*/

    /*Rectangle{
        id: alerta_RC
        x: area_alertas.x + area_alertas.width*0.6
        y: area_alertas.y
        z: area_alertas.z+1
        width: area_alertas.width/4
        height: area_alertas.height
        color: "transparent"
        border.width: 1
        border.color: "black"

        Text{

           text: "RADIO"
           font.family: "Bold"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: _activeVehicle.rcRSSI >= 115 ? (_activeVehicle.rcRSSI  >= 175 ? "red" : "yellow"): "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.verticalCenter: parent.verticalCenter
           verticalAlignment: Text.AlignVCenter
        }

        Text{

           text: _activeVehicle.rcRSSI //"quality_sinal"
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_numero
           color: "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.bottom: parent.bottom
           verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle{
        id: alerta_gasolina
        x: area_alertas.x + area_alertas.width*3/4
        y: area_alertas.y
        z: area_alertas.z+1
        width: area_alertas.width/4
        height: area_alertas.height
        color: "transparent"
        border.width: 1
        border.color: "black"

        Text{

           text: "GAS"
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.verticalCenter: parent.verticalCenter
           verticalAlignment: Text.AlignVCenter
        }

        Text{

           text: socketHandler.message + " litros"
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_numero
           color: "#FFFFFF"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.bottom: parent.bottom
           verticalAlignment: Text.AlignVCenter
        }
    }*/

    /*Rectangle{
        id: alerta_texto
        x: area_alertas.x + area_alertas.width
        y: area_alertas.y
        z: area_alertas.z+1
        color: "transparent"
        width: area_alertas.width/3
        height: area_alertas.height
        border.width: 1
        border.color: "black"

        Text{
           id: txt_pitch
           text: "PITCH: " + _pitch
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: "#FFFFFF"
           anchors.margins: 2
           anchors.left: parent.left
           anchors.top: parent.top
        }

        Text{
           id: txt_roll
           text: "ROLL: " + _roll
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: "#FFFFFF"
           anchors.left: txt_pitch.left
           anchors.top: txt_pitch.bottom
        }

        Text{
           id: txt_vel
           text: "VELOCIDADE: " + Math.round(_activeVehicle.airSpeed.value * 100) / 100
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: "#FFFFFF"
           anchors.left: txt_pitch.left
           anchors.top: txt_roll.bottom
        }

        Text{

           text: "ALTITUDE: " + _altitude_relative
           font.family: "Helvetica"
           font.pointSize: _tamanho_fonte_dados_legenda
           color: "#FFFFFF"
           anchors.left: txt_pitch.left
           anchors.top: txt_vel.bottom
        }

    }*/


    /* VERSÃO ANTIGA DOS ALERTAS. USAR COMO REFERÊNCIA E DEPOIS DELETAR.
    QGCColoredImage{
           id: alerta_bateria
           x: area_alertas.x - width*0.35
           y: area_alertas.y+ height*0.4
           z: area_alertas.z+1
           width: area_alertas.width/5
           height: area_alertas.height/2.5
           color: "#FFFFFF"
           source: "/qmlimages/Battery.svg"
           Text{
              text: _activeVehicle.batteries.get(0).percentRemaining.rawValue//_pct_bateria. por que essa bosta não funciona?
              font.family: "Helvetica"
              font.pointSize: ScreenTools.defaultFontPixelWidth
              color: "#FFFFFF"
              z: parent.z+1
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.bottom
              verticalAlignment: Text.AlignVCenter
           }
       }
    QGCColoredImage{
           id: alerta_gps
           x: alerta_bateria.x + width*0.22
           y: alerta_bateria.y
           z: area_alertas.z+1
           width: alerta_bateria.width
           height: alerta_bateria.height
           color: _activeVehicle.gps.hdop.rawValue >= 1 ? (_activeVehicle.gps.hdop.rawValue >= 1.5 ? "red" : "yellow"): "#FFFFFF"
           source: "/qmlimages/Gps.svg"
           Text{
              text: _activeVehicle.gps.hdop.rawValue//_HDOP
              font.family: "Helvetica"
              font.pointSize: ScreenTools.defaultFontPixelWidth
              color:  "#FFFFFF"
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.bottom
              verticalAlignment: Text.AlignVCenter
           }
       }
    QGCColoredImage{
           id: alerta_RC
           x: alerta_gps.x + width*0.22
           y: alerta_bateria.y
           z: area_alertas.z+1
           width: alerta_bateria.width
           height: alerta_bateria.height
           color: _activeVehicle.rcRSSI >= 115 ? (_activeVehicle.rcRSSI  >= 175 ? "red" : "yellow"): "#FFFFFF"
           source: "/qmlimages/RC.svg"
           Text{
              text: _activeVehicle.rcRSSI //descobrir qual parametro de vehicle recebe conexão RC
              font.family: "Helvetica"
              font.pointSize: ScreenTools.defaultFontPixelWidth
              color:"#FFFFFF"
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.bottom
              verticalAlignment: Text.AlignVCenter
           }
       }
    QGCColoredImage{
           id: alerta_combustivel
           x: alerta_RC.x + width*0.22
           y: alerta_bateria.y
           z: area_alertas.z+1
           width: alerta_bateria.width
           height: alerta_bateria.height
           color: "#FFFFFF"
           source: "/res/Fuel.png"
           Text{
              text: "LITROS"//Depende de quando e como recebermos a informação da gasolina restante.
              font.family: "Helvetica"
              font.pointSize: ScreenTools.defaultFontPixelWidth
              color: "#FFFFFF"
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.bottom
              verticalAlignment: Text.AlignVCenter
           }
       }
    Text{
        id: indicador_pitch
        x: area_alertas.x + area_alertas.width*0.2
        y: alerta_combustivel.y
        z: alerta_combustivel.z+1
        text: qsTr("PITCH: ") + _activeVehicle.pitch.valueString
        font.family: "Helvetica"
        font.pointSize: ScreenTools.defaultFontPixelWidth*2
        color: "#FFFFFF"
    }
    Text{
        id: indicador_roll
        x: indicador_pitch.x
        y: indicador_pitch.y + indicador_pitch.font.pointSize*1.1
        z: alerta_combustivel.z+1
        text: qsTr("ROLL: ") + _activeVehicle.roll.valueString
        font.family: "Helvetica"
        font.pointSize: ScreenTools.defaultFontPixelWidth*2
        color: "#FFFFFF"
    }
    */




            FlyViewVideo { //video da camera
                id: videoControl
                x: 0
                y: !_informacao_central ? 0 : parent.height*4/5
                width: !_informacao_central ? area_mapa_camera.width : area_info_bottom.width*0.3
                height:!_informacao_central ? area_mapa_camera.height : area_info_bottom.height
                z: !_informacao_central ? 0 : 1



                //visible: !_informacao_central
            }

            Rectangle{
                id: borda_video
                anchors.fill: videoControl
                color: "transparent"
                border.width: _informacao_central ? 1 : 5
                border.color: black
                z: videoControl.z+5
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
                        source: "/res/crossHair_res"
                        rotation: _roll
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
                    visible: !_informacao_central

                    Rectangle{
                    id: angulos_inclinacao_20p
                    width: borda_crosshair.width/2
                    height: borda_crosshair.border.width
                    x: - width/2
                    y:  - _pitch*2 -40 // +20°
                    color: "#00FF00"
                    visible: _pitch < 26 ? true : false

                    }

                    Text{ //valor 20°
                        font.family: "Helvetica"
                        font.pointSize: _tamanho_fonte_FPV
                        color: angulos_inclinacao_20p.color
                        text: "20°"
                        x:  angulos_inclinacao_20p.x + angulos_inclinacao_20p.width
                        y:  angulos_inclinacao_20p.y - font.pointSize
                        visible: _pitch < 12 ? true : false
                    }

                    Rectangle{
                    id: angulos_inclinacao_10p
                    width: borda_crosshair.width/3
                    height: borda_crosshair.border.width
                    x: - width/2
                    y: - _pitch*2 -20// +10°
                    color: "#00FF00"
                    visible: _pitch < 39 ? true : false
                    }

                    Text{ //valor 10°
                        font.family: "Helvetica"
                        font.pointSize: _tamanho_fonte_FPV
                        color: angulos_inclinacao_10p.color
                        text: "10°"
                        x:  angulos_inclinacao_10p.x + angulos_inclinacao_10p.width
                        y:  angulos_inclinacao_10p.y - font.pointSize
                        visible: _pitch < 30 ? true : false
                    }

                    Rectangle{
                    id: angulos_inclinacao_10n
                    width: borda_crosshair.width/3
                    height: borda_crosshair.border.width
                    x: - width/2
                    y: - _pitch*2 +20 // -10°
                    color: "#00FF00"
                    visible: _pitch > -38 ? true : false
                    }

                    Text{ //valor -10°
                        font.family: "Helvetica"
                        font.pointSize: _tamanho_fonte_FPV
                        color: angulos_inclinacao_10n.color
                        text: "10°"
                        x:  angulos_inclinacao_10n.x + angulos_inclinacao_10n.width
                        y:  angulos_inclinacao_10n.y - font.pointSize
                        visible: _pitch > -35 ? true : false
                    }

                    Rectangle{
                    id: angulos_inclinacao_20n
                    width: borda_crosshair.width/2
                    height: borda_crosshair.border.width
                    x: - width/2
                    y: - _pitch*2 + 40 // -20°
                    color: "#00FF00"
                    visible: _pitch > -25 ? true : false
                    }

                    Text{ //valor -20°
                        font.family: "Helvetica"
                        font.pointSize: _tamanho_fonte_FPV
                        color: angulos_inclinacao_20n.color
                        text: "20°"
                        x:  angulos_inclinacao_20n.x + angulos_inclinacao_20n.width
                        y:  angulos_inclinacao_20n.y - font.pointSize
                        visible: _pitch > -19 ? true : false
                    }

                }

                    Text{ //valor máximo permitido para o voo
                        font.family: "Helvetica"
                        font.pointSize: _tamanho_fonte_FPV
                        color: "red"
                        text: _pitch
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
                    font.pointSize: _tamanho_fonte_FPV
                    color: coluna_vel_vert.color
                    text: "MAX_VEL"
                    x: coluna_vel_vert.x - 70
                    y: coluna_vel_vert.y - font.pointSize/2

                }

                Text{ //valor minimo permitido para o voo
                    font.family: "Helvetica"
                    font.pointSize: _tamanho_fonte_FPV
                    color: coluna_vel_vert.color
                    text: "MIN_VEL"
                    x: coluna_vel_vert.x - 70
                    y: coluna_vel_vert.y + coluna_vel_vert.height - font.pointSize/2

                }

                Text{ //altitude barométrica
                    id:  pointer_velocidade_vertical
                    font.family: "Helvetica"
                    font.pointSize: _tamanho_fonte_FPV
                    color: coluna_vel_vert.color
                    y: coluna_vel_vert.y + coluna_vel_vert.height/2 - (coluna_vel_vert.height * _climb_rate /10) //assumindo MAX_VEL = 10
                    x: coluna_vel_vert.x - coluna_vel_vert.width - font.pointSize*6
                    text: _climb_rate  + "m/s"
                    visible: _climb_rate  === "NaN" ? false : true
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
                    font.pointSize: _tamanho_fonte_FPV
                    color: coluna_altitude_rel.color
                    text: "MAX_ALT"
                    x: coluna_altitude_rel.x + 10
                    y: coluna_altitude_rel.y - font.pointSize/2

                }

                Text{ //valor minimo permitido para o voo
                    font.family: "Helvetica"
                    font.pointSize: _tamanho_fonte_FPV
                    color: coluna_altitude_rel.color
                    text: "MIN_ALT"
                    x: coluna_altitude_rel.x + 10
                    y: coluna_altitude_rel.y + coluna_altitude_rel.height - font.pointSize/2

                }

                Text{ //altitude Relativa
                    id: pointer_alt_baro
                    font.family: "Helvetica"
                    font.pointSize: _tamanho_fonte_FPV
                    color: coluna_altitude_rel.color
                    y: coluna_altitude_rel.y + coluna_altitude_rel.height - font.pointSize - (coluna_altitude_rel.height * _altitude_relative/20) //assumindo MAX_ALT = 50
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
                     source: "/res/bussola_fpv"
                     rotation: _heading


             }

             Text {

                 text: _heading
                 font.family: "Helvetica"
                 font.pointSize: _informacao_central ? _tamanho_fonte_FPV : _tamanho_fonte_FPV*2
                 verticalAlignment: Text.AlignVCenter
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
                rotation: _roll
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
    Rectangle{
        id: borda_mapa
        anchors.fill: mapControl
        color: "transparent"
        border.width: _informacao_central ? 5 : 1
        border.color: black
        z:mapControl.z
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
                source: "/res/spin_icon" //"/res/crossHair_res.svg"
        }

       /* ParameterEditorController { //talvez não precise mais disso
            id: controller2
        }
        ParameterEditor {
            id: parameters_vehicle
            visible: false
        }*/
        MAVLinkInspectorController {
            id: controller3
        }

    MouseArea { //botão_troca_centro
       id: click_trocar_centro
       z: botao_troca_centro.z
       anchors.fill: botao_troca_centro
       hoverEnabled: true


       //Acredito que o caminho seja por aqui. O Controller2 parece promissor mas é bom olhar no PARAMETEREDITOR.QML depois pra pegar outras possibilidades
      /* property Fact fact1: parameters_vehicle._controller.getParameterFact(-1,"IMU_ACCEL_CUTOFF").value
       property Fact fact2: parameters_vehicle._controller.getParameterFact(-1,"BAT1_V_CHARGED")
       property Fact fact3: parameters_vehicle._controller.getParameterFact(-1,"LNDMC_ALT_GND")
       property Fact fact4: parameters_vehicle._controller.getParameterFact(-1, "IMU_ACCEL_CUTOFF")*/


       onClicked : {

           _informacao_central = !_informacao_central

           //mavlinkconsole.sendCommand("testando foda")
           //console.log("teste 2" + RadioComponentController.controller)
          // parameters_vehicle._controller.currentCategory = parameters_vehicle._controller.categories.get(0) //seta a categoria dos parametros como STANDARD
          // console.log("teste 2: " + parameters_vehicle._controller.parameters) //talvez isso aqui seja a resposta pro nosso problema de comunicação com a rasp.
          /*
           console.log(parameters_vehicle._controller.parameters.get(0).name)
           console.log(parameters_vehicle._controller.parameters.get(0).rawValue)
           console.log(parameters_vehicle._controller.parameters.get(0).defaultValue)
           console.log(parameters_vehicle._controller.parameters.get(1).name)
           console.log(parameters_vehicle._controller.parameters.get(1).rawValue)
           console.log(parameters_vehicle._controller.parameters.get(1).defaultValue)
           console.log(parameters_vehicle._controller.parameters.get(2).name)
           console.log(parameters_vehicle._controller.parameters.get(2).rawValue)
           console.log(parameters_vehicle._controller.parameters.get(2).defaultValue)
           console.log(parameters_vehicle._controller.currentCategory.name)*/

           //console.log(_parametro_custom_1)
           //console.log("TESTE, 1, 11, 1011, 1111,")
           //console.log(_armed)
           //console.log(_idle)
           /*if(_activeVehicle===null){
                console.log("sem veiculo")
           }*/

            //controller3.activeSystem.selected = 0
            //TODO: TEM QUE ITERAR SOBRE TODOS PRA ENCONTRAR OS QUE EU QUERO. MUITO PROVAVELMENTE NÃO ESTARÃO ORDENADOS ASSIM SEMPRE
           //console.log(controller3.activeSystem.messages.get(5).fields.get(1).name," ", controller3.activeSystem.messages.get(5).fields.get(1).value) //breach status
          /* console.log(controller3.activeSystem.messages.get(0).name)
           console.log(controller3.activeSystem.messages.get(0).id)
           console.log(controller3.activeSystem.messages.get(0).count)
           console.log(controller3.activeSystem.messages.get(0).fields.get(0).name)
           console.log(controller3.activeSystem.messages.get(0).fields.get(0).value)
           console.log(controller3.activeSystem.messages.get(0).fields.get(0).type)
           console.log(controller3.activeSystem.messages.get(1).fields.get(1).name)
           console.log(controller3.activeSystem.messages.get(1).fields.get(1).value)
           console.log(controller3.activeSystem.messages.get(0).fields.get(0).type)*/


           //controller3.systems.get(0).name


//


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


            RadioComponentController {
                id:             controller
                statusText:     statusText
                cancelButton:   cancelButton
                nextButton:     nextButton
                skipButton:     skipButton
                onChannelCountChanged:              updateChannelCount()
            }



    QGCColoredImage { //botão para trocar camera
            height: botao_troca_camera.width
            width: height
            x: botao_troca_camera.x
            y: botao_troca_camera.y
            z: botao_troca_camera.z
            color: "#AA00FF00"
            source: "/res/camera"
    }
        MouseArea {
           id: click_trocar_camera
           z: botao_troca_camera.z
           anchors.fill: botao_troca_camera
           hoverEnabled: true


           onClicked : {

               //console.log(_activeVehicle.cameraManager.currentCamera)
               //console.log(_activeVehicle.cameraManager.cameras.count)
               //console.log(QGroundControl.settingsManager.videoSettings.videoSource.rawValue)
               //console.log(QGroundControl.settingsManager.videoSettings.videoSource.enumString)
              // console.log(controller.channelCount.rawValue)
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


/*
    Item { // ta uma bosta isso aqui. Não funciona controller2 é meme. Ele ta lendo outra merda só deus sabe o que
        x:500
        y:200
        z:2000
        GridLayout {
            id:         videoGrid2
            columns:    1
            FactComboBox{
                id:                     videoSource2
                Layout.preferredWidth:  _comboFieldWidth
                indexModel:             false
                fact:                   parameters_vehicle._controller.parameters
            }
        }
    }
*/

    WebSocket {
        id: webSocket
        url: "ws://localhost:8765"  // Adjusted to port 8767 for receiving messages
        active: true

        onStatusChanged: {
            if (webSocket.status === WebSocket.Open) {
                console.log("WebSocket connected!")
            } else if (webSocket.status === WebSocket.Closed) {
                console.log("WebSocket closed")
            }
        }

        onTextMessageReceived: {
            console.log("Received message: " + message)
            receivedMessage.text = "Received message: " + message
        }

    }



    Column {
        spacing: 10
        anchors.centerIn: parent
        visible:false

        Button {
            text: "Connect"
            onClicked: {
                webSocket.active = true
            }
        }

        TextField {
            id: messageField
            placeholderText: "Message"
        }

        Button {
            text: "Send"
            onClicked: {
                webSocket.active = true
                if (webSocket.status === WebSocket.Open) {
                    webSocket.sendTextMessage(messageField.text)
                    console.log("Sent message: " + messageField.text)
                    messageField.text = ""  // Clear the input field after sending
                } else {
                    console.error("WebSocket is not open.")
                    //webSocket.status = WebSocket.Open

                }
            }
        }

        Text {
            id: receivedMessage
            text: "Received message: "
        }
    }



}
