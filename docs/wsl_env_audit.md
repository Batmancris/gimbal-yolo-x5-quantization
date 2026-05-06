# WSL 环境审计报告

生成时间：2026-04-25  
工作路径：/home/demo/tianbot_ws  
执行用户：demo

---

## 1. Python 环境

| 项目 | 值 |
|------|-----|
| 系统 Python | Python 3.12.3 |
| 路径 | /usr/bin/python3 |
| conda | 未安装 |
| 系统 pip 包 | 系统级（ubuntu 默认包，无 horizon 工具链） |

系统 Python 3.12 **不包含任何 horizon/hmct/hbdk 工具链包**，不可直接用于量化。

---

## 2. 虚拟环境

| 目录 | Python 版本 | 工具链包 | 状态 |
|------|------------|---------|------|
| `.venv_x5` | Python 3.12.3 | **无 horizon 包** | 空壳，未安装工具链 |
| `.venv_oe_py310` | Python 3.10 | horizon_nn-1.1.0 / hbdk-3.49.15 / horizon_tc_ui-1.24.3 | **主力量化环境（v1.2.8）** |
| `.venv_oe_py310_v123` | Python 3.10 | horizon_nn-1.0.6.1 / hbdk-3.49.9 / horizon_tc_ui-1.23.6 | 旧版环境（v1.2.3） |

**结论：** 实际可用的量化环境是 `.venv_oe_py310`，对应 open_explorer v1.2.8。

---

## 3. Horizon 工具链位置

| 路径 | 内容 |
|------|------|
| `.horizon/` | DDK 运行时库根目录 |
| `.horizon/ddk/` | DDK 库目录 |
| `.horizon/ddk/x5_x86_64_gcc_11.4.0/` | x86 仿真运行时（hb_mapper 依赖） |
| `open_explorer_x5/` | v1.2.8 安装包解压目录 |
| `open_explorer_x5_v123/` | v1.2.3 安装包解压目录 |
| `horizon_x5_open_explorer_v1.2.8-py310_20240926.tar.gz` | v1.2.8 原始压缩包（2.28GB） |
| `horizon_x5_open_explorer_v1.2.3-py310_20240517.tar.gz` | v1.2.3 原始压缩包（1.37GB） |

---

## 4. open_explorer_x5 版本

| 版本 | 目录 | venv | hbdk | horizon_nn |
|------|------|------|------|-----------|
| v1.2.8（当前主力） | `open_explorer_x5/` | `.venv_oe_py310` | 3.49.15 | 1.1.0 |
| v1.2.3（旧版备用） | `open_explorer_x5_v123/` | `.venv_oe_py310_v123` | 3.49.9 | 1.0.6.1 |

---

## 5. ONNX 模型列表（根目录）

| 文件 | 大小 | 修改时间 | 说明 |
|------|------|---------|------|
| `bear_best.onnx` | 10.4MB | 2026-04-23 | 熊检测模型，最新，当前主力 |
| `best.onnx` | 10.4MB | 2026-04-20 | 车辆检测模型（原始） |
| `shape_inference_fail.onnx` | 10.5MB | 2026-04-20 | 失败模型，shape inference 报错 |

---

## 6. YAML 配置列表

| 文件 | 输入模型 | 输入类型 | calibration 数据 | 输出目录 |
|------|---------|---------|-----------------|---------|
| `x5_quant_bear_nv12.yaml` | bear_best.onnx | nv12 | calibration_bear_rgb_uint8_nchw | x5_quant_output_bear |
| `x5_quant_best_nv12.yaml` | best.onnx | nv12 | calibration_bin_float32_nchw（不存在） | model_output_best_640x640_bayese_nv12 |
| `x5_quant_best_nv12_adapt.yaml` | best.onnx | nv12 | calibration_rgb_uint8_nchw | model_output_best_640x640_bayese_nv12 |
| `x5_quant_best_rgb.yaml` | best.onnx | rgb | calibration_bin_float32_nchw（不存在） | model_output_best_640x640_bayese_rgb |
| `x5_quant_nv12.yaml` | best.onnx | nv12 | calibration_rgb_uint8_nchw | x5_quant_output |
| `x5_quant_nv12_fixed.yaml` | best_fixed.onnx（不存在） | nv12 | calibration_rgb_uint8_nchw | x5_quant_output |

---

## 7. 异常文件

根目录存在多个以 `=` 开头的空文件，系 pip install 命令行错误产生的垃圾文件：

```
=0.2.4  =0.7.2  =1.7  =1.8.2  =2.12.0  =4.64.1
```

这些文件无害但说明安装过程中曾出现命令行错误（如 `pip install package==1.7` 写成 `pip install package =1.7`）。
