//
//  ViewController.swift
//  KeyboardAnimatorExample
//
//  Created by Ethan Setnik on 9/17/16.
//  Copyright © 2016 Sumu. All rights reserved.
//

import UIKit
import KeyboardAnimator

class ViewController: UIViewController, KeyboardAnimatorDataSource {
  @IBOutlet private weak var textField: UITextField!

  let keyboardAnimator = KeyboardAnimator()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
    view.addGestureRecognizer(tapGestureRecognizer)

    keyboardAnimator.register()
    keyboardAnimator.dataSource = self
  }

  deinit {
    keyboardAnimator.deregister()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tapGestureRecognized() {
    textField.resignFirstResponder()
  }

  // MARK: KeyboardAnimatorDataSource
  public func updateConstraintsForKeyboardTransition(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: [AnyHashable : Any]?) {
    print("direction=\(direction), keyboardFrame=\(keyboardFrame), userInfo=\(userInfo)")
  }

  weak public var keyboardAnimatorView: UIView? {
    return view
  }

}

