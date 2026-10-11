#!/system/bin/sh
MODDIR=${0%/*}

# Aguardar inicialização completa do boot
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

# Pausa breve para o thermal-engine e governors estabilizarem
sleep 5

# Aplicar o perfil salvo
sh "$MODDIR/set_profile.sh"
