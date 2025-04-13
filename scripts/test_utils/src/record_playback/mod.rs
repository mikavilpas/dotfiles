use std::path::Path;

use anyhow::Context;

pub fn load_and_update_response<N: AsRef<Path>>(
    path: &N,
    fetch: impl FnOnce() -> String,
) -> anyhow::Result<String> {
    let data = fetch();
    std::fs::write(path.as_ref(), &data)
        .with_context(|| format!("Failed to write response to {}", path.as_ref().display()))?;
    Ok(data)
}

#[cfg(test)]
mod tests {
    use tempfile::tempdir;

    use super::*;

    #[test]
    fn test_load_or_record_response() -> anyhow::Result<()> {
        let dir = tempdir()?;
        let name = "test_response";
        let fetch = || "This is a test response".to_string();

        // First call should record the response
        let name1 = dir
            .path()
            .join(name)
            .into_os_string()
            .into_string()
            .map_err(|_| anyhow::anyhow!("Failed to convert OsString to String"))?;
        let response = load_and_update_response(&name1, fetch)?;
        assert_eq!(response, "This is a test response");
        assert!(dir.path().exists());

        // Second call should load the recorded response
        let response = load_and_update_response(&name1, fetch)?;
        assert_eq!(response, "This is a test response");

        Ok(())
    }
}
