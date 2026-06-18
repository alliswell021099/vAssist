import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    required property bool isDarkTheme
    signal themeToggled()

    Column {
        id: menuColumn
        anchors.fill: parent
        anchors.margins: 8
        spacing: 0

        // 菜单项模板 - 带箭头
        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "📋"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "活动记录"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "⚡"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "个性化智能服务"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "📥"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "将记忆导入 vAssist"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "新"
                color: "#1a73e8"
                font.pixelSize: 11
                font.weight: Font.Medium
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "📊"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "用量限额"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.inputBorder
        }

        RowLayout {
            id: themeRow
            width: parent.width
            height: 40
            spacing: 10

            MouseArea {
                anchors.fill: parent
                onClicked: root.themeToggled()
            }

            Text {
                text: "🌙"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: root.isDarkTheme ? "深色主题" : "浅色主题"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "›"
                color: theme.textMuted
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "📺"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "主题订阅"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "›"
                color: theme.textMuted
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "📖"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "查看订阅"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.inputBorder
        }

        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "💬"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "发送反馈"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            width: parent.width
            height: 40
            spacing: 10

            Text {
                text: "❓"
                color: theme.textPrimary
                font.pixelSize: 16
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "帮助"
                color: theme.textPrimary
                font.pixelSize: 14
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "›"
                color: theme.textMuted
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.inputBorder
        }

        Column {
            width: parent.width
            topPadding: 8

            Text {
                width: parent.width
                text: "this is text.."
                color: "#1a73e8"
                font.pixelSize: 13
                font.weight: Font.Medium
                anchors.left: parent.left
                anchors.leftMargin: 34
            }
        }
    }
}
