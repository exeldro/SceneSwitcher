#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CGEvent.h>
#import <Carbon/Carbon.h>
#include <Carbon/Carbon.h>
#include <util/platform.h>
#include "../headers/advanced-scene-switcher.hpp"


void GetWindowList(vector<string> &windows)
{
    windows.resize(0);

    @autoreleasepool {
        NSWorkspace *ws = [NSWorkspace sharedWorkspace];
        NSArray *array = [ws runningApplications];
        for (NSRunningApplication *app in array) {
            NSString *name = app.localizedName;
            if (!name)
                continue;

            const char *str = name.UTF8String;
            if (str && *str)
                windows.emplace_back(str);
        }
    }
}

void GetCurrentWindowTitle(string &title)
{
    title.resize(0);

    @autoreleasepool {
        NSWorkspace *ws = [NSWorkspace sharedWorkspace];
        NSRunningApplication *app = [ws frontmostApplication];
        if (app) {
            NSString *name = app.localizedName;
            if (!name)
                return;

            const char *str = name.UTF8String;
            if (str && *str)
                title = str;
        }
    }
}

pair<int, int> getCursorPos() {     
    pair<int, int> pos(0, 0);       
    CGEventRef event = CGEventCreate(NULL);     
    CGPoint cursorPos = CGEventGetLocation(event);      
    CFRelease(event);       
    pos.first = cursorPos.x;        
    pos.second = cursorPos.y;       
    return pos;     
 }

bool isFullscreen() {
    @autoreleasepool {
        AXValueRef temp;
        CGSize windowSize;
        CGPoint windowPosition;
        AXUIElementRef frontMostApp;
        AXUIElementRef frontMostWindow;

        pid_t pid;
        ProcessSerialNumber psn;
        @try {
            GetFrontProcess(&psn);
            GetProcessPID(&psn, &pid);
            frontMostApp = AXUIElementCreateApplication(pid);

            AXUIElementCopyAttributeValue(
            frontMostApp, kAXFocusedWindowAttribute, (CFTypeRef *)&frontMostWindow);

            // Get the window size and position
            AXUIElementCopyAttributeValue(
               frontMostWindow, kAXSizeAttribute, (CFTypeRef *)&temp);
            AXValueGetValue(temp, kAXValueTypeCGSize, &windowSize);             
            CFRelease(temp);

            AXUIElementCopyAttributeValue(
               frontMostWindow, kAXPositionAttribute, (CFTypeRef *)&temp);
            AXValueGetValue(temp, kAXValueTypeCGPoint, &windowPosition);        
               CFRelease(temp);

            CGRect screenBound = CGDisplayBounds(CGMainDisplayID());
            CGSize screenSize = screenBound.size;

            if((windowSize.width == screenSize.width) && (windowSize.height == screenSize.height) &&
               (windowPosition.x == 0) && (windowPosition.y == 0))
                    return true;
        }
        @catch (...) {
        // deal with the exception
        }
        @catch (NSException *exception) {
        // deal with the exception
        }

    }
    return false;
}

int secondsSinceLastInput()
{
    double time = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState, kCGAnyInputEventType) + 0.5;
    return (int) time;
}

void GetProcessList(QStringList& list)
{
    list.clear();
    @autoreleasepool {
        NSWorkspace *ws = [NSWorkspace sharedWorkspace];
        NSArray *array = [ws runningApplications];
        for (NSRunningApplication *app in array) {
            NSString *name = app.localizedName;
            if (!name)
                continue;
            
            const char *str = name.UTF8String;
            if (str && *str)
                list << (str);
        }
    }
}

bool isInFocus(QString const& appQName)
{
    QByteArray ba = appQName.toLocal8Bit();
    const char * appName = ba.data();
    @autoreleasepool {
        NSWorkspace *ws = [NSWorkspace sharedWorkspace];
        NSRunningApplication *app = [ws frontmostApplication];
        if (app) {
            NSString *name = app.localizedName;
            if (!name)
                return false;
            
            const char *str = name.UTF8String;
            return (str && *str && strcmp(appName,str) == 0 )? true : false;
        }
    }
    return false;
}
