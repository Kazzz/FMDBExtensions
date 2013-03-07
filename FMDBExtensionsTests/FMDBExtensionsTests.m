//
//  FMDBExtensionTests.m
//  FMDBExtensionTests
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>

#import "BBFMDBExtensions.h"

#define TEST_DATABASE_NAME @"database_test.db"
#define TEST_VERSION 1
#define TEST_ILLEGAL_VERSION 0

#define TBL_NAME @"test_table"
#define COL_USER_ID @"userid"
#define COL_YEAR_MONTH @"yearMonth"
#define COL_DAY @"day"

@interface Test_SQLiteUtil : SenTestCase
{
    BBSQLiteOpenHelper* openHelper;
}
@end
@implementation Test_SQLiteUtil
- (void)setUp
{
    [super setUp];
    openHelper = [[BBSQLiteOpenHelper alloc] initWithParam:TEST_DATABASE_NAME version:TEST_VERSION];
}

- (void)tearDown
{
    [super tearDown];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString* dir = [paths objectAtIndex:0];
    NSString* dbPath = [dir stringByAppendingPathComponent:TEST_DATABASE_NAME];

    NSFileManager* fileManager = [NSFileManager defaultManager];


    if ( [fileManager fileExistsAtPath:dbPath])
    {
        NSError* err;
        [fileManager removeItemAtPath:dbPath error:&err];
    }

}

- (void)test_Constructor
{
    openHelper = [[BBSQLiteOpenHelper alloc] initWithParam:TEST_DATABASE_NAME version:TEST_VERSION];
    STAssertNotNil(openHelper, nil);
}
- (void)test_GetDataBase
{
    FMDatabase* db = nil;
    //readable database
    db = [openHelper getReadableDatabase];
    STAssertTrue([db isOpen], nil);

    FMDatabase* db2 = [openHelper getWritableDatabase];
    STAssertTrue(db == db2, nil);
    STAssertTrue([db isOpen], nil);

    [openHelper close];
    STAssertFalse([db isOpen], nil);

}

