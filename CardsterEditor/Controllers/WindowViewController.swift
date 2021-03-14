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
            let alert = NSAlert()
            alert.messageText = "Card Error"
            alert.informativeText = "Please select a card to delete"
            alert.runModal()
        }
        else if ((cardCount - 1) < index) {
            print("An error occured deleting the card at \(index)")
        }
        else {
            // Card is valid for deletion
            deckBuilder.removeCard(at: index)
            cardsTable.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
        }
    }
    
    @IBAction func generateJSONButtonPressed(_ sender: Any) {
        // Selected references:
        // https://stackoverflow.com/questions/52436057/how-to-display-nssavepanel-in-macos
        // https://developer.apple.com/documentation/appkit/nssavepanel
        // https://stackoverflow.com/questions/29354752/how-to-get-a-path-out-of-an-nssavepanel-object-in-swift
        // https://medium.com/@CoreyWDavis/reading-writing-and-deleting-files-in-swift-197e886416b0
        // Prompt the user for the file path
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["json"]
        savePanel.title = "Save Deck"
        savePanel.nameFieldStringValue = "New_Set"
        savePanel.begin { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                // User did not press cancel.  Get the URL and save the cards
                if let url = savePanel.url {
                    if let data = self.deckBuilder.goToJSON() {
                        do {
                            try data.write(to: url)
                            print("Successfully saved to \(url.absoluteURL)")
                        }
                        catch {
                            print("Error writing file")
                            let alert = NSAlert()
                            alert.messageText = "Error"
                            alert.informativeText = "An error occured saving to \(url.absoluteURL)."
                            alert.runModal()
                        }
                    }
                }
            }
            else {
                // User hit cancel on the save dialogue
                print("User cancelled save")
            }
        }
    }
    @IBAction func enterPressedOnBackCard(_ sender: NSTextField) {
        addCard()
    }
    
    func addCard() {
        // First, make sure that there is text in both fields.
        let front = frontCardText.stringValue
        let back = backCardText.stringValue
        if (front != "" && back != "") {
            // Add the card to the deck manager and the table view
            deckBuilder.append(f: front, b: back)
            cardsTable.insertRows(at: IndexSet(integer: (deckBuilder.getCardCount() - 1)), withAnimation: .slideDown)
            // Clear the text fields
            frontCardText.stringValue = ""
            backCardText.stringValue = ""
            // Deselect the back, and move to the front
            frontCardText.becomeFirstResponder()
        }
        else {
            // Alert the user to enter text
            let alert = NSAlert()
            alert.messageText = "Card Error"
            alert.informativeText = "Please ensure that both the front and back card text are entered before hitting the create button."
            alert.runModal()
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
        return vw
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return deckBuilder.getCardCount()
    }
}
