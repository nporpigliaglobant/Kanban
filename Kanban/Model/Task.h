//
//  Task.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * taskDescription;
@property (nonatomic, retain) NSManagedObject *project;

@end
