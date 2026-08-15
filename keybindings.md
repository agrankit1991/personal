# Keybindings

> ## Context
>
> **What this is** — One keybinding scheme, applied to all three editors in use:
> Zed, VS Code and IntelliJ IDEA. The *keys* are identical everywhere; only the
> command each editor needs behind them differs.
>
> **Why it exists** — Switching editors should not mean switching hands. The
> scheme is built around a modifier grammar so a forgotten binding can be
> *derived* rather than looked up; this sheet is for when that fails, and for
> the few keys that must simply be memorised.
>
> **Status** — Zed is implemented and in daily use. **VS Code and IntelliJ are
> specified here but not yet configured** — the action IDs below are verified to
> exist, but no keymap has been written for either. Doing so means overriding
> defaults that clash; those clashes are listed per editor.
>
> **How the IDs were checked** — every Zed action against
> `/usr/lib/zed/zed-editor`, every VS Code command against
> `/usr/share/code/resources/app/out`, every IntelliJ action against the jars in
> `/opt/intellij-idea-ultimate-edition`. None are from memory. Note that an ID
> existing does **not** prove a binding works — see *Gotchas*.
>
> **Where the real files are** — Zed bindings in
> `shared/config/zed/keymap.jsonc` (symlinked to `~/.config/zed/keymap.json`),
> dock positions in `shared/config/zed/settings.jsonc`. This file documents
> them; it does not drive anything. Change a binding and update this by hand.
>
> **The reasoning is elsewhere** — a separate `keymap-plan.md`, kept outside
> this repo, holds the design rationale, the rejected alternatives and the
> decisions log. Consult it before changing a binding; read this to remember a
> key.
>
> **Last updated** — 2026-08-15. US keyboard layout, Linux.

## Derive it before looking it up

Each modifier has exactly one meaning:

| Modifier | Meaning | Ask yourself |
|---|---|---|
| `Alt` | navigate | take me somewhere |
| `Ctrl+Alt` | transform | change the code |
| `Alt+digit` | panels | show me a tool window |
| add `Shift` | same action, widened or reversed | bigger, or backwards |

Related actions share a base key and let `Shift` pick the variant, so only one
of each pair has to be remembered:

```
Alt+J  go to definition   ->  Alt+Shift+J  go to implementation
Alt+M  symbols in file    ->  Alt+Shift+M  symbols in project
Alt+O  open file          ->  Alt+Shift+O  open recent project
Alt+E  next problem       ->  Alt+Shift+E  previous problem
Alt+1  show project panel ->  Alt+Shift+1  hide it
```

Plain `Ctrl` is left alone for the universal set — copy, paste, find, save —
with **one** exception: `Ctrl+D` / `Ctrl+Shift+D` duplicate and delete a line,
kept from IntelliJ. Nothing else lives on plain `Ctrl`.

---

## Navigate

| Key | Does |
|---|---|
| `Alt+J` | Go to definition |
| `Alt+Shift+J` | Go to implementation |
| `Alt+U` | Find all usages of the symbol |
| `Alt+M` | Symbols in this file — outline, type to filter |
| `Alt+Shift+M` | Symbols across the project |
| `Alt+O` | Open file — empty query lists recent files |
| `Alt+Shift+O` | Switch to a recent project |
| `Alt+E` | Next error or warning in this file |
| `Alt+Shift+E` | Previous error or warning |
| `Alt+Shift+F` | Find text across the project |
| `Alt+←` / `Alt+→` | Back / forward through cursor history, across files |
| `Alt+Enter` | Quick fix — code actions at the cursor |

## Edit

| Key | Does |
|---|---|
| `Ctrl+D` | Duplicate line |
| `Ctrl+Shift+D` | Delete line |
| `Ctrl+Alt+↑` / `Ctrl+Alt+↓` | Move line up / down |
| `Ctrl+Alt+R` | Rename symbol everywhere |
| `Ctrl+Alt+F` | Format file |
| `Ctrl+Alt+I` | Organize imports |
| `Ctrl+Alt+N` | Add cursor at next match of this word |
| `Alt+Shift+↑` / `Alt+Shift+↓` | Add cursor on the line above / below |
| `Ctrl+Alt+=` / `Ctrl+Alt+-` | Expand / shrink selection by syntax node |

`Escape` clears extra cursors.

## Panels

| Key | Does |
|---|---|
| `Alt+1` | Project / file tree |
| `Alt+2` | Terminal |
| `Alt+3` | Git |
| `Alt+4` | AI assistant |
| `Alt+5` | Problems — every error in the project |
| `Alt+0` | Close the panel you are currently in |
| `Alt+Shift+1` | Hide / show the left dock — project |
| `Alt+Shift+2` | Hide / show the bottom dock — terminal |
| `Alt+Shift+3` | Hide / show the right dock — git and AI |

