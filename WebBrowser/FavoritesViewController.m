//
//  FavoritesViewController.m
//  WebBrowser
//
//  Created by Hiromasa Suzuki on 13/07/28.
//  Copyright (c) 2013年 Hiromasa Suzuki. All rights reserved.
//

#import "FavoritesViewController.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController
{
    //お気に入り一式を格納する配列
    NSMutableArray *favoriteList;
    
    //SQLiteデータベースの名前とパス
    NSString *databaseName;
    NSString *databasePath;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //favoritesを初期化
    favoriteList = [[NSMutableArray alloc] init];
    
    //データベースのファイルパスを取得
    databaseName = @"favorites.sqlite";
    NSArray *documentPaths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    databasePath = [documentDir
                    stringByAppendingPathComponent:databaseName];
    
    //データベースを参照して内容をfavoritesに入れる
    [self queryDB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//データベースより、登録されたお気に入りを参照
-(void) queryDB {
    
    //Databaseを開く
    FMDatabase* db = [FMDatabase databaseWithPath:databasePath];
    [db open];
    
    //クエリ文を指定
    NSString *query =
    [NSString stringWithFormat:@"SELECT * FROM my_favorites"];
    
    //クエリ開始
    [db beginTransaction];
    
    //項目ごとに新規にFavoritesインスタンスを生成し、URLとタイトルを格納
    //その後、そのインスタンスをfavoriteListに追加
    FMResultSet *results = [db executeQuery:query];
    while([results next]) {
        Favorites *f = [[Favorites alloc] init];
        f.title = [results stringForColumn:@"title"];
        f.url  = [results stringForColumn:@"url"];
        [favoriteList addObject:f];
    }
    //Databaseを閉じる
    [db close];
}

//Table Viewのセクション数を指定
- (NSInteger)numberOfSectionsInTableView:
(UITableView *)tableView {
	return 1;
}

//Table Viewのセルの数を指定
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [favoriteList count];
}

//各セルにタイトルをセット
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルのスタイルを標準のものに指定
    static NSString *CellIdentifier = @"Cells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //セルにお気に入りサイトのタイトルを表示
    Favorites *f = [favoriteList objectAtIndex:[indexPath row]];
    cell.textLabel.text = f.title;
    
    return cell;
}
//リスト中のお気に入りアイテムが選択された時の処理
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //選択された項目のURLを参照
    Favorites *f = [favoriteList objectAtIndex:[indexPath row]];
    NSString *selectedURL = f.url;
    
    //引数でURLを指定しながらDelegate通知
    //View Controller上に設定した
    //「favoritesViewControllerDidSelect」を呼び出し
	[self.delegate favoritesViewControllerDidSelect:self
                                            withUrl:selectedURL];
}


//「戻る」ボタンが押された時の処理
-(IBAction)back:(id)sender {
    
    //「戻る」ボタンが押されたことをDelegate通知
    //View Controller上に設定した
    //「favoritesViewControllerDidCancel」を呼び出し
    [self.delegate favoritesViewControllerDidCancel:self];
    
}

@end
