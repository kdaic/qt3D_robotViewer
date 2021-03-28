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
    property string modelPath : "../models/nx01_obj/"
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
        transform_cy.rotZ  = angles[0]
        transform_ny.rotZ = angles[1]
        transform_np.rotY = angles[2]
        transform_rsy_joint.rotZ = angles[3]
        transform_rsp.rotY = angles[4]
        transform_rep.rotY = angles[5]
        transform_rwy.rotZ = angles[6]
        transform_rwp.rotY = angles[7]
        transform_rwr.rotX = angles[8]
        transform_lsy_joint.rotZ = angles[9]
        transform_lsp.rotY = angles[10]
        transform_lep.rotY = angles[11]
        transform_lwy.rotZ = angles[12]
        transform_lwp.rotY = angles[13]
        transform_lwr.rotX = angles[14]
        is_servo_unlock    = isServoUnLock
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
                            /* position: Qt.vector3d( -4.0, 3.0, 0 ) */
                            position: Qt.vector3d( -2.0, 1.5, .0 )
                            upVector: Qt.vector3d( 0.0, 1.0, 0.0 )
                            viewCenter: Qt.vector3d( 0.0, 0.3, 0.0 )
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
                        // components: Transform { matrix: Qt.matrix4x4(-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0)}
                        Entity {
                            components: Transform {
                                id: transform
                                property real rotateX: -90
                                property real rotateY: 0.0
                                property real rotateZ: 180
                                rotation: fromEulerAngles(rotateX, rotateY, rotateZ);
                            }

                            Entity {
                                id: base
                                /* components: [ mesh, alpha, material] */
                                components: [mesh_base, alpha, transform_base]
                                Transform {
                                    id: transform_base
                                    property real rotZ: 0.0

                                    matrix: Qt.matrix4x4(1.0, 0.0, 0.0, 0.0,
                                                         0.0, 1.0, 0.0, 0.0,
                                                         0.0, 0.0, 1.0, 0.0,
                                                         0.0, 0.0, 0.0, 1.0)
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
                                    source: modelPath + "BASE.obj"
                                }

                                Entity {
                                    id: chest_joint
                                    components: [ mesh_chest, alpha, transform_cy]
                                    Transform {
                                        id: transform_cy
                                        property real rotZ: 0.0
                                        matrix: Qt.matrix4x4(1.0, 0.0, 0.0, 0.0,
                                                             0.0, 1.0, 0.0, 0.0,
                                                             0.0, 0.0, 1.0, 0.0,
                                                             0.0, 0.0, 0.0, 1.0)
                                        rotation: fromEulerAngles(0, 0, -rotZ);
                                    }
                                    Mesh {
                                        id: mesh_chest
                                        source: modelPath + "CY.obj"
                                    }


                                    Entity {
                                        id: ny
                                        components: [ mesh_ny, alpha, transform_ny]
                                        Transform {
                                            id: transform_ny
                                            property real rotZ: 0.0
                                            matrix: Qt.matrix4x4(1.0, 0.0, 0.0, 0.0,
                                                                 0.0, 1.0, 0.0, 0.0,
                                                                 0.0, 0.0, 1.0, 0.5695,
                                                                 0.0, 0.0, 0.0, 1.0)
                                            rotation: fromEulerAngles(0, 0, -rotZ);
                                        }
                                        Mesh {
                                            id: mesh_ny
                                            source: modelPath + "NY.obj"
                                        }

                                        Entity {
                                            id: np
                                            components: [ mesh_np, alpha, transform_np]
                                            Transform {
                                                id: transform_np
                                                property real rotY: 0.0
                                                matrix: Qt.matrix4x4(1, 0, 0, 0.0,
                                                                     0, 1, 0, 0.0,
                                                                     0, 0, 1, 0.0,
                                                                     0, 0, 0, 1.0)
                                                rotation: fromEulerAngles(0, rotY, 0);
                                            }
                                            Mesh {
                                                id: mesh_np
                                                source: modelPath + "NP.obj"
                                            }
                                        } // End of np Entity

                                    } // End of ny Entity

                                    Entity {
                                        id: rsy
                                        components: [ mesh_rsy, alpha, transform_rsy ]
                                        Transform {
                                            id: transform_rsy
                                            matrix: Qt.matrix4x4(1.0, 0.0,               0.0,               0.0,
                                                                 0.0, 0.965925931930542, -0.258818656206131, -0.145,
                                                                 0.0, 0.258818656206131, 0.965925931930542, 0.370,
                                                                 0.0, 0.0, 0.0, 1.0)
                                        }
                                        Mesh {
                                            id: mesh_rsy
                                            source: modelPath + "RSY.obj"
                                        }
                                        Entity {
                                            id: rsy_joint
                                            components: [transform_rsy_joint]
                                            Transform {
                                                id: transform_rsy_joint
                                                property real rotZ: 0.0
                                                rotation: fromEulerAngles(0, 0, -rotZ);
                                            }


                                            Entity {
                                                id: rsp
                                                components: [ mesh_rsp, alpha, transform_rsp]
                                                Transform {
                                                    id: transform_rsp
                                                    property real rotY: 0.0
                                                    matrix: Qt.matrix4x4(1.0, 0.0, 0.0, 0.0,
                                                                         0.0, 1.0, 0.0, 0.0,
                                                                         0.0, 0.0, 1.0, 0.0,
                                                                         0.0, 0.0, 0.0, 1.0)
                                                    rotation: fromEulerAngles(0, rotY, 0);
                                                }
                                                Mesh {
                                                    id: mesh_rsp
                                                    source: modelPath + "RSP.obj"
                                                }

                                                Entity {
                                                    id: rep
                                                    components: [ mesh_rep, alpha, transform_rep]
                                                    Transform {
                                                        id: transform_rep
                                                        property real rotY: 0.0
                                                        matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                             0, 1, 0, -0.0949999988079071,
                                                                             0, 0, 1, -0.25000014901161194,
                                                                             0, 0, 0, 1.0)
                                                        rotation: fromEulerAngles(0, rotY, 0);
                                                    }
                                                    Mesh {
                                                        id: mesh_rep
                                                        source: modelPath + "REP.obj"
                                                    }

                                                    Entity {
                                                        id: rwy
                                                        components: [ mesh_rwy, alpha, transform_rwy]
                                                        Transform {
                                                            id: transform_rwy
                                                            property real rotZ: 0.0
                                                            matrix: Qt.matrix4x4(1, 0, 0, -0.03,
                                                                                 0, 1, 0, 0,
                                                                                 0, 0, 1, 0,
                                                                                 0, 0, 0, 1.0)
                                                            rotation: fromEulerAngles(0, 0, rotZ);
                                                        }
                                                        Mesh {
                                                            id: mesh_rwy
                                                            source: modelPath + "RWY.obj"
                                                        }

                                                        Entity {
                                                            id: rwp
                                                            components: [ mesh_rwp, alpha, transform_rwp]
                                                            Transform {
                                                                id: transform_rwp
                                                                property real rotY: 0.0
                                                                matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                                     0, 1, 0, 0,
                                                                                     0, 0, 1, -0.235,
                                                                                     0, 0, 0, 1.0)
                                                                rotation: fromEulerAngles(0, rotY, 0);
                                                            }
                                                            Mesh {
                                                                id: mesh_rwp
                                                                source: modelPath + "RWP.obj"
                                                            }

                                                            Entity {
                                                                id: rwr
                                                                components: [ mesh_rwr, alpha, transform_rwr]
                                                                Transform {
                                                                    id: transform_rwr
                                                                    property real rotX: 0.0
                                                                    matrix: Qt.matrix4x4(1, 0, 0, -0.047,
                                                                                         0, 1, 0, 0,
                                                                                         0, 0, 1, -0.09,
                                                                                         0, 0, 0, 1.0)
                                                                    rotation: fromEulerAngles(-rotX, 0, 0);
                                                                }
                                                                Mesh {
                                                                    id: mesh_rwr
                                                                    source: modelPath + "WR.obj"
                                                                }

                                                            } // End of rwr Entity

                                                        } // End of rwp Entity

                                                    } // End of rwy Entity

                                                } // End of rep Entity

                                            } // End of rsp Entit

                                        } // End of rsy_joint Entity

                                    } // End of rsy Entity

                                    Entity {
                                        id: lsy
                                        components: [ mesh_lsy, alpha, transform_lsy ]
                                        Transform {
                                            id: transform_lsy
                                            matrix: Qt.matrix4x4(1,  0.0, 0.0, 0.0,
                                                                 0,  0.965925931930542, 0.258818656206131, 0.145,
                                                                 0,  -0.258818656206131, 0.965925931930542, 0.370,
                                                                 0,  0,   0,   1.0)
                                        }
                                        Mesh {
                                            id: mesh_lsy
                                            source: modelPath + "LSY.obj"
                                        }

                                        Entity {
                                            id: lsy_joint
                                            components: [ transform_lsy_joint ]
                                            Transform {
                                                id: transform_lsy_joint
                                                property real rotZ: 0.0
                                                rotation: fromEulerAngles(0, 0, -rotZ);
                                            }

                                            Entity {
                                                id: lsp
                                                components: [ mesh_lsp, alpha, transform_lsp ]
                                                Transform {
                                                    id: transform_lsp
                                                    property real rotY: 0.0
                                                    matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                         0, 1, 0, 0,
                                                                         0, 0, 1, 0,
                                                                         0, 0, 0, 1.0)
                                                    rotation: fromEulerAngles(0, rotY, 0);
                                                }
                                                Mesh {
                                                    id: mesh_lsp
                                                    source: modelPath + "LSP.obj"
                                                }

                                                Entity {
                                                    id: lep
                                                    components: [ mesh_lep, alpha, transform_lep ]
                                                    Transform {
                                                        id: transform_lep
                                                        property real rotY: 0.0
                                                        matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                             0, 1, 0, 0.095,
                                                                             0, 0, 1, -0.25,
                                                                             0, 0, 0, 1.0)
                                                        rotation: fromEulerAngles(0, rotY, 0);
                                                    }
                                                    Mesh {
                                                        id: mesh_lep
                                                        source: modelPath + "LEP.obj"
                                                    }

                                                    Entity {
                                                        id: lwy
                                                        components: [ mesh_lwy, alpha, transform_lwy]
                                                        Transform {
                                                            id: transform_lwy
                                                            property real rotZ: 0.0
                                                            matrix: Qt.matrix4x4(1, 0, 0, -0.03,
                                                                                 0, 1, 0, 0,
                                                                                 0, 0, 1, 0,
                                                                                 0, 0, 0, 1.0)
                                                            rotation: fromEulerAngles(0, 0, rotZ);
                                                        }
                                                        Mesh {
                                                            id: mesh_lwy
                                                            source: modelPath + "LWY.obj"
                                                        }

                                                        Entity {
                                                            id: lwp
                                                            components: [ mesh_lwp, alpha, transform_lwp]
                                                            Transform {
                                                                id: transform_lwp
                                                                property real rotY: 0.0
                                                                matrix: Qt.matrix4x4(1, 0, 0, 0,
                                                                                     0, 1, 0, 0,
                                                                                     0, 0, 1, -0.235,
                                                                                     0, 0, 0, 1.0)
                                                                rotation: fromEulerAngles(0, rotY, 0);
                                                            }
                                                            Mesh {
                                                                id: mesh_lwp
                                                                source: modelPath + "LWP.obj"
                                                            }

                                                            Entity {
                                                                id: lwr
                                                                components: [ mesh_lwr, alpha, transform_lwr]
                                                                Transform {
                                                                    id: transform_lwr
                                                                    property real rotX: 0.0
                                                                    matrix: Qt.matrix4x4(1, 0, 0, -0.047,
                                                                                         0, 1, 0, 0,
                                                                                         0, 0, 1, -0.09,
                                                                                         0, 0, 0, 1.0)
                                                                    rotation: fromEulerAngles(0, 0, -rotX);
                                                                }
                                                                Mesh {
                                                                    id: mesh_lwr
                                                                    source: modelPath + "WR.obj"
                                                                }
                                                            } // End of wr Entity

                                                        } // End of lwp Entity

                                                    } // End of lwy Entity

                                                } // End of lep Entity

                                            } // End of lsp Entity

                                        } // End of lsy_joint Entity

                                    } // End of lsy Entity

                                } // End of cy Entity

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
                Layout.minimumWidth: 160
                Layout.maximumWidth: 160
                background: Rectangle {
                    color: panelColor
                }

                GridLayout {
                    rows: 16
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
                        id: cyLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.rowSpan:1
                        Layout.columnSpan:1
                        color: panelColor
                        border.color: "black"
                        Text {
                            font.pixelSize: jointFontPixelSize;
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "CY";
                        }
                    }
                    Rectangle {
                        id: cyValueLabel
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
                            text: " "+String((transform_cy.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: nyLabel
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
                            text: "NY"
                        }
                    }
                    Rectangle {
                        id: nyValueLabel
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
                            text: " "+String((transform_ny.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: npLabel
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
                            text: "NP"
                        }
                    }
                    Rectangle {
                        id: npValueLabel
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
                            text: " "+String((transform_np.rotY).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: rsyLabel
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
                            text: "RSY"
                        }
                    }
                    Rectangle {
                        id: rsyValueLabel
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
                            text: " "+String((transform_rsy_joint.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: rspLabel
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
                            text: "RSP"
                            }
                    }
                    Rectangle {
                        id: rspValueLabel
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
                            text: " "+String((transform_rsp.rotY).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: repLabel
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
                            text: "REP"
                        }
                    }
                    Rectangle {
                        id: repValueLabel
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
                            text: " "+String((transform_rep.rotY).toFixed(preciseDigit))
                        }
                    } // End of Row(repRow)
                    Rectangle {
                        id: rwyLabel
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
                            text: "RWY"
                        }
                    }
                    Rectangle {
                        id: rwyValueLabel
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
                            text: " "+String((transform_rwy.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: rwpLabel
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
                            text: "RWP"
                        }
                    }
                    Rectangle {
                        id: rwpValueLabel
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
                            text: " "+String((transform_rwp.rotY).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: rwrLabel
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
                            text: "RWR"
                        }
                    }
                    Rectangle {
                        id: rwrValueLabel
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
                            text: " "+String((transform_rwr.rotX).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: lsyLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 10
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "LSY"
                        }
                    }
                    Rectangle {
                        id: lsyValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 10
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_lsy_joint.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: lspLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 11
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "LSP"
                        }
                    }
                    Rectangle {
                        id: lspValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 11
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_lsp.rotY).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: lepLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 12
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "LEP"
                        }
                    }
                    Rectangle {
                        id: lepValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 12
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_lep.rotY).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: lwyLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 13
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "LWY"
                        }
                    }
                    Rectangle {
                        id: lwyValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 13
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_lwy.rotZ).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: lwpLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 14
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "LWP"
                        }
                    }
                    Rectangle {
                        id: lwpValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 14
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_lwp.rotY).toFixed(preciseDigit))
                        }
                    }
                    Rectangle {
                        id: lwrLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 15
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        Text{
                            font.pixelSize: jointFontPixelSize
                            /* anchors.verticalCenter: parent.verticalCenter */
                            anchors.centerIn: parent
                            text: "LWR"
                        }
                    }
                    Rectangle {
                        id: lwrValueLabel
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.row: 15
                        Layout.rowSpan: 1
                        Layout.column: 1
                        Layout.columnSpan: 1
                        color: panelColor
                        border.color: "black"
                        implicitWidth: jointLabelWidth
                        Text{
                            font.pixelSize: jointFontPixelSize
                            anchors.verticalCenter: parent.verticalCenter
                            text: " "+String((transform_lwr.rotX).toFixed(preciseDigit))
                        }
                    }

                } // End of GridLayout
            } // End of Pane(anglePane)

        } // End of RowLayout(mainRowLO)

    } // End of Pane(mainPanel)

} // End of ApplicationWindow
