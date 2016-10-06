//
//  MainAppController.m
//  SocialNetwork
//
//  Created by Nguyen Xuan Thanh on 8/10/16.
//  Copyright © 2016 Nguyen Xuan Thanh. All rights reserved.
//

#import "ClientSocketController.h"
#import "UIViewController+ResponseHandler.h"
#import "UIViewController+RequestHandler.h"

@interface ClientSocketController () {
    CFReadStreamRef _readStream;
    CFWriteStreamRef _writeStream;
    NSOutputStream *_outputStream;
    NSInputStream *_inputStream;
    NSString *_receivedMessage;
    NSMutableDictionary<NSString *, UIViewController *> *_responses;
    NSMutableDictionary<NSString *, NSMutableArray *> *_requests;
    NSData *_remainData;
    BOOL _isSocketOpened;
}

@end

@implementation ClientSocketController

+ (instancetype)sharedController {
    static id sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _responses = [NSMutableDictionary dictionary];
        _requests = [NSMutableDictionary dictionary];
        _isSocketOpened = NO;
    }
    return self;
}

- (void)openSocket {
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef) kServerHost, kServerPort,
        &_readStream, &_writeStream);
    _outputStream = (__bridge NSOutputStream *)_writeStream;
    _inputStream = (__bridge NSInputStream *)_readStream;
    [_outputStream setDelegate:self];
    [_inputStream setDelegate:self];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream open];
    [_inputStream open];
    _isSocketOpened = YES;
}

- (void)closeSocket {
    [_inputStream close];
    [_outputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
    [_outputStream setDelegate:nil];
    _inputStream = nil;
    _outputStream = nil;
    _isSocketOpened = NO;
}

- (void)sendData:(NSString *)message messageType:(NSString *)messageType actionName:(NSString *)actionName
    sender:(UIViewController *)sender {
    if (!_isSocketOpened) {
        [self openSocket];
    }
    NSString *finalMessage = [NSString stringWithFormat:kMessageFormat, messageType, actionName, message];
    finalMessage = [NSString stringWithFormat:kFinalMessageFormat, kStartOfStream, strlen([finalMessage UTF8String]),
        finalMessage, kEndOfStream];
    NSData *data = [finalMessage dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t *bytes = (uint8_t *) [data bytes];
    NSInteger bytesWritten = [_outputStream write:bytes maxLength:[data length]];
    if (bytesWritten < [data length]) {
        if (bytesWritten != -1) {
            bytes += bytesWritten;
        }
        _remainData = [NSData dataWithBytes:bytes length:strlen((char *)bytes)];
    }
    _responses[actionName] = sender;
}

- (void)registerRequestHandler:(NSString *)actionName receiver:(UIViewController *)receiver {
    NSMutableArray *array = [_requests valueForKey:actionName];
    if (array) {
        if (![array containsObject:receiver]) {
            [array addObject:receiver];
        }
    } else {
        array = @[receiver].mutableCopy;
        _requests[actionName] = array;
    }
}

- (void)resignRequestHandler:(NSString *)actionName receiver:(UIViewController *)receiver {
    NSMutableArray *array = [_requests valueForKey:actionName];
    if (array && [array containsObject:receiver]) {
        [array removeObject:receiver];
    }
}

#pragma mark - Process message from server

- (void)readMessage {

    uint8_t buffer[kDefaultBufferLength];
    NSString *temp;
    NSInteger bytesRead = [_inputStream read:buffer maxLength:kDefaultBufferLength];
    _receivedMessage = [[NSString alloc] initWithBytes:buffer length:bytesRead
        encoding:NSUTF8StringEncoding];
    NSUInteger offset = kDefaultBufferLength;
    if ([_receivedMessage hasPrefix:kStartOfStream]) {
        _receivedMessage = [_receivedMessage substringFromIndex:kStartOfStream.length];
        NSString *messageLengthString = [_receivedMessage componentsSeparatedByString:@"-"][0];
        _receivedMessage = [_receivedMessage substringFromIndex:messageLengthString.length + 1];
        NSUInteger messageLength = [messageLengthString integerValue] + kEndOfStream.length + kStartOfStream.length +
            messageLengthString.length + 1;
        NSUInteger bufferLength;
        while (offset < messageLength) {
            bufferLength = messageLength - offset > kDefaultBufferLength ? kDefaultBufferLength :
                messageLength - offset;
            bytesRead = [_inputStream read:buffer maxLength:bufferLength];
            offset += bytesRead;
            temp = [[NSString alloc] initWithBytes:buffer length:bytesRead encoding:NSUTF8StringEncoding];
            if (temp) {
                _receivedMessage = [_receivedMessage stringByAppendingString:temp];
            }
        }
        _receivedMessage = [_receivedMessage substringToIndex:[_receivedMessage rangeOfString:kEndOfStream].location];
    }
}

- (void)handleMessage {
    if (_receivedMessage) {
        NSArray *result = [_receivedMessage componentsSeparatedByString:kDelim];
        if ([result containsObject:@""]) {
            return;
        }
        if ([result[0] isEqualToString:kReceivingRequestSignal]) {
            [_responses[result[1]] handleResponse:result[1] message:result[2]];
            [_responses removeObjectForKey:result[1]];
        } else if ([result[0] isEqualToString:kSendingRequestSignal]) {
            NSArray *array = [_requests objectForKey:result[1]];
            for (UIViewController *viewController in array) {
                [viewController handleRequest:result[1] message:result[2]];
            }
        }
    }
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    switch (streamEvent) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            if (theStream == _inputStream) {
                [self readMessage];
                [self handleMessage];
            }
            break;
        case NSStreamEventHasSpaceAvailable: {
            if (_remainData) {
                uint8_t *bytes = (uint8_t *) [_remainData bytes];
                NSInteger bytesWritten = [_outputStream write:bytes maxLength:[_remainData length]];
                if (bytesWritten < [_remainData length]) {
                    if (bytesWritten != -1) {
                        bytes += bytesWritten;
                    }
                    _remainData = [NSData dataWithBytes:bytes length:strlen((char *)bytes)];
                } else {
                    _remainData = nil;
                }
            }
            break;
        }
        case NSStreamEventErrorOccurred:
            // TODO
            [self closeSocket];
            break;
        case NSStreamEventEndEncountered:
            // TODO
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
        default:
            break;
    }
}

@end
