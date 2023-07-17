#!/bin/bash

# 检查操作系统类型
check_os_type() {
    if [[ -f /etc/redhat-release ]]; then
        echo "centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        echo "debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        echo "ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        echo "centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        echo "debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        echo "ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        echo "centos"
    fi
}

# 下载并安装Go
install_go() {
    # 下载并解压Go安装包
    local go_download_link="https://golang.org"$(wget -qO- "https://golang.org/dl/" | sed -n '/class="download downloadBox"/,+1 s/.*href="\([^"]*\).*$/\1/p' | grep "linux-amd64")
    wget -N --no-check-certificate ${go_download_link}
    tar -xf go*linux-amd64.tar.gz && rm -f go*linux-amd64.tar.gz
    mv go /tmp/go

    # 设置环境变量
    export GOROOT=/tmp/go
    export GOPATH=$1
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

    # 检查Go安装是否成功
    if [[ ! -e "/tmp/go/VERSION" ]]; then
        echo "Go安装失败！"
        rm -rf "/tmp/go"
        exit 1
    fi

    # 打印Go版本信息
    echo "Go安装完成，版本：$(cat /tmp/go/VERSION)"
}

# 主函数
main() {
    local release=$(check_os_type)

    # 安装Go
    install_go "/usr/local/go"

    # 安装完成后，打印环境变量信息
    echo "GOROOT=$GOROOT"
    echo "GOPATH=$GOPATH"
    echo "PATH=$PATH"
}

# 执行主函数
main