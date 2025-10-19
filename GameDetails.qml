import QtQuick 2.15
import QtGraphicalEffects 1.12
import "qrc:/qmlutils" as PegasusUtils
import "utils.js" as Utils

Item {
    id: details

    property var game
    property int collectionIndex: 0

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
            spacing: 15 * vpx

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
                spacing: 8 * vpx

                InfoRow {
                    label: "Developer"
                    value: game ? game.developer : ""
                    visible: game && game.developer
                }

                InfoRow {
                    label: "Publisher"
                    value: game ? game.publisher : ""
                    visible: game && game.publisher
                }

                InfoRow {
                    label: "Release"
                    value: game && game.releaseYear > 0 ? game.releaseYear : ""
                    visible: game && game.releaseYear > 0
                }

                InfoRow {
                    label: "Genre"
                    value: game ? game.genre : ""
                    visible: game && game.genre
                }

                InfoRow {
                    label: "Players"
                    value: game ? game.players : ""
                    visible: game && game.players > 1
                }

                InfoRow {
                    label: "Play Count"
                    value: game ? game.playCount : ""
                    visible: game && game.playCount > 0
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
