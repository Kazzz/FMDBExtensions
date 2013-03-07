//
//  FMDatabase+FMDBExtensions.m
//  BlackBeans
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.

#import "BBFMDBExtensions.h"
#import "BBOrderedDictionary.h"

@implementation FMDatabase (FMDBExtensions)

- (BOOL)isOpen
{
    return [self sqliteHandle] ? YES:NO;
}
- (BOOL)isClose
{
    return [self sqliteHandle] ? NO:YES;
}
- (int)getVersion
{
    BOOL innerCloseContext = [self isClose];
    @try
    {
            //query for obtain version
            NSString* commandForVersion = @"PRAGMA user_version;";
            @try
            {
                return [self intForQuery:commandForVersion];
            }
            @catch (NSException* e)
            {
                [self logDBError:commandForVersion];
            }
    }
    @finally
    {
        if (innerCloseContext) [self close];
    }
}
- (void)setVersion:(int)version;
{
    BOOL innerCloseContext = [self isClose];
    @try
    {
        //command for set version
        NSString* commandForSetVersion =
            [[NSString alloc] initWithFormat:@"PRAGMA user_version = %i", version];
        @try
        {
            [self executeUpdate:commandForSetVersion];
        }
        @catch (NSException* e)
        {
            [self logDBError:commandForSetVersion];
        }
    }
    @finally
    {
        if (innerCloseContext) [self close];
    }
}

- (int)rowCount:(NSString*)tableName columnName:(NSString*)columnName whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs

{
    BOOL innerCloseContext = [self isClose];
    
    if (innerCloseContext) [self open];
    @try
    {
        if ([self tableExists:tableName])
        {
            //query for record counting
            NSString* sqlForCount = (whereClause)
              ? [[NSString alloc] initWithFormat:
                                     @"SELECT count(%@) as cnt from %@ WHERE %@"
                                     , columnName, tableName, whereClause]
              : [[NSString alloc] initWithFormat:
                                     @"SELECT count(%@) as cnt from %@"
                                     , columnName, tableName]; 
            
            @try 
            {
                FMResultSet* resultSet = (whereArgs) 
                  ? [self executeQuery:sqlForCount withArgumentsInArray:whereArgs]
                  : [self executeQuery:sqlForCount];
                if (![resultSet next]) 
                { 
                    return 0; 
                }                           
                return [resultSet intForColumn:@"cnt"];
            }
            @catch (NSException* e)
            {
                [self logDBError:sqlForCount];
            }            
        }
        else
        {
            @throw [[NSException alloc]initWithName:@"BBArgumentException" 
                 reason:[[NSString alloc]initWithFormat:@"Table:'%@' not exist."
                         , tableName] userInfo:nil];
        }
    }
    @finally 
    {
        if (innerCloseContext) [self close];
    }
    
}

