# Reformat Document

The command “Reformat Document” – accessible via <kbd>^</kbd> + <kbd>⇧</kbd>  +  <kbd>H</kbd> – formats the current document using the `--auto-correct` option of [RuboCop][]. It also shows information about the formatting status in a floating tooltip. The command displays the information about the formatting status either as black text only, or as colorful text if [aha][] is accessible via `PATH`.

[aha]: https://github.com/theZiz/aha
[RuboCop]: https://github.com/bbatsov/rubocop

## RuboCop Version

Which version of [RuboCop][] “Reformat Document” uses depends on your environment. The command will try the options below in the given order:

1. The value of the command specified via `TM_RUBOCOP`.
2. A executable version of RuboCop accessible via `bin/rubocop`
3. The version of `rubocop` installed via [Bundler][].
4. Any other version of `rubocop` accessible via,
   - `/usr/local/bin/rubocop`,
   - `$HOME/.rbenv/shims/rubocop`
   - or the locations in your `PATH`.

 “Reformat Document” prefers [RVM][] install location of `rubocop` for all of the applicable options above.

[Bundler]: https://bundler.io
[RVM]: https://rvm.io
