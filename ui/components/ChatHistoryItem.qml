import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    property string title: ""
    property bool selected: false
    property bool collapsed: false

    signal clicked()
    signal deleteRequested()

    height: 40
    width: parent ? parent.width : 240

    Rectangle {
        id: background
        anchors.fill: parent
        radius: 8
        color: root.selected ? theme.sidebarActive
                             : (rowMouse.containsMouse ? theme.sidebarHover : "transparent")

        Rectangle {
            width: root.collapsed ? 0 : 3
            height: parent.height - 12
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            radius: 1.5
            color: theme.accent
            visible: root.selected && !root.collapsed

            Behavior on width {
                NumberAnimation { duration: 200 }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: root.collapsed ? 0 : 14
            anchors.rightMargin: root.collapsed ? 0 : 44
            spacing: root.collapsed ? 0 : 10

            Text {
                Layout.preferredWidth: 18
                Layout.alignment: root.collapsed ? Qt.AlignHCenter : undefined
                text: "222"
                font.pixelSize: 14
                opacity: root.selected ? 1.0 : 0.75
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: titleText
                Layout.fillWidth: true
                text: root.title
                color: "#d4d4d4"
                font.pixelSize: 13
                font.weight: root.selected ? Font.Medium : Font.Normal
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                visible: !root.collapsed
                opacity: root.collapsed ? 0 : 1

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }

    ToolButton {
        id: deleteButton
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        z: 1
        opacity: (!root.collapsed && rowMouse.containsMouse) ? 1.0 : 0.0
        visible: opacity > 0
        text: "×"
        onClicked: root.deleteRequested()

        background: Rectangle {
            radius: width / 2
            color: deleteButton.down ? theme.sidebarActive
                                      : (deleteButton.hovered ? theme.sidebarHover : "transparent")
        }

        contentItem: Text {
            text: deleteButton.text
            color: theme.textSecondary
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }
}