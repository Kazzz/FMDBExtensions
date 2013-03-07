//
//  BBOrderedDictionary.h
//  BlackBeans
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBOrderedDictionary : NSMutableDictionary
{
	NSMutableDictionary *dictionary;
	NSMutableArray *array;
}
@property (strong, nonatomic) id nullHackValue;
- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex;
- (id)keyAtIndex:(NSUInteger)anIndex;
- (NSEnumerator *)reverseKeyEnumerator;
- (NSMutableDictionary *)mutableDeepCopy;

@end
