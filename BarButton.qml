import QtQuick 2.15

Row {
    id: btn

    property string iconText: ""
    property string label: ""
    property string iconSource: ""

    spacing: 10 * vpx
    opacity: (label !== "" || iconSource !== "") ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Text {
        text: iconText
        font {
            family: global.fonts.sans
            pixelSize: 27 * vpx
        }
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        visible: iconSource === ""
    }

    Image {
        width: 27 * vpx
        height: 27 * vpx
        source: iconSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        anchors.verticalCenter: parent.verticalCenter
        visible: iconSource !== ""
    }

    Text {
        text: label
        font {
            family: global.fonts.sans
            pixelSize: 27 * vpx
        }
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
    }
}
