import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    required property bool isDarkTheme
    property int currentThemeIndex: 1
    property bool themeSubMenuOpen: false
    property bool localModelSubMenuOpen: false
    property string localApiBase: "http://localhost:11434/v1"
    property string localModelName: "qwen2.5:7b"
    property string localApiKey: ""
    property string connectionStatus: ""
    property bool connectionOk: false
    implicitHeight: contentColumn.implicitHeight + 16

    signal themeSelectionChanged(int index)
    signal testConnectionRequested()
    signal applyAndSwitchLocalRequested(string apiBase, string modelName, string apiKey)
    signal switchToMockRequested()

    component SettingsRow: Item {
        id: rowRoot

        required property var theme
        property string iconText: ""
        property string label: ""
        property string trailingText: ""
        property color iconColor: theme.textPrimary
        property color trailingColor: theme.textMuted

        signal clicked()

        width: parent ? parent.width : 280
        height: 40

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: rowMouse.pressed ? rowRoot.theme.sidebarActive
                                    : (rowMouse.containsMouse ? rowRoot.theme.sidebarHover : "transparent")
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Text {
                text: rowRoot.iconText
                color: rowRoot.iconColor
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 24
            }

            Text {
                text: rowRoot.label
                color: rowRoot.theme.textPrimary
                font.pixelSize: 14
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: rowRoot.trailingText
                color: rowRoot.trailingColor
                font.pixelSize: 12
                visible: rowRoot.trailingText.length > 0
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: rowRoot.clicked()
        }
    }

    Column {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2

        SettingsRow {
            theme: root.theme
            iconText: "📋"
            label: qsTr("活动记录")
        }

        SettingsRow {
            theme: root.theme
            iconText: "⚡"
            label: qsTr("本地模型 (Ollama)")
            trailingText: root.localModelSubMenuOpen ? "∧" : "›"
            trailingColor: root.connectionOk ? "#34a853" : root.theme.textMuted
            onClicked: root.localModelSubMenuOpen = !root.localModelSubMenuOpen
        }

        Column {
            width: parent.width
            visible: root.localModelSubMenuOpen
            spacing: 4

            Item {
                width: parent.width
                height: 48

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 36
                    anchors.rightMargin: 12
                    anchors.top: parent.top
                    spacing: 4

                    Text {
                        text: qsTr("API 地址")
                        color: root.theme.textSecondary
                        font.pixelSize: 11
                    }

                    Rectangle {
                        width: parent.width
                        height: 28
                        radius: 6
                        color: root.theme.inputSurface
                        border.color: root.theme.inputBorder
                        border.width: 1

                        TextInput {
                            id: apiBaseInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.localApiBase
                            // placeholderText: "http://localhost:11434/v1"
                            color: root.theme.textPrimary
                            // placeholderTextColor: root.theme.textMuted
                            font.pixelSize: 12
                            verticalAlignment: TextInput.AlignVCenter
                            selectionColor: root.theme.accent
                            selectedTextColor: "#ffffff"
                            onTextChanged: root.localApiBase = text
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 48

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 36
                    anchors.rightMargin: 12
                    spacing: 4

                    Text {
                        text: qsTr("模型名称")
                        color: root.theme.textSecondary
                        font.pixelSize: 11
                    }

                    Rectangle {
                        width: parent.width
                        height: 28
                        radius: 6
                        color: root.theme.inputSurface
                        border.color: root.theme.inputBorder
                        border.width: 1

                        TextInput {
                            id: modelNameInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.localModelName
                            color: root.theme.textPrimary
                            font.pixelSize: 12
                            verticalAlignment: TextInput.AlignVCenter
                            selectionColor: root.theme.accent
                            selectedTextColor: "#ffffff"
                            onTextChanged: root.localModelName = text
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 48

                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 36
                    anchors.rightMargin: 12
                    spacing: 4

                    Text {
                        text: qsTr("API Key (可选)")
                        color: root.theme.textSecondary
                        font.pixelSize: 11
                    }

                    Rectangle {
                        width: parent.width
                        height: 28
                        radius: 6
                        color: root.theme.inputSurface
                        border.color: root.theme.inputBorder
                        border.width: 1

                        TextInput {
                            id: apiKeyInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.localApiKey
                            color: root.theme.textPrimary
                            font.pixelSize: 12
                            echoMode: TextInput.Password
                            verticalAlignment: TextInput.AlignVCenter
                            selectionColor: root.theme.accent
                            selectedTextColor: "#ffffff"
                            onTextChanged: root.localApiKey = text
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 32

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 36
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        id: testBtn
                        width: (parent.width - 8) / 2
                        height: 28
                        radius: 6
                        color: testBtnMouse.pressed ? root.theme.sidebarActive : root.theme.sidebarHover

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("测试连接")
                            color: root.theme.textPrimary
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: testBtnMouse
                            anchors.fill: parent
                            onClicked: root.testConnectionRequested()
                        }
                    }

                    Rectangle {
                        id: useBtn
                        width: (parent.width - 8) / 2
                        height: 28
                        radius: 6
                        color: useBtnMouse.pressed ? root.theme.accent : root.theme.sidebarActive

                        Text {
                            anchors.centerIn: parent
                            text: qsTr("应用并使用")
                            color: root.theme.textPrimary
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: useBtnMouse
                            anchors.fill: parent
                            onClicked: {
                                root.applyAndSwitchLocalRequested(
                                    root.localApiBase,
                                    root.localModelName,
                                    root.localApiKey
                                )
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 24

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 36
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        text: root.connectionOk ? "●" : "○"
                        color: root.connectionOk ? "#34a853" : root.theme.textMuted
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.connectionStatus.length > 0
                               ? root.connectionStatus
                               : qsTr("未测试连接")
                        color: root.connectionOk ? "#34a853" : root.theme.textMuted
                        font.pixelSize: 11
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            Item { width: 1; height: 4 }
        }

        SettingsRow {
            theme: root.theme
            iconText: "🧪"
            label: qsTr("Mock 测试模式")
            trailingText: "›"
            onClicked: root.switchToMockRequested()
        }

        SettingsRow {
            theme: root.theme
            iconText: "📥"
            label: qsTr("将记忆导入 vAssist")
            trailingText: qsTr("新")
            trailingColor: "#1a73e8"
        }

        SettingsRow {
            theme: root.theme
            iconText: "📊"
            label: qsTr("用量限额")
        }

        Rectangle { width: parent.width; height: 1; color: theme.inputBorder }

        SettingsRow {
            theme: root.theme
            iconText: "🌙"
            label: qsTr("主题")
            trailingText: root.themeSubMenuOpen ? "∧" : "›"
            onClicked: root.themeSubMenuOpen = !root.themeSubMenuOpen
        }

        Column {
            width: parent.width
            visible: root.themeSubMenuOpen
            spacing: 0

            SettingsRow {
                theme: root.theme
                iconText: "●"
                iconColor: root.currentThemeIndex === 0 ? root.theme.accentSoft : "transparent"
                label: qsTr("系统")
                onClicked: {
                    root.currentThemeIndex = 0;
                    root.themeSubMenuOpen = false;
                    root.themeSelectionChanged(0);
                }
            }

            SettingsRow {
                theme: root.theme
                iconText: "●"
                iconColor: root.currentThemeIndex === 1 ? root.theme.accentSoft : "transparent"
                label: qsTr("浅色")
                onClicked: {
                    root.currentThemeIndex = 1;
                    root.themeSubMenuOpen = false;
                    root.themeSelectionChanged(1);
                }
            }

            SettingsRow {
                theme: root.theme
                iconText: "●"
                iconColor: root.currentThemeIndex === 2 ? root.theme.accentSoft : "transparent"
                label: qsTr("深色")
                onClicked: {
                    root.currentThemeIndex = 2;
                    root.themeSubMenuOpen = false;
                    root.themeSelectionChanged(2);
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: theme.inputBorder }

        SettingsRow {
            theme: root.theme
            iconText: "💬"
            label: qsTr("关于")
        }

        SettingsRow {
            theme: root.theme
            iconText: "❓"
            label: qsTr("帮助")
            trailingText: "›"
        }

        Item { width: 1; height: 8 }
    }
}
