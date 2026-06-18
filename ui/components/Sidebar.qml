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
        anchors.leftMargin: 16 // 保持左侧基准线绝对不动
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
                visible: !isCollapsed
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
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                onClicked: root.isCollapsed = !root.isCollapsed

                background: Rectangle {
                    radius: 6
                    color: collapseButton.down ? theme.sidebarActive : (collapseButton.hovered ? theme.sidebarHover : "transparent")
                }

                contentItem: Text {
                    text: "☰"
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
            width: isCollapsed ? 32 : parent.width
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
                anchors.left: parent.left
                anchors.leftMargin: isCollapsed ? 4 : 12
                anchors.verticalCenter: parent.verticalCenter

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
            width: isCollapsed ? 32 : parent.width
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
        }
    }

    ListView {
        id: historyList
        anchors.top: headerColumn.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: isCollapsed ? 20 : 16
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

            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { color: "#3a3a3a"; radius: 2 }
            Behavior on opacity { NumberAnimation { duration: 200 } }
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

    // =========================================================================
    // 底部区域：使用纯坐标系控制，彻底消除动画期间任何组件对齐的抖动与错位
    // =========================================================================
    Item {
        id: footerArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 16 // 基准线：永恒固定靠左 16px
        anchors.rightMargin: 16
        anchors.bottomMargin: 16
        height: 76 // 保持固定高度，给齿轮留足折叠时的上移空间

        // 1. 固定绝对坐标的用户区 —— 无论怎么折叠，物理位置百分之百完全静止不动
        MouseArea {
            id: profileMouse
            x: 0
            y: 44 // 永远呆在 footerArea 的最底部 (76 - 32)
            width: isCollapsed ? 32 : 160
            height: 32
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: (!isCollapsed && profileMouse.containsMouse) ? theme.sidebarHover : "transparent"
            }

            // 头像圆圈
            Rectangle {
                id: avatarCircle
                x: 0
                y: 0
                width: 32
                height: 32
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

            // 用户名：展开时渐显，折叠时静默隐藏
            Text {
                anchors.left: avatarCircle.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("用户")
                color: theme.textPrimary
                font.pixelSize: 14
                visible: !isCollapsed
            }
        }

        // 2. 设置齿轮 —— 彻底摒弃动态 anchors，直接通过数学公式算 x 和 y，跟随动画丝滑移动
        MouseArea {
            id: settingsIconMouse
            width: 32
            height: 32

            // 【核心修复】：
            // 展开时：x 移到最右侧（父级总宽减去自身宽度 32）；折叠时：x 归 0，完美与头像垂直对齐
            x: isCollapsed ? 0 : (parent.width - width)

            // 展开时：y 在最下面（44），与头像并列；折叠时：y 上移到顶端（0），在头像上方隔出 12px 间距
            y: isCollapsed ? 0 : 44

            // 齿轮横向和纵向移动的丝滑动画效果
            Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.InOutQuad } }
            Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.InOutQuad } }

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