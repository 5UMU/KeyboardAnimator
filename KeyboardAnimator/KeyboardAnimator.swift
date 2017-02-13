//
//  KeyboardAnimator.swift
//  KeyboardAnimator
//
//  Created by Ethan Setnik on 9/17/16.
//  Copyright © 2016 Ethan Setnik. All rights reserved.
//

import UIKit
public protocol KeyboardAnimatorDataSource: class {
  func updateConstraintsForKeyboardTransition(_ direction: KeyboardDirection, beginKeyboardFrame: CGRect, endKeyboardFrame: CGRect, userInfo: [AnyHashable: Any]?)
  func animateWithKeyboardAnimation(_ direction: KeyboardDirection, beginKeyboardFrame: CGRect, endKeyboardFrame: CGRect, userInfo: [AnyHashable: Any]?)

  weak var keyboardAnimatorView: UIView? { get }
}

public protocol KeyboardAnimatorDelegate: class {
  func keyboardWillTransition(_ direction: KeyboardDirection, notification: Notification)
}

public enum KeyboardDirection {
  // swiftlint:disable:next type_name
  case up, down
}

open class KeyboardAnimator {
  public weak var dataSource: KeyboardAnimatorDataSource?
  public weak var delegate: KeyboardAnimatorDelegate?

  private weak var showObserver: AnyObject?
  private weak var hideObserver: AnyObject?

  public func register() {

    let center = NotificationCenter.default

    let notificationHandler = { [weak self] (notification: Notification) -> Void in
      self?.keyboardWillTransition(notification)
    }

    if showObserver == nil {
      //            print("registering keyboard animation show observer for \(dataSource)")
      showObserver = center.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main, using: notificationHandler)
    }

    if hideObserver == nil {
      //            print("registering keyboard animation hide observer for \(dataSource)")
      hideObserver = center.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main, using: notificationHandler)
    }
  }

  public func deregister() {
    let center = NotificationCenter.default

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

  func keyboardWillTransition(_ notification: Notification) {
    var direction: KeyboardDirection!
    switch notification.name {
    case NSNotification.Name.UIKeyboardWillShow:
      direction = .up
    case NSNotification.Name.UIKeyboardWillHide:
      direction = .down
    default:
      break
    }

    animateKeyboardTransition(direction, userInfo: notification.userInfo)
    delegate?.keyboardWillTransition(direction, notification: notification)
  }

  func animateKeyboardTransition(_ direction: KeyboardDirection, userInfo: [AnyHashable: Any]?) {
    guard let userInfo = userInfo else { return }

    let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    let beginKeyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
    let endKeyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero

    dataSource?.keyboardAnimatorView?.layoutIfNeeded()
    dataSource?.updateConstraintsForKeyboardTransition(direction, beginKeyboardFrame: beginKeyboardFrame, endKeyboardFrame: endKeyboardFrame, userInfo: userInfo)

    UIView.animate(
                   withDuration: duration,
                   delay: 0,
                   options: animationCurve,
                   animations: { [weak self] in
      self?.dataSource?.animateWithKeyboardAnimation(direction, beginKeyboardFrame: beginKeyboardFrame, endKeyboardFrame: endKeyboardFrame, userInfo: userInfo)
      self?.dataSource?.keyboardAnimatorView?.layoutIfNeeded()
    },
                   completion: nil
    )
  }
}
