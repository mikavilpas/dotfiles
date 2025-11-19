#[derive(Debug, Eq, PartialEq)]
pub struct MyCommit {
    pub subject: String,
    pub body: Option<String>,
    pub fixups: Vec<MyCommit>,
}

impl MyCommit {
    #[must_use]
    pub fn new(subject: String, body: String) -> Self {
        Self {
            subject,
            body: if body.is_empty() { None } else { Some(body) },
            fixups: Vec::new(),
        }
    }

    #[must_use]
    pub fn is_fixup(&self) -> bool {
        self.subject.starts_with("fixup! ")
    }

    #[must_use]
    pub fn is_fixup_for(&self, other: &MyCommit) -> bool {
        self.is_fixup() && self.normalized_subject() == other.subject
    }

    #[must_use]
    pub fn normalized_subject(&self) -> &str {
        self.subject.trim_start_matches("fixup! ").trim()
    }
}
