from sqlmodel import Session, create_engine, select, func
from datetime import datetime
from enum import Enum

from sqlalchemy import Engine

from app.database.enums import StatusComputador, TipoSistemaOperacional
from app.config import settings
from app.database.models import (
    SQLModel,
    Laboratorio,
    Usuario,
    Computador,
    Status,
    Administrador,
    Tecnico,
    Professor,
    Aluno
)

from app.services.usuarios import hash_password


# Connection
def get_engine() -> Engine:
    return create_engine(settings.DATABASE_URL)


engine = get_engine()


# Initialization
def init_db() -> None:
    SQLModel.metadata.create_all(engine)
    with Session(engine) as db:
        if not has_any(Computador, db):
            populate_db(db)


# Helpers
def has_any(table: type, db: Session) -> bool:
    stmt = func.count(table.id)
    return db.exec(stmt).scalar() or 0


# Populate Functions
def populate_status(db: Session):
    data = [
        {"nome": StatusComputador.disponivel.value, "descricao": "Disponível"},
        {"nome": StatusComputador.em_manutencao.value, "descricao": "Em Manutenção"},
    ]

    db.add_all([Status(**item) for item in data])


def populate_laboratorios(db: Session):
    admin_1 = db.get(Administrador, 1)
    admin_2 = db.get(Administrador, 2)

    lab_1 = Laboratorio(
        local='STI',
        nome='Lab de Extensão 1',
        administrador=admin_1,
    )

    lab_2 = Laboratorio(
        local='CCET',
        nome='Lab de Hardware',
        administrador=admin_1,
    )

    lab_3 = Laboratorio(
        local='STI',
        nome='Lab de Extensão 2',
        administrador=admin_2,
    )
    
    db.add_all([lab_1, lab_2, lab_3])


def populate_usuario(db: Session) -> None:
    data = [
        {
            # Professor
            'nome': 'Rodolfo Botto',
            'email': 'rodolfo@exemplo.com',
            'senha_hash': hash_password('rodolfo'),
        },
        {
            # Professor
            'nome': 'Ivone Lara',
            'email': 'ivone@exemplo.com',
            'senha_hash': hash_password('ivone'),
        },
        {
            # Técnico
            'nome': 'Patrícia Menezes',
            'email': 'patricia@exemplo.com',
            'senha_hash': hash_password('patricia'),
        },
        {
            # Técnico
            'nome': 'José Nilton',
            'email': 'nilton@exemplo.com',
            'senha_hash': hash_password('nilton'),
        },
        {
            # Administrador
            'nome': 'Júlio César',
            'email': 'julio@exemplo.com',
            'senha_hash': hash_password('julio'),
        },
        {
            # Administrador
            'nome': 'Caio Conceição',
            'email': 'caio@exemplo.com',
            'senha_hash': hash_password('caio'),
        },
        {
            # Aluno
            'nome': 'Gustavo Paiva',
            'email': 'gustavo@exemplo.com',
            'senha_hash': hash_password('gustavo'),
        },
        {
            # Aluno
            'nome': 'Luísa Mahin',
            'email': 'luisa@exemplo.com',
            'senha_hash': hash_password('luisa'),
        },
    ]

    db.add_all([Usuario(**elem) for elem in data])


def populate_admin(db: Session) -> None:
    usuario_1 = db.exec(select(Usuario).where(Usuario.nome == 'Júlio César')).first()
    usuario_2 = db.exec(select(Usuario).where(Usuario.nome == 'Caio Conceição')).first()

    admin_1 = Administrador(
        matricula='4444',
        usuario=usuario_1,
    )
    admin_2 = Administrador(
        matricula='3333',
        usuario=usuario_2,
    )

    db.add_all([admin_1, admin_2])


def populate_tecnico(db: Session) -> None:
    usuario_1 = db.exec(select(Usuario).where(Usuario.nome == 'José Nilton')).first()
    admin_1 = db.get(Administrador, 1)
    tecnico_1 = Tecnico(
        matricula='2021',
        usuario=usuario_1,
        administrador=admin_1,
    )

    usuario_2 = db.exec(select(Usuario).where(Usuario.nome == 'Patrícia Menezes')).first()
    admin_2 = db.get(Administrador, 2)
    tecnico_2 = Tecnico(
        matricula='1010',
        usuario=usuario_2,
        administrador=admin_2,
    )

    db.add_all([tecnico_1, tecnico_2])


def populate_professor(db: Session) -> None:
    usuario_1 = db.exec(select(Usuario).where(Usuario.nome == 'Rodolfo Botto')).first()
    admin_1 = db.get(Administrador, 1)
    professor_1 = Professor(
        matricula='8964',
        usuario=usuario_1,
        administrador=admin_1,
    )

    usuario_2 = db.exec(select(Usuario).where(Usuario.nome == 'Ivone Lara')).first()
    admin_2 = db.get(Administrador, 2)
    professor_2 = Professor(
        matricula='5252',
        usuario=usuario_2,
        administrador=admin_2,
    )

    db.add_all([professor_1, professor_2])


def populate_aluno(db: Session) -> None:
    usuario_1 = db.exec(select(Usuario).where(Usuario.nome == 'Luísa Mahin')).first()
    aluno_1 = Aluno(
        matricula='7777',
        usuario=usuario_1,
    )

    db.add(aluno_1)


def populate_computadores(db: Session):
    laboratorios = db.exec(select(Laboratorio)).all()
    status = db.exec(select(Status)).all()
    tecnicos = db.exec(select(Status)).all()
    data = [
        {
            "patrimonio": "12345",
            "hostname": "PC01",
            "marca": "Dell",
            "ano_aquisicao": 2020,
            "sistema_operacional": TipoSistemaOperacional.windows.value,
            "status_id": status[0].id,
            "laboratorio_id": laboratorios[0].id,
            "tecnico_id": tecnicos[0].id,
            "data_ultima_alteracao": datetime.now(),
            "dias_desde_alteracao": 0,
        },
        {
            "patrimonio": "67890",
            "hostname": "PC02",
            "marca": "HP",
            "ano_aquisicao": 2019,
            "sistema_operacional": TipoSistemaOperacional.linux.value,
            "status_id": status[1].id,
            "laboratorio_id": laboratorios[1].id,
            "tecnico_id": tecnicos[1].id,
            "data_ultima_alteracao": datetime.now(),
            "dias_desde_alteracao": 5,
        },
    ]
    db.add_all([Computador(**item) for item in data])


def populate_db(db: Session) -> None:
    populators = [
        populate_usuario,
        populate_admin,
        populate_tecnico,
        populate_aluno,
        populate_professor,
        populate_status,
        populate_laboratorios,
        populate_computadores,
    ]
    for populator in populators:
        populator(db)
        db.commit()

