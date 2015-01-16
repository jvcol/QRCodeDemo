//
//  BarCodeView.m
//  BarcodeEAN13GenDemo
//
//  Created by Strokin Alexey on 8/27/13.
//  Copyright (c) 2013 Strokin Alexey. All rights reserved.
//

static NSString *kInvalidText = @"Invalid barcode!";

static const CGFloat kDigitLabelHeight = 15.0f+10;
static const NSInteger kTotlaBarCodeLength = 113;//113; //never change this

#import "BarCodeView.h"
#import "AppDelegate.h"
#import "BarCodeEAN13.h"

@interface BarCodeView ()
{
   CGFloat horizontalOffest;

	BOOL binaryCode[kTotlaBarCodeLength];
	BOOL validBarCode;
    
    CGFloat linwWidth;
   
   UILabel *firstDigitLabel;
   UILabel *manufactureCodeLabel;
   UILabel *productCodeLabel;
   UILabel *checkSumLabel; // separate label because of sometime UI need it
}

-(BOOL)isValidBarCode:(NSString*)barCode;

-(void)createNumberLabels;

-(UILabel*)labelWithWidth:(CGFloat)aWidth andOffset:(CGFloat)offset
   andValue:(NSString*)aValue;

-(NSString*)firstDigitOfBarCode;
-(NSString*)manufactureCode;
-(NSString*)productCode;
-(NSString *)checkSum;

@end

@implementation BarCodeView

-(id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self != nil) {
      _bgColor = [UIColor whiteColor];
      _drawableColor = [UIColor blackColor];
       horizontalOffest = 0;//(frame.size.width-300)/2;
       linwWidth = 2;
      [self createNumberLabels];
   }
   return self;
}
-(void)setBarCodeNumber:(NSString *)newBarCodeNumber
{
   if (newBarCodeNumber != _barCodeNumber)
   {
      _barCodeNumber = newBarCodeNumber;
		validBarCode = [self isValidBarCode:_barCodeNumber];
      if (validBarCode)
      {
			CalculateBarCodeEAN13(_barCodeNumber, binaryCode);
         [self updateLables];
         [self setNeedsDisplay];
      }
   }
	if (!validBarCode)
	{
		memset(binaryCode, 0, sizeof(binaryCode));
      [self setNeedsDisplay];
	}
}

- (UIImage *)getBarCodeImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [[UIScreen mainScreen] scale]);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)drawRect:(CGRect)rect
{
   CGContextRef c = UIGraphicsGetCurrentContext();
   CGContextClearRect(c, rect);
   if (!validBarCode)
   {
//    draw error
      [_bgColor set];
      CGContextFillRect(c, rect);

      UIFont* font = [UIFont systemFontOfSize:15];
      UIColor* textColor = [UIColor redColor];
   
      NSDictionary* stringAttrs = @{ NSFontAttributeName : font,
         NSForegroundColorAttributeName : textColor };
      NSAttributedString* attrStr = [[NSAttributedString alloc]
         initWithString:kInvalidText attributes:stringAttrs];

      [attrStr drawAtPoint:CGPointMake(3.f, rect.size.height/2-20)];
      return;
   }
//   draw barcode
	CGContextBeginPath(c);
    CGContextSetLineWidth(c, linwWidth);
	for (int i = 0; i < kTotlaBarCodeLength; i++)
	{
   
      [binaryCode[i] ? _drawableColor : _bgColor set];
		CGContextMoveToPoint(c, i*linwWidth+horizontalOffest, 0.0f);
		CGContextAddLineToPoint(c, i*linwWidth+horizontalOffest, self.bounds.size.height);
		CGContextStrokePath(c);
	}
    //   stroke the last line
    [_bgColor set];
    CGContextMoveToPoint(c, kTotlaBarCodeLength, 0.0f);
    CGContextAddLineToPoint(c, kTotlaBarCodeLength, self.bounds.size.height);
    CGContextStrokePath(c);
}

-(BOOL)isValidBarCode:(NSString*)barCode
{
   BOOL valid = NO;
   NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
   NSCharacterSet *inStringSet = [NSCharacterSet
		characterSetWithCharactersInString:barCode];
   if ([alphaNums isSupersetOfSet:inStringSet] && barCode.length == 13)
   {
//      checksum validation
      int sum = 0;
      for (int i = 0; i < 12; i++)
      {
         int m = (i % 2) == 1 ? 3 : 1;
         int value = [barCode characterAtIndex:i] - 0x30;
         sum += (m*value);
      }
      int cs = 10 - (sum % 10);
      if (cs == 10) cs = 0;
      valid = (cs == ([barCode characterAtIndex:12] - 0x30));
      if (!valid) NSLog(@"%@",kInvalidText);
   }
   return valid;
}

-(void)updateLables
{
   firstDigitLabel.text = [self firstDigitOfBarCode];
   manufactureCodeLabel.text = [self manufactureCode];
   productCodeLabel.text = [self productCode];
   checkSumLabel.text = [self checkSum];
}

-(void)createNumberLabels
{
// smoke UI label for better visability
    CGFloat width = self.frame.size.width;
   CGFloat smokeHeight = 6.0f+6;
   UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-smokeHeight, width, smokeHeight)];
   l.backgroundColor = _bgColor;
   [self addSubview:l];
//   
   CGFloat offset = 0;
   CGFloat labelWidth = 7.0f+6;
   firstDigitLabel = [self labelWithWidth:labelWidth andOffset:offset andValue:[self firstDigitOfBarCode]];
   [self addSubview:firstDigitLabel];
   offset += 12+11;
   manufactureCodeLabel = [self labelWithWidth:85 andOffset:offset andValue:[self manufactureCode]];
   [self addSubview:manufactureCodeLabel];
   offset += 93;
   productCodeLabel = [self labelWithWidth:71 andOffset:offset andValue:[self productCode]];
   [self addSubview:productCodeLabel];
   offset += 71;
   checkSumLabel = [self labelWithWidth:labelWidth andOffset:offset andValue:[self checkSum]];
   [self addSubview:checkSumLabel];
}
-(UILabel*)labelWithWidth:(CGFloat)aWidth andOffset:(CGFloat)offset
   andValue:(NSString*)aValue
{
   UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(offset,
      self.bounds.size.height - kDigitLabelHeight, aWidth, kDigitLabelHeight)];
   label.backgroundColor = _bgColor;
//    label.backgroundColor = [UIColor redColor];
   label.textColor = _drawableColor;
   label.textAlignment = NSTextAlignmentCenter;
   label.font = [UIFont boldSystemFontOfSize:kDigitLabelHeight-1];
   label.text = aValue;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 9;
   return label;
}
-(NSString*)firstDigitOfBarCode
{
   return [self.barCodeNumber substringToIndex:1];
}
-(NSString*)manufactureCode
{
   return [self.barCodeNumber substringWithRange:NSMakeRange(1, 6)];
}
-(NSString*)productCode
{
   return [self.barCodeNumber substringWithRange:NSMakeRange(7, 5)];
}
- (NSString *)checkSum
{
   return [_barCodeNumber substringWithRange:NSMakeRange(12, 1)];
}
-(void)setShouldShowNumbers:(BOOL)shouldShowNumbers
{
   for (UILabel *label in self.subviews)
   {
      if ([label isKindOfClass:[UILabel class]]) label.hidden = !shouldShowNumbers;
   }
}
@end
