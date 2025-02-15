describe("lazygit", () => {
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
    cy.typeIntoTerminal("b")

    cy.contains("main--backup-")
  })
})
