import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property alias text: messageInput.text
    property alias placeholderText: messageInput.placeholderText
    property string modelLabel: "Mock"
    property var theme

    signal sendRequested()
    signal attachRequested()
    signal voiceRequested()

    function forceInputFocus() {
        messageInput.forceActiveFocus();
    }

    implicitWidth: 720
    implicitHeight: inputShell.height + 8

    Rectangle {
        id: shadow
        anchors.fill: inputShell
        anchors.topMargin: 3
        color: "#000000"
        opacity: 0.35
        radius: inputShell.radius
        visible: inputShell.visible
    }

    Rectangle {
        id: inputShell
        width: parent.width
        height: Math.max(56, messageInput.contentHeight + 28)
        radius: height / 2
        color: theme.inputSurface
        border.color: messageInput.activeFocus ? theme.accent : theme.inputBorder
        border.width: messageInput.activeFocus ? 1 : 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 4

            ToolButton {
                id: attachButton
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                text: "+"
                font.pixelSize: 22
                onClicked: root.attachRequested()

                background: Rectangle {
                    radius: width / 2
                    color: attachButton.down ? theme.sidebarHover
                                             : (attachButton.hovered ? theme.sidebarActive : "transparent")
                }

                contentItem: Text {
                    text: parent.text
                    color: theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font: parent.font
                }
            }

            TextArea {
                id: messageInput
                Layout.fillWidth: true
                Layout.maximumHeight: 160
                placeholderText: qsTr("问问 vAssist")
                color: theme.textPrimary
                placeholderTextColor: theme.textMuted
                selectionColor: theme.accent
                selectedTextColor: "#ffffff"
                wrapMode: TextArea.Wrap
                padding: 8
                background: null
                font.pixelSize: 15

                Keys.onReturnPressed: function(event) {
                    if (!(event.modifiers & Qt.ShiftModifier)) {
                        event.accepted = true;
                        root.sendRequested();
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: modelRow.implicitWidth + 20
                radius: 16
                color: theme.chip

                Row {
                    id: modelRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: root.modelLabel
                        color: theme.textSecondary
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "▾"
                        color: theme.textMuted
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            ToolButton {
                id: voiceButton
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                text: "🎙"
                onClicked: root.voiceRequested()

                background: Rectangle {
                    radius: width / 2
                    color: voiceButton.down ? theme.sidebarHover
                                            : (voiceButton.hovered ? theme.sidebarActive : "transparent")
                }

                contentItem: Text {
                    text: voiceButton.text
                    color: theme.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 15
                }
            }

            ToolButton {
                id: sendButton
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                text: "➤"
                enabled: messageInput.text.trim().length > 0
                opacity: enabled ? 1.0 : 0.35
                onClicked: root.sendRequested()

                background: Rectangle {
                    radius: width / 2
                    color: sendButton.enabled && (sendButton.down || sendButton.hovered)
                          ? Qt.rgba(66 / 255, 133 / 255, 244 / 255, 0.18)
                          : "transparent"
                }

                contentItem: Text {
                    text: sendButton.text
                    color: theme.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 16
                }
            }
        }
    }
}
