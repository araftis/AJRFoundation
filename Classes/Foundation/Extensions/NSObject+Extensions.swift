
import Foundation

@objc
public enum AJRBindingSelectionType : Int {
    
    case unknown
    case none
    case single
    case multiple
    
}

@objc
public extension NSObject {
    
    var descriptionPrefix : String {
        get {
            return "\(Self.self): 0x\(String(unsafeBitCast(self, to:Int.self), radix:16))"
        }
    }
    
    @objc(selectionTypeForBinding:)
    func selectionType(for binding: NSBindingName) -> AJRBindingSelectionType {
        var type = AJRBindingSelectionType.unknown
        
        if let info = infoForBinding(binding),
            let object = info[.observedObject],
            let keyPath = info[.observedKeyPath] as? String {
            let raw = (object as AnyObject).value(forKeyPath: keyPath)
            if (raw as AnyObject) === NSMultipleValuesMarker {
                type = .multiple
            } else if (raw as AnyObject) === NSNoSelectionMarker {
                type = .none
            } else {
                type = .single
            }
        }
        
        return type
    }
    
}
