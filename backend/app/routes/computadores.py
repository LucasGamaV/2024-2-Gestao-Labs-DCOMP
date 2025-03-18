from fastapi import APIRouter, HTTPException
from datetime import datetime, date
from typing import List

from sqlmodel import select
from app.deps import SessionDep

from app.database.models import (
    Computador,
    ComputadorCreateNew,
    ComputadorPublic,
    Laboratorio,
    Status,
)
from app.database.enums import TipoSistemaOperacional

router = APIRouter()


# 1. POST para criação de registro do computador
@router.post("/", response_model=ComputadorPublic)
def create_computador(dados: ComputadorCreateNew, db: SessionDep):
    # Buscar laboratório pelo nome e local
    statement = select(Laboratorio).where(
        Laboratorio.nome == dados.laboratorio_nome,
        Laboratorio.local == dados.laboratorio_local
    )
    laboratorio = db.exec(statement).first()
    if not laboratorio:
        raise HTTPException(status_code=404, detail="Laboratório não encontrado")

    # Criar computador com valores padrão
    novo_computador = Computador(
        patrimonio=dados.patrimonio,
        hostname=dados.hostname,
        marca=dados.marca,
        ano_aquisicao=dados.ano_aquisicao,
        sistema_operacional=TipoSistemaOperacional(dados.sistema_operacional),
        laboratorio_id=laboratorio.id,
        status_id=1,  # Status padrão
        tecnico_id=dados.tecnico_id,
        data_ultima_alteracao=dados.data_ultima_alteracao,
        dias_desde_alteracao=0
    )
    db.add(novo_computador)
    db.commit()
    db.refresh(novo_computador)
    return novo_computador


# 2. PUT para alteração de registro do computador
@router.put("/{computador_id}", response_model=ComputadorPublic)
def alterar_computador(computador_id: int, status_nome: str, status_descricao: str, db: SessionDep):
    # Buscar o computador pelo ID
    statement = select(Computador).where(
        Computador.id == computador_id
    )
    computador = db.exec(statement).first()
    
    if not computador:
        raise HTTPException(status_code=404, detail="Computador não encontrado.")
    
    # Buscar o status pelo nome e descrição
    statement = select(Status).where(
        Status.nome == status_nome,
        Status.descricao == status_descricao
    )
    status = db.exec(statement).first()
    
    if not status:
        raise HTTPException(status_code=404, detail="Status não encontrado.")
    
    # Atualizar os campos
    computador.status_id = status.id
    computador.data_ultima_alteracao = datetime.utcnow()
    
    db.commit()
    db.refresh(computador)
    
    return computador


# 3. GET para pegar informações de todos os computadores
@router.get("/", response_model=List[ComputadorPublic])
def get_computadores(db: SessionDep):
    statement = select(Computador)
    computadores = db.exec(statement).all()
    return computadores


# 4. GET para pegar informações de um computador específico
@router.get("/{computador_id}", response_model=ComputadorPublic)
def get_computador(computador_id: int, db: SessionDep):
    # Buscar computador
    statement = select(Computador).where(
        Computador.id == computador_id
    )
    computador = db.exec(statement).first()

    if not computador:
        raise HTTPException(status_code=404, detail="Computador não encontrado")

    # Atualizar dias desde a última alteração
    computador.dias_desde_alteracao = (date.today() - computador.data_ultima_alteracao).days

    db.commit()
    db.refresh(computador)
    return computador