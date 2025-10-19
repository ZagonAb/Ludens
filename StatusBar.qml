import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: statusBar

    anchors {
        top: parent.top
        right: parent.right
        topMargin: 15 * vpx
        rightMargin: 25 * vpx
    }

    width: 250 * vpx
    height: 50 * vpx

    property string currentTime: Qt.formatDateTime(new Date(), "hh:mm")
    property string currentDate: Qt.formatDateTime(new Date(), "dd/MM/yyyy")
    property bool batteryCharging: api.device.batteryCharging
    property real batteryPercent: api.device.batteryPercent
    property int batteryLevel: isNaN(batteryPercent) ? -1 : Math.round(batteryPercent * 100)
    property bool hasBattery: !isNaN(api.device.batteryPercent)

    Timer {
        id: timeTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            currentTime = Qt.formatDateTime(new Date(), "hh:mm")
            currentDate = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
        }
    }

    Timer {
        id: batteryTimer
        interval: 30000
        running: true
        repeat: true
        onTriggered: {
            batteryCharging = api.device.batteryCharging
            batteryPercent = api.device.batteryPercent
            batteryLevel = isNaN(batteryPercent) ? -1 : Math.round(batteryPercent * 100)
            hasBattery = !isNaN(api.device.batteryPercent)
        }
    }

    Row {
        id: statusRow
        anchors.right: parent.right
        spacing: 15 * vpx

        Row {
            id: batteryIndicator
            spacing: 5 * vpx
            anchors.verticalCenter: parent.verticalCenter
            visible: true

            Item {
                id: batteryIconContainer
                width: 50 * vpx
                height: 35 * vpx
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: batteryIcon
                    anchors.fill: parent
                    source: getBatteryIcon()
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    visible: false

                    function getBatteryIcon() {
                        if (!hasBattery) {
                            return "assets/images/icons/no_battery.svg"
                        }
                        if (batteryCharging) {
                            return "assets/images/icons/battery_charging.svg"
                        }

                        if (batteryLevel <= 9) return "assets/images/icons/battery_0.svg"
                            if (batteryLevel <= 34) return "assets/images/icons/battery_1.svg"
                                if (batteryLevel <= 59) return "assets/images/icons/battery_2.svg"
                                    if (batteryLevel <= 84) return "assets/images/icons/battery_3.svg"
                                        return "assets/images/icons/battery_4.svg"
                    }
                }

                ColorOverlay {
                    id: batteryIconOverlay
                    anchors.fill: batteryIcon
                    source: batteryIcon
                    color: textPrimary
                }
            }

            Text {
                id: batteryText
                text: getBatteryText()
                font {
                    family: global.fonts.sans
                    pixelSize: 20 * vpx
                }
                color: getBatteryColor()
                anchors.verticalCenter: parent.verticalCenter

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1
                    verticalOffset: 1
                    radius: 2
                    samples: 5
                    color: "#80000000"
                }

                function getBatteryText() {
                    if (!hasBattery) {
                        return "AC Power"
                    }
                    if (batteryCharging) {
                        return "⚡" + batteryLevel + "%"
                    }
                    return batteryLevel + "%"
                }

                function getBatteryColor() {
                    if (!hasBattery) return textSecondary
                        if (batteryCharging) return "#4CAF50"
                            if (batteryLevel <= 15) return "#F44336"
                                if (batteryLevel <= 30) return "#FF9800"
                                    return textPrimary
                }
            }
        }

        Rectangle {
            width: 1.5 * vpx
            height: 20 * vpx
            color: "#555555"
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            id: timeDateColumn
            spacing: 3 * vpx
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: timeText
                text: currentTime
                font {
                    family: global.fonts.sans
                    pixelSize: 20 * vpx
                    bold: true
                }
                color: textPrimary
                anchors.right: parent.right

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
                id: dateText
                text: currentDate
                font {
                    family: global.fonts.sans
                    pixelSize: 14 * vpx
                }
                color: textSecondary
                anchors.right: parent.right

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
    }

    Component.onCompleted: {
        currentTime = Qt.formatDateTime(new Date(), "hh:mm")
        currentDate = Qt.formatDateTime(new Date(), "dd/MM/yyyy")
        batteryCharging = api.device.batteryCharging
        batteryPercent = api.device.batteryPercent
        batteryLevel = isNaN(batteryPercent) ? -1 : Math.round(batteryPercent * 100)
        hasBattery = !isNaN(api.device.batteryPercent)

        console.log("StatusBar initialized - HasBattery:", hasBattery, "Battery:", batteryLevel + "%", "Charging:", batteryCharging)
    }


    onBatteryChargingChanged: {
        console.log("Battery charging changed:", batteryCharging)
    }

    onBatteryLevelChanged: {
        console.log("Battery level changed:", batteryLevel + "%")
    }

    onHasBatteryChanged: {
        console.log("Battery status changed - HasBattery:", hasBattery)
    }
}
