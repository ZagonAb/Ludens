import QtQuick 2.15
import QtGraphicalEffects 1.12
import "qrc:/qmlutils" as PegasusUtils
import "utils.js" as Utils

Item {
    id: details

    property var game
    property int collectionIndex: 0
    property bool hasPlayStats: game && (game.playCount > 0 || game.playTime > 0 || (game.lastPlayed && !isNaN(game.lastPlayed.getTime())))

    Rectangle {
        id: screenshotArea
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: parent.height * 0.4
        color: root.getHueColor(collectionIndex)

        Image {
            anchors.fill: parent
            source: game ? (game.assets.screenshot ||
            game.assets.titlescreen ||
            game.assets.boxFront || "") : ""
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 60 * vpx
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop {
                    position: 1.0;
                    color: Qt.darker(root.getHueColor(collectionIndex), 2.0)
                }
            }
        }
    }

    Flickable {
        id: infoFlick
        anchors {
            left: parent.left
            right: parent.right
            top: screenshotArea.bottom
            bottom: parent.bottom
            margins: 20 * vpx
        }

        contentHeight: infoColumn.height
        clip: true

        Column {
            id: infoColumn
            width: parent.width
            spacing: 5 * vpx

            Text {
                id: tiTle
                width: parent.width
                text: Utils.cleanGameTitle(game.title)
                font {
                    family: global.fonts.sans
                    pixelSize: 24 * vpx
                    bold: true
                }
                color: "white"
                wrapMode: Text.WordWrap

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1
                    verticalOffset: 1
                    radius: 4
                    samples: 10
                    color: "#CC000000"
                }
            }

            Column {
                width: parent.width
                spacing: 12 * vpx

                Rectangle {
                    width: parent.width
                    height: devPubRow.height + 20 * vpx
                    radius: 8 * vpx
                    color: "#66000000"
                    visible: (game && game.developer) || (game && game.publisher) || (game && game.releaseYear) || (game && game.genre)

                    Row {
                        id: devPubRow
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: 12 * vpx
                        }
                        spacing: 20 * vpx

                        Column {
                            width: (parent.width - parent.spacing * 3) / 4
                            spacing: 6 * vpx
                            visible: game && game.developer

                            Row {
                                width: parent.width
                                spacing: 8 * vpx

                                Rectangle {
                                    width: 4 * vpx
                                    height: devContentColumn.height
                                    color: root.getHueColor(collectionIndex)
                                    radius: 2 * vpx
                                }

                                Column {
                                    id: devContentColumn
                                    width: parent.width - 12 * vpx
                                    spacing: 2 * vpx

                                    Text {
                                        text: "Developer"
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 11 * vpx
                                            bold: true
                                            capitalization: Font.AllUppercase
                                        }
                                        color: "#a1a1a1"
                                    }

                                    Text {
                                        width: parent.width
                                        text: game ? game.developer : ""
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 14 * vpx
                                        }
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }

                        Column {
                            width: (parent.width - parent.spacing * 3) / 4
                            spacing: 6 * vpx
                            visible: game && game.publisher

                            Row {
                                width: parent.width
                                spacing: 8 * vpx

                                Rectangle {
                                    width: 4 * vpx
                                    height: pubContentColumn.height
                                    color: root.getHueColor(collectionIndex)
                                    radius: 2 * vpx
                                }

                                Column {
                                    id: pubContentColumn
                                    width: parent.width - 12 * vpx
                                    spacing: 2 * vpx

                                    Text {
                                        text: "Publisher"
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 11 * vpx
                                            bold: true
                                            capitalization: Font.AllUppercase
                                        }
                                        color: "#a1a1a1"
                                    }

                                    Text {
                                        width: parent.width
                                        text: game ? game.publisher : ""
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 14 * vpx
                                        }
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }

                        Column {
                            width: (parent.width - parent.spacing * 3) / 4
                            spacing: 6 * vpx
                            visible: game && game.releaseYear > 0

                            Row {
                                width: parent.width
                                spacing: 8 * vpx

                                Rectangle {
                                    width: 4 * vpx
                                    height: releaseContentColumn.height
                                    color: root.getHueColor(collectionIndex)
                                    radius: 2 * vpx
                                }

                                Column {
                                    id: releaseContentColumn
                                    width: parent.width - 12 * vpx
                                    spacing: 2 * vpx

                                    Text {
                                        text: "Release"
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 11 * vpx
                                            bold: true
                                            capitalization: Font.AllUppercase
                                        }
                                        color: "#a1a1a1"
                                    }

                                    Text {
                                        width: parent.width
                                        text: game && game.releaseYear > 0 ? game.releaseYear : ""
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 14 * vpx
                                        }
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }

                        Column {
                            width: (parent.width - parent.spacing * 3) / 4
                            spacing: 6 * vpx
                            visible: game && game.genre

                            Row {
                                width: parent.width
                                spacing: 8 * vpx

                                Rectangle {
                                    width: 4 * vpx
                                    height: genreContentColumn.height
                                    color: root.getHueColor(collectionIndex)
                                    radius: 2 * vpx
                                }

                                Column {
                                    id: genreContentColumn
                                    width: parent.width - 12 * vpx
                                    spacing: 2 * vpx

                                    Text {
                                        text: "Genre"
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 11 * vpx
                                            bold: true
                                            capitalization: Font.AllUppercase
                                        }
                                        color: "#a1a1a1"
                                    }

                                    Text {
                                        width: parent.width
                                        text: game ? Utils.getFirstGenre(game) : ""
                                        font {
                                            family: global.fonts.sans
                                            pixelSize: 14 * vpx
                                        }
                                        color: "white"
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 5 * vpx
                    visible: !hasPlayStats && ((game && game.players > 0) || (game && game.rating > 0))

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2
                        height: 40 * vpx
                        radius: 8 * vpx
                        color: "#66000000"
                        visible: game && game.players > 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 1 * vpx

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "PLAYERS"
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 10 * vpx
                                    bold: true
                                }
                                color: "#a1a1a1"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: game ? game.players : ""
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 14 * vpx
                                    bold: true
                                }
                                color: root.getHueColor(collectionIndex)
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2
                        height: 40 * vpx
                        radius: 8 * vpx
                        color: "#66000000"
                        visible: game && game.rating > 0

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: 12 * vpx
                            }
                            spacing: 2 * vpx

                            Text {
                                text: "RATING"
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 10 * vpx
                                    bold: true
                                }
                                color: "white"
                            }

                            Row {
                                width: parent.width
                                spacing: 6 * vpx

                                Rectangle {
                                    width: parent.width - ratingTextCompact.width - parent.spacing
                                    height: 6 * vpx
                                    radius: 10 * vpx
                                    color: "#80FFFFFF"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width * (game ? game.rating : 0)
                                        height: parent.height
                                        radius: parent.radius
                                        color: root.getHueColor(collectionIndex)
                                    }
                                }

                                Text {
                                    id: ratingTextCompact
                                    text: game ? Math.round(game.rating * 100) + "%" : ""
                                    font {
                                        family: global.fonts.sans
                                        pixelSize: 14 * vpx
                                        bold: true
                                    }
                                    color: "white"
                                }
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 5 * vpx
                    visible: hasPlayStats


                    Rectangle {
                        width: (parent.width - parent.spacing * 3) / 4
                        height: 40 * vpx
                        radius: 8 * vpx
                        color: "#66000000"
                        visible: game && game.players > 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 1 * vpx

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "PLAYERS"
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 10 * vpx
                                    bold: true
                                }
                                color: "#a1a1a1"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: game ? game.players : ""
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 14 * vpx
                                    bold: true
                                }
                                color: root.getHueColor(collectionIndex)
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing * 3) / 4
                        height: 40 * vpx
                        radius: 8 * vpx
                        color: "#66000000"
                        visible: game && game.playCount > 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 1 * vpx

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "PLAY COUNT"
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 10 * vpx
                                    bold: true
                                }
                                color: "#a1a1a1"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: game ? game.playCount : ""
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 14 * vpx
                                    bold: true
                                }
                                color: root.getHueColor(collectionIndex)
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing * 3) / 4
                        height: 40 * vpx
                        radius: 8 * vpx
                        color: "#66000000"
                        visible: game && game.playTime > 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 1 * vpx

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "PLAY TIME"
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 10 * vpx
                                    bold: true
                                }
                                color: "#a1a1a1"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: game ? Utils.formatPlayTime(game.playTime) : ""
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 16 * vpx
                                    bold: true
                                }
                                color: root.getHueColor(collectionIndex)
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing * 3) / 4
                        height: 40 * vpx
                        radius: 8 * vpx
                        color: "#66000000"
                        visible: game && game.lastPlayed && game.lastPlayed.toString().length > 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 1 * vpx

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "LAST PLAYED"
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 10 * vpx
                                    bold: true
                                }
                                color: "#a1a1a1"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: game ? Utils.formatShortDate(game.lastPlayed) : ""
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 14 * vpx
                                    bold: true
                                }
                                color: root.getHueColor(collectionIndex)
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 35 * vpx
                    radius: 8 * vpx
                    color: "#66000000"
                    visible: hasPlayStats && game && game.rating > 0

                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: 12 * vpx
                        }
                        spacing: - 4 * vpx

                        Text {
                            text: "RATING"
                            font {
                                family: global.fonts.sans
                                pixelSize: 10 * vpx
                                bold: true
                            }
                            color: "white"
                        }

                        Row {
                            width: parent.width
                            spacing: 8 * vpx

                            Item {
                                width: parent.width - ratingText.width - parent.spacing
                                height: 7 * vpx
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: parent.width
                                    height: 7 * vpx
                                    radius: 10 * vpx
                                    color: "#80FFFFFF"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width * (game ? game.rating : 0)
                                        height: parent.height
                                        radius: parent.radius
                                        color: root.getHueColor(collectionIndex)
                                    }
                                }
                            }

                            Text {
                                id: ratingText
                                text: game ? Math.round(game.rating * 100) + "%" : ""
                                font {
                                    family: global.fonts.sans
                                    pixelSize: 16 * vpx
                                    bold: true
                                }
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

            }

            Item {
                id: scrollContainer
                width: parent.width
                height: Math.min(parent.height * 0.9, 200 * vpx)
                visible: game && (game.description || game.summary)
                clip: true

                PegasusUtils.AutoScroll {
                    id: autoscroll
                    anchors.fill: parent
                    pixelsPerSecond: 15
                    scrollWaitDuration: 3000

                    Item {
                        width: autoscroll.width
                        height: descripText.height

                        Text {
                            id: descripText
                            width: parent.width
                            text: game ? (game.description || game.summary || "") : ""
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                            font {
                                family: global.fonts.sans
                                pixelSize: 16 * vpx
                            }
                            color: "white"
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
                    }
                }
            }
        }
    }
}
