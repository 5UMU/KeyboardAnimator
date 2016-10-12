//
//  KeyboardAnimator.swift
//  KeyboardAnimator
//
//  Created by Ethan Setnik on 9/17/16.
//  Copyright © 2016 Ethan Setnik. All rights reserved.
//

import UIKit
protocol KeyboardAnimatorDataSource: class {
  func updateConstraintsForKeyboardTransition(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: AnyObject?)
  func animateWithKeyboardAnimation(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: AnyObject?)

  weak var keyboardAnimatorView: UIView? { get }
}

extension KeyboardAnimatorDataSource {
  func updateConstraintsForKeyboardTransition(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: AnyObject?) {}

  func animateWithKeyboardAnimation(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: AnyObject?) {}
}

protocol KeyboardAnimatorDelegate: class {
  func keyboardWillTransition(direction: KeyboardDirection, notification: NSNotification)
}

enum KeyboardDirection {
  // swiftlint:disable:next type_name
  case Up, Down
}

enum KeyboardAnimatorError: ErrorType {
  case MissingUserInfo
}

class KeyboardAnimator {
  weak var dataSource: KeyboardAnimatorDataSource?
  weak var delegate: KeyboardAnimatorDelegate?

  weak var showObserver: AnyObject?
  weak var hideObserver: AnyObject?

  func register() {

    let center = NSNotificationCenter.defaultCenter()

    let notificationHandler = { [weak self](notification: NSNotification) -> Void in
      do {
        try self?.keyboardWillTransition(notification)
      } catch KeyboardAnimatorError.MissingUserInfo {
        print("could not transition keyboard for notification \(notification) because there was no userInfo")
      } catch {
        print("could not transition keyboard for notification \(notification) because an unknown error occurred \(error)")
      }
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

  func deregister() {
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

  deinit {
    deregister()
  }

  func keyboardWillTransition(notification: NSNotification) throws {
    var direction: KeyboardDirection!
    switch notification.name {
    case UIKeyboardWillShowNotification:
      direction = .Up
    case UIKeyboardWillHideNotification:
      direction = .Down
    default:
      break
    }

    try animateKeyboardTransition(direction, userInfo: notification.userInfo)
    delegate?.keyboardWillTransition(direction, notification: notification)
  }

  func animateKeyboardTransition(direction: KeyboardDirection, userInfo: AnyObject?) throws {

    guard let userInfo = userInfo else {
      throw KeyboardAnimatorError.MissingUserInfo
    }

    let duration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRect.zero

    self.dataSource?.keyboardAnimatorView?.layoutIfNeeded()

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
