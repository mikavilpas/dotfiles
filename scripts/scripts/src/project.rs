use std::path::Path;

use anyhow::{anyhow, Context, Result};

pub fn path_to_project_file(cwd: &Path, file: &Path) -> Result<String> {
    let target_file = resolve_file(cwd, file);
    let target_file_dir = target_file
        .ancestors()
        .find(|p| p.is_dir())
        .map(Path::to_path_buf)
        .with_context(|| {
            format!(
                "Could not get a valid directory for file: {}",
                target_file.display()
            )
        })?;

    let repo = gix::discover(&target_file_dir).with_context(|| {
        format!(
            "Could not find a repository for file_path {} in cwd {}",
            file.display(),
            cwd.display()
        )
    })?;
    let file_repo = repo
        .workdir()
        .with_context(|| {
            format!(
                "Could not find the workdir for the repo at {}",
                repo.path().display()
            )
        })?
        .to_path_buf();

    let joined_absolute = file_repo.join(target_file);
    assert!(joined_absolute.is_absolute());
    let joined_relative = joined_absolute.strip_prefix(&file_repo).with_context(|| {
        format!(
            "Could not strip the prefix {} from the path {}",
            file_repo.display(),
            joined_absolute.display()
        )
    })?;

    let path = joined_relative
        .to_str()
        .ok_or_else(|| anyhow!("Path contains invalid UTF-8: {}", joined_relative.display()))?
        .to_string();

    Ok(if path.is_empty() {
        ".".to_string()
    } else {
        path
    })
}

fn resolve_file(cwd: &Path, file: &Path) -> std::path::PathBuf {
    if file.is_absolute() {
        file.to_path_buf()
    } else {
        cwd.join(file)
    }
}
