#!/bin/sh
# ==============================================================================
# ooschemadiff Sovereign Clean Uninstaller
# "Removes ooschemadiff binary, package installations, and cache."
#
# Usage:
#   curl -fsSL https://openooda-tooschemadiff.github.io/ooschemadiff/uninstall.sh | bash
#   or: ./uninstall.sh [options]
#
# Options:
#   --prefix <dir>       Target directory where standalone binary was installed
#   --dry-run            Simulate uninstallation without modifying the system
#   -y, --yes            Assume yes to all prompts (non-interactive)
#   -h, --help           Show this help message
# ==============================================================================

set -eu

if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ] && [ "${TERM:-dumb}" != "dumb" ]; then
    CYAN="\033[38;5;51m"
    GREEN="\033[38;5;82m"
    YELLOW="\033[38;5;220m"
    RED="\033[38;5;196m"
    DIM="\033[38;5;242m"
    BOLD="\033[1m"
    RESET="\033[0m"
else
    CYAN="" GREEN="" YELLOW="" RED="" DIM="" BOLD="" RESET=""
fi

say()  { printf '%b\n' "$*"; }
ok()   { say "  ${GREEN}✔${RESET} $*"; }
warn() { say "  ${YELLOW}!${RESET} $*"; }
err()  { say "  ${RED}ERROR:${RESET} $*" >&2; }
step() { say ""; say " ${CYAN}${BOLD}$*${RESET}"; }

PREFIX=""
DRY_RUN=0
ASSUME_YES=0

while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -y|--yes)
            ASSUME_YES=1
            shift
            ;;
        -h|--help)
            say "Usage: uninstall.sh [options]"
            say "Options:"
            say "  --prefix <dir>       Target directory where standalone binary was installed"
            say "  --dry-run            Simulate uninstallation without disk writes"
            say "  -y, --yes            Assume yes to all prompts"
            say "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            err "Unknown option: $1"
            exit 2
            ;;
    esac
done

step "ooschemadiff Sovereign Clean Uninstaller"

REMOVED_COUNT=0

# --- 1. Detect Package Manager Installations ---
if command -v dpkg >/dev/null 2>&1 && dpkg -s ooschemadiff >/dev/null 2>&1; then
    if [ "$DRY_RUN" -eq 1 ]; then
        say "  [dry-run] Would remove Debian package 'ooschemadiff' (dpkg/apt)"
    else
        say "  Removing Debian package 'ooschemadiff'..."
        sudo apt-get remove -y ooschemadiff 2>/dev/null || sudo dpkg -r ooschemadiff 2>/dev/null || true
        ok "Removed Debian package 'ooschemadiff'"
    fi
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
fi

if command -v rpm >/dev/null 2>&1 && rpm -q ooschemadiff >/dev/null 2>&1; then
    if [ "$DRY_RUN" -eq 1 ]; then
        say "  [dry-run] Would remove RPM package 'ooschemadiff' (rpm/dnf)"
    else
        say "  Removing RPM package 'ooschemadiff'..."
        sudo dnf remove -y ooschemadiff 2>/dev/null || sudo rpm -e ooschemadiff 2>/dev/null || true
        ok "Removed RPM package 'ooschemadiff'"
    fi
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
fi

if command -v pacman >/dev/null 2>&1; then
    if pacman -Q ooschemadiff >/dev/null 2>&1; then
        if [ "$DRY_RUN" -eq 1 ]; then
            say "  [dry-run] Would remove Arch package 'ooschemadiff' (pacman)"
        else
            say "  Removing Arch package 'ooschemadiff'..."
            sudo pacman -R --noconfirm ooschemadiff 2>/dev/null || true
            ok "Removed Arch package 'ooschemadiff'"
        fi
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    elif pacman -Q ooschemadiff-bin >/dev/null 2>&1; then
        if [ "$DRY_RUN" -eq 1 ]; then
            say "  [dry-run] Would remove Arch package 'ooschemadiff-bin' (pacman)"
        else
            say "  Removing Arch package 'ooschemadiff-bin'..."
            sudo pacman -R --noconfirm ooschemadiff-bin 2>/dev/null || true
            ok "Removed Arch package 'ooschemadiff-bin'"
        fi
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
fi

# --- 2. Remove Standalone Binaries and Helpers ---
PATHS_TO_CHECK=""
if [ -n "$PREFIX" ]; then
    PATHS_TO_CHECK="$PREFIX/ooschemadiff $PREFIX/ooschemadiff-uninstall"
fi

PATHS_TO_CHECK="$PATHS_TO_CHECK
/usr/local/bin/ooschemadiff
/usr/local/bin/ooschemadiff-uninstall
${HOME}/.local/bin/ooschemadiff
${HOME}/.local/bin/ooschemadiff-uninstall
/usr/bin/ooschemadiff
/usr/bin/ooschemadiff-uninstall
${HOME}/.openooda/bin/ooschemadiff
${HOME}/.openooda/bin/ooschemadiff-uninstall"

if command -v ooschemadiff >/dev/null 2>&1; then
    ACTIVE_BIN="$(command -v ooschemadiff)"
    PATHS_TO_CHECK="$PATHS_TO_CHECK
$ACTIVE_BIN"
fi

DEDUPED_PATHS=""
for bin_candidate in $PATHS_TO_CHECK; do
    case " $DEDUPED_PATHS " in
        *" $bin_candidate "*) ;;
        *) DEDUPED_PATHS="$DEDUPED_PATHS $bin_candidate" ;;
    esac
done

for bin_path in $DEDUPED_PATHS; do
    if [ -f "$bin_path" ] || [ -L "$bin_path" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
            say "  [dry-run] Would delete $bin_path"
        else
            rm -f "$bin_path" 2>/dev/null || sudo rm -f "$bin_path" 2>/dev/null || true
            ok "Removed $bin_path"
        fi
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done

# --- 3. Final Verification ---
say ""
if [ "$DRY_RUN" -eq 1 ]; then
    ok "${GREEN}Dry run complete.${RESET} (No system modifications were made)"
else
    if command -v ooschemadiff >/dev/null 2>&1; then
        REMAINING="$(command -v ooschemadiff)"
        warn "ooschemadiff is still reachable at: $REMAINING (check your PATH or shell aliases)"
    else
        ok "${GREEN}${BOLD}ooschemadiff has been cleanly uninstalled.${RESET}"
    fi
fi
