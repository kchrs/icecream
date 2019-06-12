/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import Toaster

public class PickFlavorViewController: UIViewController {

  // MARK: - Instance Properties
  public var flavors: [Flavor] = []
  fileprivate let flavorFactory = FlavorFactory()

  // MARK: - Outlets
  @IBOutlet var contentView: UIView!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var iceCreamView: IceCreamView!
  @IBOutlet var label: UILabel!

  override public func viewDidLoad() {
    super.viewDidLoad()
    if (AccessToken.current != nil) {
      print("acc fb token")
      print(AccessToken.current?.tokenString)
    }
    let loginButton = FBLoginButton()
    // Optional: Place the button in the center of your view.
    loginButton.center = view.center
    view.addSubview(loginButton)

    
  }
  
  
  // MARK: - View Lifecycle
//  public override func viewDidLoad() {
//    super.viewDidLoad()
//
//    loadFlavors()
//  }

  fileprivate func loadFlavors() {
    
    // 1
    
    
//    var nsDictionary: NSDictionary?
//    if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
//      nsDictionary = NSDictionary(contentsOfFile: path)
//    }
    
    
    Alamofire.request(
      "https://www.raywenderlich.com/downloads/Flavors.plist",
      method: .get,
      encoding: PropertyListEncoding(format: .xml, options: 0)).responsePropertyList {
        [weak self] response in
        
        // 2
        guard let strongSelf = self else { return }
        
        // 3
        guard response.result.isSuccess,
          let dictionaryArray = response.result.value as? [[String: String]] else {
            return
        }
        
        // 4
        strongSelf.flavors = strongSelf.flavorFactory.flavors(from: dictionaryArray)
        
        // 5
        strongSelf.collectionView.reloadData()
        strongSelf.selectFirstFlavor()
    }
  }
  


  fileprivate func selectFirstFlavor() {
    guard let flavor = flavors.first else {
      return
    }
    update(with: flavor)
  }
}

// MARK: - FlavorAdapter
extension PickFlavorViewController: FlavorAdapter {

  public func update(with flavor: Flavor) {
    iceCreamView.update(with: flavor)
    label.text = flavor.name
  }
}

// MARK: - UICollectionViewDataSource
extension PickFlavorViewController: UICollectionViewDataSource {

  private struct CellIdentifiers {
    static let scoop = "ScoopCell"
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return flavors.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifiers.scoop, for: indexPath) as! ScoopCell
    let flavor = flavors[indexPath.row]
    cell.update(with: flavor)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension PickFlavorViewController: UICollectionViewDelegate {

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let flavor = flavors[indexPath.row]
    update(with: flavor)
  }
}
