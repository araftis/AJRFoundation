
import XCTest

import AJRFoundation

class AJRSimpleCodingTest : NSObject, NSCoding {
    
    let value : Int
    
    override init() {
        self.value = 0
    }
    
    init(value: Int) {
        self.value = value
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(value, forKey: "value")
    }
    
    required init?(coder: NSCoder) {
        self.value = coder.decodeInteger(forKey: "value")
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? AJRSimpleCodingTest {
            return value == object.value
        }
        return false
    }
}

class NSCoder_ExtensionsTests: XCTestCase {

    func testSwiftCodingConveniences() {
        let test1 = AJRSimpleCodingTest(value: 10)
        let test2 = AJRSimpleCodingTest(value: 20)
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        
        archiver["object1"] = test1
        archiver.encode(test2, forKey: "object2")
        archiver.finishEncoding()
        
        if let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: archiver.encodedData) {
            unarchiver.requiresSecureCoding = false
            let decoded1 : AJRSimpleCodingTest? = unarchiver["object1"]
            XCTAssert(decoded1 != nil)
            XCTAssert(decoded1 == test1)
            let decoded2 : AJRSimpleCodingTest? = unarchiver.decodeObject(forKey: "object2")
            XCTAssert(decoded2 != nil)
            XCTAssert(decoded2 == test2)
        } else {
            XCTAssert(false, "Failed to create decoder")
        }
    }

}
