describe("lazygit", () => {
  it("sanity check: .gitconfig is available for tests", () => {
    cy.visit("/")
    cy.startTerminalApplication({ commandToRun: ["bash"] }).then(() => {
      cy.typeIntoTerminal(`echo $HOME{enter}`)
      cy.typeIntoTerminal(`ls -al $HOME{enter}`)
      cy.typeIntoTerminal(`test -f ~/.gitconfig || echo "no gitconfig" {enter}`)
      cy.typeIntoTerminal(`git config --list --show-origin | grep user {enter}`)

      cy.typeIntoTerminal(
        "test -f ~/.config/lazygit/config.yml || echo 'no lazygit config' {enter}",
      )

      cy.contains("mika.vilpas@gmail.com")
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
    cy.contains("Author:")

    // create a backup branch
    cy.typeIntoTerminal("?")
    cy.contains("Backup branch")
    cy.typeIntoTerminal("b")

    cy.contains("main--backup-")
  })
})
