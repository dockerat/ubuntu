FROM ubuntu


MAINTAINER storezhang "storezhang@gmail.com"
LABEL architecture="AMD64/x86_64" version="latest" build="2021-04-12"
LABEL Description="Ubuntu基础镜像，增加中文支持以及其它。"



# 增加中文支持，不然命令行执行程序会报错
ENV LANG zh_CN.UTF-8
ENV TZ=Asia/Chongqing

# 设置运行用户及组
ENV USERNAME storezhang
ENV UID 1000
ENV GID 1000



# 复制文件
COPY docker /



RUN set -ex \
    \
    \
    \
    # 创建用户及用户组，后续所有操作都以该用户为执行者，修复在Docker中创建的文件不能被外界用户所操作
    && addgroup --gid ${GID} --system ${USERNAME} \
    && adduser --uid ${UID} --gid ${GID} --system ${USERNAME} \
    \
    \
    \
    # 安装JRE，确保可以启动应用
    && apt update -y --fix-missing \
    && apt upgrade -y \
    \
    \
    \
    # 安装守护进程，因为要Xvfb和Nuwa同时运行
    && apt install -y s6 gosu \
    && chmod +x /usr/bin/entrypoint \
    \
    \
    \
    # 设置中文支持，不然运行NSIS时会报解析不了参数的错误
    && apt install -y locales \
    && sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    \
    \
    \
    # 设置时区为重庆
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    \
    \
    \
    # 清理镜像，减少无用包
    && rm -rf /var/lib/apt/lists/* \
    && apt clean


ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]
