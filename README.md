# funlesson-dev

Funlesson 联合开发仓库，通过 Git 子模块固定后端与 Web 界面的版本。面向教师备课场景：将音视频/资料转成结构化图文教案笔记。

## 项目

| 目录 | 项目 | 说明 |
| --- | --- | --- |
| `apps/funlesson` | [funlesson](https://github.com/farfarfun/funlesson) | 核心库：音视频转写、内容提炼、教案生成等核心逻辑 |
| `apps/funlesson-api` | [funlesson-api](https://github.com/farfarfun/funlesson-api) | 后端服务：封装 `funlesson`，对外提供接口 |
| `apps/funlesson-web` | [funlesson-web](https://github.com/farfarfun/funlesson-web) | Web 界面、静态资源服务与后端反向代理 |

具体的安装、配置和开发方式见各子项目 README。

## 获取代码

首次克隆时同时拉取子模块：

```bash
git clone --recurse-submodules https://github.com/farfarfun/funlesson-dev.git
cd funlesson-dev
```

已有仓库可执行：

```bash
bash scripts/init.sh
```

## 更新子模块

```bash
git submodule update --remote
git add apps/funlesson apps/funlesson-api apps/funlesson-web
```

更新后的子模块提交由当前仓库记录，需要随父仓库一起提交。

## 构建

安装并配置好 `funbuild` 后执行：

```bash
bash scripts/build.sh
```

脚本会依次构建 `funlesson`、`funlesson-api` 和 `funlesson-web`，最后执行 `funbuild push`。

## 服务生命周期

`funlesson-api`、`funlesson-web` 都自带安装后即可用的 CLI（`server start/stop/restart/run/status`）。装好之后可以直接用父仓库的调度脚本：

```bash
bash scripts/setup.sh start api      # 或 web / all
bash scripts/setup.sh status all
bash scripts/setup.sh stop all
```

`build`/`install`/`publish` 同理，`target` 可以是 `api`/`web`/`all`，也可以是具体的 `apps/<name>`（包含非 CLI 的 `funlesson` 核心库）：

```bash
bash scripts/setup.sh build all
bash scripts/setup.sh publish apps/funlesson
```
