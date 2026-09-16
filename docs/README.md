# docs/

跨仓库、跨 app 的产品级文档放在这里，不进各个 `apps/<name>` 子仓库。结构遵循
`project-structure-governance` skill 的 document-bundle-standard：

```text
docs/
├── product/<feature-slug>/          # 需求
├── design/<feature-slug>/           # UI/交互设计
├── development/<feature-slug>/      # 架构、跨 app 接口约定
├── testing/<feature-slug>/          # 测试用例与报告
├── retrospective/<feature-slug>/    # 复盘
└── release/<date>-<issue-key>-<slug>/  # 发布记录
```

规则：

- 每个文档包必须以 `001-overview.md` 作为总览和目录，其余章节按 `NNN-kebab-case.md` 连续编号。
- 不在这几个生命周期目录下直接放单一大文件，必须建 `<feature-slug>` 子目录。
- `apps/<name>` 各子仓库不维护自己的 `docs/`：跨 app 的架构、发布记录等都集中记录在这里；
  只有当某个 app 本身是嵌套的 `-dev` 工作区，或者专门建了一个 `<product>-doc` 文档仓库时才例外。
- 各 app 自己的 `README.md`（用途、安装、用法）仍然放在各自仓库里，不受此规则影响。

详见 `submodule-workspace-governance` skill 的 `references/skeleton.md` 和
`project-structure-governance` skill 的 `references/document-bundle-standard.md`。
