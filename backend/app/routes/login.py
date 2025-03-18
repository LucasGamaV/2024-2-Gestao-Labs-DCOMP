from datetime import datetime, timedelta
from typing import Annotated

import jwt
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

from app.config import settings
from app.database.models import (
    EsqueciSenha,
    NovaSenha,
    RecuperacaoSenha,
    Token,
    TrocaSenha,
    Usuario,
    UsuarioPublic,
)
from app.deps import CurrentUsuario, SessionDep
from app.services.usuarios import (
    authenticate,
    create_access_token,
    get_user_by_email,
    hash_password,
    usuario_especifico,
    verify_password,
)

router = APIRouter()


@router.post('/access-token', response_model=Token)
def login_access_token(
    db: SessionDep,
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
):
    """OAuth2 compatible token login, get an access token for future requests."""
    usuario = authenticate(session=db, email=form_data.username, senha=form_data.password)
    if not usuario:
        raise HTTPException(status_code=400, detail='Email ou senha incorretos.')
    _usuario_especifico, tipo_usuario = usuario_especifico(db, usuario)
    return Token(access_token=create_access_token(usuario, _usuario_especifico, tipo_usuario))


@router.post('/atualizar-senha')
def atualizar_senha(dados_nova_senha: NovaSenha, db: SessionDep):
    usuario = db.get(Usuario, dados_nova_senha.usuario_id)
    if verify_password(dados_nova_senha.senha, usuario.senha_hash):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, 'Senha idêntica à anterior.')
    usuario.senha_hash = hash_password(dados_nova_senha.senha)
    db.commit()
    db.refresh(usuario)
    return usuario


@router.post('/esqueci-senha')
def recuperar_senha(dados: EsqueciSenha, db: SessionDep):
    email = dados.email
    usuario = get_user_by_email(db, email)

    return {
        'message': (
            'Se o email estiver cadastrado, você receberá '
            'instruções para recuperar a senha.'
        ),
    }


@router.post('/test-token', response_model=UsuarioPublic)
def test_token(current_user: CurrentUsuario):
    """Test access token."""
    return current_user


def create_reset_token(user_id: int):
    expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode = {'user_id': user_id, 'exp': expire}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


@router.post('/redefinir-senha')
async def reset_password(dados_reset: RecuperacaoSenha, db: SessionDep):
    """Reseta a senha de um usuário utilizando um token de recuperação.

    Rota utilizada no botão de redefinição de senha enviado por email,
    diferente da rota /trocar-senha, a qual é chamada no front-end para
    trocar a senha do usuário logado

    Args:
    ----
        dados_reset (RecuperacaoSenha): Dados necessários para a recuperação da senha,
            incluindo o token e a nova senha.
        db (SessionDep): Sessão de banco de dados para realizar operações de persistência.

    Raises:
    ------
        HTTPException: Se o token for inválido ou expirado, ou se houver um erro na
            decodificação do token.

    Returns:
    -------
        dict: Mensagem de sucesso indicando que a senha foi redefinida com sucesso.

    """
    try:
        payload = jwt.decode(
            dados_reset.token, settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
        user_id = payload.get('user_id')
        if user_id is None:
            raise HTTPException(status_code=400, detail='Token inválido ou expirado.')
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail='Token expirado.')
    except jwt.exceptions.DecodeError:
        raise HTTPException(
            status_code=400,
            detail='Link inválido ou expirado. Solicite a recuperação de senha novamente.',
        )

    hashed_password = hash_password(dados_reset.nova_senha)
    usuario = db.get(Usuario, user_id)
    usuario.senha_hash = hashed_password
    db.commit()

    return {'message': 'Senha redefinida com sucesso.'}


@router.post('/trocar-senha')
def change_password(dados: TrocaSenha, db: SessionDep, current_user: CurrentUsuario):
    """Troca a senha do usuário logado.

    Args:
    ----
        dados (NovaSenha): Dados necessários para a troca de senha, incluindo a senha atual
            e a nova senha.
        db (SessionDep): Sessão de banco de dados para realizar operações de persistência.
        current_user (CurrentUsuario): Usuário autenticado.

    Raises:
    ------
        HTTPException: Se a senha atual fornecida não corresponder à senha do usuário autenticado.

    Returns:
    -------
        dict: Mensagem de sucesso indicando que a senha foi trocada com sucesso.

    """
    usuario = db.get(Usuario, current_user.id)
    if not verify_password(dados.senha_atual, usuario.senha_hash):
        raise HTTPException(status_code=400, detail='Senha atual incorreta.')

    usuario.senha_hash = hash_password(dados.nova_senha)
    db.commit()
    return {'message': 'Senha alterada com sucesso.'}