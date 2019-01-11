//
//  ViewController.m
//  StringCalculate
//
//  Created by 李东岩 on 2019/1/10.
//  Copyright © 2019 李东岩. All rights reserved.
//

#import "ViewController.h"
#import "StringCalculateManager.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UITextField *field;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.numLabel.text = [textField.text stringByAppendingString:string];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.numLabel.frame;
        rect.size.height = [self.numLabel.text boundingRectFastWithMaxWidth:200 withFont:[UIFont systemFontOfSize:17]].size.height;
        rect.size.height = [self.numLabel.text boundingRectFastWithMaxWidth:200 withFont:[UIFont systemFontOfSize:17] withMaxLine:2].size.height;
        NSLog(@"height------%f",rect.size.height);
        self.numLabel.frame = rect;
    }];
    return YES;
}

@end
