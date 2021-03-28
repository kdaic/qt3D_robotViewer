import QtQuick 2.9
/* import QtQuick.Window 2.0 */
import QtQuick.Controls 2.1
import QtQuick.Scene3D 2.0

import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.1


import Qt3D.Core 2.9
import Qt3D.Render 2.9
import Qt3D.Extras 2.9
import Qt3D.Input 2.1


ApplicationWindow {
    id: mainWindow
    width: 800
    height: 480
    /* width: 1280 */
    /* height: 820 */
    title: qsTr("ModelView")
    visible: true
    locale:locale
    property string modelPath : "../models/PA10_obj/"
    property string panelColor : "lightgray"
    property int preciseDigit : 5
    property int jointLabelWidth : 2
    property int jointTopLabelFontPixelSize : 18
    property int jointFontPixelSize : 16
    property bool is_servo_unlock: true

    signal reemitted(var angles, bool isServoUnLock)
    // このManager.dataReadyがpythonから受け渡されている
    Component.onCompleted: Manager.dataReady.connect(mainWindow.reemitted)

    onReemitted: {
        /* console.log("Event Handler", angles) */
        transform_j1.rotZ       = angles[0]
        transform_j2.rotX       = angles[3]
        transform_j3.rotZ       = angles[4]
        transform_j4.rotX       = angles[5]
        transform_j5.rotZ       = angles[6]
        transform_j6.rotX       = angles[7]
        transform_j7.rotZ       = angles[8]
        transform_hand_l.slideY = angles[9]
        transform_hand_r.slideY = angles[10]
        is_servo_unlock         = isServoUnLock
    }



    Pane{
        id: mainPanel
        anchors.fill: parent
        padding: 0
        background: Rectangle {
            color: panelColor
        }
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.leftMargin: 0
        Layout.rightMargin: 0

        RowLayout{
            id: mainRowLO
            anchors.fill: parent
            /* spacing: 15 */
            spacing: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: 0
            Layout.rightMargin: 0

            // 3Dモデル表示パネル
            Pane{
                id: scene3dPanel
                padding: 0
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: 200
                Layout.minimumWidth: 400
                Layout.leftMargin: 0
                Layout.rightMargin: 0

                //[0] QtQuick の環境で Qt3D を使えるようにします
                Scene3D {
                    anchors.fill: parent
                    focus: true
                    aspects: ["input", "logic"]


                    Entity {
                        id: mainRoot

                        Camera {
                            id: camera
                            projectionType: CameraLens.PerspectiveProjection
                            fieldOfView: 30
                            aspectRatio: 16/9
                            nearPlane : 0.1
                            farPlane : 10000.0
                            position: Qt.vector3d( -4.0, 3.0, 0.0 )
                            /* position: Qt.vector3d( -2.0, 1.5, 0.0 ) */
                            upVector: Qt.vector3d( 0.0, 1.0, 0.0 )
                            viewCenter: Qt.vector3d( 0.0, 0.5, 0.0 )
                        }

                        OrbitCameraController {
                            camera: camera
                        }

                        components: [
                            RenderSettings {
                                activeFrameGraph: ForwardRenderer {
                                    // 背景色
                                    clearColor: (is_servo_unlock == true ) ? Qt.rgba(0.0, 0.1, 0.1, 1) : "yellow"
                                    camera: camera
                                }
                            },
                            DirectionalLight {
                                color: "white"
                                intensity: 0.5
                            },
                            // Event Source will be set by the Qt3DQuickWindow
                            InputSettings { },
                            ObjectPicker{
                                id: spherePicker
                                onPressed:{
                                    //myCar.notifyClick()
                                }
                            }

                        ]

                        NumberAnimation {
                            id: animationMoving
                            target: transform
                            /* properties: "rotateX" */
                            property: "rotateY"
                            /* properties: "rotateZ" */
                            duration: 3000
                            from: 0
                            to: 359
                            loops: Animation.Infinite
                            running: false
                        }


                        // Apply global blender transformation
                        Entity {
                            components: Transform {
                                id: transform
                                property real rotateX: -90.0
                                property real rotateY: 0.0
                                property real rotateZ: 90.0
                                rotation: fromEulerAngles(rotateX, rotateY, rotateZ);
                            }

                            Entity {
                                id: base
                                /* components: [ mesh, alpha, material] */
                                components: [mesh_base, alpha, transform_base]
                                Transform {
                                    id: transform_base
                                    property real rotZ: 0.0
                                    matrix: Qt.matrix4x4(1, 0, 0, 0.0,
                                                         0, 1, 0, 0.0,
                                                         0, 0, 1, 0.0,
                                                         0, 0, 0, 1.0)
                                    rotation: fromEulerAngles(0, 0, rotZ);
                                }

                                PhongAlphaMaterial {
                                    id: alpha
                                    alpha: 1.0
                                    ambient: Qt.rgba( 0.5, 0.5, 0.5, 1 )
                                    diffuse: Qt.rgba( 0.5, 0.5, 0.5, 1 )
                                    specular: Qt.rgba( 0.5, 0.5, 0.5, 1 )
                                    shininess: 0.3
                                }

                                Mesh {
                                    id: mesh_base
                                    source: modelPath + "base.obj"
                                }


                                Entity {
                                    id: j1
                                    components: [ mesh_j1, alpha, transform_j1]
                                    Transform {
                                        id: transform_j1
                                        property real rotZ: 0.0
                                        matrix: Qt.matrix4x4(1, 0, 0, 0.0,
                                                             0, 1, 0, 0.0,
                                                             0, 0, 1, 0.2,
                                                             0, 0, 0, 1.0)
                                        rotation: fromEulerAngles(0, 0, rotZ);
                                    }
                                    Mesh {
                                        id: mesh_j1
                                        source: modelPath + "j1.obj"
                                    }


                                    Entity {
                                        id: j2
                                        components: [ mesh_j2, alpha, transform_j2]
                                        Transform {
                                            id: transform_j2
                                            property real rotX: 0.0
                                            matrix: Qt.matrix4x4(1, 0, 0, 0.0,
                                                                 0, 1, 0, 0.0,
                                                                 0, 0, 1, 0.115,
                                                                 0, 0, 0, 1.0)
                                            rotation: fromEulerAngles(rotX, 0, 0);
                                        }
                                        Mesh {
                                            id: mesh_j2
                                            source: modelPath + "j2.obj"
                                        }

                                        Entity {
                                            id: j3
                                            components: [ mesh_j3, alpha, transform_j3]
                                            Transform {
                                                id: transform_j3
                                                property real rotZ: 0.0
                                                matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                     0, 1, 0, 0,
                                                                     0, 0, 1, 0.28,
                                                                     0, 0, 0, 1.0)
                                                rotation: fromEulerAngles(0, 0, rotZ);
                                            }
                                            Mesh {
                                                id: mesh_j3
                                                source: modelPath + "j3.obj"
                                            }

                                            Entity {
                                                id: j4
                                                components: [ mesh_j4, alpha, transform_j4]
                                                Transform {
                                                    id: transform_j4
                                                    property real rotX: 0.0
                                                    matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                         0, 1, 0, 0,
                                                                         0, 0, 1, 0.17,
                                                                         0, 0, 0, 1.0)
                                                    rotation: fromEulerAngles(rotX, 0, 0);
                                                }
                                                Mesh {
                                                    id: mesh_j4
                                                    source: modelPath + "j4.obj"
                                                }

                                                Entity {
                                                    id: j5
                                                    components: [ mesh_j5, alpha, transform_j5]
                                                    Transform {
                                                        id: transform_j5
                                                        property real rotZ: 0.0
                                                        matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                             0, 1, 0, 0,
                                                                             0, 0, 1, 0.25,
                                                                             0, 0, 0, 1.0)
                                                        rotation: fromEulerAngles(0, 0, rotZ);
                                                    }
                                                    Mesh {
                                                        id: mesh_j5
                                                        source: modelPath + "j5.obj"
                                                    }

                                                    Entity {
                                                        id: j6
                                                        components: [ mesh_j6, alpha, transform_j6]
                                                        Transform {
                                                            id: transform_j6
                                                            property real rotX: 0.0
                                                            matrix: Qt.matrix4x4(1, 0, 0, -0.0025,
                                                                                 0, 1, 0, 0,
                                                                                 0, 0, 1, 0.25,
                                                                                 0, 0, 0, 1.0)
                                                            rotation: fromEulerAngles(rotX, 0, 0);
                                                        }
                                                        Mesh {
                                                            id: mesh_j6
                                                            source: modelPath + "j6.obj"
                                                        }

                                                        Entity {
                                                            id: j7
                                                            components: [ mesh_j7, alpha, transform_j7]
                                                            Transform {
                                                                id: transform_j7
                                                                property real rotZ: 0.0
                                                                matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                                     0, 1, 0, 0,
                                                                                     0, 0, 1, 0.08,
                                                                                     0, 0, 0, 1.0)
                                                                rotation: fromEulerAngles(0, 0, rotZ);
                                                            }
                                                            Mesh {
                                                                id: mesh_j7
                                                                source: modelPath + "hand.obj"
                                                            }

                                                            Entity {
                                                                id: hand_l
                                                                components: [ mesh_hand_l, alpha, transform_hand_l]
                                                                Transform {
                                                                    id: transform_hand_l
                                                                    property real slideY: 0.0
                                                                    matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                                         0, 1, 0, slideY,
                                                                                         0, 0, 1, 0,
                                                                                         0, 0, 0, 1.0)
                                                                }
                                                                Mesh {
                                                                    id: mesh_hand_l
                                                                    source: modelPath + "hand_l.obj"
                                                                }

                                                            } // End of hand_l Entity

                                                            Entity {
                                                                id: hand_r
                                                                components: [ mesh_hand_r, alpha, transform_hand_r]
                                                                Transform {
                                                                    id: transform_hand_r
                                                                    property real slideY: 0.0
                                                                    matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                                         0, 1, 0, slideY,
                                                                                         0, 0, 1, 0,
                                                                                         0, 0, 0, 1.0)
                                                                }
                                                                Mesh {
                                                                    id: mesh_hand_r
                                                                    source: modelPath + "hand_r.obj"
                                                                }

                                                            } // End of hand_r Entiety

                                                        } // End of j7 Entity

                                                    } // End of j6 Entity

                                                } // End of j5 Entity

                                            } // End of j4 Entity

                                        } // End of j3 Entity

                                    } // End of j2 Entity


                                } // End of j1 Entity

                            } // End of base Entity

                        } // End of Entitiy of Transform for moving whole body Animation
                    } // End of mainRoot
                } // End of Scene3D

            } // End of Pane(scene3dPanel)


            // 関節角表示パネル
            Pane{
                id: anglePane
                padding: 5
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: 200
                Layout.minimumWidth: 250
                Layout.maximumWidth: 250
                background: Rectangle {
                    color: panelColor
                }

                GridLayout {
                    rows: 9
                    columns: 2
                    anchors.fill: parent
                    rowSpacing: 2
                    columnSpacing: 2

                    /* spacing: 40 */

                    Rectangle {
                        id: jointAnglesLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 0
                        Layout.rowSpan: 1
                        Layout.columnSpan: 2
                        /* color: panelColor */
                        color: panelColor
                        Text {
                            font.pixelSize: jointTopLabelFontPixelSize
                            text: "Joint Angles [deg]"
                        }
                    }

                    Rectangle {
                        id: j1Label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.rowSpan: 1
                        Layout.columnSpan:1
                        color: panelColor
                        border.color: "black"
                        Text {
                            font.pixelSize: jointFontPixelSize;
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "J1";
                        }
                    }
                    Rectangle {
                        id: j1ValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 1
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_j1.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: j2Label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 2
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "J2"
                        }
                    }
                    Rectangle {
                        id: j2ValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 2
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_j2.rotX).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: j3Label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 3
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "J3"
                            }
                    }
                    Rectangle {
                        id: j3ValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 3
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_j3.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: j4Label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 4
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "J4"
                        }
                    }
                    Rectangle {
                        id: j4ValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 4
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_j4.rotX).toFixed(preciseDigit))
                        }
                    } // End of Row(j4Row)
                    Rectangle {
                        id: j5Label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 5
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "J5"
                        }
                    }
                    Rectangle {
                        id: j5ValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 5
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_j5.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: j6Label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 6
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "J6"
                        }
                    }
                    Rectangle {
                        id: j6ValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 6
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_j6.rotX).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: j7Label
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 7
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "J7(HAND)"
                        }
                    }
                    Rectangle {
                        id: j7ValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 7
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_j7.rotZ).toFixed(preciseDigit))
                        }
                    }

                    Rectangle {
                        id: hand_lLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 8
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "HAND_L"
                        }
                    }
                    Rectangle {
                        id: hand_lValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 8
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_hand_l.slideY).toFixed(preciseDigit))
                        }
                    }

                    Rectangle {
                        id: hand_rLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 9
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "HAND_R"
                        }
                    }
                    Rectangle {
                        id: hand_rValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 9
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_hand_r.slideY).toFixed(preciseDigit))
                        }
                    }

                } // End of GridLayout
            }

        } // End of RowLayout(mainRowLO)

    } // End of Pane(mainPanel)

} // End of ApplicationWindow
