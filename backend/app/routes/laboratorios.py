from typing import List
from fastapi import APIRouter, HTTPException
from sqlmodel import select
from app.deps import SessionDep

from app.database.models import (
    Laboratorio, 
    LaboratorioCreate, 
    LaboratorioPublic
)

router = APIRouter()

# 1. POST para criação de um novo laboratório
@router.post("/", response_model=LaboratorioPublic)
def create_laboratorio(laboratorio: LaboratorioCreate, db: SessionDep):
    db_laboratorio = Laboratorio(
        nome=laboratorio.nome, 
        local=laboratorio.local, 
        administrador_id=laboratorio.administrador_id
    )
    db.add(db_laboratorio)
    db.commit()
    db.refresh(db_laboratorio)
    return db_laboratorio

# 2. PUT para alteração dos campos "local" e "nome"
@router.put("/{laboratorio_id}", response_model=LaboratorioPublic)
def update_laboratorio(laboratorio_id: int, laboratorio: LaboratorioCreate, db: SessionDep):
    statement = select(Laboratorio).where(
        Laboratorio.id == laboratorio_id
    )
    db_laboratorio = db.exec(statement).first()
    
    if db_laboratorio is None:
        raise HTTPException(status_code=404, detail="Laboratório não encontrado")
    
    db_laboratorio.nome = laboratorio.nome
    db_laboratorio.local = laboratorio.local
    db.commit()
    db.refresh(db_laboratorio)
    return db_laboratorio

# 3. GET para pegar "nome" e "local" de todos os laboratórios cadastrados
@router.get("/", response_model=List[LaboratorioPublic])
def get_laboratorios(db: SessionDep):
    statement = select(Laboratorio)
    laboratorios = db.exec(statement).all()
    return laboratorios

# 4. GET para pegar "nome" e "local" de um laboratório específico
@router.get("/{laboratorio_id}", response_model=LaboratorioPublic)
def get_laboratorio(laboratorio_id: int, db: SessionDep):
    statement = select(Laboratorio).where(
        Laboratorio.id == laboratorio_id
    )
    db_laboratorio = db.exec(statement).first()

    if db_laboratorio is None:
        raise HTTPException(status_code=404, detail="Laboratório não encontrado")
    
    return db_laboratorio