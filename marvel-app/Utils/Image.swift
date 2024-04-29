import Foundation

enum ImageUtil {
    static func returnCorrectUrlToShowImage(thumbnailPath: String, thumbnailExtension: String) -> String {
        var thumbnailURLString = thumbnailPath
        
        if thumbnailPath.hasPrefix("http://") {
            thumbnailURLString = "https://" + String(thumbnailPath.dropFirst("http://".count))
        }
        
        thumbnailURLString += "." + thumbnailExtension
        
        return thumbnailURLString
    }
}
