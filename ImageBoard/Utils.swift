import Foundation
import Alamofire
import UIKit

class Utils {
    static let boardBaseUrl = "http://192.168.1.3:8080/homepage/"
    static let imageBaseUrl = "http://192.168.1.3:8080/img/"
    
    enum ImageType:String {
        case JPG = "JPG"
        case PNG = "PNG"
        case GIF = "GIF"
        case Unknown = "Unknown"
    }
    static func testUpload(title:String,content:String,images:[UIImage],complet:@escaping ()->Void){
        let paramters:Parameters = [
            "subject":title,
            "id":"dy",
            "content_text":content,
            "file_count":String(images.count)
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for i in 0 ..< images.count {
                if images[i].isGIF() {
                    print("Utils - > testUpload isGIF?? 되긴하냐?")
                    multipartFormData.append(images[i].pngData()!, withName: "files", fileName: "file (\(i + 1)).gif", mimeType: "image/gif")
                } else {
                    multipartFormData.append(images[i].jpegData(compressionQuality: 0.7)!, withName: "files", fileName: "file (\(i + 1)).jpg", mimeType: "image/jpeg")
                }
            }
            for (key, value) in paramters {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: URL(string: boardBaseUrl + "board/fileUpload")!) { (encodingResult) in
            switch encodingResult {
            case .failure(let error):
                debugPrint("Error : Utils.upload -> \(error.localizedDescription)")
                complet()
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.responseData(completionHandler: { (responseData) in
                    debugPrint(responseData)
                    complet()
                })
            }
        }
    }
    
    static func upload(title:String,content:String,images:[UIImage],complet:@escaping ()->Void){
        let paramters:Parameters = [
            "subject":title,
            "id":"dy",
            "content_text":content,
            "file_count":String(images.count)
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for i in 0 ..< images.count {
                if images[i].isGIF() {
                    multipartFormData.append(images[i].pngData()!, withName: "files", fileName: "file (\(i + 1)).gif", mimeType: "image/gif")
                } else {
                    multipartFormData.append(images[i].pngData()!, withName: "files", fileName: "file (\(i + 1)).png", mimeType: "image/png")
                }
            }
            for (key, value) in paramters {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: URL(string: boardBaseUrl + "board/fileUpload")!) { (encodingResult) in
            switch encodingResult {
            case .failure(let error):
                debugPrint("Error : Utils.upload -> \(error.localizedDescription)")
                complet()
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.responseData(completionHandler: { (responseData) in
                    debugPrint(responseData)
                    complet()
                })
            }
        }
    }
    
    static func getBoard(_ complte:@escaping ([Article_simple])->Void){
        Alamofire.request(URL(string: boardBaseUrl + "getBoard")!, method: .post, parameters: [:], encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in
            var result = [Article_simple]()
            switch response.result {
            case .failure(let err) :
                debugPrint("ERROR : Utils.getBoard -> response - failure \(err.localizedDescription)")
            case .success(let value):
                if let root = value as? [String:Any] {
                    if let returnValue = root["result_list"] as? [[String:String]] {
                        for item in returnValue {
                            let subject = item["subject"] ?? ""
                            let bodNo = item["bod_no"] ?? ""
                            let writeDate = item["write_date"] ?? ""
                            
                            let article = Article_simple(
                                board_no: bodNo,
                                subject: subject,
                                write_date: writeDate)
                            result.append(article)
                        }
                    }
                }
            }
            complte(result)
        }
    }
    
    static func getArticle(bod_no:Int, _ complet:@escaping (Article?)->Void) {
        Alamofire.request(URL(string: boardBaseUrl + "getArticle?number=\(bod_no)")!, method: .get, parameters: nil, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in
            var result:Article?
            switch response.result {
            case .failure(let err) :
                debugPrint("ERROR : Utils.getBoard -> response - failure \(err.localizedDescription)")
            case .success(let value):
                debugPrint(value)
                if let root = value as? [String:Any] {
                    if let article = root["article"] as? [String:String] {
                        let writeDate = article["write_date"] ?? ""
                        let fileCount = article["file_count"] ?? ""
                        let subject = article["subject"] ?? ""
                        let folderName = article["folder_name"] ?? ""
                        let id = article["id"] ?? ""
                        let bodNo = article["bod_no"] ?? ""
                        let content_text = article["content_text"] ?? ""
                        result = Article(
                            board_no: bodNo,
                            subject: subject,
                            write_date: writeDate,
                            id: id,
                            file_count: fileCount,
                            folder_name: folderName,
                            content_text: content_text)
                        debugPrint(result)
                    }
                }
            }
            complet(result)
        }
    }
}
struct Article:protocol_BaseArticle {
    var board_no: String
    
    var subject: String
    
    var write_date: String
    
    var id:String
    var file_count:String
    var folder_name:String
    var content_text:String
}

struct Article_simple {
    var board_no:String
    var subject:String
    var write_date:String
}

protocol protocol_BaseArticle {
    var board_no:String {get set}
    var subject:String {get set}
    var write_date:String {get set}
}
