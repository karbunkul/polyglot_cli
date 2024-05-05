# WORK IN PROGRESS

## Polyglot CLI

Command line utility for create flutter l10n delegate with call chain nodes.

For example context.cart.save, directory with cart name contains save part file.

## Install

From source 
```sh 
dart pub global activate --source=path ./
```

From pub.dev 
```sh
dart pub global activate polyglot_cli
```

## Commands

- gen - Generate localizations delegate
- import - Import parts from arb files
- init - Init new project
- join - Join parts to arb files
- migrate - Migrate from arb format to yaml