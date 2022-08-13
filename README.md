# Essentials
(for iOS and iPadOS)

- UIKit
- CoreData
- TableView
- A simple app where user can make a list of anything
- Lists can be delete, edited and rearranged
- Swipe to delete enabled UITableView cells

### User flow diagram of the app

```mermaid
flowchart TD
    A[List of Lists] --> B{Show List X}
    B --> H[Items of List X]
    A --> C{Delete/Edit Lists}
    A --> D{New List}
    D --> E[New List Screen]
    E --> F{Cancel}
    E --> G{Done}
    F --> A
    G --> A
```
