#FMDBExtensions
FMDBExtensionsはiOSのSQLite用ライブラリィであるFMDBとandroidのSQLiteDatabaseクラスにインスパイアされて書いた、iOSのSQLiteデータベース用ライブラリィです。



## 経緯
iOSのアプリケーションを開発する際にSQLiteデーターペースを扱うための高次のライブラリィが提供されていない所に、FMDBというオープンソースライブラリィがあることを知り、便利に使わせて頂きました。

ccgus/fmdb:
<https://github.com/ccgus/fmdb>

一方でandroidでSQLiteにアクセスする際にはSDK標準で提供されているSQLiteDatabaseクラスを使用してました。SQLをあまり意識せずに使える一連のAPI群は非常に便利であり、生のSQLを書くのが嫌いな私はandroidと同様の使い勝手をFMDBに求めました。それがFMDBExtensionsのきっかけです。


## 前提条件
FMDBを使える環境とFMDB本体(Xcode、ARC下での開発を前提にしています。)
私はARC,Blocksが有効になった以降にiOSのプログラミングを開始しているためにARCを前提にしています。

## 提供するもの
FMDBExtensionsはFMDatabaseクラスとFMResultSetのカテゴリとして拡張機能を提供します。

### FMDBExtensions
FMDBExtensionsを使用する場合はこのヘッダをimportします

###FMDatabase+FMDBExtensions
FMDatabaseの機能を拡張します

    - (BOOL)isOpen;
    - (BOOL)isClose;
    - (int)rowCount:(NSString*)tableName columnName:(NSString*)columnName whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs;
    - (BOOL)deleteAllRows:(NSString*)tableName;
    - (long)insert:(NSString*)tableName nullColumnHack:(NSString*)nullColumnHack values:(NSMutableDictionary*)values;
    - (int)delete:(NSString*)tableName whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs;
    - (int)update:(NSString*)tableName values:(NSMutableDictionary*)values whereClause:(NSString*)whereClause whereArgs:(NSArray*)whereArgs;
    - (FMResultSet*)query:(NSString*)tableName columns:(NSArray*)columns selection:(NSString*)selection selectionArgs:(NSArray*)selectionArgs groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy;
    - (FMResultSet*)query:(NSString*)tableName distinct:(BOOL)distinct columns:(NSArray*)columns selection:(NSString*)selection selectionArgs:(NSArray*)selectionArgs groupBy:(NSString*)groupBy having:(NSString*)having orderBy:(NSString*)orderBy limit:(NSString*)limit offset:(NSString*)offset;
    - (void)logDBError:(NSString*)sql;
    - (void)open:(void (^)(void))contextBlock;
    - (void)open:(void (^)(void))contextBlock flags:(int)flags;
    - (void)openWithTransaction:(void (^)(void))contextBlock;
    - (void)openWithTransaction:(void (^)(void))contextBlock flags:(int)flags;
    - (int)getVersion;
    - (void)setVersion:(int)version;

ヘッダに書かれているコメントとテスト(FMDBExtensionsTests)をみれば見れば、FMDBを知っているプログラマの方であれば何をしているかは大体分かると思います。

### FMResultSet+FMDBExtensions
FMResultSetを拡張します

    - (id)objectForColumnNameNotNull:(NSString*)columnName nullHack:(id)nullHack;
    - (NSString*)stringForColumnNotNull:(NSString*)columnName nullHack:(id)nullHack;

同上です。

### BBSQLiteOpenHelper
androidのSQLiteOpenHelperと同様のヘルパクラスを提供します。イニシャライザで指定された名前のデータベースがパッケージバンドルにあれば、それをDocumentディレクトリにコピーするという前処理を行います。邪魔な場合は消すかオーバライドして使います。

androidに存在しているデータベースのロック機能は未だ実装していません。必要であれば書くかもしれません。


### FMDBExtensions使い方の例
Blocksを使ってデータベースのコンテキストブロックを構成できるようになっていますので、以下のようにcloseを省略したイディオムを利用できます。(もちろん各自で明示的にオープン、クローズを行うこともできます)

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

Blocksの制限や癖(循環参照)の問題はそのまま残っていますので、理解されている方が使用してください。

同様にコンテキストブロックの先頭でトランザクションを開始して、終了時にコミットを実行するコンテキストブロックも書けます。

    [db openWithTransaction:
     ^{
         [db delete:TBL_NAME
           whereClause:[[NSString alloc] initWithFormat: @"%@ = ? and %@ = ? and %@ = ?"
                        , COL_USER_ID, COL_YEAR_MONTH, COL_DAY]
             whereArgs:@[@"Kazzz", @"201303", @"02"]];

     }];

例外が発生した場合は自動的にロールバックするようになっていますので、気に入らない場合は自分でブロックを定義してみてください。カテゴリによる拡張は自由ですから。

## テスト
FMDBExtensionsTests.mにより、データベースのCRUDに関しての簡単なテストをしています。全然足りないと思いますが、必要な方は自分でテストを書いてください。


## ライセンス
FMDBと同様にMITライセンスで配布します


## その他
FMDBを書かれたAugust Mueller氏とgithub及びコミュニティの皆さんに感謝します。

