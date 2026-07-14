{ pkgs, ... }:

let
  # Базовая неизменяемая часть команды сборки
  baseRebuild = "sudo nixos-rebuild switch --flake .#Kori-Icebook";
in
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "kori-nix-wizard" ''
      clear
      echo "========================================="
      echo "       KORI NIXOS DEPLOYMENT WIZARD      "
      echo "========================================="
      echo ""

      # Начинаем сборку финальной команды с базы
      FINAL_CMD="${baseRebuild}"

      # EVENT 1: Проверка логов ошибок
      echo "1) Нужен подробный вывод ошибок (--show-trace)?"
      echo "  1. Да"
      echo "  2. Нет"
      read -p "Выбор (1-2): " trace_choice
      if [ "$trace_choice" = "1" ]; then
          FINAL_CMD="$FINAL_CMD --show-trace"
      fi
      echo ""

      # EVENT 2: Защита оперативной памяти (Потоки компиляции)
      echo "2) Ограничить количество потоков (--max-jobs) от риска смерти памяти?"
      echo "  1. Да, жестко в 1 поток (Максимально безопасно)"
      echo "  2. Да, ввести количество вручную"
      echo "  3. Нет (Использовать дефолтную мощность)"
      read -p "Выбор (1-3): " job_choice
      if [ "$job_choice" = "1" ]; then
          FINAL_CMD="$FINAL_CMD --max-jobs 1"
      elif [ "$job_choice" = "2" ]; then
          read -p "Укажите количество jobs: " job_count
          FINAL_CMD="$FINAL_CMD --max-jobs $job_count"
      fi
      echo ""

      # EVENT 3: Сохранение логов в файл (Портативно через $HOME)
      echo "3) Дублировать вывод сборки в лог-файл?"
      echo "  1. Да, в папку Загрузки (~/Downloads)"
      echo "  2. Да, в папку Документы (~/Documents)"
      echo "  3. Нет"
      read -p "Выбор (1-3): " log_choice
      if [ "$log_choice" = "1" ]; then
          FINAL_CMD="$FINAL_CMD 2>&1 | tee \$HOME/Downloads/nixos-switch.log"
      elif [ "$log_choice" = "2" ]; then
          FINAL_CMD="$FINAL_CMD 2>&1 | tee \$HOME/Documents/nixos-switch.log"
      fi
      echo ""

      # EVENT 4: Финальный старт/стоп чек
      echo "-----------------------------------------"
      echo "Сформированная команда:"
      echo ">> $FINAL_CMD"
      echo "-----------------------------------------"
      echo "1. START (Выполнить в новой правой панели)"
      echo "2. BREAK (Отмена)"
      read -p "Действие (1-2): " final_action

      if [ "$final_action" = "1" ]; then
          echo "Запускаю правый терминал..."
          
          # Разделяем текущее окно WezTerm по вертикали. Новая панель встанет СПРАВА.
          # Запоминаем её уникальный ID в переменную RIGHT_PANE.
          RIGHT_PANE=$(wezterm cli split-pane --right --percent 50)
          
          # Отправляем сформированную команду в правое окно.
          # Добавляем в конец команду 'read', чтобы панель не закрылась мгновенно после завершения логов.
          wezterm cli send-text --pane-id "$RIGHT_PANE" "$FINAL_CMD; echo; echo '=== Сборка завершена. Нажми Enter для закрытия этой панели ==='; read"
          
          echo "Процесс сборки успешно передан в правую панель!"
      else
          echo "Сборка отменена пользователем."
          exit 0
      fi
    '')
  ];
}
