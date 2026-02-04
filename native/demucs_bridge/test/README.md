# raw파일 만드는 법
`build/Debug`에 파일 넣고 아래 명령 실행하기
```shell
ffmpeg -i audio.mp3 -f f32le -ac 2 -ar 44100 audio.raw
```

# 빌드 방법
`test`폴더에서 아래 명령어 순서대로 입력
```shell
cmake --build .
# cmake --build . --target clean
cd Debug
.\demucs_test.exe
```