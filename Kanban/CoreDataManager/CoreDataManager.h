//
//  CoreDataManager.h
//  Kanban
//
//  Created by Lucas on 5/19/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL*)applicationDocumentsDirectory;
- (id)insertManagedObjectOfClass:(Class)aClass inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray*)fetchEntitiesForClass:(Class)aClass withPredicate:(NSPredicate*)predicate inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
+ (instancetype) sharedInstance;

/*
-(Tag*)getTagWithId:(NSNumber*)tagId;
-(Activity*)getActivityWithId:(NSNumber*)activityId;
-(void)deleteAllTags;
-(void)deleteAllActivities;
-(void)deleteAllSchedules;
*/
@end
