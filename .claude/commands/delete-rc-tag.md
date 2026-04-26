Delete the `rc` git tag from both local and remote.

Steps:
1. Run `git tag -d rc` to delete the local tag
2. Run `git push origin :refs/tags/rc` to delete the remote tag
