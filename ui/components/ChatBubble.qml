import QtQuick

Column {
    id: root

    required property string sender
    required property string text
    required property int bubbleWidth
    required property var theme

    spacing: 8
    width: bubbleWidth

    readonly property bool isUser: sender === "user"

    Text {
        visible: !root.isUser
        text: sender === "assistant" ? qsTr("vAssist")
             : sender === "tool" ? qsTr("工具")
             : sender === "system" ? qsTr("系统")
             : sender
        color: theme.accentSoft
        font.pixelSize: 13
        font.weight: Font.Medium
    }

    Item {
        width: parent.width
        height: bubbleContent.implicitHeight

        Rectangle {
            id: bubbleContent
            width: Math.min(root.width, messageText.implicitWidth + 28)
            anchors.right: root.isUser ? parent.right : undefined
            anchors.left: root.isUser ? undefined : parent.left
            height: messageText.implicitHeight + 24
            radius: 18
            color: root.isUser ? theme.bubbleUser : theme.bubbleAssistant

            Text {
                id: messageText
                width: parent.width - 28
                anchors.centerIn: parent
                text: root.text
                color: theme.textPrimary
                font.pixelSize: 15
                lineHeight: 1.45
                wrapMode: Text.Wrap
            }
        }
    }
}
