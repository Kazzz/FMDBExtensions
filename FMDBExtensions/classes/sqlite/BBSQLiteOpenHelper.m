//
//  BBSQLiteOpenHelper.m
//  BlackBeans
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//

#import "BBSQLiteOpenHelper.h"

#import "BBFMDBExtensions.h"
#import "BBLogging.h"

#define OPEN_READONLY  0x00000001
#define OPEN_READ_MASK 0x00000001

@implementation BBSQLiteOpenHelper
{
    int newVersion;
    int flags;
    BOOL isInitializing;
}
- (id)initWithParam:(NSString*)name version:(int)version
{
    if ( version < 1 )
    {
        @throw [[NSException alloc] initWithName:@"IllegalStateException" reason:[[NSString alloc] initWithFormat:@"Version must be >= 1, was %i " arguments:version] userInfo:nil];
    }
    self = [super init];
    
    self.name = name;
    self.db = nil;
    
    newVersion = version;
    isInitializing = NO;
    return self;
}
- (FMDatabase*)getWritableDatabase
{
    if ( self.db && [self.db isOpen] && ![self isReadonly])
    {
        return self.db;
    }
    
    if ( isInitializing )
    {
        @throw [[NSException alloc] initWithName:@"IllegalStateException" reason:@"getWritableDatabase called recursively" userInfo:nil];
    }
    BOOL success = NO;
    FMDatabase* db = nil;
    if ( self.db )
    {
        //[self.db lock]
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [paths objectAtIndex:0];
    @try
    {
        isInitializing = YES;

        NSFileManager* fileManager = [NSFileManager defaultManager];
        //パッケージのメインバンドルにDBファィルが配置されていたらドキュメントにコピーする
        //データインストール用のDBを配布したりテストに使用する
        NSBundle* bundle = [NSBundle mainBundle];
        NSArray* arr = [self.name componentsSeparatedByString:@"."];
        NSString* sourcePath = [bundle pathForResource:[arr objectAtIndex:0]
                                                ofType:[arr objectAtIndex:1]];
        if ( [fileManager fileExistsAtPath:sourcePath])
        {
            //DBファィルパス(コピー先)
            NSString* destPath = [dir stringByAppendingPathComponent:self.name];
            
            if ( ![fileManager fileExistsAtPath:destPath]) //既にある場合コピーしない
            {
                //データベースを上書きコピー
                NSError* err;
                [fileManager removeItemAtPath:destPath error:&err];
                [fileManager copyItemAtPath:sourcePath toPath:destPath error:&err];
            }
            
        }
        
        NSString* dbpath = [dir stringByAppendingPathComponent:self.name];
        db = [FMDatabase databaseWithPath:dbpath];
        
        if ( ![db open] )
        {
            @throw [[NSException alloc] initWithName:@"SQLiteException"
                                              reason:
                    [[NSString alloc] initWithFormat:@"cant not open dataBase error code = %@", [db lastError]] userInfo:nil];
        }
        
        int version = [db getVersion];
        if ( version != newVersion)
        {
            [db beginTransaction];
            @try
            {
                if ( version == 0 )
                {
                    if (self.delegate)
                    {
                        [self.delegate didDatabaseCreated:db];
                    }
                }
                else
                {
                    if (version > newVersion)
                    {
                         LogError(@"Can't downgrade read-only database from version %i to %i : %@",version, newVersion, dbpath);
                    }
                    if (self.delegate)
                    {
                        [self.delegate needDatabaseUpgrade:db oldVersion:version newVersion:newVersion];
                    }
                }
                
                [db setVersion:newVersion];
            }
            @finally
            {
                [db commit];
            }
    
            if ( self.delegate )
            {
                [self.delegate didDatabaseOpened:db];
            }
            success = YES;
        }
        return db;
    }
    @catch (NSException *exception)
    {
        LogError(@"%@", exception);
    }
    @finally
    {
        isInitializing = NO;
        if ( success)
        {
            if ( self.db )
            {
                [self.db close];
            }
            self.db = db;
        }
        else
        {
            if ( db )
            {
                [db close];
            }
        }
    }
}
- (FMDatabase*)getReadableDatabase
{
    if ( self.db && [self.db isOpen] )
    {
        return self.db;
    }
    
    if ( isInitializing )
    {
        @throw [[NSException alloc] initWithName:@"IllegalStateException" reason:@"getReadableDatabase called recursively" userInfo:nil];
    }
    @try {
        return [self getWritableDatabase];
    }
    @catch (NSException *exception) {
        if (!self.name) @throw exception;
        LogError(@"Couldn't open %@ for writing (will try read-only):", self.name);
    }
    
    FMDatabase* db = nil;
    @try
    {
        isInitializing = YES;
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                             , NSUserDomainMask, YES);
        NSString* dir = [paths objectAtIndex:0];
        NSString* dbpath = [dir stringByAppendingPathComponent:self.name];
        db = [FMDatabase databaseWithPath:dbpath];
        
        [db openWithFlags:OPEN_READONLY];
        if ([db getVersion] != newVersion)
        {
            LogError(@"Can't downgrade read-only database from version %i to %i : %@"
                     ,[db getVersion], newVersion, dbpath);
        }
        if ( self.delegate )
        {
            [self.delegate didDatabaseOpened:db];
        }
        LogInfo(@"Opened %@ in read-only mode", self.name);
        self.db = db;
        return self.db;
    }
    @finally
    {
        isInitializing = NO;
        if ( db && db != self.db )
        {
            [db close];
        }
    }
}
- (void)close
{
    if (isInitializing)
    {
        @throw [[NSException alloc] initWithName:@"IllegalStateException"
                                          reason:@"Closed during initialization"
                                        userInfo:nil];
    }
    
    if (self.db != nil && [self.db isOpen])
    {
        [self.db close];
        self.db = nil;
    }

}
- (BOOL)isReadonly
{ 
    return (flags & OPEN_READ_MASK) == OPEN_READONLY ? YES:NO;
}
@end
