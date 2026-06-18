import QtQuick

Item {
    id: root
    required property var theme

    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 0

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "📋"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                text: "活动记录"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "⚡"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                text: "个性化智能服务"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "📥"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 40
                text: "将记忆导入 vAssist"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                anchors.right: parent.right
                text: "新"
                color: "#1a73e8"
                font.pixelSize: 11
                font.weight: Font.Medium
            }
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "📊"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                text: "用量限额"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.inputBorder
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "🌙"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 20
                text: "主题"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                anchors.right: parent.right
                text: "›"
                color: theme.textMuted
                font.pixelSize: 14
            }
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "📺"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 20
                text: "主题订阅"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                anchors.right: parent.right
                text: "›"
                color: theme.textMuted
                font.pixelSize: 14
            }
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "📖"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                text: "查看订阅"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.inputBorder
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "💬"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                text: "发送反馈"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        Row {
            width: parent.width
            height: 40
            spacing: 12

            Text {
                width: 20
                text: "❓"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 20
                text: "帮助"
                color: theme.textPrimary
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                anchors.right: parent.right
                text: "›"
                color: theme.textMuted
                font.pixelSize: 14
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.inputBorder
        }

        Column {
            width: parent.width
            padding: 8

            Text {
                width: parent.width
                text: "这是一个测试"
                color: "#1a73e8"
                font.pixelSize: 13
                font.weight: Font.Medium
            }
        }
    }
}