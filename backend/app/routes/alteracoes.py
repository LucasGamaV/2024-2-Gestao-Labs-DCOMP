from fastapi import APIRouter, HTTPException
from typing import List
from sqlmodel import select
from app.deps import SessionDep

from app.database.models import (
    HistoricoAlteracaoCreate,
    HistoricoAlteracaoPublic,
    HistoricoAlteracao, 
    Computador, 
    Laboratorio, 
    Status,
)

from app.database.enums import TipoAlteracao

router = APIRouter()

# POST para criação de uma alteração
@router.post("/", response_model=HistoricoAlteracaoPublic)
async def criar_alteracao(historico: HistoricoAlteracaoCreate, db: SessionDep):
    # Verificando se o computador existe
    statement = select(Computador).where(
        Computador.id == historico.computador_id
    )
    computador = db.exec(statement).first()
    
    if not computador:
        raise HTTPException(status_code=404, detail="Computador não encontrado")

    # Verificando o status
    stat_stmt = select(Status).where(
        Status.id == historico.status_id
    )
    status = db.exec(stat_stmt).first()

    if not status:
        raise HTTPException(status_code=404, detail="Status não encontrado")
    
    # Criando o novo histórico de alteração
    novo_historico = HistoricoAlteracao(
        computador_id = historico.computador_id,
        tecnico_id = historico.tecnico_id,
        status_id = historico.status_id,
        tipo_alteracao = TipoAlteracao(historico.tipo_alteracao),
        observacao = historico.observacao,
        data_alteracao = historico.data_alteracao
    )
    

    # Atualizando o status do computador
    computador.status_id = historico.status_id

    db.add(novo_historico)
    db.commit()
    db.refresh(novo_historico)

    return novo_historico


# GET para pegar todas as alterações
@router.get("/", response_model=List[HistoricoAlteracaoPublic])
async def listar_alteracoes(db: SessionDep):
    statement = select(HistoricoAlteracao)
    alteracoes = db.exec(statement).all()
    return alteracoes


# GET para pegar uma alteração específica
@router.get("/{alteracao_id}", response_model=HistoricoAlteracaoPublic)
async def obter_alteracao(alteracao_id: int, db: SessionDep):
    statement = select(HistoricoAlteracao).where(
        HistoricoAlteracao.id == alteracao_id
    )
    alteracao = db.exec(statement).first()
    
    if not alteracao:
        raise HTTPException(status_code=404, detail="Alteração não encontrada")

    return alteracao