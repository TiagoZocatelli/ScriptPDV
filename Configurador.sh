#!/bin/bash 

trap '' SIGINT
######################################################################################################################################################################################################################################/
SetarIP () {
    
        if [ -e "/etc/os-release" ]; then
        source /etc/os-release
        case $ID in
            ubuntu)
                case $VERSION_ID in
                    16.04)
                        fixo_ubuntu16
                        log "Versao Ubuntu 16 Reconhecida SetarIP"
                        ;;
                    20.04)
                        fixo_ubuntu20
                        log "Versao Ubuntu 20 Reconhecida SetarIP"
                        ;;  

                    22.04)
                        fixo_ubuntu22
                        log "Versao Ubuntu 22 Reconhecida SetarIP"
                        ;;      
                    *)
                        log "Versao do Ubuntu nao suportada: $VERSION_ID"
                        exit 1
                        ;;
                esac
                ;;
            centos)
                case $VERSION_ID in
                    7)
                        fixo_centos7
                        log "Versao Centos 7 Reconhecida SetarIP"
                        ;;
                    *)
                        log "Versao do CentOS nao suportada: $VERSION_ID"
                        exit 1
                        ;;
                esac
                ;;
            *)
                log "Distribuicao nao suportada: $ID"
                exit 1
                ;;
        esac
    else
        log "Nao foi posssivel determinar a distribuicao do sistema."
        exit 1
    fi

}
######################################################################################################################################################################################################################################/
Inicial_bkp() {
    # Diretório de backup
    backup_dir="/mnt/bkp_pdv"

    # Arquivos para backup
    files_to_backup=(
        "arqpar.dbf"
        "parame.dbf"
        "parpdv.dbf"
        "retaguarda.sh"
        "caixa.ini"
        "CliSiTef.ini"
        "cgc.ini"
    )

    # Verifica se o diretório de backup existe, se não, cria
    if [ ! -d "$backup_dir" ]; then
        dialog --msgbox "Foi criado pasta de backup em $backup_dir ..." 5 60
        mkdir -p "$backup_dir" || { dialog --msgbox "Falha ao criar o diretório de backup." 5 60; exit 1; }
    fi

    # Define o nome do arquivo de backup com a data atual
    date=$(date +"%d-%m-%Y")
    backup_file="$backup_dir/bkp_pdv_$date.tar.gz"

    # Verifica se o arquivo de backup já existe
    if [ -e "$backup_file" ]; then
        dialog --msgbox "O arquivo de $backup_file já existe. Não será feito um novo backup." 7 60
        log "já existe. Não será feito um novo backup."
        return 0
    fi

    # Mensagem de início do backup
    dialog --infobox "Fazendo backup do PDV. Por favor, aguarde..." 5 50
    sleep 3

    # Executa o backup em segundo plano
    cd /mnt/pdv || { dialog --msgbox "Falha ao acessar o diretório de origem." 5 60; exit 1; }
    tar -czf "$backup_file" "${files_to_backup[@]}" &

    # Exibe o diretório do backup
    dialog --msgbox "Backup concluído. O arquivo está em\n$backup_file" 6 55
    log "Backup concluído. O arquivo está em\n$backup_file"
}
######################################################################################################################################################################################################################################/
ip_versao_linux () {
      if [ -e "/etc/os-release" ]; then
        source /etc/os-release
        case $ID in
            ubuntu)
                case $VERSION_ID in
                    16.04)
                        setar_ip_fixo_ubuntu16
                        log "Versao Ubuntu 16 Reconhecida Utilizando Configuracao PDV BKP/Primeiro PDV"
                        ;;
                    20.04)
                        setar_ip_fixo_ubuntu20
                        log "Versao Ubuntu 20 Reconhecida Utilizando Configuracao PDV BKP/Primeiro PDV"
                        ;;  

                    22.04)
                        setar_ip_fixo_ubuntu22
                        log "Versao Ubuntu 22 Reconhecida Utilizando Configuracao PDV BKP/Primeiro PDV"
                        ;;      
                    *)
                        log "Versao do Ubuntu nao suportada: $VERSION_ID"
                        exit 1
                        ;;
                esac
                ;;
            centos)
                case $VERSION_ID in
                    7)
                        setar_ip_fixo_centos7
                        log "Versao Centos 7 Reconhecida Utilizando Configuracao PDV BKP/Primeiro PDV"
                        ;;
                    *)
                        log "Versao do CentOS nao suportada: $VERSION_ID"
                        exit 1
                        ;;
                esac
                ;;
            *)
                log "Distribuicao nao suportada: $ID"
                exit 1
                ;;
        esac
    else
        log "Nao foi posssivel determinar a distribuicao do sistema."
        exit 1
    fi
}
######################################################################################################################################################################################################################################/
fixo_ubuntu22() {
    # Diretório onde está localizado o arquivo de configuração do Netplan
    NETPLAN_DIR="/etc/netplan"
    NETPLAN_FILE="01-netcfg.yaml.static"
    BACKUP_SUFFIX=".old"
    ip_address20=$(hostname -I | cut -d' ' -f1)

    dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }
    if [[ $? -eq 0 ]]; then

        log "Confirma definir um IP fixo Ubuntu 22 ? = SIM "

        enter_new_ip
        enter_netmask
        enter_gateway

        sudo touch "$NETPLAN_DIR/01-network-manager-all.yaml"
        sudo chmod 777 "$NETPLAN_DIR/01-network-manager-all.yaml"
        sudo cat << EOF | sudo tee "$NETPLAN_DIR/01-network-manager-all.yaml" >/dev/null
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp0s3:
            dhcp4: false
            addresses: [$NEW_IP/$NETMASK]
            gateway4: $GATEWAY
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]
    version: 2
EOF

        sudo netplan apply

        dialog --msgbox "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP" 8 80
        log "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP"
    else
        log "Confirma definir um IP fixo? = NAO "
        exit 0
    fi
}
######################################################################################################################################################################################################################################/
setar_ip_fixo_ubuntu22() {
    # Diretório onde está localizado o arquivo de configuração do Netplan
    NETPLAN_DIR="/etc/netplan"
    NETPLAN_FILE="01-netcfg.yaml.static"
    BACKUP_SUFFIX=".old"
    ip_address20=$(hostname -I | cut -d' ' -f1)

    dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }
    if [[ $? -eq 0 ]]; then

        log "Confirma definir um IP fixo Ubuntu 22 Configuracao PDV BKP/Primeiro PDV? = SIM "    

        enter_new_ip
        enter_netmask
        enter_gateway

        sudo touch "$NETPLAN_DIR/01-network-manager-all.yaml"
        sudo chmod 777 "$NETPLAN_DIR/01-network-manager-all.yaml"
        sudo cat << EOF | sudo tee "$NETPLAN_DIR/01-network-manager-all.yaml" >/dev/null
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp0s3:
            dhcp4: false
            addresses: [$NEW_IP/$NETMASK]
            gateway4: $GATEWAY
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]
    version: 2
