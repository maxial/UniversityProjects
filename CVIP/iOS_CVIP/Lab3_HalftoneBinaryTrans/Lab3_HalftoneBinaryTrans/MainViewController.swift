//
//  MainViewController.swift
//  Lab2_BrightnessTransformations
//
//  Created by Maxim Aliev on 19/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit

enum TransformationType: Int {
    case Manual
    case OtsuGlobal
    case OtsuLocal
    case OtsuHierarchical
    case QuantizationByBrightness
}
fileprivate let BINARY_SEGUE = "BinarySegue"
fileprivate let transTypesNames = ["Ручной выбор порога",
                                   "Метод Оцу (глобальный)",
                                   "Метод Оцу (локальный)",
                                   "Метод Оцу (иерархический)",
                                   "Квантование по яркости"]

class MainViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == BINARY_SEGUE {
            if let indexPath = sender as? NSIndexPath {
                if let destinationController = segue.destination as? HBTViewController {
                    destinationController.navigationItem.title = transTypesNames[indexPath.section]
                    destinationController.transType = TransformationType(rawValue: indexPath.section)
                }
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return transTypesNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: tableView.rect(forSection: section))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransCell")!
        cell.textLabel?.text = transTypesNames[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: BINARY_SEGUE, sender: indexPath)
    }
}



