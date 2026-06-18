import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    required property bool isDarkTheme
    property int currentThemeIndex: 1
    property bool themeSubMenuOpen: false
    signal themeSelectionChanged(int index)

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 2

        Item {
            width: parent.width
            height: 40

            RowLayout {
                    anchors.fill: parent
                    Text { text: "📋"; font.pixelSize: 16; Layout.preferredWidth: 24; color: theme.textPrimary }
                    Text { text: "活动记录"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
                }
        }

        Item {
            width: parent.width
            height: 40

            RowLayout {
                    anchors.fill: parent
                    Text { text: "⚡"; font.pixelSize: 16; Layout.preferredWidth: 24; color: theme.textPrimary }
                    Text { text: "个性化智能服务"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
                }
        }

        Item {
            width: parent.width
            height: 40

            RowLayout {
                    anchors.fill: parent
                    Text { text: "📥"; font.pixelSize: 16; Layout.preferredWidth: 24; color: theme.textPrimary }
                    Text { text: "将记忆导入 vAssist"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
                    Text { text: "新"; color: "#1a73e8"; font.pixelSize: 11 }
                }
        }

        Item {
            width: parent.width
            height: 40

            RowLayout {
                anchors.fill: parent
                Text { text: "📊"; font.pixelSize: 16; Layout.preferredWidth: 24 }
                Text { text: "用量限额"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
            }
        }

        Rectangle { width: parent.width; height: 1; color: theme.inputBorder }

        // 主题
        Item {
            width: parent.width
            height: 40

            RowLayout {
                    anchors.fill: parent
                    Text { text: "🌙"; font.pixelSize: 16; Layout.preferredWidth: 24; color: theme.textPrimary }
                    Text { text: "主题"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
                    Text { text: themeSubMenuOpen ? "∧" : "›"; color: theme.textMuted; font.pixelSize: 12 }
                }

            MouseArea {
                anchors.fill: parent
                onClicked: themeSubMenuOpen = !themeSubMenuOpen
            }
        }

        // 二级菜单
        Column {
            width: parent.width
            visible: themeSubMenuOpen
            spacing: 0

            Item {
                width: parent.width
                height: 36

                RowLayout {
                    anchors.fill: parent
                    Text { text: "●"; color: currentThemeIndex === 0 ? theme.accentSoft : "transparent"; font.pixelSize: 10; Layout.preferredWidth: 24 }
                    Text { text: "系统"; color: currentThemeIndex === 0 ? theme.accentSoft : theme.textPrimary; font.pixelSize: 14; Layout.fillWidth: true }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentThemeIndex = 0
                        themeSubMenuOpen = false
                        root.themeSelectionChanged(0)
                    }
                }
            }

            Item {
                width: parent.width
                height: 36

                RowLayout {
                    anchors.fill: parent
                    Text { text: "●"; color: currentThemeIndex === 1 ? theme.accentSoft : "transparent"; font.pixelSize: 10; Layout.preferredWidth: 24 }
                    Text { text: "浅色"; color: currentThemeIndex === 1 ? theme.accentSoft : theme.textPrimary; font.pixelSize: 14; Layout.fillWidth: true }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentThemeIndex = 1
                        themeSubMenuOpen = false
                        root.themeSelectionChanged(1)
                    }
                }
            }

            Item {
                width: parent.width
                height: 36

                RowLayout {
                    anchors.fill: parent
                    Text { text: "●"; color: currentThemeIndex === 2 ? theme.accentSoft : "transparent"; font.pixelSize: 10; Layout.preferredWidth: 24 }
                    Text { text: "深色"; color: currentThemeIndex === 2 ? theme.accentSoft : theme.textPrimary; font.pixelSize: 14; Layout.fillWidth: true }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        currentThemeIndex = 2
                        themeSubMenuOpen = false
                        root.themeSelectionChanged(2)
                    }
                }
            }
        }

        Item {
            width: parent.width
            height: 40

            RowLayout {
                    anchors.fill: parent
                    Text { text: "📺"; font.pixelSize: 16; Layout.preferredWidth: 24; color: theme.textPrimary }
                    Text { text: "主题订阅"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
                    Text { text: "›"; color: theme.textMuted; font.pixelSize: 12 }
                }
        }

        Item {
            width: parent.width
            height: 40

            RowLayout {
                anchors.fill: parent
                Text { text: "📖"; font.pixelSize: 16; Layout.preferredWidth: 24 }
                Text { text: "查看订阅"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
            }
        }

        Rectangle { width: parent.width; height: 1; color: theme.inputBorder }

        Item {
            width: parent.width
            height: 40

            RowLayout {
                    anchors.fill: parent
                    Text { text: "💬"; font.pixelSize: 16; Layout.preferredWidth: 24; color: theme.textPrimary }
                    Text { text: "发送反馈"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
                }
        }

        Item {
            width: parent.width
            height: 40

            RowLayout {
                    anchors.fill: parent
                    Text { text: "❓"; font.pixelSize: 16; Layout.preferredWidth: 24; color: theme.textPrimary }
                    Text { text: "帮助"; font.pixelSize: 14; Layout.fillWidth: true; color: theme.textPrimary }
                    Text { text: "›"; color: theme.textMuted; font.pixelSize: 12 }
                }
        }
    }
}
