#import <XCTest/XCTest.h>
#import "../XADTarParser.h"

@interface XADTarParser (TestExtensions)
- (void)parsePaxTarHeader:(NSData *)header toDict:(NSMutableDictionary *)dict;
@end

@interface XADTarParserTests : XCTestCase
@end

@implementation XADTarParserTests

- (NSDictionary *)_dictionaryForPaxRecords:(NSString *)records {
    XADTarParser *parser = [[XADTarParser alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [parser parsePaxTarHeader:[records dataUsingEncoding:NSUTF8StringEncoding] toDict:dict];
    [parser release];
    return dict;
}

- (void)testPaxRecordsAreApplied {
    // Each record is "<length> <key>=<value>\n", the length counting the whole record.
    NSDictionary *dict = [self _dictionaryForPaxRecords:@"22 path=long-name.txt\n20 mtime=1700000000\n12 uid=4242\n"];

    XCTAssertEqualObjects([[dict objectForKey:XADFileNameKey] string], @"long-name.txt");
    XCTAssertEqualObjects([dict objectForKey:XADLastModificationDateKey], [NSDate dateWithTimeIntervalSince1970:1700000000]);
    XCTAssertEqualObjects([dict objectForKey:XADPosixUserKey], [NSNumber numberWithInt:4242]);
}

- (void)testMalformedPaxRecordsAreIgnored {
    NSArray *inputs = [NSArray arrayWithObjects:@"2 x", @"1 ", @"0 path=x\n", @"99999 path=x\n", @"path=x\n", nil];

    for (NSString *records in inputs) {
        XCTAssertEqual([[self _dictionaryForPaxRecords:records] count], (NSUInteger)0, @"%@", records);
    }
}

@end
