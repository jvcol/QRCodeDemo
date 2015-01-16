//
//  DBHelper.h
//  FMDB
//
//  Created by sumeng on 8/5/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "CardInfo.h"

#define kDBPageCount 20

@interface DBHelper : NSObject

@property (nonatomic, strong) FMDatabase *db;

+ (DBHelper *)shared;

- (BOOL)openDB;
- (void)close;

- (BOOL)saveCard:(CardInfo *)info;
- (BOOL)updateCard:(CardInfo *)info;
- (BOOL)existWithCardName:(NSString *)name;
- (CardInfo *)queryCardWithName:(NSString *)name;
- (NSArray *)allCards;
- (BOOL)deleteCard:(CardInfo *)info;
- (BOOL)deleteCardWithName:(NSString *)name;

@end
