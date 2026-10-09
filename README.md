# Rakshithbhat03 Tap

| Formula | Description |
| --- | --- |
| [`portmap`](https://github.com/RakshithBhat03/portmap) | Bookmarks for everything listening on localhost |
| [`cliproxyapi`](https://github.com/router-for-me/CLIProxyAPI) | Prebuilt CLIProxyAPI releases (Apple silicon), bumped within minutes of each release |

## How do I install these formulae?

`brew install rakshithbhat03/tap/<formula>`

Or `brew tap rakshithbhat03/tap` and then `brew install <formula>`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "rakshithbhat03/tap"
brew "<formula>"
```

## cliproxyapi auto-updates

`bin/update-cliproxyapi` bumps `Formula/cliproxyapi.rb` to the latest upstream release and pushes it.
When `cliproxyapi` is installed from this tap, it also upgrades it and restarts the `brew services` job.
`launchd/com.rakshithbhat03.cliproxyapi-updater.plist` runs it every 15 minutes (log: `/tmp/cliproxyapi-updater.log`).

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
