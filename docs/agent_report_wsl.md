# Agent 总结报告：WSL 模型工具链整理

生成时间：2026-04-25  
执行路径：/home/demo/tianbot_ws  
执行用户：demo

---

## 1. 当前环境状态

| 项目 | 状态 |
|------|------|
| 系统 Python | 3.12.3（不可用于量化） |
| 有效量化环境 | `.venv_oe_py310`（Python 3.10，horizon_tc_ui 1.24.3） |
| 工具链版本 | open_explorer v1.2.8（hbdk 3.49.15） |
| DDK 运行时 | `.horizon/ddk/x5_x86_64_gcc_11.4.0/`（已就位） |
| 量化入口脚本 | `run_x5_quant.sh`（存在，但默认 YAML 有问题） |
| 废弃环境 | `.venv_x5`（空壳）、`.venv_oe_py310_v123`（旧版） |

---

## 2. 模型链路是否可复现

**结论：可复现，但需要手动指定正确参数。**

| 链路 | 可复现性 | 命令 |
|------|---------|------|
| 熊检测模型量化 | ✅ 完全可复现 | `bash run_x5_quant.sh x5_quant_bear_nv12.yaml` |
| 车辆检测模型量化 | ✅ 可复现 | `bash run_x5_quant.sh x5_quant_nv12.yaml` |
| 直接运行 `bash run_x5_quant.sh`（无参数） | ❌ 失败 | 默认 YAML 的 cal 目录不存在 |

当前最终部署模型：`x5_quant_output_bear/bear_yolov8n_x5_640_nv12.bin`（2026-04-23，量化成功）

---

## 3. 最大风险点

### 风险一（高）：直接运行脚本会失败

`run_x5_quant.sh` 默认使用 `x5_quant_best_nv12.yaml`，该配置引用的 `calibration_bin_float32_nchw/` 目录不存在。无参数运行脚本会立即报错，新人无法复现量化流程。

**修复方式：** 修改 `run_x5_quant.sh` 第 5 行，将默认 YAML 改为 `x5_quant_bear_nv12.yaml`。

### 风险二（中）：3 个 YAML 配置存在失效引用

`x5_quant_best_nv12.yaml`、`x5_quant_best_rgb.yaml` 引用不存在的 `calibration_bin_float32_nchw/`；`x5_quant_nv12_fixed.yaml` 引用不存在的 `best_fixed.onnx`。这 3 个配置直接使用会报错，但根目录中没有任何标记区分有效/无效配置。

**修复方式：** 将 3 个失效 YAML 移入 `deprecated/` 子目录，或在文件名加 `_BROKEN` 后缀。

### 风险三（低）：`.venv_x5` 空壳误导 + 两套工具链版本无标记

`.venv_x5` 存在但无工具链，命名误导；两套 open_explorer 版本（v1.2.8 和 v1.2.3）共存，生成的 `.bin` 文件无版本标记，未来重新量化时无法确认使用了哪个版本。

**修复方式：** 删除 `.venv_x5`，在 `quant_info.json` 或文件名中记录工具链版本。

---

## 4. 下一步建议任务（给 Windows Codex）

### Task 1：修复 `run_x5_quant.sh` 默认配置（优先级：高）

```bash
# 将第 5 行
NV12_CFG="${ROOT_DIR}/x5_quant_best_nv12.yaml"
# 改为
NV12_CFG="${ROOT_DIR}/x5_quant_bear_nv12.yaml"
```

同时在脚本顶部添加注释，说明：
- 正确量化环境：`.venv_oe_py310`（Python 3.10，v1.2.8）
- 当前主力模型：`bear_best.onnx` → `x5_quant_output_bear/bear_yolov8n_x5_640_nv12.bin`

### Task 2：准备 calibration 数据生成脚本（优先级：中）

当前 `calibration_bear_rgb_uint8_nchw/` 的 bin 文件是手动生成的，没有对应脚本。需要编写 `prepare_calibration.py`，输入 jpg 目录，输出 uint8 NCHW bin 目录，使量化流程完全可复现。

### Task 3：整理失效 YAML 和废弃环境（优先级：低）

- 将 3 个失效 YAML 移入 `deprecated/` 或删除
- 删除 `.venv_x5`（空壳）
- 删除 `x5_quant_output_v123/`（空目录）
- 考虑删除 `horizon_x5_open_explorer_v1.2.3-py310_20240517.tar.gz`（1.37 GB，旧版）

### Task 4：验证 bear 模型在 RDK X5 板端的推理效果（优先级：高）

`bear_yolov8n_x5_640_nv12.bin` 已生成，需要：
1. 将 bin 文件 scp 到 RDK X5
2. 使用 `rdk_model_zoo-main` 中的推理脚本验证
3. 确认 NV12 输入 + pyramid 输入源配置正确

---

## 附：本次 Agent 执行摘要

- 执行时间：2026-04-25
- 扫描文件数：根目录 + 5 个量化输出目录 + 3 个 venv 工具链包
- 新建文档：6 个（见下方文件列表）
- 违反限制：无（未执行 rm/mv，未修改任何 .py/.sh/.yaml）
