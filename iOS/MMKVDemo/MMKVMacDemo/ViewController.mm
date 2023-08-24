//
//  ViewController.m
//  MMKVMacDemo
//
//  Created by Ling Guo on 2018/9/27.
//  Copyright © 2018 Lingol. All rights reserved.
//

#import "ViewController.h"
#import <MMKV/MMKV.h>

@implementation ViewController {
    NSMutableArray *m_arrStrings;
    NSMutableArray *m_arrStrKeys;
    NSMutableArray *m_arrIntKeys;

    int m_loops;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self onlyOneKeyTest];
    
    [self expectedCapacityTest];

    [self funcionalTest:NO];
    [self testNeedLoadFromFile];

    m_loops = 10000;
    m_arrStrings = [NSMutableArray arrayWithCapacity:m_loops];
    m_arrStrKeys = [NSMutableArray arrayWithCapacity:m_loops];
    m_arrIntKeys = [NSMutableArray arrayWithCapacity:m_loops];
    for (size_t index = 0; index < m_loops; index++) {
        NSString *str = [NSString stringWithFormat:@"%s-%d", __FILE__, rand()];
        [m_arrStrings addObject:str];

        NSString *strKey = [NSString stringWithFormat:@"str-%zu", index];
        [m_arrStrKeys addObject:strKey];

        NSString *intKey = [NSString stringWithFormat:@"int-%zu", index];
        [m_arrIntKeys addObject:intKey];
    }
}

- (void) onlyOneKeyTest {
    {
        auto mmkv0 = [MMKV mmkvWithID:@"onlyOneKeyTest"];
        NSString *key = [NSString stringWithFormat:@"hello"];
        NSString *value = [NSString stringWithFormat:@"world"];
        auto v = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v);
        
        [mmkv0 setString:value forKey:key];
        auto v2 = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v2);
        
        for (int i = 0; i < 10; i++) {
            NSString * value2 = [NSString stringWithFormat:@"world_%d", i];
            [mmkv0 setString:value2 forKey:key];
            auto v2 = [mmkv0 getStringForKey:key];
            NSLog(@"value = %@", v2);
        }
        
        int len = 10000;
        NSMutableString *bigValue = [NSMutableString stringWithFormat:@"🏊🏻®4️⃣🐅_"];
        for (int i = 0; i < len; i++) {
            [bigValue appendString:@"0"];
        }
        [mmkv0 setString:bigValue forKey:key];
        auto v3 = [mmkv0 getStringForKey:key];
        // NSLog(@"value = %@", v3);
        if (![bigValue isEqualToString:v3]) {
            abort();
        }

        [mmkv0 setString:@"OK" forKey:key];
        auto v4 = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v4);
        
        [mmkv0 setInt32:12345 forKey:@"int"];
        auto v5 = [mmkv0 getInt32ForKey:key];
        NSLog(@"int value = %d", v5);
        [mmkv0 removeValueForKey:@"int"];
    }
    
    {
        NSString *crypt = [NSString stringWithFormat:@"fastest"];
        auto mmkv0 = [MMKV mmkvWithID:@"onlyOneKeyCryptTest" cryptKey:[crypt dataUsingEncoding:NSUTF8StringEncoding] mode:MMKVSingleProcess];
        NSString *key = [NSString stringWithFormat:@"hello"];
        NSString *value = [NSString stringWithFormat:@"cryptworld"];
        auto v = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v);
        
        [mmkv0 setString:value forKey:key];
        auto v2 = [mmkv0 getStringForKey:key];
        NSLog(@"value = %@", v2);
        
        for (int i = 0; i < 10; i++) {
            NSString * value2 = [NSString stringWithFormat:@"cryptworld_%d", i];
            [mmkv0 setString:value2 forKey:key];
            auto v2 = [mmkv0 getStringForKey:key];
            NSLog(@"value = %@", v2);
        }
    }
}

