import QtQuick 2.15

Item {
    id: hexRoot

    property real size: 100
    property color color: "#c2366d"
    property string iconSource: ""
    property real radiusHex: 0.15

    width: size
    height: size

    Canvas {
        id: hexCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var w = width
            var h = height
            var cx = w / 2
            var cy = h / 2
            var r = Math.min(w, h) / 2
            var cornerRadius = r * hexRoot.radiusHex
            var vertices = []
            for (var i = 0; i < 6; i++) {
                var angle = (Math.PI / 3) * i - Math.PI / 6 + Math.PI / 2
                vertices.push({
                    x: cx + r * Math.cos(angle),
                              y: cy + r * Math.sin(angle)
                })
            }

            ctx.beginPath()

            for (var j = 0; j < 6; j++) {
                var current = vertices[j]
                var next = vertices[(j + 1) % 6]
                var prev = vertices[(j + 5) % 6]
                var dx1 = current.x - prev.x
                var dy1 = current.y - prev.y
                var len1 = Math.sqrt(dx1 * dx1 + dy1 * dy1)
                var dx2 = next.x - current.x
                var dy2 = next.y - current.y
                var len2 = Math.sqrt(dx2 * dx2 + dy2 * dy2)
                var startX = current.x - (dx1 / len1) * cornerRadius
                var startY = current.y - (dy1 / len1) * cornerRadius
                var endX = current.x + (dx2 / len2) * cornerRadius
                var endY = current.y + (dy2 / len2) * cornerRadius

                if (j === 0) {
                    ctx.moveTo(startX, startY)
                }

                ctx.quadraticCurveTo(current.x, current.y, endX, endY)

                if (j < 5) {
                    var nextVertex = vertices[j + 1]
                    var dxNext = nextVertex.x - current.x
                    var dyNext = nextVertex.y - current.y
                    var lenNext = Math.sqrt(dxNext * dxNext + dyNext * dyNext)
                    var nextStartX = nextVertex.x - (dxNext / lenNext) * cornerRadius
                    var nextStartY = nextVertex.y - (dyNext / lenNext) * cornerRadius
                    ctx.lineTo(nextStartX, nextStartY)
                }
            }

            ctx.closePath()
            ctx.fillStyle = hexRoot.color
            ctx.fill()
        }

        Component.onCompleted: requestPaint()
    }

    Image {
        anchors.centerIn: parent
        width: parent.width * 0.7
        height: parent.height * 0.7
        source: iconSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        visible: iconSource !== ""
    }

    onColorChanged: hexCanvas.requestPaint()
    onRadiusHexChanged: hexCanvas.requestPaint()
}
