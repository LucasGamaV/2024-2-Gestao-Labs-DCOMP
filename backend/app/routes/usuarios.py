from fastapi import APIRouter, HTTPException
from sqlmodel import select

from app.database.enums import TipoUsuario
from app.database.models import (
    Administrador,
    AdministradorCreate,
    AdministradorPublic,
    Tecnico,
    TecnicoCreate,
    TecnicoPublic,
    Usuario,
    UsuarioCreate,
    Aluno,
    AlunoCreate,
    AlunoPublic,
    Professor,
    ProfessorCreate,
    ProfessorPublic,
    UsuarioPublic,
)
from app.deps import (
    CurrentUsuario,
    SessionDep,
)
from app.services.usuarios import (
    create_funcionario,
    create_usuario,
    usuario_especifico,
)

router = APIRouter()

@router.get('/', response_model=list[UsuarioPublic])
def read_usuarios(*, db: SessionDep):
    """Lê todos os usuários. Útil para verificação."""
    stmt = select(Usuario)
    return db.exec(stmt).all()


@router.post('/', response_model=UsuarioPublic)
def post_usuario(usuario: UsuarioCreate, db: SessionDep):
    """Cria um usuário novo. Útil para verificação."""
    return create_usuario(db, usuario)


@router.get('/perfil', response_model=AlunoPublic | TecnicoPublic | AdministradorPublic | ProfessorPublic)
def read_usuario_perfil(db: SessionDep, current_usuario: CurrentUsuario):
    """Retorna o atual usuário."""
    usuario, tipo_usuario = usuario_especifico(db, current_usuario)
    if tipo_usuario == TipoUsuario.tecnico:
        usuario = Tecnico.model_validate(
            usuario,
        )
    return usuario


@router.post('/tecnicos/', response_model=TecnicoPublic)
def create_tecnico(
    tecnico: TecnicoCreate,
    db: SessionDep,
):
    return create_funcionario(db, TipoUsuario.tecnico, tecnico)


@router.post('/administradores/', response_model=AdministradorPublic)
def create_administrador(
    administrador: AdministradorCreate,
    db: SessionDep,
):
    return create_funcionario(db, TipoUsuario.administrador, administrador)


@router.post('/professores/', response_model=ProfessorPublic)
def create_gestor(
    professor: ProfessorCreate,
    db: SessionDep,
):
    return create_funcionario(db, TipoUsuario.professor, professor)


@router.get("/tecnicos", response_model=list[TecnicoPublic])
def get_tecnicos(db: SessionDep):
    """
    Retorna uma lista de técnicos.
    """
    statement = select(Tecnico)
    results = db.exec(statement).all()

    if not results:
        raise HTTPException(status_code=404, detail="Nenhum técnico encontrado.")
    
    return results


@router.get("/administradores", response_model=list[AdministradorPublic])
def get_administradores(db: SessionDep):
    """
    Retorna uma lista de administradores.
    """
    statement = select(Administrador)
    results = db.exec(statement).all()

    if not results:
        raise HTTPException(status_code=404, detail="Nenhum administrador encontrado.")
    
    return results


@router.get("/professores", response_model=list[ProfessorPublic])
def get_professores(db: SessionDep):
    """
    Retorna uma lista de professores.
    """
    statement = select(Professor)
    results = db.exec(statement).all()

    if not results:
        raise HTTPException(status_code=404, detail="Nenhum professor encontrado.")
    
    return results


@router.post('/alunos/', response_model=AlunoPublic)
def create_aluno(aluno: AlunoCreate, db: SessionDep):
    usuario = create_usuario(db, aluno)
    aluno_db = Aluno.model_validate(
        aluno,
        update={'usuario_id': usuario.id},
    )
    db.add(aluno_db)
    db.commit()
    db.refresh(aluno_db)
    return aluno_db

