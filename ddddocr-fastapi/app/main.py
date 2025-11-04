import uvicorn
from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from typing import Optional, Union
import base64
from models import OCRRequest, SlideMatchRequest, DetectionRequest, APIResponse
from services import ocr_service
import requests # 导入 requests 库


app = FastAPI()

from starlette.datastructures import UploadFile as StarletteUploadFile


async def decode_image(image: Union[UploadFile, StarletteUploadFile, str, None]) -> bytes:
    if image is None:
        raise HTTPException(status_code=400, detail="No image provided")

    if isinstance(image, (UploadFile, StarletteUploadFile)):
        return await image.read()
    elif isinstance(image, str):
        # 检查是否是 URL
        if image.startswith(('http://', 'https://')):
            try:
                # 从 URL 获取图片字节内容
                response = requests.get(image)
                response.raise_for_status()  # 检查是否为成功的状态码
                return response.content
            except requests.exceptions.RequestException as e:
                # 捕获请求错误，如网络问题或URL无效
                raise HTTPException(status_code=400, detail=f"Failed to fetch image from URL: {e}")
            except Exception as e:
                # 捕获其他未知错误
                raise HTTPException(status_code=500, detail=f"An unexpected error occurred while fetching image from URL: {e}")
        
        try:
            # 检查是否是 base64 编码的图片
            if image.startswith(('data:image/', 'data:application/')):
                # 移除 MIME 类型前缀
                image = image.split(',', 1)[1] # 使用 split(',', 1) 避免数据中包含逗号的问题
            return base64.b64decode(image)
        except:
            raise HTTPException(status_code=400, detail="Invalid base64 string")
    else:
        raise HTTPException(status_code=400, detail="Invalid image input")


@app.post("/ocr", response_model=APIResponse)
async def ocr_endpoint(
        file: Optional[UploadFile] = File(None),
        image: Optional[str] = Form(None),
        imgurl: Optional[str] = Form(None), # 新增 imgurl 参数
        probability: bool = Form(False),
        charsets: Optional[str] = Form(None),
        png_fix: bool = Form(False)
):
    try:
        # 确定要处理的图片输入源：imgurl > image > file
        image_input = imgurl or image or file

        if image_input is None:
            return APIResponse(code=400, message="Either file, image (base64) or imgurl must be provided")

        image_bytes = await decode_image(image_input)
        result = ocr_service.ocr_classification(image_bytes, probability, charsets, png_fix)
        return APIResponse(code=200, message="Success", data=result)
    except HTTPException as http_e:
        return APIResponse(code=http_e.status_code, message=http_e.detail)
    except Exception as e:
        return APIResponse(code=500, message=str(e))


@app.post("/slide_match", response_model=APIResponse)
async def slide_match_endpoint(
        target_file: Optional[UploadFile] = File(None),
        background_file: Optional[UploadFile] = File(None),
        target: Optional[str] = Form(None),
        background: Optional[str] = Form(None),
        target_imgurl: Optional[str] = Form(None),      # 新增 target_imgurl 参数
        background_imgurl: Optional[str] = Form(None),  # 新增 background_imgurl 参数
        simple_target: bool = Form(False)
):
    try:
        # 确定目标图片输入源：url > base64 > file
        target_input = target_imgurl or target or target_file
        # 确定背景图片输入源：url > base64 > file
        background_input = background_imgurl or background or background_file

        if target_input is None or background_input is None:
            return APIResponse(code=400, message="Both target and background must be provided (file, base64, or url)")

        target_bytes = await decode_image(target_input)
        background_bytes = await decode_image(background_input)
        
        # 原始的 (background_file.size == 0 and target_file.size == 0) 逻辑已通过 decode_image 内部的异常处理隐式覆盖，
        # 并且新的输入方式更全面，因此此处不再需要额外检查文件 size。

        result = ocr_service.slide_match(target_bytes, background_bytes, simple_target)
        return APIResponse(code=200, message="Success", data=result)
    except HTTPException as http_e:
        return APIResponse(code=http_e.status_code, message=http_e.detail)
    except Exception as e:
        return APIResponse(code=500, message=str(e))


@app.post("/detection", response_model=APIResponse)
async def detection_endpoint(
        file: Optional[UploadFile] = File(None),
        image: Optional[str] = Form(None),
        imgurl: Optional[str] = Form(None) # 新增 imgurl 参数
):
    try:
        # 确定要处理的图片输入源：imgurl > image > file
        image_input = imgurl or image or file
        
        if image_input is None:
            return APIResponse(code=400, message="Either file, image (base64) or imgurl must be provided")

        image_bytes = await decode_image(image_input)
        bboxes = ocr_service.detection(image_bytes)
        return APIResponse(code=200, message="Success", data=bboxes)
    except HTTPException as http_e:
        return APIResponse(code=http_e.status_code, message=http_e.detail)
    except Exception as e:
        return APIResponse(code=500, message=str(e))


if __name__ == "__main__":
    # 请确保已安装 uvicorn, fastapi, python-multipart, requests 库
    uvicorn.run(app, host="0.0.0.0", port=8000)