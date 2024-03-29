//
//  Extensions.swift
//  Odd_Jobs_Realm
//
//  Created by Alan Doonan on 28/07/2019.
//  Copyright © 2019 Alan Doonan. All rights reserved.
//

import UIKit
import RealmSwift

extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let backgroundColor = UIColor.rgb(r: 21, g: 22, b: 33)
    static let outlineStrokeColor = UIColor.rgb(r: 234, g: 46, b: 111)
    static let trackStrokeColor = UIColor.rgb(r: 56, g: 25, b: 49)
    static let pulsatingFillColor = UIColor.rgb(r: 86, g: 30, b: 63)
}

// Shake Function for indicating wrong field
extension UITextField {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 4.0, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 4.0, y: self.center.y)
        layer.add(animation, forKey: "position")
    }
}

extension UIViewController {
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    func addNavBar(_ leftButtons: [UIBarButtonItem], _ rightButtons: [UIBarButtonItem], scoreCategory: [String]) {
        navigationItem.leftBarButtonItems = leftButtons
        navigationItem.rightBarButtonItems = rightButtons
        navigationItem.title = scoreCategory.joined(separator:" ")
    }
    
    func applyTheme(_ tableView: UITableView, _ view: UIView) {
        view.backgroundColor = Themes.current.background
        tableView.backgroundColor = Themes.current.background
        navigationController?.navigationBar.backgroundColor = Themes.current.background
        let textAttributes = [NSAttributedString.Key.foregroundColor:Themes.current.accent]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func applyThemeView(_ view: UIView) {
        view.backgroundColor = Themes.current.background
        navigationController?.navigationBar.backgroundColor = Themes.current.background
        let textAttributes = [NSAttributedString.Key.foregroundColor:Themes.current.accent]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func logOutUsers() {
        print("Logging out users.")
        for u in SyncUser.all {
            print("Logging out user: " + String(u.value.identity!))
            u.value.logOut()
        }
    }
    
    @objc func logOutButtonPress() {
        let alertController = UIAlertController(title: "Logout", message: "", preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "Yes, Logout", style: .destructive, handler: {
            alert -> Void in
            SyncUser.current?.logOut()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: false, completion: nil)
    }
    
    func addSearchBar(scoreCategory: [String], searchBar: UISearchBar) {
        navigationItem.titleView = searchBar
        searchBar.showsScopeBar = false
        searchBar.placeholder = "Search " + scoreCategory.joined(separator:" ")
    }
    func updateScore(realm: Realm) {
        print("Updating Scores")
        for update in Constants.listTypes {
            let scores = realm.objects(ScoreItem.self).filter("Category contains[c] %@", update)
            if let score = scores.first {
                if score.Score == score.LevelCap {
                    try! realm.write {
                        score.Score = 0
                        score.Level += 1
                        score.TotalScore += 1
                    }
                }
                else {
                    try! realm.write {
                        score.Score += 1
                        score.TotalScore += 1
                    }
                }
            }
        }
    }
    func addTaskAlert(realm: Realm, scoreCategory: [String]) {
        let alertController = UIAlertController(title: "Add Item", message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            let oddJobName = alertController.textFields![0] as UITextField
            let oddJobPriority = alertController.textFields![1] as UITextField
            let oddJobOccurrence = alertController.textFields![2] as UITextField
            let item = OddJobItem()
            item.Name = oddJobName.text ?? ""
            item.Priority = oddJobPriority.text ?? ""
            item.Occurrence = oddJobOccurrence.text ?? ""
            item.Category = scoreCategory[0]
            try! realm.write {
                realm.add(item)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        for field in Constants.sortFields {
            alertController.addTextField(configurationHandler: {(oddJobName : UITextField!) -> Void in
                oddJobName.placeholder = field
            })
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func cellSetup(_ cell: UITableViewCell, _ item: OddJobItem, _ cellFields: [String]) {
        cell.selectionStyle = .none
        cell.tintColor = .white
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.textLabel!.font = UIFont(name: Themes.mainFontName,size: 18)
        cell.selectionStyle = .none
        cell.tintColor = .white
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.textLabel!.font = UIFont(name: Themes.mainFontName,size: 18)
        if item.Category == "Personal" {
            cell.backgroundColor = UIColor.orangeTheme
        }
        if item.Category == "Life" {
            cell.backgroundColor = UIColor.greenTheme
        }
        if item.Category == "Group" {
            cell.backgroundColor = UIColor.blueTheme
        }
        cell.textLabel?.text = item.Name
        cell.detailTextLabel?.text = (cellFields[1] + ": " + item.Occurrence)
        cell.accessoryType = item.IsDone ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        cell.textLabel!.font = UIFont(name: Themes.mainFontName,size: 18)
    }
    @objc func mapTasks() {
        print("Search Button Pressed")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "MapTasksViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    func applyTaskTheme(tableView: UITableView, selectTaskButton: UIButton, selectCategoryButton: UIButton, selectWhenButton: UIButton, userLabel: UILabel) {
        tableView.isHidden = true
        tableView.backgroundColor = .clear
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        selectTaskButton.backgroundColor = Themes.current.accent
        selectCategoryButton.backgroundColor = Themes.current.accent
        selectWhenButton.backgroundColor = Themes.current.accent
        selectTaskButton.titleLabel?.textColor = Themes.current.background
        selectTaskButton.setTitleColor(Themes.current.background, for: .normal)
        selectCategoryButton.setTitleColor(Themes.current.background, for: .normal)
        selectWhenButton.setTitleColor(Themes.current.background, for: .normal)
        userLabel.text = UserDefaults.standard.string(forKey: "Name") ?? ""
        userLabel.textColor = Themes.current.accent
    }
}

extension UITableView {
    func addTableView(_ tableView: UITableView, _ view: UIView) {
        tableView.backgroundColor = Themes.current.background
        tableView.frame = view.frame
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        view.addSubview(tableView)
    }
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}

extension UISearchBarDelegate {
    func setUpSearchBar(searchBar: UISearchBar) {
        searchBar.delegate = self
    }
}

// This with work may be applicable to all classes
extension PersonalViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("typing in search bar: term = \(searchText)")
        if searchText != "" {
            let predicate = NSPredicate(format:"(Name CONTAINS[c] %@ OR Occurrence CONTAINS[c] %@) AND Category in %@", searchText, searchText, scoreCategory)
            self.items = realm.objects(OddJobItem.self).filter(predicate)
            tableView.reloadData()
        } else {
            self.items = realm.objects(OddJobItem.self).filter("Category in %@", scoreCategory)
            tableView.reloadData()
        }
        tableView.reloadData()
    }
}
