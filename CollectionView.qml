import QtQuick 2.15

FocusScope {
    id: collectionRoot

    signal collectionSelected(var collection)

    property int actualCurrentIndex: 0
    property int collectionIndex: 0

    CollectionsModel {
        id: collectionsModelManager
    }

    function setInitialIndex(index) {
        if (index >= 0 && index < collectionsModelManager.model.count) {
            actualCurrentIndex = index
            collectionList.currentIndex = index
            collectionList.positionViewAtIndex(index, ListView.Center)
        }
    }

    Component.onCompleted: {
        if (collectionsModelManager.modelReady) {
            restoreIndex()
        }
    }

    Connections {
        target: collectionsModelManager
        function onModelBuilt() {
            restoreIndex()
        }
    }

    function restoreIndex() {
        var lastIndex = api.memory.get('collectionIndex')
        if (lastIndex !== undefined && lastIndex >= 0 && lastIndex < collectionsModelManager.model.count) {
            setInitialIndex(lastIndex)
        } else {
            setInitialIndex(0)
        }
    }

    Item {
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 10 * vpx
            leftMargin: 10 * vpx
        }
        width: hexSize * 0.45
        height: hexSize * 0.45

        HexagonIcon {
            anchors.fill: parent
            size: hexSize * 0.3
            color: root.getHueColor(collectionIndex)
            iconSource: "assets/images/icon.png"
        }
    }

    ColorConfigPanel {
        id: globalColorConfig
        anchors {
            top: parent.top
            topMargin: 33 * vpx
            left: parent.left
            leftMargin: 80 * vpx
        }
        panelVisible: true
        focus: false
        collectionListView: collectionList
    }

    ListView {
        id: collectionList

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: hexSize * 1.05

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: width / 2 - hexSize * 0.9
        preferredHighlightEnd: width / 2 + hexSize * 0.9
        highlightMoveDuration: 350
        spacing: 0

        model: collectionsModelManager.model

        delegate: Item {
            id: delegateItem
            width: getItemWidth()
            height: collectionList.height

            property bool isCurrent: ListView.isCurrentItem

            function getItemWidth() {
                if (isCurrent) return hexSize * 1.8
                    return hexSize * 0.47
            }

            HexagonCollection {
                id: hexDelegate
                anchors.centerIn: parent
                width: hexSize
                height: hexSize
                collectionData: model
                isCurrentItem: isCurrent
                collectionIndex: index
                totalCollections: collectionsModelManager.model.count
                opacity: 1.0

                scale: isCurrentItem ? 1.3 : 0.41
                Behavior on scale {
                    NumberAnimation { duration: 300; easing.type: Easing.OutBack }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    collectionList.currentIndex = index
                    actualCurrentIndex = index
                }
            }
        }

        onCurrentIndexChanged: {
            actualCurrentIndex = currentIndex
        }

        focus: true
        Keys.onPressed: {
            if (api.keys.isAccept(event)) {
                event.accepted = true
                selectCurrentCollection()
            } else if (api.keys.isLeft(event)) {
                event.accepted = true
                if (currentIndex > 0) {
                    currentIndex--
                } else {
                    currentIndex = collectionsModelManager.model.count - 1
                }
            } else if (api.keys.isRight(event)) {
                event.accepted = true
                if (currentIndex < collectionsModelManager.model.count - 1) {
                    currentIndex++
                } else {
                    currentIndex = 0
                }
            } else if (api.keys.isFilters(event)) {
                event.accepted = true
                globalColorConfig.focus = true
                globalColorConfig.currentIndex = 0
                focus = false
            }
        }
    }

    Column {
        id: collectionTexts
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: collectionList.bottom
            topMargin: 40 * vpx
        }

        spacing: 25 * vpx

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: collectionsModelManager.model.count > 0 ?
            collectionsModelManager.model.get(actualCurrentIndex).name : ""

            font {
                family: global.fonts.sans
                pixelSize: 32 * vpx
                bold: false
            }
            color: root.getHueColor(collectionIndex)
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                if (collectionsModelManager.model.count === 0) return ""
                    var collection = collectionsModelManager.model.get(actualCurrentIndex)
                    return collection.games.count + " Games"
            }

            font {
                family: global.fonts.sans
                pixelSize: 20 * vpx
            }
            color: root.getHueColor(collectionIndex)
        }
    }

    function selectCurrentCollection() {
        if (collectionsModelManager.model.count > 0) {
            api.memory.set('collectionIndex', actualCurrentIndex)
            var selectedCollection = collectionsModelManager.model.get(actualCurrentIndex)
            var collectionObject = {
                name: selectedCollection.name,
                shortName: selectedCollection.shortName,
                games: selectedCollection.games,
                isVirtual: selectedCollection.isVirtual
            }

            if (!selectedCollection.isVirtual && selectedCollection.originalCollection) {
                collectionObject.originalCollection = selectedCollection.originalCollection
            }

            collectionSelected(collectionObject)
        }
    }
}
