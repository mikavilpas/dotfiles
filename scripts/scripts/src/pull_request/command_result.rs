use std::process::{self, Output};

#[derive(Debug)]
pub(crate) struct CommandResult {
    pub(crate) status: process::ExitStatus,
    pub(crate) stdout: String,
    pub(crate) stderr: String,
}
impl std::fmt::Display for CommandResult {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "command failed with status: {}\nstdout: {}\nstderr: {}",
            self.status, self.stdout, self.stderr
        )
    }
}
impl std::error::Error for CommandResult {}

impl TryFrom<Output> for CommandResult {
    type Error = CommandResult;

    fn try_from(output: Output) -> Result<Self, Self::Error> {
        let stdout = String::from_utf8_lossy(&output.stdout);
        let stderr = String::from_utf8_lossy(&output.stderr);

        if output.status.success() {
            Ok(CommandResult {
                status: output.status,
                stdout: stdout.to_string(),
                stderr: stderr.to_string(),
            })
        } else {
            Err(CommandResult {
                status: output.status,
                stdout: String::from_utf8_lossy(&output.stdout).to_string(),
                stderr: String::from_utf8_lossy(&output.stderr).to_string(),
            })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::process::Command;

    #[test]
    fn test_command_result_success() {
        let output = Command::new("echo")
            .arg("Hello, world!")
            .output()
            .expect("failed to execute process");

        let result = CommandResult::try_from(output).expect("failed to convert output");
        assert_eq!(result.stdout.trim(), "Hello, world!");
        assert!(result.status.success());
    }

    #[test]
    fn test_command_result_failure() {
        let output = Command::new("false")
            .output()
            .expect("failed to execute process");

        let result = CommandResult::try_from(output).expect_err("expected failure");
        assert!(!result.status.success());
        assert_eq!(result.stderr.trim(), "");
    }
}
