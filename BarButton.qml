import QtQuick 2.15

Row {
    id: btn

    property string iconText: ""
    property string label: ""
    property string iconSource: ""
    property bool rotating: false

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

    Item {
        id: iconContainer
        width: 27 * vpx
        height: 27 * vpx
        anchors.verticalCenter: parent.verticalCenter
        visible: iconSource !== ""

        Image {
            id: staticIcon
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            source: iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: !btn.rotating
        }

        Image {
            id: spinnerIcon
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            source: iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            visible: btn.rotating

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: spinnerIcon.visible
            }
        }
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

    onRotatingChanged: {
        if (!rotating) {
            staticIcon.rotation = 0
            spinnerIcon.rotation = 0
        }
    }
}
