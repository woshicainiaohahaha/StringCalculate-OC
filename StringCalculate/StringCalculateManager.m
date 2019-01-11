//
//  StringCalculateManager.m
//  StringCalculate
//
//  Created by 李东岩 on 2019/1/10.
//  Copyright © 2019 李东岩. All rights reserved.
//

#import "StringCalculateManager.h"

@interface StringCalculateManager ()

@property (nonatomic, strong) NSMutableDictionary *fontDictionary;

@property (nonatomic, assign) NSInteger numsNeedToSave;

@property (nonatomic, strong) NSURL *fileUrl;

@end

static StringCalculateManager *manager;

static dispatch_queue_t serialQueue;

@implementation StringCalculateManager

+ (StringCalculateManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[StringCalculateManager alloc] init];
    });
    return manager;
}

- (id) init {
    if (self = [super init]) {
        self.numsNeedToSave = 0;
        [self readFontDictionaryFromDisk];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveFontDictionaryToDisk) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveFontDictionaryToDisk) name:UIApplicationWillTerminateNotification object:nil];
        serialQueue = dispatch_queue_create("com.StringCalculateManager.queue", NULL);
    }
    return self;
}


- (NSURL *)fileUrl {
    if (!_fileUrl) {
        NSArray<NSURL *> *files = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        _fileUrl = files[0];
        [_fileUrl URLByAppendingPathComponent:@"font_dictionary.json"];
        NSLog(@"json文件的路径是------%@",_fileUrl);
    }
    return _fileUrl;
}

