//
//  MultiSelectionCollectionView.swift
//  SwiftMultiSelect
//
//  Created by Luca Becchetti on 26/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Contacts
import Foundation

extension MultiSelecetionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return selectedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CustomCollectionCell

        // Try to get item from delegate
        var item = selectedItems[indexPath.row]

        // Add target for the button
        cell.removeButton.addTarget(self, action: #selector(MultiSelecetionViewController.handleTap(sender:)), for: .touchUpInside)
        cell.removeButton.accessibilityIdentifier = item.id
        cell.labelTitle.text = item.title
        cell.initials.isHidden = true
        cell.imageAvatar.isHidden = true

        // Test if items it's CNContact
        if let contact = item.userInfo as? CNContact {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                // Build contact image in background
                if contact.imageDataAvailable && contact.imageData!.count > 0 {
                    let img = UIImage(data: contact.imageData!)
                    DispatchQueue.main.async {
                        item.image = img
                        cell.imageAvatar.image = img
                        cell.initials.isHidden = true
                        cell.imageAvatar.isHidden = false
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.initials.text = item.getInitials()
                        cell.initials.isHidden = false
                        cell.imageAvatar.isHidden = true
                    }
                }
            }

            // Item is custom type
        } else {
            if item.image == nil && item.imageURL == nil {
                cell.initials.text = item.getInitials()
                cell.initials.isHidden = false
                cell.imageAvatar.isHidden = true
            } else {
                if item.imageURL != "" {
                    cell.initials.isHidden = true
                    cell.imageAvatar.isHidden = false
                    cell.imageAvatar.setImageFromURL(stringImageUrl: item.imageURL!)
                } else {
                    cell.imageAvatar.image = item.image
                    cell.initials.isHidden = true
                    cell.imageAvatar.isHidden = false
                }
            }
        }

        // Set item color
        if item.color != nil {
            cell.initials.backgroundColor = item.color!
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: CGFloat(Config.selectorStyle.selectionHeight), height: CGFloat(Config.selectorStyle.selectionHeight))
    }

    @objc func handleTap(sender: UIButton) {
        guard let id = sender.accessibilityIdentifier else {
            return
        }
        // remove item
        reloadAndPositionScroll(itemId: id, remove: true)

        if selectedItems.count <= 0 {
            // Comunicate deselection to delegate
            toggleSelectionScrollView(show: false)
        }
    }

    /// Remove item from collectionview and reset tag for button
    ///
    /// - Parameter index: id to remove
    func removeItemAndReload(index: Int) {
        // if no selection reload all
        if selectedItems.count == 0 {
            selectionScrollView.reloadData()
        } else {
            // reload current
            selectionScrollView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    /// Reaload collectionview data and scroll to last position
    ///
    /// - Parameters:
    ///   - itemId: id of item you have to change
    ///   - remove: true if you have to remove item
    ///   - row: position in tableView
    func reloadAndPositionScroll(itemId: String, remove: Bool, row: Int? = nil) {
        // Identify the item inside selected array
        let item = selectedItems.first { itm -> Bool in
            itm.id == itemId
        }
        // For remove from collection view and create IndexPath, i need the index posistion in the array
        let collectionViewIndex = selectedItems.firstIndex { itm -> Bool in
            itm.id == itemId
        }

        guard let index = collectionViewIndex,
              let item = item else {
            return
        }

        // Remove
        if remove {
            // Filter array removing the item
            selectedItems = selectedItems.filter { itm -> Bool in
                itm.id != itemId
            }

            // Reload collectionview
            removeItemAndReload(index: index)
            // Reload cell state
            if row != nil {
                reloadCellState(row: row!, selected: false)
            }
            SwiftMultiSelect.delegate?.swiftMultiSelect(didUnselectItem: item)

            if selectedItems.count <= 0 {
                // Toggle scrollview
                toggleSelectionScrollView(show: false)
            }
            // Add
        } else {
            toggleSelectionScrollView(show: true)

            // Reload data
            selectionScrollView.insertItems(at: [IndexPath(item: selectedItems.count - 1, section: 0)])
            let lastItemIndex = IndexPath(item: selectedItems.count - 1, section: 0)

            // Scroll to selected item
            selectionScrollView.scrollToItem(at: lastItemIndex, at: .right, animated: true)

            if row != nil {
                reloadCellState(row: row!, selected: true)
            }
        }
    }
}
