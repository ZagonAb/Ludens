import QtQuick 2.15

Rectangle {
    id: bar

    property bool inGameView: false
    property string navigateIcon: inGameView ? "assets/images/icons/navigate2.png" : "assets/images/icons/navigate.png"
    property bool raLoading: false
    property bool raAvailable: false
    property bool raChecked: false

    color: "#000000"

    Row {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 60 * vpx
        }
        spacing: 40 * vpx

        BarButton {
            iconSource: bar.navigateIcon
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
        spacing: 15 * vpx

        BarButton {
            iconSource: !inGameView ? "assets/images/icons/ok.png" : ""
            label: !inGameView ? "Ok" : ""
            visible: !inGameView
        }


        BarButton {
            id: raSettingsButton
            iconSource: "assets/images/icons/setting.png"
            label: ""
            visible: inGameView && raAvailable && raChecked && !raLoading
        }

        BarButton {
            id: raIndicator
            iconSource: {
                if (!inGameView) return ""
                    if (raLoading) return "assets/images/icons/spinner.png"
                        if (raChecked) {
                            if (raAvailable) return "assets/images/icons/achievement.svg"
                                else return "assets/images/icons/no_achievement.svg"
                        }
                        return ""
            }
            label: {
                if (!inGameView) return ""
                    if (raLoading) return "Loading RA..."
                        if (raChecked) {
                            if (raAvailable) return "Achievements"
                                else return "Achievements"
                        }
                        return ""
            }
            rotating: raLoading
            visible: inGameView && (raLoading || raChecked)
            opacity: (raLoading || (raAvailable && raChecked && !raLoading)) ? 1.0 : 0.3
        }
    }

    function updateRAStatus(loading, available) {
        raLoading = loading
        if (!loading) {
            raChecked = true
            raAvailable = available
        }
        //console.log("BottomBar RA Status - Loading:", loading, "Available:", available, "Checked:", raChecked)
    }

    function resetRAStatus() {
        raLoading = false
        raAvailable = false
        raChecked = false
    }

    onInGameViewChanged: {
        if (!inGameView) {
            resetRAStatus()
        }
    }
}
