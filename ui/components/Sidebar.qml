import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "."

Item {
    id: root

    required property var theme
    property var chatHistoryModel
    property int currentIndex: -1
    property bool isCollapsed: false
    property bool showSettingsMenu: false

    signal conversationSelected(int index)
    signal conversationDeleted(int index)
    signal newConversationRequested()
    signal settingsMenuToggled()

    width: isCollapsed ? 64 : 260
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    ListModel {
        id: mockHistoryModel
        ListElement { title: "框架通路测试" }
        ListElement { title: "Qt Agent 架构研究" }
        ListElement { title: "MockProvider 下载指令" }
        ListElement { title: "QML 组件设计模式" }
        ListElement { title: "LLMProvider 接口抽象" }
        ListElement { title: "C++ 与 QML 通信机制" }
        ListElement { title: "异步数据流处理" }
        ListElement { title: "智能代理工具调用链" }
    }

    property var effectiveModel: chatHistoryModel !== undefined ? chatHistoryModel : mockHistoryModel

    Column {
        id: headerColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.leftMargin: isCollapsed ? 0 : 16
        anchors.rightMargin: isCollapsed ? 0 : 16
        spacing: 8

        RowLayout {
            width: parent.width
            spacing: 5

            Text {
                text: "✦"
                color: theme.accentSoft
                font.pixelSize: 22
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Text {
                id: titleText
                text: "vAssist"
                color: theme.textPrimary
                font.pixelSize: 20
                font.weight: Font.DemiBold
                visible: !isCollapsed
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            ToolButton {
                id: collapseButton
                width: 28
                height: 28
                onClicked: root.isCollapsed = !root.isCollapsed
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                background: Rectangle {
                    radius: 6
                    color: collapseButton.down ? theme.sidebarActive
                                               : (collapseButton.hovered ? theme.sidebarHover : "transparent")
                }

                contentItem: Text {
                    text: root.isCollapsed ? "›" : "‹"
                    color: theme.textSecondary
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Item { width: 1; height: isCollapsed ? 4 : 8 }

        Button {
            id: newChatButton
            width: isCollapsed ? 40 : parent.width
            height: isCollapsed ? 40 : 44
            text: qsTr("发起新对话")
            onClicked: root.newConversationRequested()
            flat: true

            background: Rectangle {
                radius: height / 2
                color: newChatButton.down ? theme.sidebarActive
                                          : (newChatButton.checked ? theme.sidebarActive : (newChatButton.hovered ? theme.sidebarHover : theme.pillButton))
                border.color: newChatButton.checked ? theme.accentSoft : "transparent"
                border.width: newChatButton.checked ? 2 : 0
            }

            contentItem: Row {
                spacing: isCollapsed ? 0 : 10
                anchors.centerIn: parent

                Text {
                    text: "+"
                    color: theme.textSecondary
                    font.pixelSize: isCollapsed ? 20 : 18
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: newChatButton.text
                    color: theme.textPrimary
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !isCollapsed
                }
            }
        }

        Item { width: 1; height: isCollapsed ? 4 : 8 }

        SidebarItem {
            width: isCollapsed ? 40 : parent.width
            theme: root.theme
            iconText: "⌕"
            label: qsTr("搜索对话")
            collapsed: root.isCollapsed
        }

        Text {
            width: parent.width
            topPadding: 12
            leftPadding: isCollapsed ? 0 : 14
            text: qsTr("最近")
            color: theme.textMuted
            font.pixelSize: 12
            font.weight: Font.Medium
            visible: !isCollapsed
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    ListView {
        id: historyList
        anchors.top: headerColumn.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: isCollapsed ? 0 : 16
        anchors.rightMargin: isCollapsed ? 0 : 16
        anchors.bottom: footerArea.top
        anchors.bottomMargin: 8
        clip: true
        spacing: 2
        model: root.effectiveModel

        property bool isHovered: false

        ScrollBar.vertical: ScrollBar {
            id: historyScrollBar
            policy: ScrollBar.AsNeeded
            width: 4
            opacity: (historyList.isHovered || historyScrollBar.pressed) ? 1.0 : 0.0
            visible: !root.isCollapsed

            background: Rectangle {
                color: "transparent"
            }

            contentItem: Rectangle {
                color: "#3a3a3a"
                radius: 2
            }

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: historyList.isHovered = true
            onExited: historyList.isHovered = false
        }

        delegate: ChatHistoryItem {
            width: historyList.width
            theme: root.theme
            title: model.title
            selected: index === root.currentIndex
            collapsed: root.isCollapsed
            onClicked: root.conversationSelected(index)
            onDeleteRequested: root.conversationDeleted(index)
        }
    }

    Rectangle {
        id: footerArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: isCollapsed ? 8 : 16
        height: isCollapsed ? 40 : 52
        radius: height / 2
        color: profileMouse.containsMouse ? theme.sidebarHover : "transparent"

        Row {
            anchors.fill: parent
            anchors.leftMargin: isCollapsed ? 0 : 8
            anchors.rightMargin: isCollapsed ? 0 : 12
            spacing: isCollapsed ? 0 : 10
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea {
                id: profileMouse
                width: isCollapsed ? 32 : parent.width - 32 - 10
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                Row {
                    anchors.fill: parent
                    spacing: isCollapsed ? 0 : 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: isCollapsed ? 32 : 32
                        height: isCollapsed ? 32 : 32
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 16
                        color: theme.accent

                        Text {
                            anchors.centerIn: parent
                            text: "J"
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                        }
                    }

                    Text {
                        width: parent.width - 32 - 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("用户")
                        color: theme.textPrimary
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        visible: !isCollapsed
                    }
                }
            }

            MouseArea {
                id: settingsIconMouse
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
                visible: !isCollapsed

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: settingsIconMouse.containsMouse ? theme.sidebarHover : "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: "⚙"
                    color: theme.textMuted
                    font.pixelSize: 16
                }

                onClicked: {
                    root.settingsMenuToggled()
                }
            }
        }
    }
}