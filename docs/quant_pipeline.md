# 量化流程文档

生成时间：2026-04-25  
工具链：horizon_tc_ui 1.24.3 / hbdk 3.49.15（open_explorer v1.2.8）

---

## 1. 完整流程概览

```
bear_best.onnx
    │
    ├─[Step 1] 激活虚拟环境
    │   source .venv_oe_py310/bin/activate
    │
    ├─[Step 2] 设置环境变量
    │   export HOME / LD_LIBRARY_PATH / HB_DNN_SIM_PLATFORM 等
    │
    ├─[Step 3] hb_mapper checker（兼容性检查）
    │   hb_mapper checker --model-type onnx --model bear_best.onnx --march bayes-e
    │
    └─[Step 4] hb_mapper makertbin（量化 + 编译）
        hb_mapper makertbin --config x5_quant_bear_nv12.yaml --model-type onnx
        │
        ├── bear_yolov8n_x5_640_nv12_original_float_model.onnx
        ├── bear_yolov8n_x5_640_nv12_optimized_float_model.onnx
        ├── bear_yolov8n_x5_640_nv12_calibrated_model.onnx
        ├── bear_yolov8n_x5_640_nv12_quantized_model.onnx
        └── bear_yolov8n_x5_640_nv12.bin  ← 最终部署模型
```

---

## 2. 输入模型

| 项目 | 值 |
|------|-----|
| 文件 | `/home/demo/tianbot_ws/bear_best.onnx` |
| 大小 | 10.4 MB |
| 架构 | YOLOv8n（检测头已修改为 BPU 友好格式） |
| 输入节点 | `images` |
| 输入形状 | `1x3x640x640`（NCHW） |
| 训练时格式 | RGB float32，归一化系数 1/255 |

---

## 3. Calibration 数据来源

| 项目 | 值 |
|------|-----|
| 原始图像目录 | `bear_calibration_images/`（100 张 .jpg） |
| 转换后目录 | `calibration_bear_rgb_uint8_nchw/`（100 个 .bin） |
| 数据格式 | uint8，RGB，NCHW，640×640 |
| 数量 | 100 张 |
| 来源 | 熊检测任务实际采集图像（2026-04-23） |

**转换方式（从 jpg 到 bin）：**

```python
import numpy as np
import cv2, os

src = "bear_calibration_images"
dst = "calibration_bear_rgb_uint8_nchw"
os.makedirs(dst, exist_ok=True)

for fname in sorted(os.listdir(src)):
    img = cv2.imread(os.path.join(src, fname))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, (640, 640))
    arr = img.transpose(2, 0, 1)  # HWC -> CHW
    arr = np.ascontiguousarray(arr, dtype=np.uint8)
    out = fname.replace(".jpg", ".bin")
    arr.tofile(os.path.join(dst, out))
```

---

## 4. YAML 配置说明（x5_quant_bear_nv12.yaml）

```yaml
model_parameters:
  onnx_model: /home/demo/tianbot_ws/bear_best.onnx   # 输入 ONNX
  march: bayes-e                                       # RDK X5 架构
  output_model_file_prefix: bear_yolov8n_x5_640_nv12  # 输出文件前缀
  working_dir: ./x5_quant_output_bear                  # 输出目录
  layer_out_dump: false

input_parameters:
  input_name: images
  input_type_train: rgb        # 训练时输入格式
  input_layout_train: NCHW
  input_shape: 1x3x640x640
  input_batch: 1
  norm_type: data_scale        # 归一化方式
  scale_value: '0.003921568627451'  # = 1/255
  input_type_rt: nv12          # 运行时输入格式（板端摄像头）
  input_space_and_range: regular

calibration_parameters:
  cal_data_dir: /home/demo/tianbot_ws/calibration_bear_rgb_uint8_nchw
  cal_data_type: uint8
  preprocess_on: false         # 不在工具链内做预处理
  calibration_type: default    # KL 散度校准
  per_channel: false

compiler_parameters:
  compile_mode: latency        # 优化延迟
  debug: true                  # 保留中间产物
  core_num: 1
  optimize_level: O3
  jobs: 8
  input_source:
    images: pyramid            # 输入来自 ISP pyramid（摄像头直出）
```

