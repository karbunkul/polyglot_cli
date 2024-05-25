# WORK IN PROGRESS

## Polyglot CLI

Command line utility for create flutter l10n delegate with call chain nodes.

For example context.cart.save, directory with cart name contains save part file.

## Functional

| Functional name                                                | Support | Description                           |
| -------------------------------------------------------------- | ------- | ------------------------------------- |
| Migrate from .arb                                              | ✅      | Command `polyglot migrate`            |
| Pluralization                                                  | ❌      |                                       |
| Selection                                                      | ❌      |                                       |
| Support dartifferent types  (`String`, `int`, `double`, etc.): | ✅      |                                       |
| Dart doc generation                                            | ❌      | Adds comments for getters, functions  |
| Custom documentation for node                                  | ❌      |                                       |
| Generation for other languages locales                         | ✅      | See `translates` in _.part.yaml_ file |

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

## Commands

- `gen` - Generate localizations delegate
- `import` - Import parts from arb files
- `init` - Init new project
- `join` - Join parts to arb files
- `migrate` - Migrate from arb format to yaml

## Third Party

New PR's are welcome :)

### Getting started

You must activate [spider](https://pub.dev/packages/spider) from pub.dev by using this command:

```sh
dart pub global activate spider
```

Necessary generate file classes for `assets` folder:

```sh
spider build
```

### Debugging

Debuging carried out through unit tests. See [test](./test/) folder.

> [!IMPORTANT]
> If you want to writes tests, then recomended for this tool 
> using integration tests (see [integration_test](./integration_test/) folder) instead unit test.
>
> Recomneded using unit test only for debugging. Because, this tool generating files, therefore best choice for the full test coverage it's integration_test:
>
> What does this give:
> 
> * more flexibility
> * full coverage