import QtQuick 2.15
import SortFilterProxyModel 0.2

Item {
    id: collectionsModelItem

    property alias model: collectionsModel
    property bool modelReady: false

    signal modelBuilt()

    ListModel {
        id: collectionsModel
    }

    SortFilterProxyModel {
        id: favoritesProxyModel
        sourceModel: api.allGames
        filters: ValueFilter {
            roleName: "favorite"
            value: true
        }
    }

    SortFilterProxyModel {
        id: historyPlaying
        sourceModel: api.allGames
        filters: ExpressionFilter {
            expression: lastPlayed != null && lastPlayed.toString() !== "Invalid Date"
        }
        sorters: RoleSorter {
            roleName: "lastPlayed"
            sortOrder: Qt.DescendingOrder
        }
    }

    SortFilterProxyModel {
        id: historyProxyModel
        sourceModel: historyPlaying
        filters: IndexFilter {
            minimumIndex: 0
            maximumIndex: 49
        }
    }

    Component.onCompleted: {
        buildCollectionsModel()
    }

    function buildCollectionsModel() {
        collectionsModel.clear()

        var favoritesCollection = {
            name: "Favorites",
            shortName: "favorite",
            isVirtual: true,
            games: favoritesProxyModel
        }
        collectionsModel.append(favoritesCollection)

        var historyCollection = {
            name: "History",
            shortName: "history",
            isVirtual: true,
            games: historyProxyModel
        }
        collectionsModel.append(historyCollection)

        for (var i = 0; i < api.collections.count; i++) {
            var collection = api.collections.get(i)
            collectionsModel.append({
                name: collection.name,
                shortName: collection.shortName,
                isVirtual: false,
                games: collection.games,
                originalIndex: i,
                originalCollection: collection
            })
        }

        modelReady = true
    }

    function getCollection(index) {
        if (index < 0 || index >= collectionsModel.count) {
            return null
        }
        return collectionsModel.get(index)
    }

    function getCount() {
        return collectionsModel.count
    }
}
