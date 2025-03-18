from collections.abc import Generator
from typing import Annotated

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jwt.exceptions import InvalidTokenError
from pydantic import ValidationError
from sqlmodel import Session

from app.config import settings
from app.database.enums import TipoUsuario
from app.database.models import (
    Administrador,
    Professor,
    Tecnico,
    TokenPayload,
    Usuario,
    Aluno,
    UsuarioPublic,
)
from app.database.utils import engine
from app.services.usuarios import get_user_by_email, usuario_especifico

credentials_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail='Não foi possível validar as credenciais. Tente fazer login novamente.',
    headers={'WWW-Authenticate': 'Bearer'},
)

reusable_oauth2 = OAuth2PasswordBearer(
    tokenUrl='/login/access-token',
)


def get_db() -> Generator[Session]:
    """Retorna uma Session."""
    with Session(engine) as db:
        yield db


SessionDep = Annotated[Session, Depends(get_db)]
TokenDep = Annotated[str, Depends(reusable_oauth2)]


def get_current_usuario(session: SessionDep, token: TokenDep) -> Usuario:
    """Retorna o usuário associado ao token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        token_data = TokenPayload(**payload)
        email = token_data.email
    except (InvalidTokenError, ValidationError):
        raise credentials_exception

    usuario = get_user_by_email(session, email)
    if not usuario:
        raise HTTPException(status.HTTP_404_NOT_FOUND, 'Usuario não encontrado')
    return usuario


CurrentUsuario = Annotated[UsuarioPublic, Depends(get_current_usuario)]


def get_admin(session: SessionDep, current_usuario: CurrentUsuario) -> Administrador:
    return usuario_especifico(session, current_usuario, TipoUsuario.administrador)


def get_aluno(session: SessionDep, current_usuario: CurrentUsuario) -> Aluno:
    return usuario_especifico(session, current_usuario, TipoUsuario.aluno)


def get_tecnico(session: SessionDep, current_usuario: CurrentUsuario) -> Tecnico:
    return usuario_especifico(session, current_usuario, TipoUsuario.tecnico)


def get_professor(session: SessionDep, current_usuario: CurrentUsuario) -> Professor:
    return usuario_especifico(session, current_usuario, TipoUsuario.professor)

CurrentAdministrador = Annotated[Administrador, Depends(get_admin)]
CurrentTecnico = Annotated[Tecnico, Depends(get_tecnico)]
CurrentProfessor = Annotated[Professor, Depends(get_professor)]
CurrentUsuarioDaVia = Annotated[Administrador, Depends(get_aluno)]

def get_priviliged_usuario(
    session: SessionDep,
    current_usuario: CurrentUsuario,
) -> Administrador:
    privilleged_usuario = (usuario_especifico(session, current_usuario, TipoUsuario.administrador))

    if not privilleged_usuario:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Usuário não autorizado.')

    return privilleged_usuario


PrivilegedUsuario = Annotated[Administrador, Depends(get_priviliged_usuario)]