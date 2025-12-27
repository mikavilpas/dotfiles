import { flavors } from "@catppuccin/palette"
import { rgbify, textIsVisibleWithBackgroundColor } from "@tui-sandbox/library"
import assert from "assert"

describe("lazygit", () => {
  it("sanity check: .gitconfig and lazygit config are available for tests", () => {
    cy.visit("/")
    cy.startTerminalApplication({ commandToRun: ["bash"] }).then((t) => {
      t.runBlockingShellCommand({ command: "echo $HOME" }).then((output) => {
        assert(output.type === "success")
        expect(output.stdout).includes("testdirs/")
      })

      t.runBlockingShellCommand({ command: "ls -al $HOME" }).then((output) => {
        assert(output.type === "success")
        expect(output.stdout).includes(".gitconfig")
      })

      t.runBlockingShellCommand({
        command: "test -f ~/.config/lazygit/config.yml",
      }).then((output) => {
        assert(output.type === "success")
      })

      t.runBlockingShellCommand({
        command: `git config --list --show-origin`,
      }).then((output) => {
        assert(output.type === "success")
        expect(output.stdout).includes(".gitconfig")
      })
    })
  })

  it("can create a backup branch", () => {
    cy.visit("/")
    cy.startTerminalApplication({ commandToRun: ["bash"] })
    cy.typeIntoTerminal("mkdir myrepo && cd myrepo{enter}")
    cy.typeIntoTerminal("git init{enter}")
    cy.typeIntoTerminal("touch README.md{enter}")
    cy.typeIntoTerminal("git add .{enter}")
    cy.typeIntoTerminal('git commit -m "initial commit"{enter}')
    cy.typeIntoTerminal("lazygit{enter}")

    cy.contains("Donate")

    // enter the branch pane and wait for the branch to be selected

    cy.typeIntoTerminal("3")
    textIsVisibleWithBackgroundColor(
      "main",
      rgbify(flavors.macchiato.colors.crust.rgb),
    )

    // create a backup branch
    cy.typeIntoTerminal("?")
    cy.contains("Backup branch")
    cy.typeIntoTerminal("b")

    cy.contains("main--backup-")
  })

  it("displays custom commands in the commits pane", () => {
    cy.visit("/")
    cy.startTerminalApplication({ commandToRun: ["bash"] })
    cy.typeIntoTerminal("mkdir myrepo && cd myrepo{enter}")
    cy.typeIntoTerminal("git init{enter}")
    cy.typeIntoTerminal("touch README.md{enter}")
    cy.typeIntoTerminal("git add .{enter}")
    cy.typeIntoTerminal('git commit -m "initial commit"{enter}')
    cy.typeIntoTerminal("lazygit{enter}")

    cy.contains("Donate")

    // enter the commits pane and wait for the commit to be selected
    cy.typeIntoTerminal("4")
    textIsVisibleWithBackgroundColor(
      "initial commit",
      rgbify(flavors.macchiato.colors.crust.rgb),
    )

    cy.typeIntoTerminal("X")
    cy.contains("Copy selected commits to clipboard")
    cy.contains("Paste selected commits from clipboard")
    cy.contains("Share selected commits as a patch with instructions")
  })
})
