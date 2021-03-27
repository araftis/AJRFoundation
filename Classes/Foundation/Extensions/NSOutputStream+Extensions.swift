
import Foundation

public extension OutputStream {

    /**
     Re-declares this property in a more Swift friendly manner, since Swift doesn't need to worry about the name collision.
     */
    var data : Data? {
        return ajr_data
    }

    /**
     If the receiver is a memory output stream, the data is converting to string using the provided encoding. If the data doesn't exist or cannot be converted to the string encoding this method returns nil.

     This is a Swift friendlier API to a similar Obj-C method.

     - parameter encoding The desired string encoding.

     - returns The string representation of data, or nil.
     */
    func dataAsString(using encoding: String.Encoding) -> String? {
        if let data = data {
            return String(data: data, encoding: encoding)
        }
        return nil
    }

}
