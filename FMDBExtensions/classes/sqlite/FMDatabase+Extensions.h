//
//  FMDatabase+FMDBExtensions.h
//  BlackBeans
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface FMDatabase (FMDBExtensions)

/**
 * データベースがオープン中か検査します
 * @returns BOOL オープンしている場合はYESが戻ります
 */
- (BOOL)isOpen;
/**
 * データベースがクローズ中か検査します
 * このメッセージはisOpenのnotとなります
 */
- (BOOL)isClose;
/**
 * 問合せ結果の行数を取得します
 * @param tableName テーブル名をセット
 * @param columnName 件数を調べる対象のカラム名をセット
 * @param whereClause Where句をセット
 * @param whereArgs Where句の引数にセットするパラメタをセット
 * @return int 結果の行数が戻ります
 */
- (int)rowCount:(NSString*)tableName columnName:(NSString*)columnName whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs;

/**
 * テーブルの行全てを削除する
 * @param tableName テーブル名をセット
 * @return BOOL 処理が成功したらYESを戻す
 */
- (BOOL)deleteAllRows:(NSString*)tableName;

/**
 * テーブルに行を挿入する
 * @param tableName テーブル名をセット
 * @param nullColumnHack 非NULLカラム値が空だった場合にセットするを記述する
 * @param values カラム名、値で構成される辞書をセット
 * @return long 挿入された行のIDが戻る
 */
- (long)insert:(NSString*)tableName nullColumnHack:(NSString*)nullColumnHack values:(NSMutableDictionary*)values;
/**
 * テーブルの任意の行を削除する
 * @param tableName テーブル名をセット
 * @param whereClause where句の条件を記述する
 * @param whereArgs Where句の条件に渡す引数をセットする
 * @return int 削除された行数を戻す
 */
- (int)delete:(NSString*)tableName whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs;

/**
 * テーブルの任意の行を更新する
 * @param tableName テーブル名をセット
 * @param values カラム名、値で構成される辞書をセット
 * @param whereClause where句の条件を記述する
 * @param whereArgs Where句の条件に渡す引数をセットする
 * @return int 削除された行数を戻す
 */
- (int)update:(NSString*)tableName values:(NSMutableDictionary*)values whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs;
/**
 * テーブルに対してクエリを実行する
 * @param tableName テーブル名をセット
 * @param columns 結果に含むカラム名の配列をセット
 * @param selection 検索条件(WHERE句)をセット
 * @param selectionArgs 検索条件のパラメタを置換する実引数をセット
 * @param groupBy groupBy句の条件を記述する
 * @param having having句を記述する
 * @param orderBy orderBy句の条件を記述する
 * @return FMResultSet* 結果セットが戻ります
 */
- (FMResultSet*)query:(NSString*)tableName columns:(NSArray*)columns selection:(NSString*)selection selectionArgs:(NSArray*)selectionArgs groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy;  
/**
 * テーブルに対してクエリを実行する
 * @param tableName テーブル名をセット
 * @param columns 結果に含むカラム名の配列をセット
 * @param distinct 同一行を畳むdistinctを指定する場合はYESをセット
 * @param selection 検索条件(WHERE句)をセット
 * @param selectionArgs 検索条件のパラメタを置換する実引数をセット
 * @param groupBy groupBy句の条件を記述する
 * @param having having句の条件を記述する
 * @param orderBy orderBy句の条件を記述する
 * @param limit limit句を記述する
 * @param offset offset句を記述する
 * @return FMResultSet* 結果セットが戻ります
 */
- (FMResultSet*)query:(NSString*)tableName distinct:(BOOL)distinct columns:(NSArray*)columns selection:(NSString*)selection selectionArgs:(NSArray*)selectionArgs groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy limit:(NSString*)limit offset:(NSString*)offset;  

/**
 * DB操作時のエラーをログに記録する
 * @param sql 実行に使用したSQLをセット
 */
- (void)logDBError:(NSString*)sql;
/**
 * DBをオープンして処理を実行後クローズします
 * @param contextBlock 実行する処理ブロックをセット
 */
- (void)open:(void (^)(void))contextBlock;
/**
 * DBをオープンして処理を実行後クローズします
 * @param contextBlock 実行する処理ブロックをセット
 * @param flags DBをオープンする際のフラグをセット
 */
- (void)open:(void (^)(void))contextBlock flags:(int)flags;
/**
 * DBをオープンしてトランザクション開始〜処理を実行後コミットしてクローズします
 * @param contextBlock 実行する処理ブロックをセット
 */
- (void)openWithTransaction:(void (^)(void))contextBlock;

/**
 * DBをオープンしてトランザクション開始〜処理を実行後コミットしてクローズします
 * @param contextBlock 実行する処理ブロックをセット
 * @param flags DBをオープンする際のフラグをセット
 */
- (void)openWithTransaction:(void (^)(void))contextBlock flags:(int)flags;

/**
 * DBのユーザーバージョンを取得します
 * @returns int バージョン番号が戻ります 0:生成直後 1,2::バージョン番号
 */
- (int)getVersion;
/**
 * DBのユーザバージョンを設定します
 * @param version バージョンをセットします
 */
- (void)setVersion:(int)version;

@end

