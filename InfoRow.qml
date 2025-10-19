import QtQuick 2.15
import QtGraphicalEffects 1.12

Row {
    id: infoRow

    property string label: ""
    property string value: ""

    width: parent.width
    spacing: 10 * vpx

    Text {
        text: label + ":"
        font {
            family: global.fonts.sans
            pixelSize: 14 * vpx
            bold: true
        }
        color: "white"
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

    Text {
        width: parent.width - parent.spacing - x
        text: value
        font {
            family: global.fonts.sans
            pixelSize: 14 * vpx
        }
        color: "#cbcbcb"
        wrapMode: Text.WordWrap
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
