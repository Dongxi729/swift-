import UIKit
import SwiftSocket

class ViewController: UIViewController {
    
    var client : TCPClient!
    
    var sount : Int = 0
    
    private weak var timer : Timer!
    
    /// 标记用户存在常量。
    var sendToUSerMsg : String = "888"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .default).async {
            self.testServer()
        }
    }
    
    
    func echoService(client: TCPClient) {
        
        /// 传值
        self.client = client
        
        
        /// send data
        while true {
        
            let d = client.read(1024 * 10)
            
            print(d)
            
            print(d?.count as Any)
            
            if d?.count != nil {
                sount = (d?.count)! + sount
                print("---",sount)
                client.send(data: d!)
            }
        }
    }
    
    
    func testServer() {
        //        let server = TCPServer(address: "192.168.3.4", port: 8411)
        // 172.168.1.105
        //        let server = TCPServer(address: "172.168.1.105", port: 8411)
        
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
