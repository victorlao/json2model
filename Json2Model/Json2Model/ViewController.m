//
//  ViewController.m
//  Json2Model
//
//  Created by lzq on 16/6/13.
//  Copyright © 2016年 laozhenqiang. All rights reserved.
//

#import "ViewController.h"
#import "NSString+FormatJSON.h"
#include <mach-o/dyld.h>

@interface ViewController ()

@property (weak) IBOutlet NSTextField *classNameField;
@property (weak) IBOutlet NSTextField *outputPathField;
@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;
@property (weak) IBOutlet NSTextField *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)generate:(id)sender
{
    NSString *path =[[NSBundle mainBundle] pathForResource:@"json2object" ofType:@"py"];
    NSString *className = [_classNameField stringValue];
    if (className.length == 0) {
        [_statusLabel setStringValue:@"类名不能为空!"];
        return;
    }
    NSFileManager *fm   = [NSFileManager defaultManager];
    char exePath[512];
    uint32_t size = 512;
    memset(exePath, 0, size);
    _NSGetExecutablePath(exePath, &size);
    NSString *exePathString = [NSString stringWithUTF8String:exePath];

    NSString *currentPath = [[[[exePathString stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];

    NSString *tempFilePath = [NSString stringWithFormat:@"%@/%@", currentPath,className];
    NSString *logPath = [NSString stringWithFormat:@"%@/log", currentPath];
    [fm removeItemAtPath:tempFilePath error:nil];
    [fm removeItemAtPath:logPath error:nil];
    NSString *cmd = [NSString stringWithFormat:@"%@ %@ %@ > %@", path, tempFilePath, className, logPath];
    NSString *jsonText = [_jsonTextView string];
    NSData *data = [jsonText dataUsingEncoding:NSUTF8StringEncoding];
    if (![data writeToFile:tempFilePath atomically:YES]) {
        [_statusLabel setStringValue:@"写文件出错!"];
    }
    system([cmd UTF8String]);
    NSData *logData = [[NSData alloc] initWithContentsOfFile:logPath];
    NSString *logString = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
    [_statusLabel setStringValue:logString];
    if (logString.length != 0) {
        NSString *headerPath = [NSString stringWithFormat:@"%@/%@.h", currentPath, className];
        NSString *mFilePath = [NSString stringWithFormat:@"%@/%@.m", currentPath, className];
        NSData *headerData = [[NSData alloc] initWithContentsOfFile:headerPath];
        if (headerData.length == 0) {
            [fm removeItemAtPath:headerPath error:nil];
            [fm removeItemAtPath:mFilePath error:nil];
        }
    }
    else {
        [_statusLabel setStringValue:@"success!"];
    }
    [fm removeItemAtPath:tempFilePath error:nil];
    [fm removeItemAtPath:logPath error:nil];
}

- (IBAction)format:(id)sender
{
    NSString *jsonText = _jsonTextView.string;
    NSString *formattedJsonText = [jsonText formatJSON];
    if (formattedJsonText.length > 0) {
        [_jsonTextView setString:formattedJsonText];
    }
   
}

@end
