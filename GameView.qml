import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

FocusScope {
    id: gameRoot

    property var collection
    property int collectionIndex: 0
    property bool currentRALoading: false
    property bool currentRAAvailable: false
    property bool panelsBlurred: false

    function applyBlurEffects(shouldBlur) {
        panelsBlurred = shouldBlur;
    }

    signal backRequested()

    Connections {
        target: gameRoot
        function onCurrentRALoadingChanged() {
            bottomBar.updateRAStatus(gameRoot.currentRALoading, gameRoot.currentRAAvailable)
        }
        function onCurrentRAAvailableChanged() {
            bottomBar.updateRAStatus(gameRoot.currentRALoading, gameRoot.currentRAAvailable)
        }
    }

    onVisibleChanged: {
        if (!visible) {
            currentRALoading = false
            currentRAAvailable = false
            bottomBar.resetRAStatus()
            applyBlurEffects(false);
        } else if (gameList.currentGame) {
            bottomBar.updateRAStatus(currentRALoading, currentRAAvailable)
        }
    }

    Rectangle {
        id: leftPanel

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width: 280 * vpx
        color: bgSecondary

        opacity: gameRoot.panelsBlurred ? 0.4 : 1.0
        scale: gameRoot.panelsBlurred ? 0.95 : 1.0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        layer.enabled: gameRoot.panelsBlurred
        layer.effect: FastBlur {
            radius: 32
            transparentBorder: true
        }

        StatusBar {
            id: gameViewStatusBar
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 10 * vpx
            }
            width: parent.width * 0.9
            height: 40 * vpx
            scale: 0.8
        }

        HexagonIcon {
            id: hexIcon
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            size: hexSize
            color: root.getHueColor(collectionIndex)

            Image {
                anchors.centerIn: parent
                width: parent.width * 0.5
                height: parent.height * 0.5
                source: getSystemImage()
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true

                onStatusChanged: {
                    if (status === Image.Error) {
                        source = "assets/images/PIXL-OS/icon_0.png"
                    }
                }
            }
        }

        Column {
            anchors {
                top: hexIcon.bottom
                topMargin: 30 * vpx
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 15 * vpx
            width: leftPanel.width - 40 * vpx

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width

                text: collection ? collection.name : ""
                font {
                    family: global.fonts.sans
                    pixelSize: 25 * vpx
                }
                color: root.getHueColor(collectionIndex)
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: collection ? collection.games.count + " Games" : ""
                font {
                    family: global.fonts.sans
                    pixelSize: 20 * vpx
                }
                color: root.getHueColor(collectionIndex)
                horizontalAlignment: Text.AlignHCenter
            }
        }

        FavoriteNotification {
            id: favoriteNotification
            collectionIndex: gameRoot.collectionIndex
        }
    }

    GameList {
        id: gameList
        anchors {
            left: leftPanel.right
            top: parent.top
            bottom: parent.bottom
            margins: 20 * vpx
        }
        width: parent.width * 0.4 - 40 * vpx

        model: collection ? collection.games : null
        focus: true
        collectionIndex: gameRoot.collectionIndex

        opacity: gameRoot.panelsBlurred ? 0.4 : 1.0
        scale: gameRoot.panelsBlurred ? 0.95 : 1.0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        layer.enabled: gameRoot.panelsBlurred
        layer.effect: FastBlur {
            radius: 32
            transparentBorder: true
        }

        property string currentCollectionShortName: collection ? collection.shortName : ""

        Keys.onPressed: {
            if (api.keys.isCancel(event)) {
                event.accepted = true
                soundManager.playCancel()
                backRequested()
            } else if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                event.accepted = true
                soundManager.playOk()
                launchGame()
            }
            else if (api.keys.isDetails(event)) {
                event.accepted = true
                toggleFavorite()
            }
            else if (api.keys.isFilters(event)) {
                event.accepted = true

                if (currentGame && currentRAAvailable) {
                    soundManager.playOk()

                    if (shouldUpdateRA()) {
                        if (typeof currentGame.updateRetroAchievements === 'function') {
                            currentGame.updateRetroAchievements()
                        }
                    }

                    retroAchievementsView.updateGame(currentGame)
                    retroAchievementsView.show()

                    gameRoot.applyBlurEffects(true);
                } else if (currentGame) {
                    soundManager.playNoticeBack()
                } else {
                    soundManager.playCancel()
                }
            }
            else {
                event.accepted = false
            }
        }

        Keys.onUpPressed: {
            event.accepted = true
            soundManager.playUp()
            if (currentIndex > 0) {
                currentIndex--
            } else {
                currentIndex = count - 1
            }
        }

        Keys.onDownPressed: {
            event.accepted = true
            soundManager.playDown()
            if (currentIndex < count - 1) {
                currentIndex++
            } else {
                currentIndex = 0
            }
        }

        function toggleFavorite() {
            if (currentGame) {
                var wasFavorite = currentGame.favorite
                currentGame.favorite = !currentGame.favorite
                //console.log("Game favorite status toggled:", currentGame.title, "Favorite:", currentGame.favorite)
                currentIndexChanged()
                if (currentGame.favorite) {
                    soundManager.playNotice()
                } else {
                    soundManager.playNoticeBack()
                }

                favoriteNotification.show(currentGame.favorite, Utils.cleanGameTitle(currentGame.title))
            }
        }

        function shouldUpdateRA() {
            if (!currentGame) return false

                var gameKey = currentGame.title + "_" + (currentGame.RaGameId || "0")
                var cachedData = gameList.raCache[gameKey]

                if (!cachedData) return true

                    var fiveMinutes = 5 * 60 * 1000
                    var now = new Date().getTime()

                    return (now - cachedData.timestamp) > fiveMinutes
        }
    }

    Rectangle {
        id: rightPanel

        anchors {
            left: gameList.right
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        color: root.getHueColor(collectionIndex)

        opacity: gameRoot.panelsBlurred ? 0.4 : 1.0
        scale: gameRoot.panelsBlurred ? 0.95 : 1.0

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        layer.enabled: gameRoot.panelsBlurred
        layer.effect: FastBlur {
            radius: 32
            transparentBorder: true
        }

        GameDetails {
            anchors.fill: parent
            game: gameList.currentGame
            collectionIndex: gameRoot.collectionIndex
        }
    }

    RetroAchievementsView {
        id: retroAchievementsView
        z: 100

        parent: gameRoot
        collectionIndex: gameRoot.collectionIndex

        onBackRequested: {
            gameList.focus = true
            gameRoot.applyBlurEffects(false);
        }

        onVisibleChanged: {
            if (!visible) {
                gameRoot.applyBlurEffects(false);
            }
        }
    }

    function getSystemImage() {
        if (!collection) return ""
            var shortName = collection.shortName.toLowerCase()
            return "assets/images/systems/" + shortName + ".png"
    }

    function launchGame() {
        if (gameList.currentGame) {
            //console.log("Launching game:", gameList.currentGame.title)

            api.memory.set('lastGameIndex', gameList.currentIndex)
            api.memory.set('lastCollectionIndex', collectionIndex)

            gameList.focus = false
            gameList.enabled = false

            gameList.currentGame.launch()
            restoreTimer.start()
        }
    }

    Timer {
        id: restoreTimer
        interval: 100
        repeat: false
        onTriggered: {
            //console.log("Restoring focus after game exit")
            gameList.enabled = true
            gameList.focus = true

            var lastIndex = api.memory.get('lastGameIndex')
            if (lastIndex !== undefined && lastIndex >= 0 && lastIndex < gameList.count) {
                gameList.currentIndex = lastIndex
                gameList.positionViewAtIndex(lastIndex, ListView.Center)
            }
        }
    }
}
