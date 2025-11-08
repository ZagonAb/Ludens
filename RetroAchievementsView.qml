import QtQuick 2.15
import QtGraphicalEffects 1.12

FocusScope {
    id: raView

    property var currentGame: null
    property int collectionIndex: 0
    property int currentRaIndex: 0
    property bool canShow: currentGame && currentGame.retroAchievementsCount > 0

    signal backRequested()

    visible: false

    width: parent.width * 0.4 - 20 * vpx
    height: parent.height - 23 * vpx

    property real targetY: parent.height

    y: targetY
    x: (300 - 20) * vpx

    Rectangle {
        id: raPanel
        anchors.fill: parent
        color: bgSecondary
        radius: 12 * vpx
        border.color: root.getHueColor(collectionIndex)
        border.width: 2 * vpx

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: -4
            radius: 12
            samples: 17
            color: "#80000000"
        }

        Rectangle {
            id: raHeader
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 80 * vpx
            color: root.getHueColor(collectionIndex)
            radius: 12 * vpx

            Row {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: 15 * vpx
                }
                spacing: 12 * vpx

                HexagonIcon {
                    width: 40 * vpx
                    height: 40 * vpx
                    color: "#ffffff"
                    iconSource: ""
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: achievementIcon
                        anchors.centerIn: parent
                        width: parent.width * 0.6
                        height: parent.height * 0.6
                        source: "assets/images/icons/achievement.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: achievementIcon
                        source: achievementIcon
                        color: root.getHueColor(collectionIndex)
                    }
                }

                Column {
                    spacing: 3 * vpx
                    anchors.verticalCenter: parent.verticalCenter
                    width: raPanel.width - 200 * vpx

                    Text {
                        text: "RETROACHIEVEMENTS"
                        font {
                            family: global.fonts.sans
                            pixelSize: 13 * vpx
                            bold: true
                            capitalization: Font.AllUppercase
                        }
                        color: "#ffffff"
                    }

                    Text {
                        width: parent.width
                        text: currentGame ? currentGame.title : ""
                        font {
                            family: global.fonts.sans
                            pixelSize: 12 * vpx
                        }
                        color: "#ffffff"
                        elide: Text.ElideRight
                    }

                    Item {
                        width: parent.width
                        height: 16 * vpx

                        Rectangle {
                            id: progressBarBackground
                            anchors {
                                left: parent.left
                                right: percentageText.left
                                rightMargin: 8 * vpx
                                verticalCenter: parent.verticalCenter
                            }
                            height: 6 * vpx
                            color: "#40000000"
                            radius: 3 * vpx
                        }

                        Rectangle {
                            id: progressBar
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            height: 6 * vpx
                            width: progressBarBackground.width * progressRatio
                            color: "#ffffff"
                            radius: 3 * vpx

                            property real progressRatio: {
                                if (!currentGame || currentGame.retroAchievementsCount === 0) return 0
                                    var total = currentGame.retroAchievementsCount
                                    var unlocked = 0
                                    for (var i = 0; i < total; i++) {
                                        if (currentGame.isRaUnlockedAt(i)) unlocked++
                                    }
                                    return unlocked / total
                            }
                        }

                        Text {
                            id: percentageText
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            text: {
                                if (!currentGame || currentGame.retroAchievementsCount === 0) return "0%"
                                    var total = currentGame.retroAchievementsCount
                                    var unlocked = 0
                                    for (var i = 0; i < total; i++) {
                                        if (currentGame.isRaUnlockedAt(i)) unlocked++
                                    }
                                    var percentage = Math.round((unlocked / total) * 100)
                                    return percentage + "%"
                            }

                            font {
                                family: global.fonts.sans
                                pixelSize: 10 * vpx
                                bold: true
                            }

                            color: "#ffffff"

                            layer.enabled: true
                            layer.effect: DropShadow {
                                transparentBorder: true
                                horizontalOffset: 1
                                verticalOffset: 1
                                radius: 2
                                samples: 5
                                color: "#80000000"
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 15 * vpx
                }
                width: 100 * vpx
                height: 35 * vpx
                color: "#ffffff"
                radius: 17 * vpx

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (!currentGame) return "0/0"
                            var total = currentGame.retroAchievementsCount
                            var unlocked = 0
                            for (var i = 0; i < total; i++) {
                                if (currentGame.isRaUnlockedAt(i)) unlocked++
                            }
                            return unlocked + "/" + total
                    }
                    font {
                        family: global.fonts.sans
                        pixelSize: 14 * vpx
                        bold: true
                    }
                    color: root.getHueColor(collectionIndex)
                }
            }
        }

        ListView {
            id: raListView

            anchors {
                top: raHeader.bottom
                left: parent.left
                right: parent.right
                bottom: raFooter.top
                margins: 10 * vpx
            }

            clip: true
            spacing: 6 * vpx

            model: {
                if (!currentGame || currentGame.retroAchievementsCount === 0) return []

                    var achievements = []
                    var total = currentGame.retroAchievementsCount

                    for (var i = 0; i < total; i++) {
                        if (currentGame.isRaUnlockedAt(i)) {
                            achievements.push({
                                index: i,
                                unlocked: true,
                                hardcore: currentGame.isRaHardcoreAt(i),
                                              title: currentGame.GetRaTitleAt(i),
                                              description: currentGame.GetRaDescriptionAt(i),
                                              author: currentGame.GetRaAuthorAt(i),
                                              points: currentGame.GetRaPointsAt(i),
                                              badgeId: currentGame.GetRaBadgeAt(i)
                            })
                        }
                    }

                    for (var j = 0; j < total; j++) {
                        if (!currentGame.isRaUnlockedAt(j)) {
                            achievements.push({
                                index: j,
                                unlocked: false,
                                hardcore: currentGame.isRaHardcoreAt(j),
                                              title: currentGame.GetRaTitleAt(j),
                                              description: currentGame.GetRaDescriptionAt(j),
                                              author: currentGame.GetRaAuthorAt(j),
                                              points: currentGame.GetRaPointsAt(j),
                                              badgeId: currentGame.GetRaBadgeAt(j)
                            })
                        }
                    }

                    return achievements
            }

            delegate: Rectangle {
                width: raListView.width
                height: 70 * vpx
                color: raListView.currentIndex === index ?
                Qt.lighter(root.getHueColor(collectionIndex), 1.3) :
                (index % 2 === 0 ? "#2a2a2a" : "#333333")
                radius: 6 * vpx

                property bool isUnlocked: modelData.unlocked
                property bool isHardcore: modelData.hardcore

                Row {
                    anchors {
                        fill: parent
                        margins: 8 * vpx
                    }
                    spacing: 10 * vpx

                    Item {
                        width: 54 * vpx
                        height: 54 * vpx
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.fill: parent
                            color: isUnlocked ? root.getHueColor(collectionIndex) : "#555555"
                            radius: 6 * vpx

                            Image {
                                id: achievementBadge
                                anchors.fill: parent
                                anchors.margins: 4 * vpx
                                source: {
                                    var badgeId = modelData.badgeId
                                    if (badgeId && badgeId !== "") {
                                        if (isUnlocked)
                                            return "https://s3-eu-west-1.amazonaws.com/i.retroachievements.org/Badge/" + badgeId + ".png"
                                            else
                                                return "https://s3-eu-west-1.amazonaws.com/i.retroachievements.org/Badge/" + badgeId + "_lock.png"
                                    }
                                    return "assets/images/icons/achievement.png"
                                }
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                asynchronous: true
                                mipmap: true

                                onStatusChanged: {
                                    if (status === Image.Error) {
                                        source = "assets/images/icons/achievement.png"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors {
                                top: parent.top
                                right: parent.right
                                topMargin: -2 * vpx
                                rightMargin: -2 * vpx
                            }
                            width: 16 * vpx
                            height: 16 * vpx
                            radius: 8 * vpx
                            color: "#FF9800"
                            visible: isHardcore

                            Text {
                                anchors.centerIn: parent
                                text: "H"
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 9 * vpx
                                    bold: true
                                }
                                color: "#000000"
                            }
                        }
                    }

                    Column {
                        width: parent.width - 54 * vpx - parent.spacing - 60 * vpx
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3 * vpx

                        Text {
                            width: parent.width
                            text: modelData.title
                            font {
                                family: global.fonts.sans
                                pixelSize: 12 * vpx
                                bold: true
                            }
                            color: isUnlocked ? "#ffffff" : "#888888"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: modelData.description
                            font {
                                family: global.fonts.sans
                                pixelSize: 12 * vpx
                                bold: true
                            }
                            color: isUnlocked ? "white" : "#666666"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            layer.enabled: true
                            layer.effect: DropShadow {
                                transparentBorder: true
                                horizontalOffset: 1
                                verticalOffset: 1
                                radius: 2
                                samples: 5
                                color: "#CC000000"
                            }
                        }

                        Text {
                            text: "By: " + modelData.author
                            font {
                                family: global.fonts.sans
                                pixelSize: 9 * vpx
                            }
                            color: "#888888"
                            visible: isUnlocked
                        }
                    }

                    Rectangle {
                        width: 55 * vpx
                        height: 26 * vpx
                        anchors.verticalCenter: parent.verticalCenter
                        color: isUnlocked ? "#4CAF50" : "#555555"
                        radius: 13 * vpx

                        Text {
                            anchors.centerIn: parent
                            text: modelData.points + " pts"
                            font {
                                family: global.fonts.sans
                                pixelSize: 10 * vpx
                                bold: true
                            }
                            color: "#ffffff"
                        }
                    }
                }
            }

            highlight: Rectangle {
                color: Qt.lighter(root.getHueColor(collectionIndex), 1.5)
                radius: 6 * vpx
            }
            highlightMoveDuration: 200
        }

        Rectangle {
            id: raFooter
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 40 * vpx
            color: "transparent"

            Row {
                anchors.centerIn: parent
                spacing: 30 * vpx

                Text {
                    text: "↑↓ Navigate  •  B Back"
                    font {
                        family: global.fonts.sans
                        pixelSize: 11 * vpx
                    }
                    color: textSecondary
                }
            }
        }
    }

    PropertyAnimation {
        id: showAnimation
        target: raView
        property: "targetY"
        duration: 400
        easing.type: Easing.OutCubic
    }

    PropertyAnimation {
        id: hideAnimation
        target: raView
        property: "targetY"
        duration: 350
        easing.type: Easing.InCubic
        onFinished: raView.visible = false
    }

    Keys.onPressed: {
        if (api.keys.isCancel(event)) {
            event.accepted = true
            soundManager.playCancel()
            hide()
        } else if (api.keys.isUp(event)) {
            event.accepted = true
            soundManager.playUp()
            if (raListView.currentIndex > 0) {
                raListView.currentIndex--
            }
        } else if (api.keys.isDown(event)) {
            event.accepted = true
            soundManager.playDown()
            if (raListView.currentIndex < raListView.count - 1) {
                raListView.currentIndex++
            }
        }
    }

    function show() {
        if (!canShow) {
            //console.log("Cannot show RA View: No achievements available for", currentGame ? currentGame.title : "unknown game")
            return
        }

        visible = true
        focus = true
        var startY = raView.parent.height
        var endY = 20 * vpx
        targetY = startY
        showAnimation.from = startY
        showAnimation.to = endY
        showAnimation.start()

        raListView.currentIndex = 0
    }

    function hide() {
        var startY = 20 * vpx
        var endY = raView.parent.height

        hideAnimation.from = startY
        hideAnimation.to = endY
        hideAnimation.start()

        focus = false
        backRequested()
    }

    function updateGame(game) {
        currentGame = game

        if (game && typeof game.updateRetroAchievements === 'function' && shouldForceUpdate(game)) {
            game.updateRetroAchievements()
        }

        if (game && game.retroAchievementsCount > 0) {
            //console.log("RA View: Loaded", game.retroAchievementsCount, "achievements for", game.title)
            raListView.model = createSortedModel()
        } else {
            //console.log("RA View: No achievements available for", game ? game.title : "unknown game")
            raListView.model = []
        }
    }

    function shouldForceUpdate(game) {
        var gameKey = game.title + "_" + (game.RaGameId || "0")
        var cachedData = gameList.raCache[gameKey]

        if (!cachedData) return true

            var tenMinutes = 10 * 60 * 1000
            var now = new Date().getTime()

            return (now - cachedData.timestamp) > tenMinutes
    }

    function createSortedModel() {
        if (!currentGame || currentGame.retroAchievementsCount === 0) return []

            var achievements = []
            var total = currentGame.retroAchievementsCount

            for (var i = 0; i < total; i++) {
                if (currentGame.isRaUnlockedAt(i)) {
                    achievements.push({
                        originalIndex: i,
                        unlocked: true,
                        hardcore: currentGame.isRaHardcoreAt(i),
                                      title: currentGame.GetRaTitleAt(i),
                                      description: currentGame.GetRaDescriptionAt(i),
                                      author: currentGame.GetRaAuthorAt(i),
                                      points: currentGame.GetRaPointsAt(i),
                                      badgeId: currentGame.GetRaBadgeAt(i)
                    })
                }
            }

            for (var j = 0; j < total; j++) {
                if (!currentGame.isRaUnlockedAt(j)) {
                    achievements.push({
                        originalIndex: j,
                        unlocked: false,
                        hardcore: currentGame.isRaHardcoreAt(j),
                                      title: currentGame.GetRaTitleAt(j),
                                      description: currentGame.GetRaDescriptionAt(j),
                                      author: currentGame.GetRaAuthorAt(j),
                                      points: currentGame.GetRaPointsAt(j),
                                      badgeId: currentGame.GetRaBadgeAt(j)
                    })
                }
            }

            return achievements
    }
}
