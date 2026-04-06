#![warn(clippy::indexing_slicing)]

pub mod arguments;
pub mod commit_messages;
pub mod github;
pub mod gitlab;
pub mod init;
pub mod project;

/// ANSI escape codes for terminal styling.
pub mod style {
    /// Start an OSC 8 hyperlink: `{OSC8_START}{url}{OSC8_MID}`.
    pub const OSC8_START: &str = "\x1b]8;;";
    /// Separator between URL and visible text in an OSC 8 hyperlink.
    pub const OSC8_MID: &str = "\x1b\\";
    /// End an OSC 8 hyperlink.
    pub const OSC8_END: &str = "\x1b]8;;\x1b\\";
}
