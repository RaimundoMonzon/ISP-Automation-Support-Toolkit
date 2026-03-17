# ISP Automation & Support Toolkit

A collection of **AutoHotkey v2** scripts and **JSON** databases designed to streamline technical support workflows, automate repetitive text entry, and manage network equipment configuration through a fast, searchable interface.

---

## 🚀 Features

* **Fuzzy Search Launcher:** A custom GUI to instantly find and deploy technical support response templates.
* **JSON-Driven Architecture:** All data—from support snippets to device credentials—is stored in external `.json` files for easy updates without touching the core logic.
* **Credential Automation:** Logic to handle multi-field logins (e.g., using `;root` + `TAB`) specifically optimized for Cambium routers and similar network hardware.
* **Field Injection:** Automatically handles UI transitions, such as switching from username to password fields, to minimize manual clicks.

## 📂 Repository Structure

* `Launcher.ahk`: The main executable script.
* `lib/`: Helper scripts and the `JSON.ahk` library.
* `data/`: Contains `prefabs.json` for response templates.
* `secrets/`: **(Local Only)** Contains `credenciales.json`. This folder is ignored by Git for security.

---

## ⚙️ Usage

### Using the Search Launcher
1. Run `Launcher.ahk`.
2. Press your designated Hotkey (e.g., `-` & `Tab`).
3. Type keywords to filter the list.
4. Use the Up and Down arrow keys to navigate the list.
5. Press **Enter** to paste the selected text into the active window.

### Automated Credential Injection
1. Open the login page for the router.
2. Type your shorthand trigger (e.g., `;root`).
3. The script will input the username, send a `{Tab}` command, and input the password automatically.

---

## 🛡️ Security Note

This repository includes a `.gitignore` file that excludes the `secrets/` folder. **Never** hardcode real passwords into the `.ahk` files or move them out of the ignored directory to ensure they are never uploaded to a public server.

---

## 🛠️ Setup & Requirements

1. **AutoHotkey v2.0+**: This project uses v2 syntax and is not compatible with v1.1.
2. **JSON Library**: The script requires `lib/JSON.ahk` (thqby version) to parse data.
3. **Data Initialization**: 
    * Ensure `data/prefabs.json` is populated with your snippets.
    * Create a local `secrets/` directory and a `credenciales.json` file for automated logins.

### Example Template Structure (`data/prefabs.json`)
```json
{
    "Change Password": "Muy bien, indíqueme la nueva contraseña, por favor.",
    "Router Reset": "Please perform a factory reset by holding the button for 10 seconds."
}
```
Example Credentials Structure (secrets/credenciales.json)
```json
{
    ";root": "admin{TAB}SuperSecretPassword123"
}
```

---

## acknowledgments

* **[thqby](https://github.com/thqby)** – For the excellent [AutoHotkey_v2_lib](https://github.com/thqby/AutoHotkey_v2_lib), specifically the `JSON.ahk` library.
* **AutoHotkey Community** – For the various fuzzy search logic and forum snippets that inspired this toolkit.
