import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components"

ApplicationWindow {
    id: root
    width: 1180
    height: 760
    visible: true
    title: qsTr("vAssist")
    color: theme.window

    readonly property QtObject theme: QtObject {
        readonly property color window: "#1e1e1e"
        readonly property color sidebar: "#171717"
        readonly property color sidebarHover: "#2a2a2a"
        readonly property color sidebarActive: "#333333"
        readonly property color mainGradientTop: "#1a2433"
        readonly property color mainGradientBottom: "#1e1e1e"
        readonly property color inputSurface: "#252526"
        readonly property color inputBorder: "#3c3c3c"
        readonly property color textPrimary: "#d4d4d4"
        readonly property color textSecondary: "#b0b0b0"
        readonly property color textMuted: "#7a7a7a"
        readonly property color accent: "#007acc"
        readonly property color accentSoft: "#4da3e0"
        readonly property color bubbleUser: "#2a2d2e"
        readonly property color bubbleAssistant: "#252526"
        readonly property color pillButton: "#2d2d2d"
    }

    readonly property bool hasConversation: chatModel.count > 0

    property int currentConversationIndex: -1
    property int conversationIdCounter: 0
    property var conversationStore: ({})

    ListModel {
        id: chatHistoryModel
    }

    ListModel {
        id: chatModel
    }

    function nextConversationId() {
        conversationIdCounter += 1;
        return "conv-" + conversationIdCounter;
    }

    function saveCurrentConversation() {
        if (currentConversationIndex < 0 || currentConversationIndex >= chatHistoryModel.count) {
            return;
        }

        const conversationId = chatHistoryModel.get(currentConversationIndex).conversationId;
        const messages = [];

        for (let i = 0; i < chatModel.count; ++i) {
            const item = chatModel.get(i);
            messages.push({ sender: item.sender, text: item.text });
        }

        conversationStore[conversationId] = messages;
    }

    function loadConversation(conversationId) {
        chatModel.clear();

        const messages = conversationStore[conversationId] || [];
        for (let i = 0; i < messages.length; ++i) {
            chatModel.append(messages[i]);
        }
    }

    function clearInputs() {
        inputBar.text = "";
        welcomeInput.text = "";
        Qt.callLater(function() {
            if (root.hasConversation) {
                inputBar.forceInputFocus();
            } else {
                welcomeInput.forceInputFocus();
            }
        });
    }

    function selectConversation(index) {
        if (index < 0 || index >= chatHistoryModel.count) {
            return;
        }

        saveCurrentConversation();
        currentConversationIndex = index;
        loadConversation(chatHistoryModel.get(index).conversationId);
        clearInputs();
    }

    function createNewConversation() {
        saveCurrentConversation();

        const conversationId = nextConversationId();
        chatHistoryModel.insert(0, {
            conversationId: conversationId,
            title: qsTr("新对话")
        });
        conversationStore[conversationId] = [];

        currentConversationIndex = 0;
        chatModel.clear();
        clearInputs();
    }

    function deleteConversation(index) {
        if (index < 0 || index >= chatHistoryModel.count) {
            return;
        }

        const conversationId = chatHistoryModel.get(index).conversationId;
        delete conversationStore[conversationId];
        chatHistoryModel.remove(index);

        if (currentConversationIndex === index) {
            if (chatHistoryModel.count === 0) {
                currentConversationIndex = -1;
                chatModel.clear();
            } else {
                const nextIndex = Math.min(index, chatHistoryModel.count - 1);
                selectConversation(nextIndex);
            }
        } else if (currentConversationIndex > index) {
            currentConversationIndex -= 1;
        }

        clearInputs();
    }

    function ensureActiveConversation(firstMessage) {
        if (currentConversationIndex >= 0) {
            updateConversationTitle(firstMessage);
            return;
        }

        const conversationId = nextConversationId();
        const title = firstMessage.length > 18
                      ? firstMessage.substring(0, 18) + "…"
                      : firstMessage;

        chatHistoryModel.insert(0, {
            conversationId: conversationId,
            title: title
        });
        conversationStore[conversationId] = [];
        currentConversationIndex = 0;
    }

    function updateConversationTitle(firstMessage) {
        if (currentConversationIndex < 0) {
            return;
        }

        const item = chatHistoryModel.get(currentConversationIndex);
        if (item.title === qsTr("新对话") && firstMessage.length > 0) {
            const title = firstMessage.length > 18
                          ? firstMessage.substring(0, 18) + "…"
                          : firstMessage;
            chatHistoryModel.setProperty(currentConversationIndex, "title", title);
        }
    }

    function appendMessage(sender, text) {
        chatModel.append({ sender: sender, text: text });
    }

    function sendCurrentMessage() {
        const trimmed = inputBar.text.trim().length > 0
                        ? inputBar.text.trim()
                        : welcomeInput.text.trim();
        if (trimmed.length === 0) {
            return;
        }

        ensureActiveConversation(trimmed);
        appendMessage("user", trimmed);
        agentKernel.sendMessage(trimmed);
        inputBar.text = "";
        welcomeInput.text = "";
    }

    Component.onCompleted: {
        const demoSessions = [
            { conversationId: "demo-1", title: "框架通路测试" },
            { conversationId: "demo-2", title: "Qt Agent 架构" }
        ];

        for (let i = 0; i < demoSessions.length; ++i) {
            chatHistoryModel.append(demoSessions[i]);
            conversationStore[demoSessions[i].conversationId] = [];
        }

        conversationIdCounter = demoSessions.length;
    }

    Connections {
        target: agentKernel

        function onChatMessageReady(sender, text) {
            appendMessage(sender, text);
        }

        function onTriggerTool(action, args) {
            if (action === "download") {
                const url = args.url !== undefined ? args.url : JSON.stringify(args);
                const message = qsTr("【框架通路测试成功】拦截到下载请求，参数为：") + url;
                console.log(message);
                appendMessage("tool", message);
            } else {
                appendMessage("tool", qsTr("拦截到工具调用：") + action + " " + JSON.stringify(args));
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: sidebarContainer
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: theme.sidebar

            Sidebar {
                id: sidebar
                anchors.fill: parent
                theme: root.theme
                chatHistoryModel: chatHistoryModel
                currentIndex: root.currentConversationIndex
                onConversationSelected: function(index) { root.selectConversation(index) }
                onConversationDeleted: function(index) { root.deleteConversation(index) }
                onNewConversationRequested: root.createNewConversation()
                onSettingsMenuToggled: {
                    settingsPopup.visible = !settingsPopup.visible
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: theme.mainGradientTop }
                    GradientStop { position: 0.55; color: theme.mainGradientBottom }
                    GradientStop { position: 1.0; color: theme.mainGradientBottom }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Column {
                        anchors.centerIn: parent
                        width: Math.min(parent.width - 80, 760)
                        spacing: 36
                        visible: !root.hasConversation

                        Text {
                            width: parent.width
                            text: qsTr("需要我为你做些什么？")
                            color: theme.textPrimary
                            font.pixelSize: 32
                            font.weight: Font.Normal
                            horizontalAlignment: Text.AlignHCenter
                        }

                        InputPill {
                            id: welcomeInput
                            width: parent.width
                            theme: root.theme
                            modelLabel: "Mock"
                            onSendRequested: root.sendCurrentMessage()
                            onAttachRequested: console.log("attach requested")
                        }
                    }

                    ListView {
                        id: chatList
                        anchors.fill: parent
                        anchors.topMargin: 24
                        anchors.bottomMargin: 16
                        anchors.leftMargin: 48
                        anchors.rightMargin: 48
                        visible: root.hasConversation
                        clip: true
                        spacing: 20
                        model: chatModel

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        onCountChanged: Qt.callLater(function() {
                            chatList.positionViewAtEnd();
                        })

                        delegate: ChatBubble {
                            width: chatList.width
                            bubbleWidth: chatList.width
                            sender: model.sender
                            text: model.text
                            theme: root.theme
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.hasConversation ? 96 : 0
                    visible: root.hasConversation

                    InputPill {
                        id: inputBar
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 24
                        width: Math.min(parent.width - 96, 760)
                        theme: root.theme
                        modelLabel: "Mock"
                        onSendRequested: root.sendCurrentMessage()
                        onAttachRequested: console.log("attach requested")
                    }
                }
            }
        }
    }

    Rectangle {
        id: settingsMask
        anchors.fill: parent
        color: "transparent"
        visible: settingsPopup.visible
        z: 99

        MouseArea {
            anchors.fill: parent
            onClicked: {
                settingsPopup.visible = false
            }
        }
    }

    Popup {
        id: settingsPopup
        parent: Overlay.overlay
        x: sidebarContainer.width + 8
        y: parent.height - height - 80
        width: 280
        height: 420
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            color: "#252526"
            radius: 16
            border.color: "#3c3c3c"
            border.width: 1
        }

        SettingsMenu {
            anchors.fill: parent
            theme: root.theme
        }
    }
}
