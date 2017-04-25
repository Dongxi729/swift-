import UIKit
import SwiftSocket

class ViewController: UIViewController {
    
    var client : TCPClient!
    
    private weak var timer : Timer!
    
    /// 标记用户存在常量。
    var sendToUSerMsg : String = "888"
    
    lazy var textView: UITextView = {
        let d : UITextView = UITextView.init(frame: self.view.bounds)
        d.backgroundColor = UIColor.gray
        return d
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        
        DispatchQueue.global(qos: .default).async {
            self.testServer()
        }
    }
    
    func echoService(client: TCPClient) {
        
        /// 传值
        self.client = client
        
        print("Newclient from:\(client.address)[\(client.port)]")
        
        DispatchQueue.main.async {
            self.textView.text = "Newclient from:\(client.address)[\(client.port)]"
        }
        
        DispatchQueue.main.async {
            
            self.timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.sendRandomMsg), userInfo: nil, repeats: true)
            
            self.timer.fire()

            RunLoop.main.add(self.timer, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
        while true {
            
            var d = client.read(1024*10)
            
            if d == nil {
                print("\((#file as NSString).lastPathComponent):(\(#line))\n","断开连接")
                self.timer.invalidate()
                
                
                /// 断开连接后，重置记录常量
                self.sendToUSerMsg = "888"
                
                return
            } else {
                print(d!)
                //d?[10] = (d?[10])!+3
                //let geStr = String(bytes: d!, encoding: String.Encoding.utf8)
                
                //print("\((#file as NSString).lastPathComponent):(\(#line))\n",geStr as Any)
                
                client.send(data: d!)
            }
        }
    }
    
    
    /// 发送消息
    func sendRandomMsg() -> Void {
        
        /// 生成随机用户名称,并发送
        if !self.sendToUSerMsg.contains("用户") {
            
            let temp = Int(arc4random_uniform(1000))+1
            
            let sendStr : String = "用户" + String(temp) + "在线"
            
            self.sendToUSerMsg = sendStr
        }
        
        
        let ndata = self.sendToUSerMsg.data(using: .utf8)
        
        var int : Int = (ndata?.count)!
        
        let data2 : NSMutableData = NSMutableData()
        
        /// 添加包头，反之粘包
        data2.append(&int, length: 4)
        
        /// 添加要发送的内容
        data2.append(ndata!)
        
        guard let socket = client else {
            return
        }
        
        
       // socket.send(data: data2 as Data)
        
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n")
    }
    
    func testServer() {
        let server = TCPServer(address: "192.168.3.4", port: 8411)
        
        switch server.listen() {
        case .success:
            while true {
                if let client = server.accept() {
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
