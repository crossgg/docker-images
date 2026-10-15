

```shell
docker run -d -p 9898:8000 --name ddddocr-api --restart=unless-stopped crosscc/ddddocr-fastapi
```
直接解析base64格式图纸，而不要上传图片的，nodejs脚本：
```nodejs
const axios = require('axios');
const FormData = require('form-data'); 
const fs = require('fs');

const url = 'http://10.0.0.10:9898/ocr';

const base64Image = 'xxxx'; 

const form = new FormData();

form.append('image', base64Image);
// multipart/form-data 的值通常是字符串，将布尔值转换为字符串更安全
form.append('probability', 'false'); 
form.append('png_fix', 'false');


axios.post(url, form, {
  headers: {
    ...form.getHeaders() // 让 form-data 库为你生成正确的 Content-Type 和 boundary
  }
})
  .then(response => {
    console.log(response.data);
  })
  .catch(error => {
    // 打印更详细的错误信息，有助于调试
    if (error.response) {
      console.error('Error Response:', error.response.data);
    } else {
      console.error('Error:', error.message);
    }
  });
```


-----------------------
直接解析图片链接

```bash
curl -X POST "http://0.0.0.0:8000/ocr" \
-H "Content-Type: multipart/form-data" \
-F "imgurl=YOUR_IMAGE_URL_HERE" \
-F "probability=false" 是否返回概率（默认：false）
-F "charsets=5" 字符集（可选）
-F "png_fix=false" 是否进行 PNG 修复（默认：false）
```

probability，charsets 为可选参数

probability=True时，charests必填

charsets参考值如下：

| 参数值 | 意义                                             |
| ------ | ------------------------------------------------ |
| 0      | 纯整数0-9                                        |
| 1      | 纯小写英文a-z                                    |
| 2      | 纯大写英文A-Z                                    |
| 3      | 小写英文a-z + 大写英文A-Z                        |
| 4      | 小写英文a-z + 整数0-9                            |
| 5      | 大写英文A-Z + 整数0-9                            |
| 6      | 小写英文a-z + 大写英文A-Z + 整数0-9              |
| 7      | 默认字符库 - 小写英文a-z - 大写英文A-Z - 整数0-9 |











## 转载：https://github.com/sml2h3/ddddocr-fastapi/

以下为原内容：
# 🚀 DdddOcr API

