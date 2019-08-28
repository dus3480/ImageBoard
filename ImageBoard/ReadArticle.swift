import UIKit
import SDWebImage

class ReadArticle: UIViewController {

    /*
     로드 순서
     reciveItem 이 아이템을 받고.
     getArticle 호출.
     호출이 끝나면 타이틀, 데이트에 텍스트가 들어감
     들어가고 만약 사진파일이 있는 아티클이라면
     imageLoadCount에 파일카운트를 넣음
     카운트 만큼 이미지를 불러오고, 각 이미지가 로드가 완료되면
     스크롤에 이미지를 넣고
     imageloadCount가 -1씩 내려감
     imageLoadCount가 0이 됐을때
     콘텐트 텍스트 스크롤에 추가함
     */
    @IBOutlet var activitiIndicator: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var contentScrollView: UIScrollView! {
        didSet{
            contentScrollView.contentSize = CGSize(width: contentScrollView.frame.width, height: 0)
        }
    }
    var imageLoadCount = 0 {
        didSet{
            print("did..")
            if imageLoadCount == 0, targetArticle != nil  {
                if targetArticle!.content_text.count > 0 {
                    let label = UILabel()
                    label.text = targetArticle?.content_text
                    label.frame.origin = CGPoint(x: 0, y: self.contentScrollView.contentSize.height + 8)
                    label.textColor = UIColor.black
                    label.sizeToFit()
                    debugPrint(label)
                    self.contentScrollView.addSubview(label)
                    self.contentScrollView.contentSize.height += label.frame.height + 16
                    self.contentScrollView.layoutIfNeeded()
                }
                self.activitiIndicator.stopAnimating()
                self.activitiIndicator.isHidden = true
            }
        }
    }
    var targetArticle:Article?
    var reciveItem:Article_simple? {
        didSet{
            guard reciveItem != nil else { return }
    
            if let bod_no = Int(reciveItem!.board_no) {
                Utils.getArticle(bod_no: bod_no) { (response) in
                    if let article = response {
                        self.targetArticle = article
                        self.titleLabel.text = article.subject
                        self.dateLabel.text = article.write_date
                        if let file_count = Int(article.file_count), file_count > 0 {
                            self.imageLoadCount = file_count
                            for i in 0 ..< file_count {
                                let imageView = UIImageView()
                                let str = Utils.imageBaseUrl + article.folder_name + "/" + "file%20(\(i+1)).png"
                                let url =  URL(string: str)
                                imageView.sd_setImage(with:url, completed: { (image, _, _, _) in
                                    let width = self.contentScrollView.frame.width
                                    if image != nil {
                                        print("image size = \(image!.size)")
                                        imageView.frame = CGRect(x: 0, y: self.contentScrollView.contentSize.height, width: width, height: width / image!.size.width * image!.size.height)
                                        self.contentScrollView.addSubview(imageView)
                                        self.contentScrollView.contentSize.height += imageView.frame.height
                                    } else {
                                        let image = UIImage(named:"xbox.jpeg")
                                        imageView.image = image
                                        imageView.frame = CGRect(x: 0, y: self.contentScrollView.contentSize.height, width: width, height: width / image!.size.width * image!.size.height)
                                    }
                                    self.imageLoadCount -= 1
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !self.activitiIndicator.isAnimating {
            self.activitiIndicator.startAnimating()
            self.activitiIndicator.isHidden = false
        }
    }
    
}
