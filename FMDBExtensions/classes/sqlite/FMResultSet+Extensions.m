//
//  FMResultSet+FMDBExtensions.m
//  BlackBeans
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//

#import "BBFMDBExtensions.h"

@implementation FMResultSet (FMDBExtensions)

- (NSString*)stringForColumnNotNull:(NSString*)columnName nullHack:(id)nullHack  
{
    NSString* result = [self stringForColumnIndex:[self columnIndexForName:columnName]];
    return (result == nil || result == NULL )
        ? nullHack
        : result;
}

- (id)objectForColumnNameNotNull:(NSString*)columnName nullHack:(id)nullHack 
{
    id result = [self objectForColumnIndex:[self columnIndexForName:columnName]];
    return (result == nil || result == NULL || result == [NSNull null] )
       ? nullHack
       : result;
}

@end