Pressing `Alt+<n>` a second time returns focus to the editor and leaves the
panel open. `Alt+0` and `Alt+Shift+<n>` are what actually dismiss it.

## Unchanged, but worth remembering

Editor defaults, not part of the scheme.

| Key | Does |
|---|---|
| `Ctrl+F` | Find in this file |
| `Ctrl+W` | Close tab |
| `Ctrl+Shift+P` | Command palette — reaches every action, bound or not |
| `Escape` | Clear multi-cursors, dismiss search |

The command palette is the fallback for anything deliberately left unbound —
go to type definition and open-definition-in-split both live there.

---

# Configuring each editor

## Action IDs

All three columns are verified to exist in the installed builds.

### Navigate

| Key | Zed | VS Code | IntelliJ |
|---|---|---|---|
| `Alt+J` | `editor::GoToDefinition` | `editor.action.revealDefinition` | `GotoDeclaration` |
| `Alt+Shift+J` | `editor::GoToImplementation` | `editor.action.goToImplementation` | `GotoImplementation` |
| `Alt+U` | `editor::FindAllReferences` | `references-view.findReferences` | `FindUsages` |
| `Alt+M` | `outline::Toggle` | `workbench.action.gotoSymbol` | `FileStructurePopup` |
| `Alt+Shift+M` | `project_symbols::Toggle` | `workbench.action.showAllSymbols` | `GotoSymbol` |
| `Alt+O` | `file_finder::Toggle` | `workbench.action.quickOpen` | `GotoFile` |
| `Alt+Shift+O` | `projects::OpenRecent` | `workbench.action.openRecent` | `ManageRecentProjects` |
| `Alt+E` | `editor::GoToDiagnostic` | `editor.action.marker.next` | `GotoNextError` |
| `Alt+Shift+E` | `editor::GoToPreviousDiagnostic` | `editor.action.marker.prev` | `GotoPreviousError` |
| `Alt+Shift+F` | `pane::DeploySearch` | `workbench.action.findInFiles` | `FindInPath` |
| `Alt+←` / `Alt+→` | `pane::GoBack` / `GoForward` | `workbench.action.navigateBack` / `navigateForward` | `Back` / `Forward` |
| `Alt+Enter` | `editor::ToggleCodeActions` | `editor.action.quickFix` | `ShowIntentionActions` |

### Edit

| Key | Zed | VS Code | IntelliJ |
|---|---|---|---|
| `Ctrl+D` | `editor::DuplicateLineDown` | `editor.action.copyLinesDownAction` | `EditorDuplicate` |
| `Ctrl+Shift+D` | `editor::DeleteLine` | `editor.action.deleteLines` | `EditorDeleteLine` |
| `Ctrl+Alt+↑` / `↓` | `editor::MoveLineUp` / `MoveLineDown` | `editor.action.moveLinesUpAction` / `moveLinesDownAction` | `MoveLineUp` / `MoveLineDown` |
| `Ctrl+Alt+R` | `editor::Rename` | `editor.action.rename` | `RenameElement` |
| `Ctrl+Alt+F` | `editor::Format` | `editor.action.formatDocument` | `ReformatCode` |
| `Ctrl+Alt+I` | `editor::OrganizeImports` | `editor.action.organizeImports` | `OptimizeImports` |
| `Ctrl+Alt+N` | `editor::SelectNext` | `editor.action.addSelectionToNextFindMatch` | `SelectNextOccurrence` |
| `Alt+Shift+↑` / `↓` | `editor::AddSelectionAbove` / `Below` | `editor.action.insertCursorAbove` / `insertCursorBelow` | `EditorCloneCaretAbove` / `EditorCloneCaretBelow` |
| `Ctrl+Alt+=` / `-` | `editor::SelectLargerSyntaxNode` / `Smaller…` | `editor.action.smartSelect.expand` / `shrink` | `EditorSelectWord` / `EditorUnSelectWord` |

### Panels

