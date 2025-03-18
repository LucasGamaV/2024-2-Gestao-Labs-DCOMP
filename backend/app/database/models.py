from datetime import date
from typing import List, Optional

from pydantic import EmailStr
from sqlmodel import Field, Relationship, SQLModel, func
from datetime import datetime

from app.database.enums import (
    TipoUsuario,
    TipoAlteracao,
    StatusComputador,
    TipoSistemaOperacional,
)

# --------------------------------------------------------------------------------
# Usuário

class UsuarioBase(SQLModel):
    nome: str
    email: EmailStr = Field(unique=True, index=True)


class UsuarioCreate(UsuarioBase):
    senha: str | None = None


class Usuario(UsuarioBase, table=True):
    __tablename__ = "usuario"

    id: int | None = Field(default=None, primary_key=True)
    senha_hash: str | None = None

    relato_problemas: list["RelatoProblema"] = Relationship(back_populates="usuario")


class UsuarioPublic(UsuarioBase):
    id: int


# --------------------------------------------------------------------------------
# Administrador

class AdministradorBase(SQLModel):
    matricula: str


class Administrador(AdministradorBase, table=True):
    __tablename__ = "administrador"

    id: int | None = Field(default=None, primary_key=True)
    usuario_id: int = Field(index=True, foreign_key="usuario.id")

    usuario: 'Usuario' = Relationship()
    professores: list['Professor'] = Relationship(back_populates='administrador')
    tecnicos: list['Tecnico'] = Relationship(back_populates='administrador')
    laboratorios: list['Laboratorio'] = Relationship(back_populates='administrador')


class AdministradorCreate(AdministradorBase, UsuarioCreate):
    pass


class AdministradorPublic(AdministradorBase):
    id: int
    usuario: 'Usuario'


# --------------------------------------------------------------------------------
# Técnico

class TecnicoBase(SQLModel):
    administrador_id: int = Field(foreign_key='administrador.id')
    matricula: str


class Tecnico(TecnicoBase, table=True):
    __tablename__ = "tecnico"

    id: int | None = Field(default=None, primary_key=True)
    usuario_id: int = Field(index=True, foreign_key="usuario.id")
    administrador_id: int = Field(index=True, foreign_key="administrador.id")

    usuario: 'Usuario' = Relationship()
    administrador: 'Administrador' = Relationship(back_populates='tecnicos')
    computadores: list["Computador"] = Relationship(back_populates="tecnico")
    relato_problemas: list["RelatoProblema"] = Relationship(back_populates="tecnico")
    historico_alteracoes: list["HistoricoAlteracao"] = Relationship(back_populates="tecnico")


class TecnicoCreate(TecnicoBase, UsuarioCreate):
    pass


class TecnicoPublic(TecnicoBase):
    id: int
    usuario: 'Usuario'

# --------------------------------------------------------------------------------
# Professor

class ProfessorBase(SQLModel):
    administrador_id: int = Field(foreign_key='administrador.id')
    matricula: str


class Professor(ProfessorBase, table=True):
    __tablename__ = "professor"

    id: int | None = Field(default=None, primary_key=True)
    usuario_id: int = Field(index=True, foreign_key="usuario.id")
    administrador_id: int = Field(index=True, foreign_key="administrador.id")

    usuario: 'Usuario' = Relationship()
    administrador: 'Administrador' = Relationship(back_populates='professores')


class ProfessorCreate(ProfessorBase, UsuarioCreate):
    pass


class ProfessorPublic(ProfessorBase):
    id: int
    usuario: 'Usuario'


# --------------------------------------------------------------------------------
# Funcionario

Funcionario = Administrador | Tecnico | Professor
FuncionarioCreate = AdministradorCreate | TecnicoCreate | ProfessorCreate
FuncionarioPublic = AdministradorPublic | TecnicoPublic | ProfessorPublic

# --------------------------------------------------------------------------------
# Aluno

class AlunoBase(SQLModel):
    matricula: str


class Aluno(AlunoBase, table=True):
    __tablename__ = "aluno"

    id: int | None = Field(default=None, primary_key=True)
    usuario_id: int = Field(index=True, foreign_key="usuario.id")

    usuario: 'Usuario' = Relationship()


class AlunoCreate(AlunoBase, UsuarioCreate):
    pass


class AlunoPublic(AlunoBase):
    id: int
    usuario: 'Usuario'


# --------------------------------------------------------------------------------
# Laboratório

class LaboratorioBase(SQLModel):
    nome: str
    local: str


class Laboratorio(LaboratorioBase, table=True):
    __tablename__ = "laboratorio"

    id: int | None = Field(default=None, primary_key=True)
    administrador_id: int = Field(index=True, foreign_key="administrador.id")

    computadores: list["Computador"] = Relationship(back_populates="laboratorio")
    administrador: Administrador = Relationship(back_populates="laboratorios")


class LaboratorioCreate(LaboratorioBase):
    administrador_id: int


class LaboratorioPublic(LaboratorioBase):
    id: int
    computadores: list["Computador"]
    administrador: "Administrador"

# --------------------------------------------------------------------------------
# Status

class StatusBase(SQLModel):
    nome: StatusComputador
    descricao: str


class Status(StatusBase, table=True):
    __tablename__ = "status"

    id: int | None = Field(default=None, primary_key=True)

    computadores: list["Computador"] = Relationship(back_populates="status")
    historico_alteracoes: list["HistoricoAlteracao"] = Relationship(back_populates="status")


class StatusCreate(StatusBase):
    pass


