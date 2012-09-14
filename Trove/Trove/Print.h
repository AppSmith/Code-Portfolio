//
//  Print.h
//  Trove
//
//  Created by Dana Smith on 9/9/12.
//  Copyright (c) 2012 Dana Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Print : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * recipe;
@property (nonatomic, retain) NSString * url;

@end
