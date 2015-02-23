//
//  UGCTouchTextLabel.h
//  TCTravel_IPhone
//
//  Created by elecCore on 14/11/20.
//
//

#import <UIKit/UIKit.h>
typedef void(^TopicCheckAction)(NSString *TopicName);

@interface ECTouchLabel : UILabel
@property (nonatomic,copy) TopicCheckAction eventTopicCheck;

-(CGSize)sizeToFitWithMaxSize:(CGSize)maxSize;

@end


