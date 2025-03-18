from typing import List
from fastapi import APIRouter, HTTPException
from sqlmodel import select
from sqlalchemy.exc import IntegrityError

from app.deps import SessionDep

from app.database.models import (
    Status, 
    StatusCreate, 
    StatusPublic
)

from app.database.enums import StatusComputador


router = APIRouter()


@router.post("/", response_model=StatusPublic)
async def create_status(status: StatusCreate, db: SessionDep):
    # Verifica se já existe um status com o mesmo nome
    stmt = select(Status).where(Status.nome == status.nome)
    existing_status = db.exec(stmt).first()
    
    if existing_status:
        raise HTTPException(status_code=400, detail="Status com este nome já existe.")

    # Criação de novo status
    db_status = Status(nome=status.nome, descricao=status.descricao)
    db.add(db_status)
    
    try:
        db.commit()
        db.refresh(db_status)
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=500, detail="Erro ao criar o status.")
    
    return db_status


# GET para pegar todos os status de um tipo específico
@router.get("/{status_nome}/", response_model=List[StatusPublic])
async def listar_status(status_nome: StatusComputador, db: SessionDep):
    statement = select(Status).where(
        Status.nome == status_nome
    )
    status = db.exec(statement).all()
    return status


# GET para pegar um status específico
@router.get("/{status_nome}/{status_descricao}/", response_model=StatusPublic)
async def obter_status(status_nome: StatusComputador, status_descricao: str, db: SessionDep):
    statement = select(Status).where(
        Status.nome == status_nome,
        Status.descricao == status_descricao
    )
    status = db.exec(statement).first()
    
    if not status:
        raise HTTPException(status_code=404, detail="Status não encontrado")

    return status