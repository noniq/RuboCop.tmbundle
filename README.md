# RuboCop for TextMate 2

This bundle integrates [RuboCop](https://github.com/bbatsov/rubocop) into [TextMate](https://github.com/textmate/textmate).

## Features

 * RuboCop runs automatically each time a Ruby file is saved. Output is not shown directly, but a gutter icon (warning sign) is added to each line that triggered a RuboCop message. Click on these icons to show the associated messages.
 * Alternatively there’s also the explicit **“Run RuboCop”** command (bound to <kbd>⌃⇧V</kbd>): This runs RuboCop for the files *currently selected in the file browser* and shows the output ([clang style][]) in a separate window. Clicking on the filename part of a message will bring you to the appropriate line in the source file. If no file is selected, RuboCop is run for the complete project directory (hint: use <kbd>⇧⌘A</kbd> to quickly deselect everything in the file browser).

There is one more subtle difference between running RuboCop implicitly (on save) or explicitly (via “Run RuboCop”): If your RuboCop configuration file excludes some files, those files will not be checked on save. They will however be checked if they are selected in the file browser and you use “Run RuboCop” (technically, running RuboCop on save uses [`--force-exclusion`][]).

[clang style]: http://rubocop.readthedocs.io/en/latest/formatters/#clang-style-formatter
[`--force-exclusion`]: https://github.com/bbatsov/rubocop/issues/893

## Determining Which RuboCop Executable to Use

The bundle runs the rubocop executable like this:

 * If a binstub (`bin/rubocop`) is present in the project directory, it is used.
 * Otherwise, if the project directory contains a `Gemfile.lock` with an entry for RuboCop, `bundle exec rubocop` is used.
 * Otherwise it is assumed that RuboCop is installed globally and can be run by simply invoking `rubocop` (with the project directory as working directory).

This should work for almost all setups and versions of Ruby / RuboCop. Feel free to open an issue if it doesn’t work for you!

## Known Issues

 * Does not support RuboCop’s [HTML formatter](http://rubocop.readthedocs.io/en/latest/formatters/#html-formatter).

## Installation

```shell
mkdir -p ~/Library/Application\ Support/Avian/Bundles
cd ~/Library/Application\ Support/Avian/Bundles
git clone https://github.com/noniq/RuboCop.tmbundle.git
```

## Similar Bundles

 * https://github.com/mrdougal/textmate2-rubocop
 * https://github.com/goyox86/rubocop-tmbundle
