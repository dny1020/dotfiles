# qutebrowser · config mínima (Danilo)
# Ref: https://qutebrowser.org/doc/help/configuring.html
# Los cambios hechos en caliente con  :set  se guardan en autoconfig.yml
config.load_autoconfig()

# ── Aspecto (a juego con i3 / alacritty) ────────────────────────────
c.fonts.default_family = "JetBrainsMono Nerd Font"
c.fonts.default_size = "10pt"
c.colors.webpage.preferred_color_scheme = "dark"   # pide tema oscuro a las webs
c.tabs.show = "multiple"                            # oculta la barra si hay 1 pestaña

# ── Buscadores ──────────────────────────────────────────────────────
c.url.default_page = "about:blank"
c.url.start_pages = ["about:blank"]
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "g":  "https://www.google.com/search?q={}",
    "gh": "https://github.com/search?q={}&type=repositories",
}

# ── DNS / red ───────────────────────────────────────────────────────
# qutebrowser usa el resolver del SISTEMA. NetworkManager apunta a tu
# RPi 10.0.5.10 (AdGuard), que ya filtra anuncios y resuelve *.danilocloud.me.
# NO activamos DNS-over-HTTPS para no saltarnos ese filtrado.
c.content.dns_prefetch = False

# Bloqueo cosmético extra (opcional). Para activarlo:
#   sudo apt install python3-adblock   y descomenta la línea:
# c.content.blocking.method = "both"

# ── Descargas ───────────────────────────────────────────────────────
c.downloads.location.directory = "~/Downloads"
c.confirm_quit = ["downloads"]

# Nota: al pasar a Sway, qutebrowser detecta Wayland solo (sin config extra).