- (BOOL)deleteAllRows:(NSString*)tableName
{
    BOOL innerCloseContext = [self isClose];

    if (innerCloseContext) [self open];
    @try
    {
        if ([self tableExists:tableName])
        {
            NSString* sql = 
            [[NSString alloc] initWithFormat:@"DELETE FROM %@", tableName];
            
            //[self beginTransaction];
            
            @try 
            {
                BOOL result = [self executeUpdate:sql];
                if (!result)
                {
                    [self logDBError:sql];
                }
                return result;//[self commit];
            }
            @catch (NSException* e)
            {
                [self logDBError:sql];
                [self rollback];
            }            
        }
        else
        {
            return NO;
        }
    }
    @finally 
    {
        if (innerCloseContext) [self close];
    }
    
}
- (long)insert:(NSString*)tableName nullColumnHack:(NSString*)nullColumnHack values:(NSMutableDictionary*)values;
{
    BOOL innerCloseContext = [self isClose];
    
    if (innerCloseContext) [self open];
    @try
    {
        if ([self tableExists:tableName])
        {
            //building SQL from parameter
            BBOrderedDictionary* orderedDic = 
                [[BBOrderedDictionary alloc]initWithDictionary:values];
            NSMutableArray* values = [[NSMutableArray alloc] init];
            
            NSMutableString* sql = [[NSMutableString alloc]init];
            [sql appendFormat:@"INSERT INTO %@ (",tableName];
            
            //building column1,,2,,
            for (NSString* key in orderedDic.allKeys)
            {
                id value = [orderedDic objectForKey:key];
                if ( value == nil || value == NULL)
                {
                    if ( nullColumnHack )
                    {
                        [values addObject:nullColumnHack];
                    }
                }
                else
                {
                    if ( value )
                    {
                        
                        if ( value == [NSNull null])
                        {
                            //NOOP
                        }
                        else
                        {
                            [sql appendFormat:@"%@,", key];
                            [values addObject:value];
                        }
                    }
                    /*
                    else
                    {
                        [values addObject:nullColumnHack];
                    }
                    */
                }
            }
            [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
            [sql appendString:@") VALUES ("];
             
            //パラメタ値から実引数部分を構成 
            for (id val in values)
            {
                if ( [val isKindOfClass:NSString.class] )
                {
                    [sql appendFormat:@"'%@',", [val stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
                }
                else
                {
                    [sql appendFormat:@"'%@',", val];
                }
            }
            
            [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
            [sql appendString:@")"];

            //[self beginTransaction];
            @try 
            {
               LogDebug(@"executeUpdate sql = %@ ", sql);
               BOOL done = [self executeUpdate:sql];
                if (!done)
                {
                    [self logDBError:sql];
                    [self rollback];
                    return 0;
                }
                //[self commit];
                
                return [self lastInsertRowId];
            }
            @catch (NSException* e)
            {
                [self logDBError:sql];
                @throw e;
                //[self rollback];
            }            
        }
        else
        {
            @throw [[NSException alloc]initWithName:@"BBArgumentException" 
                 reason:[[NSString alloc]initWithFormat:@"Table:'%@' not exist."
                         , tableName] userInfo:nil];
        }
    }
    @finally 
    {
        if (innerCloseContext) [self close];
    }
    
}
- (int)delete:(NSString*)tableName whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs
{
    BOOL innerCloseContext = [self isClose];
    
    if (innerCloseContext) [self open];
    @try
    {
        if ([self tableExists:tableName])
        {
            NSString* sql = [[NSString alloc] initWithFormat:
                             @"DELETE FROM %@ WHERE %@"
                             , tableName, whereClause];
            
            //[self beginTransaction];
            @try 
            {
                LogDebug(@"executeUpdate sql = %@ bindParams = %@", sql, whereArgs);
                BOOL done = [self executeUpdate:sql withArgumentsInArray:whereArgs];
                if (!done)
                {
                    [self logDBError:sql];
                    //[self rollback];
                    return 0;
                }
                //[self commit];
                
                return [self changes];
            }
            @catch (NSException* e)
            {
                [self logDBError:sql];
                @throw e;
                //[self rollback];
            }            
        }
        else
        {
            @throw [[NSException alloc]initWithName:@"BBArgumentException" 
                 reason:[[NSString alloc]initWithFormat:@"Table:'%@' not exist."
                         , tableName] userInfo:nil];
        }
    }
    @finally 
    {
        if (innerCloseContext) [self close];
    }
    
}

- (int)update:(NSString*)tableName values:(NSMutableDictionary*)values whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs
{
    BOOL innerCloseContext = [self isClose];
    
    if (innerCloseContext) [self open];
    @try
    {
        if ([self tableExists:tableName])
        {
            //パラメタからSQL構成
            BBOrderedDictionary* orderedDic =
                [[BBOrderedDictionary alloc] initWithDictionary:values];
            NSMutableArray* arguments = [[NSMutableArray alloc] init];
            
            NSMutableString* sql = [[NSMutableString alloc]init];
            [sql appendFormat:@"UPDATE %@ SET ",tableName];
            
            // キー部から (カラム1=値1, カラム2=値2,,, )を構成
            for (NSString* key in orderedDic.allKeys)
            {
                id value = [orderedDic objectForKey:key];
                
                if ( value == nil || value == NULL) //value == [NSNull null]
                {
                    @throw [[NSException alloc]initWithName:@"BBArgumentException" 
                                                     reason:@"sql parameter value must be Object Type"
                                                   userInfo:nil];
                }
                else
                {
                    [sql appendFormat:@"%@ = ?,", key];
                    [arguments addObject:value];
                }
            }
            [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
            if ( whereClause )
            {
                [sql appendString:[[NSString alloc] initWithFormat:@" WHERE %@", whereClause]];
                [arguments addObjectsFromArray:whereArgs];
            }
            //[self beginTransaction];
            @try 
            {
                LogDebug(@"executeUpdate sql = %@ bindParams = %@", sql, arguments);

                BOOL done = (arguments && arguments.count > 0)
                    ? [self executeUpdate:sql withArgumentsInArray:arguments]
                    : [self executeUpdate:sql];
                if (!done)
                {
                    [self logDBError:sql];
                    //[self rollback];
                    return 0;
                }
                //[self commit];
                
                return [self changes];
            }
            @catch (NSException* e)
            {
                [self logDBError:sql];
                //[self rollback];
                @throw e;
            }            
        }
        else
        {
            @throw [[NSException alloc]initWithName:@"BBArgumentException" 
                 reason:[[NSString alloc]initWithFormat:@"Table:'%@' not exist."
                         , tableName] userInfo:nil];
        }
    }
    @finally 
    {
        if (innerCloseContext) [self close];
    }
    
}
- (FMResultSet*)query:(NSString*)tableName columns:(NSArray*)columns selection:(NSString*)selection selectionArgs:(NSArray*)selectionArgs groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy
{
    return [self query:tableName distinct:NO columns:columns selection:selection selectionArgs:selectionArgs groupBy:groupBy having:having orderBy:orderBy limit:nil offset:nil];
}
- (FMResultSet*)query:(NSString*)tableName distinct:(BOOL)distinct columns:(NSArray*)columns selection:(NSString*)selection selectionArgs:(NSArray*)selectionArgs groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy limit:(NSString*)limit offset:(NSString*)offset
{
    BOOL innerCloseContext = [self isClose];
    
    if (innerCloseContext) [self open];
    @try
    {
        if ([self tableExists:tableName])
        {
            //パラメタからSQL構成
            NSMutableString* sql = [[NSMutableString alloc]init];
            
            //distinctの指定
            if (distinct)
            {
                [sql appendString:@"SELECT DISTINCT "];
            }
            else
            {
                [sql appendString:@"SELECT "];
            }
            
            //カラム名の列挙
            if ( columns )
            {
                NSMutableString* columnsList = [[NSMutableString alloc]init];
                for (NSString* c in columns)
                {
                    [columnsList appendFormat:@" %@,", c];
                }
                [columnsList deleteCharactersInRange:
                             NSMakeRange(columnsList.length-1, 1)];
                [sql appendFormat:@"%@ FROM %@", columnsList, tableName];
            }
            else
            {
                [sql appendFormat:@"* FROM %@", tableName];
            }
            
            //WHERE条件のセット
            if ( selection )
            {
                [sql appendFormat:@" WHERE %@", selection];
            }
            
            //groupBy句の構成
            if ( groupBy )
            {
                [sql appendFormat:@" GROUP BY %@", groupBy];
            }
            //orderBy条件の構成
            if ( orderBy )
            {
                [sql appendFormat:@" ORDER BY %@", orderBy];
            }
            //having条件の構成
            if ( having )
            {
                [sql appendFormat:@" HAVING %@", having];
            }
            //limit句の指定
            if ( limit )
            {
                [sql appendFormat:@" LIMIT %@", limit];
            }
            //offset句の指定　
            if ( offset )
            {
                [sql appendFormat:@" OFFSET %@", offset];
            }
            
            //[self beginTransaction];
            @try 
            {
                LogDebug(@"executeQuery sql = %@ bindParams = %@", sql, selectionArgs);
                
                FMResultSet* result = (selection && selectionArgs) 
                    ? [self executeQuery:sql withArgumentsInArray:selectionArgs]
                    : [self executeQuery:sql];
                //[self commit];
                
                return result;
            }
            @catch (NSException* e)
            {
                [self logDBError:sql];
                //[self rollback];
            }            
        }
        else
        {
            @throw [[NSException alloc]initWithName:@"BBArgumentException" 
                reason:[[NSString alloc]initWithFormat:@"Table:'%@' not exist."
                        , tableName] userInfo:nil];
        }
    }
    @finally 
    {
        //if (innerCloseContext) [self close];
    }
}
- (void)bb_logDebug:(NSString*)sql;
{
    LogDebug(@"** SQLite Execute Error SQL: %@", sql);
    LogDebug(@"**                ErrorCode: %d", self.lastErrorCode);
    LogDebug(@"**                LastError: %@", self.lastError);
}
- (void)logDBError:(NSString*)sql;
{
    LogError(@"** SQLite Execute Error SQL: %@", sql);
    LogError(@"**                ErrorCode: %d", self.lastErrorCode);
    LogError(@"**                LastError: %@", self.lastError);
}
- (void)open:(void (^)(void))contextBlock
{
    [self open:contextBlock flags:0];
}
- (void)open:(void (^)(void))contextBlock flags:(int)flags
{
    BOOL innerCloseContext = [self isClose];
    
    @try
    {
        if (innerCloseContext)
        {
            if ( flags )
            {
                if ([self openWithFlags:flags])
                {
                    contextBlock();
                }
            }
            else
            {
                if ([self open])
                {
                    contextBlock();
                }
            }
        }
        else
        {
            contextBlock();
        }
    }
    @finally {
        if (innerCloseContext) [self close];
    }
}
- (void)openWithTransaction:(void (^)(void))contextBlock
{
    [self openWithTransaction:contextBlock flags:0];
}
- (void)openWithTransaction:(void (^)(void))contextBlock flags:(int)flags
{
    BOOL innerCloseContext = [self isClose];

    @try 
    {
        if (innerCloseContext)
        {
            if (flags)
            {
                if ([self openWithFlags:flags])
                {
                    [self beginTransaction];
                    @try {
                        contextBlock();
                        [self commit];
                    }
                    @catch (NSException *exception) {
                        [self rollback];
                    }
                }
            }
            else
            {
                if ([self open])
                {
                    [self beginTransaction];
                    @try {
                        contextBlock();
                        [self commit];
                    }
                    @catch (NSException *exception) {
                        [self rollback];
                    }
                }
            }
        }
        else
        {
            [self beginTransaction];
            @try {
                contextBlock();
                [self commit];
            }
            @catch (NSException *exception) {
                [self rollback];
            }
        }
    }
    @finally {
        if (innerCloseContext) [self close];
    }    
}
@end
