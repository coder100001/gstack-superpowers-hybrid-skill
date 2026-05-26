# 契约摘要模板

> 进入下一阶段时，仅保留以下字段，释放前序上下文。
> 本模板定义"最小保留集合"，确保关键信息不丢失。

## 必需字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `goal` | string | 任务目标 | "添加用户登录功能" |
| `boundary` | string[] | 边界约束 | ["不改动数据库 schema", "保持向后兼容"] |
| `risks` | string[] | 已识别风险 | ["安全风险: 密码存储", "性能影响: 查询优化"] |
| `acceptance` | string[] | 验收标准 | ["登录成功返回 token", "错误提示正确显示"] |
| `frozen` | string[] | 冻结项 | ["ADR-001", "api-spec.yaml", "domain-boundaries.md"] |

## 输出格式

```yaml
contract_summary:
  goal: "添加用户登录功能"
  boundary:
    - "不改动数据库 schema"
    - "保持向后兼容"
  risks:
    - "安全风险: 密码存储"
    - "性能影响: 查询优化"
  acceptance:
    - "登录成功返回 token"
    - "错误提示正确显示"
  frozen:
    - "ADR-001"
    - "api-spec.yaml"
    - "domain-boundaries.md"
```

## 使用规则

1. **进入下一阶段时**：从当前上下文提取上述 5 个字段，其余释放
2. **冻结项检查**：若后续修改涉及 `frozen` 列表中的文件，触发 `decision-freeze` Gate
3. **验收映射**：`acceptance` 列表中的每项必须在 SHIP_REVIEW 阶段有对应证据

## 阶段间传递示例

### IDEA → DISCOVERY

```yaml
contract_summary:
  goal: "用户反馈系统"
  boundary: []
  risks: []
  acceptance: []
  frozen: []
```

### REQUIREMENT_LOCK → TASK_DECOMPOSITION

```yaml
contract_summary:
  goal: "用户反馈系统"
  boundary:
    - "使用现有数据库"
    - "不引入新依赖"
  risks:
    - "数据量增长风险"
  acceptance:
    - "用户可提交反馈"
    - "管理员可查看反馈列表"
  frozen:
    - "ADR-005"
```

### IMPLEMENTATION → SELF_REVIEW

```yaml
contract_summary:
  goal: "用户反馈系统"
  boundary:
    - "使用现有数据库"
    - "不引入新依赖"
  risks:
    - "数据量增长风险"
  acceptance:
    - "用户可提交反馈"
    - "管理员可查看反馈列表"
  frozen:
    - "ADR-005"
    - "api-spec.yaml"
    - "test-spec.yaml"
```

---

**版本**: v4.1  
**最后更新**: 2026-05-26
