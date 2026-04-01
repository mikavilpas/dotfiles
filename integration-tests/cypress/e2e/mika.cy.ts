import assert from "assert"

describe("mika terminal application (personal application)", () => {
  it("provides tab completions for the commands", () => {
    cy.visit("/")
    cy.startTerminalApplication({
      commandToRun: ["fish"],
      additionalEnvironmentVariables: {
        MISE_NO_CONFIG: "1", // disable mise config for the test
        CI: "1", // skip fish config init (fnm, atuin, etc.) that isn't available in tests
      },
      configureTerminal: (t) => {
        t.recipes.supportDA1()
      },
    }).then((t) => {
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

      // check mika mrs-summary
      cy.contains("mrs-summary")
      cy.typeIntoTerminal("mrs-summary -{control+i}")
      cy.contains("--format")
      cy.typeIntoTerminal("-format {control+i}")
      cy.contains("branches")
      cy.contains("links")
    })
  })

  it("can generate fish shell functions with 'mika init fish'", () => {
    cy.visit("/")
    cy.startTerminalApplication({
      commandToRun: ["fish"],
      additionalEnvironmentVariables: {
        MISE_NO_CONFIG: "1",
        CI: "1",
      },
      configureTerminal: (t) => {
        t.recipes.supportDA1()
      },
    }).then((t) => {
      t.typeIntoTerminal(
        "mika init fish --output-dir ~/.config/fish/mika/{enter}",
      )
      cy.contains("Wrote 3 fish files to")
      t.typeIntoTerminal("clear{enter}")

      t.runBlockingShellCommand({
        // assert that the command succeeded by checking that the output
        // directory was created
        command: "test -d ~/.config/fish/mika",
      })

      // verify the functions are available via lazy loading
      // (runBlockingShellCommand starts a fresh fish shell, so we need to
      // set fish_function_path in the same command)
      t.runBlockingShellCommand({
        shell: "fish",
        command:
          "set --append fish_function_path ~/.config/fish/mika; and functions --query prs; and echo prs:ok; or echo prs:missing",
      }).then((output) => {
        assert(output.type === "success")
        expect(output.stdout).to.include("prs:ok")
      })

      t.runBlockingShellCommand({
        shell: "fish",
        command:
          "set --append fish_function_path ~/.config/fish/mika; and functions --query mrs; and echo mrs:ok; or echo mrs:missing",
      }).then((output) => {
        assert(output.type === "success")
        expect(output.stdout).to.include("mrs:ok")
      })

      // set it for the interactive shell as well, to allow for interactive
      // experimentation when maintaining the tests
      t.typeIntoTerminal(
        "set --append fish_function_path ~/.config/fish/mika{enter}",
      )

      // verify that tab completions for mika are available
      t.typeIntoTerminal("mika {control+i}")
      cy.contains("branch-summary")
      cy.contains("mrs-summary")
      cy.contains("prs-summary")
      cy.contains("init")
    })
  })
})
