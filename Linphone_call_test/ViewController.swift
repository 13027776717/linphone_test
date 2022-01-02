//
//  ViewController.swift
//  Linphone_call_test

//

import UIKit
import linphonesw

class ViewController: UIViewController {
    
    var mCore: Core!
    var mAccount: Account?
    var mCoreDelegate : CoreDelegate!
    var loggedIn: Bool = false
    var callMsg : String = ""

    @IBOutlet weak var nameTF: UITextField!
    
    
    @IBOutlet weak var passwordTF: UITextField!
    
    
    @IBOutlet weak var domainTF: UITextField!
    
    
    @IBOutlet weak var callAddress: UITextField!
    
    
    @IBOutlet weak var msgLab: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        config()
    }
    
    func config() {
        
        nameTF.text = "889900"
        passwordTF.text = "889900"
        domainTF.text = "119.28.64.168"
        LoggingService.Instance.logLevel = LogLevel.Debug
        
        try? mCore = Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
        // Here we enable the video capture & display at Core level
        // It doesn't mean calls will be made with video automatically,
        // But it allows to use it later
        mCore.videoCaptureEnabled = true
        mCore.videoDisplayEnabled = true
        
        // When enabling the video, the remote will either automatically answer the update request
        // or it will ask it's user depending on it's policy.
        // Here we have configured the policy to always automatically accept video requests
        mCore.videoActivationPolicy!.automaticallyAccept = true
        // If you don't want to automatically accept,
        // you'll have to use a code similar to the one in toggleVideo to answer a received request
        
        
        // If the following property is enabled, it will automatically configure created call params with video enabled
        //core.videoActivationPolicy.automaticallyInitiate = true
        
        try? mCore.start()
        
        mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
            // This function will be called each time a call state changes,
            // which includes new incoming/outgoing calls
            self.msgLab.text = message
            
            if (state == .OutgoingInit) {
                // First state an outgoing call will go through
            } else if (state == .OutgoingProgress) {
                // Right after outgoing init
            } else if (state == .OutgoingRinging) {
                // This state will be reached upon reception of the 180 RINGING
            } else if (state == .Connected) {
                // When the 200 OK has been received
            } else if (state == .StreamsRunning) {
                // This state indicates the call is active.
                // You may reach this state multiple times, for example after a pause/resume
                // or after the ICE negotiation completes
                // Wait for the call to be connected before allowing a call update
//                self.isCallRunning = true
                
                // Only enable toggle camera button if there is more than 1 camera
                // We check if core.videoDevicesList.size > 2 because of the fake camera with static image created by our SDK (see below)
//                self.canChangeCamera = core.videoDevicesList.count > 2
            } else if (state == .Paused) {
                // When you put a call in pause, it will became Paused
//                self.canChangeCamera = false
            } else if (state == .PausedByRemote) {
                // When the remote end of the call pauses it, it will be PausedByRemote
            } else if (state == .Updating) {
                // When we request a call update, for example when toggling video
            } else if (state == .UpdatedByRemote) {
                // When the remote requests a call update
            } else if (state == .Released) {
                // Call state will be released shortly after the End state
//                self.isCallRunning = false
//                self.canChangeCamera = false
            } else if (state == .Error) {
                
            }
        }, onAccountRegistrationStateChanged: { [self] (core: Core, account: Account, state: RegistrationState, message: String) in
            NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
            msgLab.text = message
            if (state == .Ok) {
                self.loggedIn = true
            } else if (state == .Cleared) {
                self.loggedIn = false
            }
        })
        mCore.addDelegate(delegate: mCoreDelegate)
    }
    
    func outgoingCall() {
        
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let address = String("sip:" + callAddress.text! + "@" + domainTF.text!)
            
            let remoteAddress = try Factory.Instance.createAddress(addr: address)
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            // If we wanted to start the call with video directly
            //params.videoEnabled = true
            
            // Finally we start the call
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
        
    }
    
    func login() {
        
        do {
            let transport  = TransportType.Udp
//            if (transportType == "TLS") { transport = TransportType.Tls }
//            else if (transportType == "TCP") { transport = TransportType.Tcp }
//            else  { transport = TransportType.Udp }
            
            let authInfo = try Factory.Instance.createAuthInfo(username: nameTF.text!, userid: "", passwd: passwordTF.text, ha1: "", realm: "", domain: domainTF.text)
            let accountParams = try mCore.createAccountParams()
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + nameTF.text! + "@" + domainTF.text!))
            try! accountParams.setIdentityaddress(newValue: identity)
            let address = try Factory.Instance.createAddress(addr: String("sip:" + domainTF.text!))
            try address.setTransport(newValue: transport)
            try accountParams.setServeraddress(newValue: address)
            
            accountParams.registerEnabled = true
            mAccount = try mCore.createAccount(params: accountParams)
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: mAccount!)
            mCore.defaultAccount = mAccount
            
        } catch { NSLog(error.localizedDescription) }
    }
    
    
    @IBAction func loginButtonClick(_ sender: UIButton) {
        login()
    }
    

    @IBAction func callButtonClick(_ sender: UIButton) {
        if loggedIn {
            outgoingCall()
        } else {
            NSLog("kkkkkkkkk")
        }
        
    }
    
}

