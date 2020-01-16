//
//  ScannerView.swift
//  pSTaRT
//
//  Created by Kurt Höblinger on 07.12.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerView: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.interleaved2of5]
        } else {
            captureSession = nil
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        let button = UIButton(type: .system)
        button.frame = CGRect(x: view.frame.maxX - 8 - 100, y: view.frame.maxY - 8 - 50, width: 100.0, height: 50)
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelScan), for: .touchUpInside)
        self.view.addSubview(button)
        //view.translatesAutoresizingMaskIntoConstraints = false
        //button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 10).isActive = true
        //button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: NSLocalizedString("SCANNER_ERROR_HEADLINE", comment: ""), message: NSLocalizedString("SCANNER_ERROR_BODY", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        delegate.scannerCanceled()
        captureSession = nil
    }
    
    @objc func cancelScan() {
        delegate.scannerCanceled()
        captureSession.stopRunning()
        dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate.foundCode(code: stringValue)
        }
        dismiss(animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
