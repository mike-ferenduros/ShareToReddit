//
//  STRImgur.h
//  ShareToReddit
//
//  Created by Michael Ferenduros on 01/10/2013.
//  Copyright (c) 2013 Michael Ferenduros. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STRImgur : NSObject

+ (void)uploadImage:(UIImage*)img progress:(void(^)(float))progress completion:(void(^)(NSURL*,NSError*))completion;

@end
