#!/bin/sh

CONF_DIR=/sillyGirl/conf

if [ -z $CODE_DIR ]; then
  CODE_DIR=/sillyGirl
fi

if [ ! -f $CONF_DIR/userScript.sh ]; then
  echo "userScript.sh 不存在，不执行用户自定义脚本"
else
  echo "userScript.sh 存在，执行用户自定义脚本"
  sh $CONF_DIR/userScript.sh
fi

if [ ! -f $CODE_DIR/sillyGirl ]; then
  echo "sillyGirl 不存在，不执行"
else
  echo "启动..."
  ./sillyGirl
fi
 


