#### Dockerfile 实例

```dockerfile
FROM centos:8
MAINTAINER this is tomcat
ADD jdk-8u91-linux-x64.tar.gz /usr/local
WORKDIR /usr/local
RUN mv jdk1.8.0_91 /usr/local/java
ENV JAVA_HOME /usr/local/java     ##设置环境变量
ENV JAVA_BIN /usr/local/java/bin
ENV JRE_HOME /usr/local/java/jre
ENV PATH $PATH:/usr/local/java/bin:/usr/local/java/jre/bin
ENV CLASSPATH /usr/local/java/jre/bin:/usr/local/java/lib:/usr/local/java/jre/lib/charsets.jar
ADD apache-tomcat-8.5.16.tar.gz /usr/local
WORKDIR /usr/local
RUN mv apache-tomcat-8.5.16 /usr/local/tomcat8
EXPOSE 8080
ENTRYPOINT ["/usr/local/tomcat8/bin/catalina.sh","run"]
```

构建命令：
```sh
docker build -t fc277073030/tomcat:v0.0.1 .
```

启动命令：
```sh
docker run -d -p 8080:8080 fc277073030/tomcat:v0.0.1
```
#### 名词解释
```text
FROM --指明构建的新镜像是来自于哪个基础镜像；
MAINTAINER --指明镜像维护者及其联系方式；
RUN --执行什么命令；
CMD --指定一个容器启动时要运行的命令，Dockerfile 中可以有多个 CMD 指令，但只有最后一个生效，CMD 会被 docker run 之后的参数替换；
EXPOSE --声明容器运行的服务端口；
ENV --构建镜像过程中设置环境变量；
ADD --将宿主机上的目录或者文件拷贝到镜像中（会帮你自动解压，无需额外操作）；
COPY --作用与ADD类似，但是不支持自动下载和解压；
ENTRYPOINT --指定一个容器启动时要运行的命令，用法类似于CMD，只是有由ENTRYPOINT启动的程序不会被docker run命令行指定的参数所覆盖，而且，这些命令行参数会被当作参数传递给ENTRYPOINT指定的程序；
VOLUME --容器数据卷，指定容器挂载点到宿主机自动生成的目录或者其他容器（数据保存和持久化工作，但是一般不会在 Dockerfile 中用到，更常见的还是命令 docker run 的时候指定 -v 数据卷。）；
WORKDIR --相当于cd命令，切换目录路径；
```