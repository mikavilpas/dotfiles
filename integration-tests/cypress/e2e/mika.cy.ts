import assert from "assert"

describe("mika terminal application (personal application)", () => {
  it("provides tab completions for the commands", () => {
    cy.visit("/")
    cy.startTerminalApplication({ commandToRun: ["fish"] }).then((t) => {
      // the mika application should have been installed earlier in the build process
      t.runBlockingShellCommand({ command: "which mika" }).then((output) => {
        assert(output.type === "success")
        expect(output.stdout).matches(/\/mika/)
      })

      // the shell should offer completions for the commands

      // sanity check - the shell should be able to offer completions for
      // builtin commands
      cy.typeIntoTerminal("git --{control+i}")
      cy.contains("--git-dir")
      cy.typeIntoTerminal("{control+u}") // clear the line
      cy.contains("--git-dir").should("not.exist")

      // sanity check - the shell completions should be available
      cy.typeIntoTerminal("ls -R ~/.config/fish{enter}")

      cy.typeIntoTerminal("mika {control+i}")
      cy.contains("branch-summary")
      cy.contains("summary")
      cy.contains("path")
      cy.contains("share-patch")
    })
  })
})
