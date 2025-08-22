# Simples Firewall para Arch Linux

Firewall simples.

# Requerimentos

* iptables
* systemd
* kmod

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
sudo pacman -U firewall*.zst
```

# Configuração

Para adicionar mais regras no firewall, antes de compilar, abra o arquivo "*firewall.sh*" e adicione suas regras **Iptables** no bloco *PUT YOUR OTHER RULES HERE*.
> Você também pode querer editar algumas variáveis global no script de acordo com seu sistema.

O arquivo de configuração se encontra em **/etc/firewall.conf**.
Abre este arquivo com privilégio de root, e edite conforme sua rede, Interface, etc, antes de usá-lo.

# Usando firewall


1 - Inicie o firewall manualmente:

```
sudo systemctl start firewall.service
```

2 - Iniciando o firewall durante o boot:

```
sudo systemctl enable firewall.service
```

3 - Parando o firewall:

```
sudo systemctl stop firewall.service
```

4 - Reiniciando o firewall:

```
sudo systemctl restart firewall.service
```

5 - Desabilitando o firewall do boot:

```
sudo systemctl disable firewall.service
```