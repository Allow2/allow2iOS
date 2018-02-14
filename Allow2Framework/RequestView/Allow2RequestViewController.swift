//
//  Allow2BlockView.swift
//  Allow2Framework
//
//  Created by Andrew Longhorn on 7/1/17.
//  Copyright © 2017 Allow2 Pty Ltd. All rights reserved.
//

import UIKit

public protocol Allow2RequestViewControllerDelegate {
    
}

public class Allow2RequestViewController: UITableViewController {
    
    var delegate : Allow2RequestViewControllerDelegate?
    var newDayType : Int64? = nil;
    private var currentBans = [[String: Any]]()
    private var dayType : Allow2Day?
    var checkResult : Allow2CheckResult? {
        didSet {
            newDayType = nil
            currentBans = checkResult?.currentBans ?? [[String: Any]]()
        }
    }
    var message : String? = nil
    var pickerShown = false
    
    @IBAction func Cancel() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func Send() {
        // warning: remember what had focus and restore it to that element on failure
        self.resignFirstResponder()
        Allow2.shared.request(dayTypeId: nil, lift: [2], message: "Testing!") { response in
            print("\(response)")
            switch (response) {
            case let .Request(requestSent):
                if !requestSent {
                    return
                }
                self.presentingViewController?.dismiss(animated: true)
            case let .Error(err):
                // warning: show a suitable error somehow
                print("\(err)")
                return
            default:
                return
            }
        }
    }
    
}


// MARK:- DataSource

extension Allow2RequestViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + ( currentBans.count > 0 ? 1 : 0 )
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        if section >= self.numberOfSections(in: tableView) - 1 {
            return 1
        }
        return currentBans.count
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Change Day Type:"
        }
        if section >= self.numberOfSections(in: tableView) - 1 {
            return "Message:"
        }
        
        return "Lift Ban:"
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0) && (indexPath.row == 1) && !pickerShown {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections(in: tableView) - 1
    }
    
    func formatBanCell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let ban = self.currentBans[indexPath.row]
        cell.textLabel?.text = ban["title"] as? String
        cell.detailTextLabel?.text = "\(Double(ban["duration"] as! Int) / 60.0)"
        cell.accessoryType = ban["selected"] as? Bool ?? false ? .checkmark : .none
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DayTypeCell")!
                cell.textLabel?.text = self.dayType?.name
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "DayTypePickerCell")!
            return cell
        }
        if indexPath.section >= self.numberOfSections(in: tableView) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
            cell.messageField?.text = self.message
            cell.messageField?.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BanCell")!
        formatBanCell(cell, forRowAt: indexPath)
        return cell
    }
}


// MARK:- Delegate

extension Allow2RequestViewController {
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                pickerShown = !pickerShown
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            return
        }
        if indexPath.section < self.numberOfSections(in: tableView) - 1 {
            tableView.deselectRow(at: indexPath, animated: false)
            self.currentBans[indexPath.row]["selected"] = !(self.currentBans[indexPath.row]["selected"] as? Bool ?? false)
            formatBanCell(self.tableView(tableView, cellForRowAt: indexPath), forRowAt: indexPath)
            return
        }
        
        let cell = self.tableView(tableView, cellForRowAt: indexPath) as! MessageCell
        cell.messageField?.becomeFirstResponder()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension Allow2RequestViewController : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.Send()
        return true
    }
}
