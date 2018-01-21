//
//  ViewController.swift
//  flashcard
//
//  Created by KazukiMatsuda on 2018/01/19.
//  Copyright © 2018年 Kazuki Matsuda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var wordDict:[String:String] = [:]
    var wordKeysArray:[String] = []
    var wordValuesArray:[String] = []
    var cardNumber = 0
    
    let blueColor = UIColor(red: 0.329, green: 0.584, blue: 0.945, alpha: 1.0)
    let redColor = UIColor(red: 0.937, green: 0.325, blue: 0.314, alpha: 1.0)
    
    @IBOutlet weak var basicCard: UIView!
    @IBOutlet weak var nextCard: UIView!
    @IBOutlet weak var nextCheckLabel: UILabel!
    
    @IBOutlet weak var wordCard: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var checkbutton: UIButton!
    
    var centerOfCard: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerOfCard = basicCard.center
        cardNumber = 0
        
        setUI()
        resetDict()
        resetCard()
    }
    
    //  UIの生成
    func setUI() {
        wordCard.layer.cornerRadius = 20
        wordCard.layer.shadowColor = UIColor.black.cgColor
        wordCard.layer.shadowOpacity = 0.5
        wordCard.layer.shadowOffset = CGSize(width: 5, height: 5)
        wordCard.layer.shadowRadius = 5
        basicCard.layer.cornerRadius = 20
        checkLabel.layer.cornerRadius = 15
        checkLabel.clipsToBounds = true
        checkLabel.backgroundColor = blueColor
        nextCard.layer.cornerRadius = 20
        nextCard.layer.shadowColor = UIColor.black.cgColor
        nextCard.layer.shadowOpacity = 0.5
        nextCard.layer.shadowOffset = CGSize(width: 5, height: 5)
        nextCard.layer.shadowRadius = 5
        nextCheckLabel.layer.cornerRadius = 15
        nextCheckLabel.clipsToBounds = true
        nextCheckLabel.backgroundColor = blueColor
    }
    
    func resetDict() {
        
        let defaults = UserDefaults.standard
        if let storedWordDict = defaults.dictionary(forKey: "wordDict") as? [String: String] {
            wordDict = storedWordDict
        }
        if wordDict.count > 0 {
            wordKeysArray = Array(wordDict.keys)
            wordValuesArray = Array(wordDict.values)
        }
        
    }
    
    func resetCard() {
        basicCard.center = centerOfCard
        wordCard.center = centerOfCard
        checkLabel.backgroundColor = blueColor
        wordCard.isHidden = false
        
        if wordDict.count > 0 {
            wordLabel.font = wordLabel.font.withSize(50)
            pageLabel.text = String(cardNumber + 1 ) + " / " + String(wordKeysArray.count)
            wordLabel.text = wordKeysArray[cardNumber]
            checkLabel.isHidden = false
            checkLabel.text = "意味"
        } else {
            wordLabel.font = wordLabel.font.withSize(25)
            pageLabel.text = ""
            wordLabel.text = "単語を追加してください"
            checkLabel.isHidden = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if checkLabel.backgroundColor == blueColor {
            wordLabel.text = wordValuesArray[cardNumber]
            wordLabel.font = wordLabel.font.withSize(38)
            checkLabel.backgroundColor = redColor
            checkLabel.text = "単語"
        } else {
            wordLabel.text = wordKeysArray[cardNumber]
            wordLabel.font = wordLabel.font.withSize(50)
            checkLabel.backgroundColor = blueColor
            checkLabel.text = "意味"
        }
    }
    
    @IBAction func swipeCard(_ sender: UIPanGestureRecognizer) {
        
        guard wordDict.count > 1 else {
            return
        }
        
        let card = sender.view!
        let point = sender.translation(in: view)
        
        card.center = CGPoint(x: card.center.x + point.x, y: card.center.y)
        wordCard.center = CGPoint(x: card.center.x + point.x, y: card.center.y)
        
        //角度を変える
        if sender.state == UIGestureRecognizerState.ended {
            // 左に大きくスワイプ
            if card.center.x < 75 {
                UIView.animate(withDuration: 0.2, animations: {
                    if self.cardNumber >= self.wordValuesArray.count - 1 {
                        self.cardNumber = 0
                    } else {
                        self.cardNumber += 1
                    }
                })
                wordCard.isHidden = true
                self.resetCard()
                return
                // 右に大きくスワイプ
            } else if card.center.x > self.view.frame.width - 75 {
                UIView.animate(withDuration: 0.2, animations: {
                    if self.cardNumber <= 0 {
                        self.cardNumber = self.wordValuesArray.count - 1
                    } else {
                        self.cardNumber -= 1
                    }
                })
                wordCard.isHidden = true
                self.resetCard()
                return
            }
            // もとに戻る処理
            UIView.animate(withDuration: 0.2, animations: {
                self.resetCard()
                self.wordCard.center = self.centerOfCard
            })
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "単語の追加", message: "単語と意味を入力してください", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField:UITextField) -> Void in
            textField.placeholder = "単語"
        })
        alert.addTextField(configurationHandler: { (textField:UITextField) -> Void in
            textField.placeholder = "意味"
        })
        alert.addAction(UIAlertAction(title: "追加", style: .default, handler: { (action:UIAlertAction) -> Void in
            let textField1 = alert.textFields![0].text!
            let textField2 = alert.textFields![1].text!
            
            self.wordDict[textField1] = textField2
            
            // 保存処理
            let defaults = UserDefaults.standard
            defaults.set(self.wordDict, forKey: "wordDict")
            defaults.synchronize()
            
            self.cardNumber = 0
            self.resetDict()
            self.resetCard()
            
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action:UIAlertAction) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
        guard wordDict.count > 0 else {
            return
        }
        
        let alert = UIAlertController(title: "単語の削除", message: "削除しますか？", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "削除", style: .default, handler: { (action:UIAlertAction) -> Void in
            
            self.wordDict.removeValue(forKey: self.wordKeysArray[self.cardNumber])
            
            // 削除後の辞書をuserDefaultsに保存
            let defaults = UserDefaults.standard
            defaults.set(self.wordDict, forKey: "wordDict")
            defaults.synchronize()
            
            self.cardNumber = 0
            self.resetDict()
            self.resetCard()
            
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action:UIAlertAction) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}


