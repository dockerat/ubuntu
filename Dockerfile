FROM ubuntu:23.04


LABEL author="storezhang<华寅>"
LABEL email="storezhang@gmail.com"
LABEL qq="160290688"
LABEL wechat="storezhang"
LABEL description="Ubuntu基础镜像，增加中文支持以及挂载卷权限修复"



# 增加中文支持，不然命令行执行程序会报错
ENV LANG zh_CN.UTF-8
ENV TZ Asia/Shanghai

# 设置运行用户及组
ENV UMASK 022
ENV USERNAME storezhang
ENV UID 1000
ENV GID 1000

# 延迟启动
ENV DELAY 1s

ENV USER_HOME /config
VOLUME ${USER_HOME}
WORKDIR ${USER_HOME}



# 复制文件
COPY docker /



RUN set -ex \
    \
    \
    \
    # 替换国内源
    && sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/cn.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt clean -y \
    && apt update -y \
    \
    \
    \
    # 创建用户及用户组，后续所有操作都以该用户为执行者，修复在Docker中创建的文件不能被外界用户所操作
    && addgroup --gid ${GID} --system ${USERNAME} \
    && adduser --uid ${UID} --gid ${GID} --system ${USERNAME} --home ${USER_HOME} \
    \
    \
    \
    # 更新系统
    && apt update -y --fix-missing \
    && apt upgrade -y \
    \
    \
    \
    # 安装权限执行程序以及后台守护进程
    && apt install -y s6 gosu \
    && chmod +x /usr/bin/entrypoint \
    && chmod +x /usr/bin/property \
    && chmod +x /etc/s6/.s6-svscan/* \
    \
    \
    \
    # 设置中文支持，不然参数如果是中文会报参数解析不了的错误
    && apt install -y locales \
    && sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    \
    \
    \
    # 设置时区为上海
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    \
    \
    \
    # 清理镜像，减少无用包
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt autoclean



ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]
