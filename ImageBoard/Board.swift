
import UIKit

class Board: UIViewController {
    @IBOutlet var tableView:UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    var articles = [Article_simple]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc func refreshAction(_ sender:UIRefreshControl){
        Utils.getBoard { (result) in
            self.articles = result
            sender.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.getBoard { (result) in
            self.articles = result
        }
    }
    
    @IBAction func writeButtonAction(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_id_write") {
            debugPrint(vc)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
extension Board : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell_id_board")
        let target = self.articles[indexPath.row]
        cell.textLabel?.text = target.subject
        cell.detailTextLabel?.text = target.write_date
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let target = self.articles[indexPath.row]
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "sb_id_read") as? ReadArticle {
            vc.reciveItem = target
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
