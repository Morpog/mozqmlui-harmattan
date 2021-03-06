/*
 * Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies)
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 1.1

Item {
    id: dialog

    anchors.fill: parent
    z: 1000

    // We want to be a child of the mainScope item so that we can cover
    // the whole scene with our "dim" overlay.
    parent: mainScope

    property alias title: titleText.text
    property alias message: messageText.text
    y: parent.height // off "screen"
    anchors.horizontalCenter: parent.horizontalCenter
    default property alias __children: dynamicColumn.children

    property variant winid: 0
    visible: false
    signal handled
    property bool accepted;
    property bool checkval;

    MouseArea {
        id: mouseBlocker
        anchors.fill: parent
        onPressed: mouse.accepted = true

        // FIXME: This does not block touch events :(
    }

    Rectangle {
        id: dimBackground
        anchors.fill: parent
        color: "black"
        opacity: 0.4
    }

    Rectangle {
        id: dialogWindow

        color: "#efefef"

        width: parent.width - 40
        height: 250

        border {
            width: 1
            color: "#bfbfbf"
        }

        smooth: true
        radius: 5

        anchors.centerIn: parent

        Column {
            id: content
            anchors.centerIn: parent
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Text {
                id: titleText
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 20
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                id: messageText
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: 20
            }

            Column {
                id: dynamicColumn
                spacing: 5
                anchors {
                    margins: 10
                    bottom: content.bottom
                    horizontalCenter: content.horizontalCenter
                }
            }
        }
    }
}
