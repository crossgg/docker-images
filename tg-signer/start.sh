#!/bin/bash

# 首次配置时使用，后续注释掉
pip install -U tg-signer
pip install "tg-signer[gui]"

# 首次配置时使用，后续注释掉
sleep infinity

# 配置完成后取消注释
# tg-signer run mytasks

nohup tg-signer webgui -H 0.0.0.0 >/dev/null &     