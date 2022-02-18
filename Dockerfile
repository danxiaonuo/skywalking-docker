#############################
#     构建基础镜像          #
#############################
# 
# 指定创建的基础镜像
FROM alpine:latest AS builder

# 作者描述信息
MAINTAINER danxiaonuo
# 时区设置
ARG TZ=Asia/Shanghai
ENV TZ=$TZ
# 语言设置
ARG LANG=C.UTF-8
ENV LANG=$LANG
# 依赖包
ARG PKG_DEPS="\
      curl \
      wget \
      zip \
      unzip"
ENV PKG_DEPS=$PKG_DEPS
# skywalking版本号
ARG SKYWALKING_VERSION=8.9.0
ENV SKYWALKING_VERSION=$SKYWALKING_VERSION


# ***** 安装依赖 *****
RUN set -eux && \
   # 修改源地址
   sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
   # 更新源地址并更新系统软件
   apk update && apk upgrade && \
   # 安装依赖包
   apk add --no-cache --clean-protected $PKG_DEPS && \
   wget --no-check-certificate https://archive.apache.org/dist/skywalking/java-agent/${SKYWALKING_VERSION}/apache-skywalking-java-agent-${SKYWALKING_VERSION}.tgz \
   -O /tmp/apache-skywalking-java-agent-${SKYWALKING_VERSION}.tgz && \
   cd /tmp && tar zxvf apache-skywalking-java-agent-${SKYWALKING_VERSION}.tgz && \ 
   rm -rf /var/cache/apk/*

##########################################
#         构建基础镜像                    #
##########################################
# 
# 指定创建的基础镜像
FROM alpine:latest

# 作者描述信息
MAINTAINER danxiaonuo
# 时区设置
ARG TZ=Asia/Shanghai
ENV TZ=$TZ
# 语言设置
ARG LANG=C.UTF-8
ENV LANG=$LANG

ARG PKG_DEPS="\
      zsh \
      bash \
      bind-tools \
      iproute2 \
      git \
      vim \
      tzdata \
      curl \
      wget \
      lsof \
      zip \
      unzip \
      ca-certificates"
ENV PKG_DEPS=$PKG_DEPS

# ***** 安装依赖 *****
RUN set -eux && \
   # 修改源地址
   sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
   # 更新源地址并更新系统软件
   apk update && apk upgrade && \
   # 安装依赖包
   apk add --no-cache --clean-protected $PKG_DEPS && \
   rm -rf /var/cache/apk/* && \
   # 更新时区
   ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
   # 更新时间
   echo ${TZ} > /etc/timezone && \
   # 更改为zsh
   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true && \
   sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd && \
   sed -i -e 's/mouse=/mouse-=/g' /usr/share/vim/vim*/defaults.vim && \
   /bin/zsh

# ***** 工作目录 *****
WORKDIR /usr/skywalking/agent

# 拷贝文件
COPY --from=builder ["/tmp/skywalking-agent/", "/usr/skywalking/agent/"]
COPY ["conf/skywalking/agent.config", "/usr/skywalking/agent/config/agent.config"]
