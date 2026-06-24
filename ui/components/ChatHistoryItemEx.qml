import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var theme
    property string title: ""
    property bool pinned: false
    property bool selected: false
    property bool collapsed: false

    signal clicked()
    signal deleteRequested()
    signal renamed(string newName)
    signal pinChanged(bool pinned)
    signal shared()

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
                Layout.alignment: root.collapsed ? Qt.AlignHCenter : Qt.AlignLeft
                text: root.pinned ? "📌" : "💬"
                font.pixelSize: 14
                opacity: root.selected ? 1.0 : 0.75
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: titleText
                Layout.fillWidth: true
                text: root.title
                color: theme.textPrimary
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
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    contextMenu.x = mouse.x
                    contextMenu.y = mouse.y
                    contextMenu.visible = true
                } else {
                    root.clicked()
                }
            }
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

    ToolButton {
        id: moreButton
        anchors.right: deleteButton.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        z: 1
        opacity: (!root.collapsed && rowMouse.containsMouse) ? 1.0 : 0.0
        visible: opacity > 0
        text: "⋮"
        onClicked: {
            contextMenu.x = moreButton.x - contextMenu.width + moreButton.width
            contextMenu.y = moreButton.y + moreButton.height + 4
            contextMenu.visible = true
        }

        background: Rectangle {
            radius: width / 2
            color: moreButton.down ? theme.sidebarActive
                                    : (moreButton.hovered ? theme.sidebarHover : "transparent")
        }

        contentItem: Text {
            text: moreButton.text
            color: theme.textSecondary
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    Popup {
        id: contextMenu
        parent: Overlay.overlay
        width: 160
        modal: false
        focus: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: theme.inputSurface
            radius: 12
            border.color: theme.inputBorder
            border.width: 1
        }

        Column {
            width: parent.width
            spacing: 0

            Item {
                width: parent.width
                height: 36

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 8

                    Text {
                        text: "\uD83D\uDD17"
                        font.pixelSize: 14
                    }

                    Text {
                        text: qsTr("分享对话内容")
                        color: theme.textPrimary
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    id: shareMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close()
                        root.shared()
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: shareMouse.containsMouse ? theme.sidebarHover : "transparent"
                    }
                }
            }

            Item {
                width: parent.width
                height: 36

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 8

                    Text {
                        text: "\uD83D\uDCCD"
                        font.pixelSize: 14
                    }

                    Text {
                        text: root.pinned ? qsTr("取消固定") : qsTr("固定")
                        color: theme.textPrimary
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    id: pinMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close()
                        root.pinChanged(!root.pinned)
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: pinMouse.containsMouse ? theme.sidebarHover : "transparent"
                    }
                }
            }

            Item {
                width: parent.width
                height: 36

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 8

                    Text {
                        text: "\u270D\uFE0F"
                        font.pixelSize: 14
                    }

                    Text {
                        text: qsTr("重命名")
                        color: theme.textPrimary
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    id: renameMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close()
                        renamePopup.open()
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: renameMouse.containsMouse ? theme.sidebarHover : "transparent"
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: theme.inputBorder
            }

            Item {
                width: parent.width
                height: 36

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 8

                    Text {
                        text: "\uD83D\uDDD1\uFE0F"
                        font.pixelSize: 14
                    }

                    Text {
                        text: qsTr("删除")
                        color: "#ff4444"
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    id: deleteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        contextMenu.close()
                        root.deleteRequested()
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: deleteMouse.containsMouse ? theme.sidebarHover : "transparent"
                    }
                }
            }
        }
    }

    Popup {
        id: renamePopup
        parent: Overlay.overlay
        width: 280
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        background: Rectangle {
            color: theme.inputSurface
            radius: 12
            border.color: theme.inputBorder
            border.width: 1
        }

        Column {
            width: parent.width
            spacing: 16
            anchors.margins: 16

            Text {
                text: qsTr("重命名对话")
                color: theme.textPrimary
                font.pixelSize: 16
                font.weight: Font.Medium
            }

            TextField {
                id: renameInput
                width: parent.width
                text: root.title
                color: theme.textPrimary
                placeholderTextColor: theme.textMuted
                background: Rectangle {
                    color: theme.window
                    radius: 8
                    border.color: renameInput.activeFocus ? theme.accent : theme.inputBorder
                    border.width: 1
                }

                Keys.onReturnPressed: {
                    if (renameInput.text.trim().length > 0) {
                        root.renamed(renameInput.text.trim())
                        renamePopup.close()
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }

            RowLayout {
                width: parent.width
                spacing: 8

                Button {
                    id: cancelButton
                    Layout.fillWidth: true
                    text: qsTr("取消")
                    onClicked: renamePopup.close()

                    background: Rectangle {
                        radius: 8
                        color: cancelButton.down ? theme.sidebarActive : "transparent"
                    }

                    contentItem: Text {
                        text: cancelButton.text
                        color: theme.textPrimary
                        font.pixelSize: 14
                    }
                }

                Button {
                    id: saveButton
                    Layout.fillWidth: true
                    text: qsTr("保存")
                    enabled: renameInput.text.trim().length > 0
                    onClicked: {
                        if (renameInput.text.trim().length > 0) {
                            root.renamed(renameInput.text.trim())
                            renamePopup.close()
                        }
                    }

                    background: Rectangle {
                        radius: 8
                        color: saveButton.enabled ? theme.accent : theme.sidebarHover
                    }

                    contentItem: Text {
                        text: saveButton.text
                        color: saveButton.enabled ? "#ffffff" : theme.textMuted
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}
