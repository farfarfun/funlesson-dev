# Funlesson 工作区架构总览

- Owner: farfarfun
- 状态: 已上线
- 关联仓库: `funlesson`、`funlesson-api`、`funlesson-web`、`funlesson-dev`（本仓库）

## 章节目录

- 本文件：三个 app 的职责划分与依赖关系

## 仓库职责

| 仓库 | 角色 | 职责 | 不负责 |
| --- | --- | --- | --- |
| `funlesson` | 核心库 | 音视频转写、内容提炼、教案/大纲生成等领域逻辑；发布到公开 PyPI，作为依赖被安装 | 对外服务、跨仓库脚本 |
| `funlesson-api` | 后端服务 | 依赖 `funlesson`，封装成 FastAPI 服务对外提供接口；自带 CLI（`funlesson-api server start/stop/restart/run/status`）；发布到公开 PyPI | `funlesson` 里的领域逻辑 |
| `funlesson-web` | 前端 | Vue 静态资源 + 内置 Node server；除了托管静态资源，还负责把 `/api`、`/healthz` 等后端路径反向代理到 `funlesson-api`，避免浏览器跨源请求；自带 CLI；发布到私有 npm registry（`packages.aliyun.com` 的 `funnpm`） | CORS 处理（这是代理的职责，不在 `funlesson-api` 上开 CORS） |
| `funlesson-dev`（本仓库） | 编排 | 用 Git submodule 固定三者的配套版本；`scripts/init.sh`/`build.sh`/`setup.sh` 提供跨仓库的拉取、构建发布、服务生命周期入口 | 任何应用代码 |

## 依赖方向

```
funlesson-web --(反向代理 /api)--> funlesson-api --(依赖安装)--> funlesson
```

`funlesson-web` 和 `funlesson-api` 都满足 Entrypoint Contract（`server start/stop/restart/run/status` + 独立的 `install`/`publish`），`funlesson` 作为核心库被豁免——没有任何东西把它当长进程启动。

## 发布现状

- `funlesson`、`funlesson-api`：发布到公开 PyPI（`pip install funlesson` / `pip install funlesson-api`）。
- `funlesson-web`：发布到私有 npm registry `packages.aliyun.com/.../npm/funnpm/`（`package.json` 的 `publishConfig.registry` 已固定指向该地址）。

已知问题：`funbuild build` 在 `funlesson-web` 这一步调用 `pnpm publish` 时偶发泛化网络错误（非 401/403），紧接着手动重跑同一条命令两次都立刻成功——怀疑是 `funbuild` 子进程调用链路上的瞬时问题，尚未定位根因。出现该失败时，先用 `pnpm publish --no-git-checks` 手动确认包是否已经发布成功，再决定是否需要手动补齐 `funbuild` 原本会做的 git 提交/打 tag/父仓库子模块指针 bump（`push()`/`tags()`），而不是直接重跑整个 `funbuild build`。