- (void)test_CreateTable
{
    FMDatabase* db = [openHelper getWritableDatabase];

    [db openWithTransaction:^(void)
     {
         NSString* sql = [[NSString alloc]initWithFormat:
                          @"CREATE TABLE IF NOT EXISTS %@("
                          "%@ TEXT NOT NULL, "
                          "%@ TEXT NOT NULL, "
                          "%@ TEXT NOT NULL, "
                          "PRIMARY KEY(%@, %@, %@)"
                          ");"
                          , TBL_NAME
                          , COL_USER_ID
                          , COL_YEAR_MONTH
                          , COL_DAY
                          , COL_USER_ID, COL_YEAR_MONTH, COL_DAY
                          ] ;

         [db executeUpdate:sql];
     }];

    STAssertTrue([db tableExists:TBL_NAME] , nil);
    STAssertTrue([db columnExists:COL_USER_ID inTableWithName:TBL_NAME] , nil);
    STAssertTrue([db columnExists:COL_YEAR_MONTH inTableWithName:TBL_NAME] , nil);
    STAssertTrue([db columnExists:COL_DAY inTableWithName:TBL_NAME] , nil);
}
- (void)test_RemoveTable
{
    FMDatabase* db = [openHelper getWritableDatabase];

    [db openWithTransaction:^(void)
     {
         NSString* sql = [[NSString alloc]initWithFormat:
                          @"CREATE TABLE IF NOT EXISTS %@("
                          "%@ TEXT NOT NULL, "
                          "%@ TEXT NOT NULL, "
                          "%@ TEXT NOT NULL, "
                          "PRIMARY KEY(%@, %@, %@)"
                          ");"
                          , TBL_NAME
                          , COL_USER_ID
                          , COL_YEAR_MONTH
                          , COL_DAY
                          , COL_USER_ID, COL_YEAR_MONTH, COL_DAY
                          ] ;

         [db executeUpdate:sql];
     }];

    STAssertTrue([db tableExists:TBL_NAME] , nil);
    STAssertTrue([db columnExists:COL_USER_ID inTableWithName:TBL_NAME] , nil);
    STAssertTrue([db columnExists:COL_YEAR_MONTH inTableWithName:TBL_NAME] , nil);
    STAssertTrue([db columnExists:COL_DAY inTableWithName:TBL_NAME] , nil);

    [db openWithTransaction:^(void)
     {
         NSString* sql = [[NSString alloc]initWithFormat:@"DROP TABLE %@", TBL_NAME];
         [db executeUpdate:sql];
     }];
    STAssertFalse([db tableExists:TBL_NAME] , nil);
}
- (void)test_CRUDRecord
{
    FMDatabase* db = [openHelper getWritableDatabase];

    [db openWithTransaction:^(void)
     {
         NSString* sql = [[NSString alloc]initWithFormat:
                          @"CREATE TABLE IF NOT EXISTS %@("
                          "%@ TEXT NOT NULL, "
                          "%@ TEXT NOT NULL, "
                          "%@ TEXT NOT NULL, "
                          "PRIMARY KEY(%@, %@)"
                          ");"
                          , TBL_NAME
                          , COL_USER_ID
                          , COL_YEAR_MONTH
                          , COL_DAY
                          , COL_USER_ID, COL_YEAR_MONTH
                          ] ;

         [db executeUpdate:sql];
     }];

    //insert
    __block long result = 0;
    [db openWithTransaction:^(void)
     {
         NSMutableDictionary* valuesAndKeys =
          [@{COL_USER_ID   : @"Kazzz"
           , COL_YEAR_MONTH: @"201303"
           , COL_DAY       : @"01"} mutableCopy];

         result = [db insert:TBL_NAME nullColumnHack:nil values:valuesAndKeys];
     }];

    //query after insert
    [db open:
     ^{
         NSString* sql = [[NSString alloc] initWithFormat:@"SELECT * from %@ WHERE %@ = ?"
                          , TBL_NAME, COL_USER_ID];
         FMResultSet* rs = [db executeQuery:sql, @"Kazzz"];

         BOOL rsResult = (rs.next);
         STAssertTrue(rsResult, nil);

         STAssertEqualObjects([rs stringForColumn:COL_USER_ID], @"Kazzz", nil);
         STAssertEqualObjects([rs stringForColumn:COL_YEAR_MONTH], @"201303", nil);
         STAssertEqualObjects([rs stringForColumn:COL_DAY], @"01", nil);
     }];

    //update
    result = 0;
    [db openWithTransaction:
     ^{
         NSMutableDictionary* valuesAndKeys =
         [@{COL_DAY : @"02"} mutableCopy];

         result = [db update:TBL_NAME values:valuesAndKeys
                    whereClause:[[NSString alloc] initWithFormat: @"%@ = ? and %@ = ?", COL_USER_ID, COL_YEAR_MONTH]
                      whereArgs:@[@"Kazzz", @"201303"]];
     }];

    //query after update
    [db open:
     ^{
         NSString* sql = [[NSString alloc] initWithFormat:@"SELECT * from %@ WHERE %@ = ? and %@ = ?", TBL_NAME, COL_USER_ID, COL_YEAR_MONTH];
         FMResultSet* rs = [db executeQuery:sql, @"Kazzz", @"201303"];

         BOOL rsResult = (rs.next);
         STAssertTrue(rsResult, nil);

         STAssertEqualObjects([rs stringForColumn:COL_USER_ID], @"Kazzz", nil);
         STAssertEqualObjects([rs stringForColumn:COL_YEAR_MONTH], @"201303", nil);
         STAssertEqualObjects([rs stringForColumn:COL_DAY], @"02", nil);
     }];

    //remove
    [db openWithTransaction:
     ^{
         [db delete:TBL_NAME
           whereClause:[[NSString alloc] initWithFormat: @"%@ = ? and %@ = ? and %@ = ?"
                        , COL_USER_ID, COL_YEAR_MONTH, COL_DAY]
             whereArgs:@[@"Kazzz", @"201303", @"02"]];

     }];

    //query after remove
    [db open:
     ^{
         NSString* sql = [[NSString alloc] initWithFormat:@"SELECT * from %@ WHERE %@ = ? and %@ = ?", TBL_NAME, COL_USER_ID, COL_YEAR_MONTH];
         FMResultSet* rs = [db executeQuery:sql, @"Kazzz", @"201303"];

         BOOL rsResult = (rs.next);
         STAssertFalse(rsResult, nil);
     }];

}

@end
