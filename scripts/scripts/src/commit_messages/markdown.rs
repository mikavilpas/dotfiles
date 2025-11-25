use crate::commit_messages::my_commit::MyCommit;

const INDENT: &str = "  ";

pub fn commit_as_markdown(result_lines: &mut Vec<String>, commit: MyCommit) {
    result_lines.push(format!("{} {}", "#", commit.subject).as_str().to_owned());

    if let Some(body) = &commit.body {
        result_lines.push("".to_string());
        body.split('\n').for_each(|line| {
            result_lines.push(line.to_string());
        });
    }

    // render fixups
    if !commit.fixups.is_empty() {
        result_lines.push("".to_string());
        result_lines.push("**Fixups:**".to_string());

        for mut fixup in commit.fixups {
            if let Some(mut body_lines) = fixup.body.as_mut().map(|b| b.split('\n'))
                && let Some(first_line) = body_lines.next()
            {
                // make it into a list item
                result_lines.push(format!("{INDENT}- {first_line}"));
                for l in body_lines {
                    // indent the rest
                    result_lines.push(format!("{}{l}", INDENT.repeat(2)));
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::commit_messages::my_commit::FixupCommit;

    use super::*;
    use pretty_assertions::assert_eq;

    #[test]
    fn test_commit_as_markdown() {
        let commit = MyCommit {
            subject: "feat: my-feature".to_string(),
            body: Some(["This is the body of the commit.", "It has multiple lines."].join("\n")),
            fixups: vec![
                FixupCommit {
                    subject: "fixup! feat: my-feature".to_string(),
                    body: None,
                },
                FixupCommit {
                    subject: "fixup! feat: my-feature".to_string(),
                    body: Some("Single line fixup body.".to_string()),
                },
                FixupCommit {
                    subject: "fixup! feat: my-feature".to_string(),
                    body: Some("Multi-line\nfixup body".to_string()),
                },
            ],
        };

        let mut result_lines = vec![];
        commit_as_markdown(&mut result_lines, commit);

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
