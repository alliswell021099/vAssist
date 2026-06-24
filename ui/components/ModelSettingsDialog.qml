import QtQuick
import QtQuick.Window

Window {
    id: root
    width: 460
    height: 520
    minimumWidth: 400
    minimumHeight: 440
    title: qsTr("模型设置")
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.WindowModal
    color: "transparent"

    property var theme
    property bool isDarkTheme: false
    property string apiBase: "http://localhost:11434/v1"
    property string modelName: "qwen2.5:7b"
    property string apiKey: ""
    property string connectionStatus: ""
    property bool connectionOk: false

    property bool isDragging: false

    signal testConnectionRequested()
    signal applyAndSwitchRequested(string apiBase, string modelName, string apiKey)
    signal switchMockRequested()

    property int shadowPadding: 30

    Repeater {
        model: 8
        Rectangle {
            property int shadowLayer: index
            z: -shadowLayer
            anchors.centerIn: parent
            width: parent.width - shadowPadding * 2 + shadowLayer * 1.2
            height: parent.height - shadowPadding * 2 + shadowLayer * 1.2
            radius: 12 + shadowLayer * 0.8
            color: Qt.rgba(0, 0, 0, 0.004 + shadowLayer * 0.002)
            opacity: 1 - shadowLayer * 0.08
        }
    }

    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: parent.width - shadowPadding * 2
        height: parent.height - shadowPadding * 2
        color: root.isDarkTheme
               ? Qt.rgba(0.12, 0.12, 0.14, 0.85)
               : Qt.rgba(1.0, 1.0, 1.0, 0.85)
        border.color: root.theme.divider
        border.width: 0.5
        radius: 12
    }

    Rectangle {
        anchors.centerIn: contentRect
        width: contentRect.width
        height: contentRect.height
        radius: 12
        color: "transparent"
        border.color: root.isDarkTheme
                       ? Qt.rgba(1.0, 1.0, 1.0, 0.06)
                       : Qt.rgba(1.0, 1.0, 1.0, 0.5)
        border.width: 1
        z: 10
    }

    MouseArea {
        id: dragArea
        anchors.top: contentRect.top
        anchors.left: contentRect.left
        anchors.right: contentRect.right
        height: 56
        cursorShape: Qt.OpenHandCursor
        onPressed: {
            root.isDragging = true
            root.startSystemMove()
        }
        onReleased: {
            root.isDragging = false
        }
    }

    Column {
        anchors.fill: contentRect
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        spacing: 16

        Row {
            width: parent.width
            height: 28
            spacing: 12

            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: backMouse.pressed ? root.theme.sidebarActive
                       : (backMouse.containsMouse ? root.theme.sidebarHover
                          : "transparent")

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    color: root.theme.textPrimary
                    font.pixelSize: 16
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: root.close()
                }
            }

            Text {
                text: qsTr("模型设置")
                color: root.theme.textPrimary
                font.pixelSize: 16
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: root.theme.divider
        }

        Column {
            width: parent.width
            spacing: 14

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: qsTr("API 地址")
                    color: root.theme.textSecondary
                    font.pixelSize: 12
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: root.theme.inputSurface
                    border.color: root.theme.inputBorder
                    border.width: 1

                    TextInput {
                        id: apiBaseInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.apiBase
                        color: root.theme.textPrimary
                        font.pixelSize: 12
                        verticalAlignment: TextInput.AlignVCenter
                        selectionColor: root.theme.accent
                        selectedTextColor: "#ffffff"
                        onTextChanged: root.apiBase = text
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: qsTr("模型名称")
                    color: root.theme.textSecondary
                    font.pixelSize: 12
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: root.theme.inputSurface
                    border.color: root.theme.inputBorder
                    border.width: 1

                    TextInput {
                        id: modelNameInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.modelName
                        color: root.theme.textPrimary
                        font.pixelSize: 12
                        verticalAlignment: TextInput.AlignVCenter
                        selectionColor: root.theme.accent
                        selectedTextColor: "#ffffff"
                        onTextChanged: root.modelName = text
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: qsTr("API Key (可选)")
                    color: root.theme.textSecondary
                    font.pixelSize: 12
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: root.theme.inputSurface
                    border.color: root.theme.inputBorder
                    border.width: 1

                    TextInput {
                        id: apiKeyInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.apiKey
                        color: root.theme.textPrimary
                        font.pixelSize: 12
                        echoMode: TextInput.Password
                        verticalAlignment: TextInput.AlignVCenter
                        selectionColor: root.theme.accent
                        selectedTextColor: "#ffffff"
                        onTextChanged: root.apiKey = text
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    id: testBtn
                    width: (parent.width - 10) / 2
                    height: 32
                    radius: 6
                    color: testBtnMouse.pressed ? root.theme.sidebarActive : root.theme.sidebarHover

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("测试连接")
                        color: root.theme.textPrimary
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: testBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.testConnectionRequested()
                    }
                }

                Rectangle {
                    id: applyBtn
                    width: (parent.width - 10) / 2
                    height: 32
                    radius: 6
                    color: applyBtnMouse.pressed ? root.theme.accentSoft : root.theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("应用并使用")
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: applyBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.applyAndSwitchRequested(
                                root.apiBase,
                                root.modelName,
                                root.apiKey
                            )
                            root.close()
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 6

                Text {
                    text: root.connectionOk ? "●" : "○"
                    color: root.connectionOk ? "#34a853" : root.theme.textMuted
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.connectionStatus.length > 0
                          ? root.connectionStatus
                          : qsTr("未测试连接")
                    color: root.connectionOk ? "#34a853" : root.theme.textMuted
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    width: parent.width - 16
                }
            }
        }

        Item {
            width: parent.width
            height: 1
        }

        Rectangle {
            width: parent.width
            height: 1
            color: root.theme.divider
        }

        Row {
            width: parent.width
            spacing: 4

            Text {
                text: qsTr("仅用于测试：")
                color: root.theme.textSecondary
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: qsTr("切换到 Mock 模式")
                color: root.theme.accent
                font.pixelSize: 12
                font.underline: true
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.switchMockRequested()
                        root.close()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        var screen = root.screen
        if (screen) {
            root.x = screen.virtualX + (screen.width - root.width) / 2
            root.y = screen.virtualY + (screen.height - root.height) / 2
        }
    }
}
