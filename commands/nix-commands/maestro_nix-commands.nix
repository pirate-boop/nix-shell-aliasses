{ pkgs, ... }:

let
  # Импортируем отдельные модули, передавая им системный pkgs
  rebuild-wiz = import ./rebuild.nix { inherit pkgs; };
  git-wiz = import ./git-pull.nix { inherit pkgs; };
  #perms-wiz = import ./restore-perms.nix { inherit pkgs; };

  # Сам крутильщик меню (просто запускает уже собранные бинарники)
  kori-menu = pkgs.writeShellScriptBin "kori" ''
    clear
    echo "========================================="
    echo "       KORI SYSTEM CONTROL CENTER        "
    echo "========================================="
    echo "  1) NixOS Rebuild Wizard (Сборка системы)"
    echo "  2) Git Management Wizard (Стянуть/Пушнуть)"
    echo "  3) Restore Permissions Wizard (Починить права)"
    echo "  q) Выход"
    echo "========================================="
    echo ""
    read -p "Выберите категорию (1-3): " choice

    case "$choice" in
      1) kori-rebuild ;;
      2) kori-git ;;
      3) kori-perms ;;
      q|*) exit 0 ;;
    esac
  '';
in
{
  # Прокидываем в систему как независимые готовые утилиты
  environment.systemPackages = [
    rebuild-wiz
    git-wiz
    perms-wiz
    kori-menu
  ];
}
