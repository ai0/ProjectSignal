//
//  SetttingsViewController.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit

class SetttingsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var favoriteList: FavoriteList
    private let message = MessagePrompt()
    private var settingsManage: SettingsManage
    
    
    @IBOutlet weak var autoRenderModeSwitch: UISwitch!
    @IBOutlet weak var titleBarDarkStyleSeg: UISegmentedControl!
    @IBOutlet weak var titleBarFontSizeStepper: UIStepper!
    @IBOutlet weak var autoRefreshIntervalSlider: UISlider!
    @IBOutlet weak var titlePicker: UIPickerView!
    
    @IBAction func autoRenderModeIsChanged(_ sender: UISwitch) {
        if sender.isOn {
            settingsManage.settings.autoRenderMode = true
            message.prompt(theme: message.success, content: "✅ Auto render mode enabled.", duration: 1)
        } else {
            settingsManage.settings.autoRenderMode = false
            message.prompt(theme: message.info, content: "ℹ️ Auto render mode disabled.", duration: 1)
        }
        settingsManage.save()
    }
    
    @IBAction func titleBarDarkStyleIsChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            settingsManage.settings.titleBarDarkStyle = false
            message.prompt(theme: message.success, content: "✅ Light title bar enabled.", duration: 1)
        } else {
            settingsManage.settings.titleBarDarkStyle = true
            message.prompt(theme: message.success, content: "✅ Dark title bar enabled.", duration: 1)
        }
        updateTitleBarStyle()
        settingsManage.save()
    }
    
    @IBAction func titleBarFontSizeIsChanged(_ sender: UIStepper) {
        let fontSize = sender.value
        settingsManage.settings.titleBarFontSize = fontSize
        message.prompt(theme: message.success, content: "✅ Title bar font size changed to \(fontSize).", duration: 0.2)
        updateTitleBarFontSize()
        settingsManage.save()
    }
    
    @IBAction func autoRefreshIntervalIsChanged(_ sender: UISlider) {
        let autoRefreshInterval = Int(sender.value)
        settingsManage.settings.autoRefreshInterval = Double(autoRefreshInterval)
        if autoRefreshInterval > 0 {
            message.prompt(theme: message.success, content: "✅ Auto refresh interval changed to \(autoRefreshInterval).", duration: 1)
        } else {
            message.prompt(theme: message.info, content: "ℹ️ Auto refresh timer disabled.", duration: 1)
        }
        settingsManage.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titlePicker.delegate = self
        self.titlePicker.dataSource = self
        loadSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTitleBarStyle()
        super.viewDidAppear(animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        favoriteList = FavoriteList.shared
        settingsManage = SettingsManage.shared
        super.init(coder: aDecoder)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return settingsManage.settings.titleBarDarkStyle ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default
    }
    
    func loadSettings() {
        self.autoRenderModeSwitch.setOn(settingsManage.settings.autoRenderMode, animated: false)
        self.titleBarDarkStyleSeg.selectedSegmentIndex = settingsManage.settings.titleBarDarkStyle ? 1: 0
        self.titleBarFontSizeStepper.value = settingsManage.settings.titleBarFontSize
        self.autoRefreshIntervalSlider.value = Float(settingsManage.settings.autoRefreshInterval)
        self.titlePicker.selectRow(settingsManage.settings.titleIndex, inComponent: 0, animated: false)
    }
    
    func updateTitleBarStyle() {
        if settingsManage.settings.titleBarDarkStyle {
            navigationController?.navigationBar.barStyle = .black
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            statusBar.backgroundColor = .black
        } else {
            navigationController?.navigationBar.barStyle = .default
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            statusBar.backgroundColor = .white
        }
    }
    
    func updateTitleBarFontSize() {
        let attrs = [
            NSAttributedString.Key.font: UIFont(name: "Futura-Medium", size: CGFloat.init(settingsManage.settings.titleBarFontSize))
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = attrs as [NSAttributedString.Key : Any]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settingsManage.settings.titleChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return settingsManage.settings.titleChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        settingsManage.settings.titleIndex = row
        settingsManage.save()
        message.prompt(theme: message.success, content: "✅ Homepage title updated.", duration: 1)
    }
    
    @IBAction func resetDefaults(_ sender: Any) {
        settingsManage.reset()
        loadSettings()
        message.prompt(theme: message.success, content: "✅ All settings reset to default value.", duration: 1)
    }
    
    @IBAction func clearFavorites(_ sender: Any) {
        favoriteList.clear()
        message.prompt(theme: message.success, content: "✅ All favorites removed.", duration: 1)
    }
    
}