- (NSDictionary *)createNewFont:(UIFont *)font {
    NSArray *stringArray = @[@"中", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",  @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"a", @"b", @"c", @"d", @"e", @"f",  @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"“", @";", @"？", @",", @"［", @"]", @"、", @"【", @"】", @"?", @"!", @":", @"|"];
    NSMutableDictionary *widthDictionary = [NSMutableDictionary new];
    CGRect singleWordRect = CGRectZero;
    for (NSString *string in stringArray) {
        singleWordRect = [string boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        [widthDictionary setObject:@(singleWordRect.size.width) forKey:string];
    }
    [widthDictionary setObject:@(singleWordRect.size.height) forKey:@"singleLineHeight"];
    NSString *fontKey = [NSString stringWithFormat:@"%@-%f",font.fontName,font.pointSize];
    [_fontDictionary setObject:widthDictionary forKey:fontKey];
    self.numsNeedToSave = stringArray.count;
    [self saveFontDictionaryToDisk]; //存入本地json
    return widthDictionary;
}
//限定最大行数的场景下计算label的bounds
- (CGRect)calculateSizeWithString:(NSString *)string withMaxWidth:(CGFloat)maxWidth withFont:(UIFont *)font withMaxLine:(NSInteger)maxLine {
    CGFloat totalWidth = [self calculateTotalWidthWithString:string withFont:font];
    NSMutableDictionary *widthDic = [self fetchWidthDictionaryWithFont:font].mutableCopy;
    CGFloat singleLineHeight = [[widthDic objectForKey:@"singleLineHeight"] floatValue];
    CGFloat numsOfLine = ceil(totalWidth/maxWidth);//行数
    CGFloat resultWidth = numsOfLine <= 1?totalWidth:maxWidth;
    CGFloat resultLine = numsOfLine<(CGFloat)maxLine?numsOfLine:maxLine;
    return CGRectMake(0, 0, resultWidth, resultLine*(singleLineHeight));
}
//行数不限的场景下计算Label的bounds
- (CGRect)calculateSizeWithString:(NSString *)string withMaxWidth:(CGFloat)maxWidth withFont:(UIFont *)font {
    CGFloat totalWidth = [self calculateTotalWidthWithString:string withFont:font];
    NSMutableDictionary *widthDic = [self fetchWidthDictionaryWithFont:font].mutableCopy;
    CGFloat singleLineHeight = [[widthDic objectForKey:@"singleLineHeight"] floatValue];
    CGFloat numsOfLine = ceil(totalWidth/maxWidth);
    CGFloat resultWidth = numsOfLine <= 1?totalWidth:maxWidth;
    return CGRectMake(0, 0, resultWidth, numsOfLine*(singleLineHeight));
}
//限定最大高度的场景下计算label的bounds
- (CGRect)calculateSizeWithString:(NSString *)string withMaxSize:(CGSize)maxSize withFont:(UIFont *)font withLine:(NSInteger)maxLine {
    CGFloat totalWidth = [self calculateTotalWidthWithString:string withFont:font];
    NSDictionary *widthDictionary = [self fetchWidthDictionaryWithFont:font];
    CGFloat singleLineHeight = [[widthDictionary objectForKey:@"singleLineHeight"] floatValue];
    CGFloat numberOfLine = ceil(totalWidth/maxSize.width);
    
    CGFloat maxLineCGFloat = floor(maxSize.height/singleLineHeight);
    CGFloat resultwidth = numberOfLine <= 1? totalWidth: maxSize.width;
    CGFloat resultLine = numberOfLine < maxLineCGFloat ?numberOfLine : maxLineCGFloat;
    return CGRectMake(0, 0, resultwidth, resultLine * singleLineHeight);
}

//计算排版在一行的总宽度
- (CGFloat)calculateTotalWidthWithString:(NSString *)string withFont:(UIFont *)font {
    CGFloat totalWidth = 0;
    NSString *fontKey = [NSString stringWithFormat:@"%@-%f",font.fontName,font.pointSize];
    NSMutableDictionary *widthDictionary = [self fetchWidthDictionaryWithFont:font].mutableCopy;
    CGFloat chineseWidth = [[widthDictionary objectForKey:@"中"] floatValue];
    for (int i = 0; i<string.length; i++) {
        NSMutableString *s1 = [[NSMutableString alloc] initWithCapacity:0];
        unichar character = [string characterAtIndex: i];
        [s1 appendFormat:@"\\u%x",character];
        NSLog(@"字符串是------%@",[self replaceUnicode:s1]);//[NSString stringWithFormat:@"\\u%x",character]
        if (0x4e00 <= character && character <= 0x9fff) { //chinese
            totalWidth += chineseWidth;
        } else if ([widthDictionary objectForKey:[self replaceUnicode:s1]]) { //字母和数字
            totalWidth += [[widthDictionary objectForKey:[self replaceUnicode:s1]] floatValue];
        } else {
            NSString *tempString = [NSString stringWithFormat:@"\\u%x",character];
            CGFloat width = [tempString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size.width;
            totalWidth += width;
            [widthDictionary setObject:@(width) forKey:tempString];
            self.numsNeedToSave += 1;
        }
    }
    
    [self.fontDictionary setObject:widthDictionary forKey:fontKey];
    if (self.numsNeedToSave > 10) {
        [self saveFontDictionaryToDisk];
    }
    return totalWidth;
}

//转汉字
- (NSString *)replaceUnicode:(NSString *)unicodeStr {
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString * returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}
//获取字体对应的宽度字典
- (NSDictionary *)fetchWidthDictionaryWithFont:(UIFont *)font {
    NSDictionary *widthDictionary = [NSDictionary new];
    NSString *fontKey = [NSString stringWithFormat:@"%@-%f",font.fontName,font.pointSize];
    NSDictionary *dic = [[StringCalculateManager shareManager].fontDictionary objectForKey:fontKey];
    if (dic) {
        widthDictionary = dic;
    } else {
        widthDictionary = [[StringCalculateManager shareManager] createNewFont:font];
    }
    return widthDictionary;
}

- (void)readFontDictionaryFromDisk {
    NSData *fileData = [[NSData alloc] initWithContentsOfURL:self.fileUrl];
    NSString *json;
    NSError *error;
    if (fileData) {
        json = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingAllowFragments error:&error];
    }
    if (json && !error) {
        _fontDictionary = [[NSMutableDictionary alloc] initWithContentsOfURL:self.fileUrl error:&error];
    }
}

- (void)saveFontDictionaryToDisk {
    if (self.numsNeedToSave == 0) {
        return;
    }
    self.numsNeedToSave = 0;
    
    //防止多线程混乱

    dispatch_async(serialQueue, ^{
        NSData *data;
        if (self.fontDictionary) {
            if (@available(iOS 11.0,*)) {
                data = [NSJSONSerialization dataWithJSONObject:self.fontDictionary options:NSJSONWritingSortedKeys error:nil];
            } else {
                data = [NSJSONSerialization dataWithJSONObject:self.fontDictionary options:NSJSONWritingPrettyPrinted error:nil]
                ;
            }
        }
        if (data) {
            [data writeToURL:self.fileUrl atomically:YES];
        }
    });
}
@end

@implementation NSString (StringHeigh)

- (CGRect)boundingRectFastWithMaxWidth:(CGFloat)width withFont:(UIFont *)font withMaxLine:(NSInteger)maxLine {
    return [[StringCalculateManager shareManager] calculateSizeWithString:self withMaxWidth:width withFont:font withMaxLine:maxLine];
}

- (CGRect)boundingRectFastWithMaxWidth:(CGFloat)width withFont:(UIFont *)font {
    return [[StringCalculateManager shareManager] calculateSizeWithString:self withMaxWidth:width withFont:font];
}

@end
