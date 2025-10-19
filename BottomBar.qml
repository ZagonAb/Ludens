import QtQuick 2.15

Rectangle {
    id: bar

    property bool inGameView: false

    color: "#000000"

    Row {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 60 * vpx
        }
        spacing: 40 * vpx

        BarButton {
            iconSource: "assets/images/icons/navigate.png"
            label: "Navigate"
        }

        BarButton {
            iconSource: inGameView ? "assets/images/icons/favorite.png" : ""
            label: inGameView ? "Favorite" : ""
            visible: inGameView
        }

        BarButton {
            iconSource: inGameView ? "assets/images/icons/ok.png" : ""
            label: inGameView ? "Run" : ""
            visible: inGameView
        }

        BarButton {
            iconSource: inGameView ? "assets/images/icons/back.png" : ""
            label: inGameView ? "Back" : ""
            visible: inGameView
        }

        BarButton {
            iconSource: !inGameView ? "assets/images/icons/setting.png" : ""
            label: !inGameView ? "Color Setting" : ""
            visible: !inGameView
        }
    }

    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 60 * vpx
        }
        spacing: 40 * vpx

        BarButton {
            iconSource: !inGameView ? "assets/images/icons/ok.png" : ""
            label: !inGameView ? "Ok" : ""
            visible: !inGameView
        }
    }
}
