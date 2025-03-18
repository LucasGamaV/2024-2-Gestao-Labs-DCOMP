from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager, suppress

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from app.database.utils import init_db
from app.routes import (
    login,
    usuarios,
    laboratorios,
    computadores,
    relato_problemas,
    status,
    alteracoes,
)


@asynccontextmanager
async def lifespan(_app: FastAPI) -> AsyncGenerator:
    """Realiza computações de inicialização do banco."""
    init_db()
    yield


app = FastAPI(docs_url='/docs/api', lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    # Configura CORS para permitir acesso do devServer do Flutter.
    allow_origins=['http://localhost:7000', 'http://localhost:8000'],
    allow_methods=['*'],
    allow_headers=['*'],
)


with suppress(RuntimeError):
    app.mount('/static', StaticFiles(directory='static'), name='static')


@app.get('/')
async def read_root() -> FileResponse:
    return FileResponse('static/web-frontend/index.html')


@app.get('/docs/front')
async def read_front_docs() -> FileResponse:
    return FileResponse('static/docs/front/index.html')


@app.get('/docs/back')
async def read_back_docs() -> FileResponse:
    return FileResponse('static/docs/back/index.html')


@app.get('/recuperar-senha')
async def recuperar_senha() -> FileResponse:
    return FileResponse('static/recuperacao-senha/index.html')


app.include_router(login.router, prefix='/login', tags=['login'])
app.include_router(usuarios.router, prefix='/usuarios', tags=['usuarios'])
app.include_router(computadores.router, prefix='/computadores', tags=['computadores'])
app.include_router(laboratorios.router, prefix='/laboratorios', tags=['laboratorios'])
app.include_router(relato_problemas.router, prefix='/relato-problemas', tags=['relato-problemas'])
app.include_router(status.router, prefix='/status', tags=['status'])
app.include_router(alteracoes.router, prefix='/alteracoes', tags=['alteracoes'])


@app.get('/developers')
def root() -> list[str]:
    return [
        'Lucas',
        'Igor',
        'Rafael',
    ]

