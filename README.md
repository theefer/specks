# Specks

A minimal application to manage your dot files (you know, `~/.blah`, etc).

## Install

Use gem to build and install the specks:

```
$ gem build specks.gemspec
$ sudo gem install specks-${VERSION}.gem
```

## Use

Your specks configuration should go into the `~/.dot` directory, and
your module definitions in the `modules` directory within that.

For instance, create a module directory for your git configuration and
add files in it you want mapped into your dot-files, e.g. git config
and ignore:

```
$ mkdir -p ~/.dot/modules/git
$ cat > ~/.dot/modules/git/config
[color]
        diff = auto
        status = auto
        branch = auto
[core]
        excludesfile = ~/.gitignore_global
$ cat > ~/.dot/modules/git/ignore
.DS_Store
*~
```

Then setup the mapping rules:

```
$ cat > ~/.dot/modules/git/recipe.yml
:symlink:
  config: ~/.gitconfig
  ignore: ~/.gitignore_global
```

Once your modules are setup, you can install them by simply running
the `specks` command:

```
$ specks
Exporting config for git
Symlink config for git to ~/.gitconfig
Exporting ignore for git
Symlink ignore for git to ~/.gitignore_global
```

The output confirms symlinks have been installed successfully.

You're done!
