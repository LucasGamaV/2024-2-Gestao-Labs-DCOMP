import secrets
import string
from datetime import datetime, timedelta, timezone

import jwt
import requests
from fastapi import HTTPException, status
from passlib.context import CryptContext
from sqlalchemy.exc import SQLAlchemyError
from sqlmodel import Session, select

from app.config import settings
from app.database.enums import TipoUsuario

from app.database.models import (
    Administrador,
    Funcionario,
    FuncionarioCreate,
    FuncionarioPublic,
    Tecnico,
    Professor,
    Usuario,
    UsuarioCreate,
    Aluno,
    UsuarioPublic,
)


def hash_password(plain_password: str) -> str:
    return pwd_context.hash(plain_password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica se as senhas são equivalentes de acordo com o algoritmo de hashing."""
    return pwd_context.verify(plain_password, hashed_password)

def generate_random_password(tamanho: int = 8) -> str:
    """Gera uma senha aleatória de {tamanho} caracteres."""
    characters = string.ascii_letters + string.digits
    return ''.join(secrets.choice(characters) for _ in range(tamanho))

def create_usuario(session: Session,
                   usuario: UsuarioCreate,
                   *,
                   usar_senha_aleatoria: bool = False) -> UsuarioPublic:
    if get_user_by_email(session, usuario.email):
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            f'Um usuário com o email {usuario.email} já existe.',
        )
    senha = usuario.senha if not usar_senha_aleatoria else generate_random_password()
    usuario_db = Usuario.model_validate(
        usuario,
        update={
            'senha_hash': hash_password(senha) if senha else None,
        },
    )

    try:
        session.add(usuario_db)
        session.commit()
    except (SQLAlchemyError, requests.exceptions.RequestException) as e:
        session.rollback()
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f'Erro ao criar usuário: {e!s}',
        )
    session.refresh(usuario_db)
    return usuario_db


def get_user_by_email(session: Session, email: str) -> Usuario | None:
    stmt = select(Usuario).where(Usuario.email == email)
    return session.exec(stmt).first()


def get_funcionario_by_matricula(session: Session, matricula: str) -> object | None:
    tables = [Tecnico, Administrador, Professor]
    for table in tables:
        stmt = select(table).where(table.matricula == matricula)
        funcionario = session.exec(stmt).first()
        if funcionario is not None:
            return funcionario
    return None


def check_existing_matricula(session: Session, matricula: str) -> None:
    exists_same_matricula = get_funcionario_by_matricula(session, matricula)
    if exists_same_matricula:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            'Matrícula já cadastrada.',
        )


def authenticate(session: Session, email: str, senha: str) -> Usuario | None:
    usuario = get_user_by_email(session, email)
    if not usuario:
        return None
    if not verify_password(senha, usuario.senha_hash):
        return None
    return usuario


def busca_completa_tipo_usuario(session: Session, usuario: Usuario) -> tuple[object, TipoUsuario]:
    tipos = [
        (Administrador, TipoUsuario.administrador),
        (Aluno, TipoUsuario.aluno),
        (Tecnico, TipoUsuario.tecnico),
        (Professor, TipoUsuario.professor),
    ]
    for table, tipo in tipos:  # noqa: RET503
        usuario_especifico = session.exec(
            select(table).where(table.usuario_id == usuario.id),
        ).first()
        if usuario_especifico:
            return usuario_especifico, tipo


def user_table_from_tipo(tipo_usuario: TipoUsuario) -> type:
    match tipo_usuario:
        case TipoUsuario.aluno:
            return Aluno
        case TipoUsuario.tecnico:
            return Tecnico
        case TipoUsuario.administrador:
            return Administrador
        case TipoUsuario.professor:
            return Professor


def usuario_especifico(
    session: Session,
    usuario: Usuario,
    tipo_usuario_hint: TipoUsuario | None = None,
) -> tuple[object, TipoUsuario] | object:
    """Retorna o objeto do tipo SQLAlchemy específico desse usuário.

    Se uma hint do tipo de usuário for dada, retorna apenas o objeto representando o usuário.
    Caso contrário, retorna o objeto e o tipo dele.
    """
    if tipo_usuario_hint is None:
        return busca_completa_tipo_usuario(session, usuario)
    table = user_table_from_tipo(tipo_usuario_hint)
    stmt = select(table).where(table.usuario_id == usuario.id)
    return session.exec(stmt).first()


pwd_context = CryptContext(schemes=['pbkdf2_sha256'], deprecated='auto')


def create_access_token(
    usuario: Usuario,
    usuario_especifico: Aluno | Funcionario,
    tipo_usuario: TipoUsuario,
) -> str:
    expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode = {
        'exp': expire,
        'id_especifico': usuario_especifico.id,
        'sub': usuario.id,
        'email': usuario.email,
        'tipo_usuario': tipo_usuario,
        'nome': usuario.nome,
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_funcionario(
    session: Session,
    tipo_usuario: TipoUsuario,
    funcionario: FuncionarioCreate,
) -> FuncionarioPublic:
    """Cria um funcionário (Professor, Admin ou Tecnico).

    ## Raises
    Se um usuário com a Matrícula de `funcionario` já existir, retorna um erro 409.
    """
    check_existing_matricula(session, funcionario.matricula)
    usuario = create_usuario(session, funcionario, usar_senha_aleatoria=True)
    table = user_table_from_tipo(tipo_usuario)
    funcionario_db = table.model_validate(
        funcionario,
        update={'usuario_id': usuario.id},
    )
    session.add(funcionario_db)
    session.commit()
    session.refresh(funcionario_db)
    return funcionario_db

