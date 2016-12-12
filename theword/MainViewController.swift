//
//  MainViewController.swift
//  theword
//
//  Created by Wilbert Liu on 12/10/16.
//  Copyright © 2016 Ident. All rights reserved.
//

import UIKit
import SwiftyJSON
import SnapKit

private typealias CollectionViewDataSource = MainViewController
private typealias CollectionViewDelegateFlowLayout = MainViewController
private typealias TableViewDataSource = MainViewController
private typealias ScrollViewDelegate = MainViewController

private let chapterCell = "chapterCell"
private let passageCell = "passageCell"
private let verseCell = "verseCell"

class MainViewController: UIViewController {

// TODO: Scroll position saving
//    var scrollPoints = [CGPoint]()
    var json: JSON?
    var booksData = [[String: Any]]()

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = Bundle.main.path(forResource: "TB", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                json = JSON(data: data)

                if json != JSON.null {
                    for book in json!["books"].arrayValue {
                        let bookData = book["chapters"].arrayValue.map { (value) -> [String: Any] in
                            var chapter = [String: Any]()
                            chapter["book_name"] = book["name"].stringValue
                            chapter["number"] = value["number"].intValue
                            chapter["total_verse"] = value["total_verse"].intValue
                            chapter["verses"] = value["verses"]

                            return chapter
                        }

                        booksData += bookData
                    }

                    let book = booksData[0]["book_name"] as! String
                    let chapter = booksData[0]["number"] as! Int
                    navigationItem.title = "\(book) \(chapter)"
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension CollectionViewDataSource: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return booksData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chapterCell, for: indexPath)
        cell.contentView.tag = indexPath.item

        if let tableView = cell.viewWithTag(-1) as? UITableView {
            tableView.estimatedRowHeight = 56
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.tableHeaderView = nil

            let verses = booksData[indexPath.item]["verses"] as! JSON

            if verses[0]["type"].stringValue == "verse" {
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 20))
            }

            tableView.reloadData()
        }

        return cell
    }

}

extension CollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }

}

extension TableViewDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (booksData[tableView.superview!.tag]["verses"] as! JSON).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let verses = booksData[tableView.superview!.tag]["verses"] as! JSON
        let verse = verses[indexPath.row].dictionaryValue
        let identifier = verse["type"]?.stringValue == "passage" ? passageCell : verseCell
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        if identifier == passageCell {
            let passageLabel = cell.viewWithTag(1) as! UILabel
            passageLabel.text = verse["content"]?.stringValue
        } else {
            let numberLabel = cell.viewWithTag(1) as! UILabel
            numberLabel.text = verse["number"]?.stringValue

            let verseLabel = cell.viewWithTag(2) as! UILabel
            verseLabel.text = verse["content"]?.stringValue
            verseLabel.snp.makeConstraints { (maker) in
                maker.trailing.equalToSuperview().offset(-cell.contentView.frame.width * 0.09)
            }
        }

        return cell
    }

}


extension ScrollViewDelegate: UIScrollViewDelegate {
// TODO: Scroll position saving
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let tableView = cell.viewWithTag(-1) as? UITableView {
//            tableView.setContentOffset(scrollPoints[indexPath.item], animated: false)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let tableView = cell.viewWithTag(-1) as? UITableView {
//            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//        }
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if !scrollView.isEqual(collectionView) {
//            let tableView = scrollView as! UITableView
//            scrollPoints[tableView.superview!.tag] = scrollView.contentOffset
//        }
//    }
//
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isEqual(collectionView) {
            if let indexPath = collectionView.indexPathForItem(at: scrollView.contentOffset) {
                let book = booksData[indexPath.item]["book_name"] as! String
                let chapter = booksData[indexPath.item]["number"] as! Int
                navigationItem.title = "\(book) \(chapter)"
            }
        }
    }

}