EOF

        sudo netplan apply

        dialog --msgbox "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2" 8 80
        log "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2"
    else
        log "Confirma definir um IP fixo Ubuntu 22 Configuracao PDV BKP/Primeiro PDV? = NAO " 
        exit 0
    fi
}
######################################################################################################################################################################################################################################/
fixo_centos7() {
    INTERFACE="enp0s3"
    FILE_PATH="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
    BACKUP_SUFFIX=".old"
    ip_address7=$(hostname -I | cut -d' ' -f1)

    dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }
    if [[ $? -eq 0 ]]; then

        log "Confirma definir um IP fixo Centos 7 ? = SIM "      
        # Realiza backup do arquivo de configuração
        sudo cp "$FILE_PATH" "$FILE_PATH$BACKUP_SUFFIX"

        # Solicita e armazena o novo IP, máscara de rede e gateway
        enter_new_ip
        enter_netmask
        enter_gateway

        sudo nmcli connection modify Conexão\ cabeada\ 1 ipv4.method manual ipv4.address $NEW_IP/$NETMASK ipv4.gateway $GATEWAY ipv4.dns "8.8.8.8 8.8.4.4"
        nmcli connection up Conexão\ cabeada\ 1

        # Exibe o endereço IP atualizado
        dialog --msgbox "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP" 8 80
        log "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP"
    else
        log "Confirma definir um IP fixo Centos 7 ? = NAO " 
        return
    fi
}
######################################################################################################################################################################################################################################/
setar_ip_fixo_centos7() {
    INTERFACE="enp0s3"
    FILE_PATH="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
    BACKUP_SUFFIX=".old"
    ip_address7=$(hostname -I | cut -d' ' -f1)

    dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }
    if [[ $? -eq 0 ]]; then

        log "Confirma definir um IP fixo Ubuntu 22 Configuracao PDV BKP/Primeiro PDV? = SIM "    
        # Realiza backup do arquivo de configuração
        sudo cp "$FILE_PATH" "$FILE_PATH$BACKUP_SUFFIX"

        # Solicita e armazena o novo IP, máscara de rede e gateway
        enter_new_ip
        enter_netmask
        enter_gateway

        sudo nmcli connection modify Conexão\ cabeada\ 1 ipv4.method manual ipv4.address $NEW_IP/$NETMASK ipv4.gateway $GATEWAY ipv4.dns "8.8.8.8 8.8.4.4"
        nmcli connection up Conexão\ cabeada\ 1

        # Exibe o endereço IP atualizado
        dialog --msgbox "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2" 8 80
        log "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2"
    else
        log "Confirma definir um IP fixo Ubuntu 22 Configuracao PDV BKP/Primeiro PDV? = NAO " 
        return
    fi
}
######################################################################################################################################################################################################################################/
fixo_ubuntu16 () {
    # Diálogo para confirmar a configuração do IP estático
    dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }

    if [[ $? -eq 0 ]]; then

        log "Confirma definir um IP fixo Ubuntu 16 ? = SIM "    
        
        enter_new_ip
        enter_netmask_16
        enter_gateway

        # Configuração do arquivo /etc/network/interfaces
        sudo sed -i '/iface enp0s3 inet/d' /etc/network/interfaces
        sudo sed -i '/address/d' /etc/network/interfaces
        sudo sed -i '/netmask/d' /etc/network/interfaces
        sudo sed -i '/gateway/d' /etc/network/interfaces
        sudo sed -i '/dns-nameservers/d' /etc/network/interfaces

        sudo sed -i "/auto enp0s3/a iface enp0s3 inet static\naddress $NEW_IP\nnetmask $NETMASK\ngateway $GATEWAY" /etc/network/interfaces

        # Verifica se o DNS já está definido
        grep -q '^dns-nameservers' /etc/network/interfaces
        if [ $? -ne 0 ]; then
            # Se não estiver definido, adiciona o DNS padrão
            echo "dns-nameservers 8.8.8.8 8.8.4.4" | sudo tee -a /etc/network/interfaces > /dev/null
        fi

        # Reinicia a interface de rede
        sudo ip addr flush enp0s3 && sudo systemctl restart networking.service

        dialog --msgbox "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP" 8 80
        log "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP"
    else
        log log "Confirma definir um IP fixo Ubuntu 16 ? = NAO " 
        return
    fi
}
######################################################################################################################################################################################################################################/
setar_ip_fixo_ubuntu16 () {
    # Diálogo para confirmar a configuração do IP estático
    dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }

    if [[ $? -eq 0 ]]; then

        log "Confirma definir um IP fixo Ubuntu 16 Configuracao PDV BKP/Primeiro PDV? = SIM "   
        
        enter_new_ip
        enter_netmask_16
        enter_gateway

        # Configuração do arquivo /etc/network/interfaces
        sudo sed -i '/iface enp0s3 inet/d' /etc/network/interfaces
        sudo sed -i '/address/d' /etc/network/interfaces
        sudo sed -i '/netmask/d' /etc/network/interfaces
        sudo sed -i '/gateway/d' /etc/network/interfaces
        sudo sed -i '/dns-nameservers/d' /etc/network/interfaces

        sudo sed -i "/auto enp0s3/a iface enp0s3 inet static\naddress $NEW_IP\nnetmask $NETMASK\ngateway $GATEWAY" /etc/network/interfaces

        # Verifica se o DNS já está definido
        grep -q '^dns-nameservers' /etc/network/interfaces
        if [ $? -ne 0 ]; then
            # Se não estiver definido, adiciona o DNS padrão
            echo "dns-nameservers 8.8.8.8 8.8.4.4" | sudo tee -a /etc/network/interfaces > /dev/null
        fi

        # Reinicia a interface de rede
        sudo ip addr flush enp0s3 && sudo systemctl restart networking.service

        dialog --msgbox "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2" 8 80
        log "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2"
    else
        log "Confirma definir um IP fixo Ubuntu 16 Configuracao PDV BKP/Primeiro PDV? = NAO " 
        return
    fi
}
######################################################################################################################################################################################################################################/
fixo_ubuntu20 () {

    cd /etc/netplan 
    cp 01-netcfg.yaml 01-netcfg.yaml.old 

    # Diretório onde está localizado o arquivo de configuração do Netplan
    NETPLAN_DIR="/etc/netplan"
    NETPLAN_FILE="01-netcfg.yaml.static"
    BACKUP_SUFFIX=".old"
    ip_address20=$(hostname -I | cut -d' ' -f1)


if [[ -e /etc/netplan/01-netcfg.yaml.static ]]; then
     dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }
    if [[ $? -eq 0 ]]; then

    log "Confirma definir um IP fixo Ubuntu 20 ? = SIM "   

    sudo cp "$NETPLAN_DIR/$NETPLAN_FILE" "$NETPLAN_DIR/$NETPLAN_FILE$BACKUP_SUFFIX"

    enter_new_ip
    enter_netmask
    enter_gateway
   
    # Atualiza o arquivo de configuração do Netplan
    sudo sed -i "0,/addresses:/{s/addresses: \[.*\]/addresses: \[$NEW_IP\/$NETMASK\]/}" "$NETPLAN_DIR/$NETPLAN_FILE"
    sudo sed -i "s/gateway4: .*/gateway4: $GATEWAY/" "$NETPLAN_DIR/$NETPLAN_FILE"

    # Aplica as alterações de configuração
    mv /etc/netplan/01-netcfg.yaml.static  /etc/netplan/01-netcfg.yaml
    sudo netplan apply

    dialog --msgbox "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP" 8 80
     log "IP fixo configurado com sucesso! Endereco IP atual: $NEW_IP"
else
    log "Confirma definir um IP fixo Ubuntu 20 ? = NAO " 
    exit 0
fi
else
    dialog --msgbox "O arquivo 01-netcfg.yaml.static não existe. Verifique no caminho /etc/netplan." 8 80
    log "O arquivo 01-netcfg.yaml.static não existe. Verifique no caminho /etc/netplan."
    return 1
