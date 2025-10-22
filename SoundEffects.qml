import QtQuick 2.15
import QtMultimedia 5.15

Item {
    id: soundManager

    property SoundEffect upSound: SoundEffect {
        source: "assets/sounds/up.wav"
        volume: 0.7
    }

    property SoundEffect downSound: SoundEffect {
        source: "assets/sounds/down.wav"
        volume: 0.7
    }

    property SoundEffect okSound: SoundEffect {
        source: "assets/sounds/ok.wav"
        volume: 0.7
    }

    property SoundEffect cancelSound: SoundEffect {
        source: "assets/sounds/cancel.wav"
        volume: 0.7
    }

    property SoundEffect noticeSound: SoundEffect {
        source: "assets/sounds/notice.wav"
        volume: 0.7
    }

    property SoundEffect noticeBackSound: SoundEffect {
        source: "assets/sounds/notice_back.wav"
        volume: 0.7
    }

    function play(soundEffect) {
        if (soundEffect && soundEffect.source !== "") {
            soundEffect.play()
        }
    }

    function playUp() { play(upSound) }
    function playDown() { play(downSound) }
    function playOk() { play(okSound) }
    function playCancel() { play(cancelSound) }
    function playNotice() { play(noticeSound) }
    function playNoticeBack() { play(noticeBackSound) }
}
