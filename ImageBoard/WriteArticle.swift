import UIKit
import Photos
import SDWebImage

class WriteArticle: UIViewController {
    @IBOutlet var titleTF: UITextField!
    @IBOutlet var contentTV: UITextView!
    @IBOutlet var imageContentView: UIScrollView!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var imageArray = [UIImage]()
    
    var picker:UIImagePickerController? {
        didSet{
            picker?.delegate = self
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        picker = UIImagePickerController()
        self.contentTV.layer.borderWidth = CGFloat(1)
        self.contentTV.layer.borderColor = UIColor.black.cgColor
        self.imageContentView.layer.borderWidth = CGFloat(1)
        self.imageContentView.layer.borderColor = UIColor.black.cgColor
        
        self.imageContentView.contentSize = CGSize(width: 0, height: self.imageContentView.frame.height)
    }
    
    @IBAction func imageButtonAction(_ sender: Any) {
        let alert = UIAlertController(title: "선택", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let library = UIAlertAction(title: "사진앨범", style: .default) { (_) in
            self.openLibrary()
        }
        let camera = UIAlertAction(title: "카메라", style: .default) { (_) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func openLibrary() {
        guard picker != nil else { return }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker!.sourceType = .photoLibrary
            self.present(picker!, animated: false, completion: nil)
        }
    }
    
    func openCamera() {
        guard picker != nil else { return }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker!.sourceType = .camera
            self.present(picker!, animated: false, completion: nil)
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        Utils.upload(title: self.titleTF.text ?? "", content: self.contentTV.text, images: self.imageArray) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.navigationController?.popViewController(animated: true)
        }
        /*
        Utils.testUpload(title: self.titleTF.text ?? "", content: self.contentTV.text, images: self.imageArray) {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.navigationController?.popViewController(animated: true)
        }*/
    }
    
    func getType(info: [UIImagePickerController.InfoKey : Any]) -> Utils.ImageType {
        var type = Utils.ImageType.Unknown
        if let assetPath = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
            if (assetPath.absoluteString.hasSuffix("JPG")) {
                type = .JPG
                print("JPG")
            }
            else if (assetPath.absoluteString.hasSuffix("PNG")) {
                type = .PNG
                print("PNG")
            }
            else if (assetPath.absoluteString.hasSuffix("GIF")) {
                type = .GIF
                print("GIF")
            }
            else {
                type = .Unknown
                print("Unknown")
            }
        }
        print(type.rawValue)
        return type
    }
}
extension WriteArticle : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        switch getType(info: info) {
        case .GIF:
            if #available(iOS 11.0, *) {
                //info[UIImagePickerController.InfoKey.]
                if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    
                }
            } else {
                
            }
        case .JPG,.PNG,.Unknown:
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: self.imageContentView.contentSize.width, y: 0, width: 80, height: self.imageContentView.frame.height)
                self.imageContentView.addSubview(imageView)
                self.imageContentView.contentSize.width += 82
                imageArray.append(image)
                imageContentView.layoutIfNeeded()
            }
        }
        
        
        //debugPrint("1 - \(self.IMG)")
        /*
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            debugPrint(image)
            getFileName(info: info)
            debugPrint("2 - \(self.IMG)")
            
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: self.imageContentView.contentSize.width, y: 0, width: 80, height: self.imageContentView.frame.height)
            self.imageContentView.addSubview(imageView)
            self.imageContentView.contentSize.width += 82
            if image.isGIF() {
                debugPrint("WriteArticle -> gif!!")
            }
            imageArray.append(image)
            imageContentView.layoutIfNeeded()
        }*/
        
        dismiss(animated: true, completion: nil)
    }
}