fi
}
######################################################################################################################################################################################################################################/
setar_ip_fixo_ubuntu20 () {

    cd /etc/netplan 
    cp 01-netcfg.yaml 01-netcfg.yaml.old 

    # Diretório onde está localizado o arquivo de configuração do Netplan
    NETPLAN_DIR="/etc/netplan"
    NETPLAN_FILE="01-netcfg.yaml.static"
    BACKUP_SUFFIX=".old"
    ip_address20=$(hostname -I | cut -d' ' -f1)

    dialog --yesno "Confirma definir um IP fixo?" 8 40 || { echo "Operacao cancelada pelo usuario."; return; }
    if [[ $? -eq 0 ]]; then

    log "Confirma definir um IP fixo Ubuntu 20 Configuracao PDV BKP/Primeiro PDV? = SIM "    

    sudo cp "$NETPLAN_DIR/$NETPLAN_FILE" "$NETPLAN_DIR/$NETPLAN_FILE$BACKUP_SUFFIX"

    enter_new_ip
    enter_netmask
    enter_gateway

    # Atualiza o arquivo de configuração do Netplan
    sudo sed -i "0,/addresses:/{s/addresses: \[.*\]/addresses: \[$NEW_IP\/$NETMASK\]/}" "$NETPLAN_DIR/$NETPLAN_FILE"
    sudo sed -i "s/gateway4: .*/gateway4: $GATEWAY/" "$NETPLAN_DIR/$NETPLAN_FILE"

    # Aplica as alterações de configuração
    mv /etc/netplan/01-netcfg.yaml.static  /etc/netplan/01-netcfg.yaml
    sudo netplan apply

    dialog --msgbox "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2" 8 80
    log "IP fixo e PDV configurado com sucesso! Endereco IP atual: $NEW_IP\nTKTOTAL: F1 TKDINHEIRO F2"
else
    log log "Confirma definir um IP fixo Ubuntu 20 ? = NAO " 
    exit 0
fi
}
######################################################################################################################################################################################################################################/
# Função para validar o formato do IP
validate_ip() {
    local IP=$1
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}
######################################################################################################################################################################################################################################/
# Função para validar a máscara de rede
validate_netmask() {
    local NETMASK=$1
    if [[ $NETMASK =~ ^([1-9]|[1-2][0-9]|3[0-2])$ ]]; then
        return 0
    else
        return 1
    fi
}
######################################################################################################################################################################################################################################/
# Função para validar o formato do gateway
validate_gateway() {
    local GATEWAY=$1
    if [[ $GATEWAY =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}
######################################################################################################################################################################################################################################/
enter_new_ip() {
    caminho_caixa_ini="/mnt/pdv/caixa.ini"
    numseqecf=$(grep 'numseqecf' "$caminho_caixa_ini" | awk -F'=' '{print $2}' | tr -d '[:space:]')

    CURRENT_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
    LAST_OCTET=$(echo "$CURRENT_IP" | awk -F'.' '{print $4}')

    while true; do
        NEW_IP=$(dialog --inputbox "Digite o novo IP para o Caixa: $numseqecf" 8 40 "${CURRENT_IP%.*}.$numseqecf" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operação cancelada pelo usuário.' 5 40; clear; exit 0;}

        #Verifica se o IP esta conforme o padrao e nao deixar Passar em branco 
        if [[ ! "$NEW_IP" =~ ^[0-9.]+$ ]]; then
            dialog --msgbox "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos." 8 40
            log "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos."
            continue  # Continue o loop para permitir que o usuário insira o IP novamente
        fi

        # Verificar se o IP já está em uso na rede
        ping -c 1 $NEW_IP > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            dialog --msgbox "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro." 8 40
            log "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro."
            continue
        fi

        # Validar o formato do IP
        if ! validate_ip "$NEW_IP"; then
            dialog --msgbox "IP invalido. Por favor, insira um IP valido." 8 40
            log "IP invalido. Por favor, insira um IP valido."
            continue
        fi

        break
    done
}
######################################################################################################################################################################################################################################/
# Função para exibir um diálogo para o usuário inserir a máscara de rede
enter_netmask() {
    NETMASK=$(dialog --inputbox "Digite a mascara de rede (ex: 24 para 255.255.255.0):" 8 40 "24" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; clear; exit 0;}
    if [[ $? -ne 0 ]]; then
        log "Cancelado."
        exit 0
    fi

    if ! validate_netmask "$NETMASK"; then
        dialog --msgbox "Mascara de rede invalida. Por favor, insira uma mascara de rede valida." 8 50
        log "Mascara de rede invalida. Por favor, insira uma mascara de rede valida."
        enter_netmask
    fi
}
######################################################################################################################################################################################################################################/
enter_gateway() {
    DEFAULT_GATEWAY="1"
    GATEWAY=$(dialog --inputbox "Digite o gateway:" 8 40 "${CURRENT_IP%.*}.1" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; clear; exit 0;}
    if [[ $? -ne 0 ]]; then
        log "Cancelado."
        exit 0
    fi

    # Se o usuário não inserir um valor, utiliza o padrão com o último octeto como 1
    if [[ -z "$GATEWAY" ]]; then
        GATEWAY="${CURRENT_IP%.*}.$DEFAULT_GATEWAY"
    fi

    if ! validate_gateway "$GATEWAY"; then
        dialog --msgbox "Gateway invalido. Por favor, insira um gateway valido." 8 40
        log "Gateway invalido. Por favor, insira um gateway valido."
        enter_gateway
    fi
}
######################################################################################################################################################################################################################################/
enter_netmask_16() {
    NETMASK=$(dialog --inputbox "Digite a mascara de rede (ex: 24 para 255.255.255.0):" 8 40 "255.255.255.0" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; clear; exit 0;}
    if [[ $? -ne 0 ]]; then
        log "Cancelado."
        exit 0
    fi
}
######################################################################################################################################################################################################################################/
aviso_teclado () {
dialog --msgbox "Atencao teclado numerico nao ira funcionar Executando Via Putyy !!!" 8 55
}
######################################################################################################################################################################################################################################/
# Sistema de Log do Sript
log_file="/var/log/conf_pdv.log" 
######################################################################################################################################################################################################################################/
TEF() { 
wget -N ftp://177.125.217.139/tef/autolibtef/bin/teste/autotef.l --user=util --password=util && chmod +x autotef.l && ./autotef.l
}
######################################################################################################################################################################################################################################/
log() {
    local current_date_time=$(date +'%Y-%m-%d %H:%M:%S')
    echo "[$current_date_time] $1" >> "$log_file"
}
######################################################################################################################################################################################################################################/
mostrar_alerta() {
    mensagem=$1
    COLUMNS=$(tput cols)
    tput cols 200
    dialog --msgbox "$mensagem" 10 60
    tput cols $COLUMNS
}
######################################################################################################################################################################################################################################/
Instalacao() {

    CopiaDadosDoPDV

    if [ $? -eq 1 ]; then
        return
    fi
    
    AlteraNumeroDoPdv
    RealizaInstalacaoTef
    ip_versao_linux
    FuncaoFinaliza
}
######################################################################################################################################################################################################################################/
VerificaUsoEmPDV() {

    if [ ! -e "/mnt/pdv/sfc.l" ]; then
        mostrar_alerta "Voce esta em um servidor, a instalacao nao pode continuar."
        log "Voce esta em um servidor, a instalacao nao pode continuar."
        exit 0
    fi 
}
######################################################################################################################################################################################################################################/
RealizaInstalacaoTef() {

    dialog --clear --title "Instalacao TEF" --yes-label "Sim" --no-label "Nao" --yesno "Deseja realizar a instalacao do TEF?" 5 50
    choice=$?

    if [ $choice -eq 0 ]; then
        clear
        log "Instalando o TEF"
        wget -N ftp://177.125.217.139/tef/autolibtef/bin/teste/autotef.l --user=util --password=util && chmod +x autotef.l && ./autotef.l
    else
        clear
        log "Configuracao sem o TEF foi escolhida. Continue com as demais etapas."
        mostrar_alerta "Configuracao sem o TEF foi escolhida. Continue com as demais etapas."
    fi

}
######################################################################################################################################################################################################################################/
AlteraNumeroDoPdv() {

    arquivo_ini="/mnt/pdv/caixa.ini"
    [ -f "$arquivo_ini" ] || { echo "O arquivo $arquivo_ini nao foi encontrado."; exit 1; }

    novo_numero_caixa=$(dialog --inputbox "Digite o novo numero do caixa:" 8 40 2>&1 >/dev/tty) || { log "Operacao cancelada pelo usuario."; show_menu; }

    if sed -i "s/^numseqecf =.*/numseqecf = $novo_numero_caixa/" "$arquivo_ini"; then
        log "Número do caixa alterado para: $novo_numero_caixa"
    else
        log "Falha ao alterar o numero do caixa."
        dialog --msgbox "Erro ao alterar o numero do caixa. Verifique o arquivo $arquivo_ini." 10 40
    fi
}
######################################################################################################################################################################################################################################/
FuncaoFinaliza() {
    
    mostrar_alerta "Configuracao efetuada com sucesso atualize o caixa\nTKTOTAL F1 | TKDINHEIRO F2" 

    log "Configuracao efetuada"   

    clear
}
######################################################################################################################################################################################################################################/
get_current_network() {
    current_network=$(ip route | awk '/default/ {print $3}')
    if [ -z "$current_network" ]; then
        current_network=$(ifconfig | awk '/inet (addr:)?([0-9]*\.){3}[0-9]*/ {print $2}' | cut -d':' -f2)
    fi
}
######################################################################################################################################################################################################################################/
is_valid_ip() {
    local ip=$1
    local current_network=$2

    if [[ ! $ip =~ ^$current_network ]]; then
        return 1
    fi

    if ! ping -c 1 -W 1 "$ip" >/dev/null 2>&1; then
        return 1
    fi

    return 0
}
######################################################################################################################################################################################################################################/
CopiaDadosDoPDV() {


Inicial_bkp
aviso_teclado

cd /mnt/pdv
killall sfc.l
clear

senhas=("@c3ss0" "SG515t3m45" "senha1" "sg" "\$uP04t3")
ip_address=$(hostname -I | cut -d' ' -f1)

    while true; do
        numero_ip=""
        numero_ip=$(dialog --inputbox "Digite o numero IP BKP:" 8 40 2>&1 >/dev/tty) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; }
        log "IP fornecido pelo usuario: $numero_ip"  

        if [ "$numero_ip" == "$ip_address" ]; then
            dialog --msgbox "Voce digitou o seu proprio endereco IP.\nPor favor, forneca um endereco IP diferente para realizar a operacao de backup." 8 60
            log "Voce digitou o seu proprio endereco IP.\nPor favor, forneca um endereco IP diferente para realizar a operacao de backup."
            continue
        fi

        if ! [[ "$numero_ip" =~ ^[0-9.]+$ ]]; then
            dialog --msgbox "Entrada invalida. Por favor, insira um IP valido." 10 40
            log "IP invalido fornecido pelo usuario: $numero_ip"
            continue
        fi

        if ! is_valid_ip "$numero_ip" "$current_network"; then
            dialog --msgbox "IP invalido ou fora da faixa permitida. Por favor, insira um IP valido na faixa $current_network." 10 40
            log "IP fora da faixa permitida fornecido pelo usuario: $numero_ip"
            continue
        fi

    for senha_pdv in "${senhas[@]}"; do
    if timeout 5 sshpass -p "$senha_pdv" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no "root@$numero_ip" true 2>/dev/null; then
    if sshpass -p "$senha_pdv" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no "root@$numero_ip" '[ -f "/mnt/pdv/sfc.l" ]' 2>/dev/null; then
                    break
                else
                    dialog --msgbox "Voce esta tentando conectar a um servidor onde a instalacao nao e possivel." 10 40
                    log "Falha na conexao: IP=$numero_ip, Senha=$senha_pdv"
                    continue
                fi
            fi
        done

    if [[ $senha_pdv == "${senhas[-1]}" ]]; then
            dialog --msgbox "Todas as senhas falharam para $numero_ip. Verifique os dados e tente novamente." 10 40
            log "Todas as senhas falharam para o IP=$numero_ip"
            continue
        fi
    arquivos_filtro="/tmp/arquivos_filtro_$RANDOM"
    echo "/cadfil.dbf" >> "$arquivos_filtro"
    echo "/arqpar.dbf" >> "$arquivos_filtro"
    echo "/parame.dbf" >> "$arquivos_filtro"
    echo "/parpdv.dbf" >> "$arquivos_filtro"
    echo "/retaguarda.sh" >> "$arquivos_filtro"
    echo "/caixa.ini" >> "$arquivos_filtro"
    echo "/CliSiTef.ini" >> "$arquivos_filtro"
    echo "/cgc.ini" >> "$arquivos_filtro"

    rsync_command="sshpass -p $senha_pdv rsync -avzhP --relative --files-from=$arquivos_filtro root@$numero_ip:/mnt/pdv/ ."

    output=$(eval "$rsync_command" 2>&1)
    rsync_exit_code=$?


echo "$output"

if [ $rsync_exit_code -ne 0 ]; then
    log "Alguns arquivos nao existiam ou nao foram copiados:"
    
    # Verifique se há mensagens de erro no formato "rsync: <caminho_do_arquivo>: No such file or directory"
    while IFS= read -r line; do
        if [[ $line =~ ^rsync:[[:space:]]+(.*):[[:space:]]+No[[:space:]]such[[:space:]]file[[:space:]]or[[:space:]]directory ]]; then
            arquivo_faltante="${BASH_REMATCH[1]}"
            log "Arquivo nao encontrado: $arquivo_faltante"
        fi
    done <<< "$output"

    rm "$arquivos_filtro"
fi

centos_version=$(awk -F' ' '/CentOS/{print $3}' /etc/redhat-release | cut -d'.' -f1)

if [ "$centos_version" == "6" ]; then
    if wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Executaveis/limpaparpdv_parametro_6.l --user=util --password=util && chmod 777 limpaparpdv_parametro_6.l; then
        ./limpaparpdv_parametro_6.l 28 -1
    else
        dialog --msgbox "Falha ao baixar ou executar o arquivo limpaparpdv_parametro_6.l" 10 40
        log "Falha ao baixar ou executar limpaparpdv_parametro_6.l"
    fi
else
    # Se não for CentOS 6, execute a versão padrão
    if wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Executaveis/limpaparpdv_parametro.l --user=util --password=util && chmod 777 limpaparpdv_parametro.l; then
        ./limpaparpdv_parametro.l 28 -1
    else
        dialog --msgbox "Falha ao baixar ou executar o arquivo limpaparpdv_parametro.l" 10 40
        log "Falha ao baixar ou executar limpaparpdv_parametro.l"
    fi
fi
        break
    done

}
######################################################################################################################################################################################################################################/
show_help_pdv() {
    while true; do
        choice=$(dialog --title "CONFIGURACAO PDV - Ajuda" --menu \
            "Escolha uma opcao:" 14 45 6\
            1 "Ajuda - Primeiro PDV" \
            2 "Ajuda - Configurar PDV Via BKP" \
            3 "Ajuda - Configurar Varios PDVs" \
            4 "Ajuda - TEF" \
            5 "Sair" \
            3>&1 1>&2 2>&3)

        case $choice in
            1) 
                dialog --title "Ajuda - Primeiro PDV" --msgbox \
                "Esta opcao configura um PDV do zero, sem utilizar backups. E ideal para instalacoes iniciais." 12 60
                ;;
            2) 
                dialog --title "Ajuda - Configurar PDV" --msgbox \
                "Esta opcao permite configurar um PDV utilizando backups. Facilita a replicacao de configuracoes entre PDVs." 12 60
                ;;
            3) 
                dialog --title "Ajuda - Configurar Varios PDVs" --msgbox \
                "Esta opcao configura varios PDVs utilizando um PDV de origem como referencia. Informe os IPs de destino para distribuir as configuracoees, simplificando o processo em rede." 12 60
                ;;
            4) 
                dialog --title "Ajuda - TEF" --msgbox \
                "Esta opcao contem configuracoes relacionadas a Transferencia Eletronica de Fundos (TEF)." 12 60
                ;;
            5)
                return 0
                ;;    
            *) 
                dialog --title "Opcao Invalida" --msgbox \
                "Por favor, escolha uma opcao valida." 12 60
                exit 0
                ;;
        esac
    done
}
######################################################################################################################################################################################################################################/
verificar_versao_centos() {
    centos_version=$(awk -F' ' '/CentOS/{print $3}' /etc/redhat-release | cut -d'.' -f1)
    echo "$centos_version"
}
######################################################################################################################################################################################################################################/
PrimeiroPDV() {

Inicial_bkp
aviso_teclado

# Função para validar o CGC (CNPJ)
validate_cgc() {
    if [[ ! "$1" =~ ^[0-9]{14}$ && ! "$1" == "" ]]; then
        dialog --msgbox "Campo CNPJ deve conter 14 digitos ou estar em branco." 8 40
        log "Fora do padrao CNPJ"
        return 1
    fi
    return 0
}

# Função para validar a Filial (deve conter apenas números ou estar em branco)
validate_filial() {
    if [[ ! "$1" =~ ^[0-9]*$ && ! "$1" == "" ]]; then
        dialog --msgbox "Campo Filial deve conter apenas numeros ou estar em branco." 8 40
        log "Campo Filial deve conter apenas numeros ou estar em branco."
        return 1
    fi
    return 0
}

# Função para validar a Porta Comum (deve conter apenas números ou estar em branco)
validate_portacomu() {
    if [[ ! "$1" =~ ^[0-9]*$ && ! "$1" == "" ]]; then
        dialog --msgbox "Campo portacomu deve conter apenas numeros ou estar em branco." 8 40
        log "Campo portacomu deve conter apenas numeros ou estar em branco."
        return 1
    fi
    return 0
}

# Função para validar a Retagcentr (deve ser em branco ou 'S' maiúsculo)
validate_retagcentr() {
    if [[ ! -z "$1" && ! "$1" == "S" && ! "$1" == "" ]]; then
        dialog --msgbox "Campo retagcentr deve estar em branco ou conter 'S' maiusculo." 8 40
        log  "Campo retagcentr deve estar em branco ou conter 'S' maiusculo."
        return 1
    fi
    return 0
}

# Função para validar o Usatef (deve estar em branco ou 'S' maiúsculo)
validate_usatef() {
    if [[ ! -z "$1" && ! "$1" == "S" && ! "$1" == "" ]]; then
        dialog --msgbox "Campo usatef deve estar em branco ou conter 'S' maiusculo." 8 40
        log "Campo usatef deve estar em branco ou conter 'S' maiusculo."
        return 1
    fi
    return 0
}

# Função para validar o Usapacote (deve ser 'C' ou estar em branco)
validate_usapacote() {
    if [[ ! -z "$1" && ! "$1" == "C" && ! "$1" == "" ]]; then
        dialog --msgbox "Campo usapacote deve ser 'C' ou estar em branco." 8 40
        log "Campo usapacote deve ser 'C' ou estar em branco."
        return 1
    fi
    return 0
}
# Função para validar o Tipoimpress (deve conter apenas letras ou estar em branco)
validate_tipoimpress() {
    if [[ "$1" == "W" ]]; then
        dialog --msgbox "Atençao: Apos a conclusao do script, sera necessario configurar a marca e o modelo do SAT. Execute o comando 'startx ./sfc.l -config' para iniciar a configuraçao. Duvidas sobre a Configuracao Entrar em contato com suporte SGSistemas 44 3026 2666." 10 60
        log "Atenção: Após a conclusão do script, será necessário configurar a marca e o modelo do SAT. Execute o comando 'startx ./sfc.l -config' para iniciar a configuração."
    elif [[ ! "$1" =~ ^[a-zA-Z]*$ && ! "$1" == "" ]]; then
        dialog --msgbox "Campo tipoimpress deve conter apenas letras ou estar em branco." 8 40
        log "Campo tipoimpress deve conter apenas letras ou estar em branco."
        return 1
    fi
    return 0
}

while true; do
    cgc=$(dialog --inputbox "Informe o valor para o campo CNPJ:\n'Campo GCG PARPDV'" 8 40 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; }
    [ -z "$cgc" ] && menu && break  # Se o usuário pressionar Cancelar, volte para o menu
    validate_cgc "$cgc" || continue

    filial=$(dialog --inputbox "Informe o valor para o campo Filial:\n'Campo FilialBase PARPDV'" 8 40 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; } 
    [ -z "$filial" ] && menu && break
    validate_filial "$filial" || continue

    portacomu=$(dialog --inputbox "Informe o valor para o campo portacomu:\n'Campo PortaComu PARPDV'" 8 45 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; }
    [ -z "$portacomu" ] && menu && break
    validate_portacomu "$portacomu" || continue

    retagcentr=$(dialog --inputbox "Informe o valor para o campo retagcentr:\n'S para Centralizado'" 8 45 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; } 
    [ -z "$retagcentr" ] && menu && break
    validate_retagcentr "$retagcentr" || continue

    if [ "$retagcentr" = "S" ]; then
    echo "$cgc" > /mnt/pdv/cgc.ini
    fi

    usatef=$(dialog --inputbox "Informe o valor para o campo usatef:\n'S Cliente USATEF'" 8 40 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; } 
    [ -z "$usatef" ] && menu && break
    validate_usatef "$usatef" || continue

    usapacote=$(dialog --inputbox "Informe o valor para o campo usapacote:\n'Insira letra C'" 8 45 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; } 
    [ -z "$usapacote" ] && menu && break
    validate_usapacote "$usapacote" || continue

    tipoimpres=$(dialog --inputbox "Informe o valor para o campo tipoimpress:\n'X NFCE W SAT'" 8 45 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; } 
    [ -z "$tipoimpres" ] && menu && break
    validate_tipoimpress "$tipoimpres" || continue

    if [ -z "$cgc" ] && [ -z "$filial" ] && [ -z "$portacomu" ] && [ -z "$retagcentr" ] && [ -z "$usatef" ] && [ -z "$usapacote" ] && [ -z "$tipoimpress" ]; then
    dialog --yesno "Todos os campos estao vazios. Deseja continuar?" 8 40
    resposta=$?
    log "Todos os campos estao vazios. Deseja continuar?: $resposta"

    # Se o usuário escolhe "Cancelar" (resposta igual a 1), retorne para o menu
    if [ $resposta -eq 1 ]; then
        menu
        return 1
    fi
fi

    break  # Sair do loop se todas as entradas são válidas
done

    centos_version=$(verificar_versao_centos)

    if [ "$centos_version" == "6" ]; then
        script_nome="pdv_6.l"
    else
        script_nome="pdv.l"
    fi

    # Executar o gauge
    for percent in $(seq 0 25 100); do
        echo "$percent"
        sleep 0.5
    done | dialog --gauge "Alterando Tabelas PARPDV" 8 40

    # Construir o comando com base no nome do script
    comando="./$script_nome AADD cgc=$cgc portacomu=$portacomu retagcentr=$retagcentr usatef=$usatef usapacote=$usapacote tipoimpres=$tipoimpres filialbase=$filial"

    # Baixar e executar o script correspondente
    if wget "ftp://177.125.217.139/pdv/autoconfigpdv/Script/Executaveis/$script_nome" --user=util --password=util && chmod 777 "./$script_nome"; then
        eval $comando
    else
        dialog --msgbox "Falha ao baixar ou executar o arquivo $script_nome" 10 40
        log "Falha ao baixar ou executar $script_nome"
    fi

arquivo="/mnt/pdv/retaguarda.sh"
solicitar_ip_caminho() {
while true; do
    novo_ip=$(dialog --inputbox "Digite o novo IP do Retaguarda.sh:" 8 60 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; }

    if [[ ! "$novo_ip" =~ ^[0-9a-zA-Z./]+$ ]]; then
        dialog --msgbox "O IP fornecido é inválido. Certifique-se de usar apenas números, letras, pontos e barras (/)." 8 60
        log "O IP fornecido é inválido. Certifique-se de usar apenas números, letras, pontos e barras (/)."
        continue  
    fi

    break  
done
}

# Função para solicitar confirmação e alterar usuário e senha
solicitar_usuario_senha() {
    dialog --yesno "Deseja alterar o usuário e senha do Retaguarda.sh?" 8 60
    response=$?
    if [ $response -eq 0 ]; then
        # Solicitar novo usuário
        us_re=$(dialog --inputbox "Digite o novo Usuario do Retaguarda.sh:" 8 60 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; }
        if [ -z "$us_re" ]; then
            dialog --msgbox "O usuário não pode estar vazio." 8 60
            exit 1
        fi

        # Solicitar nova senha
        pw_re=$(dialog --inputbox "Digite a Senha do Retaguarda.sh:" 8 60 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; }
        if [ -z "$pw_re" ]; then
            dialog --msgbox "A senha não pode estar vazia." 8 60
            exit 1
        fi
    fi
}

# Realizar alterações no arquivo retaguarda.sh
alterar_arquivo_retguarda() {
    if [ -e "$arquivo" ]; then
        cp "$arquivo" "$arquivo.bak"  # Fazer backup do arquivo original

        # Substituir o IP e caminho no arquivo retaguarda.sh
        if grep -q "^caminho=//" "$arquivo"; then
            sed -i "s|^caminho=//.*|caminho=//$novo_ip/$caminho|" "$arquivo"
        else
            sed -i "s|^caminho=.*|caminho=//$novo_ip/$caminho|" "$arquivo"
        fi
        # Substituir o usuário no arquivo retaguarda.sh, se fornecido
        if [ ! -z "$us_re" ]; then
            sed -i "s|^usuario=.*|usuario=$us_re|" "$arquivo"
        fi

        # Substituir a senha no arquivo retaguarda.sh, se fornecida
        if [ ! -z "$pw_re" ]; then
            sed -i "s|^senha=.*|senha=$pw_re|" "$arquivo"
        fi

        dialog --msgbox "O arquivo $arquivo foi atualizado com sucesso." 8 40
        log "O arquivo $arquivo foi atualizado com sucesso."
    else
        dialog --msgbox "O arquivo $arquivo não foi encontrado." 8 40
        log "O arquivo $arquivo não foi encontrado."
    fi
}

# Loop para solicitar IP e caminho
solicitar_ip_caminho

# Loop para solicitar confirmação de alteração de usuário e senha
while true; do
    solicitar_usuario_senha
    alterar_arquivo_retguarda
    break
done


arquivo_ini="/mnt/pdv/caixa.ini"
[ -f "$arquivo_ini" ] || { echo "O arquivo $arquivo_ini nao foi encontrado."; exit 1; }

   
while true; do
   
    novo_numero_caixa=$(dialog --inputbox "Digite o novo numero do caixa:" 8 40 --stdout) || { dialog --msgbox 'Operacao cancelada pelo usuario.' 5 40; return 1; }

    if [[ ! "$novo_numero_caixa" =~ ^[0-9]+$ ]]; then
        dialog --msgbox "O numero do caixa fornecido e invalido. Certifique-se de usar apenas numeros." 8 40
        log "O numero do caixa fornecido e invalido. Certifique-se de usar apenas numeros."
        continue
    fi

    break
done

    if sed -i "s/^numseqecf =.*/numseqecf = $novo_numero_caixa/" "$arquivo_ini"; then
        log "Numero do caixa alterado para: $novo_numero_caixa"
    else
        log "Falha ao alterar o numero do caixa."
        dialog --msgbox "Erro ao alterar o numero do caixa. Verifique o arquivo $arquivo_ini." 10 40
    fi

    centos_version=$(awk -F' ' '/CentOS/{print $3}' /etc/redhat-release | cut -d'.' -f1)

    for percent in $(seq 0 25 100); do
        echo "$percent"
        sleep 0.5
    done | dialog --gauge "Limpando Tabelas PARPDV" 8 40

    if [ "$centos_version" == "6" ]; then
        if wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Executaveis/limpaparpdv_parametro_6.l --user=util --password=util && chmod 777 limpaparpdv_parametro_6.l; then
            ./limpaparpdv_parametro_6.l 28 -1
        else
            dialog --msgbox "Falha ao baixar ou executar o arquivo limpaparpdv_parametro_6.l" 10 40
            log "Falha ao baixar ou executar limpaparpdv_parametro_6.l"
        fi
    else
        if wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Executaveis/limpaparpdv_parametro.l --user=util --password=util && chmod 777 limpaparpdv_parametro.l; then
            ./limpaparpdv_parametro.l 28 -1
        else
            dialog --msgbox "Falha ao baixar ou executar o arquivo limpaparpdv_parametro.l" 10 40
            log "Falha ao baixar ou executar limpaparpdv_parametro.l"
        fi
    fi
    
    RealizaInstalacaoTef
    ip_versao_linux
    FuncaoFinaliza

}
######################################################################################################################################################################################################################################/
EditarArquivos() {

aviso_teclado

# Usando dialog para obter IPs de destino
    while true; do
        destination_ips=$(dialog --title "IP atual: $ip_address" --inputbox "Digite os IPs dos PDVs de destino separados por espaços:" 10 50 --stdout)

        # Verificar se o usuário pressionou o botão "Cancelar"
        if [ -z "$destination_ips" ]; then
            clear
            return
        fi

        if [[ ! "$destination_ips" =~ ^[0-9.[:space:]]+$ ]]; then
            dialog --msgbox "O IP fornecido é inválido. Certifique-se de usar apenas números e pontos." 8 60
            log "O IP fornecido é inválido. Certifique-se de usar apenas números e pontos."
        else
            break
        fi
    done

if [[ -z "$destination_ips" ]]; then
    dialog --msgbox "Nenhum IP de destino fornecido. Operacao cancelada." 7 55
    log "Nenhum IP de destino fornecido. Operacao cancelada."
    return 1
fi

if [[ ! "$destination_ips" =~ ^[0-9.]+$ ]]; then
    dialog --msgbox "IPs de destino fornecidos incorretamente. Certifique-se de usar apenas numeros e pontos." 7 55
    log "IPs de destino fornecidos incorretamente. Certifique-se de usar apenas numeros e pontos."
    return 1
fi

file_name=$(dialog --inputbox "Digite o nome do arquivo a ser editado nos destinos:" 10 50 --stdout)

# Solicitando ao usuário o título e o conteúdo
title=$(dialog --inputbox "Digite o titulo a ser inserido nos arquivos (ex: [Cheques]):" 10 50 --stdout)
content=$(dialog --inputbox "Digite o conteudo a ser inserido nos arquivos:" 10 50 --stdout)

# Convertendo a string de IPs de destino em um array
read -ra destination_ips_array <<< "$destination_ips"

# Definindo outras variáveis
remote_user="root"
remote_dir="/mnt/pdv"
passwords=("SG515t3m45" "@c3ss0")  # Use as senhas apropriadas

# Loop através dos destinos
for destination_ip in "${destination_ips_array[@]}"; do
    echo "Tentando conectar ao destino $destination_ip"

    # Loop através das senhas
    for password in "${passwords[@]}"; do
        echo "Tentando com a senha: $password"

        # Adicionando o título e o conteúdo ao arquivo no destino
        if sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$remote_user@$destination_ip" "echo -e '$title\n$content' >> $remote_dir/$file_name"; then
            echo "Conteúdo adicionado em $destination_ip no arquivo $file_name com a senha $password."
            break  # Se a senha funcionar, saia do loop de senhas
        else
            echo "Erro ao adicionar conteudo em $destination_ip no arquivo $file_name com a senha $password. Tentando proxima senha..."
        fi
    done
done

dialog --msgbox "Operacao concluida." 10 40
}
######################################################################################################################################################################################################################################/
funcao_centos () {
    local selected_password="$1"
    local destination_ip="$2"
    local novo_numero_caixa="$3"
    INTERFACE="enp0s3"
    FILE_PATH="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
    BACKUP_SUFFIX=".old"
    ip_address7=$(hostname -I | cut -d' ' -f1)


        enter_new_ip_multi () {
        CURRENT_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
        LAST_OCTET=$(echo "$CURRENT_IP" | awk -F'.' '{print $4}')

        while true; do
            NEW_IP=$(dialog --inputbox "Digite o novo IP para o Caixa: $novo_numero_caixa IP: $destination_ip" 8 55 "${CURRENT_IP%.*}.$novo_numero_caixa" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operação cancelada pelo usuário.' 5 40; clear; exit 0;}

            #Verifica se o IP esta conforme o padrao e nao deixar Passar em branco 
            if [[ ! "$NEW_IP" =~ ^[0-9.]+$ ]]; then
                dialog --msgbox "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos." 8 40
                log "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos."
                continue  # Continue o loop para permitir que o usuário insira o IP novamente
            fi

            # Verificar se o IP já está em uso na rede
            ping -c 1 $NEW_IP > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                dialog --msgbox "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro." 8 40
                log "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro."
                continue
            fi

            # Validar o formato do IP
            if ! validate_ip "$NEW_IP"; then
                dialog --msgbox "IP invalido. Por favor, insira um IP valido." 8 40
                log "IP invalido. Por favor, insira um IP valido."
                continue
            fi

            break
        done

    }
        # Realiza backup do arquivo de configuração
       sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo cp $FILE_PATH $FILE_PATH$BACKUP_SUFFIX"

        # Solicita e armazena o novo IP, máscara de rede e gateway
        enter_new_ip_multi
        enter_netmask
        enter_gateway

        sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo nmcli connection modify 'Conexão cabeada 1' ipv4.method manual ipv4.address $NEW_IP/$NETMASK ipv4.gateway $GATEWAY ipv4.dns '8.8.8.8 8.8.4.4'"
        sshpass -p "$selected_password" ssh -o "LogLevel=ERROR" $remote_user@$destination_ip "nmcli connection up Conexão\ cabeada\ 1 > /dev/null 2>&1" &

        dialog --yesno "Deseja atualizar o caixa $novo_numero_caixa para $NEW_IP?" 8 40
        if [ $? -eq 0 ]; then
         sshpass -p "$selected_password" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no  -o "LogLevel=ERROR" $remote_user@$NEW_IP "cd $remote_dir; startx ./sfc.l -a > /dev/null 2>&1" &
        else
         log "Processo Atualizacao nao foi feito"
           continue
        fi

        # Exibe o endereço IP atualizado
        dialog --msgbox "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa" 10 70
        log "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa"
   
}
######################################################################################################################################################################################################################################/
funcao_16() {
    local selected_password="$1"
    local destination_ip="$2"
    local novo_numero_caixa="$3"

    enter_new_ip_multi() {
        CURRENT_IP=$(sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "ip route get 8.8.8.8 | grep -oP 'src \K\S+'")
        LAST_OCTET=$(echo "$CURRENT_IP" | awk -F'.' '{print $4}')

        while true; do
            NEW_IP=$(dialog --inputbox "Digite o novo IP para o Caixa: $novo_numero_caixa IP: $destination_ip" 8 55 "${CURRENT_IP%.*}.$novo_numero_caixa" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operação cancelada pelo usuário.' 5 40; clear; exit 0;}

            # Verificar se o IP já está em uso na rede
            sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "ping -c 1 $NEW_IP > /dev/null 2>&1"
            if [[ $? -eq 0 ]]; then
                dialog --msgbox "O IP $NEW_IP já está em uso na rede. Por favor, escolha outro." 8 40
                log "O IP $NEW_IP já está em uso na rede. Por favor, escolha outro."
                continue
            fi

            # Validar o formato do IP
            if ! validate_ip "$NEW_IP"; then
                dialog --msgbox "IP inválido. Por favor, insira um IP válido." 8 40
                log "IP inválido. Por favor, insira um IP válido."
                continue
            fi

            break
        done
    }

    enter_new_ip_multi
    enter_netmask_16
    enter_gateway

    # Configuração remota do IP, máscara de sub-rede e gateway
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i '/iface enp0s3 inet/d' /etc/network/interfaces"
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i '/address/d' /etc/network/interfaces"
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i '/netmask/d' /etc/network/interfaces"
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i '/gateway/d' /etc/network/interfaces"
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i '/dns-nameservers/d' /etc/network/interfaces"

    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i '/auto enp0s3/a iface enp0s3 inet static\naddress $NEW_IP\nnetmask $NETMASK\ngateway $GATEWAY' /etc/network/interfaces"

    # Verifica se o DNS já está definido
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "grep -q '^dns-nameservers' /etc/network/interfaces"
    if [ $? -ne 0 ]; then
        # Se não estiver definido, adiciona o DNS padrão
        sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "echo 'dns-nameservers 8.8.8.8 8.8.4.4' | sudo tee -a /etc/network/interfaces > /dev/null"
    fi

    # Reinicia a interface de rede
    sshpass -p "$selected_password" ssh -o "LogLevel=ERROR" $remote_user@$destination_ip "sudo ip addr flush enp0s3 && sudo systemctl restart networking.service"

    dialog --yesno "Deseja atualizar o caixa $novo_numero_caixa para $NEW_IP?" 8 40
    if [ $? -eq 0 ]; then
        sshpass -p "$selected_password" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no  -o "LogLevel=ERROR" $remote_user@$NEW_IP "cd $remote_dir; startx ./sfc.l -a > /dev/null 2>&1" &
    else
        log "Processo Atualizacao nao foi feito"
        continue
    fi

    dialog --msgbox "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa" 10 70
    log "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa"
    
}
######################################################################################################################################################################################################################################/
funcao_20() {
    # Definindo variáveis
    local selected_password="$1"
    local destination_ip="$2"
    local novo_numero_caixa="$3"
    local NETPLAN_DIR="/etc/netplan"
    local NETPLAN_FILE="01-netcfg.yaml.static"
    local BACKUP_SUFFIX=".old"


    enter_new_ip_multi () {
    CURRENT_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
    LAST_OCTET=$(echo "$CURRENT_IP" | awk -F'.' '{print $4}')

    while true; do
        NEW_IP=$(dialog --inputbox "Digite o novo IP para o Caixa: $novo_numero_caixa IP: $destination_ip" 8 55 "${CURRENT_IP%.*}.$novo_numero_caixa" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operação cancelada pelo usuário.' 5 40; clear; exit 0;}

        #Verifica se o IP esta conforme o padrao e nao deixar Passar em branco 
        if [[ ! "$NEW_IP" =~ ^[0-9.]+$ ]]; then
            dialog --msgbox "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos." 8 40
            log "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos."
            continue  # Continue o loop para permitir que o usuário insira o IP novamente
        fi

        # Verificar se o IP já está em uso na rede
        ping -c 1 $NEW_IP > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            dialog --msgbox "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro." 8 40
            log "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro."
            continue
        fi

        # Validar o formato do IP
        if ! validate_ip "$NEW_IP"; then
            dialog --msgbox "IP invalido. Por favor, insira um IP valido." 8 40
            log "IP invalido. Por favor, insira um IP valido."
            continue
        fi

        break
    done

}

    # Realizar cópia de backup via SSH
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo cp $NETPLAN_DIR/$NETPLAN_FILE $NETPLAN_DIR/$NETPLAN_FILE$BACKUP_SUFFIX"

    # Verificar se o arquivo de configuração do Netplan existe
    if sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" test -e "$NETPLAN_DIR/$NETPLAN_FILE"; then
      
          # Se o usuário confirmar, continuar com a configuração do IP fixo
            enter_new_ip_multi 
            enter_netmask
            enter_gateway

            # Atualizar o arquivo de configuração do Netplan via SSH
            sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i '0,/addresses:/{s/addresses: \[.*\]/addresses: \[$NEW_IP\/$NETMASK\]/}' $NETPLAN_DIR/$NETPLAN_FILE"
            sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo sed -i 's/gateway4: .*/gateway4: $GATEWAY/' $NETPLAN_DIR/$NETPLAN_FILE"

            sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo mv $NETPLAN_DIR/$NETPLAN_FILE $NETPLAN_DIR/01-netcfg.yaml"
           
            # Aplicar as alterações de configuração via SSH
           sshpass -p "$selected_password" ssh -o "LogLevel=ERROR" $remote_user@$destination_ip "sudo netplan apply > /dev/null 2>&1" &
            
           dialog --yesno "Deseja atualizar o caixa $novo_numero_caixa para $NEW_IP?" 8 40
           if [ $? -eq 0 ]; then
             sshpass -p "$selected_password" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no  -o "LogLevel=ERROR" $remote_user@$NEW_IP "cd $remote_dir; startx ./sfc.l -a > /dev/null 2>&1" &
           else
             log "Processo Atualizacao nao foi feito"
               continue
           fi


            # Exibir mensagem de sucesso
        dialog --msgbox "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa" 10 70
        log "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa"
        else
        dialog --msgbox "O arquivo $NETPLAN_FILE não existe. Verifique no caminho $NETPLAN_DIR.' 8 80"
    fi
}

######################################################################################################################################################################################################################################/
funcao_22() {
    local selected_password="$1"
    local destination_ip="$2"
    local novo_numero_caixa="$3"
    local NETPLAN_DIR="/etc/netplan"
    local NETPLAN_FILE="01-network-manager-all.yaml"


enter_new_ip_multi () {
    CURRENT_IP=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
    LAST_OCTET=$(echo "$CURRENT_IP" | awk -F'.' '{print $4}')

    while true; do
        NEW_IP=$(dialog --inputbox "Digite o novo IP para o Caixa: $novo_numero_caixa IP: $destination_ip" 8 55 "${CURRENT_IP%.*}.$novo_numero_caixa" 3>&1 1>&2 2>&3) || { dialog --msgbox 'Operação cancelada pelo usuário.' 5 40; clear; exit 0;}

        #Verifica se o IP esta conforme o padrao e nao deixar Passar em branco 
        if [[ ! "$NEW_IP" =~ ^[0-9.]+$ ]]; then
            dialog --msgbox "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos." 8 40
            log "O IP fornecido e invalido. Certifique-se de usar apenas numeros e pontos."
            continue  # Continue o loop para permitir que o usuário insira o IP novamente
        fi

        # Verificar se o IP já está em uso na rede
        ping -c 1 $NEW_IP > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            dialog --msgbox "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro." 8 40
            log "O IP $NEW_IP ja esta em uso na rede. Por favor, escolha outro."
            continue
        fi

        # Validar o formato do IP
        if ! validate_ip "$NEW_IP"; then
            dialog --msgbox "IP invalido. Por favor, insira um IP valido." 8 40
            log "IP invalido. Por favor, insira um IP valido."
            continue
        fi

        break
    done

}

    enter_new_ip_multi
    enter_netmask
    enter_gateway

    # Criar arquivo de configuração temporário
    cat << EOT > "/tmp/01-network-manager-all.yaml.tmp"
# This file is generated from information provided by
# the datasource. Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp0s3:
            dhcp4: false
            addresses: [$NEW_IP/$NETMASK]  
            gateway4: $GATEWAY
            nameservers:
                addresses: [8.8.8.8, 8.8.4.4]
    version: 2
EOT

    # Transferir arquivo de configuração temporário para o servidor remoto
    sshpass -p "$selected_password" scp "/tmp/01-network-manager-all.yaml.tmp" "$remote_user@$destination_ip:$NETPLAN_DIR/$NETPLAN_FILE.tmp"

    # Aplicar configurações de IP fixo no servidor remoto
    sshpass -p "$selected_password" ssh "$remote_user@$destination_ip" "sudo mv $NETPLAN_DIR/$NETPLAN_FILE.tmp $NETPLAN_DIR/$NETPLAN_FILE"
    sshpass -p "$selected_password" ssh -o "LogLevel=ERROR" $remote_user@$destination_ip "sudo netplan apply > /dev/null 2>&1" &

    dialog --yesno "Deseja atualizar o caixa $novo_numero_caixa para $NEW_IP?" 8 40
    if [ $? -eq 0 ]; then
        sshpass -p "$selected_password" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no  -o "LogLevel=ERROR" $remote_user@$NEW_IP "cd $remote_dir; startx ./sfc.l -a > /dev/null 2>&1" &
    else
        log "Processo Atualizacao nao foi feito"
        continue
    fi

    # Verificar se o IP foi alterado com sucesso e exibir mensagem apropriada
    if [ $? -eq 0 ]; then
        dialog --msgbox "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa" 10 70
        log "Transferência de arquivos, execução de comandos e alteração do número do caixa para $destination_ip concluídas. IP novo: $NEW_IP, Novo número do caixa: $novo_numero_caixa"
    else
        dialog --msgbox "Falha ao aplicar configurações de IP fixo para $destination_ip." 8 70
        log "Falha ao aplicar configurações de IP fixo para $destination_ip."
    fi
}
######################################################################################################################################################################################################################################/
Tabela_Multi () {
    aviso_teclado
    ip_address=$(hostname -I | cut -d' ' -f1)
    while true; do
        destination_ips=$(dialog --title "IP atual: $ip_address" --inputbox "Digite os IPs dos PDVs de destino separados por espaços:" 10 50 --stdout)

        # Verificar se o usuário pressionou o botão "Cancelar"
        if [ -z "$destination_ips" ]; then
            clear
            return
        fi

        if [[ ! "$destination_ips" =~ ^[0-9.[:space:]]+$ ]]; then
            dialog --msgbox "O IP fornecido é inválido. Certifique-se de usar apenas números e pontos." 8 60
            log "O IP fornecido é inválido. Certifique-se de usar apenas números e pontos."
        else
            break
        fi
    done
    
    IFS=' ' read -ra destination_ips_array <<< "$destination_ips"
    remote_user="root"
    remote_dir="/mnt/pdv"
    passwords=("SG515t3m45" "@c3ss0")

    # Pedir ao usuário os arquivos a serem copiados
    files_to_copy_input=$(dialog --title "Tabelas para enviar" --inputbox "Digite o nome dos arquivos que deseja enviar para todos os destinos, separados por espaços:" 10 50 --stdout) || { echo "Operação cancelada pelo usuário."; return; }
    IFS=' ' read -ra files_to_copy <<< "$files_to_copy_input"

    for destination_ip in "${destination_ips_array[@]}"; do
        password_success=false
        selected_password=""

        for password in "${passwords[@]}"; do
            log "Tentando conectar com a senha: $password"
            if sshpass -p "$password" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no $remote_user@$destination_ip "mkdir -p $remote_dir" 2>/dev/null; then
                log "Conexão bem-sucedida!"
                password_success=true
                selected_password="$password"
                break
            else
                log "Falha ao conectar com a senha: $password"
            fi
        done

        if [ "$password_success" = false ]; then
            dialog --msgbox "Falha ao conectar ao destino $destination_ip. Verifique as senhas e a configuração." 8 50
            log "Falha ao conectar ao destino $destination_ip. Verifique as senhas e a configuração."
        else
            for file in "${files_to_copy[@]}"; do
                if [ -f "/mnt/pdv/$file" ]; then
                    rsync -avz -e "sshpass -p $selected_password ssh" "/mnt/pdv/$file" "$remote_user@$destination_ip:$remote_dir"
                else
                    dialog --msgbox "O arquivo $file não foi encontrado. Verifique o nome e tente novamente." 8 50
                fi
            done
        fi
    done
}
######################################################################################################################################################################################################################################/
Multipdv() {
    aviso_teclado
    ip_address=$(hostname -I | cut -d' ' -f1)
        while true; do
        destination_ips=$(dialog --title "IP atual: $ip_address" --inputbox "Digite os IPs dos PDVs de destino separados por espaços:" 10 50 --stdout)

        # Verificar se o usuário pressionou o botão "Cancelar"
        if [ -z "$destination_ips" ]; then
            clear
            return
        fi

        if [[ ! "$destination_ips" =~ ^[0-9.[:space:]]+$ ]]; then
            dialog --msgbox "O IP fornecido é inválido. Certifique-se de usar apenas números e pontos." 8 60
            log "O IP fornecido é inválido. Certifique-se de usar apenas números e pontos."
        else
            break
        fi
    done

    IFS=' ' read -ra destination_ips_array <<< "$destination_ips"
    remote_user="root"
    remote_dir="/mnt/pdv"
    files_to_copy=("parpdv.dbf" "arqpar.dbf" "parame.dbf" "retaguarda.sh" "caixa.ini" "CliSiTef.ini" "cgc.ini")
    passwords=("SG515t3m45" "@c3ss0")

    for destination_ip in "${destination_ips_array[@]}"; do
        password_success=false
        selected_password=""

        for password in "${passwords[@]}"; do
            log "Tentando conectar com a senha: $password"
            if sshpass -p "$password" ssh -o PreferredAuthentications=password -o StrictHostKeyChecking=no $remote_user@$destination_ip "mkdir -p $remote_dir" 2>/dev/null; then
                log "Conexão bem-sucedida!"
                password_success=true
                selected_password="$password"
                break
            else
                log "Falha ao conectar com a senha: $password"
            fi
        done

        if [ "$password_success" = false ]; then
            dialog --msgbox "Falha ao conectar ao destino $destination_ip. Verifique as senhas e a configuração." 8 50
            log "Falha ao conectar ao destino $destination_ip. Verifique as senhas e a configuração."
        else
            for file in "${files_to_copy[@]}"; do
                rsync -avz -e "sshpass -p $selected_password ssh" "/mnt/pdv/$file" "$remote_user@$destination_ip:$remote_dir"
            done

            novo_numero_caixa=$(dialog --inputbox "Digite o novo número do caixa para $destination_ip:" 8 40 --stdout) || { echo "Operação cancelada pelo usuário."; exit 1; }
            sshpass -p "$selected_password" ssh $remote_user@$destination_ip "cd $remote_dir; killall sfc.l; sed -i 's|^numseqecf =.*|numseqecf = $novo_numero_caixa|' caixa.ini"

            dialog --yesno "Deseja definir um IP fixo para $destination_ip?" 8 40 || {
                # Se o usuário optar por não definir um IP fixo, ofereça a opção de atualizar o caixa
                if dialog --yesno "Deseja atualizar o caixa para $destination_ip?" 8 40; then
                    sshpass -p "$selected_password" ssh -o "LogLevel=ERROR" $remote_user@$destination_ip "cd $remote_dir;startx ./sfc.l -a > /dev/null 2>&1" &
                fi
                continue
            }


        # Se o usuário optar por definir um IP fixo, execute o código relevante aqui


            if [[ $? -eq 0 ]]; then
                linux_version=$(sshpass -p "$selected_password" ssh $remote_user@$destination_ip ' \
                if [ -e "/etc/os-release" ]; then \
                    source /etc/os-release; \
                    case $ID in \
                        ubuntu) \
                            case $VERSION_ID in \
                                16.04) \
                                    echo "Ubuntu 16"; \
                                    ;; \
                                20.04) \
                                    echo "Ubuntu 20"; \
                                    ;; \
                                22.04) \
                                    echo "Ubuntu 22"; \
                                    ;; \
                                *) \
                                    echo "Ubuntu (versão não reconhecida)"; \
                                    ;; \
                            esac; \
                            ;; \
                        centos) \
                            case $VERSION_ID in \
                                7) \
                                    echo "CentOS 7"; \
                                    ;; \
                                *) \
                                    echo "CentOS (versão não reconhecida)"; \
                                    ;; \
                            esac; \
                            ;; \
                        *) \
                            echo "Distribuição não reconhecida"; \
                            ;; \
                    esac; \
                else \
                    echo "Não foi possível determinar a distribuição do sistema."; \
                fi' 2>/dev/null)

                echo "A versão do sistema operacional remoto é: $linux_version"
                case $linux_version in
                    "Ubuntu 16")
                        funcao_16 "$selected_password" "$destination_ip" "$novo_numero_caixa"
                        ;;
                    "Ubuntu 20")
                        funcao_20 "$selected_password" "$destination_ip" "$novo_numero_caixa"
                        ;;
                    "Ubuntu 22")
                        funcao_22 "$selected_password" "$destination_ip" "$novo_numero_caixa"
                        ;;
                    "CentOS 7")
                        funcao_centos "$selected_password" "$destination_ip" "$novo_numero_caixa"
                        ;;
                    *)
                        echo "Nenhuma função correspondente para a versão do sistema operacional encontrada."
                        ;;
                esac

            fi
        fi
    done
}
######################################################################################################################################################################################################################################/
show_opcoes() {

    local os_version=""
    local ip_address=""

    # Obter o endereço IP atual
    ip_address=$(hostname -I | cut -d' ' -f1)

    # Tenta obter informações do /etc/os-release
    if [ -f "/etc/os-release" ]; then
        os_version=$(grep "^PRETTY_NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    fi

    # Se /etc/os-release não conter as informações, tenta lsb_release
    if [ -z "$os_version" ] && command -v lsb_release &> /dev/null; then
        os_version=$(lsb_release -a 2>/dev/null | grep "Description" | cut -f2)
    fi

    # Se ainda não encontrou informações, define um valor padrão
    if [ -z "$os_version" ]; then
        os_version="Versao Desconhecida"
    fi

    local title="Menu Opcoes"
    local creator="Desenvolvido por: Tiago Zocatelli"

    current_date_time=$(date +'%Y-%m-%d %H:%M:%S')


    while true; do
        choice=$(dialog --clear --backtitle "Distribuicao: $os_version" --title "$creator " --menu "IP - $ip_address\nEscolha uma opcao:" 15 45 5\
            1 "Editar Arquivos" \
            2 "Setar IP" \
            3 "Configurar Varios PDV" \
            4 "Enviar Arquivos/Tabelas" \
            5 "Voltar" \
            3>&1 1>&2 2>&3)

        case $choice in
            1) 
                EditarArquivos
                ;;
            2)
                SetarIP
                ;;
            3)
                Multipdv
                ;;
            4)    
                Tabela_Multi
                ;;    
            5) 
                return 0
                ;;
        esac
    done
}
######################################################################################################################################################################################################################################/
show_menu() {
    
    local os_version=""
    local ip_address=""

    # Obter o endereço IP atual
    ip_address=$(hostname -I | cut -d' ' -f1)
    # Tenta obter informações do /etc/os-release
    if [ -f "/etc/os-release" ]; then
        os_version=$(grep "^PRETTY_NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    fi

    # Se /etc/os-release não conter as informações, tenta lsb_release
    if [ -z "$os_version" ] && command -v lsb_release &> /dev/null; then
        os_version=$(lsb_release -a 2>/dev/null | grep "Description" | cut -f2)
    fi

    # Se ainda não encontrou informações, define um valor padrão
    if [ -z "$os_version" ]; then
        os_version="Versao Desconhecida"
    fi

    local title="Script Configuracao PDV"
    local creator="Desenvolvido por: Tiago Zocatelli"
    local version="Versao: 3.1.23"

    current_date_time=$(date +'%Y-%m-%d %H:%M:%S')

    # Adicionar o endereço IP na chamada do dialog
    dialog --clear --backtitle "Configurador PDV $version - Distribuicao: $os_version" --title "$creator " --menu "IP - $ip_address\nEscolha uma opcao:" 15 45 6\
        1 "Primeiro PDV" \
        2 "Configurar PDV Via BKP" \
        3 "TEF" \
        4 "Outras Opcoes" \
        5 "Ajuda" \
        6 "sair" \
        2>&1 >/dev/tty
}
######################################################################################################################################################################################################################################/
UBUNTU20() {
    
    if ! command -v dialog >/dev/null 2>&1; then
         wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Dependencias/dialogubuntu20.deb --user=util --password=util && chmod 777 dialogubuntu20.deb && dpkg -i dialogubuntu20.deb

    if [ $? -eq 0 ]; then
            log "dialog instalado com sucesso"
        else
            log "Erro na instalacao do dialog"
            exit 1
        fi
    fi

    if ! dpkg -l sshpass &>/dev/null; then    
        wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Dependencias/sshpassubuntu20.deb --user=util --password=util && chmod 777 sshpassubuntu20.deb && dpkg -i sshpassubuntu20.deb

    
    if [ $? -eq 0 ]; then
            log "sshpass instalado com sucesso"
        else
            log "Erro na instalacao do sshpass"
            exit 1
        fi
    fi
}
######################################################################################################################################################################################################################################/
UBUNTU16() {
    if ! command -v dialog >/dev/null 2>&1; then
        wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Dependencias/dialogubuntu16.deb --user=util --password=util && chmod 777 dialogubuntu16.deb && dpkg -i dialogubuntu16.deb

    if [ $? -eq 0 ]; then
            log "dialog instalado com sucesso"
        else
            log "Erro na instalacao do dialog"
            exit 1
        fi
    fi

    if ! dpkg -l sshpass &>/dev/null; then    
        wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Dependencias/sshpassubuntu16.deb --user=util --password=util && chmod 777 sshpassubuntu16.deb && dpkg -i sshpassubuntu16.deb

    
        if [ $? -eq 0 ]; then
            log "sshpass instalado com sucesso"
        else
            log "Erro na instalacao do sshpass"
            exit 1
        fi
    fi

}
######################################################################################################################################################################################################################################/
CENTOS7() { 
    
    if ! rpm -qR dialog &>/dev/null; then
        wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Dependencias/dialogcentos7_2.rpm --user=util --password=util && chmod 777 dialogcentos7_2.rpm && rpm -ivh dialogcentos7_2.rpm
        wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Dependencias/dialogcentos7_1.rpm --user=util --password=util && chmod 777 dialogcentos7_1.rpm && rpm -ivh dialogcentos7_1.rpm 

    if [ $? -eq 0 ]; then
            log "dialog instalado com sucesso"
        else
            log "Erro na instalacao do dialog"
            exit 1
        fi
    fi
         
    if ! rpm -qR sshpass &>/dev/null; then    
        wget ftp://177.125.217.139/pdv/autoconfigpdv/Script/Dependencias/sshpasscentos7.rpm --user=util --password=util && chmod 777 sshpasscentos7.rpm && rpm -ivh sshpasscentos7.rpm 
    
    if [ $? -eq 0 ]; then
            log "sshpass instalado com sucesso"
        else
            log "Erro na instalacao do sshpass"
            exit 1
        fi
    fi
}
######################################################################################################################################################################################################################################/
InicioDoPrograma() {

    if [ -e "/etc/os-release" ]; then
        source /etc/os-release
        case $ID in
            ubuntu)
                case $VERSION_ID in
                    16.04)
                        UBUNTU16
                        ;;
                    20.04)
                        UBUNTU20
                        ;;  

                    22.04)
                        UBUNTU20
                        ;;      
                    *)
                        log "Versao do Ubuntu nao suportada: $VERSION_ID"
                        exit 1
                        ;;
                esac
                ;;
            centos)
                case $VERSION_ID in
                    7)
                        CENTOS7
                        ;;

                    6)
                        CENTOS7
                        ;;
                    *)
                        log "Versao do CentOS nao suportada: $VERSION_ID"
                        exit 1
                        ;;
                esac
                ;;
            *)
                log "Distribuicao nao suportada: $ID"
                exit 1
                ;;
        esac
    else
        log "Nao foi possivel determinar a distribuicao do sistema."
        exit 1
    fi
######################################################################################################################################################################################################################################/
VerificaUsoEmPDV

    while true; do
        clear
        choice=$(show_menu)

        case $choice in
            1)
                PrimeiroPDV
                continue
                ;;
            2)
                Instalacao
                continue
                ;;
            3)
                TEF
                continue
                ;;
            4)  
                show_opcoes
                continue
                ;;
            5) 
                show_help_pdv
                continue
                ;;
            6)
                dialog --msgbox "Saindo do script. Ate logo!" 10 40
                clear
                exit 0
                ;;
        esac
        break
    done
}
######################################################################################################################################################################################################################################/
InicioDoPrograma









