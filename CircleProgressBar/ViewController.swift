//
//  ViewController.swift
//  CircleProgressBar
//
//  Created by Hook Banner on 13.03.2021.
//

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {
    
    var pulsatingLayer: CAShapeLayer!
    
    let percentageLabel: UILabel = {
       let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
        return label
    }()
    let shapeLayer = CAShapeLayer()
    let urlString = "https://static.videezy.com/system/resources/previews/000/053/947/original/4k-abstract-digital-text-minute-red-sample-fx-background-clip.mp4"
    
    ///
    /// эта функция нужна для того чтобы если приложение уходило с первого плана и затем вернулось
    /// запустить анимацию пульсауии вновь
    ///
    func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: UIApplication.willEnterForegroundNotification , object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulasatingLayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
        
        
        setupNotificationObservers()
        
        //let center = view.center
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        ///
        /// то что будет пульсировать
        ///
        pulsatingLayer = CAShapeLayer()
        pulsatingLayer.path = circularPath.cgPath
        pulsatingLayer.fillColor = UIColor.pulsatingFillColor.cgColor
        pulsatingLayer.position = view.center
        view.layer.addSublayer(pulsatingLayer)
        animatePulasatingLayer()
        
        
        
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 20
        trackLayer.lineCap = .round
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.position = view.center
        //trackLayer.strokeEnd = 1
        view.layer.addSublayer(trackLayer)
        
        
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.backgroundColor.cgColor
        shapeLayer.position = view.center
        shapeLayer.transform = CATransform3DMakeRotation((-CGFloat.pi) / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
        
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        view.addSubview(percentageLabel)
        
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func animatePulasatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }

    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        
        ///
        /// эти две строчки нужны чтобы линия анимации не пропадала по завершению анимации
        ///
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        ///
        /// forKey здесь используется какая-нибудь строка рандомная, но при этом она должна быть уникальной
        ///
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    @objc private func handleTap() {
        beginDownloadingFile()
        //animateCircle()
    }
    
    func beginDownloadingFile() {
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        
        guard let url = URL(string: urlString) else {
            print("Something went wrong...")
            return
        }
        shapeLayer.strokeEnd = 0
        
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("finished downloading")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        print(percentage)
        
        DispatchQueue.main.async {
            self.shapeLayer.strokeEnd = percentage
            self.percentageLabel.text = "\(Int(percentage*100))%"
        }
    }
}

