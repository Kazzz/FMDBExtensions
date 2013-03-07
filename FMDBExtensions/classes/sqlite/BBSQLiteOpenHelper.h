//
//  BBSQLiteOpenHelper.h
//
//  BlackBeans
//  FMDatabaseを利用してandroidライクなSQLiteOpenHelperクラスを提供します
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "BBSQLiteOpenHelperDelegate.h"

@interface BBSQLiteOpenHelper : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) FMDatabase* db;
@property (strong, nonatomic) id<BBSQLiteOpenHelperDelegate> delegate;
/**
 * イニシャライザ
 * @param name DB名をセット
 * @param version DBのバージョン(最初は1)をセット
 * @returns id 本クラスのインスタンスが戻ります
 */
- (id)initWithParam:(NSString*)name version:(int)version;
/**
 * 書き込み可能なデータベースを取得します
 * @returns FMDatabase 生成したFMDatabaseクラスのインスタンスが戻ります
 */
- (FMDatabase*)getWritableDatabase;
/**
 * 読み込み可能なデータベースを取得します
 * @returns FMDatabase 生成したFMDatabaseクラスのインスタンスが戻ります
 */
- (FMDatabase*)getReadableDatabase;
/**
 * データベースをクローズします
 */
- (void)close;

@end
