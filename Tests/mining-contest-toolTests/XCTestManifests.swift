import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(mining_contest_toolTests.allTests),
    ]
}
#endif
