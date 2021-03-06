import Qt 4.7
import QtMozilla 1.0
import QtQuick 1.1

FocusScope {
    id: mainScope
    objectName: "mainScope"

    anchors.fill: parent
    property alias viewport: webViewport

    signal pageTitleChanged(string title)

    function load(address) {
        addressLine.text = address
        viewport.child().load(address)
    }

    Item {
        id: debugg

        function testt(val) {
            console.log("viewport.enabled: " + viewport.enabled)
            return val
        }

        property int test: viewport.enabled ? testt(1) : testt(0)
    }

    QmlMozContext { id: qMozContext }

    AddressField {
        id: addressLine
        viewport: webViewport
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 0
        }
    }

    QmlMozView {
        id: webViewport
        parentid: createParentID
        objectName: "webViewport"
        visible: true
        focus: true
        property bool movingHorizontally: false
        property bool movingVertically: true
        property variant visibleArea: QtObject {
            property real yPosition: 0
            property real xPosition: 0
            property real widthRatio: 0
            property real heightRatio: 0
        }

        function scrollTimeout() {
            webViewport.movingHorizontally = false
            webViewport.movingVertically = false
        }
        Timer {
            id: scrollTimer
            interval: 500
            running: false
            repeat: false
            onTriggered: webViewport.scrollTimeout()
        }

        anchors {
            top: addressLine.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        Connections {
            target: webViewport.child()
            onViewInitialized: {
                webViewport.child().addMessageListener("chrome:title")
                webViewport.child().addMessageListener("context:info")
                print("QML View Initialized")
                if (startURL.length != 0 && createParentID == 0) {
                    load(startURL)
                }
            }
            onViewAreaChanged: {
                var r = webViewport.child().contentRect
                var offset = webViewport.child().scrollableOffset
                var s = webViewport.child().scrollableSize
                webViewport.visibleArea.widthRatio = r.width / s.width
                webViewport.visibleArea.heightRatio = r.height / s.height
                webViewport.visibleArea.xPosition = offset.x
                        * webViewport.visibleArea.widthRatio
                        * webViewport.child().resolution
                webViewport.visibleArea.yPosition = offset.y
                        * webViewport.visibleArea.heightRatio
                        * webViewport.child().resolution
                webViewport.movingHorizontally = true
                webViewport.movingVertically = true
                scrollTimer.restart()
            }
            onTitleChanged: {
                pageTitleChanged(webViewport.child().title)
            }
            onRecvAsyncMessage: {
                print("onRecvAsyncMessage:" + message + ", data:" + data)
                if (message == "context:info") {
                    contextMenu.contextLinkHref = data.LinkHref
                    contextMenu.contextImageSrc = data.ImageSrc
                    navigation.contextInfoAvialable = (contextMenu.contextLinkHref.length > 0 || contextMenu.contextImageSrc.length > 0)

                }
            }
            onRecvSyncMessage: {
                print("onRecvSyncMessage:" + message + ", data:" + data)
                if (message == "embed:testsyncresponse") {
                    response.message = {
                        val: "response",
                        numval: 0.04
                    }
                }
            }
            onAlert: {
                print("onAlert: title:" + data.title + ", msg:" + data.text + " winid:" + data.winid)
                webViewport.enabled = false
                alertDlg.show(data.title, data.text, data.winid)
            }
            onConfirm: {
                print("onConfirm: title:" + data.title + ", data.text:" + data.text)
                webViewport.enabled = false
                confirmDlg.show(data.title, data.text, data.winid)
            }
            onPrompt: {
                print("onPrompt: title:" + data.title + ", msg:" + data.text)
                webViewport.enabled = false
                promptDlg.show(data.title, data.text, data.defaultValue, data.winid)
            }
            onAuthRequired: {
                print("onAuthRequired: title:" + data.title + ", msg:" + data.text + ", winid:" + data.winid)
                webViewport.enabled = false
                authDlg.show(data.title, data.text, data.defaultValue, data.winid)
            }
        }

        AlertDialog {
            id: alertDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("alertresponse", {
                                                         winid: winid,
                                                         checkval: alertDlg.checkval,
                                                         accepted: alertDlg.accepted
                                                     })
                webViewport.enabled = true
            }
        }

        ConfirmDialog {
            id: confirmDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("confirmresponse", {
                                                         winid: winid,
                                                         checkval: confirmDlg.checkval,
                                                         accepted: confirmDlg.accepted
                                                     })
                webViewport.enabled = true
            }
        }

        PromptDialog {
            id: promptDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("promptresponse", {
                                                         winid: winid,
                                                         checkval: promptDlg.checkval,
                                                         accepted: promptDlg.accepted,
                                                         promptvalue: promptDlg.prompttext
                                                     })
                webViewport.enabled = true
            }
        }

        AuthenticationDialog {
            id: authDlg
            onHandled: {
                webViewport.child().sendAsyncMessage("authresponse", {
                                                         winid: winid,
                                                         checkval: authDlg.checkval,
                                                         accepted: authDlg.accepted,
                                                         username: authDlg.username,
                                                         password: authDlg.password
                                                     })
                webViewport.enabled = true
            }
        }

        ScrollIndicator {
            id: scrollIndicator
            flickableItem: webViewport
        }
    }

    MouseArea {
        anchors.fill: webViewport
        
        property int mX: 0
        property int mY: 0
        property int edgeY: 0
        property int deltaY: 0
        property bool longPressed: false
        property bool longLocked: false

        onPressed: {
            addressLine.unfocusAddressBar()
            var mapped = mapToItem(mainScope, mouse.x, mouse.y);
            mY = mapped.y
            mX = mapped.x

            navigation.contextInfoAvialable = false
            navigation.visible = false
            contextMenu.visible = false

            viewport.focus = true
        }
        
        onReleased: {
            if (!navigation.visible) {
                viewport.enabled = true
                viewport.focus = true;

                if (viewport.child().contentRect.y == 0 && deltaY < - 20) {
                        addressLine.anchors.topMargin = 0;
                }
                else  {
                    addressLine.anchors.topMargin = -addressLine.height
                }
            }

            longPressed = false;
            longLocked = false
            edgeY = 0
        }

        onPressAndHold: {
            longPressed = true

            var mapped = mapToItem(mainScope, mouse.x, mouse.y)
            navigation.y = mapped.y - 150
            if (navigation.y < 0)
                navigation.y = 0
            else if (navigation.y + navigation.height > parent.height)
                navigation.y = parent.height - navigation.height

            if (!longLocked && !contextMenu.visible) {
                navigation.visible = true
                viewport.enabled = false
            }
        }

        onPositionChanged: {
            var mapped = mapToItem(mainScope, mouse.x, mouse.y)
            deltaY = mY - mapped.y
            if (!longPressed && Math.abs(deltaY) > 20) {
                longLocked = true
            }

            if (viewport.child().contentRect.y == 0) {
                if (deltaY < 0) {
                    viewport.enabled = false
                    if (edgeY == 0)
                        edgeY = mapped.y

                    var topDelta = mapped.y - edgeY;
                    if (topDelta > addressLine.height)
                        topDelta = addressLine.height;
                    addressLine.anchors.topMargin = topDelta - addressLine.height;
                }
                else if (!longPressed && !navigation.visible) {
                    viewport.enabled = true
                }
            }
        }
    }

    OverlayContextMenu {
        id: contextMenu
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        width: Math.min(parent.width, parent.height) - 10
        context: qMozContext
        viewport: webViewport
    }

    OverlayNavigation {
        id: navigation
        anchors.horizontalCenter: parent.horizontalCenter
        viewport: webViewport

        onContextMenuRequested: {
            console.log("context menu")
            contextMenu.visible = true
            viewport.enabled = false
            navigation.visible = false
        }
    }

    OverlayButton {
        id: newPage

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottomMargin: 10

        width: 100
        height: 100

        visible: navigation.visible

        iconSource: "../icons/plus.png"

        onClicked: {
            qMozContext.newWindow()
            navigation.visible = false
        }
    }

    Keys.onPressed: {
        if (((event.modifiers & Qt.ControlModifier) && event.key == Qt.Key_L)
                || event.key == Qt.key_F6) {
            console.log("Focus address bar")
            addressLine.focusAddressBar()
            event.accepted = true
        }
    }
}
