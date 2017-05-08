import UIKit
import SwiftSocket

class ViewController: UIViewController {
    
    var client : TCPClient!
    
    var sount : Int = 0
    
    private weak var timer : Timer!
    
    /// 标记用户存在常量。
    var sendToUSerMsg : String = "888"

    lazy var ttt: UITableView = {
        let d : UITableView = UITableView.init(frame: self.view.bounds)
        d.register(UITableViewCell.self, forCellReuseIdentifier: "aaa")
        d.delegate = self;
        d.dataSource = self
        return d
    }()
    
    var funcString : [String] = ["发送时间","停止时间"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .default).async {
            self.testServer()
        }
        
        view.addSubview(ttt)
    }
    
    
    func echoService(client: TCPClient) {
        
        /// 传值
        self.client = client
        
        
        /// send data
        while true {
        
            let d = client.read(1024 * 10)

            
            print(d?.count as Any)
            
            if d?.count != nil {
                sount = (d?.count)! + sount
                print("---",sount)
                client.send(data: d!)
            } else {
                return
            }
        }
    }
    
    
    func testServer() {
        
        let server = TCPServer(address: "127.0.0.1", port: 8888)
        
        
        switch server.listen() {
        case .success:
            
            ///
            
            while true {
                if let client = server.accept() {
                    
                    print("iiiiiiiii")
                    
                    echoService(client: client)
                } else {
                    print("accept error")
                    
                    return
                    
                }
            }
        case .failure(let error):
            
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n",error)
            print("\((#file as NSString).lastPathComponent):(\(#line))\n",error.localizedDescription)
        }
    }
}


extension ViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aaa")
        
        cell?.textLabel?.text = funcString[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return funcString.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            /// 发送时间
        case 0:
            let sendXMLDATA = "<R f='30'/>"
            
            let xmlData = sendXMLDATA.data(using: .utf8)
            client.send(data: xmlData!)
            
            print("\((#file as NSString).lastPathComponent):(\(#line))\n",xmlData as Any)

            break
            
        case 1 :
            
            let sendXMLDATA = "<R f='10'/>"
            
            let xmlData = sendXMLDATA.data(using: .utf8)
            client.send(data: xmlData!)
            break
        default:
            break
        }
    
    }
}
