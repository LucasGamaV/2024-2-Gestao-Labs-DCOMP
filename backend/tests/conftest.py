from collections.abc import Generator

import pytest
from sqlmodel import Session, StaticPool, create_engine
from starlette.testclient import TestClient

from app.database.models import SQLModel
from app.deps import get_db
from app.main import app


@pytest.fixture(name='session')
def session_fixture() -> Generator:
    """Create a new session as a test fixture."""
    engine = create_engine(
        'sqlite://',
        connect_args={'check_same_thread': False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)

    with Session(engine) as session:
        yield session


@pytest.fixture(name='client')
def client_fixture(session: Session) -> Generator:
    """Create a new HTTP client as a test fixture."""
    def get_db_override() -> Session:
        return session

    app.dependency_overrides[get_db] = get_db_override

    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()