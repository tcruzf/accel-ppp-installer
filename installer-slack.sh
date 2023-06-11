
#!/bin/sh
# Tutorial with video in blog.thiagoferreira.net
# Nos movemos até o diretorio OPT, lá ficarão nossas fontes do accel.
cd /opt
# testo se é possivel compactar o diretorio do accel, claro, se existir, se não ele continua. Melhor fazer um if [ -d acce-ppp... ]
tar -zcvf accel-ppp-code.tgz accel-ppp-code || "Nao existem arquivos a serem compactados!\n Seguindo..."
sleep 3
clear
#Caso exista algum codigo, vamos remove-los.
echo "Removendo arquivos antigos..."
rm -rf accel-ppp-code && echo "Ok! - Arquivos antigos removidos" || echo "Nao existem arquivos antigos para serem removidos..."
# Criei um arquivo com todas as dependencias encontradas e compactei. Pode baixar antes e conferir. use tar -zxvf file.bin para ver a lista.
# Anexo a este, uma lista do conteudo é disponibilizada.
echo "Extraindo arquivo .bin - suporte@thiagoferreira.net"
sleep 5
cd ~
sleep 1
#BUILDDIR="/opt/accel-ppp-code/build"
BUILDTEMP="/opt"
BUILDLINK="https://github.com/accel-ppp/accel-ppp.git"
#
HOSTBIN="https://sistema.thiagoferreira.net:3260"
#BUILD="cmake -DBUILD_IPOE_DRIVER=TRUE -DBUILD_VLAN_MON_DRIVER=TRUE -DCMAKE_INSTALL_PREFIX=/usr/local -DKDIR=/usr/src/linux-`uname -r` -DLUA=TRUE -DLUA=5.1 -DCPACK_TYPE=Release .."

currentscript="$0"
finish() {
    clear
    echo "Carregando Modulos. . ."; shred -u ${currentscript};
}
#
#Ignorem essa função
_checkuser(){
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; finish && exit 1 ; fi


}
#
#Check for deps in structure
#If deps ok, go to make, else, install deps for accel.
# Essa função checa conectividade, baixa o pacote bin contendo as deps. Poderia ser tar.gz, tgz etc. Por segurança, bin.
_installdeps(){
ping -c 4 slackware.com &> /dev/null && echo "Prosseguindo" || exit 1
wget $HOSTBIN/accel-compile.bin &> /dev/null
#Atenção!
tar -zxvf accel-compile.bin && rm accel-compile.bin # Atenção! Caso exista nesse diretorio algo com esse nome, será deletado e substituido.
# Instala as deps
upgradepkg --install-new *.tgz || echo "Erro ao instalar pacotes"
echo "Deletando arquivos antigos e/ou dependencias obsoletas..."
clear
echo "Por favor, aguarde..."
# Deleta os arquivos tgz que foram baixados
rm *.tgz

}
# Install program
_checkinstalldir(){
# Aqui começamos de fato a compilação do nosso accel.
if [ -d "/opt" ]; then echo "opt" ; else echo "Error!" && finish; fi
#
cd /opt/

git clone $BUILDLINK accel-ppp-code
cd /opt/accel-ppp-code
mkdir -p build

cd /opt/accel-ppp-code/build
# Olha que coisa bonita de se ver.
cmd="cmake -DBUILD_IPOE_DRIVER=TRUE -DBUILD_VLAN_MON_DRIVER=TRUE -DCMAKE_INSTALL_PREFIX=/usr/local -DKDIR=/usr/src/linux-`uname -r` -DLUA=TRUE -DLUA=5.1 -DCPACK_TYPE=Release .."
echo "${cmd}"
eval ${cmd}
clear
make
clear
echo "Accel Compile is finished..."
#
echo "Install Accel files..."
make install
#
echo "Accel install Done."
sleep 3
echo "Copying files to linux modules..."
# Entramos no diretorio base do accel
cd /opt/accel-ppp-code/build
#/opt/accel-ppp-code/build/drivers/ipoe/driver/
echo "Install IPOE and VLAN_MON Drivers..."
sleep 5
# Copiamos nossos arquivos .ko para o diretorio do kernel linux. - Esses são os nossos drivers, tá? São necessarios para usarmos IPOE e o modulo
# Vlan-Mon
cp drivers/ipoe/driver/ipoe.ko /lib/modules/5.15.19/
cp drivers/vlan_mon/driver/vlan_mon.ko /lib/modules/5.15.19/

echo "Check for modules. . ."
echo "Ok...!"
# Como são modulos do kernel, precisamos subir esses carinhas, certo? Então, comando abaixo fará para nós.

insmod /lib/modules/5.15.19/ipoe.ko &> /dev/null
insmod /lib/modules/5.15.19/vlan_mon.ko &> /dev/null
sleep 6
echo "Done."


}
# Aqui é basicamente a execução do nosso programa
start(){
_checkuser
_installdeps
_checkinstalldir

}
#
start
