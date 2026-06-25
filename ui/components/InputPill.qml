import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property alias text: messageInput.text
    property alias placeholderText: messageInput.placeholderText
    property string modelLabel: "Mock"
    property var theme
    property var providerSettings

    signal sendRequested()
    signal attachRequested()
    signal voiceRequested()
    signal modelSelectorClicked()
    signal modelSelected(string providerId, string modelName)

    function forceInputFocus() {
        messageInput.forceActiveFocus();
    }

    function refreshModelList() {
        modelList.clear()
        if (!providerSettings) return
        var providers = providerSettings.providers()
        for (var i = 0; i < providers.length; i++) {
            var provider = providers[i]
            var models = providerSettings.modelsForProvider(provider.id)
            for (var j = 0; j < models.length; j++) {
                var isActive = providerSettings.activeProviderId === provider.id && providerSettings.activeModel === models[j]
                modelList.append({
                    providerId: provider.id,
                    providerName: provider.name,
                    modelName: models[j],
                    isActive: isActive
                })
            }
        }
    }

    ListModel {
        id: modelList
    }

    implicitWidth: 720
    implicitHeight: inputShell.height + 8
    height: implicitHeight

    MouseArea {
        anchors.fill: parent
        z: 0
        onClicked: {
            if (modelPopup.visible) {
                modelPopup.close()
            }
        }
    }

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
        height: Math.min(168, Math.max(56, messageInput.contentHeight + 28))
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
                id: modelChip
                Layout.preferredHeight: 32
                Layout.preferredWidth: modelRow.implicitWidth + 20
                radius: 16
                color: theme.chip
                border.color: modelPopup.visible ? theme.accent : "transparent"
                border.width: modelPopup.visible ? 1 : 0

                Row {
                    id: modelRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: root.modelLabel
                        color: theme.textSecondary
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelPopup.visible ? "▴" : "▾"
                        color: theme.textMuted
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelPopup.visible) {
                            modelPopup.close()
                        } else {
                            refreshModelList()
                            var popupHeight = 200
                            var globalPos = inputShell.mapToGlobal(Qt.point(0, 0))
                            var inputBottomGlobal = globalPos.y + inputShell.height
                            modelPopup.x = inputShell.width - 220 - 8
                            if (inputBottomGlobal + popupHeight > Screen.height) {
                                modelPopup.y = inputShell.y - popupHeight
                            } else {
                                modelPopup.y = inputShell.height + 4
                            }
                            modelPopup.open()
                        }
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

    Popup {
        id: modelPopup
        width: 220
        height: 220
        modal: false
        focus: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnOutsideClick

        background: Rectangle {
            color: theme ? theme.sidebar : "#ffffff"
            radius: 10
            border.color: theme ? theme.inputBorder : "#e0e0e0"
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0

            Text {
                text: qsTr("选择模型")
                color: theme ? theme.textPrimary : "#333333"
                font.pixelSize: 13
                font.weight: Font.Medium
                Layout.leftMargin: 12
                Layout.topMargin: 12
                Layout.bottomMargin: 4
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 130
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }

                ListView {
                    id: modelListView
                    width: parent.width
                    model: modelList
                    spacing: 2

                    delegate: Rectangle {
                        id: itemRect
                        width: modelListView.width
                        height: 32
                        radius: 5
                        color: model.isActive && theme ? theme.accentLight : (mouseArea.containsMouse && theme ? theme.sidebarHover : "transparent")

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.modelSelected(model.providerId, model.modelName)
                                modelPopup.close()
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Text {
                                    text: model.modelName
                                    color: model.isActive && theme ? theme.accent : (mouseArea.containsMouse && theme ? theme.textPrimary : (theme ? theme.textSecondary : "#666666"))
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: model.isActive && theme ? theme.accent : "transparent"
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                height: 1
                color: theme ? theme.inputBorder : "#e0e0e0"
                Layout.fillWidth: true
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

            Rectangle {
                id: manageRect
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: 5
                color: mouseArea2.containsMouse && theme ? theme.sidebarHover : "transparent"

                MouseArea {
                    id: mouseArea2
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.modelSelectorClicked()
                        modelPopup.close()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        Text {
                            text: qsTr("管理模型")
                            color: mouseArea2.containsMouse && theme ? theme.textPrimary : (theme ? theme.textSecondary : "#666666")
                            font.pixelSize: 13
                        }

                        Text {
                            text: "⚙"
                            color: theme ? theme.textMuted : "#999999"
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }
    }
}
