import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    required property var model
    property int currentIndex: -1
    property bool collapsed: false

    signal conversationSelected(int index)
    signal conversationDeleted(int index)
    signal conversationRenamed(int index, string newName)
    signal conversationPinned(int index, bool pinned)
    signal conversationShared(int index)

    ListView {
        id: historyList
        anchors.fill: parent
        anchors.leftMargin: root.collapsed ? 20 : 0
        anchors.rightMargin: root.collapsed ? 0 : 0
        clip: true
        spacing: 2
        model: root.model

        property bool isHovered: false

        ScrollBar.vertical: ScrollBar {
            id: historyScrollBar
            policy: ScrollBar.AlwaysOff
            width: 4
            opacity: 0
            visible: false

            background: Rectangle { color: "transparent" }
            contentItem: Rectangle { color: "#3a3a3a"; radius: 2 }
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: historyList.isHovered = true
            onExited: historyList.isHovered = false
        }

        delegate: Item {
            id: delegateRoot

            required property int index
            required property string title
            required property bool pinned

            width: historyList.width
            height: historyItem.height

            ChatHistoryItemEx {
                id: historyItem
                width: parent.width
                theme: root.theme
                title: delegateRoot.title
                selected: delegateRoot.index === root.currentIndex
                collapsed: root.collapsed
                pinned: delegateRoot.pinned
                onClicked: root.conversationSelected(delegateRoot.index)
                onDeleteRequested: root.conversationDeleted(delegateRoot.index)
                onRenamed: function(newName) { root.conversationRenamed(delegateRoot.index, newName) }
                onPinChanged: function(pinned) { root.conversationPinned(delegateRoot.index, pinned) }
                onShared: root.conversationShared(delegateRoot.index)
            }
        }
    }
}
