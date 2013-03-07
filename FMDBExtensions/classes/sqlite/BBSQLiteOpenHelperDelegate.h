//
//  BBSQLiteOpenHelperDelegate.h
//  BlackBeans
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@protocol BBSQLiteOpenHelperDelegate <NSObject>
/**
 * データーベースが生成された時に一度だけ呼び出されます
 * @param db 生成されたデータベースがセットされます
 */
- (void)didDatabaseCreated:(FMDatabase*)db;
/**
 * データベースにアップグレードが必要な場合に呼び出されます
 * @param db データベースがセットされます
 * @param oldVersion 旧バージョンがセットされます
 * @param newVersion 新バージョンがセットされます
 */
- (void)needDatabaseUpgrade:(FMDatabase*)db oldVersion:(int) oldVersion newVersion:(int) newVersion;
/**
 * データベースがオープンされた時に呼ばれます
 * @param db 生成されたデータベースがセットされます
 */
- (void)didDatabaseOpened:(FMDatabase*)db;
@end
