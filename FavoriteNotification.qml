import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: notification

    property bool isFavorite: false
    property string gameTitle: ""
    property int collectionIndex: 0

    width: 250 * vpx
    height: 80 * vpx

    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: 10 * vpx
    }

    opacity: 0
    y: 100 * vpx

    Rectangle {
        id: notificationBg
        anchors.fill: parent
        color: root.getHueColor(collectionIndex)
        radius: 10 * vpx

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 17
            color: "#80000000"
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 15 * vpx

        Image {
            id: favoriteIcon
            width: 30 * vpx
            height: 30 * vpx
            source: "assets/images/icons/favorite.svg"
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }

        Column {
            spacing: 2 * vpx
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: isFavorite ? "ADDED TO FAVORITES" : "REMOVED FROM FAVORITES"
                font {
                    family: global.fonts.sans
                    pixelSize: 12 * vpx
                    bold: true
                    capitalization: Font.AllUppercase
                }
                color: "#ffffff"
            }

            Text {
                width: 150 * vpx
                text: gameTitle
                font {
                    family: global.fonts.sans
                    pixelSize: 11 * vpx
                }
                color: "#ffffff"
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }

    ParallelAnimation {
        id: showAnimation
        NumberAnimation {
            target: notification
            property: "opacity"
            from: 0
            to: 1
            duration: 300
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: notification
            property: "y"
            from: 100 * vpx
            to: 0
            duration: 400
            easing.type: Easing.OutBack
        }
    }

    ParallelAnimation {
        id: hideAnimation
        NumberAnimation {
            target: notification
            property: "opacity"
            from: 1
            to: 0
            duration: 300
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: notification
            property: "y"
            from: 0
            to: -50 * vpx
            duration: 300
            easing.type: Easing.InCubic
        }
    }

    Timer {
        id: autoHideTimer
        interval: 2000
        onTriggered: {
            hide()
        }
    }

    function show(favoriteStatus, title) {
        isFavorite = favoriteStatus
        gameTitle = title
        showAnimation.start()
        autoHideTimer.restart()
    }

    function hide() {
        hideAnimation.start()
    }

    onOpacityChanged: {
        if (opacity === 0 && y === -50 * vpx) {
            y = 100 * vpx
        }
    }
}
