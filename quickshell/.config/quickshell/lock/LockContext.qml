import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked()
    signal authFailure()

    property string text: ""
    property bool unlockInProgress: false

    function tryUnlock() {
        if (text === "")
            return

        unlockInProgress = true
        pam.start()
    }

    PamContext {
        id: pam

        configDirectory: "pam"
        config: "password.conf"

        onPamMessage: {
            if (responseRequired)
                respond(root.text)
        }

        onCompleted: result => {
            root.unlockInProgress = false

            if (result === PamResult.Success) {
                root.unlocked()
            } else {
                root.text = ""
                root.authFailure()
            }
        }
    }
}
