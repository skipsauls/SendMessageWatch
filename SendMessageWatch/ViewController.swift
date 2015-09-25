//
//  ViewController.swift
//  SendMessageWatch
//
//  Created by Skip Sauls on 9/23/15.
//  Copyright © 2015 SkipSauls. All rights reserved.
//

import UIKit
import WebKit
import WatchConnectivity

class ViewController: UIViewController, WKNavigationDelegate, WCSessionDelegate, WKScriptMessageHandler {

    var session: WCSession!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        
        print("################################################################################ loadView")
        
        var contentController = WKUserContentController();
        
        // Script injection below
        /*
        var userScript = WKUserScript(
            source: "redHeader()",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        */
        
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        var config = WKWebViewConfiguration()
        
        config.userContentController = contentController
        
        let rect = CGRect(x: 0, y: 100, width: 375, height: 550)
        self.webView = WKWebView(frame: rect, configuration: config)
        self.webView!.navigationDelegate = self
        view.addSubview(self.webView!)
        
        //self.containerView.insertSubview(self.webView!, atIndex: 0)
        //self.containerView = self.webView
        //self.view = self.webView
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")
            sendToWatch(message.body as! NSString)
        }
    }
    
    func sendToWatch(msg: NSString) {
        let messageToSend = ["Value":msg]
        
        session.sendMessage(messageToSend, replyHandler: { replyMessage in
            //handle the reply
            let value = replyMessage["Value"] as? String
            //use dispatch_asynch to present immediately on screen
            dispatch_async(dispatch_get_main_queue()) {
                self.messageLabel.text = value
            }
            }, errorHandler: {error in
                // catch any errors here
                print(error)
        })
        
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        //Send Message to WatchKit
        sendToWatch("Hi watch, can you talk to me?")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //var url = NSURL(string:"http://octane-benchmark.googlecode.com/svn/latest/index.html")
        let url = NSURL(string:"https://gs0.lightning.force.com/one/one.app")
        let req = NSURLRequest(URL:url!)
        self.webView!.loadRequest(req)
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self;
            session.activateSession()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        //handle received message
        let value = message["Value"] as? String
        dispatch_async(dispatch_get_main_queue()) {
            self.messageLabel.text = value
        }
        //send a reply
        replyHandler(["Value":"Hello Watch"])
    }

}

