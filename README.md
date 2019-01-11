# StringCalculate-OC
计算字符串高度
这个项目是翻译别人的swift项目，方便大家使用。SWIFT:https://github.com/577528249/StringCalculate

## 怎么使用

> 下面是两个类别方法，引入头文件 
> #import "StringCalculateManager.h"
> 直接调用就可

```
/**
* 限定最大行数的场景下，计算label的bounce
**/
- (CGRect)boundingRectFastWithMaxWidth:(CGFloat)width withFont:(UIFont *)font withMaxLine:(NSInteger)maxLine;

/**
* 行数不限的场景下，计算label的bounce
**/
- (CGRect)boundingRectFastWithMaxWidth:(CGFloat)width withFont:(UIFont *)font;

```
