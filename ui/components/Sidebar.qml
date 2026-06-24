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
    property bool showBrandTitle: true
    readonly property int railMargin: 16
    readonly property int iconSize: 32

    signal conversationSelected(int index)
    signal conversationDeleted(int index)
    signal conversationRenamed(int index, string newName)
    signal conversationPinned(int index, bool pinned)
    signal conversationShared(int index)
    signal newConversationRequested()
    signal settingsMenuToggled()
    signal collapseToggled()

    width: parent ? parent.width : (isCollapsed ? 64 : 260)
    clip: true

    onIsCollapsedChanged: {
        if (isCollapsed) {
            titleRevealTimer.stop();
            showBrandTitle = false;
        } else {
            titleRevealTimer.restart();
        }
    }

    Timer {
        id: titleRevealTimer
        interval: 210
        repeat: false
        onTriggered: root.showBrandTitle = true
    }

    ListModel {
        id: mockHistoryModel
        ListElement { title: "框架通路测试"; pinned: false }
        ListElement { title: "Qt Agent 架构研究"; pinned: false }
        ListElement { title: "MockProvider 下载指令"; pinned: false }
        ListElement { title: "QML 组件设计模式"; pinned: false }
        ListElement { title: "LLMProvider 接口抽象"; pinned: false }
        ListElement { title: "C++ 与 QML 通信机制"; pinned: false }
        ListElement { title: "异步数据流处理"; pinned: false }
        ListElement { title: "智能代理工具调用链"; pinned: false }
    }

    property var effectiveModel: chatHistoryModel !== undefined ? chatHistoryModel : mockHistoryModel

    Column {
        id: headerColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.leftMargin: root.railMargin
        anchors.rightMargin: isCollapsed ? 0 : 16
        spacing: 8

        Item {
            id: titleRow
            width: parent.width
            height: 32

            Item {
                id: titleCluster
                x: 0
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, collapseButton.x - 8)
                height: parent.height
                clip: true
                visible: root.showBrandTitle

                Text {
                    id: brandIcon
                    x: 0
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    text: "✦"
                    color: theme.accentSoft
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    id: titleText
                    anchors.left: brandIcon.right
                    anchors.leftMargin: 6
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: "vAssist"
                    color: theme.textPrimary
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            ToolButton {
                id: collapseButton
                x: root.isCollapsed ? (root.iconSize - width) / 2 : Math.max(0, parent.width - width)
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                onClicked: root.collapseToggled()

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.InOutCubic
                    }
                }

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
            width: isCollapsed ? root.iconSize : parent.width
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
                anchors.leftMargin: isCollapsed ? 0 : 12
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    width: root.iconSize
                    text: "＋"
                    color: theme.textSecondary
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
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
            width: isCollapsed ? root.iconSize : parent.width
            theme: root.theme
            iconText: "⌕"
            label: qsTr("搜索对话")
            collapsed: root.isCollapsed
            iconSize: root.iconSize
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

    ChatHistoryList {
        id: historyList
        anchors.top: headerColumn.bottom
        anchors.topMargin: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: isCollapsed ? 20 : 16
        anchors.rightMargin: isCollapsed ? 0 : 16
        anchors.bottom: footerArea.top
        anchors.bottomMargin: 8
        visible: !root.isCollapsed
        model: root.effectiveModel
        theme: root.theme
        currentIndex: root.currentIndex
        collapsed: root.isCollapsed
        onConversationSelected: function(index) { root.conversationSelected(index) }
        onConversationDeleted: function(index) { root.conversationDeleted(index) }
        onConversationRenamed: function(index, newName) { root.conversationRenamed(index, newName) }
        onConversationPinned: function(index, pinned) { root.conversationPinned(index, pinned) }
        onConversationShared: function(index) { root.conversationShared(index) }
    }

    // =========================================================================
    // 底部区域：使用纯坐标系控制，彻底消除动画期间任何组件对齐的抖动与错位
    // =========================================================================
    Item {
        id: footerArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.railMargin
        anchors.rightMargin: 16
        anchors.bottomMargin: 16
        height: 76 // 保持固定高度，给齿轮留足折叠时的上移空间

        readonly property real settingsExpandedX: 216
        readonly property real settingsCollapsedX: 0
        readonly property real settingsExpandedY: 44
        readonly property real settingsCollapsedY: 0

        // 1. 固定绝对坐标的用户区 —— 无论怎么折叠，物理位置百分之百完全静止不动
        MouseArea {
            id: profileMouse
            x: 0
            y: 44 // 永远呆在 footerArea 的最底部 (76 - 32)
            width: isCollapsed ? root.iconSize : 160
            height: root.iconSize
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
                width: root.iconSize
                height: root.iconSize
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
            width: root.iconSize
            height: root.iconSize

            x: isCollapsed ? footerArea.settingsCollapsedX : footerArea.settingsExpandedX
            y: isCollapsed ? footerArea.settingsCollapsedY : footerArea.settingsExpandedY

            Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.InOutCubic } }
            Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.InOutCubic } }

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
