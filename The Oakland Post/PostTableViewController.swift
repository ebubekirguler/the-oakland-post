//
//  PostTableViewController.swift
//  The Oakland Post
//
//  Created by Andrew Clissold on 6/13/14.
//  Copyright (c) 2014 Andrew Clissold. All rights reserved.
//

import UIKit

class PostTableViewController: BugFixTableViewController, MWFeedParserDelegate, StarButtonDelegate {

    override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var baseURL: String!
    var feedParser: FeedParser!
    var parsedItems = [MWFeedItem]()
    var finishedParsing = false
    var dateFormatter: NSDateFormatter!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl

        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle

        feedParser = FeedParser(baseURL: baseURL, length: 15, delegate: self)
        feedParser.parseInitial()

        tableView.addInfiniteScrollingWithActionHandler(loadMorePosts)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !finishedParsing {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            SVProgressHUD.show()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
    }

    func refresh() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        tableView.userInteractionEnabled = false
        parsedItems.removeAll()
        feedParser.parseInitial()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func loadMorePosts() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        tableView.userInteractionEnabled = false
        feedParser.parseMore()
    }

    func didSelectStarButton(starButton: UIButton, withItem item: MWFeedItem, atIndexPath indexPath: NSIndexPath) {
        p("selected \(item.title)")
        starButton.selected = !starButton.selected
    }

    // MARK: MWFeedParserDelegate methods

    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        parsedItems.append(item)
    }

    func feedParserDidFinish(parser: MWFeedParser!) {
        finishedParsing = true
        tableView.reloadData()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
        refreshControl!.endRefreshing()
        tableView.infiniteScrollingView.stopAnimating()
        tableView.userInteractionEnabled = true
    }

    // MARK: Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == readPostID {
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let item = parsedItems[indexPath.row] as MWFeedItem
            (segue.destinationViewController as PostViewController).URL = item.link
        }
    }

    // MARK: Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parsedItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as PostCell

        cell.delegate = self
        cell.indexPath = indexPath
        if indexPath.row <= countElements(parsedItems) {
            cell.item = parsedItems[indexPath.row] as MWFeedItem
        }

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewRowHeight;
    }

}
