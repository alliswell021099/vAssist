import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    width: 760
    height: 620
    minimumWidth: 700
    minimumHeight: 560
    title: qsTr("模型设置")
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.WindowModal
    color: "transparent"

    property var theme
    property bool isDarkTheme: false
    property var providerSettings

    property string selectedProviderId: ""
    property bool isAddingProvider: false
    property var providerItems: []
    property var modelItems: []
    property string selectedProviderActiveModel: ""

    readonly property int shadowPadding: 24
    readonly property int sidebarWidth: 220

    function refreshProviderItems() {
        if (root.providerSettings) {
            root.providerItems = root.providerSettings.providers()
            if (root.selectedProviderId.length > 0) {
                refreshModelItems()
            }
        } else {
            root.providerItems = []
            root.modelItems = []
            root.selectedProviderActiveModel = ""
        }
    }

    function refreshModelItems() {
        if (!root.providerSettings || root.selectedProviderId.length === 0) {
            root.modelItems = []
            root.selectedProviderActiveModel = ""
            return
        }
        root.modelItems = root.providerSettings.modelsForProvider(root.selectedProviderId)
        root.selectedProviderActiveModel = getCurrentProviderProp("activeModel")
    }

    function isCurrentModelActive(modelName) {
        if (!root.providerSettings || selectedProviderId.length === 0) return false
        return root.selectedProviderActiveModel === modelName
    }

    onSelectedProviderIdChanged: refreshModelItems()

    Repeater {
        model: 8
        Rectangle {
            property int shadowLayer: index
            z: -shadowLayer
            anchors.centerIn: parent
            width: parent.width - shadowPadding * 2 + shadowLayer * 1.2
            height: parent.height - shadowPadding * 2 + shadowLayer * 1.2
            radius: 10 + shadowLayer * 0.6
            color: Qt.rgba(0, 0, 0, 0.004 + shadowLayer * 0.002)
            opacity: 1 - shadowLayer * 0.08
        }
    }

    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: parent.width - shadowPadding * 2
        height: parent.height - shadowPadding * 2
        color: root.isDarkTheme
               ? Qt.rgba(0.12, 0.12, 0.14, 0.95)
               : Qt.rgba(1.0, 1.0, 1.0, 0.96)
        border.color: root.theme.divider
        border.width: 0.5
        radius: 10
        clip: true
    }

    MouseArea {
        id: dragArea
        anchors.top: contentRect.top
        anchors.left: contentRect.left
        anchors.right: contentRect.right
        height: 36
        z: 1
        cursorShape: Qt.OpenHandCursor
        onPressed: root.startSystemMove()
    }

    Row {
        id: mainRow
        anchors.fill: contentRect
        z: 10
        spacing: 0

        Item {
            id: sidebar
            width: sidebarWidth
            height: parent.height

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 0.5
                color: root.theme.divider
            }

            Column {
                anchors.fill: parent
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Row {
                    width: parent.width
                    height: 28
                    spacing: 8

                    Rectangle {
                        width: 24
                        height: 24
                        y: 2
                        radius: 4
                        color: backMouse.pressed ? root.theme.sidebarActive
                               : (backMouse.containsMouse ? root.theme.sidebarHover
                                  : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: "←"
                            color: root.theme.textPrimary
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: backMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: root.close()
                        }
                    }

                    Text {
                        text: qsTr("模型设置")
                        color: root.theme.textPrimary
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        y: 7
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.theme.divider
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 96
                    contentWidth: width
                    contentHeight: providerColumn.height
                    clip: true

                    Column {
                        id: providerColumn
                        width: sidebarWidth - 20
                        spacing: 2

                        Repeater {
                            model: root.providerItems

                            Rectangle {
                                width: providerColumn.width
                                height: 32
                                radius: 4
                                color: selectedProviderId === modelData.id
                                       ? root.theme.sidebarActive
                                       : (providerMouse.containsMouse
                                          ? root.theme.sidebarHover
                                          : "transparent")

                                Item {
                                    width: parent.width
                                    height: parent.height

                                    Rectangle {
                                        x: 8
                                        y: 6
                                        width: 20
                                        height: 20
                                        radius: 4
                                        color: selectedProviderId === modelData.id
                                               ? root.theme.accent
                                               : (root.theme.accent + "18")

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name.substring(0, 1)
                                            color: selectedProviderId === modelData.id
                                                   ? "#ffffff"
                                                   : root.theme.accent
                                            font.pixelSize: 11
                                            font.weight: Font.Bold
                                        }
                                    }

                                    Text {
                                        x: 36
                                        y: 10
                                        text: modelData.name
                                        color: selectedProviderId === modelData.id
                                               ? root.theme.accent
                                               : root.theme.textPrimary
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        width: parent.width - 56
                                    }

                                    Rectangle {
                                        x: parent.width - 14
                                        y: 13
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: isCurrentActiveItem(modelData.id) ? root.theme.accent : "transparent"
                                    }
                                }

                                MouseArea {
                                    id: providerMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        root.selectedProviderId = modelData.id
                                        root.isAddingProvider = false
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.theme.divider
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 4
                    color: addMouse.pressed ? root.theme.sidebarActive
                           : (addMouse.containsMouse ? root.theme.sidebarHover
                              : "transparent")

                    Row {
                        width: parent.width - 8
                        height: parent.height
                        x: 8
                        spacing: 6

                        Text {
                            text: "+"
                            color: root.theme.textSecondary
                            font.pixelSize: 14
                            y: 9
                        }

                        Text {
                            text: qsTr("添加供应商")
                            color: root.theme.textSecondary
                            font.pixelSize: 12
                            y: 10
                        }
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            root.isAddingProvider = true
                            root.selectedProviderId = ""
                        }
                    }
                }
            }
        }

        Item {
            id: detailPanel
            width: parent.width - sidebarWidth
            height: parent.height
            clip: true

            Flickable {
                id: detailFlick
                anchors.fill: parent
                contentWidth: width
                contentHeight: detailColumn.height + 48
                clip: true
                interactive: detailColumn.height + 48 > height

                Column {
                    id: detailColumn
                    width: parent.width - 56
                    x: 28
                    y: 24
                    spacing: 16
                    visible: selectedProviderId.length > 0 || isAddingProvider

                    readonly property real contentWidth: width

                    Item {
                        width: detailColumn.contentWidth
                        height: titleText.height + descText.height + 4

                        Text {
                            id: titleText
                            text: isAddingProvider ? qsTr("添加模型供应商") : qsTr("供应商设置")
                            color: root.theme.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        Rectangle {
                            id: deleteBtn
                            width: 72
                            height: 24
                            radius: 4
                            color: deleteBtnMouse.pressed ? "#d93025" : "#ea4335"
                            visible: !isAddingProvider && !isCurrentProviderPreset()
                            anchors.right: parent.right
                            anchors.top: parent.top

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("删除")
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: deleteBtnMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.providerSettings) return
                                    root.providerSettings.deleteProvider(selectedProviderId)
                                    root.selectedProviderId = ""
                                }
                            }
                        }

                        Text {
                            id: descText
                            text: isAddingProvider
                                  ? qsTr("配置一个完全自定义的 API 端点和初始模型。")
                                  : (isCurrentProviderPreset()
                                     ? qsTr("MockProvider 是内置测试供应商，不需要配置。")
                                     : qsTr("可保存 Base URL、API Key 和默认模型。"))
                            color: root.theme.textSecondary
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            width: parent.width
                            anchors.top: titleText.bottom
                            anchors.topMargin: 4
                        }
                    }

                    Column {
                        width: detailColumn.contentWidth
                        spacing: 12

                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: qsTr("名称")
                                color: root.theme.textSecondary
                                font.pixelSize: 11
                            }

                            Rectangle {
                                width: parent.width
                                height: 32
                                radius: 4
                                color: root.theme.inputSurface
                                border.color: root.theme.inputBorder
                                border.width: 1
                                clip: true

                                TextField {
                                    id: nameInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    text: isAddingProvider ? "" : getCurrentProviderProp("name")
                                    color: root.theme.textPrimary
                                    font.pixelSize: 12
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectionColor: root.theme.accent
                                    selectedTextColor: "#ffffff"
                                    placeholderText: qsTr("如：智谱 GLM")
                                    placeholderTextColor: root.theme.textMuted
                                    background: null
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: qsTr("Base URL")
                                color: root.theme.textSecondary
                                font.pixelSize: 11
                            }

                            Rectangle {
                                width: parent.width
                                height: 32
                                radius: 4
                                color: root.theme.inputSurface
                                border.color: root.theme.inputBorder
                                border.width: 1
                                clip: true

                                TextField {
                                    id: urlInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    text: isAddingProvider ? "" : getCurrentProviderProp("baseUrl")
                                    color: root.theme.textPrimary
                                    font.pixelSize: 12
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectionColor: root.theme.accent
                                    selectedTextColor: "#ffffff"
                                    placeholderText: qsTr("https://api.example.com/v1")
                                    placeholderTextColor: root.theme.textMuted
                                    background: null
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: qsTr("API Key")
                                color: root.theme.textSecondary
                                font.pixelSize: 11
                            }

                            Rectangle {
                                width: parent.width
                                height: 32
                                radius: 4
                                color: root.theme.inputSurface
                                border.color: root.theme.inputBorder
                                border.width: 1
                                clip: true

                                TextField {
                                    id: keyInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    text: isAddingProvider ? "" : getCurrentProviderProp("apiKey")
                                    color: root.theme.textPrimary
                                    font.pixelSize: 12
                                    echoMode: TextInput.Password
                                    verticalAlignment: TextInput.AlignVCenter
                                    selectionColor: root.theme.accent
                                    selectedTextColor: "#ffffff"
                                    placeholderText: qsTr("输入 API Key")
                                    placeholderTextColor: root.theme.textMuted
                                    background: null
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: qsTr("API 格式")
                                color: root.theme.textSecondary
                                font.pixelSize: 11
                            }

                            Rectangle {
                                width: parent.width
                                height: 32
                                radius: 4
                                color: root.theme.inputSurface
                                border.color: root.theme.inputBorder
                                border.width: 1

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: qsTr("OpenAI Messages (/v1/chat/completions)")
                                    color: root.theme.textPrimary
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 4

                            Text {
                                text: qsTr("默认模型")
                                color: root.theme.textSecondary
                                font.pixelSize: 11
                            }

                            Text {
                                text: qsTr("点击模型只会设为该供应商的默认模型，不会切换当前供应商")
                                color: root.theme.textMuted
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                            Column {
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: root.modelItems

                                    Rectangle {
                                        width: parent.width
                                        height: 28
                                        radius: 4
                                        color: isCurrentModelActive(modelData)
                                               ? root.theme.accent + "18"
                                               : root.theme.sidebarHover

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: isCurrentModelActive(modelData)
                                                          ? Qt.ArrowCursor
                                                          : Qt.PointingHandCursor
                                            onClicked: {
                                                if (!root.providerSettings || selectedProviderId.length === 0) return
                                                root.providerSettings.setProviderActiveModel(selectedProviderId, modelData)
                                                root.selectedProviderActiveModel = modelData
                                            }
                                        }

                                        Item {
                                            width: parent.width - 20
                                            height: parent.height
                                            x: 10

                                            Rectangle {
                                                x: 0
                                                y: 9
                                                width: 10
                                                height: 10
                                                radius: 5
                                                color: isCurrentModelActive(modelData)
                                                       ? root.theme.accent
                                                       : root.theme.textMuted
                                                opacity: isCurrentModelActive(modelData) ? 1 : 0.45
                                            }

                                            Text {
                                                x: 16
                                                text: modelData
                                                color: isCurrentModelActive(modelData)
                                                       ? root.theme.accent
                                                       : root.theme.textPrimary
                                                font.pixelSize: 11
                                                y: 8
                                                width: parent.width - 56
                                                elide: Text.ElideMiddle
                                            }

                                            Rectangle {
                                                id: deleteModelButton
                                                width: 18
                                                height: 18
                                                radius: 9
                                                x: parent.width - width - 2
                                                y: 5
                                                color: deleteModelMouse.containsMouse
                                                       ? root.theme.sidebarActive
                                                       : "transparent"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "×"
                                                    color: root.theme.textMuted
                                                    font.pixelSize: 12
                                                }

                                                MouseArea {
                                                    id: deleteModelMouse
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        if (root.providerSettings) {
                                                            root.providerSettings.deleteModel(selectedProviderId, modelData)
                                                            refreshModelItems()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    height: 30
                                    spacing: 6

                                    Rectangle {
                                        width: parent.width - 70
                                        height: 30
                                        radius: 4
                                        color: root.theme.inputSurface
                                        border.color: root.theme.inputBorder
                                        border.width: 1
                                        clip: true

                                        TextField {
                                            id: newModelInput
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            color: root.theme.textPrimary
                                            font.pixelSize: 11
                                            verticalAlignment: TextInput.AlignVCenter
                                            placeholderText: qsTr("输入模型名称")
                                            placeholderTextColor: root.theme.textMuted
                                            background: null
                                        }
                                    }

                                    Rectangle {
                                        width: 64
                                        height: 30
                                        radius: 4
                                        color: addModelMouse.pressed ? root.theme.accentSoft : root.theme.accent

                                        Text {
                                            anchors.centerIn: parent
                                            text: qsTr("添加")
                                            color: "#ffffff"
                                            font.pixelSize: 11
                                        }

                                        MouseArea {
                                            id: addModelMouse
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.providerSettings && selectedProviderId.length > 0
                                                    && newModelInput.text.length > 0) {
                                                    root.providerSettings.addModel(selectedProviderId, newModelInput.text)
                                                    newModelInput.text = ""
                                                    refreshModelItems()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        width: detailColumn.contentWidth
                        spacing: 8

                        Rectangle {
                            id: saveBtn
                            Layout.fillWidth: true
                            height: 32
                            radius: 4
                            color: saveBtnMouse.pressed ? root.theme.accentSoft : root.theme.accent
                            visible: isAddingProvider || (selectedProviderId.length > 0 && !isCurrentProviderPreset())

                            Text {
                                anchors.centerIn: parent
                                text: isAddingProvider ? qsTr("添加供应商") : qsTr("保存设置")
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: saveBtnMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.providerSettings) return
                                    if (isAddingProvider) {
                                        root.providerSettings.addProvider(
                                            nameInput.text,
                                            urlInput.text,
                                            keyInput.text,
                                            "openai"
                                        )
                                        root.isAddingProvider = false
                                        refreshProviderItems()
                                        if (root.providerItems.length > 0) {
                                            root.selectedProviderId = root.providerItems[root.providerItems.length - 1].id
                                        }
                                    } else {
                                        root.providerSettings.updateProvider(
                                            selectedProviderId,
                                            nameInput.text,
                                            urlInput.text,
                                            keyInput.text,
                                            "openai"
                                        )
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: useBtn
                            Layout.fillWidth: true
                            height: 32
                            radius: 4
                            enabled: modelItems.length > 0
                            color: !enabled ? root.theme.sidebarHover
                                   : (isCurrentActive() ? root.theme.accent + "18"
                                   : (useBtnMouse.pressed ? root.theme.sidebarActive : root.theme.sidebarHover))
                            visible: !isAddingProvider && selectedProviderId.length > 0

                            Text {
                                anchors.centerIn: parent
                                text: !enabled ? qsTr("请先添加模型")
                                      : (isCurrentActive() ? qsTr("当前供应商") : qsTr("切换为当前供应商"))
                                color: !enabled ? root.theme.textMuted
                                      : (isCurrentActive() ? root.theme.accent : root.theme.textPrimary)
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: useBtnMouse
                                anchors.fill: parent
                                enabled: parent.enabled
                                cursorShape: isCurrentActive() || !parent.enabled ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.providerSettings || isCurrentActive()) return
                                    root.providerSettings.setActiveProviderId(selectedProviderId)
                                    root.close()
                                }
                            }
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    visible: selectedProviderId.length === 0 && !isAddingProvider

                    Text {
                        text: "👈"
                        font.pixelSize: 28
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: qsTr("选择一个供应商或添加新的供应商")
                        color: root.theme.textMuted
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    function getCurrentProviderProp(prop) {
        if (!root.providerSettings || selectedProviderId.length === 0) return ""
        const list = root.providerSettings.providers()
        for (let i = 0; i < list.length; i++) {
            if (list[i].id === selectedProviderId) {
                return list[i][prop] || ""
            }
        }
        return ""
    }

    function isCurrentProviderPreset() {
        if (!root.providerSettings || selectedProviderId.length === 0) return true
        const list = root.providerSettings.providers()
        for (let i = 0; i < list.length; i++) {
            if (list[i].id === selectedProviderId) {
                return list[i].isPreset
            }
        }
        return true
    }

    function isCurrentActive() {
        if (!root.providerSettings || selectedProviderId.length === 0) return false
        return root.providerSettings.activeProviderId === selectedProviderId
    }

    function isCurrentActiveItem(pid) {
        if (!root.providerSettings) return false
        return root.providerSettings.activeProviderId === pid
    }

    Component.onCompleted: {
        var screen = root.screen
        if (screen) {
            root.x = screen.virtualX + (screen.width - root.width) / 2
            root.y = screen.virtualY + (screen.height - root.height) / 2
        }
        if (root.providerSettings) {
            root.selectedProviderId = root.providerSettings.activeProviderId
            refreshProviderItems()
            refreshModelItems()
        }
    }

    Connections {
        target: root.providerSettings

        function onProvidersChanged() {
            refreshProviderItems()
        }

        function onActiveProviderIdChanged() {
            refreshProviderItems()
            refreshModelItems()
        }

        function onActiveModelChanged() {
            refreshProviderItems()
        }
    }
}

