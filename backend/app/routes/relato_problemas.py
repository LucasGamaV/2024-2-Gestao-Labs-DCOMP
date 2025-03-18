from typing import List
from fastapi import APIRouter, HTTPException
from sqlmodel import select

from app.deps import SessionDep

from app.database.models import (
    RelatoProblema, 
    RelatoProblemaCreate, 
    RelatoProblemaPublic,
    RelatoProblemaUpdate,
    Computador,
    Laboratorio
)

router = APIRouter()

@router.post("/", response_model=RelatoProblemaPublic)
def criar_relato(relato: RelatoProblemaCreate, db: SessionDep):
    # Verificar se o computador existe no laboratório
    computador = db.exec(select(Computador).where(Computador.id == relato.computador_id)).first()
    if not computador:
        raise HTTPException(status_code=404, detail="Computador não encontrado")

    laboratorio = db.exec(select(Laboratorio).where(Laboratorio.id == computador.laboratorio_id)).first()
    if not laboratorio:
        raise HTTPException(status_code=404, detail="Laboratório não encontrado")

    # Criar o relato
    novo_relato = RelatoProblema(
        descricao=relato.descricao,
        computador_id=relato.computador_id,
        usuario_id=relato.usuario_id,
        tecnico_id=None,  # técnico começa como None
        aceita=None,      # aceita começa como None
        auditada=False,   # auditada começa como False
    )

    db.add(novo_relato)
    db.commit()
    db.refresh(novo_relato)

    return novo_relato


@router.put("/{relato_id}", response_model=RelatoProblemaPublic)
def atualizar_relato(relato_id: int, relato: RelatoProblemaUpdate, db: SessionDep):
    # Encontrar o relato pelo ID
    db_relato = db.exec(select(RelatoProblema).where(RelatoProblema.id == relato_id)).first()
    if not db_relato:
        raise HTTPException(status_code=404, detail="Relato não encontrado")

    # Atualizar os campos do relato
    db_relato.auditada = relato.auditada
    db_relato.aceita = relato.aceita
    db_relato.tecnico_id = relato.tecnico_id
    db_relato.data_auditada = relato.data_auditada

    db.commit()
    db.refresh(db_relato)

    return db_relato


@router.get("/", response_model=List[RelatoProblemaPublic])
def obter_relatos(session: SessionDep):
    # Obter relatos com campo auditada igual a False
    relatos = session.exec(select(RelatoProblema).where(RelatoProblema.auditada == False)).all()
    return relatos


@router.get("/auditados", response_model=List[RelatoProblemaPublic])
def obter_relatos_auditados(session: SessionDep):
    # Obter relatos com campo auditada igual a True
    relatos = session.exec(select(RelatoProblema).where(RelatoProblema.auditada == True)).all()
    return relatos


@router.get("/{relato_id}", response_model=RelatoProblemaPublic)
def obter_relato(relato_id: int, session: SessionDep):
    # Obter relato específico pelo ID
    relato = session.exec(select(RelatoProblema).where(RelatoProblema.id == relato_id)).first()
    if not relato:
        raise HTTPException(status_code=404, detail="Relato não encontrado")
    
    return relato