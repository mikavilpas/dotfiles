use std::{num::NonZeroUsize, ops::Add};

use crate::commit_messages::my_commit::MyCommit;

pub struct MarkdownOptions {
    pub heading_symbol: String,
    pub indent_level: NonZeroUsize,
}

impl Default for MarkdownOptions {
    fn default() -> Self {
        MarkdownOptions {
            heading_symbol: "#".to_string(),
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
    result_lines.push(format!("{} {}", options.heading_symbol, commit.subject));

    if let Some(body) = &commit.body {
        result_lines.push("".to_string());
        body.split("\n").for_each(|line| {
            result_lines.push(line.to_string());
        });
    }

    // render fixups
    if !commit.fixups.is_empty() {
        let fixup_options = MarkdownOptions {
            heading_symbol: "###".to_string(), // third level heading for fixups
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
            if let Some(l) = fixup_lines.first() {
                // make it into a list item

                result_lines.push(format!("{}- > {}", indent, l));
            }
            for l in fixup_lines[1..].iter() {
                // indent the rest
                result_lines.push(format!("{}> {}", indent.repeat(2), l));
            }
        }
    }
}
