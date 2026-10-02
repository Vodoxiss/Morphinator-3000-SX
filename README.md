# Morphinator 3000-SX 🤖✨

**Morphinator 3000-SX** is a specialized character morphing UI addon built for **World of Warcraft: Wrath of the Lich King (Patch 3.3.5a)**. Designed for players with **GameMaster** permissions or access to morph commands on private servers, this lightweight addon provides a simple graphical interface to search, browse, and instantly apply thousands of creature display IDs to your character or target.

## 🔥 Key Features

* **Database of ~17,000 DisplayIDs (`Data.lua`)**:
  * Search through a large database mapping NPC names to DisplayIDs.
  * Fast indexing and filtering without UI lag.

* **Smart Search & Selection**:
  * Search by NPC name or direct `DisplayID`.
  * Select entries directly from the list to prepare morph commands.

* **GM Command Execution**:
  * One-click morphing and demorphing for characters with GM privileges or server environments supporting `.morph` / `.demorph` commands.

## 🛠️ Tech & Requirements

* **Game Version**: World of Warcraft: Wrath of the Lich King (3.3.5a)
* **Server Compatibility**: Any 3.3.5a private server (Requires GameMaster / `.morph` privileges)
* **Languages & Assets**: Pure Lua (No XML templates required) + `.tga` texture file

## 📂 File Structure

```
Morphinator3000-SX/
│
├── Morphinator3000-SX.toc  # Addon metadata & file load sequence
├── Core.lua                 # Core logic and command handlers
├── Data.lua                 # Database containing ~17,000 DisplayIDs and names
├── UI.lua                   # User interface frame construction and events
└── sheep.tga                # Custom texture asset
```

## ⚙️ Installation

1. **Download the Addon**:
   * Download or clone this repository as a `.zip` archive.

2. **Locate your WoW AddOns Folder**:
   * Navigate to your 3.3.5a client directory:
     ```text
     World of Warcraft 3.3.5a/Interface/AddOns/
     ```

3. **Extract Files**:
   * Place the folder into `AddOns/`.
   * Ensure the folder structure matches:
     ```text
     World of Warcraft 3.3.5a/Interface/AddOns/Morphinator3000-SX/
     ```

4. **Enable in Game**:
   * Launch WoW, click **AddOns** at the character select screen, ensure **Load out of date AddOns** is checked, and make sure `Morphinator3000-SX` is enabled.

## 📖 Usage

1. **Open the Interface**:
   * Enter the chat command:
     ```text
     /morph
     ```

2. **Search for a Model**:
   * Type any NPC name or `DisplayID` into the search box.

3. **Apply Morph**:
   * Click to apply the morph command directly to your character or selected target.

## 📄 License

Distributed under the **MIT License**.
