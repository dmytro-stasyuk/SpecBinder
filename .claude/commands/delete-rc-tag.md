Delete the `rc` git tag from both local and remote in the main spec-binder repo.

IMPORTANT: Always run these commands from the project root `/Users/dmytro/Projects/SpecBinder/spec-binder`, not from any submodule directory.

Steps:
1. Run `cd /Users/dmytro/Projects/SpecBinder/spec-binder` to ensure you are in the main repo
2. Run `git tag -d rc` to delete the local tag
3. Run `git push origin :refs/tags/rc` to delete the remote tag
