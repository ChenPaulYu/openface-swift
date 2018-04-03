//
//  ViewController.swift
//  opencv-test
//
//  Created by Bernie on 2018/3/22.
//  Copyright © 2018年 PaulChen. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var session = AVCaptureSession()
    var previewImage = UIImage()
    var frame_count = 0;
    
    
    @IBAction func reset(_ sender: Any) {
        reset();
    }
    override func viewDidLoad() {
        startLiveVideo()
        super.viewDidLoad()
        _ = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.setPreviewImage), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     
    func startLiveVideo() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]

        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait;
        connection.isVideoMirrored = true
        updatePreviewImage(sampleBuffer:sampleBuffer)
        
    }
    func updatePreviewImage(sampleBuffer: CMSampleBuffer){
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        previewImage = self.convertCIImageToUIImage(cmage: ciimage)
    }
    func convertCIImageToUIImage(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
        return image
    }
    
    @objc func setPreviewImage(){
        
        /* ImageConverter => objective-c與swift的接口物件，裡面定義了多個functuon 詳細如下
        
         (UIImage)getBinaryImage(UIImage) => 輸入未經處理的照片，回傳原圖回來（只是用來測試opencv）
         
         (UIImage)processImage(UIImage) => 輸入未經處理的照片，回傳加上追蹤點的照片
         
         (double)getdistance(void) => 取得眼睛與螢幕的距離，回傳值回一double小數（值在200-350時有較好的效果）
         
         (bool *)getdirection(void) => 取得各種眼睛的動作，包含「左、右、上、左眨、右眨」，回傳職回一個指標位置（下面有程式把它轉成array了！）
         
         其中陣列裡，
            [0] => 左
            [1] => 右
            [2] => 上
            [3] => 左眨
            [4] => 右眨
        */
        
        //let image = ImageConverter.getBinaryImage(previewImage) -> 此為測試opencv function （只會回傳沒有經過處理的照片）
        let image = ImageConverter.processImage(previewImage,frame__:Int32(frame_count))
        imageView.image = image
        frame_count = frame_count + 1
        
        let movementArray = Array(UnsafeBufferPointer(start: ImageConverter.getdirection(), count: 5)) // 把指標位置轉成array
        let distance = ImageConverter.getdistance()
        
//        print(distance)
        
//        if(movementArray[0] == true){
//            print("左");
//
//        }
//
//        if(movementArray[1] == true){
//            print("右");
//        }
//
//        if(movementArray[2] == true){
//            print("上");
//        }
//
        
        // movementArray[0] => 左 (true)
        // movementArray[1] => 右 (true)
        // movementArray[2] => 上 (true)
        // movementArray[3] => 左眨 (true)
        // movementArray[4] => 右眨 (true)
        // distance => 眼睛與臉的距離
        
        
    }
    
    @objc func reset(){
        ImageConverter.resetCapture();
    }
    
    
    



}

