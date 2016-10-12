//
//  KeyboardAnimator.swift
//  KeyboardAnimator
//
//  Created by Ethan Setnik on 9/17/16.
//  Copyright © 2016 Ethan Setnik. All rights reserved.
//

import UIKit
public protocol KeyboardAnimatorDataSource: class {
  func updateConstraintsForKeyboardTransition(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: AnyObject?)
  func animateWithKeyboardAnimation(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: AnyObject?)

  weak var keyboardAnimatorView: UIView? { get }
}

public protocol KeyboardAnimatorDelegate: class {
  func keyboardWillTransition(direction: KeyboardDirection, notification: NSNotification)
}

public enum KeyboardDirection {
  // swiftlint:disable:next type_name
  case Up, Down
}

public class KeyboardAnimator {
  public weak var dataSource: KeyboardAnimatorDataSource?
  public weak var delegate: KeyboardAnimatorDelegate?

  private weak var showObserver: AnyObject?
  private weak var hideObserver: AnyObject?

  private func register() {

    let center = NSNotificationCenter.defaultCenter()

    let notificationHandler = { [weak self] (notification: NSNotification) -> Void in
      self?.keyboardWillTransition(notification)
    }

    if showObserver == nil {
      //            print("registering keyboard animation show observer for \(dataSource)")
      showObserver = center.addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: notificationHandler)
    }

    if hideObserver == nil {
      //            print("registering keyboard animation hide observer for \(dataSource)")
      hideObserver = center.addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: notificationHandler)
    }
  }

  private func deregister() {
    let center = NSNotificationCenter.defaultCenter()

    if let showObserver = showObserver {
      //            print("deregistering keyboard animation show observer for \(dataSource)")
      center.removeObserver(showObserver)
      self.showObserver = nil
    }

    if let hideObserver = hideObserver {
      //            print("deregistering keyboard animation hide observer for \(dataSource)")
      center.removeObserver(hideObserver)
      self.hideObserver = nil
    }
  }

  public init() {
    register()
  }

  deinit {
    deregister()
  }

  private func keyboardWillTransition(notification: NSNotification) {
    var direction: KeyboardDirection!
    switch notification.name {
    case UIKeyboardWillShowNotification:
      direction = .Up
    case UIKeyboardWillHideNotification:
      direction = .Down
    default:
      break
    }

    animateKeyboardTransition(direction, userInfo: notification.userInfo)
    delegate?.keyboardWillTransition(direction, notification: notification)
  }

  private func animateKeyboardTransition(direction: KeyboardDirection, userInfo: AnyObject?) {

    guard let userInfo = userInfo else {
      return
    }

    let duration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRect.zero

    dataSource?.keyboardAnimatorView?.layoutIfNeeded()
    dataSource?.updateConstraintsForKeyboardTransition(direction, keyboardFrame: keyboardFrame, userInfo: userInfo)

    UIView.animateWithDuration(
      duration,
      delay: 0,
      options: animationCurve,
      animations: { [weak self] in
        self?.dataSource?.animateWithKeyboardAnimation(direction, keyboardFrame: keyboardFrame, userInfo: userInfo)
        self?.dataSource?.keyboardAnimatorView?.layoutIfNeeded()
      },
      completion: nil
    )
  }
}
