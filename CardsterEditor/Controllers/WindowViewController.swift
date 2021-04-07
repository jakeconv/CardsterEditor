//
//  ViewController.swift
//  CardsterEditor
//
//  Created by Jake Convery on 3/10/21.
//

import Cocoa

class WindowViewController: NSViewController {

    @IBOutlet weak var cardsTable: NSTableView!
    @IBOutlet weak var frontCardText: NSTextField!
    @IBOutlet weak var backCardText: NSTextField!
    
    var deckBuilder = DeckBuilder()
    var deckURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the table view
        cardsTable.dataSource = self
        cardsTable.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func createButtonPressed(_ sender: Any) {
        addCard()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let index = cardsTable.selectedRow
        let cardCount = deckBuilder.getCardCount()
        if (index == -1) {
            // Alert the user to select a card to delete
            NSAlert.generateAlert(message: "Card Error", descrtiption: "Please select a card to delete")
        }
        else if ((cardCount - 1) < index) {
            print("An error occured deleting the card at \(index)")
        }
        else {
            // Card is valid for deletion
            deckBuilder.removeCard(at: index)
            //cardsTable.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
            cardsTable.reloadData()
        }
    }
    
    @IBAction func enterPressedOnBackCard(_ sender: NSTextField) {
        addCard()
    }
    
    // TODO: Add ability to edit pre-existing cards
    func addCard() {
        // First, make sure that there is text in both fields.
        let front = frontCardText.stringValue
        let back = backCardText.stringValue
        if (front != "" && back != "") {
            // Add the card to the deck manager and the table view
            deckBuilder.append(f: front, b: back)
            cardsTable.insertRows(at: IndexSet(integer: (deckBuilder.getCardCount() - 1)), withAnimation: .slideDown)
            // Scroll down if the table view is filled
            cardsTable.scrollRowToVisible(deckBuilder.getCardCount() - 1)
            // Deselect the row, if any is selected.
            let selectedRow = cardsTable.selectedRow
            cardsTable.deselectRow(selectedRow)
            // Clear the text fields
            frontCardText.stringValue = ""
            backCardText.stringValue = ""
            // Deselect the back, and move to the front
            frontCardText.becomeFirstResponder()
        }
        else {
            // Alert the user to enter text
            NSAlert.generateAlert(message: "Card Error", descrtiption: "Please ensure that both the front and back card text are entered before hitting the create button.")
        }
    }
    
    @IBAction func openDocument(_ sender: Any) {
        // Open up a pre-existing card file
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["card"]
        openPanel.runModal()
        // Verify that the user specified a file.  If they did, then try to open it.
        if openPanel.urls.count > 0 {
            let targetURL = openPanel.urls[0]
            deckURL = targetURL
            deckBuilder.openExistingFile(at: targetURL)
            cardsTable.reloadData()
        }
        else {
            print("User cancelled file open")
        }
    }
    
    @IBAction func saveDocument(_ sender: Any) {
        if deckURL != nil {
            // Deck URL is established.  Save the file.
            executeSave(to: deckURL!)
        }
        else {
            // Get the URL and then save.  If the user does not specify a file, then give up.
            if (getFileURL()) {
                executeSave(to: deckURL!)
            }
        }
    }
    
    @IBAction func saveDocumentAs(_ sender: Any) {
        // Get the URL and then save.  If the user does not specify a file, then give up.
        if (getFileURL()) {
            executeSave(to: deckURL!)
        }
    }
    
    @IBAction func newDocument(_ sender: Any) {
        // Reset the editor
        deckURL = nil
        deckBuilder = DeckBuilder()
        cardsTable.reloadData()
    }
    
    // MARK: - Items to support saving
    func checkForCardCount() -> Bool {
        // Make sure that there is at least one card
        if (deckBuilder.getCardCount() == 0) {
            // There are no cards.  Loading this deck will crash Cardster.
            NSAlert.generateAlert(message: "Error", descrtiption: "Please add some cards before saving")
            return false
        }
        else {
            // Cards exist.  We're good to save
            return true
        }
    }
    
    func executeSave(to url: URL) {
        // Selected references (for all of the document saving):
        // https://stackoverflow.com/questions/52436057/how-to-display-nssavepanel-in-macos
        // https://developer.apple.com/documentation/appkit/nssavepanel
        // https://stackoverflow.com/questions/29354752/how-to-get-a-path-out-of-an-nssavepanel-object-in-swift
        // https://medium.com/@CoreyWDavis/reading-writing-and-deleting-files-in-swift-197e886416b0
        if (checkForCardCount()) {
            if let data = deckBuilder.goToJSON() {
                let fileWriter = FileWriter()
                fileWriter.save(data, to: url)
            }
            else {
                print("An error occured saving the file")
            }
        }
    }
    
    func getFileURL() -> Bool {
        // Attempt to get a URL to save the new file to
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["card"]
        savePanel.title = "Save Deck"
        savePanel.nameFieldStringValue = "New Deck"
        savePanel.runModal()
        if let targetURL = savePanel.url {
            deckURL = targetURL
            return true
        }
        else {
            print("User cancelled save")
            return false
        }
    }
    
}

// MARK: - NSTableViewDelegate, NSTableViewDataSource
extension WindowViewController: NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else {
            print("An error done occurred making the table view cell")
            return nil
        }
        if tableColumn?.title == "Front" {
            // We're looking for the front of the card.  Add in the front.
            vw.textField?.stringValue = deckBuilder.getFront(for: row)
        }
        else if tableColumn?.title == "Back" {
            // We're looking for the back of the card.  Add in the back.
            vw.textField?.stringValue = deckBuilder.getBack(for: row)
        }
        else if tableColumn?.title == "Count" {
            // We're looking for the row number
            vw.textField?.stringValue = String(row + 1)
        }
        return vw
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return deckBuilder.getCardCount()
    }
}

// MARK: Custom NSAlert
extension NSAlert {
    static func generateAlert(message: String, descrtiption: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = descrtiption
        alert.runModal()
    }
}
