import QtQuick 2.15
import QtGraphicalEffects 1.12

FocusScope {
    id: configPanel

    property bool panelVisible: true
    property int currentIndex: 0
    property var collectionListView: null

    width: 400 * vpx
    height: 100 * vpx

    visible: panelVisible

    Row {
        id: slidersRow
        anchors.centerIn: parent
        spacing: 10 * vpx

        CircularSlider {
            id: saturationSlider
            value: root.hueSaturation
            label: "Saturation"
            progressColor: "#ffffff"
            baseColor: root.getHueColor(0)
            width: 80 * vpx
            height: 140 * vpx
            isSelected: configPanel.focus && configPanel.currentIndex === 0

            onValueChanged: {
                root.hueSaturation = value
            }

            Connections {
                target: root
                onHueSaturationChanged: {
                    saturationSlider.value = root.hueSaturation
                }
            }
        }

        CircularSlider {
            id: lightnessSlider
            value: root.hueLightness
            label: "Lightness"
            progressColor: "#ffffff"
            baseColor: root.getHueColor(0)
            width: 80 * vpx
            height: 140 * vpx
            isSelected: configPanel.focus && configPanel.currentIndex === 1

            onValueChanged: {
                root.hueLightness = value
            }

            Connections {
                target: root
                onHueLightnessChanged: {
                    lightnessSlider.value = root.hueLightness
                }
            }
        }

        Item {
            id: resetButton
            width: 80 * vpx
            height: 140 * vpx

            property bool isSelected: configPanel.focus && configPanel.currentIndex === 2
            property bool isPressed: false

            Item {
                id: resetHexagonContainer
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                width: 75 * vpx
                height: 75 * vpx

                HexagonIcon {
                    id: resetHexagon
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    color: root.getHueColor(collectionIndex)
                    radiusHex: 0.15

                    scale: resetButton.isPressed ? 0.9 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
            }

            Item {
                id: resetSelectionContainer
                anchors.centerIn: resetHexagonContainer
                width: 83 * vpx
                height: 83 * vpx

                Canvas {
                    id: resetSelectionCanvas
                    anchors.fill: parent
                    visible: resetButton.isSelected

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var w = width
                        var h = height
                        var cx = w / 2
                        var cy = h / 2
                        var radius = Math.min(w, h) / 2 - 2 * vpx
                        var cornerRadius = radius * 0.15
                        ctx.beginPath()
                        ctx.lineWidth = 2 * vpx
                        ctx.strokeStyle = root.isLightTheme ? "#000000" : "#ffffff"
                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"
                        var vertices = []
                        for (var i = 0; i < 6; i++) {
                            var angle = (Math.PI / 3) * i - Math.PI / 6 + Math.PI / 2
                            vertices.push({
                                x: cx + radius * Math.cos(angle),
                                          y: cy + radius * Math.sin(angle)
                            })
                        }

                        for (var j = 0; j < 6; j++) {
                            var current = vertices[j]
                            var next = vertices[(j + 1) % 6]
                            var prev = vertices[(j + 5) % 6]
                            var dx1 = current.x - prev.x
                            var dy1 = current.y - prev.y
                            var len1 = Math.sqrt(dx1 * dx1 + dy1 * dy1)
                            var dx2 = next.x - current.x
                            var dy2 = next.y - current.y
                            var len2 = Math.sqrt(dx2 * dx2 + dy2 * dy2)
                            var startX = current.x - (dx1 / len1) * cornerRadius
                            var startY = current.y - (dy1 / len1) * cornerRadius
                            var endX = current.x + (dx2 / len2) * cornerRadius
                            var endY = current.y + (dy2 / len2) * cornerRadius

                            if (j === 0) {
                                ctx.moveTo(startX, startY)
                            }

                            ctx.quadraticCurveTo(current.x, current.y, endX, endY)

                            if (j < 5) {
                                var nextVertex = vertices[j + 1]
                                var dxNext = nextVertex.x - current.x
                                var dyNext = nextVertex.y - current.y
                                var lenNext = Math.sqrt(dxNext * dxNext + dyNext * dyNext)
                                var nextStartX = nextVertex.x - (dxNext / lenNext) * cornerRadius
                                var nextStartY = nextVertex.y - (dyNext / lenNext) * cornerRadius
                                ctx.lineTo(nextStartX, nextStartY)
                            }
                        }

                        ctx.closePath()
                        ctx.stroke()
                    }
                }
            }

            Item {
                id: resetIcon
                anchors.centerIn: resetHexagonContainer
                width: 50 * vpx
                height: 50 * vpx
                scale: resetButton.isPressed ? 0.9 : 1.0

                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Image {
                    id: resetImage
                    anchors.fill: parent
                    source: "assets/images/icons/reset.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    visible: true
                }
            }

            Text {
                id: resetLabelText
                anchors {
                    top: resetHexagonContainer.bottom
                    topMargin: resetButton.isSelected ? 15 * vpx : -20 * vpx
                    horizontalCenter: parent.horizontalCenter
                }
                text: "Reset"
                font {
                    family: global.fonts.sans
                    pixelSize: 12 * vpx
                }
                color: resetButton.isSelected ? (root.isLightTheme ? "#000000" : "#ffffff") : textSecondary
                opacity: resetButton.isSelected ? 1.0 : 0.0

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1
                    verticalOffset: 1
                    radius: 2
                    samples: 5
                    color: "#80000000"
                }

                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            MouseArea {
                anchors.fill: resetHexagonContainer
                onClicked: {
                    resetButton.animateResetButton()
                    root.hueSaturation = 0.8
                    root.hueLightness = 0.59
                }
            }

            function animateResetButton() {
                isPressed = true
                resetTimer.start()
            }

            Timer {
                id: resetTimer
                interval: 150
                onTriggered: {
                    resetButton.isPressed = false
                }
            }

            onIsSelectedChanged: {
                if (isSelected) {
                    resetSelectionCanvas.requestPaint()
                }
            }

            Connections {
                target: root
                function onIsLightThemeChanged() {
                    if (isSelected) {
                        resetSelectionCanvas.requestPaint()
                    }
                }
            }
        }

        Item {
            id: themeButton
            width: 80 * vpx
            height: 140 * vpx

            property bool isSelected: configPanel.focus && configPanel.currentIndex === 3
            property bool isPressed: false
            property bool isLightTheme: root.isLightTheme

            Item {
                id: themeHexagonContainer
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                width: 75 * vpx
                height: 75 * vpx

                HexagonIcon {
                    id: themeHexagon
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    color: root.getHueColor(collectionIndex)
                    radiusHex: 0.15

                    scale: themeButton.isPressed ? 0.9 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
            }

            Item {
                id: themeSelectionContainer
                anchors.centerIn: themeHexagonContainer
                width: 83 * vpx
                height: 83 * vpx

                Canvas {
                    id: themeSelectionCanvas
                    anchors.fill: parent
                    visible: themeButton.isSelected

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var w = width
                        var h = height
                        var cx = w / 2
                        var cy = h / 2
                        var radius = Math.min(w, h) / 2 - 2 * vpx
                        var cornerRadius = radius * 0.15
                        ctx.beginPath()
                        ctx.lineWidth = 2 * vpx
                        ctx.strokeStyle = root.isLightTheme ? "#000000" : "#ffffff"
                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"
                        var vertices = []
                        for (var i = 0; i < 6; i++) {
                            var angle = (Math.PI / 3) * i - Math.PI / 6 + Math.PI / 2
                            vertices.push({
                                x: cx + radius * Math.cos(angle),
                                          y: cy + radius * Math.sin(angle)
                            })
                        }

                        for (var j = 0; j < 6; j++) {
                            var current = vertices[j]
                            var next = vertices[(j + 1) % 6]
                            var prev = vertices[(j + 5) % 6]
                            var dx1 = current.x - prev.x
                            var dy1 = current.y - prev.y
                            var len1 = Math.sqrt(dx1 * dx1 + dy1 * dy1)
                            var dx2 = next.x - current.x
                            var dy2 = next.y - current.y
                            var len2 = Math.sqrt(dx2 * dx2 + dy2 * dy2)
                            var startX = current.x - (dx1 / len1) * cornerRadius
                            var startY = current.y - (dy1 / len1) * cornerRadius
                            var endX = current.x + (dx2 / len2) * cornerRadius
                            var endY = current.y + (dy2 / len2) * cornerRadius

                            if (j === 0) {
                                ctx.moveTo(startX, startY)
                            }

                            ctx.quadraticCurveTo(current.x, current.y, endX, endY)

                            if (j < 5) {
                                var nextVertex = vertices[j + 1]
                                var dxNext = nextVertex.x - current.x
                                var dyNext = nextVertex.y - current.y
                                var lenNext = Math.sqrt(dxNext * dxNext + dyNext * dyNext)
                                var nextStartX = nextVertex.x - (dxNext / lenNext) * cornerRadius
                                var nextStartY = nextVertex.y - (dyNext / lenNext) * cornerRadius
                                ctx.lineTo(nextStartX, nextStartY)
                            }
                        }

                        ctx.closePath()
                        ctx.stroke()
                    }
                }
            }

            Item {
                id: themeIcon
                anchors.centerIn: themeHexagonContainer
                width: 40 * vpx
                height: 40 * vpx
                scale: themeButton.isPressed ? 0.9 : 1.0

                Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                Image {
                    id: themeImage
                    anchors.fill: parent
                    source: themeButton.isLightTheme ? "assets/images/icons/light.svg" : "assets/images/icons/night.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    visible: true
                }
            }

            Text {
                id: themeLabelText
                anchors {
                    top: themeHexagonContainer.bottom
                    topMargin: themeButton.isSelected ? 15 * vpx : -20 * vpx
                    horizontalCenter: parent.horizontalCenter
                }
                text: themeButton.isLightTheme ? "Light" : "Dark"
                font {
                    family: global.fonts.sans
                    pixelSize: 12 * vpx
                }

                color: themeButton.isSelected ? (root.isLightTheme ? "#000000" : "#ffffff") : textSecondary
                opacity: themeButton.isSelected ? 1.0 : 0.0

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1
                    verticalOffset: 1
                    radius: 2
                    samples: 5
                    color: "#80000000"
                }

                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            MouseArea {
                anchors.fill: themeHexagonContainer
                onClicked: {
                    themeButton.animateThemeButton()
                    themeButton.toggleTheme()
                }
            }

            function animateThemeButton() {
                isPressed = true
                themeTimer.start()
            }

            function toggleTheme() {
                root.toggleThemeMode(!root.isLightTheme)
                isLightTheme = root.isLightTheme
                themeImage.source = isLightTheme ? "assets/images/icons/light.svg" : "assets/images/icons/night.svg"

                if (isSelected) {
                    themeSelectionCanvas.requestPaint()
                }
            }

            Timer {
                id: themeTimer
                interval: 150
                onTriggered: {
                    themeButton.isPressed = false
                }
            }

            onIsSelectedChanged: {
                if (isSelected) {
                    themeSelectionCanvas.requestPaint()
                }
            }

            Connections {
                target: root
                function onIsLightThemeChanged() {
                    themeButton.isLightTheme = root.isLightTheme
                    themeImage.source = themeButton.isLightTheme ? "assets/images/icons/light.svg" : "assets/images/icons/night.svg"
                    themeLabelText.text = themeButton.isLightTheme ? "Light" : "Dark"
                    if (isSelected) {
                        themeSelectionCanvas.requestPaint()
                    }
                }
            }

            Component.onCompleted: {
                themeButton.isLightTheme = root.isLightTheme
                themeImage.source = themeButton.isLightTheme ? "assets/images/icons/light.svg" : "assets/images/icons/night.svg"
                themeLabelText.text = themeButton.isLightTheme ? "Light" : "Dark"
            }
        }
    }

    Keys.onPressed: {
        if (api.keys.isCancel(event)) {
            event.accepted = true
            focus = false
            if (collectionListView) {
                collectionListView.focus = true
            }
        } else if (api.keys.isLeft(event)) {
            event.accepted = true
            if (currentIndex > 0) {
                currentIndex--
            } else {
                currentIndex = 3
            }
        } else if (api.keys.isRight(event)) {
            event.accepted = true
            if (currentIndex < 3) {
                currentIndex++
            } else {
                currentIndex = 0
            }
        } else if (api.keys.isUp(event)) {
            event.accepted = true
            adjustValue(0.05)
        } else if (api.keys.isDown(event)) {
            event.accepted = true
            adjustValue(-0.05)
        } else if (api.keys.isAccept(event)) {
            event.accepted = true
            if (currentIndex === 2) {
                resetButton.animateResetButton()
                root.hueSaturation = 0.8
                root.hueLightness = 0.59
            } else if (currentIndex === 3) {
                themeButton.animateThemeButton()
                themeButton.toggleTheme()
            }
        }
    }

    function adjustValue(amount) {
        if (currentIndex === 0) {
            var newSaturation = root.hueSaturation + amount
            root.hueSaturation = Math.max(0.0, Math.min(1.0, newSaturation))
        } else if (currentIndex === 1) {
            var newLightness = root.hueLightness + amount
            root.hueLightness = Math.max(0.0, Math.min(1.0, newLightness))
        }
    }

    onFocusChanged: {
        saturationSlider.isSelected = focus && currentIndex === 0
        lightnessSlider.isSelected = focus && currentIndex === 1
        resetButton.isSelected = focus && currentIndex === 2
        themeButton.isSelected = focus && currentIndex === 3

        if (focus) {
            if (currentIndex === 0) saturationSlider.selectionCanvas.requestPaint()
                else if (currentIndex === 1) lightnessSlider.selectionCanvas.requestPaint()
                    else if (currentIndex === 2) resetButton.resetSelectionCanvas.requestPaint()
                        else if (currentIndex === 3) themeButton.themeSelectionCanvas.requestPaint()
        }
    }

    onCurrentIndexChanged: {
        saturationSlider.isSelected = focus && currentIndex === 0
        lightnessSlider.isSelected = focus && currentIndex === 1
        resetButton.isSelected = focus && currentIndex === 2
        themeButton.isSelected = focus && currentIndex === 3

        if (focus) {
            if (currentIndex === 0) saturationSlider.selectionCanvas.requestPaint()
                else if (currentIndex === 1) lightnessSlider.selectionCanvas.requestPaint()
                    else if (currentIndex === 2) resetButton.resetSelectionCanvas.requestPaint()
                        else if (currentIndex === 3) themeButton.themeSelectionCanvas.requestPaint()
        }
    }

    Connections {
        target: root
        function onIsLightThemeChanged() {
            if (saturationSlider.isSelected) saturationSlider.selectionCanvas.requestPaint()
                if (lightnessSlider.isSelected) lightnessSlider.selectionCanvas.requestPaint()
                    if (resetButton.isSelected) resetButton.resetSelectionCanvas.requestPaint()
                        if (themeButton.isSelected) themeButton.themeSelectionCanvas.requestPaint()
        }
    }
}
