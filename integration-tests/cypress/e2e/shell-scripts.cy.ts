import assert from "assert"

describe("shell scripts", () => {
  describe("git-autosquash-branch.sh", () => {
    // This script autosquashes only the specified branch in a stack,
    // preserving fixup commits in branches above.

    it("squashes fixups in the target branch only, preserving fixups in branches above", () => {
      cy.visit("/")
      cy.startTerminalApplication({ commandToRun: ["bash"] }).then((term) => {
        // Set up a git repo with stacked branches, each with their own fixups
        const setup = `
          set -eu
          mkdir myrepo && cd myrepo
          git init
          git config user.email "test@test.com"
          git config user.name "Test"
          git config rebase.updateRefs true

          # main branch
          echo "main" > main.txt && git add . && git commit -m "initial"

          # stack-branch-1: commits + fixups for its own commits
          git checkout -b stack-branch-1
          echo "a" > a.txt && git add . && git commit -m "commit A"
          echo "b" > b.txt && git add . && git commit -m "commit B"
          echo "fix-a" > a.txt && git add . && git commit -m "fixup! commit A"

          # stack-branch-2: commits + fixups for its own commits
          git checkout -b stack-branch-2
          echo "c" > c.txt && git add . && git commit -m "commit C"
          echo "d" > d.txt && git add . && git commit -m "commit D"
          echo "fix-c" > c.txt && git add . && git commit -m "fixup! commit C"
        `
        term.runBlockingShellCommand({ command: setup })

        // Verify initial state: both branches have fixup commits
        term
          .runBlockingShellCommand({
            command:
              "cd myrepo && git log --oneline stack-branch-1 | grep fixup",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.include("fixup! commit A")
          })

        term
          .runBlockingShellCommand({
            command:
              "cd myrepo && git log --oneline stack-branch-2 | grep fixup",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.include("fixup! commit A")
            expect(output.stdout).to.include("fixup! commit C")
          })

        // ACTION: Run the autosquash script on stack-branch-1 only
        term.runBlockingShellCommand({
          command:
            "cd myrepo && ~/.config/lazygit/git-autosquash-branch.sh stack-branch-1",
        })

        // VERIFY: stack-branch-1's fixup should be squashed (no more fixup commits)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline stack-branch-1",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.not.include("fixup!")
          })

        // VERIFY: stack-branch-1's fixup was actually applied (a.txt should contain "fix-a")
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git show stack-branch-1:a.txt",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout.trim()).to.equal("fix-a")
          })

        // VERIFY: stack-branch-2's fixup should be preserved (still has fixup commit)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline stack-branch-2",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.include("fixup! commit C")
          })

        // VERIFY: stack-branch-2 is still stacked on stack-branch-1
        term
          .runBlockingShellCommand({
            command:
              "cd myrepo && git merge-base --is-ancestor stack-branch-1 stack-branch-2 && echo 'OK'",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout.trim()).to.equal("OK")
          })
      })
    })

    it("can target a middle branch in a stack of 3 branches", () => {
      cy.visit("/")
      cy.startTerminalApplication({ commandToRun: ["bash"] }).then((term) => {
        // Set up: main -> branch1 -> branch2 -> branch3, each with their own fixups
        const setup = `
          set -eu
          mkdir myrepo && cd myrepo
          git init
          git config user.email "test@test.com"
          git config user.name "Test"
          git config rebase.updateRefs true

          # main branch
          echo "main" > main.txt && git add . && git commit -m "initial"

          # branch1: commits + fixups
          git checkout -b branch1
          echo "a" > a.txt && git add . && git commit -m "commit A"
          echo "fix-a" > a.txt && git add . && git commit -m "fixup! commit A"

          # branch2: commits + fixups
          git checkout -b branch2
          echo "b" > b.txt && git add . && git commit -m "commit B"
          echo "fix-b" > b.txt && git add . && git commit -m "fixup! commit B"

          # branch3: commits + fixups
          git checkout -b branch3
          echo "c" > c.txt && git add . && git commit -m "commit C"
          echo "fix-c" > c.txt && git add . && git commit -m "fixup! commit C"
        `
        term.runBlockingShellCommand({ command: setup })

        // ACTION: Run the autosquash script on branch2 (the middle branch)
        term.runBlockingShellCommand({
          command:
            "cd myrepo && ~/.config/lazygit/git-autosquash-branch.sh branch2",
        })

        // VERIFY: branch1's fixup should be squashed (it's below the target)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline branch1",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.not.include("fixup!")
          })

        term
          .runBlockingShellCommand({
            command: "cd myrepo && git show branch1:a.txt",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout.trim()).to.equal("fix-a")
          })

        // VERIFY: branch2's fixup should be squashed (it's the target)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline branch2",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.not.include("fixup!")
          })

        term
          .runBlockingShellCommand({
            command: "cd myrepo && git show branch2:b.txt",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout.trim()).to.equal("fix-b")
          })

        // VERIFY: branch3's fixup should be preserved (it's above the target)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline branch3",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.include("fixup! commit C")
          })

        // VERIFY: stack integrity is maintained
        term
          .runBlockingShellCommand({
            command:
              "cd myrepo && git merge-base --is-ancestor branch1 branch2 && git merge-base --is-ancestor branch2 branch3 && echo 'OK'",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout.trim()).to.equal("OK")
          })
      })
    })

    it("can target the bottom branch in a stack of 3 branches", () => {
      cy.visit("/")
      cy.startTerminalApplication({ commandToRun: ["bash"] }).then((term) => {
        // Set up: main -> branch1 -> branch2 -> branch3, each with their own fixups
        const setup = `
          set -eu
          mkdir myrepo && cd myrepo
          git init
          git config user.email "test@test.com"
          git config user.name "Test"
          git config rebase.updateRefs true

          # main branch
          echo "main" > main.txt && git add . && git commit -m "initial"

          # branch1: commits + fixups
          git checkout -b branch1
          echo "a" > a.txt && git add . && git commit -m "commit A"
          echo "fix-a" > a.txt && git add . && git commit -m "fixup! commit A"

          # branch2: commits + fixups
          git checkout -b branch2
          echo "b" > b.txt && git add . && git commit -m "commit B"
          echo "fix-b" > b.txt && git add . && git commit -m "fixup! commit B"

          # branch3: commits + fixups
          git checkout -b branch3
          echo "c" > c.txt && git add . && git commit -m "commit C"
          echo "fix-c" > c.txt && git add . && git commit -m "fixup! commit C"
        `
        term.runBlockingShellCommand({ command: setup })

        // ACTION: Run the autosquash script on branch1 (the bottom branch)
        term.runBlockingShellCommand({
          command:
            "cd myrepo && ~/.config/lazygit/git-autosquash-branch.sh branch1",
        })

        // VERIFY: branch1's fixup should be squashed (it's the target)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline branch1",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.not.include("fixup!")
          })

        term
          .runBlockingShellCommand({
            command: "cd myrepo && git show branch1:a.txt",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout.trim()).to.equal("fix-a")
          })

        // VERIFY: branch2's fixup should be preserved (it's above the target)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline branch2",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.include("fixup! commit B")
          })

        // VERIFY: branch3's fixup should be preserved (it's above the target)
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline branch3",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.include("fixup! commit C")
          })

        // VERIFY: stack integrity is maintained
        term
          .runBlockingShellCommand({
            command:
              "cd myrepo && git merge-base --is-ancestor branch1 branch2 && git merge-base --is-ancestor branch2 branch3 && echo 'OK'",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout.trim()).to.equal("OK")
          })
      })
    })

    it("handles the case when there are no fixups to squash", () => {
      cy.visit("/")
      cy.startTerminalApplication({ commandToRun: ["bash"] }).then((term) => {
        const setup = `
          set -eu
          mkdir myrepo && cd myrepo
          git init
          git config user.email "test@test.com"
          git config user.name "Test"
          git config rebase.updateRefs true

          echo "main" > main.txt && git add . && git commit -m "initial"
          git checkout -b branch1
          echo "a" > a.txt && git add . && git commit -m "commit A"
        `
        term.runBlockingShellCommand({ command: setup }).then((output) => {
          assert(output.type === "success")
        })

        // Should succeed even with no fixups
        term
          .runBlockingShellCommand({
            command:
              "cd myrepo && ~/.config/lazygit/git-autosquash-branch.sh branch1",
          })
          .then((output) => {
            assert(output.type === "success")
          })

        // Branch should still have the same commit
        term
          .runBlockingShellCommand({
            command: "cd myrepo && git log --oneline branch1 | head -1",
          })
          .then((output) => {
            assert(output.type === "success")
            expect(output.stdout).to.include("commit A")
          })
      })
    })
  })
})
