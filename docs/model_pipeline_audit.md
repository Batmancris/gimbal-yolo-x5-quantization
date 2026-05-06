# 模型链路审计报告

生成时间：2026-04-25

---

## 1. 模型流转路径总览

```
YOLOv8n PT 训练权重
        │
        ▼ (ultralytics export)
    best.onnx / bear_best.onnx          ← 浮点 ONNX，输入为 RGB NCHW
        │
        ▼ (hb_mapper checker)
    原始模型兼容性检查
        │
        ▼ (hb_mapper makertbin)
    ┌─────────────────────────────────┐
    │  量化中间产物（working_dir）      │
    │  *_original_float_model.onnx    │
    │  *_optimized_float_model.onnx   │
    │  *_calibrated_model.onnx        │
    │  *_quantized_model.onnx         │
    └─────────────────────────────────┘
        │
        ▼
    *.bin                               ← 最终部署模型（RDK X5 板端）
```

---

## 2. 当前所有模型文件

### 2.1 根目录 ONNX（输入模型）

| 文件 | 大小 | 时间 | 分类 |
|------|------|------|------|
| `bear_best.onnx` | 10.4MB | 2026-04-23 | **最终部署输入，熊检测** |
| `best.onnx` | 10.4MB | 2026-04-20 | 车辆检测，已被 bear 版本取代 |
| `shape_inference_fail.onnx` | 10.5MB | 2026-04-20 | **失败模型**，shape inference 报错，不可用 |

> `shape_inference_fail.onnx` 是 `best.onnx` 在 opset 转换过程中产生的失败副本，由 `fix_split_for_opset11.py` 处理时生成。

### 2.2 量化输出目录

#### `x5_quant_output_bear/`（最新，完整）

| 文件 | 说明 |
|------|------|
| `bear_yolov8n_x5_640_nv12.bin` | **当前最终部署模型** |
| `bear_yolov8n_x5_640_nv12_original_float_model.onnx` | 量化前原始浮点图 |
| `bear_yolov8n_x5_640_nv12_optimized_float_model.onnx` | 图优化后浮点模型 |
| `bear_yolov8n_x5_640_nv12_calibrated_model.onnx` | 校准后量化模型 |
| `bear_yolov8n_x5_640_nv12_quantized_model.onnx` | 最终量化 ONNX |
| `bear_yolov8n_x5_640_nv12_quant_info.json` | 量化信息 |
| `hb_mapper_checker_bear.log` | checker 日志 |
| `hb_mapper_makertbin_bear.log` | makertbin 日志 |
| `main_graph_subgraph_0/1.html/json` | 子图可视化 |

#### `model_output_best_640x640_bayese_nv12/`（车辆模型，完整）

| 文件 | 说明 |
|------|------|
| `best_640x640_bayese_nv12.bin` | 车辆检测部署模型 |
| `best_640x640_bayese_nv12_quant_info.json` | 量化信息 |
| `split_maxpool_into_multiples_pass_fail.onnx` | MaxPool 拆分失败的中间产物 |

#### `x5_quant_output/`（旧版车辆模型）

| 文件 | 说明 |
|------|------|
| `vehicle_yolov8n_x5_640_nv12.bin` | 旧版车辆检测部署模型 |
| `vehicle_yolov8n_x5_640_nv12_quant_info.json` | 量化信息 |
| `shape_inference_fail.onnx` | 失败模型副本 |

#### `x5_quant_output_v123/`（空目录）

v1.2.3 工具链量化尝试，**未产生任何输出**，量化失败或未执行。

#### `.hb_check/`（checker 临时输出）

| 文件 | 说明 |
|------|------|
| `checker_hybrid_horizonrt.bin` | checker 生成的测试 bin |
| `original/optimized/calibrated/quantized_model.onnx` | 完整量化中间产物 |
| `quant_info.json` | 量化信息 |

---

## 3. 模型分类

### 最终部署模型（推荐使用）

| 模型 | 路径 | 用途 |
|------|------|------|
| **bear_yolov8n_x5_640_nv12.bin** | `x5_quant_output_bear/` | 熊检测，NV12 输入，最新 |
| best_640x640_bayese_nv12.bin | `model_output_best_640x640_bayese_nv12/` | 车辆检测，NV12 输入 |

### 中间产物（量化过程文件）

- `x5_quant_output_bear/` 下的 4 个 `.onnx` 文件
- `.hb_check/` 下的所有文件

### 失败/废弃模型

| 文件 | 原因 |
|------|------|
| `shape_inference_fail.onnx` | shape inference 失败，opset 不兼容 |
| `model_output_best_640x640_bayese_nv12/split_maxpool_into_multiples_pass_fail.onnx` | MaxPool 拆分 pass 失败 |
| `x5_quant_output_v123/`（空） | v1.2.3 工具链量化失败，无输出 |

---

## 4. 当前最可能在用的模型

**`x5_quant_output_bear/bear_yolov8n_x5_640_nv12.bin`**

- 来源：`bear_best.onnx`（2026-04-23，最新）
- 量化时间：2026-04-23 14:13
- 工具链：horizon_tc_ui 1.24.3 / hbdk 3.49.15（v1.2.8）
- 输入：NV12，640×640，pyramid 输入源
- 量化日志显示：`Convert to runtime bin file successfully!`
- 所有量化中间产物完整，是唯一一个完整成功的量化链路
