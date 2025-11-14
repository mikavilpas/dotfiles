#[derive(Debug)]
pub struct MyCommit {
    pub subject: String,
    pub body: Option<String>,
}

impl MyCommit {
    pub fn new(subject: String, body: String) -> Self {
        Self {
            subject,
            body: if body.is_empty() { None } else { Some(body) },
        }
    }
}
