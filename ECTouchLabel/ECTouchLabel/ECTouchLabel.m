//
//  UGCTouchTextLabel.m
//  TCTravel_IPhone
//
//  Created by elecCore on 14/11/20.
//
//

#import "ECTouchLabel.h"
#import <CoreText/CoreText.h>

@interface ECTouchLabel()
@property (nonatomic,strong) NSMutableAttributedString *attributedContent;
@property (nonatomic,assign) CTFrameRef textCTframe;
@property (nonatomic,strong) NSArray    *TopicArr;
@property (nonatomic,strong) NSArray    *TopicRangeArr;
@end

@implementation ECTouchLabel
@synthesize attributedContent;
@synthesize textCTframe;
@synthesize TopicArr;
@synthesize TopicRangeArr;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    [self setNumberOfLines:0];
    [self setTextColor:[UIColor blackColor]];
    [self setUserInteractionEnabled:YES];
    [self.layer setMasksToBounds:YES];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setLineBreakMode:NSLineBreakByWordWrapping];
        [self setNumberOfLines:0];
        [self setTextColor:[UIColor blackColor]];
        [self setUserInteractionEnabled:YES];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setLineBreakMode:NSLineBreakByWordWrapping];
        [self setNumberOfLines:0];
        [self setTextColor:[UIColor blackColor]];
        [self setUserInteractionEnabled:YES];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    TopicArr = [self textFilterTopicArr];

}

-(void)drawRect:(CGRect)rect
{
    //根据UILabel原有的attributedText创建属性文字
    attributedContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    //根据过滤出的话题修改话题文字的颜色
    for (NSString *rangeStr in TopicRangeArr)
    {
        //这里对需要进行点击事件的字符heightlight效果，这里简化解析过程，直接hard code需要heightlight的范围
        [attributedContent addAttribute:@"NSColor" value:[UIColor colorWithRed:0 green:136.0f/255.0f
                                                                          blue:204.0f/255.0f alpha:1]
                                  range:NSRangeFromString(rangeStr)];
    }
    [self setAttributedContent:attributedContent];
    
    //换行模式
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = [self CTLineBreakFormNSLineBreak:self.lineBreakMode];
    //    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    CTParagraphStyleSetting settings[] = {
        lineBreakMode
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    
    
//    // build attributes
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject forKey:(id) ];
//    
//    // set attributes to attributed string
////    [attributedContent addAttributes:attributes range:];
    
    [attributedContent addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)style
                              range:NSMakeRange(0, [attributedContent length])];
    
    self.attributedText = attributedContent;
    
//    [super drawRect:rect];
   
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置context的ctm，用于适应core text的坐标体系
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //设置CTFramesetter
    CTFramesetterRef framesetter =  CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, rect.size.height));
    //创建CTFrame
    textCTframe = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attributedText.length), path, NULL);
    //把文字内容绘制出来
    CTFrameDraw(textCTframe, context);
    
    CGContextRestoreGState(context);
}

//接受触摸事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (textCTframe)
    {
        //获取UITouch对象
        UITouch *touch = [touches anyObject];
        //获取触摸点击当前view的坐标位置
        CGPoint location = [touch locationInView:self];
        
        //获取每一行
        CFArrayRef lines = CTFrameGetLines(textCTframe);
        CGPoint origins[CFArrayGetCount(lines)];
        //获取每行的原点坐标
        CTFrameGetLineOrigins(textCTframe, CFRangeMake(0, 0), origins);
        CTLineRef line = NULL;
        CGPoint lineOrigin = CGPointZero;
        for (int i= 0; i < CFArrayGetCount(lines); i++)
        {
            CGPoint origin = origins[i];
            CGPathRef path = CTFrameGetPath(textCTframe);
            //获取整个CTFrame的大小
            CGRect rect = CGPathGetBoundingBox(path);
            //坐标转换，把每行的原点坐标转换为uiview的坐标体系
            CGFloat y = rect.origin.y + rect.size.height - origin.y;
            //判断点击的位置处于那一行范围内
            if ((location.y <= y) && (location.x >= origin.x))
            {
                line = CFArrayGetValueAtIndex(lines, i);
                lineOrigin = origin;
                break;
            }
        }
        
        location.x -= lineOrigin.x;
        //获取点击位置所处的字符位置，就是相当于点击了第几个字符
        CFIndex index = CTLineGetStringIndexForPosition(line, location);
        //判断点击的字符是否在需要处理点击事件的字符串范围内，这里是hard code了需要触发事件的字符串范围
        for (NSString *rangeStr in TopicRangeArr)
        {
            NSRange TopicRange = NSRangeFromString(rangeStr);
            if (index >= TopicRange.location &&
                index <= TopicRange.location+TopicRange.length)
            {
                if (self.eventTopicCheck)
                {
                    TopicRange.length-=2;
                    TopicRange.location+=1;
                    self.eventTopicCheck([self.text substringWithRange:TopicRange]);
                }
                break;
            }
        }

    }
    
}

//过滤标签range数组
-(NSArray *)textFilterRangeArr
{
    NSMutableArray *rangeArr = [[NSMutableArray alloc] init];
    NSString *filterText = self.text;
    
    NSUInteger beginIndex = 0;
    NSUInteger strLength = 0;
    for (int i = 0 ; i < filterText.length; i++)
    {
        BOOL isFindTopic = NO;
        if ([filterText characterAtIndex:i] == '#')
        {
            beginIndex = i;
            i++;
            for (;i < filterText.length; i++)
            {
                if ([filterText characterAtIndex:i] == '#')
                {
                    strLength = i-beginIndex+1;
                    if (strLength > 2)
                    {
                        isFindTopic = YES;
                    }
                    break;
                }
            }
            if (isFindTopic)
            {
                NSRange range = NSMakeRange(beginIndex, strLength);
                NSString *strRange = NSStringFromRange(range);
                [rangeArr addObject:strRange];
            }
        }
    }
    
    return rangeArr;
}

//过滤话题字符串数组
-(NSArray *)textFilterTopicArr
{
    TopicRangeArr = [[NSArray alloc] init];
    TopicRangeArr = [self textFilterRangeArr];
    NSMutableArray *resultTopicArr = [[NSMutableArray alloc] init];
    NSString *filterText = self.text;

    for (NSString *strRange in TopicRangeArr)
    {
        NSRange range = NSRangeFromString(strRange);
        NSString *TopicName = [filterText substringWithRange:range];
        [resultTopicArr addObject:TopicName];
    }
    
    return resultTopicArr;
}

-(CGSize)sizeToFitWithMaxSize:(CGSize)maxSize
{
    NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:self.font,NSFontAttributeName, nil];
    CGSize size = [self.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              size.width, size.height+3)];
    
    return size;
}

-(CTLineBreakMode)CTLineBreakFormNSLineBreak:(NSLineBreakMode)lineBreakMode
{
    switch(lineBreakMode)
    {
        case NSLineBreakByCharWrapping:
            return kCTLineBreakByCharWrapping;
            break;
        case NSLineBreakByTruncatingHead:
            return kCTLineBreakByTruncatingHead;
            break;
        case NSLineBreakByClipping:
            return kCTLineBreakByClipping;
            break;
        case NSLineBreakByTruncatingMiddle:
            return kCTLineBreakByTruncatingMiddle;
            break;
        case NSLineBreakByTruncatingTail:
            return kCTLineBreakByTruncatingTail;
            break;
        case NSLineBreakByWordWrapping:
            return kCTLineBreakByWordWrapping;
            break;
        default:
            return kCTLineBreakByWordWrapping;
            break;
    }
}

@end
