#  Cardster Editor
## A simple macOS app to generate flashcard decks

This app is meant to be a companion to my other project, [Cardster](https://github.com/jakeconv/Cardster).  Cardster reads in flashcards from a JSON-formatted file, and this app is meant to provide a simpler means for creating card files outside of a text editor.  Hope you enjoy! 😃

## Running the app

This app was designed for macOS 11 using Swift 5 in Xcode 12.4.  To get started, clone this repository into a directory of your choosing.  Locate the CardsterEditor.xcodeproj file, open it, and then press the play button to run on your Mac.

## Using the app

When launched, Cardster Editor will display an empty table.  To get started, key in the front of the card and the back of the card.  Press the create button, or hit the return key when done editing in the back text field, to add the card to the deck.  It will now appear in the table.  To remove a card, select it in the table and press the delete button.  When you're done editing cards, select the Save Deck as JSON button and specify a path for the output file.

## Using the cards

Add the output JSON file, making sure its name ends in "_Set.json", to the Cards group in your Cardster project.  When you run Cardster next, your new cards will be available for studying.
