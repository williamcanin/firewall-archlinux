# Simples Firewall para Arch Linux

Firewall simples.

# Requerimentos

* iptables
* systemd

# Características:

✅ Proteção contra inundação SYN

✅ Prevenção DDoS

✅ Detecção de varredura de portas

✅ Anti-spoofing

✅ Limitação avançada de taxas

✅ Proteção IPv6

✅ Encadeamento de pacotes malformados

✅ Reforço do sistema

✅ Registro detalhado

✅ Múltiplos níveis de proteção

# Instalando

1 - Faça o clone deste repositório e entre na pasta do mesmo.

2 - Compile o firewall no **Arch Linux**:

```
makepkg -fc
```

3 - Instale o firewall:

```
sudo pacman -U firewall-*.zst
```

# Configuração

Para adicionar mais regras para o firewall, abra o arquivo "*/etc/firewall/rules.fw*" e adicione suas regras **Iptables**.
> Você também pode querer editar algumas variáveis global no script de acordo com seu sistema.

O arquivo de configuração de variáveis se encontra em **/etc/firewall/config.conf**.
Abre este arquivo com privilégio de root, e edite conforme sua rede, Interface, etc, antes de usá-lo.

# Usando firewall


1 - Inicie o firewall manualmente:

```
sudo systemctl start firewall
```

2 - Iniciando o firewall durante o boot:

```
sudo systemctl enable firewall
```

3 - Parando o firewall:

```
sudo systemctl stop firewall
```

4 - Reiniciando o firewall:

```
sudo systemctl restart firewall
```

5 - Desabilitando o firewall do boot:

```
sudo systemctl disable firewall
```

6 - Editar o arquivo de configuração:

```
sudo firewall config
```

6 - Editar/Adicionar novas regras para o Firewall:

```
sudo firewall rules
```


---
(c) William C. Canin - 2025