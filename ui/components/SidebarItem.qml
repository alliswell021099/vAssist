import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var theme
    property string label: ""
    property string iconText: ""
    property bool active: false
    property bool collapsed: false

    signal clicked()

    implicitWidth: parent ? parent.width : 240
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.active ? root.theme.sidebarActive
                           : (mouseArea.containsMouse ? root.theme.sidebarHover : "transparent")

        Row {
            anchors.left: collapsed ? undefined : parent.left
            anchors.leftMargin: collapsed ? 0 : 14
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: collapsed ? parent.horizontalCenter : undefined
            spacing: collapsed ? 0 : 12

            Text {
                text: root.iconText
                color: root.theme.textSecondary
                font.pixelSize: 15
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.label
                color: root.theme.textPrimary
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
                visible: !collapsed

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}