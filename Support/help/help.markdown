# Reformat Document

The command “Reformat Document” – accessible via <kbd>^</kbd> + <kbd>⇧</kbd>  +  <kbd>H</kbd> – formats the current document using the `--auto-correct` option of [RuboCop][]. It also shows information about the formatting status in a floating tooltip. The command displays the information about the formatting status either as black text only, or as colorful text if [aha][] is accessible via `PATH`.

[aha]: https://github.com/theZiz/aha
[RuboCop]: https://github.com/bbatsov/rubocop

## RuboCop Version

Which version of [RuboCop][] “Reformat Document” uses depends on your environment. The command will try the following options in the given order:

1. The version of `rubocop` installed via [Bundler][].
2. The value of the path specified in `TM_RUBOCOP`.
3. The version of `rubocop` installed via [RVM][]. (The command assumes that you installed RVM in your home directory.)
4. Any other version of `rubocop` accessible via
  1. `/usr/local/bin/rubocop`,
  2. `$HOME/.rbenv/shims/rubocop` or
  3.  the locations in your `PATH`.

[Bundler]: https://bundler.io
[RVM]: https://rvm.io
