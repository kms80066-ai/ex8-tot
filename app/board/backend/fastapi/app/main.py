from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
import pymysql
import os

app = FastAPI()

# templates 폴더 설정 (index.html이 있는 위치)
templates = Jinja2Templates(directory="templates")

# DB 연결 상태 체크 함수 (추가된 로직)
def check_db_connection():
    # DB 접속 정보는 환경변수에서 가져온다.
    db_host = os.getenv("DB_HOST")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")
    db_name = os.getenv("DB_NAME")

    # DB 접속 정보가 없는 경우
    if not all([db_host, db_user, db_password, db_name]):
        return "NOT CONFIGURED (DB 미연결)"

    # DB 접속 정보가 있는 경우
    try:
        connection = pymysql.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            database=db_name,
            connect_timeout=3
        )

        connection.close()
        return "SUCCESS (DB 연결 성공!)"

    except Exception as e:
        return f"FAILED (DB 연결 실패: {str(e)})"

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    # DB 연결 테스트 실행 (추가된 로직)
    db_status = check_db_connection()

    # 페이지에 표시될 데이터 정의 (원본 유지)
    k8s_data = {
        "title": "Kubernetes Navigation",
        "subtitle": "컨테이너 오케스트레이션의 바다를 항해하다",
        "sections": [
            {"id": "arch", "title": "Cluster Architecture", "desc": "Control Plane & Worker Node"},
            {"id": "object", "title": "K8s Objects", "desc": "Pod, Service, Deployment"},
            {"id": "network", "title": "Networking", "desc": "Ingress & Service Mesh"},
            {"id": "storage", "title": "Storage & PV", "desc": "Persistent Volumes"}
        ],
        "db_status": db_status  # HTML 템플릿으로 DB 접속 상태 전달 (추가된 키)
    }
    return templates.TemplateResponse(
        request=request,
        name="index.html",
        context={"data": k8s_data}
    )

@app.get("/health")
async def health():
    return {"status": "ok"}

# 추가로 API 형태로 상태만 간단히 확인하고 싶을 때 접속하는 엔드포인트
@app.get("/db-check")
async def db_check_api():
    status = check_db_connection()
    return {"database_connection": status}

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="0.0.0.0", port=8000)