| Key | Zed | VS Code | IntelliJ |
|---|---|---|---|
| `Alt+1` | `project_panel::ToggleFocus` | `workbench.view.explorer` | `ActivateProjectToolWindow` |
| `Alt+2` | `terminal_panel::Toggle` | `workbench.action.terminal.toggleTerminal` | `ActivateTerminalToolWindow` |
| `Alt+3` | `git_panel::ToggleFocus` | `workbench.view.scm` | `ActivateCommitToolWindow` |
| `Alt+4` | `agent::ToggleFocus` | *(chat view — varies by extension)* | `ActivateAIAssistantToolWindow` |
| `Alt+5` | `diagnostics::Deploy` | `workbench.actions.view.problems` | `ActivateProblemsViewToolWindow` |
| `Alt+0` | `workspace::CloseActiveDock` | `workbench.action.closeSidebar` | `HideActiveWindow` |
| `Alt+Shift+1` | `workspace::ToggleLeftDock` | `workbench.action.toggleSidebarVisibility` | — |
| `Alt+Shift+2` | `workspace::ToggleBottomDock` | `workbench.action.togglePanel` | — |
| `Alt+Shift+3` | `workspace::ToggleRightDock` | `workbench.action.toggleAuxiliaryBar` | — |

IntelliJ has no dock concept — tool windows hide individually via
`HideActiveWindow`, so `Alt+0` covers there what `Alt+Shift+<n>` covers
elsewhere.

---

## Defaults that must be overridden

Applying this scheme is not purely additive: each editor already uses some of
these keys for something else. These are the collisions to expect.

### VS Code

| Key | Ships as | Conflict |
|---|---|---|
| `Ctrl+D` | add selection to next find match | we use it for duplicate line |
| `Ctrl+Shift+D` | show Run and Debug view | we use it for delete line |
| `Ctrl+Alt+↑` / `↓` | insert cursor above / below | we use it for move line |
| `Alt+Shift+↑` / `↓` | copy line up / down | we use it for add cursor |

Note `Ctrl+Alt+arrows` and `Alt+Shift+arrows` are **swapped** relative to VS
Code's defaults — the two most likely keys to trip on.

### IntelliJ

| Key | Ships as | Conflict |
|---|---|---|
| `Alt+J` | add selection for next occurrence | we use it for go to definition |
| `Ctrl+Alt+F` | introduce field | we use it for format |
| `Alt+Shift+↑` / `↓` | move line up / down | we use it for add cursor |

`Alt+J` is the one to watch: the reflex fires and silently does something else
rather than nothing. Several bindings already match IntelliJ natively and need
no change — `Ctrl+D` duplicate, `Alt+Enter` quick fix, and `Alt+1`–`Alt+9` for
tool windows, which is where the whole `Alt+digit` idea came from.

---

## Gotchas

Hard-won, mostly from getting Zed working. Each cost a debugging round trip.

**A valid action ID is not a working binding.** Every failure so far passed an
existence check and still did nothing. When a key does nothing, suspect the
keystroke spelling or a more specific context first, not the action name.

**Zed — shifted digits must be written as symbols.** `Alt+Shift+1` arrives as
`alt-!`; a binding spelled `alt-shift-1` never matches. Letters and arrows are
unaffected, which is why `alt-shift-j` works. Layout-dependent — these symbols
assume US.

**Zed — the panel keys are bound twice on purpose.** Zed resolves a keystroke to
the most specific matching context, and its defaults bind `alt-1`..`alt-5` at
`Pane` depth to tab switching, which outranks a `Workspace` binding. Deleting
the duplicate `Pane` block silently reverts them to switching tabs.

**Zed — the `Alt+Shift+<n>` keys depend on dock positions.** They toggle docks,
not panels, and only line up with the panel numbers while project is left,
terminal bottom and git right. Pinned in `settings.jsonc`; dragging a panel
elsewhere breaks the pairing with no error.

**VS Code and IntelliJ — `Alt` opens the menu bar on Linux.** Both use `Alt` for
menu mnemonics, so `Alt+<letter>` may open a menu instead of running the
binding. Zed does not do this. In VS Code the relevant settings are
`window.menuBarVisibility`, `window.customMenuBarAltFocus` and
`window.enableMenuBarMnemonics` — all three exist in the installed build, though
which combination is needed has not been tested.

## Editor quirks

Three Zed keys do not behave like their neighbours. All are Zed limitations, not
choices, and none is fixable from the keymap.

- **`Alt+2` closes the terminal on a second press**, where `Alt+1` and `Alt+3`
  only return focus. The terminal is the one panel Zed gives a real toggle.
- **`Alt+0` only acts on a panel that has focus.** To dismiss one without going
  to it first, use `Alt+Shift+<n>`.
- **`Alt+Shift+4` and `Alt+Shift+5` do not exist.** The AI panel shares the right
  dock, so `Alt+Shift+3` hides it. Problems is an editor tab rather than a
  panel — close it with `Ctrl+W`.
