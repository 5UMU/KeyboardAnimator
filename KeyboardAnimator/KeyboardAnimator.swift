//
//  KeyboardAnimator.swift
//  KeyboardAnimator
//
//  Created by Ethan Setnik on 9/17/16.
//  Copyright © 2016 Ethan Setnik. All rights reserved.
//

public protocol KeyboardAnimatorDataSource: class {
  func updateConstraintsForKeyboardTransition(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: [AnyHashable: Any]?)
  weak var keyboardAnimatorView: UIView? { get }
}

public extension KeyboardAnimatorDataSource {
  public func updateConstraintsForKeyboardTransition(direction: KeyboardDirection, keyboardFrame: CGRect, userInfo: [AnyHashable : Any]?) {

  }

  func animateWithKeyboardAnimation(_ direction: KeyboardDirection, beginKeyboardFrame: CGRect, endKeyboardFrame: CGRect, userInfo: AnyObject?) {

  }
}

public protocol KeyboardAnimatorDelegate: class {
  func keyboardWillTransition(direction: KeyboardDirection, notification: Notification)
}

public enum KeyboardDirection {
  // swiftlint:disable:next type_name
  case up, down
}

public enum KeyboardAnimatorError: Error {
  case MissingUserInfo
}

open class KeyboardAnimator {
  public weak var dataSource: KeyboardAnimatorDataSource?
  public weak var delegate: KeyboardAnimatorDelegate?

  private weak var showObserver: AnyObject?
  private weak var hideObserver: AnyObject?

  public func register() {

    let center = NotificationCenter.default

    let notificationHandler = { [weak self] (notification: Notification) -> Void in
      do {
        try self?.keyboardWillTransition(notification: notification)
      } catch KeyboardAnimatorError.MissingUserInfo {
        print("could not transition keyboard for notification \(notification) because there was no userInfo")
      } catch {
        print("could not transition keyboard for notification \(notification) because an unknown error occurred \(error)")
      }
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

  public init() {}

  deinit {
    deregister()
  }

  func keyboardWillTransition(notification: Notification) throws {
    var direction: KeyboardDirection!
    switch notification.name {
    case NSNotification.Name.UIKeyboardWillShow:
      direction = .up
    case NSNotification.Name.UIKeyboardWillHide:
      direction = .down
    default:
      break
    }

    try animateKeyboardTransition(direction: direction, userInfo: notification.userInfo)
    delegate?.keyboardWillTransition(direction: direction, notification: notification)
  }

  func animateKeyboardTransition(direction: KeyboardDirection, userInfo: [AnyHashable: Any]?) throws {

    guard let userInfo = userInfo else {
      throw KeyboardAnimatorError.MissingUserInfo
    }

    let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
    let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
    let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    let keyboardFrmae = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero

    self.dataSource?.keyboardAnimatorView?.layoutIfNeeded()

    dataSource?.updateConstraintsForKeyboardTransition(direction: direction, keyboardFrame: keyboardFrmae, userInfo: userInfo)

    UIView.animate(
      withDuration: duration,
      delay: 0,
      options: animationCurve,
      animations: {
        self.dataSource?.keyboardAnimatorView?.layoutIfNeeded()
      },
      completion: nil
    )
  }
}

