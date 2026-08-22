# Mengelola Secrets untuk Coding Agents: 3 Opsi

> Research — 22 Agustus 2026
> Konteks: chezmoi + 1Password (`onepasswordRead`), multi-agent (pi, hermes, dll.), contoh kredensial `OPENROUTER_API_KEY`.

---

## Opsi 1 — Export Global Env Variable *(setup saat ini)*

Secret di-`op read` oleh chezmoi saat apply, lalu di-`export` dari `~/.config/zsh/env.d/030-secrets-op.sh` ke **setiap shell session**.

```zsh
export OPENROUTER_API_KEY="{{ $openrouter }}"
```

### ✅ Pros
- Satu sumber tunggal — semua agent & tool otomatis dapat key tanpa konfigurasi per-tool.
- Secret tidak tersimpan plaintext di disk (hanya ada di memori proses).
- Paling sederhana; nol setup tambahan.
- Kompatibel dengan semua tool yang membaca env var standar.

### ❌ Cons
- **Blast radius luas**: setiap proses yang kamu jalankan mewarisi key (termasuk script pihak ketiga, `npm install` postinstall, dsb.).
- Key terbaca via `/proc/<pid>/environ` / process memory oleh siapa pun yang bisa mengakses user session-mu.
- Mudah bocor secara tak sengaja: `env`, `set`, debug dump, error reporter, atau tool yang menyalin environment.
- Export terjadi di *setiap* shell, termasuk server/session yang tidak membutuhkannya.

---

## Opsi 2 — Plaintext secrets di file

Secret dirender langsung ke file milik tiap agent. Pola ini bukan spesifik pi — **hampir semua coding agent punya file kredensial serupa**, baik untuk LLM providers maupun MCP servers.

### Providers

Implementasi saat ini untuk API key: **chezmoi template** — referensi item 1Password (`op://`) disimpan plaintext di `.chezmoidata/onepassword.toml` (aman di-commit, bukan secret), lalu nilai aslinya dibaca via `onepasswordRead` saat `chezmoi apply` dan dirender ke file milik tiap agent:

```
.chezmoidata/onepassword.toml          # hanya referensi op://
  [secrets.ai_inference]
    openrouter_apikey = "op://.../openrouter"

~/.pi/agent/auth.json.tmpl             # template
  {{ $or := onepasswordRead .secrets.ai_inference.openrouter_apikey -}}
  { "openrouter": { "type": "api_key", "key": "{{ $or }}" } }

chezmoi apply                          # → ~/.pi/agent/auth.json (plaintext, 0600)
```

Contoh hasil render pi:

```json
{
  "openrouter": { "type": "api_key", "key": "sk-or-..." }
}
```

### ✅ Pros
- **Scope sempit** — hanya proses pi yang membaca file tersebut.
- Tidak masuk shell environment → tidak bocor lewat `env` dump / child processes.
- File dibuat `0600` (user read/write only).
- Auth file **prioritas lebih tinggi** daripada env var (docs pi.dev), jadi mudah override per-machine.

### ❌ Cons
- **Secret plaintext permanen di disk**: ikut ter-backup — **Time Machine, cloud sync (iCloud/Dropbox), snapshot VM** — dan berisiko saat disk/file dipindah. Inilah cons utama setup ini: `chezmoi apply` menulis secret ke file biasa, dan file tersebut tidak terkecuali dari backup.
- Rotasi = re-run `chezmoi apply` per mesin (lebih baik dari edit manual, tapi tetap tidak otomatis).
- Secret tersebar di banyak file target (satu per tool) vs terpusat.

> Mitigasi parsial untuk backup: exclude file auth dari Time Machine dengan `tmutil addexclusion ~/.pi/agent/auth.json` (dan setara per tool), atau enkripsi home/disk penuh (FileVault). Ini menutup vektor backup, tapi secret tetap plaintext di disk hidup.

### ⭐ Kenapa OAuth *masuk akal* ditulis ke file ini, tapi API key kurang?

Keduanya sama-sama disimpan plaintext di file. Bedanya pada **sifat kredensialnya**, bukan media penyimpanannya:

| Aspek | API key | OAuth token |
|---|---|---|
| Masa hidup | Tidak expired (OpenRouter: user-controlled key) | Access token: hitungan jam/menit; yang tersimpan terus adalah *refresh token* |
| Jika bocor | Langsung bisa dipakai untuk inference/billing sampai di-rotate manual | Access token cepat kedaluwarsa; refresh token harus lewat token-exchange flow dan bisa **di-revoke per-device** dari dashboard provider |
| Rotasi | Manual & disruptive | Otomatis refresh / revoke instan |
| Sumber file | Di-render (berpotensi lewat template/repo dotfiles) | Dibuat runtime oleh tool saat `/login` → **tidak pernah menyentuh repo chezmoi** |

