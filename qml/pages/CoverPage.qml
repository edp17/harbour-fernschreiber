/*
    Copyright (C) 2020 Sebastian J. Wolf and other contributors

    This file is part of Fernschreiber.

    Fernschreiber is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Fernschreiber is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Fernschreiber. If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import WerkWolf.Fernschreiber 1.0
import "../components"
import "../js/functions.js" as Functions

CoverBackground {

    id: coverPage

    property int unreadMessages: 0
    property int unreadChats: 0
    property bool authenticated: false
    property int connectionState: TelegramAPI.WaitingForNetwork

    function setUnreadInfoText() {
        if (unreadMessages === 1) {
            unreadMessagesText.text = qsTr("unread message");
        } else {
            unreadMessagesText.text = qsTr("unread messages");
        }

        if (unreadChats === 1) {
            unreadChatsText.text = qsTr("chat");
        } else {
            unreadChatsText.text = qsTr("chats");
        }

        switch (coverPage.connectionState) {
        case TelegramAPI.WaitingForNetwork:
            connectionStateText.text = qsTr("Waiting for network...");
            break;
        case TelegramAPI.Connecting:
            connectionStateText.text = qsTr("Connecting to network...");
            break;
        case TelegramAPI.ConnectingToProxy:
            connectionStateText.text = qsTr("Connecting to proxy...");
            break;
        case TelegramAPI.ConnectionReady:
            connectionStateText.text = qsTr("Connected");
            break;
        case TelegramAPI.Updating:
            connectionStateText.text = qsTr("Updating content...");
            break;
        }
    }

    Component.onCompleted: {
        coverPage.authenticated = (tdLibWrapper.getAuthorizationState() === TelegramAPI.AuthorizationReady);
        coverPage.connectionState = tdLibWrapper.getConnectionState();
        coverPage.unreadMessages = tdLibWrapper.getUnreadMessageInformation().unread_count || 0;
        coverPage.unreadChats = tdLibWrapper.getUnreadChatInformation().unread_count;
        setUnreadInfoText();
    }

    Connections {
        target: tdLibWrapper
        onUnreadMessageCountUpdated: {
            coverPage.unreadMessages = messageCountInformation.unread_count;
            setUnreadInfoText();
        }
        onUnreadChatCountUpdated: {
            coverPage.unreadChats = chatCountInformation.unread_count;
            setUnreadInfoText();
        }
        onAuthorizationStateChanged: {
            coverPage.authenticated = (authorizationState === TelegramAPI.AuthorizationReady);
            setUnreadInfoText();
        }
        onConnectionStateChanged: {
            coverPage.connectionState = connectionState;
            setUnreadInfoText();
        }
    }

    BackgroundImage {
        id: backgroundImage
        width: parent.height - Theme.paddingLarge
        height: width
        sourceDimension: width
        anchors {
            verticalCenter: parent.verticalCenter
            centerIn: undefined
            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingMedium
        visible: coverPage.authenticated
        Row {
            width: parent.width
            spacing: Theme.paddingMedium
            Text {
                id: unreadMessagesCountText
                font.pixelSize: Theme.fontSizeHuge
                color: Theme.primaryColor
                text: Functions.getShortenedCount(coverPage.unreadMessages)
            }
            Text {
                id: unreadMessagesText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width - unreadMessagesCountText.width - Theme.paddingMedium
                wrapMode: Text.Wrap
                anchors.verticalCenter: unreadMessagesCountText.verticalCenter
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        Row {
            width: parent.width
            spacing: Theme.paddingMedium
            visible: coverPage.authenticated && coverPage.unreadMessages > 1
            Text {
                id: inText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                text: qsTr("in")
                anchors.verticalCenter: unreadChatsCountText.verticalCenter
            }
            Text {
                id: unreadChatsCountText
                font.pixelSize: Theme.fontSizeHuge
                color: Theme.primaryColor
                text: Functions.getShortenedCount(coverPage.unreadChats)
            }
            Text {
                id: unreadChatsText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                width: parent.width - unreadChatsCountText.width - inText.width - ( 2 * Theme.paddingMedium )
                wrapMode: Text.Wrap
                anchors.verticalCenter: unreadChatsCountText.verticalCenter
            }
        }

        Text {
            id: connectionStateText
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.highlightColor
            visible: coverPage.authenticated
            width: parent.width
            maximumLineCount: 3
            wrapMode: Text.Wrap
        }
    }

}
