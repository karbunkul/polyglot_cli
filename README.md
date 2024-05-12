# WORK IN PROGRESS

## Polyglot CLI

Command line utility for create flutter l10n delegate with call chain nodes.

For example context.cart.save, directory with cart name contains save part file.

## Functional

| Functional name                        | Supporting | Description                          |
| -------------------------------------- | ---------- | ------------------------------------ |
| Migrate from .arb                      | ✅         | Command `polyglot migrate`           |
| Pluralization                          | ❌         |                                      |
| Selection                              | ❌         |                                      |
| Parameters:                            | ✅         |                                      |
| - Base types `String`, `int`, `double` | ✅         |                                      |
| Dart doc generation                    | ❌         | Adds comments for getters, functions |
| Custom documentation for node          | ❌         |                                      |

Where:

- ✅ - full completed
- ❌ - not completed
- ⚠️ - partial comleted


## Getting started

From source 

```sh 
dart pub global activate --source=path ./
```

From pub.dev 

```sh
dart pub global activate polyglot_cli
```

### Usage

Commands description:

```sh
polyglot --help
```

Init project (generating configuration file `polyglot.yaml`):

```sh
polyglot init
```

Generate localizations delegate:

```sh
polyglot gen
```

## Third Party

You must activate [spider](https://pub.dev/packages/spider) from pub.dev by using this command:

```sh
dart pub global activate spider
```

Necessary generate file classes for `assets` folder:

```sh
spider build
```

## Commands

- gen - Generate localizations delegate
- import - Import parts from arb files
- init - Init new project
- join - Join parts to arb files
- migrate - Migrate from arb format to yaml