Jadi metrik yang relevan bukan "plaintext vs bukan", melainkan: **berapa lama valid, seberapa mudah dicabut, dan apakah kredensial mengalir lewat repo dotfiles**. OAuth menang di ketiganya — itulah kenapa tools seperti pi nyaman menyimpannya di `auth.json`.

### Survey: file kredensial di coding agent lain

Hasil research per tool (22 Agustus 2026) — semua menyimpan kredensial plaintext di disk, hanya beda lokasi & format. Beberapa contoh isi file:

**opencode** — `~/.local/share/opencode/auth.json`:

```json
{
  "openrouter": { "type": "api_key", "key": "sk-or-v1-..." },
  "anthropic": { "type": "oauth", "access": "sk-ant-oat01-...", "refresh": "sk-ant-ort01-...", "expires": 1755000000000 }
}
```

**hermes** — API key di `~/.hermes/.env`, OAuth token di `~/.hermes/auth.json`:

```bash
# ~/.hermes/.env
OPENROUTER_API_KEY=sk-or-v1-...
KIMI_API_KEY=sk-kimi-...
```

```json
// ~/.hermes/auth.json
{
  "anthropic": { "type": "oauth", "access_token": "...", "refresh_token": "...", "expires_at": "2026-08-22T10:00:00Z" }
}
```

**codex** — `$CODEX_HOME/auth.json` (default `~/.codex/auth.json`):

```json
{
  "OPENAI_API_KEY": "sk-proj-...",
  "tokens": { "id_token": "eyJ...", "access_token": "eyJ...", "refresh_token": "eyJ...", "account_id": "acc_..." }
}
```

**claude code** — OAuth di `~/.claude/.credentials.json` (di macOS otomatis dimirror ke Keychain):

```json
{
  "claudeAiOauth": {
    "accessToken": "sk-ant-oat01-...",
    "refreshToken": "sk-ant-ort01-...",
    "expiresAt": 1755000000000,
    "scopes": ["user:inference", "user:profile"]
  }
}
```

Detail per tool, termasuk cara konfigurasi custom provider:

#### opencode — `~/.local/share/opencode/auth.json`

- `opencode auth login` (atau `/connect` di TUI) menulis kredensial ke `auth.json` — API key maupun OAuth token, plaintext.
- Untuk **custom provider**: jalankan `opencode auth login` → pilih **Other** → masukkan provider ID + API key (masuk ke `auth.json`), lalu daftarkan provider di `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "myprovider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "My AI Provider",
      "options": {
        "baseURL": "https://api.myprovider.com/v1",
        "apiKey": "{env:MYPROVIDER_API_KEY}"
      },
      "models": { "my-model": { "name": "My Model" } }
    }
  }
}
```

