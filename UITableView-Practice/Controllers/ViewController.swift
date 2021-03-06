//
//  ViewController.swift
//  UITableView-Practice
//
//  Created by 大西玲音 on 2021/08/08.
//

import UIKit
import RealmSwift

final class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var editButton: UIBarButtonItem!
    
    private let realm = try! Realm()
    private var persons: List<Person>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persons = realm.objects(PersonList.self).first?.list
        setupTableView()
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.nib,
                           forCellReuseIdentifier: CustomCell.identifier)
        tableView.tableFooterView = UIView()
    }
    
    @IBAction private func addButtonDidTapped(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "アイテムを追加", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "追加", style: .default) { _ in
            let person = Person()
            person.name = textField.text!
            // MARK: - add
            try! self.realm.write {
                if self.persons == nil {
                    let personList = PersonList()
                    personList.list.append(person)
                    self.realm.add(personList)
                    self.persons = self.realm.objects(PersonList.self).first?.list
                } else {
                    self.persons.append(person)
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func editButtonDidTapped(_ sender: Any) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editButton.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            editButton.title = "Done"
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
        tableView.isEditing = editing
        
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return realm.objects(Person.self).count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier) as! CustomCell
        let name = persons[indexPath.row].name
        cell.configure(name: name)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // MARK: - delete
            if let person = realm.objects(Person.self).first(where: { $0.uuid == self.persons[indexPath.row].uuid }) {
                try! realm.write {
                    realm.delete(person)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        // MARK: - sort
        try! realm.write {
            let person = persons[sourceIndexPath.row]
            persons.remove(at: sourceIndexPath.row)
            persons.insert(person, at: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
