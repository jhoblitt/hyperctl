Ruby hyperctl Gem
=================

[![Build Status](https://travis-ci.org/jhoblitt/hyperctl.png)](https://travis-ci.org/jhoblitt/hyperctl)

#### Table of Contents

1. [Description](#description)
2. [Install](#install)
3. [Usage](#usage)
4. [Versioning](#versioning)
5. [Support](#support)
6. [Contributing](#contributing)
7. [See Also](#see-also)


Description
-----------

This Gem provides a simple cli utility named `hyperctl` that can check the
status of and [with appropriate permissions] enable/disable
hyperthreading/SMT/sibling cores on Linux via the
[`sysfs`](https://www.kernel.org/doc/Documentation/filesystems/sysfs.txt)
pseudo filesystem.  It should be compatible with most modern Linux
distributions as long as `sysfs` is mounted as `/sysfs`.


Install
-------

### via rubygems

    gem install hyperctl

### from git repo with bundler

    bundle install
    bundle exec rake install


Usage
-----

### `hyperctl`

    Usage:
      hyperctl
      hyperctl (--enable | --disable) [--quiet]
      hyperctl --status (--enable | --disable) [--quiet]
      hyperctl -h | --help
      hyperctl --version

    Options:
      --enable      Enable hyperthreading.
      --disable     Diable hyperthreading.
      --status      Report hyperthreading state.
      --quiet       Suppress stdout.
      --version     Show version.
      -h --help     Show this screen.

#### Exit codes

* `0` - success
* `1` - option parsing related error
* `2` - system error (Eg., permission denied)
* `3` - status does not match desired state

#### no options

Prints the current status of hyperthreading on the system to the `stdout`.
Exits with `0` if no errors were encountered.

    $ hyperctl
    cpu0 : enabled  - hypertheading: enabled
    cpu1 : enabled  - hypertheading: enabled
    cpu2 : enabled  - hypertheading: enabled
    cpu3 : enabled  - hypertheading: enabled
    cpu4 : enabled  - hypertheading: enabled
    cpu5 : enabled  - hypertheading: enabled
    cpu6 : enabled  - hypertheading: enabled
    cpu7 : enabled  - hypertheading: enabled

#### `(--enable | --disable) [--quiet]`

Attempt to enable or disable all hyperthread/SMT/sibling cores on the system.
Exits with `0` upon success, `2` for system errors, or `3` for state change
failures (unlikely).

With appropriate permissions to modify the appropriate sysfs entries:

    $ sudo hyperctl --disable
    cpu0 : enabled  - hypertheading: disabled
    cpu1 : enabled  - hypertheading: disabled
    cpu2 : enabled  - hypertheading: disabled
    cpu3 : enabled  - hypertheading: disabled
    cpu4 : disabled - hypertheading: disabled
    cpu5 : disabled - hypertheading: disabled
    cpu6 : disabled - hypertheading: disabled
    cpu7 : disabled - hypertheading: disabled
    $ echo $?
    0

Without appropriate permissions:

    $ hyperctl --disable
    Permission denied @ rb_sysopen - /sys/devices/system/cpu/cpu4/online
    $ echo $?
    2

#### `--status (--enable | --disable) [--quiet]`

Checks the status of hyperthread/SMT/sibling cores on the system. Exits with
`0` if the state matches the `(--enable | --disable)` option, otherwise with
`3`

System already in `--disable` state:

    $ sudo hyperctl --status --disable
    cpu0 : enabled  - hypertheading: disabled
    cpu1 : enabled  - hypertheading: disabled
    cpu2 : enabled  - hypertheading: disabled
    cpu3 : enabled  - hypertheading: disabled
    cpu4 : disabled - hypertheading: disabled
    cpu5 : disabled - hypertheading: disabled
    cpu6 : disabled - hypertheading: disabled
    cpu7 : disabled - hypertheading: disabled
    $ echo $?
    0

System not in `--enable` state:

    $ sudo hyperctl --status --enable
    cpu0 : enabled  - hypertheading: disabled
    cpu1 : enabled  - hypertheading: disabled
    cpu2 : enabled  - hypertheading: disabled
    cpu3 : enabled  - hypertheading: disabled
    cpu4 : disabled - hypertheading: disabled
    cpu5 : disabled - hypertheading: disabled
    cpu6 : disabled - hypertheading: disabled
    cpu7 : disabled - hypertheading: disabled
    $ echo $?
    3

#### `[--quiet]`

Suppresses the `stdout` status message.  Intended for usage from scripts.

    $ sudo hyperctl --status --enable --quiet
    $ echo $?
    3

    $ sudo hyperctl --status --disable --quiet
    $ echo $?
    0


Versioning
----------

This Gem is versioned according to the [Semantic Versioning
2.0.0](http://semver.org/spec/v2.0.0.html) specification.


Support
-------

Please log tickets and issues at [github](https://github.com/jhoblitt/hyperctl)


Contributing
------------

1. Fork it on github
2. Make a local clone of your fork
3. Create a topic branch.  Eg, `feature/mousetrap`
4. Make/commit changes
    * Commit messages should be in
      [imperative tense](http://git-scm.com/book/ch5-2.html)
    * Check that `Rspec` unit tests are not broken and coverage is added for
      new features - `bundle exec rake spec`
    * Documentation of API/features is updated as appropriate in the README
5. When the feature is complete, rebase / squash the branch history as
   necessary to remove "fix typo", "oops", "whitespace" and other trivial
   commits
6. Push the topic branch to github
7. Open a Pull Request (PR) from the *topic branch* onto parent repo's `master`
   branch


See Also
--------

* [Linux sysfs docs](https://www.kernel.org/doc/Documentation/filesystems/sysfs.txt)
* [Linux cpu-hotplug docs](https://www.kernel.org/doc/Documentation/cpu-hotplug.txt)
