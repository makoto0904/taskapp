//
//  InputVIewController.swift
//  taskapp
//
//  Created by 小野真 on 2021/02/25.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
  
    @IBOutlet weak var titleTextFIeld: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    
    
    let realm = try! Realm()
    var task: Task! //追加
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景をタップしたらdismissKeyboadメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(disimissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextFIeld.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        category.text = task.category
    
    }
        @objc func disimissKeyboard(){
        //キーボード を閉じる
        view.endEditing(true)

        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextFIeld.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.category.text!
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task) //追加
        
        super.viewWillDisappear(animated)
    }
    //タスクのローカル通知を登録する---ここから---
    func  setNotification(task: Task){
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定（中身がない場合メッセージ無しで音だけの通知になるので「（xx無し）」を表示する）
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するtrigger(日付マッチ）を作成
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) {(error) in
            print(error ?? "ローカル通知登録　OK")
            //errorがnilなたローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します
        }
        
        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest])
            in
            for request in requests{
                print("/------------------")
                print(request)
                print("-------------------")
            }
                
            }
    }
    
    
    @objc func dismiddKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    }

