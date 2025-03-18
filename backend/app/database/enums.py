from enum import Enum, EnumType

def enum_values(enum: EnumType):
    return [variant.value for variant in list(enum)]

# Tipos de usuários
class TipoUsuario(str, Enum):
    aluno = "aluno"
    professor = "professor"
    administrador = "administrador"
    tecnico = "tecnico"

# Tipos de alterações realizadas no histórico
class TipoAlteracao(str, Enum):
    cadastro = "Cadastro"
    manutencao = "Manutenção"
    alteracao = "Alteração"
    exclusao = "Exclusão"

# Status dinâmicos para computadores
class StatusComputador(str, Enum):
    disponivel = "Disponível"
    em_manutencao = "Em manutenção"
    reservado = "Reservado"
    desativado = "Desativado"

class TipoSistemaOperacional(str, Enum):
    macos = "macos"
    linux = "linux"
    windows = "windows"