![DdddOcr Logo](https://cdn.wenanzhe.com/img/logo.png!/crop/700x500a400a500)

> 基于 FastAPI 和 DdddOcr 的高性能 OCR API 服务，提供图像文字识别、滑动验证码匹配和目标检测功能。
> 
> [自营各类GPT聚合平台](https://juxiangyun.com)

## 📋 目录

- [系统要求](#-系统要求)
- [安装和启动](#-安装和启动)
- [API 端点](#-api-端点)
- [API 调用示例](#-api-调用示例)
- [注意事项](#-注意事项)
- [故障排除](#-故障排除)
- [许可证](#-许可证)

## 💻 系统要求

| 组件 | 版本 |
|------|------|
| 操作系统 | Linux（推荐 Ubuntu 20.04 LTS 或更高版本）|
| Docker | 20.10 或更高 |
| Docker Compose | 1.29 或更高 |

## 🚀 安装和启动

1. **克隆仓库**
   ```bash
   git clone https://github.com/your-repo/ddddocr-api.git
   cd ddddocr-api
   ```

2. **启动服务**
   
   有三种方式可以启动应用：

   a. 使用 docker启动：
      1. 构建 Docker 镜像 [一键docker环境服务器购买，可一元试用](https://www.rainyun.com/ddddocr_) 
      2. 打包镜像
          ```bash
          docker build -t ddddocr-api .
          ```
      3. 启动镜像
         ```bash
         docker run -d -p 8000:8000 --name ddddocr-api-container ddddocr-api
         ```

   b. 使用 python 命令直接运行：
      ```bash
      python app/main.py
      ```
   
   b. 使用 uvicorn（支持热重载，适合开发）：
      ```bash
      uvicorn app.main:app --reload
      ```


3. **验证服务**
   ```bash
   curl http://localhost:8000/docs
   ```
   > 如果成功，您将看到 Swagger UI 文档页面。
   
4. **停止服务**

- 如果使用 Docker：
  ```bash
  docker stop ddddocr-api-container
  ```

- 如果使用 Docker Compose：
  ```bash
  docker-compose down
  ```
  
5. **查看日志**

- 如果使用 Docker：
  ```bash
  docker logs ddddocr-api-container
  ```

- 如果使用 Docker Compose：
  ```bash
  docker-compose logs
  ```

## 🔌 API 端点

### 1. OCR 识别

🔗 **端点**：`POST /ocr`

| 参数 | 类型 | 描述 |
|------|------|------|
| `file` | File | 图片文件（可选） |
| `image` | String | Base64 编码的图片字符串（可选） |
| `probability` | Boolean | 是否返回概率（默认：false） |
| `charsets` | String | 字符集（可选） |
| `png_fix` | Boolean | 是否进行 PNG 修复（默认：false） |

### 2. 滑动验证码匹配

🔗 **端点**：`POST /slide_match`

| 参数                                                                                        | 类型                                                                                         | 描述                                                                                         |
|-------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `target_file`                                                                             | File                                                                                       | 目标图片文件（可选）需要与target字段同时使用                                                                  |
| `target`                                                                                  | String                                                                                     | Base64 编码的目标图片字符串（可选） 需要与target_file字段同时使用                                                 |
| `background_file`                                                                         | File                                                                                       | 背景图片文件（可选）    需要与background字段同时使用                                                          |
| `background`                                                                              | String                                                                                     | Base64 编码的背景图片字符串（可选）  需要与background_file字段同时使用                                            |
| `simple_target`                                                                           | Boolean                                                                                    | 是否使用简单目标（默认：false）                                                                         |
|| |  `target_file`和`target` 为一组字段，`background_file`和`background` 为一组字段， 两组字段不可同时使用，同时使用则仅一组会生效 |


### 3. 目标检测

🔗 **端点**：`POST /detection`

| 参数 | 类型 | 描述 |
|------|------|------|
| `file` | File | 图片文件（可选） |
| `image` | String | Base64 编码的图片字符串（可选） |

## 📘 API 调用示例

<details>
<summary>Python</summary>

```python
import requests
import base64

url = "http://localhost:8000/ocr"
image_path = "path/to/your/image.jpg"

with open(image_path, "rb") as image_file:
    encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

data = {
    "image": encoded_string,
    "probability": False,
    "png_fix": False
}

response = requests.post(url, data=data)
print(response.json())
```
</details>
<details>
<summary>Node.js</summary>

```javascript
const axios = require('axios');
const fs = require('fs');

const url = 'http://localhost:8000/ocr';
const imagePath = 'path/to/your/image.jpg';

const imageBuffer = fs.readFileSync(imagePath);
const base64Image = imageBuffer.toString('base64');

const data = {
  image: base64Image,
  probability: false,
  png_fix: false
};

axios.post(url, data)
  .then(response => {
    console.log(response.data);
  })
  .catch(error => {
    console.error('Error:', error);
  });
```
</details>

<details>
<summary>C#</summary>

```csharp
using System;
using System.Net.Http;
using System.IO;
using System.Threading.Tasks;

class Program
{
    static async Task Main(string[] args)
    {
        var url = "http://localhost:8000/ocr";
        var imagePath = "path/to/your/image.jpg";

        var imageBytes = File.ReadAllBytes(imagePath);
        var base64Image = Convert.ToBase64String(imageBytes);

        var client = new HttpClient();
        var content = new MultipartFormDataContent();
        content.Add(new StringContent(base64Image), "image");
        content.Add(new StringContent("false"), "probability");
        content.Add(new StringContent("false"), "png_fix");

        var response = await client.PostAsync(url, content);
        var result = await response.Content.ReadAsStringAsync();
        Console.WriteLine(result);
    }
}
```
</details>

<details>
<summary>PHP</summary>

```php
<?php

$url = 'http://localhost:8000/ocr';
$imagePath = 'path/to/your/image.jpg';

$imageData = base64_encode(file_get_contents($imagePath));

$data = array(
    'image' => $imageData,
    'probability' => 'false',
    'png_fix' => 'false'
);

$options = array(
    'http' => array(
        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
        'method'  => 'POST',
        'content' => http_build_query($data)
    )
);

$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);

echo $result;
?>
```
</details>

<details>
<summary>Go</summary>

```go
package main

import (
    "bytes"
    "encoding/base64"
    "encoding/json"
    "fmt"
    "io/ioutil"
    "net/http"
    "net/url"
)

func main() {
    apiURL := "http://localhost:8000/ocr"
    imagePath := "path/to/your/image.jpg"

    imageData, err := ioutil.ReadFile(imagePath)
    if err != nil {
        panic(err)
    }

    base64Image := base64.StdEncoding.EncodeToString(imageData)

    data := url.Values{}
    data.Set("image", base64Image)
    data.Set("probability", "false")
    data.Set("png_fix", "false")

    resp, err := http.PostForm(apiURL, data)
    if err != nil {
        panic(err)
    }
    defer resp.Body.Close()

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        panic(err)
    }

    fmt.Println(string(body))
}
```
</details>

<details>
<summary>易语言</summary>

```易语言
.版本 2

.程序集 调用OCR接口

.子程序 主函数, 整数型
.局部变量 请求头, QQ.HttpHeaders
.局部变量 请求内容, QQ.HttpMultiData
.局部变量 图片路径, 文本型
.局部变量 图片数据, 字节集
.局部变量 HTTP, QQ.Http

图片路径 ＝ "path/to/your/image.jpg"
图片数据 ＝ 读入文件 (图片路径)

请求头.添加 ("Content-Type", "application/x-www-form-urlencoded")

请求内容.添加文本 ("image", 到Base64 (图片数据))
请求内容.添加文本 ("probability", "false")
请求内容.添加文本 ("png_fix", "false")

HTTP.发送POST请求 ("http://localhost:8000/ocr", 请求内容, 请求头)

调试输出 (HTTP.获取返回文本())

返回 (0)
```
</details>

> **注意**：使用示例前，请确保安装了必要的依赖库，并根据实际环境修改服务器地址和图片路径。

## ⚠️ 注意事项

- 确保防火墙允许访问 8000 端口。
- 生产环境建议配置 HTTPS 和适当的身份验证机制。
- 定期更新 Docker 镜像以获取最新的安全补丁和功能更新。

## 🔧 故障排除

遇到问题？请检查以下几点：

1. 确保 Docker 服务正在运行。
2. 检查容器日志：
   ```bash
   docker logs ddddocr-api-container
   ```
3. 确保没有其他服务占用 8000 端口。

> 如果问题仍然存在，请提交 issue 到本项目的 GitHub 仓库。

## 📄 许可证

本项目采用 MIT 许可证。详情请参见 [LICENSE](LICENSE) 文件。

---

<p align="center">
  Made with ❤️ by sml2h3
</p>