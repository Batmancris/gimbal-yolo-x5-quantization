# 建议目标目录结构

生成时间：2026-04-25  
说明：本文档仅为建议，不执行任何文件移动操作。

---

## 建议结构

```
tianbot_ws/
│
├── models/                          # 所有模型文件统一管理
│   ├── onnx/                        # 浮点 ONNX 输入模型
│   │   ├── bear_best.onnx           # 熊检测（当前主力）
│   │   └── best.onnx                # 车辆检测
│   ├── bin/                         # 最终部署模型（上板用）
│   │   ├── bear_yolov8n_x5_640_nv12.bin
│   │   └── vehicle_yolov8n_x5_640_nv12.bin
│   └── quant_output/                # 量化中间产物（按模型名分子目录）
│       ├── bear_nv12/               # 熊模型量化产物
│       └── vehicle_nv12/            # 车辆模型量化产物
│
├── calibration/                     # 校准数据统一管理
│   ├── bear_rgb_uint8_nchw/         # 熊模型校准 bin（100张）
│   ├── vehicle_rgb_uint8_nchw/      # 车辆模型校准 bin（100张）
│   └── raw_images/                  # 原始校准图像（jpg）
│       └── bear/
│
├── configs/                         # YAML 配置文件统一管理
│   ├── bear_nv12.yaml               # 熊模型量化配置（当前主力）
│   └── vehicle_nv12.yaml            # 车辆模型量化配置
│
├── scripts/                         # 脚本统一管理
│   ├── run_quant.sh                 # 量化入口脚本
│   └── prepare_calibration.py       # 校准数据生成脚本
│
├── env/                             # 虚拟环境（只保留一个）
│   └── .venv_oe_py310/              # Python 3.10 + horizon v1.2.8
│
├── tools/                           # 工具链安装包（归档）
│   ├── open_explorer_x5/            # v1.2.8 解压目录
│   └── horizon_x5_open_explorer_v1.2.8-py310_20240926.tar.gz
│
├── .horizon/                        # DDK 运行时（保持原位，脚本依赖）
│
└── docs/                            # 文档
    ├── wsl_env_audit.md
    ├── model_pipeline_audit.md
    ├── quant_pipeline.md
    ├── wsl_risk_report.md
    ├── wsl_target_structure.md
    └── agent_report_wsl.md
```

---

## 与当前结构的主要差异

| 当前状态 | 建议状态 | 原因 |
|---------|---------|------|
| ONNX 散落在根目录 | 统一放 `models/onnx/` | 便于管理，避免与其他文件混淆 |
| `.bin` 散落在多个 `x5_quant_output_*/` | 统一放 `models/bin/` | 部署时只需看一个目录 |
| 量化中间产物与最终 bin 混在同一目录 | 分离到 `models/quant_output/` | 中间产物不上板，不应与 bin 混放 |
| 校准数据散落在根目录 | 统一放 `calibration/` | 便于管理多个模型的校准数据 |
| 6 个 YAML 散落在根目录（3 个失效） | 只保留有效配置，放 `configs/` | 消除失效配置的误用风险 |
| 3 套虚拟环境（2 个废弃） | 只保留 `.venv_oe_py310` | 消除环境混淆 |
| 两套 open_explorer 压缩包（3.65GB） | 只保留 v1.2.8 | 节省磁盘空间 |
| `shape_inference_fail.onnx` 在根目录 | 删除或归档 | 失败模型不应保留在工作目录 |

---

## 迁移优先级建议

| 优先级 | 操作 | 说明 |
|--------|------|------|
| 🔴 立即 | 在 `run_quant.sh` 中修改默认 YAML 为 `x5_quant_bear_nv12.yaml` | 当前默认配置会失败 |
| 🟠 近期 | 删除或标记 3 个失效 YAML | 避免误用 |
| 🟡 计划 | 整理目录结构（按上述建议） | 提升可维护性 |
| ⚪ 可选 | 删除 v1.2.3 相关文件（open_explorer_x5_v123、.venv_oe_py310_v123、tar.gz） | 节省约 2.7GB 磁盘 |

---

> 注意：本文档仅为建议，不执行任何文件移动或删除操作。
