//
//  ViewController.swift
//  KeyboardAnimatorExample
//
//  Created by Ethan Setnik on 9/17/16.
//  Copyright © 2016 Sumu. All rights reserved.
//

import UIKit
import KeyboardAnimator

class ViewController: UIViewController, KeyboardAnimatorDataSource, KeyboardAnimatorDelegate {

  @IBOutlet private weak var textField: UITextField!

  let keyboardAnimator = KeyboardAnimator()
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  var bottomConstraintConstant: CGFloat!

  override func viewDidLoad() {
    super.viewDidLoad()

    bottomConstraintConstant = bottomConstraint.constant

    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
    view.addGestureRecognizer(tapGestureRecognizer)

    keyboardAnimator.dataSource = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tapGestureRecognized() {
    textField.resignFirstResponder()
  }

  // MARK: KeyboardAnimatorDataSource
  public func updateConstraintsForKeyboardTransition(_ direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: [AnyHashable : Any]?) {
    print("updateConstraintsForKeyboardTransition: direction=\(direction), keyboardFrame=\(keyboardFrame), userInfo=\(userInfo)")

    switch direction {
    case .up:
      bottomConstraint.constant = bottomConstraintConstant + keyboardFrame.height
    case .down:
      bottomConstraint.constant = bottomConstraintConstant
    }
  }

  public func animateWithKeyboardAnimation(_ direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: [AnyHashable : Any]?) {
    print("animateWithKeyboardAnimation: direction=\(direction), keyboardFrame=\(keyboardFrame), userInfo=\(userInfo)")
  }

  weak public var keyboardAnimatorView: UIView? {
    return view
  }

  // MARK: KeyboardAnimatorDelegate
  func keyboardWillTransition(_ direction: KeyboardDirection, notification: Notification) {
    print("keyboardWillTransition: direction=\(direction), notification=\(notification)")
  }
}