- Interpolasi bawaan: `{env:VAR}` (env var), `{file:~/.secrets/key}` (isi file) — jadi opencode pun jalur *tanpa plaintext* untuk custom provider, cukup tidak pakai `options.apiKey` literal.
- Keyring (macOS Keychain / secret-service) masih berstatus feature request/discussion (#4318, #1703); default tetap plaintext file.

#### hermes (Nous Research) — `~/.hermes/.env` + `~/.hermes/auth.json`

- API key provider disimpan di `~/.hermes/.env` (plaintext, disarankan `chmod 600`): `OPENROUTER_API_KEY=sk-or-...`
- OAuth (Nous Portal, Codex ChatGPT, Copilot, Claude Pro/Max) via `hermes model` / `hermes auth add` → tersimpan di `~/.hermes/auth.json`.
- **Custom endpoint** (OpenAI-compatible apa pun: vLLM, Ollama, LiteLLM, dll.) dikonfigurasi di `config.yaml`:

```yaml
model:
  default: my-model
  provider: custom
  base_url: http://localhost:8000/v1
  api_key: sk-or-...   # atau kosongkan untuk endpoint lokal
```

- Sejak v0.19.0 ada interface `SecretSource` pluggable yang bisa menarik secret dari Bitwarden / 1Password (`op://` reference) saat load — `.env` menjadi fallback. Ini artinya hermes juga mendukung pola Opsi 3.

#### codex (OpenAI) — `~/.codex/auth.json` + `~/.codex/config.toml`

- Login ChatGPT/OAuth dan `OPENAI_API_KEY` disimpan di `$CODEX_HOME/auth.json` (default `~/.codex/`), plaintext JSON:

```json
{ "OPENAI_API_KEY": "sk-..." }
```

- Ada tiga mode storage via `cli_auth_credentials_store` di `config.toml`: `"keyring"` (OS credential manager), `"file"` (plaintext auth.json), `"auto"` (default; keyring dulu, fallback ke file). Codex satu-satunya dari survey ini dengan dukungan keyring first-class.
- **Custom provider** di `config.toml` — key dibaca dari **env var**, bukan auth.json:

```toml
[model_providers.myprovider]
name = "My Provider"
base_url = "https://api.myprovider.com/v1"
env_key = "MYPROVIDER_API_KEY"
wire_api = "responses"
```

- Codex juga mendukung command-based auth (`[model_providers.<id>.auth] command = ...`) — sama seperti pola Opsi 3 pi.

#### Bonus: claude code — `~/.claude/.credentials.json`

- OAuth token (Claude Pro/Max) disimpan di `~/.claude/.credentials.json` (di macOS otomatis masuk Keychain); API key lewat env `ANTHROPIC_API_KEY`.
- Custom provider via `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN`, atau model router (`ANTHROPIC_MODEL`).

### MCP

Selain kredensial LLM provider, pola "secret plaintext di config" juga berlaku ke konfigurasi **MCP server** — dan ini sering terlewat karena MCP config biasanya di-commit:

| Tool | Lokasi MCP config | Cara secret masuk |
|---|---|---|
| opencode | `opencode.json` → `"mcp"` | Field `"environment"` mendukung interpolasi `{env:VAR}` / `{file:path}` → aman di-commit |
| codex | `~/.codex/config.toml` → `[mcp_servers.<name>]` | `env = { KEY = "..." }` — plaintext literal di TOML |
| claude code | `.mcp.json` (project, biasanya di-commit) / `~/.claude.json` | `"env": { "KEY": "${VAR}" }` — ekspansi `${VAR}` dari environment saat load |
| hermes | `config.yaml` → tool/MCP section | Env var via `~/.hermes/.env`; bisa dipakai `SecretSource` (`op://`) |

Contoh aman (opencode, MCP server dengan secret dari env):

```json
{
  "mcp": {
    "github": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "environment": {
        "GITHUB_TOKEN": "{env:GITHUB_TOKEN}"
      }
    }
  }
}
```

Contoh berisiko (literal plaintext, umum di tutorial):

```json
{ "mcp": { "github": { "environment": { "GITHUB_TOKEN": "ghp_xxx" } } } }
```

**Kesimpulan survey**: hampir semua agent memang punya mekanisme auth-file plaintext (jadi opsi 2 portable lintas tool), tapi hanya codex & hermes yang punya jalur resmi keluar dari plaintext (keyring / SecretSource), dan hanya pi + codex yang punya command-execution untuk Opsi 3. Untuk MCP, gunakan interpolasi env/file agar config tetap commit-able tanpa secret.

---

## Opsi 3 — Inject Saat Runtime (Command Execution)

pi mendukung field `key` berupa command — secret **tidak pernah tersimpan**, hanya diambil saat dibutuhkan:

```json
{
  "openrouter": { "type": "api_key", "key": "!op read 'op://vault/openrouter/credential'" }
}
```

File auth berisi **struktur + referensi vault**, bukan plaintext.

### ✅ Pros
- **Zero secret at rest** — tidak ada plaintext di disk maupun di env global.
- Tetap scoped per-agent (file auth hanya dibaca tool itu).
- Rotasi otomatis mengikuti 1Password (satu sumber kebenaran).
- File aman untuk di-commit/sinkron karena tidak berisi rahasia.
- Bisa juga pakai `$ENV_VAR` interpolasi jika suatu saat butuh hybrid.

### ❌ Cons
- Butuh `op` CLI ter-unlock saat agent jalan (biometric / session token) — kalau locked, agent gagal auth.
- Setup per-agent (tiap tool punya format config sendiri).
- Ada latensi kecil per pembacaan (panggilan CLI ke 1Password).
- Tidak semua coding agent mendukung command-execution di config — perlu dicek satu per satu.

---

## Ringkasan

| Kriteria | 1. Env global | 2. Plaintext auth file | 3. Runtime inject |
|---|---|---|---|
| Secret di disk | ❌ tidak | ⚠️ ya, plaintext permanen | ❌ tidak |
| Secret di env | ⚠️ ya, semua proses | ❌ tidak | ❌ tidak |
| Blast radius | Luas | Sempit (per-tool) | Sempit (per-tool) |
| Rotasi | Re-run chezmoi apply | Manual per mesin | Otomatis via 1Password |
| Butuh op unlocked | Hanya saat apply | Tidak | Ya, saat runtime |
| Kompatibilitas | Universal | Perlu dukungan auth file | Perlu dukungan `"!command"` |

## Rekomendasi

- **Hybrid bertahap**: pindahkan API key jangka panjang (mis. OpenRouter) ke **opsi 3** (`"!op read"`) di mana tool mendukungnya.
- OAuth/refresh-token biarkan ditulis runtime ke auth file masing-masing tool (opsi 2 alami) — risikonya rendah karena short-lived & revocable.
- Pertahankan env export **hanya** untuk kredensial lintas-tool yang memang butuh env (mis. `GITHUB_TOKEN` untuk git CLI, MCP servers) dan pertimbangkan scope-nya per-shell, bukan global.
