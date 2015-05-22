//
//  ViewController.m
//  thread
//
//  Created by Мариам Б. on 20.05.15.
//  Copyright (c) 2015 Мариам Б. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) NSThread * thread_Cat;
@property (nonatomic,strong) NSThread * thread_Dog;
@property (nonatomic,strong) NSThread * thread_Bird;
@property (nonatomic,strong) NSMutableArray * threadArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //запускаем методы с различной реализацией работы с потоками
    [self threads_Cat_And_Dog];
    [self threads_Fish_And_Frog];
    [self thread_With_Interface];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) thread_With_Interface {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //фоновый процесс
        [self performSelector:@selector(memoryCrash_Frog) withObject:nil];
        
        //выводим в главную очередь запуск интерфейса
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIView * squareView = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
            squareView.backgroundColor = [UIColor blueColor];
            [self.view addSubview:squareView];
            
        });
        // продолжение работы фонового процесса
        [self performSelector:@selector(memoryCrash_Frog) withObject:nil];
    });

}

- (void) threads_Cat_And_Dog {
    //инициализируем массив, в который будем передавать данные из потоков
    self.threadArray = [[NSMutableArray alloc]init];
    
    //создаем два потока, передающие объект в массив
    self.thread_Cat = [[NSThread alloc]initWithTarget:self selector: @selector (memoryCrash:) object:@"Cat"];
    self.thread_Cat.name = @"Thread_Cat";
    
    self.thread_Dog = [[NSThread alloc]initWithTarget:self selector: @selector (memoryCrash:) object:@"Dog"];
    self.thread_Dog.name = @"Thread_Dog";
    
    //запускаем потоки
    [self.thread_Cat start];
    [self.thread_Dog start];
    
    //показываем массив после задержки
     [self performSelector:@selector(showThreadArray) withObject:nil afterDelay:2];
}

//метод с последовательным выполнением потоков
- (void) threads_Fish_And_Frog {
    
    //инициализируем массив, в который будем передавать данные из потоков
    self.threadArray = [[NSMutableArray alloc]init];
    
    //задаем последовательное выполнение потоков
    dispatch_queue_t queueCreated = dispatch_queue_create("Animals", DISPATCH_QUEUE_SERIAL);
    
    //запускаем потоки
    dispatch_async(queueCreated, ^{
        [self memoryCrash: @"Fish"];
        
    });
    
    dispatch_async(queueCreated, ^{
        [self memoryCrash: @"Frog"];
        
    });
    
    //показываем массив после задержки
    [self performSelector:@selector(showThreadArray) withObject:nil afterDelay:1];
}

//метод, добавляющий данные в массив из потоков
- (void) memoryCrash: (NSString *) string {
    @synchronized (self) {
        @autoreleasepool {
            for (int i = 0; i < 5000; i++) {
                [self.threadArray addObject:string];
            }
        }
    }
}

//метод, выводящий массив в лог
- (void) showThreadArray {
    NSLog(@"массив %@", self.threadArray);
}

//массив, выводящий в лог слово Frog
- (void) memoryCrash_Frog {
    @autoreleasepool {
        for (int i = 0; i < 5000; i++) {
            NSLog(@" Frog %i", i);
        }
    }
}


@end
