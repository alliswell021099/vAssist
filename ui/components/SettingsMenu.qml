import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    required property bool isDarkTheme
    property int currentThemeIndex: 1
    property bool themeSubMenuOpen: false
    implicitHeight: contentColumn.implicitHeight + 16

    signal themeSelectionChanged(int index)

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
            label: qsTr("个性化智能服务")
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
