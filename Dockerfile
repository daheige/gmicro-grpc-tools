FROM golang:1.16.12

RUN apt-get update && apt-get -y install zip unzip git vim curl make wget && apt-get clean

# go proxy
ENV GOPROXY=https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,direct

# 设置golang环境变量和安装grpc工具
RUN go env -w GO111MODULE=on; go env -w GOPROXY=$GOPROXY;go env -w CGO_ENABLED=0 && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest  && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest && \
    go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest  && \
    go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@latest && \
    go get -u github.com/go-playground/validator/v10 && \
    go install github.com/golang/mock/mockgen@latest  && \
    go install github.com/favadi/protoc-go-inject-tag@latest

# install protoc
ENV PROTOC_VER 3.20.1
ENV PROTOC_URL https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VER}/protoc-${PROTOC_VER}-linux-x86_64.zip

# 解决docker时区问题和中文乱码问题
ENV TZ=Asia/Shanghai LANG="zh_CN.UTF-8"
RUN mkdir -p /tmp/protoc && \
    cd /tmp/protoc && \
    wget $PROTOC_URL -O protoc.zip && \
    unzip protoc.zip && \
    cp /tmp/protoc/bin/protoc /usr/local/bin && \
    cp -R /tmp/protoc/include/* /usr/local/include && \
    chmod go+rx /usr/local/bin/protoc && \
    cd /tmp && rm -r /tmp/protoc && \
    mkdir -p /go/logs && mkdir /go/go-grpc && \
    echo "export LC_ALL=$LANG" >> /etc/profile && \
    echo $TZ > /etc/timezone

# nodejs version
ENV NODE_VER v16.15.0

# install nodejs and grpc tools
RUN apt-get install xz-utils && cd /usr/local/ && \
     wget https://npmmirror.com/mirrors/node/$NODE_VER/node-$NODE_VER-linux-x64.tar.xz && \
     xz -d node-$NODE_VER-linux-x64.tar.xz && \
     tar xvf node-$NODE_VER-linux-x64.tar && \
     mv node-$NODE_VER-linux-x64 nodejs && \
     ln -s /usr/local/nodejs/bin/npm /usr/bin/npm && \
     ln -s /usr/local/nodejs/bin/node /usr/bin/node && \
     chmod +x /usr/bin/npm && \
     chmod +x /usr/bin/node && \
     echo "export NODEJS_HOME=/usr/local/nodejs" >> ~/.bashrc && \
     echo 'export PATH=$NODEJS_HOME/bin:$PATH' >> ~/.bashrc && \
     npm install -g cnpm --registry=https://registry.npm.taobao.org && \
     ln -s /usr/local/nodejs/bin/cnpm /usr/bin/cnpm && \
     chmod +x /usr/bin/cnpm && \
     cnpm install npm -g && \
     cnpm install -g grpc-tools  && \
     ln -s /usr/local/nodejs/bin/grpc_tools_node_protoc /usr/bin/grpc_tools_node_protoc && \
     ln -s /usr/local/nodejs/bin/grpc_tools_node_protoc_plugin /usr/bin/grpc_tools_node_protoc_plugin && \
     chmod +x /usr/bin/grpc_tools_node_protoc && \
     chmod +x /usr/bin/grpc_tools_node_protoc_plugin && \
     cnpm install -g google-protobuf && \
     cnpm install -g grpc && \
     echo "build grpc tools success"
