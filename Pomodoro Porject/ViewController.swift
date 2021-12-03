//
//  ViewController.swift
//  Pomodoro Porject
//
//  Created by Alikhan Tuxubayev on 30.11.2021.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {

    var timer = Timer()
    var durationTimer = 10

    var isWorkTime: Bool = true
    var isTimerStarted: Bool = false
    var isAnimationStarted: Bool = false
    
    let animation = CABasicAnimation(keyPath: "strokeEnd")

    private lazy var startOrPauseButton: UIButton = {
        let button = UIButton(type: .system)
        let iconSize = UIImage.SymbolConfiguration(pointSize: 30)
        button.setImage(UIImage(systemName: "play", withConfiguration: iconSize), for: .normal)
        button.tintColor = .systemGreen
        button.addTarget(self, action: #selector(startOrPauseButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.systemRed, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        return button
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.center = view.center
        label.text = "00:10"
        label.font = .systemFont(ofSize: 40, weight: .light)
        label.textColor = .systemGreen
        label.textAlignment = .left
        label.lineBreakMode = .byClipping


        return label
    }()

    private lazy var circularPath: UIBezierPath = {
        let circularPath = UIBezierPath(arcCenter: view.center, radius: 138, startAngle: 2 * CGFloat.pi + (-CGFloat.pi / 2), endAngle: (-CGFloat.pi / 2), clockwise: false)

        return circularPath
    }()

    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.systemGreen.cgColor
        shapeLayer.lineWidth = 15
        shapeLayer.lineCap = CAShapeLayerLineCap.round

        return shapeLayer
    }()

    private lazy var trackLayer: CAShapeLayer = {
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.systemGray.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 15
        trackLayer.lineCap = CAShapeLayerLineCap.round

        return trackLayer
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHierarchy()
        setupLayout()
        setupView()
    }

    // MARK: - Settings

    private func setupHierarchy() {
        [timeLabel, startOrPauseButton, cancelButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.layer.addSublayer(trackLayer)
    }

    private func setupLayout() {

        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            startOrPauseButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 40),
            startOrPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startOrPauseButton.widthAnchor.constraint(equalToConstant: 50),
            startOrPauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: startOrPauseButton.bottomAnchor, constant: 200)
        ])
    }

    private func setupView() {
    }

    // MARK: - for time
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func updateTimer() {
        if durationTimer < 1 {
            timer.invalidate()
            isTimerStarted = false
            stopAnimate()
            changeMode()
        } else {
            durationTimer -= 1
            timeLabel.text = formatTimer()
            print(formatTimer())
        }
    }

    private func formatTimer() -> String {
        let minutes = Int(durationTimer) / 60 % 60
        let seconds = Int(durationTimer) % 60
        return String(format: "%2i:%02i", minutes, seconds)
    }

    //MARK: - For change logic and style
   
    private func changeMode() {
        if isWorkTime {
            durationTimer = 5
            timeLabel.text = "00:05"
            shapeLayer.strokeColor = UIColor.systemRed.cgColor
            timeLabel.textColor = .systemRed
            changeIcon("play", startOrPauseButton, .systemRed)
            isWorkTime = false
        } else {
            durationTimer = 10
            timeLabel.text = "00:10"
            shapeLayer.strokeColor = UIColor.systemGreen.cgColor
            timeLabel.textColor = .systemGreen
            changeIcon("play", startOrPauseButton, .systemGreen)
            isWorkTime = true
        }
    }
    
    private func changeIcon(_ icon: String, _ button: UIButton, _ color: UIColor) {
        let iconSize = UIImage.SymbolConfiguration(pointSize: 30)
        button.tintColor = color
        button.setImage(UIImage(systemName: icon, withConfiguration: iconSize), for: .normal)
    }


    //MARK: - Button Tapped

    @objc private func startOrPauseButtonTapped() {
        if !isTimerStarted {
            trackLayer.addSublayer(shapeLayer)
            startResumeAnimation()
            startTimer()
            isTimerStarted = true
            
            if isWorkTime {
                changeIcon("pause", startOrPauseButton, .systemGreen)
            } else {
                changeIcon("pause", startOrPauseButton, .systemRed)
            }

        } else {
            pauseAnimate()
            timer.invalidate()
            isTimerStarted = false
            
            if isWorkTime {
                changeIcon("play", startOrPauseButton, .systemGreen)
            } else {
                changeIcon("play", startOrPauseButton, .systemRed)
            }

        }
    }

    @objc private func cancelButtonTapped() {
        stopAnimate()
        timer.invalidate()
        durationTimer = 10
        isTimerStarted = false
        isWorkTime = true
        timeLabel.text = "00:10"
        timeLabel.textColor = .systemGreen
        changeIcon("play", startOrPauseButton, .systemGreen)
        shapeLayer.strokeColor = UIColor.systemGreen.cgColor
    }

    //MARK: - Animations

    private func startResumeAnimation() {
        if !isAnimationStarted {
            startAnimate()
        } else {
            resumeAnimate()
        }
    }

    private func startAnimate() {
        resetAnimation()
        shapeLayer.strokeEnd = 0.0
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(durationTimer)
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        shapeLayer.add(animation, forKey: "strokeEnd")
        isAnimationStarted = true

    }

    private func resetAnimation() {
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        shapeLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }

    private func resumeAnimate() {
        let pause = shapeLayer.timeOffset
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        let timeSincePaused = shapeLayer.convertTime(CACurrentMediaTime(), from: nil) - pause
        shapeLayer.beginTime = timeSincePaused
    }

    private func pauseAnimate() {
        let pause = shapeLayer.convertTime(CACurrentMediaTime(), from: nil)
        shapeLayer.speed = 0.0
        shapeLayer.timeOffset = pause
    }

    private func stopAnimate() {
        shapeLayer.speed = 1.0
        shapeLayer.timeOffset = 0.0
        shapeLayer.beginTime = 0.0
        shapeLayer.strokeEnd = 0.0
        shapeLayer.removeAllAnimations()
        isAnimationStarted = false
    }

    // reset progress bar animation
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimate()
    }

}


