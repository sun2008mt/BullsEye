//
//  ViewController.swift
//  BullsEye
//
//  Created by Marc SUN on 11/15/17.
//  Copyright © 2017 SUN. All rights reserved.
//

import UIKit
import QuartzCore   //Core Animation
import AVFoundation  //Audio and Video

class ViewController: UIViewController {
    
    //IBOutlet必须使用弱引用声明
    @IBOutlet private weak var totalScoresLabel: UILabel!
    @IBOutlet private weak var roundLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var targetValueLabel: UILabel!
    
    private var curScores: Int = 0
    private var totalScores: Int = 0
    private var round: Int = 0
    private var targetValue: Int = 0
    
    //播放音乐
    private var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //滑动条浮标图片
        let thumbImageNormal = #imageLiteral(resourceName: "SliderThumb-Normal")
        slider.setThumbImage(thumbImageNormal, for: .normal)

        let thumbHighlighted = #imageLiteral(resourceName: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbHighlighted, for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        //拖动轨迹图片
        let trackLeftImage = #imageLiteral(resourceName: "SliderTrackLeft")
        let trackLeftResizable = trackLeftImage.resizableImage(withCapInsets: insets)
        slider.setMinimumTrackImage(trackLeftResizable, for: .normal)
        
        let trackRightImage = #imageLiteral(resourceName: "SliderTrackRight")
        let trackRightResizable = trackRightImage.resizableImage(withCapInsets: insets)
        slider.setMaximumTrackImage(trackRightResizable, for: .normal)
    
        
        //新一轮游戏
        startNewGame()
        
        //播放背景音乐
        playBgMusic()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startNewGame() {
        totalScores = 0
        round = 0
        startNewRound()
        
        //动画(渐变效果)
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        view.layer.add(transition, forKey: nil)
    }
    
    func startNewRound() {
        //增加轮次
        round += 1
        
        //滑动条得到的值是Float类型，使用四舍五入方法转化为Int型
        curScores = lroundf(slider.value)
        
        //生成一个上限为100的随机数(从0开始，但不包括100)
        targetValue = Int(arc4random_uniform(100)) + 1
        
        //更新Label控件的值
        updateLabels()
    }
    
    func updateLabels() {
        roundLabel.text = String(round)
        totalScoresLabel.text = String(totalScores)
        targetValueLabel.text = String(targetValue)
    }
    
    func playBgMusic() {
        let musicPath = Bundle.main.path(forResource: "bgmusic", ofType: "mp3")
        let url = URL.init(fileURLWithPath: musicPath!)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url) //可能会抛出错误
        } catch _{
            audioPlayer = nil
        }
        
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }

    @IBAction func showAlert() {
        let scoresDif = abs(targetValue - curScores)
        var points = 100 - scoresDif
    
        let alertTitle:String
        let alertMessage = "目标值是\(targetValue)，当前值是\(curScores)，您的当前得分是\(points)！"
        
        if scoresDif == 0 {
            alertTitle = "超神了！奖励100分！"
            points += 100
        } else if scoresDif == 99 {
            alertTitle = "太惨了！"
        } else if scoresDif < 5 {
            alertTitle = "太棒了！奖励50分！"
            points += 50
        } else if scoresDif > 40 {
            alertTitle = "悲剧了！"
        } else {
            alertTitle = "很好了！"
        }
        
        totalScores += points
        
        //alert控件定义
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        //动作定义
        let title = "确定"
        //使用闭包（closure）
        let action = UIAlertAction(title: title, style: .default, handler: {
            //alert是异步方式工作的（在action定义的handler处理完成后处理下一个界面变化）
            action in
            self.startNewRound()
        })
        
        //控件关联动作
        alert.addAction(action)
        
        //跳转到另一个页面（相当于安卓里面的startActivity方法）
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sliderMoved(_ slider: UISlider) {
        //lround, lroundf是全局函数，四舍五入
        curScores = lroundf(slider.value)
    }
    
    @IBAction func startOver() {
        startNewGame()
    }
}

