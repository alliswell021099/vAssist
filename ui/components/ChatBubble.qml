import QtQuick
import QtQuick.Controls

Column {
    id: root

    required property string sender
    required property string text
    required property int bubbleWidth
    required property var theme

    spacing: 8
    width: bubbleWidth

    readonly property bool isUser: sender === "user"
    readonly property bool isAssistant: sender === "assistant"
    readonly property bool isTool: sender === "tool"
    readonly property int maxBubbleWidth: isUser ? Math.min(root.width * 0.72, 680)
                                                 : Math.min(root.width * 0.92, 780)
    readonly property int bubbleHorizontalPadding: 32
    readonly property int minBubbleWidth: isUser ? 44 : 64
    readonly property int naturalBubbleWidth: Math.ceil(measureText.implicitWidth) + bubbleHorizontalPadding
    readonly property int actualBubbleWidth: Math.min(maxBubbleWidth,
                                                       Math.max(minBubbleWidth, naturalBubbleWidth))

    Text {
        id: measureText
        visible: false
        text: root.text
        font.pixelSize: 15
        textFormat: Text.PlainText
        wrapMode: Text.NoWrap
    }

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
        height: bubbleContent.height

        Rectangle {
            id: bubbleContent
            width: root.actualBubbleWidth
            anchors.right: root.isUser ? parent.right : undefined
            anchors.left: root.isUser ? undefined : parent.left
            height: messageText.contentHeight + 28
            radius: root.isUser ? 20 : 16
            color: root.isUser ? theme.bubbleUser
                               : (root.isTool ? theme.chip : theme.bubbleAssistant)
            border.color: root.isUser ? "transparent" : theme.divider
            border.width: root.isUser ? 0 : 1

            TextEdit {
                id: messageText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 14
                text: root.text
                color: theme.textPrimary
                font.pixelSize: 15
                wrapMode: TextEdit.Wrap
                horizontalAlignment: Text.AlignLeft
                readOnly: true
                selectByMouse: true
                activeFocusOnPress: true
                persistentSelection: true
                textFormat: TextEdit.PlainText
                selectionColor: theme.accent
                selectedTextColor: "#ffffff"

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: {
                        messageText.forceActiveFocus();
                        textMenu.popup();
                    }
                }
            }

            Menu {
                id: textMenu

                MenuItem {
                    text: messageText.selectedText.length > 0 ? qsTr("复制") : qsTr("复制全文")
                    onTriggered: {
                        if (messageText.selectedText.length === 0) {
                            messageText.selectAll();
                        }
                        messageText.copy();
                    }
                }

                MenuItem {
                    text: qsTr("全选")
                    onTriggered: {
                        messageText.forceActiveFocus();
                        messageText.selectAll();
                    }
                }
            }
        }
    }
}
