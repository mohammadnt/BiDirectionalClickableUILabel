//
//  ViewController.swift
//  BiDirectionalUILabel
//
//  Created by zigzag on 26/4/2022.
//
import GrowingTextView
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var growingTextView: GrowingTextView!
    @IBOutlet weak var BottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var customLabel: CustomLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        customLabel.font = UIFont.systemFont(ofSize: 16)
        customLabel.CreateWidthCons = false
        customLabel.delegate = self
        customLabel.text = "sample\nسمپل\nsample سمپل\nسمپل sample\n@text #text\n/text\nclickable text"
        customLabel.FindElements()
        customLabel.FineSlashCommandsClickable()
        let wantedText = "clickable text"
        let s = customLabel.text! as NSString
        customLabel.AddElement(range: s.range(of: wantedText), element: ActiveElement.mention(wantedText), type: ActiveType.mention)
        customLabel.CreateAtrStr(size: nil, addLineSpace: true)
//        customLabel.manuallyAddElement(styles: styles)
        growingTextView.delegate = self
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    var defaultViewY : CGFloat = 0
    override func viewWillAppear(_ animated: Bool) {
        
        defaultViewY = self.view.frame.origin.y
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    @IBAction func onButton(_ sender: Any) {
        customLabel.text = growingTextView.text
        customLabel.FindElements()
        customLabel.FineSlashCommandsClickable()
        customLabel.CreateAtrStr(size: nil, addLineSpace: true)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue) as! Double
        if (duration != 0.35) {
            BottomViewBottomConstraint.constant = targetFrame.height  - AppDelegate.bottomNotch
        }

        self.view.layoutIfNeeded()

    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue) as! Double
        if (duration != 0.35) {
            HideKeyboard()
        }
        
    }
    func HideKeyboard() {
      
        BottomViewBottomConstraint.constant = 0
    }
    @objc func keyboardChangeFrame(notification: NSNotification) {
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! NSValue) as! Double
        
        if (duration != 0.35) {
            

            BottomViewBottomConstraint.constant = targetFrame.height  - AppDelegate.bottomNotch
        }

        
    }
}


extension ViewController: GrowingTextViewDelegate  {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
}

extension ViewController: CustomLabelDelegate{
    func didSelect(_ text: String, type: ActiveType, style: MessageTextStyle?) {
        let alertController = UIAlertController(title: "You clicked on:", message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: {
            print("completed")
        })
    }
    
    
}
