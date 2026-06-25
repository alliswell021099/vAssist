import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "components"

ApplicationWindow {
    id: root
    width: 1180
    height: 760

    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("vAssist")
    color: theme.window

    property bool isDarkTheme: false
    property bool sidebarCollapsed: false
    property real sidebarWidth: 280
    property string activeModelLabel: qsTr("vAssist 1.0")

    Behavior on sidebarWidth {
        NumberAnimation {
            duration: 220
            easing.type: Easing.InOutQuad
        }
    }

    onSidebarCollapsedChanged: {
        sidebarWidth = sidebarCollapsed ? 72 : 280;
    }

    readonly property QtObject darkTheme: QtObject {
        readonly property color window: "#0f1115"
        readonly property color sidebar: "#0c0f14"
        readonly property color sidebarHover: "#181d25"
        readonly property color sidebarActive: "#232a35"
        readonly property color mainGradientTop: "#11151b"
        readonly property color mainGradientBottom: "#0f1115"
        readonly property color inputSurface: "#151a21"
        readonly property color inputBorder: "#2b3240"
        readonly property color textPrimary: "#e8eaed"
        readonly property color textSecondary: "#c3c8d1"
        readonly property color textMuted: "#7f8896"
        readonly property color accent: "#8ab4f8"
        readonly property color accentSoft: "#aecbfa"
        readonly property color bubbleUser: "#223149"
        readonly property color bubbleAssistant: "#151a21"
        readonly property color pillButton: "#1a2029"
        readonly property color surfaceRaised: "#1a2029"
        readonly property color divider: "#232a35"
        readonly property color chip: "#1b212b"
        readonly property color chipHover: "#242c38"
    }

    readonly property QtObject lightTheme: QtObject {
        readonly property color window: "#f8fafc"
        readonly property color sidebar: "#f2f4f7"
        readonly property color sidebarHover: "#e7ebf1"
        readonly property color sidebarActive: "#dbe2ea"
        readonly property color mainGradientTop: "#f8fafc"
        readonly property color mainGradientBottom: "#ffffff"
        readonly property color inputSurface: "#ffffff"
        readonly property color inputBorder: "#d6dce4"
        readonly property color textPrimary: "#111827"
        readonly property color textSecondary: "#374151"
        readonly property color textMuted: "#6b7280"
        readonly property color accent: "#1a73e8"
        readonly property color accentSoft: "#4285f4"
        readonly property color bubbleUser: "#dbeafe"
        readonly property color bubbleAssistant: "#ffffff"
        readonly property color pillButton: "#eef2f7"
        readonly property color surfaceRaised: "#ffffff"
        readonly property color divider: "#dbe2ea"
        readonly property color chip: "#eef2f7"
        readonly property color chipHover: "#e4eaf2"
    }

    property QtObject theme: isDarkTheme ? darkTheme : lightTheme

    readonly property bool hasConversation: currentConversationIndex >= 0
    readonly property bool hasConversationMessages: chatModel.count > 0
    readonly property bool showCenteredInput: !hasConversation || !hasConversationMessages
    readonly property bool showConversationArea: hasConversation && hasConversationMessages

    property int currentConversationIndex: -1
    property int conversationIdCounter: 0
    property int streamingMessageIndex: -1
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
        resetStreamingMessage();
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
            if (root.showConversationArea) {
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
        resetStreamingMessage();
        currentConversationIndex = -1;

        const conversationId = nextConversationId();
        chatHistoryModel.insert(0, {
            conversationId: conversationId,
            title: qsTr("新对话"),
            pinned: false
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
                resetStreamingMessage();
                chatModel.clear();
            } else {
                const nextIndex = Math.min(index, chatHistoryModel.count - 1);
                currentConversationIndex = -1;
                selectConversation(nextIndex);
            }
        } else if (currentConversationIndex > index) {
            currentConversationIndex -= 1;
        }

        clearInputs();
    }

    function renameConversation(index, newName) {
        if (index < 0 || index >= chatHistoryModel.count) {
            return;
        }

        const trimmed = newName.trim();
        if (trimmed.length === 0) {
            return;
        }

        chatHistoryModel.setProperty(index, "title", trimmed);
    }

    function setConversationPinned(index, pinned) {
        if (index < 0 || index >= chatHistoryModel.count) {
            return;
        }

        chatHistoryModel.setProperty(index, "pinned", pinned);
    }

    function shareConversation(index) {
        if (index < 0 || index >= chatHistoryModel.count) {
            return;
        }

        const title = chatHistoryModel.get(index).title;
        console.log("share conversation:", title);
        appendMessage("system", qsTr("已生成分享占位：") + title);
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
            title: title,
            pinned: false
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
        resetStreamingMessage();
        chatModel.append({ sender: sender, text: text });
    }

    function resetStreamingMessage() {
        streamingMessageIndex = -1;
    }

    function appendAssistantToken(token) {
        if (streamingMessageIndex < 0 || streamingMessageIndex >= chatModel.count) {
            chatModel.append({ sender: "assistant", text: token });
            streamingMessageIndex = chatModel.count - 1;
            Qt.callLater(function() { chatList.positionViewAtEnd(); });
            return;
        }

        const currentText = chatModel.get(streamingMessageIndex).text;
        chatModel.setProperty(streamingMessageIndex, "text", currentText + token);
        Qt.callLater(function() { chatList.positionViewAtEnd(); });
    }

    function finishAssistantStream(fullResponse) {
        if (streamingMessageIndex < 0 || streamingMessageIndex >= chatModel.count) {
            appendMessage("assistant", fullResponse);
            return;
        }

        chatModel.setProperty(streamingMessageIndex, "text", fullResponse);
        resetStreamingMessage();
    }

    function cancelAssistantStream() {
        if (streamingMessageIndex >= 0 && streamingMessageIndex < chatModel.count) {
            chatModel.remove(streamingMessageIndex);
        }

        resetStreamingMessage();
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
        x = (Screen.width - width) / 2;
        y = (Screen.height - height) / 2;

        const demoSessions = [
            { conversationId: "demo-1", title: "框架通路测试" },
            { conversationId: "demo-2", title: "Qt Agent 架构" }
        ];

        for (let i = 0; i < demoSessions.length; ++i) {
            chatHistoryModel.append({
                conversationId: demoSessions[i].conversationId,
                title: demoSessions[i].title,
                pinned: false
            });
            conversationStore[demoSessions[i].conversationId] = [];
        }

        conversationIdCounter = demoSessions.length;

        if (agentKernel && agentKernel.providerSettings) {
            const ps = agentKernel.providerSettings
            const config = ps.activeProviderConfig()
            if (config && config.model) {
                root.activeModelLabel = config.model
            } else if (config && config.name) {
                root.activeModelLabel = qsTr("未选择模型")
            }
            ps.activeProviderIdChanged.connect(updateModelLabel)
            ps.activeModelChanged.connect(updateModelLabel)
        }
    }

    function updateModelLabel() {
        if (!agentKernel || !agentKernel.providerSettings) return
        const config = agentKernel.providerSettings.activeProviderConfig()
        if (config && config.model) {
            root.activeModelLabel = config.model
        } else if (config && config.name) {
            root.activeModelLabel = qsTr("未选择模型")
        }
    }

    Connections {
        target: agentKernel

        function onChatMessageReady(sender, text) {
            appendMessage(sender, text);
        }

        function onChatTokenReady(token) {
            appendAssistantToken(token);
        }

        function onChatStreamFinished(fullResponse) {
            finishAssistantStream(fullResponse);
        }

        function onChatStreamCancelled() {
            cancelAssistantStream();
        }

        function onTriggerTool(action, args) {
            if (action === "download") {
                const url = args.url !== undefined ? args.url : JSON.stringify(args);
                const message = qsTr("已拦截下载请求：") + url;
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
            Layout.preferredWidth: root.sidebarWidth
            Layout.fillHeight: true
            color: theme.sidebar

            Sidebar {
                id: sidebar
                anchors.fill: parent
                theme: root.theme
                chatHistoryModel: chatHistoryModel
                currentIndex: root.currentConversationIndex
                isCollapsed: root.sidebarCollapsed
                onConversationSelected: function(index) { root.selectConversation(index) }
                onConversationDeleted: function(index) { root.deleteConversation(index) }
                onConversationRenamed: function(index, newName) { root.renameConversation(index, newName) }
                onConversationPinned: function(index, pinned) { root.setConversationPinned(index, pinned) }
                onConversationShared: function(index) { root.shareConversation(index) }
                onNewConversationRequested: root.createNewConversation()
                onSettingsMenuToggled: {
                    settingsPopup.visible = !settingsPopup.visible
                }
                onCollapseToggled: root.sidebarCollapsed = !root.sidebarCollapsed
            }

            MouseArea {
                anchors.fill: parent
                z: 10
                visible: settingsPopup.visible
                enabled: settingsPopup.visible
                onClicked: settingsPopup.visible = false
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
                        id: welcomePane
                        anchors.centerIn: parent
                        width: Math.min(parent.width - 112, 820)
                        visible: root.showCenteredInput
                        spacing: 24

                        Text {
                            width: parent.width
                            text: qsTr("需要我为你做些什么？")
                            color: theme.textPrimary
                            font.pixelSize: 28
                            font.weight: Font.Normal
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }

                        InputPill {
                            id: welcomeInput
                            width: Math.min(parent.width - 112, 820)
                            anchors.horizontalCenter: parent.horizontalCenter
                            theme: root.theme
                            modelLabel: root.activeModelLabel
                            providerSettings: agentKernel.providerSettings
                            onSendRequested: root.sendCurrentMessage()
                            onAttachRequested: console.log("attach requested")
                            onVoiceRequested: console.log("voice requested")
                            onModelSelectorClicked: {
                                console.log("main.qml: modelSelectorClicked received")
                                openModelSettingsDialog()
                            }
                            onModelSelected: function(providerId, modelName) {
                                agentKernel.providerSettings.setActiveProviderId(providerId)
                                agentKernel.providerSettings.setProviderActiveModel(providerId, modelName)
                                agentKernel.providerSettings.save()
                            }
                        }
                    }

                    ListView {
                        id: chatList
                        anchors.fill: parent
                        anchors.topMargin: 28
                        anchors.bottomMargin: 20
                        anchors.leftMargin: 56
                        anchors.rightMargin: 56
                        visible: root.showConversationArea
                        clip: true
                        spacing: 18
                        model: chatModel

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AlwaysOff
                        }

                        onCountChanged: Qt.callLater(function() {
                            chatList.positionViewAtEnd();
                        })

                        delegate: ChatBubble {
                            width: chatList.width
                            bubbleWidth: chatList.width
                            theme: root.theme
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.showConversationArea ? 96 : 0
                    visible: root.showConversationArea

                    InputPill {
                        id: inputBar
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 24
                        width: Math.min(parent.width - 112, 820)
                        theme: root.theme
                        modelLabel: root.activeModelLabel
                        providerSettings: agentKernel.providerSettings
                        onSendRequested: root.sendCurrentMessage()
                        onAttachRequested: console.log("attach requested")
                        onVoiceRequested: console.log("voice requested")
                        onModelSelectorClicked: openModelSettingsDialog()
                        onModelSelected: function(providerId, modelName) {
                            agentKernel.providerSettings.setActiveProviderId(providerId)
                            agentKernel.providerSettings.setProviderActiveModel(providerId, modelName)
                            agentKernel.providerSettings.save()
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
        }
    }

    Popup {
        id: settingsPopup
        parent: Overlay.overlay
        readonly property real settingsButtonX: sidebarContainer.x + 16 + (root.sidebarCollapsed ? 0 : 216)
        readonly property real settingsButtonY: parent.height - 16 - 76 + (root.sidebarCollapsed ? 0 : 44)

        x: Math.min(parent.width - width - 12, Math.max(12, settingsButtonX))
        y: Math.max(12, settingsButtonY - height - 8)
        width: 280
        height: Math.min(parent.height - 96, settingsMenuContent.implicitHeight)
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape
        transformOrigin: Item.BottomLeft

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 140
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                property: "scale"
                from: 0.96
                to: 1.0
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 100
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.98
                duration: 100
                easing.type: Easing.InCubic
            }
        }

        background: Rectangle {
            color: root.isDarkTheme ? "#252526" : "#ffffff"
            radius: 16
            border.color: root.isDarkTheme ? "#3c3c3c" : "#e0e0e0"
            border.width: 1
        }

        SettingsMenu {
            id: settingsMenuContent
            anchors.fill: parent
            theme: root.theme
            isDarkTheme: root.isDarkTheme
            currentThemeIndex: root.isDarkTheme ? 2 : 1
            currentModelName: root.activeModelLabel

            onThemeSelectionChanged: {
                if (index === 0) {
                } else if (index === 1) {
                    root.isDarkTheme = false
                } else if (index === 2) {
                    root.isDarkTheme = true
                }
            }

            onModelSettingsRequested: {
                settingsPopup.visible = false
                openModelSettingsDialog()
            }
        }
    }

    Component {
        id: modelSettingsDialogComponent
        ModelSettingsDialog {
            theme: root.theme
            isDarkTheme: root.isDarkTheme
            providerSettings: agentKernel.providerSettings
        }
    }

    property var modelSettingsDialog: null

    function openModelSettingsDialog() {
        if (modelSettingsDialog) {
            modelSettingsDialog.requestActivate()
            return
        }
        modelSettingsDialog = modelSettingsDialogComponent.createObject(root)
        modelSettingsDialog.show()

        modelSettingsDialog.closing.connect(function() {
            modelSettingsDialog.destroy()
            modelSettingsDialog = null
        })
    }
}


