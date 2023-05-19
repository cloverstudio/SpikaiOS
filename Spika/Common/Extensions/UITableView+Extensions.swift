//
//  UITableView+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 03.04.2022..
//

import UIKit

extension UITableView {
    
    func scrollToBottom(_ type: ScrollToBottomType){
        guard let lastCellIndexPath else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch type {
            case .ifLastCellVisible:
                if self.isLastCellVisible() {
                    self.scrollToRow(at: lastCellIndexPath, at: .top, animated: false)
                }
            case .force:
                self.scrollToRow(at: lastCellIndexPath, at: .top, animated: false)
            }
        }
    }
    
    func isLastCellVisible() -> Bool {
        return distanceFromBottom() < 50
    }
    
    var lastCellIndexPath: IndexPath? {
        let lastSectionIndex = self.numberOfSections - 1
        if lastSectionIndex < 0 { return nil}
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        if lastRowIndex < 0 { return nil}
        let lastCellIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        return lastCellIndexPath
    }
    
    func reloadPreviousRow(for indexPath: IndexPath) {
        let currentRow = indexPath.row
        guard currentRow > 0 else { return }
        let previousCellIndexPath = IndexPath(row: currentRow - 1, section: indexPath.section)
        DispatchQueue.main.async { [weak self] in
            UIView.performWithoutAnimation { [weak self] in
                self?.reloadRows(at: [previousCellIndexPath], with: .none)
            }            
        }
    }
    
    func blinkRow(at indexPath: IndexPath) {
        selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.deselectRow(at: indexPath, animated: true)
        }
    }
}
