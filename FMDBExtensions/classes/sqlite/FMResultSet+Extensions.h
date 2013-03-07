//
//  FMResultSet+FMDBExtensions.h
//  BlackBeans
//
//  Created by Kazz.satou on 2013/03/07.
//  Copyright (c) 2013年 BlackBeans. All rights reserved.
//

#import "FMResultSet.h"

@interface FMResultSet (FMDBExtensions)

/**
 * カラム名からカラム値を取得します
 * @params columnName カラム名をセット
 * @params nullHack カラム値が空(nill, NULL, NSNull)だった場合に返す値をセットします
 * @returns id カラムに格納されている値が戻ります
 */
- (id)objectForColumnNameNotNull:(NSString*)columnName nullHack:(id)nullHack; 
/**
 * カラム名からカラム値を文字列で取得します
 * @params columnName カラム名をセット
 * @params nullHack カラム値が空(nill, NULL, NSNull)だった場合に返す値をセットします
 * @returns id カラムに格納されている値が戻ります
 */
- (NSString*)stringForColumnNotNull:(NSString*)columnName nullHack:(id)nullHack;  

@end
