
import Foundation

public struct AJRLog {
    
    public static func `in`(domain: String?, level: AJRLogLevel = .info, message: @autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, level) {
            AJRSimpleLog(domain, level, message())
        }
    }
    
    public static func emergency(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .emergency) {
            AJRSimpleLog(functionOrMethod, .emergency, message())
        }
    }
    
    public static func alert(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .alert) {
            AJRSimpleLog(functionOrMethod, .alert, message())
        }
    }
    
    public static func critical(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .critical) {
            AJRSimpleLog(functionOrMethod, .critical, message())
        }
    }
    
    public static func error(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .error) {
            AJRSimpleLog(functionOrMethod, .error, message())
        }
    }
    
    public static func warning(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .error) {
            AJRSimpleLog(functionOrMethod, .warning, message())
        }
    }
    
    public static func notice(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .notice) {
            AJRSimpleLog(functionOrMethod, .notice, message())
        }
    }
    
    public static func info(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .info) {
            AJRSimpleLog(functionOrMethod, .info, message())
        }
    }
    
    public static func debug(functionOrMethod:String=#function, _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(functionOrMethod, .debug) {
            AJRSimpleLog(functionOrMethod, .debug, message())
        }
    }

}
