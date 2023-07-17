#!/bin/bash

# 打印信息函数
print_info() {
    echo -e "\e[1;32m[Info]\e[0m $1"
}

# 打印错误信息函数
print_error() {
    echo -e "\e[1;31m[Error]\e[0m $1"
}

# 检查依赖软件函数
check_dependencies() {
    if [[ $1 == "centos" ]]; then
        yum install git gcc automake autoconf libtool make -y
    else
        apt-get install git gcc automake autoconf libtool make -y
    fi
}

# 安装Go函数
install_go() {
    # 下载并解压Go安装包
    go_download_link="https://golang.org"$(wget -qO- "https://golang.org/dl/" | sed -n '/class="download downloadBox"/,+1 s/.*href="\([^"]*\).*$/\1/p' | grep "linux-amd64")
    wget -N --no-check-certificate ${go_download_link}
    tar -xf go*linux-amd64.tar.gz && rm -f go*linux-amd64.tar.gz
    mv go /tmp/go

    # 设置环境变量
    export GOROOT=/tmp/go
    export GOPATH=$1
    export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

    # 检查Go安装是否成功
    if [[ ! -e "/tmp/go/VERSION" ]]; then
        print_error "Go安装失败！"
        rm -rf "/tmp/go"
        exit 1
    fi

    # 打印Go版本信息
    print_info "Go安装完成，版本：$(cat /tmp/go/VERSION)"
}

# 主函数
main() {
    # 检查操作系统类型
    if [[ -e /etc/redhat-release ]]; then
        release="centos"
    elif [[ -e /etc/lsb-release ]]; then
        release="ubuntu"
    else
        print_error "不支持的操作系统！"
        exit 1
    fi

    # 检查依赖软件
    print_info "开始检查依赖软件！"
    check_dependencies $release

    # 创建目录
    if [[ ! -e "$1" ]]; then
        mkdir "$1"
    else
        [[ -e "$1" ]] && rm -rf "$1"
    fi

    # 进入目录
    cd "$1"

    # 检查编译环境
    print_info "开始检查编译环境！"
    if [[ ! -e "/tmp/go/VERSION" ]]; then
        print_info "开始安装编译环境！"
        install_go "$1"
    else
        export GOROOT=/tmp/go
        export GOPATH=$1
        export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
        print_info "Go已安装，版本：$(cat /tmp/go/VERSION)"
    fi
}

# 脚本入口
main "$@"