- (void)expectedCapacityTest {
    int len = 10000;
    NSString *value = [NSString stringWithFormat:@"🏊🏻®4️⃣🐅_"];
    for (int i = 0; i < len; i++) {
        value = [value stringByAppendingString:@"0"];
    }
    NSLog(@"value size = %ld", [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    NSString *key = [NSString stringWithFormat:@"key0"];
    
    // if we know exactly the sizes of key and value, set expectedCapacity for performance improvement
    size_t expectedSize = [key lengthOfBytesUsingEncoding:NSUTF8StringEncoding]
                        + [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    auto mmkv0 = [MMKV mmkvWithID:@"expectedCapacityTest0" expectedCapacity:expectedSize];
    // 0 times expand
    [mmkv0 setString:value forKey:key];
    
    
    int count = 10;
    expectedSize *= count;
    auto mmkv1 = [MMKV mmkvWithID:@"expectedCapacityTest1" expectedCapacity:expectedSize];
    for (int i = 0; i < count; i++) {
        // 0 times expand
        [mmkv1 setString:value forKey:[NSString stringWithFormat:@"key%d", i]];
    }
}

- (void)funcionalTest:(BOOL)decodeOnly {
    MMKV *mmkv = [MMKV defaultMMKV];

    if (!decodeOnly) {
        [mmkv setBool:YES forKey:@"bool"];
    }
    NSLog(@"bool:%d", [mmkv getBoolForKey:@"bool"]);

    if (!decodeOnly) {
        [mmkv setInt32:-1024 forKey:@"int32"];
    }
    NSLog(@"int32:%d", [mmkv getInt32ForKey:@"int32"]);

    if (!decodeOnly) {
        [mmkv setUInt32:std::numeric_limits<uint32_t>::max() forKey:@"uint32"];
    }
    NSLog(@"uint32:%u", [mmkv getUInt32ForKey:@"uint32"]);

    if (!decodeOnly) {
        [mmkv setInt64:std::numeric_limits<int64_t>::min() forKey:@"int64"];
    }
    NSLog(@"int64:%lld", [mmkv getInt64ForKey:@"int64"]);

    if (!decodeOnly) {
        [mmkv setUInt64:std::numeric_limits<uint64_t>::max() forKey:@"uint64"];
    }
    NSLog(@"uint64:%llu", [mmkv getInt64ForKey:@"uint64"]);

    if (!decodeOnly) {
        [mmkv setFloat:-3.1415926 forKey:@"float"];
    }
    NSLog(@"float:%f", [mmkv getFloatForKey:@"float"]);

    if (!decodeOnly) {
        [mmkv setDouble:std::numeric_limits<double>::max() forKey:@"double"];
    }
    NSLog(@"double:%f", [mmkv getDoubleForKey:@"double"]);

    if (!decodeOnly) {
        [mmkv setString:@"hello, mmkv" forKey:@"string"];
    }
    NSLog(@"string:%@", [mmkv getStringForKey:@"string"]);

    if (!decodeOnly) {
        [mmkv setDate:[NSDate date] forKey:@"date"];
    }
    NSLog(@"date:%@", [mmkv getDateForKey:@"date"]);

    if (!decodeOnly) {
        [mmkv setObject:[@"hello, mmkv again and again" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
    }
    NSData *data = [mmkv getObjectOfClass:NSData.class forKey:@"data"];
    NSLog(@"data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if (!decodeOnly) {
        [mmkv removeValueForKey:@"bool"];
        NSLog(@"bool:%d", [mmkv getBoolForKey:@"bool"]);
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)testNeedLoadFromFile {
    auto mmkv = [MMKV mmkvWithID:@"testNeedLoadFromFile"];
    [mmkv clearMemoryCache]; // or may be triggered by Memory Warning
    [mmkv clearAll];
    NSAssert([mmkv setString:@"value" forKey:@"key"], @"Fail to save");
}

@end
