use std::{num::NonZeroUsize, ops::Add};

use crate::commit_messages::my_commit::MyCommit;

pub struct MarkdownOptions {
    pub indent_level: NonZeroUsize,
}

impl Default for MarkdownOptions {
    fn default() -> Self {
        MarkdownOptions {
            indent_level: NonZeroUsize::new(1).unwrap(),
        }
    }
}

const MAX_HEADING_LEVEL: usize = 6;

pub fn commit_as_markdown(
    result_lines: &mut Vec<String>,
    commit: &MyCommit,
    options: &MarkdownOptions,
) {
    let mut line = String::new();
    if !commit.is_fixup() {
        line.push_str(format!("{} {}", "#", commit.subject).as_str());
        result_lines.push(line);
    }

    if let Some(body) = &commit.body {
        if !commit.is_fixup() {
            result_lines.push("".to_string());
        }
        body.split("\n").for_each(|line| {
            result_lines.push(line.to_string());
        });
    }

    // render fixups
    if !commit.fixups.is_empty() {
        let fixup_options = MarkdownOptions {
            indent_level: {
                let new_level = options.indent_level.get().add(1).min(MAX_HEADING_LEVEL);
                NonZeroUsize::new(new_level).unwrap()
            },
        };
        result_lines.push("".to_string());
        result_lines.push("**Fixups:**".to_string());

        let indent = " ".repeat(options.indent_level.get() * 2);

        for fixup in commit.fixups.iter() {
            let mut fixup_lines = vec![];
            commit_as_markdown(&mut fixup_lines, fixup, &fixup_options);

            if let Some((body_first_line, body_rest_lines)) = fixup_lines.split_first() {
                // make it into a list item
                result_lines.push(format!("{indent}- {body_first_line}"));

                for l in body_rest_lines {
                    // indent the rest
                    result_lines.push(format!("{}{l}", indent.repeat(2)));
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn test_commit_as_markdown() {
        let commit = MyCommit {
            subject: "feat: my-feature".to_string(),
            // body: Some("This is the body of the commit.\nIt has multiple lines.".to_string()),
            body: Some(["This is the body of the commit.", "It has multiple lines."].join("\n")),
            fixups: vec![
                MyCommit {
                    subject: "fixup! feat: my-feature".to_string(),
                    body: None,
                    fixups: Vec::new(),
                },
                MyCommit {
                    subject: "fixup! feat: my-feature".to_string(),
                    body: Some("Single line fixup body.".to_string()),
                    fixups: Vec::new(),
                },
                MyCommit {
                    subject: "fixup! feat: my-feature".to_string(),
                    body: Some("Multi-line\nfixup body".to_string()),
                    fixups: Vec::new(),
                },
            ],
        };

        let mut result_lines = vec![];
        let options = MarkdownOptions::default();
        commit_as_markdown(&mut result_lines, &commit, &options);

        assert_eq!(
            result_lines,
            [
                "# feat: my-feature",
                "",
                "This is the body of the commit.",
                "It has multiple lines.",
                "",
                "**Fixups:**",
                "  - Single line fixup body.",
                "  - Multi-line",
                "    fixup body"
            ]
            .iter()
            .map(|s| s.to_string())
            .collect::<Vec<String>>()
        );
    }
}
