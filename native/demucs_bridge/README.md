# 설정

## 윈도우 환경에서 onnx, ort 빌드하기

demucs.onnx github 리포지토리 아래 명령어로 clone하기

```shell
git clone --recurse-submodules https://github.com/sevagh/demucs.onnx
```

demucs.onnx폴더로 이동 후 pixi 환경 초기화 및 python, pip추가

```shell
pixi init .
pixi add python=3.10
pixi add pip
```

의존성 파일 설치

```shell
pixi run python -m pip install -r ./scripts/requirements.txt
pixi add --pypi onnxscript onnx # readme에 빠져있는 의존성 설치
```

onnx 변환 스크립트 실행  
이때 `convert-pth-to-onnx.py`에서 아래의 부분을 바꾸고 해야 경고가 뜨지 않음

```python
# Export the core model to ONNX
try:
    torch.onnx.export(
        core_model,
        dummy_input,
        onnx_file_path,
        export_params=True,
        opset_version=18,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output']
    )
    print(f"Model successfully converted to ONNX format at {onnx_file_path}")
except Exception as e:
    print("Error during ONNX export:", e)
```

그 후 아래의 명령어를 실행하면 demucs-onnx폴더에 onnx파일이 생성됨

```shell
pixi run python ./scripts/convert-pth-to-onnx.py ./demucs-onnx
```

(모바일용) ort 변환 스크립트 실행

```shell
# $1에는 onnx모델이 있는 경로를 넣으면 됨
pixi run python -m onnxruntime.tools.convert_onnx_models_to_ort $1 --enable_type_reduction
```

## 윈도우 환경에서 ort runtime 빌드하기

TODO
