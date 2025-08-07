# 🛠️ Formatter & Linter Configuration Files

This folder contains configuration files for formatters and linters, based on my personal preferences.

You can copy these files into any of your projects to ensure consistent formatting and linting rules.
Configuration files are typically placed in the **root directory** of each project.

---

## 📊 Supported Formatters and Configuration Files

| Programming Language     | CLI Formatter         | Configuration File Name                             |
|--------------------------|------------------------|------------------------------------------------------|
| JavaScript / TypeScript  | [Biome](https://biomejs.dev/)        | `biome.json`                                         |
| Lua                      | [Stylua](https://github.com/JohnnyMorganz/StyLua)          | `stylua.toml`                                        |
| TOML                     | [Taplo](https://taplo.tamasfe.dev/)         | `.taplo.toml`                                        |
| Python                   | [Black](https://black.readthedocs.io/)          | `pyproject.toml` (under `[tool.black]`)             |
| Go                       | `gofmt` / `gofumpt`     | _No configuration needed_                            |
| Rust                     | [rustfmt](https://rust-lang.github.io/rustfmt/)        | `rustfmt.toml` or `.rustfmt.toml`                    |
| JSON, YAML, etc.         | [Prettier](https://prettier.io/)         | `.prettierrc`, `.prettierrc.json`, or `package.json` |
| PHP                      | [PHP-CS-Fixer](https://cs.symfony.com/)     | `.php-cs-fixer.php`                                  |
| Ruby                     | [RuboCop](https://docs.rubocop.org/)        | `.rubocop.yml`                                       |
| Java                     | [google-java-format](https://github.com/google/google-java-format) | _No configuration needed_              |
| C / C++                  | [clang-format](https://clang.llvm.org/docs/ClangFormat.html)       | `.clang-format`                                      |

---

## 📝 Notes

- These config files are ready to use.
- Feel free to modify them to suit specific project needs.
- Some formatters like `gofmt` or `google-java-format` don't require a config file, as they use built-in formatting rules.