class StatusPublic(StatusBase):
    id: int

class StatusDesc(SQLModel):
    descricao: str

# --------------------------------------------------------------------------------
# Computador

class ComputadorBase(SQLModel):
    patrimonio: str
    hostname: str
    marca: str
    ano_aquisicao: int
    sistema_operacional: TipoSistemaOperacional
    data_ultima_alteracao: date | None = None
    dias_desde_alteracao: int = Field(default=0)


class Computador(ComputadorBase, table=True):
    __tablename__ = "computador"

    id: int | None = Field(default=None, primary_key=True)
    status_id: int | None = Field(default=None, foreign_key="status.id")
    laboratorio_id: int | None = Field(default=None, foreign_key="laboratorio.id")
    tecnico_id: int | None = Field(default=None, foreign_key="tecnico.id")

    status: "Status" = Relationship(back_populates="computadores")
    laboratorio: "Laboratorio" = Relationship(back_populates="computadores")
    tecnico: "Tecnico" = Relationship(back_populates="computadores")
    historico_alteracoes: list["HistoricoAlteracao"] = Relationship(back_populates="computador")
    relato_problemas: list["RelatoProblema"] = Relationship(back_populates="computador")


class ComputadorCreate(ComputadorBase):
    status_id: int
    laboratorio_id: int
    tecnico_id: int


class ComputadorPublic(ComputadorBase):
    id: int
    status: "Status"
    laboratorio: "Laboratorio"
    tecnico: "Tecnico"

class ComputadorCreateNew(SQLModel):
    patrimonio: str
    hostname: str
    marca: str
    ano_aquisicao: int
    sistema_operacional: TipoSistemaOperacional
    data_ultima_alteracao: date
    status_nome: str
    status_descricao: str
    laboratorio_nome: str
    laboratorio_local: str
    tecnico_id: int

# --------------------------------------------------------------------------------
# Histórico de Alteração

class HistoricoAlteracaoBase(SQLModel):
    tipo_alteracao: TipoAlteracao
    data_alteracao: date
    observacao: Optional[str]


class HistoricoAlteracao(HistoricoAlteracaoBase, table=True):
    __tablename__ = "historico_alteracao"

    id: int | None = Field(default=None, primary_key=True)
    computador_id: int | None = Field(default=None, foreign_key="computador.id")
    tecnico_id: int | None = Field(default=None, foreign_key="tecnico.id")
    status_id: int | None = Field(default=None, foreign_key="status.id")

    computador: "Computador" = Relationship(back_populates="historico_alteracoes")
    tecnico: "Tecnico" = Relationship(back_populates="historico_alteracoes")
    status: "Status" = Relationship(back_populates="historico_alteracoes")


class HistoricoAlteracaoCreate(HistoricoAlteracaoBase):
    computador_id: int
    tecnico_id: int
    status_id: int


class HistoricoAlteracaoPublic(HistoricoAlteracaoBase):
    id: int
    computador: "Computador"
    tecnico: "Tecnico"
    status: "Status"

class HistoricoAlteracaoCreateRequest(HistoricoAlteracaoBase):
    patrimonio: str
    sistema_operacional: str
    marca: str
    laboratorio_local: str
    laboratorio_nome: str
    status_nome: str
    status_descricao: str
    tecnico_id: int

# --------------------------------------------------------------------------------
# Relato de Problema

class RelatoProblemaBase(SQLModel):
    data_relato: date = Field(default=func.current_date())
    usuario_id: int = Field(foreign_key='usuario.id')
    descricao: str | None = None
    computador_patrimonio: str | None


class RelatoProblema(RelatoProblemaBase, table=True):
    __tablename__ = "relato_problema"

    id: int | None = Field(default=None, primary_key=True)
    computador_id: int | None = Field(default=None, foreign_key="computador.id")
    usuario_id: int | None = Field(default=None, foreign_key="usuario.id")
    tecnico_id: Optional[int] = Field(default=None, foreign_key="tecnico.id")
    auditada: bool = Field(default=False)
    data_auditada: date | None = None
    aceita: bool | None = None

    computador: "Computador" = Relationship(back_populates="relato_problemas")
    usuario: "Usuario" = Relationship(back_populates="relato_problemas")
    tecnico: Optional["Tecnico"] = Relationship()


class RelatoProblemaCreate(RelatoProblemaBase):
    computador_id: int
    usuario_id: int
    tecnico_id: Optional[int]


class RelatoProblemaPublic(RelatoProblemaBase):
    id: int
    computador: "Computador"
    usuario: "Usuario"
    auditada: bool
    tecnico: Optional["Tecnico"]

class RelatoProblemaUpdate(SQLModel):
    aceita: bool
    tecnico_id: int
    auditada: bool
    data_auditada: date

# --------------------------------------------------------------------------------
# Auth


class Token(SQLModel):
    """Payload JSON contendo access token."""

    access_token: str
    token_type: str = 'bearer'


class GoogleToken(SQLModel):
    token: str


class TokenPayload(SQLModel):
    """Informações no JWT."""

    sub: int
    id_especifico: int
    email: EmailStr
    tipo_usuario: TipoUsuario
    nome: str
    exp: int


class NovaSenha(SQLModel):
    usuario_id: int
    senha: str = Field(min_length=8)

class EsqueciSenha(SQLModel):
    email: str

class RecuperacaoSenha(SQLModel):
    nova_senha: str
    token: str

class TrocaSenha(SQLModel):
    senha_atual: str
    nova_senha: str = Field(min_length=8)