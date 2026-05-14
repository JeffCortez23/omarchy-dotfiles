# 🚀 Omarchy Dotfiles & System Backup

Este repositorio contiene un respaldo integral de mi configuración de **Omarchy**, incluyendo dotfiles, scripts personalizados, aplicaciones web (PWAs) y listas de software para una restauración automática.

---

## 📂 Estructura del Respaldo

- **`config/`**: Configuraciones de Hyprland, Waybar, Walker, Kitty, etc.
- **`home/`**: Archivos del home (`.zshrc`, `.bashrc`) y scripts personalizados (`liberar_ram.sh`, etc.).
- **`desktop-entries/`**: Accesos directos para todas las Web Apps (PWAs) y aplicaciones locales.
- **`local-bin/`**: Binarios instalados en `~/.local/bin` (Gemini CLI, tools de python, etc.).
- **`scripts/`**: Listas de paquetes (Pacman, AUR, Flatpak, NPM, Pip) y URLs de temas.
- **`install.sh`**: Script maestro de instalación automática.

---

## 🛠️ Requisitos Previos

Antes de ejecutar el script en una instalación limpia de Omarchy, asegúrate de tener instalado un ayudante de AUR (como `yay`):

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

---

## 📥 Cómo Restaurar Todo

Sigue estos pasos para dejar tu laptop exactamente como estaba:

1. **Clona este repositorio:**
   ```bash
   git clone https://github.com/JeffCortez23/omarchy-dotfiles.git
   cd omarchy-dotfiles
   ```

2. **Dale permisos de ejecución al script:**
   ```bash
   chmod +x install.sh
   ```

3. **Ejecuta la restauración:**
   ```bash
   ./install.sh
   ```

---

## ⚙️ ¿Qué hace el script de instalación?

El script `install.sh` automatiza las siguientes tareas:

1.  **Instalación de Software:** Reinstala todos tus paquetes de **Pacman**, **AUR**, **Flatpak**, **NPM (Global)** y **Pip (User)**.
2.  **Configuraciones (Dotfiles):** Copia todas tus carpetas de `~/.config` para recuperar tu look & feel.
3.  **Scripts y Home:** Restaura tus scripts `.sh` y configuraciones de terminal (`zsh`, `bash`).
4.  **Binarios Locales:** Restaura las herramientas en `~/.local/bin`.
5.  **Web Apps:** Vuelve a colocar todas tus aplicaciones web (WhatsApp, ChatGPT, etc.) en tu lanzador de aplicaciones.
6.  **Temas de Omarchy:** Descarga automáticamente los repositorios de los temas que tenías instalados.

---

> **Nota:** Generado y optimizado por Gemini CLI.