**关键配置说明：**

- `input_type_rt: nv12` + `input_source: pyramid`：板端直接接摄像头 ISP 输出，无需 CPU 格式转换
- `input_type_train: rgb`：工具链自动在量化时插入 NV12→RGB 转换节点
- `scale_value: 1/255`：与训练时归一化一致，工具链将其融入量化参数
- `calibration_type: default`：使用 KL 散度校准，适合通用检测模型

---

## 5. 量化执行命令

### 方式一：使用封装脚本（推荐）

```bash
cd /home/demo/tianbot_ws

# 使用熊模型配置
bash run_x5_quant.sh x5_quant_bear_nv12.yaml
```

### 方式二：手动执行

```bash
cd /home/demo/tianbot_ws

# Step 1: 激活环境
source .venv_oe_py310/bin/activate

# Step 2: 设置环境变量
export HOME="/home/demo/tianbot_ws"
export MPLCONFIGDIR="/tmp/matplotlib-x5"
export HORIZON_LIB_PATH="/home/demo/tianbot_ws/.horizon"
export DDK_LIB_PATH="/home/demo/tianbot_ws/.horizon/ddk"
export X5_X86_GCC1140_PATH="/home/demo/tianbot_ws/.horizon/ddk/x5_x86_64_gcc_11.4.0"
export LD_LIBRARY_PATH="${X5_X86_GCC1140_PATH}/dnn_x86/lib:.venv_oe_py310/lib/python3.10/site-packages/hbdk4/runtime/x86_64_unknown_linux_gnu/nash/lib:${LD_LIBRARY_PATH:-}"
export HB_DNN_SIM_PLATFORM="BAYESE"

# Step 3: 兼容性检查
hb_mapper checker \
  --model-type onnx \
  --model bear_best.onnx \
  --march bayes-e

# Step 4: 量化编译
hb_mapper makertbin \
  --config x5_quant_bear_nv12.yaml \
  --model-type onnx
```

---

## 6. 输出路径

| 文件 | 用途 |
|------|------|
| `x5_quant_output_bear/bear_yolov8n_x5_640_nv12.bin` | **板端部署文件** |
| `x5_quant_output_bear/bear_yolov8n_x5_640_nv12_quant_info.json` | 量化精度信息 |
| `x5_quant_output_bear/bear_yolov8n_x5_640_nv12_quantized_model.onnx` | x86 仿真验证用 |
| `x5_quant_output_bear/main_graph_subgraph_*.html` | 算子分配可视化 |

---

## 7. 各 YAML 配置对比

| YAML | 输入模型 | cal 数据 | cal 格式 | 输出目录 | 可用性 |
|------|---------|---------|---------|---------|--------|
| `x5_quant_bear_nv12.yaml` | bear_best.onnx | calibration_bear_rgb_uint8_nchw | uint8 | x5_quant_output_bear | ✅ 可用 |
| `x5_quant_best_nv12_adapt.yaml` | best.onnx | calibration_rgb_uint8_nchw | uint8 | model_output_best_640x640_bayese_nv12 | ✅ 可用 |
| `x5_quant_nv12.yaml` | best.onnx | calibration_rgb_uint8_nchw | uint8 | x5_quant_output | ✅ 可用 |
| `x5_quant_nv12_fixed.yaml` | best_fixed.onnx | calibration_rgb_uint8_nchw | uint8 | x5_quant_output | ❌ 输入模型不存在 |
| `x5_quant_best_nv12.yaml` | best.onnx | calibration_bin_float32_nchw | float32 | model_output_best_640x640_bayese_nv12 | ❌ cal 目录不存在 |
| `x5_quant_best_rgb.yaml` | best.onnx | calibration_bin_float32_nchw | float32 | model_output_best_640x640_bayese_rgb | ❌ cal 目录不存在 |
