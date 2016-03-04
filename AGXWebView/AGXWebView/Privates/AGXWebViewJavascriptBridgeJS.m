//
//  AGXWebViewJavascriptBridgeJS.m
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewJavascriptBridgeJS.h"

NSString *AGXWebViewJavascriptBridgeJS() {
    #define __agx_wvjb_js_func__(x) #x
    
    static NSString * preprocessorJSCode = @__agx_wvjb_js_func__
    (;(function() {
        if (window.AGXBridge) return;
        
        window.AGXBridge = {
            registerHandler: registerHandler,
            callHandler: callHandler,
            _fetchQueue: _fetchQueue,
            _handleMessageFromObjC: _handleMessageFromObjC
        };
        
        var messagingIframe;
        var sendMessageQueue = [];
        var messageHandlers = {};
        
        var CUSTOM_PROTOCOL_SCHEME = 'agxscheme';
        var QUEUE_HAS_MESSAGE = '__AGX_QUEUE_MESSAGE__';
        
        var responseCallbacks = {};
        var uniqueId = 1;
        
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        
        function callHandler(handlerName, data, responseCallback) {
            if (arguments.length == 2 && typeof data == 'function') {
                responseCallback = data;
                data = null;
            }
            _doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            sendMessageQueue.push(message);
            messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        }
        
        function _fetchQueue() {
            var messageQueueString = JSON.stringify(sendMessageQueue);
            sendMessageQueue = [];
            return messageQueueString;
        }
        
        function _dispatchMessageFromObjC(messageJSON) {
            setTimeout(function _timeoutDispatchMessageFromObjC() {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                        return;
                    }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            _doSend({ responseId:callbackResponseId, responseData:responseData });
                        };
                    }
                    
                    var handler = messageHandlers[message.handlerName];
                    try {
                        handler(message.data, responseCallback);
                    } catch(exception) {
                        console.log("AGXBridge: WARNING: javascript handler threw.", message, exception);
                    }
                    if (!handler) {
                        console.log("AGXBridge: WARNING: no handler for message from ObjC:", message);
                    }
                }
            });
        }
        
        function _handleMessageFromObjC(messageJSON) {
            _dispatchMessageFromObjC(messageJSON);
        }
        
        messagingIframe = document.createElement('iframe');
        messagingIframe.style.display = 'none';
        messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        document.documentElement.appendChild(messagingIframe);
        
        setTimeout(_callAGXBridgeCallbacks, 0);
        function _callAGXBridgeCallbacks() {
            var callbacks = window.AGXBridgeCallbacks;
            delete window.AGXBridgeCallbacks;
            for (var i=0; i<callbacks.length; i++) {
                callbacks[i](AGXBridge);
            }
        }
    })(); // function
     ); // __agx_wvjb_js_func__
    
    #undef __agx_wvjb_js_func__
    return preprocessorJSCode;
}
