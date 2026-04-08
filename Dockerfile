FROM python:3.10-slim

# 파이썬 바이트코드 생성 방지 및 출력 버퍼링 비활성화 (로그가 바로 보이도록 설정)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 빌드 및 오디오 처리에 필요한 시스템 패키지만 설치 후 캐시 삭제로 이미지 크기 최적화
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# 보안을 위해 컨테이너 내부에서 사용할 비권한(Non-root) 사용자 생성
RUN adduser --disabled-password --gecos '' mlopsuser

WORKDIR /app

# 의존성 패키지 캐시를 활용하기 위해 requirements.txt만 먼저 복사
COPY requirements.txt .

# pip 업그레이드 및 패키지 설치 (캐시 미사용으로 결과 이미지 군더더기 방지)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 앱 소스 코드 복사
COPY app/ app/

# 업로드 폴더 생성 및 소유권을 앞서 만든 비권한 사용자로 변경
RUN mkdir -p upload && chown -R mlopsuser:mlopsuser /app

# 이후 실행은 root가 아닌 mlopsuser로 실행 (보안 모범 사례)
USER mlopsuser

EXPOSE 8000

# 서버 실행
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
