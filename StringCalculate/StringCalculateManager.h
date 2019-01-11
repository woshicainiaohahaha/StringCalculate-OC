//
//  StringCalculateManager.h
//  StringCalculate
//
//  Created by 李东岩 on 2019/1/10.
//  Copyright © 2019 李东岩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (StringHeigh)

/**
 * 限定最大行数的场景下，计算label的bounce
 **/
- (CGRect)boundingRectFastWithMaxWidth:(CGFloat)width withFont:(UIFont *)font withMaxLine:(NSInteger)maxLine;

/**
 * 行数不限的场景下，计算label的bounce
 **/
- (CGRect)boundingRectFastWithMaxWidth:(CGFloat)width withFont:(UIFont *)font;

@end


@interface StringCalculateManager : NSObject

+ (StringCalculateManager *)shareManager;

@end


NS_ASSUME_NONNULL_END
