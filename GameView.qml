import QtQuick 2.15
import "utils.js" as Utils

FocusScope {
    id: gameRoot

    property var collection
    property int collectionIndex: 0
    signal backRequested()

    Rectangle {
        id: leftPanel
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: 280 * vpx
        color: bgSecondary

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
                        source = "assets/images/icon.png"
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
                    pixelSize: 20 * vpx
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
                    pixelSize: 16 * vpx
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

    Rectangle {
        id: rightPanel
        anchors {
            left: gameList.right
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        color: root.getHueColor(collectionIndex)

        GameDetails {
            anchors.fill: parent
            game: gameList.currentGame
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

        Keys.onPressed: {
            if (api.keys.isCancel(event)) {
                event.accepted = true
                backRequested()
            } else if (api.keys.isAccept(event)) {
                event.accepted = true
                launchGame()
            }
            else if (api.keys.isDetails(event)) {
                event.accepted = true
                toggleFavorite()
            }
            else {
                event.accepted = false
            }
        }
        function toggleFavorite() {
            if (currentGame) {
                var wasFavorite = currentGame.favorite
                currentGame.favorite = !currentGame.favorite
                console.log("Game favorite status toggled:", currentGame.title, "Favorite:", currentGame.favorite)
                currentIndexChanged()
                favoriteNotification.show(currentGame.favorite, Utils.cleanGameTitle(currentGame.title))
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
            gameList.currentGame.launch()
        }
    }
}
