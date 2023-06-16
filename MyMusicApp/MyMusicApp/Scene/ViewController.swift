//
//  ViewController.swift
//  MyMusicApp
//
//  Created by 지희의 MAC on 2023/06/16.
//

import UIKit
import SnapKit
import AVFoundation

class ViewController: UIViewController {
    
    //MARK: - Property
    let playImage = UIImage(systemName: "play.fill")?.resized(to: CGSize(width: 200, height: 200), tintColor: .blue)
    let pauseImage = UIImage(systemName: "pause.fill")?.resized(to: CGSize(width: 200, height: 200), tintColor: .blue)
    
    var player: AVAudioPlayer!
    var timer: Timer!
    
    //MARK: - UI Components
    private lazy var playPauseButton : UIButton = {
        let button = UIButton()
        button.tintColor = .blue
        button.setImage(playImage, for: .normal)
        button.setImage(pauseImage, for: .selected)
        button.tintColor = .blue
        button.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        return button
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00:00"
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var progressSlider : UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    //MARK: -LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        initializePlayer()
    }
    
    //MARK: -CustomMethod
    private func setUI(){
        setViewHierarchy()
        setConstraints()
        view.backgroundColor = .white
    }
    
    private func setViewHierarchy() {
        view.addSubviews(playPauseButton,timeLabel,progressSlider)
    }
    
    private func setConstraints() {
        playPauseButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-40)
            $0.size.equalTo(200)
        }
        
        timeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(playPauseButton.snp.bottom).offset(20)
        }
        
        progressSlider.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(timeLabel.snp.bottom).offset(20)
            $0.width.equalTo(300)
            
        }
    }
    
    func initializePlayer() {
        
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올 수 없습니다")
            return
        }
        
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지 : \(error.localizedDescription)")
        }
        
        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
    }
    
    func updateTimeLabelText(time: TimeInterval) {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        self.timeLabel.text = timeText
    }
    
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
            
            if self.progressSlider.isTracking { return }
            
            self.updateTimeLabelText(time: self.player.currentTime)
            self.progressSlider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    func invalidateTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    //MARK: -Action
    @objc func didTapPlayButton(_ sender: UIButton){
        sender.isSelected = !(sender.isSelected)
        
        if sender.isSelected {
            self.player?.play()
        } else {
            self.player?.pause()
        }
        
        if sender.isSelected {
            self.makeAndFireTimer()
        } else {
            self.invalidateTimer()
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
            self.updateTimeLabelText(time: TimeInterval(sender.value))
            if sender.isTracking { return }
            self.player.currentTime = TimeInterval(sender.value)
        }
        
    
}

//MARK: -extension
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        guard let error: Error = error else {
            print("오디오 플레이어 디코드 오류발생")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (action: UIAlertAction) -> Void in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidateTimer()
    }
    
}

