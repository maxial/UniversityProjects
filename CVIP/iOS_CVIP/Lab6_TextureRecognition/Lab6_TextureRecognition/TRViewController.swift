//
//  TRViewController.swift
//  Lab6_TextureRecognition
//
//  Created by Maxim Aliev on 19/05/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit

fileprivate let cellIDs = [LBPTableViewCell.className, L1TableViewCell.className]
fileprivate let imageNamesForLBP = ["texture1", "texture2", "texture3", "texture4", "texture5", "texture6"]

class TRViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let lbpCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LBPTableViewCell
        let l1cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! L1TableViewCell
        lbpCell.delegate = l1cell
    }
}

extension TRViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIDs[indexPath.section])!
        
        if let cell = cell as? LBPTableViewCell {
            cell.imageNames = imageNamesForLBP
        }
        
        return cell
    }
}

extension TRViewController: UITableViewDelegate {
    
}



