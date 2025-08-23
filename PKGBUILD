# Maintainer: William C. Canin <william.costa.canin@gmail.com>

pkgname=firewall
pkgver=0.3.1
pkgrel=1
pkgdesc='Sample Firewall using Iptables.'
arch=('any')
url='https://github.com/williamcanin/firewall-archlinux.git'
license=('MIT')
depends=('iptables' 'systemd' 'kmod' 'tar')
backup=('etc/firewall/config.conf'
        'etc/firewall/rules.fw')  # ← Protege os arquivos da desinstalação
source=('firewall.sh'
        'firewall.service'
        'firewall.tar.gz'
        'firewall.install')
sha512sums=('SKIP' 'SKIP' 'SKIP' 'SKIP')

package() {
  # Script principal
  install -Dm 700 "${srcdir}"/firewall.sh "${pkgdir}"/usr/bin/firewall

  # Service file
  install -Dm 644 "${srcdir}"/firewall.service -t "${pkgdir}"/usr/lib/systemd/system

  # Criar o diretório /etc primeiro
  install -d "${pkgdir}"/etc

  # Extrair a pasta firewall para /etc
  # Compact with: tar -czf firewall.tar.gz firewall/
  tar -xzf "${srcdir}"/firewall.tar.gz -C "${pkgdir}"/etc/
  
  # Ajustar permissões
  chmod -R 755 "${pkgdir}"/etc/firewall
  chmod 644 "${pkgdir}"/etc/firewall/*
}
