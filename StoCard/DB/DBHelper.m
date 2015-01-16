//
//  DBHelper.m
//  yxj
//
//  Created by sumeng on 8/5/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "DBHelper.h"

#define kDBVersion 1

@implementation DBHelper

+ (DBHelper *)shared {
    static id obj = nil;
    if (obj == nil) {
        obj = [[DBHelper alloc] init];
    }
    return obj;
}

- (BOOL)openDB {
    if (_db) {
        [_db close];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"StoCard.db"];
    self.db = [FMDatabase databaseWithPath:dbPath];
    if ([self.db openWithFlags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_SHAREDCACHE | SQLITE_OPEN_FULLMUTEX]) {
        [self.db setShouldCacheStatements:YES];
        [self.db setLogsErrors:YES];
        [self createTable];
        
//        NSString * query = [NSString stringWithFormat:@"select count(*) from card where cardname = \'%@\'",@"ft"];
//        FMResultSet * set = [_db executeQuery:query];
//        while ([set next]) {
//            
//        }
        
        
    }else {
        NSLog(@"Could not open db.");
        return NO;
    }    
    return YES;
}

- (void)close {
    [_db close];
    self.db = nil;
}

- (BOOL)createTable {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"table" ofType:@"sql"];
    NSString *sql = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [_db executeStatements:sql];
}

- (BOOL)saveCard:(CardInfo *)info {
    NSString * query = [NSString stringWithFormat:@"select count(*) from card where cardname = \'%@\'",info.name];
    int count = 0;
    FMResultSet * re = [_db executeQuery:query];
    while ([re next]) {
        count = [re intForColumnIndex:0];
    }
    if (count == 0) {
        NSString * sql = [NSString stringWithFormat:@"INSERT INTO card (cardname, type, data, ct) VALUES ('%@', %d, '%@', %d);",info.name,info.type,info.data,(int)[[NSDate date] timeIntervalSince1970]];
        return [_db executeUpdate:sql];
    }else {
        NSString * sql = [NSString stringWithFormat:@"update card set cardname=\'%@\',type=%d,data=\'%@\',ct=%d",info.name,info.type,info.data,(int)[[NSDate date] timeIntervalSince1970]];
        return [_db executeUpdate:sql];
    }
}

- (BOOL)existWithCardName:(NSString *)name {
    NSString * query = [NSString stringWithFormat:@"select count(*) from card where cardname = \'%@\'",name];
    int count = 0;
    FMResultSet * re = [_db executeQuery:query];
    while ([re next]) {
        count = [re intForColumnIndex:0];
    }
    return count>0;
}

- (CardInfo *)queryCardWithName:(NSString *)name {
    CardInfo * info = nil;
    NSString * sql = [NSString stringWithFormat:@"select * from card where cardname = \'%@\'",name];
    FMResultSet * set = [_db executeQuery:sql];
    while ([set next]) {
        info = [[CardInfo alloc] init];
        info.name = [set stringForColumn:@"cardname"];
        info.type = [set intForColumn:@"type"];
        info.data = [set stringForColumn:@"data"];
    }
    [set close];
    return info;
}

- (NSArray *)allCards {
    NSMutableArray * array = [NSMutableArray array];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM card ORDER BY ct DESC"];
    FMResultSet * set = [_db executeQuery:sql];
    while ([set next]) {
        CardInfo * info = [[CardInfo alloc] init];
        info.name = [set stringForColumn:@"cardname"];
        info.type = [set intForColumn:@"type"];
        info.data = [set stringForColumn:@"data"];
        [array addObject:info];
    }
    [set close];
    return array;
}

- (BOOL)deleteCardWithName:(NSString *)name {
    if ([self existWithCardName:name]) {
        NSString * sql = [NSString stringWithFormat:@"delete from card where cardname = \'%@\'",name];
        return [_db executeUpdate:sql];
    }
    return NO;
}

- (BOOL)deleteCard:(CardInfo *)info {
    return [self deleteCardWithName:info.name];
}

@end
