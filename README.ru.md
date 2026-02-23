<div align="center">
  <h1>macOS Screenshot Linker</h1>
  <p>Автоматически копирует в буфер ссылку <code>file://</code> на последний скриншот в macOS.</p>
  <p><strong>Язык:</strong> <a href="README.md">English</a> | <a href="README.ru.md">Русский</a></p>

  <p>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/SergeyAlbina/macos-screenshot-linker"></a>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/github/license/SergeyAlbina/macos-screenshot-linker"></a>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/actions/workflows/ci.yml"><img alt="CI" src="https://img.shields.io/github/actions/workflow/status/SergeyAlbina/macos-screenshot-linker/ci.yml?branch=main"></a>
    <a href="https://github.com/SergeyAlbina/macos-screenshot-linker/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/SergeyAlbina/macos-screenshot-linker"></a>
  </p>
</div>

## Зачем

Если делаешь много скриншотов, вручную копировать пути неудобно. Этот инструмент следит за папкой скриншотов и сразу кладет ссылку на последний файл в буфер обмена.

## Возможности

- Автоматически определяет новые скриншоты (`png`, `jpg`, `jpeg`, `heic`)
- Сразу копирует URL вида `file://...` в буфер обмена
- Опционально показывает уведомление macOS после каждого скриншота
- Устанавливается как пользовательский `launchd` агент
- Установка и удаление одной командой

## Быстрый старт

```bash
git clone https://github.com/SergeyAlbina/macos-screenshot-linker.git
cd macos-screenshot-linker
./scripts/install.sh
```

Сделай скриншот (`Cmd+Shift+4`), затем выполни:

```bash
pbpaste
```

Ожидаемый вывод:

```text
file:///Users/<you>/Pictures/Screenshots/Screen%20Shot%202026-02-23%20at%2015.44.12.png
```

## Опции установки

```bash
# Своя директория для скриншотов
./scripts/install.sh --dir "$HOME/Pictures/MyShots"

# Отключить уведомления macOS
./scripts/install.sh --no-notify
```

## Удаление

```bash
./scripts/uninstall.sh
```

## Как это работает

1. `launchd` следит за папкой скриншотов.
2. При появлении нового файла запускается `scripts/screenshot_copy_link.sh`.
3. Скрипт находит самый свежий скриншот и записывает его `file://` URL в буфер обмена.
4. Файл состояния предотвращает повторное копирование одного и того же скриншота.

## Структура проекта

```text
scripts/
  install.sh
  uninstall.sh
  screenshot_copy_link.sh
launchd/
  io.github.screenshot-linker.clipboard.plist.example
```

## Дорожная карта

См. [`ROADMAP.ru.md`](ROADMAP.ru.md).

## История изменений

См. [`CHANGELOG.md`](CHANGELOG.md).

## Диагностика

- Статус агента:

```bash
launchctl print "gui/$(id -u)/io.github.screenshot-linker.clipboard"
```

- Логи:

```bash
tail -n 100 /tmp/io.github.screenshot-linker.clipboard.err.log
tail -n 100 /tmp/io.github.screenshot-linker.clipboard.out.log
```

- Проверка папки скриншотов:

```bash
defaults read com.apple.screencapture location
```

## Вклад

PR приветствуются. Подробности в [`CONTRIBUTING.ru.md`](CONTRIBUTING.ru.md).

## Лицензия

MIT, см. [`LICENSE`](LICENSE).
